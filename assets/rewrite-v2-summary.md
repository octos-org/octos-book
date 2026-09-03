# octos-book v2 重写：收官总结（外环 claude，2026-09-03 06:30）

分支 `rewrite-v2`，HEAD `d0b503c`，领先 `main` 120 个 commit，**未推送**。

## 结果

- 21 章全部重写或对齐 octos main @ `9c157101`（第 1–15 章）；新增第 16–18 章（Fleet / Swarm / Goal 与 Peer）与第四部分「双环」第 19–21 章（octoscode / OctoLoop OLP v2 / herdr）。
- 前言重写（四条阅读路径、26 节点知识地图、阅读标记说明）。
- 附录 A/B/C/D 按 main 重生成数据表；附录 E 保留；新增附录 F（OLP v2 速查 + F.6 两条端到端追踪）。
- 全书统稿：219 处 `../octos/` 相对前缀统一为 `crates/...`，569 处裸短引用全路径化，加粗与「——」收口，mdbook build 零警告。

## 章节 hash 与机械指标

| 文件 | 终稿 commit | 正文汉字 | 源码引用 | mermaid |
|---|---|---|---|---|
| ch01 | 952d187 | 6,092 | 38 | 1 |
| ch02 | 952d187 | 6,122 | 64 | 3 |
| ch03 | 952d187 | 7,045 | 79 | 2 |
| ch04 | 952d187 | 5,410 | 60 | 1 |
| ch05 | 952d187 | 6,427 | 119 | 3 |
| ch06 | 952d187 | 6,225 | 121 | 4 |
| ch07 | 952d187 | 6,347 | 92 | 2 |
| ch08 | 952d187 | 5,055 | 89 | 2 |
| ch09 | 952d187 | 5,013 | 93 | 1 |
| ch10 | 952d187 | 5,347 | 61 | 3 |
| ch11 | 952d187 | 5,203 | 75 | 3 |
| ch12 | 952d187 | 5,370 | 81 | 3 |
| ch13 | 952d187 | 5,791 | 118 | 1 |
| ch14 | 952d187 | 5,274 | 82 | 5 |
| ch15 | 952d187 | 5,262 | 83 | 3 |
| ch16 | 8c68cd0 | 5,238 | 56 | 3 |
| ch17 | 952d187 | 5,441 | 70 | 3 |
| ch18 | 952d187 | 5,219 | 47 | 2 |
| ch19 | 46f4dfc | 5,235 | 88 | 3 |
| ch20 | 952d187 | 5,278 | 52 | 4 |
| ch21 | 03d152f | 5,313 | 82 | 3 |
| preface | d0b503c | 1,693 | 1 | 1 |
| appendix A | ab097df | 2,679 | 12 | 1（63 边，逐条对 Cargo.toml 核实） |
| appendix B | 1b81cd9 | 3,058 | 55 | 1 |
| appendix C | 1b81cd9 | 3,032 | 303 | 0 |
| appendix D | a93bc73 | 2,556 | 92 | 1（79 feature，逐 crate 核实） |
| appendix E | 7b4c51e（未动） | 832 | 2 | 0 |
| appendix F | d0b503c | 5,728 | 73 | 2 |

正文汉字合计约 117,700（21 章）。每章：章首「定位」锚点、章末「版本演化说明」、≥1 张 Mermaid、「——」≤2、加粗 ≤13、代码占比 ≤22%、引用路径全部存在且行号在文件范围内。每章都经过 A（facts，glm-5.3-flash）→ B（writer，glm-5.3）→ C1（factcheck，flash）+ C2（techreview，5.3）四道，外环在隔离 worktree 独立复验后采认。

## 验证方法（外环侧）

- `~/.octos/outer/verify-chapter.sh`：路径存在、行号越界、短引用、锚点、版本演化、破折号/加粗/黑话、字数与代码占比、mermaid 边 vs Cargo 依赖、mdbook build。
- 每次采认都在 `git worktree add --detach <hash>` 的隔离树上跑，不信任内环自报数字；抽查符号到源码行。
- 黑板 `.octos/OUTER_LOOP_REVIEW.md` 共 28 条条目，全部 ACK 落板；内环 peer 共 98 个（含重派与 pathfix）。

## 统稿遗留（不阻塞，建议下一轮）

1. 第 1/2/13 章有 5 处 `Cargo.toml:N` 未写 crate 路径（指工作区根 Cargo.toml，语义无歧义）。
2. 附录 C 加粗 13 对、第 8/9/10/13 章加粗 13 对，可再压到 ≤10。
3. `assets/ch18-facts.md` 已加注 52,445，其它 facts 表未回写统稿后的数字（facts 表是过程产物，不进书）。
4. `book-en/` 仍是 v1 英文旧稿，与 v2 中文内容完全脱节；需要单独立项翻译或从 SUMMARY 移除。
5. 未跟踪文件留给用户裁决：`CHANGES_SINCE_V0.1.md`、`TESTING_CHECKLIST.md`、`ch03-fix-report.md`、`ch06-depth-report.md`（过程报告）；`.octos/octosbook/`、`.octos/spawn-deliverables/`、`.octos-workspace.toml`、`.octos/active-profile`（运行时产物，建议加入 .gitignore）。

## 运行时缺陷（待向上游报 issue，详见 ~/.octos/outer/runtime-defects.md）

- octos：`goal_create` 准入只认 `complete`，archived goal 阻塞新建，需 TUI `/goal clear`。
- octos：`octos goal list/archive` CLI 与 TUI 读的不是同一份账本（CLI 报 no goal records，TUI 显示 budget_limited）。
- octos：`goal_update(complete)` 曾被验证器以空理由拒绝。
- octoscode：`octos steer` 在共享实例布局下找不到会话；`olp-board-append.sh` 依赖 flock，macOS 需 brew 安装。
- 内环行为：master 曾误判在跑 peer 为僵死并 peer_close；曾 ACK 声称 SUMMARY 已改而实未改（R2 违例一次）；SUMMARY 被并发 writer 覆盖三次（串行冲突）；master 上下文 683K 时被压缩一次，靠黑板恢复无损。
- 用户侧：8080 端口的旧 `octos serve`（PID 609）对 octosbook profile 反复自动重启报错，已把 profile 置 `enabled:false`，未动 609。

## 推送

未推送。确认后：

```bash
git push -u origin rewrite-v2
```
