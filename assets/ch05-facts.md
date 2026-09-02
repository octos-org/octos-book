# Ch5 Agent Loop 模块事实表

- **基准 commit**: octos `main` @ `9c157101`(`9c1571016e5ea86955b4b3486c04f0359dfff339`,2026-09-02 19:37 +0800)
- **统计日期**: 2026-09-02
- **源码仓库**: `/Users/zhangalex/Work/Projects/FW/octos`(只读,本表仅引用,不修改)
- **范围**: `crates/octos-agent/src/agent/`、`crates/octos-agent/src/harness_errors.rs`、`crates/octos-cli/src/autonomy/master_continuation_scheduler.rs`
- **所有行号与数字均来自本次命令实测**(生成命令附于各节;交付前已复跑核心命令,见 §7)

---

## 1. 模块清单

生成命令:

```bash
ls crates/octos-agent/src/agent/ | grep -v '_tests'
```

实测 **20 个** `.rs`(与 spec 的「20 个」一致;目录下另有 1 个 `loop_runner_tests.rs`,已排除):

| # | 文件 | 行数 |
|---|------|------|
| 1 | activity.rs | 150 |
| 2 | append_only_audit.rs | 364 |
| 3 | budget.rs | 821 |
| 4 | compaction.rs | 358 |
| 5 | detection.rs | 858 |
| 6 | execution.rs | 4730 |
| 7 | llm_call.rs | 988 |
| 8 | loop_compaction.rs | 414 |
| 9 | loop_runner.rs | 3979 |
| 10 | loop_state.rs | 768 |
| 11 | memory.rs | 1062 |
| 12 | message_repair.rs | 1260 |
| 13 | mod.rs | 1644 |
| 14 | prompt_segments.rs | 233 |
| 15 | realtime.rs | 602 |
| 16 | rich_output.rs | 309 |
| 17 | streaming.rs | 1491 |
| 18 | turn_failure.rs | 69 |
| 19 | turn_state.rs | 388 |
| 20 | verifier.rs | 881 |

**agent/ 总行数(排除 `*_tests.rs`): 21,369**(`cat $(ls *.rs | grep -v '_tests') | wc -l`;spec 估计「约 2.1 万行」相符)

---

## 2. 模块明细(行数 / 首行 `//!` / 对外符号)

生成命令(行数与首行注释):

```bash
cd crates/octos-agent/src/agent
for f in $(ls *.rs | grep -v '_tests'); do
  echo "$f | $(wc -l < $f) | $(grep -m1 '^//!' $f)"; done
```

符号生成命令(名字与行号;`pub(crate)`/`pub(super)` 为 crate 内实际接口面,一并列出):

```bash
grep -nE 'pub(\(crate\)|\(super\))? (fn|struct|enum|trait|const) ' <file>
```

### activity.rs (150 行)
`//! Loop activity tracking for idle-timeout enforcement.`
- L13 `pub(crate) const DEFAULT_IDLE_TIMEOUT_SECS`
- L16 `pub(crate) struct LoopActivityState`;方法:L21 `new`、L27 `mark_activity`、L34 `idle_elapsed`、L42 `has_timed_out`、L47 `recently_active_within`、L52 `set_last_activity_at`
- L63 `pub(crate) struct ActivityTrackingReporter`;L69 `new`

### append_only_audit.rs (364 行)
`//! Append-only context audit: does a turn's request history only ever GROW?`
- L71 `record_finding`、L91 `enabled`、L101 `arm_for_test`、L107 `disarm_for_test`、L113 `finding_count`、L119 `drain_findings`(均 `pub(crate) fn`)
- L132 `pub(crate) struct MessageFingerprint`;L162 `pub(crate) enum Rewrite`(L179 `describe`)
- L202 `pub(crate) struct AppendOnlyAudit`;L211 `observe`

### budget.rs (821 行) — 见 §3 专节
`//! Budget tracking and enforcement for the agent loop.`

### compaction.rs (358 行)
`//! Context window trimming and fallback truncation.`
全部为 `pub(super) fn`(impl 内):L12 `trim_to_context_window`、L96 `maybe_run_preflight_compaction`、L137 `run_tier1_compaction`、L172 `build_tier2_context_management`、L189 `maybe_run_turn_compaction`、L229 `prepare_prompt_with_context_manager`、L320 `fallback_truncate`

