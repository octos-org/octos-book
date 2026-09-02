# Ch3 引用核对报告(ch03-refcheck)

- 核对人:peer A(ch03-refcheck)
- 日期:2026-09-02
- 章稿:`chapters/ch03-llm-providers.md`(475 行,rewrite-v2)
- 源码:`/Users/zhangalex/Work/Projects/FW/octos` @ main **9c157101**(只读,未改动)
- 契约:`specs/ch03-llm-providers.spec.md`(分析基线同为 9c157101)
- 方法:`ls` 验路径、`wc -l` 验越界、`grep -n`/`sed -n` 验符号在区间、整段摘录与源码逐行比对。

## 文首汇总

**总引用数:45**(42 条带行号区间 + 3 条仅路径)

| 状态 | 计数 |
|---|---|
| ✅ 通过 | 21 |
| ❌ 路径/符号不存在或越界 | 2 |
| ⚠️ 行号漂移 / 符号不在区间 | 22 |

**需修正清单(按优先级)**:

1. ❌ **章稿 L76**:`HttpTimeoutConfig`(registry/mod.rs:33-58)——该类型**全仓不存在**;实际是 `CreateParams::http_timeout()`(registry/mod.rs:110-118),返回 `(u64, u64)` 元组而非配置结构体。需改符号名并重标行号。
2. ❌ **章稿 L375**:`catalog.rs:48-275` 越界——catalog.rs 现为 **274 行**(spec 勘误段已预告);`ModelCatalog` 结构体起于 48 行,区间末端应改 274。
3. ⚠️ **章稿 L15 + trait 摘录块**:trait 实际位于 provider.rs:**16-121**(摘录称 11-92)。整段 diff 还发现三处内容漂移:① 源码新增 `async fn ensure_ready()`(69-77 附近)与 `fn estimate_request_tokens()`(89-94 附近),摘录未含;② `context_window()`/`max_output_tokens()` 现有默认实现(调 `context::` 辅助函数),摘录写成无方法体;③ 摘录的 `provider_metadata_for_index(_index: usize)` 签名已改为 `(_provider_index: Option<usize>)`(103 行)。
4. ⚠️ **章稿 L123**:注册表叙事称 "15 个 Provider"——`static ALL`(registry/mod.rs:186-210)现有 **19 个 family**(新增 vertex、moonshot_coding、zai_coding、local;行号 87-105 → 186-210)。spec 完成条件要求 "列出当前注册表中的 15 个 Provider" 需按 19 family 重写。
5. ⚠️ **adaptive.rs 全部 8 条引用行号全部失效**(L242/244/252/261/267/291 + L297 两条):文件已扩至 **2795 行**,各符号实际位置见下表。这是漂移最集中的文件。
6. ⚠️ **retry.rs 3 条区间失效**(L187/215 及 L185 末端):`calculate_delay` → 259-265,`rate_limit_delay` → 267-311,`RetryProvider` 定义体 → 41-312。
7. ⚠️ **failover.rs 3 条漂移**(L221/230/238):`ProviderSlot` → 27-30,成功重置 → 112-114,`report_late_failure` → 378。
8. ⚠️ **registry/mod.rs 检测机制 3 条漂移**(L86/103/117):`ProviderEntry` → 121-167,`detect_provider` → 244-260,o 系列前缀检查 → 248-250。
9. ⚠️ **provider.rs 2 条漂移**(L57/59):`chat_stream` 默认实现 → 27-56;`provider_metadata*` → 97-109;L76 的默认超时常量 → 158-172(数值 300/10/60/15 本身仍正确,另有新增 `DEFAULT_LLM_STREAM_IDLE_TIMEOUT_SECS = 300`,165 行,可一并补)。

内容层面(行号之外)核对全部通过的陈述:退避序列 1s→2s→4s→8s 钳位 60s、429 解析 +1s 缓冲/30s 回退、混合权重 `(total/20).min(0.5)`、hedge 选最便宜备选、probe 默认 10%/60s、credential_rotation 事件 schema `octos.harness.event.v1`、classifier 默认 Strong、MAX_BUFFER_SIZE=1MB、"完成后" UTF-8 分割测试字节序列——均与源码一致。

---

## A. 引用核对表(主表)

图例:✅ 通过;❌ 路径不存在/符号不存在/越界;⚠️ 行号漂移或符号不在给定区间(给出当前正确行号)。

