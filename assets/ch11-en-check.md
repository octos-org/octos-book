# ch11 英文版机械校验报告(ch11-en-check)

- 校验对象:`chapters/ch11-message-bus.md`(492 行)↔ `book-en/src/part3/ch11.md`(487 行)
- 基线:主仓 main,前置 commit `d1202c8`(ch11-en 定稿);本 worktree 未 commit
- 日期:2026-09-03;只做机械校验,不做译评

## 1. verify-en.sh — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch11-message-bus.md book-en/src/part3/ch11.md
refs: 64 (equal sets: yes)
en words: 4349, bold 7, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

0 FAIL 为过 → PASS。

## 2. 数字集合比对 — PASS

方法:剔除代码围栏内内容 → 豁免 `U+XXXX`(两侧均 0 处,无需豁免)→ 归一化千分位逗号(如 40,937→40937)→ 提取 `[0-9]+(\.[0-9]+)?` → `sort -u` → `comm` 双向比对。

```
zh unique numbers: 155, en unique numbers: 155
--- only in zh (missing in en) ---  (空)
--- only in en (extra) ---         (空)
MISSING=0 EXTRA=0
```

缺失/多余 = 0/0。千分位逗号归一不掩盖任何差异(英文侧 40,937 / 18,207 / 3,417 与中文侧同为千分位形态);小数点、行号范围(34-82、2400-3100、2441-2460 等)均在集合内一致。

## 3. 源码引用集合比对 — PASS

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <side> | sort -u
zh refs: 62, en refs: 62
$ diff /tmp/rz.txt /tmp/re.txt   → 无输出,REFSETS-EQUAL
```

62↔62,diff 为空。含 `crates/octos-bus/src/coalesce.rs:34-82`、`crates/octos-bus/src/session.rs:2329`、`crates/octos-cli/src/api/ui_protocol_tests.rs` 等全路径行号引用。

## 4. 固定标签 — PASS

| 标签 | 中文 | 英文 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ 同行 |
| `> ### 工程决策侧栏:…` ↔ `> ### Engineering decision:…` | :400 | :396 | 1↔1 | ✅(delta −4,见注) |
| `## 延伸阅读` ↔ `## Further reading` | :470 | :466 | 1↔1 | ✅(delta −4) |
| `## 思考题` ↔ `## Exercises` | :476 | :472 | 1↔1 | ✅(delta −4) |
| `## 版本演化说明`(inline `> **版本演化说明**`)↔ `## Version note`(inline `> **Version note**`) | :483(inline);`> ###` 详版随行 | :479(inline) | 1↔1 | ✅(delta −4) |

- 行号漂移成因(已定位):`## 11.4` 两侧同为 :278,自 `### 11.4.1` 起 ZH :344 → EN :341,至章尾恒为 −4。为 `## 11.4` 引导句的英文译法比中文源稿短 4 行所致(中文「……理解它如何在安全性和可读性之间取得平衡:」一段在英文侧压缩换行),纯行数差,标题序列 26↔26 逐一同位(见 §4.1),无内容错位。
- §4.1 标题全对照:26 个标题(`#` 章题、11.1–11.7 及全部子节)ZH/EN 同序同位,:1–:278 段 delta 全 0,:344 段起统一 −4。
- `see Chapter N` ↔ 「详见第 N 章」:各 1 处,同在 :124(UTF-8 边界句,均指向第 2 章),位置与指向一致。
- 章节引用多重集:ZH `第 11 章/第 2 章/第 5 章` 各 1 ↔ EN `Chapter 11/Chapter 2/Chapter 5` 各 1,完全一致。

## 5. mermaid 对照 — PASS

```
$ grep -c '^```mermaid' …/ch11-message-bus.md …/part3/ch11.md
chapters/ch11-message-bus.md:3
book-en/src/part3/ch11.md:3
```

| 块 | 类型 | ZH 节点/边 | EN 节点/边 |
|---|---|---|---|
| B1 thread-bound streaming | sequenceDiagram | participants 4,消息边(`->>`)4 | 4 / 4 |
| B2 5 级切割策略 | flowchart TD | 节点 10,边(`-->`)10 | 10 / 10 |
| B3 durable commit | flowchart TD | 节点 7,边 6(含 fail/ok 分支) | 7 / 6 |

节点/边数逐块相等;标签本地化(「长消息」→"Long message"、"找到"→"found")后剥离引号内容做结构 diff 为空(MERMAID-STRUCTURE-EQUAL),分支拓扑一致。

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
INFO Book building has started / INFO Running the html backend / INFO HTML book written to …/book-en/book
```

WARN/ERROR 计数 = 0,构建成功。

## 总判定

| 项 | 结果 |
|---|---|
| 1. verify-en.sh | PASS |
| 2. 数字集合 | PASS(0/0) |
| 3. 源码引用集合 | PASS(diff 空) |
| 4. 固定标签 | PASS(−4 行漂移已定位,纯译句长度差) |
| 5. mermaid | PASS(3↔3,节点/边逐块相等) |
| 6. mdbook build | PASS(0 WARN/ERROR) |

**总判定:PASS,可进 C2。**
