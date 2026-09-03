# ch07-en-review — 英文版 C2 读校报告

- Peer: `ch07-en-review` (lane strong)
- 日期: 2026-09-03
- 对象: `book-en/src/part2/ch07.md`(264 行,基线 `7f0c3c1` 交付 + 本次 2 处微改)
- 对照: `chapters/ch07-security.md`、`.octos/skills/trilingual-collab-en.md`、`assets/glossary-en.md`、`assets/ch07-facts.md`、C1 报告 `assets/ch07-en-check.md`
- 工作目录: octos-book worktree `wt`(peers/ch07-en-review),未 commit
- 迭代预算: 25(实用 ~14)

## 判定:C2 通过(2 处微改已落地并复验:0 FAIL + mdbook 零警告)

---

## 1. 外环已裁决待修项范式逐条核查

| 范式 | 命中 | 判定 |
|---|---|---|
| 「双环」dual loop | 0 处(`grep -ni 'dual loop\|double loop\|双环'` 为空;本章无该概念) | 通过 |
| 顿号(、)残留→英文逗号 | 0 处(perl 扫 `[\x{3000}-\x{303F}\x{FF00}-\x{FFEF}\x{4E00}-\x{9FFF}]` 全文为空,无任何 CJK 标点/字符;curly quotes=0) | 通过 |
| colon reveal(冒号揭底) | 0 处需修。全文冒号均为合法用法:Positioning/Version note 标签、表格标签、列表引出(:875-901 系列行号引用)、引语(「"Not a security boundary."」)。L11 "reads …: it is a platform helper binary" 为"文档原句:释义"结构,冒号两侧各为完整命题,非 reveal;L104 "the order inside `wrap_command` is: strip …" 引出有序列表,合法 | 通过 |
| hedging 前缀 | 见 §2 命中表:5 个候选词逐一核实,3 个实义保留、2 个随微改消除 | 通过(修后) |
| recap ending(伪总结收尾) | "7.5 Chapter recap" 为章节结构(ZH「本章小结」1↔1,verify-en 结构镜像保留);章末落在 Version note 的基线事实(`9c157101`、三条主线 commit),无 mic-drop 隐喻、无 "In conclusion"。7.5 末段 L238 "says more about … than any single point's strength" 是对 ZH L238「同一原则在四个抽象层级上的相同形状,比任何单点的强度更能说明…」的忠实对译(对照原文),非英文侧加戏 | 通过 |

## 2. 禁用词 / 翻译腔逐条核查(对照 trilingual-collab-en.md)

- **Banned outright 21 词**(delve/foster/leverage/robust/seamless/pivotal 等):0 处。
- **Hedging/filler 10 词**全扫:命中 5,逐一判定:
  - L55 `actually`:inside 引语 `"actually runs bwrap, not a PATH scan"` —— 直接引用源码文档原句(ZH L55 同样引英文原句),verbatim 引用豁免。保留。
  - L79 `actually reach it`:实义(=真正到达后端的命令,区别于被 refusal() 短路的),非填充。保留。
  - L120 `just ~/.cargo/.package-cache`:"仅此一个路径"的限定义,非填充。保留。
  - L187 `honestly reflects`:honestly 作"诚实(承认能力边界)"实义,对应 ZH「诚实地反映它能执行的范围」。保留。
  - L232 `just several independent config keys` → **已修**:填充性 just(hedge 式弱化"只是几个配置项"),改 `only a few independent config keys`,语气对齐 ZH「只是若干独立配置项」且去掉填充。
