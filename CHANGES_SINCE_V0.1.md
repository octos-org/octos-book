# octos main 重大变更影响分析（自 v0.1.0 至 origin/main `a5ce5b45`）

> 生成时间：2026-04-25
> 比较基线：本书 commit `9b19a7c`（v0.1.0 初始发布）
> 比较目标：octos `origin/main` HEAD `a5ce5b45`（fix #558, 2026-04-24）
> 验证方法：`git ls-tree origin/main` + `git cat-file -e origin/main:<path>` + 关键提交的 PR 描述对照

本文档**仅识别和评估变更**，不动书稿。具体章节修改需要你拍板范围与优先级后，再分章用 `/tech-writer` 流程更新。

---

## 0. 前置说明

- 本仓库 octos 当前 checkout 在 `feat/matrix-media-and-fixes` 分支（且处于一个未完成的 merge 中），但**所有下文列出的"重大变更"都已经合入 `origin/main`**，已逐项用 `git cat-file -e origin/main:<path>` 验证。
- 本书有两份镜像：`chapters/ch*.md`（写作母本）和 `book/src/part*/ch*.md`（mdbook 渲染源）。任何章节修改要同步两份。
- **现存的未提交修改**（用户在写作中的精修）位于 ch03/ch04/ch11/ch14：均为对既有内容的勘误（精确化既有描述），不是关于这些新变更的。新内容应**叠加在勘误之上**，不要覆盖。
- TESTING_CHECKLIST.md（未追踪）是 v0.1.0 的手工测试清单，与本次变更无直接关联，独立维护即可。

---

## 1. 重大变更分组（按主题）

### A. Harness 体系——全书最大的新增面（M4 + M6 + M7）

octos 在 v0.1.0 之后新增了一整套"Harness"概念：把 Agent 运行时与可插拔执行单元（skill / app / 子 Agent）之间的契约**显式化、版本化、可验证化**。这是过去一个季度最大的设计动作。

#### M4：Harness 开发者契约
| 提交 | 主题 | 关键文件 |
|------|------|---------|
| `664325af` M4.2 | 开发者契约指南 + 4 个 starter app skills | `crates/app-skills/harness-starter-{audio,coding,generic,report}/` |
| `6f4abc03` M4.3 | 声明式 validator runner | `crates/octos-agent/src/validators.rs`, `tests/validator_runner.rs` |
| `56532ddc` M4.4 | 第三方 skill 兼容性 gate | `crates/octos-cli/tests/skill_compat_gate.rs`, `e2e/tests/skill-compat-gate.spec.ts`, `docs/OCTOS_HARNESS_SKILL_COMPAT.md` |
| `1de684e3` M4.5 | Operator harness dashboard | `dashboard/src/pages/HarnessPage.tsx`, `dashboard/src/components/HarnessTaskTable.tsx` |
| `6f4e1f6a` M4.1A | Live progress validation gate | `e2e/tests/live-progress-gate.spec.ts`, `e2e/fixtures/m4-1a-progress-expected.json` |
| `f28e4e7e` M4.6 | Versioned harness ABI schemas | `crates/octos-agent/src/abi_schema.rs`, `tests/abi_compat.rs`, `docs/OCTOS_HARNESS_ABI_VERSIONING.md` |
| `338e1e8e` | 多语言 harness event 发射器 | `examples/harness-event/{node,python}/`, `crates/octos-agent/src/harness_events.rs` |

#### M6：错误分类与运行时硬化
| 提交 | 主题 | 关键文件 |
|------|------|---------|
| `72436674` M6.1 | 结构化 `HarnessError` taxonomy + typed events | `crates/octos-agent/src/harness_errors.rs`, `tests/harness_errors.rs` |
| `d806fd30` M6.2 | Loop retry-bucket 状态机 | `crates/octos-agent/src/agent/loop_state.rs`, `tests/loop_retry_state.rs` |
| `e615a447` M6.3 | Contract-gated compaction + preflight + tool-result pruning | `crates/octos-agent/src/agent/loop_compaction.rs`, `tests/compaction_policy.rs` |
| `3d014f6e` M6.4 | LLM-iterative summarizer + typed `SessionSummary` | `crates/octos-agent/src/summarizer.rs`, `tests/session_summary.rs` |
| `9b72d116` M6.5 | Credential pool（持久化冷却 + 轮转策略） | `crates/octos-llm/src/credential_pool.rs`, `tests/credential_pool.rs` |
| `42e28921` M6.6 | Content-classified smart model routing | `crates/octos-llm/src/content_classifier.rs`, `tests/content_classifier.rs` |
| `f67427da` M6.7 | 同步 `DelegateTool` + MAX_DEPTH 守卫 | `crates/octos-agent/src/tools/delegate.rs`, `tests/delegate_tool.rs` |
| `f2566099` M6.8 | M6 指标投映到 operator dashboard | dashboard 改动 |

