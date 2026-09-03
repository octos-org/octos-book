# octos-book 英文版同步：收官总结（外环 claude，2026-09-03 20:00）

分支 `main`，HEAD `87b2108`（英文战役起点 7cea059 之后 65 个 commit），全部已推送到 `git@github.com:octos-org/octos-book.git`。

## 结果

- `book-en/` 从 v1 旧稿（14 章 + 附录 A–E）整体对齐到 v2：前言、21 章、附录 A–F 全部为对中文 v2 定稿的母语重写；附录 E 的 v1 英文经对照仍与中文版一致，原样保留。
- 每一份交付都经过 `verify-en.sh` 结构镜像门：标题数、代码块数与内容（注释与 mermaid 标签除外）、mermaid 数、表格行数、源码引用集合（`crates/…rs:行号`、`octoscode/…`、`herdr/…`）、中文版全部数字、正文无 CJK、禁用词零命中、章首 Positioning 与章末 Version note 标签。终态 21 章 + 前言 + 6 附录全部 0 FAIL。
- 两语 `mdbook build` 零警告；`book-en/src/SUMMARY.md` 21 章 + 6 附录；无占位页。
- 术语表 `assets/glossary-en.md` 由译者车道累积维护；全书统一 dual loop / outer loop / inner loop / blackboard / lane 等译法。

## 交付物 hash 与英文词数

| 文件 | 终稿 commit | 英文词数 |
|---|---|---|
| preface | 0ba84cd | 1,263 |
| ch01 | 179b1bd | 4,868 |
| ch02 | 659ee40 | 4,901 |
| ch03 | d2879ee | 6,054 |
| ch04 | f9752d3 | 4,245 |
| ch05 | bb900d8 | 5,697 |
| ch06 | 23692b6 | 4,886 |
| ch07 | 5bda2ad | 5,488 |
| ch08 | 60a68cf | 4,223 |
| ch09 | bb900d8 | 4,332 |
| ch10 | fad031c | 4,392 |
| ch11 | d381140 | 4,351 |
| ch12 | 94a257b | 4,332 |
| ch13 | d155bbd | 5,371 |
| ch14 | f9b7a70 | 4,566 |
| ch15 | 816ca5f | 4,521 |
| ch16 | 4c49659 | 4,675 |
| ch17 | 84efcf3 | 4,249 |
| ch18 | 84efcf3 | 5,023 |
| ch19 | 84efcf3 | 4,313 |
| ch20 | 48f708e | 4,863 |
| ch21 | 8eb9bb3 | 4,750 |
| appendix A | c35ffc1 | 3,152（63 边逐条相同） |
| appendix B | c35ffc1 | 3,160（111 表行） |
| appendix C | 94a257b | 5,263（290 表行、302 引用） |
| appendix D | 9296acc | 3,528（97 表行） |
| appendix E | 7b4c51e（v1 保留） | 931 |
| appendix F | 8eb9bb3 | 5,124（65 表行、2 时序图） |

21 章正文合计约 100,100 英文词。

## 流程

- 五个批次 G1（前言 + Ch1–5）→ G2 → G3 → G4（Ch16–21）→ G5（附录），前批过半即开下批，并发 ≤6。
- 每章三道：B 翻译重写（glm-5.3）→ C1 机械核对（glm-5.3-flash，跑 verify-en.sh 并逐项列集合比对）→ C2 英文去味与技术读校（glm-5.3）。数据表附录 A/B/C/D 只做 C1。
- 内环 peer 80 个（含 3 次重派：Ch4 空交付、附录 F 输出退化两次），审链报告 51 份归档在 `assets/*-en-check.md` / `*-en-review.md`；goal 四个（goal_06–09），每个 40M token 预算耗尽即由外环 `/goal clear` 后重建。
- 外环每份交付都在 `git worktree add --detach <hash>` 的隔离树上独立复跑脚本并抽读，采认判词落黑板；黑板全文在 `.octos/OUTER_LOOP_REVIEW.md`（第 29 条起）。

## 翻译过程中反查出的中文版缺陷（已双语同修）

- Ch1 第 19/161 行：glob `*_channel.rs` 被上一轮全路径替换弄成假路径 `*crates/octos-bus/src/cli_channel.rs`（179b1bd）。
- Ch6 章末残留写作过程段「补深度记录」（23692b6）。
- Ch14 第 108 行「见 14.6.4」应为 14.6.3（f9b7a70）。
- 附录 D 第 11 行「交叉点在 D.7 说明」应为 D.6（75fa2c0）。
- Ch5「见 5.6 节」被译者质疑，外环裁定不改（5.6 为恢复链本体）。

## 遗留（不阻塞）

1. 若中文版再修订，英文版需按同一 verify-en 门重跑：`scripts/verify-en.sh <zh> <en>`（已入库，d32c15d）。
2. `book-en/book.toml` 与 `book/book.toml` 的 `language-switcher` 依赖部署路径 `/en/`，本地 serve 用 3000/3001 端口区分。
3. 附录 E 英文沿用 v1，已补 C2 去味（1798981，1 处修改）。
4. 运行时缺陷同中文战役（`assets/reports/runtime-defects.md`，含上游 issue 草稿）：goal 预算耗尽后 CLI 与 TUI 账本不同源，需 TUI `/goal clear`；一次 peer 输出退化为 3 行占位（appendixf-en）需重派；master 在等待单个 peer 时会空转一整轮而不补槽。
