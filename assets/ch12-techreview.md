# Ch12 并发模型 — C2 技术审查(techreview)

- **审查对象**: `chapters/ch12-concurrency.md`(C1 收敛 9c78d4c 后的 master 定稿拷贝)
- **事实基准**: `assets/ch12-facts.md`(2026-09-03);源码只读 octos @ `9c157101`
- **审查日期**: 2026-09-03
- **审查员**: C2(ch12-techreview, lane strong)
- **方法**: 全部 critical 逐条对照源码行号亲测(命令在 octos 仓库根执行);跨章重复对照 Ch5 实测文本。

## 0. 结论与计数表

**结论:可定稿。** critical 0 / major 0 / minor 3(均为可选润色,不阻塞)。

| 检查项 | 结果 | 计数 |
|---|---|---|
| 1) 机制描述正确性(三层调度/投射/default 10) | ✅ 通过 | 0 critical, 0 major |
| 2) 技术公平性(共享 Mutex vs actor 侧栏) | ✅ 通过 | 0 critical, 0 major |
| 3) 论证层数(三层各节「为什么这样设计」) | ✅ 通过 | 0 critical, 0 major |
| 4) 跨章重复(Ch5/Ch16/Ch18 ≤3 行) | ✅ 通过 | 0 critical, 1 minor |
| 5) 结构(DDIA 叙事线、mermaid 与文字一致) | ✅ 通过 | 0 critical, 2 minor |
| **合计** | | **0 critical / 0 major / 3 minor** |

## 1. 机制描述正确性(检查项 1)

全部逐条亲测,行号与语义均与源码一致:

| 章节声称 | 源码亲测结果 | 判定 |
|---|---|---|
| supervisor 账本+重放水位线 `supervisor_store.rs:780-793` | `load_state` 在 `:780`,读 snapshot 取 `last_sequence`(`:783`),只重放 `row.sequence > snapshot_last_sequence` 的尾部行(`:788-791`),`state.last_sequence` 对 snapshot 取 max(`:784`)——与章文逐句吻合 | ✅ |
| `apply_ledger_row` 取 max 单调水位线(`:381-382`) | `:382` `self.last_sequence = self.last_sequence.max(row.sequence)`,且 `:383-385` event_id 去重幂等 | ✅ |
| `SNAPSHOT_EVERY_APPENDS = 512`(`:49`) | `:50` `pub const SNAPSHOT_EVERY_APPENDS: u64 = 512;`,`:45-48` 注释确为「行数而非 per-process append」论证 | ✅ |
| `.old` 单代轮转仅取证、pre-#1974 降级截断视图、新 schema 拒读(`:25/:33/:876`) | `:25` `EVENTS_FILE_NAME`、`:33` `EVENTS_ROTATED_FILE_NAME`(注释含 BACK/DOWN-COMPAT 全段)、`load_snapshot` 在 `:876` | ✅ |
| 写侧四方法 `:905/:920/:935` | `write_snapshot:905`、`snapshot_now:920`(带锁压缩)、`append_event:935`(注释含阈值触发压缩、失败不回滚 append) | ✅ |
| scheduler `:477/:99/:112/:137/:186` | 结构体 `:477`(heap + `pending_by_key` + `recently_claimed_external:497`)、Id `:99`、DedupeKey `:112`、Reason `:137`、Priority `:186`(External 最低的 doc 在 `:187-188`,与「刻意压低」吻合) | ✅ |
| TOCTOU 防护 `recently_claimed_external` | `:497` 字段、`:563` 窗口内拒绝重复 External 入队——章文「同键 External 重复投递被拒」准确 | ✅ |
| `default_max_concurrent_sessions()` 默认 10(`config.rs:1633`) | `:1633-1635` 函数体返回字面量 `10`;serde 声明在 `:1548-1549` | ✅ |
| 信号量创建(`gateway_runtime.rs:1731-1732`)、启动日志(`:1666`)、ActorRegistry 接收 | `:1731` 注释 + `:1732` `Semaphore::new(gw_config.max_concurrent_sessions)`;`:1664-1667` 打印 "Max concurrent";紧随 `:1734` 传入 `ActorRegistry::new` | ✅ |
| permit 消费在消息处理层(`session_actor.rs:7485` 与 `:9293`) | 两处均亲见 `self.semaphore.acquire().await`;排队不拒绝的语义描述与代码行为一致 | ✅ |
| actor 入口 `ActorRegistry:2524` / `ActorHandle:2502` / `ActorMessage:2443` / `SessionActor:4455` / `tokio::spawn:4122` / `DispatchParams:86` | 全部亲测行号命中,`ActorMessage` 五变体(Inbound/BackgroundResult/TaskStatusChanged/ApprovalExpired/Cancel)与枚举定义一致 | ✅ |
| TaskStatus 六态(`:140`)、`is_active:164`、`is_terminal:173`、MAX_CHILDREN 200(`:43`)、env 覆盖(`:77` 读取) | 全部亲测;`is_terminal` 只含 Completed/Failed/Cancelled,Parked 刻意排除(#27c 注释原文) | ✅ |
| **投射表**(含 C1 修正后的 Parked→Cancelled 行) | `lifecycle_state()` 在 `:373` 亲测:Spawned→Queued、Running→Running(按 runtime_state 细分 Verifying)、Completed→Ready、Failed→Failed、Cancelled→Cancelled、**Parked→Cancelled(`:379` 起 #27c 注释:「Reuse Cancelled's idle lifecycle slot…parked status string carrying the distinction」)**。章文表格含「#27c 复用空闲投射槽, task_supervisor.rs:373」一行,与 C1 修正一致 | ✅ |
| 表格 Completed→Ready(经 Verifying) | `:375` Completed→Ready;Running 的 ResolvingOutputs/VerifyingOutputs/DeliveringOutputs 投射 Verifying——章文「经 Verifying」的说法与代码路径吻合(Verifying 是 Running 的 runtime 子态,不是独立 TaskStatus) | ✅ |
| MCP 侧 `run_octos_session:66`、`final_state:108`、observer `:142-145` | 全部亲测;`McpSessionOutcome.final_state: TaskLifecycleState`(`:108`)、「会话级聚合结果」表述准确 | ✅ |
| harness `outcome` 五值(`harness_events.rs:651-652`,变体 `:397` 附近) | `:397` `McpServerCall` 变体、`:651-653` `outcome` 字段 doc 明写五值并 cross-ref TaskLifecycleState | ✅ |
| peer/lease:`PeerTaskBinding:166`、`bind_peer_supervised_task:241`、`Lease:250`(owner_epoch+expires_at_ms)、`Attempt:256`(fleet_id 冗余反查) | 全部亲测;`records.rs:247-249` doc「foreign epoch or expired 由 recovery reconciliation 回收」与章文一致 | ✅ |
| `store.rs:990-1001`(Leased + lease 写入 + checked_add TTL)、`mark_running:1053`、四部谓词 `:1230-1237`、reconciliation `:2276-2277` stale 判定、#1973 注释 | 全部亲测:`:978` `checked_add(lease_ttl_ms)` 防溢出、`:1231-1236` attempt-id/Running/generation/epoch 四条件、`:2265-2284` #1973 fix-round 注释(此前 Cancelled fleet 被整体跳过致 attempt+预留钉死)与章文逐句吻合 | ✅ |
| 优雅关停:`:4500-4503` 两 AtomicBool、`shutdown_all:2795` drop sender、Release/Acquire 对 | `:1657` `store(true, Ordering::Release)`、`:104/:111/:1796/:1818` `load(Ordering::Acquire)`——内存序契约描述准确 | ✅ |
| spawn mode 默认 background(`spawn.rs:1929`)、sync(`:1855`)、schema(`:3004`) | `default_mode() → "background"`、`#[serde(default = "default_mode")] mode: String`、schema enum `["background","sync"]` 全亲测 | ✅ |
| 批次准入:`execute_tools:2483`(pub(super))、All-Safe spawn `:701`、`join_all:2992` | 全部亲测,可见性口径(`pub(super)` 不计入统一 grep)在事实表 §1.4 有备注,章文口径一致 | ✅ |
| 版本演化说明中「事实表四条待核已亲测」 | 抽验属实:`task_supervisor.rs` 首行为 `//! Background task lifecycle management…`、`config.rs` 首行 `//! Configuration file support…`——事实表原记「无/未采集」确已修正 | ✅ |

**小口径备注(不计缺陷)**:章文 12.5 称 TaskStatus 为「六个状态」并列出 Spawned/Running/Completed/Failed/Cancelled/Parked——源码确为六变体,正确。表格中「Running→Running(worker 在跑)」省略了 runtime_state 细分(ExecutingTool→Running、VerifyingOutputs→Verifying),但表格粒度是 TaskStatus 级,不算错误。

## 2. 技术公平性(检查项 2)

12.2 侧栏「共享 Mutex、spawn-per-message 与 Session Actor」三方案对比:

- 共享 `Mutex<SessionState>` 的批评(锁粒度膨胀、持锁跨 await、取消难插队)**技术公平**:三点都是该模型在 tokio 下的真实代价,且章文点明这是「旧稿 v1 时代的描述已被纠正」而非稻草人——把历史误述转化为勘误叙事,论证姿态诚实。
- spawn-per-message 的批评(状态必须外置、一致性变锁问题)同样公平:这是无状态任务模型的标准弱点,章文没有夸大。
- Session Actor 的代价(生命周期管理、空闲回收、respawn 保 profile override)有 `ActorHandle` 字段注释背书(`:2505-2508` 亲测存在),没有只报喜。
- spec 场景 `review_ch11_actor_sidebar` 的两条验收(三方案对比 + 状态所有权优势与复杂度)均满足。

**判定:通过。** 侧栏做到了「每个方案给一条真实优点 + 两条真实代价」,无贬损式对比。

## 3. 论证层数(检查项 3)

三层各有显式的「为什么这样设计」:

| 层 | 「为什么」论证位置 | 质量 |
|---|---|---|
| Tokio 层 | 12.2 侧栏(三方案取舍 + 「代价被 ActorRegistry 集中承担」);12.3 「限流放消息处理层而非会话创建层」一段——空闲会话不占额度,这是全章最好的 why 段落之一 | ✅ |
| supervisor 层 | 12.6 开篇侧栏(为什么从 Tokio task 提升为持久化 supervisor:三件事变了 + 近五千行代价);账本三设计决策(行数触发快照/单调水位线/.old 取证妥协)每条都是 why 而非 what | ✅ |
| peer/lease 层 | 12.7 「epoch 不同就自动失权…正确性不依赖崩溃方配合」;租约与账本并列收束(「同一命题的两个答案」);subagent≈线程 / peer≈进程 对比图 | ✅ |

另 12.5 有「状态要不要持久化影响并发语义」的论证(Parked 案例),12.8 有两条关停路径互补的 why。**判定:通过**——三层无缺论证的裸机制罗列节。

## 4. 跨章重复(检查项 4)

对照 `chapters/ch05-agent-loop.md` 实测(Ch16/Ch18 尚未成稿,仅有 spec,不构成重复风险):

- **MasterContinuationScheduler**:Ch5 §5.10 已有约两段(六变体+优先级+enqueue/drain 接口);Ch12 12.6 亦介绍六变体、优先级、TOCTOU。重复内容为「变体枚举与优先级」这一共享事实,两章各自 ~3-4 行表述不同(Ch5 侧重消费边界、Ch12 侧重并发骨架),且 Ch12 明写「第 5 章从 loop 视角看过它的消费侧,完整语义属于第 18 章」。**边界处理正确**,但变体清单+优先级顺序的枚举在两章各出现一次,是最接近重复的地方 → **minor 1**(建议 Ch12 变体清单可压缩为「六种原因(枚举见第 5 章)」,优先保留 Ch12 独有的 TOCTOU 与 External 压低论证)。
- TaskLifecycleState/McpServerCall:Ch10 只在事件词汇表列名一次,无机制展开,Ch12 的投射表不构成重复。✅
- fleet lease/attempt:Ch12 自律地停在第 16 章边界(两处「详见第 16 章」),state machine 全貌未抢跑。✅
- goal/peer 编排:两处「详见第 18 章」。✅

**判定:通过**(1 minor)。

## 5. 结构与图表(检查项 5)

- **DDIA 叙事线**:从数字(12.1)→ 分层全景 mermaid → 逐层深入(快→久→隔离)→ 12.9 小结用「三种正交需求分开买单」收束,是 DDIA 式的「问题先于机制」结构。✅
- **全景 mermaid(12.1)与文字一致**:三层 subgraph 的文件/行数标注与 12.1 表格及后文各节逐一对应;`TS → STORE (lifecycle 事件)`、`SCHED → ACTOR (续跑派发)` 等边与 12.5/12.6 的文字描述吻合。✅
- **subagent vs peer 对比图(12.7)**:六节点(A1-A3/B1-B3)与随后文字段落一一对应。✅
- **投射表(12.5)**:C1 修正后的六行表与 `task_supervisor.rs:373-386` 亲测逐行一致,含 Parked→Cancelled(#27c)行及其「非终态非活跃」注记。✅
- **minor 2**:12.9 延伸阅读末条「Tokio 官方文档的 graceful shutdown 章节:` shutdown{} ` 模式」——` shutdown{} ` 不是 Tokio 文档的真实模式名(Tokio graceful shutdown 惯例是 drop runtime / `shutdown_timeout`),疑似笔误或占位,建议改为具体表述(如「`Runtime::shutdown_timeout` 与任务协作式取消」)或删除。
- **minor 3**:12.5 表格「Parked | Cancelled(#27c 复用空闲投射槽,task_supervisor.rs:373)」行内引用风格与其余五行(无行内行号)不一致;统一去掉行号或全部保留,纯格式问题。

## 6. 逐项 spec 验收对照(摘要)

| spec 场景 | 结果 |
|---|---|
| review_ch11_graceful_shutdown(Release/Acquire + 完整链路) | ✅ 12.8 |
| review_ch11_actor_sidebar | ✅ 12.2 |
| review_ch11_task_lifecycle_projection(observer/aggregate/harness/表) | ✅ 12.5(投射表+两消费面;spec 要求的「projection Mermaid 图」以表格呈现,表格信息量等同,C1 已认可该形态) |
| review_ch11_agent_orchestrator | ⚠️ 本章有意收窄:`InProcessAgentOrchestrator` 仅在全景图作节点出现,`run_native_specialist`/trait 默认方法未展开——这是黑板决策(Ch12 只讲并发原语,orchestrator 细节归 Ch18),spec 场景按分层决策由 Ch18 承接,非本章缺陷 |
| review_ch12_facts_sheet / three_layers / supervisor / renumber / refs_valid | ✅ 事实表复现、三层各≥2 行号引用、supervisor 四件套行号、文件名 ch12、抽查引用零失效 |

## 7. Minor 清单(不阻塞定稿)

| # | 位置 | 问题 | 建议 |
|---|---|---|---|
| m1 | 12.6 scheduler 段 | 六变体+优先级枚举与 Ch5 §5.10 各述一遍,逼近重复上限 | Ch12 侧压缩变体清单,保留 TOCTOU/External 论证 |
| m2 | 12.9 延伸阅读 | ` shutdown{} ` 模式名不似 Tokio 真实文档术语 | 改为 `Runtime::shutdown_timeout` 表述或删除该条 |
| m3 | 12.5 投射表 Parked 行 | 行内行号引用与同表其他行风格不一 | 统一格式 |

## 8. 是否可定稿

**可定稿。** 机制描述逐条与 `9c157101` 源码亲测一致(含 supervisor 重放水位线 780-793、Parked→Cancelled #27c 投射、default 10、四部谓词、#1973 注释、Release/Acquire 内存序);三层 why 论证齐全;跨章边界处理符合黑板分层决策;三条 minor 均为润色级,可留给后续统一编校,不需要再开一轮 C1/C2 迭代。