### detection.rs (858 行)
`//! Detection of repetitive output and retriable responses.`
全部为 `pub(super) fn`:L60 `is_retriable_response`、L84 `normalize_inline_invokes`、L111 `is_repetitive_output`、L146 `is_retryable_stream_error`、L168 `is_truncated_tool_call_error`

### execution.rs (4730 行,最大模块)
`//! Tool execution: dispatching tool calls with hooks and timeout handling.`
- 顶层私有 fn:L106 `should_auto_send_tool_files`、L174 `is_long_running_tool`、L209 `compute_batch_timeout_secs`、L261 `satisfied_delivery_is_failure`、L273 `build_spawn_only_produced_files_message`、L296 `relativize_workspace_path`、L3003 `cancelled_result`、L3035 `timed_out_result`、L3062 `panic_result`
- L327 `pub(super) fn satisfied_completion_content`;L377 `pub(super) fn compose_system_prompt`
- L398 `impl ToolApprovalRequester for ApprovedToolAutoApprover`;L412 `pub async fn revalidate_pending_approval`;L469 `pub async fn execute_approved_tool`
- L598 `spawn_tool_task`、L2457 `snapshot_before_mutating_tools`、**L2483 `pub(super) async fn execute_tools`(工具派发主入口)**、L2738 `run_serial_calls`、L2846 `execute_mixed_batch`

### llm_call.rs (988 行)
`//! LLM call orchestration with lifecycle hooks and retry logic.`
- **单一主函数:L22 `pub(super) async fn call_llm_with_hooks`**(其余均为 `mod tests` 内的 mock 实现,L433 起)

### loop_compaction.rs (414 行)
`//! Message preparation pipeline for long-turn loop calls.`
- L27 `pub(crate) fn prepare_conversation_messages`;L71 `pub(crate) fn prepare_task_messages`

### loop_runner.rs (3979 行) — 主线文件
`//! Main agent loop: process_message and run_task orchestration.`
- 顶层私有 fn(节选):L66 `compose_turn_user_content`、L104 `inspect_workspace_contract_failures`、L161 `split_tool_calls`、L207 `with_tier2_context_management`、L3193 `is_error_tool_message`、L3387 `recover_shell_retry`、L3728 `inject_loop_detected_synthetic_results`、L3912 `push_max_tokens_continuation`、L3957 `build_chat_config`(共约 50 个顶层 fn)
- `pub(crate)` 符号:L217 `enum ShellRetryRecoveryKind`、L225 `struct ShellRetryRecovery`、L249 `enum LoopErrorAction`、L313 `classify_loop_error`、L368 `dispatch_shell_retry_recovery`、L437 `dispatch_loop_error`、L3619 `struct ShellSpiralOutcome`
- `pub(super)`:L602 `try_budget_grace_call`、L715 `dedup_loop_warning`
- **入口**(impl Agent 内):
  - L784 `pub async fn process_message`
  - L804 `pub async fn process_message_with_attachments`
  - L817 `pub async fn process_message_tracked`
  - L834 `pub async fn process_message_tracked_with_attachments`
  - L852 `async fn process_message_inner`(核心循环体,L852–2242)
  - L2243 `pub async fn run_task`
  - L2254 `pub async fn run_task_with_tracker`
  - L2262 `async fn run_task_inner`
  - L2720 `fn build_result`
- 测试:L3979 `mod tests;`(独立文件 `loop_runner_tests.rs`,已排除统计)

### loop_state.rs (768 行) — 见 §4 专节
`//! Typed retry-bucket state machine for the agent loop (M6.2, issue #489).`

### memory.rs (1062 行)
`//! Initial message building and episodic memory context for the agent.`
- L44 `pub const MIN_EPISODE_SIMILARITY: f32 = 0.55`
- impl Agent(均 `pub(super) async fn`):L86 `recall_relevant_episodes`、L174 `save_conversation_episode`、L249 `build_initial_messages`
- 私有 fn:L338 `format_relevant_experiences`、L359 `render_relevant_experiences_iter`

### message_repair.rs (1260 行)
`//! Message normalization, ordering repair, and tool pair validation.`
- L8 `pub(crate) fn sanitize_tool_call_id`、L27 `normalize_tool_call_ids`、L108 `normalize_system_messages`、L189 `repair_message_order`、L325 `repair_tool_pairs`、L414 `synthesize_missing_tool_results`、L513 `truncate_old_tool_results`
- **L95 `pub fn normalize_tool_call_id`(本模块唯一全 crate 公开 fn)**

