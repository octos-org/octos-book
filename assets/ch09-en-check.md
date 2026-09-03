# ch09-en-check —— 英文版 C1 机械校验报告

- 对象:`chapters/ch09-extension.md` ↔ `book-en/src/part2/ch09.md`
- 前置:ch09-en 已交付(commit `bb900d8`;两文件在 wt 与主仓 `diff -q` 全同,且对两文件的最后变更即 `bb900d8`,wt `git status` 干净——校验基线即主仓 main 当前态)
- 校验人:peer ch09-en-check(lane cheap)
- 日期:2026-09-03
- 性质:仅机械校验,不做语言读校

## 1. verify-en.sh 脚本比对 — PASS

命令与输出(wt 内执行):

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch09-extension.md book-en/src/part2/ch09.md
refs: 76 (equal sets: yes)
en words: 4332, bold 13, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
```

0 FAIL 为过 → PASS(脚本含标题数/围栏数/mermaid 数/代码块内容 md5/引用集合/数字/CJK 残留/违禁词/Positioning 与 Version note 锚点;本轮 0 WARN,连代码块 md5、表格行、em dash、bold 全部无警告)。

## 2. 数字集合比对 — PASS

命令(代码块外提取;归一:剥 `U+XXXX` 码点、按 token 拆分、剥千分位逗号;两侧同法,与 ch06/ch07/ch10 校验同口径):

```
$ strip(){ awk '/^```/{c=!c;next} !c' "$1"; }
$ norm(){ sed -E 's/U\+[0-9A-Fa-f]{4,6}//g; s/[0-9][0-9,]*[0-9]|[0-9]/\n&\n/g' \
    | grep -E '^[0-9][0-9,]*[0-9]$|^[0-9]$' | sed -E 's/,//g' | sort -u; }
$ strip chapters/ch09-extension.md | norm > /tmp/n.zh
$ strip book-en/src/part2/ch09.md  | norm > /tmp/n.en
$ wc -l /tmp/n.zh /tmp/n.en
     151 /tmp/n.zh
     151 /tmp/n.en
$ comm -23 /tmp/n.zh /tmp/n.en | wc -l    # 缺失
0
$ comm -13 /tmp/n.zh /tmp/n.en | wc -l    # 多余
0
```

- 两侧各 151 个唯一数字,**缺失 0 / 多余 0** → PASS。
- 豁免条款动用情况:两侧 `U+XXXX` 码点均 0 处,豁免未动用;归一后数字集完全相等,无 万↔thousand 类单位换算差,无需注明。

## 3. 源码引用集合比对 — PASS

命令与输出(简报指定 grep 口径):

```
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' chapters/ch09-extension.md | sort -u > /tmp/refs.zh
$ grep -o -E '[A-Za-z0-9_./-]+\.(rs|toml)(:[0-9-]+)?' book-en/src/part2/ch09.md | sort -u > /tmp/refs.en
$ wc -l /tmp/refs.zh /tmp/refs.en
      72 /tmp/refs.zh
      72 /tmp/refs.en
$ diff /tmp/refs.zh /tmp/refs.en && echo "(empty — sets equal)"
(empty — sets equal)
```

- 两侧各 72 个唯一引用,diff 为空 → PASS。行号级引用(如 `mcp.rs:122-163/211-293/532-558/586-612`、`loader.rs:607-626/1354-1365`、`tool.rs:1229-1307/3117-3130`、`mcp_auth.rs:105-186`、`skills.rs:590-645`、`gating.rs:42/73-78` 等)在两侧同现。
- 交叉印证:verify-en.sh 自带口径(`(crates|octoscode|herdr)/…`)亦报 `refs: 76 (equal sets: yes)`。

## 4. 固定标签 — PASS(全部同行严格同位)

五标签对照(标签定义见 specs/translation-en.spec.md / AGENTS.md):

| 标签 | 中文 | 英文 | 数量 | 同位 |
|---|---|---|---|---|
| `> **定位**` ↔ `> **Positioning**` | :3 | :3 | 1↔1 | ✅ |
| 工程决策侧栏 `> ### 工程决策侧栏:…` ↔ `> ### Engineering decision: …` | :261 | :261 | 1↔1 | ✅(同行严格同位) |
| `## 延伸阅读` ↔ `## Further reading` | :334 | :334 | 1↔1 | ✅ |
| `## 思考题` ↔ `## Exercises` | :340 | :340 | 1↔1 | ✅ |
| `> **版本演化说明**` ↔ `> **Version note**`(inline 形态) | :350 | :350 | 1↔1 | ✅ |

- 真实标题 24 个两侧 24↔24,标题行号逐对 delta 全 0(`:1→:1`、`:15→:15`、…、`:334→:334`、`:340→:340`),标题文本逐行对应(译文语义一一对应,编号序列 `9.1–9.6` 一致)。
- `see Chapter N` ↔ 「详见第 N 章」:字面形 `see Chapter 10`(:279)↔「详见第 10 章」(:279),同行严格同位。
- 跨章引用归一多重集:ZH {第 6 章×1、第 9 章×1(章题)、第 10 章×2} = EN {Chapter 6×1、Chapter 9×1(章题)、Chapter 10×2},完全相等 → PASS。

## 5. mermaid 图对照 — PASS

```
$ grep -c '^```mermaid' chapters/ch09-extension.md book-en/src/part2/ch09.md
chapters/ch09-extension.md:1
book-en/src/part2/ch09.md:1
```

- 两侧各 1 块,围栏行号镜像(`:142–:152`),块内容 `diff` 为空——**逐字节相同**(sequenceDiagram:participant 2↔2(Agent、Plugin),消息箭头 `->>` 5↔5)→ PASS。
- 其余代码围栏行号两侧镜像(`:23/:36`、`:76/:84`、`:118/:136`、`:293/:300`、`:306/:312`),verify-en 代码块内容 md5 相等(0 WARN)交叉印证。

## 6. mdbook 构建 — PASS

```
$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

构建零警告零错误,HTML 正常产出(wt 内构建;`book/` 产物目录不入库,构建后 wt `git status` 仍干净)→ PASS。

## 总判定:PASS(可进 C2)

六项 6/6 PASS,无漂移备注:五标签与全部 24 个标题行号零位移,数字集 151=151(0/0),引用集 72=72,mermaid 逐字节相同,mdbook 0 警告。ch09-en 机械校验通过。
