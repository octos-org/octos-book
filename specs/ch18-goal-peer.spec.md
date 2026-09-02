spec: task
name: "Ch18. Goal 与 Peer：把目标从上下文里搬出来(v2 新增)"
inherits: project
tags: [part3, goal, peer, autonomy, rewrite-v2, new-chapter]
depends: [ch12-concurrency, ch16-fleet]
estimate: 2d
---

## 意图

新增第 18 章。服务端 goal keeper 持有并推进目标,peer≈进程、subagent≈线程的并发隐喻:
`crates/octos-cli/src/goal_tool.rs`(`GoalGetTool` :350、`GoalPlanTool` :561、`GoalDispatchTool` :766 等)、
`commands/{goal,peer,ledger}.rs`、`autonomy/{goal_loop_runtime,supervisor_store,master_continuation_scheduler,
fleet_wake}.rs`、`peers/mod.rs`(约 3000 行:staging、寻址、parked-prompt)、`crates/octos-fleet/src/sqlite_ledger.rs`
的 `GoalLedger`(:13)、`crates/octos-agent/src/tools/peer_handoff.rs`(含 `model` 车道键)。本章也是第四部分
(双环)的前置:外环靠这些原语观测与驱动。

## 决策

- 事实表先行: `assets/ch18-facts.md` 列上述文件的行数、首行文档、goal_* / peer_* 工具的 `fn name()` 与结构体行号、`GoalLedger` 公开方法、`peers/<slug>/` 黑板文件布局(brief.md / name / originator / goal / result.md / wt)、result.md frontmatter 六字段;每项附命令
- 文档依据: `octoscode/docs/PEER_GOAL_ARCHITECTURE.md`(设计渊源、绑定与回流、budget 软限制)引用时标路径;实测陷阱「模型不会自动传 goal_id」写入
- 叙事: 为什么把 goal 放在服务端 → goal 生命周期与账本 → peer 生命周期(stage → staged 通知 → client 打开 → boot 读回 → 运行 → closed → gather)→ goal×peer 绑定与三条回流通道 → budget 与续跑(`master_continuation_scheduler.rs`)→ 治理约束(depth-1、per-turn cap、brief ≤64KB)
- worktree 事实: `--worktree` 实为 `git clone --no-hardlinks`,写明原因
- 车道: `peer_handoff` 的 `model` 参数引用 `sub_providers` 键(与 Ch9 互引)
- 图表: goal/peer 时序图(取自架构文档但按源码校验)、blackboard 文件布局图、回流三通道图
- 工程决策侧栏: peer≈进程 vs subagent≈线程
- SUMMARY.md 第三部分追加本章;分析基线 octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch18-goal-peer.md
- octos-book/book/src/part3/ch18.md
- octos-book/book/src/SUMMARY.md
- octos-book/assets/ch18-*

### 禁止做
- 不修改 octos / octoscode / herdr 源码仓库
- 不讲外环协议本身(Ch20)与 TUI 显示(Ch19)

## 排除范围

- OLP 外环纪律(Ch20)
- octoscode Peer Dock UI 细节(Ch19)

## 完成条件

场景: 事实表可复现
  测试: review_ch18_facts_sheet
  假设 `assets/ch18-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 文件行数、工具名、结构体行号与命令输出一致

场景: peer 生命周期准确
  测试: review_ch18_peer_lifecycle
  当 阅读 peer 生命周期小节与时序图
  那么 六个阶段各引用 `peers/mod.rs` 或 `tools/peer_*.rs` 实际行号
  并且 worktree 实为 clone 的事实写明

场景: 绑定与回流准确
  测试: review_ch18_binding_backflow
  当 阅读绑定与回流小节
  那么 `peers/<slug>/goal` 两行格式、三条回流通道各有源码依据
  并且 「模型不会自动传 goal_id」陷阱写入

场景: 治理约束齐全
  测试: review_ch18_governance
  当 阅读治理小节
  那么 depth-1、per-turn cap、brief 上限三条各引用 serve 接线处行号

场景: SUMMARY 已追加
  测试: review_ch18_summary_entry
  当 检查 `book/src/SUMMARY.md`
  那么 含第 18 章条目指向 `./part3/ch18.md`

场景: 引用零失效
  测试: review_ch18_refs_valid
  当 提取正文全部源码路径与行号引用并对照当前仓库
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
