# Ch7 事实表 — 安全纵深(sandbox fail-closed / 注入防御 / 能力授予)

- 基准: octos main @ `9c157101`(全称 `9c1571016e5ea86955b4b3486c04f0359dfff339`,提交时间 2026-09-02 19:37:40 +0800)
- 采集日期: 2026-09-03(本地时区)
- 源码仓库(只读): `/Users/zhangalex/Work/Projects/FW/octos`
- 依据: `specs/ch07-security.spec.md`「决策」段;黑板第 10 条
- 所有命令默认在源码仓库根目录执行;行号均已实测(采集后抽查复跑,见文末)

## 1. sandbox/ 六个文件: 行数与首行文档

命令:

```sh
wc -l crates/octos-agent/src/sandbox/*.rs
for f in crates/octos-agent/src/sandbox/*.rs; do echo "== $f"; head -1 "$f"; done
```

| 文件 | 行数 | 首行文档 |
|---|---:|---|
| `crates/octos-agent/src/sandbox/mod.rs` | 2190 | `//! Sandboxing for shell command execution.` |
| `crates/octos-agent/src/sandbox/bwrap.rs` | 498 | `//! Linux sandbox using bubblewrap (bwrap).` |
| `crates/octos-agent/src/sandbox/landlock.rs` | 175 | `//! Linux container sandbox using the octos-sandbox Landlock/seccomp helper.` |
| `crates/octos-agent/src/sandbox/macos.rs` | 1767 | `//! macOS sandbox using sandbox-exec.` |
| `crates/octos-agent/src/sandbox/docker.rs` | 392 | `//! Docker container sandbox.` |
| `crates/octos-agent/src/sandbox/windows.rs` | 325 | `//! Windows sandbox using AppContainer via helper binary.` |
| 合计 | 5347 | — |

## 2. `SandboxMode` 与 `MountMode` 枚举变体(含行号)

命令:

```sh
grep -n 'pub enum SandboxMode\|pub enum MountMode' crates/octos-agent/src/sandbox/mod.rs
sed -n '408,440p' crates/octos-agent/src/sandbox/mod.rs
```

`MountMode`(mod.rs:408,`#[serde(rename_all = "lowercase")]`),3 个变体:

| 变体 | 行号 | 说明 |
|---|---:|---|
| `None` | 410 | 不挂载 workspace |
| `ReadOnly` | 413 | 只读挂载(`#[serde(rename = "ro")]`) |
| `ReadWrite` | 417 | 读写挂载(`#[default]`) |

`SandboxMode`(mod.rs:423,`#[serde(rename_all = "lowercase")]`),7 个变体:

| 变体 | 行号 | 说明 |
|---|---:|---|
| `Auto` | 426 | 自动探测(`#[default]`;文档注释: bwrap on Linux, sandbox-exec on macOS, AppContainer on Windows) |
| `Bwrap` | 428 | Linux bubblewrap |
| `Landlock` | 430 | Linux 容器沙箱,Landlock 规则 + seccomp(委托 `octos-sandbox` 助手) |
| `Macos` | 432 | macOS sandbox-exec |
| `Docker` | 434 | Docker 容器隔离 |
| `AppContainer` | 437 | Windows AppContainer 隔离(`#[serde(rename = "appcontainer")]`) |
| `None` | 439 | 不沙箱(直通) |

## 3. 七个 `impl Sandbox for` 位置

命令:

```sh
grep -n 'impl Sandbox' crates/octos-agent/src/sandbox/*.rs
```

七个 trait 实现位(grep 另外命中 `impl SandboxBackendChoice` / `impl SandboxUnavailable`,非 trait 实现):