### mod.rs (1644 行)
`//! Agent implementation.`
- 重导出:L9 `pub use budget::result_md_owner_content_is_peer`、L35 `PromptSegmentProvider`、L45 `normalize_tool_call_id`、L46 `RealtimeController`、L47 `PartialTurnUsage`;子模块声明 L16–25(`loop_state`、`memory`、`prompt_segments`、`realtime`、`rich_output`、`turn_failure`、`verifier` 等)
- L58 `pub const DEFAULT_WORKER_PROMPT`(include prompts/worker.txt)
- L62 `pub struct AgentConfig`;超时/限额常量:L148 first-token grace 180s、L150 stream idle 90s、L152 LLM call max 1200s、L154 voice LLM deadline 30s、L190/L192 tool timeout 1800s、L197 interactive 120s、L199 session 1800s
- L240 `pub struct ConversationResponse`;L288 `pub struct TokenTracker`(L294 `new`)
- L309 `pub struct Agent`;构造/装配(L522 `impl Agent` 起):L524 `new`、L625 `new_shared`、builder 系列 L691–1209(`with_agent_definitions`、`with_reporter`、`with_shutdown`、`with_steer_buffer`、`with_hooks`、`with_snapshot_manager`、`with_realtime`、`with_compaction_runner`、`with_persistent_retry_state`、`with_tiered_compaction` 等)、L1209 `pub(super) beat_heartbeat`、L1267–1304 system-prompt 段管理(`with_system_prompt`/`append_system_prompt`/`set_prompt_segment`/`add_prompt_segment_provider`、L1316 `pub async fn refresh_prompt_segments`)、L1347 `set_system_prompt`、L1358 `model_id`、L1368 `llm_provider`、L1373 `tool_registry`、L1425 `with_workspace_root`、L1450 `is_loop_detected_recently`

### prompt_segments.rs (233 行)
`//! Ordered system-prompt segments.`
- L25 `pub trait PromptSegmentProvider`
- L52 `pub struct PromptSegments`;方法(均 `pub(super) fn`):L58 `from_base`、L72 `replace_all`、L82 `append`、L99 `set_named`、L115 `render`

### realtime.rs (602 行)
`//! Real-time agent loop extensions for robotic operation.`
- L32 `pub enum AgentError`;L56 `pub struct RealtimeConfig`;L128 `pub struct Heartbeat`(L137 `pub enum HeartbeatState`;L145 `new`、L155 `beat`、L162 `count`、L168 `state`);L203 `pub struct SensorSnapshot`(L214 `to_context_line`);L230 `pub trait SensorSource`;L238 `pub struct SensorContextInjector`(L245 `new`、L255 `with_source`、L264 `push`、L286 `to_context_block`、L299 `latest`、L312 `refresh_from_source`、L326 `summarize`);L384 `pub struct RealtimeController`(L391 `new`、L426 `beat_and_check`、L437 `sensor_summary`);L455 `pub struct RealtimeHookEnricher`

### rich_output.rs (309 行)
`//! Rich output: produce a self-contained HTML document from a short brief.`
- L32 `pub const ILLUSTRATION_PLACEHOLDER`;L35 `pub struct RichHtmlContext`;L53 `pub fn inline_illustration`、L66 `pub fn extract_html`;L85 `pub async fn author_html`

### streaming.rs (1491 行)
`//! Stream consumption, shutdown handling, and cost reporting.`
- L38 `pub(super) struct StreamTimeouts`;L48 `pub(super) const REPETITIVE_OUTPUT_MESSAGE`
- L64 `pub(super) async fn wait_for_shutdown`;**L73 `pub(super) async fn consume_stream_with_input_estimate`(流消费主入口)**
- L555 `response_usage_cost`、L581 `emit_cost_update`、L669 `response_to_message`(均 `pub(super)`)

### turn_failure.rs (69 行)
`//! Voice-turn failure projection. Additive: does NOT replace the agent(注释跨行)`
- L9 `pub enum TurnFailure`;L22 `pub fn is_voice_empty_response`

