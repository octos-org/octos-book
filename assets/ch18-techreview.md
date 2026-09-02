# Ch18 techreview(C2)——chapters/ch18-goal-peer.md

- 审查员:ch18-techreview(peer)· 基线:octos main @ `9c157101`(源码只读)· 事实表:assets/ch18-facts.md(commit 8a008e5)
- 日期:2026-09-03 · 只报告不改稿

## 计数表

| 级别 | 数量 | 编号 |
|---|---|---|
| Critical(机制错误/事实错误) | 1 | C1 |
| Major(易误导/口径偏差) | 2 | M1, M2 |
| Minor(表述/一致性) | 5 | m1–m5 |

## 结论:是否可定稿

**接近可定稿:修掉 C1、拍板 M1 后可进统稿。** 全章 223 行、10 节、2 图、行号密度极高,经逐条对源码复核,绝大多数机制描述与行号准确(核对清单见文末)。唯一的机制级错误是状态清单把 `cleared` 写成 `archived`(C1);M1 的「goal 线合计」把 33,639 行的 orchestrator 计入后与「9 文件 ≈47,645」的算术自相矛盾,需要拍板口径。其余为小口径问题。

## Critical

### C1「archived」应为「cleared」:ledger 状态集写错(major 事实错误,但修复一行)

正文(§18.4 末段):「`cas_goal_status` 与 `update_goal_status` 管理字符串状态 **active、paused、completed、blocked、budget_limited、archived**」。

