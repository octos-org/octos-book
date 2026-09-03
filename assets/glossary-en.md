# English glossary (book-en)

Maintained by the translation lane. One English form per concept; add a row before introducing a new term.

| 中文 | English | Note |
|---|---|---|
| 外环 / 内环 | outer loop / inner loop | OctoLoop roles |
| 黑板 | blackboard | `.octos/OUTER_LOOP_REVIEW.md` |
| 主审 | outer reviewer | R7 duty holder |
| 车道 | lane | `cheap` / `strong` model lanes |
| 派单 | dispatch | |
| 采认 / 打回 | accept / return | outer verdicts |
| 工程决策侧栏 | Engineering decision | blockquote label |
| 定位 | Positioning | chapter anchor label |
| 版本演化说明 | Version note | chapter footer label |
| 延伸阅读 | Further reading | section title |
| 思考题 | Exercises | section title |
| 频道 | channel | octos-bus |
| 会话 | session | |
| 账本 | ledger | GoalLedger, event ledger |
| 租约 | lease | |
| 事实表 | facts table | `assets/chNN-facts.md` |
| 统稿 | final pass | |
| 双环 | dual loop | outer + inner loop collectively |
| 契约测试 | contract test | mechanical check vs snapshot/subprocess |
| 断路器 | circuit breaker | provider fault-tolerance chain |
| 凭据轮换 | credential rotation | provider fault-tolerance chain |
| fail-closed | fail-closed | sandbox/permission posture |
| 借用检查器 | borrow checker | Rust |
| 攻击面 | attack surface | ch01 |
| 多租户 | multi-tenant | ch01 |
| 能力层 | capability layer | unnumbered layer in ch01 topology |
| 热路径 | hot path | ch01 |
| 统计口径 | measurement methodology | ch01 scale table |
| 优雅关停 | graceful shutdown | ch01 |
| 审批流 | approval flow | tool-layer policy, ch01 |
| 门控 | gating | plugin discovery, ch01 |
| 领域语言 | domain language | ch2 framing term |
| 零依赖 core | zero-dependency core | architecture posture |
| 瘦 core / 胖 core | thin core / fat core | ch2 sidebar options |
| 跨 crate 协议字段 | cross-crate protocol field | wire identity |
| 乐观 UI | optimistic UI | client-side bubble |
| 长期 ABI | durable ABI | schema_version payloads |
| 类型化压缩 | typed compaction | ch8 SessionSummary |
| 中断触发词 | abort trigger | abort.rs |
| 单一事实源 | single source of truth | core boundary rule |
| 会话路由键 | session routing key | SessionKey |
| 截断报告 | truncation report | TruncationReport |
| Provider 注册表 | provider registry | ch03, model-name auto-detection |
| 对冲竞赛 | hedge racing | AdaptiveRouter Hedge mode |
| 探针策略 | probe policy | AdaptiveRouter, default 10%/60s |
| 凭据池 | credential pool | ch03 3.3.4 / 3.7, M6.5 |
| 内容分类器 | content classifier | Cheap/Strong tier heuristics |
| 模型目录 | model catalog | ModelCatalog, model_catalog.json |
| 容错链 | fault-tolerance chain | three tiers, two assembly options |
| 故障转移 | failover | |
| 缓存经济学 | cache economics | ch03 3.6, f3aa07f0 |
| 模型车道 | model lanes | per-topic lane routing, RFC-3 |
| 本地窗口探测 | local window probing | #2135, 10022387 |
| 检查点 | checkpoint | #27e budget checkpoint, ch05 |
| 续跑 | continuation | goal layer, master_continuation_scheduler |
| 错误桶 | error bucket | 16 typed retry buckets, ch05 |
| 宽限 | grace | LoopDecision::Grace, once globally |
| 循环自愈 | loop self-healing | #2172 / #2174, ch05 |
| 退化检测 | degeneration detection | detection.rs, ch05 |
| 变更轴 | axis of change | module split rationale, ch05 |
| 五道闸 | five budget gates | check_budget order, ch05 |
| 写权 | write ownership | #27h, result.md vs result.checkpoint.md |
| 主线九模块 | nine core modules | ch05 module map |
| 支线模块 | supporting modules | ch05 module map |
| 压缩双模块 | the two compaction modules | compaction.rs / loop_compaction.rs |
| 有界恢复 | bounded recovery | nudge-and-retry ≤2, ch05 |
| 情节记忆 | episodic memory | memory.rs, ch05 |
| 落盘 | persist to disk | checkpoint wording, ch05 |
| 器官级入口 | organ-level entry | pub(crate)/pub(super) entries, ch05 |
| 混合搜索 | hybrid search | BM25 + HNSW, ch04 |
| 倒排索引 | inverted index | BM25 term postings, ch04 |
| 词频 / 文档频率 | term frequency / document frequency | tf / df in BM25, ch04 |
| 前向兼容 | forward compatibility | schema_version, ch04 |
| 墓碑 | tombstone | HNSW soft delete, ch04 |
| 稠密累加器 / 稀疏累加器 | dense accumulator / sparse accumulator | #1855 hot path, ch04 |
| 三级降级 | three-tier fallback | hybrid → BM25-only → DB scan, ch04 |
| 降级可见性 | fallback visibility | VectorCoverage, ch04 |
| 经验记录 | Episode | octos-memory unit of experience, ch04 |
| 长期记忆 | long-term memory | MEMORY.md, ch04 |
| 每日笔记 | daily notes | YYYY-MM-DD.md, ch04 |
| 实体库 | entity bank | two-level prompt injection, ch04 |
| 写入闸 / 渲染闸 | write gate / render gate | guard.rs, ch04 |
| 优雅降级 | graceful degradation | BM25 without embeddings, ch04 |
| skill package | skill package | SKILL.md + manifest.json 目录形态, ch09 |
| runtime manifest | runtime manifest | plugins/manifest.rs 热路径结构, ch09 |
| verified copy | verified copy | SHA-256 校验后落盘副本, ch09 |
| fail-soft | fail-soft | MCP 启动逐 server 连接失败跳过, ch09 |
| fail-safe | fail-safe | concurrency 未知值落 Exclusive, ch09 |
| layered view | layered view | 技能目录分层视图, ch09 |
| auto-backgrounding | auto-backgrounding | spawn_only 运行时语义, ch09 |
| connection path | connection path | stdio / HTTP / OAuth 三接入, ch09 |
| configuration lane | configuration lane | mcp_servers / sub_providers, ch09 |
| 名称保护 | name protection | PROTECTED_NAMES, ch09 |
| 传输存活 | transport liveness | registry 持有 MCP 传输, ch09 |
| 运行面 | runtime surface | ch14 five surfaces; preface uses "runtime modes" loosely |
| 控制面 | control plane | serve convergence role, ch14 |
| 热加载 | hot reload | ConfigWatcher, ch14 |
| 分层默认值 | layered defaults | config_layer::apply, ch14 |
| 单写者锁 | single-writer lock | fs2 flock, OCTOS_DATA_DIR_LOCKED, ch14 |
| serve 门禁 | admission gates | --solo / --danger-full-access / --no-network, ch14 |
| 子账号继承 | sub-account inheritance | gateway ProfileConfig sections, ch14 |
| parent-trust | parent-trust | mcp-serve stdio trust model, ch14 |
| 编译期运行面 | compile-time runtime surface | feature gates, ch14 |
| 消息总线 | message bus | octos-bus, ch11 |
| 消息分片/切割 | message coalescing / splitting | coalesce.rs, ch11 |
| 硬切 | hard cut | 5 级切割第 5 级, ch11 |
| thread-bound streaming | thread-bound streaming | bound channel API, ch11 |
| sticky map | sticky map | 被 bound API 取代的旧 thread 恢复路径, ch11 |
| durable commit observer | durable commit observer | MessageCommitObserver, ch11 |
| child-session contract | child-session contract | ChildSessionContract, ch11 |
| 长轮询 | long polling | Telegram/Matrix User, ch11 |
| 百分号编码 | percent-encoding | encode_path_component, ch11 |
| write-then-rename | write-then-rename | 整会话原子重写, ch11 |
| keeper | keeper | server-side goal holder role, ch18 |
| 任务契约 | brief | peer task contract file, ch18 |
| 派生 | handoff | peer_handoff staging, ch18 |
| 落盘顺序/暂存 | staging | stage_peer write protocol, ch18 |
| 回流通道 | return channel | peer_findings/ledger_findings/open_escalations, ch18 |
| 预算收尾 | wrap-up turn | GoalWrapUp, ch18 |
| 栅栏分支 | fence branch | peer/<slug> branch in the clone, ch18 |
| 驾驶舱 | cockpit | herdr chapter anchor, ch21 |
| 识别契约 | detection contract | screen-text manifest, ch21 |
| 外环三原语 | the three outer-loop primitives | discover / inject / observe, ch21 |
| 双哨 | dual sentinels | positive ACK + negative events.jsonl watch, ch21 |
| 双重门 | double gate | named-agent list + foreground process match, ch21 |
| 注入静默丢失 | silent injection loss | herdr prompt failure mode, ch21 |
| 上岗清单 | onboarding checklist | OLP outer-loop boot card, ch21 |
| 重启硬清单 | restart hard checklist | OLP_OUTER_BOOT §0b four steps, ch21 |
| 冒烟验证 | smoke verification | herdr agent list `octoscode \| <pane> \| idle`, ch21 |
| 窗格 | pane | herdr terminal pane |
