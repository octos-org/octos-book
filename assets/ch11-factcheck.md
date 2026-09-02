# 第 11 章事实核查报告(ch11-factcheck)

**审查对象**: `chapters/ch11-message-bus.md`(master 定稿基线 ed02a3e;`cp` 落基线后与 `book/src/part3/ch11.md` 镜像 `cmp` 一致)
**事实基准**: `assets/ch11-refcheck.md`(99d1934);源码 `/Users/zhangalex/Work/Projects/FW/octos` @ `9c157101`(只读,范围 crates/octos-bus/src/,另核 octos-cli/src/api/ui_protocol_*.rs)
**审查员**: ch11-factcheck peer · 2026-09-03

## 汇总

五项检查全部执行:①**61 处**代码引用(47 处显式 `crates/...rs` + 14 处行内 `xxx.rs:NN` 简写)逐条比对,**59 处精确命中,2 处需修正**——其一为 refcheck 基准自身的过时数据(load_from_disk 区间 1608-1815,实测符号在 1611-1819),其二为 dingtalk:321 符号语义误置;②数字全部复核通过(17 频道逐个 ls、40,937/18,207、15 feature-gated+2、26 方法、平台限额逐值);③机械项 6/7 过:锚点 2 处无悬挂、mermaid 3、镜像 cmp 一致、「——」2≤2(borderline)、黑话 9 词 0 命中;**加粗 45 对,超 ≤15 预算**;④严格汉字 **5,208** ≥5,000(master 实测 5,048 复核通过);⑤SUMMARY.md:29 条目与 part3/ch11.md 在位。

**发现 3 处 P1,修后可定稿。**

## 分级

### P1(定稿前应修,3 处)

| # | 位置 | 问题 | 证据 | 修法 |
|---|---|---|---|---|
| 1 | 章 L189 | `load_from_disk` 区间 `session.rs:1608-1815` 符号不在区间:`async fn load_from_disk` 实际起于 **1611**;该函数(含内部 merge helper)收于 1819(下一方法 doc 起 1821、`append_to_disk` 在 1823),1608-1610 为 doc 注释行。refcheck 基准给的 1608-1815 是过时数据(差 3 行) | `grep -n 'async fn load_from_disk' session.rs` → **1611**;`awk 1818-1826` → 1819 `}` 收束、1823 `append_to_disk` | `:1608-1815` → `:1611-1819`(章 L189 一处;L237 的 1676-1815 不受影响) |
| 2 | 章 L390 | DingTalk 行号 321 语义误置:文中「回复优先发往这个缓存地址而不是全局配置的 webhook(dingtalk_channel.rs:**281、321**;无缓存且无配置时报错于 196 行)」。281(`.get("sessionWebhook")`,280-283)是**接收侧提取**✓、196 报错✓,但 321 是**入站事件归一化时构造 serde_json** 的字段,不是发送决策点 | 321:`"session_webhook": payload.get("sessionWebhook")`(构造 InboundMessage);发送优先级判定在 `send` 内 188-192(缓存命中 return Ok(url))、194-199(回退报错) | 发送侧引用改 `dingtalk_channel.rs:188-199`(或删 321,保留 281/196) |
| 3 | 章 L344 | 孤立残留行「4. **MAX_CHUNKS 保护**:超过上限时插入独立截断块,而不是静默丢尾部」悬在 `#### 11.4.1`(L329)与 `### 11.4.1 Unicode 安全的边界检测`(L346)之间,上文无列表可承接,编号「4.」无上下文;内容与 L122 重复。属上一版改写残留 | L343-346:空行→孤行→`### 11.4.1` 标题 | 删除该行(内容已被 L122 覆盖) |

### P2/P3(观察项,不阻断)

