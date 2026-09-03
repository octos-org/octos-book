# Ch21 techreview(C2,ch21-techreview,2026-09-03)

> 审查对象:`chapters/ch21-herdr.md`(master e42e2f9 拷入)。事实基准:`assets/ch21-facts.md`。源码只读:herdr @ `fefe5c4f`(分支 `feat/octoscode-agent`,工作树 clean,已核)、octos @ `9c157101`、octoscode 文档 168/178 行已核。规范:`specs/ch21-herdr.spec.md`。只报告,不改稿。

## 计数表

| # | 类别 | 级别 | 数量 | 结论 |
|---|---|---|---|---|
| 1 | 机制描述正确性(README 四承诺 / 三规则 manifest / 三原语全链 / TUI 层级侧栏 / 外环九点) | — | 0 错 | ✅ 机制性陈述全部与源码一致 |
| 2 | 引用行号漂移(路径对、符号对、行号错) | **critical** | 11 | ❌ 需机械修正(spec 场景 `review_ch21_refs_valid` 不过) |
| 3 | 引用区间不精确(区间部分覆盖所述代码) | minor | 3 | ⚠️ 建议一并修 |
| 4 | 技术公平性(herdr vs tmux/SSH 取舍) | — | 0 错 | ✅ 公允(见 §公平性) |
| 5 | 跨章重复(Ch19/Ch20 ≤3 行) | — | 0 超 | ✅ 边界划清,无复述条款 |
| 6 | 结构(DDIA 叙事线、mermaid×3 与文字一致) | — | 0 错 | ✅ 三图与源码/正文一致 |
| 7 | pathfix 后引用风格 | — | 0 违例 | ✅ 无裸 `.rs` 引用(grep 复跑 = 0) |

**总计:critical 11 / minor 3 / 机制错误 0。可定稿:条件可定稿——机制与结构零缺陷,仅行号引用需机械修正后即达 spec 完成条件。**

## 证据

### A. 机制正确性(逐项核对源码,全部通过)

1. **README 四承诺**:`herdr/README.md:29`(the runtime your coding agents live on)、:31-34 四条、:35 双一等公民、:37 one rust binary、:71 development——逐行 sed 核对,全对。
2. **三规则 manifest**:`octoscode.toml` 恰 40 行;`approval_blocked`(blocked/1100/whole_recent/visible_blocker + 4 条 any 子句)、`statusbar_working`(working/1000/bottom_non_empty_lines(6)/visible_working)、`statusbar_idle`(idle/900/bottom_non_empty_lines(6));version `2026.08.23.1`、min_engine_version 1、aliases `octos-tui`——与 `cat -n` 逐字一致。`Agent::ALL` 24 个(:71)、`SCREEN_MANIFEST_AGENTS` 22 个——计数正确。
3. **三原语全链(CLI→schema→server)**:list = `agent_list`(cli/agent.rs:438,usage :440)→ `Method::AgentList`(schema.rs:107)✓;prompt = `agent_prompt`(:771,usage :774,`--until`/`--timeout` 须配 `--wait` 在 :825/:828 逐字核对)→ `AgentPrompt`(:127)→ `AgentPromptParams` 三字段(schema/agents.rs:176,:178-180)→ `handle_agent_prompt`(app/api/agents.rs:62)✓;read = `pane_read`(cli/pane.rs:455,USAGE :473)→ `PaneRead`(:175)✓;wait = `agent_wait`(:506)→ `AgentWait`(:129)→ `wait_for_agent`(api/wait.rs:132)✓;split(:623,:624 读 `HERDR_PANE_ID`)→ `PaneSplit`(:131)✓;run(:1047-1056,文本+Enter 经 `PaneSendInput`)✓。
4. **四道门**:`handle_agent_prompt` 顺序 = 空文本 `empty_agent_prompt`(:63-65)→ blocked `agent_blocked`(:81-89)→ 未识别/启动未就绪 `agent_not_ready` → 前台进程 `runtime_hosts_agent`(app/agents.rs:421,内部 `foreground_job` = detect/mod.rs:347)错误码同为 `agent_not_ready`、文案 agent … no longer the pane foreground process——与正文及 OLP_QUICKSTART.md:162「双重门」互证,全部正确。300ms 补发 Enter(`AGENT_PROMPT_SUBMIT_DELAY` :13、使用 :126)✓;Copilot 先发 focus gained(:111)✓。
5. **状态两层集合**:`AgentStatus` 五态含 done(common.rs:151-156)、`AgentState` 四态无 done、`parse_agent_status`(:897,:899-903)收五值、`parse_pane_agent_state`(:910-915)收四值——正文「`--until done` 等不到」的推断成立。
6. **TUI 层级侧栏**:`encode_api_submission_parts`(api_helpers.rs:48)按终端模式编码 + Enter,证实「走输入框而非 API」;与 `octos steer`(面向 session)的对照与 OLP_OUTER_BOOT §2 一致,技术判断成立。
7. **外环九点衔接**:依赖表 QUICKSTART:35、注入 :144-145、冒烟 :151(`octoscode | <pane> | idle` 依赖 statusbar_idle)、故障 :162、重启硬清单 §0b(OUTER_BOOT:16-32 四步)、唤醒纠偏 §2(:47-58)、三层观测 §3(:60-72)、内环开设 §6(:109-130)、loop.md:5-9 维护循环——九点全部在文档实文核对通过;events.jsonl 负哨「可追认 tail」的运维语义与 §3 路径模式(`~/.octos/instances/<实例>/profiles/<档>/data/events.jsonl`)一致。
8. **平台坑**:Linux-only(flock+PDEATHSIG,§3.5 原文 Linux-only … 非 Linux unsupported)✓;`OCTOSCODE_NO_AUTO_INSTALL` 源头 backend_ensure.rs:60 `OPT_OUT_ENV` ✓;fork 分支静默不识别的推理链(unknown 无告警、prompt 报 agent_not_ready)与源码行为一致。
9. **体量**:`src/` 245 个 `.rs` 复跑一致;分层行数与事实表一致(事实表为基准)。

