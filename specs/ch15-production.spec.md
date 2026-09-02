spec: task
name: "Ch15. 生产化：认证、诊断、监控与多租户(v2 重写,原 Ch14)"
inherits: project
tags: [part3, auth, hooks, monitoring, production]
depends: [ch13-runtime-modes]
estimate: 1.5d
---

## 意图

从开发到生产的最后一公里。本章展示 octos 的认证三流（OAuth PKCE/device code/
paste-token）、Hooks 生命周期系统、Prometheus/UI Protocol/harness SSE/tracing 监控集成、AppUI UI Protocol 控制面、以及多租户配置。
帮助运维和贡献者将 octos 部署到生产环境。当前主分支还引入了 UI Protocol
capability negotiation、`/api/events/harness` typed SSE、Setup/Admin store
和 harness event 控制面，本章需要把观测与控制的边界写清楚。最新主分支还加入
coding/autonomy capability、agent lifecycle、goal/loop primitive 和 supervisor
持久化/continuation 调度，本章需要明确这些是 orchestration substrate，而不是已完成的 self-evolving optimizer。

## 决策

- 源码文件: `crates/octos-cli/src/auth/`, `crates/octos-agent/src/hooks.rs`
- 辅助文件: `tenant.rs`, `monitor.rs`, API route 文件, `ui_protocol.rs`, `../octos/crates/octos-cli/src/api/events_harness.rs`, `../octos/crates/octos-cli/src/admin_token_store.rs`, `../octos/crates/octos-cli/src/smtp_secret_store.rs`, `../octos/crates/octos-cli/src/api/admin_setup.rs`
- 图表: OAuth PKCE 流程图、Hooks 事件生命周期图、熔断器状态机、UI Protocol capability negotiation、Harness events observability layers、生产控制面总图
- 图表还应覆盖 coding/autonomy 控制面：coding tool contract、AgentOrchestrator、TaskSupervisor、SupervisorStore、MasterContinuationScheduler
- 工程决策侧栏: 为什么 hooks 用 exit code 而非 JSON 响应

- 事实边界(2026-09-02 main): 三个存储已从 octos-cli 迁到 `crates/octos-store/src/`(`admin_token_store.rs`、`setup_state_store.rs`、`smtp_secret_store.rs`,同目录还有 `admin_audit_store.rs`、`approvals_audit.rs`、`login_allowlist.rs`、`usage_ledger.rs`、`user_store.rs`);多租户实现迁到 `crates/octos-services/src/tenant.rs`(`render_frpc_config` :255 是新的部署路径);诊断独立成 `crates/octos-diagnostics/`(`7f81fa5e` doctor Stage 1、`1801a9e9` GitHub client + update --check Stage 2)
- 失效引用: 旧稿 8 处 `crates/octos-cli/src/api/ui_protocol.rs` 与存储路径引用全部改指新 crate;事实表 `assets/ch15-facts.md` 列 octos-store / octos-services / octos-diagnostics 全部文件行数与首行文档
- 结构: 14.1 认证三流保留;14.2 Hooks 缩为交叉引用 Ch10;14.3 可观测性补 doctor 两阶段;14.4 多租户改按 tenant.rs;14.5 控制面改按 octos-store;新增「部署路径:frpc 隧道」一节
- 重编号: 本章由 Ch14 改为 Ch15;`chapters/ch14-production.md` → `chapters/ch15-production.md`,`book/src/part3/ch14.md` → `book/src/part3/ch15.md`,SUMMARY.md 同步
- 图表: 生产控制面组件图(三 crate)、doctor 两阶段流程、租户隧道部署图
- 分析基线: octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch14-*.md
- octos-book/book/src/part3/ch14.md
- octos-book/book-en/src/part3/ch14.md
- octos-book/assets/ch14-*

### 禁止做
- 不暴露具体的 token 格式或加密密钥
- 不提供云厂商特定的部署 step-by-step

## 排除范围

- 云厂商 IaC 脚本（Terraform/Pulumi）
- Kubernetes 部署 YAML

## 完成条件

场景: 认证三流完整
  测试: review_ch14_auth_flows
  当 阅读认证小节
  那么 分别展示了 OAuth PKCE（带 SHA-256 challenge）、device code、paste-token 的流程
  并且 说明了凭据存储位置（`~/.octos/auth.json`）和 mode 0600 权限
  并且 解释了常量时间 bearer token 比较的安全意义

场景: Hooks 生命周期完整
  测试: review_ch14_hooks
  当 阅读 Hooks 小节
  那么 列出了核心 4 个事件（before/after × tool_call/llm_call）
  并且 说明当前源码还包含 resume/turn/spawn lifecycle 事件，避免把 HookEvent 写成只有 4 种
  并且 解释了 shell 协议（stdin JSON + exit code 语义）
  并且 说明了熔断器（3 次失败自动禁用）和可配置阈值
  并且 解释了 argv 数组执行（无 shell 解释）的安全意义

