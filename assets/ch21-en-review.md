# ch21 英文版 C2 读校报告(ch21-en-review,lane strong)

- 对象:`book-en/src/part4/ch21.md`(239 行,前置 ch21-en `0677704` 交付态);对照 `chapters/ch21-herdr.md`、C1 报告 `assets/ch21-en-check.md`(6/6 PASS,56db538 归档)
- 日期:2026-09-03;范围:英文去味 + 母语度/术语一致 + 技术读校;不改事实/数字/引用/mermaid/代码块
- 结论:**需修 → 已修 4 处后通过(PASS)**。外环五范式:2 处 colon reveal 已修、hedging/弱证词 0 命中、dual loop 4 处均为合规术语、顿号/CJK(码块外)0 命中、recap ending 合规;禁用词/翻译腔 4 处必改已落地 + 5 类判保留;术语零漂移;技术读校(3 mermaid、数字、章号)对齐;修后复验 verify-en 0 FAIL/0 WARN + mdbook 零警告,行数仍 239。

---

## 1. 外环已裁决范式逐条核查

| 待修范式 | 检查方法 | 结果 |
|---|---|---|
| 「双环」dual loop | `grep -niE 'dual[ -]?loop|double loop'` | 4 处命中(:3 "a dual-loop system"、:7 "both ends of the dual loop"、:208 "running the dual loop on a mac"、:218 "the dual loop closes here"),**全部合规保留**:ZH 底稿同位行即「双环」(:3/:7/:208/:218),Part 4 中「双环」指内环+外环整套系统,EN 术语即 dual loop,与 ch19-en-review 裁定「dual loop 属 Part4 术语」一致,非需改项 |
| 顿号(、)残留 | grep 顿号 + 码块外全 CJK 扫描(python 脚本逐行) | 0 命中 ✅(码块外无任何 CJK 字符;正文中文串仅存在于代码块内 TOML 字面量 `审批 | y 本次 | s 本会话`(:79,与 ZH 同源识别规则原文,事实内容不动)与 commit title(:56,引用原文)) |
| colon reveal | 逐条审读全部冒号 | **2 处必改已修**(:56 "Note the version fact:"、:58 "The side that matters more to this book's readers:")+1 处伴随(:107 "The maintenance duty follows:" 随弱系动词一并改 "follows from this");其余冒号均为列表引导(:11–14 编号 promise)、代码/引用前导(:20 "The topology:"、:60 "40 lines (…): the first 5 lines…")、标题(:1/:5/:52/:109)及小节内合法同位解释,合规 |
| hedging / 弱证词 | perhaps/arguably/somewhat/clearly/obviously/worth noting/basically/actually/very/really/quite 等 30+ 模式 | 0 处必改 ✅;"simply have nothing to do"(:202)、"completely invisible"(:170)均为实义副词(ZH「根本没事做」「完全不可见」),非弱化,保留 |
| recap ending | 21.7 Boundaries and Recap + Version note 逐条审读 | ✅ 合规(:216 三条边界均为"this chapter only consumes/covers"式限定句,含新信息;:218 脉络段为 Part IV 收束论点句——「连接两者的手是 herdr」——非前文回声;:239 Version note 为事实基线句) |

## 2. 禁用词/翻译腔逐条记录

系统扫描:in other words / obviously / clearly / firstly / so-called / moreover / meanwhile / not only…but also / as follows / the fact that / in terms of / carry out / make use of / in order to / due to the fact / em-dash / ellipsis / 句首 But/And/So/Now / very/really/quite / is being 被动堆叠 / there is 开头 / worth noting / "X are the two sides of the same coin as Y" 硬套。**必改 4 处全部落地:**

### 2.1 必改(4 处,已全部落地,均行内替换)

| # | 行号 | 原文 | 改后 | 理由 |
|---|---|---|---|---|
| 1 | :16 | "Keyboard and mouse are **dual first-class citizens**" | "…are **both first-class citizens**" | 翻译腔:「双一等公民」直译成 dual first-class citizens 非母语搭配(ZH :16「双一等公民」);英语惯用 both first-class citizens,语义不变 |
| 2 | :56 | "**Note the version fact:** this variant exists only on…" | "Note the version fact **that** this variant exists only on…" | colon reveal 变体:名词标签+冒号直接揭完整独立句(ch19 :7 "The conclusion first:" 同型裁定);改 fact 从句后主谓落地 |
| 3 | :58 | "**The side that matters more to this book's readers:** recognition rules live on…" | "The side that matters more to this book's readers **is that** recognition rules live on…" | colon reveal 同型(:109 标签+冒号揭独立句);改 be-从句 |
| 4 | :107 | "The maintenance duty **follows:** any status-bar rework…" | "The maintenance duty **follows from this:** any status-bar rework…" | 弱系动词+colon reveal 邻接:follows 单用悬空(duty follows what?);follows from this 接住前句(dumb-client → status bar 双重身份),冒号保留为合法解释引导 |

### 2.2 判保留(5 类)

- **dual loop ×4**(:3/:7/:208/:218):见 §1,Part 4 术语,ZH 双环 ↔ EN dual loop 全链一致。
- **dumb client / dumb-client ×2**(:107/:153):哑客户端既定译名,ZH :153「哑客户端」,ch19-en 全链同用,保留。
- **there are ×1**(:119 "Beyond the three primitives there are three supporting commands"):存在句单用一次、后接实义主语,非堆叠,保留。
- **em dash ×0 / ellipsis ×0**:全文零命中(verify-en 计数 en words 4745→4750,em dash 0)。
- **逗号无空格/叠词/duplicated words**:扫描(`the the|a a|to to|of of|is is` 及 `[A-Za-z],[A-Za-z]`)0 命中。

