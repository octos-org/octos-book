# ch14 英文版 C2 读校报告(ch14-en-review,lane strong)

- 对象:`book-en/src/part3/ch14.md`(372 行);基线 main @ f08282d(ch14-en 交付),前置 C1 ch14-en-check 6/6 PASS(a5d65bc 归档)
- 日期:2026-09-03;范围:英文去味 + 母语度/术语一致 + 技术读校;不改事实/数字/引用/mermaid/代码块
- 产出:本报告 + `book-en/src/part3/ch14.md` 微修 7 行(仅措辞,零事实/引用/数字变更;git diff 7 insertions/7 deletions,行数 372 不变)

## 1. 外环待修项范式逐条核查

| 待修范式 | 本章命中 | 判定 |
|---|---|---|
| 「双环」dual loop | 全文 0 处(dual loop 属 Part4 术语,本章无涉) | ✅ 无需修 |
| 顿号(、)残留 | `grep -n '、'` → 0 匹配 | ✅ 无需修 |
| colon reveal(冒号悬念句) | 全章冒号均为枚举引导/标签式(如 :5 "does four things: …"、:88 "not five products" 后的维度枚举),无 "The answer is: X" 式悬念;`:333` "The dividing principle:" 为标签引导后接完整判据句,与 ch13 同型合规 | ✅ 合规 |
| hedging 前缀 | 无 arguably/perhaps/in a sense/it seems/somewhat/maybe/probably;`:78` "not five products; they are five access paths" 为对比断言非 hedge | ✅ 无需修 |
| recap ending | `## 14.8 Chapter Recap`(:345)为编号要点清单(5 条),无 "In this chapter we learned…" 式回声段 | ✅ 合规 |

已知差异确认:14.6.1 text 优先级链块首标签「显式」→ "explicit"(EN :264–266),即 verify 报的唯一 WARN,外环已知,未回改中文。✅

## 2. 禁用词/翻译腔逐条记录

| 行 | 原文 | 问题类型 | 处置 |
|---|---|---|---|
| :88 | "adds **operations burden**" | 名词搭配错(operations burden×);英语惯用 operational burden | **已修** → "adds operational burden" |
| :206 | "the tools **known visible** to the model" | 双重形容词粘连直译(「已知可见」),非英语结构 | **已修** → "the tools known to be visible to the model" |
| :212 | "The old draft's "91" **is void**" | "is void" 律师/程序用语,指数字失效应为 no longer holds(全书其余处用 obsolete/no longer holds) | **已修** → "no longer holds" |
| :222 | "the **trade of** X **against** Y" | 搭配错:trade of→trade-off between/and;且 "not turned outward" 直译「不外翻」 | **已修** → "the trade-off between … and …";"is not exposed" |
| :317 | "does not **pierce** a running process" | pierce 诗意误用(「击穿」直译);程序语境用 take down / crash | **已修** → "does not take down a running process" |
| :350 | "never **turned outward**" | 同 :222「外翻」直译 | **已修** → "never exposed" |
| :372 | "the old number **is void**" | 同 :212 | **已修** → "the old number no longer holds" |

保留项(逐条核过,非必改):

- :30 "Two details deserve attention." — ZH「两处细节值得注意」直译但英语自然,全书同型(ch01 :180 "deserve a pause")。
- :32 "`octos --help` as measured lists 28" — "as measured" 轻度凝缩,但本章测量口径叙事(:7 "Measured against …"、:170 "measured output matches")刻意保留该语域,改 "as measured on the main branch" 属增字非纠错,保留。
- :96 "chat earns its keep as the thinnest verification surface" — 母语惯用语,与 ch13 "earns its keep" 保留判例一致。
- :141 "Note that the single-writer lock comes first" — "Note that" 为全书既定句式(ch01/ch06×2/ch15/appendixA/appendixE 共 7 处),非翻译腔。
- :164 "does not self-collide" — self-collide 原子物理惯用词挪用到锁冲突,本书技术修辞风格内(与 "does not self-heal" 类构造同型),保留。
- :166 "This is the root reason" — root cause/root reason 混用中前者更常见,但 root reason 语义准确且仅此一处,不构成漂移,保留。
- :88/:98 泛指 "you"("when you need a resident process"、"a configuration file you can commit")— 操作建议语境的通用读者指称,ch15 正文/Exercises 多处同型,保留。

