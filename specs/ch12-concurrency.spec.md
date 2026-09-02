spec: task
name: "Ch12. 并发模型：Tokio 异步架构实战(v2 重写,原 Ch11)"
inherits: project
tags: [part3, concurrency, tokio, async, mutex]
depends: [ch05-agent-loop, ch10-message-bus]
estimate: 1d
---

## 意图

octos 的并发模型是其性能和可靠性的基石。本章展示 session actor、
actor 内部消息任务、信号量限流、工具并发执行、TaskSupervisor 和 AgentOrchestrator 等机制如何协同工作，
是 Rust 异步编程的生产级实战教材。当前主分支中 MCP server lifecycle、
background spawn lifecycle、harness events 和 swarm dispatch 都复用或投射到这些
生命周期概念，本章需要补足 `TaskSupervisor`、`AgentOrchestrator`、`SupervisorStore`
与 CLI/MCP/Harness/AppUI 控制面的连接。

## 决策

- 源码分散在多个 crate，以模式为主线而非文件为主线
- 重点代码: session actor、Agent spawn 逻辑、join_all 工具并发、TaskSupervisor、AgentOrchestrator、SupervisorStore、MasterContinuationScheduler、MCP server lifecycle observer、AtomicBool 关停
- 图表: 并发模型全景图（Mermaid）、消息处理并发/串行分界、Task lifecycle projection 图
- 工程决策侧栏: 从共享 Mutex 到 Session Actor 的取舍

- 事实边界(2026-09-02 main): 并发原语分三层写:① Tokio 层(session actor、信号量限流、工具 join_all、优雅关停,旧稿 11.1-11.6 保留骨架并重标行号);② supervisor 层(`crates/octos-cli/src/autonomy/` 十个文件、约 4.5 万行:`supervisor_store.rs` 事件账本、`master_continuation_scheduler.rs` 续跑调度、`goal_loop_runtime.rs` goal/loop 调度策略、`agent_orchestrator.rs`、`fleet_wake.rs` outbox→keeper 唤醒、`monitor_runtime.rs` 零 token 事件监视器 `c4f03647`);③ peer≈进程模型(`crates/octos-cli/src/peers/mod.rs`)与 fleet 的 lease/attempt 状态机(`crates/octos-fleet/src/records.rs:250-256` `Lease` / `Attempt`),后者只交代作为并发原语的角色,细节「详见第 16 章」「详见第 18 章」
- 事实表先行: `assets/ch12-facts.md` 列 autonomy/ 十个文件的行数与首行文档、关键类型行号、peers/mod.rs 顶部文档、records.rs 两个结构体行号;每项附命令
- 重编号: 本章由 Ch11 改为 Ch12;`chapters/ch11-concurrency.md` 改名 `chapters/ch12-concurrency.md`,镜像 `book/src/part3/ch11.md` 改名 `book/src/part3/ch12.md`,SUMMARY.md 同步;交叉引用按 OUTLINE.md v2 重标
- 图表: 三层并发原语全景图、supervisor 事件账本与续跑调度时序图、peer≈进程 vs subagent≈线程对比图
- 工程决策侧栏: 为什么把长程编排从 Tokio task 提升为持久化 supervisor(重启幸存)
- 分析基线: octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch11-*.md
- octos-book/book/src/part3/ch11.md
- octos-book/book-en/src/part3/ch11.md
- octos-book/assets/ch11-*

### 禁止做
- 不做 Tokio 入门教程（假设读者有基础概念）
- 不重复 Agent Loop 细节（Ch5 已覆盖）

## 排除范围

- Tokio runtime 内部调度原理
- async-std 等其他异步运行时对比

## 完成条件

场景: session actor 分层并发
  测试: review_ch11_session_actor
  当 阅读 session actor 与分层 spawn 小节
  那么 解释了 Gateway dispatch、session actor、actor 内部 agent task、tool task 和后台 subagent 的层级关系
  并且 说明了同一 session 的核心状态由 actor 持有，而不是旧的 per-session Mutex 叙事
  并且 展示了 `tokio::spawn()` 在会话、消息、工具或后台任务中的实际调用语义

