# ch02 英文版 C2 读校报告(ch02-en-review)

- 日期:2026-09-02
- 读校对象:`book-en/src/part1/ch02.md`(前置 a23b4e4 交付,C1 4ed7b68 6/6 PASS)
- 对照:中文底稿 `chapters/ch02-core-types.md`;规范 `.octos/skills/trilingual-collab-en.md`;术语表 `assets/glossary-en.md`;ch01 英文版
- 性质:语言去味 + 母语度 + 技术读校;不改事实/数字/引用/mermaid/代码块

## 1. 禁用词 / 翻译腔(逐条对照 trilingual-collab-en.md)

| 规则 | 命中 | 判定 |
|---|---|---|
| 禁用词(delve/foster/leverage/robust/seamless 等 23 词) | 0 | PASS(grep 全文件零命中;`harness` L239/L278 均为技术名词,规则明示保留) |
| Hedging/filler 副词(really/just/actually 等) | 0 | PASS(仅 L38 "cannot"、L350 "does not just say" 为实义 not,非 hedging) |
| Filler 短语(it's worth noting / at its core / in order to…) | 0 | PASS |
| Colon reveal | 0 | PASS(全文冒号均为列举/标签/引用合规用法:L5 语言定义、L73 图题、L139 前后者列举、L322 指代说明,无 "The best part:" 式揭示) |
| Recap ending / fake-profound kicker | 0 | PASS(L587 收尾句对应中文底稿 L585"驯服混乱接口",是具体承接非空泛升华;"Chapter Recap" 一节为全书固定栏目,非 AI slop) |
| Bold 撒粉 | 0 | PASS(13 处 bold 全部为结构标签:Positioning/Version note/设计要点词条/函数词条/侧栏选项,无强调性撒粉) |
| Em dash | 0 | PASS(全文 0) |
| 被动语态 | 22 处 be+V-ed | PASS(逐条核过:is defined at / is initialized / are skipped 等均为"X 定义于路径"的定位句与 serde 行为描述,主语无施事者可还原,主动化反而绕;无滥用) |
| Binary contrast("not X, it's Y") | 6 处形态命中 | PASS(逐条核过:L34/L239/L278/L322/L475/L484 均为真值对比——v7 vs v4、eyre vs anyhow、thin vs fat——被驳立场真实存在,符合规则的"live position being refuted"豁免) |
| -ing 尾随从句(highlighting/underscoring) | 0 | PASS |
| 三连排比 | 1 处(L502 五动作列举,实为 5 项非三连) | PASS |
| 喉咙清理开头 | 2 处拟态 | 修 1 处(见 §4) |

## 2. 母语度与术语一致性

- **Rust 术语**:本章不涉及 borrow checker / trait object / lifetime 等表;出现的 ownership(L403)、borrowed(L408)、`Option`/`Copy`/`Display` 均为标准 Rust 术语原生用法,与 glossary-en.md 无冲突。glossary 中 ch02 相关词条(domain language / zero-dependency core / thin core / cross-crate protocol field / optimistic UI / durable ABI / abort trigger / session routing key / truncation report)在正文中用法逐一吻合。
- **C1 备注「Version note 块多一行加粗标签」**:实测这是**全书既定格式而非 ch02 孤例**——EN ch01(L381-383)、EN ch05(L308-310)均为 `## Version note` 标题 + `> **Version note**:` 加粗标签的相同双层结构,且 verify-en.sh 第 35 行将 `^> \*\*Version note\*\*` 设为**强制 FAIL 项**(appendix/preface 之外)。CN 底稿只有 `## 版本演化说明` 标题无块内标签,差异源自脚本契约,不是翻译腔。**判定:不改,保持现状**(改了会直接 FAIL)。
- 母语度总评:文风干净,句构无翻译腔长定语堆叠;仅 2 处「X deserves a look / merits a closer look」式软性预告属中文"值得一看"直译的轻微残留,处理见 §4。

## 3. 技术读校

### 3.1 状态机 mermaid 边标签(L62-71)

7 条边标签逐一对照中文底稿:created / assigned to Agent / waiting on external resource / execution succeeded / execution failed / block cleared / timeout or cancel。判定:

- 6 条准确;"**block cleared**"(阻塞解除)语法上更自然的写法是 "block cleared" 作事件名读作 "(the) block (was) cleared"——事件标签惯例允许省略被动助动词,与同图 "execution succeeded" 的主动式并存不构成错误。**通过,不改**(改标签会触碰"不改 mermaid"红线)。
- "timeout or cancel"(超时或取消):名词化事件名,准确。
- 图注 L73 "Pending can move only to InProgress (never straight to Completed)" 与图一致,且与 L329 侧栏、L56 `status="pending"` 反例的口径自洽。

### 3.2 类型系统口径与 ch01 英文版一致性

- **所有权/借用**:ch02 仅 L403-408 用到 ownership semantics / borrowed(`&str`),与 ch01 L45/L116/L122 的 ownership / borrow 用法同词同义,口径一致。
- **无生命周期/trait object 表述**,无需对表。
- `Option<T>` 表述(L38 "makes the compiler force callers to handle…"、L26 serde default 回退)与 ch01 "compile-time enforcement" 叙事口径一致。
- 数字抽查:15 variants(L300↔L607)、28 triggers/9 languages、19 channels、22,313/15,005/7,308 行数,与 Version note 及 C1 数字集合校验一致,读校层无新出入。

## 4. 改动(共 2 处,均在 book-en/src/part1/ch02.md)

| 行号(改前) | 原文 | 改后 | 理由 |
|---|---|---|---|
| L109 | `TokenUsage (…) merits a closer look. It tracks more than…` | `TokenUsage (…) tracks more than…` | 喉咙清理式预告("值得细看"),规则 2:删预告直陈要点;原为两句合一后更紧凑 |
| L284 | `The choice deserves a close look.` | `The reasons are worth working through.` | 同类软性预告;下节标题即 "the reasons",改为直接引向内容 |

保留未改(判定为可接受,记录备考):L32 "stand out"、L105 "deserves attention"、L221 "Two examples stand out"、L510 "deserves a look"、L532 "merit a second look"——频次偏高但各自承载段落路标功能,且"值得注意"型在技术书注册语域内成立;如后续 lane 统稿想收敛该句型,建议一次性处理全书而非仅 ch02。

## 5. 复验输出(改动后实跑)

```
$ bash ~/.octos/outer/verify-en.sh chapters/ch02-core-types.md book-en/src/part1/ch02.md
refs: 54 (equal sets: yes)
en words: 4901, bold 13, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
EXIT=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

verify-en 0 FAIL(引用 54 集合相等、bold 13、em dash 0,词数 4906→4901 因两句删减);mdbook 构建 WARN/ERROR 计数 0。

## 6. 结论:C2 通过(可定稿)

- 禁用词/翻译腔:12 项规则逐条过,0 硬命中;2 处软性预告已修。
- 术语一致性:与 glossary-en.md 及 ch01 英文版全部吻合;Version note 加粗标签为脚本强制的全书格式,维持。
- 技术读校:状态机 7 边标签译文准确;所有权/借用口径与 ch01 一致;数字抽查无出入。
- 未 commit(遵照 brief);工作区仅 `book-en/src/part1/ch02.md` 与本报告两个文件变更。
