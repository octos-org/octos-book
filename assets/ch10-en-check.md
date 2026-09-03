# ch10-en-check —— 英文版 C1 机械校验报告

- 对象:`chapters/ch10-harness.md` ↔ `book-en/src/part2/ch10.md`
- 前置:ch10-en 已交付(commit `fad031c`;英文侧最后变更即 `fad031c`,中文侧最后变更为全书统稿 `952d187`;wt `git status` 干净,且 wt 与主仓两文件 `diff -q` 全同,校验基线即主仓 main 当前态)
- 校验人:peer ch10-en-check(lane cheap)
- 日期:2026-09-03
- 性质:仅机械校验,不做语言读校

## 1. verify-en.sh 脚本比对 — PASS

命令与输出(wt 内执行):

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch10-harness.md book-en/src/part2/ch10.md
refs: 52 (equal sets: yes)
en words: 4392, bold 13, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
```

0 FAIL 为过 → PASS(脚本含标题数/围栏数/mermaid 数/代码块内容 md5/引用集合/数字/CJK 残留/违禁词/Positioning 与 Version note 锚点)。

## 2. 数字集合比对 — PASS

命令(代码块外提取;归一:剥 `U+XXXX` 码点、按 token 拆分、剥千分位逗号;两侧同法,与 ch06/ch07 校验同口径):

```
$ strip(){ awk '/^```/{c=!c;next} !c' "$1"; }
$ norm(){ sed -E 's/U\+[0-9A-Fa-f]{4,6}//g; s/[0-9][0-9,]*[0-9]|[0-9]/\n&\n/g' \
    | grep -E '^[0-9][0-9,]*[0-9]$|^[0-9]$' | sed -E 's/,//g' | sort -u; }
$ strip chapters/ch10-harness.md | norm > /tmp/n.zh
$ strip book-en/src/part2/ch10.md  | norm > /tmp/n.en
$ comm -23 /tmp/n.zh /tmp/n.en | wc -l    # 缺失
0
$ comm -13 /tmp/n.zh /tmp/n.en | wc -l    # 多余
0
```

- 两侧各 93 个唯一数字,**缺失 0 / 多余 0** → PASS。
- 豁免条款动用情况:两侧 `U+XXXX` 码点均 0 处,豁免未动用;数字集在归一后完全相等,不存在 万↔thousand 类单位换算差,无需注明。

## 3. 源码引用集合比对 — PASS

命令与输出(简报指定 grep 口径):

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' chapters/ch10-harness.md | sort -u > /tmp/refs.zh
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' book-en/src/part2/ch10.md | sort -u > /tmp/refs.en
$ wc -l /tmp/refs.zh /tmp/refs.en
      52 /tmp/refs.zh
      52 /tmp/refs.en
$ diff /tmp/refs.zh /tmp/refs.en && echo "(empty — sets equal)"
(empty — sets equal)
```

- 两侧各 52 个唯一引用,diff 为空 → PASS。行号级引用(如 `validators.rs:131`、`workspace_policy.rs:22/51/104`、`harness_errors.rs:47/93/166`、`tests/validator_runner.rs:123/218/293/329/531`、`tests/harness_errors.rs:26/58/77/110/126/154/248/271/280`)在两侧同现。
- 交叉印证:verify-en.sh 自带口径亦报 `refs: 52 (equal sets: yes)`。

## 4. 固定标签 — PASS(行号漂移 +2 见注)

五标签对照(标签定义见 specs/translation-en.spec.md / AGENTS.md;ch10 中文源稿的工程决策标签形态为 `> **工程决策:…**`,与 ch07 的「工程决策侧栏」措辞不同,属源稿自身形态):

| 标签 | 中文 | 英文 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ |
| 工程决策侧栏 `> **工程决策:…**` ↔ `> **Engineering decision**` | :127 | :127 | 1↔1 | ✅(同行严格同位) |
| `## 延伸阅读` ↔ `## Further reading` | :282 | :284 | 1↔1 | +2 ⚠ |
| `## 思考题` ↔ `## Exercises` | :290 | :292 | 1↔1 | +2 ⚠ |
| `## 版本演化说明` ↔ `## Version note`(inline 形态 `> **Version note**`) | :300 | :302 | 1↔1 | +2 ⚠ |

