# 附录 A 英文版 C1 机械校验报告(appendixa-en-check)

- **对象**: `chapters/appendix-a-crate-graph.md` ↔ `book-en/src/appendix/a-crate-graph.md`
- **基准**: 前置 commit `c35ffc1`(en G5 附录 A+B 采回)为其祖先;工作 worktree HEAD = `816ca5f`;主仓已推进至 `4c49659`,但两份校验对象与 `assets/appendixA-facts.md` 经 `diff -q` 逐字节一致,主仓与 worktree 内容无漂移,校验对交付内容有效。
- **日期**: 2026-09-03

---

## 1. verify-en.sh 脚本校验 — ✅ PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/appendix-a-crate-graph.md book-en/src/appendix/a-crate-graph.md
refs: 12 (equal sets: yes)
en words: 3152, bold 2, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

0 FAIL,达标。

## 2. 数字集合比对 — ✅ PASS(0 缺失 / 0 多余)

逐 token 提取(`grep -oE '[0-9][0-9,\.]*' | sort -u`,剔除行尾标点后比对——**单位制等值豁免**:中文「一万多倍」vs 英文 "more than ten thousand times" 为同一数字语义的文字化,两侧无 \[０-９\] 全角数字、无「万」计数残留):

```
CN unique numeric tokens: 118
EN unique numeric tokens: 118
--- missing in EN (CN-only) ---   (空)
--- extra in EN (EN-only) ---     (空)
MISSING=0 EXTRA=0
```

原始比对出现的 3 个 token 差异(`22313`/`0.`/`5.`)均为句末标点伪差:CN `→ 22313。` vs EN `→ 22313.`(同一句);`L0.`/`L5.` 为英文行内层号+句点。归一化后零差异。关键数字抽验:63 边、26 顶层、23 octos-\*、38 members、8 层、700,915 行、279 外部依赖、52 optional、307,299/21/55(cli/server)两侧同在。

## 3. 源码引用集合比对 — ✅ PASS(12 == 12,diff 为空)

```
$ grep -oE 'crates/[a-zA-Z0-9_-]+(/src)?' <file> | sort -u   # 两侧
diff /tmp/cn_refs.txt /tmp/en_refs.txt && echo "REF SETS EQUAL"
→ REF SETS EQUAL (12 entries)
```

集合:`crates/{app-skills, octos-agent/src, octos-cli, octos-cli/src, octos-core, octos-fleet-worker, octos-pyo3, octos-server, octos-swarm, octos-web, platform-skills, pyo3}`——与 B 侧自报 12 条一致。

## 4. 固定标签同位 — ✅ PASS

- **Positioning / 定位**:两侧均第 3 行(`> **定位**：…` ↔ `> **Positioning**: …`),六要素(地图页/26 顶层/23 crate/63 边/前置第 1 章/使用场景)对位。
- **Version note / 版本演化说明**:两侧均 271 行标题、273 行 blockquote,基准 `9c157101`(2026-09-03 统计)与 8 项数字清单逐一同位。
- 结构同位附加证据:标题 19 == 19、代码围栏 4 == 4、blockquote 4 == 4。

## 5. mermaid 63 边 + 三表行数 — ✅ PASS(外环硬指标达标)

**边数**:两侧 mermaid 各解析出 **63** 条 `-->` 边;规范化(node id → crate 全名)后:

- 两侧边集合 **逐条相同**(diff 为空,missing 0 / extra 0);
- 与 ground truth `assets/appendixA-facts.md` §3「依赖边全量清单(63 条)」**63 == 63 逐条一致**(missing 0 / extra 0);
- 出度核对与 facts 记录的计数式吻合:5+1+15+1+1+1+6+1+5+1+1+5+1+9+3+1+1+1+1+3 = 63;节点声明 23 个 octos-\* + app-skills/platform-skills/octos-web 文字节点,两侧 id 集相同(22 个带 crate 名声明 diff 为空)。

**三表行数**(管道行,两侧一致):

| 表 | CN | EN | 判定 |
|---|---|---|---|
| A.1 汇总数字 | 8 | 8 | ✅ |
| A.3 逐 crate 数据表 | 25 | 25 | ✅ |
| A.5 外部依赖明细表 | 25 | 25 | ✅ |

(A.1 含表头+分隔行共 8 管道行、6 数据行;A.3/A.5 各 25 管道行、23 数据行 = 23 个 octos-\* crate,与「23 crate」口径一致。)

## 6. mdbook build 零警告 — ✅ PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
(INFO Book building has started / INFO Running the html backend / INFO HTML book written to …/book-en/book)
```

主仓与 worktree(816ca5f)各构建一次,均 0 WARN/0 ERROR(`book-en/book` 为 gitignored,未污染仓)。

---

## 总判定

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | ✅ PASS(0 FAIL/0 WARN) |
| 2 | 数字集合 | ✅ PASS(0/0,标点豁免已注明) |
| 3 | 源码引用集合 | ✅ PASS(12==12,diff 空) |
| 4 | Positioning / Version note 同位 | ✅ PASS(3 行/271 行) |
| 5 | mermaid 63 边 + 三表 8/25/25 | ✅ PASS(对 facts 全等) |
| 6 | mdbook build | ✅ PASS(0 警告) |

**总判定:PASS(6/6)——附录 A 英文版可定稿。**
