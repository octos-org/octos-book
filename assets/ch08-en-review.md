# ch08-en-review —— 英文版 C2 读校报告

- 对象:`book-en/src/part2/ch08.md`(基线 60a68cf,C1 ch08-en-check 6/6 PASS 于 5bda2ad 归档)
- 读校人:peer ch08-en-review(lane strong)
- 日期:2026-09-03
- 性质:英文去味 + 母语度/术语 + 技术读校;不改事实/数字/引用/mermaid/代码块
- 结论:**通过(0 必修)**,`ch08.md` 零改动;唯一产出即本报告

## 0. 基线复核

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch08-context-management.md book-en/src/part2/ch08.md
refs: 86 (equal sets: yes)
en words: 4223, bold 12, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
(exit 0)
```

与 C1 报告逐字一致,基线未被污染。因零改动,复跑 verify-en(上)仅为留档;`mdbook build` 按"改后必须复跑"条款,零改动不触发。

## 1. 禁用词 / 翻译腔逐条记录

命令口径:trilingual-collab-en.md 全表 grep(banned 22 词、hedging 10 词、filler 8 短语、顿号/全角标点/CJK)。

| 检查项 | 命中 | 判定 |
|---|---|---|
| banned outright(delve/foster/leverage/utilize/facilitate/empower/streamline/robust/seamless/cutting-edge/paradigm shift/game changer/tapestry/realm/pivotal/multifaceted/meticulous/transformative/elevate/embark/ever-evolving) | 0 | ✅ |
| hedging/filler(really/just/literally/genuinely/honestly/simply/actually/truly/fundamentally/importantly/crucially;it's worth noting/at the end of the day/when it comes to/at its core/in today's world/the reality is/in order to/let's dive in) | 0 | ✅ |
| 顿号(、)/全角冒号/全角逗号/全角句号/CJK 字符(perl `\x{4e00}-\x{9fff}` + 全角区段扫描) | 0 | ✅ |
| 「双环」→ dual loop | 本章无此概念出现,grep dual/double loop 0 处,与中文版一致(章内无「双环」;Part IV 标题处用 Dual Loop 与全书一致) | ✅ |
| colon reveal("The best part: it learns" 式) | 疑似 6 处冒号(:13 :24 :49 :135 :180 及 :176 句内)逐一复核::13/:24 为引出代码块的标签用法(冒号后即 fenced code),:49/:135/:180 为引出表格/列表的标签用法,:176 句内冒号接具体事实句 — 均属"lists, labels, quotes"许可类,无 reveal 悬念句 | ✅ |
| hedging 前缀(maybe/perhaps/arguably/it seems/we believe 类) | 0 | ✅ |
| recap ending / fake-profound kicker | 8.8 为编号回顾章(中文版同构「本章回顾」,结构性对应,非 AI 式 recap 冗余);Version note 收尾为基线 hash + 文件行数清单,无 mic-drop 隐喻 | ✅ |
| em dash | 0(verify-en 计数一致) | ✅ |
| bold | 12 处,≤15 上限内,集中在 recap 条目引导词与 :71 关键性质(not cleaned by compaction),无"撒粉" | ✅ |
| 二元对仗("It's not X. It's Y.") | 逐处复核 :188 "It is not long-term memory; that belongs to…" 与 :168 "not a blanket rewrite of all input":均为驳斥真实立场的保留场景(中文版原文即含此对比语义),非装饰性对仗 | ✅ |

母语度抽样:句子均结论前置、主动语态;长句以分号串接多事实(如 :71 recall_index 段、:115 Tier 1 段)与全书技术散文节奏一致,无逐句直译腔。仅两处措辞属"可改可不改"、未达必修门槛,如实记录:**(a)** :67 "read 66 times over" 的 "times over" 稍显冗(直改 "read 66 times" 即可,但与中文「反复读取 66 次」的"反复"语气对应,保留亦通);**(b)** :196 因果句以引号短语 "one interface, distinct pressure models" 收尾为 fragment,系刻意的口诀式引用,中文版同位句式(「一个接口,不同的压力模型」)亦如此。两处均不动。

## 2. 母语度与术语一致(glossary 11 新术语)

60a68cf 增补的 11 条 ch08 术语(glossary :89-100)与正文逐一比对:

| glossary 术语 | 正文形态 | 出现 | 一致 |
|---|---|---|---|
| tiered compaction surface | the tiered compaction surface / Tier 1/2/3 | 7 处 | ✅ |
| working-set pinning | working-set pinning(:239);机制描述 :115 "working set … is pinned" | 1+1 | ✅ |
| rematerialization | :65 小节标题 "rematerialization after compaction"、Positioning :3 "recall rematerialization" | 2 | ✅ |
| budget-aware read | budget-aware reads(:67 未单列,:83 小节标题,:239 recap) | 3 | ✅ |
| read de-duplication | :239 recap 术语形态;:115 机制句用 "duplicate reads … keep only the newest entry" 叙述展开 | 1+1 | ✅ |
| tool result placeholder | ToolResultPlaceholder(代码标识符原样)+ placeholders | 10 | ✅ |
| extractive summary | extractive summary/summarizer | 7 | ✅ |
| fidelity grades | fidelity / four fidelity grades | 6 | ✅ |
| context compaction | Context Compaction(:9 标题、Positioning) | 与章名一致 | ✅ |
| prompt layer assembly | prompt layer(:3 Positioning 用 assembly;:150-154 展开) | 5 | ✅ |
| steering injection | steering(:158 节,:162 展开注入机制) | 6 | ✅ |

同义骑墙检查:全章未出现 second-tier/layered compaction 等替代译法竞争;compaction 全篇单一术语;recall/recall_memory 边界段(:75-81)两工具名零混淆。

## 3. 技术读校

- **mermaid 标签**:2 块均纯英文。图 8-1(:87-99)节点/边标签与中文版逐点对应(Estimate total tokens/total > window x 0.67?/Tier 1 local cleanup/recall(tool_call_id) fetch original bytes from ledger 等),18 节点 21 边(节点 id 集合 diff 为空系 C1 已证,本次复核标签译文自然、`<br/>` 断行完好);图 8-2(:208-221)contract-gated 流程 H→T1→T2→T3→{R,S,A}→P→V→G 分支与中文 :210-221 语义一致,"required passing?"→terminal success allowed/blocked 对应「required 通过?→允许/阻止」。
- **数字**:抽查关键数字与中文版同值同位——200K/十几次(:5)、0.8/1.2/67%/128K/85K(:20)、MIN_RECENT=6(:43)、200:1/40%/100 chars(:47/:59)、66 次(:67)、~16 条/20KB(:71)、560 处(:73)、1,271 行(:107/:261)、5 turns/8KB/last 5 files(:115)、10 turns/`clear_tool_uses_20250919`(:112/:119)、20-40%(:125)、3 次 latch(:144)、64KB(:154)、buffer 16(:160)、1,932/4,003 行(:261)。集合级相等已由 C1 双口径(104/104、166/166)证明,本次为语义级抽查,无换算味(无万↔thousand 改写,数字原样搬运)。
- **章号**:跨章引用 9 处(行 3,77,168,176,188,202,206)↔ 9 处,Chapter 5/4/7/5/4/9+12/3 与中文第 5/4/7/5/4/9+12/3 章逐处对应;SUMMARY.md 中 ch08 挂 Part II 第 8 章,章标题 "Context Management" 与书页目录一致(副题 Working Within… vs 章首 Making an Agent Work… 属章首 H1 全称,与中文版「让 Agent 在有限窗口中高效工作」同构,非错位)。
- **小节编号**:8.1-8.8 及 8.1.1-8.1.6/8.2.1/8.7.1-8.7.5 逐节同构(标题数相等系 verify-en 硬项)。

## 4. 结论

**通过(0 必修)**。外环范式五项(dual loop/顿号/colon reveal/hedging 前缀/recap ending)全部零命中;glossary 11 术语一致;mermaid 标签、数字、章号无问题;:67 与 :196 两处可改可不改的措辞按最小有效编辑原则不动。`book-en/src/part2/ch08.md` 保持 60a68cf 定稿态(md5 与采回基线一致),本报告为唯一产出。

## 附:复验输出

零改动,无需复跑;基线 verify-en 输出见第 0 节(0 FAIL / 0 WARN,refs 86 相等)。