#### M7：多 Agent 编排
| 提交 | 主题 | 关键文件 |
|------|------|---------|
| `2c4d02cb` M7.1 | MCP agent-tool backend for `SpawnTool` | `crates/octos-agent/src/tools/mcp_agent.rs`, `tests/mcp_agent_backend.rs` |
| `517f3bd4` M7.2 | **MCP server mode**——octos 自己变成 MCP server，被外层编排器调用 | `crates/octos-agent/src/mcp_server.rs`, `crates/octos-cli/src/commands/mcp_serve.rs`, `tests/mcp_server.rs`, `crates/octos-cli/tests/mcp_serve_integration.rs` |
| `5a46a2be` M7.2a | MCP server dispatch 接到真正的 Agent loop | 同上 |
| `cca16d70` M7.3 | Matrix 频道做 supervisor UI（Agent puppet 模式） | `crates/octos-bus/tests/matrix_swarm_supervisor.rs`, matrix channel 改动 |
| `da1c60a4` M7.4 | Cost/provenance ledger for swarm dispatches | `crates/octos-agent/src/cost_ledger.rs`, `tests/cost_ledger.rs` |
| `4d4737df` M7.5 | **新增 `octos-swarm` crate**——swarm 编排原语 | `crates/octos-swarm/{dispatcher,ledger,topology,persistence,result,lib}.rs` |

### B. Robotics 体系（RP01–RP06）

新增了一整套面向"Agent 驱动机器人/硬件"场景的契约和工具：

| 提交 | 主题 | 关键文件 |
|------|------|---------|
| `2d0a5b22` RP01 | `SafetyTier` 作为 `ToolPolicy` 组族 | `crates/octos-agent/src/tools/robot_groups.rs`, `tests/robot_tool_policy.rs` |
| `b02cc7fd` RP02 | `HardwareLifecycle` + 沙箱化执行器 | `crates/octos-plugin/src/lifecycle.rs`, `tests/lifecycle_sandbox.rs` |
| `2fd2f2d2` RP03 | Domain-hook 模式（`BeforeSpawnVerify` payload 扩展） | `crates/octos-agent/tests/domain_hook.rs`, `examples/robot_domain_hook.rs` |
| `5de1bcca` RP04 | Pipeline deadline + checkpoint 强制 | `crates/octos-pipeline/tests/checkpoint_resume.rs`, `tests/deadline_enforcement.rs`, fixtures/`inspection_mission.dot` |
| `857700cc` RP05 | Realtime heartbeat + sensor context 注入 | `crates/octos-agent/src/agent/realtime.rs`, `tests/realtime_loop.rs`, `examples/realtime_heartbeat.rs`, `examples/inspection_safety.rs` |
| `3df4eecb` RP06 | 移除 `octos-dora-mcp` stub crate | crate 删除 |
| `0af761eb` | **删除 `take_photo` 工具**（dead code） | `crates/octos-agent/src/tools/take_photo.rs` 删除 |
| `aec91201` | Robotics 文档套件 | `docs/OCTOS_ROBOTICS_{ARCHITECTURE,FAMILY,CONTRACTS,PR270_*}.md` |

### C. Setup Wizard / 安装与运维

整个"首次启动 → 部署上线"路径被产品化：

- **AdminTokenStore**（hashed `admin_token.json`） + token rotation：`crates/octos-cli/src/admin_token_store.rs`, `commands::admin reset-token` 子命令
- **Setup state store**（原子写）+ `/api/admin/setup` 端点：`crates/octos-cli/src/setup_state_store.rs`, `crates/octos-cli/src/api/admin_setup.rs`
- **SMTP 密码文件存储**（取代环境变量传递）：`crates/octos-cli/src/smtp_secret_store.rs`, `octos admin set-smtp-password`
- **Dashboard Setup Wizard**：`SetupWelcome` → `SetupRotateToken` → `wizard/{StepOverview,StepLlmProvider,StepSmtp,StepDeploymentMode,StepCreateProfile}`（最终被压缩成 3 步）
- **BootstrapGate**：检测未配置租户时自动跳到 wizard
- **Deployment modes**（local / tenant / cloud）写入 config.json `mode` 字段
- **Self-service tenant registration**：`POST /api/register`、`GET /api/register/setup-script`、cloud 模式内嵌 landing page
- **运维脚本套件**：`scripts/cloud-host-deploy.sh`、`setup-frps.sh`（frp 0.65.0）、`setup-caddy.sh`、`local-tenant-deploy.sh`、`build-local-bundle.sh`、`octos-doctor.sh`
- **`octos serve` 默认端口**：`8080` → **`50080`**（提交 `04288111`）

