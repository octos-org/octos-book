# ch20 英文版 C2 读校报告(ch20-en-review,lane strong)

- 对象:`book-en/src/part4/ch20.md`(175 行);基线 main(前置:ch20-en a5d65bc 交付,C1 ch20-en-check 6/6 PASS,816ca5f 归档)
- 日期:2026-09-03;范围:英文去味 + 母语度/术语一致 + 技术读校;不改事实/数字/引用/mermaid/代码块
- 产出:本报告 + `book-en/src/part4/ch20.md` 措辞微修 3 处(零事实/引用/数字变更)
- 复验:verify-en 0 FAIL 0 WARN(refs 42 相等,em dash 2,bold 10);`mdbook build` 零警告零错误

## 1. 外环待修项范式逐条核查

| 待修范式 | 本章命中 | 判定 |
|---|---|---|
| 「双环」dual loop | :5 标题 "The Dual Loop"、:55 "the dual-loop pairing matrix"、:156 "every channel of the dual loop";与 ch21/preface/SUMMARY("Part IV: Dual Loop")全书一致,无 "double loop/bi-loop" 漂移 | ✅ 合规 |
| 顿号(、)残留 | `grep -n '、'` → 0;CJK 标点全文 0(仅 :103/:124 mermaid 块内 `→`/`⇒` 箭头,系图标签非中文标点) | ✅ 无需修 |
| colon reveal(冒号悬念句) | 全章 77 处冒号均为枚举引导/标签式/引用行号前缀(:7 "The role table at `…:19`:"、:63 "form a small state machine:" 后接完整句),无 "The answer is: X" 式空悬念 | ✅ 合规 |
| hedging | 无 arguably/perhaps/it seems/somewhat/maybe/probably/it's worth noting/when it comes to/in order to;断言语气一致 | ✅ 无需修 |
| recap ending | `## 20.7 Boundaries and Recap` 为边界划分 + 编号要点清单(5 条),无 "In this chapter we learned…" 式回声段 | ✅ 合规 |

## 2. 禁用词/翻译腔逐条记录

verify-en banned 清单(delve/leverage/robust/seamless/pivotal 等)全文 0 命中;em dash 正文 0(仅 :136 两处转引源码头注释 `octos steer — …`/`octos ledger tail — …`,为代码注释原文内嵌,WARN 阈值内)。

**已修 3 处**(仅措辞):

| 行 | 原文 | 问题类型 | 修改 |
|---|---|---|---|
| :31 | "Two … incidents … **are what pushed** the doorbell pattern into its final shape" | 翻译腔 cleft 句(ZH「促成了…定型」直译,"are what pushed" 为中式伪强调) | "… incidents … settled the doorbell pattern into its final shape" |
| :31 | "delivery (the notes file is emptied) is not consumption (the turn prompt reads it) is not execution (the deliverable or ACK lands)" | 三连 "A (…) is not B (…) is not C (…)" 直译链,括注嵌套非英语结构,ZH 原文为「投递≠消费≠执行」 | 先立公式后释义:"delivery is not consumption is not execution: delivery means the notes file is emptied, consumption means the turn prompt reads it, execution means the deliverable or ACK lands" |
| :128 | "Ten contract tests … **nail this invariant set down**" | "nail … down" 搭配错(nail down 的宾语是要求/事实,不是集合;"钉死"直译),本章他处及全书均用 pin(如 :39 "the grammar is pinned by"、:128 同句 "guarded by") | "pin this invariant set down" |

保留项(逐条核过,非必改):

