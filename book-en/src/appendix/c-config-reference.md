# Appendix C: Configuration Reference

> **Positioning**: This appendix is the complete field reference for `config.json` and profile files: one table per top-level config section, with field path, type, default, one-line purpose, and source line, all verified against octos `9c157101` (`crates/octos-cli/src/config.rs` runs 3,790 lines, `crates/octos-cli/src/profiles.rs` runs 7,003 lines). For behavioral semantics (how the sandbox picks a backend, how MCP performs its handshake, how the goal three-tier inheritance works) see the corresponding chapters; this appendix answers only "what is this field, what is its default, where is it defined." `mcp_servers` and `sub_providers`, which overlap with Chapter 9 (extension mechanisms), get field tables only.

## C.1 Config file locations and load order

Resolution order for the top-level `config.json` (`crates/octos-cli/src/config.rs:1715` `resolve_config_file_path`): an explicit `--config <FILE>` overrides everything, then (under the default install) project-local `<cwd>/.octos/config.json`, then `<config_home>/config.json`, then (under the default install) the legacy `~/.octos/config.json`. When no file exists, the write location falls back to `config_home/config.json`.

Profile files live at `~/.octos/profiles/<id>.json` (`crates/octos-cli/src/profiles.rs:5`); their data directory defaults to `~/.octos/profiles/{id}/data` (`crates/octos-cli/src/profiles.rs:164`).

