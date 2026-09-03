# Ch11 引用核对报告(ch11-refcheck,peer A)

- 基线: octos main @ `9c157101`(只读核对,未改动源码仓库)
- 对象: `chapters/ch10-message-bus.md`(455 行;改号 Ch11 前的旧文件名)
- spec: `specs/ch11-message-bus.spec.md`「决策/勘误方式」(黑板第 15 条:octos-bus 17 频道对齐 main,原 Ch10 改号 Ch11)

## 汇总

| 项 | 数 |
|---|---|
| `crates/...rs` 引用总数 | **47**(46 条带行号区间 + 1 条文件级无行号) |
| ✅ 正确 | **19** |
| ⚠️ 行号漂移(符号正确、区间偏移,需改行号) | **11** |
| ❌ 符号不在区间 / 文件已拆分(需改引用目标) | **17** |
| 需修正合计 | **28**(❌17 必改,⚠️11 微调) |
| 频道文件实测 | **17 个**(与 spec 事实边界一致;章稿正文只覆盖 12-13 个 → 核心勘误点) |

另有正数验证:Channel trait 方法数「26 个、其中 `name()/start()/send()` 无默认实现」与 main 一致(channel.rs:17-265 共 26 个 `fn`,仅前 3 个无默认体)✅;「约 30K 行 Rust 源文件」已偏低(实测 `octos-bus/src/*.rs` 共 **40,937 行**,其中频道文件 18,207 行),建议改「约 40K 行」⚠️。

---

## A. 引用核对表(46+1 条,按章稿行序)

