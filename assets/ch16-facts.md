# Ch16 事实表 — Fleet:可恢复的计划执行内核

- **基准**:octos main @ `9c157101`(`9c1571016e5ea86955b4b3486c04f0359dfff339`),采集日期 **2026-09-03**
- **源仓库只读**:本文所有命令均为只读(`wc -l` / `grep -n` / `sed -n` / `git show`),未修改 octos 仓库;本文件是本轮唯一产出
- **来源 spec**:`specs/ch16-fleet.spec.md`「决策」段;grant 四类型与 `assets/ch07-facts.md` §4 交叉核对(两处行号在 9c157101 下一致)

以下命令的工作目录均为 octos 源仓库根目录(记作 `$R`;实际值 `/Users/zhangalex/Work/Projects/FW/octos`)。

## 1. 两 crate 逐文件清单(13 个源文件,23,730 行)

```bash
wc -l crates/octos-fleet/src/*.rs crates/octos-fleet-worker/src/*.rs
head -1 crates/octos-fleet/src/<file>.rs   # 首行文档
```

### octos-fleet(7 文件,16,888 行)

| 文件 | 行数 | 首行 `//!` 文档(原文) |
|---|---|---|
| `digest.rs` | 861 | `//! # The controller digest — a bounded read over the finding log` |
| `fleet.rs` | 3062 | ``//! `Fleet` — the ergonomic plan-management API over [`FleetKernelStore`].`` |
| `grant.rs` | 714 | ``//! [`WorkerGrant`] — the operator-supplied capability grant for one fleet`` |
| `lib.rs` | 68 | `//! # octos-fleet — the fleet kernel store` |
| `records.rs` | 808 | `//! Durable record types for the fleet kernel store.` |
| `sqlite_ledger.rs` | 6360 | `// SQLite-backed durable ledger for goals, tasks, findings, and escalations.`(注:首行是 `//`,非 `//!`) |
| `store.rs` | 5015 | ``//! `FleetKernelStore` — the durable transactional core of the fleet`` |

`lib.rs` 开篇自述:唯一依赖 `redb`/`serde`/`tokio`/`uuid`/`eyre`/`octos-core`,零 LLM / `octos-agent` 依赖,每次状态转移是单个 `begin_write` 内「读 → CAS 谓词 → 写下一态 + 预算结算 + outbox 追加」。

### octos-fleet-worker(6 文件,6,842 行)

| 文件 | 行数 | 首行 `//!` 文档(原文) |
|---|---|---|
| `closed_registry.rs` | 705 | `//! Module 1 — the operator-granted, replay-safe worker tool registry (**the` |
| `escalate.rs` | 293 | `//! The always-on `escalate` safety valve (PR B).` |
| `lib.rs` | 396 | `//! octos-fleet-worker — the closed, non-interactive fleet task worker.` |
| `pool.rs` | 2186 | `//! Module 3 — [`FleetWorkerPool`]: the bounded launcher.` |
| `testutil.rs` | 687 | `//! Shared test helpers: in-memory-ish store/fleet builders and scripted` |
| `worker.rs` | 2575 | `//! Module 2 — `run_attempt`: the per-attempt executor.` |

## 2. `records.rs` 记录类型行号(spec 锚点全部命中)

```bash
grep -n 'SCHEMA_VERSION\|pub enum FleetRecord\|pub struct FleetBudget\|pub struct Lease\b\|pub struct Attempt\b\|pub struct DurablePlan' crates/octos-fleet/src/records.rs
sed -n '33p;119p;145p;250p;256p;313p' crates/octos-fleet/src/records.rs
```

| 符号 | 行号 | 说明 |
|---|---|---|
| `pub const SCHEMA_VERSION: u32 = 3` | **33** | 每行持久化数据携带;更高版本行加载为 `Ok(None)`(store 只丢 `schema_version > SCHEMA_VERSION` 的行,records.rs:571) |
| `pub struct FleetBudget` | **119** | 预算;在每次转移的写事务内结算 |
| `pub struct FleetRecord` | **145** | fleet 行(`FleetStatus`:41;含 `generation` 围栏、keeper-wake 元数据 :152) |
| `pub struct Lease` | **250** | 租约(`owner_epoch` 等) |
| `pub struct Attempt` | **256** | 尝试行(`AttemptStatus`:94;`generation`、`lease`) |
| `pub struct DurablePlan` | **313** | 持久计划(`PlanTask`:333、`AcceptanceCriterion`:356、`Verifier`:367、`EvidenceRef`:378) |

其余记录:`FleetChildRecord`:193、`EscalationRequest`:238、`ChildResultSnapshot`:290、`AcceptanceVerdict`:302、`DecisionEntry`:388、`DecisionKind`:398、`FindingStatus`:420、`Finding`:447、**`OutboxEvent`:524**(真实 claim/ack 协议的持久 outbox 事件,`FleetEventKind`:545)。

