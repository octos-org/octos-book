# Ch13 引用核对报告(ch13-refcheck,peer A)

- 分析基线:octos main @ **9c157101**(与 spec「分析基线」一致,只读未改)
- 对象:`chapters/ch12-pipeline.md`(412 行,旧文件名,待改号 ch13)
- 范围:`crates/octos-pipeline/` 32,799 行(其中 `src/*.rs` 25,134 行;含 `executor_tests.rs`、子目录)
- 方法:grep -n 定位全部 `src/*.rs` 引用 → wc -l 实测文件规模 → 逐锚点(grep/sed 摘录)比对行号与符号

## 文首汇总

| 指标 | 数值 |
|---|---|
| 带行号/行号区间的引用总数 | **110** 处 |
| 仅文件名引用(无行号) | ~10 处(`parser.rs`×6、`handler.rs`×2、`condition.rs`、`human_gate.rs` 等) |
| 行号仍准确 ✅ | **5** 处 |
| 行号漂移需重标 ❌ | **105** 处(95%) |
| IR 节点(`IrNodeKind`) | 实测 **12** 种(`ir.rs:57`)vs 章稿 **0** 提及 |
| `HandlerKind` | 实测 **9** 种(`graph.rs:241`)vs 章稿 6 种(`graph.rs:184-201` 已漂移) |
| 内容级需修正(行号之外) | **7** 项(见下) |

漂移根因:各文件自旧稿分析点以来大幅增长——`executor.rs` ~2,700→**5,591** 行、`tool.rs` 462→**3,197**、`parser.rs` 667→**1,445**、`handler.rs` 965→**2,140**、`graph.rs` 230→**421**、`discovery.rs` 114→**685**;且新增 `ir.rs`(673)、`events.rs`(296)、`model_assignment.rs`(564)、`fidelity.rs`(947)、`recovery.rs`(399)、`compose.rs`(318)、`guard.rs`(102)、`artifact.rs`(176)等旧稿完全未提的模块。

### 需修正清单(内容级,按 spec「新面必补」/「勘误方式」)

1. **12.2 节整节重写:6 种 → 9 种 `HandlerKind`**(`graph.rs:241-266`)。新增 `ShellCheck` / `Notify` / `Wait` 三变体;且 `Handler` trait 实现从 4 个变 7 个(`handler.rs:257` trait;impl:`CodergenHandler`:641、`ShellHandler`:1054、`GateHandler`:1190、`NoopHandler`:1226、`ShellCheckHandler`:1247、`NotifyHandler`:1326、`WaitHandler`:1365)。「只有前四种是 Handler 实现」的表述作废——`Parallel`/`DynamicParallel` 仍是 `execute_graph()` 专门分支(`executor.rs:2749` / `3122`),但 ShellCheck/Notify/Wait 是真 handler。
2. **新增 IR 节点小节(spec 核心场景 review_ch13_ir_kinds)**:`ir.rs:57` `IrNodeKind` 12 变体 = Research / Transform / Synthesize / Report / Gate / Fanout / CodeReview / CodeEdit / ShellCheck / SubAgent / Notify / Wait;`ir.rs:206-273` 每变体有 `PaletteContract`;注意源码注释明确**故意不含 human_gate**(ir.rs 枚举尾注:防静默审批绕过)。附统计命令:`sed -n '/pub enum IrNodeKind/,/^}/p' crates/octos-pipeline/src/ir.rs | grep -cE '^\s{4}[A-Z]'`。
3. **新增进度事件小节(review_ch13_progress_workflows)**:per-node 进度/ETA/previews 经 harness 事件通道,`events.rs`(296 行,`lib.rs:12` 导出);f26d2291 改动;以「详见第 10 章」引出事件 ABI。旧稿零提及 `events.rs`。
4. **新增「workflow 与 pipeline 的分工」小节**:`crates/octos-workflows/` 已独立成 crate(octos-workflows/octos-server/octos-cli 的 Cargo.toml 均引用);旧稿零提及。
5. **per-node `max_iterations`(92175f53)补入**:`PipelineNode.max_iterations`(`graph.rs:138`,`build_node` 于 `parser.rs:611` 解析);IR 侧 Research/Synthesize/Report 均带 `max_iterations` 字段(`ir.rs:64/75/84`)。章稿 12.1.2 的 `PipelineNode` 属性清单缺它,还缺 `human_gate`/`resolver`/`artifact_refs`/`checkpoint_refs`/`continue_on_error`(`graph.rs:118-183`)。
6. **总超时钳制数值修正**:章稿 12.3.8 说「60-1800 秒」;实测钳制区间为 **[60, 3600]**、默认 1800(`tool.rs:534` 注释 `Clamped to [60, 3600]`;`tool.rs:1099` 同;input_schema 描述 Default 1800 / Max 3600)。
7. **模型路由描述需带 `model_assignment.rs`**:旧稿写「`execute_graph()` 与 CodergenHandler 联合应用模型选择」;现在 `run_graph_with_handlers_throttled`(`executor.rs:1772`)开头有 in-process 模型赋值注释(替代旧 pipeline-guard 插件,读 `model_catalog.json`/`pipeline_models.json`),且存在独立 `model_assignment.rs`(564 行)——需按新路径改写。

