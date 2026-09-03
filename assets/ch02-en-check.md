# ch02 英文版机械校验报告(ch02-en-check)

- 日期:2026-09-02
- 校验对象:`chapters/ch02-core-types.md` ↔ `book-en/src/part1/ch02.md`
- 前置 commit:a23b4e4(branch main,未做新 commit)
- 校验方式:纯机械校验(脚本 + grep/diff/构建计数),不做语言读校

## 1. verify-en.sh 脚本校验 — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch02-core-types.md book-en/src/part1/ch02.md
refs: 54 (equal sets: yes)
en words: 4906, bold 13, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

0 FAIL 为过 → 通过(含代码块内容比对,脚本为更新后版本)。

## 2. 数字集合比对 — PASS(缺失 0 / 多余 0)

命令:

```
grep -oE '[0-9][0-9_.,%]*' <file> | sort -u   # 两侧各自提取后 comm / diff
```

- 原始 unique token:CN 161 个,EN 167 个。
- raw diff 显示 EN 侧多出的 token 全部为标点吸附变体:`9562,`、`1,`、`2026.`、`3,`、`4,`、`6,`、`7,`(英文列表/句末标点贴在数字后)。
- 剥离 `.` `,` `%` `_` 后规范化 diff:**完全一致(NORM_IDENTICAL)**。
- 重点核对 `9562`:CN L594 与 EN L596 均为 RFC 9562(UUID v7 规范),两侧都有。

结论:缺失 0,多余 0(全部差异为英文标点吸附,规范化后为空集差)。

## 3. 源码引用集合比对 — PASS

命令:

```
grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <file> | sort -u
```

- CN 55 条,EN 55 条,`diff` 为空(REFS_IDENTICAL)。

## 4. 固定标签与章/节引用 — PASS

| 中文 | 英文 | CN 数 | EN 数 | 形式 |
|---|---|---|---|---|
| `> **定位**:`(L3) | `> **Positioning**:`(L3) | 1 | 1 | 章首块引用 |
| `## 版本演化说明`(L609) | `## Version note`(L611) | 1 | 1 | `##` 标题;EN 在块内另有一行加粗 `> **Version note**:` 标签,内容与 CN 块一致 |
| `> ### 工程决策侧栏…`(L534) | `> ### Engineering decision: …`(L536) | 1 | 1 | `> ###` 侧栏 |
| `## 延伸阅读` | `## Further reading` | 1 | 1 | 标题 |
| `## 思考题` | `## Exercises` | 1 | 1 | 标题 |

章引用:

| CN | EN |
|---|---|
| 详见第 4 章 ×1 | see Chapter 4 ×1 |
| 详见第 6 章 ×1 | see Chapter 6 ×1 |
| 详见第 8 章 ×2 | see Chapter 8 ×2 |

节引用:`2.3 节`(L107) ↔ `covered in 2.3`(L107)×1 一一对应;`Section 5.7` 两侧各 1 次,均为 RFC 9562 的外部章节引用,非本书节引用。

## 5. mermaid 对照 — PASS

两侧各 3 个代码块。块 2、块 3 与中文版逐字节一致;块 1 为 `stateDiagram-v2` 任务状态机:

- CN(7 条转移):`[*]→Pending: 创建`、`Pending→InProgress: 分配给 Agent`、`InProgress→Blocked: 等待外部资源`、`InProgress→Completed: 执行成功`、`InProgress→Failed: 执行失败`、`Blocked→InProgress: 阻塞解除`、`Blocked→Failed: 超时或取消`
- EN:同一 7 条转移,仅边标签译为英文(created / assigned to Agent / waiting on external resource / execution succeeded / execution failed / block cleared / timeout or cancel)

节点(6 状态 + 初始 `[*]`)与边数(7)两侧一致,差异仅为边标签翻译。

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
INFO HTML book written to …/book-en/book
```

WARN/ERROR 计数为 0(grep 无匹配退出码 1 为预期),构建成功。

## 总判定:PASS(可进 C2)

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | PASS(0 FAIL, 0 WARN) |
| 2 | 数字集合 | PASS(0 缺失 / 0 多余,仅英文标点吸附变体) |
| 3 | 源码引用集合 | PASS(55=55,diff 空) |
| 4 | 固定标签 | PASS(5 组标签 1↔1;章引用 4/6/8×2 对应;节引用 2.3 对应) |
| 5 | mermaid | PASS(3 块,结构一致,块 1 边标签为译文) |
| 6 | mdbook build | PASS(WARN/ERROR = 0) |
