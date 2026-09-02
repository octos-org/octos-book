spec: task
name: "Ch16. Fleet：可恢复的计划执行内核(v2 新增)"
inherits: project
tags: [part3, fleet, kernel, rewrite-v2, new-chapter]
depends: [ch07-security, ch12-concurrency]
estimate: 2d
---

## 意图

新增第 16 章。`crates/octos-fleet`(7 文件)+ `crates/octos-fleet-worker`(6 文件)共约 2.4 万行,是一个
redb 支撑的事务化计划内核:`FleetKernelStore` 持久化 `DurablePlan` / `Attempt` / `Lease` / `OutboxEvent`
(`records.rs` `SCHEMA_VERSION = 3`),`Fleet` 提供计划管理 API;worker 侧从空注册表按 `WorkerGrant`
装配封闭工具集(`closed_registry.rs`),`run_attempt` 执行一次 attempt,`FleetWorkerPool` 有界启动,
`escalate` 是常开安全阀。本章讲清「可恢复」如何由 attempt/lease/generation 状态机与 outbox 保证。

## 决策

- 事实表先行: `assets/ch16-facts.md` 列 13 个源文件的行数与首行文档、`records.rs` 的记录类型行号(`Lease` :250、`Attempt` :256、`DurablePlan` :313、`FleetRecord` :145、`FleetBudget` :119、`SCHEMA_VERSION` :33)、`fleet.rs:190` `Fleet`、`grant.rs` 四类型、worker 四模块的公开函数;每项附命令
- 文档依据: `docs/FLEET-KERNEL-V1-SPEC.md`、`docs/FLEET-KERNEL-FOUNDATION-SPEC.md`、`docs/FLEET-RUNTIME-ADR.md`;引用时标路径
- 叙事: 记录模型 → 事务与 outbox → attempt/lease/generation 状态机 → worker 装配(grant 已在 Ch7 立住,「详见第 7 章」)→ 有界池与 escalate;`sqlite_ledger.rs` 的 `GoalLedger` 只交代与 Ch18 的关系
- 提交锚点: `eadee2ae` / `8fc66202`(WorkerGrant 与 worktree worker)、`fleet_wake.rs` outbox→keeper 唤醒(与 Ch12 互引)
- 图表: 记录模型 ER 图、attempt/lease 状态机、一次 attempt 的时序图(Mermaid sequence)
- 工程决策侧栏: 为什么用 redb 事务而不是内存状态 + 日志
- SUMMARY.md 第三部分追加本章;分析基线 octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch16-fleet.md
- octos-book/book/src/part3/ch16.md
- octos-book/book/src/SUMMARY.md
- octos-book/assets/ch16-*

### 禁止做
- 不修改 octos / octoscode / herdr 源码仓库
- 不展开 WorkerGrant 权限模型(Ch7)与 goal keeper(Ch18)

## 排除范围

- swarm 扇出(Ch17)
- goal/peer 编排(Ch18)

## 完成条件

场景: 事实表可复现
  测试: review_ch16_facts_sheet
  假设 `assets/ch16-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 13 个源文件行数、记录类型行号与命令输出一致

场景: 状态机准确
  测试: review_ch16_state_machine
  当 阅读 attempt/lease 状态机小节与图
  那么 每个状态与转移能在 `records.rs` / `store.rs` 的类型与方法中找到
  并且 `SCHEMA_VERSION` 的值与迁移策略写明

场景: worker 装配讲清
  测试: review_ch16_worker_assembly
  当 阅读 worker 小节
  那么 `closed_registry.rs`、`worker.rs` `run_attempt`、`pool.rs`、`escalate.rs` 各有行号引用
  并且 grant 语义以「详见第 7 章」引出不重复

场景: SUMMARY 已追加
  测试: review_ch16_summary_entry
  当 检查 `book/src/SUMMARY.md`
  那么 含第 16 章条目指向 `./part3/ch16.md`

场景: 引用零失效
  测试: review_ch16_refs_valid
  当 提取正文全部源码路径与行号引用并对照当前仓库
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
