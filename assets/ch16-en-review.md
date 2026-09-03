# ch16 英文版 C2 读校报告(ch16-en-review)

- 对象:`book-en/src/part3/ch16.md`(245 行,前置 `1b247ef` 交付态);对照 `chapters/ch16-fleet.md`、`assets/glossary-en.md`、C1 报告 `assets/ch16-en-check.md`(6/6 PASS,`94a257b` 归档)
- 工作目录:wt(ch16-en-review),branch main,未 commit
- 结论:**需修 → 已修 9 处后通过(PASS)**。外环五范式:dual loop 0 命中、顿号/全角/CJK 0 命中、colon reveal 0 命中(4 处行尾冒号均为列表/表格/代码块引导,合法)、hedging 0 命中、recap ending 0 命中;禁用词/翻译腔 9 处必改已落地 + 4 条判保留;术语(lease/TTL/tick/Fleet/redb/sqlite_ledger)零漂移;技术读校(3 块 mermaid、16,888/6,842/23,730 等数字、章号 7/12/13/17/18)对齐;修后复验 verify-en 0 FAIL/0 WARN + mdbook 零警告,行数仍 245。

---

## 1. 外环已裁决范式逐条核查

| 待修范式 | 检查方法 | 结果 |
|---|---|---|
| 「双环」dual loop | `grep -niE 'dual[ -]?loop\|double loop\|双环\|two loops'` | 0 命中 ✅(本章不涉及该概念;zh 底稿亦无「双环」) |
| 顿号(、)残留 | grep 顿号 + python 扫 U+3000–303F / FF00–FFEF / 4E00–9FFF 全区间 | 0 命中 ✅(全文件零中文字符/零全角标点) |
| colon reveal | 逐条审读全部冒号;行尾冒号共 4 处(:13/:26/:96/:117) | 0 命中 ✅(4 处均为合法引导:两处表格/列表引入、两处代码块引入,与中文版同位同型;无「名词标签+冒号揭独立句」形态) |
| hedging 前缀 | `it is worth noting / note that / of course / arguably / somewhat / needless to say` 等 30+ 模式 | 0 命中 ✅(L38/184 actually 为实义「实际」,L206 simply 已随必改 #8 消除) |
| recap ending | 各节结尾 + 16.8 Recap + Version note 逐条审读 | 0 命中 ✅(16.8 为全书固定编号栏目,五条各自有新信息;Version note 为事实句) |

## 2. 禁用词/翻译腔逐条记录

系统扫描:in other words / obviously / clearly / firstly / so-called / moreover / meanwhile / not only…but also / as follows / the fact that / in terms of / carry out / make use of / in order to / due to the fact / em-dash / ellipsis / 句首 But/And/So/Now / very/really/quite / is being 被动堆叠 / there is 开头。**全部 0 命中或判保留。**

### 2.1 必改(9 处,已全部落地)

| # | 行号 | 原文 | 改后 | 理由 |
|---|---|---|---|---|
| 1 | :9 | "one-shot task workers landed first**,** dockable session workers were left…" | "…first**, and** dockable…" | comma splice:两个独立子句仅逗号相连;zh 底稿为顿号并列 |
| 2 | :111 | "it rejects the next launch**,** it does not interrupt an in-flight run" | "…launch**;** it does not…" | comma splice;对照同句式(:82)已用分号,内部不一致 |
| 3 | :115 | "because it **completes** the outbox's durable semantics into a full loop" | "because it **closes** … into a full loop" | completes…into 搭配错;close…into a loop 为惯用;zh「补成完整一环」 |
| 4 | :115 | "The fleet-side **conclusion:** the outbox guarantees…" | "The fleet-side **conclusion is that** the outbox…" | colon reveal:名词标签+冒号直接揭完整独立句(ch03/ch11/ch12 C2 同型裁定必改) |
| 5 | :180 | "the whole logic is **table-testable**" | "the whole logic **can be tested with table-driven tests**" | 生造复合词,母语技术书不用;zh「表驱动测试」 |
| 6 | :180 | "cluster hints (**a component referenced by how many paths**; …)" | "cluster hints (**how many paths reference each component**; …)" | 疑问词嵌入式直译腔,读不通;zh「component 被多少 path 引用」 |
| 7 | :188 | "the keeper **need not repeat a read that could be skipped**" | "the keeper **can skip a read it would otherwise have to make**" | 逻辑拧转(need not repeat + could be skipped 双重否定缠绕);zh「不必再做一次可能被跳过的读」 |
| 8 | :206 | "so full network is **simply** required" | "so full network is **required outright**" | simply 为弱化词/口语腔;zh「干脆要求」;outright 保留决断语气 |
| 9 | :208 | "every permit is naturally available**,** there is no secondary problem…" | "…available**, and** there is…" | comma splice |
| — | :212 | (随 #9 批次)"whole-plan APIs **over the store**" | "whole-plan APIs" | 介词尾巴悬空冗余(同句前文已有 store's CAS operations,over the store 重复指代) |

注:#9 与 :212 冗余修复合计 9 处编辑落地(表格含 10 行,其中 :212 计为同批附修)。

### 2.2 判保留(4 条)

| 行号 | 原文 | 理由 |
|---|---|---|
| :38 | "what was **actually** observed" | 实义「实际观测到的」,与 observed 连用非强调虚词 |
| :184 | "which tools can a worker **actually** use" | 实义「真正能用」,非 hedging |
| :115 | "it takes a store, a clock…" | take 为 API 语义惯用(接受参数),非口语 |
| :245 | "this chapter is **that** destination" | 指代清晰的事实句,非翻译腔 |

## 3. 母语度与术语一致性

- **Fleet/fleet**:全章统一(术语 Fleet 单独出现时大写,普通名词 fleet row / fleet 小写),与 glossary 及 ch12/ch13 用法一致。
- **redb**:全程小写(存储引擎名),0 漂移;Further reading 链接 cberner/redb 完整。
- **sqlite_ledger**:`crates/octos-fleet/src/sqlite_ledger.rs` 全路径引用 3 处(:214 两处、表格内),与 facts 表一致;`GoalLedger` (:13) 与第 18 章术语一致。
- **租约 30 秒 / tick 3 秒**:"the lease (30 seconds, :56)" 与 "ticks every 3 seconds with a per-tick cap of 64 events (:63)" — 数字+行号锚与 zh 逐位相同;lease/TTL 拼写统一(Lease 结构体大写、lease 概念小写)。
- **CAS / outbox / attempt / keeper / grant / escalate**:中英混排术语(代码名)保持原样不译,与全书 Part III 约定一致。
- **拼写/语法抽检**:无 its/it's、无主谓不一致、无冠词遗漏类硬伤;passive voice 用于系统行为描述属技术书正常密度。

## 4. 技术读校

### 4.1 mermaid 三块(结构+标签)

| 块 | 行号 | 类型 | 核验 |
|---|---|---|---|
| 1 | :40-78 | classDiagram | 6 节点/4 边,class id 与字段(FleetRecord.generation: u64 等)与 zh 逐字节一致(此块两侧同语言)✅ |
| 2 | :119-140 | sequenceDiagram | participant 4(O/P/S/W)、alt/else/end 结构、10 消息边;标签已英化("same transaction: child→Launching" / "predicate passed" / "result discarded, no state change"),与 zh 对应语义逐条核对无误 ✅ |
| 3 | :154-172 | stateDiagram-v2 | 9 状态(含 3×`[*]`)/16 转移;每条边标签携带方法+行号锚(add_child:503 / launch_child:889 / mark_running:1053 / complete_child:1157 / record_escalation:1336 / goal_grant / deny_escalation:2025 / reconcile:2191 / cancel_fleet:838),与 zh 同位同锚 ✅ |

三块均未被本次修改触碰(9 处改动全在正文段落,不在围栏内)。

### 4.2 数字

- 核心体量:16,888(:3/:17)、6,842(:3/:18)、23,730(:214)、6,360(:214)、808(:26)、861(:180)、705(:184)、293(:188)、2,575(:192)、2,186(:206)、3,062(:212)、1,807(:115) — 与 zh 逐位一致。
- 全文件数字多重集 zh↔en 归一比对:145↔145 unique 全等(独立复算,与 C1 结论一致);本次 9 处改动均未触碰任何数字 token。
- 关键机制数字:SCHEMA_VERSION = 3、30 seconds、3 seconds、64 events、4,000 max_chars、cluster_min_paths 2、5-second busy_timeout、3 retries、1 second — 全部对齐。

### 4.3 章号

Chapter 7(:3/:184×2/:216)、Chapter 12(:3/:113×2/:216/:245)、Chapter 13(:9)、Chapter 17(:216)、Chapter 18(:7/:113/:214)+ 版注 "see Chapter 16"(:245):多重集与行号分布同 C1 报告,零漂移 ✅

## 5. 修改后复验输出

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch16-fleet.md book-en/src/part3/ch16.md
refs: 55 (equal sets: yes)
en words: 4675, bold 5, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

修后行数仍 245(全部为行内替换);refs 55↔55 equal、words 4675(+5,均为替换词),0 FAIL / 0 WARN,mdbook 零警告零错误。

## 总判定

**PASS(9 处必改已落地并复验通过)。** 外环五范式全部干净;无遗留移交项;mermaid/数字/章号/术语全部零漂移。
