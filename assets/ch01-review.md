# 第 1 章三视角审查报告（peer C，只报告不改稿）

- 审查对象：`chapters/ch01-why-rust-why-agent-os.md`（371 行；已确认与 `book/src/part1/ch01.md` 逐字节一致，`diff -q` 无输出）
- 事实基准：`assets/ch01-facts.md`；源码 `/Users/zhangalex/Work/Projects/FW/octos` @ `9c157101`（只读抽查）
- 规范：`specs/ch01-*.spec.md`、`specs/project.spec.md`、`.octos/skills/trilingual-collab-zh.md`
- 抽查方式：所有汇总数字与逐 crate 行数在源码仓库逐条重跑命令复核；10 处代码引用（含行号）逐一打开源文件比对；Mermaid 图 63 条边逐条与事实表 §5.1 对照；反模式按规范全文扫描计数。

---

## 一、fact-checker（事实核对）

### critical

**C1. workspace 成员数写成 39，实际为 38（源码实测）。**
- 位置：章稿第 5、88、154、310、351 行，共 5 处「39 个成员 / 39 项」。
- 证据：源码根 `Cargo.toml` members 数组实测 38 项 = 23 个 `octos-*` + 14 个 `app-skills/*` + 1 个 `platform-skills/voice`（`python3` 解析 members 数组 len=38；`awk '/members = \[/{f=1;next} f&&/\]/{f=0} f' Cargo.toml | grep -c '"'` = 38）。
- 佐证：事实表 §3.3（`assets/ch01-facts.md:184`）虽然也写「共 39 个成员」，但其后逐项枚举的清单本身只有 38 项——事实表此处自相矛盾，属基准表漏网数字（不在 brief 给定的机器复核清单 26/700,915/17/59/8 层/63 边之内）。
- 建议：章稿 5 处 39 → 38；并回报 master 修正 `assets/ch01-facts.md:184` 的「39」及口头禅式表述。此错会被任何读者照 1.3.1 的复现路径当场抓到，必须改。

### 核对通过项（抽查记录）

| # | 章稿声称 | 复核结果 |
|---|---|---|
| 1 | 26 crate / 700,915 行 / 17 频道源文件 / 59 工具源文件 / 63 依赖边 | ✅ 全部逐条重跑一致 |
| 2 | 逐 crate 行数（1.3.2 全部 26 项：core 22,313、agent 191,985、cli 307,299、server 21、dora-mcp 11……及 app-skills 12,098 / platform-skills 1,188 / web 0） | ✅ 与 `find … wc -l` 全量一致 |
| 3 | octos-cli 占全库 44% | ✅ 307,299/700,915=43.8% |
| 4 | core 被 15 个 crate 依赖；agent 被 8 个；cli 依赖 15 个 | ✅ 按边清单数一致 |
| 5 | Mermaid 图 63 条边 | ✅ 图内 `-->` 计 63 条、无重复边，与事实表 §5.1 逐一对应 |
| 6 | `../octos/crates/octos-agent/src/sandbox/mod.rs:1-23`（六文件、四平台） | ✅ 行号与内容相符；`ls` 实证 bwrap/docker/landlock/macos/windows/mod 六文件 |
| 7 | `octos-cli/src/config.rs:1633-1635` 默认并发 10 | ✅ `default_max_concurrent_sessions() -> 10` 恰在 1633-1635 |
| 8 | `gateway_runtime.rs:1731-1732` 信号量创建 | ✅ 1731 注释 + 1732 代码逐字相符 |
| 9 | `execution.rs:598 spawn_tool_task`、`:2483 execute_tools`、`join_all` 保序 | ✅ 行号精确；保序说法与 `execution.rs:14`、`:2992` 相符 |
| 10 | `tools/mod.rs:609-642` Tool trait（`Send + Sync`） | ✅ trait 位于 609；章稿标注「节选」，省略 `tags()`/`contexts()` 合规 |
| 11 | `octos-core/src/utils.rs:6-16 truncate_utf8` | ✅ 函数位于第 6 行，引用代码逐字一致 |
| 12 | 根 `Cargo.toml:50-51` `unsafe_code = "deny"` | ✅ 逐字一致；edition 2024 / rust-version 1.85.0 亦核对无误 |
| 13 | `octos-agent/src/lib.rs:30-31` harness 模块声明；`ls crates | grep harness` 零命中 | ✅ 均属实 |
| 14 | 三处事实澄清（sandbox / web / harness） | ✅ 表述与源码及事实表 §2 一致 |
| 15 | 旧数字零残留（10 crate / 13 万行 / 14 工具 / 14 频道 / 91 REST） | ✅ 正文中零命中 |