```bash
grep -n 'pub struct\|pub enum' crates/octos-fleet/src/records.rs
```

## 3. `fleet.rs:190` — `Fleet`(计划管理 API)

```bash
grep -n 'pub struct Fleet\b\|pub async fn' crates/octos-fleet/src/fleet.rs
```

| 符号 | 行号 |
|---|---|
| `pub struct Fleet` | **190** |
| `create` / `create_with_workspace_provenance` | 210 / 240 |
| `view` → `FleetView` | 324 |
| `ready_tasks(now_ms)` | 375 |
| `apply_edit` | 402 |
| `record_outcome` | 542 |
| `is_complete` | 583 |
| `summary` → `FleetSummary` | 595 |

`Fleet` 在 `FleetKernelStore` 之上组合 CAS ops 成整计划操作,不改语义——keeper + `goal_get`/`goal_update` 工具面向的表层(见 `lib.rs` 模块文档)。

## 4. `store.rs` — 事务 CAS ops 与恢复协调

```bash
grep -n 'pub async fn\|pub struct ReconcileReport' crates/octos-fleet/src/store.rs
grep -n 'CAS state transitions\|generation\|owner_epoch' crates/octos-fleet/src/store.rs | head -30
```

关键行号:

| 符号 / 分区 | 行号 | 说明 |
|---|---|---|
| `pub struct ReconcileReport` | 160 | 恢复对账报告 |
| `pub async fn create_fleet` | 244 | `generation: 0` 起步 |
| `pub async fn add_child` | 503 | |
| `pub async fn resolve_and_collect_ready` | 676 | |
| `pub async fn cancel_fleet` | 838 | |
| **CAS 分区注释 `---- CAS state transitions ----`** | **880** | |
| `pub async fn launch_child` | **889** | 启动 CAS:child `Launching` + 新 `Leased` attempt(`AttemptStatus::Leased`:997,`Lease{owner_epoch}`:998),generation 取 fleet 当前值 |
| `pub async fn mark_running` | **1053** | CAS `Leased → Running`,四段谓词含 `attempt.generation == fleet.generation`(1122) |
| `pub async fn complete_child` | **1157** | CAS 谓词:`Running` + generation 相等(:1236)+ `lease.owner_epoch` 匹配(:1237),成功写结果并结算预算 |
| `pub async fn record_escalation` | 1336 | 同样校验 generation(:1409)与 lease(:1410) |
| `pub async fn replan` | 1512 | `expected_revision` 修订 CAS,递增 revision |
| `pub async fn retitle_task` / `set_task_grant` | 1804 / 1898 | 均为 revision-CAS |
| `pub async fn deny_escalation` | 2025 | 与 grant 的 in-txn `Blocked` CAS 互补(:2094) |
| `pub async fn reconcile(now_ms, owner_epoch)` | **2191** | 启动恢复:对账租约过期/僵死 attempt,返回 `ReconcileReport` |
| `pub async fn append_event` | 2518 | outbox 追加 |
| `pub async fn claim_next` / `ack` | **2547 / 2603** | outbox 真实 claim/ack 协议 |
| `append_decision` / `list_decisions` | 2648 / 2697 | |

模块文档(store.rs:6-8)即状态机定义:读当前行 → 检查 CAS 谓词(status / generation / lease)→ 写下一态。CAS 拒绝是*值*而非错误:`LaunchOutcome`/`CompleteOutcome`/`mark_running` 的 `Superseded`(store.rs:59/75/102)。outbox 事件在各自的写事务内追加(:2806 注释),无跨库窗口。

## 5. `grant.rs` 四类型(与 Ch7 交叉)

```bash
grep -n 'pub const BASE_TOOLS\|pub enum NetworkGrant\|pub enum FsGrant\|pub struct WorkerGrant\|pub enum GrantError\|pub fn validate\|pub fn minimal' crates/octos-fleet/src/grant.rs
```

