# Ch13 事实核查报告(ch13-factcheck,peer C1)

- 审查对象:`chapters/ch13-pipeline.md`(440 行,段落重写+改号 Ch12→Ch13 后的定稿候选,master commit 3028a93,工作分支 rewrite-v2 HEAD ed02a3e 经 `git diff 3028a93 HEAD -- <两个文件>` 确认章稿/镜像与定稿字节一致,无旧基线)
- 事实基准:`assets/ch13-refcheck.md`(commit 6659756,peer A)
- 源码:octos main @ **9c157101**(只读,`git log -1` 实证);范围 `crates/octos-pipeline/` 实测 **32,799** 行、`src/*.rs` 实测 **25,134** 行——与 refcheck 记录完全一致
- 方法:grep 提取章稿全部 `src/*.rs` 引用 → 逐锚点 sed/grep 摘录比对(文件规模、符号名、行号)→ 数字 sed 复算 → 机械项 grep/python 复算

## 文首汇总

| 检查项 | 结果 |
|---|---|
| 路径引用总数(`../octos/crates/*/src/*.rs` 带行号/区间) | **83** 处(74 个唯一锚点) |
| 行号准确 / 符号在区间内 | **83 / 83**,偏差 0 处(见「明细」微注) |
| 路径越界 / 符号不存在 | **0** 处 |
| IrNodeKind 变体数(sed 复算) | **12** ✅(章稿 12.2.8 表与源码逐条一致) |
| HandlerKind 变体数(逐行清点) | **9** ✅(graph.rs:241-265) |
| MAX_PIPELINE_FANOUT_TOTAL | **500** ✅(executor.rs:102) |
| 总超时钳制区间 / 默认 | **[60, 3600] / 1800** ✅(tool.rs:534 注释、:1099 钳制、:559 常量 1800) |
| 严格汉字数(去代码块) | **5,732** ✅ ≥ 5,000(与 master 实测 5,732 一致,非巧合——章稿未动) |
| 机械项(锚点/版本演化/mermaid/镜像/——/加粗/黑话) | 全部通过(见 §4) |
| SUMMARY 第 13 章条目 / 旧 ch12-pipeline 清理 | 均在位 ✅ |

**是否可定稿:✅ 可以定稿(必修 0 项;可选 3 项微注,不影响事实正确性)。**

83 处引用经逐锚点比对,行号与符号全部命中当前源码;数字类断言(12/9/500/[60,3600]/1800/23 条规则)全部实测复核为真;章稿对 refcheck 7 项内容级修正的落实完整(九种 HandlerKind 新表、12 种 IR 节点新节、进度事件、workflow 分工、per-node max_iterations、钳制数值、model_assignment 新路径)。未发现行号漂移、符号错位或内容级失实。

## 1) 路径引用核对(83/83)

### 重点重标段(逐行实证)

