# Ch12 并发模型 — 事实表(三层并发原语)

- **源码基准**: octos main @ `9c157101` (2026-09-02)
- **事实表日期**: 2026-09-03
- **方法**: 每项附生成命令,逐条可复跑;交付前抽查复跑两轮一致。
- **命令工作目录**: octos 源码仓库根目录(下文所有命令相对该目录)。
- **「关键符号」口径**: `grep -c 'pub fn\|pub struct\|pub enum\|pub trait\|pub(crate) fn\|pub(crate) struct\|pub(crate) enum\|pub(crate) trait'`(本仓库大量模块用 `pub(crate)`,故统一口径含两者)。

---

## 0. 决策锚点(spec 决策段,黑板第 16 条)

- 并发模型三层调度:① Tokio 层(session actor、信号量限流、工具 `join_all`、优雅关停);
  ② supervisor 层(`crates/octos-cli/src/autonomy/` 十个文件、约 4.5 万行);
  ③ peer≈进程模型(`crates/octos-cli/src/peers/mod.rs`)与 fleet 的 lease/attempt 状态机
  (`crates/octos-fleet/src/records.rs:250-256` `Lease` / `Attempt`)。
- 层内边界:peer/lease 层细节「详见第 16 章」「详见第 18 章」,本章只交代其并发原语角色。
- 逐层合计见文末汇总(§5)。

---

## 1. Tokio 层(session actor / 信号量限流 / 工具 join_all / 优雅关停)

### 1.1 文件清单与行数

```
wc -l crates/octos-cli/src/session_actor.rs \
      crates/octos-cli/src/commands/gateway/gateway_runtime.rs \
      crates/octos-agent/src/task_supervisor.rs \
      crates/octos-agent/src/agent/execution.rs \
      crates/octos-cli/src/config.rs
```

| 文件 | 行数 | 首行 `//!` 文档 |
|---|---|---|
| `crates/octos-cli/src/session_actor.rs` | 10094 | 「Session actor: per-session tokio task that owns tools and processes messages.」 |
| `crates/octos-cli/src/commands/gateway/gateway_runtime.rs` | 2420 | (无模块级 `//!`;首行 `use tokio::sync::{Mutex, Notify, RwLock, Semaphore}`) |
| `crates/octos-agent/src/task_supervisor.rs` | 4120 | (无首行 `//!`;首个 doc 注释属 `RegisterTaskError`)(待 writer 核) |
| `crates/octos-agent/src/agent/execution.rs` | 4730 | 「Tool execution: dispatching tool calls with hooks and timeout handling.」 |
| `crates/octos-cli/src/config.rs` | 3790 | (待 writer 核:未采集首行文档) |

小计:5 文件,25154 行。

### 1.2 关键 pub 符号(行号)

生成命令:

```
grep -n 'pub fn\|pub struct\|pub enum\|pub trait\|pub(crate) fn\|pub(crate) struct\|pub(crate) enum\|pub(crate) trait' <file>
```

**session_actor.rs**(33 个关键符号,节选核心):

```
grep -n 'pub struct\|pub enum\|pub(crate) fn\|pub fn' crates/octos-cli/src/session_actor.rs
```

- `86: pub struct DispatchParams<'a>` — gateway → actor 的派发参数
- `2443: pub enum ActorMessage` — actor 信箱消息
- `2502: pub struct ActorHandle` — actor join handle 封装(`516: pub fn is_finished`)
- `2524: pub struct ActorRegistry`(`2534: pub fn new`)
- `4455: struct SessionActor`(actor 本体;`4599: impl SessionActor`,`4122: tokio::spawn(actor.run())`)
- `2872: pub shutdown: Arc<AtomicBool>`;`4500-4503`: `global_shutdown: Arc<AtomicBool>` + `cancelled: Arc<AtomicBool>`(优雅关停,`10: use std::sync::atomic::{AtomicBool, Ordering}`;`2795: pub async fn shutdown_all`)

**gateway_runtime.rs**(信号量限流):

