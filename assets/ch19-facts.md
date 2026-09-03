# Ch19 事实表:octoscode 终端客户端与 UI Protocol

- 日期: 2026-09-03
- 基线:
  - octoscode 仓(仓库根 `/Users/zhangalex/Work/Projects/FW/octoscode`): branch `main`, HEAD `1129fa331faee8f8cbd350815d8a89af5ee3d01e`(短 SHA `1129fa3`,"Merge pull request #603 from onewesong/fix/peer-chinese-display")
  - octos 主仓(仓库根 `/Users/zhangalex/Work/Projects/FW/octos`): branch `main`, HEAD `9c1571016e5ea86955b4b3486c04f0359dfff339`(即基线 `9c157101`)
  - herdr 仓(仓库根 `/Users/zhangalex/Work/Projects/FW/herdr`): HEAD `fefe5c4f`(仅用于识别契约清单行号)
- 引用格式: 本表所有代码引用一律为全路径 `octoscode/src/<path>.rs:行号` / `crates/octos-core/src/ui_protocol.rs:行号` / `herdr/src/detect/manifests/octoscode.toml:行号`,禁止无路径短引用。
- 本文行数与行号均为基线 commit 下实测;复跑命令已逐条附于各节。

## 1. octoscode `src/` 顶层文件(行数 + 首行)

命令(仓库根 octoscode):

```sh
wc -l src/*.rs | sort -rn
for f in src/*.rs; do printf "%s | %s\n" "$f" "$(head -1 "$f")"; done
```

| 文件 | 行数 | 首行(截取) |
|---|---:|---|
| `octoscode/src/store.rs` | 43935 | `use std::collections::BTreeSet;`(reducer,含测试) |
| `octoscode/src/model.rs` | 12884 | `use std::time::Instant;` |
| `octoscode/src/transport.rs` | 12214 | `use std::collections::{HashMap, VecDeque};` |
| `octoscode/src/event_loop.rs` | 8655 | `use std::io;` |
| `octoscode/src/app.rs` | 6286 | `use ratatui::{` |
| `octoscode/src/insert_history.rs` | 1602 | `//! Insert finalized history lines into the terminal's **normal scrollback**,` |
| `octoscode/src/backend_ensure.rs` | 1317 | `//! Auto-provision the octos server backend so a fresh octoscode install` |
| `octoscode/src/autonomy.rs` | 1192 | `//! M15-E autonomy command parsing for /agents, /goal, and /loop.` |
| `octoscode/src/cli.rs` | 1184 | `use clap::{Parser, ValueEnum};` |
| `octoscode/src/tui_terminal.rs` | 1171 | `//! Inline-viewport terminal — ported and trimmed from codex-rs tui/src/custom_terminal.rs.` |
| `octoscode/src/history.rs` | 743 | `//! Composer command-history navigation (codex / claude-code style).` |
| `octoscode/src/viewport.rs` | 620 | `//! Inline-viewport driver: owns the scrollback-flush bookkeeping…` |
| `octoscode/src/splash.rs` | 573 | `//! Startup splash: a ttfx-rendered OCTOS logo animation…` |
| `octoscode/src/profiles.rs` | 544 | `//! Phase 3 startup profile discovery.` |
| `octoscode/src/outer_duty.rs` | 476 | `//! octoscode outer-duty (OUTER_LOOP_REVIEW #38 / #38-r1): the kernel lock…` |
| `octoscode/src/lib.rs` | 414 | `// i18n: load locales/*.yml (relative to the crate root)…` |
| `octoscode/src/olp_mcp.rs` | 406 | `//! OLP-MCP outer-loop server (OUTER_LOOP_REVIEW #31): the Rust port of the…` |
| `octoscode/src/client_event.rs` | 402 | `use octos_core::{` |
| `octoscode/src/clipboard.rs` | 378 | `//! Clipboard copy support for the TUI.` |
| `octoscode/src/file_picker.rs` | 254 | `//! @ composer file picker (#363, v1: path insert only).` |
| `octoscode/src/terminal_probe.rs` | 243 | `//! Terminal detection and color adaptation for octoscode.` |
| `octoscode/src/highlight.rs` | 209 | `//! Fenced-code-block syntax highlighting for the transcript renderer` |
| `octoscode/src/theme.rs` | 204 | `use ratatui::style::{Color, Style};` |
| `octoscode/src/sanitize.rs` | 160 | `//! Terminal control-sequence sanitisation for server-supplied text.` |
| `octoscode/src/main.rs` | 57 | `use eyre::Result;` |
| `octoscode/src/keymap.rs` | 1 | `pub const HELP: &str = "Tab agents \| Esc chat \| PgUp/PgDn scroll \| y/s/n approval…"` |

