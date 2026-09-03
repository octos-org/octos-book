# ch21-en-check — 英文版 C1 机械校验报告

- 校验对象:`chapters/ch21-herdr.md`(经 `ls chapters/ch21-*.md` 确认,唯一源文件)↔ `book-en/src/part4/ch21.md`(main @ 0677704 已入主仓)
- 校验环境:隔离 worktree(commit 816ca5f),全程未 commit、未改动交付文件
- 校验日期:2026-09-03

---

## 项 1 verify-en.sh 结构校验 — PASS

命令:
```
bash ~/.octos/outer/verify-en.sh chapters/ch21-herdr.md book-en/src/part4/ch21.md
```
输出(节选):
```
refs: 69 (equal sets: yes)
en words: 4745, bold 6, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
```
**0 FAIL(且 0 WARN),过。**

## 项 2 数字集合比对 — PASS

命令(两文件各自提取 `grep -oE '[0-9][0-9,]{2,}[0-9]|[0-9]{3,}'` 后 `sort -u`,comm 双向比对):

```
nums zh=75 en=75
missing=0 extra=0
```

- 缺失 0 / 多余 0,**且为原始精确比对(未启用任何豁免)**:两侧均无 U+XXXX 码点、无单位粘连变体、无小数形态差异,75 个数字一一对应。
- 重点口径核对:
  - `245`(.rs 文件):zh=1 / en=1(均 L18,herdr src/ 文件数)
  - `229,696`(herdr 行数):zh=1 / en=1(均 L18)
  - `700,915`(三仓合计):zh=0 / en=0 —— **两侧均未出现该数字,属预期一致**(本章讲 herdr 单仓,体量以 L18 的 245 文件、229,696 行及逐目录行数(65,400/19,166/12,416/10,540/9,822/8,957 等两侧同在集合中)表达;三仓合计口径不在本章文本中,无失配)。

## 项 3 源码引用集合比对 — PASS

命令:
```
diff <(grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' chapters/ch21-herdr.md | sort -u) \
     <(grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' book-en/src/part4/ch21.md | sort -u)
```
输出:`REFS-SET-IDENTICAL`,两侧各 57 条(herdr/ 前缀 55 条,其余为 crates/… 与 octoscode/… 前缀,含 `herdr/src/cli.rs:762`、`herdr/src/api/schema/common.rs:151`、`herdr/src/detect/manifests/octoscode.toml` 等)。**diff 为空,过。**

## 项 4 固定标签同位 — PASS

五种固定标签逐一同位(行号 zh=en):

| 标签 | zh 行 | en 行 |
|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | 3 | 3 |
| `> **工程决策:…**` ↔ `> **Engineering decision: …**` | 152–153 | 152–153 |
| `> **版本演化说明**` ↔ `> **Version note**` | 239–240 | 239–240 |
| `## 延伸阅读` ↔ `## Further reading` | 220 | 220 |
| `## 思考题` ↔ `## Exercises` | 229 | 229 |

另:全部 `##` 章节标题行号同位(1/5/52/109/157/185/204/214/220/229);跨章引用 zh `第 N 章`(L3,107,153,208,216×3,218×2)与 en `Chapter N` 逐行号一一对应(L1 Chapter 21、L107/153 Chapter 19、L208 Chapter 20、L216 Chapter 18/19/20、L218 Chapter 19/20);`see Chapter N` 措辞两侧均为 0 处(0=0,该章以 `Chapter N` 直接引用)。版本基线 `fefe5c4f` / `9c157101` / 0.8.2 双侧同在 L240。**过。**

## 项 5 mermaid 节点/边对照 — PASS

3 张图,fence 行号同位(22–44 / 123–146 / 191–200):

| 图 | 类型 | zh | en |
|---|---|---|---|
| L23–43 | flowchart LR | 16 个节点标签、6 条边 | 16 / 6 |
| L124–145 | sequenceDiagram | 4 participant、13 条箭头 | 4 / 13 |
| L192–199 | stateDiagram-v2 | 6 条状态转移 | 6 |

节点 id(`OP/CLI/SRV/SOCK/P1-P3`、`O/S/T/C`、`mounted/healthy/visible_stall/blind`)与拓扑完全一致,正文 diff 仅为标签文案中译英(如「外环侧」→"Outer-loop side"),无增删节点或边。**过。**

## 项 6 mdbook 构建零警告 — PASS

命令:
```
cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
```
输出:`0`(构建成功,HTML 写出至 book-en/book)。**0,过。**

---

## 总判定:**PASS(6/6)—— ch21-en 可进 C2**

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | PASS(0 FAIL 0 WARN) |
| 2 | 数字集合 | PASS(0 缺失 / 0 多余,原始精确无豁免;700,915 双侧均无,口径一致) |
| 3 | 源码引用集合 | PASS(diff 空,57=57) |
| 4 | 固定标签同位 | PASS(五标签 + 章节标题 + 跨章引用全部同位) |
| 5 | mermaid 对照 | PASS(3 图节点/边数一致,拓扑一致) |
| 6 | mdbook 构建 | PASS(WARN/ERROR = 0) |
