# ch04-en-check(C1 机械校验报告)

- 校验对象:`chapters/ch04-memory-search.md` ↔ `book-en/src/part1/ch04.md`(commit bf64490,且经 `git log bf64490..HEAD -- <两文件>` 核实此后无改动)
- 校验人:ch04-en-check peer(lane cheap),2026-09-03
- 范围:仅机械校验,不做语言读校;repo 未 commit,唯一产出为本文件
- **总判定:PASS(可进 C2)** — 六项全 PASS,附 1 条备注(数字多 1,系中文「10 万」→英文 `100,000` 的单位制等值改写)

| # | 校验项 | 结果 | 摘要 |
|---|--------|------|------|
| 1 | verify-en.sh | **PASS** | `RESULT: 0 FAIL(s), 0 WARN(s)`;refs 53 equal sets;en words 4243, bold 4, em dash 0 |
| 2 | 数字集合双向 diff | **PASS**(附备注 A) | 缺失 0 / 多余 1(`100,000`),为中文「10 万」同一数字的单位制表述,语义等价 |
| 3 | 源码引用集合 | **PASS** | 两侧各 52 条,`sort -u` 后 diff 为空 |
| 4 | 固定标签 + 章引用 | **PASS** | 五标签 1↔1 且行号完全对应(3/340/405/413/425);章引用集合两侧均 {2, 4};`see Chapter N`↔「详见第 N 章」两侧均 0 处,计数相等;节引用 4.3.4 1↔1(同在行 119) |
| 5 | mermaid | **PASS** | 1 块 ↔ 1 块;各 6 行、5 节点、5 `-->` 边,结构逐行同位,差异仅为节点/边标签中→英 |
| 6 | mdbook build | **PASS** | `grep -cE 'WARN\|ERROR'` = 0,build 成功输出至 `book-en/book` |

## 各项证据(命令与输出)

### 项 1 — verify-en.sh

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch04-memory-search.md book-en/src/part1/ch04.md
refs: 53 (equal sets: yes)
en words: 4243, bold 4, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
```

脚本已含代码块内容比对(mermaid 与注释剥离后 md5),本轮未触发 WARN。

### 项 2 — 数字集合双向 diff

```
$ grep -o -E '[0-9][0-9,._]*[0-9]|[0-9]' <两侧> | sort -u && diff
zh 176 个唯一数字,en 177 个;missing in EN: 0;extra in EN: 100,000
```

`U\+[0-9A-F]{4,6}` 码点模式两侧均为 0 处(本项无需豁免)。

**备注 A(多余 1 个的定性)**:唯一多余数字 `100,000` 在 EN 行 421(思考题第 4 题),对应 ZH 行 421 同一句的「10 万个 episode」——同一数字的中文单位制写法(`100,000 = 10 × 10^4`),语义完全等价,非新增数字事实。按 ch01/ch03-en-check 先例(表述形态不同、语义等价判 PASS)判 PASS。

### 项 3 — 源码引用集合

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <两侧> | sort -u
zh 52 条,en 52 条,diff 为空(REF-DIFF EMPTY)
```

(verify-en.sh 内置的 `crates|octoscode|herdr/` 前缀检查为 53 条 equal sets;本项按 brief 正则为 52 条,结论一致。)

### 项 4 — 固定标签与章/节引用

五种固定标签,行号逐一同位:

| 中文标签 | ZH 行 | EN 标签 | EN 行 |
|---|---|---|---|
| `> **定位**:` | 3 | `> **Positioning**:` | 3 |
| `> ### 工程决策侧栏:…` | 340 | `> ### Engineering decision: …` | 340 |
| `## 延伸阅读` | 405 | `## Further reading` | 405 |
| `## 思考题` | 413 | `## Exercises` | 413 |
| `> **版本演化说明**` | 425(426 为内容行) | `> **Version note**: …`(标签与内容同行) | 425 |

(注:ZH 行 161/185/324 的「定位」为正文动词用法("极难定位"/"快速定位"/"目录定位"),非标签,不计。)

章引用集合:ZH `{第 2 章(L3 前置), 第 4 章(L1 标题自指)}` ↔ EN `{Chapter 2 (L3), Chapter 4 (L1)}`。
节引用:ZH 行 119「这一点会在 4.3.4 节的热路径优化里再出现」↔ EN 行 119 "that fact returns in the hot-path discussion of 4.3.4",1↔1 同位。
`see Chapter N` ↔「详见第 N 章」:两侧均 0 处,计数相等。

### 项 5 — mermaid

```
ZH 1 块 ↔ EN 1 块;各 6 行,5 --> 边,5 节点 ID(Query/BM25/HNSW/Fusion/TopK)
```

两块结构逐行同位(`flowchart LR` + 5 条边),剥离标签后 diff 仅剩节点/边标签的中→英(如「加权融合」→"Weighted fusion"、`0.3 × BM25 + 0.7 × 向量` → `0.3 × BM25 + 0.7 × vector`,系数两侧一致)。

### 项 6 — mdbook build

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

build 成功输出:`HTML book written to …/book-en/book`,零 WARN/ERROR。