### minor

**M1. 17 个频道源文件的举例清单略有夸饰。** 第 17 行「Telegram、Discord、Slack、WhatsApp、飞书、邮件、Matrix、企业微信、钉钉、QQ Bot、Twilio、Line 等」——17 个 `*_channel.rs` 中含 `api_channel.rs`、`cli_channel.rs` 两个内部通道，并非全是「外部消息网络」。口径句本身（`*_channel.rs` 计数）是对的，建议在「等」前补半句「（含 api/cli 两个内部通道）」，防较真读者数不对账。

### fact-checker 小结：critical 1 / major 0 / minor 1

---

## 二、tech-reviewer（技术公平性）

### critical

无。

### major

无。

### minor

**M2. 「解释型运行时的每会话基线开销往往是编译型的数倍」（第 69 行）无出处、不可复现。** 事实表不含任何内存占用测量。虽有「往往」缓冲，仍是量化断言。建议改为可验证表述（如引用一次实测或改为「通常显著更高，需按目标并发实测容量」）。

**M3. 「Python 运行时本身是 C 写的，历史 CVE 不少」（第 88 行）无量化支撑。** 方向正确但不给量级，对熟悉 CPython 的读者说服力弱。建议给出一句可查的量级（如 CPython 官方 tracker 的内存安全类 CVE 数）或降格为「解释器由 C 实现，历史上多次出现解析恶意输入导致的内存安全 CVE」。

**M4. 「覆盖不到的路径依然裸奔」（第 104 行）属网络化口语。** 技术判断（-race 是测试期工具）本身准确且公平，但措辞违反 trilingual-collab-zh 反模式第 2 条。建议改「覆盖不到的路径不受保护」。

### 公平性正面确认

- Python/Go 的优点均如实呈现：Python 生态最厚、Go 并发最顺手与云原生成熟度都明确写了；GIL、多进程序列化开销、race detector 的定性均技术上站得住，无稻草人。
- Rust 代价（学习曲线、编译时间、领域库缺口）在 1.2.4 明写，结论「赢三维输一维」与论证一致。
- 三段语言对照代码已标注「示意代码，非 octos 源码」，Go 段「编译通过、运行期数据竞争」表述准确；Rust 报错文案为示意，可接受。
- 所有 octos 侧论断均落在事实表支撑范围内（沙箱目录、Tool trait 约束、deny(unsafe_code)、Semaphore 配置均有源码锚点）。

### tech-reviewer 小结：critical 0 / major 0 / minor 3

---

## 三、structure-editor（结构与文风）

### critical

无。

### major

**M5. 破折号「——」全篇 45 处，规范预算为全篇 ≤2 处。**（trilingual-collab-zh 排版节；`grep -o '——' | wc -l` = 45）已明显成为节奏拐杖：仅 1.1.1 一节内就有 5 处。建议通读一遍，保留最多 2 处真正承担论证的（如第 7 行「三条同时成立时……」处），其余改逗号/冒号/括号或拆句。

**M6. 加粗 72 处，规范预算全篇 ≤10 处且仅限术语首定义。**（`grep -o '\*\*…\*\*' | wc -l` = 72）其中相当一部分是数字强调（**26**、**700,915**、**39**）与段落标签（**第一，…**），按规范应降为正体；保留「目录数 ≠ 成员数 ≠ 核心库数」一类真正的术语级强调即可。

