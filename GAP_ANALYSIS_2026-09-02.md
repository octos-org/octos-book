# 书稿 × 源码脱节盘点（2026-09-02）

- 书稿基线：`chapters/*.md` 最后修改 2026-05-29，共 6880 行
- octos 基线：`main` @ `9c157101`（2026-09-02），26 个 crate
- octoscode 基线：`main` @ `1129fa33`（2026-09-02）
- herdr 基线：`feat/octoscode-agent` @ `fefe5c4f`

---

## 1. 摘要

书稿的**引用完整性尚可，覆盖完整性已崩**。628 处 `crates/**.rs` 引用中只有 10 处路径失效、1 处行号越界、3 处符号消失——逐条勘误的工作量不大。真正的问题是三个月里 octos 主干走了 **873 个提交**，规模从「10 crate / 13 万行」长到 **26 crate / 70 万行**（`ls crates | wc -l`；`find crates -name '*.rs' | xargs wc -l`），书稿的骨架命题已经不成立。

可保留并勘误的只有 4 章：Ch2 核心类型、Ch4 记忆检索、Ch10 消息总线、Ch12 Pipeline（含少量段落重写）。必须重写的有 6 章：Ch1、Ch5、Ch6、Ch7、Ch13、Ch14——其中 Ch6 工具系统（`crates/octos-agent/src/tools` 126 提交）、Ch13 运行模式、Ch14 生产化（`octos-cli` 498 提交，8 处引用路径已迁走）属于整章重写级。

完全没进书的新面有 9 个，其中 4 个是新的一级架构：**fleet 计划内核 + worker 能力授予**、**harness 校验/事件/ABI 三支柱**、**goal/peer 自治集群**、**octoscode + OctoLoop 双环协议**。建议在现有 14 章之上**新增 7 章**（14 → 21 章），并新开「第四部分：双环」承载 octoscode / OLP / herdr。重写按依赖顺序推进：Ch1 拓扑 → Ch2 → Ch5 循环 → Ch6/Ch7 → harness → fleet → goal/peer → 双环。

---

## 2. 逐章脱节表

「引用」列统计章节正文中形如 `crates/xxx/src/yyy.rs:行号` 的去重引用；「提交」列是该章引用到的**文件**自 2026-05-29 以来被触及的提交数总和。