### D. Workflow runtime / 后台任务运行时

| 提交 | 主题 |
|------|------|
| `0adf8ca2` | Modular workflow runtime core for forced background tasks |
| `e32a77e5` `aa35c65f` `e1c302db` | 把 research_report / research_podcast / slides / site 抽成 workflow family |
| `6eff99ee` | Typed workflow family registry |
| `7f4c63a9` | Durable child-session runtime for background spawns |
| `83d4afe3` `c56c1098` `b729c95d` | Child-session 生命周期可观测性指标 + 终态契约 + 监督策略 |
| `dc95ef64` | 子 gateway operator 指标聚合 |
| `7f372703` `05d673e3` | Workflow tool budgets + runtime limits |
| `f3514308` `77a1b00d` | 把 background reports 当作 committed session events 持久化 |
| `8264e79c` | 在任务查询接口暴露结构化 workflow metadata |

### E. 安全与沙箱强化

- **Windows AppContainer 沙箱**（`2bba98d6` #258）
- **Per-profile sandbox isolation**（`8c5eb1bf` `da9c8d59`）：SSRF DNS pinning、path boundary validation、sandbox hardening
- **macOS sandbox** 在 coding 路径上的硬化（`43fa3ed7`）
- **环境变量过滤**扩展（`crates/octos-agent/src/subprocess_env.rs`）
- **Permissions 模块**新增：`crates/octos-agent/src/permissions.rs`

### F. Dashboard 重构

- 新增 `HarnessPage`、`HarnessTaskTable`、`CodingLoopPanel`、`BootstrapGate`、`WizardNav`、`SetupWizard`、`SetupRotateToken`、`SetupWelcome`、5 个 `wizard/Step*.tsx`
- Profile 子页 `HomePage` / `SkillsPage` / `ToolsPage`、`ContentPanel`（per-profile content catalog）
- `EnvVarsEditor`、`SandboxTab`、`SearchApiTab` 的扩展
- providers.json 重构（catalog-driven LLM 路由编辑器）
- **dashboard 静态资源策略改为 ephemeral-bundle**（`335bdb09`）：构建产物不再入库；`build-local-bundle.sh` 现场打包

### G. 频道/总线层

- **WeCom Group Robot WebSocket channel**（`b7ba4f2e`）+ streaming dedup
- **Matrix bot orchestration + scheduling**（`da673310` `0f84b8cb`）—— 配置驱动的审批流（`73313637`）
- Matrix mention/route 修复多个（`a57f009e` `97762d6b`）
- Background event replay topic-aware（`3568d9da`）

### H. 其他可见的小但重要变更

- `crates/octos-cli/src/lib.rs` 新建：CLI 提取出库供其他 crate 复用
- `spawn_only` 工具直接执行（不再走 sub-agent LLM）：`73710315` `ea2dafed`
- Adaptive cost-aware QoS routing + JSON 配置权重：`9201291f`
- 移除 `crew` 旧名残留：`d2eccc32`
- 子 bot 工具注册表对齐 normal mode：`104fc958` `54a90a98`

---

## 2. 章节影响矩阵

> **影响等级**：🟢 小（个别段落补充） · 🟡 中（新增 1–2 节或部分重写） · 🔴 大（新增大节或主题级重写）
>
> **状态**：✅ 用户已开始勘误 · ⬜ 未触动