```
grep -n 'Semaphore\|max_concurrent_sessions\|tokio::spawn' crates/octos-cli/src/commands/gateway/gateway_runtime.rs
```

- `24: use tokio::sync::{Mutex, Notify, RwLock, Semaphore}`
- `1653 / 1713 / 4122(位于 session_actor.rs)`: 每会话 `tokio::spawn`
- `1731-1732`: `// Semaphore to bound concurrent session processing` + `let concurrency_semaphore = Arc::new(Semaphore::new(gw_config.max_concurrent_sessions));`
- `1666`: `gw_config.max_concurrent_sessions` 传入

**config.rs**(默认 10):

```
grep -n 'max_concurrent_sessions' crates/octos-cli/src/config.rs
```

- `1548-1549`: `#[serde(default = "default_max_concurrent_sessions")] pub max_concurrent_sessions: usize`
- `1633`: `fn default_max_concurrent_sessions() -> usize`(默认 10,待 writer 核默认值字面量)

**task_supervisor.rs**(82 个关键符号,节选):

```
grep -n 'pub enum\|pub struct' crates/octos-agent/src/task_supervisor.rs | head
```

- `90: pub enum RegisterTaskError`
- `140: pub enum TaskStatus`(`164: is_active` / `173: is_terminal` / `177: as_str`)
- `192-222`: `ChildSessionTerminalState` / `ChildSessionJoinState` / `ChildSessionFailureAction` / `TaskRuntimeState`
- `243: pub enum TaskLifecycleState` — Running/Verifying/Ready/Failed 投射来源
- `255: pub struct BackgroundTask`(`362: impl`,`363: pub fn lifecycle_state`)

**execution.rs**(工具并发 join_all;关键符号多为 `pub(super)`,见 §1.4):

```
grep -n 'join_all' crates/octos-agent/src/agent/execution.rs
```

- `14`: 「…aggregates via `futures::join_all`, preserving call order.」(模块文档)
- `2992`: `None => futures::future::join_all(handles)` — All-Safe 批并行聚合点
- 批次准入(M8.8):All-Safe 并行 / All-Exclusive 串行 / 混合批,见模块文档 7-26 行
- `2483: pub(super) async fn execute_tools` — 批次准入入口

### 1.3 首行文档采集命令

```
head -1 crates/octos-cli/src/session_actor.rs
head -1 crates/octos-cli/src/commands/gateway/gateway_runtime.rs
head -1 crates/octos-agent/src/task_supervisor.rs
head -1 crates/octos-agent/src/agent/execution.rs
head -1 crates/octos-cli/src/config.rs
```

### 1.4 口径备注(待 writer 核)

- `execution.rs` 对外可见性用 `pub(super)`(如 `327/377/2483`),不含在统一 grep 口径内,故该文件关键符号计 2。
- `gateway_runtime.rs` 无 `pub` 顶层项(全部 `pub(crate) use` / 私有),关键符号计 0;限流证据以行号引用为准。

---

## 2. supervisor 层(`crates/octos-cli/src/autonomy/`,十文件)

### 2.1 文件清单、行数、首行 `//!` 文档、关键符号数

```
wc -l crates/octos-cli/src/autonomy/*.rs
head -1 crates/octos-cli/src/autonomy/<file>.rs
grep -c 'pub fn\|pub struct\|pub enum\|pub trait\|pub(crate) fn\|pub(crate) struct\|pub(crate) enum\|pub(crate) trait' crates/octos-cli/src/autonomy/<file>.rs
```