### turn_state.rs (388 行)
`//! Typed turn state for loop execution.`
- L12 `pub(crate) enum LoopBudgetStopKind`(变体 L14–L36:`Shutdown`/`MaxIterations`/`MaxTokens`/`ActivityTimeout`/`IdleProgressTimeout`)
- L33 `pub(crate) enum LoopTerminalReason`(唯一变体 L35 `Budget { kind, message }`)
- L41 `pub(crate) enum LoopRetryReason`(L43 `EmptyResponse`/L44 `StreamError`/L45 `ProviderFailover`)
- L48 `pub(crate) enum LoopRepairReason`(L50–56:`ContextTrimmed`/`SystemMessagesNormalized`/`MessageOrderRepaired`/`ToolPairsRepaired`/`MissingToolResultsSynthesized`/`OldToolResultsTruncated`/`ToolCallIdsNormalized`)
- L59 `pub(crate) struct LoopTurnState`(字段:started_at/iteration/total_usage/turn_spend_usd/priced_usage/retry_reasons/repair_reasons/terminal_reason);方法(均 `pub(crate)`):L80 `new`、L93 `iteration`、L97 `advance_iteration`、L102 `total_usage`、L108 `spend_usd`、L113 `has_priced_usage`、L119 `priced_spend`、L124 `retry_reasons`、L129 `repair_reasons`、L138 `record_usage`、L171 `record_retry`、L175 `record_repair`、L179 `check_budget`、L187 `record_budget_stop`
- L237 `pub struct PartialTurnUsage`;L262 `pub(crate) fn attach_partial_usage`

### verifier.rs (881 行)
`//! Optional inference-time verifier and compact structured turn ledger.`
- L22 `pub const TURN_LEDGER_SCHEMA_VERSION`;L31 `pub struct AgentVerifierConfig`(L41 `with_provider`、L55/60/65 `with_ledger_path`/`with_max_quiet_turns`/`with_lane_context`)
- L73 `pub enum TurnOutcome`;L80 `pub enum ErrorClass`;L109 `pub struct TurnLedgerEntry`;L124 `pub enum VerifierVerdict`(L153 `ready_to_answer`);L159 `pub struct VerifierRecord`;L168 `pub(crate) struct TurnLedger`(L177 `new`、L187 `push_entry`、L195 `record_verdict`、L208 `latest_verdict`、L212 `should_verify_after_tool_batch`、L243 `ready_gate_active`、L249 `recent_view`)
- L320 `pub(crate) fn ledger_entry_from_tool_result`;impl Agent:L416 `pub fn with_verifier_config`、L421 `pub(super) fn new_turn_ledger`、L428 `pub(super) async fn maybe_run_verifier_after_tool_batch`、L456 `pub(super) async fn verifier_allows_termination`

---

## 3. budget.rs 专节(#27e 预算与检查点)

821 行;两个 test 模块:L180 `mod tests`、L626 `mod budget_checkpoint_tests`。**非测试函数 9 个**:

生成命令:

```bash
grep -nE '(pub(\(crate\)|\(super\))? )?(async )?fn ' crates/octos-agent/src/agent/budget.rs
```

### 3.1 预算检查点函数(核心)

| 行号 | 函数 | 职责 |
|------|------|------|
| L13–38 | `pub(super) enum BudgetStop` | 五种预算终止:Shedown(L14)/MaxIterations(L25,携 limit)/MaxTokens(L28)/ActivityTimeout(L32)/IdleProgressTimeout(L35) |
| L41 | `BudgetStop::message()` | 生成用户可读的终止消息(各 stop 变体一条) |
| L90 | `budget_tokens_used()` | 从 TokenUsage 汇总已用 token(含 cache 计入 used,见 L190 测试) |
| L100 | `check_budget()` | 每轮迭代前的预算检查点:依次判 shutdown/max_iterations/max_tokens/activity timeout/idle-progress timeout,返回 `Option<BudgetStop>` |
| L141 | `report_budget_stop()` | 把 BudgetStop 以 reporter 消息上报(含 iteration 数) |

### 3.2 #27e 落盘检查点(L479–623,`#[cfg(test)]` 之外的独立段)

