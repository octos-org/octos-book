spec: task
name: "附录 C. 配置参考(v2 重写,补 mcp_servers / sub_providers / validators / typed llm schema)"
inherits: project
tags: [appendix, reference, config]
depends: [ch13-runtime-modes]
estimate: 0.5d
---

## 意图

提供 `config.json` 所有字段的完整参考文档，包括类型、默认值、说明，
方便用户配置 octos。附录也覆盖 profile LLM 配置文件中 `config.llm` 的主模型与 fallback 模型结构。

## 决策

- 从 `crates/octos-cli/src/config.rs`、`profiles.rs` 和 `hooks.rs` 提取配置结构体定义
- 表格格式：字段路径 | 类型 | 默认值 | 说明
- 按功能分组(llm/provider、tools、hooks、gateway、serve、mcp_servers、sub_providers、validators、sandbox、memory);`config.rs` 当前约 174 个 pub 字段,逐项来源行号

- 三大新车道: `mcp_servers`(`crates/octos-agent/src/mcp.rs:53` `McpServerConfig`:name/command/args/env/url/headers/oauth/scopes)、`sub_providers`(`crates/octos-cli/src/config.rs:618` `SubProviderConfig`,保留键 `goal_verifier`)、`validators`(`crates/octos-agent/src/validators.rs` 声明式校验器配置)
- profile 层: `crates/octos-cli/src/profiles.rs` 的 `LlmProfileConfig` / `LlmModelSelectionConfig` / `LlmRouteConfig`(`3a567a4c` typed 推理参数 schema),给出一份最小可用 profile JSON 示例(以本仓库 `.octos/` 外的真实 profile 结构为准,不含密钥)
- 分析基线: octos main @ 9c157101;文件 `chapters/appendix-c-config-reference.md` 与 `book/src/appendix/c-config-reference.md`

## 边界

### 允许修改
- octos-book/chapters/appendix-c-*.md
- octos-book/book/src/appendix/c-config-reference.md
- octos-book/book-en/src/appendix/c-config-reference.md

### 禁止做
- 不编造不存在的配置字段

## 完成条件

场景: 配置字段完整
  测试: review_appendix_c_fields
  当 检查配置参考表
  那么 覆盖了 `config.rs` 中定义的所有公开配置字段
  并且 每个字段有类型、默认值和功能说明
  并且 Serve 默认端口写为 50080
  并且 hooks 使用 `hooks[]`、`event`、`command`、`timeout_ms`、`tool_filter: string[]` 的当前 schema

场景: Profile LLM 配置
  测试: review_appendix_c_profile_llm
  当 检查 Profile LLM 配置参考
  那么 说明 profile 文件位于 `~/.octos/profiles/<id>.json`
  并且 说明 `config.llm.primary.family_id`、`model_id`、`route`、`model_hints` 和 `fallbacks[]`
  并且 不把 profile LLM 配置简化成旧的顶层 `provider` / `model`

场景: 示例配置文件
  测试: review_appendix_c_example
  当 检查示例配置
  那么 提供了一个完整的 `config.json` 示例
  并且 示例使用 JSONC 风格注释说明每个主要字段

场景: 三大新车道有字段表
  测试: review_appc_new_lanes
  当 检查 mcp_servers / sub_providers / validators 三节
  那么 每个字段有类型、默认值与来源行号

场景: 字段来源可核
  测试: review_appc_field_sources
  当 抽查任意 20 个字段的来源行号
  那么 均能在对应结构体定义处找到

场景: 示例不含密钥
  测试: review_appc_no_secrets
  当 检查 profile JSON 示例
  那么 api_key 仅以环境变量名出现,不含任何密钥值
