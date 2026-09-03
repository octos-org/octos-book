# ch03-en-check(C1 机械校验报告)

- 校验对象:`chapters/ch03-llm-providers.md` ↔ `book-en/src/part1/ch03.md`(commit 8d92a22)
- 校验人:ch03-en-check peer(lane cheap),2026-09-03
- 范围:仅机械校验,不做语言读校;repo 未 commit,唯一产出为本文件
- **总判定:PASS(可进 C2)** — 六项全 PASS,附 2 条备注(数字多 2、see Chapter 4 显式化),均有语义等价依据

| # | 校验项 | 结果 | 摘要 |
|---|--------|------|------|
| 1 | verify-en.sh | **PASS** | `RESULT: 0 FAIL(s), 0 WARN(s)`;refs 72 equal sets;en words 6058, bold 2, em dash 1 |
| 2 | 数字集合双向 diff | **PASS**(附备注 A) | 缺失 0 / 多余 2(`540`、`6210`),均为 EN 侧 `U+XXXX` 码点标注,语义等价,非新增数字事实 |
| 3 | 源码引用集合 | **PASS** | 两侧各 73 条,`sort -u` 后 diff 为空 |
| 4 | 固定标签 + 章引用 | **PASS**(附备注 B) | 五标签 1↔1 且行号完全对应(3/464/525/533/545);章引用集合两侧均 {2, 3, 17} |
| 5 | mermaid | **PASS** | 2 块 ↔ 2 块;各 27 行、16 `-->` 边、16 个节点 ID 完全一致;剥离标签后 diff 为空,差异仅为节点/边标签中→英 |
| 6 | mdbook build | **PASS** | `grep -cE 'WARN\|ERROR'` = 0,build 成功输出至 `book-en/book` |

## 各项证据(命令与输出)

### 项 1 — verify-en.sh

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch03-llm-providers.md book-en/src/part1/ch03.md
refs: 72 (equal sets: yes)
en words: 6058, bold 2, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)
```

脚本已含代码块内容比对(mermaid 与注释剥离后 md5),本轮未触发 WARN。

### 项 2 — 数字集合双向 diff(brief 要求双向;verify-en.sh 内置检查为单向"zh 缺于 en")

```
$ grep -o -E '[0-9]+(\.[0-9]+)?' <两侧> | sort -u > … && diff
zh 194 个唯一数字,en 196 个;missing in EN: 0;extra in EN: 540, 6210
```

**备注 A(多余 2 个的定性)**:两个多余数字全部来自 EN 侧 UTF-8 分块小节的 `U+XXXX` 码点标注:

- EN 行 392/394:`U+6210`、`U+540E` —— 中文原文以实际汉字「成」「后」与字节序列 `[E6 88 90]` 表示(行 384/388/392)。`U+6210` 即 0xE68890 的码点,同一事实的两种编码记法;
- `540` 仅出现在 `U+540E`(行 394)内,同理。

EN 为英文读者补码点标注属合理母语化改写(汉字在英文语境不可读),非新增数字事实。按 ch01-en-check 先例(表述形态不同、语义等价判 PASS)判 PASS;如外环要求严格 0/0,可改为在数字抽取中豁免 `U\+[0-9A-F]{4}` 模式。

### 项 3 — 源码引用集合

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <两侧> | sort -u
zh 73 条,en 73 条,diff 为空(OK-EMPTY-DIFF)
```

(verify-en.sh 内置的 `crates|octoscode|herdr/` 前缀检查为 72 条 equal sets;本项按 brief 正则含更多形态,73 条,结论一致。)

### 项 4 — 固定标签与章引用

五种固定标签,行号逐一同位:

| 中文标签 | ZH 行 | EN 标签 | EN 行 |
|---|---|---|---|
| `> **定位**:` | 3 | `> **Positioning**:` | 3 |
| `### 工程决策侧栏:…` | 464 | `### Engineering decision: …` | 464 |
| `## 延伸阅读` | 525 | `## Further reading` | 525 |
| `## 思考题` | 533 | `## Exercises` | 533 |
| `> 版本演化说明` | 545 | `> **Version note**:` | 545 |

章引用集合(排除标题自指后两侧同构):ZH `{第 2 章(L3 前置), 第 3 章(L1 标题), 第 17 章(L531 TRPL 外部书)}` ↔ EN `{Chapter 2 (L3), Chapter 3 (L1), Chapter 17 (L531)}`。

**备注 B**:EN 行 521 `…(see Chapter 4).` 对应 ZH 行 521「下一章将进入 octos-memory…」—— 中文用"下一章"相对指称,EN 显式化为 `see Chapter N` 形态,目标一致(octos-memory = 第 4 章),语义等价,判 PASS。

### 项 5 — mermaid 对照

```
$ awk '/^```mermaid/{m=1;next} /^```/{m=0;next} m' <两侧>
ZH: 2 块,27 行,16 条 `-->`,16 个节点 ID
EN: 2 块,27 行,16 条 `-->`,16 个节点 ID
节点 ID 集合两侧完全一致:{AP AR CC CR F LLM_A LLM_B NC P PC Req Request RP1 RP2 Sel W}
剥离标签("…"/[…]/{…}/|…|)后 diff 为空 → 拓扑零差异;原始 diff 全部为节点/边标签中→英翻译
```

两块图:① 请求分发二选一分支(ProviderChain / AdaptiveRouter);② 3.6 成本层 cache_control 断点决策树。

### 项 6 — mdbook build

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
INFO Book building has started / INFO Running the html backend / INFO HTML book written to …/book-en/book
```

## 结论

六项 6/6 PASS,**总判定 PASS,ch03-en 可进 C2**。两条备注(A:码点标注致数字 +2;B:"下一章"→"see Chapter 4" 显式化)均为母语化改写的语义等价形态,不构成事实偏差;如需严格 0/0 口径,建议后续在数字抽取规则中统一豁免 `U\+[0-9A-Fa-f]{4}`。
