# 构建 AI Agent OS：octos 架构与实现

Building an AI Agent OS: Architecture and Implementation of octos

一本 DDIA 风格的源码解析书，对象是用 Rust 写的 AI Agent 操作系统 [octos](https://github.com/octos-org/octos)，以及围绕它的双环工具链 octoscode（终端客户端与 OctoLoop 外环协议）和 herdr（终端工作区服务）。全书 21 章、四部分、六个附录，每一条论断都给出 `crates/…rs:行号` 形式的源码引用，读者可以逐条到仓库里核对。

## 版本

| 版本 | 状态 | 基线 |
|---|---|---|
| 中文版 v2 | 完成（2026-09-03） | octos main `9c157101`、octoscode `1129fa33`、herdr `feat/octoscode-agent` `fefe5c4f` |
| 英文版 | 完成（2026-09-03），与 v2 逐章结构镜像 | 同上 |

## 目录

- 第一部分 地基：为什么是 Rust、octos-core 类型层、octos-llm、octos-memory
- 第二部分 引擎：Agent Loop、工具系统、安全纵深、上下文管理、扩展机制、Harness
- 第三部分 平台：octos-bus、并发模型、pipeline、运行模式与配置、生产化、Fleet、Swarm、Goal 与 Peer
- 第四部分 双环：octoscode、OctoLoop OLP v2、herdr 运维实务
- 附录：Crate 依赖图、工具速查、配置参考、Feature Flags、构建与贡献、OLP v2 速查与端到端追踪

完整目录见 `book/src/SUMMARY.md`；阅读路径见前言。

## 本地阅读

```bash
cargo install mdbook
cd book && mdbook serve        # 中文版，http://localhost:3000
cd book-en && mdbook serve -p 3001   # 英文版
```

推送到 `main` 后由 `.github/workflows/deploy.yml` 构建并发布到 GitHub Pages（中文在站点根，英文在 `/en/`）。

## 仓库结构

```
chapters/        中文章节定稿（book/src 为逐字镜像）
book/            中文版 mdbook
book-en/         英文版 mdbook
specs/           每章的任务契约（agent-spec），含 project.spec.md 全书约束
assets/          事实表、审查报告、统稿清单、术语表
AGENTS.md        写作纪律、引用规则与内环车道分工
OUTLINE.md       全书大纲与版本计划
```

## 写作方式

本书 v2 由 OctoLoop 双环生产：Claude 作外环负责计划、派单与隔离复验；octoscode 内环由一个 master 与按章派出的 goal/peer agent 执行，写作与技术审查走 glm-5.3，事实表与机械核对走 glm-5.3-flash。每章经事实表、写作、事实核对、技术审查四道，外环在独立 worktree 复验后才采认。完整黑板记录在 `assets/reports/OUTER_LOOP_REVIEW-rewrite-v2.md`，指标汇总在 `assets/rewrite-v2-summary.md`。

## 许可

见 [LICENSE](LICENSE)。
