# Ch15 技术审查报告(C2 / ch15-techreview)

- 审查对象:`chapters/ch15-production.md`(master 定稿副本,含 C1 修复 cf68bb8)
- 事实基准:`assets/ch15-facts.md`;源码只读 `/Users/zhangalex/Work/Projects/FW/octos` @ `9c157101`(2026-09-02 19:37:40 +0800,本会话 `git log -1` 复核一致)
- 规范:`specs/ch15-production.spec.md`
- 审查方式:正文全部 `crates/...rs:行号` 引用逐条对照源码 `sed/grep` 复核;跨章重复对 Ch1/Ch7/Ch10/Ch13(另查 Ch14)grep 核对;mermaid 三图与正文文字逐节点比对
- 本报告只报告不改稿

## 计数表

| 级别 | 数量 | 结论 |
|---|---|---|
| Critical | **1** | 章号引用错误(第 13 章≠运行模式) |
| Major | **2** | 抽取次数计数矛盾;版本说明失效自引 |
| Minor | **4** | mermaid typo ×1、图15-1 边语义、tenant 统计口径、spec 偏差清单 |
| 机制正确性抽查 | 42 处引用 **42 通过 / 0 失败** | 全部与源码一致 |

**是否可定稿:暂不可。** 机制描述层零错误,但 1 critical + 2 major 均为文字级问题,预计 ≤10 行改动后可定稿。

---

## Critical

### C-1 章号引用错误:前置依赖指向错误章(正文 :3)

> 「前置依赖:第 13 章(运行模式)。」

- **证据**:全书结构中第 13 章是 octos-pipeline(`chapters/ch13-pipeline.md` 标题「第 13 章:octos-pipeline:DOT 图驱动的工作流引擎」);运行模式是**第 14 章**(`book/src/SUMMARY.md:32`「第 14 章:运行模式与配置体系」)。
- 正文 :298 自己也写对了:「运行模式与配置体系见第 14 章」——同章前后不一致,即为 brief 点名的 13→14 残留类错误(C1 修复 cf68bb8 漏掉了 :3 这一处)。
- **修复**:「第 13 章(运行模式)」→「第 14 章(运行模式与配置体系)」。附注:spec 头部 `depends: [ch13-runtime-modes]` 的键名同样是旧编号残留,建议 spec 侧一并订正(非本章义务)。

## Major

### M-1 抽取次数自相矛盾(:7 vs :13 vs :302)

- :7「生产化经历了**两次**抽取。第一次…octos-store;第二次…octos-services;**最近一次**…octos-diagnostics」——句内列了三次却说两次。
- :13 节标题「15.1 为什么要拆:**两个 crate** 的抽取史」,但 15.1.4 整节讲第三个 crate(octos-diagnostics)。
- :302 回顾又写「**三次**抽取:octos-store…octos-services…octos-diagnostics」。
- **证据**:三 crate 均实际存在(`crates/octos-store`、`crates/octos-services`、`crates/octos-diagnostics`,`wc -l` 分别 2664/3223/2243 total,本会话复核)。
- **修复**:「两次抽取」→「三次抽取」;节标题「两个 crate 的抽取史」→「三个 crate 的抽取史」。

### M-2 版本演化说明失效自引:认证三流「详见本章 15.1」(:327)

> 「认证三流详见本章 15.1」

- **证据**:15.1 是「为什么要拆:抽取史」(:13-93),全节无 OAuth PKCE/device code/paste-token 任何流程内容;「认证三流」在本章仅 :9 的三行结论性引用。同理 :9 的「完整走读分别在**旧章位置**已有覆盖」不成立——旧 Ch14 已被本章替换重写,书内已无承载三流完整走读的章节(grep 全书 chapters/:PKCE 流程只在 本章 :3/:9/:327 与 spec 出现)。
- 关联 spec 债务见 Min-4。
- **修复**:改为「认证三流凭据存储与比较语义见本章 :9;完整流程走读未在本书展开(或:待补/见第 X 章)」,并同步修正 :9 的「旧章位置」表述。

## Minor

### Min-1 mermaid 图 15-2 typo:「frs 服务端」(:213)

- `subgraph VPS["VPS(frs 服务端)"]`——frp 的服务端进程名是 **frps**(本章他处均写 frps,`render_frpc_config` 的 `{{FRPS_TOKEN}}` 等占位符亦为 frps)。
- **证据**:`crates/octos-services/src/tenant.rs:29-30`「The **frps** plugin verifies `md5(tunnel_token + timestamp)` during Login」。

### Min-2 图 15-1 虚线边语义与「同进程」表述冲突(:136-157 附近)

