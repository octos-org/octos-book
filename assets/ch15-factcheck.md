# Ch15 Factcheck 报告(ch15-production.md,基线 master 6ce294c)

- 审查对象:`chapters/ch15-production.md`(327 行,已拷贝 master 定稿,`book/src/part3/ch15.md` 镜像 `cmp` 逐字节一致)
- 事实基准:`assets/ch15-facts.md`(c450666);源码只读复核 `/Users/zhangalex/Work/Projects/FW/octos @ 9c157101`(live `git log -1` = `9c157101 9c1571016e5e... 2026-09-02 19:37:40 +0800`,与事实表一致)
- 方法:全部 `*.rs:行号` 引用逐条 `sed -n` 命中验证;规模数字全部 `wc -l` live 重测;机械项 grep 计数

## 汇总

| # | 检查项 | 结果 | 计数/证据 |
|---|---|---|---|
| 1 | 引用路径/越界/符号 | ✅ 21 处精确行号引用全部命中,0 越界 | 见 §A 逐条清单 |
| 2 | 数字 | ✅ 5/5 项 live 复现一致 | store 2,664 / services 3,223 / diagnostics 2,243 / tenancy 全词 2,261 / 端口段 6001-6999 |
| 3 | 机械项 | ✅ | mermaid 3;—— 1(≤2);加粗 10(≤15);锚点 15.1–15.6+延伸阅读+思考题完整;黑话 0;版本演化节在位;镜像 cmp 一致 |
| 4 | 字数/占比 | ⚠️ 字数 ✅,占比 ⚠️ | 实测 5,160(CJK、去代码块)与 master 完全一致;**16.2% 无法用任何标准分母复现**(全书 5.9% / part3 19.7% / part2+3 8.6%),疑为 spec 侧另有所指 |
| 5 | SUMMARY/旧文件 | ✅ | SUMMARY 第 33 行「第 15 章:生产化…」条目在位;`chapters/` 仅 ch14-runtime-modes.md,无 ch14-production.md |

**结论(是否可定稿):修 2 处 P1 后可定稿。** 全部事实、数字、行号、规模统计与 9c157101 实测一致;唯一实质问题是章号改 14→15 后两处「第 13 章(运行模式)」残留引用未同步为第 14 章(SUMMARY 权威:第 13 章=octos-pipeline,第 14 章=运行模式与配置体系)。

## 分级

### P1(定稿前必须修,2 处)
1. **L3(定位块)**「前置依赖:第 13 章(运行模式)」→ 应为**第 14 章**。SUMMARY L31-32:第 13 章=octos-pipeline,第 14 章=运行模式与配置体系。
2. **L298(§15.5 边界)**「运行模式与配置体系见第 13 章」→ 应为**第 14 章**(同上;同句中「第 7 章=安全」「第 10 章=Harness」「第 1 章 26 crate」均核对无误)。

### P2(建议修,1 处)
3. **L327(版本演化注)**「认证三流与 Hooks 详见第 7 章与第 10 章」:Hooks→第 10 章 ✅(ch10 载 hooks.rs 2,856 行);但**认证三流在第 7 章找不到载体**——全书 `grep PKCE|device code|paste-token|OAuth|auth.json` 仅 ch15 自身命中,ch07(安全纵深)零命中。疑似旧稿残留,建议改为「详见第 14 章」或删除「第 7 章」指向(L9 的表述「分别在旧章位置已有覆盖」同样受此影响,但 L9 未点名章节,可不动)。