- 20 个真实标题(剔除 2 处 `#[derive` 代码行后)两侧 20↔20。行号对照:前 10 个(`#` 章题 :1 至 `## 10.3` :165)delta 全 0;自 `### 10.3.1`(:167→:169)起后 10 个统一 +2。
- 位移成因(已定位,与 ch07 的分隔线成因不同):英文侧在 `## 10.3`(:165)与 `### 10.3.1`(:169)之间多一段引导句「Declarations get archived, events get replayed, so a third question arises: …」(EN :167,ZH 对应位置无此独立段落,ZH :167 直接是节标题)。纯增段位移,节数与编号序列一一对应,无内容错位;两侧 `---` 分隔线 8↔8 且位置镜像,非分隔线成因。
- `see Chapter N` ↔ 「详见第 N 章」:字面形 `see Chapter 7` ×2(:49、:278)↔「详见第 7 章」×2(:49、:276),位置与指向一致;「详见第 8 章」×1(:132)在 EN 同位句(:132)意译为 "(Chapter 8 covers how compaction is consumed at runtime)",指向一致。
- 跨章引用多重集:原始 `第 N 章`(ZH 2/2/1/3/4/3/7/2/2)对 `Chapter N`(EN 2/2/2/3/4/3/7/2/2)在 16 章处差 1,成因是 ZH :128 用缩写形「Ch16」而 EN 展开为 "Chapter 16";归一(含缩写形)后两侧完全一致:`5×4、6×3、7×7、8×2、9×2、10×2、13×2、16×2、17×3` → PASS。

## 5. mermaid 图对照 — PASS

```
$ grep -c '^```mermaid' chapters/ch10-harness.md book-en/src/part2/ch10.md
chapters/ch10-harness.md:3
book-en/src/part2/ch10.md:3
```

- 两侧各 3 块,围栏行号镜像:`:20-37`、`:98-119` 两侧完全相同,`:193-201` ↔ `:195-203`(+2,与标题位移一致)。
- 结构化对照(节点按 ID、边按起止节点归一,剥离标签文本):

| 块 | 类型 | 节点 | 边 | 对照 |
|---|---|---|---|---|
| 10-1 | flowchart LR | 7(ST/WP/V/HE/AS/H/HErr)+ subgraph 1 | 7(实线 5:ST→WP、WP→V、V→HE、H→HE、HErr→HE;虚线 2:AS⇢WP、AS⇢HE) | 节点 ID 集与边拓扑全同;仅标签语言差(如「声明层 3165 行」↔ "declaration layer 3165 lines"、"版本护栏" ↔ "version guardrail") |
| 10-2 | sequenceDiagram | 5 participant(P/R/S/C/L) | 9 消息(P→R、R⇢P、R→S、R→R×3、R→C、C⇢R、R→L)+ loop/alt 块各 1 | 归一后逐行一致;仅消息文案为对应翻译(「启动(超时 SIGTERM→SIGKILL)」↔ "start (timeout SIGTERM→SIGKILL)") |
| 10-3 | flowchart TD | 7(A/B/C/D/E/F/G) | 6(A→B、B→C、B→D、D→E、D→F、F→G) | 归一后逐行一致;判定文案「缺席/存在」「found ≤/> supported」两侧语义相同 |

- 三块归一 diff 均仅剩标签译文差,节点/边数与拓扑两侧全等 → PASS。

## 6. mdbook 构建 — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

构建零警告零错误,HTML 正常产出(wt 与主仓各构建一次,均 0)→ PASS。

## 总判定:PASS(可进 C2)

六项 6/6 PASS。备注两点(不构成 FAIL):
1. 后 10 个标题行号统一 +2:成因是 EN 侧 10.3 节多一段引导句(EN :167),非分隔线(两侧 `---` 8↔8 镜像);节数与编号序列一一对应,如 master 要求行号严格同位,删该段或将语义并入 10.3.1 首段即可。
2. ch10 中文源稿工程决策标签为 `> **工程决策:…**`(非 ch07 的「工程决策侧栏」),EN 侧 `> **Engineering decision**` 与之同行(:127)严格同位;跨章引用 ZH 一处缩写形「Ch16」在 EN 展开为 "Chapter 16",归一后多重集相等。
