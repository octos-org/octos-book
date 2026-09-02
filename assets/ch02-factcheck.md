# Ch2 fact-check 审查报告（ch02-factcheck，C1）

- 审查对象:`chapters/ch02-core-types.md`(从 master 主树 f1a5cd5 拷入的勘误定稿;`book/src/part1/ch02.md` 镜像)
- 源码基线:/Users/zhangalex/Work/Projects/FW/octos @ `9c157101`(git log 实证:`9c157101 docs(guide): document mcp_servers stdio fields…`),范围 crates/octos-core/,只读
- 事实基准:assets/ch02-refcheck.md;标准:AGENTS.md §3 结构锚点 / §6 去味润色预算
- 方法:全部计数来自命令实测(ls / wc -l / grep -n / grep -c / awk / cmp),禁止目测

## 汇总表

| # | 检查项 | 命令(摘要) | 实测输出 | 判定 |
|---|---|---|---|---|
| 1a | 全部 core 引用路径存在 | `grep -noE '(crates/octos-core/src/)?[a-z_]+\.rs:[0-9]+(-[0-9]+)?' ch02` → 48 处引用 → `ls crates/octos-core/src/` | abort/app_ui_codec/app_ui/env_hygiene/error/gateway/git_worktree/lib/message/session_scope/task/types/ui_protocol_tests/ui_protocol/utils 共 15 文件全部在位;章稿引用的 7 个文件名全命中 | ✅ 0 缺失 |
| 1b | 行号不越界 + 符号在区间 | 逐条 `wc -l` + `sed -n`/`grep -n` | task.rs 653、types.rs 1151、error.rs 398、utils.rs 587、message.rs 159、abort.rs 120;48 条引用行号全部 ≤ 文件尾且符号落在区间内(明细见下) | ✅ 0 越界 |
| 1c | 抽查①TurnId | `sed -n '607,623p' ui_protocol.rs` | doc@607、`pub struct TurnId(pub Uuid)`@609、`impl TurnId`/`new()`@611-617、`impl Default`@619-623,与章稿 L161/L173/L669 `ui_protocol.rs:607-623` 一致 | ✅ |
| 1d | 抽查②api_key_not_set 摘录逐字 | `sed -n '89,99p' error.rs` vs 章稿 L380-390 | 逐行一致(含多行 suggestion:`Set the API key:\n export {env_var}=…\n Or add to .octos/config.json:…`) | ✅ 逐字 |
| 1e | 抽查③Display 区间 | `grep -n '^impl' error.rs` | `impl fmt::Display for Error`@174,闭`}`@224,与章稿 L395 `error.rs:174-224` 一致;且区间内@191 实证 `truncated_utf8(body, 200, "…")`(章稿所述截断行为属实) | ✅ |
| 1f | 抽查④truncate 91-96 / report@105 | `sed -n '91,96p;105,108p' utils.rs` | `truncate_head_tail`@94-96(doc 91-93),函数体恰为一行 `truncate_head_tail_report(...).content`,与章稿 L467/L479-485 摘录逐字一致;`truncate_head_tail_report`@105 签名逐字一致 | ✅ |
| 1g | 抽查⑤tool_output_limit 限额表 | `sed -n '180,199p' utils.rs` | read_file 50_000、shell/grep 30_000、web_fetch 40_000、web_search 20_000、**search 200_000、deep_search 200_000、news_fetch 200_000**、deep_research/spawn 50_000、默认 50_000;与章稿 L498-506 表逐格一致,防御性别名注释也在源码@185-188 | ✅ |
| 1h | 抽查⑥白名单 19 个 | `sed -n '603,630p' types.rs` + 数条目 | `is_reserved_channel_name`@603、私有 `is_channel_name`@607;`grep -c` 条目实测 **19**:api, cli, dingtalk, discord, email, feishu, line, local, matrix, qq-bot, slack, system, telegram, test, twilio, wechat, wecom, wecom-bot, whatsapp——与章稿 L531-536 列表逐词一致(含补的 dingtalk/line/local/wechat) | ✅ 19=19 |
| 1i | 抽查⑦根 Cargo.toml:97-98 | `sed -n '95,100p' Cargo.toml`(octos 主树) | 97=`eyre = "0.6"`、98=`color-eyre = "0.6"`,与章稿 L373/L669 一致 | ✅ |
| 2a | 22,313 行 | `find crates/octos-core/src -name '*.rs' -exec cat {} + \| wc -l` | **22313**;`wc -l` 合计同为 22313(15 文件) | ✅ 章稿 L3/L609/L626/L667 |
| 2b | 15,005 口径 | `find … ! -name 'ui_protocol_tests.rs' -exec cat {} + \| wc -l` | **15005**;ui_protocol_tests.rs=`wc -l`=**7308**,章稿 L3/L609/L626/L667 口径一致 | ✅ |
| 2c | ABORT_TRIGGERS 28 | `sed -n '32,71p' abort.rs \| grep -cE '^\s+"[^"]+",?$'` | **28**(9 语言分组注释实证:en/zh/ja/ru/fr/es/hi/ar/ko);章稿 L566「9 种语言、28 个触发词」+L578 一致 | ✅ |
| 3a | §2.9 七文件在位 + 行数 | `wc -l` 逐文件 | abort 120、app_ui 445、app_ui_codec 345、env_hygiene 230、gateway 182、git_worktree **1,579**、session_scope **1,880**——与章稿 L578-584 表 7 行逐一相符;lib.rs@9-21 mod 声明 7 个全在 | ✅ |
| 3b | §2.9 定位描述 vs 源码 | 抽读各文件头注释/符号 | git_worktree「借魂、纯增量、暂不合并」= 源头注释@3-10 逐句对应;session_scope `ScopeMode`(solo/multi_tenant)@313;gateway `MessageOrigin`@22;env_hygiene denylist/sanitizer@1-2/149;app_ui「刻意位于 draft JSON-RPC wire 之上」@2-4 | ✅ |
| 3c | 2.5.3 TruncationReport 摘录 | `sed -n '37,96p' utils.rs` vs 章稿 L469-487 | 字段语义逐项对应:truncated / truncated_by(仅 Bytes 可达、Lines 预留)/ total_bytes / output_bytes(含省略标记) / omitted_bytes=标记中的 N / head_ratio 钳位 [0.1,0.9];动机注释(`total - content.len()` 漏算标记长度)逐字在源码@48-51;d8125d18 日期实证 `2026-08-31` | ✅ |
| 4a | 锚点×1 | `grep -c '^> \*\*定位\*\*'` | **1** | ✅ |
| 4b | 版本演化说明×1 | `grep -c '版本演化说明'` | **1**(L665,锚定 9c157101@L667) | ✅ |
| 4c | mermaid = 3 | `grep -c '```mermaid'` | **3** | ✅ |
| 4d | 镜像 cmp | `cmp chapters/ch02-core-types.md book/src/part1/ch02.md` | 无输出(一致),两文件各 671 行;SUMMARY.md@10 已挂 part1/ch02.md | ✅ |
| 4e | —— ≤2 | `grep -o '——' \| wc -l` | **2** | ✅ |
| 4f | 加粗 ≤10 | `awk '/^```/{inCode=!inCode;next} !inCode' \| grep -o '\*\*[^*]*\*\*' \| wc -l` | **30 对**,超预算(≤10)3 倍 | ❌ major |
| 4g | 黑话 9 词零命中 | `grep -c` 逐词:护城河/深水区/底层逻辑/抓手/赋能/闭环/降维打击/颗粒度/对标 | 全部 **0** | ✅ |

