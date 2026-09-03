# ch05-en-check —— 英文版 C1 机械校验报告

- 对象:`chapters/ch05-agent-loop.md` ↔ `book-en/src/part2/ch05.md`
- 前置:ch05-en 已交付(commit 67056d6)
- 校验人:peer ch05-en-check(lane cheap)
- 日期:2026-09-02
- 性质:仅机械校验,不做语言读校

## 1. verify-en.sh 脚本比对 — PASS

命令与输出:

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch05-agent-loop.md book-en/src/part2/ch05.md
refs: 59 (equal sets: yes)
en words: 5697, bold 13, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)
```

0 FAIL 为过 → PASS(脚本含代码块内容比对)。

## 2. 数字集合比对 — PASS

命令:

```
$ for f in chapters/ch05-agent-loop.md book-en/src/part2/ch05.md; do
    grep -o -E '[0-9][0-9,._]*' "$f" | sort -u > /tmp/nums_$(basename $f).txt; done
$ diff /tmp/nums_ch05-agent-loop.md.txt /tmp/nums_ch05.md.txt   # 原始 diff 非空
$ sed -E 's/,$//; s/\.$//' /tmp/nums_ch05-agent-loop.md.txt | sort -u > a.norm   # 两侧同法
$ diff a.norm b.norm; echo $?
0
```

- 原始唯一 token 数:中文 215 / 英文 234;原始 diff 的全部差异均为英文标点粘连(`111,`↔`111`、`5.5.`↔`5.5`、列表项序号 `1.` 等,共 33 处,清单一并见上方 diff 输出)。
- 归一化(仅剥离尾部 `,` 与 `.`)后两侧集合完全相等:**缺失 0 / 多余 0**。
- 无需动用 U+XXXX 码点或单位制(万↔thousand)豁免。

## 3. 源码引用集合比对 — PASS

命令与输出:

```
$ for f in chapters/ch05-agent-loop.md book-en/src/part2/ch05.md; do
    grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' "$f" | sort -u \
      > /tmp/refs_$(basename $f).txt; done
$ wc -l /tmp/refs_*.txt
58 /tmp/refs_ch05-agent-loop.md.txt
58 /tmp/refs_ch05.md.txt
$ diff /tmp/refs_ch05-agent-loop.md.txt /tmp/refs_ch05.md.txt; echo $?
0(空)
```

58 = 58,diff 为空 → PASS(verify-en.sh 内部计数为 59,同样 equal sets: yes,系其正则口径略宽,不构成差异)。

## 4. 固定标签与交叉章引用 — PASS

五标签行号同位(两侧完全一致):

| 标签 | 中文 | 英文 | 行号 |
|---|---|---|---|
| Positioning | `> **定位**：` | `> **Positioning**:` | 3 = 3 |
| Engineering decision | `> ### 工程决策侧栏：…` | `> ### Engineering decision: …` | 229 = 229 |
| Further reading | `## 延伸阅读` | `## Further reading` | 290 = 290 |
| Exercises | `## 思考题` | `## Exercises` | 298 = 298 |
| Version note | `## 版本演化说明` | `## Version note` | 308 = 308 |

11 个节标题(`5.1`–`5.11`)行号亦逐一同位。

`see Chapter N` ↔ 「详见第 N 章」对照(6 = 6,行号同位):

| 行号 | 中文 | 英文 |
|---|---|---|
| 36 | 详见第 8 章 | in Chapter 8 |
| 42 | 详见第 6 章 | see Chapter 6 |
| 91 | 详见第 6 章 | Chapter 6's subject |
| 271 | 详见第 4 章 | is Chapter 4('s subject) |
| 271 | 详见第 14 章 | see Chapter 14 |
| 277 | 详见第 18 章 | see Chapter 18 |

非 `see` 句式的 3 处(36/91/271)为等义表述,章号一致。→ PASS

## 5. mermaid 节点/边对照 — PASS

两侧各 3 块,位置同为 L54 / L164 / L207,类型与计数:

| 块 | 类型 | 中文 节点/边 | 英文 节点/边 | ID 集合 |
|---|---|---|---|---|
| 1 | sequenceDiagram | 6 / 6 | 6 / 6 | BU,EX,LC,LR,MR,ST(同) |
| 2 | flowchart TD | 14 / 14 | 14 / 14 | A–N(同) |
| 3 | stateDiagram-v2 | 8 / 15 | 8 / 15 | CompactAndRetry,Continue,Escalate,Escalate_2,Exhausted,Grace,Looping,RotateAndRetry(同) |

统计脚本:python3 逐块解析 `​```mermaid` 围栏,节点按 ID 去重、边按连接符计数(B 车道自报 3 块,与实count一致)。→ PASS

## 6. mdbook build 警错计数 — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

计数 0(须 0)→ PASS。

## 总判定

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | PASS |
| 2 | 数字集合 | PASS |
| 3 | 源码引用 | PASS |
| 4 | 固定标签/交叉引用 | PASS |
| 5 | mermaid | PASS |
| 6 | mdbook build | PASS |

**总判定:PASS(6/6),ch05-en 可进 C2。**
