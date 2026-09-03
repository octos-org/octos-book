# ch12 英文版机械校验报告(ch12-en-check)

- 校验对象:`chapters/ch12-concurrency.md`(279 行)↔ `book-en/src/part3/ch12.md`(277 行)
- 基线:主仓 main,前置 commit `3fdba70`(ch12-en 定稿);本 worktree 未 commit
- 日期:2026-09-03;只做机械校验,不做译评

## 1. verify-en.sh — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch12-concurrency.md book-en/src/part3/ch12.md
refs: 66 (equal sets: yes)
en words: 4323, bold 4, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

0 FAIL 为过 → PASS。

## 2. 数字集合比对 — PASS(豁免注明后 0/0)

方法:剔除代码围栏内内容 → `U+XXXX` 豁免(两侧均 0 处,无需豁免)→ 剥离千分位逗号(`tr -d ','`)→ 提取 `[0-9]+(\.[0-9]+)?` → `sort -u` → `comm` 双向比对。

```
原始集合:zh unique 153, en unique 154
  only in zh: 4.5        only in en: 000, 45
归一后(剥千分位逗号):zh 153 ↔ en 153
  MISSING=1 EXTRA=1 :  4.5 ↔ 45000
```

唯一出入为同一处单位制等值对:`:15` 中文「**4.5 万**行代码」↔ 英文「**45,000** lines of code」(「万」→「,000」必然产生的形态差,`000`/`45` 为 `45,000` 被逗号切分的碎片,同一来源)。按口径作单位制等值豁免。

- 豁免注明:单位制等值 1 对(4.5万 ↔ 45,000,:15);标点粘连归一(千分位逗号剥离)已施加;`U+XXXX` 豁免两侧 0 处。
- 豁免后缺失/多余 = **0/0** → PASS。其余数字(25154/45544、2959、9c157101 等)集合内逐一一价。

## 3. 源码引用集合比对 — PASS

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <side> | sort -u
zh refs: 65, en refs: 65
$ diff /tmp/zh_refs.txt /tmp/en_refs.txt  → 无输出,REFSETS-EQUAL
```

65↔65,diff 为空。含 `crates/octos-cli/src/autonomy/monitor_runtime.rs`、`crates/octos-agent/src/agent/execution.rs`、`crates/octos-cli/src/commands/gateway/gateway_runtime.rs` 等全路径引用。

## 4. 固定标签 — PASS

| 标签 | 中文 | 英文 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ 同行 |
| `> **工程决策:…**` ↔ `> **Engineering decision**:` | :81, :153 | :81, :153 | 2↔2 | ✅ 逐行同行 |
| `## 延伸阅读` ↔ `## Further reading` | :259 | :259 | 1↔1 | ✅ 同行 |
| `## 思考题` ↔ `## Exercises` | :267 | :267 | 1↔1 | ✅ 同行 |
| `## 版本演化说明` ↔ `## Version note` | :275 | :275(inline `> **Version note**` 版本说明在 :277) | 1↔1 | ✅ 同行 |

- 行号漂移:全章仅 2 行(delta −2),位于章尾版本说明段(:275 之后),英文 inline `> **Version note**` 段比中文 bullet 段长 1 行、思考题后空行差 1 行所致;:1–:275 区间两侧标题/标签全部同行,无内容错位。
- `see Chapter N` ↔ 「详见第 N 章」:表行 `:255`(see Chapter 16 ↔ 详见第 16 章)与正文 `:239`(is in Chapter 16/18 ↔ 详见第 16/18 章)、`:3` Positioning 段同位对应。
- 章节引用多重集:ZH `第 5 章×3 / 第 10 章×2 / 第 11 章×1 / 第 12 章×1 / 第 16 章×4 / 第 18 章×4` ↔ EN `Chapter 5×3 / Chapter 10×2 / Chapter 11×1 / Chapter 12×1 / Chapter 16×4 / Chapter 18×4`,计数全等;行位 :1–:263 全部同行,唯一例外 :277/:278 的 `Chapter 11↔第 11 章` delta +1 行(同一句,章尾段)。

## 5. mermaid 对照 — PASS

```
$ grep -c '^```mermaid' chapters/ch12-concurrency.md book-en/src/part3/ch12.md
3 ↔ 3
```

| 块 | 类型 | ZH subgraphs/节点定义/边行 | EN subgraphs/节点定义/边行 |
|---|---|---|---|
| B1 三层并发架构 | flowchart TB | 3 / 12 / 10 | 3 / 12 / 10 |
| B2 续跑管线 | sequenceDiagram | participants 4,箭头 6,Note 1 | 4 / 6 / 1 |
| B3 subagent↔peer 隐喻 | flowchart TB | 2 / 6 / 2 | 2 / 6 / 2 |

节点/边数逐块相等;剥离引号标签、箭头消息文本、participant 别名与 Note 文本后做结构 diff,仅 B2 Note 行标签本地化一处差异(「进程重启后:load_state 重放账本…」→"after process restart: load_state replays ledger…"),其余为空(MERMAID-STRUCTURE-EQUAL),分支拓扑一致。

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0        (grep EXIT=1,零匹配;日志仅 INFO,HTML 正常写入 book-en/book)
```

WARN/ERROR 计数 0 → PASS。

## 总判定

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | PASS(0 FAIL / 0 WARN) |
| 2 | 数字集合 | PASS(豁免注明后 0/0) |
| 3 | 源码引用集合 | PASS(65↔65,diff 空) |
| 4 | 固定标签 | PASS(五标签同位,章引用多重集全等) |
| 5 | mermaid | PASS(3 块计数逐块相等,结构 diff 空除标签) |
| 6 | mdbook build | PASS(WARN/ERROR = 0) |

**总判定:PASS(6/6,可进 C2)。**