- **Filler phrases**(it's worth noting / at the end of the day / when it comes to / in order to / let's dive 等):0 处。
- **Em dash**:全文恰 1 处(L136 `(`:150-152`) — setting it true today…`),长文上限 1–2 内且该处确比括号套括号清晰。通过(verify-en 同口径计 1)。
- **Bold 撒粉**:7 处(阈值 ≤15):Positioning×1、Engineering decision×2、Not a security boundary.(原文引语)×1、Figure 7-1/7-2 图题×2、Version note×1 —— 全部为结构锚点/原文引语,无强调撒粉。
- **翻译腔/直译**:1 处 → **已修**:L244 Further reading 首条 "the two kernel mechanisms **the helper delegated to by** `…landlock.rs` **applies**" 为 ZH「`landlock.rs` 委托助手所施加的两类内核机制」的名词短语直译,英文侧双重畸形(关系从句 "the helper delegated to by X" 被动嵌套 + 主谓 "mechanisms … applies" 单复数错位)。改写为 "the two kernel mechanisms **applied by the helper that** `crates/octos-agent/src/sandbox/landlock.rs` **delegates to**",主谓一致、语序自然,语义与事实(Landlock 委托 octos-sandbox 助手施加两机制)不变。行内代码引用与冒号结构未动。
- **二连对比/清嗓/三连成瘾/自问自答**:L40 "`NoSandbox` is not the name of the concept…; it is a real type" 为实位反驳(被驳立场真实存在,ZH L40 同构);全文无 throat-clearing;三元组(三设计准则/三逃逸面/三重叠加属性)是内容结构,对应 ZH 原文,非修辞凑数。
- **被动语态**:抽查均为受动必要(refused/delegated/suppressed 类安全语义),无滥用。

**修后剩余命中:0 banned、0 filler phrase、0 翻译腔;3 个实义 actually/just/honestly(判定合法)+ 1 个 verbatim 引语 actually。**

## 3. 母语度与术语一致性

- **术语一致性计数**(全文 grep -oi 计数):defense in depth(标题,无连字符)/defense-in-depth(L3 定语)2 形各得其所;fail-closed 14 + fail closed 2(两处均为谓语位置 "fail closed rather than falling through" / "would fail closed on every dispatch",非定语,不须连字符)+ 代码标识 `fail_closed` 6;write fence 8;sentinel 5;redaction 9;allowlist 12 / denylist 1;SBPL 7;sandbox-exec 5;Landlock 17;seccomp 6;bwrap 26 / bubblewrap 3;AppContainer 13;deny-wins 6。与 ch06-en(deny-wins 4 处)同款连字符风格,无别名漂移。
- **crates/路径引用**:69 个 ref 集合与 ZH 侧相等(verify-en "equal sets: yes");`octos-sandbox` vs `octos-agent/src/sandbox/` 边界在 L11 显式澄清,与 L34/36 "Delegates to the `octos-sandbox` helper" 一致。
- **octos 小写**:64 处全部小写,与全书 EN 章一致(ch06 同款,`Octos` 0 处)。
- **母语度**:整体为重写型译文(conclusion first / verbs do work:"refuses outright"、"lands there automatically"、"grants nothing to create");§2 所列 2 处直译/填充已修,其余段落(7.1.2 探测诚实度、7.3.2 分工边界、Engineering decision 两块)语感自然,无需再动。
- **重复读校放行**:L136 超长段(3 准则 1 段)为与 ZH L136 段落结构 1↔1 的镜像要求,verify-en 结构项 PASS,不做拆段。

## 4. 技术读校

