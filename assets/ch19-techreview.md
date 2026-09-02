# Ch19 技术审查报告(C2 techreview)

- 审查对象: `chapters/ch19-octoscode.md`(master 定稿 1780f0d 拷入)
- 事实基准: `assets/ch19-facts.md`;源码只读两仓(octoscode @ 1129fa3、octos @ 9c157101、herdr @ fefe5c4f,均已实测核对 HEAD)
- 规范: `specs/ch19-octoscode.spec.md`
- 审查日期: 2026-09-03

## 0. 计数表

| 严重度 | 数量 | 条目 |
|---|---:|---|
| Critical | 0 | — |
| Major | 2 | M1, M2 |
| Minor | 5 | m1–m5 |
| 共复核引用锚点 | 47 处 | 全部命中,零越界,零错位 |

**结论:可定稿**(无 Critical;M1/M2 为措辞精度问题,不构成事实错误,可在下一轮顺手修)。

## 1. 机制描述正确性(检查项 1)

### 1.1 哑客户端边界(ARCHITECTURE Scope)—— ✅ 正确

正文 19.1 引用的 Scope 原文逐字与 `octoscode/docs/ARCHITECTURE.md:3` 一致("does not run the Octos agent, execute tools, approve commands, maintain the durable ledger, or own provider/model configuration")。五项清单翻译(不运行 agent、不执行工具、不做审批决定、不维护持久账本、不持有 provider/model 配置)与原文五个动词一一对应,无增减。

TUI owns / Server owns 清单(正文 :11)与 `docs/ARCHITECTURE.md:3-27` 的 Scope 节两份清单逐项对得上:TUI 侧渲染/键盘、视图状态、乐观 prompt 显示、本地 slash(`/ps` `/stop` `/help`)、翻译为 `AppUiCommand`;Server 侧 session 创建与 cwd 校验、agent 执行、shell/工具与沙箱、审批、task supervisor、ledger+replay+`protocol/replay_lossy`、diff/任务输出。✅

Architectural Invariants 转述(正文 :13,锚 `docs/ARCHITECTURE.md:713`)与 `:713-724` 实测六条全部对应:不得调运行时内部、不得依赖 M9 内部、服务端权威七项、服务端不得要求 TUI 特有行为、新能力先落 octos-core、提示词整形属服务端 profile/harness 契约。✅

### 1.2 启动链五步 —— ✅ 正确(含一个 Minor 锚点精度)

- `fn main()` @ `octoscode/src/main.rs:4` ✅(实测 `sed -n 4p` 命中)
- 拦截 `update`/`doctor` @ `:10` ✅(实测注释块首行);正文引代码块与 `main.rs:4-28` 逐行一致(仅注释略译,合规)
- `ensure_octos_backend(&mut cli)` @ `:22` ✅;实现 @ `octoscode/src/backend_ensure.rs:113` ✅(实测 `pub fn ensure_octos_backend(cli: &mut Cli)` 在 :113)
- `splash::play(&cli)` @ `main.rs:26` ✅;`event_loop::run(cli)` @ `main.rs:27`,函数体 @ `octoscode/src/event_loop.rs:192` ✅
- `DEFAULT_STDIO_COMMAND` 值 `"octos serve --stdio --solo"` @ `octoscode/src/cli.rs:118` ✅ 逐字一致;缺省回填 `:415`/`:849` ✅(实测两处均为 `DEFAULT_STDIO_COMMAND` 引用)

**19.2 的「四个提前返回」清单已逐条与 `backend_ensure.rs:113-162` 对照**:非 Protocol 模式(:117)、`stdio_command` 为 None 即 WS(:122)、非裸 octos(:125)、已在 PATH(:130)。✅ 全部准确。正文「新装完成后改写为 `~/.octos/bin/octos`」对应 `rewrite_program` + `Resolved::AtPath` 分支(:143-161),准确;正文未提的 Windows 不改写分支(:136-141)属实现细节,不写不算错。

mermaid 启动链时序图与文字五步一一对应,参与方命名用文件名,一致。✅

