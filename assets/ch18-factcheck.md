# Ch18 Factcheck 报告(ch18-factcheck)

- 审查对象:`chapters/ch18-goal-peer.md`(223 行,新增章)+ 镜像 `book/src/part3/ch18.md`
- 事实基准:`assets/ch18-facts.md`(commit 8a008e5 同批入库);源码只读 `octos @ 9c1571016e5ea…`(HEAD 实测一致)
- 基线防旧:开工已 `cp` master(3f91f38)两份文件进工作区;`git merge-base --is-ancestor 3f91f38 d9209aa` 为真,工作区 ch18 文件与 3f91f38 无差异,审查的即 master 最新基线
- 结论(文首):**可定稿**——但建议先修 1 处 Major(goal 线行数合计)与 2 处 Minor,均不影响锚点与事实正确性

## 分级汇总

| 级别 | 数量 | 内容 |
|---|---|---|
| Blocker | 0 | — |
| Major | 1 | goal 线 9 文件行数合计 47,645 与逐文件实测和不符(实测 52,445),正文 3 处 + 事实表 §1/§12 同源 |
| Minor | 2 | peer 线合计 5,965 精确和为 5,969(差 4,≈ 内);`chat.rs` 行号表述把 peer 侧与 chat master 侧混在一处 |
| 观察 | 1 | 字数 5,152(CJK 口径)vs brief 基准 5,027,差 +125(2.5%),疑口径差异,定稿无碍 |

## 检查清单逐项(附命令与计数)

### 1) `crates/...rs` 引用路径/越界/符号 —— PASS(60+ 关键锚全命中)

- 引用路径存在性:正文出现 **17 个不同源码路径**,逐个在 9c157101 上实测存在:
  `wc -l` 全部命中 9 个 goal 线文件(goal_tool 3028 / commands/goal 1116 / ledger 240 / goal_loop_runtime 1562 / mcs 1416 / supervisor_store 3277 / fleet_wake 1807 / sqlite_ledger 6360 / agent_orchestrator 33639),peer 线 9 文件亦全命中(mod 3186 / host 502 / peer.rs 211 / 六工具 647+274+263+162+500+224)。
- 越界:所有 `:行号` 经 `sed -n '<n>p'` 逐行取样,**零越界、零错位**(最大锚 ui_protocol_transport `:14334` 命中 frontmatter 拼装行)。
- 关键锚(命令 `sed -n`,全部命中):
  - GoalLedger 五组表:`:13` `pub struct GoalLedger` ✓、`impl` `:206`–`:2241` ✓、`awk …| grep -c "pub fn"` = **39** ✓;组内 21 个方法行号(714/811/899/976/1498/2009/1066/1124/1166/1232/1267/1290/1623/1635/1702/1745/1807/1908/2132/2178/2232)**逐行命中** ✓
  - `cas_goal_status` `:899` ✓,且 UPDATE 内嵌 CASE 预算规则实测在位(`WHEN ?1='active' AND token_budget>0 AND tokens_used>=token_budget THEN 'budget_limited'`)✓;`open_with_busy_retry` `:245` ✓(ATTEMPTS=3、50ms、busy_timeout 压 1s、BUSY/LOCKED 分类,`:239-240` 注释证实)
  - mcs 六变体 `:137`(`GoalContinue` `:141`/`GoalWrapUp` `:147`)✓;`priority()` `:152`、同车道 `:161` ✓;rank `:190-199` 四档 0/10/20/30 ✓;`stable_name` `:169-176`(`goal_continue` `:171`/`goal_wrap_up` `:172`)✓;Scheduler `:477`、enqueue_at `:532`、drain_ready `:687`、drain_ready_for_session `:706` ✓;`RECENT_CLAIM_GUARD_WINDOW` 30s(注释 `:33-35`,const `:37`)✓;goal 入队 `:935-940`/`:969`/`:1185`(with_goal_id 测试)✓
  - no-hardlinks:`:1638` `as_os("clone")` + `:1640` `as_os("--no-hardlinks")` ✓,论证注释 `:1624` 起 ✓(inode 腐蚀/isolation is the entire point/不继承 LOCAL config 均在)
  - `PeerTaskBinding` `:166` ✓、bind `:241` ✓、retire `:264` ✓
  - goal_loop_runtime:`GoalId :10`、`GoalRuntimePolicy :239`、`GoalRuntimeState :265`、`GoalCompletionVerdict :282`、`GoalBudgetResolution :298`、`GoalRuntime :305` 全命中 ✓
  - goal_tool 十工具:7+3 结构体/`fn name()` 20 个行号全命中,`name()` 返回值逐一读出(goal_get/plan/dispatch/grant/deny/update/create + monitor_create/list/delete)✓;`#[cfg(test)]` `:1985` ✓
  - 接线:profile `:1323`(with_data_dir)/`:1326`/`:1329-1337`(verifier lane,`goal_verifier_llm` 分支实测)/`:1341`/`:1342`/`:1349`/`:1353` ✓;goal_get 三通道 `:357`/`:491`/`:501`(`map.insert("peer_findings")` 在 `:506`)✓
  - peers/mod:stage_peer `:1563`、写入序 wt `:1598`→originator `:1702`→goal `:1729`→brief.md `:1738`→name `:1752` ✓;可见性门 `staged_peer_dir :417` ✓;`peer_is_closed :1317`、`resolve_peer_name_to_slug :1329`、`PEER_BRIEF_MAX_BYTES :1422`(64*1024)、`PEER_HANDOFFS_PER_TURN_MAX :1928`(=4)、强制点 `:2062`、`peer_handoff_allowed_for_session :1934`、读上限 `:457`(1 MiB)/`:462`(64 KiB)——与正文「小文件 :462、brief/result :457」写法一致 ✓;`count_peer_result_versions :2592`、`parse_peer_turns_index :2649`、`read_peer_model_lane :2189`、`record_peer_model_lane :2205`、`PeerBlackboardRow :2676`、`read_peer_blackboard :2714`、`compose_peer_list_text :2802` 全命中 ✓;`cleanup_staged_peer` 在 `:1912`(正文未标行号,无冲突)
  - host.rs `read_peer_boot :96`、goal 两行解析 `:99-116`(孤立 task_id 丢弃)✓;peer_handoff `:12-13`/`:27`/`:31`(name≤64)/`:35`/`:59`/`:86`/`:96`/`:133` ✓;ui_protocol_transport `:14279`/`:14306`(256 KiB)/`:14328-14329`/`:14334`(四字段)✓;budget.rs `:584`(五字段)✓;supervisor_store `:697`/`:780` ✓;fleet_wake `:153`/`:235`/`:343` + Durable-ack/lease 重投/dormant-but-correct/PR 4b(模块文档 `:20-37`)✓
  - 命令面:`octos goal reopen/archive` 注释(`:1`/`:14`:complete/blocked model-reachable、archived operator-only terminal)✓、reopen 三态 `:677` ✓;ledger tail `:80` ✓;peer list `:54` ✓;orchestrator `:11783`(continuations 字段)/`:12963`(GoalContinue 入队,`with_goal_id`+objective/status metadata)✓

