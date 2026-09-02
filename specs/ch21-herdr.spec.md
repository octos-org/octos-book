spec: task
name: "Ch21. herdr 与外环运维实务(v2 新增,第四部分)"
inherits: project
tags: [part4, herdr, operations, rewrite-v2, new-chapter]
depends: [ch20-octoloop]
estimate: 1.5d
---

## 意图

新增第 21 章。herdr 是后台常驻的终端工作区服务:终端住在它里面,agent 通过 CLI 与 socket API
互相发现、唤醒、等待。外环靠它发现内环窗格(`herdr agent list`)、注入用户消息层级的提示
(`herdr agent prompt`,`src/cli/agent.rs`)、读屏观测(`herdr pane read`)、开窗格(`herdr pane split --cwd`)。
octoscode 的识别契约在 `src/detect/manifests/octoscode.toml`(三条规则:approval_blocked / statusbar_working / …)。
本章是运维实务:上岗清单、双哨(正 ACK + 负 events.jsonl)、重启硬清单、常见坑(macOS 缺 flock、
zig 构建、代理)。

## 决策

- 事实表先行: `assets/ch21-facts.md` 列 herdr `README.md` 的功能要点、`src/cli/agent.rs` 与 `src/cli/pane.rs` 的 usage 字符串(agent list/prompt/wait/read、pane split/run/read/send-keys)、`octoscode.toml` 三条规则的 id/state/priority;每项附命令(仓库根 `/Users/zhangalex/Work/Projects/FW/herdr`)
- 文档依据: `octoscode/docs/OLP_QUICKSTART.md`、`octoscode/docs/OLP_OUTER_BOOT.md` §0b/§2/§3/§7、`octoscode/.octos/loop.md`;herdr 上游文档只引用 README(不凭记忆写 herdr.dev 的 URL 内容)
- 叙事: herdr 模型(server + client,pane 状态 working/blocked/idle)→ 识别契约 → 外环三原语(发现 / 注入 / 观测)→ 上岗与重启清单 → 侦听哨配方(基线 + 子串)→ 平台坑与降级(tmux send-keys)
- 版本事实: herdr 0.8.2,octoscode 识别在 fork `feat/octoscode-agent` 分支;写明这一点
- 图表: 外环-herdr-内环拓扑图、一次注入的时序图、双哨状态图
- 工程决策侧栏: 为什么注入走 TUI 用户消息层级而不是 API
- SUMMARY.md 追加本章;分析基线 herdr feat/octoscode-agent @ fefe5c4f

## 边界

### 允许修改
- octos-book/chapters/ch21-herdr.md
- octos-book/book/src/part4/ch21.md
- octos-book/book/src/SUMMARY.md
- octos-book/assets/ch21-*

### 禁止做
- 不修改 octos / octoscode / herdr 源码仓库
- 不复述 Ch20 的协议条款

## 排除范围

- herdr 插件系统
- 远程/ssh 场景

## 完成条件

场景: 事实表可复现
  测试: review_ch21_facts_sheet
  假设 `assets/ch21-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 usage 字符串与 manifest 规则与命令输出一致

场景: 三原语各有源码依据
  测试: review_ch21_primitives
  当 阅读发现/注入/观测小节
  那么 每个原语引用 `herdr/src/cli/*.rs` 的 usage 行号

场景: 识别契约准确
  测试: review_ch21_manifest
  当 阅读识别契约小节
  那么 三条规则的 id、state、priority 与 `octoscode.toml` 一致

场景: 清单可执行
  测试: review_ch21_checklists
  当 阅读上岗与重启清单
  那么 每一步是可复制执行的命令或可核对的状态,并与 `OLP_OUTER_BOOT.md` §0b 一致

场景: SUMMARY 已追加
  测试: review_ch21_summary_entry
  当 检查 `book/src/SUMMARY.md`
  那么 含第 21 章条目指向 `./part4/ch21.md`

场景: 引用零失效
  测试: review_ch21_refs_valid
  当 提取正文全部源码路径与行号引用并对照当前仓库
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号