## 3. 母语度与术语一致

- **术语零漂移**:cockpit(:3/:5,驾驶舱)、detection contract(:3/:60/:107/:216,识别契约)、three primitives(:3/:109/:119/:159,三原语)、dual sentinels(:3/:167/:189/:194/:199/:202/:235,双哨)、restart hard checklist(:167/:170/:189/:199/:202,重启硬清单)、double gate(:153/:206/:232,双重门,ZH 同位亦用「双重门」;与 four gates 四道门区分清楚)、outer-reviewer lock / duty-roster(:208)、structural surface(:187/:202/:235,结构面)、smoke(:107/:210)、runs what you already run(:14/:153,README 原句保留原文)、dumb client(:107/:153)——全部与 ZH 底稿及 glossary 用法一一对应,无别名混用。
- **herdr 拼写**:全篇小写 herdr(产品名小写,与 ch19/20 一致),句首亦小写(作为专有名词于句中出现的排布无句首裸用),0 漂移;octoscode / octos / serve / octos steer / olp-init 拼写与 ZH 及引用路径一致。
- **固定标签同位**:Positioning(:3)/Boundaries and Recap(:214)/Further reading(:220)/Exercises(:229)/Version note(:239)五种 1:1,本次 4 处修改均为行内替换,未动任何标签行。
- **被动句抽审**:is rejected(:148)、is dropped(:148)、is never delegated(:165)均为技术事实句合理被动,非堆叠,保留。

## 4. 技术读校

- **mermaid 3 块,零改动,与 C1 机械比对一致**:
  - flowchart LR(:22–44):3 subgraph + 7 方括号节点声明(OP/CLI/SRV/SOCK/P1/P2/P3)= 16 记号(含 subgraph 标题节点),6 条边(OP→CLI/CLI→SOCK/SOCK—SRV/SRV→P1/SRV→P2/SRV→P3/P1→SRV 中 6 条 arrow 行;实测 `-->` 计 6 + 1 条 `---` 无向线,与 C1「6 边」口径一致——C1 记 6 条边即 arrow 边,`---` 为连接线);标签如 "Outer-loop side"/"spawn calls"/"periodic sampling of tail text" 均为 ZH 标签的合法英译,无增删。
  - sequenceDiagram(:123–146):4 participant(O/C/S/T)、13 箭头(8 `->>` + 5 `-->>`,实测合计 13)✅;四道门 Gate 1–4 顺序与 :148 正文(en: empty→blocked→not_ready→process mismatch)一致;300ms Enter 延迟与 :150 正文一致。
  - stateDiagram-v2(:191–200):6 条状态转移([*]→mounted、mounted→healthy、mounted→visible_stall、mounted→blind、visible_stall→healthy、blind→mounted)✅,与 :202「三态最险是双哨齐静」叙述相容。
- **数字**:245(:18 herdr src/ 文件数)、229,696(:18 herdr 行数)均在且仅 1 次;65,400/19,166/12,416/10,540/9,822/8,957/29,927/6,606/6,155/2,303/949/2,108/24/22/40/11/300 ms/8 hours 等与 C1 数字集合(75 项)一致——本次修改零数字变动(verify-en refs 69↔69 equal,数字检查包含在 C1 口径内未触碰)。700,915(三仓合计)双侧均无,属预期(本章单仓口径)。
- **章号**:Chapter 19(:3/:107/:153/:216/:218)、20(:3/:208/:216/:218)、18(:216)、21(:1)全部有效且与 ZH 同位;`herdr/` 前缀引用 55 条(全 57 refs 中)与 C1 集合一致,含 `herdr/src/app/api/agents.rs:13`、`herdr/src/api/wait.rs:661` 等;`octoscode/docs/OLP_*` 相对路径引用未动。
- **代码块**:TOML manifest(:62–102)与 bash(:178–181)两块未触碰,中文串「审批 | y 本次 | s 本会话」为识别规则原文,事实内容保留。

## 5. 修改后复验输出

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch21-herdr.md book-en/src/part4/ch21.md
refs: 69 (equal sets: yes)
en words: 4750, bold 6, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

修后行数仍 239(全部为行内替换);refs 69↔69 equal、words 4745→4750(+5,均为替换词:that/is that/from this/both 等),0 FAIL / 0 WARN,mdbook 零警告零错误。

## 6. 上报不改稿(超 C2 权限)

- 无 ZH 侧事实疑点。本章 ZH/EN 双语在计数、引用、术语上未发现矛盾;ch19 的「四步/五步」类问题在 ch21 无对应。
- 备忘一条非必改观察::16 "dual first-class citizens" 已按母语度修为 "both first-class citizens",若 ZH 侧后续将「双一等公民」改写为「键盘与鼠标都是一等公民」,EN 可同步微调;当前 EN 措辞已自洽,无需 ZH 变更。

## 总判定

**PASS(4 处必改已落地并复验通过)。** 外环五范式清零(2 colon reveal + 1 翻译腔 + 1 弱系动词);术语零漂移;mermaid/数字/章号全部对齐;无 ZH 侧上报项。
