# Ch15 事实表 — 生产化:认证、诊断、监控与多租户

- 分析基线: octos `main @ 9c157101` (2026-09-03 复核;commit 时间 2026-09-02 19:37 +0800)
- 源码仓库(只读): `/Users/zhangalex/Work/Projects/FW/octos`
- 范围: `crates/octos-store/`、`crates/octos-services/`、`crates/octos-diagnostics/`、tenancy 相关
- 每项附生成命令;交付前已抽查复跑(见文末 §6)

生成命令(本文基准):
```bash
cd /Users/zhangalex/Work/Projects/FW/octos && git log -1 --format='%h %H %ci'   # 9c157101 9c1571016e5e... 2026-09-02 19:37:40 +0800
```

## 1. octos-store — 9 文件 / 2,664 行

生成命令:
```bash
cd /Users/zhangalex/Work/Projects/FW/octos && wc -l crates/octos-store/src/*.rs
```

| 文件 | 行数 | 首行文档(//!) | 关键 pub 符号(行号) |
|---|---|---|---|
| `lib.rs` | 18 | "Self-contained persistence / state stores extracted from `octos-cli`" — 从 octos-cli 抽出的叶子持久化模块 | `pub mod` ×8: admin_audit_store(11) admin_token_store(12) approvals_audit(13) login_allowlist(14) setup_state_store(15) smtp_secret_store(16) usage_ledger(17) user_store(18) |
| `admin_audit_store.rs` | 270 | (文件首部无模块文档;使用 redb 存储 admin 操作审计) | `ADMIN_AUDIT_SCHEMA_VERSION`(10) `AdminAuditEntry`(17) `AdminAuditRecordInput`(31) `AdminAuditQuery`(40) `AdminAuditPage`(102) `AdminAuditStore`(109) `parse_audit_datetime`(204) |
| `admin_token_store.rs` | 184 | "Hashed admin auth token stored at `{data_dir}/admin_token.json`. Replaces the static config/env bootstrap token once rotated." | `AdminTokenRecord`(14) `AdminTokenStore`(56) |
| `approvals_audit.rs` | 414 | "Append-only JSON-Lines audit log for approval decisions." — 合规/取证记录,每决策一行 | `DEFAULT_ROTATE_BYTES`(23) `DEFAULT_RETENTION_DAYS`(26) `ApprovalsAuditConfig`(39) `AuditClock`(105) `SystemAuditClock`(110) `ApprovalsAuditLog`(119) `read_audit_lines`(289) `log_decision_tracing`(300) |
| `login_allowlist.rs` | 258 | (首部无模块文档;带锁重试的登录白名单存储,`ALLOWLIST_LOCK_MAX_ATTEMPTS: usize = 40`) | `AllowedLogin`(17) `LoginAllowlistStore`(28) `normalize_email`(223) |
| `setup_state_store.rs` | 151 | "Persistent setup-wizard state stored at `{data_dir}/setup_state.json`" — 跨会话恢复首启向导 | `SetupState`(15) `SetupStateStore`(24) |
| `smtp_secret_store.rs` | 133 | "SMTP password stored at `{data_dir}/smtp_secret.json`. Replaces the `SMTP_PASSWORD` environment variable" | `SmtpSecretStore`(17) |
| `usage_ledger.rs` | 901 | "Durable session usage ledger for profile-level token and cost analytics" — 每次 LLM run 一行,redb 持久化 | `USAGE_LEDGER_FILE`(22,="usage_ledger.redb") `USAGE_EVENT_SCHEMA_VERSION`(23) `UsageCostSource`(34) `UsageEvent`(42) `UsageTotals`(164) `UsageRollup`(211) `UsageAnalytics`(217) `UsageQuery`(305) `UsageBackfillReport`(317) `PersistentUsageLedger`(323) |
| `user_store.rs` | 335 | "User management for multi-user dashboard deployments" — 每用户一个 JSON 文件,user id 1:1 映射 profile id | `UserRole`(15) `User`(22) `UserStore`(40) `email_to_user_id`(154) |

合计(首部 12 行内含 `//!` 模块文档的文件: lib/admin_token/approvals_audit/setup_state/smtp_secret/usage_ledger/user_store 共 7 个;admin_audit_store 与 login_allowlist 首部无 `//!`):
```bash
cd /Users/zhangalex/Work/Projects/FW/octos && wc -l crates/octos-store/src/*.rs | tail -1   # 2664 total
grep -n '^pub struct\|^pub enum\|^pub fn\|^pub trait\|^pub const' crates/octos-store/src/*.rs   # 顶层 pub 符号 38 个;含方法级共 95
```

## 2. octos-services — 8 文件 / 3,223 行

生成命令:
```bash
cd /Users/zhangalex/Work/Projects/FW/octos && wc -l crates/octos-services/src/*.rs
```

| 文件 | 行数 | 首行文档(//!) | 关键 pub 符号(行号) |
|---|---|---|---|
| `lib.rs` | 15 | "Self-contained support services extracted from `octos-cli`" — 与 octos-store 同源的叶子服务模块 | `pub mod` ×7: cli_agent_adapter(9) compaction(10) config_context(11) persona_service(12) soul_service(13) tenant(14) updater(15) |
| `cli_agent_adapter.rs` | 587 | "Process boundary for a future CLI-agent adapter" — 未接入 AppUI 的子进程边界 | `DEFAULT_TIMEOUT`(24,60s) `MAX_TRANSCRIPT_BYTES_PER_STREAM`(27,1MB) `CliAgentCommandConfig`(31) `CliAgentTranscript`(106) `CliAgentArtifact`(115) `CliAgentTermination`(123) `CliAgentRunResult`(132) `CliAgentProcess`(145) `run_cli_agent_command`(265) |
| `compaction.rs` | 320 | "Session compaction: summarize old messages to keep sessions manageable." | `CompactionConfig`(17) `maybe_compact`(37) `maybe_compact_with_config`(46) `maybe_compact_handle`(191) |
| `config_context.rs` | 698 | "Canonical config/auth/data path resolver — the single source of truth" — 所有配置/凭据/状态路径必须经 `resolve_config_context` | `ConfigContext`(36) `resolve_config_context`(151) `atomic_copy_into`(211) `run_migrations`(326) |
| `persona_service.rs` | 479 | "Persona service: periodically generates a communication style guide via LLM" | `DEFAULT_INTERVAL_SECS`(21,6h) `DEFAULT_STATUS_WORDS`(53) `DEFAULT_STATUS_WORDS_ZH`(73) `PersonaService`(97) |
| `soul_service.rs` | 139 | "Per-user soul/personality storage." | `read_soul`(24) `write_soul`(33) `remove_soul`(40) `read_soul_for_session`(50) `write_soul_for_session`(55) `remove_soul_for_session`(64) |
| `tenant.rs` | 512 | "Tunnel tenant management for self-hosted Mac Mini deployments." | `SSH_PORT_START`(14,6001) `SSH_PORT_END`(15,6999) `TenantConfig`(23) `TenantStatus`(61) `TenantStore`(82) `render_frpc_config`(255) |
| `updater.rs` | 473 | "Self-update module: download, verify, backup, replace, rollback." | `ReleaseInfo`(17) `UpdateResult`(27) `Updater`(33) `check_latest`(76) `check_version`(92) `update`(140) `current_version`(343) |

```bash
cd /Users/zhangalex/Work/Projects/FW/octos && wc -l crates/octos-services/src/*.rs | tail -1   # 3223 total
grep -n '^pub struct\|^pub enum\|^pub fn\|^pub trait\|^pub const' crates/octos-services/src/*.rs   # 顶层 pub 符号 29 个;含方法级共 67
```

Cargo 依赖(两 crate 均只依赖 octos-core;services 额外依赖 octos-llm、octos-bus):
```bash
cd /Users/zhangalex/Work/Projects/FW/octos && grep octos crates/octos-store/Cargo.toml crates/octos-services/Cargo.toml | grep workspace
```

## 3. octos-diagnostics — 8 文件 / 2,243 行(spec「事实边界」要求一并列入)

生成命令:
```bash
cd /Users/zhangalex/Work/Projects/FW/octos && wc -l crates/octos-diagnostics/src/*.rs
```

来源 commit:
```bash
cd /Users/zhangalex/Work/Projects/FW/octos && git log --format='%h %s' -1 7f81fa5e   # 7f81fa5e feat(diagnostics): octos-diagnostics crate + octos doctor (Stage 1) (#1443)
git log --format='%h %s' -1 1801a9e9   # 1801a9e9 feat(diagnostics): GitHub client + update --check + doctor Network (Stage 2) (#1445)
```

| 文件 | 行数 | 首行文档(//!) |
|---|---|---|
| `lib.rs` | 56 | "`octos-diagnostics` — shared, **product-agnostic** diagnostics + update";再导出 checks/github/install_method/locate/report/spec/update |
| `checks.rs` | 400 | "Generic, product-agnostic local checks: terminal environment, config/data ..." |
| `github.rs` | 321 | "Minimal **blocking** GitHub Releases client for `update --check` ..." |
| `install_method.rs` | 505 | "Install-method detection, product-agnostic." |
| `locate.rs` | 278 | "PATH resolution + shadow detection, product-agnostic." |
| `report.rs` | 312 | "The product-agnostic diagnostic report model: [`CheckStatus`], [`Check`], ..." |
| `spec.rs` | 173 | "[`ProductSpec`] — the product-agnostic seam." |
| `update.rs` | 198 | "Semver parse/compare helpers + the pure update *planner*." (`SemVer`/`UpdatePlan`/`is_newer`/`parse_version`/`plan`) |

## 4. 多租户 / tenancy 源码定位

命中统计(`grep -rn` 大小写不敏感 vs 全词):
```bash
cd /Users/zhangalex/Work/Projects/FW/octos
grep -rn 'tenan' crates/ --include='*.rs' | wc -l        # 2852
grep -rni 'tenant' crates/ --include='*.rs' | wc -l      # 2919
grep -rniw 'tenant' crates/ --include='*.rs' | wc -l     # 2261(全词)
grep -rniw 'tenant' crates/ --include='*.rs' | cut -d: -f1 | sort | uniq -c | sort -rn | head -8
```

全词 `tenant` 命中 Top 文件(次数):

| 文件 | 命中 | 角色 |
|---|---|---|
| `octos-cli/src/autonomy/agent_orchestrator.rs` | 921 | agent 编排内的 tenant 维度 |
| `octos-cli/src/api/ui_protocol_tests.rs` | 212 | UI Protocol 测试 |
| `octos-cli/src/api/admin.rs` | 138 | 管理面 API |
| `octos-cli/src/api/auth_handlers.rs` | 130 | 认证处理 |
| `octos-cli/src/api/ui_protocol_transport.rs` | 102 | UI Protocol 传输层 |
| `octos-cli/src/api/handlers.rs` | 96 | API handlers |
| `octos-cli/tests/preview_auth.rs` | 73 | 测试 |
| `octos-services/src/tenant.rs` | 65 | 租户隧道存储/配置渲染 |

多租户分层机制(章内事实,均已定位):
- **租户 = profile 目录隔离**: `crates/octos-core/src/session_scope.rs:46-49` — "`octos serve` + AppUI web client" 模式下多租户共享一个 octos 进程,每租户 profile 目录 `<config_dir>/profiles/<tenant_id>/`;`:52` 跨租户访问无条件拒绝;`:61` solo 模式无租户边界。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && sed -n '46,68p' crates/octos-core/src/session_scope.rs
  ```
- **子账号继承**: `crates/octos-cli/src/profiles.rs:2403` `resolve_effective_profile` — 子账号经 `parent_id` 继承父 profile 的 `config.llm`(直接覆盖 `ec.llm = pc.llm.clone()`),`review/search/deep_crawl/apps/email/tool_policy` 为 None 才继承;`env_vars` 以父为 base、子覆盖合并(`profiles.rs:2444-2448`)。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && sed -n '2403,2450p' crates/octos-cli/src/profiles.rs
  ```
- **子账号创建与上限**: `profiles.rs:2048` `create_sub_account`(父存在校验、父不可为子账号、`MAX_SUB_ACCOUNTS_PER_PARENT` 上限、id 形如 `{parent_id}--{sub}`);子账号 `config.llm = None`(`profiles.rs:2076-2078`),运行时才解析继承。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && sed -n '2044,2100p' crates/octos-cli/src/profiles.rs
  ```
- **子账号不继承父账号安装的 customer skills**: skills 选择走独立的 local-skills layer(父层缺省为"inherit 默认层"),不随 `resolve_effective_profile` 的 config 继承链传递(`profiles.rs:360-407` 的 skills layer 语义)。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && sed -n '355,410p' crates/octos-cli/src/profiles.rs
  ```
- **standalone Gateway 同进程 actor 隔离**: `crates/octos-cli/src/session_actor.rs:1-3` — 每 session 一个 tokio task 的 session actor,替换 spawn-per-message 模型;`crates/octos-cli/src/commands/gateway/profile_factory.rs:1-4` — gateway 按 profile 构建 dedicated `ActorFactory`(自带 LLM stack、tool registry、skills、system prompt)。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && sed -n '1,12p' crates/octos-cli/src/session_actor.rs && sed -n '1,8p' crates/octos-cli/src/commands/gateway/profile_factory.rs
  ```
- **process-manager per-profile gateway 子进程** 与 **资源边界需系统级限额补足**: 章节论述点;源码侧对应 `profile_factory.rs` 的 per-profile 构建路径与 tenant 资源限额面(API 侧),写章时按此措辞。
- **frpc 隧道部署路径(新)**: `crates/octos-services/src/tenant.rs:255` `render_frpc_config`;配套 `TenantStore` 查找族 `find_by_tunnel_token`(197)/`find_by_subdomain`(203)/`find_by_ssh_port`(209)/`find_by_owner`(219)、`next_ssh_port`(185,6001-6999 段);tenant id 校验拒绝大写/路径穿越/超 64 字符(`validate_tenant_id`:233,测试 :278-335)。admin_setup 侧 `mode: local | tenant | cloud`(`crates/octos-cli/src/api/admin_setup.rs:668`)、`<data_dir>/frpc.toml` 存在即本机为 tenant(`admin_setup.rs:748`)。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && sed -n '255,276p' crates/octos-services/src/tenant.rs && grep -n 'mode must be one of\|frpc.toml' crates/octos-cli/src/api/admin_setup.rs
  ```

## 5. 生产化运维面

- **Prometheus 指标**: `crates/octos-cli/src/api/metrics.rs`(1,554 行) — 首行文档 "Prometheus metrics endpoint and helpers";`init_metrics()`(:18)装 `PrometheusBuilder` recorder;`GET /metrics`(:29 `metrics_handler`)渲染 text exposition;关键指标: `octos_tool_calls_total`{tool,success}(:931)、`octos_tool_call_duration_seconds`{tool}(:932)、`octos_llm_tokens_total`{direction}(:937-938)、`octos_routing_decision_total`{tier,lane}(:949)。路由挂载 `crates/octos-cli/src/api/router.rs:878-880`(`/metrics`,has_auth 时加鉴权层);admin/system 指标 `router.rs:688` `GET /api/admin/system/metrics`(handler `admin.rs:1909 system_metrics`)、per-profile `router.rs:472/575`。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && sed -n '1,28p' crates/octos-cli/src/api/metrics.rs && grep -n 'octos_' crates/octos-cli/src/api/metrics.rs | head && sed -n '876,882p' crates/octos-cli/src/api/router.rs
  ```
- **harness typed SSE**: `crates/octos-cli/src/api/events_harness.rs`(183 行) — `HarnessEventsQuery.kinds`(:34-42,逗号分隔,snake_case/CamelCase/kebab-case 归一化)、`events_harness` handler(:53)、`parse_kinds`(:82,空/全分隔符→None=不过滤)。顶层 `kind` 与 nested `payload.kind` 两类帧(spec 完成条件)。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && grep -n 'pub struct\|pub async fn\|fn parse_kinds' crates/octos-cli/src/api/events_harness.rs
  ```
- **UI Protocol capability negotiation**: `crates/octos-core/src/ui_protocol.rs`(7,221 行) — feature 常量 `harness.task_control.v1`(:113);`first_server_slice`(:1630,无 feature header 的 discovery 兼容基线);server 能力 payload(:1658-1695,未知 feature 丢弃;`task/list`/`task/cancel`/`task/restart_from_node` 仅协商到 `harness.task_control.v1` 才进 `supported_methods`)。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && grep -n 'first_server_slice\|UI_PROTOCOL_FEATURE_HARNESS_TASK_CONTROL_V1' crates/octos-core/src/ui_protocol.rs | head
  ```
- **告警发送器(monitor)**: `crates/octos-cli/src/monitor.rs`(518 行) — `Monitor`(120) `run()`(164) 循环 + `add_sender`(159);`TelegramAlertSender`(357) `FeishuAlertSender`(390)。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && grep -n 'pub struct\|pub async fn\|pub fn' crates/octos-cli/src/monitor.rs | head -12
  ```
- **自更新(应用层)**: `crates/octos-services/src/updater.rs` — `check_latest`(:76)/`check_version`(:92)/`update`(:140,download→verify→backup→replace→rollback)/`current_version`(:343)。
- **doctor 诊断两阶段**: `crates/octos-diagnostics/` Stage 1 `7f81fa5e`(crate + `octos doctor`),Stage 2 `1801a9e9`(GitHub client + `update --check` + Network check)。
- **凭据存储位置**(spec 完成条件): `~/.octos/auth.json` mode 0600、常量时间 bearer token 比较 — 定位于 `crates/octos-cli/src/auth/`(章 15.1 认证三流,非本表范围展开)。
  ```bash
  cd /Users/zhangalex/Work/Projects/FW/octos && ls crates/octos-cli/src/auth/
  ```

## 6. 抽查复跑记录(2026-09-03)

- `git log -1`: `9c157101 9c1571016e5ea86955b4b3486c04f0359dfff339 2026-09-02 19:37:40 +0800` ✅
- `wc -l crates/octos-store/src/*.rs | tail -1` → `2664 total` ✅(与 spec「2,664 行」一致)
- `wc -l crates/octos-services/src/*.rs | tail -1` → `3223 total` ✅(与 spec「3,223 行」一致)
- `sed -n '255p'` tenant.rs → `pub fn render_frpc_config(` ✅(spec 决策「`render_frpc_config` :255」一致)
- `grep -n 'render_frpc_config\|2664\|3223' assets/ch15-facts.md` 自检 ✅
- `git status` 工作区仅新增本文件,未改其他文件,未 commit ✅