顶层 `src/*.rs` 合计 96124 行(含 store.rs 内嵌测试)。

## 2. `src/app/`、`src/cmd/`、`src/menu/` 子目录

命令(仓库根 octoscode):

```sh
wc -l src/app/*.rs src/cmd/*.rs src/menu/*.rs
for f in src/app/*.rs src/cmd/mod.rs src/menu/mod.rs; do printf "%s | %s\n" "$f" "$(head -1 "$f")"; done
```

| 文件 | 行数 | 首行 |
|---|---:|---|
| `octoscode/src/app/tests.rs` | 15206 | `//! Test module for crate::app (#365): moved out of app.rs…` |
| `octoscode/src/app/transcript_build.rs` | 4149 | `//! transcript_build — extracted from app.rs (#365 step 2)…` |
| `octoscode/src/app/render.rs` | 2499 | `//! render — extracted from app.rs (#365 step 2)…` |
| `octoscode/src/app/activity_nav.rs` | 558 | `//! activity_nav — extracted from app.rs (#365 step 2)…` |
| `octoscode/src/app/markdown_highlight.rs` | 516 | `//! Style-only markdown highlighting for the composer draft.` |
| `octoscode/src/cmd/doctor.rs` | 2460 | (子命令实现,无首行文档) |
| `octoscode/src/cmd/install_method.rs` | 747 | |
| `octoscode/src/cmd/update.rs` | 688 | |
| `octoscode/src/cmd/mod.rs` | 452 | `//! octoscode subcommands: update and doctor (design doc).` |
| `octoscode/src/cmd/github.rs` | 196 | |
| `octoscode/src/cmd/config.rs` | 152 | |
| `octoscode/src/cmd/outer_duty.rs` | 98 | |
| `octoscode/src/cmd/olp_mcp.rs` | 20 | |
| `octoscode/src/menu/providers.rs` | 12080 | |
| `octoscode/src/menu/registry.rs` | 1708 | |
| `octoscode/src/menu/types.rs` | 926 | |
| `octoscode/src/menu/selection_view.rs` | 837 | |
| `octoscode/src/menu/availability.rs` | 695 | |
| `octoscode/src/menu/render.rs` | 458 | |
| `octoscode/src/menu/wizard.rs` | 417 | |
| `octoscode/src/menu/multi_select_view.rs` | 495 | |
| `octoscode/src/menu/preview_layout.rs` | 133 | |
| `octoscode/src/menu/mod.rs` | 22 | `//! Menu framework model and generic render surfaces.` |

## 3. 关键 pub 符号与启动链行号

命令(仓库根 octoscode):

```sh
grep -n "DEFAULT_STDIO_COMMAND" src/cli.rs | head
grep -n "pub trait AppUiBackend\|pub fn build_backend" src/transport.rs
grep -n "pub async fn run\|pub fn run" src/event_loop.rs | head -3
grep -n "pub enum AppUiCommand" src/model.rs
grep -n "pub fn ensure_octos_backend" src/backend_ensure.rs
grep -n "pub fn parse_autonomy_slash" src/autonomy.rs
grep -n "pub enum ClientEvent" src/client_event.rs
grep -n "impl Store\|pub fn from_snapshot\|pub fn apply_event\|pub fn apply_client_event" src/store.rs | head
```

### 3.1 启动链(main → cli → backend_ensure → transport → event_loop → store → model)