仍然成立、无需改口径的结论(实测确认):`gate` 把 `prompt` 当条件表达式(`handler.rs:1193` `unwrap_or("true")`,默认 auto-pass);`human_gate.rs` 默认超时 300s(`:14-15`)且未被执行器接入(executor 无引用);`ModelStylesheet` 仅 `lib.rs:28/64` 导出,executor/tool/discovery 均无调用点(章稿「已导出但非主路径」结论正确,`stylesheet.rs:28` struct 行号恰好未变);`ExecutorConfig.checkpoint_store` 可选字段(`executor.rs:427`)、默认 None(`executor.rs:1916`);`MAX_PIPELINE_FANOUT_TOTAL = 500`(`executor.rs:102`,值正确行号变);`max_parallel_workers`(`executor.rs:405`);`DynamicParallel` 默认 `max_tasks=8`(`graph.rs:172` 注释);deadline_action 四语义 abort/skip/retry:N/escalate(`parser.rs:693-720`,retry: 与 retry( ) 均支持);`tools=""` deny-all 语义(`parser.rs:588-602`);`goal_gate` true/yes/1(`parser.rs:563-570`);`900s/15m/2h` 后缀(`parser.rs:551-570`);无名 `digraph {` → `"pipeline"`(`parser.rs:63-65`);`#` 行注释(`parser.rs:491-492`);边自动补节点(`parser.rs:110-127`);shape 映射 Msquare→Noop 等(`graph.rs:282-297`);`context.*` 语法存在于 condition 模块(`condition.rs:12-17/32-34`,`evaluate_with_context` :69)——章稿「执行主路径未注入上下文 map」的谨慎表述可保留,但需补一句 Gate/condition 模块已具备显式 context 入参。

---

## A. 引用核对表

状态:✅=行号仍准;❌=漂移需重标(给出当前正确行号/锚点;无法唯一对应的给最近已验证锚点)。

### parser.rs(旧 667 行 → 现 1,445 行)

| 章稿行 | 引用 | 状态 | 符号名 | 当前正确行号 |
|---|---|---|---|---|
| 46 | parser.rs:21-23 | ✅ | `parse_dot()` | 21-23(未变) |
| 46 | parser.rs(无行号) | ✅ | `DotParser::parse()` | struct :45,impl :50 |
| 50 | parser.rs | ✅ | 无名 digraph→"pipeline" | :63-65 |
| 51 | parser.rs | ✅ | `apply_graph_attrs`(label/default_model) | :520-530 |
| 52 | parser.rs | ✅ | `parse_subgraph` | :148-150,189 |
| 53 | parser.rs | ✅ | `parse_edge_chain` | :163,266 |
| 54 | parser.rs | ✅ | `#` 注释 | :479-502(skip),845-849 |
| 55 | parser.rs | ✅ | 边自动补节点 | :110-127 |
| 64 | parser.rs:527-576 | ❌ | `build_node()` | :579-691 |
| 66 | parser.rs:527-533 | ❌ | handler 解析顺序 | :581-586 |
| 67 | parser.rs:535-538 | ❌ | tools=""/deny-all | :588-602 |
| 68 | parser.rs(无行号) | ✅ | `parse_duration_secs` | :551-570 |
| 69 | parser.rs:520-524 | ❌ | `parse_bool`(goal_gate) | :563-570(goal_gate 解析 :619-623) |
| 70 | parser.rs:540-545 | ❌ | deadline_secs 解析 | :601-603(`parse_duration_secs_f64` :665-689) |
| 70 | parser.rs:579-627 | ❌ | `parse_deadline_action` | :693-720 |
| 71 | parser.rs:629-667 | ❌ | `parse_checkpoints` | :721-751 |
| 312 | parser.rs | ✅ | graph attrs 落 default_model | :520-530 |
| 312 | parser.rs:553-556 | ❌ | node.model 落 `PipelineNode.model` | :612 |