场景: 信号量限流
  测试: review_ch11_semaphore
  当 阅读信号量小节
  那么 解释了 `max_concurrent_sessions` 默认 10 的配置
  并且 说明了超限时的排队行为

场景: 工具并发执行
  测试: review_ch11_tool_concurrency
  当 阅读工具并发小节
  那么 解释了 `join_all` 在单次迭代内并行执行多工具的机制
  并且 说明了子 Agent 同步 vs 后台双模式的差异

场景: spawn_only 生命周期监督
  测试: review_ch11_task_supervisor
  当 阅读 TaskSupervisor 小节
  那么 说明了 `spawn_only` 后台任务由 TaskSupervisor 维护状态 ledger
  并且 列出 Spawned/Running/Completed/Failed/Cancelled 等关键状态
  并且 说明了默认 fan-out 上限 200 和 `OCTOS_MAX_CHILDREN_PER_PARENT`
  并且 说明了 workspace contract 与 artifact 验证先于 supervisor 状态更新

场景: 优雅关停
  测试: review_ch11_graceful_shutdown
  当 阅读优雅关停小节
  那么 解释了 `AtomicBool` 的 Release/Acquire 内存序
  并且 展示了 shutdown 信号从接收到传播的完整链路

场景: actor model 侧栏
  测试: review_ch11_actor_sidebar
  当 阅读工程决策侧栏
  那么 对比了共享 Mutex、完全无状态 spawn-per-message 和 Session Actor
  并且 解释了 octos 当前选择 Session Actor 的状态所有权优势和实现复杂度

场景: Task lifecycle 投射到 MCP 和 Harness
  测试: review_ch11_task_lifecycle_projection
  当 阅读 TaskSupervisor / lifecycle 小节
  那么 说明 MCP server 的 `run_octos_session` 通过 lifecycle observer 标记 Running、Verifying、Ready 或 Failed
  并且 说明外层 MCP caller 接收的是 session aggregate outcome，而不是内部工具事件流
  并且 说明 background spawn lifecycle 会通过 harness events / metrics 进入 operator 可观测面
  并且 包含 Task lifecycle projection Mermaid 图

场景: AgentOrchestrator lifecycle projection
  测试: review_ch11_agent_orchestrator
  当 阅读 AgentOrchestrator 小节
  那么 说明 `InProcessAgentOrchestrator` 如何把 `TaskSupervisor` background task mirror 成 agent state
  并且 说明 `run_native_specialist` 会注册 native_agent、运行子 Agent、推送 output/artifact 并回写 supervisor
  并且 说明 trait 默认 `spawn_agent` / `send_input` / `wait_agent` / `resume_agent` 并非所有实现都已生产接线
  并且 说明 `SupervisorStore` 的 JSONL event ledger + snapshot 持久化职责
  并且 说明 `MasterContinuationScheduler` 用 dedupe key 和优先级安排 child/goal/loop 后续 turn
  并且 不把当前实现夸大成任意互联实时对话的完整 multi-agent society

场景: 事实表可复现
  测试: review_ch12_facts_sheet
  假设 `assets/ch12-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 autonomy/ 十个文件的行数、首行文档、关键类型行号与命令输出一致

场景: 三层并发原语齐全
  测试: review_ch12_three_layers
  当 阅读全景图与三层小节
  那么 Tokio 层、supervisor 层、peer/lease 层各有至少两处源码行号引用
  并且 fleet 与 goal/peer 细节以「详见第 16/18 章」引出

场景: supervisor 层准确
  测试: review_ch12_supervisor
  当 阅读 supervisor 小节与时序图
  那么 事件账本、续跑调度、outbox 唤醒、监视器四件各引用对应文件行号
  并且 `monitor_runtime.rs` 注明 c4f03647

场景: 重编号完成
  测试: review_ch12_renumber
  当 检查文件名与 SUMMARY.md
  那么 章节文件为 `chapters/ch12-concurrency.md`、镜像为 `book/src/part3/ch12.md`
  并且 SUMMARY.md 对应条目为第 12 章

场景: 引用零失效
  测试: review_ch12_refs_valid
  当 提取正文全部 `crates/...rs:行号` 引用并对照当前源码
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