| 符号 | 位置 | 说明 |
|---|---|---|
| `fn main()` | `octoscode/src/main.rs:4` | 入口;先拦截 `update`/`doctor` 子命令(`octoscode/src/main.rs:10`),再 `backend_ensure::ensure_octos_backend(&mut cli)?`(`octoscode/src/main.rs:22`),`splash::play(&cli)`,最后 `event_loop::run(cli)`(`octoscode/src/main.rs:30`) |
| `pub const DEFAULT_STDIO_COMMAND: &str = "octos serve --stdio --solo"` | `octoscode/src/cli.rs:118` | 默认 stdio 拉起命令;缺省回填见 `octoscode/src/cli.rs:415`、`octoscode/src/cli.rs:849` |
| `--endpoint`(UI Protocol v1 WebSocket) | `octoscode/src/cli.rs:126`、`octoscode/src/cli.rs:204-207` | WS 直连替代 stdio |
| `pub fn ensure_octos_backend(cli: &mut Cli) -> Result<()>` | `octoscode/src/backend_ensure.rs:113` | 首启自动安装 octos;仅在本地 stdio 启动且未安装时生效,新装会改写 `cli.stdio_command` 为 `~/.octos/bin/octos` |
| `pub trait AppUiBackend` | `octoscode/src/transport.rs:238` | 三方法:`bootstrap -> AppUiSnapshot`、`send(AppUiCommand)`、`next_event -> Option<ClientEvent>`(`octoscode/src/transport.rs:239-243`) |
| `pub fn build_backend(cli: &Cli) -> Box<dyn AppUiBackend>` | `octoscode/src/transport.rs:244` | 按 cli 选择 stdio / WS / mock 后端 |
| `pub struct ProtocolAppUiBackend` | `octoscode/src/transport.rs:311` | 协议后端;`impl ProtocolAppUiBackend` @ `octoscode/src/transport.rs:1585`,`impl AppUiBackend for ProtocolAppUiBackend` @ `octoscode/src/transport.rs:2235` |
| `pub struct MockAppUiBackend` | `octoscode/src/transport.rs:4542` | mock 后端;`impl AppUiBackend for MockAppUiBackend` @ `octoscode/src/transport.rs:4699`(测试/离线用) |
| `struct StdioTransportDriver` | `octoscode/src/transport.rs:566` | stdio 子进程驱动 |
| `pub fn run(cli: Cli) -> Result<()>` | `octoscode/src/event_loop.rs:192` | 事件循环;`build_backend(&cli)` @ `octoscode/src/event_loop.rs:228`,`Store::from_snapshot(snapshot)` @ `octoscode/src/event_loop.rs:230` |
| `pub struct Store` | `octoscode/src/store.rs:287` | reducer 容器;`impl Store` @ `octoscode/src/store.rs:422`,`pub fn from_snapshot` @ `octoscode/src/store.rs:423` |
| `pub fn apply_client_event(&mut self, event: ClientEvent) -> Option<AppUiCommand>` | `octoscode/src/store.rs:8241` | 用户输入→命令 |
| `pub fn apply_event(&mut self, event: AppUiEvent) -> Option<AppUiCommand>` | `octoscode/src/store.rs:9063` | 服务端事件→状态迁移 |
| `pub enum AppUiCommand` | `octoscode/src/model.rs:790` | 客户端→服务端的稳定命令值 |
| `pub enum ClientEvent` | `octoscode/src/client_event.rs:25` | 客户端事件(键入/滚动等,局部于 TUI) |

### 3.2 autonomy(goal/peer 客户端侧解析)

`octoscode/src/autonomy.rs:1192 行`,首行文档「M15-E autonomy command parsing for /agents, /goal, and /loop.」

命令:`grep -n "^pub enum\|^pub fn parse" src/autonomy.rs | head -15`

| 符号 | 行号 |
|---|---:|
| `pub enum AgentsCommand` | `octoscode/src/autonomy.rs:35` |
| `pub enum AgentArtifactSelector` | `octoscode/src/autonomy.rs:59` |
| `pub enum TaskCommand` | `octoscode/src/autonomy.rs:66` |
| `pub enum TaskArtifactSelector` | `octoscode/src/autonomy.rs:76` |
| `pub enum ThreadCommand` | `octoscode/src/autonomy.rs:83` |
| `pub enum TurnCommand` | `octoscode/src/autonomy.rs:90` |
| `pub enum GoalCommand` | `octoscode/src/autonomy.rs:97` |
| `pub enum LoopCadence` | `octoscode/src/autonomy.rs:120` |
| `pub enum LoopCommand` | `octoscode/src/autonomy.rs:131` |
| `pub enum AutonomyCommand` | `octoscode/src/autonomy.rs:158` |
| `pub enum AutonomyParseError` | `octoscode/src/autonomy.rs:170` |
| `pub fn parse_autonomy_slash(input: &str) -> Result<Option<AutonomyCommand>, AutonomyParseError>` | `octoscode/src/autonomy.rs:248` |

