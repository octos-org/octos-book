spec: task
name: "Ch3. octos-llm：驯服 LLM Provider 的混乱(v2 段落重写)"
inherits: project
tags: [part1, llm, provider, failover, streaming]
depends: [ch02-core-types]
estimate: 1.5d
---

## 意图

octos-llm 是整个系统与外部 LLM 的桥梁。本章展示如何用 Rust
trait 抽象统一少数专用协议实现和 10+ 种兼容 Provider，以及如何构建三层容错链
实现生产级可靠性。当前主分支还加入了 provider metadata、HTTP timeout knobs、
credential pool、content classifier 与 routing decision event；SSE 流式解析的工程细节
对 AI 应用开发者尤其有价值。

## 决策

- 源码目录: `crates/octos-llm/src/`
- 重点文件: `provider.rs`, `retry.rs`, `failover.rs`, `adaptive.rs`, `sse.rs`, `credential_pool.rs`, `content_classifier.rs`, `anthropic.rs`, `openai.rs`
- 事实边界(2026-09-02 main): `crates/octos-llm/src/` 有 38 个源文件 + `registry/` 目录 20 个 provider family 文件;旧稿的 `enum Provider` 符号已不存在,注册表改讲 `registry/mod.rs`(509 行)的 family 注册与 `discovery.rs:134` 的 `resolve_model_discovery`
- 新面三处必补: ① `f3aa07f0` cache 经济学——一次性 cache-write 退出、cache-write 感知定价(`anthropic.rs`、`config.rs`、`context_override.rs`、`pricing.rs`),写成容错链之外的「成本层」小节;② `b0072e70` cloud-safe sampler passthrough(`openai.rs`、`config.rs`);③ `3e479ce3` per-profile `context_window` 覆盖(`config.llm.primary/fallbacks`)
- 行号勘误: `catalog.rs` 现为 274 行,旧稿 `catalog.rs:48-275` 越界,重标
- 新模块各一段: `lane.rs`、`router.rs`、`call_policy.rs`、`throttle.rs`、`credential_pool.rs`、`local_context_probe.rs`(`10022387` 本地服务器探测真实上下文窗口)
- 勘误方式: 保留 3.1-3.5 结构,新增「成本层」与「车道与路由」两个小节;所有引用行号逐条重标
- 图表: 三层容错链流程图、Provider family 注册表一览表、cache 经济学决策流
- 工程决策侧栏: `Arc<dyn Trait>` 的选择与 trait object 的代价

- 分析基线: octos main @ 9c157101;镜像同步 `book/src/part1/ch03.md`

## 边界

### 允许修改
- octos-book/chapters/ch03-*.md
- octos-book/book/src/part1/ch03.md
- octos-book/book-en/src/part1/ch03.md
- octos-book/assets/ch03-*

### 禁止做
- 不讲各 LLM 的 API 文档细节（读者查官方文档）
- 不讲 Agent Loop 如何调用 LLM（Ch5 覆盖）

## 排除范围

- 各 LLM 模型的能力对比
- Prompt engineering 技巧

## 完成条件

场景: LlmProvider trait 抽象清晰
  测试: review_ch03_provider_trait
  当 阅读本章 trait 抽象小节
  那么 展示了 `LlmProvider` trait 的完整签名
  并且 解释了 `chat()` 方法如何统一不同 Provider 的请求/响应格式
  并且 说明 `provider_metadata` / `provider_metadata_for_index` 用于把实际命中的 provider slot 传给上层观测和成本归因

场景: Provider 注册表完整
  测试: review_ch03_provider_registry
  当 阅读 Provider 注册表小节
  那么 列出了当前注册表中的 15 个 Provider 及其协议/别名/示例模型
  并且 解释了模型名自动检测机制（claude→anthropic, gpt→openai）
  并且 明确区分 detect_patterns 为空的 Provider 只能通过显式 provider 名或 alias 命中
  并且 说明了专用实现与兼容适配的边界（如 Ollama 复用 OpenAI 兼容层）

场景: 三层容错链逐层讲解
  测试: review_ch03_failover_chain
  当 阅读三层容错链小节
  那么 分别解释了 RetryProvider、ProviderChain、AdaptiveRouter 的职责
  并且 包含 Mermaid 流程图展示请求在三层间的流转
  并且 AdaptiveRouter 部分包含 EMA 评分和 circuit breaker 机制
  并且 说明 credential pool 如何接收 429/auth failure 并执行 cooldown/refresh
  并且 说明 content classifier 如何产生 `routing.decision` harness event 并影响模型 tier

场景: SSE 流式解析工程细节
  测试: review_ch03_sse_parsing
  当 阅读 SSE 流式解析小节
  那么 解释了有状态解析器的设计（为什么不用无状态逐行解析）
  并且 说明了 1MB 缓冲上限的安全考量

场景: trait object 侧栏有深度
  测试: review_ch03_trait_object_sidebar
  当 阅读工程决策侧栏
  那么 对比了 `Arc<dyn Trait>` vs 泛型 `impl Trait` vs enum dispatch
  并且 解释了 octos 选择 trait object 的具体场景和代价（vtable 开销、无法内联）

场景: 成本层小节有源码依据
  测试: review_ch03_cache_economics
  当 阅读「成本层」小节
  那么 一次性 cache-write 退出与 cache-write 感知定价各引用对应文件行号
  并且 注明引入提交 f3aa07f0

场景: sampler 与 context_window 覆盖写明
  测试: review_ch03_sampler_context_override
  当 阅读配置相关段落
  那么 sampler passthrough 引用 openai.rs 与 config.rs 行号
  并且 per-profile context_window 覆盖引用 config.llm.primary/fallbacks 的落点

场景: 注册表叙事对齐 family 目录
  测试: review_ch03_registry_families
  当 阅读 Provider 注册表小节
  那么 不再出现 `enum Provider`
  并且 family 注册以 registry/ 目录与 discovery.rs 为依据,列出 family 数量与生成命令

场景: 引用零失效
  测试: review_ch03_refs_valid
  当 提取正文全部 `crates/octos-llm/src/**/*.rs:行号` 引用并对照当前源码
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
