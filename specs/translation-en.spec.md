spec: task
name: "英文版同步:book-en 对齐 v2 中文版(21 章 + 前言 + 附录 A-F)"
inherits: project
tags: [translation, en, book-en, rewrite-v2]
depends: [ch21-herdr, appendix-f-olp-cheatsheet]
estimate: 6d
---

## 意图

`book-en/` 仍是 v1 英文旧稿(14 章 + 附录 A-E),与 v2 中文版(21 章、四部分、附录 A-F)完全脱节。
本任务把英文版整体对齐到 v2:事实、数字、源码引用、代码块、图表与中文版逐一相同;
英文按 `.octos/skills/trilingual-collab-en.md` 用母语重写,不做逐句直译。

## 决策

- 源:`chapters/<file>.md`(v2 定稿,与 `book/src/` 镜像一致)。目标:`book-en/src/<same path>.md`。英文版只维护一份(不设 chapters-en)。
- 结构镜像:标题层级与数量、代码块数量与内容、mermaid 数量、源码引用集合(`crates/…rs:行号`、`octoscode/…`、`herdr/…`)、表格行数必须与中文版相同;mermaid 节点/边标签译成英文,边数不变。
- 事实一致:中文版正文出现的所有数字(行数、计数、版本、hash、日期)必须原样出现在英文版;一处不一致按一级事实错误处理(trilingual-collab 第五节)。
- 章首锚点译为 `> **Positioning**:`,章末版本演化说明译为 `> **Version note**:`;「工程决策侧栏」译为 `> **Engineering decision**:`;「延伸阅读」`## Further reading`,「思考题」`## Exercises`;跨章引用 `详见第 N 章` → `see Chapter N`。
- 术语保留英文原文:Rust、crate、trait、agent、harness、spec、goal、peer、lane、OLP、blackboard(黑板)、outer loop / inner loop(外环/内环)、master、operator、Fleet、Swarm、Goal、Peer、Provider、Channel、Session。术语表见 `assets/glossary-en.md`(译者维护,首章起建)。
- 英文规范:`.octos/skills/trilingual-collab-en.md` 全部条款(禁用词零命中、em dash ≤2、无 colon reveal、无 recap ending、无 bold 撒粉);主动语态、结论前置。
- 车道:B `chNN-en`(strong,glm-5.3)翻译重写 → C1 `chNN-en-check`(cheap,glm-5.3-flash)跑 `scripts/verify-en.sh` 与数字/引用集合比对,计数附命令输出 → C2 `chNN-en-review`(strong)英文去味与技术读校(不改事实)。不设 A 车道(事实来自中文定稿)。
- 批次:G1 前言 + Ch1-5;G2 Ch6-10;G3 Ch11-15;G4 Ch16-21;G5 附录 A/B/C/D/F(附录 E 的 v1 英文保留,只核对与中文版一致)。并发 ≤6。
- 提交:每章一个原子 commit,只含 `book-en/src/<path>.md`(及首章的 glossary);ACK 定式 `ACK(done): <hash>;字数(英文词数)/引用集合相等/数字集合相等/禁用词 0/em dash/C1(+C2)问题计数/验证级别`。
- 站点:`book-en/src/SUMMARY.md` 已按 v2 结构重写,未译章节为占位页;`cd book-en && mdbook build` 零警告是每次 commit 的硬门。

## 边界

### 允许修改
- octos-book/book-en/src/**
- octos-book/assets/glossary-en.md
- octos-book/assets/chNN-en-*.md(审查报告)

### 禁止做
- 不修改 chapters/ 与 book/src/(发现中文版错误→写入 assets/final-pass.md,由外环裁定)
- 不改代码块内容、不改源码路径与行号、不改数字
- 不新增中文版没有的论断;不删中文版有的小节
- 不修改 octos / octoscode / herdr 仓库

## 排除范围
- 不做日文版;不改 language-switcher 与部署脚本(除非 build 失败)

## 验收场景

场景: 结构镜像
  假设 中文版 chapters/chNN-*.md 与英文版 book-en/src/partX/chNN.md
  当 运行 scripts/verify-en.sh <zh> <en>
  那么 标题数、代码块数、mermaid 数、表格行数相等
  并且 源码引用集合(路径:行号)完全相等
  并且 中文版正文出现的每个 ≥3 位数字都出现在英文版

场景: 英文质量
  假设 英文章节定稿
  当 按 .octos/skills/trilingual-collab-en.md 逐项检查
  那么 禁用词与填充短语零命中,em dash ≤2,加粗 ≤15,正文无 CJK 字符
  并且 章首有 Positioning 引用块,章末有 Version note 引用块

场景: 站点可构建
  假设 任一章 commit 后
  当 cd book-en && mdbook build
  那么 零 WARN 零 ERROR
  并且 SUMMARY 21 章 + 前言 + 附录 A-F 条目齐全

场景: 术语一致
  假设 全部章节完成
  当 grep 术语表中每个术语的备选译法
  那么 全书同一概念只用一种英文写法
