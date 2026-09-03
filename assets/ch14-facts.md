# 第 14 章事实表 — 运行模式与配置体系(octos-book v2,原 Ch13 重写)

- **源码基准 commit**: `9c157101`(main,完整 hash `9c1571016e5ea86955b4b3486c04f0359dfff339`,2026-09-02,只读实测)
- **统计日期**: 2026-09-03
- 源码仓库: `/Users/zhangalex/Work/Projects/FW/octos`(只读);octoscode 另测 `/Users/zhangalex/Work/Projects/FW/octoscode`
- 行数命令统一为 `wc -l <path>`(以 `crates/octos-cli` 为 cwd);符号行号统一 `grep -n '<pat>' <file>`
- 交付前抽查: `octos --help`、`octos serve --help`、REST 端点计数均复跑 ≥2 次,结果一致

---

## 1. 子命令清单与模式选择逻辑

`octos --help` 实测 29 行命令(含内置 `help`),27 个用户子命令,与 spec「事实边界」逐字一致:
`account acp admin auth channels chat config cron doctor docs init inbox mcp memory profile mcp-serve serve skills status steer update gateway goal ledger clean completions office peer`
(命令: `octos --help | sed -n '/^Commands:/,/^$/p' | grep -oE '^  [a-z][a-z-]*'`)

模式选择逻辑: **`crates/octos-cli/src/commands/mod.rs`**(468 行)— `pub enum Command`:114;`Executable::execute()` 的 `match` 分派:381(`Self::Chat(cmd) => cmd.execute()` 等,`Self::Serve` 带 `#[cfg(feature = "api")]`:398-399)。
顶层入口 `main.rs`(268 行,首行 `//! octos CLI entry point.`):`fn main()`:61,解析后先经 `octos_cli::config_layer::apply` 合并 `cli.<cmd>` 分层默认值(main.rs:84-86),再 `args.command.execute()`(main.rs:113)。

## 2. 五种运行面入口文件、行数、首行文档、关键符号