### B. critical:行号漂移(11 处,路径与符号全对,行号与 fefe5c4f 实测不符)

复跑命令:`cd ~/Work/Projects/FW/herdr && grep -n -E 'pub enum AgentState|SCREEN_MANIFEST_AGENTS|pub fn agent_label|pub fn parse_agent_label|SOCKET_PATH_ENV_VAR|"agent" =>|"pane" =>' src/detect/mod.rs src/api/mod.rs src/cli.rs`

| # | 章节引用(现值) | 实测 | 证据 |
|---|---|---|---|
| 1 | `herdr/src/detect/mod.rs:13`(AgentState) | **:11** | `11:pub enum AgentState {` |
| 2 | Idle `:15` | **:13** | `13:    Idle,` |
| 3 | Working `:17` | **:15** | `15:    Working,` |
| 4 | Blocked `:18` | **:17** | `17:    Blocked,` |
| 5 | SCREEN_MANIFEST_AGENTS `:96` | **:98** | `98:    pub const SCREEN_MANIFEST_AGENTS: [Self; 22]` |
| 6 | `Self::Octoscode` 在 `:118` | **:120** | `120:        Self::Octoscode,`(SCREEN_MANIFEST 尾项) |
| 7 | `agent_label` `:144` | **:124** | `124:pub fn agent_label`(渲染臂 `:149` 正确) |
| 8 | `parse_agent_label` `:207` | **:188** | `188:pub fn parse_agent_label`(octoscode 臂 `:225` 正确) |
| 9 | `SOCKET_PATH_ENV_VAR` 常量 `herdr/src/api/mod.rs:31` | **:20** | `20:pub const SOCKET_PATH_ENV_VAR: &str = "HERDR_SOCKET_PATH";` |
| 10 | `"agent"` 路由 `herdr/src/cli.rs:125` | **:120** | `120:        "agent" => agent::run_agent_command(...)` |
| 11 | `"pane"` 路由 `herdr/src/cli.rs:127` | **:122** | `122:        "pane" => pane::run_pane_command(...)` |

注:Unknown `:19`、`Agent::Octoscode` `:67`、`ALL` `:71`、`interactive_agent_executable` `:153`/`:184`、臂 `:149`/`:225` 均正确——漂移集中在上述符号,非整体平移,判断为事实表誊抄错位(事实表 §4.4/§4.5 同样带错,修章时应连带修 `assets/ch21-facts.md` 对应行)。

### C. minor:区间不精确(3 处)

| # | 现值 | 建议 | 证据 |
|---|---|---|---|
| 1 | 第四道门 `:105 至 :112` | 检查在 **:101**,报错文案 :103-110(`no longer the pane foreground process` 在 :106) | app/api/agents.rs `101: if !super::super::agents::runtime_hosts_agent(...)` |
| 2 | Copilot 特例 `(:112 起)` | **:111** | `111: if expected_agent == Agent::GithubCopilot {` |
| 3 | agent_not_ready `(:95 至 :98)` | 未识别在 **:92-94**(`effective_known_agent` :92),启动未就绪在 :95-98 | grep :92/:95 |

### D. 公平性 / 跨章 / 结构 / 风格

- **公平性**:降级路径诚实(send-keys = 无门控裸键入,双重门/等待/`--until` 全丢,「从驾驶舱退回遥控器」);herdr 自身代价写足(识别契约漂移、双重门静默丢失、fork 未合入、macOS 锁缺位);与 `octos steer` 定位互补不互斥。未见贬低替代方案或回避自身短板,公允。可选补强(非必须):对「纯 tmux 脚本为主方案」的取舍只以降级形态出现,未正面比较,但 QUICKSTART 原文口径即如此,不算失实。
- **跨章重复**:21.7 三段边界声明 + 全文对 Ch19/Ch20 只引用不复述;R1-R7/ACK 语法/黑板条款零复述。≤3 行达标。
- **mermaid×3**:拓扑图(写文本+Enter / 尾部采样 / Method 枚举)、时序图(四门顺序与错误码、300ms 补 Enter、detect 命中)、双哨状态图(mounted/healthy/visible_stall/blind)与源码及正文逐点一致,无矛盾。
- **引用风格**:复跑 `grep -o -E '[A-Za-z0-9_./-]+\.rs(:[0-9]+)?' chapters/ch21-herdr.md | grep -v -E '^(herdr|octoscode|crates)/' | wc -l` = **0** ✓;octoscode 文档引用均带相对路径。

## 是否可定稿

**条件可定稿(YES after mechanical fix)。** 机制描述、图表、公平性、跨章边界、引用风格全部通过,零机制性错误;唯一拦路的是 B 表 11 处 critical 行号漂移(连带 C 表 3 处区间收紧),全部为机械替换、无文字改写。按 spec 完成条件 `review_ch21_refs_valid`(区间内确实含所述符号)当前不过;修正 B/C 两表后本章即达定稿标准,无需再送一轮完整技术审查(修正后抽查 B 表 11 行即可)。
