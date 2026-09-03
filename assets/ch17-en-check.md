# ch17 英文版 C1 机械校验报告(ch17-en-check)

- 日期:2026-09-02
- 校验对象:`chapters/ch17-swarm.md` ↔ `book-en/src/part3/ch17.md`(基线:主仓 main,e30d961 为 ch17-en 定稿 commit;本报告在隔离 worktree 内产出,未 commit)
- 结论:**6/6 PASS,总判定 PASS(可进 C2)**

---

## 1. verify-en.sh — PASS

命令与输出:

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch17-swarm.md book-en/src/part3/ch17.md
WARN: code block content differs (mermaid and comments excluded)
refs: 56 (equal sets: yes)
en words: 4250, bold 10, em dash 0
RESULT: 0 FAIL(s), 1 WARN(s)
(exit 0)
```

0 FAIL,达标。唯一 WARN 定位:按脚本的 codeblk 逻辑逐块 diff,差异仅一处——CLI 帮助文本块中 4 行中文说明列被译为英文(其余代码块注释剥离后 md5 一致):

| 中文 | 英文 |
|---|---|
| `--swarm-backend <stdio\|cli\|http>   后端种类` | `...   backend kind` |
| `--swarm-backend-cmd <path>         stdio/cli 后端的命令` | `...   command for stdio/cli backends` |
| `--swarm-backend-arg <arg>          可重复的参数` | `...   repeatable argument` |
| `--swarm-backend-url <url>          http 后端端点` | `...   http backend endpoint` |

**W1 判定:属于「中文散文标签必译」类**,与 brief 预告的 WARN 类型一致,豁免。

## 2. 数字集合比对 — PASS

方法:与脚本同口径(strip 代码块、豁免 `U+XXXX` 后提取 `[0-9][0-9,]{2,}[0-9]|[0-9]{3,}`,sort -u),再做双向 comm:

```
zh numbers: 78, en numbers: 78
== missing in en (zh-only): (empty)
== extra in en (en-only):   (empty)
```

缺失 0 / 多余 0;两侧 78 项逐一相等,未触发任何归一豁免(无单位制等值改写、无标点粘连差异、无 U+XXXX 豁免项)。

## 3. 源码引用集合比对 — PASS

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <两侧> | sort -u | diff
zh refs=54  en refs=54  diff=(empty)
```

引用集合相等(54=54,diff 为空)。

## 4. 固定标签 + 章节交叉引用 — PASS

固定标签本侧实况:本章中文原稿仅含两种固定标签(另有「工程决策侧栏」非五标签体系),逐一对照:

| 标签 | 中文行号 | 英文行号 | 同位 |
|---|---|---|---|
| 定位 / **Positioning** | 3 | 3 | ✅ |
| 版本演化说明 / **Version note** | 224 | 224 | ✅ |
| 数据核实 / Verified against | 两侧均无 | 两侧均无 | ✅ 同缺 |
| 数据流 / Data flow | 两侧均无 | 两侧均无 | ✅ 同缺 |
| 关键要点 / Key takeaway | 两侧均无 | 两侧均无 | ✅ 同缺 |

`see Chapter N` ↔ 「详见第 N 章」:两侧各 2 处,行号与章号一一对应——

| 中文 | 英文 |
|---|---|
| 行 107:详见第 10 章 | 行 107:are covered in Chapter 10 |
| 行 167:详见第 10 章 | 行 167:is covered in Chapter 10 |

加测:全章交叉引用全集(含前置依赖、侧栏等各形态)两侧各 16 处,逐行逐条完全同位(1:17, 3:10, 3:16, 107:10, 129:12, 167:10, 191:16, 195:6/6/12/16/10/1, 211:15, 212:10, 213:16)。

## 5. mermaid 节点/边数对照 — PASS

3 个 mermaid 块两侧位于相同行号(44/76/148)。逐块对照:

| 块 | 类型 | 中文 | 英文 | 结构 |
|---|---|---|---|---|
| 1(行44) | flowchart LR | 9 节点 / 6 边行 | 9 节点 / 6 边行 | 一致 |
| 2(行76) | sequenceDiagram | 6 participant / 14 箭头 | 6 participant / 14 箭头 | 一致 |
| 3(行148) | flowchart TD | 11 边行(节点 8) | 11 边行(节点 8) | 一致 |

块 1/3 行级骨架(节点 id + 边,标签剥离)diff 为空;块 2 逐行对照,24 行全部一一对应,差异全部为消息/participant 标签的中→英译文。结构等价,标签译文属预期。

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

0 警告 0 错误,达标。

---

## 总判定

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh(0 FAIL) | PASS(1 WARN=中文散文标签必译类,豁免) |
| 2 | 数字集合 0 缺失 / 0 多余 | PASS |
| 3 | 源码引用集合相等 | PASS |
| 4 | 固定标签同位 + see Chapter N 对应 | PASS |
| 5 | mermaid 结构一致 | PASS |
| 6 | mdbook build 零警告 | PASS |

**总判定:PASS —— ch17 英文版机械校验全绿,可进 C2(母语审校)。**
