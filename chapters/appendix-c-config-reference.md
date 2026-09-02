# 附录 C：配置参考

> **定位**：这是 `config.json` 与 profile 文件的完整字段参考——每个顶层配置节一张表，字段路径、类型、默认值、一句话作用、来源行号全部亲测自 octos `9c157101`（`crates/octos-cli/src/config.rs` 共 3,790 行，`crates/octos-cli/src/profiles.rs` 共 7,003 行）。功能语义（沙箱怎么选后端、MCP 怎么握手、goal 三档继承怎么运作）见对应章节，本附录只回答"这个字段是什么、默认多少、在哪定义"。与 Ch9（扩展机制）交叉的 `mcp_servers` / `sub_providers` 在这里只给字段表。

## C.1 配置文件位置与加载顺序

顶层 `config.json` 的解析顺序（`crates/octos-cli/src/config.rs:1715` `resolve_config_file_path`）：显式 `--config <FILE>` 覆盖 →（默认安装下）项目本地 `<cwd>/.octos/config.json` → `<config_home>/config.json` →（默认安装下）legacy `~/.octos/config.json`。无文件时写入位置回退到 `config_home/config.json`。

profile 文件位于 `~/.octos/profiles/<id>.json`（`crates/octos-cli/src/profiles.rs:5`），数据目录默认 `~/.octos/profiles/{id}/data`（`crates/octos-cli/src/profiles.rs:164`）。

## C.2 顶层 `Config`（`crates/octos-cli/src/config.rs:26`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `version` | u32? | `null`（常量当前为 `1`） | 配置迁移版本号 | `crates/octos-cli/src/config.rs:29` |
| `provider` | string? | `null` | LLM provider 名（`"anthropic"` / `"openai"` / `"gemini"`） | `crates/octos-cli/src/config.rs:33` |
| `model` | string? | `null` | 模型 ID | `crates/octos-cli/src/config.rs:37` |
| `context_window` | u32? | `null` | 主模型有效上下文窗口覆盖（tokens），最外层包裹，压过目录与探测 | `crates/octos-cli/src/config.rs:46` |
| `model_temperature` | f32? | `null` | 主模型 typed 采样温度投影（#2166） | `crates/octos-cli/src/config.rs:56` |
| `model_top_p` | f32? | `null` | 主模型 top_p 投影，运行时覆盖采样参数表同名键 | `crates/octos-cli/src/config.rs:61` |
| `model_reasoning_effort` | enum? | `null` | 主模型推理力度默认（low/medium/high） | `crates/octos-cli/src/config.rs:65` |
| `base_url` | string? | `null` | API endpoint 覆盖 | `crates/octos-cli/src/config.rs:69` |
| `api_key_env` | string? | provider 默认 | API key 环境变量名 | `crates/octos-cli/src/config.rs:73` |
| `env_vars` | map<string,string> | `{}` | profile 级环境变量（含 dashboard 持久化的密钥） | `crates/octos-cli/src/config.rs:77` |
| `bypass_auth_store` | bool | `false` | 内部字段（`#[serde(skip)]`，不参与序列化）：跳过全局 AuthStore 查密钥 | `crates/octos-cli/src/config.rs:86` |
| `model_hints` | object? | `null` | OpenAI 兼容代理自定义模型行为提示 | `crates/octos-cli/src/config.rs:91` |
| `api_type` | string? | provider 默认 | 协议覆盖（`"openai"` / `"anthropic"`） | `crates/octos-cli/src/config.rs:97` |
| `auth_token` | string? | `null` | dashboard/admin token；也可 `--auth-token` 或 `OCTOS_AUTH_TOKEN` | `crates/octos-cli/src/config.rs:102` |
| `gateway` | object? | `null` | gateway 模式配置（见 C.3） | `crates/octos-cli/src/config.rs:106` |
| `mcp_servers` | array | `[]` | MCP server 列表（见 C.9） | `crates/octos-cli/src/config.rs:110` |
| `sandbox` | object | `SandboxConfig::default()` | 工具沙箱（见 C.5） | `crates/octos-cli/src/config.rs:114` |
| `snapshots` | object? | `null`（=关） | 工作区快照-回滚（#1768，默认关） | `crates/octos-cli/src/config.rs:123` |
| `tool_policy` | object? | `null` | 全局工具 allow/deny/tag 策略（见 C.5） | `crates/octos-cli/src/config.rs:127` |
| `tool_policy_by_provider` | map<string,ToolPolicy> | `{}` | 按模型/provider 前缀的工具策略 | `crates/octos-cli/src/config.rs:132` |
| `embedding` | object? | `null` | hybrid memory embedding（见 C.6） | `crates/octos-cli/src/config.rs:136` |
| `memory` | object? | `null` | 记忆子系统（见 C.6） | `crates/octos-cli/src/config.rs:140` |
| `fallback_models` | array | `[]` | provider failover 链的 fallback 模型（见 C.4） | `crates/octos-cli/src/config.rs:145` |
| `max_iterations` | u32? | `null` | 单消息最大 agent 迭代数（`--max-iterations` 可覆盖） | `crates/octos-cli/src/config.rs:149` |
| `format_after_edit` | bool | `false` | 编辑成功后跑语言 formatter（rustfmt/prettier 等，5s 超时，#1774） | `crates/octos-cli/src/config.rs:158` |
| `hooks` | array | `[]` | 生命周期 hooks（见 C.7） | `crates/octos-cli/src/config.rs:162` |
| `approval_policy` | object? | `null` | 工具调用人工审批规则（见 C.7） | `crates/octos-cli/src/config.rs:168` |
| `context_filter` | string[] | `[]` | 工具 tag 过滤；仅匹配 tag 的工具对 LLM 可见 | `crates/octos-cli/src/config.rs:173` |
| `sub_providers` | array | `[]` | 子 agent 可选 provider 车道（见 C.10） | `crates/octos-cli/src/config.rs:184` |
| `adaptive_routing` | object? | `null` | 自适应路由（见 C.8） | `crates/octos-cli/src/config.rs:189` |
| `email` | object? | `null` | `send_email` 工具配置（见 C.6） | `crates/octos-cli/src/config.rs:193` |
| `voice` | object? | `null` | ASR/TTS（见 C.6） | `crates/octos-cli/src/config.rs:198` |
| `mode` | enum | `"local"` | 部署模式：`local` / `tenant` / `cloud` | `crates/octos-cli/src/config.rs:206` |
| `tunnel_domain` | string? | `null` | cloud/tenant tunnel 域名 | `crates/octos-cli/src/config.rs:211` |
| `base_domain` | string? | 兼容 `crew.ominix.io` | 公开 profile 域名基座（`OCTOS_BASE_DOMAIN` 优先） | `crates/octos-cli/src/config.rs:222` |
| `frps_server` | string? | `null` | frps server 地址（`FRPS_SERVER` env 可覆盖） | `crates/octos-cli/src/config.rs:227` |
| `allow_admin_shell` | bool | `false` | 是否开 `/api/admin/shell`；生产保持关闭 | `crates/octos-cli/src/config.rs:233` |
| `dashboard_auth` | object? | `null` | email OTP 登录（api feature，见 C.8） | `crates/octos-cli/src/config.rs:239` |
| `monitor` | object? | `null` | watchdog/alert（api feature，见 C.8） | `crates/octos-cli/src/config.rs:244` |
| `credential_pool` | object? | `null` | 密钥池（M6.5，见 C.8） | `crates/octos-cli/src/config.rs:251` |
| `content_routing` | object? | `null` | 内容分类 Cheap/Strong 路由（M6.6） | `crates/octos-cli/src/config.rs:257` |
| `appui` | object | `AppUiConfig::default()` | AppUI 会话默认（见 C.8） | `crates/octos-cli/src/config.rs:269` |
| `plugins` | object | `PluginsConfig::default()` | 插件签名校验开关（见 C.8） | `crates/octos-cli/src/config.rs:277` |
| `cli` | map<string,json> | `{}`（省略序列化） | 按子命令持久化 CLI flag 默认值，如 `{"serve": {"port": 50080}}` | `crates/octos-cli/src/config.rs:292` |