| 章 | 引用/失效 | 相关提交 | 判定 | 关键失效点 |
|---|---|---|---|---|
| **Ch1** 为什么 Rust / Agent OS | 9 / 0 | 210 | **整章重写** | ① 「10 个 crate、约 13 万行」实为 26 crate、70 万行；② 「14 个内置工具」实为 `crates/octos-agent/src/tools/` 下 59 个源文件；③ workspace 分层拓扑已变（新增 fleet/swarm/workflows/diagnostics/services/store 六个 crate） |
| **Ch2** octos-core 类型 | 21 / 0 | 49 | **保留 + 勘误** | ① 新增 `crates/octos-core/src/ui_protocol.rs`（书中无）；② `d8125d18` 结构化截断报告改了 `truncate_utf8` 周边语义；③ core 已非零内部依赖叙事需复核 |
| **Ch3** octos-llm | 11 / 1 | 37 | **段落重写** | ① `crates/octos-llm/src/catalog.rs:48-275` 行号越界（文件仅 274 行）；② `f3aa07f0` 引入 cache 经济学（cache-write 定价 + 一次性退出），三层容错链叙事需补一层；③ `b0072e70` sampler passthrough、`3e479ce3` per-profile `context_window` 均无覆盖 |
| **Ch4** octos-memory | 6 / 0 | 65 | **保留 + 勘误** | ① `cc6744ba` BM25 top-k 分区重写了检索热路径；② `9ad56caa` 新增 `octos memory reindex`；③ `4ccdbe7e` 向量降级可见性 |
| **Ch5** Agent Loop | 39 / 0 | 133 | **整章重写** | ① `crates/octos-agent/src/agent/` 目录 88 提交、`loop_runner.rs` 单文件 39 提交，「200 行逐段解析」不再成立；② 预算检查点（50 轮耗尽自动 WIP commit + `result.checkpoint.md`）无覆盖；③ goal 续跑钩子（turn-continuation）改变了「一次对话生命周期」的边界 |
| **Ch6** 工具系统 | 58 / 1 | 427 | **整章重写** | ① `crates/octos-agent/src/tools/activate_tools.rs` 已删除（LRU 淘汰一节的主源）；② 工具集从 14 个扩到含 `write_grant`、`recall`、`read_window`、`peer_*` 六件套等；③ `0612cf82` 窗口化 read_file + 部分视图写保护 |
| **Ch7** 安全纵深 | 29 / 0 | 150 | **整章重写** | ① `crates/octos-agent/src/sandbox/` 18 提交，`eb7c7221` 让不可兑现的显式模式 fail-closed、Auto 降级变响；② `ffcde205` cargo grant 默认 lock-only；③ 全新的 `WorkerGrant` 能力模型（`crates/octos-fleet/src/grant.rs`）未进书 |
| **Ch8** 上下文管理 | 42 / 0 | 108 | **段落重写** | ① `e312e4c1` + `825d6a52` recall 工具与预算感知读取，改变了 80% 压缩阈值的叙事；② `crates/octos-agent/src/compaction_tiered.rs` 分层压缩未覆盖；③ `f3aa07f0` cache 经济学与压缩交互 |
| **Ch9** 扩展机制 | 57 / 0 | 163 | **段落重写** | ① `65486dad` MCP 客户端整体迁到 rmcp SDK（stdio + streamable-HTTP + OAuth 2.1），书中双传输描述过时；② `9b1fc38f` skill layering v1（配置列举 + per-profile 继承）；③ `3934aeb6` 由 registry 持有 MCP 传输 |
| **Ch10** octos-bus | 43 / 1 | 14 | **保留 + 勘误** | ① `crates/octos-cli/src/api/ui_protocol.rs` 已拆成 `ui_protocol_{transport,ledger,progress,...}.rs` 家族；② 频道数 14 → 17（`crates/octos-bus/src/*_channel.rs`），新增 dingtalk / line / wechat / wecom_bot / matrix_user；③ 其余为 clippy/fmt 级 |
| **Ch11** 并发模型 | 53 / 0 | 272 | **整章重写** | ① `crates/octos-cli/src/autonomy/` 36 提交引入了 supervisor 事件账本 + 续跑调度器，是书中没有的第二层并发模型；② `crates/octos-cli/src/peers/` 的 peer≈进程模型与 per-session Mutex 叙事并列；③ fleet 的 lease/attempt 状态机是第三种并发原语 |
| **Ch12** octos-pipeline | 102 / 0 | 94 | **段落重写** | ① `6b0de6ca` DOT 调色板扩到 **12 种 IR 节点**（书中写 5 种 Handler），新增 ShellCheck/Notify/Wait；② `92175f53` per-node `max_iterations` 可配置；③ `f26d2291` 起的结构化 per-node 进度 + ETA 走 harness 事件通道 |
| **Ch13** 三种运行模式 | 31 / 0 | 263 | **整章重写** | ① 「三种模式」已不成立：新增 `octos serve --stdio`（octoscode 挂载面）与 `--solo`，见 octoscode `src/cli.rs:118` 的 `DEFAULT_STDIO_COMMAND`；② `3a567a4c` 推理参数 typed schema，配置体系换了校验模型；③ 「91 个 REST 端点」需重新计数 |
| **Ch14** 生产化 | 63 / 8 | 377 | **整章重写 + 拆分** | ① `admin_token_store.rs` / `setup_state_store.rs` / `smtp_secret_store.rs` 三个存储已从 `octos-cli` 迁到新 crate `crates/octos-store/`；② `crates/octos-cli/src/api/ui_protocol.rs` 的 4 处引用全部失效（文件已拆分）；③ 多租户实现迁到 `crates/octos-services/src/tenant.rs`，`render_frpc_config` 是新的部署路径 |
| **附录 A** Crate 依赖图 | — | — | **重画** | 10 → 26 个 crate |
| **附录 B** 工具速查表 | — | — | **重写** | 14 → 约 50 个可注册工具 |
| **附录 C** 配置参考 | — | — | **重写** | 新增 `mcp_servers`、`sub_providers`（含保留键 `goal_verifier`）、`validators` 三大配置车道 |
| **附录 D** Feature Flags | — | — | **勘误** | `github`（diagnostics）等新 flag |
| **附录 E** 贡献指南 | 1 / 0 | — | **保留** | — |

