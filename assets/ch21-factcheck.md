# Ch21 factcheck 报告(ch21-factcheck / lane cheap)

- 审查对象:`chapters/ch21-herdr.md`(master `ad387d1` 工作区副本,md5 `796881f8` 与 `book/src/part4/ch21.md` 一致;e42e2f9 之后该两文件零改动,基线成立)。
- 事实基准:`assets/ch21-facts.md`(2026-09-03)。源码基线:herdr @ `fefe5c4f`(工作区 clean)、octos @ `9c157101`、octoscode 工作区(文档/`backend_ensure.rs`)。全部计数来自本次会话命令输出,未目测。

## 汇总(逐项计数)

| # | 检查项 | 命令(摘要) | 结果 | 判定 |
|---|---|---|---|---|
| 1 | `herdr/src/` 前缀引用数 | `grep -o 'herdr/src/[A-Za-z0-9_./-]*\.rs…' \| wc -l` | **54** 处(21 文件;去重 file:line 46 对) | ✅ 与基线要求一致 |
| 1a | 越界/裸引用(无 `herdr\|octoscode\|octos\|crates` 前缀的 `.rs`) | `grep -o -E '[A-Za-z0-9_./-]+\.rs(:[0-9]+)?' \| grep -v -E '^(herdr\|octoscode\|octos\|crates)/'` | **0** 条 | ✅ |
| 1b | 引用符号逐一对源(54 处全部 sed/awk 复核) | 见 §2 明细 | 47 处 ✅ / **6 处行号错**(M1、M2)/ 1 处区间口径瑕疵(m1/m2) | ⚠️ 2 Major |
| 2a | 245 文件 / 229,696 行 | `find src -name '*.rs' \| wc -l`;`…-exec cat {} + \| wc -l` | 245 / 229696 | ✅ |
| 2b | 顶层 37 / 29,927;app 54/65,400;mod.rs 6,606;actions.rs 6,155;api.rs 2,303;agent.rs 949;pane.rs 2,108 | `ls src/*.rs \| wc -l` 等 | 全部逐一相符 | ✅ |
| 2c | 识别清单 40 行;`Agent::ALL` 24(:71);`SCREEN_MANIFEST_AGENTS` 22;octoscode.toml version `2026.08.23.1`、priority 1100/1000/900 | `wc -l`、`sed -n` | 40 ✅;ALL 24 ✅ :71 ✅;22 ✅;version/priority ✅ | ✅ |
| 3a | mermaid 3(无 pie) | `grep -c '```mermaid'` | 3(flowchart/sequence/stateDiagram) | ✅ |
| 3b | `——` ≤2 | `grep -o '——' \| wc -l` | 2 | ✅ |
| 3c | 加粗 ≤15 | `grep -o '\*\*' \| wc -l` | 12 个标记(6 处) | ✅ |
| 3d | 章内锚点(内部跳转链接) | `grep '\](#'` | 0 | ✅ |
| 3e | 版本演化说明 | grep | 1 处(章末引用块) | ✅ |
| 3f | 黑话(闭环/抓手/赋能/颗粒度/底层逻辑/心智/打法/对齐等 9 词扫描) | for-grep | 仅「落地」×2(黑名单原文未在手边,请按统稿清单终核) | ⚠️ 待核 |
| 4a | 字数(汉字,`\p{Han}`) | perl 全章 / 去代码块 | 5,606 / 5,395 — 过 5,100 线 ✅ | ✅ |
| 4b | 占比 13% | 全书 21 章 Han 实测 130,405 | 5,606/130,405 = **4.3%**(part4 内 33.6%);任何自然口径均不复现 13% | ⚠️ 口径待确认(疑为「全书≈13 万字」之误记,非章错误) |
| 5 | 自证命令输出 | 通读 + grep `实测/复跑/命令输出` | 0 处粘贴输出;仅版本演化块的叙述性声明与指向 facts 文件的延伸阅读 | ✅ |
| 6 | SUMMARY 第 21 章条目 | `grep -n 'ch21' book/src/SUMMARY.md` | `:44:- [第 21 章:herdr 与外环运维实务](./part4/ch21.md)` | ✅ |
| 7 | 镜像一致 | `cmp chapters/ch21-herdr.md book/src/part4/ch21.md` | IDENTICAL | ✅ |

## 分级明细

### Major(2 项,均属行号错位;章与 facts.md 同错,疑事实表制作时锚点偏移)

