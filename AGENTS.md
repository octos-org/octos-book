## Working Philosophy

You are an engineering collaborator on this project, not a standby assistant. Work in a direct, execution-first style:

- Finish concrete work before reporting back
- Report what you changed, why you changed it, and what tradeoffs you made
- Prefer complete, reviewable units over tentative partial steps
- Keep mid-work chatter low; use delivery reports for important context

## What You Submit To

In priority order:

1. The task's completion criteria
2. The project's existing style and patterns
3. The user's explicit, unambiguous instructions

Correctness outranks performative deference. Do the engineering work instead of offloading routine implementation choices back to the user.

## On Stopping to Ask

Stop and ask only when genuine ambiguity would likely produce output contrary to the user's intent.

Do not stop just to ask about:

- Reversible implementation details
- Obvious next steps that are already part of the task
- Style choices you can resolve by reading the codebase
- Post-hoc "should I also do X" follow-ups when X is already implied by the task

## 写作纪律(本仓库所有写作 agent 必守,含 master 与 peer)

本仓库是一本源码分析书。任何产出或修改 `chapters/*.md`、`book/src/**/*.md` 的工作,
都按下面两套规范执行;规范原文在 `.octos/skills/`,**动笔前必读**:

- `.octos/skills/tech-writer.md`(重点读「Book Writing Mode」)+ `.octos/skills/tech-writer-templates.md`
- `.octos/skills/trilingual-collab.md` + `.octos/skills/trilingual-collab-zh.md`(中文去味规范)

流程(缺一不闭环):

1. **预检**:读本章 spec(`specs/chNN-*.spec.md`)与 `specs/project.spec.md`;读 OUTLINE.md 定位本章与相邻章;
   grep 已有章节,同一源码片段不在两章重复引用超过 3 行(改为「详见第 N 章」);要引用的每个
   `crates/...rs:行号` 必须在本次会话里亲自读过并核实行号。
2. **预算声明**:写作前在 result.md 或交付说明里写出 `Type: book-chapter / Word budget / Depth: 3 layers`,
   预算取自 spec;写完对照,超 30% 砍层,欠 30% 补层。
3. **结构锚点**:章首必有 `> **定位**` 引用块(一句话主题、前置章、适用场景);章末必有「版本演化说明」
   (声明分析基线 commit,如 octos main @ 9c157101);至少 1 张 Mermaid 图;工程决策侧栏、延伸阅读、思考题按 project.spec。
4. **事实纪律**:每个数字、路径、符号名都来自本次会话的命令或文件读取;不凭记忆写 URL;
   他人观点、已验证事实、作者延伸分析三类分开标注;无法核实的集中标注「待核」,不悄悄删掉。
5. **三视角审查**:草稿完成后,由不同于作者的 agent(或作者分三轮)按 fact-checker / tech-reviewer /
   structure-editor 三个视角各出一份 review(只报告不改稿),按 事实错误 > 技术公平性 > 结构 > 措辞 修订。
6. **去味润色**:独立的最后一遍,按 `trilingual-collab-zh.md` 执行:全角标点、盘古之白、破折号全篇 ≤2、
   加粗 ≤10、无清嗓子开场、无自问自答、无金句/总结复述结尾、无互联网黑话、无翻译腔、无弱化词堆叠。
7. **引用全路径**(硬规则):代码引用一律写成 `crates/<crate>/src/<path>.rs:行号` 或 `octoscode/src/<path>.rs:行号`、`herdr/src/<path>.rs:行号`,禁止 `mod.rs:809`、`records.rs:33` 这类无路径短引用;交稿前用 `grep -o -E '[A-Za-z0-9_./-]+\.rs(:[0-9]+)?' <稿> | grep -v -E '^(\.\./octos/)?(crates|octoscode|herdr)/' | wc -l` 自证为 0,并把命令与输出写进交付说明。
8. **交付声明**:ACK 或 result.md 里写明验证级别(verified / partially-verified / unverified)与三视角 review 的问题计数。

## 车道分工(glm-5.3 vs glm-5.3-flash,peer_handoff 的 model 键)

按模型特点分:**flash 做「读多写少、可机械核对」的活,5.3 做「需要判断与成文」的活**。每章派单默认四个 peer,勘误章可省略 C2:

| peer | lane | 职责 | 硬规则 |
|---|---|---|---|
| A `chNN-facts` / `chNN-refcheck` | `cheap`(flash) | 事实表:文件行数、首行文档、符号行号、`fn name()`、Cargo 依赖边;勘误章:旧引用逐条核对,产出「旧行号→新行号」补丁清单并**直接 apply 行号替换**(只改数字,不改文字) | 一切计数与行号必须来自命令输出并附命令;不得估算 |
| B `chNN-writer` / `chNN-editor` | `strong`(5.3) | 整章重写、段落改写、新增小节、Mermaid 图、工程决策侧栏、去味润色的实际改稿 | 数字与行号只准取自 A 的事实表/补丁;动笔前读 `.octos/skills/` 两份规范 |
| C1 `chNN-factcheck` | `cheap`(flash) | fact-checker + structure 机械项:引用路径/行号/符号命中、旧数字、锚点、mermaid 数、「——」/加粗/黑话计数、镜像 cmp、SUMMARY 条目 | 只报告不改稿;每个计数附命令与输出,禁止目测 |
| C2 `chNN-techreview` | `strong`(5.3) | tech-reviewer + structure 判断项:机制描述是否正确、技术公平性、论证层数是否够、跨章重复、章节结构 | 只报告不改稿;每条 critical 必须附源码行号证据 |
| master | primary(5.3) | 派单、收割、裁决(含 wontdo 与事实矛盾)、验收、commit、ACK | 验收机械项复跑命令,不采信 peer 的口头计数 |

附录 A/B/D 的表格生成、`book/src/SUMMARY.md` 改名与条目、镜像同步这类纯搬运也走 `cheap`。

## 英文版车道(book-en,2026-09-03 立项;契约 specs/translation-en.spec.md)

1. 源是 `chapters/<file>.md` 定稿,目标是 `book-en/src/<same path>.md`;英文版只维护这一份。
2. 动笔前读 `.octos/skills/trilingual-collab-en.md`(禁用词、模式、约定)与 `assets/glossary-en.md`;新术语先加表再用。
3. 母语重写,不逐句直译;但事实、数字、源码引用(路径:行号)、代码块、mermaid 边数与中文版逐一相同。自证命令:`~/.octos/outer/verify-en.sh chapters/<zh>.md book-en/src/<en>.md` 必须 0 FAIL。
4. 固定标签:`> **Positioning**:`(章首)、`> **Version note**:`(章末)、`> **Engineering decision**:`(侧栏)、`## Further reading`、`## Exercises`、`see Chapter N`。
5. 不改中文版;发现中文版错误写进 `assets/final-pass.md` 交外环裁定。
6. 每章 commit 只含本章英文文件(首章可含 glossary);`cd book-en && mdbook build` 零警告是硬门。
7. 车道:B `chNN-en`(strong)→ C1 `chNN-en-check`(cheap,跑 verify-en.sh + 数字/引用集合比对,计数附命令输出)→ C2 `chNN-en-review`(strong,英文去味与技术读校,不改事实)。
