# 附录 B：工具速查表

本附录以当前 `../octos` main 分支的 `octos-agent/src/tools/`、`octos-agent/src/tools/policy.rs`、`octos-cli/src/api/coding_tool_contract.rs` 以及 CLI 运行时注册路径为准。octos 的工具不是一个固定列表：基础 registry、Codex-compatible coding 合约、feature flags、profile、Serve/Admin API、MCP、插件和 app-skills 都会影响最终暴露给 Agent 的工具集合。

## Codex-compatible 编码工具面

这些工具由 `ToolRegistry::with_builtins_and_permissions()` 直接注册，并由 `coding.tool_contract.v1` 对 AppUI/模型声明。它们的定位是让 Octos 可以作为 autonomous coding harness 的后端工具面，而不是要求前端本地实现这些能力。

| 工具名 | 分组 | 核心参数 | 功能 |
|--------|------|---------|------|
| `apply_patch` | `group:fs` | Codex patch envelope 或 `path, diff` | 应用补丁；写入受文件访问策略约束 |
| `exec_command` | `group:runtime` | `cmd`, `workdir?`, `timeout_secs?`, `tty?`, `yield_time_ms?` | 执行命令；支持 PTY/长命令 session |
| `write_stdin` | `group:runtime` | `session_id`, `chars` | 向 `exec_command` 启动的运行中 session 写入 stdin |
| `bash` | `group:runtime` | `cmd` | Codex-compatible shell alias，共用 shell/exec policy 与 sandbox |
| `update_plan` | - | `plan: array` | 写入结构化计划状态 |
| `request_user_input` | - | `questions: array` | 请求用户输入，返回结构化 metadata |
| `spawn_agent` | `group:sessions` | `task`, `role?`, `agent_type?` | 启动受监督的子 Agent；依赖运行时绑定 native spawn delegate |
| `send_input` | `group:sessions` | `agent_id`, `input` | 当前记录到 supervisor metadata；不是实时 conversational delivery |
| `resume_agent` | `group:sessions` | `agent_id` | 重新拉起/恢复受监督任务 |
| `wait_agent` | `group:sessions` | `agent_id`, `timeout_ms?` | 等待子 Agent 进入终态或超时 |
| `close_agent` | `group:sessions` | `agent_id` | 取消活跃受监督任务或关闭终态任务 |
| `delegate` | `group:sessions` | `task`, `role?`, `timeout_ms?` | `spawn_agent` + `wait_agent` 的一调用封装 |
| `view_image` | - | `path` | 工作区内图片元数据检查，不返回原始图片字节 |
| `tool_search` | - | `query`, `limit?` | 从 live tool catalog 搜索可见工具 |
| `tool_suggest` | - | `task`, `limit?` | 根据任务描述建议工具 |
| `image_generation` | - | `prompt` | 当前仅返回 `coding_tool_unsupported`，尚未绑定生成后端 |

## 核心内置工具

| 工具名 | 分组 | 核心参数 | 功能 |
|--------|------|---------|------|
| `shell` | `group:runtime` | `command: string` | 在策略和沙箱约束下执行 Shell 命令 |
| `read_file` | `group:fs` | `path: string, offset?: int, limit?: int` | 读取文件内容，支持分页 |
| `write_file` | `group:fs` | `path: string, content: string` | 写入文件并记录 workspace 变更 |
| `edit_file` | `group:fs` | `path: string, old_string: string, new_string: string` | 精确字符串替换 |
| `diff_edit` | `group:fs` | `path: string, diff: string` | 应用 unified diff 风格补丁 |
| `glob` | `group:search` | `pattern: string, path?: string` | 文件路径模式搜索 |
| `grep` | `group:search` | `pattern: string, path?: string, include?: string` | 内容正则搜索 |
| `list_dir` | `group:search` | `path: string` | 列出目录内容 |
| `web_search` | `group:web` | `query: string, count?: int` | 网页搜索 |
| `web_fetch` | `group:web` | `url: string, max_chars?: int, extract_mode?: string` | 获取网页内容并抽取文本 |
| `browser` | `group:web` | `url?: string, action?: string, selector?: string` | 浏览器自动化 |
| `spawn` | `group:sessions` | `prompt: string, agent_definition_id?: string, allowed_tools?: string[]` | 后台异步执行子 Agent |
| `recall_memory` | `group:memory` | `query: string, limit?: int` | 检索长期记忆 |
| `save_memory` | `group:memory` | `name: string, content: string` | 保存长期记忆 |

## Feature / 运行时注册工具

