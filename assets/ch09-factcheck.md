# 第 9 章事实核对报告(ch09-factcheck,C1 全覆盖)

- **审查对象**: `chapters/ch09-extension.md`(master 定稿 0e9d79e + c7ce328 镜像)
- **事实基准**: `assets/ch09-refcheck.md`(cb72166)· **源码**: `/Users/zhangalex/Work/Projects/FW/octos` @ `9c157101`(只读实测,git log 首行确认)
- **采集方式**: 逐引用 `sed -n` 落行核对 + `wc -l` 上界 + `git log --all` 提交号回查
- **结论**: **修 2 处 major 后可定稿**(其余全部通过;两处均为单词级修改,不涉结构)

---

## A. 汇总分级

| 级别 | 数量 | 明细 |
|---|---|---|
| ❌ Major | **2** | A-1「近八成」占比错误;A-2 OCTOS_SKILLS_PATH 分隔符写反 |
| ⚠️ Minor | **1** | A-3 正文英文残留 "therefore" |
| ✅ 通过 | — | 引用 58 处全过、数字、代码摘录、机械项、字数(见 B–E) |

### A-1 ❌ Major:「近八成」与自身数字矛盾(§9.1 开头)

正文:"tool.rs 3,219 行…加上对应测试(tool_tests.rs 4,406 行)就占了近八成"。
实测:`(3219+4406)/14675 = 51.96%`,是**过半**不是八成(八成≈78% 需把 loader.rs 3,965 也算入,但正文没算)。
**改法**:「近八成」→「过半」(或「约五成二」)。

### A-2 ❌ Major:OCTOS_SKILLS_PATH 分隔符写反(§9.1.2)

正文:"追加分号分隔的 `OCTOS_SKILLS_PATH` 环境变量目录"。
源码 `config.rs:1368-1369`:注释 `(colon-separated)`、实现 `extra.split(':')` —— 是**冒号**。
**改法**:「分号」→「冒号」。

### A-3 ⚠️ Minor:英文残留(§9.2 spawn_only 段)

"模型 therefore 不需要学习…" —— "therefore" 为英文插入,建议改「因此」。

---

## B. 检查项 1:引用路径/越界/符号 —— **全过**

- 去重引用 **58 处**(`grep -oE '\.\./octos/crates/...:[0-9-]+' | sort -u`):**路径不存在 0,越界 0**(逐处对文件行数验上界,含多区间 `a-b,c-d` 拆分校验)。
- 逐处符号落行核对(重点新面全部命中):

