# 第 14 章事实核查报告(Ch14 factcheck,C1)

- **审查对象**: `chapters/ch14-runtime-modes.md`(372 行,与 `book/src/part3/ch14.md` 镜像 `cmp` 一致;master 定稿 87def5b,正文未再改动)
- **事实基准**: `assets/ch14-facts.md` @ 3728daa;源码 `/Users/zhangalex/Work/Projects/FW/octos` 只读 @ `9c157101`(完整 hash 复核一致,2026-09-02)
- **核查日期**: 2026-09-03;方法:逐条 grep/sed 源码行、二进制复跑(`octos --help`、REST 口径命令 ×2)

## 汇总

引用路径/越界/符号共核 **63 处行号锚点 + 15 组数字**,命中 60/63;发现 **P2 ×3、P3 ×7,无 P1**。三处 P2 全部是字符级小修(合计约 9 处改动),修复后即可定稿。

| 分级 | 发现 | 数量 |
|---|---|---|
| P1(事实硬伤/错误代码语义) | 无 | 0 |
| P2(与源码/基准不符,须修) | 子命令计数 27→28;main.rs 三处锚点漂移;bus 章号「第 10 章」应为第 11 章 | 3 |
| P3(口径/措辞/前向引用,建议修或挂账) | gateway 目录行数不含 adapters/;config.rs:273 锚点模糊;17/18 章前向引用未落地;Gateway::init 未标文件;旧 ch13 文件磁盘残留;issue 号无法源码复核;占比分母不可独立复核 | 7 |

## P2(须修后才可定稿)

### P2-1 「27 个用户子命令」实为 28(5 处,含事实表同错)
章节自列清单即 28 个名字:`account acp admin auth channels chat config cron doctor docs init inbox mcp memory profile mcp-serve serve skills status steer update gateway goal ledger clean completions office peer`。
```
$ awk 'NR>=114&&NR<=180' commands/mod.rs | grep -cE '^\s+[A-Z][A-Za-z]+\('   # @9c157101
28
$ octos --help | sed -n '/^Commands:/,/^$/p' | grep -oE '^  [a-z][a-z-]*' | grep -vc '^  help$'
28        # 含 help 共 29 行,与事实表「29 行命令(含 help)」自洽,28≠27
```
章节出现处:行 7(「27 个用户子命令」)、行 17(「27 个变体」)、行 32(「实测列出 27 个」)、行 363 思考题 4(「27 个命令结构体」)、行 370 版本演化(「27 个子命令逐字核对」)。事实表第 13 行「27 个用户子命令」同错(其复现命令输出即为 28)。修法:5+1 处 27→28。

### P2-2 main.rs 三处锚点漂移(约 2 行位移)
```
main.rs:80   octos_cli::config_layer::apply(&mut args, &matches)?;   # 章节写 84-84 ❌ 84-86 是 log_dir 块
main.rs:101  args.command.execute()                                  # 章节写 113 ❌
main.rs:85-86 #[cfg(feature="api")] if let Command::Serve …           # 「serve 日志目录门控」章节写 71 ❌(71 是 chaos-test 块)
```
出处:14.1.1 两处(`main.rs:84-86`、`main.rs:113`)+ 14.1.1 其二(`main.rs:71`)。事实表 18 行同错(71→85-86、84-86→80、113→101),需事实表与章节同步改。`fn main():61`、`wc -l 268` 均正确。

### P2-3 定位段「第 10 章(octos-bus)」应为第 11 章
SUMMARY 第 29 行:bus 已改号第 11 章。行 3「前置依赖:第 5 章(Agent Loop)、第 10 章(octos-bus)」→「第 11 章」。同段「第 18 章」前向引用另列 P3-3。

## P3(建议修/挂账)

1. **gateway 目录行数口径**:「`gateway/` 目录 7,595 行」按事实表命令 `wc -l gateway/*.rs`(顶层 10 文件)复算无误,但未含子目录 `gateway/adapters/*.rs`(10 文件,848 行;实测目录全树 8,443)。19,485 合计自洽(bc 复核 ✓),建议措辞限定「gateway/ 顶层 10 文件」或将口径扩为全树并级联更新 19,485。
2. **`config.rs:273 附近` typed schema 注释锚点模糊**:265–291 实为 plugins/`cli.<cmd>` 分层文档;「拒绝未知字段」语义最近注释在 `:81`(embedding「cannot be silently…」)。「附近」措辞成立,建议改指实际行。
3. **第 17/18 章前向引用未落地**:第 17 章 ×1、第 18 章 ×3。与已定稿 ch12 的惯例一致(ch12 同引 16/18 章 ×8),可保留;ch17/18 改号落地时统一复核。
4. **14.1.2 表 `Gateway::init`:226 未标文件**:实位于 `gateway_runtime.rs:226`(非 mod.rs)。事实表同样省略;runtime `run`:1789 已标注,建议补一致性标注。
5. **旧 `chapters/ch13-runtime-modes.md` 磁盘残留**:git 已 rm(`git ls-files` 为空,d1b1173 注明),SUMMARY 无引用,不影响构建;工作区还有 ch06-tool-system-draft.md 等同类未跟踪残留,可由清理批次处理。
6. **issue 号无法源码复核**:#417(端口选段)、#2166 未见对应注释;#713(serve.rs:1322 ✓)、#1774(config_watcher.rs:266/467 ✓)已在源码注释验证。风险低,挂账即可。
7. **占比 18.1% 分母不可独立复核**:分子 5,106 继承 87def5b 口径;分母含未重写章,本轮未复算,维持事实表口径。

