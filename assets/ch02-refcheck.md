# Ch2 引用核对报告（ch02-refcheck）

- 核对对象：`chapters/ch02-core-types.md` 全部 `crates/octos-core/src/*.rs` 引用（含简写 `xxx.rs:a-b` 形式）
- 源码基线：/Users/zhangalex/Work/Projects/FW/octos @ main `9c157101`（只读，未做任何修改）
- 核对方法：每条引用实际执行 `ls`（路径）、`wc -l`（越界）、`grep -n`/`sed -n`（符号在位）、摘录 diff

## 汇总统计

| 指标 | 数值 |
|---|---|
| 总引用数（含 1 条范围外备注） | 46 |
| ✅ 有效 | 38 |
| ❌ 路径不存在 | 0 |
| ⚠️ 需修正（行号漂移 / 符号不在区间 / 摘录不一致） | 8 |

### 全部需要修正的引用清单（给 editor 直接用）

| # | 章稿行号 | 现引用 | 应改为 | 说明 |
|---|---|---|---|---|
| 1 | 161 | `ui_protocol.rs:271-288` | `ui_protocol.rs:607-623` | TurnId 定义已漂移：`pub struct TurnId` 在 609，impl 611-617，Default 619-623；271-288 现在是 feature-flag 常量区 |
| 2 | 173 | `crates/octos-core/src/ui_protocol.rs:271-288` | `crates/octos-core/src/ui_protocol.rs:607-623` | 同上 |
| 3 | 380-392 | `api_key_not_set` 摘录 | 按源码 error.rs:89-99 改写 | 摘录中 suggestion 为 `format!("Set the {} environment variable or configure it in config.json", env_var)`，实际源码是多行文本：`"Set the API key:\n    export {env_var}=your-api-key\n  Or add to .octos/config.json:\n    {{\"api_key_env\": \"{env_var}\"}}"` |
| 4 | 397 | `error.rs:175-228` | `error.rs:174-224` | Display impl 实际 174-224（`impl fmt::Display for Error` @174，结束于 224） |
| 5 | 469 | `utils.rs:37-70` | `utils.rs:91-96` | `truncate_head_tail` 实际 @94-96（doc 91-93）；37-70 现在是 `TruncatedBy`/`TruncationReport`。建议同时补一句：它是 `truncate_head_tail_report`（@105）的薄包装（spec 决策项） |
| 6 | 484 | `utils.rs:73-85` | `utils.rs:180-199` | `tool_output_limit` 实际 @180-199；**限额表也过期**：`search`=200,000、`news_fetch`=200,000、`deep_search`=200,000（章稿写 deep_search 50,000 且漏了 search/news_fetch 两行）；read_file 50K、shell/grep 30K、web_fetch 40K、web_search 20K、deep_research/spawn 50K、默认 50K 均正确 |
| 7 | 518 | `types.rs:569-588` | `types.rs:603-630` | `is_reserved_channel_name` @603、`is_channel_name`（私有）@607；**白名单数量过期**：实际 19 个（章稿列 15 个，缺 `dingtalk`、`line`、`local`、`wechat`），"15 个已知 channel" 应改 19 |
| 8 | 373 | `Cargo.toml:71-72` | `Cargo.toml:97-98` | （范围外备注）workspace 根 Cargo.toml 中 eyre/color-eyre 实际在 97-98 行 |

### 内容性备注（非行号引用，建议 editor 顺手修）