- **图 7-1**(L85-99):flowchart TB;节点实测 **10**(S/Q1/U/Q2/Q3/C/R/Q4/Q5/U2),边实测 **11**(S→Q1, Q1→U, Q1→Q2, Q2→Q3, Q3→C, Q3→R, Q2→Q4, Q4→C, Q4→Q5, Q5→U2, Q5→R)——与 C1 报告及 brief 口径(10 节点 11 边)一致。标签核对:`decide_sandbox(config, os, probe)` 签名与 L62-66 代码块一致;`Unconfined(Disabled / ExplicitNone)`、`Refuse(SandboxUnavailable)`、`fail-closed`、`fail_closed` 大小写各就各位;Q5 分支 `|false|→U2 / |true|→R` 与 L53/L262 文字语义一致(Auto 降级默认告警、可升级拒绝)。图题 Figure 7-1 与正文锚点一致。
- **图 7-2**(L203-215):subgraph G 内 **6 节点**(N/T/F/W/CO + G 自身计为 subgraph 头),brief 口径 "subgraph 5+3 节点" = G 内 5 字段节点(N/T/F/W/CO)+ 外部 3 节点(V/SB/FT),边 **3**(V→G, G→SB, G→FT),与 brief 一致。标签核对:五字段名/类型/serde 默认与 L171-182 rust 代码块逐一对齐(network/tools/fs/write_paths/create_only,`#1976 write fence`,`create but do not overwrite`);`validate() (…grant.rs:247)`、`sandbox projection (…mod.rs:955-1000)` 与正文 L221/L201 行号引用一致;`O_CREAT|O_EXCL` 与 L199 一致。
- **数字**:verify-en 数字集合比对 0 缺 0 多(C1 §2 已归一复核,本次修改未触碰任何数字);抽查 5,347=2190+1767+498+392+325+175 逐文件加和吻合;7 impl=5 后端+2 哨兵;18-entry 列表 =3+5+7+3(LD 3 项、DYLD 5 项、runtime 7 项、shell 3 项)分组自洽;`GrantError` 七变体(UnknownTool/WebToolWithoutNetwork/EmptyHostAllowlist + #1976 四连)与 facts 表 L92 一致,"five classes" 对应五类不一致(七变体归并为五类),L230 "seven `GrantError` variants" 亦与事实一致,两处不矛盾。
- **章号**:交叉引用 Chapter 6(L3/L130/L228/L238)与 Chapter 16(L160/L228)方向正确(6=前置 ToolPolicy/write_grant,16=fleet 装配);本章自称 Chapter 7,标题/图题/Exercises 编号无错位。
- **技术名保留原文**:SBPL、sandbox-exec、Landlock、seccomp、bwrap/bubblewrap、AppContainer、`--die-with-parent`、`--unshare-net`、`O_CREAT|O_EXCL`、globset、TOCTOU、CGNAT、ULA 等全部原样,无转写。
- **引用行号抽查**:mod.rs:443(trait)、:809(decide_sandbox)、:914(RefusingSandbox impl)、bwrap.rs:29、docker.rs:36、landlock.rs:27、macos.rs:185、windows.rs:46、grant.rs:76/127/151/247/307/359 与 facts 表逐一相符;执行侧 execution.rs:2414 单点漏斗表述与 ZH L156 同义。

## 5. 改动清单与复验

仅改 `book-en/src/part2/ch07.md` 2 处(最小有效编辑,不动事实/数字/引用/mermaid/代码块):

| 行号 | 原 | 改 | 性质 |
|---|---|---|---|
| L232 | "were **just several** independent config keys" | "were **only a few** independent config keys" | 填充性 just 去除(hedging) |
| L244 | "the two kernel mechanisms **the helper delegated to by** `…landlock.rs` **applies**" | "the two kernel mechanisms **applied by the helper that** `crates/octos-agent/src/sandbox/landlock.rs` **delegates to**" | 直译名词短语重写 + 主谓单复数修正 |

复验输出(wt 内执行,修改后):

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch07-security.md book-en/src/part2/ch07.md
refs: 69 (equal sets: yes)
en words: 5488, bold 7, em dash 1
RESULT: 0 FAIL(s), 0 WARN(s)

$ cd book-en && mdbook build
 INFO Book building has started
 INFO Running the html backend
 INFO HTML book written to '…/wt/book-en/book'
(exit 0,零警告)
```

## 6. 结论

**C2 通过。** 禁用词 0 banned / 0 filler;翻译腔 1 处已修 + hedging 1 处已修;术语、图 7-1/7-2 标签、数字、章号、技术名全部核对一致;2 处微改后 verify-en 0 FAIL、mdbuild 零警告。无移交事项、无 ZH 侧新疑点(本章 ZH↔EN 在读校范围内未发现事实性分歧)。
