# ch19 英文版 C2 读校报告(ch19-en-review,lane strong)

- 对象:`book-en/src/part4/ch19.md`(215 行,前置 ch19-en `e30d961` 交付态);对照 `chapters/ch19-octoscode.md`、C1 报告 `assets/ch19-en-check.md`(6/6 PASS)
- 日期:2026-09-03;范围:英文去味 + 母语度/术语一致 + 技术读校;不改事实/数字/引用/mermaid/代码块
- 注:brief 所写 `chapters/ch19-mcp-octoscode.md` 不存在,实际为 `chapters/ch19-octoscode.md`,与 C1 注记一致,以其为准
- 结论:**需修 → 已修 10 处后通过(PASS)**。外环五范式:2 处 colon reveal 已修、1 处 clearly(hedging 邻接)已修、dual loop 0 命中、顿号/CJK(码块外)0 命中、recap ending 合规;禁用词/翻译腔 10 处必改已落地 + 6 类判保留;术语(UI Protocol/AppUI/octoscode/serve/dumb client)零漂移;技术读校(mermaid 3 块、数字全保、章号 2/10/14/18/20/21)对齐;修后复验 verify-en 0 FAIL/0 WARN + mdbook 零警告,行数仍 215。

---

## 1. 外环已裁决范式逐条核查

| 待修范式 | 检查方法 | 结果 |
|---|---|---|
| 「双环」dual loop | `grep -niE 'dual[ -]?loop|double loop|双环|two loops'` | 0 命中 ✅(本章仅用 outer loop(外环),与 ZH 底稿一致;dual loop 属 Part4 术语,ch19 无涉) |
| 顿号(、)残留 | grep 顿号 + 全文 CJK 扫描 | 0 命中 ✅(CJK 仅存在于代码块注释与 mermaid 标签内,verify-en 的 strip-后 CJK=0 检查通过;mermaid 中文标签为 master 已裁「可并存型」,见 §4) |
| colon reveal | 逐条审读全部冒号 | **2 处必改已修**(:7、:104)+1 处伴随(:109 标签句改写);其余行尾冒号均为列表/代码块/表格引导,合法 |
| hedging 前缀 | perhaps/arguably/somewhat/clearly/obviously/it is worth noting 等 30+ 模式 | **1 处必改已修**(:105 "clearly understood"→"were well aware");"A division worth noting:"(:109)为标签+冒号形态,随 colon reveal #7 一并改写;actually(:207)为实义「实际更旧」,保留 |
| recap ending | 19.8 边界与回顾 + Chapter recap + Version note 逐条审读 | ✅ 合规(recap 为 7 条编号要点,各含新信息;收尾段为 Part IV 论点句非回声;Version note 为事实句) |

## 2. 禁用词/翻译腔逐条记录

系统扫描:in other words / obviously / clearly / firstly / so-called / moreover / meanwhile / not only…but also / as follows / the fact that / in terms of / carry out / make use of / in order to / due to the fact / em-dash / ellipsis / 句首 But/And/So/Now / very/really/quite / is being 被动堆叠 / there is 开头 / worth noting / one one-time 类叠词 / "X are the two sides of the same coin as Y" 类硬套。**必改 10 处全部落地:**

### 2.1 必改(10 处,已全部落地,均行内替换)

| # | 行号 | 原文 | 改后 | 理由 |
|---|---|---|---|---|
| 1 | :7 | "**The conclusion first:** in protocol mode…" | "**Start with the conclusion.** In protocol mode…" | colon reveal 变体:悬念标签+冒号揭独立句(ch03/ch11/ch12/ch16 C2 同型裁定);拆为两句后主语落地 |
| 2 | :15 | "A client that "executes nothing" **approaching** a hundred thousand lines" | "…**yet weighs in at nearly** a hundred thousand lines" | approaching 表体量为直译腔(「接近十万行」),母语用 weighs in at;nearly 保留原语义 |
| 3 | :20 | "the 7,221 lines of wire types (see §19.5) are **that bill**" | "…are **the bill for it**" | that bill 指代生硬(这笔账单→the bill for it);zh「就是这笔账单」 |
| 4 | :104 | "One architectural constraint deserves a name**:** the store's two entries do not just mutate state, they produce…" | "One architectural constraint deserves a name**.** The store's two entries do not just mutate state**;** they produce…" | colon reveal + comma splice 双病;冒号改句号、逗号改分号 |
| 5 | :105 | "The designers **clearly understood** the risk of 44,000 lines" | "The designers **were well aware of** the risk of 44,000 lines" | clearly 为弱证词/hedge 邻接腔;well aware 为母语惯用;zh「设计者很清楚」 |
| 6 | :105 | "even if the impl block grows enormous **for it**" | "…grows enormous **as a result**" | for it 悬空指代读不通;zh「哪怕 impl 块因此膨胀」 |
| 7 | :109 | "A division worth noting**:** the wire-layer `UiNotification` is decoded…" | "A division worth noting **is that** the wire-layer `UiNotification` is decoded…" | colon reveal:名词标签+冒号直接揭完整独立句(ch16 :180 "The fleet-side conclusion:" 同型必改) |
| 8 | :113 | "there is **one one-time** wait" | "there is **a single one-time** wait" | one one-time 叠词拗口;zh「一次性的等待只有一个」 |
| 9 | :157 | "These four client disciplines **are the two sides of the same coin as** the reducer's…" | "These four client disciplines **and** the reducer's… **are two sides of the same coin.**" | "A is the two sides of the same coin as B" 主表数不合 + 硬套句式;改为并列主语+标准习语 |
| 10 | :169 | "the Chinese variant (**shenpi for this once / this session**)" | "…(**shenpi, y for this time, s for this session**)" | for this once 非惯用且丢义:zh 原文「审批 \| y 本次 \| s 本会话」中 y/s 各有归属;斜杠并列改逗号并列补全 |

