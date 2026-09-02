spec: task
name: "附录 D. Feature Flags 一览(v2 勘误)"
inherits: project
tags: [appendix, reference, features]
depends: [ch13-runtime-modes]
estimate: 0.5d
---

## 意图

列出 octos workspace 所有 Cargo feature flags，说明每个 flag 启用的功能、
依赖和适用场景。

## 决策

- 从各 crate 的 `Cargo.toml` [features] 段提取
- 表格格式：crate | feature | 启用的功能 | 额外依赖 | 默认开启？

- 事实边界: `crates/octos-cli/Cargo.toml` [features] 当前 22 个(default embed-llama embed-llama-metal embed-llama-cuda api admin-bot telegram discord dingtalk slack whatsapp email feishu twilio wecom line matrix wecom-bot qq-bot wechat git ast),其余 crate 逐个现取并附命令;`api` 必须写明「serve 子命令依赖它,漏掉则 octoscode 无法启动」
- 分析基线: octos main @ 9c157101;文件 `chapters/appendix-d-feature-flags.md` 与 `book/src/appendix/d-feature-flags.md`

## 边界

### 允许修改
- octos-book/chapters/appendix-d-*.md
- octos-book/book/src/appendix/d-feature-flags.md
- octos-book/book-en/src/appendix/d-feature-flags.md

### 禁止做
- 不编造不存在的 feature flag

## 完成条件

场景: Feature flags 完整
  测试: review_appendix_d_flags
  当 检查 feature flags 表
  那么 覆盖了所有 crate 的 [features] 定义
  并且 每个 flag 标明了是否默认开启和引入的额外依赖
  并且 明确列出当前 workspace 中没有 [features] 的 crate 类别

场景: Feature 传播关系
  测试: review_appendix_d_propagation
  当 检查 feature 传播说明
  那么 说明 `octos-cli` feature 如何转发到 `octos-bus` 与 `octos-agent`
  并且 提供一张传播关系图

场景: flag 全集与 Cargo 一致
  测试: review_appd_flags_match
  当 对照各 crate `Cargo.toml` [features]
  那么 表中 flag 集合与当前源码一致并附命令

场景: api flag 说明写明
  测试: review_appd_api_flag
  当 检查 `api` 行
  那么 写明 serve 子命令依赖它
