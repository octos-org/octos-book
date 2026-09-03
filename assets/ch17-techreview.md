# Ch17 techreview(C2)审查报告

- **审查对象**:`chapters/ch17-swarm.md`(master @ 3f91f38 拷入)
- **事实基准**:`assets/ch17-facts.md`;源码只读 @ `9c157101`(二者 commit 已现场复核一致)
- **规范**:`specs/ch17-swarm.spec.md`
- **审查日期**:2026-09-03;审查员:C2(ch17-techreview,lane strong)
- 方法:逐条打开源码文件比对行号引用与机制陈述;跨章重复用逐行精确匹配比对 Ch6/Ch12/Ch16。

## 计数表

| 级别 | 数量 | 说明 |
|---|---|---|
| Critical | **0** | 无机制性错误 |
| P1(应修) | **1** | Pipeline 折叠形状只写了非对象分支,对常见 object task 不成立 |
| P2(建议) | **2** | 「四类策略」归纳与前文五项自相矛盾;事实表自身一处枚举错误 |
| 信息性 | 2 | 不阻塞 |

**结论:可定稿(修 1 处 P1 一句话后定稿更稳;P1 是描述不完备,非方向性错误)。**

---

## 1. 机制描述正确性(检查项 1)

### 1.1 门禁三道 — ✅ 正确

- **GateDenial 折叠**:`enforce_or_outcome`(gate.rs:25,实测 `pub(crate) async fn` 正是 :25)调 `enforce_dispatch_gates`(dispatch_policy.rs:292,实测一致;后端感知变体 :303 ✓),denial 折叠为 `SubtaskOutcome{status: TerminalFailed, last_dispatch_outcome: 拒绝标签, error: reason}`——与 gate.rs:25-54 逐字段吻合。模块文档「与 SpawnTool agent_mcp 分支同走一套检查,#701/#714 单一绕过面」章文转述准确。
- **五项固定顺序**:章文「沙箱→工具策略→env 黑名单→env 白名单→审批,黑名单先于白名单」与 dispatch_policy.rs:284-289 文档注释及 :313-405 实现顺序完全一致。
- **四类策略**:章文归纳为「工具策略、审批、env allowlist、sandbox 要求」。⚠️ 见 P2-1:`DispatchPolicy` 实为 6 字段(tool_policy / require_approval / approval_requester / env_allowlist / env_denylist / require_sandboxed,dispatch_policy.rs:121-146),env 检查是 denylist+allowlist 两道;brief 的「四类策略」框架章文已落实,但归纳句漏掉黑名单,与它自己前一句的五项列举不齐。
- **子任务校验门**:`gate_subtask_validators`(dispatcher.rs:593 ✓)只对 `Completed` 跑 Completion 相位校验器、required 失败降级 `TerminalFailed`、「已失败不双重惩罚」——与 :593-620 实现及注释逐点吻合;测试锚 `subtask_contracts.rs:123` ✓。
- **聚合校验门**:`run_aggregate_validator`(dispatcher.rs:693 ✓)在全部子任务终态后跑、verdicts 写入 `SwarmResult.validator_results` 不改子任务状态——与 :693-716 及主循环 :395-398(先 run_aggregate 再 from_parts)一致。mermaid 图 17-3 的三道位置、拒绝标签集(`policy_denied`/`approval_unavailable`/`sandbox_required`/`env_forbidden`)与 GateDenial 文档(:254-258)一致。
- 9 个 policy 用例行号(:134/:180/:224/:264/:319/:366/:428/:469/:506)全部与 `grep -n 'async fn'` 实测一致;:469 回归锚(无策略照常派发)语义对应 `policy.is_noop()` 短路(:312)。

### 1.2 幂等三件套 — ✅ 正确