| 文件 | 行数 | 首行 `//!` 文档 | 关键符号数 |
|---|---|---|---|
| `agent_orchestrator.rs` | 33639 | (无模块级 `//!`,首行 `use std::collections::BTreeSet`) | 189 |
| `supervisor_store.rs` | 3277 | (首行 `#![allow(dead_code)]`;`//!` 文档在第 2 行起:「Durable supervisor state store for supervised agent groups.」) | 51 |
| `monitor_runtime.rs` | 2037 | 「#1977 MonitorRuntime — zero-token event watchers.」(commit `c4f03647`) | 31 |
| `fleet_wake.rs` | 1807 | 「Fleet-kernel outbox consumer → keeper wake (PR 4a).」 | 4 |
| `goal_loop_runtime.rs` | 1562 | (首行 `#![allow(dead_code)]`;`//!`:「M15 production primitives for goal and loop scheduling policy.」) | 103 |
| `master_continuation_scheduler.rs` | 1416 | (首行 `#![allow(dead_code)]`;`//!`:「M15 production primitive for scheduling automatic master-agent continuation turns.」) | 52 |
| `specialist_runner.rs` | 1155 | 「Supervised specialist runners for AppUI-visible child agents.」 | 13 |
| `human_events.rs` | 430 | 「#2019 — the HUMAN sink over background events that today only wake the model.」 | 7 |
| `escalation_notify.rs` | 169 | 「OLP-CTRL slice 4 — operator notification for goal-scoped escalations.」 | 3 |
| `mod.rs` | 52 | 「Goal / autonomy state engine.」 | 1 |
| **合计** | **45544** | | **454** |

> spec「约 4.5 万行」与实测 45544 一致。

### 2.2 关键符号行号(每文件节选核心)

生成命令(逐文件):

```
grep -n 'pub fn\|pub struct\|pub enum\|pub trait\|pub(crate) fn\|pub(crate) struct\|pub(crate) enum\|pub(crate) trait' crates/octos-cli/src/autonomy/<file>.rs
```

**mod.rs**
- `14: pub(crate) mod agent_orchestrator`(模块声明);`46: pub(crate) fn hash_session_for_inbox`

**supervisor_store.rs** — 事件账本
- `697: pub struct SupervisorStore`(字段 `root_dir/events_path/rotated_events_path`,697-700)
- `722: impl SupervisorStore`;方法:`723: new`、`780: pub fn load_state`、`876: pub fn load_snapshot`、`905: pub fn write_snapshot`、`920: pub fn snapshot_now`、`935: pub fn append_event`
- `25: const EVENTS_FILE_NAME = "supervisor-events.jsonl"`;`33: const EVENTS_ROTATED_FILE_NAME = "supervisor-events.jsonl.old"`(单代轮转,仅取证)
- 记录类型:`60: GroupStatus`、`82: ChildStatus`、`92: TerminalKind`、`100: ContinuationStatus`、`107: SupervisedGroupRecord`、`147: ChildAgentRecord`、`213: TerminalState`、`282: ArtifactRecord`、`381: apply_ledger_row`、`389: apply_event`

**master_continuation_scheduler.rs** — 续跑调度
- `477: pub(crate) struct MasterContinuationScheduler`(`506: impl`;字段 `heap: BinaryHeap<HeapEntry>` + `pending_by_key: HashMap<MasterContinuationDedupeKey, …>`)
- `99: pub(crate) struct MasterContinuationId`;`112: pub(crate) struct MasterContinuationDedupeKey`;`137: pub(crate) enum MasterContinuationReason`(`152: priority`);`186: pub(crate) enum MasterContinuationPriority`(`196: rank`);`221: pub(crate) struct MasterContinuationRequest`(`231: dedupe_key`,`288: stable_dedupe_key`)

**goal_loop_runtime.rs** — goal/loop 调度策略
- `10: pub struct GoalId`;`25: pub struct LoopId`;`40: pub struct RuntimeBudget`
- `68: pub enum NextDueState`(`75: is_due`);`85: pub enum WaitUntil`;`92: pub enum RuntimeActivity`;`98: pub enum RuntimeIdleBlocker`;`107: pub struct RuntimeIdleState`
- `180: pub enum RuntimeSchedulePriority`;`195: pub enum DenyReason`;`224: pub enum GoalCadence`;`239: pub struct GoalRuntimePolicy`;`265: pub enum GoalRuntimeState`;`282: pub enum GoalCompletionVerdict`