`mode` 枚举定义在 `crates/octos-cli/src/config.rs:14`：`Local`（独立安装、无 tunnel、dashboard 在 `/admin/`）、`Tenant`（frpc tunnel 接入云）、`Cloud`（VPS 中继 + 租户管理 + 落地页）。

## C.3 `gateway` 节（`crates/octos-cli/src/config.rs:1524` `GatewayConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `gateway.channels[]` | `array<ChannelEntry>` | `[{"type":"cli",…}]` | 启用的频道列表 | `crates/octos-cli/src/config.rs:1527` |
| `gateway.channels[].type` | string | 必填 | 频道类型：`"cli"` / `"telegram"` / `"discord"` | `crates/octos-cli/src/config.rs:1642` |
| `gateway.channels[].allowed_senders` | string[] | `[]`（= 允许所有人） | 允许的发送者 ID | `crates/octos-cli/src/config.rs:1646` |
| `gateway.channels[].settings` | json | `{}` | 频道特定设置 | `crates/octos-cli/src/config.rs:1650` |
| `gateway.max_history` | usize | `50` | 注入 LLM 的最大历史消息数 | `crates/octos-cli/src/config.rs:1531` |
| `gateway.system_prompt` | string? | `null` | gateway 模式自定义系统提示 | `crates/octos-cli/src/config.rs:1535` |
| `gateway.queue_mode` | enum | `"collect"` | 运行中收到的消息排队策略 | `crates/octos-cli/src/config.rs:1541` |
| `gateway.max_sessions` | usize | `1000` | 内存中最大会话数（LRU 淘汰） | `crates/octos-cli/src/config.rs:1545` |
| `gateway.max_concurrent_sessions` | usize | `10` | 最大并发会话处理数 | `crates/octos-cli/src/config.rs:1549` |
| `gateway.browser_timeout_secs` | u64? | `null`（代码内 300s） | 单个浏览器动作超时 | `crates/octos-cli/src/config.rs:1554` |
| `gateway.llm_timeout_secs` | u64? | `null`（默认 120） | LLM HTTP 请求总超时 | `crates/octos-cli/src/config.rs:1558` |
| `gateway.llm_connect_timeout_secs` | u64? | `null`（默认 30） | LLM HTTP 连接超时 | `crates/octos-cli/src/config.rs:1562` |
| `gateway.tool_timeout_secs` | u64? | `null`（默认 300） | 并行工具调用完成上限 | `crates/octos-cli/src/config.rs:1566` |
| `gateway.session_timeout_secs` | u64? | `null`（默认 600） | 单条会话消息处理上限 | `crates/octos-cli/src/config.rs:1570` |
| `gateway.max_output_tokens` | u32? | `null` | 每次调用默认最大输出 tokens（压过 model_limits.json） | `crates/octos-cli/src/config.rs:1575` |
| `gateway.reasoning_effort` | enum? | `null` | 思考模型推理力度（low/medium/high），非思考模型忽略 | `crates/octos-cli/src/config.rs:1582` |
| `gateway.llm_temperature` | f32? | `null`（= greedy 0.0） | 采样温度覆盖，主要救本地模型重复坍缩（#2172） | `crates/octos-cli/src/config.rs:1592` |
| `gateway.llm_sampling_params` | map<string,json>? | `null` | 透传采样参数表，如 `{"repeat_penalty":1.1}`（#2172） | `crates/octos-cli/src/config.rs:1600` |

`queue_mode` 枚举（`crates/octos-cli/src/config.rs:1499`）：`followup`（FIFO 逐条）、`collect`（默认，同会话拼接）、`latest`（只留最新，别名 `steer`）、`interrupt`（取消当前）、`speculative`（慢调用并发起新 agent）。

`octos serve` 的默认端口是 **50080**（`crates/octos-cli/src/config.rs:283` 处文档示例）。

## C.4 `fallback_models[]`（`crates/octos-cli/src/config.rs:460` `FallbackModel`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `provider` | string | 必填 | provider 名 | `crates/octos-cli/src/config.rs:462` |
| `model` | string? | `null` | 模型名 | `crates/octos-cli/src/config.rs:465` |
| `base_url` | string? | `null` | 该 fallback 的 base URL | `crates/octos-cli/src/config.rs:468` |
| `api_key_env` | string? | `null` | 该 fallback 的密钥环境变量 | `crates/octos-cli/src/config.rs:471` |
| `model_hints` | object? | `null` | 模型行为提示 | `crates/octos-cli/src/config.rs:474` |
| `api_type` | string? | `null` | 协议覆盖 | `crates/octos-cli/src/config.rs:477` |
| `cost_per_m` | f64? | `null` | 每百万 token 输出价格（成本感知路由） | `crates/octos-cli/src/config.rs:480` |
| `strong` | bool | `true` | 是否强模型（30+ 工具/大 payload 可靠） | `crates/octos-cli/src/config.rs:485` |
| `context_window` | u32? | `null` | 该 fallback 的上下文窗口覆盖（#2142） | `crates/octos-cli/src/config.rs:492` |

## C.5 `sandbox` / `tool_policy` / `snapshots`

