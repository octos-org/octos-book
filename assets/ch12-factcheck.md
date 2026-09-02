# Ch12 factcheck 报告(ch12-concurrency.md @ master 7146471)

- **审查基准**:章节 = master 定稿 commit `7146471` 的 `chapters/ch12-concurrency.md`(已 cp 入本工作区,与 `book/src/part3/ch12.md` `cmp` 逐字节一致);事实表 = `assets/ch12-facts.md`(`c450666`);源码 = `/Users/zhangalex/Work/Projects/FW/octos` @ `9c157101`(git log 首行核对:9c157101 docs(guide) #2212)。
- **方法**:全量提取章内 69 处行号引用(30 处全路径 + 39 处 `:N` 短引),逐条 sed 取行比对符号;数字三层复算;机械项与字数/占比脚本实测。只报告,未改任何稿件。

## 汇总

| 检查项 | 结果 | 计数 |
|---|---|---|
| 1) 引用路径/越界/符号 | ✅ 通过(2 处行级偏差,见 B2/C2) | 69 处引用,0 越界,1 处锚点偏 2 行,1 处表格行与源码不符 |
| 2) 三层数字 | ✅ 全部复算一致 | 25154+45544+3994=74692;170+454+98=722 |
| 3) 机械项 | ⚠️ 1 处旧章号残留 | mermaid 3;—— 1(≤2);加粗 3(≤15);锚点/版本演化/镜像/SUMMARY 在位;「第 11.3 节」残留 1 处 |
| 4) 字数与占比 | ✅ 通过 | 严格汉字 5,358(≥5,000);围栏代码占比 12.3%(≤28%) |
| 5) SUMMARY 条目 | ✅ 在位 | `book/src/SUMMARY.md:30` |

**分级:B 级(须修)2 处,C 级(可选)2 处。**

**是否可定稿:修完 2 处 B 级后可定稿**(均为行级修改,不动结构)。

---

## 1) 引用核查(命令输出节选)

全路径引用提取与计数:

```
$ grep -on 'crates/[a-z-]*/src/[a-z_/]*\.rs[:：][0-9-]*' chapters/ch12-concurrency.md | sort | uniq -c | wc -l
54 行(去重后);含短引 `:N` 共 69 处
```

逐条核验结果(全部在 `9c157101` 实测,✅=符号/语义与章文一致):

**session_actor.rs(10094 行)**
- ✅ `:86 pub struct DispatchParams<'a>`
- ✅ `:2443 pub enum ActorMessage` —— 枚举体 2443-2497,变体恰 5 个(Inbound/BackgroundResult/TaskStatusChanged/ApprovalExpired/Cancel),章文代码块与「五种消息」均准确
- ✅ `:2502 pub struct ActorHandle`(`:2872 pub shutdown: Arc<AtomicBool>`)
- ✅ `:2524 pub struct ActorRegistry`(字段 actors/factory/profile_factories/semaphore,`:2534 pub fn new` 收 semaphore)
- ✅ `:4122 let join_handle = tokio::spawn(actor.run());`
- ✅ `:4455 struct SessionActor`(session_key/inbox 等)
- ✅ `:4500-4503` global_shutdown + cancelled 两个 `Arc<AtomicBool>` 字段及注释
- ✅ `:7485` / `:9293` 两处 `let _permit = match self.semaphore.acquire().await`(章文「permit 消费点在 actor 消息处理入口」成立)
- ✅ `:2795 pub async fn shutdown_all` —— 函数体即「drop 全部 sender,recv() 返回 None 后退出」,与 12.8 叙述一致

**gateway_runtime.rs(2420 行)**
- ✅ `:24 use tokio::sync::{Mutex, Notify, RwLock, Semaphore}`
- ✅ `:1653 tokio::spawn(async move {` + `:1654 tokio::signal::ctrl_c().await` + `:1656 shutdown_clone.store(true, Ordering::Release)`(12.8 的 Release 序声明与源码一致)
- ✅ `:1666 gw_config.max_concurrent_sessions`(启动日志打印)
- ✅ `:1713 tokio::spawn(async move {`(系统提示词异步刷新)
- ✅ `:1731-1732` `// Semaphore to bound concurrent session processing` + `Semaphore::new(gw_config.max_concurrent_sessions)`;`:1733-1738` 随后传入 `ActorRegistry::new`,与「紧随其后交给 ActorRegistry::new」一致

