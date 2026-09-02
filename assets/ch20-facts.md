# Ch20 事实表 — OctoLoop 外环协议 OLP v2(源码载体定位)

- 基准:
  - octos 主仓 `main` @ `9c157101`(9c1571016e5ea86955b4b3486c04f0359dfff339;goal/peer/ledger 交叉面与 ch18-facts 同基准)
  - octoscode `main` @ `1129fa33`(1129fa331faee8f8cbd350815d8a89af5ee3d01e;即 spec 指定分析基线 octoscode main @ 1129fa33)
  - herdr `feat/octoscode-agent` @ `fefe5c4f`(fefe5c4ffb90a0f11320d836640dbc040cc28dc5)
  - octos-book `rewrite-v2` @ `42660d7`(本 peer worktree HEAD)
- 日期:2026-09-03 · 产出:peer A(ch20-facts,lane cheap)· octos/octoscode/herdr 三仓只读,本 worktree 只新增本文件,未 commit
- 路径约定:代码与测试引用一律带 `octoscode/…`(octoscode 仓)或 `crates/…`(octos 主仓)全路径前缀,符合 AGENTS.md 第 7 条硬规则。
- 生成命令约定:`OC=/Users/zhangalex/Work/Projects/FW/octoscode; O=/Users/zhangalex/Work/Projects/FW/octos; B=/Users/zhangalex/Work/Projects/FW/octos-book` 后执行;下述行号均已在本会话于上述 commit 上逐条复跑。

基准复核命令:
```bash
git -C $O  rev-parse --short=8 HEAD   # 9c157101
git -C $OC rev-parse --short=8 HEAD   # 1129fa33
git -C /Users/zhangalex/Work/Projects/FW/herdr rev-parse --short=8 HEAD  # fefe5c4f
git -C $B  rev-parse --short=8 HEAD   # 42660d7(peer worktree)
```

---

## 1. 协议文本与文档载体(octoscode 仓,7 件)

