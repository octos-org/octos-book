# Ch16 factcheck 报告(chapters/ch16-fleet.md)

- **审查员**:ch16-factcheck(C1);**日期**:2026-09-03
- **基准**:稿 = master 3f91f38 拷贝(`cmp` 镜像一致);源 = /Users/zhangalex/Work/Projects/FW/octos @ `9c1571016e5ea86955b4b3486c04f0359dfff339`(实测 HEAD 即此);事实基准 = assets/ch16-facts.md
- **审查方式**:只读核对,不改稿;全部锚点逐条 `sed -n` 对源

## 汇总(文首)

| 检查项 | 结果 |
|---|---|
| 1) 引用路径/锚点 | 40 处全路径 `:line` 锚点 + 14 处文件路径;**37/40 锚点精确**,1 偏 1 行、1 指向 impl 首行、1 区间错;**1 条文件路径不存在**(P1)。自证命令泄漏 **0** |
| 2) 数字 | 9/9 组全对:16,888 / 6,842 / 23,730 / SCHEMA_VERSION=3 / 租约 30s / tick 3s / 64 条 / docs 347·219·176 / 提交锚点 eadee2ae·8fc66202;13 个文件行数逐一相符 |
| 3) 机械项 | mermaid 3 ✅;镜像 cmp 0 差异 ✅;「——」0(≤2)✅;加粗 10 处(≤15)✅;版本演化说明在位 ✅;黑话均有首现解释 ✅ |
| 4) 字数/占比 | 去代码块汉字 **5,166**(= master 实测,≥5,000 ✅;含代码块 5,238);**16.2% 无自然分母可复现**(全书 5.0% / part3 12.4%,同 ch15 悬案) |
| 5) 自证命令 | `grep -o -E '[A-Za-z0-9_./-]+\.rs(:[0-9]+)?' 稿 \| grep -v -E '^(\.\./octos/)?(crates\|octoscode\|herdr)/' \| wc -l` → **0** |
| 6) SUMMARY | book/src/SUMMARY.md:34 第 16 章条目在位 ✅ |

**是否可定稿:可定稿(有条件)**——先修 P1-1 一处路径(一行);P2 两处为一行内修正,建议顺手改。P3 不阻塞。

## 分级发现

### P1(阻断定稿,须修)

| # | 位置 | 问题 | 证据 |
|---|---|---|---|
| P1-1 | 稿 :214(16.7) | sqlite_ledger.rs 路径错误:写为 `crates/octos-cli/src/autonomy/sqlite_ledger.rs`,该文件**不存在**;实际在 `crates/octos-fleet/src/sqlite_ledger.rs`(6,360 行)。同段后续 6 个行号锚点(:13、:222、:245、:409-410、:1623、:2132)对 octos-fleet 副本**全部精确命中**,且「crate 里最大的文件不是 store」「为什么一份代码里同时有 redb 和 sqlite」只在 octos-fleet 语境下自洽,故判定为路径前缀笔误 | `find … -name sqlite_ledger.rs` → 仅 `./crates/octos-fleet/src/sqlite_ledger.rs`;`crates/octos-cli/src/autonomy/` 下无此文件 |

### P2(应修,一行改动)

| # | 位置 | 问题 | 证据 |
|---|---|---|---|
| P2-1 | 稿 :152 | `FleetStatus` 枚举漏列 `Cancelled`:稿列 4 个(Active/Draining/Complete/Failed),源实际 **5** 个变体(records.rs:41-47 含 `Cancelled`) | `sed -n '41,47p' records.rs` |
| P2-2 | 稿 :26 | 「六张 redb 表…全部定义在 store.rs:48-53」区间错:表常量实际在 **46-51**(FLEETS:46、FLEET_CHILDREN:47、ATTEMPTS:48、PLANS:49、DECISION_LOG:50、OUTBOX:51);48-53 只含后 4 表且混入 DB_FILENAME(:53) | `grep -n 'TableDefinition::new' store.rs` |

### P3(不阻塞,酌情)

| # | 位置 | 问题 |
|---|---|---|
| P3-1 | 稿 :115 | 租约锚点 `:56` 应为 `:57`:`FLEET_WAKE_TTL_MS = 30_000` 在 fleet_wake.rs:57,:56 是其 doc 注释尾行。brief 预期即 57 |
| P3-2 | 稿 :162(图 16-3) | `Launching → Blocked: record_escalation(1336)` 这条边不可达:record_escalation 谓词要求 `attempt.status == Running`(store.rs:1407-1410),而 child Launching ⟺ attempt Leased(同一事务置位),故只有 Running → Blocked 真实存在 |
| P3-3 | 字数占比 | 16.2% 需分母 ≈31,900 汉字,无自然分母可得(全书去代码块 103,911 → 5.0%;part3 41,638 → 12.4%)。与 ch15-factcheck 同一 spec 口径悬案,建议报告口径改注实测值 |
| INFO | 稿 :180 | `max_chars 默认 4,000(digest.rs:52)`:52 是 `impl Default` 的 `fn default() -> Self {` 首行,字面量 `4_000` 在 :56。语义命中 Default 定义,brief 预期即 52,可接受 |

## 检查清单逐项计数

### 1) 引用路径/越界/符号(重点全覆盖)

