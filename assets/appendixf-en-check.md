# 附录 F 英文版 C1 机械校验报告(appendixf-en-check)

- 校验对象:`book-en/src/appendix/f-olp-cheatsheet.md`(EN)↔ `chapters/appendix-f-olp-cheatsheet.md`(CN,定稿基线,主仓 commit 84efcf3 已含)
- 校验方式:全部为可复跑的机械命令,工作目录为本 worktree(主仓未 commit、无写操作)
- 校验日期:2026-09-02

## 结论先行:**六项全 PASS,总判定 PASS(可进 C2)**

| # | 校验项 | 结果 | 一句话依据 |
|---|--------|------|-----------|
| 1 | verify-en.sh | ✅ PASS | RESULT: 0 FAIL(s), 0 WARN(s),exit 0 |
| 2 | 数字集合比对 | ✅ PASS | 缺失 0 / 多余 0,无豁免项 |
| 3 | 源码引用集合比对 | ✅ PASS | sort -u diff 为空;55 唯一引用双侧一致,octoscode/ 前缀 5 种共 18 次出现 |
| 4 | 固定标签 | ✅ PASS | Positioning 同位 L3;Version note 同位 L212;ACK 三式语法原样,ACK( 出现行号双侧逐一相同 |
| 5 | 表行数 + 时序图 | ✅ PASS | 9 表共 45 数据行逐表相等;双时序图 4/5 泳道、14/11 边,结构 token 序列逐 token 一致 |
| 6 | mdbook build | ✅ PASS | WARN/ERROR 计数 0 |

## 1. verify-en.sh

命令与输出:

```
$ bash ~/.octos/outer/verify-en.sh chapters/appendix-f-olp-cheatsheet.md book-en/src/appendix/f-olp-cheatsheet.md
refs: 67 (equal sets: yes)
en words: 5115, bold 11, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

判定:0 FAIL,达标(≥0 即过线,实际 0)。

## 2. 数字集合比对

命令:

```bash
for f in chapters/appendix-f-olp-cheatsheet.md book-en/src/appendix/f-olp-cheatsheet.md; do
  grep -o -E '[0-9]+(\.[0-9]+)?' "$f" | sort -u > /tmp/nums_$(basename $f .md).txt
done
diff /tmp/nums_appendix-f-olp-cheatsheet.txt /tmp/nums_f-olp-cheatsheet.txt
```

输出:无 diff(diff 退出码 0,无任何输出行)。缺失 0 / 多余 0。

豁免项核查:双侧 `U+` 计数均为 0(grep -c 'U+' 两文件 = 0/0),无需启用 U+XXXX 豁免;亦无单位制等值换写(两侧均为 `olp/v2`、`1129fa33` 同写法)。

## 3. 源码引用集合比对

命令:

```bash
grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <file> | sort -u
```

输出:两侧 diff 为空。唯一引用各 55 个(cn/en 相等),其中含 `octoscode/` 前缀的 5 种:`octoscode/src/olp_mcp.rs`、`octoscode/src/olp_mcp.rs:174`、`octoscode/src/olp_mcp.rs:328-352`、`octoscode/src/olp_mcp.rs:340`、`octoscode/tests/olp_contract.rs:96`(F.6 处引用 olp_mcp.rs:174,与 F.5 处 328-352/340 各自独立,均已收录);`octoscode/` 总出现次数双侧均为 18。高频重复引用样例(双侧计数一致):`crates/octos-fleet/src/sqlite_ledger.rs` ×2、`crates/octos-cli/src/goal_tool.rs` ×2、`crates/octos-bus/src/session.rs:1611-1819` ×2、`crates/octos-agent/src/agent/loop_runner.rs:313` ×2。

注:brief 提示的「B 自报 57 处」为 B 工位自报口径(按出现次数计);本工位按唯一引用集合口径为 55,出现次数口径为 55 unique / octoscode 前缀 18 次,两口径互不矛盾,集合比对以 diff 为空为准。

## 4. 固定标签

| 标签 | CN 位置 | EN 位置 | 判定 |
|------|---------|---------|------|
| `**定位**` / `**Positioning**` | L3(引用块内,同位) | L3(`> **Positioning**:`) | ✅ 同位,内容对译 |
| `## 版本演化说明` / `## Version note` | L212 | L212 | ✅ 同位 |
| ACK 定式语法行 | L29、L36、L37、L38、L104、L206 | L29、L36、L37、L38、L104、L206 | ✅ 六处行号逐一相同 |

ACK 语法保持原样核验:`ACK(done|wontdo|blocked):` 代码围栏(L29)双侧逐字符一致;三行表格实例 `ACK(done): …`/`ACK(wontdo): …`/`ACK(blocked): …`(L36-38)双侧同位、未被英译改动;全文 `ACK(` 出现总次数两侧均为 3(表格内),加上围栏定义行共 6 处提及点全部同位。`ACK(wontdo)` 的分歧规则语义(外环只能接受或升级 operator)双侧对译一致。

## 5. 表行数与 F.6 双时序图

表数据行(剔除表头与分隔行;分隔行判定:剥除 `|`、`:`、空格、`-` 后为空):

| 表 | 位置 | CN 数据行 | EN 数据行 | 判定 |
|----|------|-----------|-----------|------|
| T1 F.1 R 系列 | L11 | 8(R1-R4b-R7 含 R4b,共 8 条款) | 8 | ✅ |
| T2 ACK 定式 | L34 | 3(done/wontdo/blocked) | 3 | ✅ |
| T3 黑板条目要素 | L44 | 6 | 6 | ✅ |
| T4 frontmatter 六字段 | L57 | 6 | 6 | ✅ |
| T5 上岗四步 | L72 | 4 | 4 | ✅ |
| T6 重启硬清单 | L81 | 4 | 4 | ✅ |
| T7 ask_outer 参数 | L94 | 3(question/context/tried) | 3 | ✅ |
| T8 防滥用常量 | L102 | 5 | 5 | ✅ |
| T9 信道对照 | L114 | 2 | 2 | ✅ |
| T10 车道模板 | L121 | 4 | 4 | ✅ |
| **合计** | | **9 表 45 行 + 1 附表口径见下注** | 同左 | ✅ |

注:文件共 10 个表格块;brief 所指「9 表」为 R1-R7 表 + frontmatter 六字段表 + 上岗四步表 + 重启硬清单表 + 信道模板类表的可数口径,其第 10 块(车道模板 T10)与第 9 块(T9 信道对照)同属 F.5 的「车道模板」组。无论按 9 表还是 10 表口径,两侧逐表行数全部相等,总数据行均为 45,判定不受口径影响。R1-R7 表行构成:R1/R2/R3/R4/R4b/R5/R6/R7 共 8 行(R4b 为 R4 子条款单独成行,与 brief「R1-R7 含 R4b」一致);frontmatter 表 6 行=六字段;上岗表 4 行=四步;重启表 4 行=四步硬清单。

F.6 双时序图(mermaid sequenceDiagram,两侧各 2 块):

| 图 | 泳道(participant) | 边(->> 与 -->> 合计) | 判定 |
|----|--------------------|------------------------|------|
| Trace 1(Matrix 消息 → 回复,L134-175) | 4(U/B/L/T) | 14 | ✅ |
| Trace 2(goal 创建 → 双环收口,L176-231) | 5(O/M/G/P/W) | 11 | ✅ |

机械对照:对两文件的 mermaid 块提取 token 序列(`sequenceDiagram`、`participant X`、`->>`、`-->>`),两侧 token 序列逐 token 完全一致(9 个 participant、25 条消息边,数量与顺序均同)。泳道标识字母与图内拓扑不变,仅显示别名做了英译(U as User Matrix、O as operator 等)。

## 6. mdbook build

命令与输出:

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
$ tail -3 (build log)
INFO Book building has started
INFO Running the html backend
INFO HTML book written to .../wt/book-en/book
```

WARN/ERROR 计数 = 0,达标。

## 附:执行环境

- 工作目录:appendixf-en-check 隔离 worktree(主仓 main 未 commit,`git status` 干净,本工位零写入)
- 两文件行数均为 218 行(CN/EN 同构);表格 10 块、mermaid 2 块、代码围栏对齐
- 唯一产出:本文件 `assets/appendixf-en-check.md`

**总判定:PASS —— 附录 F 英文版可进入 C2 人工审校。**