### minor

**M7. 版本演化说明无显式块。** project.spec 写作纪律要求「版本演化说明」锚点；现有素材分散在 1.3.1（commit+日期锚点 ✅）、1.3.3（「包括本书 v1 版稿」）、1.4（v1→v2 章号平移），但 grep「版本演化」零命中。建议在 1.4 开头补一句显式声明（例：本章数字基于 9c157101，后续版本以 1.3.1 命令现算为准；v1 旧稿的 10 crate/13 万行数字全部作废），满足锚点检查。

**M8. 「不是 X，而是 Y」句式约 6 处，超规范 ≤4 处上限。** 第 7、13、105（「不是编码规约」）、146、171（「症状都不是…而是」）、173 行附近各一处。建议把装饰性的（如「不是人为划分，而是从依赖方向推导的客观结果」→「分层由依赖方向推导得出」）改直陈，保留 1-2 处真实对立。

**M9. 个别段落超长、密度偏高。** 第 17 行（1.1.1 首段约 400 字单段，含口径说明+频道枚举）与第 136 行（1.2.4 首段，两条链一句话带过）建议各拆为两段：前者把「口径括号」独立成句或脚注，后者把「向外 FFI 链」与「向外 plugin 链」分开。

**M10. 两处读者化反问接近自问自答边界。** 第 3 行定位块「难在哪里？为什么……形状？」与第 5 行「为什么不用 Python？……为什么不用 goroutine？」。均为标题回声/读者视角设问而非作者自问自答，可保留；若从严执行 project.spec「不出现自问自答式过渡句」，建议第 5 行改为「从 LangChain/AutoGen 过来的人第一反应是质疑语言选型」的陈述式。另 1.2.4 末「这笔账是划算的」接近金句收尾，建议改为具体结论（「对这三类工作负载，Rust 的编译期保证收益大于生态成本」）。

### 结构正面确认

- DDIA 叙事线完整：问题空间（1.1，三大挑战各有真实场景）→ 论证（1.2，四维对照）→ 拓扑（1.3，口径→分层→澄清→图）→ 地图（1.4 导览表）→ 回顾/延伸阅读/思考题，环环相扣，无断线。
- 章首定位块 ✅（四类读者分路指引具体到小节号）；章末延伸阅读 5 条均真实可用、与本章内容对应 ✅；思考题 5 道质量高（第 3、4 题直接复用本章拓扑事实）✅；导览表 21 章 + 附录齐全，与 OUTLINE.md v2 一致 ✅。
- 工程决策侧栏（mono-repo vs multi-repo）含 A/B/C 三方案利弊 + 具体理由（16 个 PR、lockfile、feature 组合爆炸），满足 spec「至少两个 alternative」且有深度 ✅。
- 字数与代码占比在预算内：正文约 5,800 汉字（另含大量英文术语），代码+图约占 27% < 30% 上限 ✅。

### structure-editor 小结：critical 0 / major 2 / minor 4

---

## 汇总与结论

| 视角 | critical | major | minor |
|---|---|---|---|
| fact-checker | 1 | 0 | 1 |
| tech-reviewer | 0 | 0 | 3 |
| structure-editor | 0 | 2 | 4 |
| **合计** | **1** | **2** | **8** |

**结论：暂不可定稿。** 唯一 critical（C1：workspace 成员数 39 → 38，章稿 5 处 + 事实表 1 处）是读者按本章自己给出的复现命令必被抓到的硬伤，必须先改；两处 major（破折号 45 处、加粗 72 处，均为 trilingual-collab-zh 明文预算的数倍超支）属一轮机械润色可清。修掉 C1/M5/M6 并顺手处理 8 条 minor 后，本章即达「零 critical、零 major，可定稿」状态——除此之外的事实、代码引用、拓扑图、叙事结构均干净。
