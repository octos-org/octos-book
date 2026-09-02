# 附录 B 事实表 — 工具速查表数据(octos-book v2)

- **源码基准 commit**: `9c157101`(main 分支,只读实测)
- **统计日期**: 2026-09-03
- **采集方式**: octos 源码仓库 `/Users/zhangalex/Work/Projects/FW/octos` 直跑实测(只读);以 `assets/ch06-facts.md` 为底,逐工具 `//!` 首行 + `fn name()` + `input_schema` 复核
- **口径**: `crates/octos-agent/src/tools/` 共 **58 个条目**(57 个 .rs + admin/ 子目录,ch06-facts §1);本表逐工具枚举 **80 个注册名**(核心 60 + admin 20),另标注 6 个内部/共享件(非模型可见注册名)。域分组以 `crates/octos-agent/src/tools/policy.rs:186` `TOOL_GROUPS`(10 组)与 ch06-facts §2 能力域双重对照

---

## 1. coding_tools 的 9 个 shim 与 P0 required 10 的关系(重点)

- 源文件: `crates/octos-agent/src/tools/coding_tools.rs`(首行 `//!`: "Codex-compatible P0 coding tool shims.")。该文件定义 **15 个注册名**:9 个结构体工具 + 6 个 `simple_codex_tool!` 宏工具(coding_tools.rs:1827-1862)。
- **P0 required 10** 定义于 `crates/octos-cli/src/api/coding_tool_contract.rs:85` `CODING_P0_REQUIRED_TOOL_NAMES`:
  `apply_patch, exec_command, write_stdin, update_plan, request_user_input, spawn_agent, send_input, resume_agent, wait_agent, close_agent`。
- **映射关系**: P0 10 = `apply_patch`(原生文件工具,`crates/octos-agent/src/tools/apply_patch.rs`,不在 coding_tools.rs)+ **coding_tools.rs 内的 9 个**(`exec_command, write_stdin, update_plan, request_user_input, spawn_agent, send_input, resume_agent, wait_agent, close_agent`)。
- 简报点名的 **9 个 headline shim**(exec_command/write_stdin/spawn_agent/bash/delegate/view_image/tool_search/tool_suggest/image_generation)中,仅前 3 个(exec_command/write_stdin/spawn_agent)属 P0;其余 6 个的关系:

| shim | 注册名 | 与 P0 的关系 | 依据(全路径) |
|---|---|---|---|
| exec_command | `exec_command` | **P0 成员** | coding_tools.rs:382;contract:85 |
| write_stdin | `write_stdin` | **P0 成员** | coding_tools.rs:739 |
| spawn_agent | `spawn_agent` | **P0 成员** | coding_tools.rs:1284 |
| bash | `bash` | P0 外,#1172 命名对齐别名(与 shell/exec_command 共享 policy+sandbox,三者一处 deny 处处 deny) | coding_tools.rs:1946;registry.rs:1283-1290 |
| delegate | `delegate` | P0 外,#1172 一站式 wrapper(`DelegateAliasTool`,绑定 spawn_agent,group:sessions 成员) | coding_tools.rs:2429;registry.rs:549,567,1303 |
| view_image | `view_image` | P0 外,#972/M14-B P1 图像检视,只读、受 filesystem_scope 约束 | coding_tools.rs:2801;registry.rs:1357-1361 |
| tool_search | `tool_search` | P0 外,#1148 codex P2 动态发现,读 live catalog cell | coding_tools.rs:3150;registry.rs:1369-1373 |
| tool_suggest | `tool_suggest` | P0 外,同 #1148,按任务推荐工具 | coding_tools.rs:3251;registry.rs:1374 |
| image_generation | `image_generation` | P0 外,#1149/M14-B P2;**当前返回 typed `coding_tool_unsupported` envelope**(无原生/技能后端绑定,wire 合约完整,不再报 tool not found) | coding_tools.rs:3389;registry.rs:1361-1369 注释原文 |

- **spec 附录另须注明**(specs/appendix-b-tool-reference.spec.md:41-42):`image_generation` typed unsupported(证据同上);`send_input` 当前**不是实时 conversational delivery**(注册为 `simple_codex_tool!`,coding_tools.rs:1839-1842;spec 要求正文说明该限制)。
- 注册位置:全部 15 个在 `crates/octos-agent/src/tools/registry.rs` `with_builtins_and_permissions`(registry.rs:1275-1376)注册;`bash`/`exec_command` 属 `CWD_BOUND_TOOLS`(registry.rs:1435-1470),rebind_cwd 时随工作区重绑。