| 运行面 | 入口文件 | 行数 | 首行 `//!` 文档 | 关键符号(行号) |
|---|---|---|---|---|
| chat(单机) | `commands/chat.rs` | 4,143 | `//! Chat command: interactive multi-turn conversation with an agent.` | `pub struct ChatCommand`:37;`fn execute`:1043;`async fn run_chat_peer`:828 |
| gateway(多频道常驻) | `commands/gateway/mod.rs`(目录共 7,595) | 908 | `//! Gateway command: run as a persistent messaging daemon.` | `pub struct GatewayCommand`:45;`fn execute`:159;`async fn run_async`:178;`Gateway::init`:226;`pub(super) async fn run`(gateway_runtime.rs):1789 |
| serve(HTTP/WS 控制面 + `--stdio`) | `commands/serve.rs` | 2,849 | `//! Serve command: start the REST API server.` | `pub struct ServeCommand`:320;`--port` 默认 **50080**:324;`pub stdio: bool`:334;`bind_http_listener`:464;`fn execute`:539;`async fn run_async`:549;**stdio 分支**:1541(`stdio_connection` 后 return);`build_router(state)`:1778 |
| mcp-serve(协议服务面) | `commands/mcp_serve.rs` | 1,138 | `//! M7.2 — octos mcp-serve subcommand.` | `pub enum McpTransport`:72(Stdio 默认/Http);`pub struct McpServeCommand`:79;`--bind` 默认 `127.0.0.1:4033`;`fn execute`:103;`async fn run_session`:485 |
| acp(协议服务面,Zed 等) | `commands/acp.rs` | 3,024 | `//! octos acp`: run octos as an [Agent Client Protocol][acp] agent over stdin/stdout` | `pub struct AcpCommand`:100;`fn execute`:160;`async fn run_async`:1163 |

入口文件合计: 4,143+7,595+2,849+1,138+3,024+268+468 = **19,485 行**。(命令: `wc -l commands/{chat.rs,serve.rs,mcp_serve.rs,acp.rs,mod.rs} main.rs commands/gateway/*.rs`)

### 2.1 serve `--stdio` 挂载面
- `serve.rs:1541`: `if self.stdio { crate::api::ui_protocol_transport::stdio_connection(state).await?; …; return Ok(()); }` — stdio 模式不绑 HTTP(`bind_http_listener` serve.rs:464-471 返回 `None` listener)
- octoscode 默认命令: `/Users/zhangalex/Work/Projects/FW/octoscode/src/cli.rs:118` `pub const DEFAULT_STDIO_COMMAND: &str = "octos serve --stdio --solo";`(命令: `grep -n DEFAULT_STDIO_COMMAND octoscode/src/cli.rs`)
- 单写锁: `DATA_DIR_LOCKED_MARKER = "OCTOS_DATA_DIR_LOCKED"`(serve.rs:487 附近,`acquire_serve_data_dir_lock` 用 fs2 flock)

### 2.2 serve 门禁(`octos serve --help` 实测,2026-09-02 main)
- `--solo`: 单人本地免密登录(`POST /api/auth/solo*`),仅 loopback + Local-mode,反向代理头出现时永不生效;env `OCTOS_SOLO_LOGIN=1`
- `--danger-full-access`: 默认 FULL-ACCESS 权限档,**必须绑 `--solo`**;env `OCTOS_DANGER_FULL_ACCESS=1`
- `--no-network`: 回退默认网络拒绝;env `OCTOS_NO_NETWORK=1`
- `--swarm-backend <stdio|http|cli>` + `--swarm-backend-cmd/-args/-url`(M7.6;未设时 `/api/swarm/*` 返回 503)
- (命令: `octos serve --help`;`grep -c 'solo\|danger\|no-network\|swarm-backend'` 命中 13 行)

### 2.3 Serve 控制面汇聚与 coding/autonomy capability
- 汇聚点(serve.rs `run_async`): `ProfileStore::open`:673/818、`EventBroadcaster::new(256)`:750、`SessionManager::open`:764、`init_metrics()`:775、`SwarmState` 构建:1316 起(`DispatchPolicy::from_agent_gates(tool_policy, true)`:1969,tool_policy 来自 `config.tool_policy`,#713 注释:1322)、`build_router`:1778
- REST 端点数: **67**(spec 口径命令 `grep -rhoE '\.route\("[^"]+"' crates/octos-cli/src/api/*.rs | sort -u | wc -l`,两次复跑均 67;api/ 共 42 个 .rs 文件)
- coding capability(UI Protocol `SessionOpened.capabilities`,均经 `has_ui_feature` 投影,`api/ui_protocol_transport.rs`): `coding.tool_contract.v1`(常量在 `api/coding_tool_contract.rs:12`)、`coding.autonomy.v1`:2037、`coding.agent_control.v1`:2042、`coding.goal_runtime.v1`:2047、`coding.loop_runtime.v1`:2052、(另有 monitor_runtime_v1:2057)
- 工具状态常量(`api/coding_tool_contract.rs:19-28`): `available` / `aliased` / `deferred` / `disabled_by_policy` / `missing` / `unimplemented`;contract id `codex-compatible-coding-v1`:13

### 2.4 MCP serve session-level 边界
- 只暴露 `run_octos_session`: `octos-agent/src/mcp_server.rs:66` `pub const RUN_OCTOS_SESSION_TOOL`;`McpServer`:169;`handle_request`:201;HTTP: `streamable_http_service`:268(文件 1,044 行)
- stdio = parent-trust auth;HTTP transport 必须 `OCTOS_MCP_SERVER_TOKEN`(mcp_serve.rs:81、185-186 缺 token 直接报错)

## 3. 配置体系规模

| 文件 | 行数 | 首行文档 | 关键符号(行号) |
|---|---|---|---|
| `config.rs` | 3,790 | `//! Configuration file support for octos CLI.` | `pub struct Config`:26;`mcp_servers: Vec<McpServerConfig>`:110;`sub_providers: Vec<SubProviderConfig>`:184;`SubProviderConfig`:618;`load_with_context`:1740;`load_with_context_path`:1749;`load_resolved`:1770 |
| `profiles.rs` | 7,003 | `//! User profile management for multi-user deployments.` | `ProfileConfig`:181;`ProfileConfigPatch`:741;**`LlmProfileConfig`:814;`LlmModelSelectionConfig`:824;`LlmRouteConfig`:881**;`env_vars` 经 keychain 解析(`profile_factory.rs:108/149`) |
| `config_watcher.rs` | 608 | `//! Config file watcher with hot-reload support. Polls every 5 seconds using SHA-256 hash comparison.` | `pub enum ConfigChange`:17(**HotReload{system_prompt, max_history}** / RestartRequired(Vec\<String\>):22-25);`ConfigWatcher`:28;`new`:44;`with_profile_defaults`:67;`spawn`:87;`diff_and_emit`:241 |
| `config_layer.rs` | 543 | `//! Layered startup config for serve/gateway/chat.` | `pub const LAYERED_COMMANDS = ["serve","gateway","chat"]`:40;`pub fn apply`:48 |

配置系统合计 **11,944 行**。优先级链(config.rs `load_resolved` 注释): ① 项目本地 `cwd/.octos/config.json`(仅 default context)→ ② `<config_home>/config.json` → ③ legacy `~/.octos/config.json`;显式 `--config`/tenant 上下文不读项目本地。分层默认值: `显式 CLI flag > env var > config.json cli.<cmd> > built-in default`(config_layer.rs:5-8)。3a567a4c typed schema: 静默丢字段改为拒绝(config.rs:273 附近注释)。Gateway 子账号继承结构化 profile sections + `env_vars` base(profile_factory.rs)。

## 4. Feature Flags(`crates/octos-cli/Cargo.toml:142` 起)
`[features] default = []`;`api`(154,axum/rustls/prometheus 等,`octos-bus/api`+`matrix`)、`admin-bot`、`telegram/discord/dingtalk/slack/whatsapp/email/feishu/twilio/wecom/line/matrix/wecom-bot`(octos-bus 通道门)、`embed-llama/-metal/-cuda`(147-149)。`Command::Serve` 与 main.rs log_dir 均以 `#[cfg(feature = "api")]` 门控(mod.rs:398、main.rs:71)。完整列表见附录 D。

## 5. 侧栏素材: 热加载 vs 全重启边界
- 可热加载: 仅 `system_prompt` / `max_history`(ConfigChange::HotReload);watcher 每 5s SHA-256 比对
- 需重启: `base_url`/`api_key_env`/hooks 等落入 `RestartRequired(Vec<String>)`(仅告警);profile 的 policy 翻转有防误报回归注释(config_watcher.rs:136-150)
- provider/model 文件变更不被 watcher 自动应用 — 显式运行时切换路径;`--danger-full-access` 绑 `--solo` 的原因: 两者都是 local-single-user keystone,避免远程暴露免沙箱档

## 6. 复现命令汇总
```bash
cd /Users/zhangalex/Work/Projects/FW/octos && git log -1 --format='%H %cd' --date=short
octos --help                                   # 27 子命令(+help)
octos serve --help                             # 门禁与默认端口 50080
wc -l crates/octos-cli/src/commands/{chat,serve,mcp_serve,acp}.rs crates/octos-cli/src/commands/gateway/*.rs
grep -n 'pub struct ServeCommand\|pub stdio\|default_value = "50080"' crates/octos-cli/src/commands/serve.rs
grep -n 'stdio' crates/octos-cli/src/commands/serve.rs | sed -n '1,15p'
grep -rhoE '\.route\("[^"]+"' crates/octos-cli/src/api/*.rs | sort -u | wc -l   # 67
grep -n 'pub struct LlmProfileConfig\|pub struct LlmModelSelectionConfig\|pub struct LlmRouteConfig' crates/octos-cli/src/profiles.rs
grep -n 'enum ConfigChange\|fn spawn\|diff_and_emit' crates/octos-cli/src/config_watcher.rs
grep -n 'DEFAULT_STDIO_COMMAND' ../octoscode/src/cli.rs
```
