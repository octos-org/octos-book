# Ch19 Factcheck 报告(ch19-factcheck)

- 审查对象:`chapters/ch19-octoscode.md`(214 行,新增章)+ 镜像 `book/src/part4/ch19.md`
- 事实基准:`assets/ch19-facts.md`;源码只读 octoscode @ `1129fa33`、octos @ `9c157101`、herdr @ `fefe5c4f`(仅识别契约清单),三仓 HEAD 均实测与基准一致
- 基线防旧:开工 `cp` master 两份文件进工作区(`cmp` 213/214 行一致);审查期间 master 落了 C2 修复 `aa7554e`(仅改正文 1 行:103「八类输入一个入口」→「双入口折叠」+ 归档 techreview),已按 master HEAD `5c279dd` 复核:工作区副本与 master 仅此 1 行差异,全部 62 处行号锚判定不受影响(:138 两版同为 `:2247`,Major 成立);`1780f0d`(新增章 commit,自记「正文 5,235 汉字」)为 master 祖先,审查的即 master 最新基线
- 结论(文首):**修 1 Major + 2 Minor(三处行号单点替换)后可定稿**——事实面、数字面、机械面全部通过,唯一 Major 是 C2 已判未修的 `:2247`

## 分级汇总

| 级别 | 数量 | 内容 |
|---|---|---|
| Blocker | 0 | — |
| Major | 1 | 19.5(正文 :138)`LocalShellExec` 拦截写「传输层在 `octoscode/src/transport.rs:2247` 起的实现里先拦截它」,实测拦截在 `:2280`(`send` 内 `if let AppUiCommand::LocalShellExec`);`:2247` 处于 `bootstrap` 的 readonly 离线快照返回段。C2 techreview(`aa7554e`)已判 Major 并列入修复表,但该提交对正文的 diff 仅落了 M1 一行,**M2 未落盘**,master `5c279dd` 仍为 `:2247` |
| Minor | 2 | ① 19.3(:88)`AppUiEndpoint` 标 `transport.rs:190`,实测 `pub enum` 在 `:192`(`:190` 空行、`:191` derive),差 2 行;② 19.7(:144)`statusbar_idle` 写「在 `:30`」,实测 `id = "statusbar_idle"` 在 `:32`(`:30` 空行、`:31` `[[rules]]`),事实表 §6 同写 `:30`,同源错位 |
| 观察 | 2 | ① 字数口径:实测 5,235 汉字 vs brief 基准 5,147(+88,+1.7%);占比实测 4.4%(全书 CJK 118,657)或 4.0%(wc -m 17,870/447,140),brief 的 7.2% 两种口径均无法复现,疑基准记错,建议以 5,235 入册;② 19.5 Durability 服务端纪律列 4 条,原文档有 5 条(未提 backpressure 交付那条),但正文未声明穷举,客户端 4 条完整,不构成错误 |

## 检查清单逐项(附命令与计数)

### 1) 引用路径/越界/符号 —— 62 处行号锚逐一 `sed -n '<n>p'` 实测,0 越界,59 中 / 3 错

- 引用面普查:行号锚 62 处(octoscode 41 + octos ui_protocol/app_ui 15 + ARCHITECTURE 3 + herdr manifest 3),加文件级/符号级引用约 16 处,合计与 brief 的 78 处量级吻合;全部路径在对应基线仓库存在。
- brief 点名 13 锚全部**精确命中**:`main.rs:4`(`fn main() -> Result<()> {`)、`cli.rs:118`(`pub const DEFAULT_STDIO_COMMAND: &str = "octos serve --stdio --solo";` 逐字)、`backend_ensure.rs:113`、`transport.rs:238`(trait 三方法 `:239-242`)、`transport.rs:244`(build_backend)、`event_loop.rs:192`(`pub fn run`)、`store.rs:287`(struct Store)、`store.rs:423`(from_snapshot)、`store.rs:8241`(apply_client_event)、`store.rs:9063`(apply_event)、`model.rs:790`(AppUiCommand)、`ui_protocol.rs:4197`(UiCommand)、`ui_protocol.rs:6616`(UiNotification)。
- 「附近」措辞 4 处全部成立:`transport.rs:997 附近`(实测 :997 即 `OCTOSCODE_SHARED_INSTANCE` 注释行,精确)、`store.rs:291 附近`(:291 即 `SlashCommandOutcome` 文档注释首行,精确)、`event_loop.rs:830 附近`(fn 在 :829,:830 为函数体首行)、`event_loop.rs:786 附近`(fn 在 :783,:786 在函数体内)。
- 其余抽样全中(命令 `sed -n`):`main.rs:10/22`、`cli.rs:126/204/415/849`、`transport.rs:311/354/556/566/1585/2235/4542/4699`、`event_loop.rs:228/230/755/816/833起`(:755 为 drain_backend_events 的文档注释末行、:835 fn 在「:833 起」跨度内,按「起」口径算中)、`client_event.rs:25/132`、`autonomy.rs` 12 个符号(:35/59/66/76/83/90/97/120/131/158/170/248)逐行命中、`keymap.rs:1`(HELP 逐字)、`ui_protocol.rs:20/68/684/708/730/752/1553/1577/1777/1814/4760`、`app_ui.rs:146(into_protocol)/172(AppUiEvent)`、`ARCHITECTURE.md:3/666/713`。
- 错位 3 处即上表 1 Major + 2 Minor;0 越界(最大锚 `:9063` < 12,214 文件尾,herdr 锚 < 40 行文件尾)。