| 工具名 | 来源 | 分组 | 核心参数 | 功能 |
|--------|------|------|---------|------|
| `git` | `git` feature | - | `command: string` | Git 操作与仓库查询 |
| `code_structure` | `ast` feature | - | `path: string` | AST 代码结构分析 |
| `search` | bundled app skill / runtime | `group:research` | `query: string` | 单 binary 研究流水线；旧文档中的 `deep_search` 是 contract/兼容别名 |
| `synthesize_research` | runtime | `group:research` | `findings: array/object` | 综合研究结果 |
| `deep_crawl` | bundled app skill / runtime | `group:research` | `url: string, max_depth?: int` | 深度爬取站点 |
| `run_pipeline` | CLI/Gateway/Serve per-session | - | `dot: string` 或 pipeline 配置 | 执行 DOT 工作流 |
| `model_check` | CLI runtime | `group:admin` | `action: string` | 查询/切换模型配置 |
| `configure_tool` | core runtime | `group:admin` | `action: string, tool?: string, key?: string, value?: any` | 查看、设置或重置可配置工具字段 |
| `activate_tools` | core runtime | - | `tools: string[]` | 激活被延迟隐藏的工具或工具组 |
| `manage_skills` | core runtime | `group:admin` | `action: string, name?: string` | 管理本地 skills |
| `check_background_tasks` | core runtime | - | `status?: string` | 查看后台任务状态 |
| `read_task_output` | core runtime | - | `task_id: string, mode: object` | 读取后台任务输出 |
| `check_workspace_contract` | core runtime | - | `path?: string` | 检查 workspace 合约 |
| `workspace_log` / `workspace_show` / `workspace_diff` | workspace history | - | Git revision / diff 参数 | 查看 workspace 变更历史 |
| `send_file` | channel runtime | - | `path: string, caption?: string` | 向用户发送文件 |
| `message` | channel runtime | `group:delegated` deny list | `text: string` | 向频道发送进度消息 |
| `send_app_card` / `show_weather_card` | App UI runtime | `group:media` 类能力 | card/weather payload | 发送结构化 App 卡片 |
| `delegate_task` | delegate runtime | `group:delegated` deny list | `task: string, allowed_tools?: string[]` | 同步委托子任务 |

## Serve/Admin API 工具

这些工具只在 Serve/Admin API 上下文注册，名称来自 `octos-agent/src/tools/admin/`。

| 类别 | 工具 |
|------|------|
| Profile 管理 | `admin_list_profiles`, `admin_profile_status`, `admin_start_profile`, `admin_stop_profile`, `admin_restart_profile`, `admin_enable_profile`, `admin_update_profile` |
| 系统监控 | `admin_view_logs`, `admin_system_health`, `admin_system_metrics`, `admin_provider_metrics`, `admin_manage_watchdog` |
| 诊断 | `admin_view_sessions`, `admin_cron_status`, `admin_check_config` |
| 多租户子账号 | `admin_list_sub_accounts`, `admin_create_sub_account` |
| Skill / 平台管理 | `admin_manage_skills`, `admin_platform_skills`, `admin_update_octos` |

## 工具分组策略

分组定义来自 `octos-agent/src/tools/policy.rs`。

| 分组名 | 包含工具 | 典型策略 |
|--------|---------|---------|
| `group:fs` | `read_file`, `write_file`, `apply_patch`, `edit_file`, `diff_edit` | 文件操作 |
| `group:runtime` | `shell`, `exec_command`, `write_stdin`, `bash` | 命令执行 |
| `group:web` | `web_search`, `web_fetch`, `browser` | 网络操作 |
| `group:search` | `glob`, `grep`, `list_dir` | 代码搜索 |
| `group:sessions` | `spawn`, `spawn_agent`, `send_input`, `resume_agent`, `wait_agent`, `close_agent`, `delegate` | 后台任务与子 Agent 生命周期 |
| `group:memory` | `recall_memory`, `save_memory` | 记忆操作 |
| `group:research` | `search`, `synthesize_research`, `deep_crawl` | 深度研究 |
| `group:admin` | `manage_skills`, `configure_tool`, `model_check` | 管理操作 |
| `group:media` | `mofa_comic`, `mofa_slides`, `mofa_infographic`, `mofa_cards`, `fm_tts`, `fm_voice_list` | 媒体生成与语音 |
| `group:delegated` | `delegate_task`, `spawn`, `send_message`, `message`, `save_memory`, `execute_code` | 委托子任务的 canonical deny list |

## 策略配置示例

```json
{
  "tool_policy": {
    "allow": ["group:fs", "group:search", "shell"],
    "deny": ["browser", "web_fetch"]
  },
  "tool_policy_by_provider": {
    "ollama": {
      "allow": ["read_file", "shell", "grep"]
    }
  }
}
```

**deny-wins 规则**：deny 列表优先于 allow 列表。上例中 `browser` 被禁止，即使它属于某个允许的分组。profile 级 allow/deny 还支持普通工具名、`group:<id>` 和 `<prefix>*` 通配符；spawn-only 工具会被保留，以避免后台任务 wiring 被 profile 过滤破坏。
