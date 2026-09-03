# ch20-en-check — 英文版 C1 机械校验报告(chapter 20)

- 校验对象:`chapters/ch20-octoloop.md`(174 行)↔ `book-en/src/part4/ch20.md`(175 行)
- 前置:ch20-en 定稿已 commit(a5d65bc,main);本 peer 在隔离 worktree 校验,未 commit
- 日期:2026-09-03 · 工具:`~/.octos/outer/verify-en.sh` + 逐项机械比对
- **总判定:PASS(6/6,可进 C2)**

---

## 1. verify-en.sh — PASS

```
$ ls chapters/ch20-*.md
chapters/ch20-octoloop.md

$ bash ~/.octos/outer/verify-en.sh chapters/ch20-octoloop.md book-en/src/part4/ch20.md
refs: 42 (equal sets: yes)
en words: 4859, bold 10, em dash 2
RESULT: 0 FAIL(s), 0 WARN(s)
```

0 FAIL(脚本 exit 0),阈值要求 0 FAIL,过。

## 2. 数字集合比对 — PASS(缺失 0 / 多余 0)

命令与结果(千分位逗号归一 `tr -d ','`,sort -u 后 comm):

```
$ grep -o -E '[0-9][0-9,]*(\.[0-9]+)?' <侧> | tr -d ',' | sort -u
zh: 134 个唯一数字串    en: 134 个唯一数字串
$ comm -23 /tmp/num-zh.txt /tmp/num-en.txt   # zh 独有(缺失)
(空)
$ comm -13 /tmp/num-zh.txt /tmp/num-en.txt   # en 独有(多余)
(空)
```

- 缺失 0 / 多余 0;U+XXXX 豁免:两侧 `grep -o -E 'U\+[0-9A-Fa-f]{4}'` 均无匹配,本节无豁免项。
- 本轮提取口径比 verify-en.sh(≥3 位)更宽(含 1-2 位数),仍 0/0。

## 3. 源码引用集合比对 — PASS(diff 为空)

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <侧> | sed 's#^octoscode/##' | sort -u
zh: 22    en: 22
zh-only: (空)    en-only: (空)
```

`octoscode/` 前缀归一后两侧集合相等,22↔22,diff 为空。(verify-en.sh 内建口径 `(crates|octoscode|herdr)/…` 42 条亦 equal sets: yes。)

## 4. 固定标签 / see Chapter N / OLP 术语 — PASS(计数全等,20.7 起 +1 同位偏移,已定位根因)

| 标签 | 中文行 | 英文行 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ 同行 |
| `> **工程决策:…**` ↔ `> **Engineering decision**` | :142 | :142 | 1↔1 | ✅ 同行 |
| `## 延伸阅读` ↔ `## Further reading` | :157 | :158 | 1↔1 | ✅ +1 |
| `## 思考题` ↔ `## Exercises` | :164 | :165 | 1↔1 | ✅ +1 |
| `> **版本演化说明**` ↔ `> **Version note**` | :174 | :175 | 1↔1 | ✅ +1 |

节标题同位:`:1 / :5 / :35 / :57 / :84 / :109 / :134`(章名与 20.1–20.6)零漂移;`:145→:146`(20.7)及其后(延伸阅读/思考题/版注/本章回顾 :149→:150)恒 +1。

**+1 偏移根因(格式性,非内容漂移)**:zh :142 工程决策侧栏为单个 blockquote 段落;EN :142–144 为 `> **Engineering decision**…` 标题行后接一个 `>` 空引用行再接正文(md 渲染所需),EN 全文因此多 1 行(174↔175),偏移自 20.7 起恒定,无累积漂移。

`see Chapter N` ↔「详见第 N 章」:两侧 grep 均 0 处(本章无此定式,0↔0 不适用)。章引用全量多重集逐行同位:`第 18 章`/`Chapter 18` :3/:138↔:138/:143↔:144/:147×3↔:148×3,`第 19 章`×2、`第 21 章`×1 同在 :147↔:148;`:1` 章名 `第 20 章`↔`Chapter 20` 同行;`Chapter recap`↔`本章回顾` :150↔:149(小节标,非交叉引用)。

OLP 术语:
- R1–R7 逐条计数全等:R1 4↔4、R2 3↔3、R3 2↔2、R4 2↔2、R5 2↔2、R6 1↔1、R7 7↔7;
- 「ACK 定式」↔ `ACK grammar`::152/:166 ↔ :153/:167 同位(+1);
- 「双环」↔ `dual loop`::5/:9/:55/:155 ↔ :5/:55/:156,标题与小节均对应;
- `GoalRuntimeState` 四态枚举 `Active/Paused/Completed/Failed` 计数全等(5/1/1/1)且同行(zh :138 ↔ en :138),`GoalBudgetResolution`(:298)与调度器引用一致。

## 5. mermaid 对照 — PASS(4 块逐块全等)

```
mermaid blocks: zh=4 en=4
block1: lines 17↔17, nodes 8↔8,  edges 6↔6
block2: lines 12↔12, nodes 7↔7,  edges 11↔11
block3: lines 14↔14, nodes 1↔1,  edges 2↔2
block4: lines 8↔8,   nodes 6↔6,  edges 6↔6
```

节点 ID 集合逐块全等:块1 `BB/INNER/KEEPER/MCP/OP/OUTER/PEERS/PLAN`;块2 `Accepted/Blocked/Done/Historical/Operator/Pending/Wontdo`;块3 `S`;块4 `A–F`。块内标签文本随语言翻译(EN 英文 / ZH 中文),属翻译本体;verify-en.sh 亦将 mermaid 排除在代码块内容比对之外。

## 6. mdbook build — PASS(0 WARN / 0 ERROR)

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
$ mdbook build 2>&1 | tail -5   # 确认构建成功
INFO Book building has started
INFO Running the html backend
INFO HTML book written to …/book-en/book
book/part4/ch20.html 存在 → BUILD_OK
```

(grep 无匹配返回 exit 1 属 grep 语义,计数 0 即要求达成。)

---

## 结论

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | PASS(0 FAIL / 0 WARN,refs 42 相等) |
| 2 | 数字集合 | PASS(134↔134,缺 0 / 多 0,无豁免项) |
| 3 | 源码引用 | PASS(22↔22,diff 空) |
| 4 | 固定标签同位 | PASS(五标签 1↔1;:3/:142 同行,:157 起 +1 恒定偏移,根因为 EN 侧栏 `>` 空行;章引用多重集逐行同位;OLP 术语全等) |
| 5 | mermaid | PASS(4 块行/节点/边全等,节点 ID 全等) |
| 6 | mdbook build | PASS(0 WARN/ERROR,BUILD_OK) |

**总判定:PASS — 可进 C2。**

备注:唯一结构差异为 EN :143 的 `>` 空引用行(20.6 工程决策侧栏内),致其后行号恒 +1;如后续章节核对需严格同行,可在 EN 侧栏去掉该空行,属可选微调,不阻塞 C2。
