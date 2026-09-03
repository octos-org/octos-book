# 第 17 章事实表 — octos-swarm:契约扇出与聚合门禁

- **源码基准 commit**: `9c157101`(`9c1571016e5ea86955b4b3486c04f0359dfff339`,main 分支)
- **统计日期**: 2026-09-03
- **源码仓库**: `/Users/zhangalex/Work/Projects/FW/octos`(只读;本书仓库与源码仓库是两个目录)
- 除特别注明外,所有命令均在 octos 仓库根执行。
- 行数统计方式统一为:
  ```bash
  wc -l crates/octos-swarm/src/*.rs crates/octos-swarm/tests/*.rs
  ```
- 符号行号提取方式统一为:
  ```bash
  grep -n -E '<pattern>' crates/octos-swarm/src/<file>.rs
  ```

---

## 1. 逐文件清单与行数(7 源文件 + 3 测试文件 = 4,980 行)

生成命令:

```bash
cd /Users/zhangalex/Work/Projects/FW/octos && git rev-parse HEAD
find crates/octos-swarm -name '*.rs' | sort
wc -l crates/octos-swarm/src/*.rs crates/octos-swarm/tests/*.rs
```

| 文件 | 行数 | 一句话职责 |
|---|---|---|
| src/dispatcher.rs | 1,261 | 编排核心:`Swarm::dispatch` 扇出/顺序/流水线三轮循环、门禁、聚合、幂等 |
| src/result.rs | 395 | 类型化结果:`SwarmResult` / `SubtaskOutcome` / `AggregateArtifact` |
| src/persistence.rs | 275 | redb 持久化:`DispatchStore` 幂等账本(`swarm-state.redb`) |
| src/topology.rs | 229 | 拓扑与契约:`SwarmTopology` / `ContractSpec` / `FanoutPattern` |
| src/ledger.rs | 115 | 成本账本适配(M7.5):`CostLedger` trait + Noop 实现 |
| src/lib.rs | 111 | crate 门面与 re-export |
| src/gate.rs | 119 | 门禁粘合层:`enforce_or_outcome`(复用 octos_agent 的 dispatch-policy 门) |
| tests/swarm_dispatch.rs | 1,576 | 集成测试(23 个用例:扇出/顺序/流水线/重试/重启恢复/幂等) |
| tests/swarm_dispatch_policy.rs | 548 | 门禁策略集成测试(9 个用例,spec 指定为主) |
| tests/subtask_contracts.rs | 351 | 子任务校验器/预算隔离集成测试(4 个用例) |
| **合计** | **4,980** | `src` 2,505 + `tests` 2,475 |

---

## 2. 首行 `//!` 文档(逐字摘录)

生成命令(每个文件):

```bash
head -1 crates/octos-swarm/src/<file>.rs
```

| 文件 | 首行 `//!`(逐字) |
|---|---|
| src/lib.rs | `//! Swarm orchestration primitive for octos (harness M7.5).` |
| src/dispatcher.rs | `//! `[`Swarm::dispatch`]: the core swarm orchestration primitive.` |
| src/topology.rs | `//! Swarm topology types and contract specs.` |
| src/persistence.rs | `//! Session-durable state for swarm dispatches.` |
| src/gate.rs | `//! Swarm-local glue around the shared dispatch-policy gate.` |
| src/result.rs | `//! Typed outcome for a swarm dispatch.` |
| src/ledger.rs | `//! Cost ledger adapter layer for M7.5.` |

lib.rs `//!` 次行补充(逐字):`//! \`octos-swarm\` formalises the PM + swarm supervisor pattern the…`(生成命令 `sed -n '1,8p' crates/octos-swarm/src/lib.rs`)。

---

## 3. 关键 pub 符号行号

### 3.1 crate 门面 re-export(src/lib.rs)

生成命令:

```bash
grep -n -E 'pub use' crates/octos-swarm/src/lib.rs
```

| 行号 | 符号 | 说明 |
|---|---|---|
| 99 | `pub use dispatcher::{…}` | 导出 Swarm 系类型(Swarm/SwarmBuilder/SwarmBudget/SwarmContext/SwarmEventSink 等) |
| 107 | `pub use ledger::{CostLedger, NoopCostLedger, SwarmCostAttribution}` | 成本账本 |
| 108 | `pub use octos_agent::DispatchPolicy` | 门禁策略来自 octos-agent |
| 109 | `pub use persistence::{DISPATCH_RECORD_SCHEMA_VERSION, DispatchRecord, DispatchStore}` | 持久化 |
| 110 | `pub use result::{AggregateArtifact, SubtaskOutcome, SubtaskStatus, SwarmOutcomeKind, SwarmResult}` | 结果类型 |
| 111 | `pub use topology::{ContractSpec, FanoutPattern, MAX_CONTRACTS_PER_DISPATCH, SwarmTopology}` | 拓扑与契约 |