---

## 2. 逐工具数据表(按 ch06-facts §2 能力域;全路径 + 生成命令)

生成命令约定(每行适用,`<F>`=该行源文件全路径):
- 注册名: `grep -n 'fn name(' -A3 <F> | grep '"'`
- 一句话职责: `grep -m1 '^//!' <F>`(无 `//!` 时取 `fn description()` 返回串: `grep -n 'fn description(' -A3 <F>`)
- 参数: `grep -n 'fn input_schema(' -A25 <F>`

### 2.1 文件系统(fs)

| 注册名 | 源文件(全路径) | 一句话职责 | 门 |
|---|---|---|---|
| read_file | crates/octos-agent/src/tools/read_file.rs | Read file tool | — |
| write_file | crates/octos-agent/src/tools/write_file.rs | Write file tool for creating new files | — |
| edit_file | crates/octos-agent/src/tools/edit_file.rs | Edit file tool for making precise text replacements | — |
| diff_edit | crates/octos-agent/src/tools/diff_edit.rs | Diff-based file editing tool using unified diff format | — |
| apply_patch | crates/octos-agent/src/tools/apply_patch.rs | Codex-style `apply_patch` tool (#1773);P0 成员 | — |
| list_dir | crates/octos-agent/src/tools/list_dir.rs | List directory tool | — |
| glob | crates/octos-agent/src/tools/glob_tool.rs | Glob tool for finding files by pattern | — |
| grep | crates/octos-agent/src/tools/grep_tool.rs | Grep tool for searching file contents | — |
| workspace_log | crates/octos-agent/src/tools/workspace_history.rs | Read-only workspace git history tools | — |
| workspace_show | 同上 workspace_history.rs | 按 commit 读文件 | — |
| workspace_diff | 同上 workspace_history.rs | 两 commit 间 diff | — |
| (内部)replacer | crates/octos-agent/src/tools/replacer.rs | Cascading fuzzy replacer chain for `edit_file` (#1771);非独立注册名 | — |
| (内部,flag)read_window | crates/octos-agent/src/tools/read_window.rs | Flag-gated windowed read_file enforcement (#1638),**Off by default** | 环境变量 `OCTOS_READ_WINDOW=1`(read_window.rs:177) |
| (内部,flag)read_paging_probe | crates/octos-agent/src/tools/read_paging_probe.rs | Observe-only probe for the read-paging question; Records nothing unless armed | 环境变量 `OCTOS_READ_PAGING_PROBE=1`(read_paging_probe.rs:131) |

生成命令: `for t in read_file write_file edit_file diff_edit apply_patch list_dir glob_tool grep_tool workspace_history replacer read_window read_paging_probe; do grep -m1 '^//!' crates/octos-agent/src/tools/$t.rs; done`

### 2.2 Shell/执行(runtime)

| 注册名 | 源文件 | 一句话职责 | 门 |
|---|---|---|---|
| shell | crates/octos-agent/src/tools/shell.rs | Shell tool for executing commands | — |
| exec_command | crates/octos-agent/src/tools/coding_tools.rs | Codex-compatible 长任务 exec(会话化 stdin/yield,P0) | — |
| bash | 同上 coding_tools.rs | Codex 命名对齐一次性 shell 别名 | — |
| write_stdin | 同上 coding_tools.rs | 向 exec 会话写 stdin 并回收输出(P0) | — |
| check | crates/octos-agent/src/tools/check.rs | Project static-check tool (#1772, lite scope) | — |
| (内部)write_grant | crates/octos-agent/src/tools/write_grant.rs | #1976 per-path WRITE-grant enforcement for the native file tools;非模型可见注册名 | — |

生成命令: `grep -m1 '^//!' crates/octos-agent/src/tools/{shell,check,write_grant}.rs`

### 2.3 Web/研究(web/search/research)

| 注册名 | 源文件 | 一句话职责 | 门 |
|---|---|---|---|
| web_search | crates/octos-agent/src/tools/web_search.rs | Web search tool with multiple provider support | — |
| web_fetch | crates/octos-agent/src/tools/web_fetch.rs | Web fetch tool for retrieving URL content | — |
| browser | crates/octos-agent/src/tools/browser.rs | Browser automation tool using chromiumoxide (Chrome DevTools Protocol) | — |
| search | crates/octos-agent/src/tools/deep_search.rs | Deep search tool: web search + parallel crawl, saving results to disk | — |
| synthesize_research | crates/octos-agent/src/tools/synthesize_research.rs | Synthesize research tool: reads search source files and produces a synthesis | — |
| deep_crawl | crates/octos-agent/src/tools/site_crawl.rs | Deep crawl tool: CDP-based recursive site crawler | — |
| (共享库)http/ssrf/research_utils | crates/octos-agent/src/tools/{http,ssrf,research_utils}.rs | HTTP-backed tool / Shared SSRF protection / Shared utilities for research tools;非独立模型可见注册名 | — |

生成命令: `grep -m1 '^//!' crates/octos-agent/src/tools/{web_search,web_fetch,browser,deep_search,synthesize_research,site_crawl,http,ssrf,research_utils}.rs`

### 2.4 记忆(memory)

| 注册名 | 源文件 | 一句话职责 | 门 |
|---|---|---|---|
| memory_note | crates/octos-agent/src/tools/memory_note.rs | Memory note tool: append-only capture of memory-worthy observations | — |
| record_memory_use | crates/octos-agent/src/tools/record_memory_use.rs | Record-memory-use tool: the model reports which memory entries actually informed the answer | — |
| recall | crates/octos-agent/src/tools/recall.rs | Recall tool (#2131): re-materialize a tool output that compaction replaced | — |
| recall_memory | crates/octos-agent/src/tools/recall_memory.rs | Recall memory tool: load full entity pages from the memory bank | — |
| save_memory | crates/octos-agent/src/tools/save_memory.rs | Save memory tool: write/update entity pages in the memory bank | — |

生成命令: `grep -m1 '^//!' crates/octos-agent/src/tools/{memory_note,record_memory_use,recall,recall_memory,save_memory}.rs`

### 2.5 消息/交互

| 注册名 | 源文件 | 一句话职责 | 门 |
|---|---|---|---|
| message | crates/octos-agent/src/tools/message.rs | Message tool for cross-channel messaging | — |
| send_file | crates/octos-agent/src/tools/send_file.rs | Send file tool for delivering files to chat channels | — |
| send_app_card | crates/octos-agent/src/tools/send_app_card.rs | Send-app-card tool: deliver a structured mini-app payload | — |
| ask_user_question | crates/octos-agent/src/tools/ask_user_question.rs | structured mid-turn user question (UPCR-2026-023) | — |

生成命令: `grep -m1 '^//!' crates/octos-agent/src/tools/{message,send_file,send_app_card,ask_user_question}.rs`

### 2.6 Peer/Fleet(sessions)

| 注册名 | 源文件 | 一句话职责 | 门 |
|---|---|---|---|
| spawn | crates/octos-agent/src/tools/spawn.rs | Spawn a subagent to work on a task; mode='sync' waits, 'background' fire-and-forget(spawn.rs:2925 description) | — |
| delegate_task | crates/octos-agent/src/tools/delegate.rs | Synchronous DelegateTool(delegate.rs:503;注意 registry 注册名为 delegate_task,`delegate` 是 coding_tools.rs 的别名 wrapper) | — |
| peer_handoff | crates/octos-agent/src/tools/peer_handoff.rs | LLM-initiated peer staging (#1801 v3) | — |
| peer_send_input | crates/octos-agent/src/tools/peer_send_input.rs | master→peer cross-session input injection (#436) | — |
| peer_gather | crates/octos-agent/src/tools/peer_gather.rs | model-readable peer blackboard (#1801 v3 fan-in) | — |
| peer_list | crates/octos-agent/src/tools/peer_list.rs | compact status index of the caller's peers | — |
| peer_respond | crates/octos-agent/src/tools/peer_respond.rs | master→peer answer for a BLOCKED peer (human-in-the-loop) | — |
| peer_close | crates/octos-agent/src/tools/peer_close.rs | retire a running peer you created | — |
| check_background_tasks | crates/octos-agent/src/tools/check_background_tasks.rs | Session-scoped background task inspection | — |
| read_task_output | crates/octos-agent/src/tools/read_task_output.rs | selective inspection of background task output | — |

生成命令: `grep -m1 '^//!' crates/octos-agent/src/tools/{spawn,delegate,peer_handoff,peer_send_input,peer_gather,peer_list,peer_respond,peer_close,check_background_tasks,read_task_output}.rs`

### 2.7 代码/结构(coding_tools 全 15 名在此)

| 注册名 | 源文件 | 一句话职责 | 门 |
|---|---|---|---|
| code_structure | crates/octos-agent/src/tools/code_structure.rs | Code structure analysis tool using tree-sitter for AST parsing | **feature = "ast"**(tools/mod.rs:864) |
| exec_command / write_stdin / spawn_agent / bash / delegate / view_image / tool_search / tool_suggest / image_generation | crates/octos-agent/src/tools/coding_tools.rs | 见 §1 逐条 | — |
| update_plan | 同上 coding_tools.rs(:1827) | Update the visible task plan for Codex-compatible coding workflows(P0) | — |
| request_user_input | 同上(:1833) | Request structured user input from the host UI(P0) | — |
| send_input | 同上(:1839) | Send input to a Codex-compatible subagent(P0;**非实时 conversational delivery**) | — |
| resume_agent | 同上(:1845) | Resume a Codex-compatible subagent handle(P0) | — |
| wait_agent | 同上(:1851) | Inspect or wait on Codex-compatible subagent handles(P0) | — |
| close_agent | 同上(:1857) | Close or cancel a Codex-compatible subagent handle(P0) | — |

生成命令: `sed -n '1827,1862p' crates/octos-agent/src/tools/coding_tools.rs`(六个宏注册的注册名+描述即在此)

### 2.8 Git

| 注册名 | 源文件 | 一句话职责 | 门 |
|---|---|---|---|
| git | crates/octos-agent/src/tools/git.rs | Native git integration tool using gix (pure Rust) | **feature = "git"**(tools/mod.rs:861) |

生成命令: `grep -m1 '^//!' crates/octos-agent/src/tools/git.rs`

### 2.9 技能/插件/平台

| 注册名 | 源文件 | 一句话职责 | 门 |
|---|---|---|---|
| manage_skills | crates/octos-agent/src/tools/manage_skills.rs | Skill management tool for normal profile gateways | — |
| mofa_make | crates/octos-agent/src/tools/mofa_make.rs | RFC-1 (issue #1290) content-generator dispatcher;spawn_only(profile/mod.rs:874),具体系列 internal_hidden(mofa_make.rs:986-987) | — |
| check_workspace_contract | crates/octos-agent/src/tools/check_workspace_contract.rs | Read-only inspection of workspace contract state | — |
| configure_tool | crates/octos-agent/src/tools/tool_config.rs | Persistent per-tool configuration store | — |
| model_check | (chat 网关注册;group:admin 成员,policy.rs:254-258) | 模型/供应商清点 | — |
| (共享件)dora_bridge | crates/octos-agent/src/tools/dora_bridge.rs | Dora-RS to MCP tool bridge — canonical home for the HTTP-transport;非独立注册名 | — |
| (共享件)mcp_agent | crates/octos-agent/src/tools/mcp_agent.rs | MCP-backed sub-agent backends for SpawnTool;后端而非注册名 | — |
| (共享件)robot_groups | crates/octos-agent/src/tools/robot_groups.rs | Registry mapping robot tools to supervisory safety tiers;非注册名 | — |
| (共享件)args / policy / registry / mod | crates/octos-agent/src/tools/{args,policy,registry,mod}.rs | 骨架:参数校验 / 策略与分组 / 注册表 / 模块根;非注册名 | — |

生成命令: `grep -m1 '^//!' crates/octos-agent/src/tools/{manage_skills,mofa_make,check_workspace_contract,tool_config,dora_bridge,mcp_agent,robot_groups}.rs`

### 2.10 admin/ 子表(7 文件,20 个注册名)

| 注册名 | 源文件(全路径) | 一句话职责 |
|---|---|---|
| admin_platform_skills | crates/octos-agent/src/tools/admin/platform_skills.rs | server-level ASR/TTS engine management via ominix-api |
| admin_list_profiles / admin_profile_status / admin_start_profile / admin_stop_profile / admin_restart_profile / admin_enable_profile / admin_update_profile | crates/octos-agent/src/tools/admin/profiles.rs(:31,145,197,258,319,386,673) | Profile management tools: list, status, start, stop, restart, enable, update |
| admin_manage_skills | crates/octos-agent/src/tools/admin/skills.rs | Per-profile skill management (install/remove GitHub skills for a profile) |
| admin_list_sub_accounts / admin_create_sub_account | crates/octos-agent/src/tools/admin/sub_accounts.rs | Sub-account management tools |
| admin_view_logs / admin_system_health / admin_provider_metrics / admin_manage_watchdog / admin_system_metrics / admin_view_sessions / admin_cron_status / admin_check_config | crates/octos-agent/src/tools/admin/system.rs | System monitoring: health, metrics, logs, watchdog, provider metrics, sessions, cron, config |
| admin_update_octos | crates/octos-agent/src/tools/admin/update.rs | checking and applying octos updates via the serve API |

生成命令: `grep -rn '"admin_' crates/octos-agent/src/tools/admin/*.rs | grep 'fn name' -A2` 或逐文件 `grep -n 'fn name(' -A3 <F>`

---

## 3. 分组策略表(policy.rs TOOL_GROUPS,10 组)

源: `crates/octos-agent/src/tools/policy.rs:186-333`。生成命令: `sed -n '186,333p' crates/octos-agent/src/tools/policy.rs`

| 组 | 成员(policy.rs 原文) |
|---|---|
| group:fs | read_file, write_file, apply_patch, edit_file, diff_edit |
| group:runtime | shell, exec_command, write_stdin, bash |
| group:web | web_search, web_fetch, browser |
| group:search | glob, grep, list_dir |
| group:sessions | spawn, spawn_agent, send_input, resume_agent, wait_agent, close_agent, delegate |
| group:memory | recall_memory, save_memory, memory_note, record_memory_use |
| group:research | search, synthesize_research, deep_crawl |
| group:admin | manage_skills, configure_tool, model_check |
| group:media | mofa_make, mofa_describe_content_type, mofa_comic, mofa_slides, mofa_infographic, mofa_cards, fm_tts, fm_voice_list |
| group:delegated | 委派子代 deny 表(policy.rs:307;成员为 group:sessions 超集,mofa_make.rs:519-589 断言) |

spec 场景核对(review_appendix_b_groups):`group:fs` 含 apply_patch ✅;`group:runtime` 含 exec_command/write_stdin/bash ✅;`group:sessions` 含 spawn_agent/send_input/resume_agent/wait_agent/close_agent/delegate ✅。

---

## 4. fleet worker 子表

### 4.1 BASE_TOOLS(`crates/octos-fleet/src/grant.rs:27`)

生成命令: `sed -n '27,35p' crates/octos-fleet/src/grant.rs`

- BASE_TOOLS(7): `read_file, write_file, edit_file, glob, grep, list_dir, shell`
- GRANTABLE_TOOLS(9,grant.rs:41): 上述 7 + `web_fetch, web_search`
- WEB_TOOLS(2,grant.rs:56): `web_fetch, web_search`(仅在网络 grant 下可授)

### 4.2 lean coding roster(`crates/octos-agent/src/assets/profiles/coding.json`)

生成命令: `cat crates/octos-agent/src/assets/profiles/coding.json`

- allow_list: `read_file, write_file, edit_file, diff_edit, group:runtime, group:search, group:memory, spawn, ask_user_question, check, update_plan, tool_search`
- 展开后 19 名: read_file, write_file, edit_file, diff_edit, shell, exec_command, write_stdin, bash, glob, grep, list_dir, recall_memory, save_memory, memory_note, record_memory_use, spawn, ask_user_question, check, update_plan, tool_search
- 注(json description 原文): ADDS `check`/`update_plan`/`tool_search`;**仅 drop `apply_patch`**(edit_file/diff_edit 覆盖);重面用 `--profile coding-full` 恢复;`run_pipeline` 为 spawn_only 且不在 coding allow_list(profile/mod.rs:874,891)

---

## 5. 统计与写作提示

- **注册名总数**: 本表枚举 80(核心 60 + admin 20);`crates/octos-agent/src/tools/` 目录口径 58 条目(ch06-facts §1);简报「44 注册名/9 域」为旧口径,以本表与 ch06 定稿为准,写作时统一注明口径差。
- **coding_tools.rs 一文件 15 名**,其中 9 名入 P0 10(P0 另一成员 apply_patch 为原生文件工具)。
- **feature 门(编译期)**: 2 — `git`(feature="git")、`code_structure`(feature="ast");**运行期环境变量门**: 2 — read_window(`OCTOS_READ_WINDOW=1`)、read_paging_probe(`OCTOS_READ_PAGING_PROBE=1`)。
- **旧数字零残留**(spec review_appb_no_stale): 正文不得出现「14 个内置工具」。
- 每项引用前用 §2 顶部生成命令亲测(spec 决策:「不编造工具参数」)。
