# Ch16 技术审查报告(C2 — techreview)

- **审查对象**:`chapters/ch16-fleet.md`(246 行,C1 产出拷贝入本工作树)
- **事实基准**:`assets/ch16-facts.md`;**源码只读基准**:octos main @ `9c157101`(2026-09-02,已现场核对 `git rev-parse`)
- **规范**:`specs/ch16-fleet.spec.md`
- **审查方式**:逐支柱对照源码原文(`sed`/`grep` 只读),重点核对检查项 1 的五个机制簇与全部关键行号引用
- **审查日期**:2026-09-03

## 0. 计数表

| 级别 | 数量 | 摘要 |
|---|---|---|
| Critical | **1** | sqlite_ledger 路径写成不存在的 `crates/octos-cli/src/autonomy/`,违反 spec「引用零失效」 |
| Major | **1** | 六张 redb 表定义行号区间 `store.rs:48-53` 错位(实际 46-51),与事实表同源错 |
| Minor | **4** | digest 默认预算行号 :52→:56;sqlite 头注释论证未核实;boot-resume 唤醒补口缺失;goal_grant/deny 易误读为 store 方法名 |
| 通过项 | 31 | 见 §5 验证通过清单 |

## 1. Critical(附源码证据)

### C-1 `sqlite_ledger.rs` 路径不存在,spec 完成条件「引用零失效」不通过

- **位置**:ch16-fleet.md:214(16.7 节首句)
- **原文**:「crate 里最大的文件不是 store,是 `crates/octos-cli/src/autonomy/sqlite_ledger.rs`(6,360 行……),`GoalLedger`(:13)落地于此。」
- **源码证据**:
  - `ls crates/octos-cli/src/autonomy/sqlite_ledger.rs` → **No such file or directory**(实测)
  - 实际文件在 `crates/octos-fleet/src/sqlite_ledger.rs`,6,360 行(`wc -l` 实测),`pub struct GoalLedger` 在 :13(`grep -n` 实测)
- **影响**:spec 测试 `review_ch16_refs_valid` 要求「每个路径存在」——此引用直接失败。且同段后半句已正确引用 `crates/octos-fleet/src/sqlite_ledger.rs:409-410`,同一段两个路径自相矛盾;「crate 里最大的文件」的说法也因错误路径与「两 crate 合计」的语境打架。
- **修复**:把首现路径改为 `crates/octos-fleet/src/sqlite_ledger.rs`。「crate 里最大的文件不是 store」随之成立(store.rs 5,015 < sqlite_ledger.rs 6,360)。

## 2. Major(附源码证据)

### M-1 六张表定义区间 `store.rs:48-53` 错位,实际 46-51

- **位置**:ch16-fleet.md:26(16.2 节首句):「全部定义在 `crates/octos-fleet/src/store.rs:48-53`」
- **源码证据**(`sed -n '40,56p' crates/octos-fleet/src/store.rs` 实测):
  - :43 `use redb::{...}`,:44 `use uuid::Uuid;`,:46 `FLEETS`,:47 `FLEET_CHILDREN`,:48 `ATTEMPTS`,:49 `PLANS`,:50 `DECISION_LOG`,:51 `OUTBOX`,:53 `DB_FILENAME`
- **影响**:区间 48-53 只覆盖六张表中的四张(48-51),把 `FLEETS`/`FLEET_CHILDREN` 排除在外,又把非表常量 `DB_FILENAME`(:53)圈了进来。spec「区间内确实含所述符号」打了擦边球(部分命中)。此错与事实表同源(事实表未记该区间,系行文时推算),修文字即可,不需回改事实表。
- **修复**:改为 `store.rs:46-51`。

## 3. Minor

1. **digest 默认 `max_chars` 行号漂移**(16.4 节,正文引 `digest.rs:52`)。实测 `grep -n 'max_chars: 4_000'` → **:56**(`Default` 实现内);:52 附近是 `DigestOptions` 字段区。事实表同样未记此行号,建议正文改 :56 或删行号只留默认值。
2. **sqlite vs redb 选型的「文件头三行注释」论证未核实**。16.7 节声称头三行注释给出「redb 单写者单进程 / SQLite WAL 多进程」理由;事实表只记录了首行注释(`//` 风格),未录三行全文。选型判据本身(按访问者切:内核六表单进程独占写→redb;goal 账本 keeper/worker/transition sync 多方读写→sqlite)与代码结构一致,判据成立;但「头三行」这一出处建议定稿前对 `sqlite_ledger.rs:1-3` 做一次目检,若注释实际是更长段落则改措辞。
3. **恢复协调的唤醒补口缺失**(16.4 节)。正文说 reconcile 后「活 fleet 的 child 回到 Ready 等待本次启动重发」,但源码明确:reconcile **不产生 outbox 事件**(`fleet_wake.rs:392-396` `enqueue_fleet_boot_resume_wakes` 的注释点名这一缺口:「NOTHING re-dispatches them……the fleet stalls forever」),靠 boot-resume 专用的稳定 dedupe key 唤醒补口。当前措辞不算错但把最有趣的一环(reconcile 静默 → boot-resume 唤醒)抹平了;建议补一句,同时天然回应「outbox 事件必达 vs 唤醒必持久」的对称性。附带:已核实的消费环细节(取消 fleet 的 ChildDone 直接 ack 不唤醒、fleet 消失直接 ack 防卡死,fleet_wake.rs:255-307)也未提,属可接受省略。
4. **`goal_grant` / `goal_deny` 的层级归属易误读**(16.4 图 16-3 边标注与 16.5 正文)。二者是 keeper 侧工具名;store 层对应的转移是 `set_task_grant` 的 Blocked→Ready(store.rs:1979 注释实测)与 `deny_escalation`(store.rs:2025)。图 16-3 其他边都标 store 方法行号,唯独这两条边标的是工具名,读者会去找不存在的 `store.goal_grant`。建议边标注补 `set_task_grant(1898)` 或在 16.5 首现处点明「keeper 工具,落到 store 是 set_task_grant/deny_escalation」。