### 1.3 reducer 双入口纪律(与 Ch18 GoalLedger 的镜像论证)—— ✅ 论证成立,细节有一处需修(M1)

- `pub struct Store` @ `octoscode/src/store.rs:287`,唯一字段 `AppState` ✅(实测 :287-290:`pub struct Store { pub state: AppState }`)
- `from_snapshot` @ `:423` ✅;`apply_client_event` @ `:8241` ✅(签名逐字一致,返回 `Option<AppUiCommand>`);`apply_event` @ `:9063` ✅(同)
- `apply_client_event` 内部首臂即 `ClientEvent::App(event) => self.apply_event(*event)`(实测 :8245),正文「双入口、客户端事件与服务端事件」表述与实现一致 ✅
- Snapshot 分支克隆本地字段(正文 :128 列 command history、sub_providers、composer 草稿与 pending 消息)——实测 `store.rs:9066-9110` 起逐条克隆 `composer_history`、`sub_providers_state`、`composer/composer_drafts`、`pending_messages(_by_session)` 等,与正文列举相符(实际清单长得多,正文用了「一批纯本地字段」概括,可接受)✅
- 「Ch18 GoalLedger 用 39 个方法把状态转移收进一个 impl 块」——实测 octos 仓 `crates/octos-fleet/src/sqlite_ledger.rs` 的 `impl GoalLedger` 块内 `pub fn` 计数 = **39** ✅(镜像论证的数字成立)

**M1(措辞精度)**:正文 19.4 说「架构文档的 Client Layers 表给它的职责描述是『snapshots, RPC results, notifications, local commands, approvals, diffs, task output and queued prompts folded into AppState』」并把英文清单数成「八类输入一个入口」。实测 `docs/ARCHITECTURE.md:507`(Client Layers 表 store.rs 行)原文即这串;但 Client Layers 表标题是 `## Client Layers` @ :476,子节 Core loop and state @ :497——正文未给该表行号,且「一个入口」的说法与 reducer 实为双入口(本章自己反复强调)略有张力,建议改为「八类输入、双入口折叠」。属措辞,非事实错误。

**m1(锚点差一)**:`drain_backend_events` 实测定义在 `event_loop.rs:756`(正文 :111 写 `:755`,该行是文档注释首行);`apply_client_event_and_send_followup` 实测 :816 ✅;`drain_pending_autonomy_hydration` 实测 :829(正文写「:830 附近」,可接受);`send_command` 实测 :835(正文写「:833 起」,该行在函数体内注释前,可接受但偏松)。建议把 `:755` 改 `:756`。

### 1.4 UI Protocol 契约面(UiCommand/UiNotification/compare_protocol)—— ✅ 正确(一处 Major 措辞)

全部 wire 锚点实测命中(octos @ 9c157101,`crates/octos-core/src/ui_protocol.rs` 共 7,221 行):
`RpcRequest<T>`:684、`RpcResponse<T>`:708、`RpcNotification<T>`:730、`RpcError`:752、`EventEnvelope<P>`:68、`UiProtocolVersion`:1553、`UiProtocolCapabilities`:1577、`ProtocolCompat`:1777、`compare_protocol`:1814、`TurnStartParams`:1999、`ApprovalDecision`:2074、`TurnLifecycleState`:3031、`Payload`:3803、`PayloadV2`:4059、`UiCommand`:4197、`UiRpcResult`:4760、`UiNotification`:6616、`UI_PROTOCOL_V1`="octos-ui/v1alpha1":20。✅ 零越界零错位。