| 章 | 影响 | 状态 | 主要新增/重写点 | 来源 |
|----|------|------|----------------|------|
| Ch1 为什么 Rust | 🟢 | ⬜ | 提及 `octos-swarm` 是新增的第 11 个 crate；Robotics 作为新场景增添佐证 | A.M7.5、B |
| Ch2 octos-core | 🟢 | ⬜ | `task.rs` `message.rs` 有小改，多半是字段补充；只在确认有破坏性变更时再动 | — |
| Ch3 octos-llm | 🟡 | ✅（勘误） | **新节**：Credential Pool（M6.5，持久化冷却 + 轮转策略）；**新节**：Content-Classified Routing（M6.6）；AdaptiveRouter 节补 cost-aware QoS（H） | A.M6.5、A.M6.6、H |
| Ch4 octos-memory | 🟢 | ✅（勘误） | 与新内容相关性低，仅在 Episode 写入时机段落核对一次 | — |
| Ch5 Agent Loop | 🔴 | ⬜ | **新节**：HarnessError taxonomy & typed events（M6.1）；**新节**：Loop Retry-Bucket 状态机（M6.2）；**新节**：LLM-iterative Summarizer（M6.4）；**新节**：DelegateTool（M6.7，与 SpawnTool 对照）；stop_reason 决策树补 retry-bucket 分支 | A.M6.1/2/4/7 |
| Ch6 工具系统 | 🟡 | ⬜ | **删除**：`take_photo` 全部提及；**新增**：`DelegateTool`（同步、MAX_DEPTH=3 守卫）；**新增**：robot_groups（`SafetyTier` 作为 `ToolPolicy` 组族）；**更新**：`spawn_only` 直接执行（不走子 Agent LLM） | B.RP01、A.M6.7、H |
| Ch7 安全 | 🟡 | ⬜ | **新节**：Windows AppContainer 沙箱；**新节**：per-profile sandbox isolation（SSRF DNS pinning、path boundary）；与 Robotics 安全等级（`SafetyTier`/`HardwareLifecycle`）的关系 | E、B.RP01/RP02 |
| Ch8 上下文管理 | 🔴 | ⬜ | **重写**：Compaction 改为 contract-gated（M6.3，preflight + tool-result pruning）；**新节**：LLM-iterative Summarizer（M6.4，typed `SessionSummary`） | A.M6.3/M6.4 |
| Ch9 扩展机制 | 🔴 | ⬜ | **新节**：Harness 开发者契约（M4.2，4 个 starter app）；**新节**：Harness ABI versioning（M4.6）；**新节**：Skill compatibility gate（M4.4）；**新节**：Validator runner（M4.3）；**新节**：MCP agent-tool backend for `SpawnTool`（M7.1）；**新节**：harness event 多语言发射器（Node/Python 示例） | A.M4.2/3/4/6、A.M7.1、A.fixtures |
| Ch10 octos-bus | 🟡 | ⬜ | **新节**：Matrix-as-supervisor-UI（M7.3，Agent puppets）；**新节**：WeCom Group Robot WebSocket；Matrix bot orchestration + 审批流；app-card reply tools | A.M7.3、G |
| Ch11 并发 | 🔴 | ✅（已加"冷启动优势"） | **新大节**：octos-swarm crate（M7.5，dispatcher/topology/persistence/ledger/result）；**新节**：Cost/Provenance Ledger（M7.4）；**新节**：Realtime heartbeat（RP05）；**新节**：Background workflow runtime + child-session lifecycle（D） | A.M7.4/5、B.RP05、D |
| Ch12 Pipeline | 🟡 | ⬜ | **新节**：Pipeline deadline + checkpoint enforcement（RP04）；**新节**：Workflow family registry（4 family：research_report/research_podcast/slides/site）；**新节**：HardwareLifecycle 与 domain-hook 模式（RP02/RP03） | B.RP02/3/4、D |
| Ch13 运行模式 | 🔴 | ⬜ | **新增第 4 种运行模式**：MCP Serve（`octos mcp serve`，M7.2/2a）；**新节**：Setup Wizard（rotate token → LLM provider → SMTP → deployment mode → channels）；**新节**：BootstrapGate；**关键事实更新**：`octos serve` 默认端口 `8080` → `50080`；**新节**：deployment modes（local/tenant/cloud）+ self-service registration；**新节**：Per-profile content catalog | A.M7.2/2a、C |
| Ch14 生产化 | 🔴 | ✅（勘误，已新增 14.3/14.4 重写） | **新节**：Admin Token Rotation（hashed `admin_token.json`、强度校验、并发守卫）+ `octos admin reset-token`；**新节**：SMTP password 文件存储 + `octos admin set-smtp-password`；**新节**：Operator dashboard（M4.5/M6.8 surfaces）；**新节**：Cost/Provenance Ledger 作为成本治理面（M7.4）；**新节**：Cloud-host 部署链（cloud-host-deploy.sh、setup-frps、setup-caddy、octos-doctor.sh） | C、A.M7.4、A.M4.5/M6.8 |
| 附录 A Crate 依赖图 | 🟡 | ⬜ | 新增 `octos-swarm` 节点；移除 `octos-dora-mcp` | A.M7.5、B.RP06 |
| 附录 B 工具速查 | 🟡 | ⬜ | 删除 `take_photo`；新增 `delegate`、`mcp_agent`、robot_groups | A.M6.7、A.M7.1、B.RP01 |
| 附录 C 配置参考 | 🟡 | ⬜ | 新字段：admin token、setup wizard state、SMTP secret、deployment mode、credential pool、content classifier | C、A.M6.5/6.6 |
| 附录 D Feature flags | 🟢 | ⬜ | 是否新增 harness/robotics/swarm 相关 feature 待源码确认 | — |