| 章稿行号 | 引用 | 状态 | 符号名 | 当前正确行号或说明 |
|---|---|---|---|---|
| L15 | `provider.rs:11-92` | ⚠️ | `trait LlmProvider` | 实际 **16-121**;且摘录块缺 `ensure_ready`/`estimate_request_tokens`,`provider_metadata_for_index` 签名已变(见汇总 3) |
| L51 | `provider.rs:13` | ✅ | "intentionally minimal" 注释 | 第 13 行确为该注释,语义吻合 |
| L57 | `provider.rs:25-49` | ⚠️ | `chat_stream` 默认实现 | 实际 **27-56**(起点在区间、末端越出);事件序列 Text→ToolCall→Usage→Done 仍正确 |
| L59 | `provider.rs:67-76` | ⚠️ | `provider_metadata` / `provider_metadata_for_index` | 符号不在区间;实际 **97-109** |
| L65 | `config.rs`(无行号) | ✅ | `ChatConfig` | 路径存在(343 行);字段清单与源码一致 |
| L76 | `registry/mod.rs:33-58` | ❌ | `HttpTimeoutConfig` | **符号全仓不存在**;实际为 `CreateParams::http_timeout()` @ **110-118**(返回 `(u64,u64)`) |
| L76 | `provider.rs:117-139` | ⚠️ | `DEFAULT_LLM_*_TIMEOUT_SECS` | 实际 **158-172**;数值 300/10/60/15 正确;新增 stream idle 300 @165 |
| L82 | `registry/mod.rs`(无行号) | ✅ | — | 路径存在 |
| L86 | `registry/mod.rs:61-82` | ⚠️ | `struct ProviderEntry` | 实际 **121-167**;字段结构有增(key_env_aliases、model_discovery) |
| L103 | `registry/mod.rs:131-150` | ⚠️ | `detect_provider()` | 实际 **244-260** |
| L117 | `registry/mod.rs:137-140` | ⚠️ | o1/o3/o4 前缀匹配 | 实际 **248-250**;前缀(非子串)语义正确 |
| L123 | `registry/mod.rs:87-105` | ⚠️ | `static ALL` | 实际 **186-210**;且 **15 → 19 family**(见汇总 4) |
| L185 | `retry.rs:40-226` | ⚠️ | `RetryProvider` | struct @41,定义体(inherent impl)至 **312**;40-226 只覆盖前半 |
| L187 | `retry.rs:149-154` | ⚠️ | `calculate_delay()` | 实际 **259-265**;算法与摘录代码逐行一致 |
| L198 | `retry.rs:28-37` | ✅ | `RetryConfig::default()` | impl @29-38;3 次/1s/60s/×2.0 全部吻合 |
| L200 | `retry.rs:107-147` | ✅ | `should_failover()` 判定表 | 函数 76-157,107-147 覆盖 LlmErrorKind 分支 + 401/403 + 400 特例;表格语义与源码一致 |
| L215 | `retry.rs:159-185` | ⚠️ | `rate_limit_delay()` | 实际 **267-311**;"try again in" 解析、+1s 缓冲、30s 回退均正确 |
| L219 | `failover.rs:36-249` | ✅ | `ProviderChain` | struct @41 + inherent impl 至 243;区间基本吻合(244 起为 LlmProvider impl) |
| L221 | `failover.rs:23-26` | ⚠️ | `struct ProviderSlot` | 实际 **27-30**(26 为文档注释);结构一致 |
| L230 | `failover.rs:104` | ⚠️ | 成功后计数器重置 | 实际 `record_success` @111-114(`swap(0)` 在 114);104 附近是 pick_start 尾部 |
| L232 | `failover.rs:85-99` | ✅ | `pick_start()` | fn @94-109,起点在区间;三条故障转移规则与源码一致 |
| L238 | `failover.rs:245-248` | ⚠️ | `report_late_failure()` | 符号不在区间;实际 **378**(245-248 现为 `chat()` 方法) |
| L242 | `adaptive.rs:486-1490` | ⚠️ | `AdaptiveRouter` | struct @**803**,impl 延伸至文件尾 **2795**;原区间仅覆盖前段辅助函数 |
| L244 | `adaptive.rs:486-499` | ⚠️ | `enum AdaptiveMode` | 实际 **619-631**(Off=0/Hedge=1/Lane=2 语义正确) |
| L252 | `adaptive.rs:1126-1202` | ⚠️ | `score()` 权重组合 | 符号不在区间;`score()` @**1766**+;权重配置字段 @42-64(`weight_latency` 0.3 等);30/30/20/20 语义正确 |
| L261 | `adaptive.rs:933-955` | ⚠️ | 混合权重 `(total/20).min(0.5)` | 实际 **1582** 与 **1772**(score 内 EMA blend);描述正确 |
| L267 | `adaptive.rs:1310-1409` | ⚠️ | `hedged_chat()` / `tokio::select!` | 实际 **2150+**(select 在 ~2220);"选最便宜备选" 注释也在该函数内 |
| L291 | `adaptive.rs:1297-1308` | ⚠️ | probe(`should_probe`/`probe_probability`) | `should_probe()` @**2097**,`is_stale` @337,默认 0.1/60s @42-44、62-63;数值正确 |
| L297 | `credential_pool.rs:1-29` | ✅ | 模块注释(persistent cooldown/rotation) | 区间内,"持久化 cooldown / rotation state" 表述吻合 |
| L297 | `credential_pool.rs:166-189` | ✅ | `enum RotationStrategy` | @166-189;FillFirst/RoundRobin/Random/LeastUsed 四策略吻合 |
| L297 | `adaptive.rs:674-737` | ⚠️ | auth / rate-limit 失败分类 | 符号不在区间;`notify_credential_failure()` @**1081+** |
| L297 | `adaptive.rs:1473-1490` | ⚠️ | (同上声称) | 1473-1490 现为 metrics 汇总代码,与凭据通知无关;应改指 1081-1120 一带 |
| L297 | `credential_pool.rs:213-245` | ✅ | `RotationEvent`(harness event) | @213-245;`schema: "octos.harness.event.v1"` @239,kind `credential_rotation` @221 |
| L299 | `content_classifier.rs:1-18` | ✅ | 模块注释(默认 Strong) | @1-18,"default off → Strong" 语义吻合 |
| L299 | `content_classifier.rs:61-80` | ✅ | 关闭时返回 `Strong` 的配置语义 | 区间覆盖默认路径文档(68 附近) |
| L299 | `content_classifier.rs:158-209` | ✅ | `classify()`(代码块/长度/关键词/URL) | fn @158-209;关键词与 URL-only-as-reason 行为吻合 |
| L299 | `adaptive.rs:783-812` | ✅ | `RoutingDecisionCallback` 类型 | 类型文档 @796-797("emit octos.harness.event.v1 { kind: routing.decision }")在区间内;但 `set_routing_decision_callback()` 安装方法 @**1414** 在区间外,建议补注 |
| L329 | `sse.rs:16-72` | ✅ | `parse_sse_response()` | fn @21-72(unfold @23,超限检查 @34);四步字节缓冲描述吻合 |
| L342 | `sse.rs:6-7` | ✅ | `MAX_BUFFER_SIZE` | 常量 @7,`1024*1024` 吻合 |
| L352 | `sse.rs:261-281` | ✅ | `test_utf8_split_across_byte_chunks` | 测试体 @~260-281;E5AE8C/E68890/E5908E 切"成"字节序与章稿图示一致,断言 @279 |
| L375 | `catalog.rs:48-275` | ❌ | `ModelCatalog` | **越界**:文件仅 **274 行**(spec 勘误已预告);struct @48,应改 48-274 |
| L389 | `catalog.rs:72-74` | ✅ | `get(id_or_alias)` | @72-74 精确命中;ID→别名→None 顺序吻合 |
| L65/L82/L475 | 仅路径引用(`config.rs`、`registry/mod.rs`、`crates/octos-llm/src/`) | ✅ | — | 3 条路径全部存在 |

