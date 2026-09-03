# ch10 英文版 C2 读校报告(ch10-en-review)

- 基线:`book-en/src/part2/ch10.md`(302 行,工作区 @ `246fb65`,ch10-en 正文为 fad031c 交付态);前置 C1 ch10-en-check 6/6 PASS(`5bda2ad` 归档)
- 工作目录:wt(ch10-en-review),branch main,未 commit
- 结论:**通过(PASS,正文零改动)**。外环五范式 0 命中;禁用词/翻译腔 0 必改(3 条已判保留并记录理由);技术读校(mermaid 标签/代码块/数字/章号/引用集)全部对齐;verify-en 0 FAIL + mdbook 零警告(基线即终态,无需复跑)。

---

## 1. 外环已裁决范式逐条核查

| 待修范式 | 检查方法 | 结果 |
|---|---|---|
| 「双环」dual loop | `grep -niE 'dual[ -]?loop\|double loop\|双环\|two loops\|inner loop'` | 0 命中 ✅(本章中英文版均不涉及该概念) |
| 顿号(、)残留 | `grep -n '、'`;另用 perl 扫全 CJK + 全角标点区间(U+3000–303F / FF00–FFEF / 4E00–9FFF) | 0 命中 ✅(全文件无任何中文字符/全角标点) |
| colon reveal(冒号揭示式起段) | 人工逐条审读全部 8 处行尾冒号(L7/53/76/96/142/171/237 + L49 `fn validate():`) | 全部为合法的列表/表格/代码块/枚举引入冒号,与中文版对应位置一致,无"悬念式冒号起段后再揭示" ✅ |
| hedging 前缀 | `it is worth noting / it should be noted / note that / of course / after all / arguably / somewhat / to some extent / needless to say` 等 9+ 模式 | 0 命中 ✅(L225 "The #2153 fix is worth recording" 为实义句"值得记录这个修复",非 it-is-worth-noting 空转前缀) |
| recap ending(总结式复读收尾) | 各节结尾 + 10.6 逐条人工审读 | 各节均以事实句收束;L280 "Chapter 10 closes Part Two… Part Three moves from…" 为中文版 L279「第 10 章收束第二部分……第三部分……」的忠实对应(结构性过渡句,非复读式 recap),与 ch05–ch09 的系列收尾一致 ✅ |

## 2. 禁用词/翻译腔逐条记录

系统扫描:`in other words / as mentioned / we can see / it can be seen / obviously / clearly / simply put / in a word / all in all / in conclusion / firstly / secondly / so-called / with the development of / not only…but also / meanwhile / moreover / furthermore / what's more / at the same time` 等 30+ 模式;em-dash(—)与省略号;`is being / are being` 被动堆叠。

**命中 3 条,全部判定为可保留(非必改),理由如下:**

| # | 行号 | 原文片段 | 判定 |
|---|---|---|---|
| A | L39/L270 | "Hooks and harness_errors are **the two wings**" | 保留。中文版「两翼」的结构性隐喻在本章三支柱/两翼框架内前后一致(L39 引入、L213 §10.4 标题 "The Two Wings"、L270 recap),是有意的章节骨架词而非临时翻译腔;全章 3 处用法统一,无漂移。 |
| B | L262 | "This is 10.1.1's 'validation is data, not code' **cashed out** on the user side." | 保留。"cash out"(把原则兑换成实际收益)为母语惯用语,准确对应中文版「在用户侧兑现」;非 so-called 类翻译腔。 |
| C | L258 | "The `file_size_min` of 64 bytes **plugs** the 'a zero-byte diff still counts as delivered' **hole**" | 保留。"plug the hole"(堵住漏洞)为母语动词短语,对应中文版「堵住……的洞」;idiomatic,非必改。 |

**其余典型"高风险位"复核后全部干净:** L121 "over-blocking beats letting it through"(=「宁可误拦不可放行」,忠实且母语);L262 "audio's 4096 exists because the WAV header alone is not small"(省略结构自然);L221 "tax every turn" 仅出现于 L225 一次;`octos's` 所有格、`ValidatorsRunner`/`SafePolicy` 等代码名引用一致;全文 em-dash 0 处、省略号仅 L205 `#[serde(default = "...")]`(代码字符串,与中文版 L203 逐字节相同,非文体省略号)。

## 3. 母语度与术语一致