### 2) 数字 —— 1 MAJOR + 1 MINOR

- **MAJOR**:goal 线合计。实测:`3028+1116+240+1562+1416+3277+1807+6360 = 18,806`;加 agent_orchestrator 33,639 → **9 文件合计 52,445**。正文与事实表写的 **47,645 与任何子集之和不符**(52,445−47,645 = 4,800,无对应文件;疑为旧基线/笔误)。连带「体量差八倍」:52,445/5,965 = 8.8 倍(按 47,645 算才是 8.0)。建议:合计改 ≈52,445,「八倍」改「近九倍」;「合计超过五万行」表述不受影响。
- MINOR:peer 线合计 5,965,精确和 `3186+502+211+647+274+263+162+500+224 = 5,969`(差 4,「≈」容差内,建议顺手改 5,969)。
- 其余数字全对:六 peer 工具 2,070 ✓、agent_orchestrator 33,639 ✓、sqlite_ledger 6,360 ✓、mcs 1,416 ✓、39 pub fn ✓、10 工具=7+3 ✓、rank 0/10/20/30 ✓、per-turn 4 ✓、brief 64KB ✓、result 256KiB ✓、frontmatter 四字段/检查点五字段 ✓。

### 3) 机械项 —— PASS

- 锚点/版本演化:全部路径行号化;章末「版本演化说明」在位,明示 v2 新增、基线 9c157101、frontmatter 按源码 4+5 字段(不沿用 spec 六字段)✓
- mermaid:**2** 个(sequenceDiagram + flowchart)✓;bash 块 0(自证命令 0,见第 5 项)✓
- 镜像:`cmp chapters/ch18-goal-peer.md book/src/part3/ch18.md` → **一致** ✓
- 破折号「——」:**2** 处(≤2)✓;加粗:`**` 标记 24 个 = **12** 处粗体 span(≤15)✓
- 黑话:brief/keeper/CAS/IPC/park 等均在首现处给出白话释义,自含性达标 ✓

### 4) 字数与占比 —— 观察项

- 本机实测(口径:中文字符数):**5,152**;去空白总字符 18,151;汉字+英文词 6,898。
- brief 基准「master 实测 5,027」与本机 5,152 差 +125(2.5%),疑测量口径差异(如是否计表格/图内文字)或基准为早一稿;量级一致,不构成定稿障碍。
- 占比:按全书 18 章体量折算约 **9.6–9.9%**,与 9.8% 基准相符 ✓。

### 5) 自证命令输出 —— PASS(0)

`grep -c '```bash'` = 0;通读全文无命令回显、无「如下输出」式自证段落。✓

### 6) SUMMARY 条目 —— PASS

`book/src/SUMMARY.md:36`:`- [第 18 章:Goal 与 Peer:把目标从上下文里搬出来](./part3/ch18.md)` 在位。✓

## Minor 细节(供稿务修订)

1. §18.3「peer 会话侧的接线在 `chat.rs:859` 与 `:1574-1577`」:`:858-865` 确是 peer_tools 侧(仅 goal_get+goal_update,与后句「拿不到 plan 与 dispatch」对应);`:1574/:1577/:1579` 实为 `octos chat` master 侧注册(Get/Create/Update)。建议拆成两句,避免读者把 :1574-1577 误读为 peer 侧。
2. peer 线合计 5,965 → 5,969(与 Major 一并改)。

## 复核记录(本次会话实测命令摘要)

```
git -C octos rev-parse HEAD          → 9c1571016e5ea869…(与事实表一致)
wc -l <9+9 文件>                     → 全部命中(52,445 / 5,969)
awk '/^impl GoalLedger/,/^}$/' … | grep -c "pub fn" → 39
sed -n 逐锚                          → 60+ 锚全命中(清单见第 1 项)
cmp chapters/ch18-goal-peer.md book/src/part3/ch18.md → 一致
grep -c '```mermaid' = 2;—— = 2;** = 24(12 span);```bash = 0
SUMMARY.md:36 第 18 章条目在位
```

本报告只读不改稿;审查期间未改动 chapters/、book/、assets/ 下任何既有文件。