### `sandbox`（`crates/octos-agent/src/sandbox/mod.rs:37` `SandboxConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `sandbox.enabled` | bool | `true` | 是否启用沙箱 | `crates/octos-agent/src/sandbox/mod.rs:40` |
| `sandbox.mode` | enum | `"auto"` | `auto` / `bwrap` / `landlock` / `macos` / `docker` / `appcontainer` / `none` | `crates/octos-agent/src/sandbox/mod.rs:44`、枚举 `crates/octos-agent/src/sandbox/mod.rs:423` |
| `sandbox.fail_closed` | bool | `false` | auto 无后端时拒绝执行而非降级裸跑 | `crates/octos-agent/src/sandbox/mod.rs:58` |
| `sandbox.allow_network` | bool | `false` | 沙箱内放行网络 | `crates/octos-agent/src/sandbox/mod.rs:62` |
| `sandbox.workspace_write` | bool | `true` | shell 是否可写 cwd（false = 工作区只读挂载） | `crates/octos-agent/src/sandbox/mod.rs:75` |
| `sandbox.repo_git_write` | path? | `null` | 额外授予 `<repo>/.git` 写权限 | `crates/octos-agent/src/sandbox/mod.rs:92` |
| `sandbox.docker.image` | string | `"ubuntu:24.04"` | docker 模式镜像 | `crates/octos-agent/src/sandbox/mod.rs:361` |
| `sandbox.docker.cpu_limit` | string? | `null` | CPU 限制如 `"1.0"` | `crates/octos-agent/src/sandbox/mod.rs:365` |
| `sandbox.docker.memory_limit` | string? | `null` | 内存限制如 `"512m"` | `crates/octos-agent/src/sandbox/mod.rs:369` |
| `sandbox.docker.pids_limit` | u32? | `null` | 最大进程数 | `crates/octos-agent/src/sandbox/mod.rs:373` |
| `sandbox.docker.mount_mode` | enum | `"rw"` | `none` / `ro` / `rw` 工作区挂载 | `crates/octos-agent/src/sandbox/mod.rs:377`、枚举 `crates/octos-agent/src/sandbox/mod.rs:408` |
| `sandbox.docker.extra_binds` | string[] | `[]` | 额外 bind 挂载（`host:container[:ro]`） | `crates/octos-agent/src/sandbox/mod.rs:381` |
| `sandbox.read_allow_paths` | string[] | `[]`（= 全放行） | 限制可读路径（cwd 之外白名单） | `crates/octos-agent/src/sandbox/mod.rs:102` |
| `sandbox.write_allow_globs` | string[]? | `null` | #1976 shell 写围栏：工作区相对 glob | `crates/octos-agent/src/sandbox/mod.rs:125` |
| `sandbox.profile_name` | string? | `null` | 沙箱 profile 名（Windows AppContainer ID） | `crates/octos-agent/src/sandbox/mod.rs:129` |
| `sandbox.allow_toolchains` | bool | `true` | 授予语言工具链必需写路径（cargo 缓存等） | `crates/octos-agent/src/sandbox/mod.rs:149` |

### `tool_policy`（`crates/octos-agent/src/tools/policy.rs:28` `ToolPolicy`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `tool_policy.allow` | string[] | `[]`（= 全允许） | 允许的工具/组/通配符 | `crates/octos-agent/src/tools/policy.rs:31` |
| `tool_policy.deny` | string[] | `[]` | 拒绝列表，永远压过 allow | `crates/octos-agent/src/tools/policy.rs:34` |
| `tool_policy.require_tags` | string[] | `[]` | 只暴露声明匹配 tag 的工具（fail closed） | `crates/octos-agent/src/tools/policy.rs:40` |
| `tool_policy.bash_file_writes` | enum | `"allow"` | `allow` / `warn` / `deny`：shell 写文件三档 | `crates/octos-agent/src/tools/policy.rs:49` |

`tool_policy_by_provider` 为同结构 map（`crates/octos-cli/src/config.rs:132`），键为精确 model ID（优先）或 provider 前缀。

### `snapshots`（`crates/octos-agent/src/snapshot.rs:122` `SnapshotConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `snapshots.enabled` | bool | `false` | 快照总开关（git-backed，存 `<data_dir>/snapshots/`） | `crates/octos-agent/src/snapshot.rs:124` |
| `snapshots.keep_last` | usize | `20` | 每工作区保留份数（<1 钳到 1） | `crates/octos-agent/src/snapshot.rs:127` |

## C.6 `embedding` / `memory` / `email` / `voice`

### `embedding`（`crates/octos-cli/src/config.rs:655` `EmbeddingConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `embedding.provider` | string | `"openai"` | embedding provider（含本地 `llamacpp`） | `crates/octos-cli/src/config.rs:658` |
| `embedding.api_key_env` | string? | `null` | 密钥环境变量名 | `crates/octos-cli/src/config.rs:662` |
| `embedding.base_url` | string? | `null` | API base URL | `crates/octos-cli/src/config.rs:666` |
| `embedding.model` | string? | `text-embedding-3-small` | embedding 模型 ID | `crates/octos-cli/src/config.rs:672` |
| `embedding.dimensions` | u32? | `null` | 请求维度字段（episodic HNSW 固定 1536） | `crates/octos-cli/src/config.rs:678` |
| `embedding.model_path` | string? | `null` | 本地 `.gguf` 路径（feature `embed-llama`） | `crates/octos-cli/src/config.rs:685` |

