# Ch21 事实表 — herdr 与外环运维实务(peer A,ch21-facts)

> 本表所有数字、行号、符号均来自 2026-09-03 会话内命令输出,每项附生成命令;未跑命令的条目不写。
> 引用规范(AGENTS.md 第 7 条):herdr 源码引用一律 `herdr/src/<path>.rs:行号`;octoscode 文档引用注明相对路径。

## 0. 基准(analysis baseline)

| 项 | 值 | 生成命令 |
|---|---|---|
| herdr 仓 HEAD | `fefe5c4ffb90a0f11320d836640dbc040cc28dc5`(短 `fefe5c4f`),分支 `feat/octoscode-agent`,提交时间 2026-08-29 17:59:33 +0800,标题 `feat(detect): add octoscode as a supported agent` | `cd ~/Work/Projects/FW/herdr && git log -1 --format='%H %h %ci %s' && git branch --show-current` |
| herdr 版本 | `0.8.2`(herdr/Cargo.toml:3),description `terminal workspace manager for AI coding agents`(herdr/Cargo.toml:6),license Apache-2.0(herdr/Cargo.toml:7) | `cd ~/Work/Projects/FW && sed -n '1,10p' herdr/Cargo.toml` |
| octos 主仓基线 | `9c157101`(2026-09-02 19:37:40 +0800) | `cd ~/Work/Projects/FW/octos && git log -1 --format='%h %ci'` |
| 事实表日期 | 2026-09-03 | — |
| 版本事实(写章用) | herdr 0.8.2;octoscode 窗格识别(`Agent::Octoscode` 与 `herdr/src/detect/manifests/octoscode.toml`)只在本 fork 分支 `feat/octoscode-agent` 上,上游 master 尚未合入(见 §8 衔接点 1) | 本表 §4.4、§5 |

## 1. README 功能要点(herdr/README.md)

生成命令:`cd ~/Work/Projects/FW/herdr && grep -n -E 'always running|never hunt|agent-native|runs what you already|keyboard and mouse|plugins\*\*|one rust binary' README.md`

| 行 | 要点 |
|---|---|
| herdr/README.md:29 | 定位语:**the runtime your coding agents live on** |
| herdr/README.md:31 | **always running** — herdr 是后台 server,终端住在里面;合盖/断网/重启机器后 agent 继续干活、会话可恢复,可从任意终端或 ssh 重新 attach |
| herdr/README.md:32 | **never hunt for the stuck one** — 每个 pane 标记 working / blocked / idle;agent 停下要答案时 herdr 会标出来 |
| herdr/README.md:33 | **agent-native** — agent 经 CLI 与 socket API 驱动 herdr:开窗格、互相 prompt、等另一个 agent 真正 blocked |
| herdr/README.md:34 | **runs what you already run** — 不包装不替换 claude code / codex / cursor / opencode / grok 等,只拥有它们的终端 |
| herdr/README.md:35 | 键盘与鼠标双一等公民(tmux 式 prefix + 点击/拖拽/分屏) |
| herdr/README.md:36 | 插件系统(Ch21 排除范围,不展开) |
| herdr/README.md:37 | **one rust binary, no electron** |

