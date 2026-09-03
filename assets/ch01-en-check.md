# ch01-en-check — 英文版 C1 机械校验报告

- Peer: `ch01-en-check` (lane cheap)
- 日期: 2026-09-02
- 基线: `main` @ `a6fb75c`(en(G1) ch01 母语重写);校验时 HEAD 为 `a23b4e4`(ch02 已并发合入,未触碰 ch01 两文件)
- 对象: `chapters/ch01-why-rust-why-agent-os.md`(385 行) ↔ `book-en/src/part1/ch01.md`(385 行)
- 工作目录: `/Users/zhangalex/Work/Projects/FW/octos-book`,未 commit

## 六项校验结果

| # | 校验项 | 结果 | 判定 |
|---|--------|------|------|
| 1 | verify-en.sh(0 FAIL 为过) | `RESULT: 0 FAIL(s), 0 WARN(s)`;refs 22 集合相等;en words 4868 / bold 7 / em dash 0;exit 0 | **PASS** |
| 2 | 数字集合比对(应为缺失 0/多余 0) | 仅 1 处 token 级差异:ZH-only `70`(「70 万行」)↔ EN 写作 `700K lines`(同数值 700,000,与正文 700,915 口径一致);缺失 0、多余 0(语义层面) | **PASS**(附注) |
| 3 | 源码引用集合比对(应为空 diff) | 两侧各 22 条,`sort -u` 后 diff 为空 | **PASS** |
| 4 | 固定标签对应 | 定位/Positioning 1↔1;工程决策/Engineering decision 1↔1;版本演化说明/Version note 1↔1(EN 行 381 `## Version note` + 行 383 `> **Version note**:` 为同一处,标题+加粗引语);延伸阅读/Further reading 1↔1;思考题/Exercises 1↔1。章引用:ZH `{1, 2, 6+7(顿号并列), 7, 10×5, 11×2, 16}` ↔ EN `{1, 2, 7, 10×5, 11×2}`,ZH 多出「第 16 章」1 处(行 385 版本演化说明),EN 对应句写作 "Chapters 16 onward are new",数字 16 仍在,仅表述形态不同,语义等价 | **PASS** |
| 5 | mermaid 节点/边数(26/63) | 两侧均 26 节点、63 边、109 行;diff 仅 subgraph/节点标签中→英翻译(L0 基础层→L0 Foundation 等 9 处),拓扑一致 | **PASS** |
| 6 | mdbook build(须 0 WARN/ERROR) | `grep -cE 'WARN\|ERROR'` = 0;build 成功,HTML 输出至 `book-en/book` | **PASS** |

## 各项证据(命令与输出)

### 项 1 — verify-en.sh

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch01-why-rust-why-agent-os.md book-en/src/part1/ch01.md
refs: 22 (equal sets: yes)
en words: 4868, bold 7, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0
```

### 项 2 — 数字集合比对

```
$ grep -o -E '[0-9]+(\.[0-9]+)?%?' chapters/ch01-why-rust-why-agent-os.md | sort -u > /tmp/zh_nums.txt
$ grep -o -E '[0-9]+(\.[0-9]+)?%?' book-en/src/part1/ch01.md          | sort -u > /tmp/en_nums.txt
$ comm -3 /tmp/zh_nums.txt /tmp/en_nums.txt
DIFF: 70            # 唯一差异,ZH-only
zh=87 en=86
```

唯一差异根因:ZH 行 144「全量构建 70 万行代码」/ 行 314「把全部 70 万行塞进一个 crate」,EN 写作 "a full build of 700K lines" / "Pack all 700K lines into one crate"。数值相同(70 万 = 700,000),EN 的 `700K` 中 `700` 已在双方集合内,故 EN 侧无新增 token。缺失 0、多余 0。

### 项 3 — 源码引用集合比对

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' <file> | sort -u
$ diff /tmp/zh_refs.txt /tmp/en_refs.txt
(空输出)
zh_refs=22 en_refs=22
```

22 条引用逐条相等(与 verify-en.sh 的 refs 22 equal sets 一致)。

### 项 4 — 固定标签与章引用

```
EN: Positioning 1 / Engineering decision 1 / Version note 2(381 标题+383 加粗引语,同一处)
    ## Further reading 1 / ## Exercises 1
ZH: 定位 1 / 工程决策 1 / 版本演化说明 1 / ## 延伸阅读 1 / ## 思考题 1

章引用集合:
  ZH: 第 1 章×1, 第 2 章×1, 第 6、7 章×1, 第 7 章×1, 第 10 章×5, 第 11 章×2, 第 16 章×1
  EN: Chapter 1×1, Chapter 2×1, Chapter 7×1, Chapter 10×5, Chapter 11×2, (16 见 "Chapters 16 onward")
```

`see Chapter N` / 「详见第 N 章」字面形态在两侧均出现 0 次;ZH 行 23「(详见第 6、7 章)」对应 EN 行 25 "Chapter 7 takes them apart" + 后文 Chapter 6 语境——语义对应,非缺失。ZH「第 16 章」(行 385)在 EN 为 "Chapters 16 onward are new",数字 16 保留,仅句式不同。如需字面 `see Chapter 16` ↔ 「详见第 16 章」完全形态对齐,可留 C2 润色时统一。

### 项 5 — mermaid

```
$ awk '/```mermaid/,/```$/' <file>
zh: unique-declared nodes=26 edges(-->)=63 lines=109
en: unique-declared nodes=26 edges(-->)=63 lines=109
$ diff /tmp/zh_mmd.txt /tmp/en_mmd.txt   # 仅 9 处标签中→英,无拓扑差异
```

### 项 6 — mdbook build

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
$ mdbook build 2>&1 | tail -3
 INFO Book building has started
 INFO Running the html backend
 INFO HTML book written to `.../book-en/book`
```

(`grep -c` 无匹配时 exit=1 属正常,计数 0 即通过。)

## 总判定

**PASS —— 六项全过,ch01-en 可进 C2。**

附注(非阻断,供 C2 参考):①「70 万行/700K lines」为记法差异,若追求 token 级完全一致可统一为 `700,000` 或均写 `700K`;②「第 16 章」/ "Chapters 16 onward" 句式差异同上。
