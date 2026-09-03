# ch08-en-check —— 英文版 C1 机械校验报告

- 对象:`chapters/ch08-context-management.md` ↔ `book-en/src/part2/ch08.md`
- 前置:ch08-en 已交付(commit `60a68cf`),wt 与主仓两文件逐字节一致(`diff` 为空),基线即该定稿态
- 校验人:peer ch08-en-check(lane cheap)
- 日期:2026-09-03
- 性质:仅机械校验,不做语言读校

## 1. verify-en.sh 脚本比对 — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch08-context-management.md book-en/src/part2/ch08.md
refs: 86 (equal sets: yes)
en words: 4223, bold 12, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
(exit 0)
```

0 FAIL 为过 → PASS(脚本含标题数/围栏数/mermaid 数/代码块内容 md5/引用集合/数字/CJK 残留/违禁词/Positioning 与 Version note 锚点)。

## 2. 数字集合比对 — PASS

双口径,均先剥代码块(代码块内容已由项 1 md5 证明两侧一致):

口径 A(简报口径,行内长数字 token):

```
$ strip chapters/ch08-context-management.md | sed -E 's/U\+[0-9A-Fa-f]{4,6}//g' \
    | grep -oE '[0-9][0-9,]{2,}[0-9]|[0-9]{3,}' | sort -u > /tmp/nzh     # 104 个
$ strip book-en/src/part2/ch08.md          | …同法…              > /tmp/nen     # 104 个
$ comm -23 /tmp/nzh /tmp/nen | wc -l    # 缺失
0
$ comm -13 /tmp/nzh /tmp/nen | wc -l    # 多余
0
```

口径 B(ch07 家族口径,千分位逗号归一):两侧各 **166** 个唯一数字,**缺失 0 / 多余 0**。

- 豁免条款动用情况:两侧全篇 `U+XXXX` 码点均为 0 处,豁免未动用;千分位归一后集合完全相等,不存在万↔thousand 类换算差,无需注明。
- **缺失 0 / 多余 0** → PASS。

## 3. 源码引用集合比对 — PASS

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' chapters/ch08-context-management.md | sort -u > /tmp/rzh   # 86
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' book-en/src/part2/ch08.md           | sort -u > /tmp/ren   # 86
$ diff /tmp/rzh /tmp/ren && echo "(no diff)"
(no diff)
```

- 两侧各 86 个唯一引用,diff 为空 → PASS。行号级引用(如 `compaction.rs:99-153`、`context_manager.rs:2408-2440`)两侧同现。
- 交叉印证:verify-en.sh 自带口径亦报 `refs: 86 (equal sets: yes)`。

## 4. 固定标签 — PASS

五标签对照(标签定义见 specs/translation-en.spec.md / AGENTS.md):

| 标签 | 中文 | 英文 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ |
| 工程决策侧栏 `> ### 工程决策侧栏:…` ↔ `> ### Engineering decision:…` | :227 | :227 | 1↔1 | ✅(行号完全同位) |
| `## 延伸阅读` ↔ `## Further reading` | :248 | :247 | 1↔1 | −1 ⚠ |
| `## 思考题` ↔ `## Exercises` | :254 | :253 | 1↔1 | −1 ⚠ |
| `> **版本演化说明**` ↔ `> **Version note**` | :262 | :261 | 1↔1 | −1 ⚠ |

- 位移成因(已定位,净额 +2 已闭合核算):① 英文侧章回顾(recap)编号列表第 6/7 条之间少一个空行(中文 :243 空行,英文 :243 为第 7 条内容),致其后三个章末标签各 −1,列表 7 条内容本身 1↔1 同序对应;② 英文侧 Version note 之后多一条 `---` 主题分隔线(:263,中文无)。①为 −1、②为 +1,总行数 262↔264 差恰为 +2,除这两处外其余正文逐行同位。纯排版装饰差异,无内容错位 → 判 PASS,如实注明,由 master 裁量是否要求 EN 补空行/去尾线。
- `see Chapter N` ↔「详见第 N 章」:两侧字面形式均为 0 处(`grep -c '详见'`=0,`grep -ci 'see Chapter'`=0,本章无「详见第 N 章」句式)。跨章引用以裸形式出现且多重集完全一致、逐处同位:两侧均 `第 N 章`/`Chapter N` 出现于行号 1,3,77,168,176,188,202(×2:9、12),206 —— 9 处 ↔ 9 处,编号一一对应 → PASS。

## 5. mermaid 图对照 — PASS

```
$ awk '/^```mermaid/{m=1;n++;next} /^```/{m=0} m' <file>     # 提取
```

- 块数:2 ↔ 2(verify-en.sh 亦报 mermaid 数相等,代码围栏数相等)。
- 边数(`-->` 行):21 ↔ 21。
- 节点 id(`ID[`/`ID((` 形态提取,sort -u):18 ↔ 18,且 **id 集合完全相等**(diff 为空)。
- 结构归一对比(标签体剥空、仅留图元骨架):23 行骨架逐行一致,唯一差异为 1 处决策节点标签 `G{required 通过?}` ↔ `G{required passing?}` —— 属规格允许的标签英译,结构不变 → PASS。

## 6. mdbook 构建 — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

0 条 WARN/ERROR → PASS。

## 总判定:PASS(可进 C2)

六项 6/6 PASS。仅存两处纯排版注释项(章末标签整体 −1 位移的空行缺失、Version note 后多一条 `---`),不涉及内容、数量或指向错位,不影响 C2 放行,由 master 裁量是否顺手修齐。