### `memory`（`crates/octos-cli/src/config.rs:694` `MemoryConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `memory.max_inject_tokens` | usize? | `DEFAULT_MAX_INJECT_TOKENS` | 注入系统提示的记忆块 token 预算 | `crates/octos-cli/src/config.rs:701` |
| `memory.refresh.enabled` | bool? | `null`（= 开） | 记忆自动刷新总开关（默认产品行为为开） | `crates/octos-cli/src/config.rs:719` |
| `memory.refresh.extract_model` | string? | `null`（= profile provider） | 抽取模型键 | `crates/octos-cli/src/config.rs:723` |
| `memory.refresh.consolidate_model` | string? | `null`（= profile provider） | 整合模型键 | `crates/octos-cli/src/config.rs:726` |
| `memory.refresh.min_idle_minutes` | u64? | `30` | 会话空闲多久才可被扫 | `crates/octos-cli/src/config.rs:729` |
| `memory.refresh.max_session_age_days` | u64? | `10` | 超龄会话不再扫 | `crates/octos-cli/src/config.rs:732` |
| `memory.refresh.max_sessions_per_pass` | usize? | `2` | 每轮扫的会话数 | `crates/octos-cli/src/config.rs:735` |
| `memory.refresh.max_extractions_per_day` | u32? | `20` | 每 profile 日抽取预算 | `crates/octos-cli/src/config.rs:738` |
| `memory.refresh.max_consolidations_per_day` | u32? | `12` | 每 profile 日整合预算 | `crates/octos-cli/src/config.rs:742` |
| `memory.refresh.max_daily_tokens` | u64? | `200000` | 日 token 预算（抽取+整合共享） | `crates/octos-cli/src/config.rs:745` |
| `memory.refresh.consolidate_interval_minutes` | u64? | `30` | 后台扫描间隔（分钟） | `crates/octos-cli/src/config.rs:748` |
| `memory.refresh.debounce_seconds` | u64? | `90` | 用户笔记后的快车道防抖 | `crates/octos-cli/src/config.rs:751` |
| `memory.refresh.unused_days` | u32? | `null` | 闲置多久成为归档候选 | `crates/octos-cli/src/config.rs:755` |
| `memory.refresh.max_memory_file_tokens` | usize? | `null` | MEMORY.md 大小上限（整合时执行） | `crates/octos-cli/src/config.rs:758` |
| `memory.refresh.pending_confirm_days` | u32? | `null` | 待确认遗忘请求过期天数 | `crates/octos-cli/src/config.rs:762` |
| `memory.refresh.max_extract_input_tokens` | usize? | `24000` | 单次抽取调用输入硬预算 | `crates/octos-cli/src/config.rs:767` |

设计默认值来自 `crates/octos-cli/src/config.rs:772` `MemoryRefreshConfig::knobs`。

### `email`（`crates/octos-cli/src/config.rs:856` `EmailConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `email.provider` | string | 必填 | `"smtp"` 或 `"feishu"`/`"lark"` | `crates/octos-cli/src/config.rs:858` |
| `email.smtp_host` | string? | `null` | SMTP 主机 | `crates/octos-cli/src/config.rs:862` |
| `email.smtp_port` | u16? | `null` | SMTP 端口 | `crates/octos-cli/src/config.rs:864` |
| `email.username` | string? | `null` | SMTP 用户名 | `crates/octos-cli/src/config.rs:866` |
| `email.password_env` | string? | `null` | SMTP 密码环境变量（legacy） | `crates/octos-cli/src/config.rs:869` |
| `email.password` | string? | `null` | SMTP 密码明文（优先于 password_env） | `crates/octos-cli/src/config.rs:872` |
| `email.from_address` | string? | `null` | 发件人地址 | `crates/octos-cli/src/config.rs:874` |
| `email.feishu_app_id` | string? | `null` | Feishu app ID | `crates/octos-cli/src/config.rs:878` |
| `email.feishu_app_secret_env` | string? | `null` | Feishu secret 环境变量（legacy） | `crates/octos-cli/src/config.rs:881` |
| `email.feishu_app_secret` | string? | `null` | Feishu secret 明文（优先） | `crates/octos-cli/src/config.rs:884` |
| `email.feishu_from_address` | string? | `null` | Feishu 发件人 | `crates/octos-cli/src/config.rs:886` |
| `email.feishu_region` | string? | `"cn"` | `"cn"` / `"global"` | `crates/octos-cli/src/config.rs:889` |

### `voice`（`crates/octos-cli/src/config.rs:936` `VoiceConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `voice.api_url` | string? | —（legacy，忽略） | OminiX URL 已改为平台级 `OMINIX_API_URL` | `crates/octos-cli/src/config.rs:939` |
| `voice.auto_asr` | bool | `true` | 自动转写语音消息 | `crates/octos-cli/src/config.rs:942` |
| `voice.auto_tts` | bool | `true` | 语音会话自动合成回复 | `crates/octos-cli/src/config.rs:945` |
| `voice.default_voice` | string | `"vivian"` | 默认 TTS 音色 | `crates/octos-cli/src/config.rs:948` |
| `voice.asr_language` | string? | `null`（自动检测） | ASR 语言提示 | `crates/octos-cli/src/config.rs:951` |
| `voice.tts_provider` | string | `"auto"` | TTS 路由：`auto` / `local` / `cloud` | `crates/octos-cli/src/config.rs:964` |
| `voice.cloud` | object? | `null` | Volcano 云 TTS 非密钥设置 | `crates/octos-cli/src/config.rs:969` |
| `voice.cloud.appid` | string? | `null` | 云 TTS app ID | `crates/octos-cli/src/config.rs:904` |
| `voice.cloud.voice` | string? | `null` | 云 TTS 音色 | `crates/octos-cli/src/config.rs:906` |
| `voice.cloud.cluster` | string? | `null` | 云 TTS 集群 | `crates/octos-cli/src/config.rs:908` |
| `voice.cloud.encoding` | string? | `null` | 云 TTS 编码 | `crates/octos-cli/src/config.rs:910` |
| `voice.cloud.endpoint` | string? | `null` | 云 TTS endpoint | `crates/octos-cli/src/config.rs:912` |

云 TTS 密钥永不落此节：token 走 `env_vars["VOLC_TTS_TOKEN"]`（`crates/octos-cli/src/config.rs:1040` `with_cloud_token_from_env`）。

## C.7 `hooks` 与 `approval_policy`

### `hooks[]`（`crates/octos-agent/src/hooks.rs:77` `HookConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `hooks[].event` | enum | 必填 | 触发事件（见下） | `crates/octos-agent/src/hooks.rs:79` |
| `hooks[].command` | string[] | 必填 | argv 数组直执行（无 shell 解释） | `crates/octos-agent/src/hooks.rs:81` |
| `hooks[].timeout_ms` | u64 | `5000` | 超时毫秒数 | `crates/octos-agent/src/hooks.rs:84`、默认 `crates/octos-agent/src/hooks.rs:112` |
| `hooks[].tool_filter` | string[] | `[]`（= 全部工具） | 仅这些工具名触发（工具事件） | `crates/octos-agent/src/hooks.rs:87` |
| `hooks[].path_filter` | string[] | `[]`（= 不过滤） | 工具参数 `path` 匹配 glob 才触发 | `crates/octos-agent/src/hooks.rs:103` |
| `hooks[].requires_bin` | string? | `null` | PATH 上须存在此二进制才触发 | `crates/octos-agent/src/hooks.rs:109` |

`event` 可取（`crates/octos-agent/src/hooks.rs:58` `as_str`）：`user_prompt_submit`、`before_tool_call`、`after_tool_call`、`before_llm_call`、`after_llm_call`、`on_resume`、`on_turn_end`、`before_spawn_verify`、`on_spawn_verify`、`on_spawn_complete`、`on_spawn_failure`。