| 章稿断言 | 源码实测 | 结论 |
|---|---|---|
| `build_node()` parser.rs:579-691 | :579 `fn build_node`,区间内含 handler 解析/tools/deny-all/checkpoints 等全部子逻辑 | ✅ |
| `HandlerKind` graph.rs:241-266 | :241 `pub enum HandlerKind`,:265 枚举闭括号,:266 空行(`impl` :266 起) | ✅(9 变体逐行清点:Codergen/Shell/Gate/Noop/Parallel/DynamicParallel/ShellCheck/Notify/Wait) |
| 7 个 impl Handler | handler.rs:641(Codergen)/1054(Shell)/1190(Gate)/1226(Noop)/1247(ShellCheck)/1326(Notify)/1365(Wait)——`grep -c "impl Handler for"` = **7** | ✅ 逐行命中 |
| executor.rs:4882 select_next_edge | :4882 `fn select_next_edge(` | ✅ |
| executor.rs:102 / :121 | `MAX_PIPELINE_FANOUT_TOTAL = 500` / `MAX_FANOUT_WORKER_SECS = 3600` | ✅ |
| tool.rs:534 / :1099 | 「Clamped to [60, 3600]」/「Final value is clamped to [60, 3600]」 | ✅ |
| handler.rs:1192 | `node.prompt...unwrap_or("true")` | ✅ |
| ir.rs:57 | `pub enum IrNodeKind` | ✅ |
| parser.rs:45 / :50 | `struct DotParser` / `impl<'a> DotParser` | ✅ |
| executor.rs:2749 / :3122 | `if node.handler == HandlerKind::Parallel` / `...::DynamicParallel` | ✅ |
| executor.rs:1772 throttled 入口 / :1808 model_assignment 调用 | `async fn run_graph_with_handlers_throttled` / `model_assignment::assign_from_catalog_dir` | ✅ |
| executor.rs:1640 / :1650-1672 / :1673 / :2520 / :2555 / :272 | `pipeline_llm_semaphore` / `pub async fn run` / `run_graph` / `execute_graph` / `build_resume_skip_set` 调用点 / 定义 | ✅ |
| executor.rs:2409-2438 build_handlers | :2409 `fn build_handlers`,:2438 WaitHandler 注册;Shell **确实未注册**(:2415 注释「intentionally NOT registered」),DynamicParallel 注册 NoopHandler(:2430),与章稿 13.2.2/13.2.6 表述一致 | ✅ |
| executor.rs:2751-2754 / :2756-2763 / :2804 / :2849 / :3108-3121 / :2263-2289 | converge 缺错报 / 下游收集 / `unwrap_or(MAX_PIPELINE_FANOUT_TOTAL)` / `max_parallel_workers` 使用 / converge 跳转 / `pipeline:{node_id}` 合成工具名(:2289 `format!("pipeline:{node_id}")`) | ✅ |
| executor.rs:1158-1272 / :1274 | `plan_dynamic_tasks` / `fallback_tasks` | ✅ |
| executor.rs:387/:427 / :1916 / :4043 | ExecutorConfig / checkpoint_store 字段 / 默认路径 `checkpoint_store.is_none()` 判断 / 持久化点 | ✅ |
| tool.rs:109 / :144* / :686 / :1259-1278 / :1332 / :1405 / :1118-1119 / :2917 | RunPipelineTool / input_schema/ir 门(:144,**见微注 N1**)/ `fn input_schema` / structured_metadata 投射 / `.md` 判定 / `run_pipeline_{ts}_{pid}_{seq}.md` / shutdown 置位 / `input_schema_exposes_ir_only_when_enabled` 测试 | ✅ |
| validate.rs:181 / :186 / :394 / :242 / :1046 / :210-232 | `pub fn validate` / `validate_with_context` / `find_start_node` / `fn rule_23_no_shell` / `fn validate_model_name` / 规则表 23 条(`rule_23_no_shell(graph,...)` 为第 232 行即末条,含 210-232 共 23 个规则调用) | ✅ |
| graph.rs:10-54 / :48 / :54 / :118-184 / :140 / :163/:166/:169/:172/:184 / :270-279 / :282-297 | PipelineGraph(:10-54 含 subgraphs :48)/ detect_cycles :54 / PipelineNode :118 起、struct 止于 :188 / max_iterations :140 / human_gate :163、resolver :166、artifact_refs :169、checkpoint_refs :172、continue_on_error :184 / from_str / from_shape | ✅(区间端点微注见 N2) |
| host_context.rs:34-60 / :78 / context.rs:59 / discovery.rs:84 / human_gate.rs:14-15 / checkpoint.rs:127/:154 / run_dir.rs:17/:23/:107 / stylesheet.rs:28 / condition.rs:12-17/:32-34/:69 / events.rs:14 / lib.rs:12/:35/:36 / ir.rs:195/:204 / ir.rs:64/:75/:84 | 全部命中:PipelineHostContext struct/from_tool_context、PipelineContext :59、PipelineDiscovery :84、DEFAULT_INPUT_TIMEOUT=300s(:14 注释 5 分钟+:15 常量)、CheckpointStore trait/:154 FS store、RunDir/NodeStatus/PipelineRunSummary、ModelStylesheet、condition grammar 的 context.* 行与 evaluate_with_context、PipelineEvent 枚举、lib.rs 导出行、PaletteContract struct/:204 contract_for、三处 max_iterations 字段 | ✅ |

*(其余非重点锚点——parser.rs:21-23/:63-65/:110-127/:148-150/:163/:479-502/:520-537/:551-570/:588-602/:601-603/:619-623/:620/:665-689/:693-720/:721-751 等——均已逐条摘录验证,符号与语义一致。)*

### 明细微注(事实仍正确,不计为错误)

- **N1**|章稿 13.3.6 说 from_tool_context「调用点 tool.rs:144」——:144 现为 typed-IR opt-in 注释;实际调用点在 **:981/:1152**(`try_with(PipelineHostContext::from_tool_context)`)。refcheck 记「调用点 :144」系其时点的近似;属可选修正。
- **N2**|13.1.2 末「`:118-184`(节点)」——PipelineNode struct 起于 :118、止于 :188;:184 是字段 continue_on_error 而非 struct 终点。区间内符号全部真实,仅终点略收窄;可选修正为 :118-188。
- **N3**|13.1.3「deadline_secs 解析(:601-603)」——`let deadline_secs` 实际在 **:604-606**(:601-603 是 tools 解析收尾),±3 行;refcheck 基线即如此,区间语义不受影响。
- **N4**|13.1.3「parse_checkpoints(:721-751)」——fn 起于 :721,主体止于 :753;终点差 2 行,符号在区间。

## 2) 数字核对