- **finalized + final_result(#1718)**:persistence.rs:59-66 逐字快照语义、重放原样返回、旧行退回重算——章文与源码注释一致;测试锚 :821 ✓。
- **contracts_fingerprint(#1719)**:`ensure_record_matches_dispatch`(章文写「dispatcher.rs:856 附近」,实测 fn 签名约 :858,措辞「附近」成立;InFlightGuard :833 ✓)做 topology/count/slot-id 三重前置检查 + sha-256 指纹(排序键、`label` 刻意排除、只暴露哈希不泄 payload)——章文「同 id 换契约表、换 task 负载、换拓扑都被拒绝」准确;「修复前越界 panic 或张冠李戴」与源码注释(:851-855)一致。
- **InFlightGuard 拒并发**:RAII insert/drop-remove,:833-861 实测;第二个同 id 调用 bail 而非排队——「拒并发」措辞正确;测试锚 :1100 ✓。
- 账本细节:schema v1 高版本行按不存在处理(persistence.rs:172-175 ✓)、`io_gate` owned-guard 移入 `spawn_blocking` 使取消的写仍有序落盘(:93 注释 + load/store 实现 ✓)、每轮写回而非攒批(:392 ✓)均与源码吻合。

### 1.3 编排三原语不变量互斥论证 — ✅ 成立

- 三执行路径与四变体的关系(Parallel|Fanout 共用 `run_parallel_round`,dispatcher.rs:361-368 ✓);三函数行号 428/478/518 实测一致。
- Sequential「首个 TerminalFailed 即中止、后续 not_run」✓(:493-501 + 恢复路径前置检查 :485-492);Pipeline「前驱非 Completed 不派发」✓(:528-537);并发度恒 1(topology.rs:143 ✓)。
- 「enum 而非 struct ⇒ 类型层面杜绝『Sequential 但并发 3』」论证成立:Sequential/Pipeline 变体确实不携带 max_concurrency 字段(topology.rs:98-110)。三条不变量(吞吐可调/失败即停/依赖即序)与各自代码语义对得上,互斥论证不是修辞。
- 重试预算:「3 轮、只有零进展轮消耗、轮前检查」三点全对(MAX_RETRY_ROUNDS=3 @ dispatcher.rs:60;progress 才不加 round @ :384-392;`round >= max_rounds` 先断 @ :343-348)。

### 1.4 ⚠️ P1:Pipeline 折叠形状只描述了 else 分支

章文 17.2:「折叠的具体形状是:后继契约的 task 被包成 `{"original_task": …, "pipeline_input": 前驱输出}` 的对象」。

源码 dispatcher.rs:549-558 是**两个分支**:
- `task` 是 JSON **Object**(契约的常态)→ 直接 `obj.insert("pipeline_input", String(prev))`,**不**包 `original_task`;
- `task` 非 Object → 才包成章文所述的 `{"original_task": …, "pipeline_input": …}`。

章文把兜底分支当成了唯一形状,对最常见的 object task 描述失真。**修法(一句话)**:「若 task 已是对象则直接注入 `pipeline_input` 键;否则包成 `{"original_task": …, "pipeline_input": 前驱输出}`,前驱输出以字符串形态注入」。证据:dispatcher.rs:549-558;测试 `should_chain_pipeline_output_as_next_input`(swarm_dispatch.rs:330)。

### 1.5 MCP vs spawn 取舍 — ✅ 公平(检查项 2)

论证四层:故障域(子 agent 膨胀/死锁拖垮 supervisor)、异构性(claude/codex 各有工具面与计费)、信任边界(外部系统待遇:过门禁、过校验、落账)、协议耦合面(`tools/call` 形状即全部耦合)。**公平性合格**:明确承认本地 spawn 的两项优点(零协议开销、状态天然可见)并给出双向选择标准,不是单方面贬低。侧栏「为什么与 Fleet 并列」给三层理由(失败模型/信任边界/演化节奏)并点名代价(两套持久化文件),`SCHEMA_VERSION 已到 3`(octos-fleet/src/records.rs:33 实测)属实。论证层数达标。

## 2. 跨章重复(检查项 3)— ✅ 通过

对 Ch6(`ch06-tool-system.md`)、Ch12(`ch12-concurrency.md`)、Ch16(`ch16-fleet.md`)做逐行精确匹配(>25 字符行):**重复 0 行**,远低于 ≤3 行红线。17.8 边界小节以「是什么关系/不共享机制」收束,未复述相邻章机制细节。

## 3. 结构与图表(检查项 4)— ✅ 通过

- **DDIA 叙事线**:契约(数据模型)→ 拓扑(执行形状)→ 时序(一次 dispatch)→ 后端抽象 → 门禁 → 幂等账本 → 成本 → 边界,由具体到通用、每节绑定不变量,符合本书范式。
- **mermaid 图 17-1** 与文字一致:三子图行号 428/478/518 实测正确;「Sequential 中止整批 vs Pipeline 斩链保留前段」与两函数返回语义吻合;并发度恒 1 标注正确。
- **图 17-2 时序**与 `dispatch()`(dispatcher.rs:246-425)逐步对得上:acquire→load→finalized 短路→store 初始→loop{enforce(经 dispatch_with_budget 先于 reserve/commit,:976-984)→dispatch→gate→store}→aggregate→finalized→store→emit;三个测试锚行号 560/821/1100 实测一致。「失败事件把首个未完成子任务错误顶到 message」与 build_event(:1099-1112)一致。
- **图 17-3** 见 1.1,一致。

## 4. 引用风格与引用有效性(检查项 5)— ✅ 通过(pathfix 后)

全部源码引用为 `crates/...` 全路径 + 行号。抽查 30+ 处全部命中:mcp_agent.rs:411/266/218/182;serve.rs:420/427/433/439/1867;Cargo.toml:32(`octos-swarm = { workspace = true }` 实测);gate.rs:25;dispatch_policy.rs:292/303;dispatcher.rs:60/92/246/428/478/518/593/693/833/971/1053;result.rs:20/58/145;persistence.rs:27/36/93/110/147/178;topology.rs:27/37/59/72/98/133/143;swarm_dispatch.rs:560/821/1100/1462;subtask_contracts.rs:123。规模表 7 文件行数与 `wc -l` 完全一致,src 2,505 + tests 2,475 = 4,980,1:0.99,36=23+9+4 用例——零漂移。

## 5. P2 与信息性

- **P2-1**(17.5):前句五项检查列举正确后,归纳句「四类策略(工具策略、审批、env allowlist、sandbox 要求)」漏掉 env 黑名单,建议改「env 检查(denylist+allowlist)」以自洽。
- **P2-2**(事实表,非章文):`assets/ch17-facts.md` §3.4 把 `SubtaskStatus` 列为四变体 `Completed / RetryableFailed / TerminalFailed / Aborted`——**源码 result.rs:20-27 只有三变体**,`Aborted` 属于 `SwarmOutcomeKind`(result.rs:117-128)。章文自身没有犯此错(通篇「三类终态」正确),建议修事实表该行,避免后续校对以讹传讹。
- **信息性**:17.4 排版上「为什么走外部 MCP 后端」段落插在四标志引入句与标志代码块之间,阅读顺序略跳(先抛问题再给标志),可把标志块前移;不影响正确性。
- **信息性**:章文称 dispatch 上限「在 dispatch 入口强制(dispatcher.rs:246)」,实际经 `budget.effective_max_contracts()`(默认即 `MAX_CONTRACTS_PER_DISPATCH`)——表述成立,只是默认值路径可提一句。

## 是否可定稿

**可定稿。** 0 critical;唯一 P1(Pipeline 折叠两分支只写其一)为一句改写;两处 P2 均不涉机制方向。机制、行号、图表、跨章边界、公平性全部通过源码实测。
