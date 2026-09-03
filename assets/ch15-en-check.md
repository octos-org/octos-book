# ch15 英文版机械校验报告(ch15-en-check)

- 校验对象:`chapters/ch15-production.md`(327 行)↔ `book-en/src/part3/ch15.md`(326 行)
- 基线:主仓 main @ `e30d961`,前置 commit `e6ef9eb`(ch15-en 定稿)属实;本 worktree 未 commit,无未提交变更
- 日期:2026-09-03;只做机械校验,不做译评

## 1. verify-en.sh — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch15-production.md book-en/src/part3/ch15.md
refs: 55 (equal sets: yes)
en words: 4521, bold 12, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

0 FAIL 为过 → PASS。

## 2. 数字集合比对 — PASS(0/0,零豁免)

方法:剔除代码围栏内内容 → `U+XXXX` 豁免(两侧均 0 处,无需豁免)→ 剥离千分位逗号(`tr -d ','`)→ 提取 `[0-9]+(\.[0-9]+)?` → `sort -u` → `comm` 双向比对。

```
归一后 unique:zh 138 ↔ en 138
MISSING (zh only): (空)
EXTRA   (en only): (空)
```

附加核对:不做逗号归一的原始集合亦 138↔138 全等(本章两侧数字写法完全一致,无「万↔,000」类单位制差,无标点粘连案例)。豁免后缺失/多余 = **0/0** → PASS。与 B 车道自报「全部数字 1:1」一致。

## 3. 源码引用集合比对 — PASS

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <side> | sort -u
zh refs: 54, en refs: 54
$ diff /tmp/zh15_ref.txt /tmp/en15_ref.txt  → 无输出,REFSETS-EQUAL
```

54↔54,diff 为空。verify-en.sh 的 55 为含去重口径差异的行级计数,集合级两侧一致。

## 4. 固定标签 — PASS

| 标签 | 中文行 | 英文行 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ 同行 |
| `### 工程决策侧栏` ↔ `> **Engineering decision**` | :91, :290 | :91, :290 | 2↔2 | ✅ 逐行同行(本章 2 处) |
| `## 延伸阅读` ↔ `## Further reading` | :310 | :310 | 1↔1 | ✅ 同行 |
| `## 思考题` ↔ `## Exercises` | :317 | :317 | 1↔1 | ✅ 同行 |
| `> **版本演化说明**` ↔ `> **Version note**` | :326 | :326 | 1↔1 | ✅ 同行 |

六处标签行号零漂移。

`see Chapter N` ↔ 「详见第 N 章」:

- 正文 `:9`:see Chapter 10 ↔ 详见第 10 章(Hooks shell 协议与熔断器)✅ 同行
- 版注 `:326`/`:327`:EN `:326` 两处(Chapter 14 相对旧版 / Chapter 10 Hooks)↔ ZH `:327` 两处(旧版第 14 章 / 详见第 10 章)——同一句,EN 版注是单行长句,ZH 排版折为版注 + 尾注两行,delta +1 行,内容同位 ✅

章节引用多重集(排除 `## 15.6 Chapter recap` 这一无数字标题):ZH `第 15 章×1(:1) / 第 14 章×3(:3,:298,:327) / 第 10 章×3(:9,:298,:327) / 第 7 章×1(:298) / 第 1 章×1(:298) / 第 18 章×1(:298)` ↔ EN `Chapter 15×1(:1) / Chapter 14×3(:3,:298,:326) / Chapter 10×3(:9,:298,:326) / Chapter 7×1(:298) / Chapter 1×1(:298) / Chapter 18×1(:298)`,计数全等、除上述 :326/:327 版注行外全部同行。

标题结构:25↔25 个标题,level 序列(1×1 + 2×7 + 3×17)diff 为空,LEVEL-SEQUENCE-EQUAL;表行 19↔19。与 B 车道自报 55 refs/19 表行/25 标题 1:1 一致。

## 5. mermaid 对照 — PASS

3 块两侧逐块全等:

| 块 | 中文(行/边/节点) | 英文(行/边/节点) |
|---|---|---|
| 1 | 17 / 3 / 6 | 17 / 3 / 6 ✅ |
| 2 | 14 / 4 / 5 | 14 / 4 / 5 ✅ |
| 3 | 19 / 9 / 8 | 19 / 9 / 8 ✅ |

合计边数 16↔16。

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

构建成功,`HTML book written to .../book-en/book`,0 WARN / 0 ERROR。

## 结论

| # | 校验项 | 判定 |
|---|---|---|
| 1 | verify-en.sh | PASS(0 FAIL / 0 WARN) |
| 2 | 数字集合 0/0 | PASS(零豁免) |
| 3 | 源码引用集合 | PASS(54↔54,diff 空) |
| 4 | 固定标签同位 | PASS(六处零漂移) |
| 5 | mermaid | PASS(3 块逐块全等) |
| 6 | mdbook build | PASS(0 WARN/ERROR) |

**总判定:PASS(6/6),ch15 英文版可进 C2。**
