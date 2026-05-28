spec: task
name: "附录 B. 工具速查表"
inherits: project
tags: [appendix, reference, tools]
depends: [ch06-tool-system]
estimate: 0.5d
---

## 意图

提供当前工具注册表和 Codex-compatible coding 工具合约的速查表，包括名称、参数、分组归属和使用示例，
方便用户和贡献者快速查阅。

## 决策

- 从 `crates/octos-agent/src/tools/`、`crates/octos-agent/src/tools/policy.rs`、`crates/octos-cli/src/api/coding_tool_contract.rs` 源码提取工具定义
- 表格格式：工具名 | 分组 | 参数列表 | 一句话描述
- 每个分组（group:fs/web/search/sessions/runtime）单独列出成员

## 边界

### 允许修改
- octos-book/chapters/appendix-b-*.md
- octos-book/book/src/appendix/b-tool-reference.md
- octos-book/book-en/src/appendix/b-tool-reference.md

### 禁止做
- 不编造工具参数

## 完成条件

场景: 工具表完整
  测试: review_appendix_b_tools
  当 检查工具速查表
  那么 列出了核心内置工具、运行时注册工具、Serve/Admin 工具和插件/app-skill 工具类别
  并且 每个工具有名称、分组、参数签名、一句话描述
  并且 单独列出 Codex-compatible coding 工具面：`apply_patch`、`exec_command`、`write_stdin`、`bash`、`update_plan`、`request_user_input`、`spawn_agent`、`send_input`、`resume_agent`、`wait_agent`、`close_agent`、`delegate`、`view_image`、`tool_search`、`tool_suggest`、`image_generation`
  并且 说明 `image_generation` 当前 typed unsupported
  并且 说明 `send_input` 当前不是实时 conversational delivery

场景: 分组策略表
  测试: review_appendix_b_groups
  当 检查分组策略表
  那么 列出了所有源码中定义的工具分组（group:fs/web/search/sessions/runtime/memory/research/admin/media/delegated）
  并且 每个分组列出了包含的工具成员
  并且 `group:fs` 包含 `apply_patch`
  并且 `group:runtime` 包含 `exec_command`、`write_stdin`、`bash`
  并且 `group:sessions` 包含 `spawn_agent`、`send_input`、`resume_agent`、`wait_agent`、`close_agent`、`delegate`