## 核查清单逐项计数

**1) 引用路径/越界/符号(60/63 通过,3 处即 P2-1/2)**
- `mod.rs`:`pub enum Command`:114 ✓;execute match:381 ✓;引文块 381-399 逐字 ✓(Account/Acp/…/McpServe/`#[cfg]`Serve 顺序一致);398-399 ✓
- `main.rs`:61 ✓、268 ✓;80/101/85-86 三处 ✗(P2-2)
- `serve.rs`(wc 2,849 ✓):320 ✓、324(50080)✓、334 ✓、464-471(stdio→None)✓、487「附近」(const 490)✓、539 ✓、549 ✓、673/818 ✓、750 ✓、764 ✓、775 ✓、1316 起 ✓、1541-1546 引文**逐字** ✓、1778 ✓、1969 ✓、#713:1322 ✓、injection-env denylist:1855 ✓、`--instance-data-dir`:355 ✓
- `mcp_serve.rs`(wc 1,138 ✓):72(Stdio 默认)✓、79 ✓、103 ✓、485 ✓、bind 默认 127.0.0.1:4033:86 ✓、token 拒绝:185-186 ✓
- `mcp_server.rs`(wc 1,044 ✓):66 ✓、169 ✓、201 ✓、268 ✓
- `coding_tool_contract.rs`:12 ✓、13(契约 id)✓、19-28 六状态 ✓(19/20/21/22/23/28)
- `ui_protocol_transport.rs`:2037/2042/2047/2052/2057 `has_ui_feature` ✓
- `config_watcher.rs`(wc 608 ✓):17-25 枚举引文**逐字** ✓、28 ✓、44 ✓、67 ✓、87 ✓、241 ✓、防误报注释 136-150 ✓(135-151)、九项重启清单全命中(252/255/258/261/264/270/277/284/309)、#1774 ✓
- `config.rs`(wc 3,790 ✓):26 ✓、110 ✓、184 ✓、618 ✓、1740 ✓、1749 ✓、1770 ✓;:273 模糊(P3-2)
- `config_layer.rs`(wc 543 ✓):优先级文档 5-8 ✓、40 ✓、48 ✓、value_source:15 ✓、危险开关排除:34 ✓
- `profiles.rs`(wc 7,003 ✓):181 ✓、741 ✓、814 ✓、824 ✓、881 ✓;`profile_factory.rs` 108/149 keychain ✓
- `chat.rs`(wc 4,143 ✓):37 ✓、828 ✓、1043 ✓;`acp.rs`(wc 3,024 ✓):100 ✓、160 ✓、1163 ✓;gateway/mod.rs 45/159/178 ✓、gateway_runtime.rs 1789 ✓(226 未标文件,P3-4)
- `octoscode/src/cli.rs:118` DEFAULT_STDIO_COMMAND **逐字** ✓(`octos serve --stdio --solo`)
- Cargo.toml:[features]:142 ✓、embed-llama 系:147-149 ✓、api:154(含 octos-bus/api+matrix)✓
- 路径越界:0(全部 `../octos/crates/...` 与实际相符)

**2) 数字**
- 5 运行面 ✓(chat/gateway/serve/mcp-serve/acp)
- 7 入口合计 19,485 ✓(bc 复算;gateway 口径见 P3-1)
- 配置四件套 3,790+7,003+608+543=11,944 ✓
- REST 67 ✓(口径命令复跑 ×2 均 67;api/ 42 个 .rs ✓;91→67 演化说明在位)
- 端口 50080 ✓(serve.rs:324;50080∈IANA 动态段 49152-65535 ✓;#417 见 P3-6)
- **27 子命令 ✗ → 28**(octos --help 复跑,P2-1)

**3) 机械项**
- 锚点:14.1→14.8 连续 ✓(26 个标题);图 14-1…14-5 连续各 1 次 ✓;mermaid 5 ✓
- 镜像:`cmp chapters/ch14-runtime-modes.md book/src/part3/ch14.md` 一致 ✓
- 「——」:0(≤2 ✓);加粗 7 对(≤15 ✓);黑话首次出现均有释义 ✓
- 引文块 3 处(mod.rs/serve.rs/config_watcher.rs)与源码逐字一致 ✓

**4) 字数与占比**
- master 实测 5,106(87def5b 提交口径;正文剔除代码/表格/标题口径实测 5,038,同量级)
- 14.4.2 stdout 段实测 ≈266 汉字,与「小补 133 字」提交量级吻合;占比 18.1% 分母未独立复算(P3-7)

**5) SUMMARY 与旧章**
- SUMMARY 第 32 行「第 14 章:运行模式与配置体系 → part3/ch14.md」在位 ✓;part2/3 全部条目改号连续 ✓
- 旧 ch13-runtime-modes:git 已删、无引用 ✓(磁盘残留见 P3-5);新 ch13-pipeline.md 在位 ✓

## 是否可定稿

**暂不可,修复 3 项 P2 后即可定稿。** P2-1(27→28,6 处含事实表)、P2-2(main.rs 三锚点,章/表同步)、P2-3(第 10 章→第 11 章)均为机械替换,预计一次 commit 完成;P3 各项不阻塞,建议随修随挂账。修复后建议复审范围仅:行 3/7/17/32/363/370 + 14.1.1 三处 main.rs 行号。
