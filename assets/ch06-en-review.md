# ch06 英文版 C2 读校报告(ch06-en-review,lane strong)

- 日期:2026-09-03
- 读校对象:`book-en/src/part2/ch06.md`(前置:ch06-en 85a8cc2 交付 + 23692b6 过程残留删除;C1 ch06-en-check 6/6 PASS,1c27e2d 归档)
- 对照:中文底稿 `chapters/ch06-tool-system.md`;规范 `.octos/skills/trilingual-collab-en.md` + `specs/translation-en.spec.md`;术语表 `assets/glossary-en.md`;ch01–ch04 英文版 C2 报告范式
- 性质:英文去味 + 母语度 + 技术读校;不改事实/数字/引用语义/mermaid/代码块
- 工作目录:octos-book worktree(branch main,未 commit);改动由 master 采回
- 源码实测基线:octos 主仓 `9c157101`(与本章 Version note 声明一致),所有源码行数/注册名/常量均为只读实测核对

## 1. 外环已裁决待修项范式逐条核查

| 待修项范式 | 命中 | 判定 |
|---|---|---|
| 「双环」术语(dual loop,非 double loop) | `double loop` 0 命中;本章正文「双环」不出现(底稿亦无),天然合规 | **PASS** |
| 顿号(、)残留 | 全文(含代码块外与 mermaid 内)`、` 0 命中;CJK 标点在英文正文区 0 命中 | **PASS** |
| colon reveal(冒号揭幕整句) | 0 处揭幕式冒号。全文冒号均为合规用法:L3 Positioning 固定标签、L30 "How the totals add up:" 引出算式、L109 "shares three rules:" 引出三规则列举、L284 "Gate one, size." 类节内标签、L302 "recent direction:" 引出三工具列举、代码/注释引用内冒号 | **PASS** |
| hedging 前缀(Actually,/ Honestly,/ In fact, 句首) | 0 命中;全篇无 really/just/literally/genuinely/simply/actually/truly 的 hedging 用法(grep 复核 0) | **PASS** |
| recap ending / fake-profound kicker | 0。6.7 Recap 为全书固定编号栏目,enumerate 具体要点(58 entries/10 domains → 三骨架 → 四层机制),末句为具体承接(Ch7/Ch16/Ch18 落点),无 "In conclusion" 式空泛升华、无 mic-drop | **PASS** |
| 「补深度记录/Depth-addition record」段残留 | `Depth-addition` / `深度记录` / `补深度` 全文 0 命中(23692b6 删除已生效,无残留) | **PASS** |

## 2. 禁用词 / 翻译腔(逐条对照 trilingual-collab-en.md)