### `approval_policy`（`crates/octos-cli/src/config.rs:545` `ApprovalPolicyConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `approval_policy.default` | enum | `"allow"` | 未匹配规则的工具的处置（v1 仅 allow） | `crates/octos-cli/src/config.rs:547` |
| `approval_policy.rules[]` | array | `[]` | 人工审批规则列表 | `crates/octos-cli/src/config.rs:549` |
| `approval_policy.rules[].tools` | string[] | 必填非空 | 本规则拦截的工具名 | `crates/octos-cli/src/config.rs:530` |
| `approval_policy.rules[].require_approval` | bool | 必须为 `true` | 显式意图声明 | `crates/octos-cli/src/config.rs:532` |
| `approval_policy.rules[].risk_level` | enum | — | `normal` / `critical` | `crates/octos-cli/src/config.rs:533` |
| `approval_policy.rules[].authorized_approvers` | string[] | 必填非空 | 有权答复的频道用户 ID | `crates/octos-cli/src/config.rs:535` |
| `approval_policy.rules[].expires_in_secs` | u64 | 必填 >0 | 请求过期秒数 | `crates/octos-cli/src/config.rs:537` |
| `approval_policy.rules[].on_timeout` | enum | — | v1 仅 `notify` | `crates/octos-cli/src/config.rs:538` |

校验逻辑在 `crates/octos-cli/src/config.rs:587` `validate`：非空 tools、`require_approval == true`、非空 approvers、`expires_in_secs > 0`，否则 fail fast。

## C.8 自适应路由与运维节

### `adaptive_routing`（`crates/octos-cli/src/config.rs:1085` `AdaptiveRoutingConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `adaptive_routing.enabled` | bool | `false` | 总开关 | `crates/octos-cli/src/config.rs:1088` |
| `adaptive_routing.latency_threshold_ms` | u64 | `10000` | 软惩罚延迟阈值 | `crates/octos-cli/src/config.rs:1092`、默认 `crates/octos-cli/src/config.rs:1253` |
| `adaptive_routing.error_rate_threshold` | f64 | `0.3` | 去优先级错误率阈值 | `crates/octos-cli/src/config.rs:1096`、默认 `crates/octos-cli/src/config.rs:1256` |
| `adaptive_routing.probe_probability` | f64 | `0.1` | 探测非主 provider 概率 | `crates/octos-cli/src/config.rs:1100`、默认 `crates/octos-cli/src/config.rs:1259` |
| `adaptive_routing.probe_interval_secs` | u64 | `60` | 同 provider 探测最小间隔 | `crates/octos-cli/src/config.rs:1104`、默认 `crates/octos-cli/src/config.rs:1262` |
| `adaptive_routing.failure_threshold` | u32 | `3` | 熔断开启的连续失败数 | `crates/octos-cli/src/config.rs:1108`、默认 `crates/octos-cli/src/config.rs:1265` |
| `adaptive_routing.mode` | enum | `"off"` | `off` / `hedge` / `lane` | `crates/octos-cli/src/config.rs:1114`、枚举 `crates/octos-cli/src/config.rs:1053` |
| `adaptive_routing.qos_ranking` | bool | `false` | 评分计入响应质量 | `crates/octos-cli/src/config.rs:1120` |
| `adaptive_routing.weight_latency` | f64 | `0.3` | 延迟评分权重 | `crates/octos-cli/src/config.rs:1124`、默认 `crates/octos-cli/src/config.rs:1268` |
| `adaptive_routing.weight_error_rate` | f64 | `0.3` | 错误率权重 | `crates/octos-cli/src/config.rs:1127`、默认 `crates/octos-cli/src/config.rs:1271` |
| `adaptive_routing.weight_priority` | f64 | `0.2` | 配置优先级权重 | `crates/octos-cli/src/config.rs:1130`、默认 `crates/octos-cli/src/config.rs:1274` |
| `adaptive_routing.weight_cost` | f64 | `0.2` | token 成本权重 | `crates/octos-cli/src/config.rs:1133`、默认 `crates/octos-cli/src/config.rs:1277` |
| `adaptive_routing.auto_escalation.enabled` | bool | `true` | 延迟劣化自动升 hedge | `crates/octos-cli/src/config.rs:1169+`、默认 `crates/octos-cli/src/config.rs:1214` |
| `adaptive_routing.auto_escalation.window_size` | usize | `5` | 观测窗口样本数 | `crates/octos-cli/src/config.rs:1217` |
| `adaptive_routing.auto_escalation.baseline_samples` | usize | `5` | 基线样本数 | `crates/octos-cli/src/config.rs:1220` |
| `adaptive_routing.auto_escalation.degradation_threshold` | f64 | `3.0` | 劣化判定倍数 | `crates/octos-cli/src/config.rs:1223` |
| `adaptive_routing.auto_escalation.slow_trigger` | u32 | `3` | 连续慢样本触发数 | `crates/octos-cli/src/config.rs:1226` |
| `adaptive_routing.auto_escalation.latency_ceiling_ms` | u64 | `8000` | 延迟上限 | `crates/octos-cli/src/config.rs:1229` |
| `adaptive_routing.auto_escalation.recovery_factor` | f64 | `0.6` | 恢复因子 | `crates/octos-cli/src/config.rs:1232` |

### `monitor`（`crates/octos-cli/src/config.rs:1284` `MonitorConfig`，api feature）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `monitor.alerts_enabled` | bool | `true` | 主动告警开关 | `crates/octos-cli/src/config.rs:1287` |
| `monitor.watchdog_enabled` | bool | `true` | watchdog 自动重启 | `crates/octos-cli/src/config.rs:1290` |
| `monitor.health_check_interval_secs` | u64 | `60` | 健康检查间隔 | `crates/octos-cli/src/config.rs:1293` |
| `monitor.max_restart_attempts` | u32 | `3` | 放弃前最大重启次数 | `crates/octos-cli/src/config.rs:1296` |
| `monitor.telegram_token_env` | string? | `null` | Telegram bot token 环境变量名 | `crates/octos-cli/src/config.rs:1299` |
| `monitor.telegram_alert_chat_ids` | i64[] | `[]` | 告警 Telegram chat ID | `crates/octos-cli/src/config.rs:1302` |
| `monitor.feishu_app_id_env` | string? | `null` | Feishu app ID 环境变量 | `crates/octos-cli/src/config.rs:1305` |
| `monitor.feishu_app_secret_env` | string? | `null` | Feishu secret 环境变量 | `crates/octos-cli/src/config.rs:1308` |
| `monitor.feishu_alert_user_ids` | string[] | `[]` | 告警 Feishu 用户 ID | `crates/octos-cli/src/config.rs:1311` |