## C.2 Top-level `Config` (`crates/octos-cli/src/config.rs:26`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `version` | u32? | `null` (constant currently `1`) | config migration version | `crates/octos-cli/src/config.rs:29` |
| `provider` | string? | `null` | LLM provider name (`"anthropic"` / `"openai"` / `"gemini"`) | `crates/octos-cli/src/config.rs:33` |
| `model` | string? | `null` | model ID | `crates/octos-cli/src/config.rs:37` |
| `context_window` | u32? | `null` | effective context window override for the primary model (tokens), outermost wrapper, beats catalog and probing | `crates/octos-cli/src/config.rs:46` |
| `model_temperature` | f32? | `null` | typed sampling temperature projection for the primary model (#2166) | `crates/octos-cli/src/config.rs:56` |
| `model_top_p` | f32? | `null` | top_p projection for the primary model; overrides the same-named key in the sampling params table at runtime | `crates/octos-cli/src/config.rs:61` |
| `model_reasoning_effort` | enum? | `null` | default reasoning effort for the primary model (low/medium/high) | `crates/octos-cli/src/config.rs:65` |
| `base_url` | string? | `null` | API endpoint override | `crates/octos-cli/src/config.rs:69` |
| `api_key_env` | string? | provider default | API key environment variable name | `crates/octos-cli/src/config.rs:73` |
| `env_vars` | map<string,string> | `{}` | profile-scoped environment variables (including keys persisted by the dashboard) | `crates/octos-cli/src/config.rs:77` |
| `bypass_auth_store` | bool | `false` | internal field (`#[serde(skip)]`, not serialized): skip the global AuthStore key lookup | `crates/octos-cli/src/config.rs:86` |
| `model_hints` | object? | `null` | custom model behavior hints for OpenAI-compatible proxies | `crates/octos-cli/src/config.rs:91` |
| `api_type` | string? | provider default | protocol override (`"openai"` / `"anthropic"`) | `crates/octos-cli/src/config.rs:97` |
| `auth_token` | string? | `null` | dashboard/admin token; also `--auth-token` or `OCTOS_AUTH_TOKEN` | `crates/octos-cli/src/config.rs:102` |
| `gateway` | object? | `null` | gateway mode configuration (see C.3) | `crates/octos-cli/src/config.rs:106` |
| `mcp_servers` | array | `[]` | MCP server list (see C.9) | `crates/octos-cli/src/config.rs:110` |
| `sandbox` | object | `SandboxConfig::default()` | tool sandbox (see C.5) | `crates/octos-cli/src/config.rs:114` |
| `snapshots` | object? | `null` (= off) | workspace snapshot-rollback (#1768, off by default) | `crates/octos-cli/src/config.rs:123` |
| `tool_policy` | object? | `null` | global tool allow/deny/tag policy (see C.5) | `crates/octos-cli/src/config.rs:127` |
| `tool_policy_by_provider` | map<string,ToolPolicy> | `{}` | per-model/provider-prefix tool policy | `crates/octos-cli/src/config.rs:132` |
| `embedding` | object? | `null` | hybrid memory embedding (see C.6) | `crates/octos-cli/src/config.rs:136` |
| `memory` | object? | `null` | memory subsystem (see C.6) | `crates/octos-cli/src/config.rs:140` |
| `fallback_models` | array | `[]` | fallback models for the provider failover chain (see C.4) | `crates/octos-cli/src/config.rs:145` |
| `max_iterations` | u32? | `null` | max agent iterations per message (`--max-iterations` can override) | `crates/octos-cli/src/config.rs:149` |
| `format_after_edit` | bool | `false` | run a language formatter after a successful edit (rustfmt/prettier etc., 5s timeout, #1774) | `crates/octos-cli/src/config.rs:158` |
| `hooks` | array | `[]` | lifecycle hooks (see C.7) | `crates/octos-cli/src/config.rs:162` |
| `approval_policy` | object? | `null` | human approval rules for tool calls (see C.7) | `crates/octos-cli/src/config.rs:168` |
| `context_filter` | string[] | `[]` | tool tag filter; only tools with matching tags are visible to the LLM | `crates/octos-cli/src/config.rs:173` |
| `sub_providers` | array | `[]` | provider lanes selectable by spawned sub-agents (see C.10) | `crates/octos-cli/src/config.rs:184` |
| `adaptive_routing` | object? | `null` | adaptive routing (see C.8) | `crates/octos-cli/src/config.rs:189` |
| `email` | object? | `null` | `send_email` tool configuration (see C.6) | `crates/octos-cli/src/config.rs:193` |
| `voice` | object? | `null` | ASR/TTS (see C.6) | `crates/octos-cli/src/config.rs:198` |
| `mode` | enum | `"local"` | deployment mode: `local` / `tenant` / `cloud` | `crates/octos-cli/src/config.rs:206` |
| `tunnel_domain` | string? | `null` | cloud/tenant tunnel domain | `crates/octos-cli/src/config.rs:211` |
| `base_domain` | string? | compatible `crew.ominix.io` | base domain for public profiles (`OCTOS_BASE_DOMAIN` takes precedence) | `crates/octos-cli/src/config.rs:222` |
| `frps_server` | string? | `null` | frps server address (`FRPS_SERVER` env can override) | `crates/octos-cli/src/config.rs:227` |
| `allow_admin_shell` | bool | `false` | whether `/api/admin/shell` is enabled; keep off in production | `crates/octos-cli/src/config.rs:233` |
| `dashboard_auth` | object? | `null` | email OTP login (api feature, see C.8) | `crates/octos-cli/src/config.rs:239` |
| `monitor` | object? | `null` | watchdog/alert (api feature, see C.8) | `crates/octos-cli/src/config.rs:244` |
| `credential_pool` | object? | `null` | credential pool (M6.5, see C.8) | `crates/octos-cli/src/config.rs:251` |
| `content_routing` | object? | `null` | content-classifier Cheap/Strong routing (M6.6) | `crates/octos-cli/src/config.rs:257` |
| `appui` | object | `AppUiConfig::default()` | AppUI session defaults (see C.8) | `crates/octos-cli/src/config.rs:269` |
| `plugins` | object | `PluginsConfig::default()` | plugin signature check switch (see C.8) | `crates/octos-cli/src/config.rs:277` |
| `cli` | map<string,json> | `{}` (skip serializing) | per-subcommand persisted CLI flag defaults, e.g. `{"serve": {"port": 50080}}` | `crates/octos-cli/src/config.rs:292` |

The `mode` enum is defined at `crates/octos-cli/src/config.rs:14`: `Local` (standalone install, no tunnel, dashboard at `/admin/`), `Tenant` (frpc tunnel into the cloud), `Cloud` (VPS relay plus tenant management plus landing pages).

## C.3 The `gateway` section (`crates/octos-cli/src/config.rs:1524` `GatewayConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `gateway.channels[]` | `array<ChannelEntry>` | `[{"type":"cli",…}]` | list of enabled channels | `crates/octos-cli/src/config.rs:1527` |
| `gateway.channels[].type` | string | required | channel type: `"cli"` / `"telegram"` / `"discord"` | `crates/octos-cli/src/config.rs:1642` |
| `gateway.channels[].allowed_senders` | string[] | `[]` (= everyone allowed) | allowed sender IDs | `crates/octos-cli/src/config.rs:1646` |
| `gateway.channels[].settings` | json | `{}` | channel-specific settings | `crates/octos-cli/src/config.rs:1650` |
| `gateway.max_history` | usize | `50` | max history messages injected into the LLM | `crates/octos-cli/src/config.rs:1531` |
| `gateway.system_prompt` | string? | `null` | custom system prompt for gateway mode | `crates/octos-cli/src/config.rs:1535` |
| `gateway.queue_mode` | enum | `"collect"` | how messages received mid-run are queued | `crates/octos-cli/src/config.rs:1541` |
| `gateway.max_sessions` | usize | `1000` | max sessions in memory (LRU eviction) | `crates/octos-cli/src/config.rs:1545` |
| `gateway.max_concurrent_sessions` | usize | `10` | max concurrently processed sessions | `crates/octos-cli/src/config.rs:1549` |
| `gateway.browser_timeout_secs` | u64? | `null` (300s in code) | timeout for a single browser action | `crates/octos-cli/src/config.rs:1554` |
| `gateway.llm_timeout_secs` | u64? | `null` (default 120) | total LLM HTTP request timeout | `crates/octos-cli/src/config.rs:1558` |
| `gateway.llm_connect_timeout_secs` | u64? | `null` (default 30) | LLM HTTP connect timeout | `crates/octos-cli/src/config.rs:1562` |
| `gateway.tool_timeout_secs` | u64? | `null` (default 300) | cap on completing parallel tool calls | `crates/octos-cli/src/config.rs:1566` |
| `gateway.session_timeout_secs` | u64? | `null` (default 600) | cap on processing one session message | `crates/octos-cli/src/config.rs:1570` |
| `gateway.max_output_tokens` | u32? | `null` | default max output tokens per call (beats model_limits.json) | `crates/octos-cli/src/config.rs:1575` |
| `gateway.reasoning_effort` | enum? | `null` | reasoning effort for thinking models (low/medium/high), ignored by non-thinking models | `crates/octos-cli/src/config.rs:1582` |
| `gateway.llm_temperature` | f32? | `null` (= greedy 0.0) | sampling temperature override, mainly to rescue repetition collapse on local models (#2172) | `crates/octos-cli/src/config.rs:1592` |
| `gateway.llm_sampling_params` | map<string,json>? | `null` | pass-through sampling params table, e.g. `{"repeat_penalty":1.1}` (#2172) | `crates/octos-cli/src/config.rs:1600` |

The `queue_mode` enum (`crates/octos-cli/src/config.rs:1499`): `followup` (FIFO, one by one), `collect` (default, concatenates within a session), `latest` (keep only the newest, alias `steer`), `interrupt` (cancel current), `speculative` (a slow call continues while a new agent starts).

The default port for `octos serve` is **50080** (documented example at `crates/octos-cli/src/config.rs:283`).

## C.4 `fallback_models[]` (`crates/octos-cli/src/config.rs:460` `FallbackModel`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `provider` | string | required | provider name | `crates/octos-cli/src/config.rs:462` |
| `model` | string? | `null` | model name | `crates/octos-cli/src/config.rs:465` |
| `base_url` | string? | `null` | base URL for this fallback | `crates/octos-cli/src/config.rs:468` |
| `api_key_env` | string? | `null` | key environment variable for this fallback | `crates/octos-cli/src/config.rs:471` |
| `model_hints` | object? | `null` | model behavior hints | `crates/octos-cli/src/config.rs:474` |
| `api_type` | string? | `null` | protocol override | `crates/octos-cli/src/config.rs:477` |
| `cost_per_m` | f64? | `null` | output price per million tokens (for cost-aware routing) | `crates/octos-cli/src/config.rs:480` |
| `strong` | bool | `true` | whether it is a strong model (reliable with 30+ tools / large payloads) | `crates/octos-cli/src/config.rs:485` |
| `context_window` | u32? | `null` | context window override for this fallback (#2142) | `crates/octos-cli/src/config.rs:492` |

## C.5 `sandbox` / `tool_policy` / `snapshots`

### `sandbox` (`crates/octos-agent/src/sandbox/mod.rs:37` `SandboxConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `sandbox.enabled` | bool | `true` | whether the sandbox is enabled | `crates/octos-agent/src/sandbox/mod.rs:40` |
| `sandbox.mode` | enum | `"auto"` | `auto` / `bwrap` / `landlock` / `macos` / `docker` / `appcontainer` / `none` | `crates/octos-agent/src/sandbox/mod.rs:44`, enum `crates/octos-agent/src/sandbox/mod.rs:423` |
| `sandbox.fail_closed` | bool | `false` | refuse execution when auto finds no backend, rather than degrade to bare execution | `crates/octos-agent/src/sandbox/mod.rs:58` |
| `sandbox.allow_network` | bool | `false` | allow network inside the sandbox | `crates/octos-agent/src/sandbox/mod.rs:62` |
| `sandbox.workspace_write` | bool | `true` | whether shell can write the cwd (false = workspace mounted read-only) | `crates/octos-agent/src/sandbox/mod.rs:75` |
| `sandbox.repo_git_write` | path? | `null` | additionally grant write access to `<repo>/.git` | `crates/octos-agent/src/sandbox/mod.rs:92` |
| `sandbox.docker.image` | string | `"ubuntu:24.04"` | image for docker mode | `crates/octos-agent/src/sandbox/mod.rs:361` |
| `sandbox.docker.cpu_limit` | string? | `null` | CPU limit such as `"1.0"` | `crates/octos-agent/src/sandbox/mod.rs:365` |
| `sandbox.docker.memory_limit` | string? | `null` | memory limit such as `"512m"` | `crates/octos-agent/src/sandbox/mod.rs:369` |
| `sandbox.docker.pids_limit` | u32? | `null` | max process count | `crates/octos-agent/src/sandbox/mod.rs:373` |
| `sandbox.docker.mount_mode` | enum | `"rw"` | `none` / `ro` / `rw` workspace mount | `crates/octos-agent/src/sandbox/mod.rs:377`, enum `crates/octos-agent/src/sandbox/mod.rs:408` |
| `sandbox.docker.extra_binds` | string[] | `[]` | extra bind mounts (`host:container[:ro]`) | `crates/octos-agent/src/sandbox/mod.rs:381` |
| `sandbox.read_allow_paths` | string[] | `[]` (= everything allowed) | restrict readable paths (whitelist outside the cwd) | `crates/octos-agent/src/sandbox/mod.rs:102` |
| `sandbox.write_allow_globs` | string[]? | `null` | #1976 shell write fence: workspace-relative globs | `crates/octos-agent/src/sandbox/mod.rs:125` |
| `sandbox.profile_name` | string? | `null` | sandbox profile name (Windows AppContainer ID) | `crates/octos-agent/src/sandbox/mod.rs:129` |
| `sandbox.allow_toolchains` | bool | `true` | grant write paths a language toolchain needs (cargo cache and the like) | `crates/octos-agent/src/sandbox/mod.rs:149` |

### `tool_policy` (`crates/octos-agent/src/tools/policy.rs:28` `ToolPolicy`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `tool_policy.allow` | string[] | `[]` (= allow all) | allowed tools/groups/wildcards | `crates/octos-agent/src/tools/policy.rs:31` |
| `tool_policy.deny` | string[] | `[]` | deny list, always beats allow | `crates/octos-agent/src/tools/policy.rs:34` |
| `tool_policy.require_tags` | string[] | `[]` | expose only tools whose declared tags match (fail closed) | `crates/octos-agent/src/tools/policy.rs:40` |
| `tool_policy.bash_file_writes` | enum | `"allow"` | `allow` / `warn` / `deny`: three tiers for shell file writes | `crates/octos-agent/src/tools/policy.rs:49` |

`tool_policy_by_provider` is a map of the same structure (`crates/octos-cli/src/config.rs:132`); its keys are exact model IDs (preferred) or provider prefixes.

### `snapshots` (`crates/octos-agent/src/snapshot.rs:122` `SnapshotConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `snapshots.enabled` | bool | `false` | master snapshot switch (git-backed, stored under `<data_dir>/snapshots/`) | `crates/octos-agent/src/snapshot.rs:124` |
| `snapshots.keep_last` | usize | `20` | retained snapshots per workspace (<1 clamps to 1) | `crates/octos-agent/src/snapshot.rs:127` |

## C.6 `embedding` / `memory` / `email` / `voice`

### `embedding` (`crates/octos-cli/src/config.rs:655` `EmbeddingConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `embedding.provider` | string | `"openai"` | embedding provider (including local `llamacpp`) | `crates/octos-cli/src/config.rs:658` |
| `embedding.api_key_env` | string? | `null` | key environment variable name | `crates/octos-cli/src/config.rs:662` |
| `embedding.base_url` | string? | `null` | API base URL | `crates/octos-cli/src/config.rs:666` |
| `embedding.model` | string? | `text-embedding-3-small` | embedding model ID | `crates/octos-cli/src/config.rs:672` |
| `embedding.dimensions` | u32? | `null` | dimensions field in requests (episodic HNSW is fixed at 1536) | `crates/octos-cli/src/config.rs:678` |
| `embedding.model_path` | string? | `null` | path to a local `.gguf` (feature `embed-llama`) | `crates/octos-cli/src/config.rs:685` |

### `memory` (`crates/octos-cli/src/config.rs:694` `MemoryConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `memory.max_inject_tokens` | usize? | `DEFAULT_MAX_INJECT_TOKENS` | token budget for memory blocks injected into the system prompt | `crates/octos-cli/src/config.rs:701` |
| `memory.refresh.enabled` | bool? | `null` (= on) | master switch for automatic memory refresh (default product behavior is on) | `crates/octos-cli/src/config.rs:719` |
| `memory.refresh.extract_model` | string? | `null` (= profile provider) | model key for extraction | `crates/octos-cli/src/config.rs:723` |
| `memory.refresh.consolidate_model` | string? | `null` (= profile provider) | model key for consolidation | `crates/octos-cli/src/config.rs:726` |
| `memory.refresh.min_idle_minutes` | u64? | `30` | how long a session must idle before it can be scanned | `crates/octos-cli/src/config.rs:729` |
| `memory.refresh.max_session_age_days` | u64? | `10` | sessions older than this are never scanned | `crates/octos-cli/src/config.rs:732` |
| `memory.refresh.max_sessions_per_pass` | usize? | `2` | sessions scanned per pass | `crates/octos-cli/src/config.rs:735` |
| `memory.refresh.max_extractions_per_day` | u32? | `20` | daily extraction budget per profile | `crates/octos-cli/src/config.rs:738` |
| `memory.refresh.max_consolidations_per_day` | u32? | `12` | daily consolidation budget per profile | `crates/octos-cli/src/config.rs:742` |
| `memory.refresh.max_daily_tokens` | u64? | `200000` | daily token budget (shared by extraction and consolidation) | `crates/octos-cli/src/config.rs:745` |
| `memory.refresh.consolidate_interval_minutes` | u64? | `30` | background scan interval (minutes) | `crates/octos-cli/src/config.rs:748` |
| `memory.refresh.debounce_seconds` | u64? | `90` | fast-lane debounce after a user note | `crates/octos-cli/src/config.rs:751` |
| `memory.refresh.unused_days` | u32? | `null` | how long unused entries become archive candidates | `crates/octos-cli/src/config.rs:755` |
| `memory.refresh.max_memory_file_tokens` | usize? | `null` | MEMORY.md size cap (enforced at consolidation) | `crates/octos-cli/src/config.rs:758` |
| `memory.refresh.pending_confirm_days` | u32? | `null` | days before a pending forget request expires | `crates/octos-cli/src/config.rs:762` |
| `memory.refresh.max_extract_input_tokens` | usize? | `24000` | hard input budget for a single extraction call | `crates/octos-cli/src/config.rs:767` |

Design defaults come from `MemoryRefreshConfig::knobs` at `crates/octos-cli/src/config.rs:772`.

### `email` (`crates/octos-cli/src/config.rs:856` `EmailConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `email.provider` | string | required | `"smtp"` or `"feishu"`/`"lark"` | `crates/octos-cli/src/config.rs:858` |
| `email.smtp_host` | string? | `null` | SMTP host | `crates/octos-cli/src/config.rs:862` |
| `email.smtp_port` | u16? | `null` | SMTP port | `crates/octos-cli/src/config.rs:864` |
| `email.username` | string? | `null` | SMTP username | `crates/octos-cli/src/config.rs:866` |
| `email.password_env` | string? | `null` | SMTP password environment variable (legacy) | `crates/octos-cli/src/config.rs:869` |
| `email.password` | string? | `null` | SMTP password in plaintext (takes precedence over password_env) | `crates/octos-cli/src/config.rs:872` |
| `email.from_address` | string? | `null` | sender address | `crates/octos-cli/src/config.rs:874` |
| `email.feishu_app_id` | string? | `null` | Feishu app ID | `crates/octos-cli/src/config.rs:878` |
| `email.feishu_app_secret_env` | string? | `null` | Feishu secret environment variable (legacy) | `crates/octos-cli/src/config.rs:881` |
| `email.feishu_app_secret` | string? | `null` | Feishu secret in plaintext (takes precedence) | `crates/octos-cli/src/config.rs:884` |
| `email.feishu_from_address` | string? | `null` | Feishu sender | `crates/octos-cli/src/config.rs:886` |
| `email.feishu_region` | string? | `"cn"` | `"cn"` / `"global"` | `crates/octos-cli/src/config.rs:889` |

### `voice` (`crates/octos-cli/src/config.rs:936` `VoiceConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `voice.api_url` | string? | n/a (legacy, ignored) | OminiX URL moved to platform-level `OMINIX_API_URL` | `crates/octos-cli/src/config.rs:939` |
| `voice.auto_asr` | bool | `true` | automatically transcribe voice messages | `crates/octos-cli/src/config.rs:942` |
| `voice.auto_tts` | bool | `true` | automatically synthesize replies in voice sessions | `crates/octos-cli/src/config.rs:945` |
| `voice.default_voice` | string | `"vivian"` | default TTS voice | `crates/octos-cli/src/config.rs:948` |
| `voice.asr_language` | string? | `null` (auto-detect) | ASR language hint | `crates/octos-cli/src/config.rs:951` |
| `voice.tts_provider` | string | `"auto"` | TTS routing: `auto` / `local` / `cloud` | `crates/octos-cli/src/config.rs:964` |
| `voice.cloud` | object? | `null` | non-secret Volcano cloud TTS settings | `crates/octos-cli/src/config.rs:969` |
| `voice.cloud.appid` | string? | `null` | cloud TTS app ID | `crates/octos-cli/src/config.rs:904` |
| `voice.cloud.voice` | string? | `null` | cloud TTS voice | `crates/octos-cli/src/config.rs:906` |
| `voice.cloud.cluster` | string? | `null` | cloud TTS cluster | `crates/octos-cli/src/config.rs:908` |
| `voice.cloud.encoding` | string? | `null` | cloud TTS encoding | `crates/octos-cli/src/config.rs:910` |
| `voice.cloud.endpoint` | string? | `null` | cloud TTS endpoint | `crates/octos-cli/src/config.rs:912` |

Cloud TTS secrets never land in this section: the token goes through `env_vars["VOLC_TTS_TOKEN"]` (`crates/octos-cli/src/config.rs:1040` `with_cloud_token_from_env`).

## C.7 `hooks` and `approval_policy`

### `hooks[]` (`crates/octos-agent/src/hooks.rs:77` `HookConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `hooks[].event` | enum | required | trigger event (see below) | `crates/octos-agent/src/hooks.rs:79` |
| `hooks[].command` | string[] | required | argv array executed directly (no shell interpretation) | `crates/octos-agent/src/hooks.rs:81` |
| `hooks[].timeout_ms` | u64 | `5000` | timeout in milliseconds | `crates/octos-agent/src/hooks.rs:84`, default `crates/octos-agent/src/hooks.rs:112` |
| `hooks[].tool_filter` | string[] | `[]` (= all tools) | fire only for these tool names (tool events) | `crates/octos-agent/src/hooks.rs:87` |
| `hooks[].path_filter` | string[] | `[]` (= no filter) | fire only when the tool argument `path` matches a glob | `crates/octos-agent/src/hooks.rs:103` |
| `hooks[].requires_bin` | string? | `null` | fire only if this binary exists on PATH | `crates/octos-agent/src/hooks.rs:109` |

Allowed `event` values (`crates/octos-agent/src/hooks.rs:58` `as_str`): `user_prompt_submit`, `before_tool_call`, `after_tool_call`, `before_llm_call`, `after_llm_call`, `on_resume`, `on_turn_end`, `before_spawn_verify`, `on_spawn_verify`, `on_spawn_complete`, `on_spawn_failure`.

### `approval_policy` (`crates/octos-cli/src/config.rs:545` `ApprovalPolicyConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `approval_policy.default` | enum | `"allow"` | disposition for tools matching no rule (v1: allow only) | `crates/octos-cli/src/config.rs:547` |
| `approval_policy.rules[]` | array | `[]` | list of human approval rules | `crates/octos-cli/src/config.rs:549` |
| `approval_policy.rules[].tools` | string[] | required, non-empty | tool names this rule intercepts | `crates/octos-cli/src/config.rs:530` |
| `approval_policy.rules[].require_approval` | bool | must be `true` | explicit intent declaration | `crates/octos-cli/src/config.rs:532` |
| `approval_policy.rules[].risk_level` | enum | n/a | `normal` / `critical` | `crates/octos-cli/src/config.rs:533` |
| `approval_policy.rules[].authorized_approvers` | string[] | required, non-empty | channel user IDs allowed to answer | `crates/octos-cli/src/config.rs:535` |
| `approval_policy.rules[].expires_in_secs` | u64 | required, >0 | seconds before a request expires | `crates/octos-cli/src/config.rs:537` |
| `approval_policy.rules[].on_timeout` | enum | n/a | v1: `notify` only | `crates/octos-cli/src/config.rs:538` |

Validation lives in `validate` at `crates/octos-cli/src/config.rs:587`: non-empty tools, `require_approval == true`, non-empty approvers, `expires_in_secs > 0`; otherwise it fails fast.

## C.8 Adaptive routing and operations sections

### `adaptive_routing` (`crates/octos-cli/src/config.rs:1085` `AdaptiveRoutingConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `adaptive_routing.enabled` | bool | `false` | master switch | `crates/octos-cli/src/config.rs:1088` |
| `adaptive_routing.latency_threshold_ms` | u64 | `10000` | soft-penalty latency threshold | `crates/octos-cli/src/config.rs:1092`, default `crates/octos-cli/src/config.rs:1253` |
| `adaptive_routing.error_rate_threshold` | f64 | `0.3` | error-rate threshold for de-prioritization | `crates/octos-cli/src/config.rs:1096`, default `crates/octos-cli/src/config.rs:1256` |
| `adaptive_routing.probe_probability` | f64 | `0.1` | probability of probing a non-primary provider | `crates/octos-cli/src/config.rs:1100`, default `crates/octos-cli/src/config.rs:1259` |
| `adaptive_routing.probe_interval_secs` | u64 | `60` | minimum interval between probes of the same provider | `crates/octos-cli/src/config.rs:1104`, default `crates/octos-cli/src/config.rs:1262` |
| `adaptive_routing.failure_threshold` | u32 | `3` | consecutive failures before the circuit breaker opens | `crates/octos-cli/src/config.rs:1108`, default `crates/octos-cli/src/config.rs:1265` |
| `adaptive_routing.mode` | enum | `"off"` | `off` / `hedge` / `lane` | `crates/octos-cli/src/config.rs:1114`, enum `crates/octos-cli/src/config.rs:1053` |
| `adaptive_routing.qos_ranking` | bool | `false` | include response quality in scoring | `crates/octos-cli/src/config.rs:1120` |
| `adaptive_routing.weight_latency` | f64 | `0.3` | latency score weight | `crates/octos-cli/src/config.rs:1124`, default `crates/octos-cli/src/config.rs:1268` |
| `adaptive_routing.weight_error_rate` | f64 | `0.3` | error-rate weight | `crates/octos-cli/src/config.rs:1127`, default `crates/octos-cli/src/config.rs:1271` |
| `adaptive_routing.weight_priority` | f64 | `0.2` | configured-priority weight | `crates/octos-cli/src/config.rs:1130`, default `crates/octos-cli/src/config.rs:1274` |
| `adaptive_routing.weight_cost` | f64 | `0.2` | token cost weight | `crates/octos-cli/src/config.rs:1133`, default `crates/octos-cli/src/config.rs:1277` |
| `adaptive_routing.auto_escalation.enabled` | bool | `true` | auto-escalate to hedge on latency degradation | `crates/octos-cli/src/config.rs:1169+`, default `crates/octos-cli/src/config.rs:1214` |
| `adaptive_routing.auto_escalation.window_size` | usize | `5` | observation window samples | `crates/octos-cli/src/config.rs:1217` |
| `adaptive_routing.auto_escalation.baseline_samples` | usize | `5` | baseline samples | `crates/octos-cli/src/config.rs:1220` |
| `adaptive_routing.auto_escalation.degradation_threshold` | f64 | `3.0` | degradation multiple for the verdict | `crates/octos-cli/src/config.rs:1223` |
| `adaptive_routing.auto_escalation.slow_trigger` | u32 | `3` | consecutive slow samples to trigger | `crates/octos-cli/src/config.rs:1226` |
| `adaptive_routing.auto_escalation.latency_ceiling_ms` | u64 | `8000` | latency ceiling | `crates/octos-cli/src/config.rs:1229` |
| `adaptive_routing.auto_escalation.recovery_factor` | f64 | `0.6` | recovery factor | `crates/octos-cli/src/config.rs:1232` |

### `monitor` (`crates/octos-cli/src/config.rs:1284` `MonitorConfig`, api feature)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `monitor.alerts_enabled` | bool | `true` | proactive alerting switch | `crates/octos-cli/src/config.rs:1287` |
| `monitor.watchdog_enabled` | bool | `true` | watchdog auto-restart | `crates/octos-cli/src/config.rs:1290` |
| `monitor.health_check_interval_secs` | u64 | `60` | health check interval | `crates/octos-cli/src/config.rs:1293` |
| `monitor.max_restart_attempts` | u32 | `3` | max restart attempts before giving up | `crates/octos-cli/src/config.rs:1296` |
| `monitor.telegram_token_env` | string? | `null` | Telegram bot token environment variable name | `crates/octos-cli/src/config.rs:1299` |
| `monitor.telegram_alert_chat_ids` | i64[] | `[]` | Telegram chat IDs for alerts | `crates/octos-cli/src/config.rs:1302` |
| `monitor.feishu_app_id_env` | string? | `null` | Feishu app ID environment variable | `crates/octos-cli/src/config.rs:1305` |
| `monitor.feishu_app_secret_env` | string? | `null` | Feishu secret environment variable | `crates/octos-cli/src/config.rs:1308` |
| `monitor.feishu_alert_user_ids` | string[] | `[]` | Feishu user IDs for alerts | `crates/octos-cli/src/config.rs:1311` |

### `dashboard_auth` (`crates/octos-cli/src/otp.rs:46` `DashboardAuthConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `dashboard_auth.smtp.host` | string | required | SMTP host | `crates/octos-cli/src/otp.rs:23` |
| `dashboard_auth.smtp.port` | u16 | `465` | SMTP port (465 implicit TLS / 587 STARTTLS) | `crates/octos-cli/src/otp.rs:26`, default `crates/octos-cli/src/otp.rs:40` |
| `dashboard_auth.smtp.username` | string | required | SMTP username | `crates/octos-cli/src/otp.rs:28` |
| `dashboard_auth.smtp.password_env` | string | required | SMTP password environment variable (legacy; new installs use `smtp_secret.json`) | `crates/octos-cli/src/otp.rs:35` |
| `dashboard_auth.smtp.from_address` | string | required | sender address | `crates/octos-cli/src/otp.rs:37` |
| `dashboard_auth.session_expiry_hours` | u64 | `24` | session expiry in hours | `crates/octos-cli/src/otp.rs:59` |
| `dashboard_auth.allow_self_registration` | bool | `false` | auto-create accounts for unknown emails | `crates/octos-cli/src/otp.rs:62` |
| `dashboard_auth.static_tokens` | string[] | `[]` | static tokens that bypass OTP (for E2E) | `crates/octos-cli/src/otp.rs:67` |

The `dashboard_auth.smtp` block is optional as a whole (`crates/octos-cli/src/otp.rs:56`); when absent, OTP goes to console output.

### `credential_pool` (`crates/octos-cli/src/config.rs:415` `CredentialPoolConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `credential_pool.state_path` | string? | `<data_dir>/credential_pool.redb` | persistent state file override | `crates/octos-cli/src/config.rs:419` |
| `credential_pool.name` | string | `"default"` | pool name used as a metrics label | `crates/octos-cli/src/config.rs:423` |
| `credential_pool.strategy` | string | `"round_robin"` | `fill_first`/`round_robin`/`random`/`least_used` | `crates/octos-cli/src/config.rs:427` |
| `credential_pool.credential_ids` | string[] | `[]` | credential IDs in the pool (env_vars supplies the keys at runtime) | `crates/octos-cli/src/config.rs:431` |
| `credential_pool.default_cooldown_ms` | u64? | `null` | default cooldown when a 429 carries no reset hint | `crates/octos-cli/src/config.rs:435` |

### `appui` (`crates/octos-cli/src/config.rs:339` `AppUiConfig`) and `plugins` (`crates/octos-cli/src/config.rs:315` `PluginsConfig`)

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `appui.allowed_origins` | string[] | `[]` | extra allowed REST/WS browser origins (exact `http(s)://`) | `crates/octos-cli/src/config.rs:348` |
| `appui.default_session_cwd` | path? | `null` | Tier-2 fallback directory when an AppUI session declares no cwd capability (must be absolute) | `crates/octos-cli/src/config.rs:360` |
| `appui.sessions_in_cwd` | bool | `true` | store sessions by project directory (`<cwd>/.octos/sessions/`) | `crates/octos-cli/src/config.rs:388` |
| `plugins.require_signed` | bool | `false` | enforce plugin `manifest.sha256` signatures (default: warn and allow) | `crates/octos-cli/src/config.rs:325` |

## C.9 The `mcp_servers[]` section (`crates/octos-agent/src/mcp.rs:53` `McpServerConfig`)

The field table follows; for protocol behavior (handshake, DNS anti-loopback, OAuth flow) see Chapter 9, not repeated here.

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `mcp_servers[].command` | string? | `null` | stdio transport: command to spawn | `crates/octos-agent/src/mcp.rs:56` |
| `mcp_servers[].args` | string[] | `[]` | stdio transport: command arguments | `crates/octos-agent/src/mcp.rs:58` |
| `mcp_servers[].env` | map<string,string> | `{}` | stdio transport: child process environment variables | `crates/octos-agent/src/mcp.rs:60` |
| `mcp_servers[].url` | string? | `null` | HTTP transport: server endpoint URL | `crates/octos-agent/src/mcp.rs:63` |
| `mcp_servers[].headers` | map<string,string> | `{}` | HTTP transport: extra headers (e.g. a static bearer); ignored when oauth is set | `crates/octos-agent/src/mcp.rs:67` |
| `mcp_servers[].oauth` | bool | `false` | use the OAuth 2.1 authorization-code flow with this server (requires url) | `crates/octos-agent/src/mcp.rs:72` |
| `mcp_servers[].scopes` | string[] | `[]` | OAuth scopes requested by `octos mcp login` | `crates/octos-agent/src/mcp.rs:75` |
| `mcp_servers[].concurrency_class` | string? | `null` (= `safe`) | concurrency class for all tools of this server: `safe`/`exclusive`; unknown values are treated conservatively as exclusive | `crates/octos-agent/src/mcp.rs:84` |

Non-configurable hard limits (constants): 30s handshake timeout (`crates/octos-agent/src/mcp.rs:43`), 60s per `tools/call` (`crates/octos-agent/src/mcp.rs:45`), tool input schema nesting ≤10 levels (`crates/octos-agent/src/mcp.rs:47`), schema serialization ≤64KB (`crates/octos-agent/src/mcp.rs:49`).

## C.10 The `sub_providers[]` section (`crates/octos-cli/src/config.rs:618` `SubProviderConfig`)

Model lanes that spawned sub-agents can reference. Reserved key: `goal_verifier` (#1935): when present, that lane becomes a dedicated goal-completion verifier; otherwise the old behavior applies (verifying with the scoring session's own provider). Division of labor with Chapter 9: that chapter covers how the spawn tools consume these lanes; this one gives fields only.

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `sub_providers[].key` | string | required | short key referenced by the LLM (e.g. `cheap` / `strong` / `goal_verifier`) | `crates/octos-cli/src/config.rs:620` |
| `sub_providers[].provider` | string | required | provider name | `crates/octos-cli/src/config.rs:622` |
| `sub_providers[].model` | string? | `null` | model name | `crates/octos-cli/src/config.rs:625` |
| `sub_providers[].api_key_env` | string? | provider default | key environment variable name | `crates/octos-cli/src/config.rs:629` |
| `sub_providers[].base_url` | string? | `null` | base URL | `crates/octos-cli/src/config.rs:632` |
| `sub_providers[].description` | string? | `null` | statement of when to use this model (goes into the spawn tool schema) | `crates/octos-cli/src/config.rs:636` |
| `sub_providers[].default_context_window` | u32? | `null` | default context budget for a sub-agent that selects this lane | `crates/octos-cli/src/config.rs:642` |
| `sub_providers[].max_output_tokens` | u32? | auto-detected | per-call max output tokens override | `crates/octos-cli/src/config.rs:647` |
| `sub_providers[].api_type` | string? | provider default | protocol override | `crates/octos-cli/src/config.rs:650` |

## C.11 `validators` (declarative validators, workspace policy layer)

`validators` does not live in `config.json`: it is a subkey of the `validation` section in the workspace policy file `.octos-workspace.toml` (`crates/octos-agent/src/workspace_policy.rs:13` `WORKSPACE_POLICY_FILE`). The top-level policy struct `WorkspacePolicy` is at `crates/octos-agent/src/workspace_policy.rs:22`; the `validation` section (`crates/octos-agent/src/workspace_policy.rs:115` `ValidationPolicy`):

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `validation.on_turn_end` | string[] | `[]` | Tier 1: cheap checks at end of each turn (<100ms) | `crates/octos-agent/src/workspace_policy.rs:118` |
| `validation.on_source_change` | string[] | `[]` | Tier 2: mid-weight checks on source changes (1-5s) | `crates/octos-agent/src/workspace_policy.rs:121` |
| `validation.on_completion` | string[] | `[]` | Tier 3: expensive checks at completion/release (10-30s) | `crates/octos-agent/src/workspace_policy.rs:124` |
| `validation.validators[]` | `array<Validator>` | `[]` | typed declarative validators (M4.3) | `crates/octos-agent/src/workspace_policy.rs:127` |

Each `Validator` (`crates/octos-agent/src/workspace_policy.rs:143`):

| Field path | Type | Default | Purpose | Source |
|---------|------|--------|------|---------|
| `validators[].id` | string | required | stable unique identifier | `crates/octos-agent/src/workspace_policy.rs:145` |
| `validators[].required` | bool | `true` | whether a failure blocks terminal success | `crates/octos-agent/src/workspace_policy.rs:149` |
| `validators[].soft_fail` | bool | `false` | when true, failures only warn instead of downgrading (Wave-3a soft tier) | `crates/octos-agent/src/workspace_policy.rs:157` |
| `validators[].timeout_ms` | u64? | `null` | per-validator timeout (command/tool kinds) | `crates/octos-agent/src/workspace_policy.rs:161` |
| `validators[].phase` | enum | `"completion"` | `turn_end` / `completion` | `crates/octos-agent/src/workspace_policy.rs:164`, enum `crates/octos-agent/src/workspace_policy.rs:290` |
| `validators[].spec` | enum (tagged `kind`) | required | the validation body, see below | `crates/octos-agent/src/workspace_policy.rs:166` |

`spec` variants (`crates/octos-agent/src/workspace_policy.rs:301` `ValidatorSpec`, serde tag `kind`, snake_case):

- `command`: `cmd` (required), `args` (default `[]`): subprocess command, goes through the shell safety layer (`crates/octos-agent/src/workspace_policy.rs:306`)
- `tool_call`: `tool` (required), `args` (default `{}`): calls a registered agent tool (`crates/octos-agent/src/workspace_policy.rs:313`)
- `file_exists`: `path` (required), `min_bytes` (default `null`): asserts the file exists / minimum bytes (`crates/octos-agent/src/workspace_policy.rs:318`)
- `http_probe`: `url_template` (required), `expected_status` (default `200`), `expected_contains` (default `null`): HTTP probe, default 5s timeout (`crates/octos-agent/src/workspace_policy.rs:325`)
- `ominix_voice_exists`: `name_arg` (required): looks up a custom voice registered with ominix-api (`crates/octos-agent/src/workspace_policy.rs:336`)
- `audio_non_silent`: `glob` (default `""`), `min_ratio` (default `0.3`), `source` (default glob mode), `extension` (default `null`): non-silent audio ratio (`crates/octos-agent/src/workspace_policy.rs:344`)
- `per_file_non_silent`: per-file non-silent validation over whole files, with an `require_at_least` count (`crates/octos-agent/src/workspace_policy.rs:368` vicinity)
- magic-byte assertion `MagicByteKind`: `mp3`/`wav`/`png`/`jpeg`/`pdf`/`mp4`/`webm`/`pptx` (`crates/octos-agent/src/workspace_policy.rs:469`)

Runtime constants: default timeout 30s for command kinds (`crates/octos-agent/src/validators.rs:55` `DEFAULT_COMMAND_TIMEOUT_MS`), default 5s for HTTP probes (`crates/octos-agent/src/validators.rs:60` `DEFAULT_HTTP_PROBE_TIMEOUT_MS`), evidence files under `<workspace_root>/.octos/validator-evidence/` (`crates/octos-agent/src/validators.rs:53`), each evidence item ≤512KB (`crates/octos-agent/src/validators.rs:62` `MAX_EVIDENCE_BYTES`).

## C.12 Profile system in brief

The `config.llm` of a profile file `~/.octos/profiles/<id>.json` is a first-class structured LLM selection contract, **not** the flat `provider`/`model` keys of the top-level `config.json`. Three layers:

**`config.llm` (`crates/octos-cli/src/profiles.rs:814` `LlmProfileConfig`)**

| Field | Type | Default | Purpose |
|------|------|------|------|
| `primary` | LlmModelSelectionConfig? | `null` | primary model selection |
| `fallbacks` | array | `[]` | fallback model chain |

**`config.llm.primary` / each fallback (`crates/octos-cli/src/profiles.rs:824` `LlmModelSelectionConfig`, `#[serde(deny_unknown_fields)]`)**

| Field | Type | Default | Purpose |
|------|------|------|------|
| `family_id` | string? | `null` | model family (e.g. `moonshot` / `deepseek`) |
| `model_id` | string? | `null` | concrete model ID (e.g. `kimi-k2.5`) |
| `route` | LlmRouteConfig? | `null` | provider route for this model |
| `model_hints` | object? | `null` | behavior hints for custom/proxied models |
| `cost_per_m` | f64? | `null` | output price per million tokens (for routing) |
| `strong` | bool? | `null` | whether it is reliable for large tool counts |
| `temperature` | f32? | `null` | typed sampling temperature (#2166, AppUI validates 0.0..=2.0) |
| `top_p` | f32? | `null` | nucleus sampling (#2166, validates 0.0..=1.0) |
| `reasoning_effort` | enum? | `null` | default reasoning effort for thinking models (#2166) |
| `context_window` | u32? | `null` | context window override (#2135/#2142, beats probing and catalog) |

**`config.llm.primary.route` (`crates/octos-cli/src/profiles.rs:881` `LlmRouteConfig`)**

| Field | Type | Default | Purpose |
|------|------|------|------|
| `route_id` | string? | `null` | stable route ID in the catalog (e.g. `official` / `wisemodel`) |
| `label` | string? | `null` | human-readable route label |
| `base_url` | string? | `null` | endpoint for this route |
| `api_key_env` | string? | `null` | key environment variable for this route |
| `api_type` | string? | `null` | protocol override |

**Three-tier inheritance (`crates/octos-cli/src/profiles.rs:2403` `resolve_effective_profile`)**: when a child profile carries `parent_id`, the parent's LLM contract is inherited as a whole, overriding (`ec.llm = pc.llm`), while structural sections such as review/search/deep_crawl/apps/email/tool_policy are inherited only when the child's are empty; with no parent, the profile returns unchanged. This is the profile-side mechanism of the goal three tiers (operator default → queue → worker override); the full three-tier semantics are in Chapter 15.

A minimal usable profile JSON example (keys appear only as environment variable names, no key values):

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

## C.13 A complete `config.json` example (JSONC comments)

```jsonc
{
  // migration version, currently 1
  "version": 1,
  // primary LLM (flat keys; for serve multi-tenancy use the profile's config.llm)
  "provider": "anthropic",
  "model": "claude-sonnet-4",
  "api_key_env": "ANTHROPIC_API_KEY",
  "env_vars": {},
  "context_window": 200000,          // #2142 overrides catalog/probing
  // failover chain
  "fallback_models": [
    { "provider": "openai", "model": "gpt-4o", "strong": true, "cost_per_m": 2.5 }
  ],
  // sessions and tools
  "max_iterations": 50,
  "format_after_edit": true,         // #1774 auto-format after edits
  "context_filter": [],
  "tool_policy": { "deny": [], "allow": [] },
  "sandbox": {
    "enabled": true,
    "mode": "auto",
    "allow_network": false,
    "workspace_write": true
  },
  "snapshots": { "enabled": false, "keep_last": 20 },
  // MCP server (see C.9; protocol details in Chapter 9)
  "mcp_servers": [
    {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"],
      "env": {},
      "concurrency_class": "safe"
    }
  ],
  // sub-agent lanes (see C.10; goal_verifier is a reserved key)
  "sub_providers": [
    { "key": "cheap", "provider": "openai", "model": "gpt-4o-mini", "api_key_env": "OPENAI_API_KEY" }
  ],
  // lifecycle hooks (C.7)
  "hooks": [
    { "event": "after_tool_call", "command": ["cargo", "check"], "timeout_ms": 5000, "tool_filter": ["edit_file"], "path_filter": [] }
  ],
  // gateway (C.3)
  "gateway": {
    "channels": [{ "type": "cli", "allowed_senders": [], "settings": {} }],
    "max_history": 50,
    "queue_mode": "collect",
    "llm_timeout_secs": 120
  },
  // adaptive routing (C.8)
  "adaptive_routing": { "enabled": false, "mode": "off" },
  // memory and embedding (C.6)
  "memory": { "max_inject_tokens": 4000, "refresh": { "enabled": true } },
  "embedding": { "provider": "openai", "model": "text-embedding-3-small", "api_key_env": "OPENAI_API_KEY" },
  // operations (C.8)
  "mode": "local",
  "allow_admin_shell": false,
  "appui": { "allowed_origins": [], "sessions_in_cwd": true },
  "plugins": { "require_signed": false },
  "cli": { "serve": { "port": 50080 } }
}
```

## C.14 Version note

The data baseline of this appendix is octos main `9c157101` (docs(guide): document mcp_servers stdio fields, env sanitization, timeouts, #2211/#2212). Main changes from earlier baselines:

- **typed LLM schema (`3a567a4c` / #2166)**: `LlmModelSelectionConfig` gained `temperature` / `top_p` / `reasoning_effort` / `context_window` (#2142, split from #2127); the top-level `Config` mirrors them as `model_temperature` / `model_top_p` / `model_reasoning_effort` (`crates/octos-cli/src/config.rs:56-65`), forming an explicit precedence chain with `gateway.llm_temperature` / `gateway.llm_sampling_params` (#2172).
- **`mcp_servers`**: profile-level `[[mcp_servers]]` registers no tools before OLP #29 S2b (comment at `crates/octos-cli/src/profiles.rs:198`); stdio fields, env sanitization, and timeouts documented in #2211/#2212.
- **`sub_providers` reserved key `goal_verifier`** (#1935): when absent, goal completion verification falls back to the scoring session's own provider (old behavior).
- **hooks schema**: the current shape is `hooks[]` + `event` + `command` (argv) + `timeout_ms` (default 5000) + `tool_filter: string[]`, plus the newer `path_filter` and `requires_bin`.
- **queue_mode**: `steer` renamed to `latest` (`crates/octos-cli/src/config.rs:1507-1512`, serde alias kept for compatibility).
- **`snapshots` (#1768), `approval_policy`, `appui.sessions_in_cwd`, `plugins.require_signed`, and the `cli` section** are later additions; `sandbox.write_allow_globs` (#1976) and `tool_policy.bash_file_writes` (#28b) are recent tightenings.

Numbers and field tables from older versions of this appendix are obsolete; this appendix is authoritative.