## 4. 检查项逐条结论

### 4.1 机制描述正确性 — 通过(除上述引用缺陷)

| 机制簇 | 结论 | 关键证据(实测 @ 9c157101) |
|---|---|---|
| 事务记录三支柱 | ✅ 准确 | 六表 store.rs:46-51;`SCHEMA_VERSION=3` records.rs:33;`FleetBudget`:119、`FleetRecord`:145、`Lease`:250、`Attempt`:256、`DurablePlan`:313、`OutboxEvent`:524、`FleetEventKind`:545 全部命中;2→3 升版理由(records.rs:25-31:加枚举变体是破坏性变更,v2 二进制解 `"Blocked"` 报未知变体)与正文逐句一致 |
| CAS 三转移 | ✅ 准确 | `launch_child` :889(谓词:Ready :928-931、double-launch :932-939、终态围栏 `!fleet_is_live` :959-963、预算放行 :967-969;`AttemptStatus::Leased` :997、`Lease{owner_epoch}` :998);`mark_running` :1053(四段谓词 :1119-1124,generation 在 :1122);`complete_child` :1157(gen :1236、lease :1237,`gen_ok`/`lease_ok` 实测在 1235-1236 区);预算 `admits` records.rs:132 checked 加法逐字与正文代码块一致 |
| 值 vs 错误分离 | ✅ 准确 | `LaunchOutcome` store.rs:62(含 `RejectedFleetTerminal` #1973)、`CompleteOutcome::Superseded` :81、`MarkRunningOutcome::Superseded` :112;`Err` 只留基础设施故障(:1049 注释原文) |
| fleet_wake 消费环 | ✅ 准确 | `drain_fleet_outbox_once` fleet_wake.rs:235;`WakeCommit` :70(`Durable`/`NotDurable`);TTL 30s :56;claim→wake→durable→ack 顺序(:226-232 注释);`NotDurable` 不 ack 留待租约过期重投(:309-316);`StaleClaim` break 让新 owner 接管(:331-334)。「事件必达 vs 唤醒必持久」的对偶表述与代码语义一致 |
| outbox claim/ack | ✅ 准确 | `claim_next` store.rs:2547(最低序号未确认+claim 空闲或过期,盖 `claimed_by`/新 `claim_token`/`claim_expires_at`);`ack` :2603 出示 `(consumer, claim_token)`,不匹配 `StaleClaim`;事件四种 :545-550 |
| digest 恒定成本重入 | ✅ 准确 | 纯函数 `digest()` :175,不吃 store/LLM/时钟;`max_chars` 默认 4,000(:56,正文 :52 见 Minor-1);`Dropped` :126;`drift` :156;五分区(`DigestFinding`:65/`Overturn`:77/`StaleFinding`:89/`ClusterHint`:108/`PathCost`:116)+ 水位线;最新在前、尾部砍的排序理由(:170-174 注释) |
| sqlite vs redb 选型 | ✅ 判据成立 | 结构证据:goal 账本 `append_finding` sqlite_ledger.rs:1623、`list_findings_since` :2132、findings goal/task 双索引 :409-410(实测 `idx_findings_goal` :409、`idx_findings_task` :410)、`open` :222 / `open_with_busy_retry` :245 均命中;「头三行注释」出处见 Minor-2 |
| worker replay-safe 注册表 | ✅ 准确 | `ALLOWED` = `octos_fleet::BASE_TOOLS` closed_registry.rs:43;`build_fleet_worker_registry` :92 从 grant 出发先 `validate()`(:106-110);grant 四类型 grant.rs:76/127/151/359、`validate` :247、`minimal` :207 |
| 状态机与恢复 | ✅ 准确 | `reconcile` :2191:活 fleet 仅租约失效(外来 epoch 或过期,:2272-2275)回收;终态 fleet 无条件结算(#1973 注释 :2266-2271);`checked_sub` 下溢即报错(:2285-2296);活→Ready / 终态→Cancelled 永不复活(:2300-2308);`record_escalation` :1336 校验 generation :1409 |
| run_attempt / 池 | ✅ 准确 | `AttemptOutcome` worker.rs:146 五变体及 `Aborted` vs `RecordError` 的守卫语义(:156-168 注释);`run_attempt` :177;`PoolConfig` :58、`FleetWorkerPool` :109、`dispatch` :233;per-(fleet,task) preflight 锁 :118;worktree 三条件(FsGrant::Host + NetworkGrant::Full + `repo_git_write_supported`,pool.rs:269-284 注释 + :284 代码)与全信任推理一致 |

### 4.2 技术公平性与论证层数 — 通过

每支柱均有「为什么」层:加字段 vs 加枚举变体的通用判据(16.2)、redb 事务 vs 内存+日志的工程决策侧栏(16.3,三缺口论证成立且与 spec 要求的侧栏吻合)、checked 算术 vs 饱和算术、claim_token 围栏的具体竞态、永不复活 vs 复活的不变量推理(16.4)、封闭注册表「不是边界」的坦率澄清(16.5)、并发上限放池不放内核的职责切分(16.6)。无只述不证的段落。

### 4.3 跨章重复 — 通过

- Ch7(grant):仅列四类型行号 + 「语义与校验规则详见第 7 章,本章只消费它的结论」,约 3 行,合规;
- Ch12(supervisor):16.3 末一句 + 16.7 一句,合规;
- Ch18(GoalLedger):16.7 一段但内容是本章检查项明列的 sqlite/redb 选型判据与 busy-retry 工程细节,并两处显式「详见第 18 章」,属边界内。

### 4.4 结构与 mermaid — 通过

- 叙事线「记录模型→事务与 outbox→状态机与恢复→装配→执行→表层」与 spec「决策」段一致;
- 图 16-1(classDiagram)字段与 records.rs 实测一致(`claim_token`/`acked` 在 :539/:541、`reserved_tokens`、`generation` 等);
- 图 16-2(sequenceDiagram)与 `launch→mark_running→complete→claim/ack` 时序及「CAS 落败走值返回」一致;
- 图 16-3(stateDiagram)边与 CAS 方法对应正确,唯 `goal_grant`/`goal_deny` 两条边标注层级问题见 Minor-4;`Launching→Blocked` 与 `Running→Blocked` 两条边未逐一边核到 store 判词(escalation 在 attempt 运行中触发,Running 边证据充分;Launching 边来自池取消路径,低风险,建议 C1 顺手自证)。

### 4.5 pathfix 后引用风格一致性 — 基本通过

全文 `crates/...rs:NNN` 与 `(:NNN)` 缩写风格统一,`docs/FLEET-*.md` 均带行数;唯一不一致是 C-1 的错误路径。数字面全部复核:两 crate 13 文件 23,730 行、`fleet_wake.rs` 1,807 行、三份 docs 347/219/176 行、`eadee2ae`/`8fc66202` 锚点——与实测一致。

## 5. 验证通过清单(31 项)

records.rs 锚点 8 项(SCHEMA_VERSION/FleetBudget/FleetRecord/Lease/Attempt/DurablePlan/OutboxEvent/FleetEventKind);store.rs 方法锚点 12 项(add_child 503 / resolve_and_collect_ready 676 / cancel_fleet 838 / CAS 分区 880 / launch 889 / mark_running 1053 / complete 1157 / record_escalation 1336 / replan 1512 / deny_escalation 2025 / reconcile 2191 / claim_next 2547 / ack 2603 —— 计 13 项含 append_event 2518,合计并入 12+1);grant.rs 5 项(BASE_TOOLS 27 / 76 / 127 / 151 / 359 / validate 247 —— 计 6);worker 侧 6 项(ALLOWED 43 / build 92 / AttemptOutcome 146 / run_attempt 177 / PoolConfig 58 / dispatch 233);fleet_wake 4 项(70 / 56 / 235 / 消费顺序语义);数字面 4 项(行数合计 / fleet_wake 行数 / docs 行数 / 提交锚点);digest 6 项(175 / 156 / 126 / 五分区 / 水位线 / 排序理由);sqlite_ledger 5 项(13 / 222 / 245 / 1623 / 2132 / 双索引 409-410)。

## 6. 结论

**有条件可定稿。** 机制叙事三支柱、消费环、digest、选型判据、装配与池的描述全部经源码复核成立,公平性与跨章边界合规;唯一 Critical(C-1 路径错误)与唯一 Major(M-1 行号区间)均为两处字符级修补,不动叙事。C1 完成 C-1、M-1 两处替换并顺手处理 Minor-1(:52→:56)后即可定稿;Minor-2/3/4 建议但不阻塞。
