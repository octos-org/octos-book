# Ch7 factcheck 报告(C1,ch07-factcheck)

- 审查对象:`chapters/ch07-security.md`(v2 候选,取自 master 定稿 commit `66946a3`,246 行)
- 事实基准:`assets/ch07-facts.md` @ `7ad7a72`;源码只读 `/Users/zhangalex/Work/Projects/FW/octos` @ `9c157101`(工作树 clean,`git status --porcelain` = 0)
- 基线防旧:`cmp` 镜像一致;`66946a3:chapters/ch07-security.md` 与 `66946a3:book/src/part2/ch07.md` 均与本地副本逐字节一致(MASTER_CH_OK / MASTER_BK_OK);两提交均为 `9c157101` 祖先(merge-base --is-ancestor 通过)

## 汇总表

| 检查项 | 结果 | 判定 |
|---|---|---|
| 1a) 路径存在(10 个 .rs) | 10/10 存在 | ✅ |
| 1b) 行号命中(46 处 `path:line` 引用) | 46/46 符号在区间;其中 2 处区间偏移见 P2-1/P2-2 | ✅(2 处偏移) |
| 1c) sandbox 六文件行数 | 2190/1767/498/392/325/175,合计 5347,与章一致 | ✅ |
| 1d) SandboxMode :423 七变体 / MountMode :408 三变体 | 实测 7 / 3,逐变体行号全中 | ✅ |
| 1e) impl Sandbox 七处 | bwrap:29 / docker:36 / landlock:27 / macos:185 / mod:500 / mod:914 / windows:46 全中 | ✅ |
| 1f) grant.rs 五锚点 | NetworkGrant:76 / FsGrant:127 / WorkerGrant:151 / GrantError:359 / validate:247 全中;WorkerGrant 五字段 :154/:157/:160/:179/:189 全中 | ✅ |
| 1g) 两提交 | eb7c7221 = 14 files +1621/−158(2026-08-31);ffcde205 = 4 files +140/−82(2026-08-26) | ✅ |
| 2) 数字核对 | 5,347 ✓ 七变体 ✓ 五字段 ✓;**BLOCKED_ENV_VARS 章称 20 项,实测 18 项** | ❌ P1-1 |
| 3a) 锚点 | 定位块引 ✓ 工程决策侧栏×2 ✓ 延伸阅读 ✓ 思考题 ✓ 版本演化 ✓ | ✅ |
| 3b) mermaid ≥1 | 2 个(`grep -c '```mermaid'` = 2) | ✅ |
| 3c) 镜像 cmp | MIRROR_OK(逐字节一致) | ✅ |
| 3d) ——破折号 ≤2 | 0(`grep -o '——' \| wc -l` = 0) | ✅ |
| 3e) 加粗 ≤15 | 6 对(`grep -oE '\*\*[^*]+\*\*' \| wc -l` = 6) | ✅ |
| 3f) 黑话 9 词 | 赋能/抓手/闭环/打通/沉淀/助力/践行/势能/组合拳 全部 0 次 | ✅ |
| 4) 字数 ≥5,000 | **4,527**(去 fenced 代码块后汉字数,inline code 计入;inline code 一并去掉为 4,523)——未达标,差 473 | ❌ P1-2 |
| 5) 旧叙事残留 | 旧稿「五层+第零层」图已整体替换;新稿 :150「前三层防御」、:177「三层语义」均指本章四层内前三层/三个取值,与新叙事自洽,无冲突 | ✅ |
| 附) SUMMARY 锚点 | book/src/SUMMARY.md:20 仍是旧标题「安全纵深:从沙箱到 Prompt 注入防御」 | ⚠️ P2-3 |

## 分级发现

### P1(事实/硬指标,定稿前必须处理)

1. **§7.1.5「一个 20 项的清单」→ 实际 18 项。** 且本章自己列的四组计数 3(LD_*)+5(DYLD_*)+7(runtime)+3(shell startup)=18,与「20 项」自相矛盾。事实表未记此数,系 writer 笔误。
   ```
   $ sed -n '23,55p' crates/octos-core/src/env_hygiene.rs | grep -c '^\s*"'
   18
   $ grep -c '"LD_' crates/octos-core/src/env_hygiene.rs   → 3
   $ grep -c '"DYLD_' ...                                  → 5
   ```
   改法:「一个 20 项的清单」→「一个 18 项的清单」。

