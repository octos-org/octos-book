# ch07-en-check —— 英文版 C1 机械校验报告

- 对象:`chapters/ch07-security.md` ↔ `book-en/src/part2/ch07.md`
- 前置:ch07-en 已交付(commit `7f0c3c1`;两文件最后变更提交均为 `7f0c3c1`,wt git status 干净,校验基线即该定稿态)
- 校验人:peer ch07-en-check(lane cheap)
- 日期:2026-09-03
- 性质:仅机械校验,不做语言读校

## 1. verify-en.sh 脚本比对 — PASS

命令与输出(wt 内执行):

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch07-security.md book-en/src/part2/ch07.md
refs: 69 (equal sets: yes)
en words: 5486, bold 7, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)
```

0 FAIL 为过 → PASS(脚本含标题数/围栏数/mermaid 数/代码块内容 md5/引用集合/数字/CJK 残留/违禁词/Positioning 与 Version note 锚点)。

## 2. 数字集合比对 — PASS

命令(代码块外提取;归一:剥 `U+XXXX` 码点、按 token 拆分、剥千分位逗号;两侧同法):

```
$ strip(){ awk '/^```/{c=!c;next} !c' "$1"; }
$ norm(){ sed -E 's/U\+[0-9A-Fa-f]{4,6}//g; s/[0-9][0-9,]*[0-9]|[0-9]/\n&\n/g' \
    | grep -E '^[0-9][0-9,]*[0-9]$|^[0-9]$' | sed -E 's/,//g' | sort -u; }
$ strip chapters/ch07-security.md | norm > /tmp/n.zh
$ strip book-en/src/part2/ch07.md  | norm > /tmp/n.en
$ comm -23 /tmp/n.zh /tmp/n.en | wc -l    # 缺失
0
$ comm -13 /tmp/n.zh /tmp/n.en | wc -l    # 多余
0
```

- **缺失 0 / 多余 0** → PASS。
- 豁免条款动用情况:两侧全篇 `U+XXXX` 码点均为 0 处(`grep -c 'U+'` 皆 0),豁免未动用;两侧数字集在千分位归一后完全相等,不存在 万↔thousand 类单位换算差(若存在,集合必不等),亦无需注明。
- 标点粘连:归一含逗号剥离;英文句尾 `.` 粘连 token(如 `Chapter 7.`)在按 token 拆分后与中文裸数字同集,无残留差异。

## 3. 源码引用集合比对 — PASS

命令与输出(简报指定 grep 口径):

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' chapters/ch07-security.md | sort -u > /tmp/refs.zh
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' book-en/src/part2/ch07.md | sort -u > /tmp/refs.en
$ wc -l /tmp/refs.zh /tmp/refs.en
      68 /tmp/refs.zh
      68 /tmp/refs.en
$ diff /tmp/refs.zh /tmp/refs.en && echo "(empty — sets equal)"
(empty — sets equal)
```

- 两侧各 68 个唯一引用,diff 为空 → PASS。行号级引用(如 `mod.rs:809`、`grant.rs:151`、`mod.rs:955-1000`)在两侧同现。
- 交叉印证:verify-en.sh 自带口径(`(crates|octoscode|herdr)/` 前缀)亦报 `refs: 69 (equal sets: yes)`。

## 4. 固定标签 — PASS

五标签对照(标签定义见 specs/translation-en.spec.md / AGENTS.md):

| 标签 | 中文 | 英文 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ |
| 工程决策侧栏 `> **工程决策侧栏:**` ↔ `> **Engineering decision**` | :122、:230 | :122、:230 | 2↔2 | ✅(简报提示的两处,行号完全同位) |
| `## 延伸阅读` ↔ `## Further reading` | :240 | :242 | 1↔1 | +2 ⚠ |
| `## 思考题` ↔ `## Exercises` | :248 | :250 | 1↔1 | +2 ⚠ |
| `## 版本演化说明` ↔ `## Version note`(+ `> **Version note**` :256/:260) | :256 | :260 | 1↔1 | +4 ⚠ |

- 位移成因(已定位):英文侧在 7.5 章末段后(:240)与 Exercises 后(:258)各有一条 `---` 主题分隔线(EN 共 2 条,ZH 共 0 条),纯排版装饰,后三节标题整体 +2/+4 位移。
- 全部 22 个标题(`#`–`###`)两侧数量 22↔22,前 20 个(至 `## 7.5 Chapter recap`,:234)行号逐一完全同位;仅章末三节因上述分隔线位移。节数、章节编号序列一一对应,无内容错位 → 判 PASS,位移在此如实注明,由 master 裁量是否要求 EN 去掉分隔线以对齐。
- `see Chapter N` ↔ 「详见第 N 章」:英文侧字面 `see Chapter N` 为 0 处;中文侧字面「详见第 16 章」1 处(:228),英文对应句(:228)意译为 "…is Chapter 16's subject",指向与位置一致。跨章引用多重集完全一致:`第 6 章×5 / 第 7 章×1 / 第 16 章×2` ↔ `Chapter 6×5 / Chapter 7×1 / Chapter 16×2` → PASS。

## 5. mermaid 图对照 — PASS

```
$ grep -c '^```mermaid' chapters/ch07-security.md book-en/src/part2/ch07.md
chapters/ch07-security.md:2
book-en/src/part2/ch07.md:2
```

- 两侧各 2 块:图 7-1 `decide_sandbox` 决策流程(flowchart TB)、图 7-2 WorkerGrant 五轴与双层执行(flowchart LR)。
- 结构化对照(节点/边按 ID 归一,剥离标签文本):

| 块 | 类型 | 节点 | 边 | 对照 |
|---|---|---|---|---|
| 7-1 | flowchart TB | 10(S/Q1–Q5/U/U2/C/R) | 11 | 节点 ID 集与边拓扑全同;仅边标签语言差(是/否/有/无 ↔ yes/no),语义归一后 diff 为空 |
| 7-2 | flowchart LR | subgraph G + 5 成员(N/T/F/W/CO)+ 3 外部(V/SB/FT) | 3(V→G、G→SB、G→FT) | 归一后逐行一致 |

- 节点/边数与拓扑两侧全等 → PASS。仅节点标签文本为对应翻译(如「唯一合法降级」↔ "the only legal degradation"),且引用行号(`grant.rs:151`、`grant.rs:247`、`mod.rs:955-1000`)两侧一致。

## 6. mdbook 构建 — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

构建零警告零错误(HTML 正常产出)→ PASS。

## 总判定:PASS(可进 C2)

六项 6/6 PASS。备注两点(不构成 FAIL):
1. 章末三节标题行号 +2/+4 位移:成因是 EN 侧两条 `---` 主题分隔线(ZH 无),节数与编号序列一一对应,前 20 个标题行号完全同位;如 master 要求行号严格同位,删 EN 两条分隔线即可,不影响内容判定。
2. 「详见第 16 章」1 处在英文侧意译为 "is Chapter 16's subject"(非字面 "see Chapter 16"),位置与指向一致,跨章引用多重集相等。
