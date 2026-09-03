# ch15 英文版 C2 读校报告(ch15-en-review,lane strong)

- 对象:`book-en/src/part3/ch15.md`(326 行);worktree 基线 main @ 94a257b,前置 ch15-en `e6ef9eb` + C1 ch15-en-check 6/6 PASS(`90cca6e` 归档)属实
- 日期:2026-09-03;范围:英文去味 + 母语度/术语一致 + 技术读校;不改事实/数字/引用/mermaid/代码块
- 产出:本报告 + `book-en/src/part3/ch15.md` 微修 5 行(仅措辞,零事实/引用/数字/mermaid 变更)

## 1. 外环待修项范式逐条核查

| 待修范式 | 本章命中 | 判定 |
|---|---|---|
| 「双环」dual loop | 全文 0 处(`dual loop`/`dual-loop`/`double loop` 均无;dual loop 属 Part4 术语,本章无涉) | ✅ 无需修 |
| 顿号(、)残留 | `grep -n '、'` → 0 匹配 | ✅ 无需修 |
| colon reveal | 全章冒号均为枚举引导/标签式(如 `in three tiers by field:` 后接代码块、`(:14-21)` 引用前置),无 "The answer is: X" 悬念句 | ✅ 合规 |
| hedging 前缀 | 无 perhaps/arguably/somewhat/in a sense/more or less;`actually` ×2(:9 "actually changed"、:55 "actually save")均为实义强调(「真正改变的」/「实际省下多少」)非 hedge,与 ch01–ch13 既定语气同型,保留 | ✅ 无需修 |
| recap ending | `## 15.6 Chapter recap` 为编号要点清单(5 条),无 "In this chapter we learned…" 回声段 | ✅ 合规 |

em dash:全章 1 处(:315 RFC 链接的破折号注释式),与 B 车道自报 6→1 相符,合规。

## 2. 禁用词/翻译腔逐条记录

| 行 | 原文 | 问题类型 | 处置 |
|---|---|---|---|
| :21 | "The before/after shape change **can be told** in three cross-sections" | 直译「可以从三个剖面讲」;英语惯用主动动词 | **已修** → "comes through in three cross-sections" |
| :99 | "tenancy vocabulary in the code **tells the story**" | 「讲故事」直译腔(narrative-speak) | **已修** → "across the code tells that story plainly" |
| :136 | "The limit … **must also be said plainly**" | 被动 + 直译「也必须说清楚」 | **已修** → "must be stated plainly as well" |
| :73 | "most worth **pausing on**" | 介词搭配欠妥(pause over/at 才是与 worth 搭配的分词) | **已修** → "most worth pausing over" |
| :132 | "it builds **on the spot** a factory" | 「当场」直译 + 副词插在 builds 与宾语之间,语序生硬 | **已修** → "it builds right there a factory" |
| :19/:132 | "(octoscode's doctor, **say**)" / "(a Matrix sub-bot, **say**)" | 保留:插入语 say 为母语惯用,非直译 |
| :164 | "To **land** multi-tenancy on a real deployment" | 保留:land 作「落地」在硅谷工程写作中属惯用,与全书 EN 风格一致 |
| :5 | "a batch of unglamorous machinery" | 保留:母语惯用表达,开篇语气词,非翻译腔 |
| :19/:29 | "the **shape** of things / shape change" | 保留:shape 为本书关键隐喻(结构 vs 约定),非翻译腔 |

其余扫描:`Note that`/`Please note`/`As mentioned`/`it is worth noting`/`in other words`/`obviously`/`let's`/`we can see` 全部 0;重复词(`the the` 类)0;句首 And/But/So 0。

## 3. 母语度与术语一致

