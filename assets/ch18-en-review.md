# ch18 英文版 C2 读校报告(ch18-en-review,lane strong)

- 对象:`book-en/src/part3/ch18.md`(223 行);基线 main @ 3b18dbd(ch18-en 5352cdb 交付,C1 ch18-en-check 6/6 PASS,dacb8b6 归档)
- 日期:2026-09-03;范围:英文去味 + 母语度/术语一致 + 技术读校;不改事实/数字/引用/mermaid/代码块
- 产出:本报告 + `book-en/src/part3/ch18.md` 措辞微修 11 行(git diff 11 insertions/11 deletions,13 处替换中 2 处同行合并;零事实/引用/数字/mermaid/代码块变更,行数 223 不变)
- 复验:verify-en.sh **0 FAIL / 0 WARN**(refs 36 相等,en words 5023,bold 10,em dash 0);`cd book-en && mdbook build` grep 计数 **0**(无 WARN/ERROR)

## 1. 外环待修项范式逐条核查

| 待修范式 | 本章命中 | 判定 |
|---|---|---|
| 「双环」dual loop | 0 处(dual loop 属 Part4 术语,本章用 outer loop (Chapter 20) 指称,与 glossary 一致) | ✅ 无需修 |
| 顿号(、)残留 | `grep -n '、'` → 0;CJK 字符全文 0(verify-en 同口径) | ✅ 无需修 |
| colon reveal | 全章冒号为枚举/标签/引用合规用法(:3 Positioning 标签+字段枚举、:34 判据句、:67 四档枚举、:199 列表引导);"states this tradeoff plainly: do not kill…"/"gives the reason: a wrap-up is…" 为引述-展开式,非悬念句 | ✅ 合规 |
| hedging 前缀 | arguably/perhaps/maybe/in a sense/it seems/somewhat 全 0;唯一 really 见 §2 已修 | ✅(修 1 处后) |
| recap ending | `## 18.10 Boundaries and Recap` + "Chapter recap:" 为编号要点清单(7 条),无 "In this chapter we learned…" 回声段;:201-203 结尾段为 concrete 的 WAL 独占语义陈述,非 mic-drop | ✅ 合规 |

## 2. 禁用词/翻译腔逐条记录

| 行 | 原文 | 问题类型 | 处置 |
|---|---|---|---|
| :7 | "history that rots**, one** compaction pass can lose…" | 逗号粘连两独立句(zh 分号直译为逗号) | **已修** → 分号 |
| :20 | "escalations**, the two ledgers do not** substitute for each other" | 同上逗号粘连;"the two ledgers do not substitute for each other" 生硬 | **已修** → "escalations; neither ledger substitutes for the other" |
| :34 | "embeds a budget rule**, when** the goal is active…" | 逗号粘连:规则判据被并成从句 | **已修** → "embeds a budget rule: when…" |
| :34 | "**compresses** busy_timeout to 1 second" | compress+timeout 搭配错(时间值不压缩);zh「压到」直译 | **已修** → "shortens busy_timeout to 1 second" |
| :38 | "overshoot**, operators** must…" | 逗号粘连 | **已修** → 分号 |
| :38 | "budget limited **is not stopped**" | 系表结构不通:两状态名比较应为 does not mean;zh「budget limited 不是 stopped」直译 | **已修** → "budget limited does not mean stopped" |
| :75 | "**Assembling this section's states**, the goal state machine…" | 垂悬分词(状态机不是 assembling 的施事);zh「把本节的状态拼起来」直译 | **已修** → "Taken together, this section's states show the goal state machine running at two levels." |
| :75 | "reopen admits exactly three **entrances**: blocked, paused, budget_limited" | entrances 用于状态入口是中式搭配(门/入口直译);这些是来源状态非入口 | **已修** → "three source states" |
| :105 | "This division of responsibility is deliberate**, the** server does not know…" | 逗号粘连(zh:「这层职责切分是刻意的:」有冒号,en 丢了) | **已修** → 补冒号 |
| :108 | `"not completed" is stated in **three plain words**` | 「未完成三个字明示」直译——中文字数修辞在英文无对应(three 只对中文"三个字"成立) | **已修** → "stated in plain words" |
| :132 | "must be written last**, the** peer "exists" only after it lands" | 逗号粘连 | **已修** → 分号 |
| :142 | "the clone inherits **neither** the source repository's LOCAL config" | neither 单配错(neither 需 or-nor 双项或复数否定);zh「也不继承」直译 | **已修** → "inherits none of" |
| :178 | "the comment … **documents itself**" | 「注释自证」直译,documents itself 非英语惯用 | **已修** → "says as much" |
| :197 | "Worktree **is really** `git clone --no-hardlinks`" | really 在禁用词表(hedging);且「实为」直译语序突兀 | **已修** → "Worktree is `git clone --no-hardlinks` under the hood" |

保留项(逐条核过,非必改):