符号级失效仅 3 处真阳性：`enum Provider`（Ch3）、`fn find_evictable` 与 `struct ToolLifecycle`（Ch6，随 `activate_tools.rs` 一并消失）。

---

## 3. 未覆盖新面清单

| 新面 | 源码入口 | 提交数 | 建议落点 |
|---|---|---|---|
| **Fleet 计划内核** — redb 支撑的 attempt/lease/generation 事务状态机 | `crates/octos-fleet/src/store.rs`（`FleetKernelStore`）、`fleet.rs`（`Fleet`）、`records.rs`（`DurablePlan`/`Attempt`/`OutboxEvent`/`SCHEMA_VERSION`） | 28 | **新增 Ch16** |
| **Fleet Worker 能力授予** — 从空注册表按 grant 装配的封闭工具集 | `crates/octos-fleet/src/grant.rs`（`WorkerGrant`/`FsGrant`/`NetworkGrant`）、`crates/octos-fleet-worker/src/closed_registry.rs`（`build_fleet_worker_registry`）、`worker.rs`（`run_attempt`）、`escalate.rs` | 8 | **新增 Ch16** + Ch7 呼应 |
| **Harness 三支柱** — 声明式校验器 / 结构化事件 ABI / schema 版本化 | `crates/octos-agent/src/validators.rs`（`ValidatorRunner`）、`harness_events.rs`（`HarnessEventPayload`）、`abi_schema.rs`（`check_supported`）、`workspace_policy.rs`（`ValidationPolicy`）、`crates/app-skills/harness-starter-*` | 10 | **新增 Ch10**（Part 2 末） |
| **Swarm 扇出** — 一个 supervisor 写 N 份契约并分发给外部 agent 后端 | `crates/octos-swarm/src/dispatcher.rs`（`Swarm`/`SwarmBuilder`）、`topology.rs`、`persistence.rs`（`DispatchStore` 幂等）、`gate.rs`、`ledger.rs` | 6 | **新增 Ch17**（与 fleet 并列，非上下层） |
| **Goal / Peer 自治集群** — 服务端 goal keeper + peer≈进程模型 | `crates/octos-cli/src/autonomy/agent_orchestrator.rs`、`goal_loop_runtime.rs`、`supervisor_store.rs`、`master_continuation_scheduler.rs`、`fleet_wake.rs`、`crates/octos-cli/src/goal_tool.rs`、`crates/octos-cli/src/peers/mod.rs`、`crates/octos-fleet/src/sqlite_ledger.rs`（`GoalLedger`） | 61 | **新增 Ch18** |
| **`mcp_servers` / `sub_providers` 配置车道** | `crates/octos-agent/src/mcp.rs:53`（`McpServerConfig`）、`crates/octos-cli/src/config.rs:110` 与 `:618`（`SubProviderConfig`）、`crates/octos-cli/src/runtime/profile.rs:126-135`（保留键 `goal_verifier`）、`crates/octos-agent/src/tools/spawn.rs:1758` | 3+ | Ch9 + **附录 C** |
| **octoscode TUI 与 UI Protocol** — 独立终端客户端，经 stdio 挂载 `octos serve` | `src/event_loop.rs`（`run`）、`src/transport.rs`（`AppUiBackend`/`build_backend`）、`src/store.rs`（reducer）、`src/model.rs`（`AppUiCommand`）、`src/cli.rs:118`、`src/backend_ensure.rs`、`docs/ARCHITECTURE.md` | — | **新增 Ch19** |
| **OctoLoop / OLP 双环协议** — R1–R7 纪律、黑板、ACK、外环主审锁、olp-mcp 第五信道 | `docs/OUTER_LOOP_PROTOCOL.md`、`docs/OLP_OUTER_BOOT.md`、`src/olp_mcp.rs`（`ask_outer`/`report_blocked`）、`src/outer_duty.rs`（`DutyState`/`lock_digest`）、`tests/olp_contract.rs`、`tests/olp_mcp_contract.rs`、`tests/outer_duty_contract.rs`、`docs/PEER_GOAL_ARCHITECTURE.md` | — | **新增 Ch20** |
| **herdr 终端工作区** — 外环驱动内环的注入与观测原语 | `herdr/README.md`、`src/cli/agent.rs:771`（`agent_prompt`）、`src/detect/manifests/octoscode.toml` | — | **新增 Ch21** |
| 诊断 / 沙箱助手 / 服务抽取 / 工作流搬迁（低优先） | `crates/octos-diagnostics/src/report.rs`、`crates/octos-sandbox/src/main.rs`、`crates/octos-services/src/config_context.rs`、`crates/octos-workflows/src/workflow_runtime.rs` | 4/4/9/1 | 分别并入 Ch14、Ch7、Ch13、Ch12 |