1. **章稿 L3/L578/L595 "约 8.8k 行"**：实际 `crates/octos-core/src/*.rs` 共 22,313 行（含 ui_protocol_tests.rs 7,308 行；剔除测试文件约 15,005 行）。"大头是 UI Protocol wire 类型" 方向正确（ui_protocol.rs 7,221 行 + tests 7,308 行）。
2. **章稿 L553 "30 个触发词"**：`ABORT_TRIGGERS`（abort.rs:32-71）实际 28 个词条；9 种语言正确；源文件顶部 doc 注释写 "30+"。建议章稿写 "约 30 个（实际 28）" 或 "9 种语言、28 个触发词"。
3. **章稿 L587 侧栏外部依赖列表**：core `[dependencies]` 实际为 serde、serde_json、chrono、uuid、eyre、**tracing、sha2**（见 crates/octos-core/Cargo.toml）。章稿漏了 tracing 和 sha2；"零内部依赖" 结论仍成立。
4. 其余代码摘录（Task/TaskStatus/TaskKind/TaskContext/TaskResult/SessionSummary/Error/ErrorKind/Message/MessageRole/as_str/Display/ToolCall/AgentMessage/truncate_utf8 两变体）与源码逐行比对**一致**（省略 serde attr 的属合理简化）。

---

## 逐条核对明细

状态：✅有效 / ❌路径不存在 / ⚠️行号漂移 / ⚠️符号不在区间 / ⚠️摘录不一致