- **M1 `herdr/src/detect/mod.rs` 五处行号漂移**(章 :54、:56 行):
  - `AgentState` 枚举:章写 `:13` → 实 **`:11`**;`Idle` `:15` → 实 **`:13`**;`Working` `:17` → 实 **`:15`**;`Blocked` `:18` → 实 **`:17`**(`Unknown :19` ✅)。实测:`sed -n '11,20p'`。
  - `SCREEN_MANIFEST_AGENTS`:章写 `:96` → 实 **`:98`**;其中 `Self::Octoscode`:章写 `:118` → 实 **`:120`**。实测:`awk NR>=95&&NR<=121`。
  - `agent_label`:章写 `:144` → 实 **`:124`**(其 Octoscode 分支 `:149` ✅)。
  - `parse_agent_label`:章写 `:207` → 实 **`:188`**(Octoscode 别名分支 `:225` ✅)。
  - 同段正确的引用:`Agent::Octoscode :67` ✅、`ALL :71` ✅、`manifest.rs:256` ✅、`interactive_agent_executable :153/:184` ✅。
- **M2 `herdr/src/api/mod.rs:31` SOCKET_PATH_ENV_VAR**(章 :46 行):章写 `:31` → 实 **`:20`**(`pub const SOCKET_PATH_ENV_VAR…`,`:31` 实为 Method 匹配臂)。实测:`grep -n 'SOCKET_PATH_ENV_VAR' src/api/mod.rs`。

### Minor(2 项)

- m1 `AgentPromptParams` 字段区间(章 :115):「`:178` 至 `:180`」→ 实字段 **`:177`-`:180`**(`target :177`、`text :178`、`wait :180`;`:179` 为 serde 属性)。结构体 `:176` ✅。
- m2 blocked 门区间(章 :148):「`:81` 至 `:89`」→ 门体 if 实在 **`:82`**,错误串收口在 `:90`(`:81` 为上句 `};`)。语义无误,区间建议 `:82` 至 `:90`。

### 可不计(核过但放行)

- `--until/--timeout` 配 `--wait` 两道检查:章写 `:825`、`:828` —— 实第一道 if 在 `:824`(`:825` 是其报错行),第二道 `:828` ✅;两行号均落在各自检查体内,放行。
- `AgentDetection`「`:25` 起」:结构声明在 `:24`,`:25` 起为字段;「起」字表述可容,放行。
- facts.md §4.1 `run_pane_command` 分发行号 `:40 wait-output`/`:44 run` → 实 `:38`/`:43`:**章未引用这些行号**(只列命令名),不构成章错误,建议下轮修事实表。

### 全对项(抽样列示,均为 `sed -n` 实测)

`cli.rs:95/125/127/762/897/899-903/910-915`;`cli/agent.rs:12/19-29/41/91/438/771/922/923-941`;`cli/pane.rs:12/455/473/623/624/733/1047/1049/1050-1056`;`app/api/agents.rs:13/62/63-65/95-98/105-112/112/126`(300ms delay、四门顺序、Copilot focus-gained 特例、`runtime_hosts_agent` 于 `app/agents.rs:421` 全部属实);`session.rs:169/173/177/183`;`config/io.rs:30`;`client/mod.rs:1`、`layout.rs:1`、`server/headless.rs:1`、`events.rs:1/56/58/60/66/76`;`api/schema.rs:107/127/175`;`schema/common.rs:151/152-156`(五态含 done);`api/wait.rs:22/132/177/661`;octoscode.toml 三规则行号与逐字内容;`README.md:29/31/35/37/71`;`OLP_QUICKSTART.md:35/151/162`、`OLP_OUTER_BOOT.md` 第 0b(:16-:32)/第 2(:47-:58)/第 3(:60-:72)节、`loop.md:5-9`;`backend_ensure.rs:60 OPT_OUT_ENV`。交叉仓引用均带 `octoscode/` 相对路径前缀 ✅。

## 是否可定稿

**不可定稿(2 Major / 2 Minor),但修复成本极低**:改章内 6 处行号(detect/mod.rs 五处 + api/mod.rs 一处,集中在 :54、:56、:46 三行)并同步 `assets/ch21-facts.md` §4.4/§4.5 的同源错误;m1/m2 顺带收口。修完即可定稿——机械项、数字、镜像、SUMMARY、自证全部通过,54 处引用仅 6 处行号漂移、零符号错误、零越界。占比「13%」无法按实测口径复现(实测 4.3%),请外环确认该指标定义;若指「全书约 13 万字」,则该项无错。