| 章稿行 | 引用 | 状态 | 符号名 | 当前正确行号 |
|---|---|---|---|---|
| 11 | channel.rs:17-248 | ⚠️行号漂移 | `trait Channel`(health_check 至 265,`ChannelHealth` 至 287) | 17-265 |
| 48 | channel.rs:85-93 | ✅ | `edit_message` | 85-93 |
| 49 | channel.rs:117-129 | ⚠️行号漂移 | `finish_stream` | 122-133 |
| 61 | channel.rs:95-200 | ⚠️行号漂移 | `edit_message_bound`/`finish_stream_bound`/`send_raw_sse_bound` 家族 | 107-201 |
| 75 | channel.rs:241-262 | ⚠️行号漂移 | `health_check`(245-251)+ `ChannelHealth`(268-287) | 245-251 / 268-287 |
| 79 | bus.rs:8-77 | ✅ | `AgentHandle`(9-51)/`BusPublisher`(52-77) | 8-77 |
| 98 | channel.rs:27-30 | ✅ | `is_allowed` | 28-31 |
| 104 | coalesce.rs:26-120 | ✅ | `ChunkConfig`+`split_message`+`find_break_point` | 26-118 |
| 122 | coalesce.rs:46-57 | ⚠️行号漂移 | `MAX_CHUNKS`+截断块(现还带 `warn!` 日志) | 57-71 |
| 126 | coalesce.rs:5-24 | ✅ | `ChunkConfig::{telegram,discord,slack,default_limit}` | 5-24 |
| 138 | coalesce.rs:84-120 | ⚠️行号漂移(轻微) | `find_break_point` | 87-118 |
| 163 | session.rs:482-503 | ⚠️行号漂移 | `struct Session` | 587-608 |
| 184 | session.rs:454-480 | ⚠️行号漂移 | `struct SessionMeta` | 560-584 |
| 184 | session.rs:1365-1381 | ✅ | `SessionManager::append_to_disk` 写 meta 行 | 1360-1381 |
| 184 | session.rs:2132-2149 | ❌符号不在区间 | `SessionHandle::append_to_disk`(文件现共 3417 行) | 2992-3060 |
| 188 | session.rs:1096-1146 | ✅ | `list_sessions_inner`(legacy flat 分支 1101-1126) | 1096-1146 |
| 189 | session.rs:1688-1859 | ⚠️行号漂移 | `load_from_disk` flat+per-user 合并 | 1608-1815 |
| 193 | session.rs:129-140 | ✅ | `encode_path_component` | 134-147 |
| 194 | session.rs:116-127 | ✅ | `fnv1a_64` | 121-133 |
| 194 | session.rs:1117-1146 | ❌符号不在区间 | FNV 后缀逻辑(在 `session_path_static`;1117-1146 现为 list_sessions_inner per-user 分支) | 1554-1610 |
| 198 | session.rs:15-16 | ✅ | `CURRENT_SESSION_SCHEMA = 1` | 16 |
| 201 | session.rs:1312-1388 | ✅ | `SessionManager::append_to_disk` | 1322-1381 |
| 201 | session.rs:2252-2319 | ❌符号不在区间 | `SessionHandle::append_to_disk`(canonical 写入路径 2388-2415) | 2992-3060 |
| 202 | session.rs:1390-1443 | ❌符号不在区间 | `SessionManager::rewrite`(1390-1443 现为 `data_dir`/`list_for_analysis`) | 1914-1963 |
| 202 | session.rs:2130-2174 | ❌符号不在区间 | `SessionHandle::rewrite`/`rewrite_blocking` | 2862-2987 |
| 204 | session.rs:91-114 | ⚠️行号漂移 | `rewrite_tmp_path`(含 `REWRITE_TMP_COUNTER` 90) | 90-117 |
| 206 | session.rs:685-686 | ❌符号不在区间 | `MAX_SESSION_FILE_SIZE = 10MB` const | 792-793 |
| 206 | session.rs:1197-1208 | ✅ | 超限检查(`.map(len > MAX)` 1206) | 1196-1208 |
| 206 | session.rs:2274-2294 | ❌符号不在区间 | SessionHandle 侧 10MB 检查(`load_from_disk`) | 1644-1649 |
| 210 | session.rs:1445-1465 | ❌符号不在区间 | `SessionManager::fork`(1445-1465 现为 list_for_analysis 体) | 1972-2010 |
| 220 | session.rs:688-706 | ❌符号不在区间 | `struct SessionManager`(+`impl`/`open` 908-921) | 903-905 |
| 220 | session.rs:1688-1702 | ❌符号不在区间 | `SessionHandle::open`(per-user 优先+迁移状态机;1688-1702 现为 load_from_disk 内部) | 2426-2530 |
| 225 | session.rs:716-760 | ❌符号不在区间 | `list_top_level_sessions*`(716-760 现为 `threads()`);内部 topic 判定 `is_internal_session_key` | 965-1005 / 1196-1208 |
| 225 | session.rs:934-947 | ✅ | `list_sessions` doc(skip internal topics) | 928-947 |
| 226 | session.rs:1704-1759 | ❌符号不在区间 | per-key persist lock:`persist_lock_for`+`persist_message_through_canonical_path`(1704-1759 现为 load_from_disk merge) | 2332-2420 |
| 230 | session.rs:265-359 | ❌符号不在区间(待重定位) | `derive_thread_id_for_new_write`/`synthesize_thread_ids`(265-359 已非此段;相关 doc 在 ≈397-415) | 写作时以 `grep -n 'derive_thread_id_for_new_write\|synthesize_thread_ids' session.rs` 为准 |
| 237 | session.rs:1033-1094 | ❌符号不在区间 | flat+per-user 合并时间线(`load_from_disk`;1033-1094 现为 list_user 系列) | 1676-1815 |
| 237 | session.rs:2052-2104 | ❌符号不在区间 | `SessionHandle::load_from_file` | 3061-3110 |
| 243 | session.rs:18-89 | ✅ | `MessageCommitObserver` hook(set/get/notify) | 17-90 |
| 260 | session.rs:71-89 | ✅ | `notify_message_commit`(best-effort fan-out) | 71-89 |
| 260 | `crates/octos-cli/src/api/ui_protocol.rs`(文件级,无行号) | ❌文件已拆分 | `ui_protocol.rs` 已不存在;`message/persisted` 旧记录/恢复逻辑在 ledger | `ui_protocol_ledger.rs`(LegacyMessagePersisted 294-330;recovery 跳过 1269-1423);transport 在 `ui_protocol_transport.rs` |
| 264 | session.rs:386-434 | ❌符号不在区间 | `struct ChildSessionContract` | 519-546 |
| 264 | session.rs:454-480 | ⚠️行号漂移 | `SessionMeta.child_contracts` 载荷 | 560-584 |
| 280 | coalesce.rs:34-82 | ✅ | `split_message` | 34-83 |
| 403 | session.rs:116-127 | ✅ | `fnv1a_64` | 121-133 |
| 403 | session.rs:1117-1146 | ❌符号不在区间 | 同章稿 194 行(FNV 后缀 → `session_path_static`) | 1554-1610 |
| 418 | session.rs:129-140 | ✅ | `encode_path_component` | 134-147 |

### 需修正清单(❌ 17 条,必改)

