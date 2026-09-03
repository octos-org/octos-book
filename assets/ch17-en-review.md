# ch17 英文版 C2 读校报告(ch17-en-review,lane strong)

- 日期:2026-09-03
- 对象:`book-en/src/part3/ch17.md`(225 行,基线 e30d961;本报告与改动在隔离 worktree 内产出,未 commit)
- 前置:C1 `assets/ch17-en-check.md` 6/6 PASS(dacb8b6 归档)
- 结论:**通过(需修 7 处,已全部就地修改并复验通过)**

---

## 一、命中清单(逐条)

### A. 已裁决范式类(外环待修项范式,C2 必查)

| # | 位置(改前行号) | 问题 | 处置 |
|---|---|---|---|
| A1 | :62 | 疑问句以句号收尾:"Why cut three shapes instead of merging them into one parameterized executor." — 陈述句式提问属翻译腔残留(中文原稿即「为什么…。」) | 改为 `...one parameterized executor?` |
| A2 | :129 | 同上:"Why an external MCP backend instead of reusing the local spawn of Chapter 12." | 改为 `...of Chapter 12?` |
| A3 | :210-213 | "URL : 说明" 空格冒号连写(MCP/redb/10.1-10.3/Chapter 16 四条),系中文全角冒号直译痕迹;且与 ch15/ch16 Further reading 既有格式(`URL, 说明`)不一致 | 四条统一改为 `URL, 说明` / `章节, 说明`(分号仅在嵌套说明处保留) |

「双环」→ dual loop:全章无该词,无命中。顿号(、)残留:`grep '、'` 0 命中。hedging 前缀(Perhaps/Maybe/Arguably 等置句首):0 命中。recap ending(章末总结后再拖尾段):17.9 六条收束干净,后接 Further reading/Exercises 属全书固定结构,非 recap ending。禁用词(delve/foster/leverage/utilize/robust/seamless/in order to 等 verify-en 全表):0 命中。

### B. 母语度/体例类

| # | 位置(改前行号) | 问题 | 处置 |
|---|---|---|---|
| B1 | :62 | "at the cost that aggregation order equals arrival order" — `at the cost that + 从句` 非母语搭配 | 改为 `at the cost of making aggregation order equal arrival order` |
| B2 | :144 | 引号内 "may it run" — 情态倒装疑问式生硬,对应中文「能不能跑」 | 改为 `"is it allowed to run"`(与后文 gates 语义贴合) |
| B3 | :105 | 图注 `Figure 17-2:` 无加粗,而 :60 `**Figure 17-1: ...**` 加粗,同章体例不一致 | 补齐加粗 `**Figure 17-2: the sequence of one dispatch.**` |
| B4 | :163 | 同上,`Figure 17-3:` 未加粗 | 补齐加粗 `**Figure 17-3: the decision flow of the three gates.**` |

### C. 记录不改(判定为可接受,附理由)

- colon reveal / 冒号密度:叙述句冒号 ~85/百句、≥3 冒号长句 10 句 — 密度偏高属本书既定文体(中文底稿「甲:乙」句式直承),ch14-16 同量级,非本章独有退化;B3/A3 已消化最刺眼两处,其余不动以免偏离镜像。
- "it would rather idle the whole round than risk polluting the chain"(拟人)与 "concurrency only produces artifacts destined for the trash"(隐喻):与中文底稿修辞对应(「宁可整轮空转」「注定进垃圾桶」),保留。
- `Two details worth knowing:`(:138):与 ch14 `Two details deserve attention.` 措辞异但均合法;不改(避免引入与镜像无对应的重写)。

## 二、技术读校

1. **mermaid 三块**:块 1 flowchart LR(:44)10 节点 id / 6 边行(A→B、B→B 自环、B→PA、S1→S2、S2→S3、S2-.->SX,链式 S1→S2→S3 计 2 op);块 2 sequenceDiagram(:76)6 participant(S/D/G/P/B/V)/ 14 箭头;块 3 flowchart TD(:148)8 方形节点 + 3 菱形判定 / 11 边。逐块骨架(节点 id + 边,标签剥离)与 `chapters/ch17-swarm.md` diff 为空;标签为英文但语义逐条对译抽查无误(TerminalFailed aborts / pipeline_input / enforce_dispatch_gates / gate_subtask_validators :593 / run_aggregate_validator :693 均与中文同位同义)。
2. **数字**:4,980 / 2,505 / 2,475 / 1:0.99 / 36 cases / 128 上限 / retry 3 轮 / schema version 1 / 1,261+395+275+229+115+111+119 文件行数表(:11-17)全部与中文镜像及 facts 表口径一致(数字集合双向 78=78,C1 已验,本轮改动未触碰任何数字)。
3. **章号**:Chapter 6/10(×5)/12/15/16/17 交叉引用 16 处与中文逐行同位(C1 第 4 项);标题 17.1-17.9 顺序无错位。

## 三、改动与复验

改动文件:仅 `book-en/src/part3/ch17.md`,7 处(A1-A3、B1-B4),全部为标点/体例/搭配级微修,未动任何事实、数字、引用、mermaid、代码块。

复验输出:

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch17-swarm.md book-en/src/part3/ch17.md
WARN: code block content differs (mermaid and comments excluded)
refs: 56 (equal sets: yes)
en words: 4249, bold 12, em dash 0
RESULT: 0 FAIL(s), 1 WARN(s)
(exit 0)

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

0 FAIL 达标;唯一 WARN 即 C1 已豁免的 CLI 帮助文本 4 行中文标签必译类(:130-134),本轮未触碰。bold 10→12(B3/B4 两处图注补粗,仍在 ≤15 内)。mdbook 零警告零错误。

## 四、判定

**通过。** 7 处微修已就地完成并复验全绿,可采回;无需 master 追加改动。

## 五、上报(超 C2 权限,只报不改)

- 无中文版错误需上报。中文镜像 `chapters/ch17-swarm.md` 的「为什么…。」句式(:62/:129)与全角冒号在中文语法内均正确,仅英文版需要问号化,已按镜像纪律只在英文侧处理。
- 观察项(不构成错误):英文版 Further reading 的 `URL, 说明` 逗号分隔格式在 ch15/ch16 间本就存在 `—` 与 `,` 两种写法(ch15 混用),建议后续统一全书时一并裁定,本章已按多数派 `,` 对齐。
