# ch13 英文版 C2 读校报告(ch13-en-review,lane strong)

- 对象:`book-en/src/part3/ch13.md`(439 行);基线 main @ 90cca6e worktree,前置 f08282d + C1 79d6234(6/6 PASS)
- 日期:2026-09-03;范围:英文去味 + 母语度/术语一致 + 技术读校;不改事实/数字/引用/mermaid/代码块
- 产出:本报告 + `book-en/src/part3/ch13.md` 微修 6 行(仅措辞,零事实/引用/数字变更)

## 1. 外环待修项范式逐条核查

| 待修范式 | 本章命中 | 判定 |
|---|---|---|
| 「双环」dual loop | 全文 0 处出现(dual loop 属 Part4 术语,本章无涉);全书 EN 侧 `dual loop`/`dual-loop` 拼法与 ch20/ch21/preface 一致 | ✅ 无需修 |
| 顿号(、)残留 | `grep -n '、'` → 0 匹配 | ✅ 无需修 |
| colon reveal(冒号悬念句) | 全章冒号均为枚举引导/标签式(如 `One subtle implementation fact:` 后接完整句、`The accurate conclusion:` 同),无 "The answer is: X" 式悬念 | ✅ 合规 |
| hedging 前缀 | 无 arguably/perhaps/in a sense/it seems/somewhat/more or less;bare `clearly` ×1(:160 "clearly tuned for…")为断言强化非 hedge,属本书既定语气(ch01–ch12 同型),保留 | ✅ 无需修 |
| recap ending | `## 13.5 Chapter Recap` 为编号要点清单(6 条),无 "In this chapter we learned…" 式回声段 | ✅ 合规 |

## 2. 禁用词/翻译腔逐条记录

| 行 | 原文 | 问题类型 | 处置 |
|---|---|---|---|
| :96 | "grew to 9 entries **in step**, including…" | 直译「同步增长到」,缺介词补语,英语读者费解 | **已修** → "grew to 9 entries in step with them, including…" |
| :136 | "after checking the current source **I can state this plainly**" | 第一人称叙事侵入(I can state),技术书去味 | **已修** → "the current source is unambiguous on this point" |
| :84/:98/:109/:343 | `sub-Agent`(大写 A)4 处 | 拼写不一致:全书 EN 其余 9 处均小写 `sub-agent`(ch03/ch17) | **已修** → 统一 `sub-agent`(4 处) |
| :184 | "Incidentally, in `build_handlers()`…" | 口语插入语,轻度翻译腔 | 保留:后接真实技术要点(registry 占位),语气与本书侧栏一致,非必改 |
| :177 | "a placeholder that earns its keep" | 俚语化标题 | 保留:母语惯用语、非直译腔,与 ch 系列标题风格一致 |
| :188 | "One line each:" | 电报体省略 | 保留:引导列表的标准简式,合规 |

其余扫描:em dash 0、`Note that`/`Please note`/`As mentioned`/`we can say`/`obviously`/`of course` 均 0;`still`/`simply`/`actually` 的使用均在「旧稿对照」句境中承担语义(纠正旧稿),非填充词。

## 3. 母语度与术语一致

- **Pipeline/DOT/五类节点术语**:`HandlerKind`(9)/`IrNodeKind`(12)/`DynamicParallel`/`Codergen`/`converge`/`fan-out`(连字符,×9 全一致)/`pipeline-level`/`sub-agent`(修后全一致)/`event ABI` 全章拼写零漂移;标题 `## 13.2 Nine HandlerKinds and Twelve IR Node Kinds` 与 Positioning 行 "nine HandlerKinds, twelve IR node kinds" 计数口径一致(数字 9/12 与正文表 9 行/12 行相合)。
- **章引用**:Chapter 5/8/10/11 前置式与 C1 记录的多重集全等(`Chapter 10`×4 含 13.3.4/13.4),无 "see Chapter N" 句式残留。
- **固定标签**:Positioning(:3)/Engineering decision(:377)/Further reading(:426)/Exercises(:431)/Version note(:439)行号与 C1 快照一致(本章微修均为行内替换,零行数变化,git diff 确认 6 insertions/6 deletions)。

## 4. 技术读校

- **mermaid**(:228–244):1 块;节点 13(DOT/Parse/Validate/Start/Loop/Kind/PFan/DPlan/Normal/Merge/Workers/Select/Done)、边行 15;标签与 ZH 侧逐块一致(C1 已机械全等);EN 保留中文标签为 master 已裁可并存型(ch06/ch15/ch19 同型),未动。边语义抽查:`Kind{node.handler}` 三分支 + Merge/Select 汇聚 + 有后继/无后继闭环,与 13.3.1 七步、13.3.3 五步算法文字相容。
- **数字**:25,134/5,591/3,197/2,140/1,445(:439)、1,445(:46)、3,197(:363)、23 条规则、12 IR、9 HandlerKind、7 实现、`MAX_PIPELINE_FANOUT_TOTAL = 500`、`MAX_FANOUT_WORKER_SECS = 3600`、[60,3600] 默认 1800、默认 300 秒/5 分钟——与 ch13-refcheck/ch13-factcheck 实测口径逐项相合。注意:32,799 行(crate 全量)属 ch01/附录 A 口径,本章 Version note 用 `src/*.rs` 25,134,不冲突。C1 数字集合 212↔212 零缺失,本次微修未触及任何数字。
- **章号**:标题 `Chapter 13`、节号 13.1–13.5、交叉引用 13.2.1/13.2.2/13.2.7/13.2.8/13.3.4/13.3.5 与实际节号逐一对得上;无悬空节引用。

## 5. 改动清单与复验

改动(仅 book-en/src/part3/ch13.md,6 行,`git diff` 6+/6−,零行数位移):

| 行 | 改动 |
|---|---|
| :84 | `Spawns a full sub-Agent` → `sub-agent` |
| :96 | `in step,` → `in step with them,` |
| :98 | 标题 `a sub-Agent` → `a sub-agent` |
| :109 | `the sub-Agent through` → `the sub-agent through` |
| :136 | `after checking the current source I can state this plainly:` → `the current source is unambiguous on this point:` |
| :343 | `a background sub-Agent` → `a background sub-agent` |

复验输出:

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch13-pipeline.md book-en/src/part3/ch13.md
refs: 95 (equal sets: yes)
en words: 5371, bold 15, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build
(无 warn/error 输出)rc=0
```

## 6. 结论

**通过(可采回)。** 必改项 2 类(第一人称叙事 ×1、术语不一致 sub-Agent ×4+缺介词 ×1)已当场修复并复验 0 FAIL + mdbook 零警告;范式五项(双环术语/顿号/colon reveal/hedging/recap)全数合规;技术读校(mermaid 13 节点 15 边、数字、章号)零异常。保留项 3 条(Incidentally/earns its keep/One line each)为语气选择,不构成翻译腔,交 master 备查。
