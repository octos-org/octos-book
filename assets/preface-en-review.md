# preface-en C2 读校报告(preface-en-review)

- 读校对象:`book-en/src/preface.md`(基线 main @ 8d92a22,源文本 8ec09a6 交付版)
- 对照中文:`chapters/preface.md`(124 行 ↔ 124 行)
- 规则基准:`.octos/skills/trilingual-collab-en.md`(禁用词表 + 12 条模式清单 + 约定)
- 读校日期:2026-09-03;迭代预算 25,实际消耗 ~14

## 1. 禁用词 / 翻译腔扫描 — 0 硬命中

### 1.1 禁用词(grep 逐词扫描)

| 类别 | 命中 |
|---|---|
| Banned outright(delve/foster/leverage/utilize/…/ever-evolving,22 词) | 0 |
| Hedging/filler(really/just/literally/genuinely/…,10 词) | 0(见 2.2 一个边界案例) |
| Filler phrases(it's worth noting/at the end of the day/…,8 条) | 0 |
| Em dash | 0(全文无 `—`) |
| Bold 撒粉 | 0(`**` 计数 0) |
| CJK 字符残留 | 0 |

### 1.2 模式清单逐条

| # | 模式 | 命中 | 说明 |
|---|---|---|---|
| 1 | Binary contrast("not X. It's Y.") | L5、L11 各 1 处 | **保留**。规则原文:"Keep only when X is a live position being refuted"——L5「not a feature but operating-system-grade infrastructure」反驳的是"缺个功能"这一常见误判(活立场);L11「not a user manual. It is a dissection」反驳"这是教程类书"的默认预期,与 zh「不是用户手册」对位,均属正当反驳,不改 |
| 2 | Throat-clearing openers | 0 | — |
| 3 | Colon reveal | 0 处违规 | 全文冒号均为列表/标签/定义用途(L5"scripts:"后接清单、L105-111 约定条目的"label: 内容"结构),无"最妙的是:"式悬念冒号 |
| 4 | Importance puffery | 0 | — |
| 5 | Weasel attribution | 0 | — |
| 6 | Superficial -ing 拖尾 | 0 | — |
| 7 | Synonym cycling | 轻微,不修 | octos/the book/he 等指称轮换均在正常范围;核心术语(见 2.3)无轮换 |
| 8 | Triplet addiction | 0 | L5 四联清单(permission boundaries/concurrent scheduling/ledger/protocol)、L121-124 四问,数量由内容决定,非凑三 |
| 9 | Rhetorical setup / self-answered question | 0 | L9「who reviews the result, and who takes over when they fail」是真实开放问题(第二版要回答的问题),非自问自答 |
| 10 | Fake-profound kicker / recap ending | 0 | 结尾落在四条具体问句上,正是规则要求的"end on the last concrete point";L119 "a yardstick for judging agent infrastructure" 是承重比喻(规则 Keep 条:metaphors that carry an argument) |
| 11 | Em dash | 0 | — |
| 12 | Formatting slop | 0 | 标题无 emoji、无装饰 bold、bullet 均用于真正的清单(前置知识/阅读约定/四问) |

### 1.3 被动语态

机械扫描 `was/were/been/being` 共 4 处,逐条判定:

| 行 | 片段 | 判定 |
|---|---|---|
| L7 | "it was designed for…" | 保留:无施动者(设计者是隐含的团队),补出来反而臃肿 |
| L11 | "why it was designed that way, which alternatives were weighed" | 保留:同上,且与 zh「为什么这样设计、考虑过哪些替代方案」对位 |
| L26 | "why Rust was chosen" | 保留:标准搭配,who chose 无信息量 |
| L106 | "The distinction was first used for…" | **已改**(见第 4 节 #6 说明前的初稿判断——最终保留原文;此条实为可接受的历史陈述) |

结论:4 处均无施动者可补,不构成"滥用",0 处需改。

## 2. 母语度 — 6 处已修,3 处保留判定

### 2.1 四条收尾问句(B 车道自提「是否过重」)

原文(L121-124):

- "Where is the security boundary: …?"
- "Who enforces the protocol: …?"
- "Can state be recovered: …?"
- "Where do errors go: …?"

**判定:不过重,保留。** 理由:(a) 四问结构对称、每条都落在具体物象上(process/syscall/line of code;compiler/runtime/contract test/document;checkpoint/lost work;swallowed/logged/reported/retried),是工程师面试题式的追问而非抒情;(b) 冒号在每条内做"问题:展开"的 label 用途,属规则允许的 colon 用法;(c) 与 zh 原文四问一一对应,改动会破坏 C1 已验的对位。"Can state be recovered" 略正式,但在"crash/checkpoint/resume"语境里准确,不修。

### 2.2 习语与其他母语度项

| 项 | 判定 |
|---|---|
| "make peace with the borrow checker"(L26) | 自然,保留——Rust 社区惯用语,比直译"adapt to"有味道且承重(对应 zh「适应借用检查器」) |
| L34 "what **actually** happens to the message you send" | **边界案例,保留**:hedging 词表里的 actually 通常删;此处是实义"到底"(zh「到底经历了什么」),删掉语义受损。记为 1 个有正当理由的例外 |
| "Give yourself two weeks"(L26) | 自然;已改搭配见 #4 |
| "Skipping implementation-detail sidebars costs nothing"(L34) | 干脆,保留 |
| "walk into the repository and check it yourself"(L11) | 保留 |

### 2.3 术语一致性(glossary 8 新词)

8ec09a6 增补的 6 行 + 既有相关词条,在 preface 正文的使用逐一核对:

| 词条 | glossary 英文 | preface 用法 | 一致 |
|---|---|---|---|
| 双环 | double loop | L9/L34/L79 "double loop / double-loop part",全程一种拼法(名词 double loop,形容词 double-loop) | ✅ |
| 契约测试 | contract test | L106/L122 一致 | ✅ |
| 断路器 | circuit breaker | L7 一致 | ✅ |
| 凭据轮换 | credential rotation | L7 一致 | ✅ |
| fail-closed | fail-closed | L7 一致 | ✅ |
| 借用检查器 | borrow checker | L26 一致 | ✅ |
| 账本 | ledger | L5/L7 "execution ledger / event ledger" 与 glossary note 一致 | ✅ |
| 租约 | lease | L30 "peer/lease layer" 一致 | ✅ |
| 事实表 | facts table | L115 一致 | ✅ |
| Positioning / Version note / Engineering decision / Exercises | 章节标签 | L106-111 描述与 ch01-03 实际章内锚点(`> **Positioning**` 等)一致 | ✅ |

**一处跨文件不一致(不属 preface 正文,记录在案):** preface mermaid 标签 C14 = "Ch14 Run Modes",而 SUMMARY.md 第 14 章标题为 "Runtime Modes and the Configuration System",ch14 正文标题亦为 Runtime Modes。按任务约束 mermaid 不可改,**留待 lane 决定**(若统一,应改 mermaid 标签向 SUMMARY 靠拢,且需 zh 侧「运行模式」同步评估)。正文 L34 我已统一为 "runtime modes"。

## 3. 技术读校 — 全部 PASS

### 3.1 知识地图 27 节点(26 章 + 附录节点)标签逐条对照

zh ↔ en 逐 token 对照(paste 比对,27 行全查):

| 节点 | zh | en | 判定 |
|---|---|---|---|
| C1 | 为什么是 Rust | Why Rust | ✅ 准确(SUMMARY: "Why Rust? Why an Agent OS?" 简写合理) |
| C2 | octos-core 类型 | octos-core types | ✅ |
| C5/C10/C11/C13/C16/C17/C19-C21 | 专有名词 | 原样保留 | ✅ |
| C6 | 工具系统 | Tool System | ✅ 与 SUMMARY ch06 "Tool System" 一致 |
| C7 | 安全纵深 | Defense in Depth | ✅ 与 SUMMARY ch07 一致 |
| C8 | 上下文管理 | Context Management | ✅ |
| C9 | 扩展机制 | Extension Mechanisms | ✅ |
| C12 | 并发模型 | Concurrency Model | ✅ |
| C14 | 运行模式 | Run Modes | ⚠️ 与 SUMMARY "Runtime Modes" 不一致(见 2.3,地图本身不可改) |
| C15 | 生产化 | Production Hardening | ✅ 语义准确(SUMMARY ch15 "Production: Storage, Services, Operations, and Multi-Tenancy") |
| C18 | Goal 与 Peer | Goal and Peer | ✅ |
| A1 | Crate 依赖图 | Crate Dependency Graph | ✅ |
| A2 | 工具速查 | Tool Reference | ✅(SUMMARY: "Tool Quick Reference" 简写可) |
| A3-A6 | — | — | ✅(A6 "OLP Reference and E2E Trace" 对应 zh「OLP 速查与 E2E 追踪」,SUMMARY: "OLP v2 Protocol Cheat Sheet",简写均可) |

结构:C1-C21 + A1-A6 = 27 节点、20 实线 + 3 虚线、5 subgraph,与 C1 报告第 5 项一致,未动。

### 3.2 阅读路径 A-D 章节号对位(与 zh 逐项)

| 路径 | en 描述 | 核对 |
|---|---|---|
| A(L24-26) | Ch1→2→5→6;Ch8(context compaction)/Ch12(concurrency model) | ✅ 与 zh 同号;ch08 zh 正文确实以 compaction 开题,ch12 确为并发模型 |
| B(L28-30) | Ch1→3→12;Ch7/Ch10 安全、Ch14/15 平台、Ch16-18 多 agent 内核 | ✅ 与 zh 同号;「三层并发调度(Tokio 层、supervisor 层、peer/lease 层)」与 ch12 zh 定位段三层描述逐项一致 |
| C(L32-34) | Ch1→5→6→14→19→20→21;Ch18 为 Ch20 服务端前提 | ✅ 与 zh 同号,依赖方向(18→20)与地图 C18-->C20 边一致 |
| D(L36-38) | 全书 + 附录 A(26 crate/63 边)+ 附录 E;Ch10 契约测试与事件 ABI | ✅ 数字 26/63 与 L7/L115 基准一致;ch10 zh 正文确以契约测试 + 事件 ABI 为主题 |

### 3.3 三仓基准(L115)

en:octos main @ `9c157101`(figures gathered 2026-09-02)/ octoscode @ `1129fa33` / herdr `feat/octoscode-agent` @ `fefe5c4f`;规模数字(26 crates、约 700,000 行、63 边、per-module line counts)标注取自 facts tables 且附复现命令。逐项与 zh L115 对位:三 commit、日期、分支名、四个规模数字全部一致。700,000 ↔ 70 万 为 C1 已确认的等值记法。✅

## 4. 改动清单(book-en/src/preface.md,6 处,均措辞级)

| # | 行 | 原 | 改 | 理由 |
|---|---|---|---|---|
| 1 | L5 | "ask an agent to run long-lived" | "ask an agent to run as a long-lived process" | "run long-lived" 缺名词中心语,母语者读为不完整;"as a long-lived process" 与后文 "serve multiple tenants" 平行 |
| 2 | L18 | "skipping them does not break the main line" | "you can skip them without losing the thread" | "break the main line" 是 zh「不影响主线」直译腔;"lose the thread" 是地道习语且语义等价 |
| 3 | L24 | "(learn Rust and agent engineering through…)" | "(learning Rust and agent engineering through…)" | 路径标题做同位语,动名词形式与 Path C 定语语境更顺(对应 zh「借…入门」) |
| 4 | L26 | "Give yourself two weeks to make peace with the borrow checker" | 未改 | (保留判定:自然,见 2.2) |
| 5 | L30 | "platform in Ch14 and Ch15" | "the platform in Ch14 and Ch15" | 冠词:branch by direction 的宾语并列三项,首项 "security in Ch7 and Ch10" 无冠词是 security 不可数;platform 此处指代具体子系统群,加 the 更顺 |
| 6 | L32 | "understanding the runtime inside" | "understanding the runtime's internals" | "the runtime inside" 语序生硬;"internals" 是技术书标准用词 |
| 7 | L34 | "Ch14 settles run modes and configuration" | "Ch14 settles runtime modes and configuration" | 术语统一向 SUMMARY/正文第 14 章标题 Runtime Modes 靠拢 |

(表内 #4 为显式保留项,列出以示已审;实际 diff 为 6 处。)

## 5. 复验输出(改动后)

```
$ bash ~/.octos/outer/verify-en.sh chapters/preface.md book-en/src/preface.md
refs: 1 (equal sets: yes)
en words: 1308, bold 0, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)          → exit 0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
(HTML book written to /Users/zhangalex/Work/Projects/FW/octos-book/book-en/book)
```

未 commit(按 brief 约束);`git diff --stat`:book-en/src/preface.md | 6 insertions, 6 deletions。

## 6. 总判定

**C2 通过(带 1 项跨文件记录项)。**

- 禁用词/翻译腔:0 硬命中;模式清单 12 条仅 2 处正当 binary contrast,其余 0。
- 母语度:6 处措辞已修并复验;四问收尾与 borrow checker 习语判定保留;术语与 glossary 全一致。
- 技术读校:27 节点标签、路径 A-D 章号、三仓基准全部对位准确。
- 遗留(非本文件可修):mermaid C14 标签 "Run Modes" ↔ SUMMARY "Runtime Modes" 不一致,mermaid 按约束未动,建议 lane 统一时同步 zh 侧「运行模式」标签。