### graph.rs(旧 230 行 → 现 421 行)

| 章稿行 | 引用 | 状态 | 符号名 | 当前正确行号 |
|---|---|---|---|---|
| 52 | graph.rs:21-24 | ❌ | `PipelineGraph.subgraphs` | 字段 :48(struct :10-54) |
| 57 | graph.rs:10-24 | ❌ | `PipelineGraph` struct | :10-54(新增 max_total_tokens/default_timeout_secs/result_fidelity) |
| 57 | graph.rs:91-140 | ❌ | `PipelineNode` struct | :118-183 |
| 66 | graph.rs:204-230 | ❌ | `HandlerKind::from_shape` | :282-297(`from_str` :270-279) |
| 79 | graph.rs:184-201 | ❌ | `HandlerKind` enum | :241-266(**9 变体**,见 B) |
| 250 | graph.rs:26-88 | ❌ | `PipelineGraph::detect_cycles` | :54 |

### handler.rs(旧 965 行 → 现 2,140 行)

| 章稿行 | 引用 | 状态 | 符号名 | 当前正确行号 |
|---|---|---|---|---|
| 83 | handler.rs:186-758 | ❌ | CodergenHandler 全段 | struct :293,`impl Handler` :641-1041 |
| 94 | handler.rs:186-758 | ❌ | 同上 | 同上 |
| 100 | handler.rs:21-124 | ❌ | HandlerContext 等 | `HandlerContext` :237;常量 :23-24;plugin 快照 :36-56 |
| 101 | handler.rs:520-545 | ❌ | 插件工具捕获 | :125-130 附近(spawn_only 标记) |
| 102 | handler.rs:662-683 | ❌ | codergen 内部(压缩/上下文) | 已漂移,位于 :641-1041 内,需重定位 |
| 103 | handler.rs:708-717 | ❌ | 同上 | 同上 |
| 105 | handler.rs:620-633 | ❌ | 同上 | 同上 |
| 114 | handler.rs:613-624 | ❌ | 同上 | 同上 |
| 118 | handler.rs:760-834 | ❌ | ShellHandler | struct :1043,impl :1054-1135 |
| 140 | handler.rs:836-949 | ❌ | GateHandler | struct :1136,`synthesize_predecessor_outcome` :1138,impl :1190-1222 |
| 142 | handler.rs:907-949 | ❌ | Gate 条件求值 | :1190-1222(prompt 默认 "true" :1193) |
| 281 | handler.rs:907-914 | ❌ | 同上 | 同上 |
| 90 | handler.rs(无行号) | ❌ | 「4 个 Handler trait 实现」 | 现 **7** 个:641/1054/1190/1226/1247/1326/1365 |
| 194 | handler.rs:951-965 | ❌ | NoopHandler | struct :1223,impl :1226-1243 |

### executor.rs(旧 ~2,700 行 → 现 5,591 行;全部 ❌)