- 自证命令输出 **0**(54 处 `.rs` 引用全部落在 `crates/` 下)。
- 40 处全路径 `:line` 锚点逐一对照 9c157101:
  - **fleet_wake 消费环**::235 `drain_fleet_outbox_once` ✅、:63 `FLEET_WAKE_MAX_BATCH = 64` ✅、:70 `enum WakeCommit` ✅、:343 `spawn_fleet_outbox_consumer` ✅、:56 ⚠️(P3-1);
  - **digest**::126 `pub struct Dropped` ✅、:156 `fn drift(` ✅、:175 `pub fn digest(` ✅、:52(INFO);
  - **sqlite_ledger open**::222 `pub fn open(` ✅、:245 `open_with_busy_retry` ✅(3 次重试 + 1s 超时,ATTEMPTS=3 实测);:13 `GoalLedger` ✅、:409/:410 findings 双索引 ✅、:1623 `append_finding` ✅、:2132 `list_findings_since` ✅;文件 6,360 行 ✅;
  - **records 六锚点**::33 `SCHEMA_VERSION=3` ✅、:119 `FleetBudget` ✅、:145 `FleetRecord` ✅(:152 keeper-wake 注释 ✅)、:250 `Lease` ✅、:256 `Attempt` ✅、:313 `DurablePlan` ✅;附::25 PR B 注释 ✅、:41/:64/:94 枚举 ✅、:132 `admits` ✅、:447 `Finding` ✅、:524 `OutboxEvent`/:545 `FleetEventKind` ✅、:571 高版本守卫 ✅、VersionProbe:560 ✅;
  - **store 12 符号**:ReconcileReport:160 ✅、create_fleet:244 ✅、add_child:503 ✅、resolve_and_collect_ready:676 ✅、cancel_fleet:838 ✅、launch_child:889 ✅、mark_running:1053 ✅、complete_child:1157 ✅、record_escalation:1336 ✅、replan:1512 ✅、deny_escalation:2025 ✅、reconcile:2191 ✅;附:模块文档 :6-8 ✅、CAS 分区 :880 ✅、Leased:997/Lease:998 ✅、generation 谓词 :1122/:1236/:1237/:1409/:1410 ✅、Superseded :59/:75/:102 ✅、deny-grant 互补注释 :2094 ✅、append_event:2518/claim_next:2547/ack:2603 ✅、decisions :2648/:2697 ✅、outbox in-txn 注释 :2806 ✅、StaleClaim ✅、io_gate/spawn_blocking ✅;
  - **worker 模块**:closed_registry :43/:92 ✅、worker :67/:146(五变体逐一相符)/:177 ✅、escalate :34/:37/:42 ✅、pool :58/:98/:109/:142/:197/:204/:233 ✅、grant :27/:76/:127/:151/:247/:359 ✅、fleet.rs :190/:210/:300/:324/:375/:402/:542/:583/:595 ✅。
- **精度:40 锚点中 37 精确 + 1 语义命中(:52)+ 1 偏 1 行(:56)+ 1 区间错(:48-53);bare 路径 14 条中 1 条不存在(P1-1)。**

### 2) 数字

16,888 ✅(7 文件求和相符)、6,842 ✅(6 文件)、合计 23,730 ✅;SCHEMA_VERSION=3 ✅(records.rs:33);租约 30s ✅(`FLEET_WAKE_TTL_MS: u64 = 30_000`)、tick 3s ✅(`FLEET_WAKE_INTERVAL_SECS = 3`)、单 tick 64 条 ✅(`FLEET_WAKE_MAX_BATCH = 64`);max_chars 4,000 ✅、cluster_min_paths=2 ✅;docs 347/219/176 ✅;提交锚点 `eadee2ae`(#1875 WorkerGrant)、`8fc66202`(#1881 worktree)均 main 可达 ✅;「四分之一强」6,360/23,730=26.8% ✅;`one-write-transaction`、从 octos-swarm 逐字抬升(spec:25 「LIFTED verbatim」)、ADR「objective survives, progress rots」(ADR:13-14)✅。

### 3) 机械项

mermaid 3(类图/时序/状态)✅;镜像 `cmp` 0 差异 ✅;「——」0 ✅;加粗 10 处 ✅;「版本演化说明」在位(:245-246,含 9c157101 与日期)✅;术语 CAS/outbox/attempt/claim-ack/水位线均首现解释 ✅。

### 4) 字数与占比

去代码块 CJK **5,166**(与 brief「master 实测 5,166」完全一致;含代码块 5,238);占比 16.2% 不可复现(P3-3)。

### 5) 自证命令

```
$ grep -o -E '[A-Za-z0-9_./-]+\.rs(:[0-9]+)?' chapters/ch16-fleet.md \
  | grep -v -E '^(\.\./octos/)?(crates|octoscode|herdr)/' | wc -l
0
```

### 6) SUMMARY

`book/src/SUMMARY.md:34`:`- [第 16 章:Fleet:可恢复的计划执行内核](./part3/ch16.md)` ✅;`book/src/part3/ch16.md` 与章稿 `cmp` 全等。

## 结论

**是否可定稿:可(条件:先修 P1-1 路径一处)。** P1-1 为纯路径前缀笔误,行号证据全部自洽;P2-1/P2-2 是一行内补列/改区间;P3 三项不阻塞,其中占比口径建议与 ch15 一并上报 spec 方。
