# 第 10 章事实表 — Harness 三支柱(octos-book v2)

- **源码基准 commit**: `9c157101`(main 分支,只读实测)
- **统计日期**: 2026-09-03
- **采集方式**: master 直跑降级模式(peer 会话通道僵死,turns=0 两代;黑板批注在案)
- 源码仓库: `/Users/zhangalex/Work/Projects/FW/octos`(只读)

---

## 1. 六模块行数与首行文档

| 模块 | 行数 | 首行 `//!` 文档 | 命令 |
|---|---|---|---|
| validators.rs | 2,772 | `//! Declarative validator runner (harness M4.3).` | `wc -l crates/octos-agent/src/validators.rs` |
| harness_events.rs | 2,789 | `//! Structured harness event ABI and local sink transport.` | 同上 |
| abi_schema.rs | 349 | `//! Harness ABI schema versioning.` | 同上 |
| workspace_policy.rs | 3,165 | (无 `//!`,首行 `use std::collections::BTreeMap;`) | 同上 |
| harness_errors.rs | 745 | `//! Structured harness error taxonomy (M6.1, issue #488).` | 同上 |
| hooks.rs | 2,856 | `//! Hook/lifecycle system for running shell commands at agent lifecycle points.` | 同上 |

合计 12,676 行。

## 2. 关键类型行号

`grep -n 'pub struct\|pub enum\|pub trait' <file>` 实测(每模块前 6 个):

- **validators.rs**: ValidatorPhase(枚举):105、ValidatorStatus(枚举):131、ValidatorInvocation:167、ValidatorOutcome:236、ValidatorLedger:298、trait ValidatorToolDispatcher:367
- **harness_events.rs**: HarnessEventError:75、HarnessEventSinkContext:88、HarnessCredentialRotationSink:336、HarnessEvent:360、HarnessEventPayload(枚举):368、HarnessProgressEvent:461
- **abi_schema.rs**: UnsupportedSchemaVersionError:135(该文件仅此主类型;schema 版本化常量与函数见源文件)
- **workspace_policy.rs**: WorkspacePolicy:22、CompactionPolicy:51、CompactionSummarizerKind(枚举):104、ValidationPolicy:115、Validator:143、Required(枚举):198
- **harness_errors.rs**: RecoveryHint(枚举):47、HarnessError(枚举):93、HarnessErrorEvent:166
- **hooks.rs**: HookContext:24、HookEvent(枚举):32、HookConfig:77、HookPayload:123、trait HookPayloadEnricher:671、HookResult(枚举):679

## 3. 四个 harness-starter 目录

`ls crates/app-skills/ | grep harness` → audio/coding/generic/report 四个。每个目录结构一致:
`Cargo.toml manifest.json SKILL.md src tests workspace-policy.toml`

(命令:`for d in crates/app-skills/harness-starter-*; do ls $d; done`)

## 4. 测试文件与用例数

`ls crates/octos-agent/tests/ | grep -E 'harness|validator|abi'`:

| 测试文件 | 用例数(`grep -c '#\[test\]\|#\[tokio::test\]'`) |
|---|---|
| harness_errors.rs | 18 |
| abi_compat.rs | 13 |
| validator_runner.rs | 17 |

(注:黑板第 11 条称「四个测试文件」,实测 harness/validator/abi 相关为以上 3 个 + slides_validator_project_scope.rs;若 spec 另有所指以 spec 为准,写作前需核对 spec 决策段。)

## 5. docs 文档清单

`ls docs/ | grep OCTOS_HARNESS` → 10 个:
OCTOS_HARNESS_ABI_VERSIONING / AUDIT_M6_M9_2026-04-30 / DEVELOPER_GUIDE / DEVELOPER_INTERFACE / ENGINEERING_REQUIREMENTS_M6_M9 / M4_1A_LIVE_GATE / M4_WORKSTREAMS_2026-04-21 / M5_CODING_RUNNER_CONTRACT / MASTER_PLAN / SKILL_COMPAT(均 .md)

## 6. 与既有事实表的交叉引用

- harness_errors.rs 三类型(RecoveryHint:47 / HarnessError:93 / HarnessErrorEvent:166)与 `assets/ch05-facts.md` §harness_errors 一致(Ch5 已用)。
- WorkerGrant 等 grant 类型见 `assets/ch07-facts.md`(Ch7 事实表)。