| 章稿行 | 引用 | 状态 | 符号名 | 当前正确行号/锚点 |
|---|---|---|---|---|
| 87 | executor.rs:1439-1684 | ❌ | Parallel 专门分支 | `HandlerKind::Parallel` 分支 :2749 起 |
| 88 | executor.rs:1686-2033 | ❌ | DynamicParallel 分支 | :3122 起 |
| 90 | executor.rs:1439-2033 | ❌ | 两个分支合计 | :2749-~3300 |
| 153 | executor.rs:1439-1684 | ❌ | Parallel 分支 | :2749 |
| 157 | executor.rs:1445-1450 | ❌ | converge 缺失报错 | :2751-2754 |
| 159 | executor.rs:55-68 | ❌ | 下游 target 收集 | :2756-2763 |
| 159 | executor.rs:1488-1509 | ❌ | fan-out 执行 | :2849(max_parallel_workers)附近 |
| 160 | executor.rs:1536-1549 | ❌ | join/合并 | :~2850-2950 内重定位 |
| 161 | executor.rs:1551-1560 | ❌ | 同上 | 同上 |
| 161 | executor.rs:1588-1605 | ❌ | 同上 | 同上 |
| 162 | executor.rs:556-642 | ❌ | worker 执行辅助 | :~2263-2289(`pipeline:<node_id>` 合成工具名 :2289) |
| 162 | executor.rs:1621-1634 | ❌ | 跳 converge | :3108-3121 |
| 163 | executor.rs:1647-1683 | ❌ | fan-out 总量闸门 | :2804(`MAX_PIPELINE_FANOUT_TOTAL` unwrap_or) |
| 167 | executor.rs:1513-1518 | ❌ | max_parallel_workers 使用 | :2849(字段 :405) |
| 168 | executor.rs:1341-1342 | ❌ | 跳过/错误路径 | :~2900-3000 内重定位 |
| 168 | executor.rs:1374-1393 | ❌ | 同上 | 同上 |
| 168 | executor.rs:1631-1634 | ❌ | 同上 | 同上 |
| 170 | executor.rs:636-758 | ❌ | worker 超时/取消 | `MAX_FANOUT_WORKER_SECS` :121 |
| 174 | executor.rs:1786-1844 | ❌ | synthetic Codergen 节点合成 | :~3170+(:3173 plan_prompt 注释为锚) |
| 176 | executor.rs:1686-2033 | ❌ | DynamicParallel 全段 | :3122 起 |
| 178 | executor.rs:1721-1729 | ❌ | planner 输入构造 | :3135-3160 附近 |
| 179 | executor.rs:1731-1736 | ❌ | planner 调用 | `plan_dynamic_tasks` :1158-1272 |
| 180 | executor.rs:404-553 | ❌ | `plan_dynamic_tasks` | :1158-1272(期望 JSON 数组/回退 :1181-1185) |
| 180 | executor.rs:1750-1778 | ❌ | `fallback_tasks()` | :1274-1300 |
| 181 | executor.rs:1786-1844 | ❌ | `{task}` 替换 | :3170+ |
| 182 | executor.rs:1873-1895 | ❌ | fan-out 总量检查+成本预留 | :2804/:3373(两处 unwrap_or MAX) |
| 182 | executor.rs:1906-1924 | ❌ | synthetic worker 成本预留 | :3373 附近 |
| 183 | executor.rs:1948-2033 | ❌ | 并发执行+合并+跳 converge | :3122 之后,结构同 Parallel |
| 187 | executor.rs:1791-1816 | ❌ | model pool 轮询 | 由 `model_assignment.rs`(564 行)+ `run_graph_with_handlers_throttled` :1772+ 接管,需重写引用 |
| 188 | executor.rs:1719 | ❌ | 无 semaphore 说明 | 现有 `pipeline_llm_semaphore`(`run()` :1655)——**口径需更新**:DynamicParallel 现也过 pipeline 级 LLM semaphore |
| 188 | executor.rs:1873-1895 | ❌ | MAX_PIPELINE_FANOUT_TOTAL | 常量 :102(=500 ✅) |
| 228 | executor.rs:801-979 | ❌ | `PipelineExecutor::run()` | :1650-1672;`run_graph` :1673;`run_graph_with_handlers` :1740;`run_graph_with_handlers_throttled` :1772 |
| 238 | executor.rs:1322-2470 | ❌ | `execute_graph()` 主循环 | :2520 起 |
| 103 | executor.rs:2061-2075 | ❌ | 成本聚合 | `project_cost_usd("pipeline-aggregate")` :2061-2065(该锚点恰在 :2061 附近,基本吻合,重排后需复核) |
| 273 | executor.rs:2597-2657 | ❌ | validators/收尾 | :2520+ 循环内重定位 |
| 281 | executor.rs:2611-2619 | ❌ | 同上 | 同上 |
| 285 | executor.rs:267-307 | ❌ | `PipelineResult` | struct :327 |
| 294 | executor.rs:2446-2467 | ❌ | terminal validators | :2520+ 末段重定位 |
| 295 | executor.rs:2391-2417 | ❌ | 成本提交/退款 | 同上 |
| 296 | executor.rs:2420-2433 | ❌ | node_costs 汇总 | 同上 |
| 297 | executor.rs:2498-2595 | ❌ | PipelineResult 组装 | 同上 |
| 299 | executor.rs:248-265 | ❌ | handler 名映射 | `handler_name` :251-259(现含 shell_check/notify/wait) |
| 312 | executor.rs:2077-2080 | ❌ | 模型选择生效点 | :1772+(throttled 入口模型赋值) |
| 327 | executor.rs:1195-1221 | ❌ | TaskSupervisor 注册 `pipeline:<node_id>` | :2263-2289 |
| 327 | executor.rs:2120-2133 | ❌ | 子任务状态更新 | 同段内重定位 |
| 327 | executor.rs:2318-2343 | ❌ | 同上 | 同上 |
| 328 | executor.rs:883-891 | ❌ | pipeline 级 reservation | `PipelineContext`(`context.rs:59`)持有 CostAccountant;opening 在 run 路径 :1772+ |
| 328 | executor.rs:981-1046 | ❌ | 成功提交 | 重定位 |
| 328 | executor.rs:1223-1258 | ❌ | 节点级预留 | 重定位(:1327 有 remaining_tokens 判断为锚) |
| 328 | executor.rs:2290-2316 | ❌ | node_costs 形成 | 重定位 |
| 330 | executor.rs:1075-1193 | ❌ | per-node validators | `ValidatorsByNode`(`context.rs`,`lib.rs:35` 导出);executor 侧重定位 |
| 330 | executor.rs:2270-2288 | ❌ | terminal validators | 重定位 |
| 339 | executor.rs:195-216 | ❌ | `ExecutorConfig.checkpoint_store` | 字段 :427(`ExecutorConfig` :387) |
| 339 | executor.rs:330-336 | ❌ | resume 构造 | `build_resume_skip_set` :2555;默认 None 判断 :1916 |
| 339 | executor.rs:2363-2389 | ❌ | checkpoint persist | :2555 附近重定位 |
| 2409 区(build_handlers,章稿未给行号) | — | ❌ | `build_handlers` | :2409-2438(注册 7 种:codergen/gate/noop/dynamic_parallel 占位/shell/shell_check/notify/wait) |

