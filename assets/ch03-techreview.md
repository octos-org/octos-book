# Ch3 技术审查报告(ch03-techreview,C2)

- 审查人:peer C2(ch03-techreview,lane strong)
- 日期:2026-09-02
- 审查对象:`chapters/ch03-llm-providers.md`(475 行,段落重写定稿候选;`book/src/part1/ch03.md` 镜像已 cmp 一致)
- 源码:`/Users/zhangalex/Work/Projects/FW/octos` @ main **9c157101**(只读)
- 契约:`specs/ch03-llm-providers.spec.md`;C1 机械核对见 `assets/ch03-refcheck.md`,本报告不重复行号漂移类问题,只报技术判断项
- 方法:逐机制对照源码语义(非字符串比对),grep 交叉验证 19 family 表、必补项覆盖、跨章重复

## 文首计数表

| 等级 | 计数 |
|---|---|
| 🔴 Critical(机制描述错误 / spec 必补项缺失) | **5** |
| 🟠 Major(技术事实不准 / 关键前提缺失) | **3** |
| 🟡 Minor(表述不严谨) | **2** |

**结论:❌ 不可定稿。** spec 标注「新面三处必补」的 cache 经济学、sampler passthrough、per-profile context_window 覆盖在章稿中零覆盖,且容错链层级、退避序列、ChatConfig 字段存在与源码语义相反的描述。需一轮定向补写 + 修正后再审。

---

## Critical(5 条,每条附章稿行号 + 源码行号证据)

### C-1. spec 三处必补新面整体缺失;「成本层」「车道与路由」两节未新增