| 规则 | 命中 | 判定 |
|---|---|---|
| 禁用词 23 词(delve/foster/leverage/utilize/robust/seamless/streamline/pivotal/realm/meticulous/…) | 0(grep 全文件 0 命中,含形态变体) | **PASS** |
| Filler 短语(it's worth noting / at the end of the day / when it comes to / at its core / in order to / let's dive in / Here's the thing / Let me be clear) | 0 | **PASS** |
| Em dash | 0(≤2 阈值内) | **PASS** |
| Bold 撒粉 | 4(Positioning/Version note 固定标签 ×2 + L7 **58 entries** + L246 **untagged tools fail outright (fail closed)**,后两处为关键数字与安全语义的实义强调,对位底稿加粗) | **PASS** |
| Binary contrast("It's not X. It's Y.") | 0 空转式对立。L7 "`registry.rs`, `policy.rs`, `args.rs` … that belong to no domain"、L30 "It is no simple name-to-tool dictionary" 类均为实义否定(底稿同位实义),非修辞模板 | **PASS** |
| -ing 尾随从句(highlighting/underscoring/showcasing) | 0 | **PASS** |
| 三连排比(triplet addiction) | 0 无理由三连。L9 "three-line defense"、L245 "Three dimensions of semantics plus one shell special case"、L273 "Three gates" 均对位底稿「三道防线/三个维度/三道闸」实指结构,内容决定数量 | **PASS** |
| 被动语态 | 全文以主动句为主;被动仅限无施事者可还原处(如 "were bolted on by the RFC-1 fixup" 底稿同位为「补上的」),主动化反而绕 | **PASS** |
| 翻译腔句式(母语度抽查) | L61 "a scar from this batch's early days of dodging Codex-compatible aliases" 对位「早期为躲避 Codex 兼容别名留下的疤」,scar/dodging 均为地道实义;L143 "an architecture autobiography in struct form" 对位「结构体形式的架构自传」;L161 "the sediment layers" 对位「沉积层」;L282 "Zero allocation, zero copy, good enough and stopping there" 对位「零分配零拷贝,够用即止」——均为底稿风格的有意修辞,非翻译腔 | **PASS** |

## 3. 母语度与术语一致性

本章新术语(简报点名 capability domain / exposure control / escape hatch 等)全文用法与底稿概念一一对应,零漂移:

| 术语 | 出现次数 | 一致性判定 |
|---|---|---|
| capability domain / capability-domain | 6 | 全文统一(标题、L15、L63 等),无 "ability area / functional domain" 变体 ✅ |
| exposure control | 7 | 统一(6.3.3 节标题及正文),无 "visibility management" 变体 ✅ |
| escape hatch | 3 | L61 `TOOL_GROUPS` 语境、L274 `# octos:allow-write`、L299 `tool_search`,三处均为「逃生通道」实义,用法一致 ✅ |
| deny-wins | 4 | 统一(连字符形态),与底稿「deny 优先/赢者通吃」对位 ✅ |
| fail closed / fail-closed | 3 + 2 | 副词形态(fail closed)用于行为描述、形容词形态(fail-closed)用于定语,glossary 收录 fail-closed,分工正确 ✅ |
| spawn_only | 17 | 代码符号,原样保留 ✅ |
| tool surface / tool surfaces | 1 | 对位「工具面」,单复数按语境 ✅ |
| tool_output_limit / spawn_only_handle_message 等代码符号 | — | 全部原样,无翻译 ✅ |

glossary-en.md 既有序词(facts table、Positioning/Version note/Further reading/Exercises/Engineering decision、attack surface、fail-closed、approval flow 等)在本章用法均与词条吻合。术语保留英文原文清单(Rust/crate/trait/agent/harness/peer/lane/blackboard/outer loop…)合规:grep 确认无 "工具面"→意译漂移、无 crate/trait 误译。

## 4. 技术读校

### 4.1 mermaid 四块(C1 已裁定的字节级一致标签复核)

底稿与英文 mermaid 区逐块 `md5` 相同(`e2cec0d…`),即四块与中文底稿完全一致——按「不改 mermaid」约束,这是 C2 应确认的终态;块内中文标签(文件系统/执行/Web·研究/记忆/执行循环/后台任务等 31 行 CJK)与底稿同源,非英文版漏译(全书 mermaid 图中英两版共用同一图面,与 ch01–ch05 英文版处理一致:book-en/src/part1 各章 mermaid CJK 行均为 0,而 ch06 底稿本身含中文标签——此处英文版保留底稿原样,与 C1 §5「逐块 cmp 字节级一致」判定一致,C2 不越权改动)。逐块标签与 C1 更正数核对:

- 图 6-1 能力域家族:5 subgraph(文件系统/执行/Web·研究/记忆/Peer·Fleet),与 §6.1 表格 10 域中出图的前 6 域一致(代码结构/Git/技能插件/平台杂项 4 小域按底稿设计不出图,两侧一致)✅
- 图 6-2 spawn_only 时序:7 participant/消息标签与 6.3.3 文字描述(LLM→执行循环→ToolRegistry→后台任务→task_handle→完成回调→下一轮注入)逐项对位 ✅
- 图 6-3 注册路径叠加:with_builtins 基座 → profile allow_list 裁剪 → chat/acp+gateway/session_actor 三支 → apply_policy → mcp.register_tools → specs 缓存输出,与 6.3.4 六路径文字完全对位 ✅
- 图 6-4 策略判定:deny 命中→Deny / allow 空→Allow / require_tags 非空→标签交集→fail closed,与 6.4 deny-wins + fail-closed 语义一致 ✅

### 4.2 数字(对 octos 源码 9c157101 只读实测)

简报所列「66 .rs / 69,553 行 / 44 注册名 / 9 域」在本章与底稿均不存在(疑为其他章或旧稿数字);本章实际关键数字全部实测核对:

| 本章数字 | 实测(9c157101) | 判定 |
|---|---|---|
| 58 条目(57 .rs + admin/ 子目录) | `ls tools/ \| grep -v test` = 58,其中 .rs = 57,admin/ 内 7 文件 | ✅ |
| admin/ 7 文件 3,424 行 | `wc -l admin/*.rs` total = 3,424 | ✅ |
| 骨架三件 registry 3,581 / policy 741 / args 479 | wc -l = 3,581 / 741 / 479 | ✅ |
| read_file 2,366 / write_file 2,220 / shell 2,745 / spawn 5,309 行 | wc -l 全部一致 | ✅ |
| `MAX_ARGS_SIZE = 1_048_576` 在 registry.rs(非 args.rs),:1133 附近 | registry.rs:1133 `const MAX_ARGS_SIZE: usize = 1_048_576` ✅ | ✅ |
| `estimate_json_size` registry.rs:95-119 | :95 定义 | ✅ |
| 输出限额 read_file 50,000 / shell 30,000 / web_fetch 40,000 / web_search 20,000 / search 200,000(utils.rs:180-196) | utils.rs:182-193 实测逐一相符 | ✅ |
| `SSRF_MAX_REDIRECTS = 10`(ssrf.rs:101) | :101 相符 | ✅ |
| TOOL_GROUPS 10 组、`ToolGroupInfo` :180、`:187 onward` | 实测 group: 前缀 11 个枚举值中含 `group:admin` 等——policy.rs 定义 `ToolGroupInfo` 共 11 块;本章 L63 写「10 groups in all」。逐条核对:group:admin/delegated/fs/media/memory/research/robot/runtime/search/sessions/web = 11 个前缀,但其中 `group:robot` 为 robot 专属 tier 门(:26-38 语境),`group:delegated` 为 deny 表(本章 L65 自述「standard deny table」)。若按「可见性分组」口径数,排除 deny 表 delegated 即 10;底稿中文同位也是「10 组」。**两侧一致、且与底稿口径相同(中文版 C 链 factcheck 已裁定),非英文版引入偏差** | ✅(随底稿口径) |
| CODING_P0_REQUIRED_TOOL_NAMES 10 项(apply_patch/exec_command/write_stdin/update_plan/request_user_input/spawn_agent/send_input/resume_agent/wait_agent/close_agent) | coding_tool_contract.rs:85-96 逐项一致 | ✅ |
| 注册名 glob/grep/workspace_log/deep_crawl/search/delegate_task | 各文件 `fn name()` 实测逐一相符(deep_search.rs:71 "search"、delegate.rs:503 "delegate_task"、site_crawl.rs:283 "deep_crawl") | ✅ |
| 20 个 admin_* 操作(admin/ 7 文件) | 与事实表口径一致 | ✅ |
| 数字集合 | C1 §2 已裁定:归一后 162/162 唯一 token,缺失 0/多余 0;C2 抽查关键大数与行号无漂移 | ✅ |

### 4.3 引用与章号

- 源码引用集合:verify-en 实测 refs 89,equal sets: yes(0 miss/0 extra)✅
- 章号引用:Chapter 5×2 / 6×1 / 7×5 / 8×3 / 10×1 / 16×1 / 18×1,与底稿「第 5/6/7/8/10/16/18 章」多重集一致(C1 §4 同判)✅
- commit/issue 号:9c157101(版本注)、552be31(事实表)、172fb2be + #1289(RFC-0 删 LRU)、#1148/#1172/#1886/#607/#1638/#1690/#1765/#1976/#2131/#2193/#896/#28b 均与底稿及事实表一致 ✅
- 交叉锚点:6.3(spawn_only 曝露控制)← L97、6.3.4 ← L184、6.1.3 ← L286、7 章 → 运行时语义,内部编号引用逐个可解析 ✅

## 5. 改动

**无。** 全部读校项通过,未发现必须修改的措辞问题;`book-en/src/part2/ch06.md` 零改动(本工作区仅新增本报告文件)。因此复跑 verify-en 与 mdbook 为确认性复验(文件未变,输出与 C1 基线一致)。

## 6. 复验输出(实跑)

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch06-tool-system.md book-en/src/part2/ch06.md
refs: 89 (equal sets: yes)
en words: 4886, bold 4, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

verify-en:0 FAIL / 0 WARN(refs 89 集合相等、CJK 代码外 0、禁用词 0、em dash 0、bold 4);mdbook build 零警告零错误。

## 7. 结论:C2 通过(可定稿)

- 外环范式 6 项(双环/顿号/colon reveal/hedging/recap ending/补深度残留)逐条 0 命中。
- 禁用词与翻译腔 10 类规则 0 硬命中;bold 4、em dash 0 在阈值内;底稿风格化修辞(scar/sediment/autobiography)判定为有意保留。
- 术语一致:capability domain ×6 / exposure control ×7 / escape hatch ×3 / deny-wins ×4 / fail closed(-) ×5 / spawn_only ×17,全文零漂移;glossary 既有序词吻合。
- 技术读校:mermaid 4 块与底稿逐块字节一致(标签与 C1 更正数对位);关键数字对 9c157101 源码实测全部相符(58 条目/57+7/3,424/3,581/741/479/2,366/2,220/2,745/5,309/1_048_576/五档输出限额/SSRF 10/P0 十项/六个注册名);章号、commit、issue 号全部对位。TOOL_GROUPS「10 组」沿用底稿与事实表口径(可见性分组排除 deny 表),两侧一致,非英文版偏差,仅备考。
- 简报所列「66 .rs / 69,553 行 / 44 注册名 / 9 域」四个数字在本章与底稿均不存在,判定为简报数字串章,不构成缺陷;本章实有数字已全部核毕。
- G2 的 ch06 C2 缺口闭合:ch06-en 翻译(C1 6/6 PASS)→ 本报告 C2 通过。未 commit(遵照 brief);工作区仅本报告一个新增文件。
