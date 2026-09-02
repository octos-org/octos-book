# 附录 F：OLP v2 协议速查

> **定位**:本附录是 OLP(octos 外环协议 OctoLoop,当前版本 `olp/v2`)的一页纸速查:R 系列条款、ACK 定式、result.md frontmatter、黑板条目格式、外环上岗与重启清单、第五信道参数与车道模板。协议为什么这样设计、载体全景与实证分析见第 20 章,此处不重复;本附录只做一件事,把散在协议文档、上岗卡与源码里的可执行规则压成可直接对照的表,每张表附来源路径与行号,便于逐条复核。

术语约定(首次出现处统一解释,后文不再重复):外环(outer agent)指以计划、监控、审查、指导身份接入的外部强模型;内环(runtime)指 `octos serve` 驱动的 master/peers 执行体;operator 指人类操作者;黑板指各仓库 `.octos/OUTER_LOOP_REVIEW.md` 的 `Active` 区,是任务级指导的权威载体;第五信道指内环在 turn 内主动向外环发问的 MCP 问询信道。数据基线:octoscode 仓库 main @ 1129fa33。

导览:F.1 是 R 系列条款速查,按 R1 至 R7 顺序排列(R4b 为 R4 子条款一并收录);F.2 给出 ACK 定式语法与黑板条目的写入规范;F.3 是 result.md frontmatter v1 的六字段表;F.4 是外环上岗流程与内环重启后的巡检硬清单;F.5 是第五信道的参数、防滥用常量与 sub_providers 车道模板。使用方式建议:新外环上岗前按 F.4 顺序走一遍;写指导意见前对照 F.2 的条目要素;审查交付时用 F.3 校验 frontmatter、用 F.1 的 R2 复核验证声明;为任务选模型档位时查 F.5 的配对矩阵。

## F.1 R 系列条款速查

