# Ch3 修复报告(ch03-fix-spawn)

- 修复人:ch03-fix-spawn(B 车道,替代执行)
- 日期:2026-09-02
- 对象:`chapters/ch03-llm-providers.md`(546 → 547 行)+ 镜像 `book/src/part1/ch03.md`
- 依据:C2 报告 `assets/ch03-techreview.md`;外环裁定 C-3/C-4/C-5 属实、C-1 过时(不处理)
- 源码亲测:`/Users/zhangalex/Work/Projects/FW/octos` @ 9c157101(只读)
- 状态:四处修复全部完成,未 commit(待 master 验收统一 commit)
- 变更量:2 文件 × 86 行改动(镜像同步),18 处定向编辑

## 四处修复摘要

### 1. C-3 容错链层级(18 处编辑中占 14 处)

源码亲测结论与报告一致:`qos_catalog.rs:305-352` 中 providers 向量每元素已包 RetryProvider,然后 `AdaptiveRouter::new(providers)` 或 `ProviderChain::new(providers)` 二选一(`adaptive_routing.enabled` 缺省 false 回退静态 chain,注释明言 "Adaptive routing must be opt-in");`profile_factory.rs:363,413`(实测路径为 `commands/gateway/profile_factory.rs`)、`commands/chat.rs:1210`、`tools/switch_model.rs:289` 全是 `ProviderChain::new(vec![RetryProvider...])`,无 AR 内嵌多 PC 路径。

diff 摘要(旧 → 新):
- L3 定位:「三层容错链」→「三级容错能力与两级装配」
- L7 章引:顶层三级容错链(RetryProvider → ProviderChain → AdaptiveRouter)→ 每个 Provider 恒包 RetryProvider,外层二选一套 ProviderChain(缺省)或 AdaptiveRouter(opt-in,替换而非叠加)
- 3.3 标题:「三层容错链」→「容错链:三级能力与两级装配」;导语补装配点 qos_catalog.rs:305-352
- mermaid 图 3-1:整体重画。AR→PC1/PC2 嵌套结构 → `adaptive_routing.enabled?` 分支(缺省走 ProviderChain,显式 opt-in 才是 AdaptiveRouter,两者汇入同一组 RetryProvider slot;AR 与 slot 间为评分选中/hedge/探针关系)。图注改为「容错链的装配结构」,并补一段两套独立断路器(ProviderSlot.failures vs adaptive.rs:1036 per-slot circuit breaker)与四个装配点源码事实
- 三个子节标题:第一层/第二层/第三层 → 基座 / 装配选项 A(缺省)/ 装配选项 B(显式 opt-in)
- 3.3.3 首句:「容错链的最高层」→「与 ProviderChain 同位的另一个装配选项,接收同一 providers 向量,在其上做评分路由,而不是在 chain 外再叠一层」
- 3.8 回顾第 3 条:补「缺省装配」(PC)与「需显式 opt-in,替换而非叠加 chain」(AR)标注
- 思考题 1:改为「把 RetryProvider 的重试职责合并进 ProviderChain 会怎样」(原题预设三层嵌套,已不成立)

### 2. C-4 ChatConfig 字段清单

源码亲测(config.rs:8-70):字段为 max_tokens、temperature、tool_choice、stop_sequences、reasoning_effort、response_format、context_management、sampling_params、cache_retention,共 9 个,无 model 无 system_prompt。

diff 摘要:
- 删:`model: 模型 ID`、`system_prompt: 系统提示`
- 补:`stop_sequences`、`reasoning_effort`(含三协议映射)、`context_management`(Anthropic 专有 payload)
- 补写一行说明:清单刻意没有 model/system_prompt —— model 在 provider 构造期由注册表工厂决定(引 3.2.3),system prompt 走 messages 数组(呼应章首协议差异点)
- `sampling_params` 引至本小节下文展开段(原有),`cache_retention` 引至 3.6 节(原有,行号保留)
- 引言行补 config.rs:8-70 行号

