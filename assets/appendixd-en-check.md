# Appendix D 英文版 C1 校验报告(appendixd-en-check)

- 日期:2026-09-03
- 对象:`chapters/appendix-d-feature-flags.md` ↔ `book-en/src/appendix/d-feature-flags.md`
- 基线:wt HEAD `64733bc`(zh 最后改动 `75fa2c0`——含 B 车道上报的 :11 D.7→D.6 修正;en 最后改动 `9296acc`)
- 校验车道:C1(数据表章),共 6 项
- **总判定:PASS(6/6 PASS,英文版附录 D 可定稿)**

---

## 1. verify-en.sh — **PASS**

```
$ bash ~/.octos/outer/verify-en.sh chapters/appendix-d-feature-flags.md book-en/src/appendix/d-feature-flags.md
refs: 20 (equal sets: yes)
en words: 3528, bold 1, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

0 FAIL(且 0 WARN,连已知的 text 块 WARN 都没有)。

## 2. 数字集合比对 — **PASS(0 缺失 / 0 多余)**

方法:剥离代码块后,`grep -oE '[0-9][0-9,.]*[0-9]|[0-9]' | sort -u` 逐 token 比对(comm 两侧)。

```
zh numbers: 59, en numbers: 59
--- missing in en: (空)
--- extra in en:   (空)
```

无需单位制豁免。重点数字均两侧同现:**79**(feature)、**14**(频道门)、**12**(crate)、**9**(显式 default 行)、**70/8/26/23/17/50** 等全部在集合内且相等。

## 3. 源码引用集合比对 — **PASS(diff 为空)**

方法:`grep -oE '(crates|octoscode|herdr)/[A-Za-z0-9_./-]+(:[0-9]+(-[0-9]+)?)?' | sort -u` 后 diff。

```
zh refs: 20, en refs: 20
REF DIFF EMPTY
```

含 `crates/octos-agent/Cargo.toml:117-131`、`crates/octos-cli/src/commands/mod.rs:398-399` 等,两侧逐条一致。

## 4. 固定标签同位 — **PASS**

| 标签 | zh | en | 同位 |
|---|---|---|---|
| Positioning(`> **定位**` / `> **Positioning**`) | :3 | :3 | ✅ |
| Version note(`### 版本演化说明` / `### Version note`) | :216 | :216 | ✅ |

两侧首部定位块与尾部版本说明逐段对齐(版本说明同含 `9c157101` 完整 hash、79/12/14/26 四数与 v1 三类更新叙述)。

## 5. 表行数逐一对照 — **PASS**

| 表 | zh | en | 判定 |
|---|---|---|---|
| D.1 主表(表头 1 + feature 行 **79**) | 80 行 | 80 行 | ✅ 79 feature 行相等 |
| D.3 频道门表(表头 1 + 门行 **14**) | 15 行 | 15 行 | ✅ 14 门行相等 |
| D.1 中 default=yes 行 | 10 | 10 | ✅ |
| D.4 default 链 | 无表(散文) | 无表(散文) | ✅ 同构 |
| D.5 mermaid `-->` 边 | 6 | 6 | ✅(附加核对) |
| 全文件 `^\|` 行 | 97 | 97 | ✅ |

D.1 每行 `| crate | feature | deps | what | default | source |` 六列,两侧一致;default=yes=10 与正文「9 条显式 default 行中 octos-agent 一条非空」自洽。

## 6. mdbook build — **PASS**

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

构建正常完成,HTML 写出,无任何 WARN/ERROR。

---

## B 车道上报核对(注记,不修改)

B 车道上报内容属实,且已被主仓修复:

- `a93bc73`(v2 重写)时的中文版 `:11` 确为「交叉点在 **D.7** 说明」——指错节,交叉点实为 D.6。
- 英文版 `9296acc` 按正确节写:「their meeting point is discussed in **D.6**」。
- 当前 wt 基线下,中文 `:11` 已由主仓 commit **`75fa2c0`**(「appendix D: 第 11 行交叉引用 D.7→D.6(appendixd-en 上报,外环核实)」)改为 D.6,与英文一致。两侧现均无 D.7 误引(D.7 仅作为节标题出现)。

**结论:该差异已闭环,本次两文件 :11 均为 D.6,无遗留动作。**

## 总判定

| # | 项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | PASS |
| 2 | 数字集合 0/0 | PASS |
| 3 | 引用集合 diff 空 | PASS |
| 4 | 固定标签同位 | PASS |
| 5 | 表行数 79/14/default 链 | PASS |
| 6 | mdbook 零警告 | PASS |

**PASS——英文版附录 D 可定稿。**