| 位置 | 后端 | 一句话定位 |
|---|---|---|
| `bwrap.rs:29` | `impl Sandbox for BwrapSandbox` | Linux bubblewrap 后端 |
| `docker.rs:36` | `impl Sandbox for DockerSandbox` | Docker 容器后端 |
| `landlock.rs:27` | `impl Sandbox for LinuxContainerSandbox` | Landlock/seccomp 助手后端(委托 `octos-sandbox`) |
| `macos.rs:185` | `impl Sandbox for MacosSandbox` | macOS sandbox-exec 后端 |
| `mod.rs:500` | `impl Sandbox for NoSandbox` | 哨兵: 无沙箱直通(`pub struct NoSandbox;` 在 mod.rs:498) |
| `mod.rs:914` | `impl Sandbox for RefusingSandbox` | 哨兵: 拒绝执行(fail-closed 载体,`pub struct RefusingSandbox` 在 mod.rs:909) |
| `windows.rs:46` | `impl Sandbox for AppContainerSandbox` | Windows AppContainer 后端 |

五个真后端 + 两个哨兵,与 spec「五后端两哨兵齐全」一致。trait 定义 `pub trait Sandbox` 在 mod.rs:443;fail-closed 决策核心 `pub fn decide_sandbox` 在 mod.rs:809,`pub struct SandboxUnavailable` 在 mod.rs:694,`auto_sandbox_kind` 在 mod.rs:1062。

## 4. `crates/octos-fleet/src/grant.rs` 四个类型

命令:

```sh
grep -n 'pub enum NetworkGrant\|pub enum FsGrant\|pub struct WorkerGrant\|pub enum GrantError\|pub fn validate' crates/octos-fleet/src/grant.rs
```

