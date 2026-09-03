# ch12 英文版 C2 读校报告(ch12-en-review)

- 基线:`book-en/src/part3/ch12.md`(277 行,前置 `3fdba70` 交付态);对照 `chapters/ch12-concurrency.md`、`assets/glossary-en.md`、C1 报告 `assets/ch12-en-check.md`(6/6 PASS,`37cd818` 归档)
- 工作目录:wt(ch12-en-review),branch main,未 commit
- 结论:**需修 → 已修 9 处后通过(PASS)**。外环五范式:dual loop 0 命中、顿号/全角/CJK 0 命中、colon reveal 2 命中已修、hedging 0 命中(句首 So 演示腔 1 处已修)、recap ending 0 命中;禁用词/翻译腔 9 处必改已落地 + 5 条判保留;术语(glossary 五条目)零漂移;技术读校(三层调度、4.5万↔45,000 等值、章号)对齐;修后复验 verify-en 0 FAIL + mdbook 零警告。

---

## 1. 外环已裁决范式逐条核查

| 待修范式 | 检查方法 | 结果 |
|---|---|---|
| 「双环」dual loop | `grep -niE 'dual[ -]?loop|double loop|双环|two loops|both loops'` | 0 命中 ✅(本章不涉及该概念,Part IV 才引入) |
| 顿号(、)残留 | `grep -n '、'` + perl 扫 U+3000–303F / FF00–FFEF / 4E00–9FFF 全区间 | 0 命中 ✅(全文件零中文字符/零全角标点) |
| colon reveal | 逐条审读全部行尾冒号(L55/70/83/93/108/122/136/215 共 8 处行尾 + 段内标签冒号) | **2 命中已修(L191、L239)**;其余均为列表/表格/代码块/枚举/mermaid 引入的合法冒号,与中文版同位同型 |
| hedging 前缀 | `it is worth noting / note that / of course / arguably / somewhat / needless to say` 等 9+ 模式 | 0 命中 ✅(L104 "actually running LLM calls" 为实义副词「实际在跑」,非 hedging;L116 "in fact" 为转折实义词,同 ch11 C2 判例保留) |
| recap ending | 各节结尾 + 12.9 Summary + Version note 逐条审读 | 0 命中 ✅(12.9 为全书固定编号栏目,表格化归纳非复读;Version note 为事实句) |

## 2. 禁用词/翻译腔逐条记录

系统扫描 30+ 模式(in other words / obviously / clearly / firstly / so-called / moreover / meanwhile / not only…but also / as follows / the fact that / in terms of / carry out / make use of / in order to / due to the fact…)、em-dash、`is/are being` 被动堆叠、句首 But/And/So/Now、very/really/quite/simply、ellipsis。

### 2.1 必改(9 处,已全部落地)

| # | 行号 | 原文 | 改后 | 理由 |
|---|---|---|---|---|
| 1 | L53 | "octos's answer is not to put a lock on shared state **but the session actor: each session…**" | "…but **to introduce the session actor. Each session**…" | colon reveal + not X but Y 后接名词导致悬垂:冒号后揭出完整独立句;ch11 C2 同型(L61)已裁定必改,拆为两句消解 |
| 2 | L116 | "**So** the semaphore handles excess with waiting…" | "The semaphore **therefore** handles excess…" | 句首 So 演示腔(ch06/ch11 侧禁用词族);中文底稿「所以」位于句中,非句首演示 |
| 3 | L163 | "Three design decisions **hold this replay up**." | "Three design decisions **underpin this replay**." | hold up 误向:phrasal verb hold up = 延误/支撑(口语);直译底稿「撑起」;underpin 为技术书标准动词且与 ch03 侧用法一致 |
| 4 | L171 | "The four write-side methods **close over** this read semantics" | "…methods **close the loop on** this read semantics" | close over 为程序设计术语(闭包捕获),非「在这套读语义上闭合」之意;直译底稿「在这套读语义上闭合」;close the loop 为母语惯用搭配 |
| 5 | L181 | "Polling rather than pushing **buys this: if the consumer crashes…**" | "Polling rather than pushing **means that if** the consumer crashes…" | colon reveal(buys this 悬空指代 + 冒号揭从句)+ buys this 省略宾语不合语法;底稿「换来的是」 |
| 6 | L191 | "**An honest boundary:** the current implementation is…" | "**An honest boundary is that** the current implementation is…" | colon reveal:名词标签 + 冒号直接揭出完整从句;ch03 C2 裁定同型必改(L290) |
| 7 | L237 | "**Surrender and reclaim** rely on the same four-part predicate." | "**Surrender and reclamation** rely on…" | reclaim(v.)与 surrender(n.)不平行;底稿「让渡与回收」两名词并列 |
| 8 | L237 | "the books **change by zero**" | "the books **do not move**" | calque「账面零变动」;change by zero 非母语搭配;the books do not move 为会计/账本惯用语,与 ledger 语域一致 |
| 9 | L239 | "**The concurrency consequence of this design:** after the old process crashes…" | "**The concurrency consequence of this design is that** after the old process crashes…" | colon reveal:名词标签 + 冒号直接揭完整从句;ch11 C2 L61 同型 |

改动特征:9 处均为纯措辞层,零数字改动、零源码路径/行号改动、零 mermaid/代码块触碰 —— verify-en 引用集合 66↔66 equal、数字集合不受影响(见 §5 复验)。

### 2.2 判保留(5 条,记录理由)

