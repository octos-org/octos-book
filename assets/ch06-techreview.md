# Ch6 技术审查报告(C2 techreview,lane strong)

- **审查对象**: `chapters/ch06-tool-system.md`(master 99c0543 版,322 行)
- **事实基准**: `assets/ch06-facts.md`(552be31);源码只读基准 octos @ `9c157101`(实测确认)
- **审查日期**: 2026-09-03
- **分工**: C1(cheap 机械核对)另线在跑,本报告只做 C2 技术判断;以下所有源码行号均为本人在 `9c157101` 上亲测复核

## 计数表

| 级别 | 数量 |
|---|---|
| Critical | 0 |
| Major | 3 |
| Minor | 4 |

---

## 一、机制描述正确性(检查项 1)——全部通过

以下每项声明均经源码逐行验证,**未发现机制级错误**:

| 章稿声明(行号) | 源码证据 | 判定 |
|---|---|---|
| `Tool` trait 三层契约、默认互相委托、"至多覆写其一"(L113-137) | `mod.rs:609` trait 定义;`:594-598` 注释原文 "A tool should override at most one of the two. Overriding both produces two independent entry paths";`truncation_recovery` 默认 `None` @ `:674-686` | ✅ 准确 |
| RFC-0 后 `specs()` 全量输出,排除项仅 internal-hidden / provider 策略 / 上下文过滤器(L176) | `registry.rs:706-711` 注释逐字对应:"every enabled tool is emitted every turn…no longer any recency-based (LRU) deferral" | ✅ 准确 |
| `specs()` 按名排序防 prompt 缓存打穿(L151) | `registry.rs:748` `specs.sort_by(|a,b| a.name.cmp(&b.name))`,注释含 "busted provider-side prompt caches…Anthropic `cache_control`" | ✅ 准确 |
| `mark_spawn_only`/`mark_internal_hidden`/`clear_spawn_only` 语义(L178-200) | `registry.rs:299`(`mark_spawn_only`)、`:324`(`mark_internal_hidden`,注释 "no 'un-hide' path through any LLM-callable tool")、`:355`(`clear_spawn_only`,注释 "the subagent IS the background context") | ✅ 准确,含子代理方向性论述 |
| spawn_only 拦截点 + provider 策略复查(L178, 图 6-2) | `agent/execution.rs:775-780`:`if tools.is_spawn_only(&tc_name)` 后、`tokio::spawn` 前复查 provider policy(PR #688 follow-up 注释) | ✅ 准确,时序图与源码一致 |
| `TOOL_GROUPS` 10 组、`group:fs` 只收 5 主入口、`bash` 入 `group:runtime`(#1172)、`group:sessions` 七成员(L61-63) | `policy.rs:186` `TOOL_GROUPS`;`:187-197` group:fs 恰 5 项;`:201-210` #1172 注释原文 "include the Codex-compatible `bash` alias";`:219-236` 七成员(spawn/spawn_agent/send_input/resume_agent/wait_agent/close_agent/delegate) | ✅ 准确 |
| `group:delegated` 超集不变量 + 测试 + "非 confinement boundary"(L63) | `policy.rs:307` group:delegated;`:299-301` "no group-in-group" 注释;`:581` 测试 `group_delegated_supersets_session_spawn_family`;`:283-285` "THIS IS NOT A CONFINEMENT BOUNDARY" | ✅ 准确 |
| deny-wins、`robot_tier_gate`/`policy_deny` 指标、`require_tags` fail-closed(L243-261) | `policy.rs:77-128` `evaluate`(deny 优先、空 allow 放行、metric reason 区分);`:131-148` `is_allowed_with_tags` 带 "SECURITY / BEHAVIOR CHANGE (peer-review fix)" 注释 | ✅ 准确 |
| `apply_policy` 物理裁剪 vs `set_provider_policy` 过滤器(L267) | `registry.rs:869-874`(`retain`);`:947-953`(仅设 `provider_policy` + `invalidate_cache`);`provider_policy_permits` @ `:973`;`config.rs:132` `tool_policy_by_provider` | ✅ 准确 |
| `estimate_json_size` 零分配递归、1 MB 上限在 registry.rs 非 args.rs(L275-277) | `registry.rs:95-119`(字符串 `len+escapes+2`、数组 `2+sum+commas`、对象 `k.len()+3+v`);`MAX_ARGS_SIZE = 1_048_576` @ `:1133` | ✅ 准确,且纠正事实表口径的做法正确 |
| coding_tool_contract P0 十项、状态词汇、`deferred` 历史语义(L283-285) | `coding_tool_contract.rs:12`(`coding.tool_contract.v1`)、契约 ID/策略 ID @ `:13-16`;P0 @ `:85-96` 逐项一致;状态词汇 `:21-34`;`deferred` 注释 @ `:29-33` 仍写 "#970 — LRU auto-eviction…recover via `activate_tools`" | ✅ 准确,历史词汇处理得当 |
| 三种构造及其权限语义(L155-168) | `registry.rs:1243/1248/1254`,代码摘录与源码一致(`with_builtins_and_sandbox` 内 `EffectivePermissions::workspace_write()`) | ✅ 准确 |
| 注册路径六处(L206-211) | `chat.rs:855/:1337`(`with_builtins_and_permissions`)、`acp.rs:224/:501`(`with_builtins_and_sandbox`)、`gateway_runtime.rs:823`、`session_actor.rs:2884`(apply_policy 顺序注释逐字对应)、`mcp.rs:532`(`register_tools`,名字冲突拒绝 + 传输先持有 #1886) | ✅ 六处全验 |
| lean coding roster 12 项含 3 组条目、补回 check/update_plan/tool_search(L207) | `assets/profiles/coding.json` allow_list 实测恰 12 项,description 原文证实 "which the earlier lean list denied" | ✅ 准确 |
| 工具注册名分离(glob/grep/workspace_log/deep_crawl/search/delegate_task/configure_tool, L59/L75/L79/L103) | `glob_tool.rs:106`、`grep_tool.rs:108`、`workspace_history.rs:101`、`site_crawl.rs:283`、`deep_search.rs:71`、`delegate.rs:503`、`tool_config.rs:633` | ✅ 全部一致 |
| 输出限额表(L83) | `octos-core/src/utils.rs:180-196`:read_file 50,000 / shell 30,000 / web_fetch 40,000 / web_search 20,000 / search 200,000 | ✅ 准确 |
| write_grant 单段通配语法(L79) | `write_grant.rs:15`("literal_separator;`**`, `[...]`, `{...}` are rejected")、`:75`、`:96-107` | ✅ 准确 |
| read_window 默认关 + 参数来源(L71/L289) | `read_window.rs:1-30`(pi harness 2000 行、48 KiB 反推自 50,000 上限)、`armed_from_env` @ `:178` | ✅ 准确 |
| 行数声明(L69/L95/L147) | spawn.rs 5,309、read_file.rs 2,366、write_file.rs 2,220、shell.rs 2,745、registry.rs 3,581、policy.rs 741、args.rs 479 | ✅ 全部实测一致 |
| `catch_unwind` + 1,800s 超时(L172) | `registry.rs:1155-1164`;`DEFAULT_REGISTRY_TOOL_TIMEOUT_SECS` 默认 1800(`:189` 附近注释) | ✅ 准确 |
| args.rs 结构化报错、4,096 上限、无副作用不级联(L279) | `args.rs:1-30`(#1770/#1765);`mod.rs:59` `TOOL_INPUT_ERROR_MAX_BYTES = 4096` | ✅ 准确 |
| LRU/activate_tools/find_evictable/ToolLifecycle 仅出现于"已删除"标注语境 | 全文 grep:仅 L174-176、L285、L293-295、L320,全部为历史注记 | ✅ 符合 spec `review_ch06_lru_removed`;"14 个内置工具" 零残留 ✅ |

## 二、技术公平性(检查项 2)——通过

6.6 侧栏(L293-295)对 LRU 删除的论证公允:承认原始动机(token 开销)真实,论证走的是"因果链已变"而非"方案错误";`tool_search` 被表述为"以更低的复杂度解决了发现问题"而非唯一解;`spawn_only` 的幸存有独立需求支撑(别阻塞前台轮次)。教训句("先问各自因果链是否还成立")是方法论而非立场宣示。**未把实现选择写成唯一解** ✅。

Minor-4:两处措辞可再克制——"缓存机制把重复序列化的开销吃掉"(L295):`cached_specs` 缓存的是 `specs()` 构造,provider 侧 JSON 序列化每轮仍发生,"吃掉"偏强,建议改"摊平 specs 重建的开销";侧栏未提业界仍有项目(如 OpenAI deferred-tools 类机制)在超大规模工具面下采用延迟激活,补一句适用边界会让论证更完整(非必须)。

## 三、论证层数(检查项 3)——大体达标

10 能力域小节中:文件系统(三点设计)、Web(输出限额梯度)、记忆(recall 机制)、Peer/Fleet(spawn_only 绑定)、代码/Git(1 MB 上限)、技能/插件(分发器+映射表)均有明确"为什么这样设计";另有专节"为什么按域拆文件"(L105-107)质量很高(不变量共享/威胁模型隔离/spawn.rs 反例)。**消息/交互域(L89-91)论证最薄**:仅一句"结果不是给模型的,是给人的",且是唯一没有源码引用的域(见 Major-3)。工程决策侧栏(6.6)深度足够。

## 四、跨章重复(检查项 4)——通过

- ch05 对 spawn_only 仅 1 处一句带过(execute_tools 段,"工具语义详见第 6 章"),ch06 展开机制,重复 <3 行 ✅
- ch07 L216 有明确分工声明("第 6 章讲了单工具的参数级写授权,本章的 WorkerGrant…"),ch06 L79 也预留"运行时语义与沙箱翻译在第 7 章",双向引用,重复 <3 行 ✅

## 五、结构与叙事线(检查项 5)——通过

口径澄清(58 条目)→ 10 域导航表+图 → 逐域速览 → "为什么按域拆" → Tool trait → Registry(构造/查找/曝光/六路径+图)→ Policy(判定图)→ 三道安全闸 → 契约面 → 治理工具三例 → LRU 侧栏 → 小结/思考题/版本说明。叙事线由浅入深、每层有图或源码锚点,思考题(L310-316)质量高(尤其第 1、3 题直击机制边界)。

---

## 问题清单

### Critical(0)

无。

### Major(3)

**M-1 admin/ 子目录文件数:章稿写 6,实测 7 个 `.rs` 文件**
- 章稿 L3("内含 6 个文件,合计 3,424 行")、L28("admin/(6 文件)")
- 实测:`ls crates/octos-agent/src/tools/admin/*.rs | wc -l` = **7**(mod.rs / platform_skills.rs / profiles.rs / skills.rs / sub_accounts.rs / system.rs / update.rs);`wc -l admin/*.rs` 合计 3,424 ✅(行数对,文件数错)
- 根因:事实表 L14 同错——列出的名字本身就是 7 个却写"6 文件",章稿照抄了自相矛盾的事实表
- 修复:L3/L28 改"7 个文件";同步修 `assets/ch06-facts.md` L12-14

**M-2 能力域表"平台杂项 = 9"与所列清单对不上,58 的合计靠错误数字凑出**
- 章稿 L28:文件数列写 9,清单为 check_workspace_contract / tool_config / mofa_make / robot_groups / mod / admin/(6 文件)——按条目口径(admin/ 算 1)只有 **6** 个
- 全表合计 12+3+9+5+4+10+2+1+3+9 = 58,恰好依赖"平台杂项=9"才等于 58;真实口径下应为 6,合计 55(+admin 内 7 文件另计=62)。"9" 用任何口径都无法解释(5 个 .rs + admin 1 条目 = 6;5 + admin 内 7 文件 = 12)
- 这是本章导航图的算术矛盾,读者按表复算即穿帮
- 修复:L28 文件数改 6;L15 导语"58 个条目"口径不受影响(`ls | grep -v test | wc -l` = 58 实测正确,admin/ 算 1 条目);若想保留"含 admin 拆分"的口径,需全表统一并重算

**M-3 消息/交互域(6.1.5)零源码引用,违反 spec 完成条件**
- 章稿 L89-91:全段无任何 `crates/...rs:行号` 引用
- spec `review_ch06_domain_grouping`(specs/ch06-tool-system.spec.md L61-65):"每个能力域至少一处源码引用"——10 域中 9 域达标,唯此域缺失
- 修复:补一处即可,如 `message.rs` 的 `fn name()` 或 send_app_card 的注册点行号(与 C1 线核对后填)

### Minor(4)

**m-1 robot_groups 引用落在测试代码**
- 章稿 L103:"`robot_groups.rs:186-187`" 实测为 `#[test] fn should_expand_tier_to_include_lower_tiers` 内的 `insert("camera_read", SafetyTier::Observe)` 调用,非生产注册表
- 修复:改引生产侧(`robot_groups.rs:26` `group_name` 或 RobotToolRegistry 定义),或注明"测试中的示例注册"

**m-2 消息/交互域论证单薄**
- L89-91 仅一句设计理由。补一句为何走消息总线而非工具结果(与第 10 章分工处点到即止)即可

**m-3 `#2193 R4` 归属存疑**
- 章稿 L279 将 4,096 字节错误消息上限归因 "(#2193 R4)";实测 `read_window.rs:182` 的 "#2193 R4" 指文件代际身份(ReadMeta),`mod.rs:59-68` 的上限注释未见 issue 号。可能 #2193 review 有多条 R4 分落不同文件,建议 writer 复核后保留或删注

**m-4 LRU 侧栏措辞与适用边界**
- 见第二节 Minor-4:`cached_specs` "吃掉重复序列化开销"偏强;可补一句延迟激活在超大规模工具面下的适用边界,增强公平性

---

## 结论

**可定稿(小修后)**:0 critical;全部机制性论述——Tool trait 契约、specs() 全量输出与排序、双曝光控制、deny-wins 与分组不变量、estimate_json_size 非分配设计、coding_tool_contract P0、六处注册路径——均经 `9c157101` 源码逐行验证准确,LRU 删除论证公允,跨章重复合规,叙事线完整。3 处 major 均为局部计数/引用问题(admin 6→7、平台杂项 9→6、消息域补一处引用),不动机制叙述即可在半小时内修复;修复后即可定稿,无需二轮 C2。