其余引用逐条核验(未列入抽查的 40 条):task.rs 11-29/63-77/79-99/102-115/125-157/138-157/159-173/188-305/233-305、types.rs 12-64/79-177/12-177/180-189/227-258/229-256/232-234/239-241/310-350(assistant_with_thread@318、tool_with_thread@337)/444-451/453-463/465-469/471-479/476-478/355-417/489-567/525-528/530-533、error.rs 10-17/20-56(ErrorKind 实数 15 变体=章稿所写)/80-173/89-99、message.rs 10-29/31-42、utils.rs 6-16/21-30、abort.rs 6-13/15-30/32-71——`sed -n` 逐条比对,行号与符号全部命中;代码摘录与源码逐行一致(Task/TaskStatus/TaskKind/TaskContext/TaskResult/TokenUsage/SessionSummary/Error/ErrorKind/Message/MessageRole/as_str/Display/ToolCall/AgentMessage/task_id/truncate_utf8 两变体;省略 serde attr 属合理简化)。

## 分级

**Critical:0。** 无事实错误、无失效引用、无过期数字。refcheck 提出的 8 处修正(TurnId 607-623、api_key_not_set 多行摘录、Display 174-224、truncate 91-96/105、tool_output_limit 限额表含 search/news_fetch/deep_search=200,000、白名单 19、Cargo.toml 97-98)在定稿中**全部落实并经本次独立复测确认**;refcheck 4 条内容性备注(22,313/15,005、28 触发词、tracing/sha2 依赖、白名单 19)也全部落实(L3/L566/L618/L531)。

**Major:1。**
- M1. 加粗 30 对,超预算(全篇 ≤10,AGENTS.md §6)。分布:小节内要点标签(TaskId/parent_id/result、差异一/差异二、truncate_utf8/truncated_utf8)、侧栏方案标题、本章回顾 7 条编号项等。事实无伤,属一轮机械降粗:保留术语首定义级强调,其余改正体。

**Minor:2。**
- m1. L401「只有 10 行代码(`utils.rs:6-16`)」:区间实为 11 行(6-16 含签名与闭括号),「10 行」为约数,建议写「约 10 行」或改 6-16 为 7-15(函数体)。
- m2. L377 便捷构造函数区间 `error.rs:80-173` 略松:`impl Error` 实际 @58-172(闭括号 172),构造函数区约 83-171;引用的 api_key_not_set@89 在区间内,不影响正确性,建议改 58-172 或 83-171。

## 是否可定稿

**可定稿(附 1 项 major 润色建议)。** 全部 C1 机械项与事实核查通过:48 处源码引用 0 缺失 0 越界 0 符号落空,内容数字(22,313/15,005/7,308/28/19)全部实测相符,§2.9 七文件与源码在位一致,锚点/版本演化说明/mermaid×3/镜像 cmp/破折号≤2/黑话零命中全绿。唯一超支项是加粗 30 对 > 预算 10,不改任何事实,建议定稿前做一轮机械降粗(或由编辑在合并时顺手处理);两条 minor 为可选的行号收紧。
