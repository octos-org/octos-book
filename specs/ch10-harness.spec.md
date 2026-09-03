spec: task
name: "Ch10. Harness:让「模型说做完了」变成可验证契约(v2 新增)"
inherits: project
tags: [part2, harness, validators, abi, rewrite-v2, new-chapter]
depends: [ch05-agent-loop, ch06-tool-system, ch07-security]
estimate: 2d
---

## 意图

新增第 10 章(第二部分末)。octos 在 2026 年 4 月后建成了 harness 体系:声明式校验器
(`validators.rs`,M4.3)、结构化事件 ABI(`harness_events.rs`)、schema 版本化
(`abi_schema.rs`,M4.6)、工作区校验策略(`workspace_policy.rs`)、结构化错误分类
(`harness_errors.rs`,M6.1)与生命周期 hooks(`hooks.rs`)。它把「不可信的长跑」变成可审计、
可门禁的运行。本章是 Ch13 pipeline 进度事件与 Ch17 swarm 门禁的共享词汇,必须先立。
事实纠正:不存在 harness crate,harness 是 `octos-agent` 内的六个模块加
`crates/app-skills/harness-starter-*` 四个 starter。

## 决策

- 事实表先行: `assets/ch10-facts.md` 列出六个模块的行数、首行文档、关键类型行号(`ValidatorRunner` validators.rs:441、`HarnessEventPayload` harness_events.rs:368、`check_supported` abi_schema.rs:159、`ValidationPolicy` workspace_policy.rs:115、`HarnessError`/`RecoveryHint` harness_errors.rs:93/:47)、四个 starter 的目录与 manifest 要点、四个契约测试文件(`crates/octos-agent/tests/{validator_runner,abi_compat,harness_errors,slides_validator_project_scope}.rs`);每项附命令
- 三支柱叙事: 校验器(声明什么算完成)→ 事件 ABI(运行中说了什么)→ schema 版本(不同版本还能互相听懂);`workspace_policy.rs` 讲工作区级策略如何驱动校验;`hooks.rs` 讲生命周期钩子与 `9ebaf468`/`fb0f9eeb` 接通的编码反馈回路
- 安全交叉: `b64bd532` 与 `bf6be8cc` 让 project-root 校验器进沙箱、mcp-serve fail-closed,与 Ch7 呼应一段,不展开
- 文档依据: `docs/OCTOS_HARNESS_DEVELOPER_GUIDE.md`、`docs/OCTOS_HARNESS_ABI_VERSIONING.md`、`docs/OCTOS_HARNESS_MASTER_PLAN.md`(阶段划分)、`docs/OCTOS_HARNESS_DEVELOPER_INTERFACE.md`;引用时标注文档路径
- starter 走读: 以 `crates/app-skills/harness-starter-coding` 为主例,其余三个各一段
- `HarnessError -> RecoveryHint -> LoopDecision` 链路在 Ch5 已讲,本章只讲错误分类与 ABI 的关系,「详见第 5 章」
- 图表: 三支柱关系图、一次校验器运行的时序图(Mermaid sequence)、ABI 版本协商决策流
- 工程决策侧栏: 为什么校验是声明式(数据)而不是代码
- 文件: `chapters/ch10-harness.md` 与 `book/src/part2/ch10.md`;`book/src/SUMMARY.md` 的第二部分末追加本章条目(旧 Ch10-14 条目的重编号在各章自己的条目里处理,本条不动它们)
- 分析基线: octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch10-harness.md
- octos-book/book/src/part2/ch10.md
- octos-book/book/src/SUMMARY.md
- octos-book/assets/ch10-*

### 禁止做
- 不重写 Ch5 的错误恢复链
- 不讲 fleet / swarm 的具体门禁实现(Ch16 / Ch17)
- 不修改 octos 源码仓库
- 不把 harness 描述为独立 crate

## 排除范围

- pipeline 节点进度事件的消费(Ch13)
- swarm 聚合门禁(Ch17)

## 完成条件

场景: 事实表可复现
  测试: review_ch10_facts_sheet
  假设 `assets/ch10-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 六个模块的行数、关键类型行号、四个 starter 目录、四个测试文件与命令输出一致

场景: 三支柱各有源码锚点
  测试: review_ch10_three_pillars
  当 阅读三支柱小节
  那么 校验器、事件 ABI、schema 版本各至少两处 `crates/octos-agent/src/<file>.rs:行号` 引用
  并且 三者关系图与正文一致

场景: 校验器运行时序准确
  测试: review_ch10_validator_sequence
  当 阅读校验器时序图
  那么 图中每一步能在 `validators.rs` 的 `ValidatorRunner` 方法中找到
  并且 与 `tests/validator_runner.rs` 的至少一个用例对应

场景: ABI 版本协商准确
  测试: review_ch10_abi_versioning
  当 阅读 schema 版本小节
  那么 `check_supported` 的输入输出与不支持版本的错误路径写明
  并且 与 `docs/OCTOS_HARNESS_ABI_VERSIONING.md` 表述一致

场景: 事实纠正写明
  测试: review_ch10_no_harness_crate
  当 在正文检索 harness crate
  那么 每处都表述为 octos-agent 内的模块集合
  并且 四个 starter 以 app-skills 目录路径引用

场景: SUMMARY 已追加
  测试: review_ch10_summary_entry
  当 检查 `book/src/SUMMARY.md`
  那么 第二部分末含第 10 章 Harness 条目指向 `./part2/ch10.md`

场景: 引用零失效
  测试: review_ch10_refs_valid
  当 提取正文全部 `crates/...rs:行号` 与 `docs/*.md` 引用并对照当前源码
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号

场景: 跨章不重复
  测试: review_ch10_cross_ref
  当 检查错误恢复链与沙箱相关段落
  那么 均以「详见第 N 章」引出
  并且 不与第 5/7 章重复引用超过 3 行的同一源码片段
