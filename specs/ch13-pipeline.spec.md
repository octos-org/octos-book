spec: task
name: "Ch13. octos-pipeline：DOT 图驱动的工作流引擎(v2 段落重写,原 Ch12)"
inherits: project
tags: [part3, pipeline, dot, workflow, orchestration]
depends: [ch05-agent-loop]
estimate: 1.5d
---

## 意图

本章应准确描述当前 `crates/octos-pipeline/src/` 的实现：DOT 解析如何生成
`PipelineGraph`，6 种 `HandlerKind` 如何在执行器中落地，`Parallel` /
`DynamicParallel` 的真实 fan-out 机制，以及 `run_pipeline` 工具如何把 pipeline
暴露给 Agent。对 `human_gate`、`checkpoint`、`run_dir`、`ModelStylesheet` 的描述
必须区分“模块存在”、“可选配置已接入执行器”和“默认 `run_pipeline` 工具路径”。

## 决策

- 源码目录: `crates/octos-pipeline/src/`
- 重点文件:
  `parser.rs`, `graph.rs`, `executor.rs`, `handler.rs`, `condition.rs`,
  `validate.rs`, `tool.rs`, `discovery.rs`
- 相邻模块:
  `human_gate.rs`, `checkpoint.rs`, `run_dir.rs`, `stylesheet.rs`
- 图表: 示例 DOT、6 类节点对比表、执行流程 Mermaid 图
- 工程决策侧栏: 为什么选 DOT 而非 YAML/JSON
- 当前增补重点:
  `PipelineHostContext`, `PipelineContext`, cost reservation, node cost metadata,
  deadline action, mission checkpoint, cumulative fan-out cap, synthetic report delivery

- 事实边界(2026-09-02 main): `crates/octos-pipeline/src/ir.rs:57` 的 `IrNodeKind` 与 `graph.rs:241` 的 `HandlerKind`;`6b0de6ca` 把 DOT 调色板扩到 12 种 IR 节点并新增 ShellCheck / Notify / Wait handler,旧稿「5 种 Handler」作废,以枚举变体现算为准并附命令
- 新面必补: `92175f53` per-node `max_iterations` 可配;`f26d2291` 结构化 per-node 进度 + ETA + previews 经 harness 事件通道(与 Ch10 互引);`543010be` workflow 子系统抽取为 `crates/octos-workflows/`(`workflow_runtime.rs`、`workflow_families/`、`workflows/`)——本章加一节「workflow 与 pipeline 的分工」
- 重编号: 本章由 Ch12 改为 Ch13;`chapters/ch12-pipeline.md` → `chapters/ch13-pipeline.md`,`book/src/part3/ch12.md` → `book/src/part3/ch13.md`,SUMMARY.md 同步;交叉引用按 OUTLINE.md v2 重标
- 勘误方式: 保留结构,改写 handler 小节为 IR 节点小节,新增进度事件与 workflow 分工两小节;引用行号逐条重标
- 分析基线: octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch12-*.md
- octos-book/book/src/part3/ch12.md
- octos-book/book-en/src/part3/ch12.md
- octos-book/assets/ch12-*
- octos-book/specs/ch12-pipeline.spec.md

### 禁止做
- 不做 Graphviz DOT 语法完整教程
- 不重复第 5 章的 Agent Loop 细节

## 排除范围

- Graphviz 渲染引擎内部
- 与 Airflow / Prefect / Step Functions 的详细横向评测

## 完成条件

场景: DOT 解析为带类型的 PipelineGraph
  测试: review_ch12_dot_parsing
  当 阅读 DOT 解析小节
  那么 展示了一个完整的 DOT 工作流定义示例
  并且 解释了 `parse_dot()` 的入口和 `DotParser::parse()` 的职责
  并且 说明了可选图名、graph 级属性、subgraph、edge chain、自动补节点这些当前 parser 能力
  并且 说明了节点属性到 `PipelineNode` 的映射规则以及 handler 解析顺序
  并且 说明了 `deadline_secs` / `deadline_action` / `checkpoint` 已经进入节点模型

场景: 6 种 HandlerKind 与执行路径
  测试: review_ch12_handler_kinds
  当 阅读节点类型小节
  那么 列出了 `Codergen`、`Shell`、`Gate`、`Noop`、`Parallel`、`DynamicParallel` 六种类型
  并且 说明了只有前四种是 `Handler` trait 实现
  并且 说明了 `Parallel` / `DynamicParallel` 是 `PipelineExecutor::execute_graph()` 中的专门分支