- `compare_protocol` 三态语义:实测 `:1798-1826` 决策序为 family 不匹配或 server schema 更旧 → `SchemaIncompatible`;缺必需 feature → `MissingFeatures`(按请求顺序携带缺失名);否则 `Compatible`。正文 :140 的表述(「协议族不同或服务端 schema 更旧判 SchemaIncompatible(服务端更新是允许的,加法式前向兼容),族与版本兼容但缺必需 feature 判 MissingFeatures」)与源码注释逐条一致 ✅
- 「比较器是纯函数,客户端与服务端复用同一个,skew 判定不会分叉;`octos-diagnostics` 只是把结果包装成报告行」——实测 `:1773` 文档注释即 "`octos-diagnostics` wraps the result of [`compare_protocol`] into a..." ✅
- `into_protocol` @ `crates/octos-core/src/app_ui.rs:146` ✅(实测 `pub fn into_protocol(self) -> UiCommand`);`AppUiEvent` 五变体(Snapshot/Protocol/Progress/Status/Error)@ `app_ui.rs:172` ✅;`From<AppUiEvent> for ClientEvent` @ `octoscode/src/client_event.rs:132` ✅;`ClientEvent` @ `:25` 首变体 `App(Box<AppUiEvent>)` ✅
- `AppUiCommand::method()` @ `octoscode/src/model.rs:915` ✅
- `LocalShellExec` 客户端拦截:实测 `octoscode/src/transport.rs:2280` `if let AppUiCommand::LocalShellExec {..} = command`。**M2**:正文 :138 写「传输层在 `octoscode/src/transport.rs:2247` 起的实现里先拦截它」,:2247 是 `impl AppUiBackend for ProtocolAppUiBackend` 的 `bootstrap` 开头附近,拦截实际在 :2280——「:2247 起」指向 impl 块整体尚可辩解,但精确应写 `:2280`。判 Major(行号指向的段落不含所述行为)。

mermaid 19.5 消息流图与文字一致(AppUiCommand → into_protocol → UiCommand → JSON-RPC → UiNotification → ledger → replay event_seq)✅。

## 2. 技术公平性与论证层数(检查项 2)—— ✅

- 哑客户端取舍侧栏(19.1 工程决策)给出三得(安全边界唯一化、可替换、观测外置)一失(协议必须厚,7,221 行 wire 类型是账单),非单向吹捧 ✅
- 「薄的是职责,不是代码量,把交互做厚、把权限做薄,本身是重活」(:15)与体量数据(26 文件 96,124 行,实测 `ls src/*.rs | wc -l`=26、`wc -l` 合计 96,124 ✅)自洽
- mock 模式边界如实写明「不得用来验证服务端策略、沙箱、provider 配置、账本持久化或工具执行」,与 `docs/ARCHITECTURE.md:653-659` Mock Mode 逐项一致 ✅
- Client Layers 表行数滞后问题正文 :130 主动披露(event_loop 7,047 vs 实测 8,655;store 37,021 vs 43,935,实测表内数字 `docs/ARCHITECTURE.md` Client Layers 表命中),并声明以事实表为准——这是公平性加分项 ✅
- 思考题 5 道全部可从本章内容推导,无超纲;第 3 题对 `MissingFeatures` 边界的追问是真实的开放问题 ✅

论证层数:每个论断基本都有「源码锚 + 架构文档引文 + 作者解读」三层,解读未越过证据。达标。

## 3. 跨章重复(检查项 3)—— ✅ 合规

- 与 Ch10(harness 事件 ABI):仅 19.8 一句边界声明「HarnessEvent 及其 schema 常量是服务端运行时内部的事件契约,客户端看到的只是经 UiNotification 投影后的通知;两层的版本化机制不同,本章不重复展开」——零机制复述 ✅
- 与 Ch21(herdr):19.7 全节约 9 行,只列三条规则事实(锚点 `herdr/src/detect/manifests/octoscode.toml:8/:21/:30`,实测 :8 `approval_blocked`、:21 `statusbar_working`、:32 `statusbar_idle`——**m2**:第三条正文写「:30」,实测 `[[rules]]` 在 :31、`id = "statusbar_idle"` 在 :32;:30 是空行。差两行,Minor)并声明「完整语义与 herdr 引擎的通用机制留给第 21 章」,≤3 行机制层面内容 ✅
- 与 Ch14:stdio/stdout/数据目录锁仅客户端侧引用并回指,未复述 serve 侧机制 ✅
- 与 Ch18:服务端 goal/peer 明确让位(19.6 首句),只讲解析层 ✅

