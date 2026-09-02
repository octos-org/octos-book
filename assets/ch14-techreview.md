# Ch14 techreview(C2)— chapters/ch14-runtime-modes.md @ 4d88720

- 审查对象: `chapters/ch14-runtime-modes.md`(372 行,master 4d88720 = pathfix 66 处 + C1 三 P2 修复,已 cp 进工作区)
- 事实基准: `assets/ch14-facts.md`(基准 9c157101);源码只读 `/Users/zhangalex/Work/Projects/FW/octos` @ 9c157101(本轮全部锚点已实读核对)
- 规范: `specs/ch14-runtime-modes.spec.md`

## 计数表

| # | 检查项 | 结论 | 计数 |
|---|---|---|---|
| 1 | 五运行面分派(mod.rs:381-399) | ✅ 通过 | 实测 match 臂 28 个,`Self::Serve` 唯一 `#[cfg(feature="api")]` @ :398(变体声明处 :148) |
| 2 | stdio/solo 语义(octoscode cli.rs:118) | ✅ 通过 | `DEFAULT_STDIO_COMMAND = "octos serve --stdio --solo"` @ cli.rs:118 实存;serve.rs:1541-1546 stdio 分支逐字符一致;bind_http_listener :464;`DATA_DIR_LOCKED_MARKER`="OCTOS_DATA_DIR_LOCKED" @ :490 |
| 3 | 配置四件与热加载 watcher | ✅ 通过 | 四文件 wc -l 实测 3790/7003/608/543 = 11,944(与章内一致);ConfigChange :17、ConfigWatcher :28、new :44、with_profile_defaults :67、spawn :87、diff_and_emit :241 全对;重启项 9 项清单与 :241-315 源码逐一吻合(base_url/api_key_env/sandbox/mcp_servers/hooks/format_after_edit(#1774)/plugins/gateway.queue_mode/gateway.channels) |
| 4 | Feature Flags 门控(Cargo.toml:142 起) | ✅ 通过 | `[features]` @ :142、`default = []` @ :143、embed-llama 系 :147-149、api @ :154(axum/rustls/prometheus…+octos-bus/api+matrix)全对 |
| 5 | 技术公平性:热加载 vs 全重启侧栏 | ✅ 通过 | 「能热加载的只有 system_prompt 与 max_history…每多一项热加载,就要回答两个问题」+ base_url/TLS 撕裂、hooks 熔断计数器、format_after_edit 三处烘焙——三个理由均为源码真实动机(#1774 注释、:252、:266-270),无偏袒 |
| 6 | 论证层数(每面「为什么这样设计」) | ✅ 通过(5/5) | chat=最薄验证面/诊断成本最低;gateway=常驻进程改配置成本最高故为热加载主要消费者;serve=控制面汇聚而非「chat 的 HTTP 外壳」;mcp-serve=粗粒度任务边界 vs 细粒度工具代理取舍;acp+mcp-serve=共同结构约束(stdout 是协议信道)+会话归属差异 |
| 7 | 跨章重复(Ch1/Ch9/Ch18) | ✅ 通过 | Ch1 仅投影引用(「workspace 分层在 CLI 层的投影…附录 A」);Ch9 仅点名 mcp_servers/sub_providers「完整的字段参考都在附录 C」;Ch18 编排面只点名定位;Agent Loop/Bus 均转指第 5/10 章。各处均 ≤3 行,无重复展开 |
| 8 | 结构:DDIA 叙事线 | ✅ 通过 | 五面总览→逐面(chat→gateway→serve→协议服务)→配置体系→Feature Flags→回顾,「共享装配 vs 接入差异」主线贯穿,含两张工程决策侧栏(danger-full-access 绑 solo、热加载边界) |
| 9 | mermaid 5 张与文字一致 | ✅ 通过 | 14-1 拓扑(dispatch :381)与 §14.1.1 一致;14-2 serve 装配(673/750/764/775/1316/1969/1778)与 §14.4.1 清单一致;14-3 门禁决策流与 §14.4.3 表格+`--danger-full-access` 必绑 `--solo` 一致;14-4 MCP session 级分派(run_octos_session:66/handle_request:201/run_session:485)与 §14.5.1 一致;14-5 配置链(5s SHA-256→diff_and_emit:241→HotReload/RestartRequired)与 §14.6.3/6.4 一致 |
| 10 | 28 子命令(C1 已修 27→28) | ⚠️ 残留 2 处「27」 | 正文 3 处已改 28(:7/:32/:372);但 **:17「27 个变体」与 :367 思考题 4「27 个命令结构体」仍是 27**。事实:enum Command 变体实测 28 个(含 :148 `#[cfg(feature="api")] Serve`)。事实表 assets/ch14-facts.md:13 也仍写「27 个用户子命令」——按 4d88720 的修复口径(5 处 27→28),:17/:367 属同类漏改,非新错误 |

## 逐项证据(critical 项附源码行号)

### 1) 五运行面分派 — 通过
- `impl Executable for Command` 的 match 起 `crates/octos-cli/src/commands/mod.rs:381`(`fn execute(self)` @ :381-382,match @ :383),臂内 `Self::Account…Self::Peer` awk 实数 28;章内引用 `mod.rs:381-399` 与 `:398-399`(cfg 门)均命中。
- `pub enum Command` @ mod.rs:114;`#[cfg(feature = "api")] Serve(ServeCommand)` @ :148-149(分派臂 :398)。main.rs:61 `fn main`、:80 `config_layer::apply`、:85-86 serve log_dir 门、:101 `args.command.execute()` 四锚点全对(C1 已修)。
- 行数复核:main.rs 268、mod.rs 468、chat.rs 4143、gateway/ 7595、serve.rs 2849、mcp_serve.rs 1138、acp.rs 3024,合计 19,485 ✅;config 四件 11,944 ✅。
- REST 67:spec 口径命令在事实表,facts 复跑 ≥2 次;章内使用与 spec 一致。

### 2) stdio/solo — 通过
- serve.rs:1541-1546 章内代码块与源码逐行一致(stdio_connection → stop_all → return Ok)。
- octoscode/src/cli.rs:118 `pub const DEFAULT_STDIO_COMMAND: &str = "octos serve --stdio --solo";` 实存。
- 门禁表(§14.4.3)与事实表 2.2 逐行一致;`--port` 默认 50080 @ serve.rs:324 ✅;mcp-serve `--bind` 默认 `127.0.0.1:4033` @ mcp_serve.rs:86、HTTP 缺 `OCTOS_MCP_SERVER_TOKEN` 拒启动 @ :185-189(章写 :185-186,区间内含所述报错,可接受)。
- `--instance-data-dir` 共享 state home/私有 runtime dir 的表述与 serve.rs:673(ProfileStore::open state_home,data_dir)装配一致。

### 3) 配置四件与 watcher — 通过
- config_layer.rs:40 `LAYERED_COMMANDS = ["serve","gateway","chat"]`、:48 `apply`、:5-8 优先级链文档(`显式 CLI flag > env var > config.json cli.<cmd> > built-in default`)与章 14.6.1 逐字对应;value_source 作「显式与否」oracle(:15 注释)与章内表述一致;danger/yolo/secrets 排除(:33-34、:103-104、:164-177)与「危险开关与密钥字段被显式排除」一致。
- config_watcher.rs:17-25 ConfigChange 枚举章内代码块与源码一致;5 秒硬编码轮询(spawn :87-93,#149 注释);SHA-256 比对(首行文档);provider/model 不走 watcher 自动应用(:247-249 注释「live swap via SwappableProvider」)与章内「显式路径 SwappableProvider.swap」一致 ✅。
- profiles.rs 锚点:ProfileConfig:181、ProfileConfigPatch:741、LlmProfileConfig:814、LlmModelSelectionConfig:824、LlmRouteConfig:881 全命中;keychain 解析 profile_factory.rs:108/149(`resolve_env_vars`)命中。
- typed schema:`#[serde(deny_unknown_fields)]` @ config.rs:314/338/414,「config.rs:273 附近注释」为邻域引用(实测 273 附近是 plugins.require_signed 注释,deny_unknown_fields 实体在 :314+)——区间锚略偏但机制描述真实存在,记 P3 观察项,不阻断。

### 4) Feature Flags — 通过
- Cargo.toml:142 `[features]`、:143 `default = []`、:147-149 embed-llama/-metal/-cuda、:154 api(含 matrix 连带,章内「连带 octos-bus/api 与 matrix」与源码注释「matrix is pulled in unconditionally」语义一致)。章内频道门列表 12 个与 facts §4 一致。

### 5) 技术公平性 — 通过
侧栏「热加载与全重启的边界」不是站队:先承认热加载短清单的代价(每项要回答旧值/新值与回滚两问),再给不可热加载的三个机理(TLS 撕裂、hooks 熔断计数器、AgentConfig 烘焙),全部可回溯到 #1774 与 watcher 源码;结尾给出可推广原则而非教条。「danger-full-access 必绑 solo」侧栏同样给推广形式(复用已审计信任链)。无技术偏袒。

### 6) 论证层数 — 通过(每面一段「为什么」)
见计数表 #6;均落在章内对应小节(§14.2 chat、§14.3 gateway、§14.4 serve、§14.5.1 mcp-serve、§14.5.2 acp)。

### 7) 跨章重复 — 通过
grep 复核:Ch1 投影引用 2 处、Ch9 点名 1 处(转附录 C)、Ch18 点名定位 3 处、Ch5/Ch10/Ch17 互引均为「细节见 X 章」单句。均 ≤3 行。

### 8) mermaid 5 张 — 通过(与文字一致)
逐图节点/行号锚点对照见计数表 #9;无图中出现而正文否认(或反之)的节点。

### 10) ⚠️ 唯一发现:两处「27」残留(P2)
- `chapters/ch14-runtime-modes.md:17`:「27 个变体每个对应一个命令结构体」→ 应为 28(enum 实测 28 变体)。
- `chapters/ch14-runtime-modes.md:367`(思考题 4):「27 个命令结构体要付出什么代价」→ 应为 28(或改「28 个」保持与全文口径一致)。
- 关联:事实表 `assets/ch14-facts.md:13`「27 个用户子命令」与 spec「事实边界」同写 27——若以 4d88720「28 子命令」修复口径为准,事实表也需同步;但这超出本章审查对象,仅报告。
- 定性:同一修复批次(pathfix 4d88720 明言「27→28 子命令 5 处」)的漏改,非技术性错误;两处均在低风险位置(枚举描述、思考题),不影响任何机制表述。

## 结论:是否可定稿

**可定稿(条件:修复 2 处「27」残留)。**

- P0/P1:0 项。五运行面分派、stdio/solo 链、配置四件、watcher 重启清单、Feature Flags 门控、REST 67、行数 19,485/11,944 等全部 critical 锚点经只读源码 @ 9c157101 逐条复核命中。
- P2:1 项(两处「27」→「28」,chapters/ch14-runtime-modes.md:17、:367)。修复后即可定稿;修复本身是两词替换,无连带。
- P3:2 项观察(不阻断):(a) config.rs:273 typed-schema 邻域锚偏(deny_unknown_fields 实体在 :314);(b) 事实表 facts:13 的「27」与 master 修复口径不同步,建议下一批事实表维护时一并对齐。
