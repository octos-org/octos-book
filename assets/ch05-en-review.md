# ch05 英文版 C2 读校报告(ch05-en-review)

- 日期:2026-09-03
- 读校对象:`book-en/src/part2/ch05.md`(前置:ch05-en 67056d6 交付,C1 ch05-en-check 6/6 PASS,d2879ee 归档)
- 对照:中文底稿 `chapters/ch05-agent-loop.md`;规范 `.octos/skills/trilingual-collab-en.md`;术语表 `assets/glossary-en.md`;ch01–ch04 英文版 C2 报告范式
- 性质:英文去味 + 母语度 + 技术读校;不改事实/数字/引用/mermaid/代码块
- 工作目录:octos-book(branch main,未 commit);改动落 wt,由 master 采回
- **总判定:通过(需修 3 处措辞,已修;G1 C2 最后缺口闭合)**

## 1. 禁用词 / 翻译腔(逐条对照 trilingual-collab-en.md)

| 规则 | 命中 | 判定 |
|---|---|---|
| 禁用词 23 词(delve/foster/leverage/utilize/robust/seamless/streamline/…/harness 动词) | 0 | PASS(grep 全文件零命中) |
| Hedging/filler 副词(really/literally/genuinely/honestly/simply/actually/truly/fundamentally/importantly/crucially) | 形态 3+2,逐条核过 | PASS:L3 "what the runtime **actually** does"(实义:真正发生在 runtime 的事,对位 ZH「runtime 实际做什么」)、L87 "as they were **actually** consumed"(实义:按实际消耗,与 merged totals 相对)、L293 "the mechanism that **actually** switches lanes"(实义:真正换 lane 的机制,对位 ZH「真正换」)——均限定实义非填充,删则损义。L133 "truly runs out"(对位 ZH「真正耗尽」,与 Grace 放行一轮相对)、L231 "genuinely structural 401"(实义:真正的结构性故障,与 429 瞬态相对)同判。句首 "Actually, / Worth a warning / It's worth noting" 前缀 0 |
| Filler 短语(it's worth noting / worth a warning / at the end of the day / when it comes to / at its core / in order to / let's dive in / here's the thing / let me be clear) | 0 | PASS |
| Colon reveal(冒号后接整句揭示) | 98 个正文冒号逐条枚举 | PASS:全部为列举/标签/定位句合规用法——L3 Positioning 标签、L5 "one line: receive…"(引出定义原文,列表式)、L5 "boundary conditions: iteration caps, token budgets, …"(八项列举)、各 `path (loc):` / "variant (Lxx) means:" 结构、L188 六变体逐个定义句、L263 "show the shape of loop self-healing: detect…"(三要素列举)。无 "The best part:" 式揭幕 |
| Recap ending / 泛化收尾 | 0 | PASS:5.11 Chapter Recap 为全书固定编号栏目(ch01–ch04 同构,enumerate 要点 1–6),非 "In conclusion" 式升华;正文无 mic-drop;末段 Version note 为固定格式。外环范式「结尾泛化收尾不保留」不适用——无泛化收尾句可删 |
| Binary contrast("It's not X. It's Y.") | 0 | PASS:L5 "is not the verb 'loop' but the decision surface" 为 but 连接的实义否定(对位 ZH「不是动词『循环』而是它编排的决策面」,被驳立场真实存在);L40 "exposes the loop, not the loop's organs" 同构 |
| 喉咙清理开头(Here's the thing / Let me be clear) | 0 | PASS |
| -ing 尾随从句(highlighting/underscoring/showcasing) | 0 | PASS |
| 三连排比(triplet addiction) | 0 无理由三连 | PASS:L3 五要素(lifecycle 组成)、L5 八项 boundary conditions、L42 "Five distinct axes of change"(五模块五轴实指,数字由内容决定) |
| Em dash | 2(均在引文内) | PASS:L148 `// not a git worktree — nothing to checkpoint.`(源码注释原样引用)与 L152 `wip: budget exhausted (#27e) — checkpointed mid-task`(commit message 原样引用),均为代码/提交原文,不得改写;verify-en 实测 1 ≤ 2 |
| Bold 撒粉 | 26 个 `**`(=13 对) | PASS:Positioning/Version note 固定标签 + L36 三个模块分层术语(**nine core modules**/**supporting modules**/**two compaction modules**,对位 ZH 加粗),verify-en 实测 13 ≤ 15 |
| CJK 标点/字符混入(顿号、) | 0 | PASS:全文 perl 逐行扫描 [\u3000-\u303f\u4e00-\u9fff\uff00-\uffef],仅 L148/L152 的 U+2014(—,上条引文内合法);顿号 0 |
| 「双环」术语(dual loop) | 天然合规 | PASS:「双环」在本章底稿不出现(grep 0),EN 无对应需求;`double loop`/`two-loop` 0 命中;`dual loop` 一词本章无需出现(preface 与 Part IV 已确立) |

## 2. 母语度与术语一致性

术语与 `assets/glossary-en.md` 逐条核对(ch05 专列 17 项全数一致):

| 术语表条目 | 章内形式 | 出现 | 一致 |
|---|---|---|---|
| five budget gates 五道闸 | five budget gates / five gates | 7 | ✓ |
| error bucket 错误桶 | (typed retry-)bucket | 16 buckets, limits 等 | ✓ |
| grace 宽限 | Grace(grace iteration, one reprieve) | 23 | ✓ |
| checkpoint 检查点 | checkpoint | 21 | ✓ |
| continuation 续跑 | continuation | 20 | ✓ |
| loop self-healing 循环自愈 | loop self-healing | 4 | ✓ |
| degeneration detection 退化检测 | degeneration detection / degenerate | 2+ | ✓ |
| axis of change 变更轴 | axes of change | 3 | ✓(复数形态一致) |
| write ownership 写权 | write ownership / write-ownership | 2 | ✓ |
| nine core modules 主线九模块 | nine core modules | 3 | ✓ |
| supporting modules 支线模块 | supporting modules | 4 | ✓ |
| two compaction modules 压缩双模块 | two compaction modules | 2 | ✓ |
| bounded recovery 有界恢复 | recover within a bound / bounded nudge | ✓ | ✓ |
| episodic memory 情节记忆 | episodic memory | 3 | ✓ |
| organ-level entry 器官级入口 | organ-level entries/functions | 2 | ✓ |
| Engineering decision 工程决策侧栏 | L229 `> ### Engineering decision:` | ✓ | ✓(行位与 ZH 同位 229=229,C1 已核) |

六阶段术语链与正文自洽:sequenceDiagram 标签 (1)–(6) ↔ 5.2.2 六个小标题 (1) Message preparation … (6) State update and stop decision ↔ 5.11 recap 第 2 条六要素——三处同序同指。agent loop 系列核心词(process_message / run_task / stop_reason / LoopDecision / BudgetStop / HarnessError / RecoveryHint)全篇零同义轮换,保持原文(ch04 报告「Synonym cycling」条款)。

母语度:主动句为主;"cramming them into one file"(L42)、"eats all the retries"(L231)、"blow past eight thousand lines"(L91)、"spinning loops"(L205)、"a black hole in cost accounting"(L87)等为携带论证的比喻,符合 "Keep" 条款。

## 3. 技术读校

### 3.1 三块 mermaid 标签译文(逐标签对照 ZH)

- **块 1 sequenceDiagram(L54–81,6 参与者/6 边)**:调用方→Caller、①–⑥→(1)–(6)、规范化后的 messages→normalized messages、BudgetStop 或放行→BudgetStop or pass、含 stop_reason→with stop_reason、工具结果消息→tool result messages——16 处差异全部为忠实翻译,函数/类型名(check_budget/call_llm_with_hooks/consume_stream_with_input_estimate/execute_tools/ConversationResponse/TaskResult)保持原文未译。✓
- **块 2 flowchart TD(L164–180,14 节点/14 边)**:迭代开始→Iteration start、五道闸→five gates、未获准→not granted、落盘→to persist、放行→pass、有内容?→has content?、是:任务循环→yes:task loop、续跑 ≤2 次→continue ≤2 times、耗尽则终态错误→exhausted: terminal error、上抛→escalate the error——✓;Shutdown/MaxIterations/MaxTokens/ActivityTimeout/IdleProgressTimeout 等技术词原样保留 ✓。
- **块 3 stateDiagram-v2(L207–225,8 状态/15 边)**:瞬态错误且桶未满→transient error, bucket not full、provider 不可用→provider unavailable、或 shell 螺旋首触发→or first shell spiral、计数>桶上限→count > bucket limit、下一迭代→next iteration、换 lane 后重试→retry after lane switch、压缩后重试→retry after compaction、首次且 productive ≥1→first time and productive ≥ 1、宽限迭代→grace iteration、二次耗尽→second exhaustion、恢复资格,全局仅一次→restores eligibility, once globally——✓。

三块节点/边计数与 C1 结论一致(6/6、14/14、8/15),EN 未动任何 ID 或结构。

### 3.2 数字

全文抽核关键数字:20 modules / 21,369 lines(L5=L9=L281=L310 四处一致)、execution.rs 4,730 与 loop_runner.rs 3,979(L5=L20=L23=L310)、16 buckets(authentication 1 / quota 1 / content_filtered 1 / internal 1 / rate_limited 5 / network 4 / provider_unavailable 4 / timeout 3 / shell_spiral 1,L186+L302 一致)、MAX_TOKENS_CONTINUATION_LIMIT=2(L175=L182=L250=L259)、MIN_EPISODE_SIMILARITY=0.55(L271)、16,384-token(L245)、763 次(L261)、1,416 lines(L275)、窗 12(L267)。C1 已做归一化数字集合比对(缺失 0/多余 0),本次改动不触碰任何数字。✓

### 3.3 章号与交叉引用

- 「详见第 N 章」6 处(Ch2/3/4/6/8/14/16/18 相关)与 C1 第 4 项结论一致,无串号。✓
- **5.4/5.6 互引(L93 "see 5.4 and 5.6"、L182 "see 5.6")**:EN 保持原文指向,与 ZH 底稿 L93/L182 同位同指(5.4 stop_reason 决策树、5.6 harness_errors 三层类型,指向内容确实覆盖「续跑与自愈」所述主题);B 车道译注按外环裁定不改。✓
- L83 "Seven `pub(crate)` functions" 只列了 6 个名字:与 ZH 底稿逐字对应(ZH L83 同样说「七个」并只列 6 个);facts 表 L130 列出的 7 个 `pub(crate)` 为 sanitize_tool_call_id、normalize_tool_call_ids、normalize_system_messages、repair_message_order、repair_tool_pairs、synthesize_missing_tool_results、truncate_old_tool_results——正文缺列的是 L8 `sanitize_tool_call_id`。这是 ZH 侧既有事实,EN 按契约镜像,不修(修则两侧不对称且涉事实);已移交记录在案,建议源车道在 ZH+EN 同步补列。
- L271 "Four supporting modules, one paragraph each" 实列 7 个模块文件:与 ZH「四个支线模块各用一段交代」逐字对应(ZH 同样列 7 个);支线=memory/prompt_segments/verifier/append_only_audit 四个功能面,后三个(realtime/rich_output/turn_failure)在句尾作"serve specific runtime modes"收束,两种语言同构。EN 镜像不动。✓

### 3.4 代码块

3 块(check_budget L101–119、checkpoint_budget_exhaustion L135–150、observe L190–200、nudge L247–257 共 4 块 rust)与 ZH 逐字节一致(C1 第 1 项含代码块比对已 PASS);本次改动未触碰。✓

## 4. 改动清单(仅 `book-en/src/part2/ch05.md`,3 处)

| # | 行号 | 原文 | 改为 | 理由 |
|---|---|---|---|---|
| 1 | L89 | `so a "estimate while consuming" component is required` | `so an "estimate while consuming" component is required` | 冠词错误:a→an(estimate 元音)。纯语法,不涉数字/引用/mermaid/代码 |
| 2 | L188 | `` `Grace` (L153) is the most special: it is not an error verdict `` | `` `Grace` (L153) is the most unusual: it is not an error verdict `` | 翻译腔:ZH「最特殊的一个」直译为 "the most special"(中式高频误用);"most unusual" 为母语自然等价,语义无损 |
| 3 | L296 | `- The issue #489 (M6.2 typed retry bucket) and #2172 / #2174 commit messages:` | `- Issue #489 (M6.2 typed retry bucket) and the #2172 / #2174 commit messages:` | 冠词冗余:"The issue #489" 冠词与编号并用不地道(编号即特指);并列后半加 the 使结构对齐。纯措辞 |

未改动(有意保留):L133 "truly"/L231 "genuinely"/L3·L87·L293 "actually"(均实义限定);L148/L152 两处 em dash(源码注释与 commit message 原文);5.11 "Chapter Recap" 标题(全书固定栏目名,ch01–ch04 同构)。

## 5. 复验输出(改动后)

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch05-agent-loop.md book-en/src/part2/ch05.md
refs: 59 (equal sets: yes)
en words: 5697, bold 13, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

verify-en 0 FAIL + refs 集合相等(59 = 59)✓;mdbook build 零警告 ✓。改动仅触措辞,数字/引用/代码/mermaid 全部未动。

## 6. 总判定

**通过。** 禁用词/翻译腔 14 类规则逐条清零(3+2 个形态命中均判实义保留);术语 17 项与 glossary 全数一致;三块 mermaid 标签译文忠实;数字/章号/交叉引用与 C1 结论及 ZH 底稿一致;5.4/5.6 互引按外环裁定保持原指。需修 3 处措辞(L89 冠词、L188 翻译腔、L296 冠词)已直接修改并复验通过。G1 C2 最后一个缺口闭合。

遗留移交(不属 EN 车道):ZH L83「七个函数」只列 6 名(缺 `sanitize_tool_call_id`),建议源车道在 ZH+EN 同步补列。
