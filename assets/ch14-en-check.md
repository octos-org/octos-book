# ch14 英文版机械校验报告(ch14-en-check)

- 校验对象:`chapters/ch14-runtime-modes.md`(372 行)↔ `book-en/src/part3/ch14.md`(372 行)
- 基线:主仓 main(前置 commit `f08282d`,ch14-en 定稿);本 worktree(隔离 wt)未 commit
- 日期:2026-09-03;只做机械校验,不做译评
- 预告 WARN:简报已声明 14.6.1 text 块中文散文标签必译为唯一 WARN,本报告第 1 项以 0 FAIL 为门,WARN 单列核实

## 1. verify-en.sh — PASS(0 FAIL;唯一 WARN 确认在 14.6.1)

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch14-runtime-modes.md book-en/src/part3/ch14.md
WARN: code block content differs (mermaid and comments excluded)
refs: 61 (equal sets: yes)
en words: 4563, bold 7, em dash 2
RESULT: 0 FAIL(s), 1 WARN(s)
EXIT=0
```

0 FAIL 为门 → PASS。

**WARN 定位核实**:两侧全章唯一的 ```` ```text ```` 块均在 **:264**(开)–:266(闭),正落在 §14.6.1(### 标题 :252 至 §14.6.2 :290 之间)——即简报预告的那一处,无第二处 text 块、无其他 WARN 来源。该块内容:

- ZH :264–266:`显式 CLI flag  >  env var  >  config.json \`cli.<cmd>\`  >  built-in default`
- EN :264–266:`explicit CLI flag  >  env var  >  config.json \`cli.<cmd>\`  >  built-in default`

差异仅为首标签「显式」→ "explicit"(散文标签已译),属已知 WARN 类型;链上其余 token(结构名/文件名)两侧一致。

## 2. 数字集合比对 — PASS(0/0,无豁免项)

方法:`grep -o -E '[0-9][0-9,._]*[0-9]|[0-9]'` → 剥离千分位逗号/下划线 → `sort -u` → `comm` 双向比对。

```
zh unique: 151, en unique: 151
missing in en (zh-only): (空)
extra in en (en-only):   (空)
```

- 缺失/多余 = **0/0** → PASS。
- 豁免项注明:**单位制等值 0 对**(中文侧无「万」字,不存在 4.5万↔45,000 类形态差);**标点粘连归一**(千分位逗号剥离)已施加;**`U+XXXX` 转义两侧均 0 处**、全角数字 perl 字符模式统计两侧均 0 处——两类豁免均未触发。
- 关键数字抽查:11,944(:3/:243 两侧同行)、67 端点、59 工具、28 子命令、543 行 config_layer 等集合内一价对应。

## 3. 源码引用集合比对 — PASS(去重集与多重集双等)

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <side> | sort -u | comm 双向
去重集:zh 58 ↔ en 58,diff 为空
多重集:zh 78 ↔ en 78,diff 为空
```

含 `crates/octos-cli/src/main.rs`、`crates/octos-cli/src/config.rs`、`crates/octos-cli/src/config_layer.rs:5-8/:40`、`crates/octos-agent/src/mcp_server.rs:66`、`Cargo.toml` 等全路径引用,逐条相等。

## 4. 固定标签 — PASS(五标签同位,章引用多重集全等)

| 标签 | 中文 | 英文 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ 同行 |
| `> ### 工程决策侧栏:` ↔ `> ### Engineering decision:` | :325, :331 | :325, :331 | 2↔2 | ✅ 逐行同行 |
| `## 延伸阅读` ↔ `## Further reading` | :355 | :355 | 1↔1 | ✅ 同行 |
| `## 思考题` ↔ `## Exercises` | :362 | :362 | 1↔1 | ✅ 同行 |
| `> **版本演化说明**` ↔ `> **Version note**` | :371 | :371 | 1↔1 | ✅ 同行 |

- 全章标题行 25↔25,**行号漂移 0**(`paste` 逐行比对全部同行);两侧总行数 372↔372,零位移。
- `see Chapter N` ↔ 「详见第 N 章」:`:32`(see Chapter 18 ↔ 详见第 18 章)等处行位对应。
- 章节引用多重集两侧全等:ZH/EN 均为 `第1/Chapter 1×2、3×2、5×3、6×1、9×1、10×1、11×1、13×1、14×1、17×1、18×3`(计数逐项相同,合计 17↔17)。

## 5. mermaid 对照 — PASS(5 块同位,计数逐块相等,结构差异仅 id 本地化)

```
$ grep -c '^```mermaid' → 5 ↔ 5,块起始行两侧相同(:48 :127 :181 :224 :270)
```

| 块 | 类型 | ZH 箭头行 | EN 箭头行 | 结构化 diff |
|---|---|---|---|---|
| B1 CLI 入口→五运行面(:49–71) | flowchart LR | 9 | 9 | 仅 id 本地化(见下) |
| B2 serve 启动装配(:128–138) | flowchart TD | 10 | 10 | 空 |
| B3 门禁判定(:182–194) | flowchart TD | 12 | 12 | 空 |
| B4 mcp-serve 边界(:225–230) | flowchart LR | 5 | 5 | 空 |
| B5 热加载决策(:271–285) | flowchart TD | 13 | 13 | 空 |

- 结构化 diff(剥离 `[]`/`{}`/`()` 标签与引号串后逐行比较):B2–B5 **完全一致**;B1 唯一差异为 subgraph/节点 id 本地化——`subgraph CLI入口`→`CLI_ENTRY`、`五种运行面`→`SURFACES`、`共享装配`→`SHARED_ASSEMBLY`(拓扑、分支 `CTX-->|yes|/|no|` 类边数与方向不变)。
- 节点/边数逐块相等;分支拓扑一致 → PASS。

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

WARN/ERROR 计数 **0**(日志仅 INFO);`book-en/book/part3/ch14.html` 正常写出(72,998 bytes)→ PASS。

## 总判定

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | **PASS**(0 FAIL / 1 WARN;WARN 即预告的 14.6.1 text 块 :264,已核实位置与类型) |
| 2 | 数字集合 | **PASS**(0/0,无豁免项触发) |
| 3 | 源码引用集合 | **PASS**(58↔58 去重 / 78↔78 多重集,diff 双空) |
| 4 | 固定标签 | **PASS**(五标签同行同数,标题 0 漂移,章引用多重集全等) |
| 5 | mermaid | **PASS**(5 块同位,逐块计数相等,结构 diff 仅 B1 id 本地化) |
| 6 | mdbook build | **PASS**(WARN/ERROR = 0) |

**总判定:PASS(6/6,可进 C2)。** 唯一 WARN 为外环已知项(14.6.1 text 块中文散文标签,已译),不阻塞。