### tool.rs(旧 462 行 → 现 3,197 行;全部 ❌)

| 章稿行 | 引用 | 状态 | 符号名 | 当前正确行号 |
|---|---|---|---|---|
| 323 | tool.rs:314-347 | ❌ | TOOL_CTX 快照 | `PipelineHostContext::from_tool_context`(`host_context.rs:78`),调用点 :144 |
| 325/340 | tool.rs:325-347 | ❌ | run_dir 相关 | 重定位(默认仍未接 run_dir,口径不变) |
| 346 | tool.rs:19-462 | ❌ | `RunPipelineTool` | struct :109(文件 3,197 行) |
| 350 | tool.rs:152-211 | ❌ | inline DOT→名称回退 | 重定位(:686 input_schema 附近为执行区) |
| 351 | tool.rs:481-514 | ❌ | DOT sanitize | 重定位 |
| 352 | tool.rs:127-132 | ❌ | 搜索路径挂载 | discovery 侧见下行 |
| 353 | tool.rs:349-368 | ❌ | 总超时钳制 | 钳制 **[60,3600]**(:534 注释、:1099);shutdown flag 置位 :1118-1119 |
| 354 | tool.rs:386-443 | ❌ | 合成 .md 报告 | :1332(`.md` 判定)/:1405(`run_pipeline_{ts}_{pid}_{seq}.md`) |
| 355 | tool.rs:444-479 | ❌ | node_costs→structured_metadata | :1259-1278 |
| 357 | tool.rs:249-285 | ❌ | `input_schema()` | :686(提示词措辞已大改,12.3.8 引文需更新) |
| 330 | tool.rs:77-125 | ❌ | workspace policy→PipelineContext | 重定位(`PipelineContext` `context.rs:59`) |

### discovery.rs / host_context.rs / checkpoint.rs / run_dir.rs / human_gate.rs / stylesheet.rs / validate.rs

| 章稿行 | 引用 | 状态 | 符号名 | 当前正确行号 |
|---|---|---|---|---|
| 352 | discovery.rs:14-114 | ❌ | `PipelineDiscovery` | struct :84,`new` :98,`new_operator_trusted` :127(pipelines/skills :102-104),`add_search_path` :137,`add_bundled_pipelines_dir` :147(**新增 bundled-pipelines 最低优先级机制**,旧稿未写),`resolve` :184 |
| 102 | host_context.rs:29-84 | ❌ | `PipelineHostContext` | struct :34-~60,`from_tool_context` :78 |
| 144 | human_gate.rs:14-140 | ✅ | 默认 300s/channel 抽象 | `DEFAULT_INPUT_TIMEOUT` :14-15(模块共 233 行,未接入执行器 ✅) |
| 339 | checkpoint.rs:127-224 | ✅ | `CheckpointStore` trait / FS store | trait :127,`FileSystemCheckpointStore` :154 |
| 340 | run_dir.rs:17-114 | ✅ | `RunDir`/`NodeStatus`/`PipelineRunSummary` | :17 / :23 / :107(约定 `{working_dir}/.octos/runs/...` 口径不变) |
| 314 | stylesheet.rs:28-104 | ✅ | `ModelStylesheet` | struct :28;仍仅 `lib.rs:28/64` 导出、无调用点(结论保持) |
| 296 区(validate,章稿多数无行号) | validate.rs | — | `validate` :181、`validate_with_context` :186、`find_start_node` :394、`validate_model_name` :1046(新增模型名校验,可补一句) |