证据:
- `sqlite_ledger.rs:39`:`pub status: String, // active | complete | blocked | budget_limited | paused | cleared` —— GoalLedger 的 goals 表状态集是 **cleared**,不是 archived。
- `sqlite_ledger.rs:914` / `:1512`(CAS 与 update_goal_status 的 WHERE 子句):`AND status NOT IN ('complete', 'cleared')` —— 账本层的终态保护针对 `cleared`,archived 根本不是 SQLite 侧状态。
- `cleared` 的出处:goals.rs:36-37 注释「`cleared`(#1973 fix B)是用户 `goal_clear` 盖的终态章」。

正文的混淆源:`archived` 确实存在,但它是 **supervisor 事件流侧**(`commands/goal.rs:12-14`:「archive admits any status → archived, TERMINAL, irreversible」「Goal state is authoritative in the supervisor event stream … NOT in the goal-ledger SQLite goals table」)的状态,与账本层不是同一本账。正文同段前文引用 `commands/goal.rs` 注释谈 reopen/archive,接着把 archived 混进了账本状态集,读者会以为一个 SQLite 列装着七态。

连带修:§18.2 末段「budget_limited … 操作员要理解 budget limited 不是 stopped」处如果补一句两本账状态集不同,可顺带把 `cleared`(账本终态)与 `archived`(supervisor 侧终态)分立讲清。另「completed」在账本里写作 `complete`(单列注释与 `:914` 均为 complete),正文用 completed 与 update_goal_status 语义无冲突但建议统一为账本字面 `complete`。

## Major

### M1 goal 线「9 文件 ≈47,645 行」自相矛盾(orchestrator 计入后不是 9 个文件)

正文(§18.1 表格与首段):「goal 线 9 文件 ≈47,645 行」但同段又把 `agent_orchestrator.rs`(33,639 行)列为「goal 的持有方」。算术:事实表 §1 列的 9 文件(goal_tool 3028 + commands/goal 1116 + commands/ledger 240 + goal_loop_runtime 1562 + mcs 1416 + supervisor_store 3277 + fleet_wake 1807 + sqlite_ledger 6360 + **orchestrator 33639**)= 52,445,不是 47,645;47,645 是 **不含 orchestrator 的 8 文件合计**(18,806)也拼不出。实际两数都对不上:
- 8 文件(不含 orchestrator)= **18,806**;
- 9 文件(含 orchestrator)= **52,445**。
事实表 §1「Goal 线合计:9 文件 ≈47,645 行」自身同样算错(其括号内加式漏了 orchestrator,又标了 9 文件)。建议拍板口径:orchestrator 是「持有方/宿主」而非 goal 专属文件,推荐写「goal 线 8 文件 ≈18,806 行,宿主 orchestrator 另计 33,639 行」;若坚持计入,数字改 52,445 且体量比随之变。「体量差八倍」一句(18,806 vs 5,965 ≈ 3.2 倍;52,445 vs 5,965 ≈ 8.8 倍)取哪种口径都要跟着改。§18.1 首段「合计超过五万行」同样依赖 52,445 口径。

### M2 peer 线合计 5,965 → 实测 5,969(差 4 行,顺带修)

peer 线 9 文件实测(本会话 wc -l @9c157101):3186+502+211+647+274+263+162+500+224 = **5,969**(事实表与正文均写 5,965)。差 4 行,极可能是个别文件在 8a008e5 之后有微调。不影响结论,但既然是「计数表+算术」章,建议统一按本审查的 wc 输出改为 5,969,或在事实表标注采集时点。peer 线文件构成(9 文件、peers/mod 3186、六工具 2,070)核对无误。

## Minor

### m1 §18.4「`update_goal_status`(`:1498`)管理 … 字符串状态」与 C1 同源

同句把 `update_goal_status` 也拉进「管理七态」的表述,修复 C1 时一并处理。

### m2 §18.3 表格 goal_update 行号「:1163 / :1266」含义未标注

其他行「结构体行号 / fn name() 行号」格式一致,goal_update 的 :1266 距 :1163 一百余行,读者易误读为区间。事实表同格式,建议表头注明「结构体 / fn name()」。

### m3 §18.1「(goal_tool.rs)首行文档注明它取代脆弱的提示词方案 #1696」——首行是截断的英文注释

事实表 §1 原文:`//! Structured goal tools for the model (#1696) — replaces the fragile`(#1696 在首行,「取代提示词方案」在其后的续行)。正文转述无误,但「首行文档注明它取代…」略强于证据;改「首行文档(#1696)注明它取代脆弱的提示词方案」即可,或不必动。

### m4 §18.7「克隆也不继承源仓的 LOCAL config」无行号锚点

同段其他断言均有 :1624-1640 注释锚定,这一句裸述(clone 确实不拷贝 .git/config 的本地修改,机制上真),建议补 `git clone` 语义说明或删去,保持「每断言有锚」的章风。

### m5 版本演化说明「第 5 章 §5.10 与第 12 章对本章的前向引用在此落地」——第 5 章确有(L295「第 18 章:MasterContinuationScheduler 的消费侧与 goal 续跑全貌」),第 12 章侧未核到同语句

若第 12 章没有对应前向引用句,建议改为只提第 5 章;撰写侧可自查 ch12 的「第 18 章」字样。此项不阻塞。

## 核对通过项(抽样全对,列作证据)

以下为正文逐条对源码复核通过的断言(编号对应正文行):

1. §18.2 全部 39 个 pub fn 及分组行号(抽样 :13/:206/:222/:245/:714/:811/:899/:976/:1066/:1124/:1166/:1232/:1267/:1290/:1498/:1623/:1635/:1702/:1745/:1807/:1908/:2009/:2132/:2178/:2232/:2241 全部命中);39 = awk 实测;`impl GoalLedger :206-:2241` 收束正确。
2. `cas_goal_status :899` 预算规则嵌 UPDATE(sqlite_ledger.rs:907-911 CASE 表达式,active 且 tokens_used≥token_budget 写 budget_limited);`open_with_busy_retry :245`(3 次 / 50ms / busy_timeout 1s / 仅 BUSY-LOCKED 重试,:246-285 实测)全部与正文一致。
3. §18.3 工具族 10 个(7 goal_* + 3 monitor_*),结构体与 fn name() 行号 15 项全中;monitor keeper 门控(goal_tool.rs:46-50 is_peer_session fence + :1724-1728 monitor_create 拒 peer)属实;profile.rs 接线 :1323/:1326/:1329-1337/:1341/:1342/:1349/:1353 与 verifier 注入(goal_verifier_llm → with_verifier_provider)逐行核对一致;chat.rs :859/:1574-1577(peer 侧仅 goal_get/goal_update)一致;goal_get 三键聚合(peer_findings/ledger_findings/open_escalations,:503/:512/:524)一致。
4. §18.4 六变体(:137-146)、GoalContinue :141 / GoalWrapUp :147(#1131 wrap_up_prompt 原文直传注释在 :142-146)、同车道(:160-161 注释「LAST goal turn … not a privileged one」)、rank 四档 0/10/20/30(:196-202)、stable_name :171/:172、RECENT_CLAIM_GUARD_WINDOW 30s(:33-35,循环原因永不设防)、入队点 agent_orchestrator.rs:12963(`MasterContinuationRequest::new("coding-autonomy-goal", …).with_goal_id … with_metadata("objective"/"status")`)、continuations 字段 :11783、enqueue_at :532、drain_ready :687 / for_session :706、去重键带 goal_id 测试 :1185 —— 全部一致。
5. §18.4 fleet_wake:durable-before-ack(fleet_wake.rs 模块文档「acks an outbox event only once its wake is WakeCommit::Durable … left claimed and redelivers after the lease lapses」)、dormant-but-correct(「Nothing writes live fleet events until a later PR」)、PR 4b 边界、drain_fleet_outbox_once :235 / spawn_fleet_outbox_consumer :343 —— 与模块文档逐句一致。
6. §18.4 supervisor 支撑:SupervisorStore :697 / load_state :780 属实;「goal 的续走请求走同一条持久化路径」有 fleet_wake 文档「the SAME durable-persist path the peer/goal wakes use」支撑。
7. §18.5 peer 六阶段:stage_peer :1563、写入顺序 wt :1598 → originator :1702 → goal :1729 → brief.md :1738 → name :1752(实测源码顺序与正文一致);brief.md 可见性门(staged_peer_dir :417 以 brief.md 存在判定)、originator 先写理由(:1566-1571 注释「no window where a member is visible-but-ownerless」)、goal 孤立 task_id 丢弃(host.rs:96-116,注释「A task id without a goal id is meaningless — drop it」)、result 四字段 frontmatter(ui_protocol_transport.rs:14334)、turn 号推导 :14328-14329、256KiB :14306、budget 检查点五字段(agent/budget.rs:584)—— 全部一致。
8. §18.6 黑板布局:叶文件清单与读上限(:457 1MiB / :462 64KiB / :1422 64KB brief)一致;PeerBlackboardRow :2676、read_peer_blackboard :2714、compose_peer_list_text :2802、count_peer_result_versions :2592、parse_peer_turns_index :2649、peer_is_closed :1317、read_peer_model_lane :2189、resolve_peer_name_to_slug :1329 —— 全中。fd 锚定 + 拒 symlink 与 stage_peer 注释一致(worktree 路径的 TOCTOU 残余风险 :1610-1616 注释也诚实标注)。
9. §18.7 worktree 真相:clone :1638 / --no-hardlinks :1640 实测(as_os("clone") / as_os("--no-hardlinks") 各占一行);:1624 起注释逐句支撑「.git 是文件指向沙箱外 / fatal: not a git repository / git init 自救毁栅栏 / 共享 inode 腐蚀源仓 / 隔离优先,成本另付,evidence 后再评估」—— 正文转述忠实。
10. §18.8 绑定与回流:goal 两行文件、PeerHandoffRequest :35、model :59、model_note :86、「模型不会自动传 goal_id」实测陷阱(架构文档 :237 ⚠️ 原句)—— 一致;三通道 mermaid 与文字/live vs durable vs escalation 语义一致。
11. §18.9 治理:depth-1(peer_handoff_allowed_for_session :1934,topic peer- 前缀即拒,peer 工具注册表无 peer_handoff)、per-turn cap 4(:1928 常量、:2062 fetch_add 强制点)、brief 64KB(peer_handoff.rs:27 / peers/mod.rs:1422 双侧镜像)、name 上限 64 字符(peer_handoff.rs:31 PEER_HANDOFF_NAME_MAX_CHARS = 64,:212 检查)—— 全部属实;PeerTaskBinding :166 / bind :241 / retire :264 一致。
12. 结构:DDIA 式「问题→机制→边界→回顾」叙事线成立;§18.10 与 Ch5/Ch12/Ch16 的三处划界表述与三章实际内容对得上(Ch5 §5.10 确从 loop 视角讲过 MCS 并前引第 18 章;Ch12 租约/supervisor;Ch16 fleet redb vs GoalLedger SQLite)。mermaid 时序图(§18.5)六阶段与文字一一对应;回流三通道图(§18.8)与 goal_get :491-:525 实现一致。
13. pathfix 引用风格:全文 `crates/…` 全路径 + `:行号`,与全书 pathfix 后风格一致,未发现裸文件名引用(「goals.rs:36」仅在本报告内部使用,正文无此类);交叉引用(§5.10、第 12 章、第 16 章 §16.7、第 9 章车道、第 19/20 章排除)均有落点。
14. 跨章重复:与 Ch5 §5.10 关于 MCS 的重叠为「同一调度器的两个视角」,正文以「这里补 goal 侧的全部语义」显式划界,重复句 ≤3 行;与 Ch16 的 fleet/grant-deny 重叠以「状态机细节回到第 16 章」划界;未发现成段重复。

## 给统稿的一句话

C1 改一个词(archived→cleared)+ 补一句两本账状态集;M1 拍板 goal 线口径(建议 8 文件 18,806 + 宿主另计,或 9 文件 52,445 全改齐);M2 改 5,969。此后本章技术面可定稿。
