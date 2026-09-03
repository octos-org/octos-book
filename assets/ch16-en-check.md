# ch16 英文版机械校验报告(ch16-en-check)

- 校验对象:`chapters/ch16-fleet.md`(246 行)↔ `book-en/src/part3/ch16.md`(245 行)
- 基线:主仓 main @ `90cca6e`,前置 commit `1b247ef`(ch16-en 定稿,SUMMARY 对应 part3)已验证为 HEAD 祖先(`git merge-base --is-ancestor` 通过);本 worktree 除本报告外无未提交变更
- 日期:2026-09-03;只做机械校验,不做译评

## 1. verify-en.sh — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch16-fleet.md book-en/src/part3/ch16.md
refs: 55 (equal sets: yes)
en words: 4670, bold 5, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

0 FAIL 为过 → PASS。

## 2. 数字集合比对 — PASS(0/0,零豁免)

方法:`[0-9][0-9,]*(\.[0-9]+)?(%?)` 提取 → 千分位/粘连逗号归一(`sed 's/,//g'`)→ `sort -u` 集合比对,另做逐 token 计数的多重集交叉验证。`U+XXXX` 豁免:两侧均 0 处,无豁免案例。

```
归一后 unique:zh 145 ↔ en 145,集合 diff 为空
多重集:239 ↔ 239 个 token 逐计数全等(multiset IDENTICAL)
MISSING (zh only): 0
EXTRA   (en only): 0
```

附加核对:不做任何归一的原始集合有差,但差异 token 全部为「数字后半角逗号」形态(共 zh 9 / en 16 处,如 zh `:1623` ↔ en `:1623,`、zh `880,` ↔ en `880`——行号引用后接标点的排版写法差),剥离尾逗号去重后 145↔145 完全一致。即:全部差异均属题设允许的「标点粘连归一」范畴,无真实数值差,无「万↔,000」类单位制差。归一后缺失/多余 = **0/0** → PASS。与 B 车道自报「全部数字 16,888 等 1:1」一致。

## 3. 源码引用集合比对 — PASS

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <side> | sort -u
zh refs: 53, en refs: 53
$ diff <(zh) <(en) → 无输出,SRC DIFF EMPTY
```

53↔53,diff 为空。verify-en.sh 的 55 为行级计数(同行多引用口径),集合级两侧一致——与 ch15(54 集合/55 行级)同形态。

## 4. 固定标签 — PASS

| 标签 | 中文行 | 英文行 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ 同行 |
| `### 工程决策侧栏` ↔ `> ### Engineering decision` | :146 | :146 | 1↔1 | ✅ 同行(本章 1 处) |
| `## 延伸阅读` ↔ `## Further reading` | :228 | :228 | 1↔1 | ✅ 同行 |
| `## 思考题` ↔ `## Exercises` | :235 | :235 | 1↔1 | ✅ 同行 |
| `> **版本演化说明**` ↔ `> **Version note**` | :245 | :245 | 1↔1 | ✅ 同行 |

五处标签行号零漂移。

`see Chapter N` ↔ 「详见第 N 章」:

- 版注 :245/:246:`see Chapter 16` ↔ 「详见第 16 章」,同一句(`fleet 状态机在此前章节中曾被第 12 章以「详见第 16 章」前向引用` / `forward-referenced by Chapter 12 as "see Chapter 16"`),EN 版注单行长句、ZH 折行,行数差即两文件 246↔245 的 delta,内容同位 ✅

章节引用多重集(两侧全量 `第 N 章` / `Chapter N`):zh `第16章×2(:1,:246) 第12章×5(:3,:113×2,:216,:246) 第7章×4(:3,:184×2,:216) 第18章×3(:7,:113,:214) 第13章×1(:9) 第17章×1(:216)` ↔ en 完全相同的计数与行号(版注 :246↔:245)。计数全等、全部同行,零漂移。

## 5. mermaid 对照 — PASS

3 块,B 自报类型(classDiagram / sequenceDiagram / stateDiagram-v2)逐一对应,围栏起始行 :40/:119/:154 两侧同位:

| 块 | 类型 | 内容行 | 边/转移 | 节点 |
|---|---|---|---|---|
| 1 | classDiagram | 37↔37 | 4↔4 | 6↔6(class id 集合全等;两侧行内容逐字节一致) |
| 2 | sequenceDiagram | 20↔20 | 10↔10 | participant 4↔4(O/P/S/W 全等;alt/else/end/Note 结构行同位) |
| 3 | stateDiagram-v2 | 17↔17 | 16↔16 | 9↔9(state id 集合全等,含 3×`[*]` 终态) |

块 2/3 diff 行均为 note/标签/转移措辞的语言差(CN 16 / EN 36 变更行),结构行数、边数、节点数逐块全等。

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
| 2 | 数字集合 0/0 | PASS(仅标点粘连归一,零豁免) |
| 3 | 源码引用集合 | PASS(53↔53,diff 空) |
| 4 | 固定标签同位 | PASS(五处零漂移 + see Chapter 16 同句) |
| 5 | mermaid | PASS(3 块逐块边/节点全等) |
| 6 | mdbook build | PASS(0 WARN/ERROR) |

**总判定:PASS(6/6),ch16 英文版可进 C2。**
