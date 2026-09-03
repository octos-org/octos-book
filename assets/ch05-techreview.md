# Ch5 技术审查报告（C2 lane）

- **审查对象**: `chapters/ch05-agent-loop.md`，**开工时刻所见版本 593 行**（章稿正在补深度修订；本报告全部行号以 593 行版为准。`book/src/part2/ch05.md` 为 607 行，镜像当前**不一致**，定稿前须同步）
- **事实基准**: `assets/ch05-facts.md`（octos main @ `9c157101`）；源码只读复核于 `/Users/zhangalex/Work/Projects/FW/octos @ 9c157101`（已实测确认 HEAD）
- **审查员**: C2 techreview（只报告不改稿）。行号核对细节归 C1 lane，本报告只收录影响技术判断的行号证据。

## 0. 计数表

| 级别 | 数量 | 编号 |
|------|------|------|
| Critical（技术错误/规格缺口，阻断定稿） | 7 | C-1 … C-7 |
| Major（结构/深度问题） | 4 | M-1 … M-4 |
| Minor（行号漂移/小遗漏） | 8 | m-1 … m-8 |
| 亮点（已核实正确） | 5 | ✔-1 … ✔-5 |

**结论：不可定稿。** 机制主线（迭代流程、stop_reason、循环检测、预算门禁顺序、ProviderUnavailable 边界）技术上站得住，但 4 项 spec 明确要求的内容整块缺失（#27e 检查点、scheduler 续跑边界、循环自愈实例、Grace/Exhausted 完整语义），1 处流式超时数字与源码不符，且 5.8 的关键行号错位。补齐后可复审定稿。

---

## 1. Critical

### C-1 #27e 预算检查点整节缺失（spec 决策第 24 条）
章稿全文 0 次出现 `#27e` / `checkpoint` / `result.checkpoint.md`（grep 无命中）。spec 要求「必须写清触发条件与不触发条件」。源码事实：
- `budget.rs:546 checkpoint_budget_exhaustion()`：`else` 分支 L553-556 直接 `return None`——**仅 `BudgetStop::MaxIterations` 触发**；非 git 目录（`.git` 不存在）不动作；`git status --porcelain` 为空（clean）不动作、不产生空 commit。
- #27h：peer 拥有 result.md（sidecar `.result-owner` 判 `peer`）时写 `result.checkpoint.md`（L579-581），**永不覆盖** peer 的 `result.md`；commit message `wip: budget exhausted (#27e) — checkpointed mid-task`，`git add -A` 本地 commit，**永不 push**。
- 调用点 `loop_runner.rs:2328`（`run_task_inner` 预算停机路径，注释 "#27e (R2)"）。与事实表 §3.2 完全一致。
章稿 5.2.3/5.7 只写了 `record_budget_stop` 就 return，把 #27e 整段丢掉了。**修复**：在 5.5 或 5.2.3 后增「预算检查点」小节，覆盖触发三条件（MaxIterations + git 仓库 + dirty）与不触发三条件（MaxTokens/Shutdown/timeout、非 git、clean），以及 #27h 双文件语义与永不 push。

### C-2 scheduler「goal 层、loop 之外」定位缺失（spec 决策第 26 条，brief 检查项 1）
章稿 0 次出现 `scheduler` / `continuation` / `第 18 章`（grep 无命中）。turn 结束后「谁来再造一个 turn」这条边界完全没讲。源码事实：`master_continuation_scheduler.rs` 1416 行；`MasterContinuationScheduler` L477（延迟优先队列，`enqueue` L525 / `drain_ready` L687 / `drain_ready_for_session` L706）；持有方 `agent_orchestrator.rs:11783`（`continuations` 字段，实测确认）；出队链 `agent_orchestrator.rs:3027 → 3112 → scheduler L706`。`MasterContinuationReason` L137 六变体含 `GoalWrapUp`（预算耗尽收尾）——与本章预算叙事天然衔接。**修复**：5.8 末尾或 5.9 前加一段「turn 之外：goal 层续跑」，一段即可，细节指第 18 章。

