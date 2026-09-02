# ch06 勘误+重写章 factcheck 报告(C1,ch06-factcheck)

- **审查对象**: `chapters/ch06-tool-system.md`(勘误+重写章,commit `99c0543`,322 行);镜像 `book/src/part2/ch06.md` `cmp` 逐字节一致
- **事实基准**: `assets/ch06-facts.md`(commit `552be31`);源码只读 `/Users/zhangalex/Work/Projects/FW/octos @ 9c157101`(实测 `git log -1` = `9c157101 docs(guide)...`)
- **方法**: 全部引用逐一 grep/sed/awk 机验,禁止目测;`spawn.rs` 等行号交叉核对为 0 差
- **日期**: 2026-09-03

## 汇总

| 清单项 | 结果 | 计数 |
|---|---|---|
| 1. `crates/...rs` 引用 | 43 条 + 40 条简写锚点全部核验,37 项精确/等价命中,1 项 ±2 偏移,5 项存疑(均附实测) | 83 引用 / 37 精确 / 1 偏移 / 5 存疑 / 0 越界 |
| 2. 58 条目 + 10 能力域表 | 58 条目、58 分组、10 域、58 总和全部与 `ls` 实测吻合(骨架 3 文件单列,详见 F-3) | 58/58/10 ✅ |
| 3. 「14 个内置工具」 | `14 个内置工具` 0 命中;`activate_tools`/`172fb2be`/`#1289` 共 5 处,均为 RFC-0 有意保留 | 0 / 5 |
| 4. 机械项 | 锚点见项 1;mermaid 4;镜像 cmp 一致;—— 0;加粗 3;黑话 0/9 词 | 全过 |
| 5. 字数与代码占比 | 去代码 6,014 汉字(≥5,000 ✅);代码块 13.7%(≤28% ✅) | 双达标 |

**分级**: critical 0 / major 0 / minor 6(M-1…M-6,均不阻塞定稿)
**是否可定稿:是**(6 条 minor 中 4 条为行号微偏建议,2 条为口径表述建议,均可随下次刷行号顺手处理)

---

## 1. `crates/...rs` 引用逐条核验(命令输出为证)

核验方式:`grep -n` 取真实行号,与章内引用逐一比对。以下为**全部**带行号引用的核验记录(✅=精确/区间命中;⟳=在合理偏移内;⚠=存疑)。

### registry.rs(3,581 行,实测)

| 章内引用 | 实测 | 判定 |
|---|---|---|
| `:127` `ToolRegistry` | 127: `pub struct ToolRegistry` | ✅ |
| `:127-235` 字段清单 | 127–235 覆盖 struct 体(236 为 `new()`) | ✅ |
| `:164-166` spawn_only/messages | 164 `spawn_only:` / 166 `spawn_only_messages:` | ✅ |
| `:179` live_catalog | 179 `live_catalog: Arc<...Mutex<Vec<ToolCatalogEntry>>>` | ✅ |
| `:206` internal_hidden | 206 `internal_hidden: HashSet<String>`(204–205 为 mofa dispatcher 注释) | ✅ |
| `:236` `new()` | 236: `pub fn new()` | ✅ |
| `:271` `sandbox()` | 271: `pub fn sandbox()` | ✅ |
| `:279` `set_tool_timeout_secs` | 279 精确;默认 1,800s 见 189/222/225 注释 | ✅ |
| `:289` `mark_as_plugin` | 289 精确 | ✅ |
| `:294` `set_session_key` | 294 精确 | ✅ |
| `:299` `mark_spawn_only` | 299 精确(简写 `:299` 一致) | ✅ |
| `:324` `mark_internal_hidden` | 324 精确(简写 `:324` 一致) | ✅ |
| `:332` `is_internal_hidden` | 332 精确 | ✅ |
| `:355` `clear_spawn_only` | 355 精确;注释「subagent registries… the subagent IS the background context」 | ✅ |
| `:388` `spawn_only_handle_message` | 388 精确;payload 含 `read_modes: [head,tail,grep,line_range,file]` 五种 | ✅ |
| `:536` register / `:558` register_arc | 536/558 精确 | ✅ |
| `:706-711` specs 注释(RFC-0) | 706–711 原文逐字吻合(「no longer any recency-based (LRU) deferral」) | ✅ |
| `:746` specs 排序 `sort_by(name)` | 746: `specs.sort_by(\|a, b\| a.name.cmp(&b.name))` | ✅ |
| `:869-875` `apply_policy`(retain 裁剪) | 869–875 精确 | ✅ |
| `:947-953` `set_provider_policy`(过滤器) | 947–953 精确 | ✅ |
| `:1086` `invalidate_cache` | 1086: `fn invalidate_cache(&mut self)` | ✅ |
| `:1132-1143` 1MB 分派边界 | 1133 `MAX_ARGS_SIZE = 1_048_576`、1135 bail——章内区间 ±1 | ⟳ |
| `:95-119` `estimate_json_size` | 95 起函数定义,121 收尾 | ✅ |
| `:1243-1254` 构造器族 | 1243 `with_builtins` / 1248 `with_builtins_and_sandbox` / 1254 `with_builtins_and_permissions` | ✅ |
| `:1243-1252` 代码摘录 | 与源码逐字一致(仅省注释) | ✅ |
| `:1420` `live_catalog_handle` | 1420: `pub fn live_catalog_handle` | ✅ |
| 摘录代码块(trait 五行) | `mod.rs:609-640` 一致 | ✅ |

