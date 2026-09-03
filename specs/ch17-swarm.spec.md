spec: task
name: "Ch17. Swarm：契约扇出与聚合门禁(v2 新增)"
inherits: project
tags: [part3, swarm, dispatch, rewrite-v2, new-chapter]
depends: [ch10-harness, ch16-fleet]
estimate: 1.5d
---

## 意图

新增第 17 章。`crates/octos-swarm`(7 文件 + 3 个集成测试)实现「一个 supervisor 写 N 份契约,分发给
外部 agent 后端,聚合产物并过校验门」:`dispatcher.rs` 的 `SwarmBudget` / `SwarmContext` / `SwarmEventSink`、
`topology.rs`、`persistence.rs` 的幂等 `DispatchStore`、`gate.rs`、`result.rs`、`ledger.rs` 的 `CostLedger`。
与 Fleet 并列而非上下层:Fleet 管可恢复执行,Swarm 管扇出与聚合。`octos serve --swarm-backend*` 是其接线面。

## 决策

- 事实表先行: `assets/ch17-facts.md` 列 7 个源文件的行数、首行文档、公开类型行号、3 个测试文件的用例名(`tests/swarm_dispatch_policy.rs` 为主);每项附命令
- 叙事: 契约扇出 → 后端分发(`octos serve --swarm-backend`/`--swarm-backend-cmd`/`-url`)→ 幂等持久化 → 聚合与门禁(校验门发 harness 事件,「详见第 10 章」)→ 成本账本
- 图表: 扇出/聚合拓扑图、一次 dispatch 的时序图、门禁决策流
- 工程决策侧栏: 为什么 Swarm 与 Fleet 并列而不是叠在 Fleet 上
- SUMMARY.md 第三部分追加本章;分析基线 octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch17-swarm.md
- octos-book/book/src/part3/ch17.md
- octos-book/book/src/SUMMARY.md
- octos-book/assets/ch17-*

### 禁止做
- 不修改 octos / octoscode / herdr 源码仓库
- 不展开 fleet 状态机(Ch16)与 harness 校验器实现(Ch10)

## 排除范围

- 外部 agent 后端(claude / codex 等)自身的行为

## 完成条件

场景: 事实表可复现
  测试: review_ch17_facts_sheet
  假设 `assets/ch17-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 7 个源文件与 3 个测试文件的信息与命令输出一致

场景: dispatch 时序准确
  测试: review_ch17_dispatch_sequence
  当 阅读时序图
  那么 每一步能在 `dispatcher.rs` / `persistence.rs` 的方法中找到
  并且 与 `tests/swarm_dispatch_policy.rs` 至少一个用例对应

场景: 幂等与门禁写明
  测试: review_ch17_idempotency_gate
  当 阅读持久化与门禁小节
  那么 `DispatchStore` 幂等键与 `gate.rs` 判定各引用实际行号

场景: SUMMARY 已追加
  测试: review_ch17_summary_entry
  当 检查 `book/src/SUMMARY.md`
  那么 含第 17 章条目指向 `./part3/ch17.md`

场景: 引用零失效
  测试: review_ch17_refs_valid
  当 提取正文全部源码路径与行号引用并对照当前仓库
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