### C-3 5.8 映射表缺 `Quota → SwitchProvider`（表会教错读者）
章稿 L520-527 的失败类型表把可恢复面写全了吗？没有：`Quota` 变体（harness_errors.rs:115）在 `recovery_hint()` 中映射为 **`SwitchProvider`**（L267，#27b：402/429-billing/403-quota 是 provider 降级而非致命，真 401 `Authentication` 才是 FailFast，L275-278 有 pinned contract 注释与测试 `quota_switches_provider_but_401_stays_fail_fast`）。章稿表把 `Authentication` 归 FailFast 是对的，但完全没提 `Quota`——读者遇到 quota burn 会按表中最近的 `Authentication` 行误判为致命。附带：`PluginTimeout` 也映射 `BackoffRetry`（L246），表中 `RateLimited/Network/Timeout` 一行未含它。**修复**：表中加一行 `Quota → SwitchProvider → RotateAndRetry`，并把 `PluginTimeout` 并入 BackoffRetry 行；一句话点出「quota ≠ 401」的 pinned 边界（这正是源码注释里最强调的 invariant）。

### C-4 LoopDecision 6 变体只讲了 4 个：`Grace` 与 `Exhausted` 不在 5.8 表中
`loop_state.rs:131-159` 定义 6 变体（facts §4.1：Grace L153、Exhausted 约 L146）。章稿 5.8 表只有 Continue/RotateAndRetry/CompactAndRetry/Escalate；`Exhausted` 仅在正文 L531 顺带一句，`Grace` 只在 5.7 代码注释（L398 `try_budget_grace_call`）和 L549 一笔带过，语义从未展开。源码事实：
- Grace 资格：`observe_budget_exhaustion()`（loop_state.rs:303-313）——`grace_calls_fired == 0 && productive_tool_calls_since_last_grace >= 1` 才给一次宽限迭代，**全局仅一次**（源码注释明说 deliberately global，防止productive-read 死循环）；否则 `Escalate`。`record_productive_tool_call()` L253 恢复资格计数。
- Grace 适用停机类型：`try_budget_grace_call`（loop_runner.rs:602-640）只对 `MaxIterations | MaxTokens`（L611-615），`Shutdown/ActivityTimeout/IdleProgressTimeout` 永不宽限（doc 注释 L596-599）——注意这与 #27e「仅 MaxIterations 落盘」是**两个不同的谓词**，章稿补写时必须区分。
**修复**：5.8 表补 `Exhausted`（bucket>limit 硬停，#489 invariant #2）与 `Grace`（一次性、须先有 ≥1 生产性工具调用）两行，并写清 grace-eligible stop 集合与 #27e checkpoint 集合的差异。

### C-5 MaxTokens 分支过时：#2174 空 MaxTokens nudge 与 continuation 未提（spec 决策第 25 条全缺）
章稿 5.3.3（L291-294）写「循环退出，返回截断的内容」。源码实际两套机制：
- 对话循环 `loop_runner.rs:2154+`：MaxTokens 且 content 为空且无 tool call 且 `max_token_empty_recoveries < MAX_TOKENS_CONTINUATION_LIMIT` 时，做 bounded nudge-and-retry（#2174，防静默空退出）；有 content 的正常截断才原样返回。
- 任务循环 `loop_runner.rs:2660-2667` 调 `push_max_tokens_continuation`（L3912-3918：推 assistant + `MAX_TOKENS_CONTINUATION_PROMPT` user 消息**继续循环**）——这直接推翻 5.3.3「MaxTokens 一律退出」与图 5-2「ToolUse 是唯一触发循环继续的分支」的绝对表述。
spec 要求的「循环自愈」小节（`9fe39f1b` 空 MaxTokens nudge、`3c7ff8bf` cloud-safe temperature override 两个实例）章稿 **0 覆盖**（grep `自愈/nudge/9fe39f1b/3c7ff8bf` 无命中；`chat_temperature` 的 cloud-unchanged 语义就在 mod.rs:88-92 注释里）。**修复**：重写 5.3.3 并修图 5-2 注脚（改为「对话模式下 ToolUse 是唯一的常规继续分支；任务模式的 MaxTokens continuation 是受控例外」），新增循环自愈小节收这两个实例。

### C-6 流式 inter-chunk 超时写成 30s，实际默认 90s 且可配置——事实错误
章稿 L222-231 代码示例 `Duration::from_secs(30)`，5.6 表「token 间隔 固定 30s」。源码：`StreamTimeouts.inter_chunk_idle_secs` 生产值来自 `AgentConfig.llm_stream_idle`（streaming.rs:98-99），默认 `DEFAULT_LLM_STREAM_IDLE_SECS = 90`（mod.rs:150），env `OCTOS_LLM_STREAM_IDLE_SECS` 可覆盖；且存在章稿未提的第三道闸 `overall_max_secs`（wall-clock backstop，默认 `llm_call_max` 1200s，mod.rs:152、streaming.rs:29-32）。TTFT 公式 `30 + input/1000`、上限 `first_token_grace_secs` 默认 180s（streaming.rs:173-175、mod.rs:148）这一半是对的。**修复**：5.2.7/5.6 的示例代码与表格改为「TTFT = 30s+1s/1K，上限 180s（可配）；inter-chunk 默认 90s（可配）；overall 1200s 兜底」三闸模型。