**agent_orchestrator.rs** — 编排器
- `606: pub(crate) trait AgentOrchestrator`(RPC 面:`607 list_agents` … `662: spawn_agent`、`675: send_input`、`688: wait_agent`、`699: resume_agent`,均带默认实现)
- `746: pub(crate) struct InProcessAgentOrchestrator`;`1451: impl InProcessAgentOrchestrator`;`9462: impl AgentOrchestrator for InProcessAgentOrchestrator`(实现块内 `9661/9729/9778/9797` 为 spawn/send/wait/resume 具体实现)
- `2471: pub(crate) async fn run_native_specialist`(注册 native_agent → 运行子 Agent → 推 output/artifact → 回写 supervisor)
- `271: pub(crate) struct FleetKeeperSeed`;`376: pub(crate) enum PeerSendInputEnqueueOutcome`;`110: pub(crate) fn xml_escape_untrusted`

**fleet_wake.rs** — outbox→keeper 唤醒
- `70: pub(crate) enum WakeCommit`;`84: pub(crate) struct FleetKeeperSnapshot`
- `153: pub(crate) fn fleet_keeper_continuation_request`;`235: pub(crate) async fn drain_fleet_outbox_once`
- `343: pub(crate) fn spawn_fleet_outbox_consumer`(后台 tokio 消费者,`FLEET_WAKE_INTERVAL_SECS` tick);`420: pub(crate) async fn enqueue_fleet_boot_resume_wakes`

**monitor_runtime.rs** — 零 token 监视器(`c4f03647`)
- `72: pub(crate) enum MonitorMode`(`83: as_str`,`90: interval_secs`;poll/stream 两态)
- `100: pub(crate) struct MonitorSpec`(`153: validate`);`123: pub(crate) enum MonitorSpecError`
- `185: pub(crate) fn monitor_batch_hash`;`209: pub(crate) struct MonitorRateWindow`(`217: MonitorRateDecision`,`230: record`)
- `256: pub(crate) struct MonitorBatcher`(`271: MonitorBatch`,`277: new`,`287: push`)

**specialist_runner.rs** — 受监督专家 runner
- `29: pub(crate) trait AppUiSupervisorEventSink`
- `34: pub(crate) struct SupervisedSpecialistSpec`;`50: SpecialistArtifactSpec`;`58: SupervisedCliSpecialist`;`66: SupervisedMcpSpecialist`;`77: SupervisedSpecialistRunSummary`

**human_events.rs** — HUMAN 事件汇
- `76: pub(crate) fn set_background_activity_sink`;`114: clear_background_activity_sink`
- `127: pub(crate) enum CapDecision`;`199: pub(crate) fn emit_background_activity`;`274: pub(crate) fn background_activity`

**escalation_notify.rs** — 升级通知
- `22: pub(crate) fn profile_has_notification_channel`;`35: profile_first_channel_type`;`64: pub(crate) fn maybe_notify_escalation`

### 2.3 monitor_runtime 与 c4f03647 的关系(佐证)

```
git log --oneline -3 -- crates/octos-cli/src/autonomy/monitor_runtime.rs
git show --stat c4f03647 | head -12
```