### `dashboard_auth`（`crates/octos-cli/src/otp.rs:46` `DashboardAuthConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `dashboard_auth.smtp.host` | string | 必填 | SMTP 主机 | `crates/octos-cli/src/otp.rs:23` |
| `dashboard_auth.smtp.port` | u16 | `465` | SMTP 端口（465 隐式 TLS / 587 STARTTLS） | `crates/octos-cli/src/otp.rs:26`、默认 `crates/octos-cli/src/otp.rs:40` |
| `dashboard_auth.smtp.username` | string | 必填 | SMTP 用户名 | `crates/octos-cli/src/otp.rs:28` |
| `dashboard_auth.smtp.password_env` | string | 必填 | SMTP 密码环境变量（legacy，新装走 `smtp_secret.json`） | `crates/octos-cli/src/otp.rs:35` |
| `dashboard_auth.smtp.from_address` | string | 必填 | 发件人 | `crates/octos-cli/src/otp.rs:37` |
| `dashboard_auth.session_expiry_hours` | u64 | `24` | 会话过期小时数 | `crates/octos-cli/src/otp.rs:59` |
| `dashboard_auth.allow_self_registration` | bool | `false` | 未知邮箱自动建号 | `crates/octos-cli/src/otp.rs:62` |
| `dashboard_auth.static_tokens` | string[] | `[]` | 绕过 OTP 的静态 token（E2E 用） | `crates/octos-cli/src/otp.rs:67` |

`dashboard_auth.smtp` 整体可省（`crates/octos-cli/src/otp.rs:56`），缺省时 OTP 走控制台输出。

### `credential_pool`（`crates/octos-cli/src/config.rs:415` `CredentialPoolConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `credential_pool.state_path` | string? | `<data_dir>/credential_pool.redb` | 持久状态文件覆盖 | `crates/octos-cli/src/config.rs:419` |
| `credential_pool.name` | string | `"default"` | 指标标签用池名 | `crates/octos-cli/src/config.rs:423` |
| `credential_pool.strategy` | string | `"round_robin"` | `fill_first`/`round_robin`/`random`/`least_used` | `crates/octos-cli/src/config.rs:427` |
| `credential_pool.credential_ids` | string[] | `[]` | 池内 credential id（运行时配 env_vars 密钥） | `crates/octos-cli/src/config.rs:431` |
| `credential_pool.default_cooldown_ms` | u64? | `null` | 429 无 reset 提示时的默认冷却 | `crates/octos-cli/src/config.rs:435` |

### `appui`（`crates/octos-cli/src/config.rs:339` `AppUiConfig`）与 `plugins`（`crates/octos-cli/src/config.rs:315` `PluginsConfig`）

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `appui.allowed_origins` | string[] | `[]` | 追加允许的 REST/WS 浏览器 origin（精确 `http(s)://`） | `crates/octos-cli/src/config.rs:348` |
| `appui.default_session_cwd` | path? | `null` | AppUI 会话未声明 cwd capability 时的 Tier-2 回退目录（须绝对路径） | `crates/octos-cli/src/config.rs:360` |
| `appui.sessions_in_cwd` | bool | `true` | 会话存储按项目目录（`<cwd>/.octos/sessions/`） | `crates/octos-cli/src/config.rs:388` |
| `plugins.require_signed` | bool | `false` | 强制插件 `manifest.sha256` 签名（默认警告放行） | `crates/octos-cli/src/config.rs:325` |

## C.9 `mcp_servers[]` 专节（`crates/octos-agent/src/mcp.rs:53` `McpServerConfig`）

字段表见下；协议行为（握手、DNS 防回环、OAuth 流程）详见 Ch9，此处不重复。

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `mcp_servers[].command` | string? | `null` | stdio 传输：要 spawn 的命令 | `crates/octos-agent/src/mcp.rs:56` |
| `mcp_servers[].args` | string[] | `[]` | stdio 传输：命令参数 | `crates/octos-agent/src/mcp.rs:58` |
| `mcp_servers[].env` | map<string,string> | `{}` | stdio 传输：子进程环境变量 | `crates/octos-agent/src/mcp.rs:60` |
| `mcp_servers[].url` | string? | `null` | HTTP 传输：server endpoint URL | `crates/octos-agent/src/mcp.rs:63` |
| `mcp_servers[].headers` | map<string,string> | `{}` | HTTP 传输：附加头（如静态 bearer）；设 oauth 时忽略 | `crates/octos-agent/src/mcp.rs:67` |
| `mcp_servers[].oauth` | bool | `false` | 对该 server 走 OAuth 2.1 授权码流（须 url） | `crates/octos-agent/src/mcp.rs:72` |
| `mcp_servers[].scopes` | string[] | `[]` | `octos mcp login` 时请求的 OAuth scope | `crates/octos-agent/src/mcp.rs:75` |
| `mcp_servers[].concurrency_class` | string? | `null`（= `safe`） | 该 server 全部工具的并发类：`safe`/`exclusive`；未知值保守取 exclusive | `crates/octos-agent/src/mcp.rs:84` |

不可配置的硬限制（常量）：握手超时 30s（`crates/octos-agent/src/mcp.rs:43`）、单次 `tools/call` 60s（`crates/octos-agent/src/mcp.rs:45`）、工具输入 schema 嵌套 ≤10 层（`crates/octos-agent/src/mcp.rs:47`）、schema 序列化 ≤64KB（`crates/octos-agent/src/mcp.rs:49`）。

## C.10 `sub_providers[]` 专节（`crates/octos-cli/src/config.rs:618` `SubProviderConfig`）

spawn 子 agent 可引用的模型车道。保留键：`goal_verifier`（#1935）：存在时该 lane 成为独立的 goal 完成校验模型，否则回退到旧行为（用评分会话自己的 provider 校验）。与 Ch9 的分工：那边讲 spawn 工具如何消费这些车道，这里只给字段。

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `sub_providers[].key` | string | 必填 | LLM 引用的短键（如 `cheap` / `strong` / `goal_verifier`） | `crates/octos-cli/src/config.rs:620` |
| `sub_providers[].provider` | string | 必填 | provider 名 | `crates/octos-cli/src/config.rs:622` |
| `sub_providers[].model` | string? | `null` | 模型名 | `crates/octos-cli/src/config.rs:625` |
| `sub_providers[].api_key_env` | string? | provider 默认 | 密钥环境变量名 | `crates/octos-cli/src/config.rs:629` |
| `sub_providers[].base_url` | string? | `null` | base URL | `crates/octos-cli/src/config.rs:632` |
| `sub_providers[].description` | string? | `null` | 何时用此模型的说明（进 spawn 工具 schema） | `crates/octos-cli/src/config.rs:636` |
| `sub_providers[].default_context_window` | u32? | `null` | 选中时子 agent 的默认上下文预算 | `crates/octos-cli/src/config.rs:642` |
| `sub_providers[].max_output_tokens` | u32? | 自动检测 | 每次调用最大输出 tokens 覆盖 | `crates/octos-cli/src/config.rs:647` |
| `sub_providers[].api_type` | string? | provider 默认 | 协议覆盖 | `crates/octos-cli/src/config.rs:650` |