### C-7 5.8 两处关键行号错位到错误函数（技术叙述的对/错因此不可信）
- L529 称 RotateAndRetry bail 边界在 `loop_runner.rs:336-350`：实测 336-350 落在 `classify_loop_error`（L313 起）的事件上报段；真正的 arm 在 **L514-530**（注释原文 "rotate_and_retry requested but no hook wired; bailing"，L522）。叙述本身正确（见 ✔-4），行号须改为 514-530（facts 表：`handle_loop_error_with_dispatch` L476）。
- L547 称 CompactAndRetry in-band 压缩在 `loop_runner.rs:321-339`：实测该段同样在 classify_loop_error 内；真正分支在 **L494-511**（调 `maybe_run_turn_compaction` + `prepare_prompt_with_context_manager(PromptContextPhase::Retry)`）。
两处错号都指向同一个旧版本函数布局，属系统性漂移（见 M-4），但这两条直接支撑 5.8 的核心论点，单列 critical。

---

## 2. Major

### M-1 20 模块地图主线未落地，章节骨架仍是旧版「200 行走读」
spec 意图明确：以模块地图讲生命周期，支线文件「各一段，不展开」。593 行版实际结构是 5.1 结构体 → 5.2 主循环走读 → … → 5.7 核心 200 行 → 5.8 typed recovery，与 spec 所替换的旧骨架同构。`verifier.rs`（881 行，ready-gate/turn ledger）、`append_only_audit.rs`、`activity.rs`、`realtime.rs`、`rich_output.rs`、`turn_failure.rs`、`prompt_segments.rs`、`detection.rs`（858 行）在章稿中 0 次出现（grep 确认）。brief 检查项 3 的「20 模块叙事每模块都有为什么」无从谈起——目前只有 loop_runner/streaming/loop_state/budget/message_repair 五个模块有设计动机。若 ch05-writer 本轮扩写正是补此缺口，以其新稿为准复审。

### M-2 turn 生命周期 Mermaid sequence 图缺失
spec 图表清单第 1 项「一次 turn 的生命周期时序图（Mermaid sequence）」。章稿只有 flowchart（图 5-1）与状态图（5.8），无 sequence 图。DDIA 式「一次对话的完整生命周期」主线（brief 检查项 5）因此缺少跨模块时序骨架：消息构建→LLM 调用→流式→stop_reason→工具→预算→检查点→（外）continuation。

### M-3 工程决策侧栏错位：spec 要 typed retry-bucket 侧栏，现有侧栏是 Actor Model
现有侧栏（L483-515）本身质量不错（见 ✔-5），但 spec 决策第 29 条点名「为什么把 retry 状态从 `bool` 提升为 typed bucket 状态机」。5.8 正文有这个叙事的素材（每 variant 独立 bucket+hard limit、`PersistentRetryStateGuard` 跨 turn hydrate/drop 写回、serde 可经 session ledger 往返——loop_runner.rs:267/295-301、facts §4.2），但没有以侧栏格式高亮，深度停在「是什么」，缺「bool 方案为什么会坏」（全局计数器会把 quota 与网络抖动混桶、grace 资格无处安放、不可序列化故不可跨 turn）。建议 5.8 内新增第二个侧栏而非替换 Actor 侧栏。

### M-4 系统性行号漂移：全章 loop_runner/budget/turn_state/mod 引用疑似来自旧 commit，与事实表（9c157101）大面积不符
抽查对照（章稿引用 → 事实表/实测）：`budget.rs:42-80 check_budget` → **L100**；`budget.rs:82-123 report_budget_stop` → **L141**；`turn_state.rs:103-120 record_usage` → **L138**；`mod.rs:93-112 TokenTracker` → **L288**；`mod.rs:143-230 Agent` → **L309**；`mod.rs:45-94 AgentConfig` → **L62**；`loop_runner.rs:578-1057 主循环` → **L852-2242**；`33-41,293-474 入口` → **L784/852/2243**；`735-740 工具数警告` → **L1264-1270**；`754-814 LLM 调用` → 空响应重试实际 **L1310**；`849-865 EndTurn` → **L1486**；`866-1013 ToolUse` → **L1543**；`1014-1029 MaxTokens` → **L2154**；`1030-1051 ContentFiltered` → **L2210**；`mod.rs:168-173 is_loop_detected_recently` → **L1450**。spec 禁止「未核实的行号引用」，此规模须整章对齐事实表重标（细节归 C1 复核，此处确认漂移是系统性的）。

