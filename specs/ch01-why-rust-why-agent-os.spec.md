spec: task
name: "Ch1. 为什么是 Rust？为什么是 Agent OS？(v2 重写)"
inherits: project
tags: [part1, introduction, architecture, rewrite-v2]
depends: []
estimate: 1d
---

## 意图

作为全书开篇,阐明 octos 项目存在的理由:多租户 AI Agent 平台面临安全隔离、
并发、性能三大挑战,以及为什么 Rust 是解决这些挑战的最佳选择。引导读者理解
当前 workspace(26 个 crate,2026-09-02 main @ 9c157101)的分层拓扑,为后续
21 章建立全局地图。本章是全书唯一的架构总图与规模基准,所有数字必须由源码
命令现算,不得沿用旧稿的「10 crate / 13 万行 / 14 工具 / 14 频道」。

## 决策

- 源码入口: `Cargo.toml`(workspace members)、`crates/*/Cargo.toml`(description 与 [dependencies] 中的 octos-* 边)、`crates/*/src/lib.rs` 或 `main.rs` 顶部文档注释
- 事实表先行: 写作前先产出 `assets/ch01-facts.md`,内容为 26 个 crate 的名称 / 一句话职责 / Rust 行数 / 依赖的 octos-* crate,每项附生成命令;正文中一切数字与拓扑只准取自事实表
- 分层: 层数与归属由 Cargo 依赖方向推导(零内部依赖为最底层),不预设层数;`app-skills` / `platform-skills` 是能力二进制而非核心库分层
- 三处事实纠正必须写入: `crates/octos-sandbox` 是平台助手二进制而非沙箱子系统(真沙箱在 `crates/octos-agent/src/sandbox/`);`crates/octos-web` 不含 Rust、不是 workspace 成员;不存在 harness crate(harness 是 octos-agent 内的模块)
- 规模数字: crate 数 `ls crates | wc -l`;行数 `find crates -name '*.rs' | xargs wc -l | tail -1`;频道数 `ls crates/octos-bus/src/*_channel.rs | wc -l`;工具源文件数 `ls crates/octos-agent/src/tools/*.rs | wc -l`,正文引用时注明统计口径
- 对比维度: Python(langchain/autogen) vs Go vs Rust —— 安全、并发、性能、生态
- 架构图: 26 crate 依赖拓扑 Mermaid 图,边只来自 Cargo.toml [dependencies]
- 工程决策侧栏: mono-repo vs multi-repo
- 全书地图: 章末给出 21 章 + 6 附录的导览表(以 OUTLINE.md v2 为准)
- 镜像同步: `book/src/part1/ch01.md` 与 `chapters/ch01-*.md` 内容一致

## 边界

### 允许修改
- octos-book/chapters/ch01-*.md
- octos-book/book/src/part1/ch01.md
- octos-book/assets/ch01-*
- octos-book/assets/ch01-facts.md

### 禁止做
- 不深入任何单个 crate 的实现细节(后续章节覆盖)
- 不做 Rust 语言教程(假设读者有基础或会查阅)
- 不修改 octos 源码仓库
- 不保留旧稿中任何未经事实表核实的数字

## 排除范围

- Rust 语法教学
- 具体 LLM API 调用细节

## 完成条件

场景: 事实表可复现
  测试: review_ch01_facts_sheet
  假设 `assets/ch01-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 26 个 crate 的名称、行数、依赖边与命令输出一致
  并且 每个 crate 的一句话职责能在其 Cargo.toml description 或 lib.rs 文档注释中找到依据

场景: 问题空间完整阐述
  测试: review_ch01_problem_space
  假设 读者是不了解 Agent OS 的开发者
  当 阅读本章「问题空间」小节
  那么 能理解多租户 AI Agent 平台的三大核心挑战(安全隔离、并发、性能)
  并且 每个挑战有具体的真实场景举例

场景: 语言选型论证有说服力
  测试: review_ch01_language_choice
  假设 读者熟悉 Python 或 Go
  当 阅读本章「语言选型」小节
  那么 能理解 Rust 在安全性、并发模型、性能三方面的具体优势
  并且 论证包含具体数据或代码对比而非泛泛而谈

场景: Workspace 拓扑清晰
  测试: review_ch01_workspace_topology
  假设 读者首次接触 octos 代码库
  当 阅读本章「Workspace 拓扑」小节
  那么 能说出 26 个 crate 的名称和一句话职责描述
  并且 能区分 app-skills / platform-skills 是能力二进制程序而非核心库 crate
  并且 三处事实纠正(octos-sandbox / octos-web / 无 harness crate)均已写明

场景: 架构图准确
  测试: review_ch01_architecture_diagram
  当 检查本章的 Mermaid 依赖拓扑图
  那么 图中每条边都能在对应 crate 的 Cargo.toml [dependencies] 中找到
  并且 无虚假依赖边

场景: 旧数字零残留
  测试: review_ch01_no_stale_numbers
  当 在正文中检索「10 个 crate」「13 万行」「14 个内置工具」「14 个消息频道」「91 个 REST」
  那么 一处都不出现

场景: 工程决策侧栏有深度
  测试: review_ch01_sidebar
  当 阅读「mono-repo vs multi-repo」侧栏
  那么 包含至少两个 alternative 的利弊分析
  并且 解释 octos 选择 workspace 的具体原因
