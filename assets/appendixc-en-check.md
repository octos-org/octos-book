# 附录 C C1 校验报告(appendixc-en-check)

- 校验对象:`chapters/appendix-c-config-reference.md`(ZH, 536 行) ↔ `book-en/src/appendix/c-config-reference.md`(EN, 536 行)
- worktree HEAD:`816ca5f`(分支 main,未 commit;前置基线 94a257b 已含附录 C 定稿)
- 校验日期:2026-09-02 · 迭代消耗:约 6/20

## 1. verify-en.sh — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/appendix-c-config-reference.md \
      book-en/src/appendix/c-config-reference.md
refs: 302 (equal sets: yes)
en words: 5263, bold 13, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
```

0 FAIL,达到通过线。

## 2. 数字集合比对 — PASS(缺失 0 / 多余 0,无豁免项)

提取规则:`grep -oE '\b[0-9][0-9,._]*\b'`,剥离尾部标点(`[.,_]*$`)后 `sort -u`。

```
ZH: 325 个唯一数字 token,EN: 325 个
only in ZH: (空)    only in EN: (空)
```

说明:首轮对比出现的 `15.` / `2212.` 差异为提取伪影(英文 ASCII 句点被字符类吞入,中文全角句读不会),规范化后归零。逐处核验:`2212` 两侧均在 C.14(L527/L530,`#2211/#2212`);`15` 两侧均在 L424(中文「见 Ch15」/ 英文「in Chapter 15.」),同一交叉引用的书写差异,非数字缺失。无单位制换算差异,无需豁免。

## 3. 源码引用集合比对 — PASS(diff 为空,302 = 302)

```
$ grep -oE 'crates/[A-Za-z0-9_/.:-]+' <file> | sed 's/[._]*$//' | sort -u
ZH refs: 302, EN refs: 302
$ diff <(zh) <(en)   → 无输出,REF SETS IDENTICAL
```

与 verify-en.sh 自报的 `refs: 302 (equal sets: yes)` 一致。

## 4. 固定标签 — PASS

| 标签 | ZH | EN |
|---|---|---|
| Positioning(定位) | L3:`> **定位**:…` | L3:`> **Positioning**:…`(同位) |
| Version note(版本演化说明) | L525:`## C.14 版本演化说明` | L525:`## C.14 Version note`(同位) |

两侧标题结构逐行同位(29 个标题,`## C.1`…`## C.14` 行号完全一致,仅文字为译文)。

## 5. 表行数与形态 — PASS

**行数**(两侧一致):

```
| 开头行: 290(= 简报口径)  分隔行: 24  数据行: 266
266 = 242 字段行 + 24 表头行;顶层 Config 全表(C.2, L13-58)= 44 数据行 + 1 表头(45 个 | 行)✔
```

**逐行对照**:266 行按 `字段路径|类型|来源` 逐行 diff,行序一致;归一化(表头词 字段路径/类型/来源行号↔Field path/Type/Source;连接词 `、默认`↔`, default`、`、枚举`↔`, enum`;`enum(tagged`↔`enum (tagged`))后 **diff 为空**——所有行号、类型、字段路径逐行相等。

**array 类型反引号形态**:

```
`array<ChannelEntry>`: ZH ×1 / EN ×1    `array<Validator>`: ZH ×1 / EN ×1
非反引号的 array< 出现: 两侧均为 0
```

**JSONC 示例(C.13, L459-524)**:`//` 注释行 13/13 两侧保留;块内 diff 仅 C.13 标题译文一行,配置结构与注释内容一致。

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
INFO HTML book written to …/wt/book-en/book
```

0 WARN / 0 ERROR。

## 总判定:PASS(6/6,可定稿)

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | PASS(0 FAIL/0 WARN) |
| 2 | 数字集合 | PASS(0 缺/0 多,无豁免) |
| 3 | 源码引用集合 | PASS(302=302,diff 空) |
| 4 | 固定标签 | PASS(同位) |
| 5 | 表行数/形态 | PASS(290/242/44;266 行逐行一致;array 反引号一致;JSONC 13 注释保留) |
| 6 | mdbook build | PASS(0 WARN/ERROR) |

备注:仅发现两处非问题级书写差异,已记录不扣分——L424 交叉引用「Ch15」↔「Chapter 15.」;Source 单元格连接词 `、默认/、枚举` ↔ `, default/, enum`。