场景: 监控集成
  测试: review_ch14_monitoring
  当 阅读监控小节
  那么 说明了 Prometheus 指标端点的暴露方式
  并且 列出了关键指标（请求量、延迟、token 用量等）
  并且 解释了 UI Protocol 进度流、harness typed SSE 与 tracing 分别解决什么观测问题

场景: AppUI UI Protocol 控制面
  测试: review_ch14_ui_protocol
  当 阅读 UI Protocol 小节
  那么 说明了 `/api/ui-protocol/ws` 是 AppUI 的 WebSocket JSON-RPC 控制通道
  并且 说明了 `session/open` 返回 profile、workspace、cursor、panes 和 capabilities
  并且 说明了 capability negotiation 和 `harness.task_control.v1` 的方法级门控
  并且 说明了 task list/cancel/restart 这类控制能力不是普通 SSE 事件

场景: 多租户配置
  测试: review_ch14_multi_tenant
  当 阅读多租户小节
  那么 解释了 Profile / Account / User / Session 的分层隔离机制
  并且 说明了子账号通过 `parent_id` 继承父 profile 的 `config.llm`、search、deep_crawl、apps、email 和 env_vars base
  并且 说明了子账号不继承父账号安装的 customer skills
  并且 区分 standalone Gateway 的同进程 actor 隔离和 process-manager 的 per-profile gateway 子进程
  并且 说明了租户间的资源边界仍需要系统级限额补足

场景: exit code 侧栏
  测试: review_ch14_exit_code_sidebar
  当 阅读工程决策侧栏
  那么 对比了 exit code vs JSON 响应 vs gRPC 三种 hook 协议
  并且 解释了 exit code 在简洁性和跨语言兼容性上的优势

场景: UI Protocol capability negotiation 准确
  测试: review_ch14_ui_protocol_capability_negotiation
  当 阅读 UI Protocol capability 小节
  那么 说明 `SessionOpened.capabilities` 来自 client 请求 features 与 server known features 的交集
  并且 说明无 feature header 时返回 `first_server_slice` 以支持 discovery
  并且 说明发送 feature header 时未知 feature 会被丢弃
  并且 说明 `task/list`、`task/cancel`、`task/restart_from_node` 只在协商到 `harness.task_control.v1` 时出现在 `supported_methods`
  并且 包含 UI Protocol capability negotiation sequence diagram

场景: Coding autonomy 控制面准确
  测试: review_ch14_coding_autonomy_control_plane
  当 阅读 Coding / Agent / Goal / Loop 控制面小节
  那么 说明 `coding.tool_contract.v1`、`coding.autonomy.v1`、`coding.agent_control.v1`、`coding.goal_runtime.v1`、`coding.loop_runtime.v1` 的用途
  并且 说明 agent/list、agent/status/read、agent/output/read、agent/artifact/list/read、session/goal/get/set/clear、loop/create/list 等方法受 capability gate 控制
  并且 说明 `image_generation` 当前不作为真实可用能力广告
  并且 说明 AgentOrchestrator、TaskSupervisor、SupervisorStore、MasterContinuationScheduler 的职责边界
  并且 明确当前没有实现 DSPy/GEPA-style 自动 prompt/program optimizer 或完整 self-evolving runtime

场景: harness events 与 tracing/metrics 边界
  测试: review_ch14_harness_events_observability
  当 阅读可观测性小节
  那么 区分 tracing、Prometheus metrics 和 `/api/events/harness` 的职责
  并且 说明 `/api/events/harness` 是 typed event stream，不是通用 log stream
  并且 说明 `kinds` filter 支持 snake_case、CamelCase 和 kebab-case 归一化
  并且 说明 top-level `kind` 和 nested `payload.kind` 两类 frame 都被兼容

场景: 生产控制面总图
  测试: review_ch14_production_control_plane
  当 阅读生产控制面小节
  那么 说明 admin token store、setup state、SMTP secret store、profile config、gateway/serve/process manager 的关系
  并且 说明 `admin_token.json` 是 hash store
  并且 说明 `smtp_secret.json` 优先于 SMTP env var
  并且 包含生产控制面 Mermaid 图

场景: 事实表可复现
  测试: review_ch15_facts_sheet
  假设 `assets/ch15-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 三个 crate 的文件清单、行数、首行文档与命令输出一致

场景: 存储迁移引用已更新
  测试: review_ch15_store_refs
  当 提取正文中 admin_token / setup_state / smtp_secret 相关引用
  那么 全部指向 `crates/octos-store/src/` 且路径存在

场景: 多租户与部署路径准确
  测试: review_ch15_tenant_deploy
  当 阅读多租户与部署小节
  那么 `render_frpc_config` 引用 `crates/octos-services/src/tenant.rs` 实际行号
  并且 doctor 两阶段注明 7f81fa5e / 1801a9e9

场景: 重编号完成
  测试: review_ch15_renumber
  当 检查文件名与 SUMMARY.md
  那么 章节文件为 `chapters/ch15-production.md`、镜像为 `book/src/part3/ch15.md`
  并且 SUMMARY.md 对应条目为第 15 章

场景: 引用零失效
  测试: review_ch15_refs_valid
  当 提取正文全部 `crates/...rs:行号` 引用并对照当前源码
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
