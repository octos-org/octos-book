spec: task
name: "附录 F. OLP v2 协议速查(v2 新增)"
inherits: project
tags: [appendix, olp, cheatsheet, rewrite-v2, new-chapter]
depends: [ch20-octoloop]
estimate: 0.5d
---

## 意图

新增附录 F:一页纸的 OLP v2 速查——R1–R7 条款、ACK 语法、result.md frontmatter v1 六字段、
黑板条目格式、外环上岗四步与重启硬清单、第五信道参数。全部内容从 `octoscode/docs/OUTER_LOOP_PROTOCOL.md`
与 `docs/OLP_OUTER_BOOT.md` 逐条提取,不重复 Ch20 的论证。

## 决策

- 数据源: `octoscode/docs/OUTER_LOOP_PROTOCOL.md`(R1–R7、附录 A 六字段、附录 B 车道模板)、`docs/OLP_OUTER_BOOT.md`(§0 署名、§0b 重启清单、§1 黑板格式、§3.5 主审锁命令)、`src/olp_mcp.rs`(90s / 3 次)
- 形式: 表格为主,每表附来源路径;不含任何具体战役的黑板内容
- 文件: `chapters/appendix-f-olp-cheatsheet.md` 与 `book/src/appendix/f-olp-cheatsheet.md`;SUMMARY.md 附录段追加
- 分析基线: octoscode main @ 1129fa33

## 边界

### 允许修改
- octos-book/chapters/appendix-f-olp-cheatsheet.md
- octos-book/book/src/appendix/f-olp-cheatsheet.md
- octos-book/book/src/SUMMARY.md

### 禁止做
- 不修改 octoscode 仓库
- 不引用本书 `.octos/OUTER_LOOP_REVIEW.md` 的具体条目

## 排除范围

- 协议设计论证(Ch20)

## 完成条件

场景: 条款与来源一致
  测试: review_appf_rules_match
  当 对照 `docs/OUTER_LOOP_PROTOCOL.md`
  那么 R1–R7 每条的关键语义与原文一致并附行号

场景: 六字段与语法准确
  测试: review_appf_schema_ack
  当 检查 frontmatter 表与 ACK 语法
  那么 六字段名称/类型与协议附录 A 一致
  并且 ACK 语法为 `ACK(done|wontdo|blocked): <说明>`

场景: 无战役内容
  测试: review_appf_no_campaign_content
  当 在正文检索本书黑板条目编号或署名
  那么 一处都不出现

场景: SUMMARY 已追加
  测试: review_appf_summary_entry
  当 检查 `book/src/SUMMARY.md`
  那么 附录段含附录 F 条目