| 章稿行号 | 引用（路径:行号） | 状态 | 符号名 | 当前正确行号或说明 |
|---|---|---|---|---|
| 17 | `crates/octos-core/src/task.rs:11-29` | ✅ | `Task` | struct @12-29，字段与摘录一致 |
| 34 | `crates/octos-core/src/types.rs:180-189` | ✅ | `TaskId` | struct @182，`new()` 用 `Uuid::now_v7` @186-188 |
| 42 | `crates/octos-core/src/task.rs:63-77` | ✅ | `TaskStatus` | enum @66-77，5 变体一致 |
| 77 | `crates/octos-core/src/task.rs:79-99` | ✅ | `TaskKind` | enum @82-99，5 变体一致 |
| 93 | `crates/octos-core/src/task.rs:102-115` | ✅ | `TaskContext` | struct @103-115，字段一致 |
| 107 | `crates/octos-core/src/task.rs:125-157` | ✅ | `TaskResult` | struct @138-157 |
| 121 | `crates/octos-core/src/task.rs:159-173` | ✅ | `TokenUsage` | struct @161-173，5 字段 + `is_zero` skip 一致 |
| 131 | `crates/octos-core/src/types.rs:227-258` | ✅ | `Message` | struct @229-258 |
| 147 | `types.rs:232-234` | ✅ | `media` 字段 | doc @232，attr @233，字段 @234 |
| 149 | `types.rs:239-241` | ✅ | `reasoning_content` | doc @239，attr @240，字段 @241 |
| 151 | `crates/octos-core/src/types.rs:229-256` | ✅ | `client_message_id`/`thread_id` | @248 / @256，均在区间内 |
| 159 | `types.rs:12-64` | ✅ | `ClientMessageId` | doc @12-22，struct @23，impl 至 64 |
| 160 | `types.rs:79-177` | ✅ | `ThreadId` | doc @79 起，struct @88，impl 至 177 |
| 161 | `ui_protocol.rs:271-288` | ⚠️ 符号不在区间 | `TurnId` | 实际 @607-623（struct @609）；271-288 是 feature-flag 常量 |
| 173 | `crates/octos-core/src/types.rs:12-177` | ✅ | `ClientMessageId`+`ThreadId` | 两 newtype 均在 12-177 内 |
| 173 | `crates/octos-core/src/ui_protocol.rs:271-288` | ⚠️ 符号不在区间 | `TurnId` | 同 L161，应改 607-623 |
| 184 | `crates/octos-core/src/types.rs:310-350` | ✅ | `assistant_with_thread`/`tool_with_thread` | @318 / @337-350 |
| 188 | `crates/octos-core/src/types.rs:444-451` | ✅ | `MessageRole` | enum @446-451（attr 444-445） |
| 199 | `types.rs:453-463` | ✅ | `MessageRole::as_str` | impl @453-463，摘录逐字一致 |
| 214 | `types.rs:465-469` | ✅ | `impl Display for MessageRole` | @465-469，摘录一致 |
| 233 | `crates/octos-core/src/types.rs:471-479` | ✅ | `ToolCall` | struct @472-479 |
| 244 | `types.rs:476-478` | ✅ | `metadata` 字段 | doc @476，attr @477，字段 @478 |
| 248 | `types.rs:355-417` | ✅ | `user`/`assistant`/`system` legacy 构造器 | @364 / @385 / @405-417（均 `#[doc(hidden)]`，与"legacy"表述一致） |
| 266 | `crates/octos-core/src/task.rs:138-157` | ✅ | `TaskResult.schema_version` | 字段 @142-144，serde default @142；`TASK_RESULT_SCHEMA_VERSION=1` @130 |
| 284 | `crates/octos-core/src/task.rs:233-305` | ✅ | `SessionSummary` | struct @233-286，摘录字段一致 |
| 306 | `crates/octos-core/src/task.rs:188-305` | ✅ | `validate_schema_version`/`UnsupportedSessionSummaryVersion` | error struct @198-215，validate @290（均在区间） |
| 331 | `crates/octos-core/src/error.rs:10-17` | ✅ | `Error` | struct @10-17 |
| 343 | `error.rs:20-56` | ✅ | `ErrorKind` | enum @21-56，15 变体与摘录一致 |
| 377 | `error.rs:80-173` | ✅ | 便捷构造函数群 | task_not_found @83、api_key_not_set @89、unknown_provider @100、api_error @108、… session_error 至 ~161，均在区间 |
| 380-392 | `api_key_not_set` 摘录 | ⚠️ 摘录不一致 | `api_key_not_set` | 函数位置正确（@89-99），但 suggestion 文本与源码不符（见修正清单 #3） |
| 397 | `error.rs:175-228` | ⚠️ 行号漂移 | `impl fmt::Display for Error` | 实际 @174-224；`truncated_utf8` 调用在 @191，与叙述一致 |
| 403 | `crates/octos-core/src/utils.rs:6-16` | ✅ | `truncate_utf8` | fn @6-16，摘录逐字一致 |
| 428 | `utils.rs:6-16` | ✅ | `truncate_utf8` | 同上 |
| 444 | `utils.rs:21-30` | ✅ | `truncated_utf8` | fn @21-31，摘录逐字一致 |
| 469 | `utils.rs:37-70` | ⚠️ 符号不在区间 | `truncate_head_tail` | 实际 @91-96（fn @94）；37-70 是 `TruncatedBy`/`TruncationReport` 定义。签名与 `[0.1,0.9]` 钳位叙述与源码一致 |
| 484 | `utils.rs:73-85` | ⚠️ 符号不在区间 | `tool_output_limit` | 实际 @180-199；限额表部分过期（见修正清单 #6） |
| 501 | `crates/octos-core/src/types.rs:489-567` | ✅ | `SessionKey` | struct @491，impl 含 new/with_profile/with_topic/base_key/topic 等，均在区间 |
| 514 | `types.rs:525-528` | ✅ | `base_key()` | fn @526-528 |
| 514 | `types.rs:530-533` | ✅ | `topic()` | fn @531-533 |
| 518 | `types.rs:569-588` | ⚠️ 行号漂移 | `is_channel_name` | 实际：`is_reserved_channel_name` @603-605、`is_channel_name`（私有）@607-630；白名单 19 个非 15 个 |
| 531 | `crates/octos-core/src/message.rs:10-29` | ✅ | `AgentMessage` | enum @11-29，5 变体与摘录一致（`ContextResponse` 源码分 3 行书写，语义一致） |
| 545 | `message.rs:31-42` | ✅ | `AgentMessage::task_id` | impl @31，fn @33-42 |
| 553 | `abort.rs:32-71` | ✅（附注） | `ABORT_TRIGGERS` | 数组 @32-71 准确；但"30 个触发词"实际 28 个（见内容备注 2） |
| 553 | `abort.rs:6-13` | ✅ | `is_abort_trigger` | doc @5-9，fn @10-13 |
| 553 | `abort.rs:15-30` | ✅ | `abort_response` | doc @15，fn @16-30，9 语言分支一致 |
| 373 | `Cargo.toml:71-72`（workspace 根，范围外备注） | ⚠️ 行号漂移 | eyre/color-eyre 依赖声明 | 实际在 workspace 根 Cargo.toml @97-98 |

