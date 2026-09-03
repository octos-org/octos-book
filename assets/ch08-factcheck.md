# Ch8 factcheck 报告(C1,ch08-factcheck)

- 审查对象:`chapters/ch08-context-management.md`(v2 候选,取自 master 定稿 commit `949f715`,263 行)
- 事实基准:`assets/ch08-refcheck.md` @ `72d4f0f`;源码只读 `/Users/zhangalex/Work/Projects/FW/octos` @ `9c1571016e5e…`(`git status --porcelain` = 0 行,工作树 clean;`merge-base --is-ancestor` 通过)
- 基线防旧:两文件从 master 工作区拷贝后 `cmp` 镜像逐字节一致(MIRROR: IDENTICAL);`git show 949f715:chapters/…` 与 `949f715:book/src/part2/ch08.md` 均与本地副本逐字节一致(MASTER_949f715_IDENTICAL / MASTER_BK_IDENTICAL)

## 汇总表

| 检查项 | 结果 | 判定 |
|---|---|---|
| 1a) 路径存在 | 80 处唯一带行号引用、15 个不同 .rs,`MISSING` 计 0 | ✅ |
| 1b) 越界 | 80/80 以 `wc -l` 验上界,`OOB` 计 0;重点新增引用 compaction_tiered.rs:5-8 / prompt_context.rs:55-58 / loop_runner.rs:1218、1249 邻域全中 | ✅ |
| 1c) 符号在区间 | 逐符号 grep 核对(约 60 个符号):锚点常量/函数定义全部命中或紧邻区间;7 处 off-by-one/邻段偏移见 P3 | ✅(P3 微偏) |
| 2) 行数表 vs wc -l | 1,932/1,271/64/942/707/407/4,003 全对,合计 9,326 | ✅ |
| 3) 代码摘录 diff | 两处 rust 代码块与源码逐字符一致(`:25` 预算式、:68-89 边界扫描+Tool 回退) | ✅ |
| 4a) 锚点 | 定位块 ✓ 工程决策侧栏 ×1 ✓ 延伸阅读 ✓ 思考题 ✓ 版本演化 ✓ | ✅ |
| 4b) mermaid ≥2 | `grep -c '```mermaid'` = 2 | ✅ |
| 4c) 镜像 cmp | MIRROR: IDENTICAL(263 行 = 263 行) | ✅ |
| 4d) —— ≤2 | 0 | ✅ |
| 4e) 加粗 ≤15 | 13 对 | ✅ |
| 4f) 黑话 9 词 | 赋能/抓手/闭环/打通/沉淀/助力/践行/势能/组合拳 全 0 次 | ✅ |
| 5) 字数 ≥5,000 | 严格 CJK 区间 [\u4e00-\u9fa5] 去 fenced 含 inline = **4,974**(与 master 已知一致,差 26);`\p{Han}` 口径 = 5,212(含 238 个「、」);去 inline 后 4,957 / 5,195;commit 声称 5,055 与两口径均不符 | ⚠️ P2-1 |
| 6) 小节编号 | **两个 `### 8.1.5`**(L75、L83) | ❌ P2-2 |
| 附) SUMMARY 锚点 | book/src/SUMMARY.md:21 已是新标题「上下文管理:让 Agent 在有限窗口中高效工作」 | ✅ |

## 事实抽样验证(全部命中)

