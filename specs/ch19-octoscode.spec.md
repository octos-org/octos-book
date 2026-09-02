spec: task
name: "Ch19. octoscode：终端客户端与 UI Protocol(v2 新增,第四部分)"
inherits: project
tags: [part4, octoscode, ui-protocol, rewrite-v2, new-chapter]
depends: [ch14-runtime-modes, ch18-goal-peer]
estimate: 2d
---

## 意图

新增第 19 章,开启第四部分「双环」。octoscode 是不跑 agent、不执行工具的纯客户端,经 stdio 把
`octos serve --stdio --solo` 挂进 TUI:`src/main.rs`(57 行)→ `cli.rs`(`DEFAULT_STDIO_COMMAND` :118)→
`backend_ensure.rs`(首启自动安装 octos)→ `transport.rs`(`AppUiBackend` / `build_backend`)→
`event_loop.rs`(`run`)→ `store.rs`(reducer,约 4.4 万行含测试)→ `model.rs`(`AppUiCommand`);
`autonomy.rs` 承载 goal/peer 的客户端侧。wire 类型在 `crates/octos-core/src/ui_protocol.rs`(与 Ch2 互引)。

## 决策

- 事实表先行: `assets/ch19-facts.md` 列 octoscode `src/` 顶层文件的行数与首行文档、上述关键符号行号、`docs/ARCHITECTURE.md` 的章节标题;每项附命令(仓库根 `/Users/zhangalex/Work/Projects/FW/octoscode`)
- 叙事: 客户端边界(为什么不执行工具)→ 启动链与自动安装 → 传输层(stdio vs `--endpoint` WS)→ reducer 与命令模型 → Peer Dock / goal 面板 → 与 herdr 的识别契约(`herdr/src/detect/manifests/octoscode.toml` 三条规则,「详见第 21 章」)
- 引用格式: octoscode 路径写为 `octoscode/src/xxx.rs:行号`,octos 路径保持 `crates/...`
- 图表: 启动链时序图、UI Protocol 消息流图、reducer 状态图(取主干)
- 工程决策侧栏: 哑客户端(Client 是哑的)的取舍
- SUMMARY.md 新增「第四部分:双环」并追加本章;分析基线 octoscode main @ 1129fa33、octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch19-octoscode.md
- octos-book/book/src/part4/ch19.md
- octos-book/book/src/SUMMARY.md
- octos-book/assets/ch19-*

### 禁止做
- 不修改 octos / octoscode / herdr 源码仓库
- 不讲 OLP 纪律(Ch20)
- 不复述 Ch18 的服务端 goal/peer 机制

## 排除范围

- TUI 主题/键位等纯 UI 细节
- OLP 协议(Ch20)

## 完成条件

场景: 事实表可复现
  测试: review_ch19_facts_sheet
  假设 `assets/ch19-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 文件行数、符号行号与命令输出一致

场景: 启动链准确
  测试: review_ch19_boot_chain
  当 阅读启动链小节与时序图
  那么 main → cli → backend_ensure → transport → event_loop 每步引用 `octoscode/src/*.rs` 实际行号
  并且 `DEFAULT_STDIO_COMMAND` 值与源码一致

场景: 哑客户端边界写明
  测试: review_ch19_dumb_client
  当 阅读客户端边界小节
  那么 明确写出不执行工具、不跑 agent,并引用 `docs/ARCHITECTURE.md` 对应段落

场景: SUMMARY 已新增第四部分
  测试: review_ch19_summary_part4
  当 检查 `book/src/SUMMARY.md`
  那么 含「第四部分」标题与第 19 章条目指向 `./part4/ch19.md`

场景: 引用零失效
  测试: review_ch19_refs_valid
  当 提取正文全部源码路径与行号引用并对照当前仓库
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