1. L184 `session.rs:2132-2149` → `2992-3060`(SessionHandle::append_to_disk)
2. L194 `session.rs:1117-1146` → `1554-1610`(FNV 后缀在 session_path_static)
3. L201 `session.rs:2252-2319` → `2992-3060`(或 canonical 写入 `2388-2415`)
4. L202 `session.rs:1390-1443` → `1914-1963`(SessionManager::rewrite)
5. L202 `session.rs:2130-2174` → `2862-2987`(SessionHandle::rewrite/rewrite_blocking)
6. L206 `session.rs:685-686` → `792-793`(MAX_SESSION_FILE_SIZE)
7. L206 `session.rs:2274-2294` → `1644-1649`(handle 侧 10MB 检查)
8. L210 `session.rs:1445-1465` → `1972-2010`(fork)
9. L220 `session.rs:688-706` → `903-905`(struct SessionManager)
10. L220 `session.rs:1688-1702` → `2426-2530`(SessionHandle::open 迁移状态机)
11. L225 `session.rs:716-760` → `965-1005`(list_top_level_sessions*)+ `1196-1208`(is_internal_session_key)
12. L226 `session.rs:1704-1759` → `2332-2420`(per-key persist lock)
13. L230 `session.rs:265-359` → 写作时 grep 重定位(derive/synthesize_thread_ids)
14. L237 `session.rs:1033-1094` → `1676-1815`(load_from_disk merge)
15. L237 `session.rs:2052-2104` → `3061-3110`(SessionHandle::load_from_file)
16. L260 `ui_protocol.rs` → `ui_protocol_ledger.rs` 294-330 / 1269-1423(文件已拆分,spec 接线点勘误条目所列家族)
17. L264 `session.rs:386-434` → `519-546`(struct ChildSessionContract)

⚠️ 11 条(行号微调):L11→17-265、L49→122-133、L61→107-201、L75→245-251(可加 ChannelHealth 268-287)、L122→57-71、L138→87-118、L163→587-608、L184(454-480)→560-584、L189→1608-1815、L204→90-117、L264(454-480)→560-584。

---

## B. 17 频道核对(核心勘误点)

`ls crates/octos-bus/src/*_channel.rs | wc -l` → **17**(与 spec 事实边界一致 ✅)。逐个(按 `wc -l`,2026-09-02 main @ 9c157101):

| # | 频道文件 | 行数 | Cargo feature |
|---|---|---|---|
| 1 | telegram_channel.rs | 963 | `telegram` |
| 2 | discord_channel.rs | 437 | `discord` |
| 3 | slack_channel.rs | 469 | `slack` |
| 4 | whatsapp_channel.rs | 515 | `whatsapp` |
| 5 | email_channel.rs | 567 | `email` |
| 6 | feishu_channel.rs | 2145 | `feishu` |
| 7 | twilio_channel.rs | 695 | `twilio` |
| 8 | wecom_channel.rs | 628 | `wecom` |
| 9 | wecom_bot_channel.rs | 931 | `wecom-bot` |
| 10 | qq_bot_channel.rs | 878 | `qq-bot` |
| 11 | wechat_channel.rs | 234 | `wechat` |
| 12 | matrix_channel.rs | 3905 | `matrix` |
| 13 | matrix_user_channel.rs | 1525 | (Cargo.toml 未单列 feature,以 lib.rs 声明为准) |
| 14 | dingtalk_channel.rs | 544 | `dingtalk` |
| 15 | line_channel.rs | 826 | `line` |
| 16 | api_channel.rs | 2808 | `api` |
| 17 | cli_channel.rs | 137 | (无 feature,始终编译) |
| — | 频道文件合计 | 18,207 | (crate 全部 40,937 行) |

### 章稿 vs 实测差异(Ch11 必须勘误处)

1. **频道一览表(L356-368)只有 12 个频道行**(Telegram/Discord/Slack/WhatsApp/Email/飞书/Twilio/企业微信/Matrix/WeCom Bot/QQ Bot/WeChat/API——表内 12 行),**实测 17 个**:缺 **CLI、DingTalk、LINE、Matrix User** 4 个定位行。按 spec「勘误方式」需各补一行(含 dingtalk/line/wechat/wecom_bot/matrix_user 中尚缺者;wechat/wecom_bot/qq_bot 已在表内)。
2. **L367 feature 清单列了 13 个**(`api/telegram/discord/slack/whatsapp/email/feishu/twilio/wecom/matrix/wecom-bot/qq-bot/wechat`),实测 feature-gated 频道还差 **`dingtalk`、`line`**(matrix_user 无独立 feature)。CLI readline「不在 feature 频道列表中」的说法正确 ✅。
3. **「约 30K 行」→ 实测 40,937 行**(L3、L367 两处),建议改「约 40K 行」。
4. L126 平台限制表(telegram 4000 / discord 1900 / slack 3900 / 默认 4000)与 `coalesce.rs:5-24` 一致 ✅。

## 方法备注

- 引用提取:`grep -on '\.\./octos/crates/[^`:。」,]*\.rs:[0-9-]*'`(46 条)+ 1 条无行号文件引用,无其他 `crates/` 引用形式。
- 行号核对:`grep -n 'fn |pub struct|const'` + 摘录比对(每处确认符号签名落点);session.rs 现共 3417 行、channel.rs 580、bus.rs 206、coalesce.rs 208。
- 源码仓库只读,未做任何修改;本文件是本次唯一产物,未 commit。