## C.11 `validators`（声明式校验器，workspace policy 层）

`validators` 不在 `config.json` 里——它是工作区策略文件 `.octos-workspace.toml`（`crates/octos-agent/src/workspace_policy.rs:13` `WORKSPACE_POLICY_FILE`）中 `validation` 节的子键。顶层策略结构 `WorkspacePolicy` 在 `crates/octos-agent/src/workspace_policy.rs:22`；`validation` 节（`crates/octos-agent/src/workspace_policy.rs:115` `ValidationPolicy`）：

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `validation.on_turn_end` | string[] | `[]` | Tier 1：每轮末跑的廉价检查（<100ms） | `crates/octos-agent/src/workspace_policy.rs:118` |
| `validation.on_source_change` | string[] | `[]` | Tier 2：源码变更时跑的中档检查（1-5s） | `crates/octos-agent/src/workspace_policy.rs:121` |
| `validation.on_completion` | string[] | `[]` | Tier 3：完成/发布才跑的昂贵检查（10-30s） | `crates/octos-agent/src/workspace_policy.rs:124` |
| `validation.validators[]` | `array<Validator>` | `[]` | 类型化声明式校验器（M4.3） | `crates/octos-agent/src/workspace_policy.rs:127` |

每个 `Validator`（`crates/octos-agent/src/workspace_policy.rs:143`）：

| 字段路径 | 类型 | 默认值 | 作用 | 来源行号 |
|---------|------|--------|------|---------|
| `validators[].id` | string | 必填 | 稳定唯一标识 | `crates/octos-agent/src/workspace_policy.rs:145` |
| `validators[].required` | bool | `true` | 失败是否阻断终态成功 | `crates/octos-agent/src/workspace_policy.rs:149` |
| `validators[].soft_fail` | bool | `false` | true 时失败只告警不降级（Wave-3a 软档） | `crates/octos-agent/src/workspace_policy.rs:157` |
| `validators[].timeout_ms` | u64? | `null` | 单校验器超时（命令/工具类） | `crates/octos-agent/src/workspace_policy.rs:161` |
| `validators[].phase` | enum | `"completion"` | `turn_end` / `completion` | `crates/octos-agent/src/workspace_policy.rs:164`、枚举 `crates/octos-agent/src/workspace_policy.rs:290` |
| `validators[].spec` | enum(tagged `kind`) | 必填 | 校验体，见下 | `crates/octos-agent/src/workspace_policy.rs:166` |

`spec` 变体（`crates/octos-agent/src/workspace_policy.rs:301` `ValidatorSpec`，serde tag `kind`，snake_case）：

- `command`：`cmd`（必填）、`args`（默认 `[]`）：子进程命令，走 shell 安全层（`crates/octos-agent/src/workspace_policy.rs:306`）
- `tool_call`：`tool`（必填）、`args`（默认 `{}`）：调用注册的 agent 工具（`crates/octos-agent/src/workspace_policy.rs:313`）
- `file_exists`：`path`（必填）、`min_bytes`（默认 `null`）：断言文件存在/最小字节数（`crates/octos-agent/src/workspace_policy.rs:318`）
- `http_probe`：`url_template`（必填）、`expected_status`（默认 `200`）、`expected_contains`（默认 `null`）：HTTP 探测，默认 5s 超时（`crates/octos-agent/src/workspace_policy.rs:325`）
- `ominix_voice_exists`：`name_arg`（必填）：查 ominix-api 已注册自定义音色（`crates/octos-agent/src/workspace_policy.rs:336`）
- `audio_non_silent`：`glob`（默认 `""`）、`min_ratio`（默认 `0.3`）、`source`（默认 glob 模式）、`extension`（默认 `null`）：音频非静音比例（`crates/octos-agent/src/workspace_policy.rs:344`）
- `per_file_non_silent`：整文件逐一非静音校验，`require_at_least` 计数（`crates/octos-agent/src/workspace_policy.rs:368` 附近）
- 魔数断言 `MagicByteKind`：`mp3`/`wav`/`png`/`jpeg`/`pdf`/`mp4`/`webm`/`pptx`（`crates/octos-agent/src/workspace_policy.rs:469`）

运行时常量：命令类默认超时 30s（`crates/octos-agent/src/validators.rs:55` `DEFAULT_COMMAND_TIMEOUT_MS`）、HTTP 探测默认 5s（`crates/octos-agent/src/validators.rs:60` `DEFAULT_HTTP_PROBE_TIMEOUT_MS`）、证据文件在 `<workspace_root>/.octos/validator-evidence/`（`crates/octos-agent/src/validators.rs:53`）、单条证据 ≤512KB（`crates/octos-agent/src/validators.rs:62` `MAX_EVIDENCE_BYTES`）。

## C.12 profile 体系简表

profile 文件 `~/.octos/profiles/<id>.json` 的 `config.llm` 是一等结构化 LLM 选择契约，**不是**顶层 `config.json` 那种 `provider`/`model` 扁平键。三层结构：

**`config.llm`（`crates/octos-cli/src/profiles.rs:814` `LlmProfileConfig`）**

| 字段 | 类型 | 默认 | 作用 |
|------|------|------|------|
| `primary` | LlmModelSelectionConfig? | `null` | 主模型选择 |
| `fallbacks` | array | `[]` | 备选模型链 |

**`config.llm.primary` / 每个 fallback（`crates/octos-cli/src/profiles.rs:824` `LlmModelSelectionConfig`，`#[serde(deny_unknown_fields)]`）**

| 字段 | 类型 | 默认 | 作用 |
|------|------|------|------|
| `family_id` | string? | `null` | 模型家族（如 `moonshot` / `deepseek`） |
| `model_id` | string? | `null` | 具体模型 ID（如 `kimi-k2.5`） |
| `route` | LlmRouteConfig? | `null` | 该模型的 provider 路由 |
| `model_hints` | object? | `null` | 自定义/代理模型行为提示 |
| `cost_per_m` | f64? | `null` | 每百万 token 输出价格（路由用） |
| `strong` | bool? | `null` | 大工具量任务是否可靠 |
| `temperature` | f32? | `null` | typed 采样温度（#2166，AppUI 校验 0.0..=2.0） |
| `top_p` | f32? | `null` | nucleus 采样（#2166，校验 0.0..=1.0） |
| `reasoning_effort` | enum? | `null` | 思考模型默认推理力度（#2166） |
| `context_window` | u32? | `null` | 上下文窗口覆盖（#2135/#2142，压过探测与目录） |