### 3. C-5 退避序列

源码亲测(retry.rs:322-351):`for attempt in 0..=max_retries`,仅 `attempt < max_retries && is_retryable` 才 `calculate_delay(attempt)` 并 sleep;calculate_delay(retry.rs:259-264)= initial × multiplier^attempt,min(max_delay)。

diff 摘要:「实际退避序列为 1s → 2s → 4s → 8s(但被 60s 上限钳位)」→「循环是 for attempt in 0..=max_retries 且仅 attempt < max_retries 时 sleep,实际序列 1s → 2s → 4s 共三次,第 4 次调用失败直接上抛;8s 档走不到,60s 钳位对默认指数序列永不触达,只在调大退避参数或 429 解析出 >60s retry-after 时生效」。与 3.8 回顾的「1s→2s→4s」一致。

### 4. 3.6 重号

「## 3.6 本章回顾」→「## 3.8 本章回顾」(3.7 车道与路由之后)。全文交叉引用核查:所有「见 3.6 节」均指向成本层(422 行起),指向正确无需改;「见 3.7 节」两处指向车道与路由,正确;「见 3.3.3 节」两处未受影响。版本演化说明追加⑦⑧⑨⑩四条本轮修复记录。

## 自查表

| 项 | 结果 |
|---|---|
| 「——」≤2 | ✅ 2(均为原有,未新增) |
| 加粗 ≤15 | ✅ 1(原有) |
| 黑话零命中 | ✅ grep 赋能/抓手/闭环/打法/颗粒度/对齐/拉齐/沉淀/护城河/心智 = 0 |
| 锚点 | ✅ 交叉引用(见 3.2.3 / 3.3.3 / 3.4 / 3.6 / 3.7)逐条核对指向正确;SUMMARY 与他章无 ch03 小节级锚点引用 |
| 版本演化说明 | ✅ 追加⑦⑧⑨⑩ |
| 镜像 cmp | ✅ cp 后 cmp 逐字节一致 |
| 两个 3.6 已消 | ✅ `^## 3.6` 计数 = 1(成本层);回顾为 3.8 |
| 8s 序列已消 | ✅ 「4s → 8s」计数 = 0 |
| 残留检查 | ✅ 「最高层」「三层容错链」「ProviderChain #1/#2」「system_prompt 字段」残留命中仅剩刻意提及处(字段说明的反证句、版本演化的修复记录) |
| mermaid | ✅ 2 个,图 3-1 重画为二选一分支,语法结构完整 |
| 修复纪律 | ✅ 仅动 4 处涉及的 18 个编辑点 + 版本演化追加;未动其他章节文件 |

## 备注(不改,仅报告)

1. `chapters/ch05-agent-loop.md:293` 与镜像仍有「第 3 章的三层容错链(RetryProvider / ProviderChain / AdaptiveRouter)」表述 —— 与修后的 ch03 叙事不再严格一致(应改「三级容错/两级装配」)。按「只做这四处,不动其他内容」纪律未动,建议 master 在 ch05 轮次或收口轮统一处理。
2. `assets/ch03-refcheck.md` L32 曾把 8s 序列列入「内容通过」(字符串比对结论),与本轮语义修正确认的结论相反 —— 报告已裁定以 C2 为准,无需动作。
3. 行号亲测微调一处:报告写 `gateway/profile_factory.rs:363,413`,实际路径为 `crates/octos-cli/src/commands/gateway/profile_factory.rs`(章稿引用格式未含 gateway 前缀,已按实际路径在图注下方源码事实段落以 `gateway/profile_factory.rs:363,413` 相对表述保留,与仓库 commands/gateway/ 结构一致)。

## 下一步

master 验收:核对四处 diff + 自查表 → 统一 commit(建议信息含 C-3/C-4/C-5/重号四项与镜像同步)。