- `SAFETY_MARGIN=1.2`(:45)、`MIN_RECENT_MESSAGES=6`(:48)、`BASE_CHUNK_RATIO=0.4`(:51);0.8/1.2≈67%、128K→约 85K 算术成立
- 摘要形态字符串:`> User:` :163 / `- Called {}` :169 / `> Assistant:` :176 / `-> {}: {} - {}` + 100 字符 :190-192 / `> Context:` :197 / `[media omitted]` :161 / `... (N earlier messages omitted)` :126、:137;`Error:` 前缀判定 :184;`unknown_tool` 降级 :230;`first_line` 按 char_indices 截断 :203-216
- #2132 plan 扣除在生产者内部(:100-114),注释四路径「AppUI、session actor、legacy agent channel、summarizer tiers」与章文逐词一致
- `fallback_truncate` 至少保两条非系统(:336-339)、Tool 组不拆(:341-345)
- recall 链:`ToolOutputLedger` :19 / `RecallTool` :27 / `render_page` :51 / `recall_index`「NEVER pruned」context_manager.rs:391-398 / `tool_output_by_call_id` 三分支 :1192-1206(含 cold-reload「[truncated] 不误导」文档);测试名 `recall_survives_compaction_that_prunes_the_transcript` :2412、20KB 构造 :2418
- `e312e4c1` 2026-08-27 合入 ✓;提交说明原文含 sha256/`~560 construction sites`/「paged like recall_memory」✓;`825d6a52`「prunes items to the last ~16」✓;66 次重读在 pin 字段文档 :80(llm.c pathology)✓
- Tier 1:`DEFAULT_TIER1_MAX_AGE_TURNS=5` :40、8KB=8*1024 :43、`DEFAULT_TIER1_PIN_RECENT_FILES=5` :98、`Tier1Pass::Full/OversizedOnly` :51-57、原因标签 :237-241、`protected_tool_call_ids` 必传 :139-142;`tier1_pass()`: iteration==1 跑 Full(loop_runner.rs:3846-3852);会话模式 :1227、任务模式 :2366
- Tier 2:`ApiMicroCompactionConfig` 默认 `enabled:false`(:437-439 doc)、`clear_tool_uses_20250919` :426/:489、`DEFAULT_TIER2_KEEP_LAST_N_TURNS=10` :421、`with_tier2_context_management` 非 Anthropic 原样返回 :203-213
- Tier 3:`needs_preflight` :572、`run()` :584、post-prune 预算判定「不为压缩而压缩」:602-610、prune_tool_results :711、摘要失败回退提取式 :679-695、`enforce_preservation` :278-318(TurnEnd 校验、缺失回滚)、`with_provider` :494、`with_workspace_policy` :538
- prompt_context:`PromptContextPhase` 三变体 :12-30、`PromptContextReport` 六字段 :44-53、「Returning an error does not abort the agent loop」:55-58;早退 :15-17、:90-93(doc)、:191-196;桥错误 WARN 后沿用现有向量 :262-268;TurnStart/Iteration 按 iteration==1 选择 :1251-1258;Retry 于 CompactAndRetry :509-513
- steering:`SteeringMessage` 四变体 :80-90、`DEFAULT_BUFFER=16` :97、非阻塞 `drain_pending` :100、FIFO `split_off(0)` :41-46、TODO 未接线 :6、调用点 :1136、`steer_input_pending` :776
- 其余:`sanitize_tool_output` 三步+defang :90-95、「**Not a security boundary**」+base64/同形字/零宽绕过+sandbox/tool policy/human-in-the-loop :6-19;prompt_layer 发现顺序 CLAUDE.md→.octos→.claude(:16-18)、AGENTS.md→.octos/agents.md→agents.md(:14)、`MAX_PROMPT_FILE_SIZE=64KB` :11;`SessionSummary` typed+`[STALE]` task.rs:233/253/268;`required_validators_satisfied`→`ready` :663-669、optional→warnings :664;`f3aa07f0`(#2194)提交说明与 summarizer.rs:303-305「1.25x cache-write premium」、compaction.rs:1194-1198 一致
- 两处 mermaid 图与源码语义一致(0.67 阈值、占位符继续、required gate 允许/阻止 terminal success)

## 分级发现

### P1(事实/硬指标,定稿前必须处理)

无。80 处引用 0 缺路径 0 越界;数字、代码摘录、两 commit 元数据、三个 #issue 叙事全部核实无误。

### P2(口径/编号,建议定稿前处理)

1. **字数口径需裁决。** 严格 CJK 统一区 [\u4e00-\u9fa5]、去 fenced(含 mermaid)、inline code 保留 = **4,974**,与 brief 所记 master 实测完全一致(无回归),但差 26 字未达 ≥5,000;`\p{Han}` 口径(多计 238 个「、」)= 5,212 达标;`949f715` 提交说明声称的「正文 5,055 汉字」与两种口径都不吻合,来源不明。建议:外环明确口径;若认 \p{Han} 口径则达标,若认严格口径需补约 26 个汉字(或下调门槛)。
   ```
   $ awk '/^```/{f=!f;next} !f' chapters/ch08-context-management.md \
     | perl -CSD -ne 'my $c=()=/[\x{4e00}-\x{9fa5}]/g;$t+=$c;END{print "$t\n"}'   → 4974
   $ … 同式 /\p{Han}/ …                                                            → 5212
   ```

2. **小节编号重复:两个 `### 8.1.5`**(L75「recall 与记忆子系统的边界」、L83「预算感知读取:预防先于恢复」)。第二个应为 `### 8.1.6`;同章回顾与目录锚点未受影响。

### P3(off-by-one/邻段偏移,符号均可定位,顺手改)

1. §8.1.5(episode):「两处调用见 `loop_runner.rs:1215-1245`」——第一处 :1218(注释)/:1219(调用)在区间内,**第二处实际在 :1249**,超出区间 4 行。建议改 `1215-1252`(或并引 :1218/:1249)。
2. §8.3:「`DEFAULT_LLM_SUMMARIZER_FAILURE_THRESHOLD`(summarizer.rs:93-96)」——常量定义实际在 **:87**;93-96 是提及 3-strike 的文档行。建议改 `:87`(或用点 :201)。
3. §8.7.4:「持久化到 `.octos/validator_outcomes.jsonl`(workspace_git.rs:708-714)」——708-714 是**读侧** `latest_validator_outcomes` 去重段;路径构造 `workspace_validator_ledger_path` 在 **:690-692**。建议改 `:690-692`。
4. §8.3 对 `with_provider` 的重复引用 `compaction.rs:500-514`——签名在 **:494**(§8.2 处的 494-514 正确),500-514 只是构造体初始化。建议统一为 `:494-514`。
5. §8.5:「`SteerBuffer`(steering.rs:36-63)」——struct 定义在 **:27**,36-63 是 impl(push/drain/is_empty)。语义相关,建议 `:27-63`。
6. §8.1.3:`find_tool_name` 引 `compaction.rs:219-234`,签名在 :218(off-by-one,函数体覆盖)。
7. §8.2.1:摘要失败回退引 `compaction.rs:683-695`,`warn!(… falling back to extractive)` 在 :679,回退体在区间内(轻微)。

## 是否可定稿

**有条件可定稿。** 事实层(引用、数字、代码、commit/issue 元数据)全部通过,机械项除字数口径外全过。建议:① 改 P2-2 重复编号(一行改动);② 外环裁决 P2-1 字数口径(\p{Han} 口径已达标;严格口径差 26 字);③ P3 七处区间微调可随下次 editor pass 顺手处理,不阻塞定稿。

---
*审查人:C1 ch08-factcheck · 2026-09-03 · 源码 @ 9c157101(工作树 clean)· 章稿 = master 949f715 逐字节一致*