场景: Gate 与 human_gate 的边界
  测试: review_ch12_gate_vs_human_gate
  当 阅读 Gate 小节
  那么 明确说明当前接入执行器的是 `handler.rs` 中的 `GateHandler`
  并且 解释了它把 `prompt` 当作条件表达式求值
  并且 明确说明 `human_gate.rs` 提供了 channel-based human input 抽象
  并且 不把 `human_gate.rs` 写成当前 `PipelineExecutor` 默认主路径的一部分

场景: Parallel 与 DynamicParallel 的 fan-out 细节
  测试: review_ch12_parallel_runtime
  当 阅读并发节点小节
  那么 解释了 `Parallel` 会并发执行真实下游节点并跳到 `converge`
  并且 说明了 `DynamicParallel` 会先规划任务，再合成临时 `Codergen` worker 节点
  并且 说明了 `Parallel` 使用 `max_parallel_workers` 限制并发
  并且 说明了 `DynamicParallel` 主要依赖 `max_tasks` 约束 fan-out 上限
  并且 说明了两种 fan-out 现在还受 `MAX_PIPELINE_FANOUT_TOTAL` 的 pipeline 生命周期总量上限保护

场景: 条件语言与选边算法
  测试: review_ch12_conditions
  当 阅读条件边小节
  那么 使用当前真实的 `outcome.status` / `outcome.contains()` 条件语法
  并且 解释了 `select_next_edge()` 的 5 步选择顺序
  并且 不再使用过时的 `success` / `failure` 简写
  并且 若提及 `context.*` 语法 明确说明其在当前执行主路径中尚未注入实际上下文 map

场景: 模型选择与相邻/可选模块
  测试: review_ch12_model_and_adjacent_modules
  当 阅读模型和执行引擎小节
  那么 说明当前生效的模型选择主路径是 `graph.default_model + node.model`
  并且 若提及 `ModelStylesheet` 明确说明它是已导出模块但不应被描述为当前执行主路径
  并且 若提及 `CheckpointStore` 明确说明它是 `ExecutorConfig` 可选接线而非默认 `RunPipelineTool` 路径
  并且 若提及 `RunDir` 明确说明它仍是相邻模块而不是默认 `RunPipelineTool` 路径

场景: run_pipeline 工具集成
  测试: review_ch12_tool_integration
  当 阅读工具集成小节
  那么 解释了 `RunPipelineTool` 如何解析 inline DOT、名称和文件路径
  并且 说明了 `PipelineDiscovery` 的搜索路径
  并且 说明了 inline DOT sanitize / parse-fallback / 总超时钳制这些当前工具层行为
  并且 说明了工具会从 `TOOL_CTX` 快照 host context，读取 workspace policy，合成缺省 markdown 报告，并通过 structured metadata 暴露 node cost

场景: DOT vs YAML 侧栏
  测试: review_ch12_dot_sidebar
  当 阅读工程决策侧栏
  那么 对比了 DOT、YAML、JSON 作为工作流定义语言的权衡
  并且 强调了 DOT 的图结构原生语义和可视化优势

场景: pipeline runtime parity 与生产护栏
  测试: review_ch12_runtime_parity
  当 阅读执行引擎和工具集成小节
  那么 说明 `PipelineHostContext` 如何把父 session 的 FileStateCache、SubAgentOutputRouter、AgentSummaryGenerator、TaskSupervisor、CostAccountant 传给节点 worker
  并且 说明 pipeline 级和节点级 cost reservation 的关系
  并且 说明 per-node / terminal validators 如何通过 workspace policy 生效
  并且 说明 deadline action 的 `abort` / `skip` / `retry` / `escalate` 语义

场景: IR 节点种类准确
  测试: review_ch13_ir_kinds
  当 阅读 IR 节点小节
  那么 节点种类数与 `ir.rs` 的 `IrNodeKind` 变体数一致并附统计命令
  并且 ShellCheck / Notify / Wait 三个新 handler 各有一句话定位与行号

场景: 进度事件与 workflow 分工写明
  测试: review_ch13_progress_workflows
  当 阅读新增两小节
  那么 per-node 进度/ETA 经 harness 事件通道的说明引用 f26d2291 改动文件并以「详见第 10 章」引出事件 ABI
  并且 `octos-workflows` 与 `octos-pipeline` 的职责边界引用 `workflow_runtime.rs`

场景: 重编号完成
  测试: review_ch13_renumber
  当 检查文件名与 SUMMARY.md
  那么 章节文件为 `chapters/ch13-pipeline.md`、镜像为 `book/src/part3/ch13.md`
  并且 SUMMARY.md 对应条目为第 13 章

场景: 引用零失效
  测试: review_ch13_refs_valid
  当 提取正文全部 `crates/...rs:行号` 引用并对照当前源码
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