| 行号 | 函数 | 职责 |
|------|------|------|
| L484 | `git_in()`(私有) | 在 dir 内跑 `git <args>`,返回成功+stdout(供 dirty 判断与 commit) |
| L499 | `write_result_md_named()`(私有) | 原子写 result 文件(tmp + rename,tmp 名含 `.tmp-27e`,见 L501) |
| L532 | `pub(super) fn result_md_owned_by_peer()` | 读 sidecar `.result-owner`,判断 peer 是否拥有 result.md 写权(#27h) |
| L542 | `pub fn result_md_owner_content_is_peer()` | 该判断的唯一公开入口(cli 侧 #1824 安全读路径复用同一判断) |
| **L546** | **`pub(super) fn checkpoint_budget_exhaustion(workdir, stop, iteration)`** | **#27e 主函数**:仅 `MaxIterations` stop 触发(L553–556 else 直接 return None);dirty 工作树(`git status --porcelain` 非空)才动作;① auto-commit `wip: budget exhausted (#27e) — checkpointed mid-task`(仅本地,永不 push);② 原子写 staged result——peer 拥有 result.md 时改写 **`result.checkpoint.md`**(L579–581,#27h),否则 `result.md`,内容含 `status: budget_exhausted` front-matter;③ 返回 marker 文本拼进 TaskResult.output |

**调用点**: `loop_runner.rs:2328`(`super::budget::checkpoint_budget_exhaustion(...)`,位于 run_task_inner 的 MaxIterations 终止分支)。

**触发/不触发条件(实测注释 L553–558, L517–522)**: 触发 = `BudgetStop::MaxIterations` **且** workdir 是 git 仓库 **且** `git status --porcelain` 非空。不触发 = MaxTokens/Shutdown/两种 timeout(走 legacy 路径)、非 git 目录、clean 工作树(无空提交、不覆盖 result.md)。fail-open:`.result-owner` 缺失/不可读/内容非 "peer" 时按无 owner 处理。默认预算 50 不因此提高;任何情况不 push。

---

## 4. loop_state.rs 专节(typed retry-bucket 状态机,M6.2 #489)

768 行;`mod tests` 从 L447 起。**枚举 1 个**(public 层面;turn_state.rs 另有 4 个 `pub(crate)` 枚举,见 §2)。

生成命令:

```bash
grep -nE 'pub(\(crate\)|\(super\))? (fn|struct|enum|const) ' crates/octos-agent/src/agent/loop_state.rs
```

### 4.1 枚举与类型

- **L131 `pub enum LoopDecision`** — 状态机对循环的裁决,6 变体:
  - L134 `Continue`(BackoffRetry 类瞬态错误,原样重试)
  - L138 `RotateAndRetry`(换 provider/credential lane)
  - L141 `CompactAndRetry`(压缩对话后重试,ContextOverflow 唯一出路)
  - L145 `Escalate`(不可重试,上抛:auth/invalid request/content filter/工具或插件故障/bug)
  - L149 `Exhausted`(桶计数超限,硬停,防无限循环 #489 不变量 2)
  - L153 `Grace`(硬预算耗尽后的一次宽限迭代,须先有 ≥1 次生产性工具调用)
  - L159 `as_str()` 输出稳定 snake_case(指标/事件用)
- L42 `pub const OCTOS_LOOP_RETRY_TOTAL`(指标名);L180 `pub const SHELL_SPIRAL_VARIANT = "shell_spiral"`
- L81 `pub struct LoopRetryLimits` — 16 个桶上限字段(rate_limited 5 / context_overflow 2 / authentication 1 / quota 1 / invalid_request 2 / content_filtered 1 / provider_unavailable 4 / network 4 / timeout 3 / tool_execution 5 / plugin_spawn 2 / plugin_timeout 3 / plugin_protocol 2 / delegate_depth_exceeded 1 / internal 1 / shell_spiral 1;默认值 L44–66)
- L186 `pub struct LoopRetryCounters` — 同 16 字段的计数器
- L217 `pub struct LoopRetryState` — counters + limits + `productive_tool_calls_since_last_grace` + `grace_calls_fired`(全 serde,可经 session ledger 往返)

### 4.2 状态转移方法(impl LoopRetryState)

| 行号 | 方法 | 转移语义 |
|------|------|----------|
| L234 | `new()` | 初始态:全桶清零、默认上限 |
| L240 | `with_limits()` | 同上但显式上限(测试/运维覆盖) |
| L253 | `record_productive_tool_call()` | 记一次生产性工具调用 → 恢复 Grace 资格(productive ≥ 1) |
| L266 | `observe(error: &HarnessError)` | 错误入桶:bump 对应计数(L365 `bump_counter`),计数 > 上限 → `Exhausted`,否则按 recovery_hint 映射(L431 `decide_for_variant`:BackoffRetry→Continue / SwitchProvider→RotateAndRetry / CompactContext→CompactAndRetry / FailFast、Bug→Escalate) |
| L284 | `observe_shell_spiral()` | shell 螺旋事件:第 1 次 → `Escalate`(停 shell 重试,上抛最近输出),超限(>1)→ `Exhausted`;计数由本状态机持有 |
| L303 | `observe_budget_exhaustion()` | 硬预算耗尽:首次且 productive≥1 → `Grace`(清 productive、grace_calls_fired+1,全局仅一次);否则 → `Escalate` |
| L319 | `counters()` | 计数快照(导出/调试) |
| L327 | `emit_event()` | 构造 `HarnessEventPayload::Retry` 结构化事件(variant+decision) |

---

## 5. harness_errors.rs 专节(错误恢复主线)

745 行,路径 `crates/octos-agent/src/harness_errors.rs`。实测 **3 个类型 + 1 个指标常量**,与 spec 的「HarnessError → RecoveryHint → LoopDecision」一致:

生成命令:

```bash
grep -nE '^pub (const|enum|struct) ' crates/octos-agent/src/harness_errors.rs
grep -nE '^    (RateLimited|ContextOverflow|...)' crates/octos-agent/src/harness_errors.rs
```

| 行号 | 类型 | 职责 |
|------|------|------|
| L40 | `pub const OCTOS_LOOP_ERROR_TOTAL` | 错误指标名 |
| **L47** | **`pub enum RecoveryHint`** | 恢复提示,5 变体(L50 `BackoffRetry`/L53 `SwitchProvider`/L56 `CompactContext`/L60 `FailFast`/L63 `Bug`);L69 `as_str()` 稳定 snake_case |
| **L93** | **`pub enum HarnessError`** | 规范化错误,15 变体:L96 `RateLimited`、L102 `ContextOverflow`、L109 `Authentication`、L115 `Quota`、L118 `InvalidRequest`、L120 `ContentFiltered`、L123 `ProviderUnavailable`、L128 `Network`、L130 `Timeout`、L133 `ToolExecution`、L135 `PluginSpawn`、L140 `PluginTimeout`、L146 `PluginProtocol`、L153 `DelegateDepthExceeded`、L160 `Internal` |
| **L166** | **`pub struct HarnessErrorEvent`** | 结构化错误事件(入 harness event sink);L198 `variant_name`、L231 `variant_is_tool_scoped` |

HarnessError 关键方法:L240 `recovery_hint()`(变体→恢复提示;**`ProviderUnavailable` → `SwitchProvider`,L249**——spec「事实边界」问的 agent 内 lane 映射:映射在 harness_errors.rs,实际换 lane 由 loop 侧 `RotateAndRetry` 裁决驱动)、L287 `message()`、L309 `metric_labels()`、L317 `record_metric()`、L334 `classify_report()`(eyre::Report → HarnessError)、L356 `from_llm_error()`(LlmErrorKind → HarnessError,如 ModelNotFound/ServerError → `ProviderUnavailable`)、L414 `to_event()`。

---

## 6. master_continuation_scheduler.rs 专节(续跑边界,goal 层)

1416 行,路径 `crates/octos-cli/src/autonomy/master_continuation_scheduler.rs`。

生成命令:

```bash
grep -nE 'pub(\(crate\))? (fn|struct|enum|trait|type|const) ' \
  crates/octos-cli/src/autonomy/master_continuation_scheduler.rs
grep -rn 'MasterContinuationScheduler' crates/octos-cli/src/autonomy/agent_orchestrator.rs | head
```

### 6.1 符号清单(全部 `pub(crate)`,cli crate 内部接口)

- 常量:L37 `RECENT_CLAIM_GUARD_WINDOW`(30s)、L60 `MAX_REDELIVERY_ATTEMPTS`(5)
- L99 `struct MasterContinuationId`;L112 `struct MasterContinuationDedupeKey`;L218 `type MasterContinuationMetadata`
- **L137 `enum MasterContinuationReason`** — 6 变体:`ChildCompleted` / `ScatterJoinComplete` / `LoopFire` / `GoalContinue` / `GoalWrapUp`(#1131,预算耗尽的收尾 turn)/ `External(String)`;L152 `priority()` 映射优先级
- L186 `enum MasterContinuationPriority`(L196 `rank`,Ord 按优先级出队)
- L221 `struct MasterContinuationRequest`(builder:L235 `new`、L256–288 `with_child_agent_id`/`with_goal_id`/`with_loop_id`/`with_metadata`/`with_dedupe_key`/`stable_dedupe_key`)
- L334 `struct QueuedMasterContinuation`;L373 `enum MasterContinuationEnqueueOutcome`(queued/duplicate);L396 `enum ReinsertOutcome`;L410 `enum RuntimeActivity`;L416 `struct MasterContinuationRuntimeState`(L449 `is_idle_eligible`)
- **L477 `struct MasterContinuationScheduler`** — 延迟优先队列;方法:L525 `enqueue`、L532 `enqueue_at`、L606 `cancel`、L631 `reinsert`、L656 `peek_ready`、L668 `pop_ready`、L687 `drain_ready`、L706 `drain_ready_for_session`、L748 `pending_count_for_session`、L765 `pending_sessions`、L776 `pending_items`、L842 `has_recent_external_claim_with_prefix`、L866 `clear_recent_external_claim`

### 6.2 与 agent loop 的衔接点(实测)

- 本文件是**纯数据结构 + 队列**(无 tokio、无 LLM 调用);「turn 结束后再创造 turn」的驱动在消费侧。
- 持有方:`agent_orchestrator.rs` L11783 `continuations: MasterContinuationScheduler`(AgentOrchestrator 状态字段)。
- 出队点:`agent_orchestrator.rs` L3027 `drain_ready_continuations_for_session` → L3112 `drain_ready_continuations_locked` → scheduler 的 `drain_ready_for_session`(L3158);L4843 注释明确并发正确性靠 ORDER 而非单锁(`pop_ready` 语义)。
- 入队来源(同目录):`fleet_wake.rs`、`commands/steer.rs`;`LoopFire` 项在 session 停车时被退役(agent_orchestrator.rs L2028–2064)。
- **与本章的关系**:spec 的定位成立——它属于 goal 层自动续跑,不在 agent loop 内部;loop 侧唯一可见效果是:一次 `run_task` 返回 stop_reason 后,orchestrator 依据 ready 队列(优先级:LoopFire > ChildCompleted/ScatterJoinComplete > GoalContinue(含 GoalWrapUp)> External)再次派发新 turn。细节属第 18 章。

---

## 7. 交付前复跑记录(2026-09-02)

以下命令在成文前复跑,结果与上文一致:

1. 模块清单:`ls crates/octos-agent/src/agent/ | grep -v '_tests' | wc -l` → **20**
2. 行数表:逐文件 `wc -l`(20/20 与 §1 表一致);总行数 `cat $(ls *.rs | grep -v '_tests') | wc -l` → **21,369**
3. budget.rs 专节:`grep -nE '(pub(\(crate\)|\(super\))? )?(async )?fn ' budget.rs`(非测试区 L41/L90/L100/L141 + L484–L546,与 §3 一致);`grep -nE '^    (Shutdown|MaxIterations \{|...)'` 变体行号一致
4. loop_state.rs 专节:`grep -nE 'pub(\(crate\)|\(super\))? (fn|struct|enum|const) '` → L42/L81/L131/L159/L180/L186/L217/L234/L240/L253/L266/L284/L303/L319/L327,与 §4 一致;`LoopDecision` 6 变体行号(L134/138/141/145/149/153)复验一致
5. harness_errors.rs:类型行号 L47/L93/L166 复验一致;`ProviderUnavailable` 变体 L123、`→ SwitchProvider` 映射 L249 复验一致
6. master_continuation_scheduler.rs:`wc -l` → **1416**;scheduler 结构 L477、orchestrator 持有点 L11783 复验一致

**对 spec 的两点实测补正**(正文引用时以此为准):
- 符号可见性:`agent/` 目录大量接口是 `pub(crate)`/`pub(super)` 而非全公开 `pub`(如 execution.rs 全部派发入口、streaming.rs 消费入口);`loop_runner.rs` 的 `process_message`/`run_task` 家族是全公开 `pub async fn`。
- `execution.rs`(4730 行)是目录内最大模块,超过 `loop_runner.rs`(3979 行)。