**config.rs(3790 行)**
- ✅ `:1548-1549` serde default 声明;✅ `:1633 fn default_max_concurrent_sessions() -> usize {`,`:1634` 函数体字面量 `10`(事实表待核项 1 已闭合)

**execution.rs(4730 行)**
- ✅ `:7-26` 模块文档三策略(M8.8 / #1766);`:14 join_all preserving call order`
- ✅ `:701 tokio::spawn(async move {`;✅ `:2483 pub(super) async fn execute_tools`(章文已注明 pub(super) 口径)
- ✅ `:2992 None => futures::future::join_all(handles)`
- ⚠️ C2: `join_parallel_handles` 章文引「`:2957` 起」——声明实际在 `:2959`(2957-2958 为上一 helper 尾部);「起」字勉强覆盖,建议改 2959。同句「`crates/octos-cli` 无关」措辞别扭(应为「属 octos-agent」),内容不错
- ✅ 超时语义:`:2959-2996` deadline→`timeout_at`→`abort()`+有界宽限(`abort_and_join_with_grace`)→合成超时结果,与章文逐点一致

**task_supervisor.rs(4120 行)**
- ✅ `:1` 首行 `//! Background task lifecycle management for spawn_only tools.`(事实表待核项 2 闭合)
- ✅ `:43 MAX_CHILDREN_PER_PARENT = 200`;`:41`/`:77` 环境变量覆盖;`:90 RegisterTaskError`
- ✅ `:140 TaskStatus` 六变体;`:164 is_active`(只含 Spawned/Running);`:173 is_terminal`(Completed/Failed/Cancelled,Parked 注释明言 deliberately NOT terminal)
- ✅ `:243 TaskLifecycleState` 六变体 Queued/Running/Verifying/Ready/Failed/Cancelled;`:363 lifecycle_state()`
- ❌ **B2(见下)**:`:373 TaskStatus::Parked => TaskLifecycleState::Cancelled`

**spawn.rs / mcp_server.rs / harness_events.rs**
- ✅ spawn.rs `:1929 "background".into()`(default_mode 在 `:1928`,章文引 1929 指返回行,可接受)、`:1855` 字段 doc、`:3004` JSON schema enum
- ✅ mcp_server.rs `:66 RUN_OCTOS_SESSION_TOOL`(全文件仅此一个对外工具,`:229/:385` 单工具断言佐证)、`:108 final_state: TaskLifecycleState`、`:142-145` SessionLifecycleObserver::mark_state
- ✅ harness_events.rs `:651-652` outcome 五值 doc + `:397 附近` McpServerCall 变体定义

**autonomy 层(十文件)**
- ✅ supervisor_store.rs(3277 行):`:25`/`:33` 常量、`:49 SNAPSHOT_EVERY_APPENDS = 512`(取值依据注释逐句吻合)、`:300-304` serde type/payload 注释、`:381 apply_ledger_row`、`:382 last_sequence.max(row.sequence)`、`:697 SupervisorStore`、`:723 new`、`:780 load_state`(780-793:先 snapshot 后账本,只重放 `row.sequence > snapshot_last_sequence`)、`:784 max`、`:876 load_snapshot`(`schema_version >` 支持版本即拒绝)、`:905 write_snapshot`、`:920 snapshot_now`、`:935 append_event`
- ✅ master_continuation_scheduler.rs:`:477` 结构体(BinaryHeap + pending_by_key)、`:497 recently_claimed_external`(TOCTOU 字段 doc 与章文一致)、`:506 impl`、`:99/:112/:137/:186/:221` 各类型;Reason 六变体 ChildCompleted/ScatterJoinComplete/LoopFire/GoalContinue/GoalWrapUp/External(String) 与章文列举一致;Priority rank External=0 最低、LoopFire=30 最高,「刻意压低」注释原文在 `:188-189`
- ✅ fleet_wake.rs:`:59 FLEET_WAKE_INTERVAL_SECS = 3`(章文「每 3 秒」)、`:343 spawn_fleet_outbox_consumer`、`:235 drain_fleet_outbox_once`、`:70/:84/:153/:420`
- ✅ monitor_runtime.rs:`:72 MonitorMode`(poll/stream 两态;`:83 as_str`/`:90 interval_secs`)、`:100/:123/:153/:185/:209/:217/:230/:256/:271/:277/:287` 全部命中
- ✅ goal_loop_runtime.rs:`:10 GoalId`、`:239 GoalRuntimePolicy`、`:265 GoalRuntimeState`;`:25/:40/:68/:75`
- ✅ agent_orchestrator.rs(33639 行):`:606 trait AgentOrchestrator`、`:607 list_agents`、`:662/:675/:688/:699` 四个带默认实现的方法(默认体调用 `method_not_supported_error`,全文件 6 处)、`:746 InProcessAgentOrchestrator`、`:1451 impl`、`:9462 trait impl`、`:9661/:9729/:9778/:9797` spawn/send/wait/resume 具体实现、`:2471 run_native_specialist`、`:110/:271/:376`
- ✅ specialist_runner/human_events/escalation_notify/mod.rs:事实表所列行号抽查命中(`mod.rs:14 pub(crate) mod agent_orchestrator`)

**peer/lease 层**
- ✅ peers/mod.rs(3186 行):`:1` 首行文档逐字一致;`:3-7` 「Lifted VERBATIM…No logic changed: only module placement and item visibility」与章文「逐字提升…只改模块位置与可见性」一致;`:166 PeerTaskBinding`(字段含 `_liveness: octos_agent::TaskLivenessLease`,注释「The lease lives HERE」)、`:182 bind`、`:215 take`、`:225 peer_task_registry`、`:241 bind_peer_supervised_task`、`:264 retire_peer_supervised_task`
- ✅ records.rs(808 行):`:250 pub struct Lease`(251-252 两字段 owner_epoch/expires_at_ms;247-249 doc「foreign epoch or expired → recovery reconciliation reclaims」)、`:256 pub struct Attempt`(259-261 child 行 key/反查 doc)、`:41/:64/:84/:94/:105/:119/:132/:145/:193/:238/:290/:302/:313` 全命中
- ✅ store.rs:`:975-1001` 构造 Attempt 时 `status: AttemptStatus::Leased` + `lease { owner_epoch, expires_at_ms: lease_expires }`,lease_expires 由 `:977-978 checked_add(now_ms, lease_ttl_ms)` 求得(章文「TTL 加法用 checked_add 防溢出」✅);`:1053 pub async fn mark_running`;`:1158 pub async fn complete_child`,四部谓词本体在 `:1233-1237`(attempt-id/Running/generation/owner_epoch,注释「Four-part predicate」原文在 1231-1232),任一不满足返回 `CompleteOutcome::Superseded`(章文 1230-1237 覆盖谓词区,✅);`:2274-2277` stale 判定(foreign epoch or expired)+ 置 `Interrupted` + 释放预留(2282-2297),`:2269-2273` #1973 fix-round 注释原文在位

## 2) 三层数字复算

```
$ wc -l <五 Tokio 文件>            → 10094+2420+4120+4730+3790 = 25154 ✅
$ wc -l crates/octos-cli/src/autonomy/*.rs → 33639+3277+2037+1807+1562+1416+1155+430+169+52 = 45544 ✅
$ wc -l peers/mod.rs records.rs    → 3186+808 = 3994 ✅
$ echo "25154+45544+3994" | bc     → 74692 ✅
```

符号数(口径 `pub fn|pub struct|pub enum|pub trait|pub(crate) …`):

```
session_actor 33 ✅ / task_supervisor 82 ✅ / config 53 ✅ / execution 2(pub(super) 不计口径)✅ → 170 ✅
autonomy 十文件合计 454 ✅(cat autonomy/*.rs | grep -Ec → 454)
peers/mod.rs 71 + records.rs 27 = 98 ✅
170+454+98 = 722 ✅
```

其余数字:`default_max_concurrent_sessions` 返回字面量 `10`(config.rs:1634)✅;`max_concurrent_sessions` 调到 100 的思考题背景 ✅;`c4f03647`(2026-08-12,#1977/#1988)、`e2f999a0`(2026-09-01 clippy)、`0c44b26f`(2026-08-28 OLP control)三 commit 均存在且日期与版本演化说明一致 ✅。

## 3) 机械项

- mermaid 图:**3** 张(12.1 分层 / 12.6 时序 / 12.7 对比)✅(每章 3 张口径)
- 破折号「——」:**1** 处 ✅(≤2)
- 加粗 `**…**`:**3** 段(定位块/两处工程决策标签)✅(≤15)
- 锚点:定位/前置依赖(第 5、10 章)/适用场景 ✅;章内自述 12.2–12.9 结构与实际标题一致 ✅
- 版本演化说明:在位,基线 9c157101 + 事实表指引 + v1→v2 变化 ✅
- 镜像:`cmp chapters/ch12-concurrency.md book/src/part3/ch12.md` → 一致,0 输出 ✅
- SUMMARY:`book/src/SUMMARY.md:30` 第 12 章条目在位 ✅
- 黑话抽查:水位线/背压/TOCTOU/epoch/Release-Acquire 均在使用处带一句白话解释 ✅;「RPC 面」首次出现有列举解释 ✅
- ⚠️ **B1**:第 269 行思考题 1「**第 11.3 节**的 permit 消费位置」——旧章号残留,本章该内容是 **12.3** 节(全章仅此一处旧号;第 278 行「原第 11 章」为有意的历史指称,不改)。

## 4) 字数与代码占比

```
$ python3 统计 chapters/ch12-concurrency.md
严格汉字(U+4E00-U+9FFF):5,358 ✅(≥5,000)
围栏代码字符(rust+mermaid)/全文:2329/18943 = 12.3% ✅(≤28%)
```

> 口径注:master commit 信息记「5,156 汉字、占比 25%」,与本报告 5,358/12.3% 的差异均为统计口径不同(是否含标点/是否只算 rust 围栏等);两种口径下均满足阈值,不构成问题。

## 5) 分级清单

| 级别 | 位置 | 问题 | 建议 |
|---|---|---|---|
| **B1** | 第 269 行(思考题 1) | 「第 11.3 节」为 Ch11→Ch12 改号残留,本章实为 12.3 | 改「第 12.3 节」 |
| **B2** | 12.5 节映射表末行 | 表称 Parked「(无投射)」,但源码 `lifecycle_state()`(task_supervisor.rs:373)实际 `Parked => Cancelled`(#27c:复用 Cancelled 的空闲投射槽,由 `parked` 状态字符串区分);表格与源码行为不符 | 该行改「Cancelled(复用空闲槽,`parked` 字符串区分)」并加半句;或改为「无独立投射态」以避免「无投射」的硬性错误 |
| C2 | 12.4 节 `join_parallel_handles` | 引「`:2957` 起」,声明实际在 `:2959`(2957-2958 为上一函数尾部);同句「`crates/octos-cli` 无关」措辞含混 | 锚点改 2959;措辞改「属 octos-agent」 |
| C3 | 12.4 节混合批 | 未提混合批的级联语义(阶段 1 Safe 失败携带 cascade bit 时整体取消阶段 2,#1690 的 ToolInputError 例外,见 execution.rs 模块文档 27-45 行) | 非错误,属可选增补;如补,一句即可 |

## 结论

**是否可定稿:修完 B1、B2 两处行级修改后可定稿。** 69 处引用全部在区间且符号/语义与 `9c157101` 实测一致(仅 1 处锚点偏 2 行),三层数字 25154/45544/3994=74692、170/454/98=722 全部复算吻合,机械项除 1 处旧章号外全部达标,字数 5,358 ≥ 5,000、代码占比 12.3% ≤ 28%,SUMMARY 条目在位,镜像一致。本章无越界引用、无符号错位、无数字错误。