**`config.llm.primary.route`（`crates/octos-cli/src/profiles.rs:881` `LlmRouteConfig`）**

| 字段 | 类型 | 默认 | 作用 |
|------|------|------|------|
| `route_id` | string? | `null` | 目录中的稳定路由 ID（如 `official` / `wisemodel`） |
| `label` | string? | `null` | 人读路由标签 |
| `base_url` | string? | `null` | 该路由 endpoint |
| `api_key_env` | string? | `null` | 该路由密钥环境变量 |
| `api_type` | string? | `null` | 协议覆盖 |

**三档继承（`crates/octos-cli/src/profiles.rs:2403` `resolve_effective_profile`）**：子 profile 带 `parent_id` 时，父的 LLM 契约整体覆盖继承（`ec.llm = pc.llm`），review/search/deep_crawl/apps/email/tool_policy 等结构节则仅当子级为空时继承；无 parent 则原样返回。这是 goal 三档（operator 默认 → 队列 → worker 覆盖）中 profile 侧的机制，完整三档语义见 Ch15。

最小可用 profile JSON 示例（密钥只出现环境变量名，无任何密钥值）：

```jsonc
{
  "id": "writer",
  "display_name": "Writer",
  "config": {
    "llm": {
      "primary": {
        "family_id": "deepseek",
        "model_id": "deepseek-v4-pro",
        "route": {
          "route_id": "wisemodel",
          "base_url": "https://api.wisemodel.cn/v1",
          "api_key_env": "WISEMODEL_API_KEY"
        },
        "temperature": 0.3,
        "context_window": 131072
      },
      "fallbacks": [
        {
          "family_id": "moonshot",
          "model_id": "kimi-k2.5",
          "route": { "api_key_env": "MOONSHOT_API_KEY" },
          "strong": true
        }
      ]
    },
    "memory": { "max_inject_tokens": 4000 }
  }
}
```

## C.13 完整 `config.json` 示例（JSONC 注释）

```jsonc
{
  // 迁移版本，当前 1
  "version": 1,
  // 主 LLM(扁平键；serve 多租户请用 profile 的 config.llm)
  "provider": "anthropic",
  "model": "claude-sonnet-4",
  "api_key_env": "ANTHROPIC_API_KEY",
  "env_vars": {},
  "context_window": 200000,          // #2142 覆盖目录/探测
  // failover 链
  "fallback_models": [
    { "provider": "openai", "model": "gpt-4o", "strong": true, "cost_per_m": 2.5 }
  ],
  // 会话与工具
  "max_iterations": 50,
  "format_after_edit": true,         // #1774 编辑后自动格式化
  "context_filter": [],
  "tool_policy": { "deny": [], "allow": [] },
  "sandbox": {
    "enabled": true,
    "mode": "auto",
    "allow_network": false,
    "workspace_write": true
  },
  "snapshots": { "enabled": false, "keep_last": 20 },
  // MCP server(见 C.9;协议细节见 Ch9)
  "mcp_servers": [
    {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"],
      "env": {},
      "concurrency_class": "safe"
    }
  ],
  // 子 agent 车道(见 C.10;goal_verifier 为保留键)
  "sub_providers": [
    { "key": "cheap", "provider": "openai", "model": "gpt-4o-mini", "api_key_env": "OPENAI_API_KEY" }
  ],
  // 生命周期 hooks(C.7)
  "hooks": [
    { "event": "after_tool_call", "command": ["cargo", "check"], "timeout_ms": 5000, "tool_filter": ["edit_file"], "path_filter": [] }
  ],
  // gateway(C.3)
  "gateway": {
    "channels": [{ "type": "cli", "allowed_senders": [], "settings": {} }],
    "max_history": 50,
    "queue_mode": "collect",
    "llm_timeout_secs": 120
  },
  // 自适应路由(C.8)
  "adaptive_routing": { "enabled": false, "mode": "off" },
  // 记忆与 embedding(C.6)
  "memory": { "max_inject_tokens": 4000, "refresh": { "enabled": true } },
  "embedding": { "provider": "openai", "model": "text-embedding-3-small", "api_key_env": "OPENAI_API_KEY" },
  // 运维(C.8)
  "mode": "local",
  "allow_admin_shell": false,
  "appui": { "allowed_origins": [], "sessions_in_cwd": true },
  "plugins": { "require_signed": false },
  "cli": { "serve": { "port": 50080 } }
}
```

## C.14 版本演化说明

本附录数据基线为 octos main `9c157101`（docs(guide): document mcp_servers stdio fields, env sanitization, timeouts, #2211/#2212）。相对早期基线的主要演化：

- **typed LLM schema（`3a567a4c` / #2166）**：`LlmModelSelectionConfig` 新增 `temperature` / `top_p` / `reasoning_effort` / `context_window`（#2142 拆自 #2127），顶层 `Config` 同步投影出 `model_temperature` / `model_top_p` / `model_reasoning_effort`（`crates/octos-cli/src/config.rs:56-65`），与 `gateway.llm_temperature` / `gateway.llm_sampling_params`（#2172）构成显式优先级链。
- **`mcp_servers`**：profile 级 `[[mcp_servers]]` 在 OLP #29 S2b 前不会注册工具（`crates/octos-cli/src/profiles.rs:198` 注释）；stdio 字段、env 清洗与超时在 #2211/#2212 文档化。
- **`sub_providers` 保留键 `goal_verifier`**（#1935）：缺省时 goal 完成校验回退评分会话自身 provider（旧行为）。
- **hooks schema**：现行为 `hooks[]` + `event` + `command`（argv）+ `timeout_ms`（默认 5000）+ `tool_filter: string[]`，另有较新的 `path_filter` 与 `requires_bin`。
- **queue_mode**：`steer` 更名 `latest`（`crates/octos-cli/src/config.rs:1507-1512`，serde 别名保留兼容）。
- **`snapshots`（#1768）、`approval_policy`、`appui.sessions_in_cwd`、`plugins.require_signed`、`cli` 节**均为后续新增；`sandbox.write_allow_globs`（#1976）与 `tool_policy.bash_file_writes`（#28b）是近期收紧项。

旧版附录中的数字与字段表一律作废，以本表为准。