- 图中 `SRV -.->|同进程内 profile 目录隔离| GW1`:SRV(octos serve)与 GW1(PM 下的 gateway 子进程)在图上是两个分离的 subgraph,边标签却写「同进程内」。文字(:15.2.3)说两层「并不互斥」,图的画法把两条路径混在一条边上,读者会问「到底同不同进程」。
- **修复建议**:去掉该虚线边,改为 SRV 节点旁注「进程内按 profile 目录隔离」,或拆成两个独立小图。

### Min-3 §15.2 tenant 命中统计跳过第二名(:99)

> 「最多的…agent_orchestrator.rs(921 次),其次才是 admin.rs(138)…」

- **证据**:事实表 §4 Top 文件顺序为 agent_orchestrator 921、**ui_protocol_tests.rs 212**、admin.rs 138、auth_handlers.rs 130、ui_protocol_transport.rs 102。「其次」在计数上不成立(212>138)。
- **修复**:补「(测试文件 ui_protocol_tests.rs 212 次居次,不计入)」或改措辞「非测试文件中其次」。

### Min-4 spec 完成条件与正文的偏差(记录性,豁免需显式化)

正文以 15.5 边界声明 + 交叉引用处理了以下 spec 完成条件,属重写范围收窄决策,但**未见任何显式豁免记录**,且与 M-2 的失效自引相互印证:

| spec 要求 | 正文现状 |
|---|---|
| 认证三流完整(PKCE SHA-256 challenge/device code/paste-token 流程图) | 仅 :9 三行结论性引用,无流程、无图 |
| Hooks exit-code vs JSON vs gRPC 工程侧栏 | 指向第 10 章 |
| `/api/ui-protocol/ws` 端点与 `session/open` 返回字段(profile/workspace/cursor/panes/capabilities) | 15.4.3 未提 ws 端点,仅议 capability 机制 |
| capability negotiation sequence diagram | 无(仅文字) |
| coding autonomy 五个 feature 常量与方法 gate 枚举、image_generation 不广告 | 15.5 一句划给第 18 章(「orchestration substrate」边界声明本身已满足 spec 意图) |

- **建议**:在版本演化说明中补一行「按重写范围决策,以上项让渡至 Ch10/Ch18,spec 完成条件相应豁免」,并同步 spec;否则按 spec 验收会被判未达。

---

## 检查项逐项结论

### 1) 机制描述正确性 —— ✅ 通过(42 处引用逐条复核,0 失败)

**三 crate 抽取史**:`wc -l` 复核 store 9 文件 2664 行 / services 8 文件 3223 行 / diagnostics 8 文件 2243 行,与正文及事实表一致;文件级行数(store 8 模块 + services 7 模块 + diagnostics 7 模块)逐一对上;Cargo 依赖方向复核(store → 仅 octos-core;services → core/llm/bus,`grep octos crates/octos-{store,services}/Cargo.toml`);「octoscode#182」ADR 出处核实于 `octos-diagnostics/src/lib.rs:6`;「current_version 必须由调用方传入」硬规则核实于 `spec.rs:7-9`;`AdminTokenRecord` 四字段(:14-21)、`constant_time_eq` 校验(:39-45)、临时文件+rename+0o600(:96-104)、尾部测试断言 0o600(:182)全部核实。

**多租户四层隔离**:
- session_scope 边界:`session_scope.rs:46-68` 逐行核实(多租户共享一进程、`<config_dir>/profiles/<tenant_id>/`、跨租户无条件拒绝、跨 session 写在 workspace 层拒、读需显式动作、solo 无边界)——正文转述准确。
- resolve_effective_profile 继承:`profiles.rs:2403-2450` 核实:llm 无条件覆盖(:2418 `ec.llm = pc.llm.clone()`)、review/search/deep_crawl/apps/email/tool_policy 六项 None 才继承、env_vars 父 base 子覆盖合并(:2444-2448)——正文「三档」归纳与代码精确对应;customer skills 确实不在该函数继承链内(函数体无 skills 处理)。`create_sub_account` 规则三条 + `MAX_SUB_ACCOUNTS_PER_PARENT = 10`(:16)+ 子账号 id `{parent}--{sub}` + 创建时 `llm: None`(:2088)均核实。
- session actor 竞态:`session_actor.rs:1-4` 文档原文「eliminating the `set_context()` race condition where shared tools could route messages to the wrong chat」——正文对竞态成因与 actor 解法的转述准确;`profile_factory.rs:1-4` per-profile dedicated ActorFactory 核实。

**frpc 隧道**:`SSH_PORT_START 6001/SSH_PORT_END 6999`(:14-15)、`TenantConfig`(:23)九类字段含 tunnel_token 注释「frps 插件 Login 阶段校验 md5(tunnel_token + timestamp)」(:29-30)、`next_ssh_port` 顺序找空位池满报错(:185-194)、四个 find_by_*(197/203/209/219)、`render_frpc_config`(:255,`include_str!` 内嵌模板 + 七占位符替换,代码块与源码逐字符一致)、id 校验测试组拒绝空/大写/首尾连字符/路径穿越(`tenant.rs` 测试 :278 起)——全部核实。