### 2) 数字 —— 全部实测命中(0 错)

`wc -l src/*.rs`:合计 **96,124** ✓、**26** 个顶层文件 ✓、store **43,935** ✓、model 12,884 ✓、transport 12,214 ✓、event_loop 8,655 ✓、app 6,286 ✓、backend_ensure 1,317 ✓、autonomy 1,192 ✓、tui_terminal 1,171 ✓、insert_history 1,602 ✓、main.rs 57 ✓;子目录 app/ 5、cmd/ 8、menu/ 10 ✓;「比第二名还多三万行」= 31,051 ✓;`wc -l crates/octos-core/src/ui_protocol.rs` = **7,221** ✓、24 pub enum / 223 pub struct / 47 pub const ✓(另有 pub fn 6、pub type 1 与正文不冲突);ARCHITECTURE.md 724 行 ✓,其滞后行数表引作 7,047/37,021 ✓(确为文档旧值);herdr manifest 40 行、3 规则、priority 1100/1000/900、region whole_recent 与 bottom_non_empty_lines(6) ✓;三段引文(ARCHITECTURE Scope、启动链代码、keymap HELP)与源文件逐词一致。

### 3) 机械项 —— 全过

mermaid 3 ✓(19.2 时序 / 19.4 流向 / 19.5 拓扑);代码 fence 另有 rust 3 ✓;破折号「——」**0** 处(≤2 达标);加粗 3 处(定位/工程决策框/版本演化说明,6 个 marker,≤15 达标);镜像 `cmp` 完全一致 ✓;黑话均有 gloss(reducer=函数式状态机、wire=线上契约、水合=冷启动快照折叠、重放/游标在文内展开),无未解释缩写;文末版本演化 note 三 SHA(1129fa33 / 9c157101 / fefe5c4f)与事实表基线一致 ✓;事实锚自称的 `assets/ch19-facts.md` 在仓库在位。

### 4) 字数与占比 —— 口径差异(观察,定稿无碍)

实测汉字(CJK)5,235;brief 基准 5,147,差 +88(+1.7%),疑口径差(1780f0d commit message 自记即 5,235);占比实测 4.4%(5,235/118,657 全书汉字)/ 4.0%(wc -m 口径 17,870/447,140),brief 的 7.2% 无法用现有两种口径复现,建议定稿页以实测值入册。

### 5) 自证命令输出 —— 0

全章无 `sh` fence,代码 fence 仅 3 mermaid + 3 rust(均为源码摘录,非命令输出);无 `wc -l`/`sed -n` 等命令行或输出残留。

### 6) SUMMARY —— 在位

`book/src/SUMMARY.md` `# 第四部分:双环 — 外环驱动内环`(:40)+ `[第 19 章:octoscode:终端客户端与 UI Protocol](./part4/ch19.md)`(:42),part4/ch19.md、ch20、ch21 三章齐备。

## 与 C2 轮的衔接(重要)

`aa7554e` 的修复表列了 M1+M2 两项,commit message 亦称「LocalShellExec 拦截 :2280」,但该提交对正文两份文件的实际 diff 各只有 1 行(仅 M1「八类输入一个入口」→「八类输入双入口折叠」)。本轮逐字复核确认 master `5c279dd` 正文 :138 仍写 `:2247`。**建议补一次单行替换 `:2247`→`:2280`**(两份镜像同步),避免「报告已修、正文未改」的账实不符。

## 是否可定稿

**修 1 Major + 2 Minor 后可定稿。** 三处均为行号单点替换(`:2247`→`:2280`、`:190`→`:192`、manifest `:30`→`:32` 并同步事实表 §6),不动叙事、不动锚点体系、不动数字;其余 59 处行号锚、全部体量数字与机械项零差错。
