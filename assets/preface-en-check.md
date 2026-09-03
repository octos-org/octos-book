# preface-en C1 校验报告(preface-en-check)

- 校验对象:`chapters/preface.md`(zh)↔ `book-en/src/preface.md`(en)
- 基线:main @ 8ec09a6(preface-en 交付);当前 HEAD a23b4e4,preface 两文件自 8ec09a6 起未再改动
- 两侧行数:124 ↔ 124
- 校验日期:2026-09-03

## 1. verify-en.sh — PASS

```
$ bash ~/.octos/outer/verify-en.sh chapters/preface.md book-en/src/preface.md
refs: 1 (equal sets: yes)
en words: 1304, bold 0, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
```

0 FAIL → 通过。

## 2. 数字集合比对 — PASS(附记法差异说明)

命令(逗号归一化后取数字多重集):

```
$ grep -o -E '[0-9][0-9,]*(\.[0-9]+)?%?' chapters/preface.md      | sed 's/,//g' | sort
$ grep -o -E '[0-9][0-9,]*(\.[0-9]+)?%?' book-en/src/preface.md    | sed 's/,//g' | sort
$ diff <zh> <en>
174,175c174,175
< 70
< 70
---
> 700000
> 700000
```

- 计数:zh 183 个数字 token,en 183 个,数量相等。
- 唯一差异:zh 两处「70 万行」(L7、L115)↔ en 两处「700,000 lines」(L7、L115)。同一数量、不同记法(70 万 = 700,000),逐处核对位置与次数(各 2 处)均一致。
- 中文侧无其他 万/亿 记法数字(grep `[0-9]+\s*[万亿]` 仅上述两处);英文侧无其他千分位逗号数字(grep `[0-9],[0-9]{3}` 仅上述两处)。
- 语义缺失/多余:0/0 → 通过。

## 3. 源码引用集合比对 — PASS

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' chapters/preface.md    | sort -u
crates/octos-agent/src/agent/execution.rs:2483
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' book-en/src/preface.md  | sort -u
crates/octos-agent/src/agent/execution.rs:2483
$ diff <zh> <en>   → 空
```

两侧各 1 条且完全相同 → diff 为空,通过。

## 4. 固定标签检查 — PASS

「see Chapter N」↔「详见第 N 章」:

```
zh L7:  详见第 3 章 / 详见第 7 章 / 详见第 12 章        (共 3 处)
en L7:  see Chapter 3 / see Chapter 7 / see Chapter 12  (共 3 处)
```

一一对应(3/7/12,各 1 次)。

其余章号交叉引用(含顿号列表与区间)多重集比对相等:

- 单章:{2:1, 3:2, 7:1, 10:1, 12:3, 16:1, 18:2, 20:2} 双侧一致
- 区间:1-2、6-10、19-21 各 1 次,双侧一致
- en L109「Chapter positioning」为小节标题(章首定位),非交叉引用,不计入

前言豁免项(Positioning / Version note)不在本项比对范围 → 通过。

## 5. Mermaid 结构对照 — PASS

```
$ awk '/```mermaid/,/```$/' <file>   # 两侧各 1 个代码块
                 zh    en
blocks           1     1
subgraph         5     5
边 -->          20    20
边 -.->          3     3
节点定义        27    27
```

(节点按 `id[` / `id(` / `id{` 形态计。)

节点/边/子图三项全同,与 8ec09a6 commit message 声称一致(27 节点 / 20+3 边)→ 通过。

## 6. mdbook build — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

build 成功(`HTML book written to .../book-en/book`),WARN/ERROR 计数 0 → 通过。

---

## 总判定

| # | 校验项 | 结果 |
|---|--------|------|
| 1 | verify-en.sh | PASS(0 FAIL / 0 WARN) |
| 2 | 数字集合 | PASS(唯一差异为 70万↔700,000 记法,语义 0 缺失/0 多余) |
| 3 | 源码引用集合 | PASS(diff 为空) |
| 4 | see Chapter N ↔ 详见第 N 章 | PASS(3:3 一一对应,其余章号多重集相等) |
| 5 | mermaid 结构 | PASS(27 节点 / 20+3 边 / 5 subgraph) |
| 6 | mdbook build | PASS(0 WARN/ERROR) |

**6/6 PASS — 总判定 PASS,preface-en 可进 C2。**