- :111 "two-headed command" — ZH「双头指挥」,与 split-brain(:115)同属本书自造技术隐喻,语义自足,保留。
- :111/:155 "honest shrink"/"shrinks honestly" — 源码注释术语的回译("诚实收缩"),两次出现形式一致,保留。
- :113 "The lock's design density rewards a symbol-by-symbol read." — ZH「设计密度经得起逐符号读」的紧凑英译,母语可读,保留。
- :115 "Death coupling is the soul of this lock" — ZH「死亡耦合是这把锁的灵魂」;soul 在此为修辞强调,本书风格内(与 ch18 "the heart of" 同型),保留。
- :140 "settles accounts against the ledger" — "按账本收账" 直译但搭配成立(settle accounts against 为合规介词搭配),保留。
- :132 "closes the door" — ZH「把话说死」;close the door on 为英语习语,此处省略 on the ambiguity 但语义完整,保留。
- :61 "commit but never push" / :3 "pushed on behalf of the runtime" — git push 动词用法,无歧义,保留。
- :86/:90 "the inner loop pushes" — 与 pull model 对仗的技术动词,非口语化,保留。

## 3. 母语度与术语一致

| 项 | 核查 | 判定 |
|---|---|---|
| OLP v2 | :1/:33/:151/:175 一致;`protocol: olp/v2` 形式仅出现在 :53 引用处 | ✅ |
| R1–R7 | :35-:53 七条齐全(R1 ACK/R2 verification/R3 escalation/R4 workspace/R4b fencing/R5 idempotent/R6 version/R7 duty lock),与 ZH 逐条对齐,含 #20-20c、#38-r1、#31 编号 | ✅ |
| ACK 定式 | 全章统一 "ACK(done\|wontdo\|blocked)" 语法 + "fixed grammar"(与 ZH「定式」对应);:39/:61/:63/:80/:152 五处一致 | ✅ |
| blackboard | 全文 blackboard(无 whiteboard/boardroom 漂移);`OUTER_LOOP_REVIEW.md` 路径 :21/:61/:145 一致 | ✅ |
| GoalRuntimeState 四态 | :140 "four-state enum (Active/Paused/Completed/Failed)" + budget_limited 明确标注为 ledger 侧字符串状态,与 ch18 划界呼应;`GoalBudgetResolution`(:298)、`cas_goal_status` 拼写一致 | ✅ |
| downlink/uplink | :9 五下行/六上行编号与 :25-:26 mermaid 边标签(1 AGENTS.md … 5 TUI injection / 1 event stream … 6 git diff)完全对应 | ✅ |
| lanes | cheap lane/strong lane/main tier(:55)与 ch21/preface 用语一致 | ✅ |

## 4. 技术读校

- **mermaid(4 块)**::11 flowchart(节点/边/编号标签与正文矩阵一致)、:64 stateDiagram(10 边,Pending/Done/Wontdo/Blocked/Accepted/Operator/Historical 与正文状态机一致,含 Blocked→Pending 回边)、:94 sequenceDiagram(9 消息,行号 :25/:26/:184-187 与正文一致)、:118 flowchart(outer-duty,VACANT/HELD/ERROR 与 :34 DutyState 一致)。标签英文、无 CJK、无顿号。
- **数字**:verify-en 全量核对 ZH 数字 0 缺失(30/7/2/9/3/5/4/403/406/476/25/13/465/29/71/367/8/745/10/290/7/90.0/0.5/3/64KB/39/6,360/5-10M/10-20M/30-50M 等全过)。
- **章号/引用**:Chapter 18/19/21 交叉引用与 ZH 对齐;octoscode/ 前缀引用 42 条两语集合相等(verify-en refs equal sets: yes);`crates/octos-cli/src/commands/{steer,ledger,peer,goal}.rs` 与 `crates/octos-cli/src/autonomy/{goal_loop_runtime,master_continuation_scheduler}.rs` 路径拼写逐条目检无误。
- **Positioning/Version note 锚**::3 与 :175 双锚在位;Version note 三仓基线(9c157101/1129fa33/fefe5c4f,2026-09-03)与 ZH 一致。

## 5. 中文版上报项(超 C2 权限,只报不改)

无。ZH ch20-octoloop.md 逐段对照未发现事实/数字/引用错误。

## 6. 结论

**通过(3 处措辞微修后)**。改动全部为去翻译腔措辞,零事实/数字/引用/mermaid/代码块变更;复验 verify-en 0 FAIL 0 WARN、mdbook build 零警告。英文版 ch20 可定稿。
