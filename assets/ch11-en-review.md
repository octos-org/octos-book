# ch11 英文版 C2 读校报告(ch11-en-review)

- 基线:`book-en/src/part3/ch11.md`(487 行,前置 `d1202c8` 交付态);对照 `chapters/ch11-message-bus.md`、`.octos/skills/trilingual-collab-en.md`、`assets/glossary-en.md`、C1 报告 `assets/ch11-en-check.md`(6/6 PASS,`42df99c` 归档)
- 工作目录:wt(ch11-en-review),branch main,未 commit
- 结论:**需修 → 已修 5 处后通过(PASS)**。外环五范式:dual loop 0 命中、顿号/全角 0 命中、colon reveal 1 命中已修、hedging 0 命中、recap ending 0 命中;禁用词/翻译腔:5 必改已落地 + 7 条判保留记录在案;技术读校(mermaid 4·4/10·10/7·6、数字、章号)全部对齐;修后复验 verify-en 0 FAIL + mdbook 零警告。

---

## 1. 外环已裁决范式逐条核查

| 待修范式 | 检查方法 | 结果 |
|---|---|---|
| 「双环」dual loop | `grep -niE 'dual[ -]?loop\|double loop\|双环\|two loops\|inner loop'` | 0 命中 ✅(本章中英文版均不涉及该概念;Part IV 才引入) |
| 顿号(、)残留 | `grep -n '、'`;perl 扫全 CJK + 全角区间(U+3000–303F / FF00–FFEF / 4E00–9FFF) | 0 命中 ✅(全文件零中文字符/零全角标点) |
| colon reveal | 人工逐条审读全部 22 处行尾冒号 | **1 命中已修(L61)**;其余 21 处均为列表/表格/代码块/枚举引入的合法冒号(L11/13/45/55/79/104/126/163/186/191/200/210/230/243/264/280/323/343/360/410/416/447),与中文版对应位置一致 |
| hedging 前缀 | `it is worth noting / it should be noted / note that / of course / after all / arguably / somewhat / needless to say` 等 9+ 模式 | 0 命中 ✅(L475 "may be incomplete" 为事实性可能性陈述,非 hedging) |
| recap ending | 各节结尾 + 11.7 Chapter recap 逐条审读 | 0 命中 ✅(11.7 为全书固定编号栏目,enumerate 具体要点;末章 Version note 为事实句;无 "In conclusion" 式复读/升华) |

## 2. 禁用词/翻译腔逐条记录

系统扫描 30+ 模式(in other words / obviously / clearly / firstly / so-called / moreover / meanwhile / not only…but also / as follows / the fact that / in terms of / carry out / make use of …)、em-dash、`is/are being` 被动堆叠、句首 But/And、very/really/quite。

### 2.1 必改(5 处,已全部落地)

| # | 行号 | 原文 | 改后 | 理由 |
|---|---|---|---|---|
| 1 | L61 | "The bound API's contract: the caller already knows…" | "The bound API's contract **is that** the caller already knows…" | colon reveal:名词标签 + 冒号直接揭出完整从句,直译底稿「bound API 的契约:调用方……」;ch03 C2 裁定同型必改(L290 "Worth a warning here:") |
| 2 | L204 | "the other child task **can be mislabeled orphaned**" | "the other child task **gets mislabeled as orphaned**" | 语法错误:孤立分词补语("mislabeled orphaned" 缺 as);直译底稿「被误标成 orphaned」;被动堆叠 can be + 分词亦属翻译腔 |
| 3 | L216 | "**So** `/new` in the current implementation is closer to…" | "`/new` in the current implementation **is thus** closer to…" | 句首 So 演示腔("So we see that…"),ch06 侧禁用词族;中文底稿无对应连接词 |
| 4 | L280 | "**Now** the full implementation of `split_message()` … and how it balances…" | "**The full implementation of `split_message()` … shows how it balances** safety and readability:" | 句首 Now 演示腔 + 名词短语孤立成句(无谓语),直译底稿「让我们深入……」的 tour-guide 口吻;改为完整陈述句,句尾冒号改为合法代码块引入 |
| 5 | L339 | "the same instance **hangs on it** at `crates/…/discord_channel.rs:32`" | "the same `MessageDedup` instance **also covers it** at `crates/…/discord_channel.rs:32`" | "hangs on it" 含混(挂起?挂着?),直译底稿「也挂了同一个实例」的「挂」;补出实例名 `MessageDedup` 消解歧义指代 |

修后定位 5 处均在 L61/L204/L216/L280/L339,verify-en 数字/引用集合不受影响(零数字、零源码路径改动;L339 仅在行内复述文件路径,原路径引用保留)。

### 2.2 判保留(7 条,记录理由)

