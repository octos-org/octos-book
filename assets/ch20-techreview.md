# Ch20 技术审查(C2,ch20-techreview,lane strong)

审查对象:`chapters/ch20-octoloop.md`(master @ e42e2f9 拷入本 worktree)
事实基准:`assets/ch20-facts.md`;源码只读 octoscode @ 1129fa33、octos @ 9c157101(两者均已 `rev-parse` 复核,octoscode 工作树有未提交改动,所有行号以 `git show <commit>:<path>` 复核,不受污染)
审查日期:2026-09-03 · 迭代 ≤35 · 只报告不改稿

## 计数表

| # | 级别 | 位置 | 问题 | 证据 |
|---|---|---|---|---|
| 1 | **critical** | 20.6「`GoalRuntimeState`(`:265`)的五态里 budget_limited 是独立中间态」 | **机制描述错误**。`GoalRuntimeState` 是**四态枚举**:`Active, Paused, Completed, Failed(String)`(octos @ 9c157101 `crates/octos-cli/src/autonomy/goal_loop_runtime.rs:265-271`,逐行核对)。`budget_limited` 根本不是该枚举的成员——它是**账本(SQLite goals 表)状态集**里的字符串状态,由 `cas_goal_status` 的 UPDATE 预算规则写入(`crates/octos-fleet/src/sqlite_ledger.rs:899` 起,Ch18 :34 已正确表述),另在 ui_protocol_transport.rs 多处以注释/transition 形态出现。且本章同段把 `GoalBudgetResolution`(`:298`)说成预算耗尽的触发器走 GoalWrapUp——正确,但与「五态」错误叠加后读者会把账本态与运行时态混为一谈,这正是 Ch18 第 75 行反复警告的两本账混写问题。Ch18 同文件引用写作「四态」(ch18 :59 :75),Ch20 与 Ch18 直接矛盾 | `git show 9c157101:crates/octos-cli/src/autonomy/goal_loop_runtime.rs` L265-271;`grep -rn budget_limited 9c157101 -- crates/` 仅命中 ui_protocol_transport.rs 注释与 sqlite_ledger 账本态;chapters/ch18-goal-peer.md:59「四态」 |
| 2 | **critical** | 20.1 定位段 & 20.7 回顾 1「契约测试 3 件 25 个用例」 | **计数前后矛盾且两处皆错**。实际:olp_contract 8 + olp_mcp_contract 7 + outer_duty_contract 10 = **25** 个 `#[test]`。定位段写「25 个用例」✓,但 20.3 写「367 行,8 个用例」、20.4 写「290 行,7 个用例」、20.5 写「十条契约测试…745 行」——8+7+10=25 自洽。**矛盾点在事实表 §5 与章内数字**:事实表 §5 标题写「契约测试三件」,olp_contract 8 用例清单完整,数字链一致。复核结论:25 处总计数正确、分件计数正确——**撤回此条 critical,降级为通过**(详见 #7 备注:唯一瑕疵是定位段「契约测试 3 件(25 个用例)」的括号歧义,建议写「三件共 25 用例」) | `grep -c '#\[test\]'` 三文件 @1129fa33 = 8/7/10;行数 367/290/745 复核一致 |
| 3 | major | 20.2 多外环协作规则「(`:260` 起)」 | 行号锚点偏移。@1129fa33 的 `docs/OUTER_LOOP_PROTOCOL.md` 共 **397 行**(章末版本演化说明与事实表 §1 写 403 行,为**工作树未提交版**行数);「多外环并发」小节实际在 **:259-275**(标题 :259,署名/分域/冲突裁决在 :264-271),章写「:260 起」偏差 1-5 行。同因受累的锚点::131-137(挂载三坑实为 **:155-158**,章内 20.4 又同时引「:131-137」与「profiles JSON」内容,后者在 :155-157)、:289(驱动选型实为 **:296** 起,外环在线直驱条目在 :300)、:322(裁决审计面实为 **:285-293**,goal_03 案例在 :289-290)。**根因:章按 octoscode 工作树(M 状态)行号写,违反「源码只读 @ 1129fa33」的基准约定**。R1-R7 主锚点(:52/:67/:71/:74/:77/:89/:91/:103)与 :7/:12-15/:19/:27/:29/:39/:196/:218/:345/:349/:354/:375/:393 在 @1129fa33 下复核**全部命中** ✓ | `git show 1129fa33:docs/OUTER_LOOP_PROTOCOL.md \| wc -l` → 397;工作树 `wc -l` → 403(M 未提交);`grep -n "### 多外环并发\|### 驱动机制选型"` @1129fa33 → :259/:296 |
| 4 | major | 20.3 黑板统计「465 行、29 个编号条目、71 处 ACK 行」 | 数字与事实表 §2 自洽,但**与当前主 checkout 实测不符**:实测 491 行 / 30 个 `### ` 条目 / 85 处 `ACK(`。黑板是活文档、追加型增长,审查基准应取事实表生成时点(465/29/71 已在事实表 §9 复跑记录 ✅)或更新为现值。**建议**:数字旁标注「截至事实表生成时(2026-09-03)」,避免出版即过期。属表述稳健性问题,非错误 | `wc -l` / `grep -c` 主 checkout `.octos/OUTER_LOOP_REVIEW.md` → 491/30/85;事实表 §2/§9 → 465/29/71 |
| 5 | major | 20.6 工程决策侧栏「39 个公开方法」 | 实测 @9c157101 `sqlite_ledger.rs` 的 `pub fn` 计数 = **43**(含 trait impl 内方法)。若按「GoalLedger impl 块内 pub fn」口径需重新圈定;39 这个数字在事实表里同样出现(§7「39 个 pub fn」),事实表与源码不一致,章随事实表错。属可核对数字,定稿前必须择一口径复算 | `git show 9c157101:crates/octos-fleet/src/sqlite_ledger.rs \| grep -c "pub fn"` → 43 |
| 6 | minor | 20.1「上行…六条:…以及方向相反的主动问询,即后文的第五信道」 | 信道矩阵编号与自然序混排易误读:协议上行表按「事件流/交付物/账本/求助/代码/主动问询」排列,「第五信道」之名来自历史排序(MCP 问询曾列第五),现行协议表里它列第六。章内 20.4 自己写「前四条上行信道…与第 6 条代码信道都是外环拉取,第五信道方向相反」——与 20.1 的六条列举顺序(问询列最后)不一致。建议 20.1 统一为「第五信道(历史编号,现行矩阵列于第六行)」或调整列举顺序 | 协议 @1129fa33 :39-49 上行表:第五行 git log/diff、第六行 MCP 主动问询 |
| 7 | minor | 定位段「契约测试 3 件(25 个用例)」 | 括号歧义:可读作「每件 25」。改「三件共 25 个用例」。同段「Rust 源码 9 件」未在事实表中逐件列出对应清单,建议事实表补一节 §0 文件清单(协议文档 7 + 脚手架 2 + Rust 9 + 测试 3 + 脚本技能 5 + octos 交叉 4 = 30)以便 30 这个总数可复核 | 事实表 §1-§7 分件计数 = 7+2+9+3+5+4 = 30 ✓(数字自洽) |
| 8 | minor | pathfix 引用风格 | 章内源码引用全部带 `octoscode/`、`crates/` 前缀 ✓(自检:唯一裸匹配 `config.toml` 是协议文档正文引述「不是 instances/.../config.toml」,非源码路径引用,合规)。`octos-book/.octos/loop.md`、`octos-book/.octos/OUTER_LOOP_REVIEW.md` 用仓前缀,与全书风格一致 ✓。`knowledge/requirements/req-olp-duty-macos.md` 带文字说明「octoscode 仓」但路径本身无前缀—— borderline,建议写 `octoscode/knowledge/requirements/req-olp-duty-macos.md` | `grep -oE` 裸路径扫描仅 `config.toml` 一处,属引述非引用 |

## 逐项检查结论

### 1) 机制描述正确性

- **双环信道矩阵**:下行五条(AGENTS.md/黑板/commit/门铃/TUI 注入)、上行六条 ✅ 与协议 :29-49 逐行对上;每条的载体、时效、语义(门铃「仅事件通知与黑板指针」✅、TUI「落在 composer 即用户消息层级」✅)转录准确。mermaid #1 与文字一致 ✅。
- **R1-R7 条款与案例对应**:七条主锚点行号(:52/:67/:71/:74/:77/:89/:91/:103)在 @1129fa33 全部命中 ✅。R1 案例(v0 #9 wontdo 抗命、外环复核接受)✅ 协议 :205「#9:内环以证据拒绝重派指令,外环复核后接受——内环是对的」。R2 案例(权限档 1-4 bwrap 不挂 `~/.cargo`/`~/.rustup` → command not found ✅ :116-118;快照零收益 + duplex 真管道损坏 ✅ :237-239)。R3 案例(goal_03 测量方法错误零上报 ✅ :289-290)。R4 案例(探针混编译断、diff-preview 竞态 SIGBUS ✅ :231-233)。R4b 谓词三条件与树主权 checkout 拒绝 ✅ :77-88 逐条对应。R6 双落点 + 契约 :215 ✅。R7 范围条款(Linux-only/flock+PDEATHSIG+/proc/NFS 不适用/Windows LockFileEx 另立)✅ :91-102。
- **黑板无 Rust 实现 / 追加唯一正道**:✅ 核心论断成立。`olp-board-append.sh` 24 行,但章写「核心就三行:`exec 9>"$LOCK"`(:20)、`flock -x 9`(:21)、`cat >> "$BOARD"`(:22)」——**行号错误**:@1129fa33 实际 `trap` :20、`cat > "$TMP"` :21、`exec 9>"$LOCK"` **:22**、`flock -x 9` **:23**、`cat "$TMP" >> "$BOARD"` **:24**(事实表 §6 同错,三行内容描述本身正确,且实际机制是 mktemp+trap 的安全版而非直接 `cat >>`)。**应为 :22-24**。此条并入 #3 的行号族,单独列出因 brief 点名此项。
- **R7 主审锁 Linux-only 与 macOS 回退**:`outer_duty.rs:23` cfg 行 ✅(注意:章写 :23,事实表 §4 写 :24——**@1129fa33 实测 cfg 在 :23**,章对、事实表错 1 行);`DutyState` :34 ✅、`as_str` :43(章)/ :44(实测,`pub fn as_str` 在 :44,枚举体在 :34-40;章引「(:43) as_str」差 1 行,minor);macOS 退值班簿 + operator 裁决 ✅ GUIDE :229;值班簿「任何平台都只是提示性目录,不构成所有权」✅ GUIDE :232-233;reaper 立项文件存在(octoscode 工作树 untracked + spec)⚠️ 注意 `req-olp-duty-macos.md` 在 1129fa33 **未签入**(工作树 untracked),若按只读基准口径该文件不属于基准内容,建议章内注明「已立项、需求文件在 octoscode 仓(基准后签入)」或核实签入 commit。
- **第五信道 90s/每片 3 次**:`ASK_TIMEOUT_SECS = 90.0` :25 ✅、`ASK_QUOTA_PER_SLICE = 3` :27 ✅、`ASK_POLL_INTERVAL_SECS = 0.5` :26 ✅、tried 必填拒绝 :186-188(章写 :184-187,差 2 行,同 #3 族)、quota 拒绝 :190-195(章 mermaid 写 :189-196,容差内)、`DEGRADED_GUIDANCE` :30 ✅、`QUOTA_REFUSAL` :31 ✅、`TRIED_REFUSAL` :32 ✅、两个工具 :328 ✅、署名 :24 ✅、`outer_root` :36 ✅、serve :46 ✅、cmd 接线 :6/:8-10/:28 全部命中 ✅。olp_mcp_contract 七用例行号 :98/:115/:144/:209/:227/:246/:266 全部命中 ✅。
- **goal 预算档落点**:预算档文字(修订 5-10M/切片 10-20M/战役 30-50M)✅ BOOT :44(章引 :34,BOOT 该行在 :44——**章引行号错 10 行**,BOOT「## 1. 黑板」标题在 :34,预算档在 §6 :44;同 #3 族);octos 侧落点 `GoalRuntimeState` :265 ✅ `GoalBudgetResolution` :298 ✅ `GoalWrapUp` @master_continuation_scheduler :147 ✅,但见 **#1 critical(五态 vs 四态)**。

### 2) 技术公平性(三层标注)

✅ 公允,无「把约定写成已实现」的越界。逐机制核验:黑板=Markdown 约定+无 Rust 实现 ✅(章 20.3 明写「没有 Rust 实现,没有数据库,没有服务进程」);ACK=条款+契约 ✅;R2/R3/R5=纯条款 ✅;R4b 明确标注「octos 侧机制,非本仓」且运行时实现归 Ch18 ✅;第五信道/主审锁=条款+实现+契约 ✅;预算=约定档位 + octos 侧机制(ch18 范围)✅。反向越界(把实现降格成约定)亦未发现。`GoalRuntimeState` 五态错误(#1)是唯一把账本态错安到运行时态的实现层描述错误。

### 3) 跨章重复(Ch18/Ch21 ≤3 行)

✅ 合规。Ch18 侧:ch20 :138 的预算落点段约 6 行,但内容是「外环视角的后果」且明确划界「内部实现属第 18 章范围」,与 ch18 :34/:59/:75 无文本重复(Ch18 讲 cas_goal_status 账本规则,Ch20 讲 budget_limited 可恢复语义)——但 **#1 修正后须确保不引入「budget_limited 是账本态」的 Ch18 复述**,一句话划界即可。Ch21 侧:仅 :208 一处提及 outer-duty Linux-only 且已标注「第 20 章已展开」✅。herdr 细节 ch20 未越界 ✅(TUI 注入仅作为下行信道出现,与边界声明一致)。

### 4) 结构:DDIA 叙事线 / mermaid 与文字一致

✅ 叙事线完整:问题(双环成本不对称)→ 协议(信道+纪律)→ 核心机制深潜(黑板/第五信道/主审锁)→ 交叉面(octos 侧)→ 工程决策侧栏 → 边界回顾,符合本书 DDIA 式「先给心智模型再给机制密度」节奏。4 张 mermaid(双环信道图/ACK 状态机/ask_outer 时序/duty 锁生命周期)与文字一致 ✅;唯一小瑕:mermaid #1 把黑板画成「权威账本」、MCP 信箱画成第五信道节点,与 20.1 文字的六信道列举顺序存在 #6 所述编号摩擦;mermaid #4 的 `(:220 仅观察)`/`(:34)` 行号与文字一致 ✅。

### 5) pathfix 后引用风格

✅ 基本合规(见 #8)。全章源码引用带仓前缀;建议 `knowledge/requirements/...` 补 `octoscode/` 前缀以彻底满足 AGENTS.md 第 7 条。

## 是否可定稿

**不可直接定稿——需一轮修订(C2 建议:修 1 critical + 3 major 后可定稿)**。

必改(阻塞):
1. **#1** `GoalRuntimeState` 五态 → 四态,`budget_limited` 改述为账本态(`sqlite_ledger.rs` cas_goal_status 预算规则,与 Ch18 对齐),一句话划界。
2. **#3 行号族**(含 olp-board-append.sh :20-22→:22-24、BOOT 预算档 :34→:44、协议 :260/:131-137/:289/:322 等):统一以 octoscode @1129fa33 为准重锚;`OUTER_LOOP_PROTOCOL.md` 总行数 403→397(或显式注明按签入后版本)。同时修正事实表 §4 cfg :24→:23、§6 append 行号,保持章与事实表一致。
3. **#5** 39 个公开方法 → 复算口径(实测 `pub fn` = 43),章与事实表同步。

建议改(非阻塞):#4 黑板统计加时点标注;#6 第五信道编号摩擦统一表述;#7 「三件共 25 用例」;#8 reaper 需求文件签入状态核实 + 路径前缀。

修订后本章机制密度、三层标注公平性、叙事结构均达标,事实锚点质量在可复核范围内(抽查约 60 处行号,基准 commit 下命中率 >90%,错集中在协议文档工作树漂移族与个别 ±1-2 行偏移)。

---
*审查方法:逐条 `git show <commit>:<path>` 复核行号与符号;计数用 grep -c;跨章重复用关键词扫描;三层标注逐机制对照事实表 §8 归属表。全部证据可在两个只读仓按上述命令复跑。*