| 文件 | 行数 | 关键锚点(行号 @1129fa33) |
|---|---|---|
| `octoscode/docs/OUTER_LOOP_PROTOCOL.md` | 403 | 头部 `protocol: olp/v2` :7;v1→v2 变更 #38-r1 :12-15;角色 :19;L0 信道矩阵 :27(下行 :29 / 上行 :39);协议语义 :50(**R1** :52 / **R2** :67 / **R3** :71 / **R4** :74 / **R4b** :77 / **R5** :89 / **R7** :91 / **R6** :103);接入清单 :106;路线 :160;v0 实验记录 :196;实战沉淀·第二辑 :218;已知局限 :345;**附录 A** result.md frontmatter v1 :354;**附录 B** sub_providers 车道模板 :375;双环搭配矩阵 :393 |
| `octoscode/docs/OLP_OUTER_BOOT.md` | 178 | 外环上岗卡:0 身份与署名 :10;0b 重启硬清单 :16;1 黑板(权威账本) :34(条目预算档:修订 5-10M / 切片 10-20M / 战役 30-50M);2 唤醒与纠偏 :47(herdr prompt :42-45、octos steer :49-53);3 观测三层 :60;3.5 主审权锁 :74;4 复验与代推 :87;5 安全红线 :99;6 内环选型与开设 :109;7 战术手册 :143 |
| `octoscode/docs/OCTOLOOP_GUIDE.md` | 563 | 上篇使用指南 :14(三模式 :66,goal/peer 上手 :116);平台支持矩阵 :221(Linux 全功率 :227;macOS 两缺口 :229——outer-duty 不可用退回值班簿纪律层、bwrap 档不成立);下篇机制 :244(角色 :248、信道矩阵 :263、第五信道「五」:274);R1-R6 机制版 :302/:320/:332/:344/:352/:372/:378;goal 状态机 :390;peer 生命周期 :417;model 车道解析 :444;result.md frontmatter v1 六字段 :460;goal 状态存储拓扑 :472;五项引擎机制 :497 |
| `octoscode/docs/OCTOLOOP_FEATURES.md` | 55 | 一页功能全景:稳性与自治 :8;结果与审计 :30;通信与信道 :40;命名 :52 |
| `octoscode/docs/PEER_GOAL_ARCHITECTURE.md` | 481 | goal/peer 架构(Ch18 交叉):架构总览 :67;Fleet :269;Budget 控制 :281;关键设计决策 :290;代码组织 :341 |
| `octoscode/docs/OUTER_LOOP_REVIEW.md` | 497 | octoscode 仓自带参考黑板(v1 ACK 定式说明 :4;### 编号条目 :11 起) |
| `octoscode/AGENTS.md` | — | :3 `protocol: olp/v2 — 完整协议见 docs/OUTER_LOOP_PROTOCOL.md`(R6 版本协商的第二落点,契约测试钉住双处一致) |

生成命令:
```bash
wc -l $OC/docs/{OUTER_LOOP_PROTOCOL,OLP_OUTER_BOOT,OCTOLOOP_GUIDE,OCTOLOOP_FEATURES,PEER_GOAL_ARCHITECTURE,OUTER_LOOP_REVIEW}.md
grep -n -E "^#{1,3} " $OC/docs/OUTER_LOOP_PROTOCOL.md          # 章节锚点
grep -n -E "R[0-9]b? —" $OC/docs/OUTER_LOOP_PROTOCOL.md        # R1-R7 条款行号
grep -n "protocol: olp" $OC/AGENTS.md $OC/docs/OUTER_LOOP_PROTOCOL.md
```

## 2. workspace 双环脚手架(octos-book)

| 文件 | 规模 | 说明 |
|---|---|---|
| `octos-book/.octos/loop.md` | 13 行 | 内环维护循环(master 每轮唤醒执行):读板 → 取编号最小未 ACK 条目执行到完成 → 补 `ACK(done|wontdo\|blocked): <说明>`;无未 ACK 则检查在途 goal;纪律:只 commit 不 push、黑板只追加。Markdown 约定层,**无 Rust 实现** |
| `octos-book/.octos/OUTER_LOOP_REVIEW.md` | 465 行 | 外环审查黑板(权威账本):29 个 `### ` 编号条目、71 处 `ACK(` 行;同目录伴生 `OUTER_LOOP_REVIEW.md.lock`(olp-board-append.sh 的 flock 锁文件) |

注:本 peer worktree 的 `.octos/` 只有 `loop.md`——黑板被加入 `.gitignore`(olp-init.sh 第 3 步,「分支无关,避免跨分支裂脑」),465 行黑板实体在主 checkout `/Users/zhangalex/Work/Projects/FW/octos-book/.octos/OUTER_LOOP_REVIEW.md`。黑板、ACK、loop.md 全部是 Markdown 约定,无任何 Rust 实现;唯一机械强制是契约测试对快照的 grep(见 §5)。

生成命令:
```bash
wc -l $B/.octos/loop.md $B/.octos/OUTER_LOOP_REVIEW.md
grep -c "^### " $B/.octos/OUTER_LOOP_REVIEW.md   # 29
grep -c "ACK("  $B/.octos/OUTER_LOOP_REVIEW.md   # 71
ls $B/.octos/OUTER_LOOP_REVIEW.md.lock
```

## 3. 第五信道:octoscode/src/olp_mcp.rs(406 行,关键符号)

| 符号 | 行号 | 值 / 说明 |
|---|---|---|
| `PROTOCOL_VERSION` | 21 | `"2024-11-05"`(MCP 握手协议版本) |
| `SERVER_NAME` / `SERVER_VERSION` | 22 / 23 | `"olp-mcp"` / `"0.2.0"` |
| `SIGNATURE` | 24 | `"MCP(ask_outer)"`(黑板署名) |
| `ASK_TIMEOUT_SECS` | **25** | `90.0`(ask_outer 超时降级秒数) |
| `ASK_POLL_INTERVAL_SECS` | 26 | `0.5` |
| `ASK_QUOTA_PER_SLICE` | **27** | `3`(每切片问询上限,防思考外包) |
| `BOARD_RELATIVE` | 28 | `"OUTER_LOOP_MCP.md"`(MCP 黑板) |
| `DEGRADED_GUIDANCE` / `QUOTA_REFUSAL` / `TRIED_REFUSAL` | 30 / 31 / 32 | 三段固定中文话术(降级/超限/tried 空) |
| `outer_root()` | 36 | 默认 `~/.octos/outer`,`OLP_MCP_OUTER_ROOT` 可覆盖 |
| `serve()` | 46 | 逐行 JSON-RPC 主循环,返回 ask_outer 派发数 |
| `OlpMcpServer::new` | 108 | |
| `board_append` / `audit` | 125 / 150 | 落板与审计(调 board_append.sh) |
| `ask_outer` | **174** | tried 空 → 拒绝 :184-187;quota ≥3 → 拒绝 :189-196 |
| `report_blocked` | 255 | 直通落板(第二工具) |
| `handle_request` | 275 | initialize :281、tools/list :286 |
| `tools_schema()` | 328 | 恰好两个工具 |

CLI 接线:`octoscode/src/cmd/olp_mcp.rs`(20 行)`run()` :6,`OLP_MCP_TIMEOUT_SECS` 环境变量覆盖默认超时 :8-10;`octoscode/src/cmd/mod.rs` `SUBCOMMANDS` :28(含 `"olp-mcp-serve"`、`"outer-duty"`)、`Route::OlpMcpServe` 派发 :47。挂载方式:内环 profile `~/.octos/profiles/<id>.json` 的 `config.mcp_servers`,`command` 指 octoscode 二进制、`args` 为 `["olp-mcp-serve"]`(协议文档 :131-137;改配置须新会话,工具表会话建立时快照)。

生成命令:
```bash
wc -l $OC/src/olp_mcp.rs
grep -n -E "ASK_TIMEOUT_SECS|ASK_QUOTA_PER_SLICE|SIGNATURE|PROTOCOL_VERSION|SERVER_NAME|SERVER_VERSION|ASK_POLL_INTERVAL|BOARD_RELATIVE" $OC/src/olp_mcp.rs
grep -n "pub fn\|fn tools_schema" $OC/src/olp_mcp.rs
```

## 4. 主审权锁 R7:octoscode/src/outer_duty.rs(476 行,Linux-only)

| 符号 | 行号 | 说明 |
|---|---|---|
| `#![cfg(target_os = "linux")]` | **24** | 整个模块 macOS 上不编译(「honest shrink」);非 Linux 走 cmd 层 unsupported |
| `DutyState` | **34** | 三态枚举 `Vacant`/`Held`/`Error`;`as_str` :43 输出 `"VACANT"`/`"HELD"`/`"ERROR"`(stdout 单行、机器可读;Error 绝不伪装成 VACANT) |
| `LOCK_DOMAIN` | 55 | `"octoscode/outer-duty/v1"`(锁名域前缀) |
| `PROBE_COLLISION_RETRY_MS` | 59 | `2_000`(探测碰撞重试窗) |
| `lock_path()` | 63 | `~/.octos/outer/duty/<sha256>.lock`;HOME 缺失 fail-closed |
| `lock_digest()` | **83** | SHA-256(`LOCK_DOMAIN` ++ NUL ++ canonical path)→ 64 位小写十六进制;不用 DefaultHasher(跨 Rust 版本不稳定) |
| `DutyHold` | 99 | fd 即锁(唯一持有者,CLOEXEC 不外泄) |
| `acquire()` | 162 | flock 持锁 + tighten 文件权限 + 写 metadata sidecar |
| `check()` | **220** | 仅观察、绝不夺取 |
| `write_metadata` / `read_metadata` / `held_diagnostics` | 259 / 311 / 318 | sidecar 与一切 TTL 仅诊断、绝不参与裁定 |
| `spawn_holder_child()` | **345** | setpgid + `PR_SET_PDEATHSIG(SIGKILL)` 守护式死亡耦合(:345-380,含 fork/prctl 竞态处理);wrapper 亡 ⇒ agent 必亡 ⇒ 锁 VACANT |

CLI 层:`octoscode/src/cmd/outer_duty.rs`(98 行)`run()` :10(hold/check 二动作)、`run_hold()` :45(`--` 后必须带子命令)、check 输出分支 :25-42;`octoscode/src/cmd/mod.rs` `mod outer_duty` :17、`Route::OuterDuty` :49、`OuterDutyArgs` :79(`--` 分隔 agent 启动命令)、`parse_outer_duty_args` :93。上岗命令形如 `octoscode outer-duty hold --project P --signature S --duties D -- <agent>`;macOS 语义退回值班簿纪律层 + operator 裁决(octoscode/docs/OCTOLOOP_GUIDE.md:229),macOS reaper 需求已立项 `knowledge/requirements/req-olp-duty-macos.md`(spec 点名,octoscode 仓)。

生成命令:
```bash
wc -l $OC/src/outer_duty.rs
grep -n -E "cfg\(target_os|pub enum DutyState|LOCK_DOMAIN|PROBE_COLLISION_RETRY|pub fn lock_path|pub fn lock_digest|pub struct DutyHold|pub fn acquire|pub fn check|pub fn write_metadata|pub fn read_metadata|pub fn held_diagnostics|pub fn spawn_holder_child" $OC/src/outer_duty.rs
grep -n -E "DutyState|lock_digest" $OC/src/outer_duty.rs | head
```

## 5. 契约测试三件(用例名与行号 @1129fa33)

`octoscode/tests/olp_contract.rs`(367 行,8 个 `#[test]`;快照 grep 型——黑板/ACK 的唯一机械强制):

| 行号 | 用例 |
|---|---|
| 96 | `olp_ack_lines_match_v1_grammar`(ACK v1 定式语法,历史行豁免) |
| 120 | `olp_ack_exemption_is_bounded_whitelist` |
| 159 | `olp_ack_rejects_unknown_status` |
| 178 | `olp_lane_template_parses`(附录 B 车道模板可解析) |
| 215 | `olp_version_consistent_across_docs`(protocol: olp/v2 双处一致) |
| 252 | `olp_result_schema_fields_documented`(frontmatter v1 六字段) |
| 303 | `outer_duty_wiring_three_surfaces_consistent`(protocol/boot/skill 三面一致) |
| 329 | `outer_duty_docs_pin_guardian_semantics_and_h1` |

辅助 fn:`ack_line_matches_v1` :30、`blackboard_ack_lines` :51、`is_exempt_legacy_ack` :89。

`octoscode/tests/olp_mcp_contract.rs`(290 行,7 个 `#[test]`,真实子进程 stdio):
:98 `self_test_initialize_handshake`;:115 `self_test_tools_list_exactly_two`;:144 `self_test_ask_outer_roundtrip`;:209 `self_test_ask_outer_timeout_degrades`;:227 `self_test_ask_outer_quota_refusal`;:246 `self_test_ask_outer_requires_tried`;:266 `self_test_report_blocked_board_only`。

`octoscode/tests/outer_duty_contract.rs`(745 行,10 个 `#[test]`,真实进程):
:174 `duty_two_contenders_exactly_one_wins`;:288 `duty_wrapper_death_kills_agent_and_releases`;:371 `duty_grandchild_lingering_yields_vacant`;:446 `duty_check_does_not_disturb_holder`;:475 `duty_corrupt_metadata_keeps_ownership`;:526 `duty_files_tighten_preexisting_permissive`;:579 `duty_error_never_vacant_for_bad_inputs`;:605 `duty_stdout_single_line_with_hostile_metadata`;:650 `duty_lock_digest_golden_and_convergence`;:709 `duty_create_dir_failure_is_error`。

生成命令:
```bash
grep -n "#\[test\]" -A1 $OC/tests/olp_contract.rs $OC/tests/olp_mcp_contract.rs $OC/tests/outer_duty_contract.rs | grep "fn "
wc -l $OC/tests/{olp_contract,olp_mcp_contract,outer_duty_contract}.rs
```

## 6. 脚本与技能载体(octoscode 仓)

| 文件 | 行数 | 关键锚点 |
|---|---|---|
| `octoscode/scripts/olp-board-append.sh` | **24** | 黑板原子追加唯一正道:`exec 9>"$LOCK"` :20、`flock -x 9` :21、整条目一次性 `cat >> "$BOARD"` :22;条目正文从 stdin 喂 |
| `octoscode/scripts/olp-init.sh` | **106** | 一键铺设 OLP 脚手架:依赖体检 :17-38;生成 `.octos/loop.md` :45-60(heredoc);生成 `.octos/OUTER_LOOP_REVIEW.md` :63 起;黑板加入 .gitignore(头注 :8);幂等绝不覆盖(:13-14);不代写 API key、不加 --danger-full-access(:11-14) |
| `octoscode/scripts/olp-cross-check-diagnostic.sh` | **17** | 交叉自检诊断 |
| `octoscode/scripts/reference/olp-mcp-server.py` | **440** | #31 之前的 Python 原型,已归档 scripts/reference/(Rust 化后仅存档) |
| `octoscode/.claude/skills/octoloop/SKILL.md` | **126** | octoloop 技能页;契约测试 `outer_duty_wiring_three_surfaces_consistent` 的第三面 |

生成命令:
```bash
wc -l $OC/scripts/{olp-board-append,olp-init,olp-cross-check-diagnostic}.sh $OC/scripts/reference/olp-mcp-server.py $OC/.claude/skills/octoloop/SKILL.md
sed -n '20,22p' $OC/scripts/olp-board-append.sh
```

## 7. octos 主仓交叉面(goal/peer/ledger CLI,细节详见 ch18-facts)

基准 9c157101。OLP 视角只需这四个只读/写信 CLI + 预算落点:

| 文件 | 行数 | OLP 关联锚点 |
|---|---|---|
| `crates/octos-cli/src/commands/ledger.rs` | 240 | :1 `octos ledger tail — read-only goal-ledger tail (OLP L1, slice 4)`;`LedgerCommand` :17、`LedgerAction` :23、`Tail(LedgerTailArgs)` :25、`LedgerTailArgs` :29、表格打印 `print_table` :106 |
| `crates/octos-cli/src/commands/peer.rs` | 211 | OLP L1 slice 3 只读观测;`PeerCommand` :18、`PeerAction` :24(`List` :26)、`PeerListArgs` :30、`list_peers` :54 |
| `crates/octos-cli/src/commands/goal.rs` | 1116 | `GoalCommand` :30、`GoalSubcommand` :43、`GoalStatusArgs` :340(`octos goal status`) |
| `crates/octos-cli/src/commands/steer.rs` | — | :1 `octos steer — external reviewer steer channel (OLP P2, slice 1)`;`STEER_MAX_BYTES` :22 = 64×1024(超限入队即拒,`.reviewer-notes` sidecar、user-message 层级非系统指令);`SteerCommand` :25 |
| `crates/octos-cli/src/autonomy/goal_loop_runtime.rs` | 1562 | **goal 预算落点**:`GoalRuntimeState` :265(Active/Paused/Completed/Failed)、`GoalBudgetResolution` :298(#1131 预算耗尽 → `GoalWrapUp`,crates/octos-cli/src/autonomy/master_continuation_scheduler.rs:147) |
| `crates/octos-fleet/src/sqlite_ledger.rs` | 6360 | `GoalLedger` :13(WAL 多进程账本;39 个 pub fn,impl :206-2241)——黑板之外的结构面权威账本 |

生成命令:
```bash
wc -l $O/crates/octos-cli/src/commands/{ledger,peer,goal,steer}.rs
head -1 $O/crates/octos-cli/src/commands/{ledger,peer,steer}.rs
grep -n "pub struct\|pub enum" $O/crates/octos-cli/src/commands/ledger.rs | head -4
grep -n "GoalRuntimeState\|GoalBudgetResolution" $O/crates/octos-cli/src/autonomy/goal_loop_runtime.rs | head -4
```

## 8. 协议要素 → 源码落点 + 三层归属

| 协议要素 | 落点 | 层归属 |
|---|---|---|
| 外环/内环角色与信道矩阵 | octoscode/docs/OUTER_LOOP_PROTOCOL.md:19-49;octoscode/docs/OCTOLOOP_GUIDE.md:248-295 | **协议条款**(纯文档,无实现) |
| 黑板(OUTER_LOOP_REVIEW.md) | octos-book/.octos/OUTER_LOOP_REVIEW.md(465 行/29 条目/71 ACK);追加唯一正道 octoscode/scripts/olp-board-append.sh:20-22(flock);octoscode/docs/OUTER_LOOP_PROTOCOL.md:52-53 | **Markdown 约定**——黑板无 Rust 实现;机械强制仅 §5 契约测试 grep 签入快照 |
| 内环维护循环 | octos-book/.octos/loop.md:1-13;由 octoscode/scripts/olp-init.sh:45-60 生成 | **Markdown 约定**(master 每轮唤醒自律,无 runtime 组件) |
| R1 ACK 定式 `ACK(done\|wontdo\|blocked): <说明>` | octoscode/docs/OUTER_LOOP_PROTOCOL.md:52-65( wontdo 分歧规则 :59-60;2026-08-24 生效分界 :63-65);黑板头注 octos-book/.octos/OUTER_LOOP_REVIEW.md:4 | **协议条款 + 契约测试**:octoscode/tests/olp_contract.rs:96/:120/:159(语法、豁免白名单、非法状态拒绝) |
| R2 诚实验证声明 | octoscode/docs/OUTER_LOOP_PROTOCOL.md:67-70(verified/partially-verified/unverified) | **协议条款**(无代码强制) |
| R3 升级三级 / R5 指导幂等 / R6 版本协商 | octoscode/docs/OUTER_LOOP_PROTOCOL.md:71-73 / :89-90 / :103;R6 双落点 octoscode/AGENTS.md:3 | **协议条款**;R6 有契约:octoscode/tests/olp_contract.rs:215 |
| R4 工作区共存 / R4b 树主权与自动围栏 | octoscode/docs/OUTER_LOOP_PROTOCOL.md:74-88;R4b 运行时实现属 octos 主仓(ch18 交叉),octoscode/docs/PEER_GOAL_ARCHITECTURE.md:281(Budget)/:269(Fleet) | **协议条款 + 系统默认**(R4b 为 octos 侧机制,非本仓) |
| 第五信道 ask_outer(OLP-MCP) | octoscode/src/olp_mcp.rs:25(90s)/ :27(每片 3 次)/ :24(署名)/ :174(ask_outer)/ :255(report_blocked);挂载 octoscode/docs/OUTER_LOOP_PROTOCOL.md:131-137 | **协议条款 + 契约测试**:octoscode/tests/olp_mcp_contract.rs 七件(:98-:266) |
| R7 主审权 OS 独占锁(outer-duty) | octoscode/src/outer_duty.rs:24(Linux-only)/ :34(DutyState)/ :83(lock_digest)/ :162(acquire)/ :220(check)/ :345(PDEATHSIG 死亡耦合);CLI octoscode/src/cmd/outer_duty.rs:10/:45;上岗卡 octoscode/docs/OLP_OUTER_BOOT.md:74-86 | **协议条款(R7 :91-102)+ 契约测试**:octoscode/tests/outer_duty_contract.rs 十件(:174-:709);macOS 退回值班簿纪律层(octoscode/docs/OCTOLOOP_GUIDE.md:229;reaper 立项 knowledge/requirements/req-olp-duty-macos.md) |
| goal 预算(OLP 派单预算档) | 预算档文字 octoscode/docs/OLP_OUTER_BOOT.md:37-39(修订 5-10M/切片 10-20M/战役 30-50M);运行时落点 octos 主仓 crates/octos-cli/src/autonomy/goal_loop_runtime.rs:265/:298 + crates/octos-fleet/src/sqlite_ledger.rs:13 | 预算档=**约定**;goal 预算机=octos 侧(ch18 已述,本章不复述) |
| 上行观测(octos goal status / peer list / ledger tail) | octos/crates/octos-cli/src/commands/goal.rs:340、octos/crates/octos-cli/src/commands/peer.rs:18-30、octos/crates/octos-cli/src/commands/ledger.rs:17-29(OLP L1 slice 3/4) | **CLI 层**(octos 主仓) |
| 下行即时注入(steer / herdr prompt) | octos/crates/octos-cli/src/commands/steer.rs:1/:22(64KiB 上限);herdr 侧为 herdr 仓(Ch21 范围,本章不展开) | **CLI 层**(octos 主仓)+ 外部工具 |

## 9. 抽查复跑记录(交付前,@对应基准 commit)

- `git -C $OC rev-parse HEAD` → `1129fa331faee8f8cbd350815d8a89af5ee3d01e` ✅(= spec 基线 1129fa33)
- `sed -n '25p;27p' octoscode/src/olp_mcp.rs` → `pub const ASK_TIMEOUT_SECS: f64 = 90.0;` / `pub const ASK_QUOTA_PER_SLICE: usize = 3;` ✅(spec review_ch20_ask_outer 两参数)
- `sed -n '24p' octoscode/src/outer_duty.rs` → `#![cfg(target_os = "linux")]` ✅(spec review_ch20_platform_limits cfg 行)
- `sed -n '7p' octoscode/docs/OUTER_LOOP_PROTOCOL.md` → `> \`protocol: olp/v2\`` ✅;`grep -n "protocol: olp" octoscode/AGENTS.md` → :3 ✅
- `grep -n "R[0-9]b? —" octoscode/docs/OUTER_LOOP_PROTOCOL.md` → 52/67/71/74/77/89/91/103 八条 ✅
- `sed -n '96p;120p;159p;178p;215p;252p;303p;329p' octoscode/tests/olp_contract.rs` → 8 个 `#[test]` 行逐行命中 ✅
- `wc -l` 六组行数(§1/§3/§4/§5/§6/§7)全部复跑一致 ✅
- `grep -c "^### \|ACK(" $B/.octos/OUTER_LOOP_REVIEW.md` → 29 / 71 ✅

引用全路径自检(AGENTS.md 第 7 条):`grep -o -E '[A-Za-z0-9_./-]+\.rs(:[0-9]+)?' assets/ch20-facts.md | grep -v -E '^(octoscode|crates|herdr)/' | wc -l` → 0(命令与输出见交付说明)。
