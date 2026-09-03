# ch01-en-review — 英文版 C2 读校报告

- Peer: `ch01-en-review` (lane strong)
- 日期: 2026-09-03
- 对象: `book-en/src/part1/ch01.md` (385 行,基线 a6fb75c 交付 + 本次 2 处微改)
- 对照: `chapters/ch01-why-rust-why-agent-os.md`、`.octos/skills/trilingual-collab-en.md`、`assets/glossary-en.md`、`assets/ch01-facts.md`、C1 报告 `assets/ch01-en-check.md`
- 工作目录: octos-book worktree `peer/ch01-en-review`,未 commit

## 判定:C2 通过(2 处微改已落地并复验;另 1 处 ZH 侧疑似缺陷移交外环,不在 EN 车道修)

---

## 1. 禁用词 / 翻译腔逐条核查(对照 trilingual-collab-en.md)

| 规则 | 命中 | 判定 |
|---|---|---|
| Banned outright(delve/leverage/robust/seamless/pivotal 等 21 词) | 0 处(verify-en 同口径为 0) | 通过 |
| Hedging/filler(really/just/literally/genuinely/honestly/simply/actually/truly/fundamentally/importantly/crucially) | 2 处 → **已修 1** :L138 "Honestly stated:"(冒号开场+hedging)→ "The ecosystem is Rust's relative weak spot, stated plainly.";L19 "Every tool actually exposed" 的 actually 为实义(强调"真正暴露给 LLM 的",对应 ZH「真正暴露给」),非填充,保留 | 通过(修后) |
| Filler phrases(it's worth noting / at the end of the day / when it comes to 等) | 0 处 | 通过 |
| Colon reveal | 1 处:L138 同上(已随 hedging 一并消除);其余冒号均为列表/标签/引用合法用法(L40 "correctness under concurrency is:" 引出列表、L57 "all of these run on every iteration" 列举、表格标签等) | 通过(修后) |
| Recap ending / fake-profound kicker | "1.5 Chapter Recap" 为章节结构(与 ZH「本章小结」1↔1,verify-en 结构镜像要求保留),非 slop 判定范围;结尾 L359 落在具体动作("From the next chapter we work bottom-up: first, how `octos-core`…"),无 mic-drop | 通过 |
| Em dash | 0 处(全文无 —) | 通过 |
| Bold 撒粉 | 7 处(阈值 ≤15):L3 Positioning 锚点×1+读者画像 A/B/C/D 标记×4(结构标记非强调)、L7 三挑战三元组×1、L19 数字强调×1、L178 定义强调×1、L383 Version note 锚点×1——后四处均为"关键断言单点强调",非撒粉 | 通过 |
| 翻译腔(直译痕迹) | 1 处 → **已修 2** :L5 "Lying in there:"(ZH「这里躺着」的直译,英文突兀)→ "Inside are a message bus…",主谓自然 | 通过(修后) |
| 被动语态滥用 | 抽查全文,被动均为受动必要(如 "depended on by 8 crates" 依赖统计、"inherited by all 26 directories" 配置语义),无滥用 | 通过 |
| 二元对比/喉咙清嗓/三连排比成瘾/自问自答 | L13 "not a chatbot framework; it is a…" 为反驳实位(chatbot framework 是被驳的立场,规则允许);无 throat-clearing;三元组(三挑战/三通道面)是内容结构而非修辞凑数 | 通过 |

**修后剩余命中:0 个 banned、0 个 filler phrase、1 个实义 actually(合法)。**

## 2. 母语度与术语一致性

- **26 crate 名**:EN 全文 `octos-*` token 集与 `assets/ch01-facts.md` 的 crate 集合 diff 为空(逐 token sort -u 比对,exit 0)。23 个 octos-* crate + app-skills/platform-skills/octos-web 全部按 facts 表原名出现,无改写、无别名漂移。
- **glossary-en 术语**抽查全部一致:channel(频道)、session、attack surface(ch01 注册条目)、multi-tenant、capability layer、hot path、measurement methodology、graceful shutdown、approval flow、gating、borrow checker、Positioning/Engineering decision/Version note/Further reading/Exercises 标签 1↔1。
- **依赖方向表述**:L194 「`A --> B` means A depends on B; `graph BT` reads bottom-up」与 facts §5.2 说明逐字同义;L306 (4) "All dependencies point downward, with no cycles" 与 facts 层级推导一致;L168 层定义公式 "1 + max(layer of every octos-* dependency)" 与 facts §4 一致。无一处方向反写。
- **母语度**:整体为重写型译文(非直译),行文符合"conclusion first / verbs do the work";两处直译残留已修(见上)。

## 3. 技术读校

- **63 边 mermaid**:提取 EN 图内 63 条边,经别名映射(core→octos-core、diag→octos-diagnostics、dora→octos-dora-mcp、fworker→octos-fleet-worker、embed→octos-embed-llama 等)后与 facts §5.1 边清单 sort 比对:**63/63 完全一致,零多零少**(脚本级 diff 输出空)。节点标签中 crate 名全部保持原文未译,仅 subgraph 层名翻译(L0 Foundation 等 9 处),与 C1 结论一致。
- **数字/引用**:verify-en refs 22 集合相等;700,915 / 26 / 38 / 17 / 59 / 63 等关键数字与 facts 表一致;"700K lines"(2 处)与 700,915 同口径,C1 已附注。
- **CVE/unsafe 安全断言**:L90 "the Python interpreter is written in C and has repeatedly shipped memory-safety CVEs from parsing malicious input" 与 ZH「历史上多次出现解析恶意输入导致的内存安全 CVE」语义一致,无夸大(未写成"必然失守");"Go is memory-safe but its `unsafe` package and the cgo boundary remain surfaces where it can fail" 与 ZH「同样存在失守面」一致,断言强度对齐。`unsafe_code = "deny"`(workspace-wide、可逐 crate 豁免)表述与 facts 一致。
- **「详见第 N 章」章号**:L23 Chapters 6 and 7(工具策略/审批,对应 Ch6 工具系统、Ch7 纵深防御,目录表 L333/334 佐证);L25 Chapter 7(沙箱拆解)✓;L190 Chapter 10(Harness)✓;L306 Chapter 2(octos-core)✓;L324/338 旧 10→11 平移说明 ✓;L385 "Chapters 16 onward are new" ✓。全部与 1.4 目录表自洽,无串号。
- **遗留疑点(移交外环,ZH 侧缺陷,EN 不动)**:L19 与 L161 的字符串 `` `*crates/octos-bus/src/cli_channel.rs` `` 在 ZH 源文件同行(L19/L161)即如此——应为 glob `*_channel.rs` 被错误全路径替换后的残骸(facts 表 §1.1 正确写法是 `ls crates/octos-bus/src/*_channel.rs | wc -l`)。因 brief 明令不改引用,且 EN 侧改动会造成 refs 集合 diff(verify-en FAIL),EN 车道保持镜像,建议由源车道在 ZH+EN 同步修复。

## 4. 改动清单与复验

改动 2 处(仅 book-en/src/part1/ch01.md):

1. L5: `Lying in there:` → `Inside are`(去直译腔;不触碰任何数字/引用)
2. L138: `Honestly stated: the ecosystem is Rust's relative weak spot.` → `The ecosystem is Rust's relative weak spot, stated plainly.`(去 hedging + colon reveal)

复验输出:

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch01-why-rust-why-agent-os.md book-en/src/part1/ch01.md
refs: 22 (equal sets: yes)
en words: 4867, bold 7, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build
 INFO Book building has started
 INFO Running the html backend
 INFO HTML book written to `.../book-en/book`
$ mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0        # grep exit 1 = 无匹配,即 0 警告 0 错误
```

## 5. 结论

**C2 通过。** 禁用词/翻译腔清零(2 处微改已落地)、术语与 63 边拓扑与 facts/glossary 完全一致、安全断言强度与 ZH 对齐、章号引用自洽。唯一遗留是 ZH 源的 `*_channel.rs` glob 残骸(L19/L161 双语同病),属引用内容缺陷,超出本车道「不改引用」授权,移交外环裁定修复车道。