| 条款 | 关键语义 | 来源行号 |
|---|---|---|
| R1 ACK 义务 | 黑板 `Active` 区每条意见,内环执行后必须在条目下补一行 ACK;无 ACK 视为未读,外环有权打回交付。v1 起定式语法由契约测试 `olp_ack_lines_match_v1_grammar` 钉住 | octoscode/docs/OUTER_LOOP_PROTOCOL.md:52-58 |
| R2 诚实验证声明 | 每个交付必须声明三档验证级别之一:`verified`(跑过 `cargo test --all-targets` + clippy + fmt)、`partially-verified`(列出跑了什么)、`unverified`(说明原因);声称 verified 但复验不符视为协议违例,打回并记黑板 | 同上 :67-70 |
| R3 升级分级 | escalation 三级:内环自决(重试/换法)→ 外环裁决(技术取舍、方案批准)→ operator 裁决(权限审批、范围变更、对外动作);外环不得代按审批,operator 缺席时 escalation 保持 park | 同上 :71-73 |
| R4 工作区共存 | 多写者各自只 `git add` 自己改的文件,禁止 `git add -A`;改动即原子 commit;来源不明的 dirty 文件必须保留并报告,不得自动清理或提交 | 同上 :74-76 |
| R4b 树主权与自动围栏 | 多 goal 并行时主工作树只属一个 goal:撞车谓词(active goal 多于一个 / peer 目标分支与主树不符 / 主树有未围栏在途 peer)命中即自动开 worktree 围栏;主树 owner 持久化进 goal-ledger,非 owner 会话在主树跨分支 checkout 一律拒绝;防撞成为系统默认,外环 steer 只做边界补位。作为 R4 子条款,不升协议版本 | 同上 :77-88 |
| R5 指导幂等 | 外环意见带日期与唯一编号,只在 `Active` 区可执行;ACK 后移入历史区永不重放,重复投递以 ACK 为去重依据 | 同上 :89-90 |
| R6 版本协商 | 协议文档头部 `protocol: olp/vN`,`AGENTS.md` 引用同版本;信道语义变更必须升版本 | 同上 :103-104 |
| R7 主审权 OS 独占锁 | 多外环的主审权以 per-project 会话寿命 OS 锁为准:上岗必须经 `octoscode outer-duty hold --project P --signature S --duties D -- <agent>` 包裹启动,锁即 authority;`check` 仅观察绝不夺取;活锁接管只归 operator(终止旧 holder 后再 acquire),无 agent 自助强夺;metadata sidecar 与一切 TTL 仅诊断、绝不参与裁定;Linux-only(非 Linux 平台显式 unsupported 退出 2,Windows LockFileEx 另立条目),NFS 不适用。v2 新增(#38-r1) | 同上 :91-102 |

原文条目顺序为 R1、R2、R3、R4、R4b、R5、R7、R6(R7 插在 R6 之前),本表按编号重排,行号可径直回查。

## F.2 ACK 定式与黑板条目格式

ACK 定式语法(v1 起,`ACK` 行写在内环刚执行完的黑板条目之下):

```
ACK(done|wontdo|blocked): <说明>
```

来源:octoscode/docs/OUTER_LOOP_PROTOCOL.md:56-58。

| 定式 | 语义 | 说明字段要求 | 来源行号 |
|---|---|---|---|
| `ACK(done): …` | 已执行 | 写做了什么与证据(commit hash / 测试结果) | 同上 :60 |
| `ACK(wontdo): …` | 带证据的异议,不执行 | 写为何不做;分歧规则:外环对 wontdo 只能接受或升级 operator 裁决,不得对同一条目再次打回 | 同上 :61-62 |
| `ACK(blocked): …` | 被阻塞无法执行 | 写阻塞原因与解除条件 | 同上 :63 |

生效边界:v1 语法只约束 2026-08-24 起新增的 ACK 行,历史行不重写,由契约测试的生效日期分界豁免;说明部分自由文本,非空即可(同上 :65-66)。

黑板条目写入规范(来源:octoscode/docs/OLP_OUTER_BOOT.md §1):

| 要素 | 规范 | 来源行号 |
|---|---|---|
| 板位置 | 每仓库一块 `<repo>/.octos/OUTER_LOOP_REVIEW.md`;`docs/` 下同名文件是冻结快照,严禁写入 | OLP_OUTER_BOOT.md:36-37 |
| 写入方式 | 必须走原子追加助手 `scripts/olp-board-append.sh <板路径>`(正文从 stdin 喂),flock 互斥加自写登记 | 同上 :38-41 |
| 编号 | 先 `grep -oE '^### [0-9]+' <板> \| tail -1` 取当前最大号,加一使用 | 同上 :42 |
| 条目内容 | 自包含:背景、精确文件/行号、修法方向、验收标准、分支名(基于 main) | 同上 :43-44 |
| 预算档 | 修订 5-10M / 切片 10-20M / 战役 30-50M,条目中写明 | 同上 :44 |
| 推送纪律 | 条目写明「只 commit 不 push,主审复验后代推」 | 同上 :45 |

## F.3 result.md frontmatter v1 六字段

`peers/<slug>/result.md` 是内环到外环的每轮交付物,v1 起其 YAML frontmatter 必须包含恰好六个字段,契约测试 `olp_result_schema_fields_documented` 钉住该清单(来源:octoscode/docs/OUTER_LOOP_PROTOCOL.md:354-358)。

| 字段 | 类型 | 含义 | 来源行号 |
|---|---|---|---|
| `slug` | string | peer 的唯一标识(目录名) | 同上 :362 |
| `outcome` | string | 交付结论,取值 `complete` / `partial` / `blocked` / `failed` | 同上 :363 |
| `updated_unix` | integer | 最近更新的 Unix 时间戳(秒) | 同上 :364 |
| `turn` | integer | 该 peer 已运行的 turn 数 | 同上 :365 |
| `verified` | string | R2 验证级别:`verified` / `partially-verified` / `unverified` | 同上 :366 |
| `protocol` | string | 写入时遵循的协议版本,当前 `olp/v2` | 同上 :367 |

消费侧约定:未知字段必须忽略(forward compatibility),消费方按上述六字段取数,对其他字段不解释、不报错;`verified` 与 `protocol` 由 octos 侧写入(同上 :369-373)。

## F.4 外环上岗与重启硬清单

上岗流程(数据源:octoscode/docs/OLP_OUTER_BOOT.md 与 OUTER_LOOP_PROTOCOL.md 接入清单):

| 步骤 | 内容 | 来源行号 |
|---|---|---|
| 署名 | 选定署名 `外环(<名字>)`,所有黑板写入必须署名;多外环并存时每条目单一主审,他人条目只可署名批注,分歧升级 operator | OLP_OUTER_BOOT.md:10-14 |
| 取主审锁 | 以 `octoscode outer-duty hold --project <项目> --signature <署名> --duties <职责> -- <agent 启动命令>` 包裹启动;`check` 仅观察,stdout 恰一态 VACANT/Held/ERROR | 同上 :74-81 |
| 定数据根与监听 | 数据根 `~/.octos/instances/<cwd-hash>/profiles/<profile>/data`;tail serve 日志过滤 `peer-goal:\|escalation\|transitioned goal\|ERROR`;观测分投递、消费、执行三层,只看一层必误判 | OUTER_LOOP_PROTOCOL.md:126-134 |
| 读协议与黑板 | 读协议全文与黑板 `Active` 区了解当前指导,历史区仅用于审计 | 同上 :135-136 |

内环重启后的外环巡检硬清单,四步逐项核对,禁止「记一笔稍后补」(来源:OLP_OUTER_BOOT.md:16-19):

| 步骤 | 内容 | 来源行号 |
|---|---|---|
| 1. serve 起 | operator 亲手执行;免沙箱启动属信任决策,永不由 agent 代劳 | 同上 :20-21 |
| 2. `/loop resume` 外环必代 | 先 `/loop list` 取 id,再 `/loop resume <id>`;裸 resume 缺 id 会被拒。maintenance 心跳暂停时主机制仍健康,兜底瘫痪不可见,只能靠巡检发现 | 同上 :22-27 |
| 3. 双哨挂载 | 正信号哨(ACK 落板)加负信号哨(events.jsonl 的 `goal_transition blocked` 与 escalation);只盯正信号时,goal 熔断的沉默与「还在干活」不可区分 | 同上 :28-30 |
| 4. fallbacks 与会话快照核对 | fallbacks 已配置且新会话已完成快照;改配置不重启等于纸面保险,工具表在会话建立时快照、不回补 | 同上 :31-32 |

## F.5 第五信道参数与车道模板

第五信道由 `octoscode olp-mcp-serve` 子命令提供(#31 起纯 Rust 标准库实现,源文件 octoscode/src/olp_mcp.rs,共 406 行),暴露恰好两个 MCP 工具,供内环在 turn 内同步向外环发问或直通落板。工具注册表见 octoscode/src/olp_mcp.rs:328-352。

`ask_outer` 参数(三参全必填,required 声明在 octoscode/src/olp_mcp.rs:340):

| 参数 | 语义 | 校验 | 来源行号 |
|---|---|---|---|
| `question` | 问外环的问题 | 为空直接拒绝 | 同上 :197-198 |
| `context` | 卡在何处、相关状态 | 无额外校验 | 同上 :183、:336 |
| `tried` | 已自行尝试过什么 | 为空拒绝(防思考外包:先试再问) | 同上 :186-188、:32 |

防滥用常量与行为:

| 项 | 值 | 行为 | 来源行号 |
|---|---|---|---|
| 超时 | 90 秒(`ASK_TIMEOUT_SECS`) | 超时返回降级指引:按黑板既有指导推进,无法推进则以 `ACK(blocked)` 收场并注明问询 id | 同上 :25、:30、:248-251 |
| 配额 | 每片 3 次(`ASK_QUOTA_PER_SLICE`) | 超出返回拒绝话术,提示自行推进或改用 `report_blocked` | 同上 :27、:31、:193-195 |
| 轮询间隔 | 0.5 秒(`ASK_POLL_INTERVAL_SECS`) | 答案文件轮询节奏 | 同上 :26 |
| 信箱 | `~/.octos/outer/mcp/` 下 questions、answers、consumed 三级流转 | 取答后问答对归档 consumed 并删除原文件 | 同上 :109-111、:231-241 |
| 审计 | 落 `OUTER_LOOP_MCP.md`,署名固定 `MCP(ask_outer)` | 全程留痕 | 同上 :24、:28 |

`report_blocked` 参数:`reason`(为何阻塞)与 `needs`(需要什么解除),二者必填,空 reason 拒绝;直通落板,无信箱往返(同上 :255-272、:344-352)。

sub_providers 车道模板(v1 附开箱模板,契约测试 `olp_lane_template_parses` 钉住;来源:octoscode/docs/OUTER_LOOP_PROTOCOL.md:375-391):

| 车道 | model | description 要点 | 来源行号 |
|---|---|---|---|
| cheap | kimi/kimi-k2-turbo | 低成本高吞吐:机械、低风险、强可回滚的任务(文档、测试诊断、日志分类、格式化),做错代价是一次重跑 | 同上 :384-386 |
| strong | anthropic/claude-opus | 长链推理与跨文件架构判断(审查定级、wontdo 复核、多步调试),做错会污染主线判断 | 同上 :388-390 |

双环搭配矩阵(同上 :393-400):

| 工作性质 | 车道 |
|---|---|
| 分析(读代码、写摘要、分类盘点) | cheap |
| 验证(跑测试、复验 R2 声明、机械断言) | cheap |
| 实施(写生产代码、契约测试、schema 改动) | primary(主档,不走路由) |
| keeper(goal 推进、ledger 记账、状态判断) | primary |

矩阵理由:分析与验证的产出被外层审查兜底,错了可重跑;实施与 keeper 的产出直接进主线与账本,错误成本高,留在主档由 R2 与外层审查控质(同上 :402-403)。

## 版本演化说明

- v0 至 v1(2026-08-24 生效):R1 ACK 定式语法化(done/wontdo/blocked 与 wontdo 分歧规则);result.md frontmatter v1 schema 固化;sub_providers 车道模板(附录 A、B 随之定稿)。v1 语法只约束生效日起新增的 ACK 行(octoscode/docs/OUTER_LOOP_PROTOCOL.md:9-12)。
- v1 至 v2(2026-08-30 生效,#38-r1):新增 R7 主审权 OS 独占锁(outer-duty hold/check;锁即 authority、check 仅观察、活锁接管归 operator、metadata/TTL 仅诊断;Linux-only 单机 flock 加 PDEATHSIG,Windows 另立条目,NFS 不适用);`AGENTS.md` 引用同步 v2(同上 :14-17)。
- R4b 树主权与自动围栏系 octos #20-20c 移植,作为 R4 子条款收录,不升协议版本(同上 :88)。
- 后续:L3 平台扩展(R7 主审锁 macOS 支持)已于 2026-09-02 立项,守护 reaper 进程加 kqueue 复刻死亡耦合,信道语义不变、不升协议版本(同上 :167-172)。
- 本附录全部行号以 octoscode 仓库 main @ 1129fa33 为基线,后续协议演进请以仓库内文档为准。