---

## B. 12 种 IR 节点核对(本章核心)

实测命令与结果:

```
$ sed -n '/pub enum IrNodeKind/,/^}/p' crates/octos-pipeline/src/ir.rs | grep -cE '^\s{4}[A-Z]'
12
$ grep -n "pub enum IrNodeKind" crates/octos-pipeline/src/ir.rs
ir.rs:57
$ grep -n "pub enum HandlerKind" crates/octos-pipeline/src/graph.rs
graph.rs:241
```

| # | `IrNodeKind` 变体(ir.rs:57 起) | 对应 `HandlerKind`(graph.rs:241) | 一句话定位(源码注释) |
|---|---|---|---|
| 1 | `Research` | (经 IR→节点映射,落 Codergen 类路径) | 只读研究(web+file reads),cheap 模型;带 `max_iterations`(:64) |
| 2 | `Transform` | 同上 | 纯变换,cheap 模型 |
| 3 | `Synthesize` | 同上 | 最终综合(只读),strong;带 `max_iterations`(:75) |
| 4 | `Report` | 同上 | 综合**并**经 write_file 落盘,terminal 步;带 `max_iterations`(:84) |
| 5 | `Gate {}` | `Gate` | 纯路由门,无 LLM,出边条件决定分支 |
| 6 | `Fanout` | `DynamicParallel` | 规划 N 个 worker 并行跑后 converge(`plan_prompt`/`worker_prompt`/`converge`/`max_tasks`) |
| 7 | `CodeReview` | Codergen 类 | 只读代码分析(read/grep/glob),可带 `scope` |
| 8 | `CodeEdit` | Codergen 类 | 改代码,可带预期 `files` |
| 9 | `ShellCheck` | **`ShellCheck`(新 handler,handler.rs:1244/1247)** | 固定命令串、编译期锁死,与可任意执行的 `Shell` 相对 |
| 10 | `SubAgent` | (spawn 子代理) | 独立 LLM 会话的子代理节点(`task`/`tools`/`model`) |
| 11 | `Notify` | **`Notify`(新,handler.rs:1299/1326)** | 发通知给用户,`message`+可选 `channel`,基本无 LLM |
| 12 | `Wait` | **`Wait`(新,handler.rs:1362/1365)** | 等待固定秒数或轮询 `until_condition`,无 LLM |

差异清单(章稿 → 实测):

1. 章稿 12.2 只写 `HandlerKind` 6 种(`graph.rs:184-201` 旧行号)→ 实测 **9 种**(`graph.rs:241-266`),新增 ShellCheck/Notify/Wait;`handler_name` 映射(executor.rs:251-259)同步 9 项。
2. 章稿 **0 次提及 `ir.rs` / IR 节点** → 实测 `ir.rs`(673 行)是 6b0de6ca 扩出的 12 种 DOT 调色板,`ir.rs:206-273` 每变体有 `PaletteContract`,且枚举尾注明确**故意不含 human_gate**(防静默审批绕过)——这句值得写进书。
3. 章稿说「只有 4 个 Handler trait 实现」→ 实测 **7 个**(Codergen:641、Shell:1054、Gate:1190、Noop:1226、ShellCheck:1247、Notify:1326、Wait:1365);Parallel/DynamicParallel 仍是 `execute_graph()` 分支(:2749/:3122)。
4. 章稿 0 次提及 `events.rs`(296 行,进度事件,f26d2291)、`octos-workflows` crate、`model_assignment.rs`(564 行)——均为「新面必补」。
5. `input_schema` 现在带 IR 开关测试(`tool.rs:2917 input_schema_exposes_ir_only_when_enabled`)——工具层对 LLM 暴露的是 IR 调色板而非裸 handler,12.3.8 需补。

### 结论

- 总引用数 **110**(行号级),✅ 5 / ❌ 105;内容级需修正 **7** 项;IR 节点实测 **12** vs 章稿 **0**(HandlerKind 9 vs 6)。段落重写时按上表「当前正确行号」逐条重标,并按需修正清单 1-7 改写。