## 4. `crates/octos-core/src/ui_protocol.rs`(octos 主仓 @ 9c157101)

命令(仓库根 octos):

```sh
wc -l crates/octos-core/src/ui_protocol.rs          # 7221
head -1 crates/octos-core/src/ui_protocol.rs        # //! Draft client/runtime protocol types for M9.
grep -c "^pub enum" crates/octos-core/src/ui_protocol.rs   # 24
grep -c "^pub struct" crates/octos-core/src/ui_protocol.rs # 223
grep -c "^pub fn" crates/octos-core/src/ui_protocol.rs     # 6
grep -c "^pub type" crates/octos-core/src/ui_protocol.rs   # 1
grep -c "^pub const" crates/octos-core/src/ui_protocol.rs  # 47
grep -n "^pub enum UiCommand\|^pub enum UiNotification\|^pub enum Payload\|pub struct RpcRequest\|pub struct RpcNotification\|pub struct UiProtocolCapabilities" crates/octos-core/src/ui_protocol.rs
```

- 行数: **7221 行**;首行文档:`//! Draft client/runtime protocol types for M9.`
- 规模: `pub enum` 24 个、`pub struct` 223 个、`pub fn` 6 个、`pub type` 1 个、`pub const` 47 个(顶层)。

关键符号:

| 符号 | 行号 |
|---|---:|
| `pub struct RpcRequest<T>` | `crates/octos-core/src/ui_protocol.rs:684` |
| `pub struct RpcResponse<T>` | `crates/octos-core/src/ui_protocol.rs:708` |
| `pub struct RpcNotification<T>` | `crates/octos-core/src/ui_protocol.rs:730` |
| `pub struct RpcError` | `crates/octos-core/src/ui_protocol.rs:752` |
| `pub struct EventEnvelope<P>` | `crates/octos-core/src/ui_protocol.rs:68` |
| `pub struct UiProtocolVersion` | `crates/octos-core/src/ui_protocol.rs:1553` |
| `pub struct UiProtocolCapabilities` | `crates/octos-core/src/ui_protocol.rs:1577` |
| `pub enum ProtocolCompat` / `pub fn compare_protocol` | `crates/octos-core/src/ui_protocol.rs:1777` / `:1814` |
| `pub struct TurnStartParams` | `crates/octos-core/src/ui_protocol.rs:1999` |
| `pub enum ApprovalDecision` | `crates/octos-core/src/ui_protocol.rs:2074` |
| `pub enum TurnLifecycleState` | `crates/octos-core/src/ui_protocol.rs:3031` |
| `pub enum Payload`(事件负载) | `crates/octos-core/src/ui_protocol.rs:3803` |
| `pub enum PayloadV2` | `crates/octos-core/src/ui_protocol.rs:4059` |
| `pub enum UiCommand`(客户端→服务端方法全集) | `crates/octos-core/src/ui_protocol.rs:4197` |
| `pub enum UiRpcResult` | `crates/octos-core/src/ui_protocol.rs:4760` |
| `pub enum UiNotification`(服务端→客户端通知全集) | `crates/octos-core/src/ui_protocol.rs:6616` |

## 5. `octoscode/docs/ARCHITECTURE.md` 要点

命令(仓库根 octoscode):

```sh
wc -l docs/ARCHITECTURE.md            # 724
grep -n "^#\{1,3\} " docs/ARCHITECTURE.md
sed -n '3,30p' docs/ARCHITECTURE.md
```

- 行数: **724 行**;标题 `# octoscode Architecture`(`docs/ARCHITECTURE.md:1`)。

哑客户端边界(第 19 章「客户端边界」小节直接引用):`## Scope` @ `docs/ARCHITECTURE.md:3` —

> `octoscode` is a standalone terminal client for the Octos UI Protocol. In protocol mode it does not run the Octos agent, execute tools, approve commands, maintain the durable ledger, or own provider/model configuration. Those responsibilities belong to the `octos serve` process.