| # | 行号 | 原文片段 | 判定 |
|---|---|---|---|
| A | L184 | "First, the first line…" / L186 "Second, …" | 保留。First/Second 为实序枚举(底稿「第一/第二」同结构),非 firstly/secondly 翻译腔 |
| B | L239 | "In other words, octos-bus separates…" | 保留。对应底稿「也就是说」,且 ch13(L306)/ch19(L13)已交付章节同型用法先例,全书一致;非空转复读(后接两条路径的实质归纳) |
| C | L39 | "The key methods: `start()` receives…" | 保留。标签冒号后接分号并列的方法逐条定义(三方法三职责),属 ch06 裁定的 "label + enumerated clauses" 合法用法,非悬念式揭幕;底稿「关键方法:」同型 |
| D | L331 | "A second detail: `find_break_point()` rejects position 0." | 保留。节内路标标签 + 单句事实,承 L330 "The step most easily missed…";ch03 裁定 "deserves attention/stand out" 软性路标句在技术书语域内成立,同族保留 |
| E | L37/L120 等 | "wide trait, heavy defaults" / "hard cut is the last resort" | 保留。结构性对仗短语与术语,与底稿「大 trait + 多默认实现」「硬切是最后手段」一一对应 |
| F | L384/L386/L388/L390 | "Four late additions each deserve a paragraph of positioning." + 各频道段首 | 保留。承前表格的展开路标,母语技术书惯用;底稿「后到的四个频道各值得一段定位」同构 |
| G | L61 | "…so stop guessing from shared state." | 保留。祈使收束对应底稿「别再从共享状态里猜」,与 ch10 L121 "over-blocking beats letting it through" 同判;语气为契约陈述,非口语演示腔 |

其余复核干净:em-dash 0;省略号仅 L196 文件名示例 `0123ABCD....jsonl`(与底稿 L196 逐字节同型)及代码块内 `...`;`is/are being` 0;句首 But/And 0;very/really/quite 0;smart quotes 0。

## 3. 母语度与术语一致(glossary-en ch11 专列 10 条)

| glossary 词条 | 频次 | 一致性 |
|---|---|---|
| message bus | 1(Positioning) | ✅ 无 variant |
| message coalescing / splitting | coalesc- 词族 17 | ✅ 无 "merging/concatenating" 漂移;splitting 固定指 5 级切割 |
| hard cut | 6 | ✅ 无 "hard-cut/hard slice" 变体(仅 hard-cut branch 形容词用法 2 处,合规) |
| thread-bound streaming | 标题 L53 + 正文 | ✅ 与 bound API / bound variants 家族(`edit_message_bound` 等)用法统一 |
| sticky map | 3 | ✅ 无 "sticky-map/stick map" 漂移 |
| durable commit observer | 3 | ✅ 均小写通名,`MessageCommitObserver` 为类型名单独出现 |
| child-session contract | 2 + `ChildSessionContract` 类型名 | ✅ 通名连字符、类型名单驼峰,零漂移 |
| long polling | 4 | ✅ 动词位 "long-polls"(L388)为正确屈折,非术语漂移 |
| percent-encoding | 1(L443 编号节)+ L196 描述 | ✅ 对应 `encode_path_component()` |
| write-then-rename | 3 | ✅ 无 "write then rename/rename-after-write" 变体 |

其它:channel(频道)通篇统一,飞书→Feishu、企业微信→WeCom、QQ Bot/WeChat/WeCom Bot 与底稿及 Cargo feature 名一致;`fail closed`(L228 标题/L237 形容词位 fail-closed)与 glossary fail-closed 条目及 ch07 用法一致;17 频道名、`MAX_CHUNKS`、`SessionKey`、`SessionHandle`、`SessionActor`、`per-key Tokio mutex` 等代码名引用零漂移。

## 4. 技术读校

- **mermaid 3 块逐块比对**:B1 thread-bound streaming(sequenceDiagram)participants 4 / 消息边 `->>` 4 ✅;B2 5 级切割(flowchart TD)节点 10 / 边 `-->` 10 ✅,标签本地化(「长消息」→Long message、「找到」→found、「未找到」→not found、「硬切 UTF-8 安全边界」→Hard cut UTF-8 safe boundary)与底稿结构 diff 为空;B3 durable commit(flowchart TD)节点 7 / 边 6(含 fail/ok 分支)✅。三块与 C1 §5 记录一致,本轮未改 mermaid。
- **图注编号**:L120 "Figure 10-1" 与中文底稿 L120 「图 10-1」逐字对应——该编号是中文源的章号错标(本章为第 11 章,应为图 11-1),双语同病。属事实/引用层缺陷,超出本车道「不改事实」授权,**移交外环裁定修复车道**(中文源 + 英文镜像需同步改,类似 ch01 `*_channel.rs` glob 残骸先例)。
- **数字**:40,937 / 18,207 / 17 频道文件 / 26 方法 / 3 基础方法 / 4,000 / 1,900 / 3,900 / 1,600 / MAX_CHUNKS=50 / 1,000 容量 60s TTL / 10MB / 3,417 行 / 2400-3100 / 2441-2460 / 9c157101 等抽核与底稿一致;C1 §2 已证全集 155↔155 零差。
- **章号**:章题 Chapter 11 ✅;交叉引用 Chapter 5(Prerequisite)、Chapter 2(truncate_utf8)、Chapters 13 and 14(transport 边界)与底稿第 5/2/13、14 章一一对应 ✅;标题序 26↔26 逐一同位(C1 §4.1)。

## 5. 改动与复验

改动文件:仅 `book-en/src/part3/ch11.md`(5 处,见 §2.1)。

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch11-message-bus.md book-en/src/part3/ch11.md
refs: 64 (equal sets: yes)
en words: 4351, bold 7, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
(INFO Book building has started / Running the html backend / HTML book written to …/book-en/book)
```

## 总判定

**PASS(5 处必改已落地并复验通过)。** 遗留 1 项移交:Figure 10-1 图注章号错标(双语同病,L120,需中外环车道同步改 Figure 11-1)。