**运维面**:metrics.rs 1554 行;`init_metrics`(:18)、`metrics_handler`(:29-34)、`record_tool_call`(:929)/`record_llm_tokens`(:937)/`record_routing_decision`(:947);`build_operator_summary_from_sources`(:139-193)四信号独立判据核实——running 位、api_port、scrape_status=="failed"、样本非空各自分支(:161-178),非 running 单走 `configuration_error_gateways`(结构体 :49)且注释明言防「坏配置被读成活进程」,「聚合为何不放 Prometheus 侧」的论证成立(跨进程 running 位只有 process manager 知道)。events_harness 183 行:kinds 归一化、307 重定向历史、user_auth_middleware 只读——与文件头注释(:1-20)一致。UI Protocol 7221 行:feature 常量(:113)、`first_server_slice`(:1630,字节级兼容注释原文核实)、`for_negotiated_features`(:1658 起,交集+未知丢弃+方法门控+method_not_supported 理由注释原文核实)。monitor:Monitor(:120)/add_sender(:159)/run(:164)/Telegram(:357)/Feishu(:390),`health_interval`(:129)/`max_restart_attempts`(:127)字段核实。updater:update(:140)五步、check_latest(:76)、GITHUB_TOKEN 回退(:40-49)核实。doctor 两阶段 commit 号 7f81fa5e/1801a9e9 与事实表 git log 记录一致。

### 2) 技术公平性(抽取 vs 保留 cli 内)—— ✅ 通过

15.1.5 给出了反方向判据:「依赖 AppState 或路由的代码(handler、middleware)留在 octos-cli,没有跟着搬」,并上升到可复用边界「按依赖方向拆,而不是按领域名词拆」;15.1.1 对抽取代价(测试树、编译闭包)与收益(复用、粒度)两侧均有陈述,无单边吹捧。

### 3) 论证层数(「为什么这样设计」)—— ✅ 通过

各节均含设计理由:15.1.1 依赖方向三切面、15.1.2 redb vs JSON 侧栏(写入形态→数据量→查询复杂度的判断序)、15.2.2 继承三档的心智模型、15.2.3 actor 把隔离从「约定」变「结构」、15.3.1 id 校验=路径安全第一道闸、15.4.1 聚合四信号判据、15.4.5 双路径分工、15.4.6 侧栏 smtp_secret 暴露面论证。无「只列清单不讲为什么」的节。

### 4) 跨章重复(Ch1/Ch7/Ch10/Ch13 ≤3 行)—— ✅ 通过

grep 四章:Ch7/Ch10/Ch13 对 session_scope/resolve_effective_profile/render_frpc_config/admin_token_store/租户等关键词零命中;Ch1 仅 crate 地图两行(store/services/diagnostics 行数),为合理回指。**额外发现(不在清单,不计违规)**:Ch14 §14.3/§14.6.2 亦描述子账号继承(config.llm/env_vars base,约两段),与本章 15.2.2 存在主题重叠,但两章侧重不同(Ch14 讲结构化配置sections,Ch15 讲继承三档+安全语义),行数未超限,建议定稿时在 15.2.2 加半句「配置 section 结构见 14.3」即可。

### 5) 结构 —— ⚠️ 一处 critical(见 C-1),其余通过

- DDIA 叙事线:问题(为什么拆)→机制(三 crate)→隔离(四层)→部署(frpc)→运维面(读状态→动手修)→边界→回顾,生产化主线完整。
- mermaid 3 张(图15-1/15-2/15-3)与文字逐节点比对:15-3 全部节点与 15.4 各小节一一对应 ✅;15-2 拓扑与 tenant.rs 机制一致,仅 Min-1 typo;15-1 存在 Min-2 边语义问题。
- 章号引用:除 C-1 外(:3),:9(第 10 章)、:298(第 7/10/14/1/18 章)、:327(第 10 章)均正确。

## 汇总判定

| 项 | 状态 |
|---|---|
| 机制正确性(42 引用复核) | ✅ 0 失败 |
| 技术公平性 | ✅ |
| 论证层数 | ✅ |
| 跨章重复 | ✅ |
| 结构(叙事/mermaid/章号) | ⚠️ C-1 + Min-1/Min-2 |
| 文字自洽 | ❌ M-1/M-2/Min-3 |
| spec 完成条件覆盖 | ⚠️ Min-4(需显式豁免) |

**是否可定稿:暂不可。** 全部问题为文字级(C-1、M-1、M-2 三处必修,Min-1/2/3 建议顺手修,Min-4 补一行豁免说明),源码机制描述无一处需要返工——修复后本章即达到可定稿水平。
