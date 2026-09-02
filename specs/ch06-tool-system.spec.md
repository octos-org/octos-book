spec: task
name: "Ch6. 工具系统:按能力域组织的 59 个工具源文件(v2 重写)"
inherits: project
tags: [part2, tools, registry, policy, rewrite-v2]
depends: [ch05-agent-loop]
estimate: 2d
---

## 意图

重写第 6 章。旧稿「14 个内置工具 + LRU 淘汰」的骨架已不成立:`crates/octos-agent/src/tools/`
在 2026-09-02 有 59 个源文件,LRU 工具延迟激活在 RFC-0(`172fb2be`,#1289)中连同
`activate_tools.rs` 一并删除,只保留 `spawn_only` 自动后台化。本章改为按能力域讲工具家族,
再讲 `Tool` trait、`ToolRegistry` 的三种构造与六处注册路径、`ToolPolicy` 的 deny-wins 语义、
参数与路径安全,以及 `write_grant` / `read_window` / `recall` 这类新增治理工具。Ch16 的封闭
注册表与 Ch18 的 goal/peer 工具都建立在本章的注册与策略语义上。

## 决策

- 事实表先行: `assets/ch06-facts.md` 列出 tools/ 下 59 个源文件的首行 `//!` 文档、每个工具的 `fn name()` 返回值、所属能力域、行数与生成命令;正文工具名与分组只准取自事实表
- 能力域分组(以事实表核实为准,允许微调归属): 文件读写(read_file、read_window、write_file、edit_file、diff_edit、apply_patch、write_grant、replacer)/ 代码检索(glob_tool、grep_tool、code_structure)/ 执行与版本控制(shell、check、git、workspace_history、check_workspace_contract)/ 网络(web_fetch、web_search、site_crawl、deep_search、http、ssrf、research_utils、synthesize_research)/ 记忆(save_memory、recall_memory、memory_note、record_memory_use、recall)/ 委派与后台(spawn、delegate、mcp_agent、check_background_tasks、read_task_output、peer_handoff、peer_list、peer_gather、peer_respond、peer_send_input、peer_close)/ 通信(message、send_file、send_app_card、ask_user_question)/ 机器人(dora_bridge、robot_groups、mofa_make)/ 框架与治理(mod、registry、policy、args、tool_config、coding_tools、read_paging_probe、manage_skills、browser、admin)
- `Tool` trait 以 `crates/octos-agent/src/tools/mod.rs` 当前真实签名为准;typed `ToolContext`(M8.1)取代 task-local 的迁移在 mod.rs 顶部文档,必须讲
- 注册表: `ToolRegistry`(`registry.rs:127`)的 `with_builtins` / `with_builtins_and_sandbox` / `with_builtins_and_permissions`(`registry.rs:1243-1254` 附近)三种构造;`register_arc`、`apply_policy`(`registry.rs:869`)、`set_provider_policy`(`registry.rs:947`)
- 注册路径六处(每处一段,附路径): profile roster(`crates/octos-agent/src/assets/profiles/coding.json` + `crates/octos-agent/src/profile/mod.rs`,`9ecc5845` 的 lean coding roster 与 `tool_search` 逃生口)、`crates/octos-cli/src/commands/chat.rs`、`crates/octos-cli/src/commands/acp.rs`、`crates/octos-cli/src/commands/gateway/gateway_runtime.rs`、`crates/octos-cli/src/session_actor.rs`、MCP `crates/octos-agent/src/mcp.rs:532` 的 `register_tools`
- 曝光控制: 明确写「LRU 延迟已删除」并引用 `172fb2be`;`spawn_only`(`registry.rs:156-194` 附近)单独一节;不得复述旧稿的 `find_evictable` / `ToolLifecycle`
- 策略: `ToolPolicy { allow, deny, require_tags }`(`policy.rs:28-40`)、deny-wins、通配与分组;provider 级 `tool_policy_by_provider` 匹配顺序以当前源码为准
- 编码工具契约: `crates/octos-cli/src/api/coding_tool_contract.rs` 的 `coding.tool_contract.v1`、P0 required tools、tool status 词汇
- 新增治理工具三例: `write_grant.rs`(#1976 按路径写授权)、`read_window.rs`(#1638 窗口化读取,默认关闭)、`recall.rs`(#2131 重新物化被压缩替换的工具输出,与 Ch8 呼应)
- 安全: `args.rs` 的 `estimate_json_size` 与 1MB 上限、`resolve_path`、`read_no_follow` / `write_no_follow`、`ssrf.rs`;以当前源码行号为准
- 图表: 能力域工具家族图、注册路径六层叠加图、`ToolPolicy` 判定流程图、`spawn_only` 自动后台化时序
- 工程决策侧栏: 为什么删掉 LRU 延迟激活(RFC-0 的取舍)
- 镜像同步: `book/src/part2/ch06.md` 与 `chapters/ch06-*.md` 内容一致
- 分析基线: octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch06-*.md
- octos-book/book/src/part2/ch06.md
- octos-book/assets/ch06-*

### 禁止做
- 不讲沙箱后端(Ch7)、压缩算法(Ch8)、MCP 客户端迁移细节(Ch9)、fleet 封闭注册表(Ch16)
- 不修改 octos 源码仓库
- 不保留旧稿中已删除机制(LRU、activate_tools、find_evictable、ToolLifecycle)的任何描述,除非明确标注为「已删除」的历史

## 排除范围

- 单个工具的完整参数手册(附录 B)
- 沙箱与权限模型(Ch7)

## 完成条件

场景: 事实表可复现
  测试: review_ch06_facts_sheet
  假设 `assets/ch06-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 59 个源文件的首行文档与行数与命令输出一致
  并且 每个工具的 `fn name()` 返回值与事实表一致

场景: 能力域分组覆盖全部工具
  测试: review_ch06_domain_grouping
  当 阅读能力域小节
  那么 事实表里每个工具都被归入恰一个能力域
  并且 每个能力域至少一处源码引用

场景: LRU 删除事实写明
  测试: review_ch06_lru_removed
  当 在正文检索 LRU、activate_tools、find_evictable、ToolLifecycle
  那么 只出现在明确标注「已于 172fb2be 删除」的历史说明里
  并且 `spawn_only` 小节引用 `registry.rs` 实际行号

场景: 注册路径六处齐全
  测试: review_ch06_registration_paths
  当 阅读注册路径小节
  那么 六处注册路径各有路径引用
  并且 lean coding roster 与 `tool_search` 逃生口引用 `9ecc5845` 所改文件

场景: 策略语义准确
  测试: review_ch06_policy
  当 阅读 `ToolPolicy` 小节与判定流程图
  那么 allow / deny / require_tags 三维与 deny-wins 的说明能在 `policy.rs` 与 `registry.rs:869-947` 附近找到依据
  并且 `apply_policy` 与 `set_provider_policy` 的区别写明

场景: 新增治理工具有源码依据
  测试: review_ch06_governance_tools
  当 阅读 write_grant / read_window / recall 小节
  那么 三者各引用对应文件行号与引入 issue 号
  并且 `read_window` 写明默认关闭

场景: 引用零失效
  测试: review_ch06_refs_valid
  当 提取正文全部 `crates/...rs:行号` 引用并对照当前源码
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号

场景: 旧数字零残留
  测试: review_ch06_no_stale_numbers
  当 在正文检索「14 个内置工具」「14 个工具」
  那么 一处都不出现