- **harness 系术语**:harness(39 次)、starter/starters(12)、circuit breaker(3)、envelope(5)、guardrail(6)、workspace policy、event ABI、schema versioning、fail-closed/fail-soft 语义分野——全章用法统一,与 ch05–ch09 已定稿风格一致;glossary-en.md 无 ch10 专属新增条目要求(ch09 为最近一次登记,未见 ch10 待登记清单)。
- **骨架隐喻一致**:three pillars(L39/43/47/142/167/270)+ two wings(L39/213/270)贯穿使用,标题与正文零漂移。
- **母语度整体**:冠词、单复数、时态、连接词抽查未发现错误;句式节奏(短句断言 + 长句展开)与 ch06/ch08/ch09 已定稿风格一致;L96/L121/L161/L205 四处长难句结构清晰、无中式从句堆叠。

## 4. 技术读校

1. **mermaid(3 块)**:① L20 flowchart LR——六模块节点行数(3165/2772/2789/349/2856/745)、四 starter 节点、7 条边及标签(workspace-policy.toml / validators list / ValidatorResult events / Feedback injected into the model / Error events / version guardrail ×2)与中文版逐边对应,标签为中文标签的忠实英译(声明层→declaration layer 等);② L98 sequenceDiagram——5 个 participant、`->>`/`-->>` 消息 8 条、loop/alt/else/end 结构与中文版完全同构,`SIGTERM→SIGKILL` 箭头字符原样保留;③ L195 flowchart TD——decision 分支标签(found ≤ supported / found > supported)、`UnsupportedSchemaVersionError<br/>fail closed`、操作员可见三要素(type/version read/max + upgrade hint)与中文版逐节点对应。三块均为合法 mermaid 语法(mdbook 零警告佐证)。
2. **代码块(5 块:rust×4 + toml×1)**:与中文版提取后 `diff` **逐字节 IDENTICAL** ✅(`ValidationPolicy`/`tier()`/`HarnessEvent`/`check_supported`/starter-coding 的 `workspace-policy.toml`)。
3. **数字对照**:全文件数字多重集比对,唯一差异为中文版 15 个"4" vs 英文版 13 个"4"——溯源确认中文版多出的 2 个"4"是「2026 年 4 月(前)」×2(L203/L205),英文版译为 "April 2026"(L205)/"pre-April-2026"(L207),数字语义完整保留,非缺失。其余全部相等:2,772 / 2,789 / 349 / 3,165 / 745 / 2,856 / 12,676(×2)/ 17 / 18 / 13 / 5 / 64 / 4096 / 5000ms / #2153 / #2129 / #488 / 9c157101(×2)/ M4.3/M4.6/M6.1/M6.3/M6.5/M6.6/M7.6/M8.6/M8.7 等 ✅。
4. **章号/结构**:23 个标题(1+6+13+3)与中文版同位严格对齐(paste 比对行号仅 10.3.1 起整体 +2,源于英文版 L167/169 两行的段落拆分,非标题错位);Chapter 引用 5/6/7(前置)、8/9(交叉)、13/16/17(前向)与中文版一致;Part Two→Part Three 过渡(L280=中文 L279)正确;"Further reading"/"Exercises" 五条/三条与中文版逐条对应 ✅。
5. **引用集**:`verify-en.sh` refs 52=52,equal sets yes ✅。

## 5. 备注(非必改,0 处修改正文)

1. **L161 句长**:该段(契约测试 + 分类学)单段近 400 词,为全章最长段;但结构为「两句论点 + 用例清单」且分号切分清晰,与中文版 L159 段落密度镜像,忠实优先,不改。
2. **bullet 句点风格**:本章 Further reading 列表无句尾句号,与 ch09-en-review §5-3 记录的全书层面议题一致,超出本章 C2 范围,维持原状。
3. **L1 标题**:中文版书名号结构「第 10 章:Harness:把……」译为 `Chapter 10: Harness: Turning "the model says it's done" into a Verifiable Contract`,双冒号层级在英文技术书名中可接受(主标题:副标题),且 verify-en 0 FAIL,不改。

## 6. 复验输出(基线即终态,正文零改动)

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch10-harness.md book-en/src/part2/ch10.md
refs: 52 (equal sets: yes)
en words: 4392, bold 13, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)

$ cd book-en && mdbook build
 INFO Book building has started
 INFO Running the html backend
 INFO HTML book written to `/Users/zhangalex/Work/Projects/FW/octos-book/book-en/book`
exit=0   ← 零警告
```

## 7. 判定

**通过。** 外环五范式 0 命中;禁用词/翻译腔 0 必改(3 条已判保留并记录理由);mermaid 3 块标签忠实、代码块 5 块逐字节相同、数字仅"2026 年 4 月→April 2026"的书写形式差异(语义完整)、章号与引用集全部对齐;verify-en 0 FAIL + mdbook 零警告。正文未做任何改动(基线输出即终态输出,无需复跑)。**G2 C2 至此 6/6 补齐。**
