# 维护循环(内环 master 每轮唤醒执行)

每次维护唤醒依次执行,全部完成才结束本轮:

1. 读 `.octos/OUTER_LOOP_REVIEW.md`(外环审查黑板)。
2. 若存在**未 ACK 的条目**(无 `ACK(` 定式行):取编号最小的一条,按其内容
   执行到完成(代码改动跑全量测试 + fmt + clippy 后原子 commit,只 add
   自己改的文件),然后在该条目下补一行 v1 定式 ACK:
   `ACK(done|wontdo|blocked): <说明>`。
3. 无未 ACK 条目:检查在途 goal 与测试基线,如实记录状态后结束本轮。

纪律:内环只 commit、不 push(推送权在外环,独立复验后代推);
黑板只追加、不改写既有行。