| # | 行号 | 原文片段 | 判定 |
|---|---|---|---|
| A | L104 | "sessions **actually** running LLM calls" | 保留。actually 为实义副词「实际在跑的」(区别于 idle),非 hedging/演示腔;删除则语义损失 |
| B | L116 | "when **in fact** an Exclusive member is protecting semantics" | 保留。in fact 为转折实义词,对应底稿「其实」;ch11 C2 已有同判保留先例 |
| C | L247 | "`recv()` returns `None` — the mailbox draining is the shutdown" | 保留。em-dash 为解释性同位语(全章唯一一处),底稿破折号同型;verify-en 计 em dash 1,非禁用硬限 |
| D | L15/L151 | "45,000 lines of code **answer** a question / The supervisor layer's 45544 lines **all answer** this one question" | 保留。answer a question 拟人呼应底稿「在解决一个问题」;技术书修辞语域内,双处同型保持一致 |
| E | L163 | "barely a dozen lines" / L187 "reading the code, do not assume…" | 保留。barely 对应「只有十几行」的量感;do not assume 祈使为契约陈述,同 ch11 L61 "stop guessing" 判例 |

其余复核干净:省略号 0(仅代码块内 `/* … */`);`is/are being` 0;句首 But/And/Now/Then 0;very/really/quite/simply 0;smart quotes 0; firstly/moreover/meanwhile 0。

## 3. 母语度与术语一致(glossary 五条目)

| 词条 | 频次 | 一致性 |
|---|---|---|
| mailbox(信箱) | 7(L55/68/73/79/87 + L247 mailbox draining) | ✅ 全章统一 mailbox,无 inbox/queue/message box 漂移;与 ch11(ch11 无 actor 章)及 ch19 语域一致 |
| epoch | 9(owner_epoch ×6 + epoch 通名 ×3) | ✅ 术语零漂移;L213 "each daemon start gets a new epoch"、L237 "the caller's epoch" 与 L235 owner_epoch 定义同链 |
| zero-token monitor(零令牌监视器) | 2(L28 mermaid 标签 + L183 正文) | ✅ hyphen 形态统一;无 zero token/0-token 变体 |
| process metaphor(进程隐喻) | 2(L3 Positioning + L209 节标题) | ✅ 与 12.7 节标题及 Summary L255 一致,无 process analogy 漂移 |
| adoption(收养) | 4(L128 代码注释/L145 表格/L233 正文 + L255 Summary Parked adoption) | ✅ adopt/adoptable/adoption 屈折正确,无 takeover/reclaim 混用(reclaim 已由 L237 lease 语义专用) |

其它代码名引用零漂移:SessionActor/ActorRegistry/ActorHandle/ActorMessage/TaskSupervisor/TaskStatus/TaskLifecycleState/SupervisorStore/MasterContinuationScheduler/InProcessAgentOrchestrator/TaskLivenessLease/PeerTaskBinding 全章 CamelCase 统一;spawn_only/`spawn` tool/octos 小写体例与 ch11 一致;`octos's` 所有格 2 处(L3/L53)与全书 32 处先例同型。

## 4. 技术读校

- **三层调度表述**:① Tokio 层(session actor/semaphore/batch admission,12.2–12.5)→ ② supervisor 层(event ledger + continuation,12.6)→ ③ peer/lease 层(process metaphor + lease,12.7),章节序与 L49 路标、L9–13 表格、B1 mermaid 三处互证一致 ✅;12.8 graceful shutdown 收尾与 L49 预告吻合;12.9 三行 Summary 与三层一一对应。
- **数字**:17 文件 / 74692 行 / 722 符号;分层 5+25154 / 10+45544 / 2+3994(25154+45544+3994=74692 ✅);符号 170+454+98=722 ✅;**4.5万↔45,000 单位制等值**:L15「45,000 lines of code」对应底稿 L15「4.5 万行代码」(C1 §2 已裁定豁免,唯一出入);L151 "45544 lines"、L157 "nearly five thousand lines"、512 行 snapshot、3-second interval、10 并发上限、200 子任务上限、`(child_id, attempt_id)`、`SNAPSHOT_EVERY_APPENDS = 512`、9c157101 基线全部与底稿一一对应 ✅。
- **章号**:章题 Chapter 12 ✅;交叉引用 Chapter 5 ×3 / Chapter 10 ×2 / Chapter 16 ×4 / Chapter 18 ×4 与底稿第 5/10/16/18 章多重集全等(C1 §4 已证,本轮未触碰任何章号)✅;12.2–12.8 内部小节引用(L49 路标、L55 12.8 前指、L74 12.4 前指、L75 12.5 前指)均指向正确小节 ✅。
- **mermaid 3 块**:B1 三层架构(flowchart TB,3 subgraph/12 节点/10 边)、B2 续跑管线(sequenceDiagram,4 participant/6 箭头/1 Note)、B3 subagent↔peer(flowchart TB,2 subgraph/6 节点/2 边)——本轮零改动,C1 §5 已证结构 diff 空 ✅。

## 5. 改动与复验

改动文件:仅 `book-en/src/part3/ch12.md`(9 处,见 §2.1);报告为本文件。未 commit。

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch12-concurrency.md book-en/src/part3/ch12.md
refs: 66 (equal sets: yes)
en words: 4332, bold 4, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
(grep EXIT=1,零匹配;日志仅 INFO,HTML 正常写入)
```

修后行数仍 277(全部为行内替换);verify-en refs 66↔66 equal、0 FAIL/0 WARN,mdbook 零警告。

## 总判定

**PASS(9 处必改已落地并复验通过)。** 无遗留移交项;术语表、章号、数字等值、mermaid 全部干净。