| 类型 | 行号 | 与 `ch07-facts.md` §4 的一致性 |
|---|---|---|
| `pub const BASE_TOOLS: &[&str]` | 27 | worker `ALLOWED` 的来源(closed_registry.rs:43 引用) |
| `NetworkGrant`(enum) | **76** | `None` / `Hosts(Vec<String>)` / `Full` — 同 ch07:76 |
| `FsGrant`(enum) | **127** | `Workspace` / `Host` — 同 ch07:127 |
| `WorkerGrant`(struct) | **151** | `network`:154、`tools`:157、`fs`:160、`write_paths`:179(#1976)、`create_only`:189 — 同 ch07:151;`minimal()`:207 |
| `GrantError`(enum) | **359** | 变体同 ch07:359(`UnknownTool`、`WebToolWithoutNetwork`、`EmptyHostAllowlist`、#1976 三个围栏错误、`InvalidWritePath`) |

`validate()` 在 **247**(同 ch07:247),`validate_write_path_pattern` 在 **307**(同 ch07:307);文件 714 行,与 ch07-facts 记录一致。grant 语义本章不展开——**详见第 7 章**。

## 6. worker 侧四模块关键符号

```bash
grep -n 'pub fn\|pub async fn\|pub struct\|pub enum\|pub const' crates/octos-fleet-worker/src/{closed_registry,worker,pool,escalate}.rs
grep -n 'pub use' crates/octos-fleet-worker/src/lib.rs
```

### 6.1 `closed_registry.rs` — replay-safe 封闭注册表

| 符号 | 行号 |
|---|---|
| `pub const ALLOWED: &[&str]` = `octos_fleet::BASE_TOOLS` | 43 |
| `pub fn build_fleet_worker_registry(...)` | **92** |

从空注册表按 `WorkerGrant.sorted_tools()` 装配封闭工具集;grant 外工具不可达,重放(replay)时装配结果一致。

### 6.2 `worker.rs` — `run_attempt`

| 符号 | 行号 |
|---|---|
| `pub struct WorktreeContext` | 67 |
| `pub enum AttemptOutcome` | **146** |
| `pub async fn run_attempt(...)` | **177** |

`AttemptOutcome` 变体(worker.rs:146-175,一次 attempt 的全部终态):`Completed{verdict: AcceptanceVerdict}` / `Superseded`(CAS 落败,结果丢弃而非报错)/ `Aborted{reason}`(`mark_running` Superseded,池解除守卫)/ `RecordError{reason}`(store CAS 本身报错,守卫保持armed,交给恢复)/ `Escalated{request: EscalationRequest}`(PR B:非终局让位,child `Blocked` + `pending_escalation`,由 keeper `goal_grant`/`goal_deny` 决断)。

### 6.3 `pool.rs` — `FleetWorkerPool` 有界启动

| 符号 | 行号 |
|---|---|
| `pub struct PoolConfig` | **58**(`global_concurrency` / `per_fleet_concurrency` / `deadline` / `owner_epoch` / `lease_ttl_ms` / `projected_tokens` / `workspace_root` / `keeper_profile_id` / `repo_git_write_supported`) |
| `pub struct Dispatched` | 98(内含 `launch: LaunchOutcome`,:42 起) |
| `pub struct FleetWorkerPool` | **109** |
| `pub fn new` / `keeper_profile_id` / `projected_tokens` | 142 / 197 / 204 |
| `pub async fn dispatch(fleet_id, task_id)` | **233** |

### 6.4 `escalate.rs` — 常开安全阀(PR B)

| 符号 | 行号 |
|---|---|
| `pub type EscalationSlot = Arc<Mutex<Option<EscalationRequest>>>` | 34 |
| `pub struct EscalateTool` | **37** |
| `pub fn new(slot: EscalationSlot)` | 42 |

## 7. 文档依据(`docs/`,3 份)

```bash
wc -l docs/FLEET-KERNEL-V1-SPEC.md docs/FLEET-KERNEL-FOUNDATION-SPEC.md docs/FLEET-RUNTIME-ADR.md
```

| 文档 | 行数 |
|---|---|
| `docs/FLEET-KERNEL-V1-SPEC.md` | 347 |
| `docs/FLEET-KERNEL-FOUNDATION-SPEC.md` | 219 |
| `docs/FLEET-RUNTIME-ADR.md` | 176 |

`lib.rs` 模块文档引用的就是 `docs/FLEET-KERNEL-V1-SPEC.md`(PR 1)。

## 8. 提交锚点与 `fleet_wake.rs`

```bash
git log --oneline -1 eadee2ae
git log --oneline -1 8fc66202
wc -l crates/octos-cli/src/autonomy/fleet_wake.rs
```

| 项 | 值 |
|---|---|
| `eadee2ae` | `feat(fleet): master-granted worker permissions (WorkerGrant) (#1875)` |
| `8fc66202` | `feat(fleet): PR C — worktree workers, thin on the operator grant (#1881)` |
| `fleet_wake.rs` | `crates/octos-cli/src/autonomy/fleet_wake.rs`,1807 行(outbox → keeper 唤醒,与 Ch12 互引) |
| `sqlite_ledger.rs` | `pub struct GoalLedger` 在 sqlite_ledger.rs:13 —— 本章只交代它是 Ch18 goal keeper 的持久账本,不展开 |

## 9. 数字汇总

- octos-fleet:**7 文件 / 16,888 行**;octos-fleet-worker:**6 文件 / 6,842 行**;合计 13 文件 / 23,730 行
- 关键符号:records.rs 6 个 spec 锚点 + 13 个其余记录类型;fleet.rs `Fleet` + 8 个 API;store.rs 12 个事务/恢复/outbox 符号;grant.rs 4 类型 + 2 校验函数;worker 四模块 12 个 pub 符号
- docs:3 份;提交锚点:2 个(均在 main 可达)
