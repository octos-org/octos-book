# ch04 英文版 C2 读校报告(ch04-en-review)

- 日期:2026-09-03
- 读校对象:`book-en/src/part1/ch04.md`(前置 ch04-en bf64490 交付,C1 ch04-en-check 6/6 PASS,25fdf70 归档)
- 对照:中文底稿 `chapters/ch04-memory-search.md`;规范 `.octos/skills/trilingual-collab-en.md`;术语表 `assets/glossary-en.md`;ch01/ch02/ch03 英文版 C2 报告范式
- 性质:英文去味 + 母语度 + 技术读校;不改事实/数字/引用语义/mermaid/代码块
- 工作目录:octos-book worktree(branch main,未 commit);改动由 master 采回

## 1. 禁用词 / 翻译腔(逐条对照 trilingual-collab-en.md)

| 规则 | 命中 | 判定 |
|---|---|---|
| 禁用词 23 词(delve/foster/leverage/utilize/robust/seamless/streamline/…/harness 动词) | 0 | PASS(grep 全文件零命中;无任何禁用词形态) |
| Hedging/filler 副词(really/just/literally/genuinely/honestly/simply/actually/truly/…) | 形态命中 2,逐条核过均非 hedging | PASS:L288 "documents that **actually** reached HNSW" 为限定实义(真正进入 HNSW 的文档,与 index 内文档相对),删掉即损义;L310 "which **just** renders the three sections" 为实义「仅是渲染」(区别于 token-budgeted 版本),同 ch03 先例。句首 "Actually, / Honestly, " 前缀 0 |
| Filler 短语(it's worth noting / at the end of the day / when it comes to / at its core / in order to / worth a warning / let's dive in / Here's the thing / Let me be clear) | 0 | PASS(ch03 的 L290 "Worth a warning" 模式在本章无对应命中) |
| Colon reveal(冒号后接整句揭示) | 0 | PASS:全文冒号均为列举/标签/定位句合规用法——L3 Positioning 标签、L17 "advantages … are clear-cut:" 引出三段列举、L276 "falls back to pure BM25 search:" 引出编号列表、L105 "given a term (say, 'refactoring'), it quickly yields…"、各 `path (loc):` 结构、L206/L241 公式与图注、L425 Version note 固定格式。无 "The best part:" 式揭幕 |
| Recap ending / fake-profound kicker | 0 | PASS:4.7 Chapter recap 为全书固定编号栏目(与 ch01/ch02/ch03 同构,enumerate 具体要点 1-5 + 方法学 + 运维小节),非 "In conclusion" 式空泛升华;L401 末段是具体承接(octos-agent 主循环,对位底稿「下一章将进入 octos-agent」),无 mic-drop。外环范式「结尾泛化收尾不保留」不适用——无泛化收尾句可删 |
| Binary contrast("It's not X. It's Y.") | 0 | PASS(仅 L322 "is not full-text search; it is two-level prompt injection" 为分号连接的实义否定,对位底稿「不是全文搜索,而是两级提示注入」,被驳立场真实存在) |
| -ing 尾随从句(highlighting/underscoring/showcasing) | 0 | PASS |
| 三连排比(triplet addiction) | 0 无理由三连 | PASS:L5 的三问句对位底稿三连问(内容决定数量);L7 "BM25 full-text search, the HNSW vector index, and the engineering of hybrid rank fusion" 为三层架构实指 |
| Em dash | 0 | PASS(verify-en 实测 0 ≤ 2) |
| Bold 撒粉 | bold 4(Positioning/Version note 标签 ×2 组) | PASS:均为全书固定结构标签,verify-en 实测 4 ≤ 15 |
| 喉咙清理开头("Here's the thing"/"Let me be clear") | 0 | PASS |
| 被动语态 | 少量("older data still parses"类主动为主) | PASS:全文以主动句为主;被动仅出现在无施事者可还原的定位/行为描述,主动化反而绕 |
| 「双环」术语(dual loop,非 double loop) | 天然合规 | PASS:「双环」在本章不出现(底稿与英文均无),`double loop` 0 命中;`dual loop` 在 ch01 L324 已确立的用词本章无需出现 |
| **中文标点残留(CJK 标点混入英文正文)** | **2 硬命中:`、` 顿号出现在源码引用内的行号枚举** | **修 2 处(见 §4)**:L245 `hybrid_search.rs:92、94`、L289 `hybrid_search.rs:36-38、318-337`,为底稿中文顿号的直译残留,英文必须用 `, `。修正后引用集合与底稿仍 equal sets(见 §5 复验),引用语义(文件 + 行号)未变 |

## 2. 母语度与术语一致性(对照 assets/glossary-en.md)

- **glossary ch04 专列 14 词条全文用法吻合,零漂移**:`hybrid search`×9、`inverted index`×7、`term frequency`/`document frequency`(L123 表格行,与 glossary "tf / df in BM25" 一致)、`forward-compatible`(L65,与 glossary "forward compatibility" 同根)、`tombstone`×2(L81/L425)、`dense accumulator`×2(L163/L169)、`sparse branch` 表述(L170,与 dense 对举,无 accumulator 变体漂移)、`three-tier fallback`×3、`VectorCoverage` 降级可见(L284 标题 "Making fallback visible" + L288/L425 "fallback visibility",同族一致)、`Episode`(37 处,首字母大写恒定,与 glossary "octos-memory unit of experience" 定位一致)、`long-term memory`×3、`daily notes`×3、`entity bank`×3(连字符形式 `entity-bank layer` L322 为形容词用法,合规)+ `Memory Bank`(专有层名,L320/322/324/327/331,与 `entity bank` 泛称分工清晰,对位底稿「Memory Bank/entity bank」同样双轨)、`write gate`/`render gate`(L333/L334)、`graceful degradation`×1(L364)。
- **无变体拼写**:无 "hybrid retrieval"/"hybrid rank" 名词混用之外的多余变体(`hybrid rank fusion` 仅出现在 L7/L226/L389,严格对位底稿「混合排名融合」栏目名,与 `hybrid search`(混合搜索)两词分工与底稿一致);无 "memory bank" 小写漂移。
- **母语度抽查**:L270 "Exact keyword matches never drown under semantic search"、L272 "BM25-only fallback does not artificially depress every score"、L336 "the cost of a false positive … is far below the cost of silently accepting one injection" 均为紧凑主动句,直接陈述;L63 "in fact only writes `Success` episodes" 的 "in fact" 为实义限定(实际只会),非 hedging;全文章节推进语(L7 "starts at the storage layer and works up through…")具体、无空转。
- **备考(不修,记录给 lane 统稿)**:L63 "resemble the terminal states of a Task in meaning" 的 "in meaning" 后置略带翻译腔,更地道为 "are semantically close to",但语义清晰、非禁用模式,按最小改动原则保留。

## 3. 技术读校

### 3.1 mermaid(1 块,5 节点,5 边)

L232-239 唯一 mermaid 块,对位底稿 L232-239:

| 元素 | 底稿(ZH) | EN | 判定 |
|---|---|---|---|
| 节点 Query | 查询文本 + 查询向量 | Query text + query vector | ✓ 忠实 |
| 节点 BM25 | BM25 搜索 / 倒排索引 / 关键词匹配 | BM25 search / inverted index / keyword match | ✓ 忠实 |
| 节点 HNSW | HNSW 搜索 / 向量索引 / 语义匹配 | HNSW search / vector index / semantic match | ✓ 忠实 |
| 节点 Fusion | 加权融合 / 0.3 × BM25 + 0.7 × 向量 | Weighted fusion / 0.3 × BM25 + 0.7 × vector | ✓ 忠实(权重数字同序) |
| 节点 TopK | Top-K 结果 / 按分数降序 | Top-K results / sorted by score, descending | ✓ 忠实 |
| 边 | Query→BM25、Query→HNSW、BM25→Fusion、HNSW→Fusion、Fusion→TopK 共 5 条 | 同构 5 条 | ✓ 逐边对位 |

图注 L241 "Figure 4-1: the hybrid search pipeline…" 对位「图 4-1:混合搜索流程」✓。

### 3.2 数字

双向数字集合 diff 实测:ZH 176 个唯一数字,EN 177 个;missing 0 / extra 1(`100,000`,L421,对位底稿同句「10 万个 episode」的单位制等值改写,C1 备注A已裁定语义等价 PASS)。修正顿号两处不影响数字集合。关键数字抽查:6,428(L3/L7/L381/L395/L425 五处一致)、K1=1.2 / B=0.75、0.7/0.3 权重、`1e-10`、`DENSE_ACCUM_DIVISOR = 8`、`n_docs / 8`、10,000 容量、1536/768(L286)、2,417/1,940/1,527/325/195/24 六文件行数(L395,合计 6,428 ✓)、100 characters(L324)、7 天窗口——均与底稿逐一对位。

### 3.3 章号引用

Chapter 2(L3 prerequisite,对位「前置依赖:第 2 章」)✓;Section 引用:4.3.4(L119 "the hot-path discussion of 4.3.4" 与 L163 标题实存)、4.7.2(L292 "see 4.7.2" 与 L397 标题实存)、§4.3.4/§4.5.5/§4.7.2/§4.6.4(L425 Version note 内,四节均实存)——指向全部存在且语义对位。代码块/引用核对:verify-en refs 53 equal sets(见 §5)。

### 3.4 其他技术忠实性抽查

- L141 IDF 公式代码块、L126 BM25 公式、L213-219 `l2_normalize` 代码块:与底稿逐字一致(仅注释按既定规则译英),无改写。
- L153-159 epsilon 守卫叙述对位底稿「1e-10 阈值检查…提前返回空结果」✓;L161 NaN 传播段对位「NaN 的传播性极强」✓。
- L165 `cc6744ba (#1855)`、L286 `4ccdbe7e (#1851, following #1816)`、L292/L399 `9ad56caa (#1853)`:commit 短哈希与 issue 号均与底稿一致。

## 4. 改动(2 处,book-en/src/part1/ch04.md)

| 行号 | 原文 | 改后 | 理由 |
|---|---|---|---|
| L245 | `` Default weights (`crates/octos-memory/src/hybrid_search.rs:92、94`): `` | `` Default weights (`crates/octos-memory/src/hybrid_search.rs:92, 94`): `` | 中文顿号 `、` 残留在英文正文(底稿 L245 同位为 `92、94`),英文行号枚举必须用 `, `。引用语义不变(同文件 92 与 94 行),修正后引用集合与底稿仍 equal sets |
| L289 | `` - Count instead of spam (`crates/octos-memory/src/hybrid_search.rs:36-38、318-337`): … `` | `` - Count instead of spam (`crates/octos-memory/src/hybrid_search.rs:36-38, 318-337`): … `` | 同上,底稿 L289 同位顿号残留;引用语义不变 |

未改动但记录备考(判定为合规):
- L288 "actually reached HNSW" / L310 "just renders" / L63 "in fact only writes":实义限定词,非 hedging(§1 已述)。
- L288 "- **name**: abstract" 为被注入行的字面格式描述(对位底稿同格式),冒号为标签用法。
- L322 "is not full-text search; it is two-level prompt injection":对位底稿的实义否定,保留。

## 5. 复验输出(改动后实跑)

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch04-memory-search.md book-en/src/part1/ch04.md
refs: 53 (equal sets: yes)
en words: 4245, bold 4, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

verify-en:0 FAIL / 0 WARN,引用 53 集合相等(顿号改逗号未破坏 ref 抽取——两侧均解析为同一条 `hybrid_search.rs:92` 等),bold 4、em dash 0 在阈值内;词数 4243→4245(顿号拆词计数 +2,无实词增删)。mdbook build 成功,WARN/ERROR 计数 0。

```
$ git diff --stat
 book-en/src/part1/ch04.md | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
```

## 6. 结论:C2 通过(可定稿)

- 禁用词/翻译腔:14 项规则逐条过,唯一硬命中为 2 处中文顿号残留(L245/L289),已修,余 0;2 处 "actually/just" 形态命中逐条核过均为实义限定。
- 术语一致性:glossary-en.md ch04 专列 14 词条全文用法吻合,零漂移;`hybrid search` 与 `hybrid rank fusion`、`entity bank` 与 `Memory Bank` 的双轨分工与底稿严格对位;「双环」在本章不出现,天然合规。
- 技术读校:mermaid 1 块 5 节点 5 边标签译文逐条忠实;数字双向 diff 仅 C1 已裁定的 `100,000` 等值项;章号/节号引用全部对位;三个 commit 短哈希与 issue 号无误。
- 改动 2 处(仅 L245/L289 顿号→逗号,均在 `book-en/src/part1/ch04.md`),复验 verify-en 0 FAIL + mdbook 零警告,已记录于 §4/§5。
- 未 commit(遵照 brief);工作区仅 `book-en/src/part1/ch04.md` 与本报告 `assets/ch04-en-review.md` 两个文件变更。
- G1 的 C2 缺口至此闭合:ch04-en 翻译(C1 6/6 PASS)→ 本报告 C2 通过。