**三处必须写进书的事实纠正**（否则新章会写错）：

1. `crates/octos-sandbox` **不是**沙箱子系统，是单文件平台助手二进制（`src/main.rs`，macOS 上是 no-op 直通）。真正的 `Sandbox` trait 与五个后端在 `crates/octos-agent/src/sandbox/`。
2. `crates/octos-web` **不含 Rust、不是 Web 服务**，是 UI Protocol reducer 的 vitest fixture 回放包（见其 `package.json`），且不是 Cargo workspace 成员。
3. **不存在 harness crate**。harness 是 `octos-agent` 内的四个模块加 `crates/app-skills/harness-starter-*`。

---

## 4. 新大纲建议（与 OUTLINE.md 对照）

```diff
  ## 代码规模
- - 10 个 crate，约 13 万行 Rust
- - 14 个消息频道，91 个 REST 端点，14+ 内置工具
+ - 26 个 crate，约 70 万行 Rust
+ - 17 个消息频道（`ls crates/octos-bus/src/*_channel.rs`），约 50 个内置工具，双环（OLP）协议 v2

  ## 第一部分：地基
~ Ch1  为什么是 Rust？为什么是 Agent OS？        【重写】拓扑从 10 crate 改为 26 crate 六层
= Ch2  octos-core：用类型系统定义领域语言        【保留+勘误】补 ui_protocol.rs、结构化截断
~ Ch3  octos-llm：驯服 LLM Provider 的混乱      【段落重写】补 cache 经济学、sampler、per-profile 上下文
= Ch4  octos-memory：混合搜索的工程实现          【保留+勘误】补 BM25 top-k 分区、reindex

  ## 第二部分：引擎
~ Ch5  Agent Loop：一次对话的完整生命周期        【重写】按 agent/ 目录八文件重组，补预算检查点与续跑钩子
~ Ch6  工具系统                                 【重写】删 activate_tools 一节，改按能力域分组叙述
~ Ch7  安全纵深：沙箱、注入防御与能力授予        【重写】补 fail-closed 模式与 WorkerGrant
~ Ch8  上下文管理                               【段落重写】补 recall 工具与分层压缩
~ Ch9  扩展机制：Skills / Plugins / MCP         【段落重写】补 rmcp 迁移、skill layering、两条配置车道
+ Ch10 Harness：让「模型说做完了」变成可验证契约  【新增】
       定位：声明式校验器 + 结构化事件 ABI + schema 版本化，把不可信的长跑变成可审计可门禁的运行
       必引：crates/octos-agent/src/validators.rs、harness_events.rs、abi_schema.rs、
             workspace_policy.rs、harness_errors.rs、hooks.rs、
             docs/OCTOS_HARNESS_DEVELOPER_GUIDE.md、docs/OCTOS_HARNESS_ABI_VERSIONING.md

  ## 第三部分：平台
= Ch11 octos-bus：17 频道的统一消息抽象          【保留+勘误】原 Ch10，频道数与 ui_protocol 拆分
~ Ch12 并发模型：从 Tokio 到三层调度             【重写】原 Ch11，补 supervisor / peer / lease 三种原语
~ Ch13 octos-pipeline：DOT 图驱动的工作流引擎    【段落重写】原 Ch12，5 Handler → 12 IR 节点
~ Ch14 运行模式与配置体系                       【重写】原 Ch13，三模式 → 含 stdio/solo 的四模式
~ Ch15 生产化：认证、诊断、监控与多租户          【重写】原 Ch14，存储迁 octos-store、租户迁 octos-services
+ Ch16 Fleet：可恢复的计划执行内核                【新增】
       定位：redb 事务化的 attempt/lease/generation 状态机，加按 grant 装配的封闭 worker
       必引：crates/octos-fleet/src/{lib,store,records,fleet,grant,sqlite_ledger}.rs、
             crates/octos-fleet-worker/src/{closed_registry,worker,pool,escalate}.rs、
             docs/FLEET-KERNEL-V1-SPEC.md
+ Ch17 Swarm：契约扇出与聚合门禁                  【新增】
       定位：一个 supervisor 写 N 份契约、分发给外部 agent 后端、聚合产物并过校验门
       必引：crates/octos-swarm/src/{lib,dispatcher,topology,result,persistence,gate,ledger}.rs、
             crates/octos-swarm/tests/swarm_dispatch_policy.rs
+ Ch18 Goal 与 Peer：把目标从上下文里搬出来        【新增】
       定位：服务端 goal keeper 持有并推进目标，peer≈进程、subagent≈线程的并发隐喻
       必引：crates/octos-cli/src/autonomy/{mod,goal_loop_runtime,supervisor_store,
             master_continuation_scheduler,fleet_wake}.rs、goal_tool.rs、commands/goal.rs、
             peers/mod.rs、crates/octos-fleet/src/sqlite_ledger.rs、
             crates/octos-agent/src/tools/peer_handoff.rs

+ ## 第四部分：双环 — 外环驱动内环                【全新部分】
+ Ch19 octoscode：终端客户端与 UI Protocol        【新增】
       定位：不跑 agent、不执行工具的纯客户端，如何用 stdio 把 octos serve 挂进 TUI
       必引：octoscode/src/{main,cli,event_loop,transport,store,model,autonomy,backend_ensure}.rs、
             octoscode/docs/ARCHITECTURE.md、crates/octos-core/src/ui_protocol.rs
+ Ch20 OctoLoop：外环协议 OLP v2                  【新增】
       定位：R1–R7 纪律、Markdown 黑板与 ACK 语法、外环主审独占锁、olp-mcp 第五信道
       必引：octoscode/docs/{OUTER_LOOP_PROTOCOL,OLP_OUTER_BOOT,OCTOLOOP_GUIDE,
             OCTOLOOP_FEATURES,PEER_GOAL_ARCHITECTURE}.md、
             octoscode/src/{olp_mcp,outer_duty}.rs、octoscode/src/cmd/mod.rs、
             octoscode/tests/{olp_contract,olp_mcp_contract,outer_duty_contract}.rs、
             octoscode/scripts/olp-board-append.sh
+ Ch21 herdr 与外环运维实务                       【新增】
       定位：把终端本身变成 agent 运行时，外环靠它发现、唤醒、观测内环
       必引：herdr/README.md、herdr/src/cli/agent.rs、herdr/src/detect/manifests/octoscode.toml、
             octoscode/docs/OLP_QUICKSTART.md、octoscode/.octos/loop.md

  ## 附录
~ A  Crate 依赖图                【重画】26 crate
~ B  工具速查表                  【重写】约 50 个工具 + 分组策略 + WorkerGrant 目录
~ C  配置参考                    【重写】补 mcp_servers / sub_providers / validators
~ D  Feature Flags               【勘误】
= E  贡献指南                    【保留】
+ F  OLP v2 协议速查             【新增】R1–R7、ACK 语法、result.md frontmatter v1 六字段
```

规模：14 章 5 附录 → **21 章 6 附录**，其中保留 4 章、段落重写 4 章、整章重写 6 章、新增 7 章。

---

## 5. 重写优先级与依赖顺序

新的依赖图（新增节点标 `*`）：

```
Ch1 → Ch2 → Ch3 ─┐
                  ├→ Ch5 → Ch6 → Ch7 → Ch10*
Ch1 → Ch2 → Ch4 ─┘       │              │
                          ├→ Ch8        ├→ Ch16* → Ch17*
                          ├→ Ch9        │      └→ Ch18* → Ch19* → Ch20* → Ch21*
                          ├→ Ch11       │
                          └→ Ch12 ──────┘
                  Ch12 + Ch14 → Ch13, Ch15
```

**P0 — 地基必须先对，否则后续每章都会继承错误数字**
1. **Ch1** 26 crate 拓扑与规模数字。它是全书唯一的架构总图，附录 A 与所有「本章在系统中的位置」段落都依赖它。
2. **Ch2** octos-core 勘误。类型层是 Ch5/Ch6/Ch16 的共同词汇表。

**P1 — 引擎层，新增章的前置**
3. **Ch5** Agent Loop 重写。Ch16 的 worker、Ch18 的 goal 续跑都是它的变体，先定基准叙事。
4. **Ch6** 工具系统重写。Ch16 的封闭注册表、Ch18 的 goal/peer 工具都建立在 `ToolRegistry` 与策略语义上。
5. **Ch7** 安全重写。`WorkerGrant` 必须先在这里立住，Ch16 才能只讲装配不讲权限模型。
6. **Ch10\*** Harness 新写。Ch13 pipeline 进度、Ch17 swarm 门禁都发 harness 事件，它是共享词汇。

**P2 — 平台层**
7. **Ch12** 并发模型重写（三种并发原语的总账）。
8. **Ch16\*** Fleet 新写 → **Ch17\*** Swarm 新写（两者并列，Swarm 可与 Fleet 并行推进）。
9. **Ch18\*** Goal/Peer 新写。依赖 Ch16 的 `sqlite_ledger` 与 Ch12 的 supervisor 叙事。
10. **Ch14 / Ch15** 运行模式与生产化重写。Ch14 需要先知道 `--stdio` 通向谁，故排在 Ch19 认识之后亦可，但配置体系部分可先行。

**P3 — 第四部分（可与 P2 后段并行，只依赖 Ch18）**
11. **Ch19\*** octoscode → **Ch20\*** OctoLoop → **Ch21\*** herdr。严格顺序：先讲清客户端边界，再讲协议纪律，最后讲运维工具。

**P4 — 附录**，全部在对应章定稿后回填。

**并行建议**：P1 的 Ch5/Ch6/Ch7 三章耦合紧，宜同一人连续写；Ch10\*、Ch17\*、Ch21\* 相互独立，可分派。

**写新章前必须先解决的两个前置事实问题**（会影响章节结论，建议由作者拍板）：

- OLP 的 R7 外环主审锁 `#![cfg(target_os = "linux")]`（octoscode `src/outer_duty.rs:25`），在 macOS 上整个模块不编译。书稿若以 macOS 为演示平台，Ch20 必须明确标注这是文档级纪律而非运行时强制。
- OLP 黑板**没有 Rust 实现**。追加、编号、ACK 校验全靠 Markdown 约定加 `scripts/olp-board-append.sh`，唯一「强制」是契约测试 grep 一份签入的快照。Ch20 若按「系统组件」写会失真，应按「协议 + 约定 + 契约测试」三层写。

---

## 6. 方法与证据

全部命令只读，未修改 octos / octoscode / herdr 任何文件。

**引用提取与路径核对**

```bash
# 提取 628 处 crates/**.rs 引用（含行号）
for f in chapters/*.md; do
  grep -oE 'crates/[A-Za-z0-9_./-]+\.rs(:[0-9]+(-[0-9]+)?)?' "$f"
done
# 路径存在性
git -C /Users/zhangalex/Work/Projects/FW/octos ls-files
# 行号越界：比较引用区间上界与 wc -l
```
结果：唯一路径 154 个，`crates/` 前缀失效 10 处，行号越界 1 处。其余 20 处「失效」是书稿自身 mdbook 路径（`src/part1/ch01.md` 等），非源码引用，已排除。

**符号核对**

```bash
grep -oE '(pub )?(async )?(fn|struct|enum|trait|type) [A-Za-z_][A-Za-z0-9_]*' chapters/*.md
grep -rE "(fn|struct|enum|trait|type) +<name>\b" crates/
```
102 个符号，真阳性失效 3 个。

**提交量统计**

```bash
git -C .../octos log --since=2026-05-29 --oneline | wc -l          # 873
git -C .../octos log --since=2026-05-29 --oneline -- crates/<c>    # 逐 crate
git -C .../octos log --since=2026-05-29 --oneline -- <引用到的文件> # 逐章聚合
```

**规模核对**

```bash
ls crates | wc -l                                   # 26
find crates -name '*.rs' | xargs wc -l | tail -1    # 700915
ls crates/octos-bus/src/*_channel.rs | wc -l        # 频道数
ls crates/octos-agent/src/tools/*.rs | wc -l        # 59
```

**关键哈希索引**（便于复核判定）

| 哈希 | 主题 | 影响章 |
|---|---|---|
| `9c157101` | octos HEAD，`docs(guide)` 记录 mcp_servers stdio 字段 | Ch9、附录 C |
| `f3aa07f0` | cache 经济学 + get_goal 探针闩锁 | Ch3、Ch8、Ch18 |
| `eb7c7221` | 沙箱不可兑现模式 fail-closed | Ch7 |
| `0612cf82` | 窗口化 read_file + 部分视图写保护 | Ch6 |
| `6b0de6ca` | DOT 调色板 12 种 IR 节点 | Ch13 |
| `65486dad` | MCP 迁移至 rmcp SDK | Ch9 |
| `cd65eb68` | OctoLoop 双环可靠性加固（16 分支集成） | Ch18、Ch20 |
| `cc425ada` | OLP 可观测性：goal/peer/ledger JSON 命令 + events.jsonl | Ch18、Ch20 |
| `eadee2ae` / `8fc66202` | fleet WorkerGrant 与 worktree worker | Ch7、Ch16 |
| `543010be` | workflow 子系统抽取为 octos-workflows（纯搬迁） | Ch13 |
| `7f81fa5e` / `1801a9e9` | octos-diagnostics 与 doctor 两阶段 | Ch15 |

**octoscode / herdr 证据**：`docs/OUTER_LOOP_PROTOCOL.md` 头部 `protocol: olp/v2`（v1→v2 由板条目 `#38-r1` 于 2026-08-30 生效，新增 R7）；`src/olp_mcp.rs:22-28` 的 `ASK_TIMEOUT_SECS 90.0` / `ASK_QUOTA_PER_SLICE 3`；`src/outer_duty.rs:37-42` 的 `DutyState`；`src/cli.rs:118` 的 `DEFAULT_STDIO_COMMAND = "octos serve --stdio --solo"`；herdr `src/detect/manifests/octoscode.toml` 的三条优先级识别规则。

**已知盲区**（本次未核）：附录 C 的逐项配置字段、附录 D 的 feature flag 全集、「91 个 REST 端点」的重新计数、`chapters/` 中散文里未带路径的事实性断言（如具体阈值、超时秒数）。这三类需要在各章重写时逐条回归。