职责划分(同节):TUI owns — 终端渲染与键盘、本地视图状态/焦点/滚动/展开/composer 草稿、用户 prompt 的乐观显示、本地 slash 命令(`/ps` `/stop` `/help`)、用户交互与稳定 `AppUiCommand` 值的翻译。Server owns — session 创建与 cwd 校验、agent/运行时执行、shell/工具执行与沙箱策略、审批请求/决定/范围、task supervisor 与后台任务注册表、持久 UI 事件 ledger + replay + `protocol/replay_lossy`、diff 预览与任务输出数据源。

章节标题(顶层 `##`,附行号;`###` 条目略,可复跑上面 grep 复现):

| 行号 | 标题 |
|---:|---|
| 3 | `## Scope` |
| 28 | `## Runtime Topology` |
| 63 | `## Server Endpoints` |
| 91 | `## Shared API Types` |
| 104 | `## Protocol Commands`(`### profile/ session/ agent/ mcp/ tool/ loop/ task/ auth/ turn/ approval/ permission/ snapshot/ peer/ user_question/ diff/ launch/ thread/ review/ config/ local/`,行 114–290) |
| 296 | `## Protocol Notifications`(`### session/ turn/ monitor/ background/ approval/ visual/ tool/ agent/ loop/ context/ message/ voice/ task/ router/ projection/ user_question/ plan/ progress/ warning/ protocol/ file/ queue/ peer/`,行 308–470) |
| 476 | `## Client Layers`(Entry and configuration @481 / Core loop and state @497 / Transport and backend @508 / Rendering @516 / Menu framework @535 / Composer and input @550) |
| 560 | `## Menu Framework` |
| 577 | `## Protocol Startup Flow` |
| 590 | `## Turn Flow` |
| 603 | `## Approval Flow` |
| 616 | `## Task and Output Flow` |
| 632 | `## Durability and Replay` |
| 653 | `## Mock Mode` |
| 660 | `## Readonly Mode` |
| 666 | `## Codex-Style Reference Architecture` |
| 713 | `## Architectural Invariants` |

## 6. 与 herdr 的识别契约(仅列事实,叙事详见第 21 章)

命令:`cat /Users/zhangalex/Work/Projects/FW/herdr/src/detect/manifests/octoscode.toml`

`herdr/src/detect/manifests/octoscode.toml`(40 行,herdr @ `fefe5c4f`)共 **3 条规则**:

1. `approval_blocked`(state=blocked, priority=1100, region=whole_recent, visible_blocker)@ `herdr/src/detect/manifests/octoscode.toml:8` — 关键词含 `Approval | y once | s session | n deny`、`Waiting on you`、`Ctrl+R/Alt+A answer`、中文变体 `审批 | y 本次 | s 本会话`
2. `statusbar_working`(state=working, priority=1000, region=bottom_non_empty_lines(6))@ `herdr/src/detect/manifests/octoscode.toml:21` — 正则 `state·Working` 或含 `Esc interrupt`
3. `statusbar_idle`(state=idle, priority=900, region=bottom_non_empty_lines(6))@ `herdr/src/detect/manifests/octoscode.toml:30` — 正则 `state Idle/Done` 或含 `Tab agents | Ctrl+O expand`、`Ask Octos to change code`

(状态栏提示串与 `octoscode/src/keymap.rs:1` 的 `pub const HELP` 同源风格,可互证。)

## 7. 抽查复跑记录(2026-09-03 交付前)

```sh
# octoscode @ 1129fa33,逐条命中:
sed -n '118p' src/cli.rs        # pub const DEFAULT_STDIO_COMMAND: &str = "octos serve --stdio --solo";
sed -n '192p' src/event_loop.rs # pub fn run(cli: Cli) -> Result<()> {
sed -n '238,244p' src/transport.rs  # pub trait AppUiBackend { … } / pub fn build_backend …
sed -n '113p' src/backend_ensure.rs # pub fn ensure_octos_backend(cli: &mut Cli) -> Result<()> {
sed -n '790p' src/model.rs      # pub enum AppUiCommand {
sed -n '248p' src/autonomy.rs   # pub fn parse_autonomy_slash(…
sed -n '25p'  src/client_event.rs   # pub enum ClientEvent {
# octos @ 9c157101,逐条命中:
sed -n '4197p' crates/octos-core/src/ui_protocol.rs  # pub enum UiCommand {
sed -n '6616p' crates/octos-core/src/ui_protocol.rs  # pub enum UiNotification {
```

全部与上文表格一致。