### P3(可选打磨,3 处)
4. **§15.4.5**「`Updater::new` 支持 `GITHUB_TOKEN` 环境变量鉴权(:40-48)」:doc 注释与签名在 :40-48,但 env 实际读取在 **:49**(`github_token.or_else(|| std::env::var("GITHUB_TOKEN").ok())`),建议区间写 :40-49。
5. **占比 16.2% 无分母可复现**(见汇总#4)。5,160 字数本身精确无误;请 spec 方提供 16.2% 的分母定义,否则建议报告口径改为「全书 5.9%」。
6. **operator summary 端点未给引用**:§15.4.1 论述多源聚合但未引 `admin.rs:2021`(handler doc `/// GET /api/admin/operator/summary`)/`:2046`(`pm.all_statuses()` 收集)——两行均真实存在且语义吻合(brief 列为「重点补写段新引用」),建议补引;属增强而非错误。

## §A 引用逐条核对(命令:`cd octos && sed -n '<range>p' <file>`,全部命中)

| 章内引用 | 源码实测 |
|---|---|
| admin_token_store.rs:14-21 AdminTokenRecord 四字段 | ✅ salt/hash/created_at/created_by,与章内 rust 代码块逐行一致 |
| admin_token_store.rs:39-45 verify | ✅ salt 重建 hash → `constant_time_eq` |
| admin_token_store.rs:96-104 0o600 | ✅ tmp+rename 后 `Permissions::from_mode(0o600)` |
| admin_token_store.rs:182 测试断言 0o600 | ✅ L180-184 `assert_eq!(mode, 0o600)`,文件 184 行确为尾部测试 |
| usage_ledger.rs:42/:52-66/:323 | ✅ UsageEvent / cache_read 注释「full prompt = input + cache_read」/ PersistentUsageLedger |
| auth/store.rs:59-71 | ✅ auth.json 加固注释(0644→0600) |
| router.rs:1124-1233 常量时间比较 | ✅ `fn constant_time_eq` @1124,调用点 1221/1233 在区间内 |
| session_actor.rs:1-3/:1-4 | ✅ 「per-session tokio task…Replaces spawn-per-message…set_context() race」原文吻合 |
| profile_factory.rs:1-4 | ✅ dedicated ActorFactory(LLM stack/tool registry/skills/system prompt) |
| session_scope.rs:46-68 | ✅ 多租户 profile 目录/无条件拒绝/solo 无租户边界,全在区间 |
| profiles.rs:16/:2048/:2092 附近/:2403-2450/:360-407 | ✅ MAX_SUB_ACCOUNTS_PER_PARENT=10 / create_sub_account / `..Default::default()`(llm=None)/ resolve_effective_profile + env_vars 合并(2444-2448 原文)/ skills layer 语义 |
| tenant.rs:14-15/:23/:82/:185-194/:197/:203/:209/:219/:233/:255-270/:270-310/:29-30 | ✅ 6001/6999 常量、TenantConfig、TenantStore、next_ssh_port、四个 find_*、validate_tenant_id、render_frpc_config 七占位符、md5(tunnel_token+timestamp) 注释、测试组 |
| spec.rs:7-9 current_version 传入 | ✅ ADR「Traps」原文;:3-5 ProductSpec 引文为忠实节选 |
| metrics.rs:18/:29-34/:106-139/:139-193/:161-178/:929/:937/:947 | ✅ 全命中;`scope == "gateway"` @160、running/configuration_error 分支原文吻合 |
| events_harness.rs(183 行) | ✅ 307 重定向史注释 L13-14、kinds 过滤、user_auth_middleware |
| ui_protocol.rs:113/:1630/:1658-1700 | ✅ harness.task_control.v1 常量、first_server_slice、for_negotiated_features 门控 |
| monitor.rs:120/:159/:164/:357/:390 + health_interval/max_restart_attempts | ✅ 全命中 |
| updater.rs:33/:40-48(→:49)/:76/:140 | ✅ 除 P3#4 的 1 行区间外全命中 |
| approvals_audit.rs:23-27 | ✅ DEFAULT_ROTATE_BYTES=10 MiB、DEFAULT_RETENTION_DAYS=90 |
| 各文件行数与符号表(两张表 17 行) | ✅ 与事实表一致且各分节合计自洽:store 18+270+184+414+258+151+133+901+335=2,664;services 15+587+320+698+479+139+512+473=3,223;diagnostics 56+400+321+505+278+312+173+198=2,243 |

## §B 数字 live 复现(2026-09-03,@9c157101)

```text
wc -l crates/octos-store/src/*.rs      | tail -1 → 2664  ✅(9 文件,lib.rs 18 行)
wc -l crates/octos-services/src/*.rs   | tail -1 → 3223  ✅(8 文件,lib.rs 15 行)
wc -l crates/octos-diagnostics/src/*.rs| tail -1 → 2243  ✅(8 文件)
grep -rw 'tenant' crates/ --include='*.rs' | wc -l → 2261 ✅(与章内「全词 2,261 次」精确一致)
tenant.rs:14-15 → SSH_PORT_START=6001 / SSH_PORT_END=6999 ✅(池上限 999 与 6999-6001+1=999 一致)
metrics.rs 1554 / events_harness.rs 183 / ui_protocol.rs 7221 / monitor.rs 518 / updater.rs 473 / tenant.rs 512 ✅
git log -1 7f81fa5e → Stage 1 (#1443);1801a9e9 → Stage 2 (#1445) ✅
```

## §C 机械项计数

```text
grep -c '```mermaid' → 3(图 15-1/15-2/15-3,均有加粗题注)
grep -o '——' | wc -l → 1(≤2 ✅,L240)
grep -o '\*\*[^*]*\*\*' | wc -l → 10(≤15 ✅)
锚点:# 第 15 章 → 15.1(5 小节)→ 15.2(3)→ 15.3(2)→ 15.4(6)→ 15.5 → 15.6 → 延伸阅读 → 思考题,无跳号 ✅
黑话(赋能/抓手/闭环/生态/降维)→ 0 ✅
cmp chapters/ch15-production.md book/src/part3/ch15.md → 一致 ✅
SUMMARY.md:33 → 「第 15 章:生产化:存储、服务、运维面与多租户」在位 ✅;chapters/ 无 ch14-production.md ✅
```

## §D 字数

- 实测口径(CJK 字符、剔除 ``` 围栏代码块):**5,160**,与 master 定稿及 brief 给定值精确一致 ✅
- 占比:16.2% **未能复现**——以同一口径实测:全书 book/src(88,183)的 5.9%;正文五章 part1-3(84,060)的 6.1%;part3(26,202)的 19.7%;part2+3(60,043)的 8.6%。无任何自然分母得 16.2%(需总量 ≈31,852)。判:字数达标;占比声明存疑,见 P3#5。

— ch15-factcheck(C1)2026-09-03,迭代 35 内完成,仅新增本文件,未改动其他文件。