2. **字数未达 ≥5,000:4,527。**(与 master 已知值 4,527 一致,确认无回归;新增字数未发生。)统计口径:去 ``` fenced 块(含 mermaid)后统计汉字,inline code 保留;若 inline code 也剔除为 4,523。是否以 5,000 为硬门槛由 master 裁决;如实报告:**未达标,差 473 字**。

### P2(引用区间偏移/外围锚点,建议顺手改)

1. §7.1.4 Docker:`is_blocked_bind_source`(章引 `docker.rs:24-33`)→ 函数签名实际在 **:20**,函数体 :20-27;24-33 只盖住函数体尾部+struct 声明。建议改 `docker.rs:20-27`。
2. §7.1.4 bwrap:「(`bwrap.rs:30-40` 的字段文档)」→ repo_git_write 字段文档实际在 **:18-26**;:30-40 是 `impl Sandbox for BwrapSandbox` 开头(内容相关但称谓「字段文档」与区间不符)。建议改 `bwrap.rs:18-26`。
3. **book/src/SUMMARY.md:20 目录条目为旧标题**「第 7 章:安全纵深:从沙箱到 Prompt 注入防御」,新章题为「安全纵深:沙箱 fail-closed、注入防御与能力授予」。章文件本身正确,属外围锚点失同步。

### P3(口径/措辞,不改亦可)

1. §7.4.3 与 7.5「五类不一致」与正文分组不一致:正文 4 个条目(最后一项「#1976 四连」含 4 个变体),按变体数是 3+4=7,与侧栏「GrantError 七个变体」一致。「五类」两头不靠,建议统一口径(如「三类 + #1976 四变体」或「七变体」)。
2. §7.1.4 macOS:章引 `macos.rs:205-212` 为注入防御;检查谓词在 :199-204,:205-212 是拒绝分支(符号在区间,判定通过,偏移备忘)。
3. §7.4.3「validate 在两个时点调用:goal_plan 解析时与 registry 构建时」:plan 变更路径重跑 `grant.validate()` 佐于 `crates/octos-fleet/src/records.rs:234` 文档;「registry 构建时」未逐点核实(unverified,倾向成立)。
4. §7.3.1「before_tool_call hook exit 1」未逐点核实(prompt_guard.rs:19+ 架构缓解段与 agent 执行链,超出本轮范围)。

## 已验证无误的抽样证据(全部来自命令输出)

```
$ wc -l crates/octos-agent/src/sandbox/*.rs
 2190 mod.rs / 1767 macos.rs / 498 bwrap.rs / 392 docker.rs / 325 windows.rs / 175 landlock.rs / 5347 total
$ grep -n 'impl Sandbox for' sandbox/*.rs     → 7 处,行号与章逐一相符
$ sed -n '408,445p' mod.rs                    → MountMode None:410/ReadOnly:413(ro)/ReadWrite:417(rw,#[default]);
                                                SandboxMode Auto:426(#[default])/Bwrap:428/Landlock:430/Macos:432/Docker:434/
                                                AppContainer:437(appcontainer)/None:439
$ grep -n 'pub trait Sandbox' mod.rs          → 443
$ grep -n 'pub enum NetworkGrant\|pub enum FsGrant\|pub struct WorkerGrant\|pub enum GrantError' grant.rs
  → 76 / 127 / 151 / 359;validate :247;validate_write_path_pattern :307;GrantError 7 变体实测
$ git show --stat eb7c7221 | tail -1          → 14 files changed, 1621 insertions(+), 158 deletions(-)
$ git show --stat ffcde205 | tail -1          → 4 files changed, 140 insertions(+), 82 deletions(-)
$ python3 han-count(去 fenced)               → 4527
```

其余抽验通过的关键语义:stderr_line 字符白名单 `[A-Za-z0-9 ./:_=,-]`(mod.rs:731 逐字符一致)、Display「will keep refusing until then」(mod.rs:711)、decide_sandbox 契约三条(mod.rs:800-808)、Auto 文档注释三平台(mod.rs:425)、warn_auto_unconfined_once 用 std::sync::Once(mod.rs:1040)、landlock 助手缺失拒绝文本(landlock.rs:35 逐字一致)、macOS SBPL 元字符拒绝(macos.rs:199-206)、#1976 SBPL per-glob 注释在 build_backend(mod.rs:1084,fn :1075)、fence 三函数 :955/:970/:985、scrub_credentials Anthropic 先于 OpenAI(sanitize.rs:63-67)、redact_credential 前 4 字符(sanitize.rs:56-57)、七凭据正则齐(sanitize.rs:23-49)、AWS=AKIA+16 位大写数字、is_special_purpose_v4 四段范围(ssrf.rs:244-256)、IPv6 两条映射递归(ssrf.rs:273-278)、测试 :580/:590、两提交日期与 PR 号。

## 是否可定稿

**否(原样不可);补 4 处小改后可定稿。** 必改:①「20 项」→「18 项」(P1-1);②字数差 473,需 master 裁决是否放宽或补写(P1-2)。建议顺手:③`docker.rs:24-33`→`docker.rs:20-27`;④`bwrap.rs:30-40`→`bwrap.rs:18-26`;⑤SUMMARY.md:20 目录标题换新。四处均为纯文本微调,不需要重跑事实表。
