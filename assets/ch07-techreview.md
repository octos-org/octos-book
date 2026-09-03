# Ch7 技术审查(C2)— chapters/ch07-security.md(v2 候选)

- 审查对象: `chapters/ch07-security.md`(246 行,基线 66946a3 worktree 拷贝)
- 事实基准: `assets/ch07-facts.md`(7ad7a72);源码只读 octos @ `9c157101`(HEAD 实测一致,工作树干净)
- 规范: `specs/ch07-security.spec.md`、`specs/project.spec.md`(DDIA 风格)
- 审查人: ch07-techreview(C2);审查日期 2026-09-03
- 方法: 逐项对照源码原文(非仅事实表),覆盖 C2 全部五类检查项;行号均为本次实测

## 0. 计数表

| 类别 | 数量 | 编号 |
|---|---:|---|
| Critical(机制描述与源码不符) | 0 | — |
| 必改(事实/准确性错误) | 2 | F-1, F-2 |
| 建议改(行号引用漂移) | 2 | M-1, M-2 |
| 观察(不阻塞定稿) | 2 | O-1, O-2 |
| 结构/mermaid 问题 | 0 | — |
| 技术公平性问题 | 0 | — |
| 跨章重复超标 | 0 | — |

## 1. 机制描述正确性(检查项 1)— 逐条核验

### 1.1 四层纵深叙事 ✅
章稿 L9/L224 的四层 = 进程沙箱 → 命令与派发策略 → 注入与脱敏 → 能力授予,与 spec「决策」段逐字一致。每层核心机制均与源码语义相符(证据见 1.2–1.5)。与 brief 括注的「内存安全→工具策略→…」四层不同,但 spec 是规范源头,章稿正确遵循 spec(O-1,非缺陷)。

### 1.2 SandboxMode 七变体 + Auto 回退序 ✅
- 七变体行号全部命中: `mod.rs:423` 枚举,`Auto`:426(`#[default]`,文档注释原文「bwrap on Linux, sandbox-exec on macOS, AppContainer on Windows」)、`Bwrap`:428、`Landlock`:430、`Macos`:432、`Docker`:434、`AppContainer`:437(serde `appcontainer`)、`None`:439。
- `MountMode`(`mod.rs:408`)三变体 `None`:410 / `ReadOnly`:413(`ro`) / `ReadWrite`:417(`rw`,默认)全部命中。
- Auto 回退序与 `mod.rs:875-899` 逐步一致: 先按 OS 选原生(macOS→sandbox-exec、Linux→bwrap、Linux→Landlock 助手、Windows→AppContainer 助手),`native.or_else(|| probe.docker()…)` Docker 兜底;全无时 `fail_closed=true`→`Refuse`,否则 `Unconfined(AutoNoBackend)`。章稿 L71/L87 的「原生优先,Docker 兜底」「fail_closed 可把降级变成拒绝」与源码逐句对应。

