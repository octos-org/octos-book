# 附录 E 中英对照核查报告(appendixe-en-check)

- 核查对象:`book-en/src/appendix/e-contributing.md`(英文 v1,下称 EN)vs `chapters/appendix-e-contributing.md`(中文 v2,下称 CN)
- 行数:EN 208 行 / CN 208 行;均以换行结尾
- 核查方式:全文逐行人工比对 + 结构化 diff(标题、围栏、表格行、列表、空行、行内代码 span、数字多重集、引用集合)
- 结论先行:**两稿逐行平行、结构 100% 对齐,未发现英文缺失项,未发现时效性冲突项**。附录 E 可按契约保留 v1 英文稿,无需补译。

## 1. 结构对比

| 维度 | EN | CN | 一致性 |
|------|----|----|--------|
| H1 | 1(行 1) | 1(行 1) | ✅ |
| H2 | 8,行号 5/18/42/73/107/137/154/185 | 8,行号完全相同 | ✅ 逐行对位 |
| H3 | 6 | 6 | ✅ |
| 代码块 | 9 个(18 条围栏) | 9 个(18 条围栏) | ✅ 围栏行号逐一对位 |
| 表格 | 2 个(环境要求 7 行、CI 矩阵 23 行,合计 30 行表内容) | 2 个,同规格 | ✅ |
| mermaid | 0 | 0 | ✅ |
| 列表项 | 29 | 29 | ✅ |
| 空行 | 51 | 51 | ✅ |

H2 节名对照(EN ← CN):Environment Requirements ← 环境要求、Minimal Build Path ← 最小构建路径、Local CLI Install ← 本地安装 CLI、CI-Equivalent Test Matrix ← CI 等价测试矩阵、Code Conventions ← 代码规范、TDD Workflow ← TDD 工作流、Pull Request Guide ← PR 提交指南、Project Structure Quick Reference ← 项目结构速查。8 节顺序一致,无缺节、无多节。

按行做结构分类(H1/H2/H3/FENCE/TABLE/LIST/BLANK/TEXT)diff:208 行全部对齐,零错位。

## 2. 内容时效(中文 v2 是否有 v1 之后的新增段落)

逐节检查 brief 点名的疑似 v2 新增物,两侧均无差异:

| 检查项 | EN | CN | 判定 |
|--------|----|----|------|
| 仓库 URL | 行 22 `https://github.com/octos-org/octos.git` | 行 22 同 | ✅ 一致 |
| 构建命令 | 行 20-38、46-49、59-61、65-69、102-105、147-152,两侧命令逐字符相同 | 同左 | ✅ 一致 |
| 验证脚本(factcheck/verify 类) | 无 | 无 | ✅ 两侧均无 |
| 团队流程(peer/blackboard/双环类) | 无 | 无 | ✅ 两侧均无 |
| `.octos`、milestone 相关 | 仅行 71 `scripts/milestone-ci.sh release-bundle`(发布打包脚本,属 v1 原有安装流程) | 行 71 同 | ✅ 一致 |
| 引用块 `>`(承载 Positioning/Version note 类标签的容器) | 0 条 | 0 条 | ✅ 两侧均无 |

无任何仅存在于中文稿的段落;无任何仅存在于英文稿的段落。

## 3. 引用与数字

- `crates/...rs:行号` 形态的源码引用:EN 0 条 / CN 0 条(diff 为空)。本附录的引用全部指向配置/脚本/文档(`Cargo.toml`、`CLAUDE.md`、`scripts/*.sh`、`.github/workflows/ci.yml`),两侧一一对应。
- 全文数字多重集(出现次数归一后 diff):完全一致。关键数字双侧同值——Rust `1.85.0`(行 9/16/112)、Edition `2024`(行 10/111)、resolver `2`(行 11)、`26 members`(行 189 结构树注释)、四个 starter crate(行 97)。
- 行内代码 span:去重后各 67 个,集合 diff 为空(EN 的说明列英文措辞、CN 的中文措辞差异属正常翻译,不计)。

## 4. 固定标签

`> **Positioning**:`、`> **Version note**:` 等固定标签:EN 缺失,CN 亦缺失(grep 0 命中,双侧一致)。这与"附录 E 按 v1 原样保留、不加重译标签"的契约一致,不构成英文缺失项。

## 5. 结论(三类汇总)

### (a) 可直接保留一致项
全部 8 节:标题层级与节名、9 个代码块、2 张表、29 个列表项、全部命令/URL/数字/行内代码 span、项目结构速查树(行 187-208)。英文稿与中文稿逐行平行,可整体保留,无需任何补译。

### (b) 英文缺失需补项
无。未发现中文 v2 稿中存在而英文稿缺失的段落、命令、脚本、流程或标签。

### (c) 时效性冲突项(中文新 / 英文旧)
无。两侧描述的同一事实集合(Rust 1.85.0、edition 2024、resolver 2、26 members、同一仓库 URL、同一安装/测试命令)完全同值,不存在版本漂移。

**裁定建议**:附录 E 无需补译,维持契约现状(EN 保留 v1 原稿)即可。
