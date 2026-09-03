# 运行时缺陷记档(外环,待向上游报 issue)
- 2026-09-02 octos 9c157101:goal_create admission 只认 status=="complete"(crates/octos-cli/src/autonomy/agent_orchestrator.rs:8992),外环 `octos goal --profile P archive` 后会话仍视为「未完成 goal」,需 TUI `/goal clear` 才能新建。建议:archived 视为已完成。
- 2026-09-02 octos 9c157101:goal_update(complete) 被验证器以空理由拒绝(glm-5.3 经 zai-coding anthropic 端点),未配 goal_verifier 车道;疑似验证器输出解析失败。待复现后补充。
- 2026-09-02 octoscode 1129fa33:`octos steer --session` 只在 <cwd>/.octos/octos/sessions 找会话,共享实例(OCTOS_TUI_SHARED_INSTANCE=1)布局下不可用;herdr agent prompt 是唯一可靠注入面。
- 2026-09-02 octoscode:scripts/olp-board-append.sh 依赖 flock,macOS 需 brew install flock;olp-init.sh 未提示。
- 2026-09-03 01:58 R2 违例记录:内环 ACK(第 19 条 Ch15 6ce294c)称 SUMMARY 已改号,复验 HEAD 未改;已打回并要求 ACK 附 grep 自证。
- 2026-09-03 04:56 `octos goal --profile octosbook archive goal_04` 报「no goal goal_04 found in the supervisor event stream」,而 TUI 状态栏与 events.jsonl 均显示 goal_04 budget_limited;`octos goal list` 亦返回「no goal records」。CLI 与 TUI 读的不是同一份账本(instances/<id>/profiles/octosbook 与 ~/.octos/profiles 路径分歧?)。TUI `/goal clear` 生效。
- 2026-09-03 英文战役:master 在只剩单个 peer 时会整轮空等(pane 显示「唯一下一步:等 X 交付」)而不并行补派其它可派任务,靠外环每轮催派;建议 master 的规划提示里加「等待期间先填满并发额度」。
- 2026-09-03 英文战役:strong 车道 peer(appendixf-en)一次输出退化为 3 行占位并自报 completed;master 靠工作树行数判死重派。建议 peer 交付前强制自证(行数/verify 脚本)再写 result.md。

## 建议上游 issue(待用户确认后提交)

| 仓库 | 标题 | 要点 |
|---|---|---|
| octos | goal_create admission treats `archived` as unfinished | agent_orchestrator.rs:8992 只认 `complete`;`octos goal archive` 后需 TUI `/goal clear` 才能新建 |
| octos | `octos goal list/archive` reads a different ledger than the TUI | CLI 报 no goal records 时 TUI 显示 budget_limited;instances/<id>/profiles 与 ~/.octos/profiles 路径分歧 |
| octos | goal_update(complete) rejected by verifier with empty reason | glm-5.3 经 anthropic 协议端点,未配 goal_verifier;疑验证器输出解析失败 |
| octoscode | `octos steer` cannot find sessions under shared-instance layout | 只查 <cwd>/.octos/octos/sessions;OCTOS_TUI_SHARED_INSTANCE=1 下不可用 |
| octoscode | olp-board-append.sh needs flock; olp-init.sh should check | macOS 需 brew install flock |
| octoscode | master idles a whole turn waiting on one peer instead of filling slots | 见上;规划提示建议 |