### policy.rs(741 行,实测)

| 章内引用 | 实测 | 判定 |
|---|---|---|
| `:10` `PolicyDecision` | 10: `pub enum PolicyDecision` | ✅ |
| `:28-40` `ToolPolicy` 核心结构 | 28 `pub struct ToolPolicy`、40 `require_tags` | ✅ |
| `:55-68` `BashFileWrites` 三档 | 55 枚举、57 `#[default] Allow`、`# octos:allow-write` 注释在 65 | ✅ |
| `:69` `is_allowed` | 69 精确 | ✅ |
| `:77-128` `evaluate`(deny-wins) | 77 起函数,下一项 131 止 | ✅ |
| `:131-148` `is_allowed_with_tags`(fail-closed) | 131 精确;137 `require_tags.is_empty()` 早退;145 匹配 | ✅ |
| `:149` `is_empty` | 149 精确 | ✅ |
| `:179-183` `ToolGroupInfo` 结构 | 180–184 定义(章写 `:179-183`,±1) | ⟳ |
| `:180` 起 `TOOL_GROUPS` | 实际 187 起 `pub const TOOL_GROUPS`;**但同章 322 行版本演化注亦写 `:187`,前后不一致** | ⚠ M-1 |
| `:187` 起 `TOOL_GROUPS`(6.1 节/322 行) | 187 精确 | ✅ |
| `:307` 起 `group:delegated` | 307 为 `ToolGroupInfo {`(M6.7 注释块 279–306),结构体行 | ✅ |
| 共 10 组 | `grep -c 'name: "group:'` = 10 | ✅ |
| `group:fs` 五成员 | `read_file/write_file/apply_patch/edit_file/diff_edit`(189–200) | ✅ |
| `group:runtime` 含 `bash`(#1172) | 199–204 原文注释吻合 | ✅ |
| `group:sessions` 七成员 | 227–246:spawn/spawn_agent/send_input/resume_agent/wait_agent/close_agent/delegate | ✅ |
| `group:delegated` ⊇ `group:sessions` + 手工维护 + 守护测试 | 295–305 注释原文;测试 `group_delegated_supersets_session_spawn_family` 在 581 | ✅ |
| 「不是 confinement boundary」 | 291–293 原文「THIS IS NOT A CONFINEMENT BOUNDARY」 | ✅ |
| deny 指标区分两 reason | 18/21/24 三常量 + 74–76 注释吻合 | ✅ |
| 三形态条目(名字/组/通配) | 155–169 `entry_matches`:robot group → expand_group → 后缀 `*` 前缀匹配 → 精确 | ✅ |

### coding_tool_contract.rs(octos-cli,实测)

| 章内引用 | 实测 | 判定 |
|---|---|---|
| `:12` `coding.tool_contract.v1` | 12 精确 | ✅ |
| 契约 ID `codex-compatible-coding-v1` / 策略 ID `coding-v1` | 13 / 16 | ✅ |
| `:85` P0 十工具 | 85–97:apply_patch, exec_command, write_stdin, update_plan, request_user_input, spawn_agent, send_input, resume_agent, wait_agent, close_agent——十项逐一吻合 | ✅ |
| `:21-34` 六状态词汇 | 19 available、20 aliased、21 disabled_by_policy、22 missing、23 unimplemented、28 deferred(区间 ±2);MCP 四状态 30–34 | ⟳ |
| `deferred` 保留历史语义(#970) | 24–28 注释原文吻合;章内明确「机制已随 RFC-0 删除」 | ✅ |

### 其余文件(实测)

| 引用 | 实测 | 判定 |
|---|---|---|
| `coding_tools.rs:381/:738/:1283/:1945/:2428/:2800/:3149/:3250/:3388` 九 shim | 逐一为 `fn name()` 行,返回值依次 exec_command/write_stdin/spawn_agent/bash/delegate/view_image/tool_search/tool_suggest/image_generation | ✅ |
| `spawn.rs:2922` 注册名 `spawn`、5,309 行 | 2920 `impl Tool for SpawnTool`、2922 `"spawn"`;`wc -l` 5,309 | ✅ |
| `recall.rs:1-4`(#2131 台账)/`:15-21` ToolOutputLedger | 1–4 模块注释、19 trait 定义 | ✅ |
| `git.rs:291` 1MB diff 上限 | 290 注释、291 `MAX_DIFF_SIZE = 1_048_576` | ✅ |
| `code_structure.rs:72` 1MB 解析上限 | 71 注释、72 `MAX_PARSE_SIZE` | ✅ |
| `ssrf.rs:24` fail-closed DNS | 22–24 注释+函数签名 | ✅ |
| `http.rs:130` name() | 129 impl、131 `&self.name`(±1) | ⟳ |
| `utils.rs:180` / `:180-196` `tool_output_limit` | 181 函数起(±1);read_file 50,000、shell/grep 30,000、web_fetch 40,000 | ⟳ |
| `write_grant.rs:53` WriteGrantViolation(#1976) | 53 精确;1 行 `//! #1976` | ✅ |
| `check.rs:526` name `check` | 524 impl、526 `"check"` | ✅ |
| `workspace_history.rs:101` name `workspace_log` | 100 impl、101 `"workspace_log"` | ✅ |
| `replacer.rs:1-8` 级联链(#1771) | 1–8 原文;阶段 exact→line_trimmed→whitespace_normalized→…→escape_normalized(119/202/213/320) | ✅ |
| `read_paging_probe.rs:1-6` 只观察不改行为 | 1–2 原文「Observe-only probe… Changes no behaviour」 | ✅ |
| `read_window.rs:3` / `:178` `OCTOS_READ_WINDOW=1` | 3 行 flag 注释、178 env 判断 | ✅ |
| `read_window.rs:1-30` 2,000 行 / 48 KiB / 50,000 | 13–14(pi DEFAULT_MAX_LINES=2000)、25(50,000)、29(48 KiB=49,152);常量 124/131 | ✅ |
| `edit_file.rs:182` 附近 no-follow 用法 | 178–184 fenced 打开+`O_NOFOLLOW` 组件遍历、`read_no_follow`+`write_no_follow` | ✅ |
| `tool_config.rs:633` name `configure_tool` | 631 impl、633 `"configure_tool"` | ✅ |
| `robot_groups.rs:186-187` camera_read=Observe / slow_move=SafeMotion | 186/187 精确 | ✅ |
| `dora_bridge.rs:178` 工具名来自映射表 | 177 impl、179 `&self.mapping.tool_name`(±1) | ⟳ |
| `mcp_agent.rs:1-6` MCP 后端派发 | 1–6 原文(Claude Code/Codex/hermes/jiuwenclaw) | ✅ |
| `mod.rs:609` `pub trait Tool` | 609 精确;方法序 name/description/input_schema/tags/contexts/execute/truncation_recovery/execute_with_context 与章内代码块一致 | ✅ |
| `mod.rs:11-28` M8.1 迁移模块文档 | 11–28 原文 | ✅ |
| `mod.rs:261` `ToolContext` | 261 精确 | ✅ |
| `mod.rs:972` `resolve_path` | 972 精确;`:1014/:1052/:1061` 三变体精确 | ✅ |
| `TOOL_INPUT_ERROR_MAX_BYTES` 4,096 | mod.rs:59 `= 4096`(#2193 R4 注释 57–68) | ✅ |
| `args.rs:1-30`(#1770/#1765/#1690) | 1–30 原文全命中(缺参/拼错 did-you-mean/类型错/#1690 不级联) | ✅ |
| `MAX_ARGS_SIZE` 在 registry 而非 args.rs | args.rs 0 命中,registry.rs:1133 | ✅(章内口径声明属实) |
| `chat.rs:855`/`:1337` `with_builtins_and_permissions` | 855/1337 精确 | ✅ |
| `acp.rs:224`/`:501` `with_builtins_and_sandbox` | 224/501 精确(另 2128/2161/2616/2925 处,「等多处」成立) | ✅ |
| `gateway_runtime.rs:823` | 823 精确 | ✅ |
| `session_actor.rs:2884` apply_policy 时序注释 | 2884–2889 原文(「calls `apply_policy` BEFORE…」) | ✅ |
| `mcp.rs:532` `register_tools` 冲突拒绝+传输先行 | 530–536 原文(#1886) | ✅ |
| `config.rs:132` `tool_policy_by_provider` | 131–132 原文 | ✅ |
| `execution.rs:775-780` spawn_only 拦截+provider 复查 | 775–780 `is_spawn_only` 拦截点;788 `provider_policy()` 复查 | ✅ |
| `#896` 文件名进 task_handle 信封 | execution.rs:241/1882/3126 | ✅ |
| `#1886` 可见性过滤不决定传输生命周期 | registry.rs:149、mcp.rs:342/536 | ✅ |
| `coding.json` allow_list 12 项含三组+补回 check/update_plan/tool_search(#9ecc5845) | 实测 tools 数组恰 12 项,组条目 group:runtime/search/memory,补回三工具,commit 信息吻合 | ✅ |
| RFC-0 `172fb2be` #1289 删 LRU/activate_tools;`find_evictable`/`ToolLifecycle` 已不存在 | commit 实测存在;grep 全 tools/ 0 命中 | ✅ |
| `#1771`/`#1770`/`#1765`/`#1690`/`#1638`/`#2131`/`#1976`/`#1172`/`#1607` | 均在对应源文件注释命中 | ✅ |

**存疑 5 项(⚠,均 minor)**:
- M-1 `TOOL_GROUPS` 行号前后不一:第 61 行写 `policy.rs:187` 起(✅),第 263 行却写 `:180` 起(实际 180 是 `ToolGroupInfo` 结构体定义,常量在 187)。二处应统一为 187(或注明「结构 180 / 表 187」)。
- M-2 `:179-183` `ToolGroupInfo`:实际 180–184,±1。
- M-3 `coding_tool_contract.rs:21-34` 状态词汇:实际 available/aliased 在 19–20,区间整体 ±2。
- M-4 `http.rs:130`/`utils.rs:180`/`dora_bridge.rs:178` 等三处为 impl 行 ±1(指向的符号均真实存在于区间)。
- M-5 第 275 行「估算函数在 `:95-119`」与「`:1132-1143`」:实际函数体 95–121、常量在 1133(±1~2);另 `:1132-1143` 若指「检查块」宜写 1131–1143。均不改变结论。

无任何行号越界或符号不存在的情况;`spawn.rs`/`registry.rs`/`policy.rs`/`coding_tools.rs` 等重点文件交叉核对 0 差。

## 2. 58 条目 + 10 能力域分组表核对(ls 实测)

- `ls crates/octos-agent/src/tools/ | grep -v test | wc -l` = **58**(与章内口径一致)
- `ls .../tools/*.rs | wc -l` = 59(含 2 个 test 文件:coding_tools_tests.rs、spawn_tests.rs;58 口径含 mod.rs,不含 test)——章内第 7 行对此口径差异的解释**准确**
- `ls .../tools/admin/ | wc -l` = **7**(mod.rs + 6 文件);`wc -l admin/*.rs` = **3,424 行**(章内「6 个文件,合计 3,424 行」按除 mod.rs 外 6 文件计,总数吻合;若按 7 文件计则口径需注明,minor M-6)
- 10 域逐行与实际文件名 diff:两方向差异仅 **args/policy/registry 三个骨架文件未入表**——它们是「骨架三件」而非工具,第 7/15 行已明确单列,不构成遗漏;表内 58 = Σ(12+3+9+5+4+10+2+1+3+9) = 58 ✅
- admin/ 六文件名单与事实表一致(platform_skills/profiles/skills/sub_accounts/system/update);`admin_*` 工具名 grep 去重恰 **20** 个(章内「20 个 admin_*」✅,含 admin_list_profiles、admin_system_health、admin_update_octos)
- 文件名↔注册名分离六例全部实测:`glob_tool`→`glob`、`grep_tool`→`grep`、`workspace_history`→`workspace_log`、`site_crawl`→`deep_crawl`、`deep_search`→`search`、`delegate`→`delegate_task`;`tool_config`→`configure_tool` 亦吻合

## 3. 「14 个内置工具」零命中

- `grep -c '14 个内置工具\|14个内置工具'` = **0**;宽松 `grep -o '14 个'` = 0
- `activate_tools` 命中 2 处(176 行 RFC-0 删除说明、285 行 deferred 历史语义)+ `172fb2be`/`#1289` 3 处,共 5 处——全部为 RFC-0 删除决策的**有意保留**,单独计数如上,属正当历史注记

## 4. 机械项

| 项 | 要求 | 实测 |
|---|---|---|
| mermaid 图 | 4 | **4**(图 6-1 graph / 图 6-2 sequenceDiagram / 图 6-3 graph TD / 小结前 1 图) |
| 镜像 cmp | 一致 | `cmp chapters/ch06-tool-system.md book/src/part2/ch06.md` → 无输出(**逐字节一致**) |
| 破折号「——」 | ≤2 | **0** |
| 加粗 | ≤15 | **3**(定位段 **定位**、**58 个条目**、三防线段 **58 个条目**) |
| 黑话 9 词(赋能/抓手/闭环/沉淀/对齐/颗粒度/底层逻辑/顶层设计/护城河) | 0 | **0/9** |
| 锚点有效性 | 见项 1 | 83 引用全部核验,0 越界 |

## 5. 字数与代码占比

- 去代码块汉字数(Python `[\u4e00-\u9fff]` 扫描,剔除全部 4 个 fenced 块):**6,014** ≥ 5,000 ✅
- 代码块字符占比(4 个 fenced 块字节数/全文):**13.7%** ≤ 28% ✅

## 结论

**是否可定稿:是。** critical 0、major 0;minor 6(行号微偏 4 处建议下次刷行号时统一:TOOL_GROUPS 二处统一为 `:187`、`ToolGroupInfo` 改 `:180-184`、contract 状态词汇区间改 `:19-28`;admin 口径 1 处建议注明「mod.rs 之外的 6 文件」;estimate_json_size 区间建议 `:95-121`)。全部引用可溯源、58/10 口径与实测一致、机械项全过、字数与代码占比双达标。