---

## 3. 推荐执行顺序

### 阶段 0：先收尾既有工作（建议你先决定）
1. **决定未提交修改去留**：`chapters/ch{03,04,11,14}.md` + `book/src/...` 的勘误是先 commit 出去再叠加新内容，还是和新内容一起 commit。建议先单独 commit 勘误（信息粒度更清晰，且新内容里某些段落要建立在勘误后的基线上）。
2. **决定 dual-copy 策略**：每章修改要同时改 `chapters/` 和 `book/src/`。是否考虑用脚本同步、或彻底放弃其中一份？

### 阶段 1：影响最大、读者最受益（建议优先）
1. **Ch13 运行模式**：MCP serve 是第 4 种运行模式，端口变更属于事实纠正，Setup Wizard 是新读者接触 octos 的第一印象。这章不更新，新读者跑书里的命令会直接错。
2. **Ch5 Agent Loop**：M6 系列把 loop 内核改了（retry-bucket、HarnessError、Summarizer），这是 Part 2 的核心章；不更新，Ch6/Ch8/Ch9 的引用会脱节。
3. **Ch9 扩展机制**：Harness 开发者契约 + ABI versioning + skill compat gate 是面向"想给 octos 写扩展"的读者（读者 D）的关键内容，对应大量新文档。

### 阶段 2：架构性补充
4. **Ch11 并发**：octos-swarm 是新 crate，Cost Ledger / Realtime / Background workflow 是常驻运行时新增的并发原语。
5. **Ch8 上下文管理**：Compaction 重写为 contract-gated 是对原章核心结论的修正。
6. **Ch14 生产化**：Admin token rotation、SMTP secret store、operator dashboard 是 production checklist 的硬变化。

### 阶段 3：场景与目录
7. **Ch6 工具系统**：删 `take_photo`、加 `DelegateTool`/`mcp_agent`/`robot_groups`。
8. **Ch10 octos-bus**：Matrix supervisor UI、WeCom 频道。
9. **Ch12 Pipeline**：Workflow family registry、HardwareLifecycle、deadline enforcement。
10. **Ch7 安全**：AppContainer、per-profile isolation。

### 阶段 4：附录与扫尾
11. 附录 A/B/C 修订；附录 D 视需要。
12. Ch3 / Ch4 的小补充。
13. Ch1 / Ch2 的轻量提及。

---

## 4. 我需要你的确认

在动笔前，请就以下问题给我指示：

1. **范围**：先做阶段 1（Ch13 + Ch5 + Ch9）三章，还是希望我一次性按推荐顺序往下做？（一次会话内只能做 1–3 章这种深度的更新。）
2. **未提交修改**：先 commit 勘误再叠加新内容，OK？
3. **dual-copy**：每次修改同步 `chapters/` 和 `book/src/`，OK？
4. **Robotics 章节定位**：你想把 RP 系列内容**集中**写一节（独立的 Robotics 视角），还是**散布**在 Ch6/Ch7/Ch11/Ch12 各自相关位置？
5. **Harness 概念定位**：把 M4/M6/M7 三组当成"Harness"统一主题（建议 Ch9 增加"Harness 体系"大节作为入口，再分散到 Ch5/Ch11 等），还是按既有章节分散收纳？
6. **mdbook 双语版本**（`book/src/` 现在只有中文 part；OUTLINE 提到双语 mdbook）：英文版本是否也要同步更新，还是只更新中文版？

---

## 附：自动化辅助命令

> 后续每次更新章节，可以用下面这组命令快速找出对应源文件位置。

```bash
# 查看 main 上某主题相关的代码入口
git -C /Users/zhangalex/Work/Projects/FW/octos show origin/main:crates/octos-agent/src/agent/loop_state.rs | less

# 查看 main 上 PR 范围的实际 diff
git -C /Users/zhangalex/Work/Projects/FW/octos log origin/main --oneline --grep "M6\."
git -C /Users/zhangalex/Work/Projects/FW/octos show <commit-hash> --stat

# 验证某文件是否在 main 上（避免再次踩 ls-tree --name-only 的坑）
git -C /Users/zhangalex/Work/Projects/FW/octos cat-file -e origin/main:<path> && echo IN_MAIN || echo NOT_IN_MAIN
```
