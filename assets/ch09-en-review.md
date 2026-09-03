# ch09 英文版 C2 读校报告(ch09-en-review)

- 基线:`book-en/src/part2/ch09.md` @ `bb900d8`(351 行);前置 C1 ch09-en-check 6/6 PASS(`f86f8b2`)
- 工作目录:wt(ch09-en-review),branch main,未 commit
- 结论:**通过(PASS,无需修改正文)**。发现 0 个必改项、3 条备注(见 §5),正文零改动。

---

## 1. 外环已裁决范式逐条核查

| 待修范式 | 检查方法 | 结果 |
|---|---|---|
| 「双环」dual loop | `grep -niE 'dual[ -]?loop\|double loop\|双环\|two loops\|inner loop'` | 0 命中 ✅(本章本就不涉及) |
| 顿号(、)残留 | `grep -n '、'`;另用 perl 扫全 CJK + 全角标点区间 | 0 命中 ✅(全文件无任何中文字符/全角标点) |
| colon reveal(冒号揭示式起段) | 人工逐条审读全部 16 处行尾冒号 | 全部为合法列表/表格/代码块引入冒号,无"悬念式冒号起段后再揭示" ✅ |
| hedging 前缀 | `it is worth noting / it should be noted / note that / of course / after all / arguably / somewhat / to some extent` 等 12 模式 | 0 命中 ✅ |
| recap ending(总结式复读收尾) | 各节结尾 + 9.6 逐条人工审读 | 各节均以事实句收束;L330 "This closes Part 2. The next chapter opens Part 3…" 为中文版 L330「Part 2 到此结束…」的忠实对应(结构性过渡句,非复读式 recap),与 ch01–ch04 的 "The next chapter…" 系列收尾一致 ✅ |

## 2. 禁用词/翻译腔逐条记录

系统扫描:`in other words / as mentioned / we can see / it can be seen / obviously / clearly / simply put / in a word / all in all / in conclusion / firstly / secondly / so-called / with the development of / not only…but also` 等 30+ 模式;em-dash 与省略号(…);`is being / are being` 被动堆叠。

**命中 3 条,全部判定为可保留(非必改),理由如下:**

| # | 行号 | 原文 | 判定 |
|---|---|---|---|
| A | L104 | "The model can thus see the tool and, **at the same time**, receive the prompt context…" | 保留。此处 at the same time 是真实的同时性语义(can see X and at the same time receive Y),不是中文「与此同时」的空转连接词。thus 单次出现,密度正常。 |
| B | L138 | "**Put plainly**: 'a plugin without a binary' is a legal form" | 保留。Put plainly 为英文母语惯用插入语,对应中文版「说白了」;非 so-called 类翻译腔。 |
| C | L221 | "**Upstack**, this means concurrent tool calls no longer queue…" | 保留(备注)。Upstack 为业内(term:协议栈上层)可读的紧凑表达,母语技术写作中可见;若 master 希望全书更保守,可改 "For callers above the transport",非必改。 |

**其余典型"高风险位"复核后全部干净:** L19 "stark division"(母语强度词,中文版「悬殊对比」)、L49 "buys one property"(idiomatic,中文版「换来」)、L233 "concedes"(用于引 source comment,准确)、L287 "Their names rhyme; their semantics do not."(母语式对仗,中文版「名字押韵、语义不押韵」)、`octos's` 两处(L7/L213)与 ch07 用法一致,均已保留所有格's。

## 3. 母语度与术语一致(glossary 12 新术语)

`assets/glossary-en.md`(L90–99)登记的 ch09 新术语 11 条 + fail-closed(通用),在正文中全部按定名使用、无变体漂移:

| Glossary 定名 | 正文命中 | 备注 |
|---|---|---|
| skill package | 9 | ✅ |
| runtime manifest | 3 | ✅(§9.2.1 标题与正文一致) |
| verified copy | 5 | ✅ |
| fail-soft | 2 | ✅(L240、L324 recap) |
| fail-safe | 1 | ✅(L291,concurrency 未知值落 Exclusive;与 §9.2.3 的 fail-**closed**(`FailClosed` 枚举名)语义区分正确,两词在各自源码语境下使用无误) |
| layered view | 1 | ✅(L53,与 "layered directories" 家族用词连贯) |
| auto-backgrounding | 2 | ✅(§9.1.5 标题 + L322 recap;L102 的动词形 auto-backgrounded 与名词形并存,自然) |
| connection path | 2 | ✅(§9.3.2) |
| configuration lane | 3 | ✅(§9.5 标题/正文/recap) |
| name protection | 2 | ✅(L247 bullet + L269 表格) |
| transport liveness | 1 | ✅(L248) |

母语度整体:冠词、单复数、时态、连接词抽查未发现错误;句式节奏(短句断言 + 长句展开)与 ch06/ch08 的已定稿风格一致。

## 4. 技术读校

1. **mermaid(1 块 sequenceDiagram)**:participant 2 个(Agent / Plugin as Verified Executable)、`->>` 5 条(exec / stdin / stderr / stdout / process exits),与 brief 契约完全一致;与中文版 diff **逐字节相同**(标签 `exec(".weather_verified", argv[1]="get_weather")`、`{"output":"Beijing: 25°C, sunny","success":true}` 均原样保留)。
2. **代码块对照**:`markdown`(SKILL.md)、`json`(runtime manifest)、`json` ×2(§9.5 两个 config 例)、`xml`(skill index)与中文版逐字节 diff 全部 IDENTICAL ✅。
3. **数字对照**:942 / 14,675(×3)/ 3,219(×2)/ 4,406(×2)/ 51.96% / 100MB / 600(秒,×3 含 JSON 块)/ 30 秒 / 60 秒 / 64KB / 20 built-in names / rmcp 1.8 / 9c157101 / 65486dad / 9b1fc38f / 3934aeb6 / #1886 / #1935——与中文版逐项相等 ✅。
4. **章号**:Prerequisite: Chapter 6(=中文「前置依赖:第 6 章」);§9.4 标题与正文两处 "see Chapter 10 / **Chapter 10**"(=中文「详见第 10 章」);L330 Part 2→Part 3 过渡=中文 L330。全部一致 ✅。
5. **引用集**:`verify-en.sh` refs 76=76,equal sets yes ✅。

## 5. 备注(非必改,0 处修改正文)

1. **L248 bullet 句末无句号**:`A visibility filter should not have the side effect of terminating a connection`——但中文版同句(L248)同样无「。」,且全章 28 个 bullet 0 句点为既有风格(中文版 28/28 亦无),忠实镜像,**不改**。
2. **L221 "Upstack"**:见 §2-C,可选更保守措辞,非必改。
3. **各章 bullet 句点风格在英文件间不统一**(ch07 无句点、ch06/ch08/ch10 有):属全书层面议题,超出本章 C2 范围,建议在外环 style guide 层裁决,本章不改。

## 6. 复验输出(基线即终态,正文零改动)

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch09-extension.md book-en/src/part2/ch09.md
refs: 76 (equal sets: yes)
en words: 4332, bold 13, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)

$ cd book-en && mdbook build
 INFO Book building has started
 INFO Running the html backend
 INFO HTML book written to '…/wt/book-en/book'
exit=0   ← 零警告
```

## 7. 判定

**通过。** 外环五范式 0 命中;禁用词/翻译腔扫描 0 必改(3 条已判保留并记录理由);glossary 12 术语一致;mermaid/代码块/数字/章号与中文版及源码锚点全部对齐;verify-en 0 FAIL + mdbook 零警告。正文未做任何改动(无需复跑三轮,基线输出即终态输出)。