其余扫描:em dash 正文 0(仅 :41 表格引用 facts 原文 doc 注释 1 处 + :177 表格空单元格 1 处,均为转引/表格惯例);`please note`/`obviously`/`of course`/`actually`/`simply`/`basically`/`essentially`/`in other words`/`as mentioned` 均 0;`we` 仅 :333 内嵌引语 "do in-flight sessions use the old value" 的问句内(设计者自问,合规);英式拼写(behaviour/organise)0 处,US 拼写一致。

## 3. 母语度与术语一致

- **runtime surfaces(五运行面)**:本章核心术语,`runtime surface`(单数)/`runtime surfaces`(复数)共 11 处拼写全一致;五面命名 chat/gateway/serve/mcp-serve/acp 全章零漂移(:3/:11/:34–42 表/:46/:55/:80 列头/:347 recap 相互一致)。标题 `## 14.1 One entry point, five runtime surfaces` 与 ZH「一个入口,五种运行面」对应。
- **「runtime modes」的正当残留**:`:7` "An earlier draft summarized this layer as 'four runtime modes'"、`:337` "## 14.7 Feature flags: the compile-time runtime surface"、`:372` Version note "'four runtime modes' was rebuilt as 'five runtime surfaces'" — 三处均为旧稿对照/演化叙事的引述性使用,与 ZH「四种运行模式」重构叙事一致,非术语漂移。
- **跨章一致**:ch15 Positioning "Prerequisite: Chapter 14 (runtime modes)" 与 ch15 :298 "runtime modes and the configuration system are Chapter 14" 用的是 ZH 章名「运行模式」对应词(runtime modes),与本章内文 surfaces 并存属「章名 vs 正文术语」分工,简报已声明前言统一 runtime modes 表述——现状(章名 modes、正文 surfaces)与该裁决相容,无需改动,记录备查。
- **首字母大小写惯例**:五面名在正文句中小写(chat/gateway/serve/mcp-serve/acp)、表头/枚举同小写,全章一致;`FULL-ACCESS`/`Workspace-Write`/`Local mode` 大小写与 :174–179 门禁表一致。
- **固定标签**:Positioning(:3)/Engineering decision×2(:325/:331)/Further reading(:355)/Exercises(:362)/Version note(:371)与 C1 快照同行;`sub-account` 3 处拼写一致;Positioning 用 "Who should read it"(14 章主流标签,ch15 用 "Intended readers" 为孤立变体,本章无需动)。
- **章引用**:Chapter 1/3/5/6/9/10/11/17/18 前置式(Chapter N's subject / details: Chapter N)全章一致,无 "see Chapter N" 句式(唯一 "see Chapter 6" :222 为工具目录指引同型句,与 ZH「见第 6 章」对应);内部节引用仅 :108 "(see 14.6.4)" 与 :292 "(see 14.3)",后者正确。

## 4. 技术读校

- **mermaid 5 块**(:48/:127/:181/:224/:270,与简报指定行号逐一相符):
  - 块 1(:48–72):拓扑 CLI入口→SURFACES→SHARED_ASSEMBLY,subgraph id 本地化(CLI_ENTRY/SURFACES/SHARED_ASSEMBLY)与 ch13 B1 判例同型;五 DISPATCH 分支 + CONFIG→LLM + 五面 & 汇入共享装配,边数/方向与 ZH 一致。
  - 块 2(:127–139):serve 装配链 S→LOCK→PS→EB→SM→M→SW→R→STDIO 分支,行号标签 :673/818/:750/:764/:775/:1316/1969/:1778 与 facts 表逐项相符;`127.0.0.1:50080` 默认与 :179 正文一致。
  - 块 3(:181–195):SOLO/NO/LOOP/DANGER/NN 五判定节点,REJECT"danger requires solo"语义与 :325 侧栏一致;yes/no 边标签与 ZH 是/否一一对应。
  - 块 4(:224–231):ORCH→SRV→SES→AGENT→OUT 回环,`handle_request:201`/`mcp_serve.rs:485` 与 :220/:233 正文一致。
  - 块 5(:270–286):START→PARSE→APPLY→CTX 分支→P1/P2/P3→MERGE→RUNTIME→WATCH→DIFF→HOT/RESTART;①②③ 圈号、`every 5s, SHA-256 compare` 虚线边与 :298/:315 正文一致;SKIP 直接汇入 MERGE 与 :260 "显式 --config 或 tenant 不读项目本地文件"一致。
  - EN 侧标签全部英译且与正文术语一致(terminal readline/ChannelManager multi-channel/REST/UI Protocol control plane/run_octos_session/ACP over stdio),无中文残留。
- **数字**:19,485(:5/:347)与 facts 合计式 4,143+7,595+2,849+1,138+3,024+268+468 相符;11,944(:3/:243/:351)= 3,790+7,003+608+543;67 端点(:5/:210/:212/:348)双跑口径注;28 子命令(:7/:32/:367)逐字清单与 facts 相符;59 工具(:222)、7,003/3,790/608/543(:7/:247–250/:292)、1,044(mcp_server.rs :220)、`EventBroadcaster::new(256)`(:121/:131)、127.0.0.1:50080(:179/:349)、127.0.0.1:4033(:233)、10 频道(:5)全与 facts 对上。**修后复跑数字集合比对:zh unique 151 ↔ en unique 151,diff 为空**(剥离千分位逗号),7 处措辞修改零数字影响。
- **章号**:章题 Chapter 14(:1);对 v1 旧稿的指称 "the v1 draft (Chapter 13)"(:372)与 facts/版本演化一致;前置 Chapter 5(agent loop)/Chapter 11(octos-bus)(:3)正确。
- **发现 1 处 ZH/EN 同源悬空引用(不改,上报)**::108 "(see 14.6.4)" — 本章 14.6 只有小节到 14.6.3(热加载 watcher,:296);热加载内容实际在 14.6.3,ZH 侧同为「见 14.6.4」。EN-only 改为 14.6.3 会破坏 C1 数字集合奇偶(6.4→6.3 引入 en-only 3、zh-only 4),且属事实层修正,超出 C2 措辞授权 → **上报 master 建议双语同修**(chapters/ch14-runtime-modes.md:108 与 book-en/src/part3/ch14.md:108 各 1 处)。
- 代码块 3 处(rust :19–28 mod.rs 节选 / :147–155 serve.rs stdio 分支 / :300–311 ConfigChange 枚举)+ octoscode 常量引用 :159–162:与 facts 的符号/行号注释相符,未动。

## 5. 改动与复验

改动(`git diff --stat`:7 insertions, 7 deletions,仅 `book-en/src/part3/ch14.md`):

| 行 | 改前 → 改后 |
|---|---|
| :88 | operations burden → **operational burden** |
| :206 | known visible → **known to be visible** |
| :212 | is void → **no longer holds** |
| :222 | not turned outward → **is not exposed**;the trade of … against → **the trade-off between … and** |
| :317 | does not pierce → **does not take down** |
| :350 | never turned outward → **never exposed** |
| :372 | the old number is void → **the old number no longer holds** |

复验输出:

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch14-runtime-modes.md book-en/src/part3/ch14.md
WARN: code block content differs (mermaid and comments excluded)
refs: 61 (equal sets: yes)
en words: 4566, bold 7, em dash 2
RESULT: 0 FAIL(s), 1 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

verify 0 FAIL(唯一 WARN 即外环已知的 14.6.1 text 块首标签英译差异,未回改);mdbook build WARN/ERROR 计数 0(仅 INFO,book 正常写出)。行数两侧均 372 不变。

## 总判

**通过(需修 7 处已修并复验)**:范式五项全合规;禁用词/翻译腔 7 处必改已修,7 处保留均逐条说明理由;术语(runtime surfaces 五面、门禁档位、能力常量)零漂移;5 块 mermaid 标签与正文/facts 三方一致;关键数字(19,485/11,944/67/28/59 等)全对上,修后数字集合 151↔151 双等。

上报 1 项(超出 C2 权限):14.6.4 悬空引用(ZH/EN 同源,建议 master 双语同修为 14.6.3,修后需两侧同跑 verify)。
