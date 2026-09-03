# ch19 英文版机械校验报告(ch19-en-check)

- 校验对象:`chapters/ch19-octoscode.md`(214 行)↔ `book-en/src/part4/ch19.md`(215 行)
- 基线:worktree HEAD `94a257b`,前置 commit `e30d961`(ch19-en 定稿)经 `git merge-base --is-ancestor` 验证为 HEAD 祖先;`book-en/src/SUMMARY.md:42` 已收录 `./part4/ch19.md`;工作区无未提交变更(除本报告);两侧文件在 `e30d961` 为最新 touched commit,一致
- 日期:2026-09-03;只做机械校验,不做译评
- 注:brief 所写源文件名 `ch19-mcp-octoscode.md` 不存在,`ls chapters/ch19-*.md` 实际为 `ch19-octoscode.md`,按 brief 预案以其为准

## 1. verify-en.sh — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch19-octoscode.md book-en/src/part4/ch19.md
refs: 73 (equal sets: yes)
en words: 4299, bold 3, em dash 2
RESULT: 0 FAIL(s), 0 WARN(s)
(exit 0)
```

0 FAIL,通过。

## 2. 数字集合比对 — PASS(豁免注明)

数字提取(先剥离行内代码再取连续数字串,去尾随标点)后 sort -u 集合 diff:

- 缺失(ZH 有 EN 无):**0**
- 多余(EN 有 ZH 无):**1 → 归一为 0**

唯一差异:`4.4`(ZH)↔ `44,000`(EN),三处同位(L22 标题 19.2、L94 标题 19.4、L105 正文),为「4.4 万行」↔ "44,000-Line" 的单位制等值改写,按规程豁免。

高频数字两侧一致:18×7、2×6、21/14×5、7,221×4、43,935×3、8,655/1,192/57/2026×2、96,124/9063/900 等。`43,935`(ZH)↔ `44,000`(EN)并存(EN 同时保留精确值),非替代关系。

## 3. 源码引用集合比对 — PASS

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <side> | sort -u
ZH: 68 refs; EN: 68 refs
$ diff ref_zh.txt ref_en.txt   → (empty)
```

差异为空;其中 50 个为 `octoscode/` 前缀引用,两侧一致。

## 4. 固定标签与 see Chapter N — PASS

- 标题 11 个,行号同位:1/5/22/74/94/132/159/165/175/195/203(章名 + 19.1–19.8 + Further reading↔延伸阅读 + Exercises↔思考题)
- 五种固定标签均 1:1 同位:**定位↔Positioning**、**前置依赖↔Prerequisites**(均 L3)、**边界与回顾↔Boundaries and Recap**(均 L175)、**延伸阅读↔Further reading**(均 L195)、**思考题↔Exercises**(均 L203)
- 章节引用(多重集,ZH「第 N 章」含「第 20、21 章」顿号式归一,EN "Chapter(s) N" 含 "Chapters 20 and 21" 拆分归一):2×2、10×1、14×5、18×7、19×1、20×2、21×5,两侧完全相等;`see Chapter 2` ↔ 「见第 2 章」同位(L199)

## 5. mermaid 节点/边数对照 — PASS

- mermaid 块:ZH 3 = EN 3
- 节点:节点 id 集合 diff 为空(两图均 17 个匹配记号)
- 边:两侧均 15 条边行(16 连字符计数为图内标签所致),结构一致

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
(mdbook 本体 exit 0)
```

WARN/ERROR 计数 0。

## 总判定:PASS(6/6,可进 C2)

| # | 校验项 | 结果 |
|---|--------|------|
| 1 | verify-en.sh | PASS(0 FAIL / 0 WARN) |
| 2 | 数字集合 | PASS(缺失 0;多余 1 处为单位制等值,豁免注明) |
| 3 | 源码引用集合 | PASS(68/68,diff 空) |
| 4 | 固定标签 + 章节引用 | PASS(五种标签与 11 标题全同位;章号多重集相等) |
| 5 | mermaid | PASS(3 块 / 节点集相等 / 各 15 边) |
| 6 | mdbook build | PASS(WARN/ERROR = 0) |
