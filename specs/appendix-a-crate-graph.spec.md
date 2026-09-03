spec: task
name: "附录 A. octos 完整 Crate 依赖图(v2 重画,26 crate)"
inherits: project
tags: [appendix, reference]
depends: [ch01-why-rust-why-agent-os]
estimate: 0.5d
---

## 意图

提供 octos workspace 主要 Rust crate 的完整依赖关系图，包括外部依赖，
作为全书的快速参考。

## 决策

- 从 `Cargo.toml` workspace 和各 crate 的 `Cargo.toml` 自动提取依赖
- Mermaid 格式绘制内部 crate 依赖图
- 表格列出每个 crate 的关键外部依赖及版本
- 事实纠正: fleet / swarm / workflows / diagnostics / services / store 六个新 crate 已独立;goal/peer 编排仍在 `octos-cli`(autonomy/、peers/)与 `octos-agent` 工具层,harness 不是 crate

- 数据源: 直接复用 `assets/ch01-facts.md`(26 crate 名称/职责/行数/依赖边),本附录只做全量图与外部依赖表,不重复计算
- 分析基线: octos main @ 9c157101;文件 `chapters/appendix-a-crate-graph.md` 与 `book/src/appendix/a-crate-graph.md`

## 边界

### 允许修改
- octos-book/chapters/appendix-a-*.md
- octos-book/book/src/appendix/a-crate-graph.md
- octos-book/book-en/src/appendix/a-crate-graph.md
- octos-book/assets/appendix-a-*

### 禁止做
- 不编造不存在的依赖关系

## 完成条件

场景: 内部依赖图准确
  测试: review_appendix_a_internal
  当 检查 Mermaid 依赖图
  那么 11 个 octos-* crate 的内部依赖边与 `Cargo.toml` 一致
  并且 无遗漏或虚假的依赖
  并且 说明 app-skills / platform-skills 是 workspace 成员但不展开到核心 crate 图
  并且 说明最新 autonomy 相关模块不应被画成不存在的 `octos-autonomy` crate

场景: 外部依赖表完整
  测试: review_appendix_a_external
  当 检查外部依赖表
  那么 每个 octos-* crate 列出了关键外部依赖及版本
  并且 标注了 feature-gated 依赖

场景: 与事实表一致
  测试: review_appa_matches_facts
  当 对照 `assets/ch01-facts.md`
  那么 依赖图的节点集合与 26 个 crate 一致
  并且 每条边能在对应 Cargo.toml [dependencies] 找到

场景: 旧数字零残留
  测试: review_appa_no_stale
  当 在正文检索「10 个 crate」「11 个」
  那么 一处都不出现
