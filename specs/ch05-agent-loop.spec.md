spec: task
name: "Ch5. Agent Loop:一次对话的完整生命周期(v2 重写)"
inherits: project
tags: [part2, agent-loop, runtime, rewrite-v2]
depends: [ch02-core-types, ch03-llm-providers]
estimate: 2d
---

## 意图

重写第 5 章。旧稿以「loop_runner.rs 核心 200 行逐段走读」为骨架,而 2026-09-02 的
`crates/octos-agent/src/agent/` 已是 20 个模块、约 2.1 万行(不含测试),`loop_runner.rs`
单文件 133 提交中改了 39 次。本章改为按模块地图讲清一次 `process_message` / `run_task`
从入口到 stop_reason 的完整生命周期:消息准备、LLM 调用与重试、流式消费、工具派发、
typed 重试状态机、预算与检查点、退化检测。Ch16 fleet worker 与 Ch18 goal 续跑都是本章
循环的变体,本章先定基准叙事。

## 决策

- 源码目录: `crates/octos-agent/src/agent/`(20 个 .rs,不含 `*_tests.rs`);事实表先行:`assets/ch05-facts.md` 列出每个模块的行数、首行文档注释、对外 `pub fn`/`pub struct` 清单及生成命令,正文只引用事实表里核实过的符号
- 主线文件: `loop_runner.rs`(process_message / run_task 编排)、`loop_state.rs`(typed retry-bucket 状态机,M6.2 #489)、`turn_state.rs`(typed turn state)、`budget.rs`(预算与 #27e 检查点)、`execution.rs`(工具派发、hooks、超时)、`llm_call.rs`(LLM 调用与重试)、`streaming.rs`(流消费、shutdown、成本上报)、`message_repair.rs`(消息规范化与 tool pair 校验)、`detection.rs`(重复输出与可重试响应检测)
- 支线文件(各一段,不展开): `activity.rs`、`append_only_audit.rs`、`memory.rs`、`prompt_segments.rs`、`verifier.rs`、`realtime.rs`、`rich_output.rs`、`turn_failure.rs`;`compaction.rs` / `loop_compaction.rs` 只交代入口,细节「详见第 8 章」
- 恢复链: `crates/octos-agent/src/harness_errors.rs` 的 `HarnessError -> RecoveryHint -> LoopDecision` 仍是错误恢复主线;旧稿 5.8 的 typed recovery 叙事保留并对齐当前行号
- 预算检查点: `budget.rs` #27e —— 预算耗尽且工作树 dirty 时自动落 WIP commit(`wip: budget exhausted (#27e) — checkpointed mid-task`,永不 push)与 `result.checkpoint.md`,fail-open 语义(无 sidecar 时不写);必须写清触发条件与不触发条件
- 退化处理: `9fe39f1b`(空 MaxTokens 的 nudge)与 `3c7ff8bf`(cloud-safe temperature override)作为「循环自愈」小节的两个实例
- 续跑边界: `crates/octos-cli/src/autonomy/master_continuation_scheduler.rs` 的自动续跑属于 goal 层,本章只说明它如何在 turn 结束后再创造 turn,细节「详见第 18 章」
- 事实边界: `ProviderUnavailable` 的 `RotateAndRetry` 在 agent 内部是否有 provider lane hook,以当前源码为准写明;不声称已实现 self-evolving optimizer
- 图表: 一次 turn 的生命周期时序图(Mermaid sequence)、stop_reason 决策树、`LoopState` 状态图、预算检查点决策流
- 工程决策侧栏: 为什么把 retry 状态从 `bool` 提升为 typed bucket 状态机
- 镜像同步: `book/src/part2/ch05.md` 与 `chapters/ch05-*.md` 内容一致
- 分析基线: octos main @ 9c157101(章末「版本演化说明」写明)

## 边界

### 允许修改
- octos-book/chapters/ch05-*.md
- octos-book/book/src/part2/ch05.md
- octos-book/assets/ch05-*

### 禁止做
- 不讲工具的具体实现(Ch6)、沙箱(Ch7)、压缩算法(Ch8)、goal/peer 编排(Ch18)
- 不修改 octos 源码仓库
- 不保留旧稿中未在本次会话核实的行号引用

## 排除范围

- LLM Provider 内部(Ch3)
- 具体工具语义(Ch6)
- 上下文压缩算法(Ch8)

## 完成条件

场景: 事实表可复现
  测试: review_ch05_facts_sheet
  假设 `assets/ch05-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 20 个模块的行数与首行文档注释与命令输出一致
  并且 正文引用的每个符号都出现在事实表的清单里

场景: 模块地图完整
  测试: review_ch05_module_map
  当 阅读本章「模块地图」小节
  那么 20 个模块每个有一句话职责且与其首行文档注释一致
  并且 主线 9 个模块与支线模块的划分与 spec 决策段一致

场景: 一次 turn 的生命周期讲清
  测试: review_ch05_turn_lifecycle
  假设 读者是 AI 应用开发者
  当 阅读主循环小节与时序图
  那么 能按顺序说出消息准备、LLM 调用、流消费、工具派发、状态更新、stop 判定六个阶段各在哪个文件
  并且 每个阶段至少一处 `crates/octos-agent/src/agent/<file>.rs:行号` 引用

场景: 预算检查点行为准确
  测试: review_ch05_budget_checkpoint
  当 阅读预算小节
  那么 写明 #27e 的触发条件(预算耗尽 且 工作树 dirty)、产物(WIP commit 与 result.checkpoint.md)、永不 push
  并且 写明 fail-open 语义
  并且 引用 `budget.rs` 的实际行号

场景: typed 重试状态机准确
  测试: review_ch05_loop_state
  当 阅读 `loop_state.rs` 小节与状态图
  那么 状态图的每个状态与转移能在 `loop_state.rs` 的枚举与方法中找到
  并且 `HarnessError -> RecoveryHint -> LoopDecision` 链路引用 `harness_errors.rs` 实际行号

场景: 循环自愈实例有源码依据
  测试: review_ch05_self_heal
  当 阅读「循环自愈」小节
  那么 空 MaxTokens nudge 与 temperature override 两个实例各引用对应文件行号
  并且 注明引入它们的提交哈希

场景: 旧叙事零残留
  测试: review_ch05_no_stale_walkthrough
  当 在正文检索「核心 200 行」「agent.rs」
  那么 一处都不出现

场景: 引用零失效
  测试: review_ch05_refs_valid
  当 提取正文全部 `crates/...rs:行号` 引用并对照当前源码
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号

场景: 跨章引用不重复
  测试: review_ch05_cross_ref
  当 检查压缩、工具、沙箱、goal 相关段落
  那么 均以「详见第 N 章」引出而非展开
  并且 与第 6/7/8/18 章不重复引用超过 3 行的同一源码片段
