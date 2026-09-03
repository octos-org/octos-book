# 第 17 章事实核查报告(ch17-factcheck)

- **审查对象**:`chapters/ch17-swarm.md`(镜像 `book/src/part3/ch17.md`,cmp 一致)
- **事实基准**:`assets/ch17-facts.md`;源码 octos main @ `9c157101` 实测复跑
- **审查日期**:2026-09-03;基线:master 3f91f38 之后的 ch17 镜像稿

---

## 汇总

**结论:可定稿。** 0 Critical / 0 Major / 3 Minor(均不阻塞)。全部行号引用逐条实测命中,数字与源码一致,机械项全过,自证命令 0,SUMMARY 条目在位。

## 一、源码引用核查(重点项全过)

共 66 处 `crates/...rs` 引用(含重复),其中带行号的符号引用 40 组逐一在 octos @ `9c157101` 实测 `sed -n` 命中,0 越界、0 区间漂移。抽查记录:

| 项 | 章中引用 | 实测 | 结果 |
|---|---|---|---|
| 门禁一道 | `gate.rs:25` `enforce_or_outcome` | 25 行命中 | ✅ |
| 门禁一道(共享) | `dispatch_policy.rs:292` / 后端感知 `:303` | 两行分别命中 `enforce_dispatch_gates` / `_for_backend` | ✅ |
| 门禁二道 | `dispatcher.rs:593` `gate_subtask_validators` | 命中 | ✅ |
| 门禁三道 | `dispatcher.rs:693` `run_aggregate_validator` | 命中 | ✅ |
| 幂等·版本 | `persistence.rs:27` `DISPATCH_RECORD_SCHEMA_VERSION = 1` | 命中 | ✅ |
| 幂等·快照 | #1718 finalized + final_result | dispatcher.rs:267-273 注释与实现一致 | ✅ |
| 幂等·指纹 | #1719 `ensure_record_matches_dispatch`「:856 附近」 | 实际定义 :870(856 位于相邻 Drop impl),偏差 14 行,章已用「附近」表述 | ✅(Minor-1) |
| 幂等·并发 | `dispatcher.rs:833` `InFlightGuard` | 命中(#1719 RAII 注释逐字在位) | ✅ |
| 三原语 | `run_parallel_round :428` / `run_sequential_round :478` / `run_pipeline_round :518` | 三行全命中 | ✅ |
| 拓扑符号 | topology.rs :27/:37/:59/:72/:98/:133/:143 | 七行全命中(128 上限、ContractSpec 四字段、`::variant` 后缀、resolve 覆盖、并发 1) | ✅ |
| 后端抽象 | mcp_agent.rs :182/:218/:266/:411 | 四行全命中;`from_dispatch` 代码块与 result.rs:47-56 逐字一致 | ✅ |
| CLI 接线 | serve.rs :420/:427/:433/:439/:1867 + Cargo.toml:32 | 全命中;Ok(None)/未知值报错/PersistentCostLedger 接线实测一致 | ✅ |
| 测试行号 | swarm_dispatch.rs 20 处、policy 9 用例(:134-:506)、subtask 4 用例 | 与事实表及实测 grep 完全一致(23+9+4=36 用例) | ✅ |

范围检查:octos-swarm 之外仅引用 octos-agent(门禁/后端,brief 授权)、octos-cli serve 接线面与 Cargo.toml(事实表 3.3 载有),无越界。

## 二、数字核查

| 数字 | 章中 | 实测 | 结果 |
|---|---|---|---|
| 总行数 | 4,980(2,505 src + 2,475 tests) | `wc -l` total 4,980;src 7 文件、tests 3 文件 | ✅ |
| 测试/源码比 | 1:0.99 | 2475/2505=0.988 | ✅ |
| 用例数 | 36 | 23+9+4 = 36 | ✅ |
| 契约上限 | 128 | topology.rs:27 | ✅ |
| 重试预算 | 3 轮、钳制、零进展轮才消耗、轮前检查 | MAX_RETRY_ROUNDS=3、`.min()` 钳制、:337 轮前、:378 进展判定 | ✅ |
| 48 符号 | 正文未引用(属事实表数据) | 不适用 | — |
| Fleet SCHEMA_VERSION | 「已到 3」 | octos-fleet records.rs:33 = 3 | ✅ |
| SWARM_DISPATCH_SCHEMA_VERSION | 固定 1 | octos-agent abi_schema.rs:80 | ✅ |
| 门禁五项顺序/拒绝标签 | 沙箱→工具→env 黑→env 白→审批;policy_denied/approval_unavailable/sandbox_required/env_forbidden | dispatch_policy.rs:303-380 逐项一致 | ✅ |

## 三、机械项

| 项 | 要求 | 实测 |
|---|---|---|
| 图表锚点 | 图 17-1/17-2/17-3 | 3/3 在位 ✅ |
| mermaid | 3 | 3 ✅ |
| 镜像 | cmp 一致 | `cmp` 零输出 ✅ |
| 破折号 —— | ≤2 | 0 ✅ |
| 加粗 | ≤15 | 12 ✅ |
| 黑话 | 无 | 未发现对齐/赋能类;Minor-3 一处中英混排 |
| 版本演化说明 | 在位 | 末尾 blockquote,9c157101 + 2026-09-03 ✅ |
| 自证命令 | 0 | 0(无 bash 块、无 `$ ` 提示符) ✅ |
| SUMMARY 条目 | 第 17 章 | SUMMARY.md:35 在位 ✅ |

## 四、字数与占比

- 正文字数(去 fenced 代码块):**5,247 汉字**,与 master 实测口径一致;全文含代码块 5,418。
- 占比:全书四部分正文合计 117,542 汉字 → **4.46%**(若按含 SUMMARY 的 118,566 口径为 4.43%)。brief 所记 4.2% 疑为其他分母口径,建议外环统一口径;本章体量在 5,000±250 带内,不构成问题。

## 五、Minor 清单(不阻塞定稿)

| # | 位置 | 问题 | 建议 |
|---|---|---|---|
| Minor-1 | 17.6 幂等件 2 | `ensure_record_matches_dispatch` 写作「:856 附近」,实际定义在 :870(856 是相邻 `impl Drop` 内) | 定稿时直接写 :870,删「附近」 |
| Minor-2 | 17.2 Pipeline 折叠 | 只给了非 object task 的 `{"original_task": …, "pipeline_input": …}` 包裹形状;task 本是 object 时实际是原对象插入 `pipeline_input` 键(dispatcher.rs:545-556 双分支) | 补半句「task 本为对象时仅插入 pipeline_input 键」 |
| Minor-3 | 17.2 末段 | 「链条 silently 断裂」中英混排 | 改「链条静默断裂」 |

## 是否可定稿

**可定稿。** 三处 Minor 均为措辞/行号精度级别,可在定稿批次顺手处理,不需要返工轮。