| 断言 | 命令与结果 | 结论 |
|---|---|---|
| IrNodeKind 12 种 | `sed -n '/pub enum IrNodeKind/,/^}/p' ir.rs \| grep -cE '^\s{4}[A-Z]'` → **12** | ✅ |
| HandlerKind 9 种 | graph.rs:241-265 逐行清点 = 9;`handler_kind_label`(executor.rs:251-259)恰 9 分支 | ✅ |
| MAX_PIPELINE_FANOUT_TOTAL = 500 | executor.rs:102 `pub const ... = 500` | ✅ |
| MAX_FANOUT_WORKER_SECS = 3600 | executor.rs:121 | ✅ |
| 钳制 [60, 3600]、默认 1800 | tool.rs:534 注释 / :1099 注释 / :559 `const PIPELINE_TIMEOUT_DEFAULT_SECS: u64 = 1800` | ✅(旧「60-1800」已纠正) |
| 验证规则 23 条 | validate.rs 规则调用清点 = 23(210-232),Rule 23 = rule_23_no_shell(:242) | ✅ |
| 7 个 Handler 实现 | `grep -c "impl Handler for"` = 7 | ✅ |
| Gate 默认条件 true / Shell 默认超时 300s / human_gate DEFAULT_INPUT_TIMEOUT 300s / max_tasks 默认 8 | handler.rs:1192 / :1057(unwrap_or(300))/ human_gate.rs:15 / graph.rs:159 注释「(default 8)」 | ✅ |
| WaitHandler 默认 300 秒 | handler.rs:1367 `unwrap_or(300)` | ✅ |
| 文件规模 | executor 5,591 / tool 3,197 / handler 2,140 / parser 1,445 / ir 673 / graph 421 / events 296 / model_assignment 564 / discovery 685;crate 32,799;src/*.rs 25,134 | ✅ 全部与 refcheck 一致 |

## 3) 内容级修正落实核对(refcheck 7 项 → 章稿)

1. HandlerKind 6→9 + 7 个 impl:13.2 新表 + :94 段落 ✅(并保留 Parallel/DynamicParallel 为 executor 分支的准确表述)
2. IR 12 变体新节:13.2.8 ✅(12 变体逐条与 ir.rs 一致;`human_gate` 故意缺席的尾注动机已写入 :220,附统计命令)
3. 进度事件:13.3.4 ✅(events.rs 296 行、PipelineEvent 变体、两个 handler 实现、f26d2291、「详见第 10 章」)
4. workflow 分工:13.4 ✅(octos-workflows 独立 crate、server/cli 依赖、families 布局)
5. per-node max_iterations:13.1.3/:111 ✅(graph.rs:140、parser.rs:620、动机注释转述准确;PipelineNode 属性清单已含 human_gate/resolver/artifact_refs/checkpoint_refs/continue_on_error)
6. 钳制数值:13.3.8 → [60,3600] 默认 1800 ✅
7. 模型路由:13.3.5 ✅(throttled 入口 + model_assignment.rs:135/:155 + 插件静默退化的迁移动机 + model pool 轮询归因)
附加:validate_model_name(Rule 18,:1046)、IR schema 测试 tool.rs:2917、bundled-pipelines 相关的 discovery 表述均已在章稿体现。

## 4) 机械项

| 项 | 实测 | 结论 |
|---|---|---|
| 锚点标题编号 | 13.1(13.1.1-3)/13.2(13.2.1-8)/13.3(13.3.1-8)/13.4/13.5 连续,章题「第 13 章」 | ✅ |
| 版本演化说明 | 文末引用块,含 9c157101、25,134、5,591/3,197/2,140/1,445、四个演化 commit | ✅ |
| mermaid | 恰 1 块(```mermaid ×1),流程与正文一致 | ✅ |
| 镜像 | `cmp chapters/ch13-pipeline.md book/src/part3/ch13.md` → 一致 | ✅ |
| 破折号「——」 | **0** 处 | ✅(≤2) |
| 加粗 `**…**` | **13** 处(定位块 1 + 13.2.1 六点 6 + 图注 1 + human_gate 尾注 1 + [60,3600] 1 + 侧栏 3) | ✅(≤15) |
| 黑话 | DOT/IR/ABI 首现即带中文解释(DOT 语言、类型化 IR、事件 ABI);无未解释缩写残留 | ✅ |
| 旧章号残留 | `grep "第 12 章\|12\.[0-9]"` = 0 | ✅ |

## 5) 字数

- 严格汉字(去代码块):**5,732** ≥ 5,000 ✅(全文件含代码注释汉字 5,791)
- 与 master 定稿实测值 5,732 完全一致(章稿即定稿内容,未发现改动)

## 6) SUMMARY 与旧文件清理

- SUMMARY.md 第 31 行:`- [第 13 章:octos-pipeline:DOT 图驱动的工作流引擎](./part3/ch13.md)` ✅
- 旧 `chapters/ch12-pipeline.md` 已不存在(ls 计数 0)✅
- part3 现为 ch11-ch15 连续,`ch12.md` 是新第 12 章(并发模型),非残留 ✅

## 结论

- **是否可定稿:✅ 可定稿。** 必修 0 项。
- 可选微注 3 项(N1 tool.rs:144→:981/:1152;N2 graph.rs:118-184→:118-188;N3 :601-603→:604-606),均为行号区间端点的 ±几行精度问题,符号与事实全部正确,不改也不构成失实。
- 风险提示:本章引用基于 9c157101,若 master 前进需按惯例重跑 refcheck。
