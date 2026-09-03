spec: task
name: "Ch2. octos-core：用类型系统定义领域语言(v2 勘误)"
inherits: project
tags: [part1, core, types, domain-modeling, rewrite-v2]
depends: [ch01-why-rust-why-agent-os]
estimate: 1d
---

## 意图

深入 octos-core crate，展示如何用 Rust 类型系统构建系统级领域语言。
Task 状态机、Message 抽象、Error 设计是整个 octos 的基石，所有上层 crate
都依赖这些类型。当前主分支还把 AppUI / Gateway 所需的
`ClientMessageId`、`ThreadId`、`TurnId`、`SessionSummary` schema version
和 UI Protocol capabilities 放进 core，本章需要解释这些“跨 crate wire identity”
为什么属于 core，而不只是讲基础 enum/struct。

## 决策

- 源码目录: `crates/octos-core/src/`
- 重点文件: `task.rs`, `message.rs`, `error.rs`, `types.rs`, `utils.rs`, `ui_protocol.rs`
- 新增文件归类(2026-09-02 main 共 15 个源文件): `abort.rs`, `app_ui.rs`, `app_ui_codec.rs`, `env_hygiene.rs`, `gateway.rs`, `git_worktree.rs`, `session_scope.rs` 需在「core 的边界」小节各用 1-3 句说明它们为何进 core,不展开实现
- 结构化截断: `d8125d18`(2026-08-31)后 `truncate_head_tail` 是 `truncate_head_tail_report` 的薄包装,返回 `TruncationReport { content, truncated, truncated_by, total_bytes, output_bytes, omitted_bytes, ... }`,2.5.3 小节按此改写
- 勘误方式: 保留章节结构与叙事,只改失实处与补新面;所有 `crates/octos-core/src/*.rs:行号` 引用逐条对照当前源码重标行号
- 零内部依赖事实: `crates/octos-core/Cargo.toml` [dependencies] 当前只有 serde/serde_json/chrono/uuid/eyre/tracing/sha2,侧栏据此复核
- 图表: Task 状态机 Mermaid 状态图、message identity 三元组图、SessionSummary ABI 图
- 工程决策侧栏: 为什么 core crate 零内部依赖

## 边界

### 允许修改
- octos-book/chapters/ch02-*.md
- octos-book/book/src/part1/ch02.md
- octos-book/book-en/src/part1/ch02.md
- octos-book/assets/ch02-*

### 禁止做
- 不讲 LLM 相关逻辑（Ch3 覆盖）
- 不讲工具系统（Ch6 覆盖）

## 排除范围

- Rust enum/struct 基础语法教学
- serde 序列化框架教学

## 完成条件

场景: Task 状态机完整呈现
  测试: review_ch02_task_state_machine
  当 阅读本章 Task 状态机小节
  那么 包含 Mermaid 状态图展示 Pending→InProgress→Blocked/Completed/Failed
  并且 Task、TaskStatus、TaskKind、TaskResult、TokenUsage 的说明都有对应源码引用（文件路径+行号）

场景: MessageRole 跨 Provider 设计解释清晰
  测试: review_ch02_message_role
  当 阅读本章 Message 小节
  那么 解释了 `as_str()` 和 `Display` impl 如何确保跨 Provider 一致性
  并且 包含实际的 Rust 代码片段（来自源码，非编造）

场景: Message identity 三元组准确
  测试: review_ch02_message_identity
  当 阅读 Message identity 小节
  那么 区分 `ClientMessageId`、`ThreadId`、`TurnId` 的职责
  并且 说明 `ClientMessageId` 是客户端乐观 UI / 幂等相关 token
  并且 说明 `ThreadId` 是渲染分组 key，user thread 通常 root at client_message_id
  并且 说明 `TurnId` 是 UI Protocol 的服务器协议 identity
  并且 包含三者关系 Mermaid 图
  并且 说明 `assistant_with_thread` / `tool_with_thread` 强制显式 thread 绑定，避免“最近 user”推导错误

场景: Durable schema version 解释清晰
  测试: review_ch02_schema_version
  当 阅读 TaskResult / SessionSummary 小节
  那么 说明 `TaskResult.schema_version` 是 durable ABI 字段
  并且 说明 `SessionSummary.schema_version` 缺失时默认到当前版本
  并且 说明未来版本会返回 `UnsupportedSessionSummaryVersion` typed error
  并且 连接到 Ch8 的 typed compaction 与 Ch9 的 Harness ABI

场景: SessionKey 语义不夸大
  测试: review_ch02_session_key
  当 阅读 SessionKey 小节
  那么 说明 `SessionKey` 支持 profile 与 topic 维度
  并且 说明当前 core 构造函数不做 channel 合法性拒绝
  并且 说明 `is_channel_name` 用于三段式 key 的 profile/channel 推断
  并且 不把 SessionKey 描述成“构造期让未知 channel 不可构造”

场景: Error 设计选型有说服力
  测试: review_ch02_error_design
  当 阅读本章 Error 小节
  那么 解释了选择 `eyre`/`color-eyre` 而非 `anyhow` 的具体理由
  并且 展示了 octos 中错误类型的实际定义

场景: truncate_utf8 案例深入浅出
  测试: review_ch02_truncate_utf8
  当 阅读 `truncate_utf8` 小节
  那么 解释了 UTF-8 多字节字符在截断时的陷阱
  并且 展示了 octos 的两个变体（in-place 和 copying）的实现差异

场景: 结构化截断报告已更新
  测试: review_ch02_truncation_report
  当 阅读 truncate_head_tail 小节
  那么 说明 `truncate_head_tail_report` 返回 `TruncationReport` 及其字段含义
  并且 说明 `truncate_head_tail` 是保持字节一致的薄包装
  并且 引用的行号与当前 `crates/octos-core/src/utils.rs` 一致

场景: core 新增文件有归类
  测试: review_ch02_new_files_mapped
  当 阅读「core 的边界」小节
  那么 `abort.rs`、`app_ui.rs`、`app_ui_codec.rs`、`env_hygiene.rs`、`gateway.rs`、`git_worktree.rs`、`session_scope.rs` 各有一句话定位
  并且 每句定位能在该文件顶部文档注释或主要类型名中找到依据

场景: 引用零失效
  测试: review_ch02_refs_valid
  当 提取正文全部 `crates/octos-core/src/*.rs:行号` 引用并对照当前源码
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号

场景: 零依赖设计哲学
  测试: review_ch02_zero_dep_sidebar
  当 阅读工程决策侧栏
  那么 解释了 core crate 不依赖 workspace 内任何其他 crate 的原因
  并且 对比了"胖 core"与"瘦 core"两种策略的利弊