| 类型 | 行号 | 变体 / 字段 |
|---|---:|---|
| `NetworkGrant`(pub enum) | 76 | `None`(默认)、`Hosts(Vec<String>)`、`Full`;方法 `allows_raw_egress`(仅 `Full` 真)、`web_allowlist`、`permits_web_tools` |
| `FsGrant`(pub enum) | 127 | `Workspace`(默认,cwd 读写)、`Host`(全盘读写,显式操作者授予);方法 `is_host` |
| `WorkerGrant`(pub struct) | 151 | `network: NetworkGrant`(:154)、`tools: Vec<String>`(:157)、`fs: FsGrant`(:160)、`write_paths: Option<Vec<String>>`(:179,#1976 按路径写围栏)、`create_only: bool`(:189);方法 `minimal()`、`has_write_fence()`、`sorted_tools()`、`validate()`(:247) |
| `GrantError`(pub enum) | 359 | `UnknownTool(String)`、`WebToolWithoutNetwork(String)`、`EmptyHostAllowlist`、`WritePathsWithHostFs`(#1976)、`CreateOnlyWithoutWritePaths`(#1976)、`EmptyWritePathsWithCreateOnly`(#1976)、`InvalidWritePath { pattern, reason }`(#1976) |

`WorkerGrant::validate` 在 grant.rs:247(拒绝 grantable 外工具、`NetworkGrant::None` 下授予 web 工具、空 `Hosts` 允许表,以及 #1976 围栏不一致组合);`validate_write_path_pattern` 在 grant.rs:307。文件共 714 行。

## 5. 两个提交的改动文件清单(`git show --stat`,只读)

命令:

```sh
git merge-base --is-ancestor eb7c7221 9c157101 && git merge-base --is-ancestor ffcde205 9c157101
git show --stat eb7c7221
git show --stat ffcde205
```

### `eb7c7221` — feat(sandbox): fail closed on unhonorable explicit modes; make Auto degradation loud (#2196)

(2026-08-31,14 个文件,+1621/−158)

| 文件 | 改动 |
|---|---|
| `.github/workflows/ci.yml` | 6 + |
| `CLAUDE.md` | 4 +- |
| `crates/octos-agent/src/sandbox/mod.rs` | 1264 +++…--- |
| `crates/octos-agent/src/sandbox/windows.rs` | 114 ++- |
| `crates/octos-agent/src/tools/check.rs` | 39 + |
| `crates/octos-agent/src/tools/coding_tools.rs` | 42 + |
| `crates/octos-agent/src/tools/shell.rs` | 79 ++ |
| `crates/octos-agent/tests/security_sandbox.rs` | 2 + |
| `crates/octos-agent/tests/validator_runner.rs` | 57 ++ |
| `crates/octos-cli/src/commands/doctor.rs` | 4 +- |
| `crates/octos-cli/src/commands/mcp_serve.rs` | 9 + |
| `crates/octos-cli/src/commands/serve.rs` | 36 +- |
| `crates/octos-cli/src/profiles.rs` | 39 + |
| `crates/octos-fleet-worker/src/worker.rs` | 84 ++ |

要点: 显式选择却无法兑现的模式 fail-closed(返回 `RefusingSandbox`,wrap 时 shell-inert stderr + exit 1,shell/exec/check 短路并给模型可见的拒绝文本);决策抽成纯函数 `decide_sandbox(config, HostOs, &dyn HostBackendProbe)`;Auto 无后端仍降级 `NoSandbox` 但每进程告警一次,`sandbox.fail_closed`(默认 false)可把降级变成拒绝。

### `ffcde205` — fix(sandbox): lock-only cargo grant by default; downloads gated on allow_network

(2026-08-26,4 个文件,+140/−82)

| 文件 | 改动 |
|---|---|
| `crates/octos-agent/src/sandbox/macos.rs` | 18 +- |
| `crates/octos-agent/src/sandbox/mod.rs` | 155 +++…--- |
| `crates/octos-agent/src/tools/coding_tools.rs` | 10 +- |
| `crates/octos-agent/src/tools/coding_tools_tests.rs` | 39 ++ |

要点: cargo 授权默认 lock-only(可写集仅 `~/.cargo/.package-cache`);registry index/cache/src、git 与 rustup 全部只读;`allow_network` 开启时才授予下载所需的写权限与网络;并修复会话退出码竞态与拒绝提示文案。

两个提交均为 `9c157101` 的祖先(`git merge-base --is-ancestor` 通过)。

## 6. 辅助事实(同基准实测)

命令:

```sh
wc -l crates/octos-agent/src/{policy,dispatch_policy,permissions,prompt_guard,sanitize}.rs crates/octos-agent/src/tools/ssrf.rs crates/octos-sandbox/src/main.rs
for f in crates/octos-agent/src/{policy,dispatch_policy,permissions,prompt_guard,sanitize}.rs crates/octos-agent/src/tools/ssrf.rs; do echo "== $f"; head -1 "$f"; done
```

| 文件 | 行数 | 首行文档 |
|---|---:|---|
| `crates/octos-agent/src/policy.rs` | 746 | `//! Command approval policy.` |
| `crates/octos-agent/src/dispatch_policy.rs` | 566 | `//! Pre-dispatch policy gate shared by every MCP-agent dispatch site —` |
| `crates/octos-agent/src/permissions.rs` | 167 | `//! Supervisory safety tiers for robotic tool authorization.` |
| `crates/octos-agent/src/prompt_guard.rs` | 772 | `//! Prompt injection detection and sanitization (defense-in-depth).` |
| `crates/octos-agent/src/sanitize.rs` | 245 | `//! Tool output sanitization.` |
| `crates/octos-agent/src/tools/ssrf.rs` | 620 | `//! Shared SSRF (Server-Side Request Forgery) protection.` |
| `crates/octos-sandbox/src/main.rs` | 1252 | `//! octos-sandbox: platform sandbox helper binary.` |

事实纠正(spec 要求): `crates/octos-sandbox/src/main.rs` 是**平台沙箱助手二进制**(Windows 上创建/复用 AppContainer profile;macOS 上 no-op 直通),不是沙箱子系统;真沙箱实现都在 `crates/octos-agent/src/sandbox/`。

## 7. 交付前抽查复跑记录

采集后抽 4 项复跑(2026-09-03),输出与本表一致:

```sh
$ grep -h 'impl Sandbox for' crates/octos-agent/src/sandbox/*.rs | wc -l
7
$ sed -n '423,440p' crates/octos-agent/src/sandbox/mod.rs | grep -cE '^\s{4}[A-Z][A-Za-z]+,?$'
7
$ wc -l crates/octos-fleet/src/grant.rs
     714 crates/octos-fleet/src/grant.rs
$ git show --stat eb7c7221 | tail -1
 14 files changed, 1621 insertions(+), 158 deletions(-)
$ git show --stat ffcde205 | tail -1
 4 files changed, 140 insertions(+), 82 deletions(-)
```
