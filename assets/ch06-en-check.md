# ch06-en-check —— 英文版 C1 机械校验报告

- 对象:`chapters/ch06-tool-system.md` ↔ `book-en/src/part2/ch06.md`
- 前置:ch06-en 已交付(commit 85a8cc2)
- 校验基线:commit `23692b6`(主仓在校验期间由 85a8cc2 → b952e49 → 23692b6 推进,该提交把「补深度记录/Depth-addition record」过程残留段从三文件删除;本报告全部六项在 23692b6 定稿态于 wt 内重跑,wt 两文件与主仓 HEAD `cmp` 逐字节一致)
- 校验人:peer ch06-en-check(lane cheap)
- 日期:2026-09-03
- 性质:仅机械校验,不做语言读校

## 1. verify-en.sh 脚本比对 — PASS

命令与输出(23692b6 定稿态,wt 内执行):

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch06-tool-system.md book-en/src/part2/ch06.md
refs: 89 (equal sets: yes)
en words: 4886, bold 4, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
```

0 FAIL 为过 → PASS(脚本含代码块内容比对)。

## 2. 数字集合比对 — PASS

命令(代码块外提取,归一规则:剥离每 token 尾部 `,` 与 `.`;两侧同法):

```
$ strip(){ awk '/^```/{c=!c;next} !c' "$1"; }
$ strip chapters/ch06-tool-system.md | sed -E 's/U\+[0-9A-Fa-f]{4,6}//g' \
    | grep -oE '[0-9][0-9,]*\.?[0-9]*' | sed -E 's/,$//; s/\.$//' | sort -u > zh.nums
$ strip book-en/src/part2/ch06.md  | sed -E 's/U\+[0-9A-Fa-f]{4,6}//g' \
    | grep -oE '[0-9][0-9,]*\.?[0-9]*' | sed -E 's/,$//; s/\.$//' | sort -u > en.nums
$ comm -23 zh.nums en.nums | wc -l   # 缺失
0
$ comm -13 zh.nums en.nums | wc -l   # 多余
0
```

- 归一后唯一 token:中文 162 / 英文 162;**缺失 0 / 多余 0**。
- 原始(未归一)diff 的全部差异均为英文句尾标点粘连,逐样本定位核实,例如:`RFC-0.`(RFC-0 后接句点)、`#607.`、`Chapter 7.`——中文对应为 `RFC-0`、`#607)`(括号)、`第 7 章`;与 ch05 报告同类(标点粘连归一后相等)。
- 豁免条款动用情况:全篇无 `U+XXXX` 码点(两侧 `grep -c 'U+'` 均为 0);无万↔thousand 类单位制换算;两项豁免均无需注明动用。

## 3. 源码引用集合比对 — PASS

命令与输出(简报指定 grep 口径):

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' chapters/ch06-tool-system.md | sort -u > zh.refs
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' book-en/src/part2/ch06.md | sort -u > en.refs
$ wc -l zh.refs en.refs
      87 zh.refs
      87 en.refs
$ diff zh.refs en.refs && echo "diff empty"
diff empty
```

- 两侧各 87 个唯一引用,diff 为空 → PASS。
- 与 B 车道自报 refs 90 的偏差:简报口径 grep 实测 87(90 系 B 车道自报口径差异);通过判据是「两侧集合相等、diff 为空」,成立。行号级引用(`:179-183` 等)在两侧均同现。

## 4. 固定标签 — PASS

五标签行号对照(标签定义见 specs/translation-en.spec.md:20 / AGENTS.md:76):

| 标签 | 中文 | 英文 | 同位 |
|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | ✅ |
| 工程决策侧栏(章内 `## 6.6 工程决策侧栏` ↔ `## 6.6 Engineering decision sidebar`) | :295 | :295 | ✅ |
| `## 延伸阅读` ↔ `## Further reading` | :305 | :305 | ✅ |
| `## 思考题` ↔ `## Exercises` | :312 | :312 | ✅ |
| `## 版本演化说明` ↔ `## Version note`(+ `> **Version note**` 引用块 :322) | :320 | :320 | ✅ |

- 五种标签数量一一对应,行号全部同位。
- `see Chapter N` ↔ 「详见第 N 章」:本章正文均无该字面形式(两侧各 0),替代形态为跨章引用,多重集完全一致:`第 5 章×2/第 6 章×1/第 7 章×5/第 8 章×3/第 10 章×1/第 16 章×1/第 18 章×1` ↔ `Chapter 5×2/Chapter 6×1/Chapter 7×5/Chapter 8×3/Chapter 10×1/Chapter 16×1/Chapter 18×1` → PASS。

## 5. mermaid 图对照 — PASS

```
$ grep -c '^```mermaid' chapters/ch06-tool-system.md book-en/src/part2/ch06.md
chapters/ch06-tool-system.md:4
book-en/src/part2/ch06.md:4
```

- 两侧各 4 块(图 6-1 能力域家族 / 6-2 spawn_only 时序 / 6-3 注册路径叠加 / 6-4 策略判定),逐块 `cmp` 字节级一致(行数 25/14/11/14)。
- 与 B 车道自报 5 块的偏差:实测 4 块,自报有误;两侧一致即为过。
- 节点/边数因逐块内容字节一致而天然相等(块 1 graph TD、块 2 sequenceDiagram、块 3 flowchart、块 4 flowchart)。

## 6. mdbook 构建 — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

构建零警告零错误 → PASS。

## 总判定:PASS(可进 C2)

六项 6/6 PASS。备注两点(不构成 FAIL):
1. B 车道自报与实测偏差两处:mermaid 自报 5 实为 4、refs 自报 90 实为 87(简报 grep 口径),均两侧相等,判据不受影响。
2. 全部校验基于 23692b6 定稿态(23692b6 仅删过程残留段,删除后六项复跑仍全过;verify-en 数字 4886 词、refs 89 为该态实测)。
