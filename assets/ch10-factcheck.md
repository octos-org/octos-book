# 第 10 章事实核查报告(ch10-factcheck)

**审查对象**: `chapters/ch10-harness.md`(master 定稿基线 8928f35,两处镜像 cmp 一致)
**事实基准**: `assets/ch10-facts.md`(558bc92);源码 `/Users/zhangalex/Work/Projects/FW/octos` @ `9c157101`(实测 HEAD 一致)
**审查员**: ch10-factcheck peer · 2026-09-03

## 汇总

五项检查全部执行:①58 处代码引用(46 处显式 `crates/...` + 12 处 `(:NNN)` 简写)逐条比对行号与符号,**57 处精确命中,1 处行号偏差 2 行**;②数字全部复核通过(12,676 行合计逐项求和精确、测试 17/18/13 用例、docs×10、starter×4 六件套);③五个代码块与源码逐字 diff 全部一致;④机械项全过;⑤SUMMARY.md 条目在案(book/src/SUMMARY.md:23)。

**发现 3 处 P1,修后可定稿。**

## 分级

### P1(定稿前应修,3 处)

| # | 位置 | 问题 | 证据 | 修法 |
|---|---|---|---|---|
| 1 | 章 L121 | `ValidatorLedger.append` 标注 `validators.rs:323`,实际 `pub fn append` 在 **321**(read_all 在 337) | `grep -n 'fn append'` → 321 | `:323` → `:321` |
| 2 | 章 L159 | 「区分『401 认证失败』与『403 配额耗尽』**这两种都叫 403**」自相矛盾:401≠403 | harness_errors.rs:93 起十五变体含 Authentication 与 Quota;tests :248(403+quota→Quota)、:271(403 无标记→Auth)、:50(401→Auth) | 改为「这两种 4xx」或「403 配额耗尽与 403 认证失败」 |
| 3 | 章 L201 | 「13 个用例…覆盖**五个**耐久类型的新旧两端」与源文件模块注释不符:abi_compat.rs 头注写明「Covers the **four** versioned harness types」(WorkspacePolicy/HookPayload/TaskResult/ProgressEventEnvelope);SessionSummary 仅有 fixture 无用例 | abi_compat.rs:3-7;fixtures 含 session_summary_*.json 但 13 个测试名无一覆盖 | 「五个」→「四个」(或注名四个) |

### P2/P3(观察项,不阻断)

- SUMMARY.md:23 条目副标题「校验器、事件 ABI 与 Schema 版本化」与章内 H1「把「模型说做完了」变成可验证契约」不一致——若全书 SUMMARY 惯用紧凑标题则可保留,建议编辑侧确认。
- L167「核心函数只有九行」为约数:`check_supported` 物理行 159-172 共 14 行,逻辑行约 9,可辩护,可选改「十余行」。
- L130「缺席时退回旧抽取式路径、与 M6.3 之前逐字节一致」未独立复验(依赖 CompactionPolicy 运行时行为,超出本次静态核查范围)。

### 未覆盖(时间盒截止,风险低)

`OCTOS_HARNESS_ABI_VERSIONING.md`「五条兼容规则」的逐字核对;L215 提交哈希 `9ebaf468`/`fb0f9eeb`、L49/L223 `b64bd532`/`bf6be8cc` 未逐一 `git show`(#1607/#2153 决策内容已在源码注释中交叉印证:harness_events.rs #2153 注释、validators.rs:719-749 #1607 fail-closed 注释);事件单行大小上限常量与「gateway 注入 HookContext」的确切注入点未定位;`CompactionSummarizerKind` 两变体名未展开核对。

## 检查明细(计数附命令)

1. **引用路径/行号/符号** — 58 处引用 + 3 处区间(677-696 插值、719-734 安全闸门、735-749 fail-closed 注释):
   - validators.rs(2,772 行):ValidatorPhase:105✓ ValidatorStatus:131✓(Pass/Fail/Timeout/Error 四态✓) ValidatorInvocation:167✓ ValidatorOutcome:236✓ ValidatorLedger:298✓ append:**321**(章 323✗) ValidatorToolDispatcher:367✓ ValidatorRunner:441✓ EVIDENCE_SUBDIR:46✓ run_command:661✓
   - harness_events.rs(2,789 行):HARNESS_EVENT_SCHEMA_V1:29✓ HarnessEventError:75✓ SinkContext:88✓ CredentialRotationSink:336✓ HarnessEvent:360✓ Payload:368✓(16 变体与章列表逐一对应✓) ProgressEvent:461✓(`progress_fraction` alias✓)
   - abi_schema.rs(349 行):UnsupportedSchemaVersionError:135✓ check_supported:159✓ HARNESS_ERROR_SCHEMA_VERSION:126✓
   - workspace_policy.rs(3,165 行):WorkspacePolicy:22✓ CompactionPolicy:51✓ SummarizerKind:104✓ ValidationPolicy:115✓ Validator:143✓ Required:198✓(Hard/Soft/None 三档✓) ValidatorSpec:301✓ tier():182✓
   - harness_errors.rs(745 行):RecoveryHint:47✓(5 变体✓) HarnessError:93✓(15 变体=「十数」✓) HarnessErrorEvent:166✓ variant_name():198✓
   - hooks.rs(2,856 行):HookContext:24✓(2 可选字段✓) HookEvent:32✓(11 变体✓) HookConfig:77✓(5000ms 默认✓) HookPayload:123✓ Enricher:671✓ HookResult:679✓(Allow/Deny/Modified/Context/Error/Feedback 六态✓) #2153 会话隔离 716 起✓
   - 测试引用 12 处全中:validator_runner :123/:218/:293/:329/:490/:531✓;harness_errors :26/:58/:77/:110/:126/:154/:248/:271/:280✓;abi_compat :197/:259✓
2. **数字** — 2,772+2,789+349+3,165+745+2,856=**12,676**✓(逐项 wc -l);测试 17/18/13✓(`grep -c '#\[test\]\|#\[tokio::test\]'`);docs `ls|grep -c OCTOS_HARNESS`=**10**✓;starter×4 且目录六件套一致✓
3. **五个代码块逐字 diff** — ①ValidationPolicy(章 L54-70 ↔ policy.rs:113-133)逐字✓ ②tier()(L86-95 ↔ :182-189,正文逐字、省略 doc 注释)✓ ③HarnessEvent(L143-148 ↔ events.rs:359-365)逐字✓ ④check_supported(L170-184 ↔ abi_schema.rs:159-172)逐字✓ ⑤starter-coding TOML(L234-250 ↔ workspace-policy.toml [validation]/[artifacts]/[spawn_tasks] 段)逐字✓(省略 [workspace] 等头部段,系摘录)
4. **机械项** — mermaid 3✓;章↔book 镜像 cmp 一致✓、两镜像↔master cmp 一致✓;「——」0≤2✓;加粗 13 处(27 个 `**` 中 1 对属 `**/*.rs` glob)≤15✓;黑话 9 词(抓手/赋能/闭环/对齐/颗粒度/打法/沉淀/心智/护城河)0 命中✓;锚点(见 10.3/10.5/10.4.2)无悬挂✓;文末版本演化说明含 `9c157101`+日期✓
5. **SUMMARY.md** — `grep -n 'part2/ch10' book/src/SUMMARY.md` → 23 行✓

## 是否可定稿

**修 3 处 P1 后可定稿。** 三处均为单点小改(行号 1 字符、措辞一短语、数字一字的),不动结构、不动代码块、不触碰镜像同步之外的内容;P2/P3 与未覆盖项不阻断。