### 3.2 编排原语:扇出 / 顺序 / 流水线(src/dispatcher.rs、src/topology.rs)

生成命令:

```bash
grep -n -E 'pub (struct|const|fn|trait)|async fn (run_|dispatch|gate_|spawn_)' crates/octos-swarm/src/dispatcher.rs
grep -n -E 'pub (struct|enum|const|fn)|Parallel|Sequential|Pipeline|Fanout' crates/octos-swarm/src/topology.rs | head -20
```

| 行号 | 符号 | 说明 |
|---|---|---|
| dispatcher.rs:60 | `pub const MAX_RETRY_ROUNDS: u32 = 3` | 重试轮上限 |
| dispatcher.rs:66 | `pub struct SwarmBudget` | 预算与旋钮(max_contracts / max_retry_rounds) |
| dispatcher.rs:165 | `pub struct Swarm` | 编排原语本体 |
| dispatcher.rs:206 | `pub fn builder(…)` | 构造入口 |
| dispatcher.rs:246 | `pub async fn dispatch(…)` | **核心入口**:5 参(id, contracts, topology, budget, context) |
| dispatcher.rs:428 | `async fn run_parallel_round(…)` | Parallel 拓扑执行轮 |
| dispatcher.rs:478 | `async fn run_sequential_round(…)` | Sequential 拓扑执行轮(首个硬失败即中止) |
| dispatcher.rs:518 | `async fn run_pipeline_round(…)` | Pipeline 拓扑执行轮(输出折叠进下一条 `pipeline_input`) |
| dispatcher.rs:646 | `fn spawn_subtask(…)` | 单子任务派发 |
| dispatcher.rs:833 | `struct InFlightGuard` | 同 id 并发 dispatch 拒绝(#1719) |
| dispatcher.rs:1053 | `async fn dispatch_once(…)` | 单轮派发(门禁在此调用) |
| dispatcher.rs:1164 | `pub fn flatten_aggregate(result: &SwarmResult)` | 聚合产物展平 |
| topology.rs:27 | `pub const MAX_CONTRACTS_PER_DISPATCH: usize = 128` | 单次派发契约数上限 |
| topology.rs:37 | `pub struct ContractSpec` | 契约(contract_id / tool_name / task / label) |
| topology.rs:59 | `pub struct FanoutPattern` | 种子契约 × variants 扇出模式 |
| topology.rs:72 | `pub fn expand(&self)` | 扇出展开(variant 注入 task、id 加 `::variant` 后缀) |
| topology.rs:98 | `pub enum SwarmTopology` | 4 变体:`Parallel` / `Sequential` / `Pipeline` / `Fanout` |
| topology.rs:120 | `pub fn as_str(&self)` | 稳定拓扑标签(metrics/事件用) |
| topology.rs:133 | `pub fn resolve_contracts(…)` | Fanout 展开覆盖种子表,其余原样保留 |
| topology.rs:143 | `pub fn max_concurrency(&self)` | 拓扑并发度(Sequential/Pipeline 恒为 1) |

### 3.3 MCP-backed sub-agents(后端抽象与接线面)

生成命令:

```bash
grep -n -E 'pub (trait|struct|enum) (McpAgentBackend|DispatchRequest|DispatchResponse|DispatchOutcome)' crates/octos-agent/src/tools/mcp_agent.rs
grep -n -E 'swarm_backend|build_swarm_state_from_flags' crates/octos-cli/src/commands/serve.rs | head
```

| 位置 | 符号 | 说明 |
|---|---|---|
| octos-agent/src/tools/mcp_agent.rs:411 | `pub trait McpAgentBackend` | Swarm 分发目标后端 trait(`dispatch` 异步方法) |
| octos-agent/src/tools/mcp_agent.rs:266 | `pub struct DispatchRequest` | tools/call 请求(契约 task 逐字转发) |
| octos-agent/src/tools/mcp_agent.rs:218 | `pub struct DispatchResponse` | 后端响应(文本 + files_to_send) |
| octos-agent/src/tools/mcp_agent.rs:182 | `pub enum DispatchOutcome` | 单次派发结果(Success/Timeout/TransportFailure 等) |
| octos-cli/src/commands/serve.rs:420 | `pub swarm_backend: Option<String>` | `--swarm-backend`(`stdio`/`cli`/`http`) |
| octos-cli/src/commands/serve.rs:427 | `pub swarm_backend_cmd: Option<String>` | `--swarm-backend-cmd`(stdio 后端命令) |
| octos-cli/src/commands/serve.rs:433 | `pub swarm_backend_args: Vec<String>` | `--swarm-backend-arg`(可重复) |
| octos-cli/src/commands/serve.rs:439 | `pub swarm_backend_url: Option<String>` | `--swarm-backend-url`(http 后端) |
| octos-cli/src/commands/serve.rs:1867 | `async fn build_swarm_state_from_flags(…)` | CLI 标志 → Swarm 状态装配(无标志返回 `Ok(None)`,处理器返回 503) |

依赖声明:`crates/octos-cli/Cargo.toml:32` → `octos-swarm = { workspace = true }`(生成命令 `grep -n octos-swarm crates/octos-cli/Cargo.toml`)。

### 3.4 契约与聚合门禁相关类型

生成命令:

```bash
grep -n -E 'pub(crate) async fn enforce_or_outcome' crates/octos-swarm/src/gate.rs
grep -n -E 'pub async fn enforce_dispatch_gates|pub struct GateDenial|pub enum DispatchPolicy' crates/octos-agent/src/dispatch_policy.rs crates/octos-agent/src/lib.rs
grep -n -E 'fn (gate_subtask_validators|run_aggregate_validator)' crates/octos-swarm/src/dispatcher.rs
grep -n -E 'pub (struct|enum) (AggregateValidator|AggregateArtifact|SwarmOutcomeKind|SubtaskStatus|SubtaskOutcome|SwarmResult)' crates/octos-swarm/src/dispatcher.rs crates/octos-swarm/src/result.rs
```

| 位置 | 符号 | 门禁角色 |
|---|---|---|
| octos-swarm/src/gate.rs:25 | `pub(crate) async fn enforce_or_outcome(…)` | 门禁粘合层:调 `enforce_dispatch_gates`,把 `GateDenial` 折叠成 `SubtaskOutcome`(TerminalFailed);注释点明 audit #701/#714 单一绕过面 |
| octos-agent/src/dispatch_policy.rs:292 | `pub async fn enforce_dispatch_gates(…)` | 共享门禁判定(工具策略 deny / 审批 / env allowlist / sandbox 要求) |
| octos-agent/src/dispatch_policy.rs:303 | `pub async fn enforce_dispatch_gates_for_backend(…)` | 后端感知变体(require_sandboxed 校验) |
| octos-agent/src/lib.rs:119-120 | re-export `DispatchPolicy, GateDenial, enforce_dispatch_gates, …` | 门禁类型面 |
| dispatcher.rs:92 | `pub struct AggregateValidator` | 聚合校验器配置(全部子任务到终态后跑 M4.3 `ValidatorRunner`) |
| dispatcher.rs:593 | `async fn gate_subtask_validators(…)` | 子任务完成校验器门(Completed 才跑) |
| dispatcher.rs:693 | `async fn run_aggregate_validator(…)` | 聚合校验门(对合并产物跑,产出 `Vec<ValidatorOutcome>`) |
| result.rs:20 | `pub enum SubtaskStatus` | `Completed` / `RetryableFailed` / `TerminalFailed` / `Aborted` |
| result.rs:58 | `pub struct SubtaskOutcome` | 单契约终态(含 attempts、last_dispatch_outcome) |
| result.rs:100 | `pub struct AggregateArtifact` | 聚合产物(展平后的合并输出) |
| result.rs:117 | `pub enum SwarmOutcomeKind` | `Success` / `Partial` / `Aborted`(聚合判定,`build_aggregate` 于 result.rs:228) |
| result.rs:145 | `pub struct SwarmResult` | 派发总结果(topology、subtasks、aggregate、cost) |
| persistence.rs:27 | `pub const DISPATCH_RECORD_SCHEMA_VERSION: u32 = 1` | 持久化 schema 版本 |
| persistence.rs:36 | `pub struct DispatchRecord` | 幂等记录(finalized / final_result 快照 #1718 / contracts_fingerprint #1719) |
| persistence.rs:93 | `pub struct DispatchStore` | redb 存储;`io_gate` 串行化 load/store |
| persistence.rs:110 / 147 / 178 | `open` / `load` / `store` | 打开账本(`swarm-state.redb`)/ 读记录 / 写记录 |

---

## 4. 测试用例名(3 个集成测试文件)

### 4.1 tests/swarm_dispatch_policy.rs(主,9 个用例)

生成命令:

```bash
grep -n -E '^\s*async fn [a-z]' crates/octos-swarm/tests/swarm_dispatch_policy.rs
```

| 行号 | 用例 |
|---|---|
| 134 | `local_mcp_backend_respects_tool_policy_deny` |
| 180 | `remote_mcp_backend_respects_tool_policy_deny` |
| 224 | `approval_required_without_requester_fails_closed` |
| 264 | `approval_deny_blocks_dispatch` |
| 319 | `approval_approve_lets_dispatch_through` |
| 366 | `env_allowlist_blocks_forbidden_keys` |
| 428 | `require_sandboxed_blocks_unsandboxed_backend` |
| 469 | `no_policy_preserves_legacy_behaviour` |
| 506 | `sequential_aborts_on_gate_denial` |

### 4.2 tests/swarm_dispatch.rs(23 个用例)

生成命令:

```bash
grep -n -E '^\s*async fn should' crates/octos-swarm/tests/swarm_dispatch.rs
```

行号 → 用例:246 `should_fan_out_parallel_n_contracts`;287 `should_sequence_contracts_in_order_with_abort_on_failure`;330 `should_chain_pipeline_output_as_next_input`;368 `should_redispatch_failed_subcontract_bounded_retries`;431 `should_redispatch_recovering_subcontract_within_budget`;474 `should_aggregate_validator_over_combined_output`;560 `should_survive_process_restart_mid_dispatch`;657 `should_emit_typed_swarm_dispatch_event`;707 `should_expand_fanout_pattern_into_variant_contracts`;763 `should_stop_pipeline_round_at_retryable_stage_and_resume_with_input`;821 `should_replay_finalized_result_verbatim_including_validator_verdicts`;924 `should_error_not_panic_when_resume_contracts_fewer_than_recorded`;1008 `should_error_when_resume_contract_ids_mismatch_recorded`;1060 `should_error_when_finalized_replay_contracts_mismatch`;1100 `should_reject_concurrent_dispatch_with_same_id`;1163 `should_not_resume_pipeline_tail_after_persisted_terminal_failure`;1213 `should_not_resume_sequential_tail_after_persisted_terminal_failure`;1259 `should_not_run_extra_round_when_resumed_at_retry_cap`;1314 `should_recompute_replay_for_legacy_finalized_record_without_snapshot`;1364 `should_reject_same_id_with_changed_task_payload`;1406 `should_not_burn_retry_budget_on_progress_rounds`;1462 `should_dispatch_through_cli_backend_with_retry_on_nonzero_exit`;1527 `should_record_cost_attribution_via_ledger_stub`。

### 4.3 tests/subtask_contracts.rs(4 个用例)

生成命令:

```bash
grep -n -E '^\s*async fn should' crates/octos-swarm/tests/subtask_contracts.rs
```

| 行号 | 用例 |
|---|---|
| 123 | `should_run_completion_validators_in_swarm_subtask` |
| 182 | `should_pass_swarm_subtask_when_required_validator_satisfied` |
| 225 | `should_use_reserve_api_for_budget_isolation_in_swarm` |
| 306 | `should_commit_reservation_on_swarm_subtask_completion` |

---

## 5. 交付前抽查复跑记录(2026-09-03)

在 octos 仓库根逐条复跑,结果与本表一致:

```bash
$ wc -l crates/octos-swarm/src/*.rs crates/octos-swarm/tests/*.rs | tail -1
4980 total

$ grep -n 'pub async fn dispatch' crates/octos-swarm/src/dispatcher.rs
246:    pub async fn dispatch(

$ grep -n 'pub enum SwarmTopology' crates/octos-swarm/src/topology.rs
98:pub enum SwarmTopology {

$ grep -n 'pub struct DispatchStore' crates/octos-swarm/src/persistence.rs
93:pub struct DispatchStore {

$ grep -n 'pub(crate) async fn enforce_or_outcome' crates/octos-swarm/src/gate.rs
25:pub(crate) async fn enforce_or_outcome(

$ grep -n 'swarm_backend:' crates/octos-cli/src/commands/serve.rs | head -1
420:    pub swarm_backend: Option<String>,

$ git rev-parse HEAD
9c1571016e5ea86955b4b3486c04f0359dfff339
```
