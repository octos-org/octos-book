# ch18-en-check — 英文版 C1 机械校验报告

- peer: ch18-en-check(lane cheap)
- 日期: 2026-09-03
- 对象: `chapters/ch18-goal-peer.md` ↔ `book-en/src/part3/ch18.md`
- 环境: 隔离 worktree(branch `peer/ch18-en-check`),两份文件与主仓 main 逐字节一致(md5 相同);ch18-en 定稿 commit `5352cdb` 在主仓已核实存在(en(G4): ch18 母语重写,part3,verify 0 FAIL,mdbook 零警告)。未做任何 commit。

## 总判定: PASS(6/6,可进 C2)

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh 结构/事实镜像 | PASS(0 FAIL / 0 WARN) |
| 2 | 数字集合比对 | PASS(0 缺 / 2 归一豁免,已注明) |
| 3 | 源码引用集合比对 | PASS(diff 为空) |
| 4 | 固定标签与交叉引用 | PASS(标签 3 处同位;章引用 multiset 全等) |
| 5 | mermaid 节点/边对照 | PASS(结构 1:1) |
| 6 | mdbook build 警告 | PASS(grep 计数 = 0) |

---

## 1. verify-en.sh — PASS

命令:
```
bash ~/.octos/outer/verify-en.sh chapters/ch18-goal-peer.md book-en/src/part3/ch18.md
```
输出(完整):
```
refs: 36 (equal sets: yes)
en words: 5019, bold 10, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
```
退出码 0。0 FAIL 即过;附带指标也干净:bold 10(≤15)、em dash 0(≤2)、代码块内容 md5 相同(mermaid/注释除外)、表行数相同、EN 正文中 CJK 字符 0。

## 2. 数字集合比对 — PASS(0 缺失 / 0 实质多余;2 处归一豁免)

命令(两侧对称,数字从代码围栏外提取,U+XXXX 先豁免,逗号分组归一后比较):
```
strip(){ awk '/^```/{c=!c;next} !c' "$1"; }
strip <file> | sed -E 's/U\+[0-9A-Fa-f]{4,6}//g' \
  | grep -oE '[0-9][0-9,]*\.?[0-9]*' | tr -d ',' | sort -u > /tmp/n_<side>.txt
comm -23 /tmp/n_zh.txt /tmp/n_en.txt   # zh 有 en 无(缺失)
comm -13 /tmp/n_zh.txt /tmp/n_en.txt   # en 有 zh 无(多余)
```
输出:
- 缺失(zh→en):空
- 多余(en-only):`16`、`1945` 两条

豁免说明(2/2 均为英文句点粘连伪差,非内容数字):英文句号为 `.`,紧跟句尾数字被正则带出——`...stays in Chapter 16. With Chapter 16...`(zh:「留在第 16 章。」)与 `...from #1967 and #1945. All line numbers...`(zh:「…#1945。」)。两数在 zh 侧均以别的形态存在(「第 16 章」/`#1945`),en 未增删任何事实数字。U+XXXX 本两侧均为 0 处,豁免规则未实际触发。

重点口径核对(52,445 / 5,969):
- zh L3/L11/L17-18 与 en L3/L11 及对应表行完全一致:goal 线 9 文件 52,445 行、peer 线 9 文件 5,969 行;`sqlite_ledger.rs` 6,360、`goal_tool.rs` 3,028、`peers/mod.rs` 3,186 等逐数相同。
- 「体量差约九倍」↔ "a size gap of roughly nine times" —— 已采用九倍口径(与 memory 中旧疑点 ch18 中文版的「八倍/47,645」问题无关;本对照两版均为 52,445/5,969/九倍,无旧基线残留)。

数字侧集合规模:zh 204 项 / en 206 项(差即上述 2 条句点粘连)。

## 3. 源码引用集合比对 — PASS

命令:
```
grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <file> | sort -u > /tmp/ref_<side>.txt
diff /tmp/ref_zh.txt /tmp/ref_en.txt
```
输出:diff 为空(两侧各 35 个唯一引用,含 `:line` 与 `:line-line` 后缀形态,逐一相同)。

注:B 自报 "36 refs" 是 verify-en.sh 的计数口径(其正则含 `octoscode|herdr` 前缀且不计 `.rs|toml` 后缀约束),与本项目 35 不矛盾;两口径下 zh/en 集合均相等。

## 4. 固定标签与交叉引用 — PASS

四种随文固定标签(逐行同位):
| 标签 | zh 行 | en 行 | en 文本 |
|---|---|---|---|
| 定位 ↔ Positioning | 3 | 3 | `> **Positioning**:` |
| 工程决策:peer 是进程,subagent 是线程 ↔ Engineering decision | 184 | 184 | `> **Engineering decision: peers are processes, subagents are threads**` |
| 版本演化说明 ↔ Version note | 222 | 222 | `> **Version note**:` |

verify-en.sh 的 appendix 外强制锚(`> **Positioning**`、`> **Version note**`)均命中。本文无第五章固定标签变体(无 `**Engineering decision:**` 之外的第五种);若按五标签口径,未出现的标签两侧同为 0,同位成立。

标题骨架(`^#{1,4}`)13 节全部同行号(1/5/22/40/63/77/111/138/144/174/187/205/212),章节号 18.1–18.10 + 延伸阅读/Exercises 一一对应。

章引用 multiset(代码围栏外):
```
zh: 第 5 章×6, 第 9 章×1, 第 12 章×6, 第 16 章×9, 第 18 章×2, 第 19 章×1, 第 20 章×3
en: Chapter 5×6, Chapter 9×1, Chapter 12×6, Chapter 16×9, Chapter 18×2, Chapter 19×1, Chapter 20×3
```
两组完全相等。本文无 `see Chapter N`/「详见第 N 章」句式(两侧均 0),该规则空满足;实际交叉引用以「第 N 章 ↔ Chapter N」形态全数对齐。

## 5. mermaid 节点/边对照 — PASS

两侧各 2 个 mermaid 块,结构 1:1(仅文案中英互译):
- sequenceDiagram:5 个 participant(H/M/S/C/P)+ 10 条消息 + 1 个 loop,消息序列逐一对应(peer_handoff → persist → staged → open session → boot read-back → loop turn → result.md → closed → peer_gather/goal_get)。
- flowchart LR:3 个 subgraph(MASTER/PEERDIR/LEDGER)+ 6 个节点(GG、RM、GF、LF、ES、PEER)+ 4 条边语句(通道1/2/3 各 `PEER→节点→GG` 共 6 段箭头,加 `GF -. boot 读回 .-> PEER`),边标签 Channel 1/2/3 ↔ 通道1/2/3 对应。

节点/边数两侧相等;文本差异仅为译文(含 `<br/>`、`&lt;slug&gt;` 等转义原样保留)。

## 6. mdbook build — PASS

命令:
```
cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
```
输出:`0`
(构建原始输出仅 `INFO Book building has started` / `INFO Running the html backend` / `INFO HTML book written to .../book-en/book`,无任何 WARN/ERROR。)

---

## 结论

六项全 PASS,总判定 **PASS** —— ch18 英文版机械校验通过,可进 C2(母语者评审)。本报告为唯一产出文件;校验过程未改动两份被检文件,未产生其他产物,未 commit。