herdr/README.md:71-77(## development):`cargo build --release` 源码构建;`just test` 单测;`just check` 格式+测试+维护检查。生成命令:`cd ~/Work/Projects/FW/herdr && sed -n '71,80p' README.md`。

## 2. 目录 / 文件行数

### 2.1 全仓概览

生成命令:`cd ~/Work/Projects/FW/herdr && find src -name '*.rs' | wc -l && find src -name '*.rs' -exec cat {} + | wc -l`

- `src/` 全部:`.rs` 文件 **245** 个,合计 **229 696** 行。
- 顶层 `src/*.rs`:37 个文件、29 927 行(命令:`cd ~/Work/Projects/FW/herdr && ls src/*.rs | wc -l && wc -l src/*.rs | tail -1`)。

### 2.2 子目录行数(文件数 / 行数)

生成命令(`~/Work/Projects/FW/herdr` 下执行):`for d in api app cli client config detect pane persist protocol pty server terminal ui workspace platform input integration remote; do echo "$d: $(find src/$d -name '*.rs' | wc -l | tr -d ' ') files, $(find src/$d -name '*.rs' -exec cat {} + | wc -l | tr -d ' ') lines"; done`

| 目录 | 文件数 | 行数 | 备注(大文件行数,命令:`wc -l herdr/src/<该文件>`) |
|---|---|---|---|
| src/app | 54 | 65 400 | herdr/src/app/mod.rs 6606、herdr/src/app/actions.rs 6155、herdr/src/app/api.rs 2303 |
| src/server | 16 | 19 166 | server 模式(herdr/src/server/headless.rs 等) |
| src/ui | 17 | 12 416 | 渲染 |
| src/pane | 9 | 10 540 | pane 终端仿真(herdr/src/pane/agent_detection.rs、herdr/src/pane/osc.rs…) |
| src/integration | 13 | 9 822 | 集成 |
| src/api | 22 | 8 957 | socket API(herdr/src/api/server.rs 1477、herdr/src/api/wait.rs 818、herdr/src/api/schema.rs 246,herdr/src/api/schema/ 另 13 文件 4064 行) |
| src/cli | 16 | 8 669 | CLI 子命令(见 §2.4) |
| src/terminal | 8 | 8 225 | 终端仿真 |
| src/platform | 7 | 8 192 | 平台层 |
| src/client | 4 | 7 698 | thin client(herdr/src/client/mod.rs 3637、herdr/src/client/input.rs 937、herdr/src/client/direct_graphics.rs 437) |
| src/config | 8 | 7 019 | 配置(herdr/src/config/io.rs 1111、herdr/src/config/keybinds.rs 2298、herdr/src/config/model.rs 1964) |
| src/protocol | 3 | 4 266 | 协议 |
| src/detect | 4 | 5 158 | agent 识别(herdr/src/detect/mod.rs 1600、herdr/src/detect/manifest.rs 1547、herdr/src/detect/manifest_update.rs 991、herdr/src/detect/manifest/tests.rs 1020) |
| src/workspace | 8 | 3 796 | 工作区 |
| src/remote | 2 | 3 491 | 远程(Ch21 排除) |
| src/persist | 4 | 3 611 | 持久化 |
| src/input | 5 | 2 926 | 输入 |
| src/pty | 6 | 2 094 | PTY |

### 2.3 顶层大文件(前 10)

生成命令(`~/Work/Projects/FW/herdr` 下执行):`wc -l src/*.rs | sort -rn | head -11`

| 文件 | 行数 |
|---|---|
| herdr/src/pane.rs | 4 560 |
| herdr/src/update.rs | 3 694 |
| herdr/src/kitty_graphics.rs | 3 252 |
| herdr/src/raw_input.rs | 3 118 |
| herdr/src/workspace.rs | 1 814 |
| herdr/src/ui.rs | 1 561 |
| herdr/src/layout.rs | 1 167 |
| herdr/src/cli.rs | 1 166 |
| herdr/src/session.rs | 1 060 |
| herdr/src/main.rs | 1 015 |

### 2.4 src/cli/ 逐文件

生成命令(`~/Work/Projects/FW/herdr` 下执行):`wc -l src/cli/*.rs | sort -rn`

| 文件 | 行数 |
|---|---|
| herdr/src/cli/pane.rs | 2 108 |
| herdr/src/cli/plugin.rs | 1 834 |
| herdr/src/cli/spec.rs | 1 377 |
| herdr/src/cli/agent.rs | 949 |
| herdr/src/cli/server.rs | 367 |
| herdr/src/cli/worktree.rs | 333 |
| herdr/src/cli/status.rs | 324 |
| herdr/src/cli/workspace.rs | 252 |
| herdr/src/cli/notification.rs | 207 |
| herdr/src/cli/integration.rs | 191 |
| herdr/src/cli/tab.rs | 187 |
| herdr/src/cli/runtime.rs | 123 |
| herdr/src/cli/api.rs | 118 |
| herdr/src/cli/completion.rs | 115 |
| herdr/src/cli/protocol_guard.rs | 110 |
| herdr/src/cli/server_not_running.rs | 74 |

## 3. 首行文档(模块 doc comment 抽样)

生成命令(`~/Work/Projects/FW` 下执行):`for f in herdr/src/detect/mod.rs herdr/src/events.rs herdr/src/client/mod.rs herdr/src/layout.rs herdr/src/server/headless.rs herdr/src/detect/manifest.rs herdr/src/main.rs herdr/src/cli.rs herdr/src/config.rs herdr/src/session.rs; do echo "-- $f: $(head -1 $f)"; done`

| 文件 | 首行 |
|---|---|
| herdr/src/detect/mod.rs:1 | `//! Agent state detection via terminal tail pattern matching.`(每 pane 周期读屏幕底部,匹配已知 agent 输出模式定状态) |
| herdr/src/events.rs:1 | `//! Internal app events delivered via channel.`(后台任务→主循环,免轮询) |
| herdr/src/client/mod.rs:1 | `//! Thin client mode — connects to the server's client socket.` |
| herdr/src/layout.rs:1 | `//! BSP tree layout for tiling panes within a workspace.` |
| herdr/src/server/headless.rs:1 | `//! Headless server mode — runs the herdr event loop without a real terminal.` |
| herdr/src/detect/manifest.rs:1 | 无模块 doc(直接 `use std::…`;模块说明在 herdr/src/detect/mod.rs:1) |

注:herdr/src/main.rs、herdr/src/cli.rs、herdr/src/config.rs、herdr/src/session.rs、herdr/src/cli/agent.rs 首行均为 `use` 语句,无模块 doc(命令同上,输出为 `use …`)。

## 4. 关键 pub 符号行号

### 4.1 CLI 入口与分发

生成命令:`cd ~/Work/Projects/FW && grep -n -E 'pub(\(super\))? fn' herdr/src/cli.rs | head -20`

| 符号 | 位置 | 说明 |
|---|---|---|
| `pub fn maybe_run(args)` | herdr/src/cli.rs:95 | CLI 总入口;`"agent" =>` 分支在 herdr/src/cli.rs:125,`"pane" =>` 在 herdr/src/cli.rs:127(命令:`cd ~/Work/Projects/FW && sed -n '105,133p' herdr/src/cli.rs`) |
| `pub(super) fn send_request(request)` | herdr/src/cli.rs:762 | CLI→socket 请求 |
| `pub(super) fn parse_agent_status(value)` | herdr/src/cli.rs:897 | 状态串解析:herdr/src/cli.rs:899 `idle`、:900 `working`、:901 `blocked`、:903 `unknown` |
| `pub(super) fn parse_read_source(value)` | herdr/src/cli.rs:875 | read 的 `--source` 解析 |
| `pub(super) fn run_agent_command(args)` | herdr/src/cli/agent.rs:12 | agent 子命令分发(:19 `list`、:20 `get`、:21 `read`、:22 `send-keys`、:23 `prompt`、:24 `rename`、:25 `focus`、:26 `wait`、:27 `attach`、:28 `start`、:29 `explain`;命令:`cd ~/Work/Projects/FW && sed -n '12,35p' herdr/src/cli/agent.rs`) |
| `pub(super) fn run_pane_command(args)` | herdr/src/cli/pane.rs:12 | pane 子命令分发(:19 `list`、:21 `get`、:29 `read`、:32 `split`、:37 `send-keys`、:40 `wait-output`、:44 `run`;命令:`cd ~/Work/Projects/FW && sed -n '12,50p' herdr/src/cli/pane.rs`) |

### 4.2 agent 子命令函数(herdr/src/cli/agent.rs)

生成命令:`cd ~/Work/Projects/FW && grep -n -E '^fn agent_|^fn print_agent_help' herdr/src/cli/agent.rs`

| 函数 | 行 | usage 首发行 |
|---|---|---|
| `agent_explain` | herdr/src/cli/agent.rs:41 | :91(`herdr agent explain <target> [--json|--verbose]`) |
| `agent_start` | herdr/src/cli/agent.rs:289 | :291(`herdr agent start <name> --kind KIND --pane ID [--timeout MS] [-- <agent-args...>]`) |
| `agent_list` | herdr/src/cli/agent.rs:438 | :440(`herdr agent list`) |
| `agent_get` | herdr/src/cli/agent.rs:450 | :452(`herdr agent get <target>`) |
| `agent_focus` | herdr/src/cli/agent.rs:468 | :470 |
| `agent_attach` | herdr/src/cli/agent.rs:486 | :488(`herdr agent attach <target> [--takeover]`) |
| `agent_wait` | herdr/src/cli/agent.rs:506 | :508(`herdr agent wait <target> [--until STATUS]... [--timeout MS]`) |
| `agent_rename` | herdr/src/cli/agent.rs:751 | :753 |
| `agent_prompt` | herdr/src/cli/agent.rs:771 | :774(`herdr agent prompt <target> <text> [--wait] [--until STATUS]... [--timeout MS]`) |
| `agent_send_keys` | herdr/src/cli/agent.rs:843 | :845 |
| `agent_read` | herdr/src/cli/agent.rs:858 | :860(`herdr agent read <target> [--source visible|recent|recent-unwrapped] [--lines N] [--format text|ansi] [--ansi]`) |
| `print_agent_help` | herdr/src/cli/agent.rs:922 | 帮助总表 :923-941 |

`agent_prompt` 行为(命令:`cd ~/Work/Projects/FW && sed -n '771,842p' herdr/src/cli/agent.rs`):`--until`/`--timeout` 必须配 `--wait`(:825、:828 检查);请求 id `cli:agent:prompt`,方法 `Method::AgentPrompt`(:832-839)。

### 4.3 pane 子命令函数(herdr/src/cli/pane.rs)

生成命令:`cd ~/Work/Projects/FW && grep -n -E '^fn pane_(read|split|run|send_keys|wait_output|close|send_text)' herdr/src/cli/pane.rs`

| 函数 | 行 | usage / 常量行 |
|---|---|---|
| `pane_read` | herdr/src/cli/pane.rs:455 | USAGE 常量 :473(`herdr pane read <pane_id> [--source visible|recent|recent-unwrapped|detection] [--lines N] [--format text|ansi] [--ansi] [--raw]`) |
| `pane_split` | herdr/src/cli/pane.rs:623 | usage :733(`herdr pane split [<pane_id>|--pane ID|--current] --direction right|down [--ratio FLOAT] [--cwd PATH] [--env KEY=VALUE] [--right-click herdr|pane] [--focus] [--no-focus]`);函数头读 `HERDR_PANE_ID` 环境变量(:624;命令:`cd ~/Work/Projects/FW && sed -n '623,628p' herdr/src/cli/pane.rs`) |
| `pane_close` | herdr/src/cli/pane.rs:1012 | usage :1014 |
| `pane_send_text` | herdr/src/cli/pane.rs:1025 | usage :1027 |
| `pane_send_keys` | herdr/src/cli/pane.rs:1036 | usage :1038 |
| `pane_run` | herdr/src/cli/pane.rs:1047 | usage :1049(`herdr pane run <pane_id> <command>`);实现 = 发送文本 + `Enter` 键(:1050-1056,`Method::PaneSendInput`) |
| `pane_wait_output` | herdr/src/cli/pane.rs:1062 | USAGE 常量 :1078(`herdr pane wait-output <pane_id> (--match TEXT | --regex PATTERN) …`) |

另:report 系列 USAGE 常量 — `report-agent` herdr/src/cli/pane.rs:1167、`report-agent-session` :1297、`release-agent` :1415、`report-metadata` :1480(命令:`cd ~/Work/Projects/FW && grep -n 'const USAGE' herdr/src/cli/pane.rs`)。

### 4.4 识别引擎(detect)

生成命令:`cd ~/Work/Projects/FW && grep -n -E 'pub enum AgentState|Octoscode|octoscode|octos-tui' herdr/src/detect/mod.rs | head -12`

| 符号 | 位置 | 说明 |
|---|---|---|
| `pub enum AgentState` | herdr/src/detect/mod.rs:13 | 四态:`Idle` :15 / `Working` :17 / `Blocked` :18 / `Unknown` :19 |
| `Agent::Octoscode` 变体 | herdr/src/detect/mod.rs:67 | 本 fork 新增 |
| `SCREEN_MANIFEST_AGENTS` | herdr/src/detect/mod.rs:96 | 22 个走屏幕 manifest 的 agent,`Self::Octoscode` 在 :118 |
| `pub fn agent_label(agent)` | herdr/src/detect/mod.rs:144 | `Agent::Octoscode => "octoscode"` 在 :149 |
| `pub fn interactive_agent_executable(agent)` | herdr/src/detect/mod.rs:153 | `Agent::Octoscode => "octoscode"` 在 :184 |
| `pub fn parse_agent_label(agent)` | herdr/src/detect/mod.rs:207 | `"octoscode" | "octos-tui" => Some(Agent::Octoscode)` 在 :225(别名来源 = manifest `aliases`) |
| manifest 内嵌清单 | herdr/src/detect/manifest.rs:256 | `("octoscode", include_str!("manifests/octoscode.toml"))` |

### 4.5 socket API 关键符号

生成命令:`cd ~/Work/Projects/FW && grep -n 'SOCKET_PATH_ENV_VAR' herdr/src/api/mod.rs herdr/src/session.rs | head -5` 与 `cd ~/Work/Projects/FW && sed -n '160,190p' herdr/src/session.rs`

| 符号 | 位置 | 说明 |
|---|---|---|
| `pub const SOCKET_PATH_ENV_VAR: &str = "HERDR_SOCKET_PATH"` | herdr/src/api/mod.rs:31 | 可用环境变量覆盖 socket 路径 |
| `pub fn api_socket_path_for(name)` | herdr/src/session.rs:169 | `<config_dir>/sessions/<name>/herdr.sock`(默认 `data_dir/herdr.sock`) |
| `pub fn active_api_socket_path()` | herdr/src/session.rs:173 | 优先 `HERDR_SOCKET_PATH`(:177),否则按 session 名 |
| `pub fn client_socket_path_for(name)` | herdr/src/session.rs:183 | `herdr-client.sock`(thin client 用) |
| `pub fn config_dir()` | herdr/src/config/io.rs:30 | 尊重 `XDG_CONFIG_HOME`(:31) |
| Method 变体 | herdr/src/api/schema.rs | `AgentList` :107、`AgentGet` :109、`AgentRead` :111、`AgentSendKeys` :115、`AgentStart` :125、`AgentPrompt` :127、`AgentWait` :129、`PaneSplit` :131、`PaneSendKeys` :171、`PaneRead` :175、`PaneReportAgent` :198、`PaneWaitForOutput` :216 |
| `pub struct AgentPromptParams` | herdr/src/api/schema/agents.rs:176 | 字段 `target` / `text` / `wait: Option<AgentPromptWaitOptions>`(:178-180) |
| `pub enum AgentStatus` | herdr/src/api/schema/common.rs:151 | snake_case:`idle` :152 / `working` :153 / `blocked` :154 / `done` :155 / `unknown` :156 — 注意 API 比 detect 的四态多一个 `done` |
| `handle_agent_prompt` | herdr/src/app/api/agents.rs:62 | server 侧注入实现(见 §6) |
| wait 族 | herdr/src/api/wait.rs | `wait_for_output` :22、`wait_for_agent` :132、`prompt_agent` :177、`wait_for_event` :661 |
| `pub enum AppEvent` | herdr/src/events.rs:56 | `PaneDied` :58、`AgentProcessDetected` :60、`StateChanged` :66、`HookStateReported` :76 |

## 5. 识别契约:herdr/src/detect/manifests/octoscode.toml

生成命令:`cd ~/Work/Projects/FW && cat -n herdr/src/detect/manifests/octoscode.toml`

文件头(:1-5):`id = "octoscode"`、`version = "2026.08.23.1"`、`min_engine_version = 1`、`updated_at = "2026-08-23T00:00:00Z"`、`aliases = ["octos-tui"]`。

| 规则 id | 行 | state | priority | region | 匹配要点 |
|---|---|---|---|---|---|
| `approval_blocked` | :7-18(:8 id / :9 state / :10 priority) | `blocked` | `1100` | `whole_recent` | `visible_blocker = true`(:12);any 子句(:13-18):contains `Approval | y once | s session | n deny`、`Waiting on you`、`Ctrl+R/Alt+A answer`、`审批 | y 本次 | s 本会话` |
| `statusbar_working` | :20-29(:21 id / :22 state / :23 priority) | `working` | `1000` | `bottom_non_empty_lines(6)` | `visible_working = true`(:25);line_regex `state\s*[·,]\s*Working`、contains `Esc interrupt` |
| `statusbar_idle` | :31-40(:32 id / :33 state / :34 priority) | `idle` | `900` | `bottom_non_empty_lines(6)` | line_regex `state\s*[·✓,⚠]*\s*(Idle|Done)`、contains `Tab agents | Ctrl+O expand`、`Ask Octos to change code` |

三条规则与文件逐字一致(抽查复跑见 §9)。

## 6. 注入的服务端门控(外环「注入静默丢失」的源码依据)

生成命令:`cd ~/Work/Projects/FW && sed -n '62,135p' herdr/src/app/api/agents.rs`

`handle_agent_prompt`(herdr/src/app/api/agents.rs:62)顺序检查:

1. 空文本拒绝(:63-65,错误码 `empty_agent_prompt`);
2. blocked 的 agent 拒绝注入(:81-89,错误码 `agent_blocked`,要求交互输入);
3. 未识别 agent / 启动未就绪返回 `agent_not_ready`(:95-98);
4. **前台进程名匹配**:`runtime_hosts_agent(runtime, expected_agent)` 不符 → `agent {} is no longer the pane foreground process`(:105-112)——与 octoscode 文档「双重门:named-agent 名单 + 窗格前台进程名匹配,缺一即丢」对应;
5. 通过后写入文本,再延时发送 `Enter`(`send_bytes_after(…, AGENT_PROMPT_SUBMIT_DELAY)`,:126-127)。

## 7. 外环三原语 → herdr 命令映射(写章骨架用)

| 原语 | 命令 | CLI 函数 | server 处理 |
|---|---|---|---|
| 发现 | `herdr agent list` | herdr/src/cli/agent.rs:438(`agent_list`) | `Method::AgentList`(herdr/src/api/schema.rs:107) |
| 注入 | `herdr agent prompt <target> <text> [--wait] [--until STATUS]... [--timeout MS]` | herdr/src/cli/agent.rs:771(`agent_prompt`) | herdr/src/app/api/agents.rs:62(`handle_agent_prompt`) |
| 观测 | `herdr pane read <pane_id> [--source …]` | herdr/src/cli/pane.rs:455(`pane_read`) | `Method::PaneRead`(herdr/src/api/schema.rs:175);server 侧 wait 族在 herdr/src/api/wait.rs:22(`wait_for_output`) |
| 开窗格 | `herdr pane split … --cwd PATH` | herdr/src/cli/pane.rs:623(`pane_split`) | `Method::PaneSplit`(herdr/src/api/schema.rs:131) |
| 开内环 | `herdr pane run <pane_id> <command>` | herdr/src/cli/pane.rs:1047(`pane_run`) | `Method::PaneSendInput` + Enter(:1050-1056) |
| 等待 | `herdr agent wait <target> [--until STATUS]...` | herdr/src/cli/agent.rs:506(`agent_wait`) | `Method::AgentWait`(herdr/src/api/schema.rs:129);`wait_for_agent` 在 herdr/src/api/wait.rs:132 |

状态值合法集(CLI 侧):`idle | working | blocked | done | unknown`(herdr/src/cli.rs:899-903);pane report 侧另有 `PaneAgentState` 四态解析(herdr/src/cli.rs:910-915,无 `done`)。

## 8. 与 octos 外环机制的衔接点清单(spec 点名文档,均为本次实读)

来源:`octoscode/docs/OLP_QUICKSTART.md`(168 行)、`octoscode/docs/OLP_OUTER_BOOT.md`(178 行)、`octoscode/.octos/loop.md`(13 行)。生成命令:`cd ~/Work/Projects/FW/octoscode && grep -n 'herdr' <doc>`。

1. **依赖表**(octoscode/docs/OLP_QUICKSTART.md:35):herdr「否,推荐」——外环用 `herdr agent prompt` 程序化驱动内环窗格,不装可用 tmux send-keys 降级;**octoscode 窗格识别(`--kind octoscode`)当前在 `feat/octoscode-agent` 分支,从该分支构建**。← 与 §0 版本事实互证:本仓 HEAD 即该分支,提交标题 `feat(detect): add octoscode as a supported agent`。
2. **驾驶舱注入**(octoscode/docs/OLP_QUICKSTART.md:144-145):`herdr agent list` 看窗格,`herdr agent prompt <pane> '<text>'` 即**用户消息级**下发(与 `octos steer` 的独立 user 消息层级同层,herdr 面向窗格、steer 面向 session)。
3. **冒烟验证**(octoscode/docs/OLP_QUICKSTART.md:151):`herdr agent list` 应显示 `octoscode | <pane> | idle`——依赖 §5 的 `statusbar_idle` 规则识别成功。
4. **故障速查**(octoscode/docs/OLP_QUICKSTART.md:162):「herdr 注入静默丢失」双重门 = named-agent 名单 + 窗格前台进程名匹配,缺一即丢;降级 tmux `send-keys`(首字符 `-` 用 `--` 分隔)。← 源码依据 §6 第 4 条。
5. **重启硬清单 §0b**(octoscode/docs/OLP_OUTER_BOOT.md:16-32,四步):serve 起(operator 亲手)→ `/loop resume`(先 `/loop list`)→ 双哨挂载(正 ACK + 负 events.jsonl)→ fallbacks 快照核对。
6. **唤醒与纠偏 §2**(octoscode/docs/OLP_OUTER_BOOT.md:47-58):`herdr agent list` 发现内环窗格;`herdr agent prompt <pane> '<一句话>'` 空闲唤醒、指向黑板新条目编号;master 在途 turn 用 `octos steer` 插话。
7. **观测三层 §3**(octoscode/docs/OLP_OUTER_BOOT.md:60-72):`herdr pane read <pane>`(现场屏幕)+ `tail -f …/data/events.jsonl`(事件)+ `octos goal status / octos peer list`(结构面)。
8. **内环开设 §6**(octoscode/docs/OLP_OUTER_BOOT.md:109-130):`herdr pane run <pane> 'cd <repo> && octoscode --stdio-command "octos serve --stdio --solo --danger-full-access"'` 等三形态(octoscode / claude / codex),开设后发内环上岗词。
9. **内环循环**(octoscode/.octos/loop.md:5-9):被 herdr 驱动的内环按「读黑板 Active 区 → 执行最小编号未 ACK 条目 → 只 commit 不 push → 落 ACK 定式」循环——herdr 注入的 prompt 即该循环的外部触发器。

## 9. 抽查复跑记录(交付前)

生成命令(2026-09-03 复跑,输出与上文数字一致):

```bash
cd ~/Work/Projects/FW && git -C herdr log -1 --format='%H %ci %s'
# fefe5c4ffb90a0f11320d836640dbc040cc28dc5 2026-08-29 17:59:33 +0800 feat(detect): add octoscode as a supported agent
cd ~/Work/Projects/FW && wc -l herdr/src/cli/agent.rs herdr/src/cli/pane.rs   # 949 / 2108
cd ~/Work/Projects/FW && sed -n '440p;774p;860p' herdr/src/cli/agent.rs
# usage: herdr agent list / usage: herdr agent prompt <target> <text> [--wait] ... / usage: herdr agent read <target> ...
cd ~/Work/Projects/FW && sed -n '473p;733p;1049p' herdr/src/cli/pane.rs
# USAGE: herdr pane read ... / usage: herdr pane split ... --cwd PATH ... / usage: herdr pane run <pane_id> <command>
cd ~/Work/Projects/FW && sed -n '256p' herdr/src/detect/manifest.rs
# ("octoscode", include_str!("manifests/octoscode.toml")),
cd ~/Work/Projects/FW && sed -n '7,10p' herdr/src/detect/manifests/octoscode.toml
# id = "approval_blocked" / state = "blocked" / priority = 1100
```

引用自检(AGENTS.md 第 7 条,无 `herdr|octoscode|crates` 前缀的 `.rs` 引用必须为 0):

```bash
grep -o -E '[A-Za-z0-9_./-]+\.rs(:[0-9]+)?' assets/ch21-facts.md \
  | grep -v -E '^(herdr|octoscode|crates)/' | wc -l    # 期望 0
```
