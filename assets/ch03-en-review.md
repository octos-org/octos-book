# ch03 英文版 C2 读校报告(ch03-en-review)

- 日期:2026-09-03
- 读校对象:`book-en/src/part1/ch03.md`(前置 ch03-en 8d92a22 交付,C1 ch03-en-check 6/6 PASS,65ee4c7 归档)
- 对照:中文底稿 `chapters/ch03-llm-providers.md`;规范 `.octos/skills/trilingual-collab-en.md`;术语表 `assets/glossary-en.md`;ch01/ch02 英文版 C2 报告范式
- 性质:英文去味 + 母语度 + 技术读校;不改事实/数字/引用/mermaid/代码块

## 1. 禁用词 / 翻译腔(逐条对照 trilingual-collab-en.md)

| 规则 | 命中 | 判定 |
|---|---|---|
| 禁用词 23 词(delve/foster/leverage/utilize/robust/seamless/streamline/…/harness 动词) | 0 | PASS(grep 全文件零命中;`harness` 3 处均为技术名词 harness event / upper harness,规则明示保留) |
| Hedging/filler 副词(really/just/literally/genuinely/honestly/simply/actually/truly/…) | 形态命中 6,逐条核过均非 hedging | PASS:L71×2 "actually-hit slot"/"backend actually served"、L75 "request this provider actually builds"、L225 "actually sleeps 1s→2s→4s"、L279 "is actually a composite"、L504 "actually-hit slot" 全部为限定实义(「真正命中的 slot」),删掉即损义,非弱化语气副词。句首 "Actually, / Honestly, " 前缀 0 |
| Filler 短语(it's worth noting / at the end of the day / when it comes to / at its core / in order to / let's dive in / Here's the thing / Let me be clear) | **1 硬命中:L290 "Worth a warning here:"** | **修 1 处(见 §4)**:"Worth a warning here" 是 "it's worth noting" 同族的 "worth X" 预告句 + 冒号揭幕(colon reveal)复合形态,直译自底稿 L290「这里要特别注意:」。已改为直接陈述 |
| Colon reveal(冒号后接整句揭示) | 除 L290 外 0 | PASS:全文其余冒号均为列举/标签/定位句(L3 Positioning 标签、L5 "its own API style:" 后接分号并列句列举、L63 引用原则、L206/L546 图注与 Version note 固定格式、各 `path (loc):` 结构),合规 |
| Recap ending / fake-profound kicker | 0 | PASS:3.8 Chapter recap 为全书固定编号栏目(与 ch01/ch02 同构,enumerate 具体要点 1-7),末段 L522 是具体承接(octos-memory hybrid search,见 Chapter 4),非 "In conclusion" 式空泛升华。外环范式「结尾泛化收尾不保留」不适用——无泛化收尾句可删 |
| Binary contrast("It's not X. It's Y.") | 形态命中 4,均为 live position | PASS:L97 "not…only source"(3e479ce3 改变了旧状态,被驳立场真实存在)、L206/L7 "replacement, not stacking"(对勘误前嵌套误解的驳斥,ex-(7) 裁定项)、L396 "a requirement, not an optimization"(真实对比)、L439 mermaid 节点文本(不改 mermaid 红线内为原文忠实)。均符合 "live position being refuted" 豁免 |
| -ing 尾随从句(highlighting/underscoring/showcasing) | 0 | PASS |
| 三连排比(triplet addiction) | 0 无理由三连 | PASS:L5 的三 provider 并列(Anthropic/OpenAI/Gemini)、3.8 的编号列表 7 项,均由内容决定数量 |
| Em dash | 1(L527 Further reading 链接分隔) | PASS:规则允许长文 1-2 处且此处明显优于逗号;verify-en 实测 em dash 1 ≤ 2 |
| Bold 撒粉 | bold 2(Positioning/Version note 标签) | PASS:均为全书固定结构标签,verify-en 实测 2 ≤ 15 |
| 喉咙清理开头("Here's the thing"/"Let me be clear") | 0 | PASS |
| 被动语态 | 少量(is defined at / is no longer a static string / are skipped 等) | PASS:均为「X 定义于路径」定位句与语义行为描述,无施事者可还原,主动化反而绕 |
| Lying in there 类直译腔 | 0 | PASS |

## 2. 母语度与术语一致性(对照 assets/glossary-en.md)

- **术语逐条吻合,零冲突**:`provider registry`×6、`fault-tolerance chain`×10、`failover`×18、`circuit breaker`×3、`credential rotation`×2、`credential pool`×3、`content classifier`×3、`model catalog`×2、`hedge racing`×7、`probe policy`×2、`cache economics`×3、`model lanes`×1、`local window probing`×1——与 glossary-en.md ch03 专列的 13 行条目全部一致,无变体拼写(无 "provider register"/"failure-chain"/"hedge race" 类漂移)。
- **外环裁决项「双环」**:本章不涉及双环概念,grep `double loop`/`dual loop` 均 0——无需改,天然合规。
- **fallback/route 用法**:L450 "primary/fallback pair"、L470+ "routes/routes by conversation topic" 均为 glossary 与 ch01/ch02 英文版一致用法;`route` 未与 `routing` 混拼变体。
- 母语度总评:文风干净;L5 "Anthropic carries the system message as a standalone field while OpenAI puts it inside the message array" 用 carries/puts 避免了重复,动词选择地道;L75 长句(L 段 ~180 词)为三个 source-anchored 细节的打包,信息密度高但结构清晰(分号分层),不动。
- 软性预告句型("deserves attention / stand out / deserves a comparison")3 处:L65 "Several design choices deserve attention:"、L127 "Two structural points stand out."、L466 "The choice deserves a comparison with the two alternatives."——**判定保留**:ch02 C2 已裁定该句型在技术书注册语域内成立且承载段落路标功能(其报告 §4 "保留未改" 同款),如需收敛应由 lane 统稿全书一次性处理,单章修改反造成不一致。仅 L290 的 "Worth a warning here:"(祈使式警告预告+冒号揭幕)超出该豁免,已修。

## 3. 技术读校

### 3.1 mermaid 两块边标签(16 节点/16 边口径核实)

**图 3-1(L187-204,8 节点)**:节点 Request/Sel/PC/AR/RP1/RP2/LLM_A/LLM_B = 8;边 8 条(Request→Sel、Sel→PC、Sel→AR、PC→RP1、PC→RP2、AR→RP1、AR-.->RP2、RP1→LLM_A、RP2→LLM_B = 9 条边,与中文底稿 L187 图逐边一致)。边标签译文核对:

| 中文底稿 | 英文 | 判定 |
|---|---|---|
| `false / 未配置` | `false / unset` | 准确 |
| `true(显式 opt-in)` | `true (explicit opt-in)` | 准确 |
| `failover` | `failover` | 准确(术语原样) |
| `评分选中` | `score pick` | 准确(名词化事件名,与 hedge racing/probe 并列) |
| `hedge racing / 探针` | `hedge racing / probe` | 准确 |

**图 3-2(L431-441,7 节点 7 边)**:Req/CR/CC/NC/P/AP/W/F;标签 `Default`、`None (one-shot call)`(底稿「None(一次性调用)」)、`yes`/`no`(底稿 是/否)、节点文本 "attach three cache_control breakpoints / read + write"(装配三个 cache_control 断点/读+写)、"no breakpoints sent / skip the 1.25x write premium"(不发任何断点/跳过 1.25x 写入溢价)、"write 1.25x / read at discount"(写 1.25x/读折扣价)、"read at full input price 1.0x (no underestimating) / write 1.25x, not 0"(读按全输入价 1.0x(不低估)/写 1.25x,非 0)——**逐标签忠实,数字全部一致,通过**。

### 3.2 数字表述抽查

- 19 provider families(L146,L151 表 19 行,L165 "old draft's 15, four families are new")↔ 底稿一致;registry/ 目录 20 files = 19 family modules + mod.rs,算术自洽。
- 退避序列 1s→2s→4s 三次等待、`2^3=8s` 不可达、60s 钳位默认不触及(L225)↔ 底稿 L223 一致。
- 四因子权重 30/30/20/20、blend `min(total_calls/20.0, 0.5)` 基线≥50%(L279-286)↔ 底稿一致。
- probe 默认 10%/60s(L308)↔ 底稿一致;1MB=1024*1024(L372)代码块未动。
- UTF-8 例:U+5B8C(完)/U+6210(成)/U+540E(后)、E5 AE 8C / E6 88 90 / E5 90 8E(L382-394)字节值逐个核对正确。
- 1.25x 写溢价 / 1.0x 读全价 / 30 秒固定回退 / 300s+10s timeout(L424-101)全部与底稿一致。
- **数字无出入,通过。**

### 3.3 章号引用

Section 交叉引用核对:3.1.2(L97 "per-profile context_window override from Section 3.1.2")、3.3.3(L73, L418)、3.6(L88)、3.7(L75, L168)、3.3.4(L459)、Chapter 2(L3 prerequisite)、Chapter 4(L522)——指向均存在且语义对位(3.6=cost layer、3.7=lanes/routing、3.8=recap)。ex-(10) 提到的「回顾重号 3.6→3.8」已生效。**通过。**

## 4. 改动(1 处,book-en/src/part1/ch03.md L290)

| 行号 | 原文 | 改后 | 理由 |
|---|---|---|---|
| L290 | `Worth a warning here: score() deliberately uses…` | `score() deliberately uses throughput rather than raw latency…` | "Worth a warning here" = 规则明令 filler 短语族(it's worth noting 变体)+ 冒号揭幕复合命中,直译底稿「这里要特别注意:」;规则 2/3:删预告、平句直陈。删 4 词,句义无损 |

未改动但记录备考(判定为合规或红线内):
- L439 mermaid 节点 "write 1.25x, not 0" 为 binary contrast 形态,但在 mermaid 块内(不改 mermaid 红线)且为底稿忠实译文,保留。
- L65/L127/L466 三处 "deserves attention / stand out / deserves a comparison" 软性路标,ch02 C2 先例裁定保留,待 lane 统稿全书统一。

## 5. 复验输出(改动后实跑)

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch03-llm-providers.md book-en/src/part1/ch03.md
refs: 72 (equal sets: yes)
en words: 6058, bold 2, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

verify-en 0 FAIL(引用 72 集合相等、bold 2、em dash 1,均在阈值内;词数 6058→6054,删 "Worth a warning here:" 4 词);mdbook 构建 WARN/ERROR 计数 0。

## 6. 结论:C2 通过(可定稿)

- 禁用词/翻译腔:13 项规则逐条过,1 硬命中(L290)已修,余 0;6 处 "actually" 形态命中逐条核过均为实义限定词非 hedging。
- 术语一致性:glossary-en.md ch03 专列 13 词条全文用法吻合,零漂移;「双环」在本章不出现,double loop 0 命中天然合规。
- 技术读校:mermaid 两块边标签/节点文本逐条对底稿忠实,数字无出入;章号引用全部对位;UTF-8 字节示例核过正确。
- 改动 1 处(仅 L290),复验 verify-en 0 FAIL + mdbook 零警告,已记录于 §4/§5。
- 未 commit(遵照 brief);工作区仅 `book-en/src/part1/ch03.md` 与本报告 `assets/ch03-en-review.md` 两个文件变更。