- `c4f03647` = 「feat(monitor): MonitorRuntime — zero-token event watchers waking the master via external continuations (#1977) (#1988)」(2026-08-12);
  当前 main 上该文件后续又有 `e2f999a0`(clippy 格式化)与 `0c44b26f`(OLP control channel)两次提交,行号为 `9c157101` 实测值。

---

## 3. peer≈进程模型(`crates/octos-cli/src/peers/mod.rs`)

```
wc -l crates/octos-cli/src/peers/mod.rs        # 3186 行
head -1 crates/octos-cli/src/peers/mod.rs      # 首行文档,见下
grep -n 'pub(crate) fn\|pub(crate) struct\|pub(crate) enum\|pub fn\|pub struct\|pub enum' crates/octos-cli/src/peers/mod.rs
```

- **首行 `//!` 文档**:「Peer-agent staging, addressing, and parked-prompt plumbing.」
  (第 3 行起:Lifted VERBATIM out of the `api`-gated `api::ui_protocol` tree — Phase 3 peer-goal 提取,仅改模块位置与可见性,逻辑未变)
- 关键符号共 71 个,节选:
  - `59: pub(crate) fn capped_utf8`
  - `83: pub(crate) struct PeerWireRegistry`(`95: register` / `111: resolve` / `125: evict_if_value`;`139: peer_wire_registry()`)
  - `166-225`: `PeerTaskBinding` / `pub(crate) struct PeerTaskRegistry`(`182: bind` / `215: take`;`225: peer_task_registry()`)
  - `241: pub(crate) fn bind_peer_supervised_task`;`264: retire_peer_supervised_task`
  - `276: pub(crate) fn peer_wire_key`;`283: peer_slug_and_profile`
  - `346: pub(crate) fn peer_slug_is_safe`;`373: pub(crate) fn name_to_slug`
  - `417: pub(crate) fn staged_peer_dir`;`1329: pub(crate) fn resolve_peer_name_to_slug`

---

## 4. fleet lease/attempt 状态机(`crates/octos-fleet/src/records.rs`)

```
wc -l crates/octos-fleet/src/records.rs   # 808 行
grep -n 'pub struct Lease\|pub struct Attempt' crates/octos-fleet/src/records.rs
```

- **`250: pub struct Lease`** — 字段 `owner_epoch: u64`、`expires_at_ms: u64`(daemon-boot lease;
  doc 注释 247-249 行:外来 epoch 或过期 `expires_at_ms` 由 recovery reconciliation 回收)
- **`256: pub struct Attempt`** — 字段 `schema_version: u32` 等(259-261:child 行 key 为 `{fleet_id}\0{child_id}`,attempt 可由 `(child_id, attempt_id)` 反查)
- 同文件其余状态机符号(节选):`41: FleetStatus`、`64: ChildStatus`(`84: is_terminal`)、`94: AttemptStatus`、`105: WorkerKind`、`119: FleetBudget`(`132: admits`)、`145: FleetRecord`、`193: FleetChildRecord`、`238: EscalationRequest`、`290: ChildResultSnapshot`、`302: AcceptanceVerdict`、`313: DurablePlan`
- 全文件关键符号 27 个。
- 本章角色边界:lease/attempt 只作并发原语交代,状态机细节「详见第 16 章」;goal/peer 编排细节「详见第 18 章」。

---

## 5. 三层汇总

| 层 | 文件数 | 行数合计 | 关键符号数 |
|---|---|---|---|
| ① Tokio 层(session actor/gateway/task_supervisor/execution/config) | 5 | 25154 | 170(session_actor 33 + task_supervisor 82 + config 53 + execution 2) |
| ② supervisor 层(`autonomy/` 十文件) | 10 | 45544 | 454 |
| ③ peer/lease 层(`peers/mod.rs` + `octos-fleet/records.rs`) | 2 | 3994(3186+808) | 98(71+27) |
| **总计** | **17** | **74692** | **722** |

### 复算命令

```
wc -l crates/octos-cli/src/session_actor.rs \
      crates/octos-cli/src/commands/gateway/gateway_runtime.rs \
      crates/octos-agent/src/task_supervisor.rs \
      crates/octos-agent/src/agent/execution.rs \
      crates/octos-cli/src/config.rs \
      crates/octos-cli/src/autonomy/*.rs \
      crates/octos-cli/src/peers/mod.rs \
      crates/octos-fleet/src/records.rs | tail -1
```

### 待 writer 核清单

1. `config.rs` `default_max_concurrent_sessions()`(1633 行)默认值字面量是否为 10(spec 叙事口径,未直接采字面量)。
2. `task_supervisor.rs` 与 `config.rs` 首行非 `//!`,正文如需引首行文档,建议引首个 doc 注释位置而非首行。
3. `agent_orchestrator.rs` 3.4 万行,本表只列 trait/实现/run_native_specialist 骨架行号;内部更多实现块(`11228: impl InProcessAgentOrchestrator` 等)按写作需要再取。
4. `execution.rs` 可见性为 `pub(super)`,若正文按「pub 符号」口径引用需注明。