### 2.2 判保留(6 类)

- **dumb client / dumb-client ×7**(:7/:19/:20/:128/:173/:187/:189):哑客户端的既定译名,ZH 底稿用「哑客户端」,ch21 EN(:153)已用 "a dumb client",全链一致,保留。
- **In other words ×1**(:13):单一用例、标准技术连接词,与 ch16 C2 同型裁定(保留)一致。
- **actually ×1**(:207):Exercise 3 内 "the server is actually older" 为实义「实际更旧」,非 hedge,保留。
- **em dash ×2**(:15/:20):≤2 限额内,且均为插入语式破折号(非连接两个独立句),保留。
- **for example(:107)/for instance(:138)**:标准引导语各一次,非翻译腔,保留。
- **ellipsis ×1**(:173):位于 keymap 帮助串引用内部("…y/s/n approval …"),为引用原文的省略,事实内容不动,保留。

## 3. 母语度与术语一致

- 术语零漂移:UI Protocol(:3/:52)、AppUI(:11/:13/:17)、`octos serve`(:3/:11/:13…)、octoscode(全篇)、`AppUiCommand`/`UiCommand`/`UiNotification`/`AppUiEvent`/`ClientEvent` 的三层命名(:109/:137 附近的分工叙述)与 ZH 底稿及 ch21 EN 完全一致;dumb client 见 §2.2。
- 固定标签同位:Positioning(:3)/Boundaries and Recap(:175)/Further reading(:195)/Exercises(:203)/Version note(:215)五种 1:1。
- 被动句抽审:is expressed by(:88)、is anchored by(:88)、is preserved by(:184)均为技术事实句的合理被动(受事为主语强调对象),非被动堆叠,保留。

## 4. 技术读校

- **mermaid**(3 块::51 sequenceDiagram、:116 flowchart LR、:141 flowchart TD):节点/边数与 C1 机械比对一致(17 节点记号/15 边行),本次零改动。中文标签(用户终端/拦截 update 或 doctor/键盘与 composer 等 20 行)为 master 已裁「EN 保留中文标签可并存型」(ch06/ch13/ch15 同型,ch15-en-review :46 明文),不动。标签语义抽查:sequenceDiagram 四步顺序与 :42 文字一致;flowchart LR 双入口(apply_client_event :8241 / apply_event :9063)与正文引用行号一致;flowchart TD 的 into_protocol/compare_protocol/replay 游标链与 19.5 文字相容。
- **数字**:43,935×3、96,124、7,221×4、12,884、12,214、8,655×2、6,286、1,317、1,192、1,171、1,602、57、24/223/47、44,000×3(标题/正文/recap)、73 refs、39 methods、8/5/10 files 等——verify-en 数字检查 0 缺失;:101 "thirty thousand lines more than the runner-up" 与 ZH「多三万行」同口径(43,935−12,884=31,051,取整三万),忠实镜像,保留。
- **章号**:Chapter 2(:197)/10(:177)/14×5/18×7/20、21(:191/:199)全部有效;§19.5(:20)内部节引用正确;"#27 outer review"(:111)为事实引用保留。
- **代码块**:main.rs(:26)与 DEFAULT_STDIO_COMMAND(:48)含中文注释,与 ZH 同源代码块,C1 判定 code fence 内容一致(md5),不动。

## 5. 修改后复验输出

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch19-octoscode.md book-en/src/part4/ch19.md
refs: 73 (equal sets: yes)
en words: 4313, bold 3, em dash 2
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

修后行数仍 215(全部为行内替换);refs 73↔73 equal、words 4313(+14,均为替换词),0 FAIL / 0 WARN,mdbook 零警告零错误。

## 6. 上报不改稿(超 C2 权限,ZH 侧疑点)

- **:42「四步」vs :182 recap「五步」计数矛盾(ZH/EN 双语同病)**:正文 :42 "The order of the four steps is deliberate"(ZH :42「四步的顺序都有讲究」)明确四步:拦截子命令、ensure_octos_backend、splash、event_loop::run;而 recap 第 2 条(:182)写 "The startup chain has five ordered steps"(ZH :182「启动链五步有序」)却只列同样四项。疑 ZH 底稿将「ensure 后端」拆成安装+改写两步所致的历史残留,或「五步」为笔误。EN 忠实镜像了该矛盾;属事实层,ZH/EN 需 master 裁定统一(改 recap 为四步,或数清五步),C2 不动。

## 总判定

**PASS(10 处必改已落地并复验通过)。** 外环五范式清零;术语零漂移;mermaid/数字/章号全部对齐;1 项 ZH 侧疑点(四步/五步)上报待裁。
