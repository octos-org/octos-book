# ch13 英文版机械校验报告(ch13-en-check)

- 校验对象:`chapters/ch13-pipeline.md`(440 行)↔ `book-en/src/part3/ch13.md`(439 行)
- 基线:主仓 main @ e30d961,前置 commit `f08282d`(ch13-en 定稿);本 worktree 未 commit
- 日期:2026-09-03;只做机械校验,不做译评

## 1. verify-en.sh — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch13-pipeline.md book-en/src/part3/ch13.md
refs: 95 (equal sets: yes)
en words: 5371, bold 15, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

0 FAIL 为过 → PASS(标题数/围栏数/mermaid 数/代码块 md5/引用集合/数字/CJK 残留/违禁词/Positioning 与 Version note 锚点全过,且 0 WARN:em dash 0、bold 15 未超限)。

## 2. 数字集合比对 — PASS

```
$ grep -oE '[0-9][0-9,._]*[0-9]|[0-9]' <side> | sort -u
zh 212 行 ↔ en 212 行
$ comm -23 zh en → 空;comm -13 zh en → 空(MISSING=0 EXTRA=0)
$ grep -nE '[0-9](万|亿)' chapters/ch13-pipeline.md → 无匹配
$ grep -c 'U+' 两侧 → 0 / 0
```

缺失/多余 = **0/0**。归一口径说明:千分位逗号随 `grep -oE` 模式保留,两侧集合直接相等(如 `5,591`、`25,134`、`3,197`、`2,140`、`1,445` 在两侧形态一致),无需剥逗号归一;本章中文原文无「万/亿」记数(无单位制等值豁免),无 `U+XXXX` 码点引用(豁免 0 处)。逐项一价示例:9c157101、6b0de6ca、92175f53、f26d2291、543010be、23 条验证规则、12 种 IrNodeKind、[60,3600]/1800、tool.rs:534/:1099 等。

## 3. 源码引用集合比对 — PASS

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <side> | sort -u
zh refs: 95, en refs: 95
$ diff zh_refs en_refs → 无输出(REFSETS-EQUAL)
```

95↔95,diff 为空。含 `crates/octos-pipeline/src/executor.rs`、`crates/octos-pipeline/src/parser.rs`、`crates/octos-pipeline/src/handler.rs`、`crates/octos-pipeline/src/events.rs`、`crates/octos-pipeline/src/model_assignment.rs`、`crates/octos-pipeline/src/tool.rs:534`、`:1099`、`crates/octos-agent/src/plugins/tool.rs` 等全路径引用。

## 4. 固定标签 — PASS

五类固定标签数量与行号同位(全章仅章尾 1 行 delta):

| 标签 | 中文行 | 英文行 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ 同行 |
| 工程决策侧栏 ↔ `> **Engineering decision**:` | :377 | :377 | 1↔1 | ✅ 同行 |
| `## 延伸阅读` ↔ `## Further reading` | :426 | :426 | 1↔1 | ✅ 同行 |
| `## 思考题` ↔ `## Exercises` | :431 | :431 | 1↔1 | ✅ 同行 |
| `> 版本演化说明`(:439+内容 :440)↔ `> **Version note**: …`(inline 合并 :439) | :439 | :439 | 1↔1 | ✅ 同行 |

- 全部 42 个标题(#{1,4})两侧行号零位移(:1–:431 逐行相同);章尾 delta −1 行:中文版本说明为两行 blockquote(:439 标题行 + :440 正文行),英文并为一段 inline `> **Version note**`(:439),内容事实(9c157101、2026-09-03、25,134/5,591/3,197/2,140/1,445 行、四个 commit)逐项保留。
- 形态备注(非机械项):中文 :377 为 `> ### 工程决策侧栏:…`(blockquote 内三级标题形),英文 :377 为 `> **Engineering decision**: why DOT instead of YAML/JSON`(加粗行内标签形),与 ch12 报告所记 EN 惯例一致,同位同义。
- `see Chapter N` ↔ 「详见第 N 章」:两侧精确短语计数均为 0(本章章引用均为 "Chapter 5, Chapter 8…" 前置依赖式,无交叉 "see" 句式)→ 无需比对,记 0↔0。
- 章节引用多重集与行位:ZH `第 5 章×1 / 第 8 章×2 / 第 10 章×4 / 第 11 章×2 / 第 13 章×1` ↔ EN `Chapter 5×1 / Chapter 8×2 / Chapter 10×4 / Chapter 11×2 / Chapter 13×1`,计数全等;逐行同位 `5→:3 / 8→:3,:349 / 10→:3,:319,:411 / 11→:3,:349 / 13→:1`,零漂移。

## 5. mermaid 对照 — PASS

```
$ grep -c '^```mermaid' <side>   → 1 ↔ 1(两侧均在 :228)
$ python3 统计(节点=唯一 id 形参定义,边=含 '-->' 行,标签=[..]/{..} 计)
ZH unique_nodes=13 def_lines=1 edge_lines=15 labeled=13
EN unique_nodes=13 def_lines=1 edge_lines=15 labeled=13
```

节点 13↔13、边行 15↔15、带标签节点 13↔13;剥引号标签/圆括号/花括号后对块做 diff 为空(仅图题行「图 13-1:…」→"Figure 13-1: …" 本地化,属块外标题)。分支拓扑一致(Kind 分流 Parallel/DynamicParallel/其他 → Merge/Workers/Select → Loop/Done)。

- 风格备注(非机械项):EN 块内 8 行节点/边标签保留中文(如 `|其他|`、`合并结果并跳到 converge`)。verify-en.sh 法定 CJK 检查剥离 mermaid 块,故 0 FAIL 属其既定口径;且与全书已定稿章 ch06(31 行 CJK)/ch15(26)/ch19(20) 同型,而 ch12 采取块内全译。两种风格在已过检章节中并存,不构成本章 FAIL,是否统一留 master 决断。

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0        (grep EXIT=1,零匹配;日志仅 INFO,HTML 正常写入 book-en/book)
```

WARN/ERROR 计数 0 → PASS。

## 总判定

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | PASS(0 FAIL / 0 WARN,refs 95 相等) |
| 2 | 数字集合 | PASS(212↔212,0/0,无豁免情形) |
| 3 | 源码引用集合 | PASS(95↔95,diff 空) |
| 4 | 固定标签 | PASS(五标签同位,42 标题零位移,章引用多重集+行位全等) |
| 5 | mermaid | PASS(1 块,13 节点/15 边逐项相等,结构 diff 空) |
| 6 | mdbook build | PASS(WARN/ERROR = 0) |

**总判定:PASS(6/6,可进 C2)。**

非阻塞备注两条(master 决断):① EN mermaid 块内标签保留中文,与 ch06/ch15/ch19 同型、与 ch12 全译型并存;② 章尾 Version note 英文为 inline 合并式(−1 行),五标签行号仍同位。