行数边界核对（`wc -l`）：task.rs 653 / types.rs 1151 / ui_protocol.rs 7221 / error.rs 398 / utils.rs 587 / message.rs 159 / abort.rs 120 —— 全部引用区间上界均未越界（失效原因均为符号漂移，非越界）。

---

## 新增源文件盘点

spec `specs/ch02-core-types.spec.md`「决策」段列出的 7 个新增文件全部存在；"2026-09-02 main 共 15 个源文件" 经 `ls src/*.rs | wc -l` 核实为 **15** ✅（abort, app_ui, app_ui_codec, env_hygiene, error, gateway, git_worktree, lib, message, session_scope, task, types, ui_protocol, ui_protocol_tests, utils）。

| 文件 | 行数 | 顶部 `//!` 摘要 | 主要 pub 符号 |
|---|---|---|---|
| `abort.rs` | 120 | 多语言中断触发词检测：识别 9 种语言 30+ 个取消词，用于聊天式中止在途 Agent 操作 | `is_abort_trigger`, `abort_response`（lib.rs 再导出） |
| `app_ui.rs` | 445 | 面向 App 客户端的稳定 UI API 层，刻意位于 draft JSON-RPC wire 协议之上，TUI/App 依赖这些 app 概念 | `AppUiLaunch`, `AppUiSnapshot`, `AppUiSession`, `AppUiTask`, `AppUiLiveReply`, `AppUiCommand`, `AppUiEvent`, `AppUiStatus`, `AppUiError` |
| `app_ui_codec.rs` | 345 | AppUI 共享 JSON-RPC 文本帧编解码：传输中立的帧规则，供 WebSocket 文本帧与 stdio NDJSON 复用 | `AppUiFrame`, `to_compact_json`, `to_ndjson_frame`, `parse_ndjson_frame`, `parse_text_frame`, `frame_too_large_error`, `FRAME_TOO_LARGE` |
| `env_hygiene.rs` | 230 | 子进程环境卫生：进程注入变量 denylist + 秘密名启发式 + `Command` 消毒器；放在最底层 crate 以便 agent spawner 与 core 自身 git ops 共用单一事实源 | `BLOCKED_ENV_VARS`, `is_secret_env_name`, `is_registered_secret_env_name`, `register_secret_env_names`, `sanitize_git_command_env` |
| `gateway.rs` | 182 | 基于频道的网关消息类型（入站/出站消息与来源标记） | `MessageOrigin`, `InboundMessage`, `OutboundMessage`, `METADATA_SENDER_USER_ID` |
| `git_worktree.rs` | 1579 | 共享 `git worktree` 管道：让 fleet-worker 池为每个任务分配真实 worktree 而无需依赖 octos-agent；含安全章节（worktree worker 是全信任 worker） | `prepare_fleet_worktree`, `PreparedWorktree`, `deliverable_commit_command`, `worktree_populate_command`, `is_git_repo`, `probe_git_repo`, `git_ref_exists`, `branch_advanced_past`, `remove_checkout_keep_branch`, `clear_worktree_admin_entry` |
| `session_scope.rs` | 1880 | SessionScope——octos 组件文件系统访问的单一契约：所有组件必须由 SessionScope 派生工作目录并校验路径，禁止各自从 raw 输入推算 | `SessionScope`, `ScopeMode`, `PathClassification`, `SessionScopeError`, `SESSION_SCOPE_SCHEMA_VERSION`, `multi_tenant`, `solo`, `root`, `workspace`, `classify_lexical_path`, `classify_canonical_path`, `canonicalize_lossy`, `canonical_root_lossy`, `canonicalize_skill_read_zones`, `is_safe_session_id` |

（pub 符号清单用 `grep -E 'pub (fn|struct|enum|trait|const)'` 提取；`const`/`static` 一并列出供归类文案引用。）

---

*报告生成：peer ch02-refcheck；未修改 octos 源码仓库与本仓库其他任何文件；未 commit。*