---

## 3. Minor

- **m-1** L518 引 `harness_errors.rs:93-233`：93 起 HarnessError 枚举对，但 `recovery_hint()` 在 **L240-287**，`ProviderUnavailable → SwitchProvider` 在 **L249**（实测确认，与 brief 给的一致）——引用范围应延至 287。
- **m-2** L518 引 `loop_state.rs:126-148` 为 LoopDecision：枚举实际 **L131-159**，`Grace` 变体在 **L153**，落在引用范围之外。
- **m-3** L531 引 `loop_state.rs:70-104, 171-253`：`LoopRetryState` 结构 **L217**，`observe()` **L266**、`observe_shell_spiral()` **L284**、`observe_budget_exhaustion()` **L303** 均在 253 之后，范围需扩到 313。
- **m-4** L309 引 `loop_detect.rs:11-16`：`LoopDetector` 结构在 **L46**，`record()` **L98**，`is_repeating()` **L196-204**。注意该文件在 `crates/octos-agent/src/loop_detect.rs`（agent/ 目录之外），事实表范围未含——建议事实表补录或章稿注明。
- **m-5** L265 章稿称 octos 定义五种 stop_reason 引 `octos-llm/src/types.rs:26-41`：超出本 lane 事实基准，移交 C1 核对。
- **m-6** L549 引 `loop_runner.rs:126-170` 为 `PersistentRetryStateGuard`：结构实际 **L267**，Drop 写回 **L295-301**。
- **m-7** AgentConfig 表（L48-58）数值全部核实正确（max_iterations 50、max_tokens None、max_timeout 1800s、tool_timeout 1800s、save_episodes true、chat_max_tokens None、suppress_auto_send_files false，mod.rs:204-232/190），仅出处行号 `45-94` 应为 `62-99` 附近；建议顺带补 `default_interactive_tool_timeout_secs`（120s，mod.rs:78-88）——它体现「interactive 工具不继承 1800s」的分层，一段话即可。
- **m-8** 镜像不一致：`chapters/ch05-agent-loop.md` 593 行 vs `book/src/part2/ch05.md` 607 行，spec 镜像同步条件当前不满足（应在 writer 定稿后统一）。

## 4. 亮点（核实无误）

- **✔-1** 5.9 预算五道门禁顺序 shutdown → iterations → idle → activity → tokens 与 `budget.rs:100-138` 实测顺序完全一致，且「activity 只在无近期进展时触发」的表述与 `check_budget` 中 `recently_active_within` 判断吻合。
- **✔-2** 循环检测描述准确：cycle 长度 1/2/3、需 3 次完整重复（`loop_detect.rs:119-123,196-204`）、窗口 12（`loop_runner.rs:1010/2305`）、检测后停止本批工具优先 shell 恢复的保守语义与 `dispatch_shell_retry_recovery`（L368）方向一致。
- **✔-3** 7 类 repair reason 清单与 `turn_state.rs:48-56` 逐字对应；「为什么需要修复」三原因分层（压缩副作用/Provider 差异/LLM 不可靠输出）技术上成立。
- **✔-4** ProviderUnavailable 边界的诚实处理是全章最出彩的一段：明确「不能描述成 loop 内自动切换 provider」（L529），与源码 L514-530 的 degrade-to-bail 注释语义一致——正是 spec「事实边界」要求的样子（仅行号错，见 C-7）。
- **✔-5** Actor Model 侧栏两方案优势/劣势对列、不贬低备选方案，给出 octos 特定理由（顺序主线、控制面可审计），公允；未把实现选择写成唯一解。跨章重复合规：对 ch03 的 4 处与 ch06 的 2 处均为指针式引用（L3/5/22/202、L23/569），无内容性重复。

## 5. 是否可定稿

**不可定稿。** 定稿前必须：① 补 C-1（#27e 小节）、C-2（goal 层续跑一段）、C-4（Grace/Exhausted 两行）、C-5（MaxTokens 分支重写 + 循环自愈小节）；② 修 C-3（Quota 行）、C-6（90s/三闸）；③ 按 M-4 对事实表整章重标行号并同步 book 镜像；④ 视 ch05-writer 本轮扩写结果复审 M-1/M-2/M-3。内容骨架健康，缺口全部可增量补齐，无需推倒。