- **crate 术语**:`octos-store`×27 / `octos-services`×22 / `octos-diagnostics`×12,大小写零漂移(无 `Octos-Store` 类误拼);与 ZH 侧「运维面/控制面」对应的 `operations plane`×5 / `control plane`×4 语义分工与 ZH 6/4 使用一致(EN 侧 :7 "operations plane…assembles…control plane" 合并一处,故 5/4)。
- **multi-tenancy 拼法**:`multi-tenancy` 小写正文统一;`Multi-tenancy`(标题首词/句首)×2、标题 `Multi-Tenancy`×1(Title Case,与 ch 标题体例一致);`multi-tenant` 形容词 ×3 —— 各形态均在正确位置,零漂移。
- **sub-account** ×11(9 小写 + 2 句首大写),全一致。
- **process-manager / process manager**:模式名 `process-manager`(=运行模式)×4 与普通名词短语 `process manager`×3 语义分工正确(对照 :134/:158/:303 为模式名,:240/:254 为组件名),保留不改。
- **frpc/frps**:frpc ×13(工具名)/ frps ×8(服务端),无混用;`render_frpc_config`/`TenantStore`/`ProductSpec`/`resolve_effective_profile` 符号拼写零漂移。
- **章引用**:Prerequisite "Chapter 14 (runtime modes)"(:3)✓;`see Chapter 10`(:9)✓;:298 边界段 Chapter 7/10/14/1/18 多重集与 C1 记录全等;版注 :326 Chapter 14×2 + Chapter 10×1 同位。**前置依赖 see Chapter 14 在 Positioning 行以 "Prerequisite: Chapter 14" 形式存在,合规**。

## 4. 技术读校

- **mermaid**(:138–156、:207–222、:262–282):3 块,边数 3+4+9=16、节点 6+5+8=19,与 C1 机械比对逐块全等;EN 保留中文标签为 master 已裁可并存型(ch06/ch13/ch19 同型),未动。抽查语义:块 1 ProcessManager→GW1/GW2 + serve→TenantStore 与 15.2.3 进程隔离文字相容;块 2 Browser→Frps→Frpc→Serve + Admin 渲染 frpc.toml 与 15.3.1/15.3.2 一致;块 3 观测/动作双通道与 15.4 各节一一对应。
- **数字**:2,664/3,223/2,243(标题 :23/:59/:79 与 recap :302 一致)、9/8/8 files、512/901/1,554/183/7,221/518/473/698 行、6001–6999 端口池、999 上限、2,261/921/138/130/102 grep 计数、`MAX_SUB_ACCOUNTS_PER_PARENT = 10`、10 MiB/90 天轮换 —— 与 C1 数字集合 138↔138 全等口径一致,本次微修未触及任何数字。
- **章号/节号**:标题 Chapter 15、节 15.1–15.6、交叉引用 15.1(:326 版注 "covered in 15.1")、15.1.1–15.1.5、15.2.1–15.2.3、15.3.1–15.3.2、15.4.1–15.4.6 全部对得上,无悬空节引用。
- **事实层疑点(不改,报 master 备查)**::59 讲 octos-services 时引 `crates/octos-store/src/lib.rs` 文档——ZH 原文 :59 同样写 octos-store(疑 ZH 笔误,EN 忠实镜像);:61 表中 compaction 行路径为 `crates/octos-agent/src/agent/compaction.rs` 而 ZH :64 与 facts 表 §2 均如此(facts 表列 octos-services 8 文件含 compaction.rs:320,路径归属疑为跨 crate 笔误)。两处均属事实/引用层,C2 无权改动,建议 master 裁定是否提交 ZH 侧勘误。

## 5. 改动清单与复验

改动(仅 book-en/src/part3/ch15.md,5 行,`git diff` 5+/5−,零行数位移):

| 行 | 改动 |
|---|---|
| :21 | `can be told in` → `comes through in` |
| :73 | `worth pausing on` → `worth pausing over` |
| :99 | `in the code tells the story` → `across the code tells that story plainly` |
| :132 | `builds on the spot a factory` → `builds right there a factory` |
| :136 | `must also be said plainly` → `must be stated plainly as well` |

复验输出:

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch15-production.md book-en/src/part3/ch15.md
refs: 55 (equal sets: yes)
en words: 4521, bold 12, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build
INFO Book building has started
INFO Running the html backend
INFO HTML book written to .../book-en/book
mdbook_rc=0(0 WARN / 0 ERROR)
```

## 6. 结论

**通过(可采回)。** 必改项 1 类(翻译腔措辞 ×5:can be told/tells the story/must also be said/pausing on/on the spot)已当场修复并复验 0 FAIL + mdbook 零警告;范式五项(双环/顿号/colon reveal/hedging/recap)+ em dash 6→1 全数合规;技术读校(mermaid 3 块 16 边、数字 138 集合、章号节号)零异常。保留项 4 条(say 插入语/land/unglamorous/shape)为语气选择,不构成翻译腔。事实层疑点 2 条(:59 octos-store lib.rs、:61 compaction 跨 crate 路径)非 C2 职权,交 master 裁定。