- :11 "the peer's entire protocol is **just** a dozen small files" — just 为实义「仅仅」,对比 goal 线体量,非 hedging 填充,保留。
- :13/:75 "the holder is **not** a standalone daemon **but** the keeper role" / "is not in the ledger's state set" — 二元对比规则豁免:被驳立场(独立 daemon / ledger 状态)真实存在,真值对比,保留。
- :34 "Two methods deserve a closer look" — 全书同型句式(ch02 "deserves a look" C2 保留判例),保留。
- :57/:109 "one `goal_get` call **settles the accounts**" / "settles accounts directly" — 收账的会计隐喻,与 ch16 "settle the budget"/"settlement" 同语域;且 :30 `settle_task_status` 技术名在场,术语自洽,保留。
- :67 "The priority ranks come in **four grades**" — grades 表档位为标准用法(与 priority grades 常见搭配),保留。
- :99/:103-109 六段 "Client opens" / "**Boot read-back**" 等列表项 — 标题式短语省冠词,与 zh 六阶段同名条目一一对应,列签形态,保留。
- :73 "The fleet_wake doc states **plainly**" — plainly 副词非禁用词表成员,且为引述定位(:34/:38/:105 同型三处),全文 3 处未超量,保留。
- :170 "One trap found in engineering practice **must go into the docs**" — 「必须写进文档」直译略硬,但语义准确、主语明确,未构成必改级问题,保留。
- :75 "At the ledger level:" / "At the runtime level:" — 平行标签式冒号,合规。

## 3. 母语度与术语一致性

- **GoalLedger 六态**::75 逐一列出 active, complete, blocked, budget_limited, paused, cleared,加 `archived` 不在集合内的辨析 — 与 zh 底稿及 sqlite_ledger.rs:39 注释口径一致,术语零漂移。✅
- **keeper**:11 处,全部小写普通名词用例(keeper role / keeper-gated / the keeper does not need),与 ch16/glossary 一致,无 Keeper 大小写漂移。✅
- **brief**:14 处,语义统一为任务契约(:178 "a brief is a task contract, not blob storage" 点题),brief.md 文件名/`PEER_HANDOFF_BRIEF_MAX_BYTES` 技术名原样。✅
- **handoff**:10 处(peer_handoff 工具名原样;动词/名词混用自然)。✅
- **staging**:7 处(:stage_peer 函数名原样;staging/staged 派生一致)。✅
- **return channel**:5 处,全部三通道口径(peer_findings/ledger_findings/open_escalations),与 :57/:167/:171 汇聚点叙事一致。✅
- **wrap-up turn**:GoalWrapUp/goal_wrap_up 技术名 + wrap-up turn 自然语言,:67 "a wrap-up is the last goal turn…not a privileged turn" 与 zh「不是特权轮」一致。✅
- **fence branch**:2 处(:142 checkout、:141 destroying the fence branch),peer/<slug> 分支名一致。✅
- 其余:blackboard 7、tombstone 3、lane(:172 lane key、cheap-lane verifier)均与 glossary/他章一致。全章无同义词轮换违规(agent/tool 等技术词未 paraphrase)。

## 4. 技术读校

- **mermaid 标签**:sequenceDiagram 5 participant + 11 消息 + 1 loop,与 zh 1:1(仅中英互译:宏观指令↔macro instruction、落盘↔persist、后台打开↔open in the background);flowchart 3 subgraph + 6 节点 + 4 边语句,Channel 1/2/3 ↔ 通道1/2/3,"(park 时写)"→"(written when parked)" 准确;`&lt;slug&gt;`/`<br/>` 转义两侧原样。✅
- **数字口径**:52,445×3 / 5,969×3 两侧同数同位(L3 定位、L11 正文、L17-18 表行);"roughly nine times"↔「约九倍」——九倍口径一致,无旧 47,645/八倍基线残留(memory 疑点已由中文版修订解决)。逐文件行数 3,028/6,360/3,186/3,277 等与 zh 及 facts 表一致。✅
- **章号**:Chapter 5×6 / 9×1 / 12×6 / 16×9 / 18×2 / 19×1 / 20×3,multiset 与 zh 全等(C1 已核,本次抽查 §5.10/§16.7/Chapter 19 TUI/Chapter 20 外环指向全部正确)。✅
- **行数不变**:223 行;git diff 11+/11−,全部为句内替换,无段落增删。

## 5. 中文版问题上报(超 C2 权限,只报不改)

无。本次对照未发现 zh 底稿事实/结构错误需要回改。

## 6. 结论

**通过(可定稿)**——13 处措辞问题已全部就地修复(见 §2),复验全绿:

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch18-goal-peer.md book-en/src/part3/ch18.md
refs: 36 (equal sets: yes)
en words: 5023, bold 10, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

修复模式归纳(供后续章节 lane 复用):本章翻译腔集中为三类——①逗号粘连(zh 分号/冒号映射丢失,6 处);②中文修辞直译失效("三个字明示"/"注释自证"/"实为"各 1 处);③搭配错(compress timeout / neither 单配 / entrances 入口 3 处)。其余部分为干净的母语技术散文。
