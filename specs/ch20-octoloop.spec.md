spec: task
name: "Ch20. OctoLoop：外环协议 OLP v2(v2 新增,第四部分)"
inherits: project
tags: [part4, olp, outer-loop, protocol, rewrite-v2, new-chapter]
depends: [ch19-octoscode]
estimate: 2d
---

## 意图

新增第 20 章。OLP v2 是让外部强模型以标准方式计划、监控、审查、指导 octos 长程执行的协议:
R1–R7 纪律、Markdown 黑板与 `ACK(done|wontdo|blocked)` 语法、result.md frontmatter v1 六字段、
外环主审 OS 独占锁(`octoscode/src/outer_duty.rs`,`DutyState` / `lock_digest`)、olp-mcp 第五信道
(`octoscode/src/olp_mcp.rs`,`ASK_TIMEOUT_SECS = 90.0` :25、`ASK_QUOTA_PER_SLICE = 3` :27)。
必须按「协议 + 约定 + 契约测试」三层写,不得写成系统组件:黑板没有 Rust 实现,追加靠
`scripts/olp-board-append.sh`(flock),唯一强制是契约测试 grep 签入快照;`outer_duty.rs` 整个模块
`#![cfg(target_os = "linux")]`,macOS 上不编译,多外环退回值班簿纪律层。

## 决策

- 事实表先行: `assets/ch20-facts.md` 列 `docs/OUTER_LOOP_PROTOCOL.md` 的 R1–R7 条款行号、`docs/OLP_OUTER_BOOT.md` 章节、`src/olp_mcp.rs` 与 `src/outer_duty.rs` 关键常量/类型行号、三个契约测试文件(`tests/{olp_contract,olp_mcp_contract,outer_duty_contract}.rs`)的用例名、`scripts/olp-board-append.sh` 与 `scripts/olp-init.sh` 行数;每项附命令
- 文档依据: `docs/OUTER_LOOP_PROTOCOL.md`(v2 头部与 R7)、`docs/OLP_OUTER_BOOT.md`、`docs/OCTOLOOP_GUIDE.md`、`docs/OCTOLOOP_FEATURES.md`、`docs/PEER_GOAL_ARCHITECTURE.md`;引用标路径
- 叙事: 角色与信道矩阵 → R1–R7 逐条(每条一个「为什么需要它」的实战案例,取自协议文档的实战沉淀)→ 黑板与 ACK 语法 → 第五信道 → 主审锁(Linux-only 与 macOS 限制、reaper 方案已立项 `knowledge/requirements/req-olp-duty-macos.md`)→ 与本书写作本身的关系(本书 v2 即由此协议驱动,黑板在 `.octos/OUTER_LOOP_REVIEW.md`,可作案例但不引用具体内容)
- 三层标注: 每个机制标注属于「协议条款 / Markdown 约定 / 契约测试强制」哪一层
- 图表: 双环角色与信道矩阵图、ACK 状态机、ask_outer 时序图、duty 锁生命周期
- 工程决策侧栏: 为什么黑板是 Markdown 而不是数据库
- SUMMARY.md 追加本章;分析基线 octoscode main @ 1129fa33

## 边界

### 允许修改
- octos-book/chapters/ch20-octoloop.md
- octos-book/book/src/part4/ch20.md
- octos-book/book/src/SUMMARY.md
- octos-book/assets/ch20-*

### 禁止做
- 不修改 octos / octoscode / herdr 源码仓库
- 不把黑板/ACK 描述为运行时组件
- 不复述 Ch18 的 goal/peer 服务端机制

## 排除范围

- herdr 的安装与驱动细节(Ch21)
- 具体某次战役的黑板内容

## 完成条件

场景: 事实表可复现
  测试: review_ch20_facts_sheet
  假设 `assets/ch20-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 条款行号、常量值、测试用例名与命令输出一致

场景: R1–R7 逐条有案例
  测试: review_ch20_rules
  当 阅读纪律小节
  那么 七条规则各有一个来自协议文档实战沉淀的案例并标注文档路径

场景: 三层标注齐全
  测试: review_ch20_three_layers
  当 检查每个机制的描述
  那么 黑板、ACK、第五信道、主审锁各标注了「协议条款 / 约定 / 契约测试」归属
  并且 黑板明确写为无 Rust 实现

场景: 平台限制写明
  测试: review_ch20_platform_limits
  当 阅读主审锁小节
  那么 写明 `outer_duty.rs` Linux-only 与 macOS 退回值班簿
  并且 引用 `src/outer_duty.rs` 顶部 cfg 行与 macOS reaper 需求文件路径

场景: 第五信道参数准确
  测试: review_ch20_ask_outer
  当 阅读第五信道小节
  那么 90s 超时与每片 3 次限额引用 `src/olp_mcp.rs` 实际行号

场景: SUMMARY 已追加
  测试: review_ch20_summary_entry
  当 检查 `book/src/SUMMARY.md`
  那么 含第 20 章条目指向 `./part4/ch20.md`

场景: 引用零失效
  测试: review_ch20_refs_valid
  当 提取正文全部源码路径与行号引用并对照当前仓库
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
