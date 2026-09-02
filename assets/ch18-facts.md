# Ch18 事实表 — Goal 与 Peer(源码定位)

- 基准:octos `main` @ `9c157101`(9c1571016e5ea86955b4b3486c04f0359dfff339,「docs(guide): document mcp_servers stdio fields…」#2212)
- 日期:2026-09-03 · 产出:peer A(ch18-facts)· 仓库只读,未改动任何源文件
- 生成命令约定:`O=/Users/zhangalex/Work/Projects/FW/octos; cd $O` 后执行。行号均已在 9c157101 上复跑核对。

---

## 1. Goal 线文件清单

| 文件 | 行数 | 首行文档 |
|---|---|---|
| `crates/octos-cli/src/goal_tool.rs` | 3028 | `//! Structured goal tools for the model (#1696) — replaces the fragile` |
| `crates/octos-cli/src/commands/goal.rs` | 1116 | `//! #25 — operator goal exits: octos goal reopen / octos goal archive.` |
| `crates/octos-cli/src/commands/ledger.rs` | 240 | `//! octos ledger tail — read-only goal-ledger tail (OLP L1, slice 4).` |
| `crates/octos-cli/src/autonomy/goal_loop_runtime.rs` | 1562 | 首行 `#![allow(dead_code)]`,文档次行 `//! M15 production primitives for goal and loop scheduling policy.` |
| `crates/octos-cli/src/autonomy/master_continuation_scheduler.rs` | 1416 | 首行 `#![allow(dead_code)]`,文档次行 `//! M15 production primitive for scheduling automatic master-agent continuation turns.` |
| `crates/octos-cli/src/autonomy/supervisor_store.rs` | 3277 | 首行 `#![allow(dead_code)]`,文档次行 `//! Durable supervisor state store for supervised agent groups.` |
| `crates/octos-cli/src/autonomy/fleet_wake.rs` | 1807 | `//! Fleet-kernel outbox consumer → keeper wake (PR 4a).` |
| `crates/octos-fleet/src/sqlite_ledger.rs` | 6360 | `// SQLite-backed durable ledger for goals, tasks, findings, and escalations.` |
| `crates/octos-cli/src/autonomy/agent_orchestrator.rs`(goal 持有方) | 33639 | — |

生成命令:
```bash
for f in crates/octos-cli/src/goal_tool.rs crates/octos-cli/src/commands/goal.rs \
         crates/octos-cli/src/commands/ledger.rs \
         crates/octos-cli/src/autonomy/{goal_loop_runtime,supervisor_store,master_continuation_scheduler,fleet_wake}.rs \
         crates/octos-fleet/src/sqlite_ledger.rs; do wc -l $f; head -1 $f; done
```
Goal 线合计:9 文件实核 52,445 行(goal_tool 3028 + goal 1116 + ledger 240 + goal_loop_runtime 1562 + mcs 1416 + supervisor_store 3277 + fleet_wake 1807 + sqlite_ledger 6360 = 18,806,再加 agent_orchestrator 33,639;原 47,645 为旧基线笔误,正文已统一 52,445——2026-09-03 外环 06:05 裁定加注,f39f333/2a07870 双轮实核)。

## 2. Peer 线文件清单

| 文件 | 行数 | 首行文档 |
|---|---|---|
| `crates/octos-cli/src/peers/mod.rs` | 3186 | `//! Peer-agent staging, addressing, and parked-prompt plumbing.` |
| `crates/octos-cli/src/peers/host.rs` | 502 | chat-host 侧 peer 绑定(`PeerBoot` 读取 goal/originator/brief) |
| `crates/octos-cli/src/commands/peer.rs` | 211 | `//! octos peer list — read-only peer observability (OLP L1, slice 3).` |
| `crates/octos-agent/src/tools/peer_handoff.rs` | 647 | `//! peer_handoff — LLM-initiated peer staging (#1801 v3).` |
| `crates/octos-agent/src/tools/peer_close.rs` | 274 | `pub struct PeerCloseTool` :42,`fn name()` :62 |
| `crates/octos-agent/src/tools/peer_gather.rs` | 263 | `pub struct PeerGatherTool` :35,`fn name()` :64 |
| `crates/octos-agent/src/tools/peer_list.rs` | 162 | `pub struct PeerListTool` :33,`fn name()` :56 |
| `crates/octos-agent/src/tools/peer_respond.rs` | 500 | `PeerRespondAnswer` :68 / `PeerRespondRequest` :80 / `PeerRespondTool` :100,`fn name()` :148 |
| `crates/octos-agent/src/tools/peer_send_input.rs` | 224 | `PeerSendInputRequest` :46 / `PeerSendInputTool` :72,`fn name()` :90 |

生成命令:
```bash
wc -l crates/octos-cli/src/peers/*.rs crates/octos-cli/src/commands/peer.rs \
      crates/octos-agent/src/tools/peer_*.rs
head -1 crates/octos-cli/src/peers/mod.rs
```
Peer 线合计:9 文件 ≈ 5,965 行(peers/mod 3186 + host 502 + commands/peer 211 + 六个 peer_* 工具 2070)。

## 3. goal_* / monitor_* 工具族(goal_tool.rs)

`fn name()` 返回值与结构体行号(命令:`grep -n "pub struct\|fn name" crates/octos-cli/src/goal_tool.rs` 后逐条 `sed -n '<l>,<l+1>p'`):

| 结构体 | 行号 | `fn name()` 行号 | 工具名 |
|---|---|---|---|
| `GoalGetTool` | 350 | 404 | `goal_get` |
| `GoalPlanTool` | 561 | 575 | `goal_plan` |
| `GoalDispatchTool` | 766 | 780 | `goal_dispatch` |
| `GoalGrantTool` | 861 | 875 | `goal_grant` |
| `GoalDenyTool` | 1024 | 1050 | `goal_deny` |
| `GoalUpdateTool` | 1163 | 1266 | `goal_update` |
| `GoalCreateTool` | 1495 | 1509 | `goal_create` |
| `MonitorCreateTool` | 1634 | 1655 | `monitor_create` |
| `MonitorListTool` | 1824 | 1838 | `monitor_list` |
| `MonitorDeleteTool` | 1893 | 1907 | `monitor_delete` |

- 测试区从 `#[cfg(test)]` :1985 起;10 个工具 = 7 个 goal_* + 3 个 monitor_*(#1977 零 token 监视器,keeper 门控:peers 不能布防)。
- serve 接线:`runtime/profile.rs` :1323(GoalGetTool,`.with_data_dir`)、:1326(GoalCreateTool)、:1329-1337(GoalUpdateTool + verifier lane)、:1341(GoalPlanTool)、:1342(GoalDispatchTool)、:1349(GoalGrantTool)、:1353(GoalDenyTool + data_dir);chat 接线:`commands/chat.rs` :859、:1574、:1577。
- `goal_get` 的聚合面:`<data_dir>/peers/<slug>/goal` 活体发现(:501 `data_dir.join("peers")`)+ `<data_dir>/goal-ledgers/<goal_id>.db` 持久 findings(:357、:491),键 `peer_findings` / `ledger_findings` / `open_escalations`(#1967)与 ledger digest(#1945)。

## 4. master_continuation_scheduler.rs 的 goal 侧衔接(1416 行,Ch5 §5.10 已有基线)

命令:`grep -n "GoalContinue\|GoalWrapUp\|MasterContinuationReason\|fn enqueue_at\|fn drain_ready" crates/octos-cli/src/autonomy/master_continuation_scheduler.rs`

- `MasterContinuationReason` :137,六变体:`ChildCompleted`、`ScatterJoinComplete`、`LoopFire`、`GoalContinue`(:141)、`GoalWrapUp`(:147,#1131 预算耗尽的收尾 turn,wrap_up_prompt 原文直传)、`External(String)`。
- `priority()` :152:`GoalContinue | GoalWrapUp => MasterContinuationPriority::GoalContinue`(:161)— wrap-up 与普通续跑同车道,「最后一个 goal turn,不是特权 turn」。
- 优先级 rank(:190-199):External=0、GoalContinue=10、ChildOrScatterJoinComplete=20、LoopFire=30。
- `stable_name()` :169-176:`"goal_continue"`(:171)/`"goal_wrap_up"`(:172)。
- `MasterContinuationScheduler` :477;`enqueue_at` :532;`drain_ready` :687;`drain_ready_for_session` :706。
- 循环原因不入 30s `RECENT_CLAIM_GUARD_WINDOW`(:33-35:LoopFire/GoalContinue/ChildCompleted 逐 tick 重入队,永不设防)。
- goal 侧入队点::935-940(`request(GoalContinue, "goal")`)、:969;去重键带 `with_goal_id`(:1185 测试)。
- 持有方:`agent_orchestrator.rs:11783` `continuations: MasterContinuationScheduler`(Ch5 §5.10 已引,已复核)。
- goal 侧交付物:`goal_loop_runtime.rs` 提供 `GoalId` :10、`GoalRuntimeState` :265(Active/Paused/Completed/Failed)、`GoalCompletionVerdict` :282(Done/NotDone——独立 verifier 判完成,#1935)、`GoalBudgetResolution` :298、`GoalRuntime` :305、`GoalRuntimePolicy` :239(cadence + max_continuations)、Loop 族 `LoopRuntimePolicy` :583 / `LoopRuntimeState` :629 / `LoopFireTrigger` :636。

## 5. GoalLedger 公开面(sqlite_ledger.rs,6360 行)

`pub struct GoalLedger` :13(WAL 多进程:master/PM/peers 独立进程共享同一账本);`impl GoalLedger` :206 起,到 :2241 收束,共 **39 个 pub fn**(命令:`awk '/^impl GoalLedger/,/^}$/' crates/octos-fleet/src/sqlite_ledger.rs | grep -c "pub fn"`)。核心方法(绝对行号 = 206 + 相对行号 − 1):

- 生命周期:`open` :222、`open_with_busy_retry` :245
- goal:`create_goal` :714、`upsert_goal` :811、`create_goal_if_absent` :848、`cas_goal_status` :899、`get_goal` :976、`update_goal_status` :1498、`stamp_goal_cleared` :2009、`settle_cleared_goal_cost_delta` :2096
- task:`create_task` :1066、`create_task_if_absent` :1124、`get_task` :1166、`update_task_status` :1232、`settle_task_status` :1267、`tasks_for_goal` :1290、`tasks_open_to_correction` :1349、`task_authority` :1383、`task_status_counts` :2178
- findings/escalations/decisions:`append_finding` :1623、`append_escalation` :1635、`resolve_escalation` :1702、`list_open_escalations` :1745、`resolve_escalation_by_id` :1764、`list_expired_open_escalations` :1793、`append_decision` :1807、`list_decisions` :1865、`list_findings_since` :2132、`findings_count_by_lifecycle` :2194、`findings_count_by_kind` :2212
- 审计/成本:`commit_state_with_audit` :1908、`count_decisions` :931、`total_cost_tokens` :2232、`data_version` :1398
- kv/主树:`kv_get` :1411、`kv_get_with_time` :1424、`kv_put` :1442、`main_tree_owner_goal` :1475、`claim_main_tree_owner` :1482

抽样核对:`sed -n '13p;206p;222p;714p;976p;1623p;2232p;2241p' crates/octos-fleet/src/sqlite_ledger.rs` → 全部命中。

## 6. peers/<slug>/ 黑板文件布局(stage_peer 写入顺序即发布不变量)

`stage_peer` `peers/mod.rs:1563`,写入顺序(绝对行号):
1. `wt/` — worktree,:1598 `peer_dir.join("wt")`;:1638-1640 实为 **`git clone --no-hardlinks`**(命令:`grep -n "as_os(\"clone\")\|as_os(\"--no-hardlinks\")" crates/octos-cli/src/peers/mod.rs` → :1638/:1640)。注释(:1624 起):默认 local-clone 优化共享对象文件 inode,`--no-hardlinks` 保证隔离——isolation is the entire point;克隆把整个 `.git` 放进 `wt`,peer 的栅栏分支在自己的克隆里 checkout(:1704 区域 `git checkout -b`);克隆不继承源仓 LOCAL config。
2. `originator` :1702(owner 先行,原子写)
3. `goal` :1729(两行格式:第 1 行 goal_id,第 2 行 task_id;task 无 goal 即丢弃 —— 读取侧 `peers/host.rs:96 read_peer_boot`,:99-116 解析)
4. `brief.md` :1738(**可见性门**:`staged_peer_dir` :417 以 brief.md 存在为准;必须最后写,写完 peer 才「存在」)
5. `name` :1752(显示名,主寻址键;`resolve_peer_name_to_slug` :1329)

其余叶子:`result.md`(runtime 终局副本,256 KiB 写入上限)、`result-<n>.md`(#435 版本化,`count_peer_result_versions` :2592)、`result.checkpoint.md`(#27e peer 持有写权时预算检查点的侧车)、`turns.txt`(行式索引 `turn read append`,`parse_peer_turns_index` :2649)、`closed`(墓碑,`peer_is_closed` :1317)、`model`(车道键,`read_peer_model_lane` :2189 / `record_peer_model_lane` :2205)、`.result-owner: peer` 侧车(#27f 单写者标记)。读上限:小文件 64 KiB(:462 `PEER_FILE_READ_CAP_SMALL`)、brief/result 1 MiB(:457 `PEER_FILE_READ_CAP_LARGE`);黑板上限 `PEER_BRIEF_MAX_BYTES = 64*1024`(:1422)。

生成命令:`sed -n '1598p;1638p;1640p;1702p;1729p;1738p;1752p' crates/octos-cli/src/peers/mod.rs` + `sed -n '96p;99p;117p' crates/octos-cli/src/peers/host.rs`

黑板行结构:`PeerBlackboardRow` :2676(slug/name/brief/result/turn_history/model_lane/closed/has_worktree),读取 `read_peer_blackboard` :2714,呈现 `compose_peer_list_text` :2802。`octos peer list`(commands/peer.rs:54)直读同一目录,零 serve 依赖;`octos ledger tail`(commands/ledger.rs:80)直读 `goal-ledgers/<goal_id>.db`。

## 7. result.md frontmatter —— 实测与 spec「六字段」的差异(写作时需按源码改口径)

- runtime 终局副本(`ui_protocol_transport.rs:14279 fn write_peer_result_if_peer_session`,frontmatter 拼装 :14334)**4 字段**:`slug` / `outcome` / `updated_unix` / `turn`(turn 号由 `count_peer_result_versions+1` 推导,:14328-14329)。
- 预算检查点副本(`octos-agent/src/agent/budget.rs:584`)**5 字段**:`status: budget_exhausted` / `completed: false` / `iteration_budget` / `iterations_used` / `checkpoint_commit`。
- peer 手写终局(`.result-owner: peer` 侧车时 runtime 不得覆盖,#27f/#27h):内容自由,无固定 frontmatter。
- 结论:ch18 正文应写「runtime 副本四字段 + 检查点副本五字段」,不要沿用 spec 的「六字段」表述。
- 生成命令:`sed -n '14325,14336p' crates/octos-cli/src/api/ui_protocol_transport.rs` + `sed -n '584p' crates/octos-agent/src/agent/budget.rs`

## 8. peer_handoff 与治理约束

- `PeerHandoffRequest` `octos-agent/src/tools/peer_handoff.rs:35`;`model: Option<String>` :59 —— **sub_provider 车道键**(与 Ch9 互引),host 校验键存在性,未知车道降级主模型并以 `PeerHandoffStaged.model_note`(:86)回告。
- `PEER_HANDOFF_BRIEF_MAX_BYTES = 64*1024` :27(brief ≤64KB);`PeerHandoffTool` :96,`fn name()` :133 → `peer_handoff`。
- 治理接线在 serve 侧(`peer_handoff.rs:12-13` 注释自证):depth-1 —— `peer_handoff_allowed_for_session` `peers/mod.rs:1934`(topic `peer-<slug>` 前缀即拒);per-turn cap —— `PEER_HANDOFFS_PER_TURN_MAX = 4` :1928,强制点 :2062;brief 上限见上。
- 绑定:`PeerTaskBinding` `peers/mod.rs:166`,`bind_peer_supervised_task` :241 / `retire_peer_supervised_task` :264 —— peer 存活与 supervisor 租约(Ch12/Ch16)对齐。
- `peer_handoff` 回调装配:`build_peer_handoff_callback` `peers/mod.rs:2047`,serve/chat 注册点 `commands/chat.rs:1662`(PeerHandoffTool)、:1674(PeerListTool)。
- boot 读回:`peers/host.rs:96 read_peer_boot`(goal 两行格式 + originator + brief),绑定「chat-hosted peer ↔ master 的 goal」(:439-443 注释)。

## 9. 三条回流通道(goal × peer 绑定)

1. **活体发现**:`goal_get` 聚合 `<data_dir>/peers/<slug>/goal` + peers 下 `result.md` → `peer_findings`(`goal_tool.rs:490-505`,`orchestrator.model_goal_peer_findings` :502)。
2. **持久账本**:peer 终局写入 `goal-ledgers/<goal_id>.db` findings → `ledger_findings` + `open_escalations` + ledger digest(`goal_tool.rs:505-545`;`GoalLedger::append_finding` :1623)。
3. **内核唤醒**:fleet outbox 事件 → keeper 续跑(`fleet_wake.rs:153 fleet_keeper_continuation_request`、:343 `spawn_fleet_outbox_consumer`;复用 mcs 的 MasterContinuationScheduler——`fleet_wake.rs:1-8` 首行文档点名 GoalContinue 同机制)。
- 陷阱(实测,写入正文):**模型不会自动传 goal_id** —— goal_get 靠 `ToolContext::parent_session_key` 解析会话(goal_tool.rs 首部文档 :10-12),peer 侧 goal 绑定靠 `peers/<slug>/goal` 文件而非对话上下文。

## 10. 与既有章节的交叉点

- **Ch5 §5.10**(chapters/ch05-agent-loop.md:273-275):mcs 1,416 行、Reason L137、priority() L152、Scheduler L477、enqueue L525、drain_ready L687、drain_ready_for_session L706、orchestrator :11783 —— 全部在 9c157101 复核为真(注意 Ch5 写的 `enqueue` L525 是 `pub(crate) fn enqueue`,`enqueue_at` 在 :532,两者并存,无冲突)。
- **Ch12**(chapters/ch12-concurrency.md)::13 peer/lease 层(peers/mod.rs 3186 行)、:189 goal_loop_runtime(GoalId :10、GoalRuntimePolicy :239、GoalRuntimeState :265)、:211 PeerTaskBinding :166 / bind :241、:12 supervisor_store 3277 行、:161-163 SupervisorStore :697 / load_state :780;Ch12 两处「goal/peer 编排详见第 18 章」(:3、:239)是本章的挂接点。
- **Ch9**(车道):`model` 参数 = `sub_providers` 键(peer_handoff.rs:52-59)。
- **Ch16**(fleet 状态机):fleet_wake 消费 `octos-fleet` outbox;GoalLedger 同属 `octos-fleet` crate。

## 11. 抽查复跑记录(交付前)

- `git -C $O rev-parse HEAD` → `9c1571016e5ea86955b4b3486c04f0359dfff339` ✅
- `sed -n '350p;561p;766p;861p;1024p;1163p;1495p' goal_tool.rs` → 7 个 `pub struct` 逐行命中 ✅
- `sed -n '137p;141p;147p;152p;477p;532p;687p;706p' master_continuation_scheduler.rs` → 全部命中 ✅
- `sed -n '13p;206p;222p;714p;976p;1623p;2232p;2241p' sqlite_ledger.rs` → 全部命中 ✅
- `sed -n '166p;417p;1563p;1702p;1729p;1738p;1752p;1928p;1934p;2062p;2714p' peers/mod.rs` → 全部命中 ✅
- `sed -n '27p;59p;96p;133p' peer_handoff.rs` + `sed -n '14279p;14334p' ui_protocol_transport.rs` + `sed -n '1323p;1341p;1342p' runtime/profile.rs` + `sed -n '1662p' commands/chat.rs` + `sed -n '11783p' agent_orchestrator.rs` → 全部命中 ✅

## 12. 关键数字汇总

- goal 线:9 文件实核 52,445 行(旧值 47,645 系笔误,见上注);peer 线:9 文件实核 5,969 行
- goal 工具族:10 个工具(7 goal_* + 3 monitor_*),`fn name()` 均已列
- GoalLedger 公开方法:39 个 pub fn(impl :206-:2241)
- mcs:1416 行,Reason 六变体、priority 四档(rank 0/10/20/30)
- peers/mod.rs:3186 行、host.rs 502 行;peer 目录叶子 ≥10 种(brief.md/goal/originator/name/wt/result.md/result-N.md/turns.txt/closed/model)