| 引用 | 区间内实测 |
|---|---|
| `Cargo.toml:41-44` | L41 注释 "MCP over the official rmcp SDK. Client: stdio + streamable-HTTP + OAuth 2.1." + L44 `rmcp = { version = "1.8", ...}` ✓ |
| `config.rs:108-110` | `pub mcp_servers: Vec<octos_agent::McpServerConfig>` ✓ |
| `config.rs:182-184` | `pub sub_providers: Vec<SubProviderConfig>`(#1935 back-compat 注释)✓ |
| `config.rs:616-654` | `SubProviderConfig` 全字段(key/provider/model/api_key_env/base_url/description/default_context_window/max_output_tokens/api_type)✓ |
| `config.rs:1330-1375` | `plugin_dirs_from_project()`:plugins/skills/bundled-app-skills + OCTOS_SKILLS_PATH + legacy HOME 一次性 warn ✓ |
| `runtime/profile.rs:128-190` | `GOAL_VERIFIER_LANE_KEY = "goal_verifier"` + `build_goal_verifier_provider()` ✓ |
| `mcp.rs:452-485` | `connect_stdio()`:`kill_on_drop(true)` + `sanitize_command_env` + 显式 env 再过 denylist(LD_PRELOAD 注释)+ 无界 `read_until` 注释(465-472)✓ |
| `mcp.rs:499-528` / `501-504` | `connect_http()`;L502-503 `if config.oauth → mcp_auth::connect_oauth` ✓ |
| `mcp.rs:53-88` | `McpServerConfig` 字段与 9.3.2 表三分派一致;concurrency_class 未知值落 `Exclusive`(fail-safe)✓ |
| `mcp.rs:1-22` | 模块文档:三 spec 缺口(missing `initialized`/hardcoded version/one-line desync)✓ |
| `mcp.rs:47-49,296-322` | `MAX_SCHEMA_DEPTH=10`、`MAX_SCHEMA_SIZE=65_536`(64KB)、`validate_schema()` ✓ |
| `mcp.rs:374-437` + L43 | `start()` fail-soft;`HANDSHAKE_TIMEOUT=30s` 包 `list_all_tools()` ✓ |
| `mcp.rs:586-612` + L45 | `TOOL_CALL_TIMEOUT=60s`;非文本 content 丢弃注释 ✓ |
| `mcp.rs:349-372` | `PROTECTED_NAMES` 逐项点数 = **20** ✓ |
| `mcp.rs:532-558` | `register_tools()`:transports 先于 tools 移交 registry(#1886 注释、`keep_mcp_service_alive`)✓ |
| `mcp.rs:122-183,211-293` | `SsrfDnsResolver`(每次 resolve 重查、防 rebinding)、`reject_private_url_host`(字面 IP/localhost)、redirect=none、`SsrfOAuthHttpClient` ✓ |
| `mcp_auth.rs:30-95,186` | keyring 键 `"<normalized-url>|<sha256[..16]>"`、`StoredTokens` JSON 序列化、`login()` 交互流程 ✓ |
| `mcp_auth.rs:105-186` / `105-125` / `126-135` | `connect_oauth()`:require_https + 拒字面私网;传输客户端与 OAuth 端点客户端**两份**(`SsrfOAuthHttpClient`)✓ |
| `skills.rs:12-36` | `SkillFilter::{AllExcept,Only}` + "intentionally free of any CLI dependency" ✓ |
| `skills.rs:62-116,118-173` | loader 目录列表、`BUILTIN_SKILLS` 先装、`iter().rev()` + `retain` 去重 ✓ |
| `skills.rs:156-176,176-201` / `203-219` | `load_skill()` 被禁返回 `Ok(None)`;`list_skills` retain 过滤;XML 摘要 `tools="true"` 属性 ✓ |
| `skills.rs:244-294,351-369` | `requires_bins`→`which_exists`、`requires_env`,双双通过才 `available` ✓ |
| `skills.rs:301-320,322-343` | `split_frontmatter()`、`fm_value()`:剥行内注释、`[]`/`""`/`~` 视为缺失 ✓ |
| `skills.rs:590-645` | 测试组:重复键取首个/冒号在值中/空值标记/行内注释 ✓ |
| `plugins/loader.rs:24,654-664` | `MAX_EXECUTABLE_SIZE = 100_000_000`(100MB),读内存前拒绝 ✓ |
| `loader.rs:649-712` | 一次读入内存算 `Sha256` → `load_time_hash` 台账,tool.rs 侧 pre-spawn re-hash gate 封 TOCTOU ✓ |
| `loader.rs:640-646,1189-1193` | 找二进制顺序:manifest 名→目录名→`main`→目录扫描 ✓ |
| `loader.rs:607-626` | `tools.is_empty()` 且 `has_extras()` → extras-only 装载 ✓ |
| `loader.rs:296-316` | layering:manifest id 未过 filter 整包跳过 ✓ |
| `loader.rs:332-339` | `registry.mark_spawn_only(name, msg)` ✓ |
| `plugins/manifest.rs:8-110,387-477` | `id/SkillMcpServer/SkillHookDef/prompts.include/actions/binaries{os-arch}/spawn_only/env(alias env_allowlist)/risk/concurrency_class/make_type` 全部在位 ✓ |
| `manifest.rs:180-198` | `has_extras()` = mcp_servers∨hooks∨prompts.include∨discovery ✓ |
| `manifest.rs:452-455,479-520,569-609` | 工具级 `spawn_only`、`ManifestRiskGate::classify/requires_approval`、并发分类 ✓ |
| `plugins/tool.rs:109-131,85-91,151-163` | `verified_exe_sha256`/`manifest_sha256` 台账;extra_env secret-like 需显式 allowlist;`DEFAULT_TIMEOUT = 600s` ✓ |
| `tool.rs:1229-1307,3117-3130` | `files_to_send` 自动回传、`out` 参数探测文件、结构化 stdout 解析 ✓ |
| `plugins/extras.rs:39-45,449-456` | `spawn_only_tools/spawn_only_messages` 字段 + PR-F 技能卡 fragment ✓ |
| `tools/registry.rs:156-172` | "ARE visible in specs()… intercepted at execute time and converted into a background spawn" —— 与正文「不是隐藏,是自动后台化」完全一致 ✓ |
| `agent/execution.rs:579` 起 | "Spawn a single tool call as a detached tokio::spawn task" ✓ |
| `skills_scope.rs:96-112` | account skills 只解析当前账号 `data_dir/skills`,不从父账号继承 ✓ |
| `gateway_runtime.rs:566-573,646-648` | bootstrap bundled/platform skills;`with_skill_filter()` 接线 ✓ |
| `profile_factory.rs:698-702` | 子 bot 继承同一 filter ✓ |
| `octos-plugin: discovery.rs:47-59 / gating.rs:42,73-78 / manifest.rs:112` | `discover_plugins`、`check_requirements`、darwin/macos 等价别名注释、`pub struct PluginManifest` ✓ |

## C. 检查项 2:数字 —— 除 A-1 外全过

- **rmcp "1.8"** ✓(Cargo.toml:44)
- **plugins/ 8 文件 14,675** ✓(extras 736 + http_discovery 313 + install 282 + loader 3,965 + manifest 1,728 + mod 26 + tool_tests 4,406 + tool 3,219 = 14,675)
- **skills.rs 942 / mcp.rs 707 / mcp_auth.rs 407** ✓(`wc -l`)
- tool.rs 3,219 / tool_tests.rs 4,406 ✓(单文件行数对;占比表述见 A-1)
- 提交号三个全中:`65486dad`(迁 rmcp)、`9b1fc38f`(skill layering v1)、`3934aeb6`(registry 持有传输,PR #1900/issue #1886)✓
- 30s/60s/600s/100MB/深度 10/64KB/20 个保护名 ✓(逐一对 const)

## D. 检查项 3:代码摘录 —— 全过

- 9.2.1 manifest JSON:全字段(`name/version/tools[].{name,description,input_schema,env,risk,concurrency_class}/sha256/timeout_secs/requires_network`)与 `PluginManifest`/`PluginToolDef` 对照在位;`"concurrency_class": "safe"` 合法值 ✓
- 9.5.1 mcp_servers 最小 JSON:`command/args` 与 `url/oauth/scopes` 均为 `McpServerConfig` 实字段 ✓
- 9.5.2 sub_providers 最小 JSON:`key/provider/model/api_key_env` 与 `SubProviderConfig` 一致 ✓

## E. 检查项 4/5:机械项与字数 —— 全过

- 锚点结构 9.1–9.6 + 图 9-1 题注 ✓;版本演化说明在文末且三个提交号与实测一致 ✓
- mermaid 块 = **1** ✓;`——` = **2**(≤2)✓;加粗 = **13**(≤15)✓
- 黑话 9 词(赋能/抓手/闭环/沉淀/颗粒度/底层逻辑/心智/护城河/值得注意)正文**零命中** ✓(master 已清 1 处复核确认)
- 字数(去代码围栏汉字)= **5,012**(复核口径;editor 报 5,018,差异为围栏剥离方式,**两口径均 ≥5,000**)✓
- 镜像:`cmp chapters/ch09-extension.md book/src/part2/ch09.md` → **逐字节一致** ✓

## F. 是否可定稿

**修 A-1、A-2 两处(共约 10 个字的单词级改动)后即可定稿**;A-3 顺带修。无结构性风险,镜像两份需同步改后重跑 `cmp`。