---

## B. 新面必补盘点(以 spec「决策」段为准)

spec 列出:三处必补提交(①f3aa07f0 ②b0072e70 ③3e479ce3)+ 六个新模块各一段 + discovery/registry 叙事。逐项实测如下。

| # | spec 要求 | 实测结果 | 关键符号与行号(grep -n) | 给章稿补什么(链接 spec 完成条件) |
|---|---|---|---|---|
| B1 | ① `f3aa07f0` cache 经济学(anthropic.rs、config.rs、context_override.rs、pricing.rs),写成「成本层」小节 | ✅ 提交存在(`git cat-file -t` = commit,标题 "Cache economics: one-shot cache-write opt-out, cache-write-aware pricing…"),四个文件均存在 | config.rs:58-75 `ChatConfig::cache_retention` + `enum CacheRetention`(一次性调用退出);anthropic.rs:148、1965 one-shot 请求不写 cache,build_request 的 cache_control 装配 @179-207;pricing.rs:149/191-195 cache-write 按 1.25x 计价、cache-read 折扣建模 | 「成本层」小节的全部源码依据;完成条件 review_ch03_cache_economics 要求"各引用对应文件行号 + 注明 f3aa07f0" |
| B2 | ② `b0072e70` cloud-safe sampler passthrough(openai.rs、config.rs) | ✅ 提交存在("feat(llm): add cloud-safe sampler passthrough (repeat_penalty etc.)…") | config.rs:44-46 `extra sampler params` 字段;openai.rs:635-640 展平注入、908-909 字段文档(repeat_penalty/top_p/top_k/min_p/frequency_penalty…)、1614-1616 测试佐证 | 配置相关段落:sampler 参数如何逐字透传到 OpenAI 兼容服务;review_ch03_sampler_context_override 的 openai.rs+config.rs 行号要求 |
| B3 | ③ `3e479ce3` per-profile `context_window` 覆盖(`config.llm.primary/fallbacks`) | ✅ 提交存在("feat(llm): per-profile context_window override…")。**范围注记**:配置结构 `LlmModelSelectionConfig` 落在 `crates/octos-cli/src/`(config.rs、runtime/profile.rs、profiles.rs),不在 octos-llm;octos-llm 侧落点是 `context_override.rs` 的 wrapper | 提交信息:`config.llm.primary.context_window` / `fallbacks[i].context_window` → `apply_context_window_override` 包在 local-context probe(#2135)之外;octos-llm/src/context_override.rs 存在 | 配置段落:profile 级窗口覆盖如何同时压过静态目录与运行时探测;spec 完成条件"引用 config.llm.primary/fallbacks 的落点"——落点如实记录为 octos-cli+context_override 两处 |
| B4 | 新模块各一段:`lane.rs`、`router.rs`、`call_policy.rs`、`throttle.rs`、`credential_pool.rs`、`local_context_probe.rs` | ✅ 六个文件全部存在 | lane.rs:1 "Per-topic model lane routing (RFC-3, #1292)";router.rs:1 "Provider router for multi-model sub-agent"(前缀 scheme);call_policy.rs:1-2 语音 turn 的 FailFast 策略(短路 retry/failover/hedge);throttle.rs:1-2 信号量节流;credential_pool.rs:1(M6.5);local_context_probe.rs:1-3 探测本地服务器真实窗口,`new` @201 / `new_ollama` @226 | 各补一段模块定位;章稿 3.3.x 之外的「车道与路由」小节素材 |
| B5 | `10022387` 本地服务器探测真实上下文窗口 | ✅ 提交存在("feat(llm): probe local servers for their real context window (#2135)") | 即 local_context_probe.rs(provider.rs:69-77 `ensure_ready` 是其上游钩子:探测须在首次 compaction 决策前 resolve) | 3.1/3.3 段可补一句:context_window 不再纯静态,本地 family 由探测得出 |
| B6 | registry 叙事对齐:`registry/mod.rs`(509 行)family 注册 + `discovery.rs:134` `resolve_model_discovery`;不再出现 `enum Provider` | ✅ registry/mod.rs 实测 **509 行**(与 spec 一致);discovery.rs:**134** `pub fn resolve_model_discovery(family, api_type)` 精确命中;全仓 grep 未见 `enum Provider`(旧符号已不存在,章稿正文也未再使用 ✅) | `static ALL` @186-210 共 **19 family**;注册方式 = "add a file + one line in ALL"(mod.rs:2-4);registry/ 目录 20 个文件(19 family + mod.rs) | review_ch03_registry_families:章稿 L123 的"15 个 Provider"表需按 19 family 重列(vertex/moonshot_coding/zai_coding/local 缺席),并补 family 数量与模型发现协议说明 |
| B7 | 行号勘误:catalog.rs 现为 274 行 | ✅ 实测 **274 行**,与 spec 勘误一致;章稿 L375 仍写 48-275,未采纳勘误 | `ModelCatalog` @48;`get()` @72-74 | 对应 A 表 ❌ 项:章稿需改为 48-274 |

**新面必补项数:7**(三处提交 + 六个新模块合并计 1 项 + 10022387 + registry/discovery 叙事 + catalog 勘误)。
**spec 与源码不符项数:0** —— 所有 spec 点名的提交与文件均在 main@9c157101 实测存在。
**范围注记(非不符)**:B3 的 `config.llm.primary/fallbacks` 接线主体在 `crates/octos-cli/src/`,超出 `crates/octos-llm/` 主范围,章稿引用时需如实标注跨 crate 落点。

---

## 结论

- A 节:45 条引用,21 ✅ / 2 ❌ / 22 ⚠️;**需修正 24 条**(2 条 ❌ 必改,22 条 ⚠️ 行号重标,其中 adaptive.rs 8 条为重灾区,另有 trait 摘录块 3 处内容性漂移与 "15→19 Provider" 一处内容性过期)。
- B 节:spec「新面必补」全部可在源码落地,**无 spec 与源码不符项**,master 无需为存在性裁决;唯一需要裁决的是叙事取舍——B3 跨 crate 落点与 A 表 19 family 重列。
- 建议修订顺序:先改 2 条 ❌,再按文件批量重标 adaptive.rs(8)→ registry(4+1)→ provider.rs(3)→ retry.rs(3)→ failover.rs(3),最后补「成本层」与「车道与路由」两小节(spec 勘误方式段要求的新结构)。