- **加粗 45 对(90 个 `**`)超 ≤15**(P2):扣除 fenced 代码块后统计不变(`awk '/^```/{f=!f;next} !f' | grep -o '\*\*'|wc -l` = 90)。构成:小节引导词约 20、对比侧栏 5、本章回顾 5、延伸/思考 4、图注/**定位**/三方案标题等。若团队惯例允许「引导词加粗」可豁免一半,建议编辑侧统一口径压缩。
- **版本演化说明双块**(P2):L485-486 旧格式「**版本演化说明**」+ L489-492「> ### 版本演化说明」基线块并存,内容互补但格式冗余,建议合并为单块。
- **小节编号冲突**(P2):L329「#### 11.4.1 窗口语义」与 L346「### 11.4.1 Unicode 安全的边界检测」编号重复且层级倒挂(#### 在 ### 前);L340「#### 11.4.2」同理。
- L225「跳过 `child-*` 与 `*.tasks` 等内部 topic」:`child-*` 字面核对✓(session.rs:152 推导、1190-1193 `starts_with("child-")`);`*.tasks` 只核到 `ends_with(".tasks")` 判定与 doc 注释(1188-1190),列表调用点(965-1005)未逐行追踪过滤路径。
- P3 微偏:`ChannelHealth` 枚举实测 **253-262**(章 L75 写 253-265,265 已入 `ChannelManager` doc 区);`SYNC_TIMEOUT_MS` 定义在 matrix_user_channel.rs:**45**(章 L394 写 44,44 为 doc 首行);L198 引用 `session.rs:15-16` 而定义在 16(15 为 doc 行)——三处均 1-2 行 doc 行偏差,符号与语义正确。

### 未覆盖(范围外/风险低)

octos-core `truncate_utf8` 算法逐字比对(仅确认存在:octos-core/src/utils.rs:6);mermaid 图与正文一致性的图形级核对;`sessionWebhook` 缓存 TTL 行为(章文未给出具体数值,无核对目标)。

## 检查明细(计数附命令)

1. **引用路径/行号/符号** — 61 处(47 显式 + 14 行内简写),59✓ / 2✗(P1-1、P1-2):
   - channel.rs(580 行):trait **17**-248✓(17-265 含 health_check✓;`awk 17,248|grep -cE 'fn '`=**26**✓;无默认实现 name/start/send **3**✓) is_allowed 28-30✓(27-30) edit_message 86-93✓(85-93) finish_stream 122-133✓ bound 家族 107-201✓ health_check 245✓ ChannelHealth 253-262(章 253-265,P3)
   - bus.rs(206 行):AgentHandle 9-51✓ BusPublisher 52-77✓(8-77✓)
   - coalesce.rs(208 行):ChunkConfig 5-24✓(telegram 4000/discord 1900/slack 3900/default 4000 逐值✓) MAX_CHUNKS=50 **27**✓ split_message 34-82✓ 截断块+warn 48-55✓(47 命中) find_break_point 87-118✓(rfind 89/95/101/107,pos>0 拒绝 96/101/107/109,硬切 112-116) 窗口 66-73✓(72-73、68-71) 单空格 76-78✓
   - dedup.rs(162 行):DEFAULT_CAPACITY=1000 **14**✓ DEFAULT_TTL=60s **17**✓ struct **20**✓(12-25✓) is_duplicate **44**✓(42-61✓);discord_channel.rs:32✓
   - session.rs(3,417 行)33 处:590-608✓ 562-584✓ 1365-1381✓ 2992-3060✓ 1096-1146✓ **1611-1819**(章 1608-1815 ✗ P1-1) 134-143✓ 121-129✓ 1554-1610✓(HASH_SUFFIX 1556-1576) 16✓ 1312-1388✓ 1914-1963✓ 2862-2987✓(rewrite 2862/rewrite_blocking 2944) 90-117✓(counter 104/fn 113) 792-793✓ 1196-1208✓ 1644-1649✓ 1972-2010✓ 903-905✓ 2426-2530✓(open 2431/迁移状态机 2443) 965-1005✓ 934-947✓ 2332-2420✓(persist_lock_for 2360✓ persist_message_through_canonical_path **2388**✓) 288✓ 328✓ 1676-1815✓(指标点 1347/2759,synth 调用 450/455) 3061-3110✓ 17-90✓ 71-89✓ 519-546✓;尾注 2329✓(doc 2318-2328)/2388✓/2360✓/2443-2459(章 2441-2460)✓/2405-3108(章约 2400-3100)✓
   - ui_protocol_ledger.rs:LegacyMessagePersisted **294**✓(294-330✓) 恢复跳过 **1269-1423**✓;`ls ui_protocol_*.rs|wc -l`=**8**✓(章「拆分为 7 个文件」= 8 减 tests,口径成立)
   - 四新频道行:dingtalk 280-283✓(281)/321 语义误置(P1-2)/195-199✓(196);line 88-94✓(87-95,HMAC+BASE64+ct_eq 94);matrix_user SYNC_TIMEOUT_MS=30_000 在 **45**(章 44,P3);cli 52-56✓(52-57,stdin/stdout/提示符)
2. **数字** — `ls crates/octos-bus/src/*_channel.rs|wc -l`=**17**✓;`xargs wc -l` 合计 **18,207**✓(telegram 963/discord 437/slack 469/whatsapp 515/email 567/feishu 2145/twilio 695/wecom 628/wecom_bot 931/qq_bot 878/wechat 234/matrix 3905/matrix_user 1525/dingtalk 544/line 826/api 2808/cli 137,与章表逐一相符);`cat src/*.rs|wc -l`=**40,937**✓;Cargo.toml `[features]`=**15**✓(api/telegram/discord/dingtalk/slack/whatsapp/feishu/line/twilio/wecom/matrix/wecom-bot/qq-bot/wechat/email)+cli 无门✓+matrix_user 随 matrix(lib.rs:31-32 双 `cfg(feature="matrix")`)✓;Twilio max_message_length=1600✓(247-249)
3. **机械项** — mermaid `grep -c '```mermaid'`=**3**✓;镜像 `cmp` 一致✓(cp 自 master 后复核仍一致);「——」`grep -o|wc -l`=**2**≤2✓;加粗 **45 对**>15(P2);黑话 9 词(抓手/赋能/闭环/打通/沉淀/助力/践行/势能/组合拳)`grep`=**0**✓;锚点 2 处(第 2 章 truncate_utf8、第 13/14 章区分)无悬挂✓;基线块含 `9c157101`+「2026-09-03 核对」✓
4. **字数** — `grep -o '[一-鿿]' chapters/ch11-message-bus.md|wc -l`=**5,208**≥5,000✓(master 5,048 复核通过,494 行完整镜像口径)
5. **SUMMARY** — `grep -n 'part3/ch11' book/src/SUMMARY.md` → **29 行**✓;`book/src/part3/ch11.md` 在位✓

## 是否可定稿

**修 3 处 P1 后可定稿。** P1-1(L189)与 P1-2(L390)为行号单点小改,P1-3(L344)删一行残留,均不动文字结构与镜像之外的任何内容;P2(加粗超标、版本演化双块、小节编号冲突)属编辑侧统一口径事项,P2/P3 与未覆盖项不阻断。其余 59 处引用、全部数字、17 频道口径、镜像一致性均与源码 @ 9c157101 逐项吻合;refcheck 基准(99d1934)仅 load_from_disk 一处区间过时,已在本报告给出修正值。