- **章稿**:全文 grep `cache_retention|CacheRetention|1.25|sampling_params|sampler|ContextWindowOverride|local_context_probe|lane.rs|router.rs|call_policy|throttle` 命中 **0**;现 3.6 是「本章回顾」(L431),spec 勘误方式要求的「新增『成本层』与『车道与路由』两个小节」不存在。
- **spec**:`specs/ch03-llm-providers.spec.md:30-33`(「新面三处必补」:① `f3aa07f0` cache 经济学;② `b0072e70` sampler passthrough;③ `3e479ce3` per-profile `context_window` 覆盖)、L34-36(新模块各一段)、完成条件 `review_ch03_cache_economics`(L82-85)与 `review_ch03_sampler_context_override`(L87-90)直接不满足。
- **源码证据(应写而未写的机制)**:
  - cache 经济学:`octos-llm/src/config.rs:60-91`(`ChatConfig::cache_retention` + `CacheRetention::{Default,None}` 三态、unset 不上 wire)、`anthropic.rs:145-155`(`prompt_caching && cache_retention != None` 才发三个 ephemeral 断点;一次性调用退出 1.25x cache-write 溢价)、`anthropic.rs:950,1010`(`cache_write_tokens` 计量)、`pricing.rs:123-128`(`CACHE_READ_INPUT_MULTIPLIER = 0.1` / `CACHE_WRITE_INPUT_MULTIPLIER = 1.25`)、`pricing.rs:130-200`(`CacheRates` 按协议而非 family 计价:#2194 review 明确「cache economics 是协议属性不是常量」,`speaks_anthropic_protocol` 覆盖 zai/r9s-claude 代理,Gemini 0.25x 读且无写计费)。
  - sampler passthrough:`config.rs:44-57`(`sampling_params: Option<Map>`,None → 不加键,cloud 请求字节不变)、`openai.rs:636-648`(展平进请求体 + `RESERVED_SAMPLING_KEYS` 防重键,#2172)、`openai.rs:651-668`(保留键清单:model/messages/max_tokens/temperature/tools/stream 等 12 键,dedicated field 赢)。
  - context_window 覆盖(操作员 > 探测 > 目录):`octos-cli/src/qos_catalog.rs:14-35`(#2142:override 包在 local-context probe 之外、RetryProvider/ProviderChain/AdaptiveRouter 之内,"beats BOTH the static catalog and the runtime probe",per primary/fallback 独立)、`qos_catalog.rs:267,296`(落点)、`octos-llm/src/local_context_probe.rs:1-30`(llama.cpp `/props`、`GET /v1/models` 探测真实窗口;unreachable/5xx 不 pin 只重试)、`context_override.rs:13,51`(薄包装仅覆写 `context_window()` 其余 delegate)。
- **修法**:按 spec 勘误方式新增 3.6「成本层」、3.7「车道与路由」(lane.rs RFC-3 topic→lane 过滤、router.rs `ProviderRouter` 前缀子代理路由、call_policy.rs FailFast、throttle.rs 各一段),引用以上行号。

### C-2. 注册表叙事仍是 15 Provider;实际 19 family,且缺 model_discovery 维度

- **章稿**:L123「octos 当前注册 15 个 Provider」、L127-141 表格 15 行(无 vertex、moonshot-coding、zai-coding、local);L143 重申「当前注册表共有 15 个 Provider」。
- **源码**:`registry/mod.rs:186-210` `static ALL` 现列 **19** 个 ENTRY(anthropic, openai, gemini, **vertex**, r9s, openrouter, deepseek, groq, **moonshot_coding**, moonshot, dashscope, minimax, **zai_coding**, zhipu, zai, nvidia, ollama, vllm, **local**);coding-plan family 排在 base family 之前(193-195 行注释)。`registry/mod.rs:121-167` `ProviderEntry` 已含 `model_discovery` 字段(L150-155,由 `discovery.rs:134 resolve_model_discovery` 消费,「协议绝不从 family 名推断」)——spec 完成条件 `review_ch03_registry_families`(spec L91-95)要求「family 注册以 registry/ 目录与 discovery.rs 为依据,列出 family 数量与生成命令」,章稿两者皆无(全文无 discovery.rs/resolve_model_discovery)。
- **与 C1 重合**:refcheck 汇总第 4 条已标行号漂移;本条升级为 critical 的依据是内容结构性过时(漏 4 个 family + 缺协议发现维度),非行号问题。
- **新 family 语义提示**:vertex(`registry/vertex.rs:59` 用 GeminiProvider + service-account,非 OpenAI 兼容)、local(`registry/local.rs:20` 多别名,配套 local_context_probe)——补表时协议列不能照抄「OpenAI 兼容」。

### C-3. 容错链层级描述与源码不符:AdaptiveRouter 不是「管理多个 ProviderChain 的顶层」,而是与 ProviderChain 同位二选一

- **章稿**:L7「顶层的三级容错链(RetryProvider → ProviderChain → AdaptiveRouter)」;L157-179 mermaid 图画成 `AdaptiveRouter → ProviderChain #1 / #2 → RetryProvider×N` 的三层嵌套;L242「AdaptiveRouter 是容错链的最高层」。
- **源码**:生产装配 `octos-cli/src/qos_catalog.rs:305-352`——`providers` 向量每个元素已是 `RetryProvider::new(p)`(L273/L297),然后 **`AdaptiveRouter::new(providers)` 或 `ProviderChain::new(providers)` 二选一**:`adaptive_routing.enabled` 缺省 false 时明确「falling back to static ProviderChain」(L343-352,注释「Adaptive routing must be *opt-in*」)。`gateway/profile_factory.rs:363,413`、`commands/chat.rs:1210`、`tools/switch_model.rs:289` 全部是 `ProviderChain::new(vec![RetryProvider…])`,**不存在 AR 内嵌多个 PC 的路径**。AdaptiveRouter 有自己的 per-slot circuit breaker(`adaptive.rs:1036-1040` 一带,`is_circuit_open`),与 ProviderChain 的 `ProviderSlot.failures` 是两套独立断路器。
- **修法**:把「三层」讲成「三级能力递进 + 两级装配」:RetryProvider(每 slot 恒包)→ ProviderChain(静态有序故障转移)或 AdaptiveRouter(评分路由,**替换而非叠加** chain,需显式 opt-in);mermaid 图改为二选一分支。现图会让读者以为开 adaptive 会多一层 chain 管理开销。

### C-4. ChatConfig 字段清单含两个不存在的字段,漏掉四个真实字段

- **章稿**:L65-72 列出 `model: 模型 ID`、`system_prompt: 系统提示`。
- **源码**:`config.rs:8-70` `ChatConfig` 实际字段为 `max_tokens`、`temperature`、`tool_choice`、`stop_sequences`、`reasoning_effort`、`response_format`、`context_management`、`sampling_params`、`cache_retention`——**没有 `model` 也没有 `system_prompt`**(model 在 provider 构造期由 registry 决定,system prompt 走 `messages` 数组,这正是章首 L5 自己强调的差异点,清单自相矛盾)。同时清单漏了 `reasoning_effort` / `stop_sequences` / `sampling_params` / `cache_retention`。
- **修法**:按 config.rs:8-70 重列,并顺势把 sampling_params/cache_retention 引到 C-1 的两节。

### C-5. 退避序列「1s → 2s → 4s → 8s」错误——8s 永不出现

- **章稿**:L198「最多重试 3 次,初始延迟 1 秒……实际退避序列为 1s → 2s → 4s → 8s(但被 60s 上限钳位)」。
- **源码**:`retry.rs:27-39` 默认 `max_retries=3, initial=1s, multiplier=2.0, max=60s`;chat 循环 `for attempt in 0..=max_retries`(retry.rs:322,stream 版 ~L378),且仅当 `is_retryable && attempt < max_retries` 才 `calculate_delay(attempt)` sleep(retry.rs:330-345 一带)。attempt 取 0/1/2 时各 sleep 一次 → 延迟恰为 **1s→2s→4s**,第 4 次调用失败后直接放弃;`2^3 = 8s` 只有在第 5 次调用路径上才会被计算,而循环不含它。60s 钳位在默认序列下同样永不触达(4s < 60s),那句「但被 60s 上限钳位」在默认配置语境下是空转修饰。
- **注**:refcheck L32 将该序列列入「内容通过」——那是字符串比对结论;按循环结构语义核对为误。3.6 回顾(L440)同句「1s→2s→4s」反而是对的,两处自相矛盾。

---

## Major(3 条)

### M-1. L143 称 OpenRouter「复用 `OpenAIProvider`」——实际是独立实现

- **章稿**:L143「Ollama、vLLM、OpenRouter、DeepSeek 等复用 `OpenAIProvider`」。
- **源码**:`registry/openrouter.rs:25,39` 工厂构造的是 `OpenRouterProvider`(`octos-llm/src/openrouter.rs:19`,自带独立 reqwest client/stream client、独立 SSE 解析入口 `parse_openai_sse_events`),不是 `OpenAIProvider`。同句其余核对无误:Ollama(`registry/ollama.rs:40`)、vLLM(`registry/vllm.rs:38`)、DeepSeek(`registry/deepseek.rs:41`)确实 `OpenAIProvider::new`;Z.AI 确用 `AnthropicProvider`(`registry/zai.rs:43`);R9s 按模型族切协议(`registry/r9s.rs:20-21,55-58`,仅 `claude-*` 前缀走 Anthropic,且大小写敏感)。把 OpenRouter 从复用清单摘出即可,顺带可提它"OpenAI 兼容但自带一层路由 provider"的定位,对公平性反而更准。

### M-2. EMA「质量/吞吐 60/40 复合」仅在 `qos_ranking` 开启时成立,章稿未提开关

- **章稿**:L252-259 权重表把「质量/吞吐」行写死为「60% 深度搜索 token 数 + 40% 吞吐量」,并称「默认配置下」。
- **源码**:`adaptive.rs:1819-1821`(运行时 `score()`)与 `adaptive.rs:524-528`(冷启动 seed)都是 `ranking_component = if qos_ranking { 0.6*norm_quality + 0.4*norm_throughput } else { norm_throughput }`——**qos_ranking 关闭时第二因子退化为纯吞吐,深度搜索 token 不参与**。qos_ranking 是 `adaptive_routing.qos_ranking` 配置项(`qos_catalog.rs:324`)。章稿把条件分支写成了无条件公式。权重 30/30/20/20 本身与 `adaptive.rs:58-67` 默认值一致 ✅,混合权重 `min(total/20, 0.5)`(L261)与 `adaptive.rs:1582,1772` 一致 ✅。

### M-3. 错误分类表对 408/400 的描述与源码分支不符

- **章稿**:L202-211 表格:408「是否重试:看具体情况 / 触发 failover:是」;400「看具体消息 / 部分情况」。
- **源码**:`retry.rs:173`(typed/status 路径)与 `retry.rs:231`(字符串回退路径)的可重试集合均为 `429|500|502|503|504|529`——**408 不在其中**;408 也非 timeout/connect,故 `is_retryable=false`,而 `should_failover` 的字符串分支只认 "401"/"403" 前缀(`retry.rs:133`),"408" 不含 "400" 子串 → **不重试、不 failover,直接失败上抛**。章稿两格都写宽了。400 的准确语义是:typed `LlmErrorKind::InvalidRequest` → failover=true(`retry.rs:97-100`,deepseek `reasoning_content` 400 场景),其余 400 保持当前 provider——建议把这行写成「typed InvalidRequest 才 failover」。表格其余行(429 解析 retry-after、401/403 不重试但立即 failover、reqwest timeout 不本地重试但 failover、504 可重试)与 `retry.rs:118-133,173-231` 一致 ✅。

---

## Minor(2 条)

### m-1. Arc<dyn Trait> 侧栏的「枚举无法支持用户自定义 Provider」论据与 octos 现实错位

- **章稿**:L419「无法支持用户自定义 Provider(除非用 `Custom` 变体退化回 trait object)」。但 octos 的 19 family 全部编译期封闭在 `static ALL`(`registry/mod.rs:186`),并没有运行时插件注册。对该代码库更有力的论据是:注册表工厂签名统一返回 `fn(CreateParams) -> Result<Arc<dyn LlmProvider>>`(`registry/mod.rs:156-157`),任何 `Vec<provider>` 容器/容错链装配天然要求同一擦除类型。侧栏整体论证(网络延迟 100ms-10s vs vtable <1ns、装饰器组合性、运行时配置选择)到位,仅此论据建议换掉。注意 L407 的类型爆炸示例与 C-3 修正后的结构要对齐(嵌套泛型在真实装配里是 `Vec<T>` 异构,泛型根本表达不了)。

### m-2. L336「SSE 协议保证事件边界不会落在 UTF-8 字符中间」表述不严谨

- 保证来自**解析器设计**(仅在 `\n\n`/`\r\n\r\n` 分隔符处切分、`String::from_utf8_lossy` 只作用于完整事件块,`sse.rs:106-131`),不是 SSE 协议的规定——协议只规定分隔符是 ASCII 换行。机制描述本身(字节累积、双分隔符搜索、1MB 上限发 error 事件并清缓冲、`stream::unfold` 保状态)与 `sse.rs:16-72` 完全一致 ✅,这句因果倒置改一个从句即可。

---

## 逐检查项结论

1. **机制描述正确性**:cache 经济学 / sampler passthrough / context_window 覆盖 → **未覆盖**(C-1);三层容错链分工衔接 → 层级错误(C-3),RetryProvider/ProviderChain 细节除 C-5/M-3 外准确;SSE → 准确(m-2 表述)。
2. **技术公平性**:无贬损或营销性措辞;OpenAI 兼容系表述公允度高,唯 OpenRouter 复用说错(M-1);19 family 表与 registry 现状不一致(C-2)。
3. **论证层数**:侧栏对比三方案 + 代价量化,论证到位(m-1 一处论据错位);「为什么」层总体讲透(detect_patterns 为空的原因、混合权重防冷启动、hedge 观测不完整的坦白 L285 均是好段)。
4. **跨章重复**:grep 对照 ch01/ch04/ch05,ch03 仅一句 ch04 预告(L450)和 ch05 对 `Arc<dyn LlmProvider>` 的前向引用(ch05 L22),**无超 3 行重复** ✅。
5. **章节结构**:3.1→3.5 自底向上顺序服务叙事线,3.3.4 融入自然;但「新增 3.6/3.7」实为未做(C-1),现 3.6 是回顾。

## 核对通过、无需改动的陈述(抽样)

退避默认参数 3/1s/60s/2.0(retry.rs:27-39);429 retry-after 解析 +1s 缓冲 / 30s 回退;failover 阈值 3、全降级取最少失败、成功重置(failover.rs:74,96-106,112-114);三模式 Off/Hedge/Lane 语义(adaptive.rs:617-627);hedge 备选最便宜且不同名、输者指标不记录(adaptive.rs:2150-2230);probe 10%/60s 仅打 stale 槽(adaptive.rs:62-63,2065-2093);credential pool 四策略与 `octos.harness.event.v1 credential_rotation` 事件(credential_pool.rs:10,239-240);classifier 默认关、关时 Strong、URL 仅 reason(content_classifier.rs:63-73,193-197);SSE 1MB 上限行为(sse.rs:6-7,37-45)。

## 是否可定稿

**不可定稿(❌)。** 一轮修订可解:补 C-1 两节(成本层 / 车道与路由,含三处新面)、改 C-2 至 19 family + discovery 维度、改 C-3 装配语义与图、C-4/C-5/M-1/M-2/M-3 定点改写——修订后建议 C1 复核新增引用行号,无需 C2 全文重审。