## 4. 结构(检查项 4)—— ✅

- DDIA 叙事线:边界(为什么)→ 启动链(怎么起来)→ 传输(怎么连)→ reducer(状态怎么折叠)→ 协议(合同长什么样)→ autonomy(上层功能客户端半边)→ herdr(外部观测)→ 回顾。从具体入口到抽象契约再到外环闭环,层次递进合理 ✅
- mermaid 共 3 张:启动链时序图(19.2)、reducer 数据流(19.4)、协议消息流(19.5),均已逐一与对应文字段落比对一致,无图中出现而文字未讲的元素 ✅

## 5. 引用风格与「附近」措辞清单(检查项 5,pathfix 后)

全章 47 个带行号锚点已逐一实测。引用风格全部为全路径(`octoscode/src/*.rs`、`crates/octos-core/src/*.rs`、`octoscode/docs/ARCHITECTURE.md`、`herdr/src/detect/manifests/octoscode.toml`),符合 spec 的引用格式决策 ✅。autonomy 小节内部短引用(`:35`、`:66` 等)均在同段已建立全路径上下文之后,属规范允许的「同文件续引」。

**模糊锚点(「附近/起」)清单,共 5 处:**

| # | 正文位置 | 写法 | 实测精确值 | 建议 |
|---|---|---|---|---|
| 1 | :88 | `octoscode/src/transport.rs:997` 附近(注释) | :997 即注释行 ✅ | 可去「附近」 |
| 2 | :90 | `octoscode/src/transport.rs:354` 起 | :354-356 为注释+常量 ✅ | 合规,可保留 |
| 3 | :92 | `octoscode/src/transport.rs:2235` 起的实现 | :2235 impl 块 ✅ | 合规 |
| 4 | :111 | `event_loop.rs:786` 附近 / `:833` 起 | :783 / :835 | 改精确值 |
| 5 | :111 | `event_loop.rs:755` | :756 | **必改**(差一) |

无路径短引用:0 处(除上述同文件续引)。「附近」措辞密度在可接受范围,建议至少修 #5。

## 6. 汇总:问题清单

| 编号 | 严重度 | 位置 | 问题 | 建议修法 |
|---|---|---|---|---|
| M1 | Major | 19.4 :103 | 「八类输入一个入口」与本章「双入口」叙事自相张力 | 改「八类输入、双入口折叠」 |
| M2 | Major | 19.5 :138 | `LocalShellExec` 拦截写「`:2247` 起的实现里」,实际拦截在 `:2280` | 改 `octoscode/src/transport.rs:2280` |
| m1 | Minor | 19.4 :111 | `drain_backend_events` 锚 `:755` 差一 | 改 `:756` |
| m2 | Minor | 19.7 :171 | `statusbar_idle` 写「:30」,实测规则头 `:31`、id `:32` | 改 `:31` 或 `:32` |
| m3 | Minor | 19.4 :111 | `:786 附近`/`:833 起` 偏松 | 改 `:783`/`:835` |
| m4 | Minor | 19.6 :161 | 「六个命令族」列举 Agents/Task/Thread/Turn/Goal/Loop 共六个,但 facts 表还列 `AgentArtifactSelector`/`TaskArtifactSelector` 选择器(正文 :163 已单独讲),计数无错,仅提示读者勿把选择器误计为第七族 | 可不改 |
| m5 | Minor | 19.4 :130 | Client Layers 表行数对照给出了 store 37,021,但未给 transport(10,721 vs 12,214),例证略单薄 | 可不改 |

## 7. 是否可定稿

**可定稿。** 零 Critical;两个 Major 均为锚点/措辞精度问题,不涉及机制理解错误;47 处行号锚点实测命中率高(44 精确命中、3 处「附近/起」类中 1 处差一)。M1/M2/m1/m2 建议在终稿前顺手修掉,不阻塞 C1 定稿流程。

— C2 techreview,迭代 8/35