### 1.3 fail-closed 语义(eb7c7221)✅
- 契约三条(L69-71)与 `decide_sandbox` 文档(`mod.rs:795-808`)逐条对应: opt-out 优先于 `fail_closed`、显式模式不可兑现 REFUSE 绝不静默降级、Auto 降级 warned-never-silent。
- `UnconfinedReason`(`mod.rs:664`)三变体 `Disabled`/`ExplicitNone`/`AutoNoBackend` 与 L73 一致;`AutoNoBackend` 注释原文确为「the one LEGAL degradation」。
- `SandboxUnavailable`(`mod.rs:694`)三字段 `requested`/`reason`/`remediation`;双受众拆分(#2196 MUST-FIX)在 `mod.rs:676-700` 文档中明写,`Display` 面向模型含「Shell/exec commands will keep refusing until then」,remediation 仅走 creation-time `tracing::error!`(create_sandbox Refuse 臂,`mod.rs:1020-1026`)与 doctor — 章稿 L75 表述准确。
- `stderr_line()`(`mod.rs:724`)字符白名单实测为 `A-Za-z0-9 ./:_=,-`(mod.rs:734-741),章稿 L75 字符集引用逐字符一致。
- `create_sandbox`(`mod.rs:1005`)「签名保持不可失败」+ `warn_auto_unconfined_once`(`mod.rs:1039`,`std::sync::Once` 在 :1040)每进程告警一次 — L77 全部属实。
- `eb7c7221`: 14 files / +1621/−158 实测复现,是 `9c157101` 祖先;事实表 §5 的 14 文件清单与 `git show --stat` 一致,含 worker.rs/check.rs/validator_runner.rs 等「改动面」证据。

### 1.4 RefusingSandbox 定位(mod.rs:914)✅
struct 定义 `mod.rs:909`、impl `mod.rs:914`;`wrap_command` 永不执行原命令,POSIX 侧构造 `sh -c "echo '<line>' >&2; exit 1"`,Windows 侧 cmd.exe 分词传参防元字符(`mod.rs:925-941`);`refusal()` 经 exec 形态工具短路(`mod.rs:911-913` 文档)。章稿 L40/L239(思考题 2)的描述与源码一致。

### 1.5 WorkerGrant 五字段与 fleet 衔接 ✅
- 五字段行号全部命中(`grant.rs:151` struct;network:154、tools:157、fs:160、write_paths:179、create_only:189);`#[serde(default)]`/`skip_serializing_if` 语义与 L160-175 一致;`minimal()`(`grant.rs:207`)、`validate()`(:247)、`validate_write_path_pattern`(:307)、`GrantError`(:359,七变体)全命中。
- BASE_TOOLS 七项、GRANTABLE_TOOLS 九项(`grant.rs:27-49`)与 L165 一致;「空允许表 fail-open 陷阱」注释原文在 `grant.rs:240-243`。
- #1976 围栏三取值语义(None/Some(空)=只读围栏/Some(列表))与 `grant.rs:165-190` 字段文档逐条一致;语法收窄理由(工具层 globset 与 SBPL regex 表达力交集)在 :172-178 原文化呈现;`create_only` 的「沙箱层只能执行路径围栏,不覆盖一半由工具层执行」与 :181-184 注释一致。
- 双时点 validate: master `goal_plan` 解析 + registry 构建防御性复跑,`records.rs:234` 注释明写 re-runs `grant.validate()` — L216 属实。
- 第 16 章预告衔接: L150/L216 两处「装配详见第 16 章」,符合 spec 边界「不讲 fleet 装配(Ch16)」。

### 1.6 其余模块行号抽核 ✅
policy.rs(746 行,`Decision`:16/`ApprovalPolicy`:28/`FilesystemScope`:46)、dispatch_policy.rs(566 行,`GateDenial`:253、`last_dispatch_outcome`:257、`approval_unavailable`/`sandbox_required` 标签、#714 来历文档 :1-10)、permissions.rs(167 行,`SafetyTier`:19 四级 + `group:robot:<tier>` 经 ToolPolicy 分组)、prompt_guard.rs(772 行,`ThreatKind`:29 五类、`scan`:195、「Not a security boundary」文档 :5-19 及六种绕过列举)、sanitize.rs(245 行,`sanitize_tool_output`:90、DATA_URI:13、HEX:16、OpenAI:24、`redact_credential`:55、`scrub_credentials`:62 Anthropic 先于 OpenAI)、ssrf.rs(620 行,`check_ssrf_with_addrs`:24、`validate_answer_set`:69、`is_private_host`:228、`is_special_purpose_v4`:244(CGNAT/IETF/基准/组播+保留 全对)、`is_private_ip`:258、映射 v6 测试 :580/:590)— 全部与章稿 L124-146 一致。六文件行数(wc -l)与事实表逐项相符;`octos-sandbox/src/main.rs:1`「platform sandbox helper binary」+ :13 其他平台 no-op 直通,章稿 L11 事实纠正成立。

## 2. 发现的问题

### F-1(必改|事实错误)BLOCKED_ENV_VARS 是 18 项,不是 20 项
- 章稿: L110「一个 **20 项**的清单,按注入面分组:Linux 动态库注入(`LD_PRELOAD` 等 **3** 项)、macOS dylib 注入(`DYLD_*` **5** 项)、运行时代码注入(`NODE_OPTIONS`、`PYTHONSTARTUP` 等 **7** 项)、shell 启动注入(`BASH_ENV`、`ENV`、`ZDOTDIR`)」
- 源码: `crates/octos-core/src/env_hygiene.rs:23-45`,`awk` 实数 **18** 项;且章稿自列分组 3+5+7+3=18,与「20 项」自相矛盾(shell 组漏写「3 项」)。
- 修法: 「20 项」→「18 项」,shell 组补「3 项」。
- 严重度: 必改(事实表外的新增事实性错误,数字可直接复现实证)。

### F-2(必改|准确性)env_remove 的后端归属写窄了
- 章稿: L110「**bwrap 与 Landlock** 后端在进入沙箱前逐项 `env_remove`」
- 源码: `bwrap.rs:42`、`landlock.rs:36/:67`、**`macos.rs:478`**、**`windows.rs:90/:139`** 均逐项 `env_remove`;**`docker.rs` 全文件 0 处 env_remove**(grep 实测)。
- 影响: 现文暗示五后端中只有两个清理注入面变量,既低macOS/Windows 的实际防御,也掩盖了 Docker 后端确实不清理这一真实差异(技术公平性问题)。
- 修法: 改为「bwrap、Landlock、macOS、Windows 四个后端在进入沙箱前逐项 `env_remove`;Docker 后端不清理(容器隔离本身不继承注入变量治理,这是该后端的已知差异)」。
- 严重度: 必改。

### M-1(建议改|引用漂移)bwrap 字段文档行号
- 章稿: L98「(`bwrap.rs:30-40` 的字段文档)」——`:30-40` 实际落在 `impl Sandbox for BwrapSandbox`(`:29`)的方法体内。
- 源码: SSH_AUTH_SOCK/docker.sock 暴露风险注释在 `bwrap.rs:19-26`(struct 字段文档区,`repo_git_write` 字段 `:26`)。
- 修法: 改引 `bwrap.rs:17-26`。此条触发 spec「引用零失效」测试(区间须含所述符号)。

### M-2(建议改|引用漂移)`is_blocked_bind_source` 行号
- 章稿: L104「`is_blocked_bind_source`(`docker.rs:24-33`)」。
- 源码: 函数在 `docker.rs:20-30`,危险源常量表 `BLOCKED_DOCKER_BIND_SOURCES` 在 `:10-17`(`docker.sock`/`/etc`/`/proc`/`/sys`/`/dev`)。
- 修法: 改引 `docker.rs:20-30`(清单 `:10-17`)。区间部分越界(:31-33 已出函数)。

### O-1(观察)四层命名与 brief 括注不一致
brief 把四层写作「内存安全→工具策略→进程沙箱→WorkerGrant」;章稿与 spec 均为「沙箱→策略→注入脱敏→能力授予」。spec 为规范源头,章稿无错;内存安全归 ch01 叙事。仅记录,供外环对齐口径,不需改稿。

### O-2(观察)macOS `supports_repo_git_write` 的条件性
`macos.rs:185-193`: macOS 只有在 `read_allow_paths` 为空(非受限读 profile)时才支持 `.git` 写(bwrap 无条件支持,`bwrap.rs:30-39`)。章稿 L98 只写了 bwrap 的 `.git` bind,未提 macOS 的这一条件——与 fleet worktree 流相关,属 ch16 装配细节,本章不写不构成缺陷;若 C1 行文需要可补半句。

## 3. 技术公平性(检查项 2)✅(F-2 修正后)
- bwrap(mount namespace、tmpfs 先于 workspace bind 的反噬说明、窄授权 `.git`)、Landlock(纯委托助手、助手缺失即拒绝 `landlock.rs:29-37`)、macOS(最厚 1,767 行、SBPL 元字符 fail-closed 拒绝 `macos.rs:~199-212`、唯一能精确表达 #1976 围栏 `mod.rs:1081-1085`)、Docker(跨平台兜底、bind source 黑名单)、AppContainer(SID、默认拒绝)—— 各后端适用场景与强弱表述均与源码相符,无贬低或美化。唯一不公允处即 F-2(env_remove 归属)。

## 4. 论证层数(检查项 3)✅
- 每层「被绕过时下一层还在」的论证链在文中成立: 策略层自称非安全边界、真边界是沙箱与脱敏(L124);prompt_guard 文档明确「不是前三者的替代品」,架构性缓解=沙箱+工具策略+HITL(L136);7.5 用 deny-wins/fail-closed 在四层同形收束(L226)。
- 工程决策侧栏两个,均 ≥2 alternative: 侧栏 1(L116-118)对比「旧 fail-open 照跑 / 拒绝+可操作修复文本 / Auto 降级+一次性告警+fail_closed 开关」三案并写明代价与接受理由;侧栏 2(L218-220)对比「散落配置项 / 类型化 grant+解析时 validate」,含扩展成本(三处同步)。深度达标。

## 5. 跨章重复(检查项 4)✅
- 与 ch06: ShellTool SafePolicy 仅一句带过并显式回指「第 6 章已展开」(L124);`write_grant.rs` 关系两句话(L216),ch06 侧(:79)也只留接口与语法、把运行时语义指回第 7 章。双向接力干净,重复 ≤3 行。
- 与 ch16: 仅两处预告式引用(L150/L216),无装配内容泄露;ch16 章稿尚不存在,前向引用符合 spec。

## 6. 结构(检查项 5)✅
- DDIA 叙事线: 7.0 抛「沙箱不可用时该拒绝还是照跑」的问题→7.1 决策与实现→7.5 回顾收束;两处侧栏、五道思考题(含反问式论证题)、延伸阅读、版本演化说明齐全。
- 章内序号 7.0→7.5 连续无跳号;小节 7.1.1-7.1.6、7.3.1-7.3.3、7.4.1-7.4.3 齐整。
- mermaid 图 7-1 与 `decide_sandbox`(`mod.rs:812-900`)逐步一致(opt-out 优先、显式模式 OS+probe 双检、Auto 原生优先 Docker 兜底、fail_closed 分叉);图 7-2 五字段+validate+双执行层投影与 grant.rs/mod.rs:955-1000 一致。

## 7. 结论

**小修后可定稿(minor-revise → accept)。** 机制层面零 Critical:七变体行号、Auto 回退序、fail-closed 契约、RefusingSandbox 定位、WorkerGrant 五字段与 #1976 三取值、双时点 validate、eb7c7221/ffcde205 改动面,全部经源码原文逐条核验为真。定稿前必改两处:F-1(BLOCKED_ENV_VARS 20→18 项,含自相矛盾)、F-2(env_remove 后端归属写窄,漏 macOS/Windows、掩 Docker 差异);建议同批修 M-1/M-2 两处行号漂移以满足 spec「引用零失效」测试。以上均为局部文字修订,不动结构、不动图、不动叙事。
