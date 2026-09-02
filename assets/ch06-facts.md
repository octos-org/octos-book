# 第 6 章事实表 — 工具系统按能力域重组(octos-book v2)

- **源码基准 commit**: `9c157101`(main 分支,只读实测)
- **统计日期**: 2026-09-03
- **采集方式**: master 直跑替代执行(peer ch06-facts/ch06-facts2 通道冻结,黑板批注在案;依据 ch10 先例)
- 源码仓库: `/Users/zhangalex/Work/Projects/FW/octos`(只读)

---

## 1. tools/ 目录总览

- 源文件数: `ls crates/octos-agent/src/tools/ | grep -v test | wc -l` → **58 个条目**(57 个 .rs + admin/ 子目录)
  - 注:黑板第 9 条写「59 个源文件」,口径为 `ls crates/octos-agent/src/tools/*.rs | wc -l`(含 test 类与 mod.rs 计满 59);本表以 58 条目 + admin 子目录 7 文件为结构口径,写作时统一注明。
- admin/ 子目录(7 文件): mod.rs platform_skills.rs profiles.rs skills.rs sub_accounts.rs system.rs update.rs
- 骨架三件: registry.rs **3,581 行**、policy.rs **741 行**、args.rs **479 行**

## 2. 能力域分组(按文件名与职责初步归属,供 writer 重组叙事)

| 能力域 | 工具/文件 |
|---|---|
| 文件系统 | read_file, read_paging_probe, read_window, write_file, edit_file, apply_patch, diff_edit, list_dir, glob_tool, grep_tool, replacer, workspace_history |
| Shell/执行 | shell, check, write_grant |
| Web/研究 | web_fetch, web_search, deep_search, synthesize_research, research_utils, site_crawl, http, ssrf, browser |
| 记忆 | memory_note, record_memory_use, recall, recall_memory, save_memory |
| 消息/交互 | message, send_file, send_app_card, ask_user_question |
| Peer/Fleet | peer_handoff, peer_send_input, peer_gather, peer_list, peer_respond, peer_close, spawn, delegate, check_background_tasks, read_task_output |
| 代码/结构 | code_structure, coding_tools |
| Git | git |
| 技能/插件 | manage_skills, dora_bridge, mcp_agent |
| 平台杂项 | check_workspace_contract, tool_config, mofa_make, robot_groups, mod, admin/(7 文件) |

## 3. 骨架符号(行号实测)

**registry.rs**(3,581 行): ToolRegistry:127、new():236、sandbox():271、set_tool_timeout_secs():279、mark_as_plugin():289、set_session_key():294、mark_spawn_only():299、mark_internal_hidden():324、is_internal_hidden():332
**policy.rs**(741 行): PolicyDecision(枚举):10、ToolPolicy:28、BashFileWrites(枚举):55、is_allowed():69、evaluate():77、is_allowed_with_tags():131、is_empty():149、ToolGroupInfo:180
**args.rs**(479 行): 参数大小限制与 estimate_json_size(详见源文件;黑板/旧章提过 1MB 上限,写作前以 grep 实测行号为准)

## 4. 生成命令

- 文件清单: `ls crates/octos-agent/src/tools/ | grep -v test`
- 骨架行数: `wc -l crates/octos-agent/src/tools/{registry,policy,args}.rs`
- 符号行号: `grep -n 'pub fn\|pub struct\|pub enum' crates/octos-agent/src/tools/registry.rs`

## 5. 写作提示(与 spec 对齐)

- spec 决策段若与上表口径有出入(如 59 vs 58、能力域划分),以 spec 为准并实测补差
- 每 tool 的 `fn name()` 注册名与 `//!` 首行文档,writer 引用前用 `head -3 <file>` 亲测
