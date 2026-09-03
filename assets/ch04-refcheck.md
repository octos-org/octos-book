# Ch4 引用核对报告（assets/ch04-refcheck.md）

- 核对人: peer A `ch04-refcheck`（lane cheap）
- 日期: 2026-09-02
- 源码基线: `/Users/zhangalex/Work/Projects/FW/octos` @ main `9c157101`（只读，未改动）
- 章稿: `chapters/ch04-memory-search.md`（383 行，rewrite-v2）
- 契约: `specs/ch04-memory-search.spec.md`
- 方法: `ls` 验路径 → `wc -l` 验越界 → `grep -n` 验符号在区间 → 代码摘录逐段与源码 diff

## 汇总

- **总引用数: 31**（含 4 处纯路径引用 + 26 处带行号区间引用 + 文首目录注记 1 处）
- ✅ 路径存在且行号/符号正确: **7**
- ❌ 路径不存在: **0**（所有路径均存在；但 1 处符号完全不在区间，归入 ❌）
- ⚠️ 行号漂移（符号仍在文件内、区间失效）: **19**
- ⚠️ 符号不在区间（指向了别处代码）: **4**
- **需修正合计: 24 / 31**。根因单一：章稿行号基于旧版源码，cc6744ba / 4ccdbe7e / 9ad56caa 三个提交大幅改动 hybrid_search.rs（现 1,527 行）、store.rs（现 1,940 行）、memory_store.rs（现 2,417 行），几乎全部引用整体下移。**建议按「符号名 + 重新实测行号」整表重标（spec 勘误方式段亦如此要求）。**

需修正清单（高优先）:
1. L68 `loop_runner.rs:368-395` → 符号不在区间，实际 2,474-2,504
2. L264 `store.rs:171-187`（空索引 DB 扫描）→ 实际 `find_relevant_db_scan` 554-，判定分支 467
3. L284 `memory_store.rs:102-147` / `:110` → 实际 `get_memory_context` 571-573、`read_recent(7)` 调用点 520
4. L296 `memory_store.rs:153-241`（entity bank）→ 实际 673-841 + `extract_abstract` 1222-1241
5. 其余 19 处 ⚠️ 行号漂移逐条见主表「当前正确行号」列

---

## A. 引用核对表

状态图例: ✅ 正确；❌ 路径不存在；⚠️漂 行号漂移（文件内但区间失效）；⚠️区间 符号不在所引区间。行数上限: episode.rs=195, hybrid_search.rs=1,527, store.rs=1,940, memory_store.rs=2,417, loop_runner.rs=3,979（均未越界）。

| 章稿行号 | 引用 | 状态 | 符号名 | 当前正确行号或说明 |
|---|---|---|---|---|
| 15 | `crates/octos-memory/src/store.rs`（纯路径） | ✅ | redb 持久化层 | 路径存在 |
| 27 | `store.rs:14-20` | ✅ | `EPISODES_TABLE`/`CWD_INDEX_TABLE`/`EMBEDDINGS_TABLE` | 14-20，三表定义精确命中 |
| 45 | `crates/octos-memory/src/episode.rs:21-43` | ⚠️漂 | `pub struct Episode` | 实际 32-59（21-30 现为 `EpisodeSource` 枚举） |
| 62 | `episode.rs:72-81` | ⚠️漂 | `enum EpisodeOutcome`（Success/Failure/Blocked/Cancelled） | 实际 86-98（四种结果不变） |
| 64 | `episode.rs:24` | ⚠️漂 | `schema_version` 字段 | 实际 36（`#[serde(default)]` 35） |
| 64 | `episode.rs:16-17` | ✅ | `default_schema_version()` → `CURRENT_SCHEMA_VERSION`=1 | 16-18（常量在 14），所述「默认值 1」成立 |
| 68 | `crates/octos-agent/src/agent/loop_runner.rs:368-395` | ❌区间 | EndTurn 写 Episode（`save_episodes` + `Episode::new` + `store()`） | 368-395 是无关代码；实际写入块 2,474-2,504（EndTurn 臂 2,457 起） |
| 68 | `crates/octos-memory/src/store.rs:87-151` | ⚠️漂 | 落库逻辑 `pub async fn store()` | 实际 371-423；87-111 是 salvage 解析（见 L78） |
| 78 | `store.rs:109-127` | ⚠️漂 | 腐败恢复 `parse_episode_ids_with_salvage`（按引号分割抢救 ID） | 实际 84-111；机制描述与源码一致 |
| 80 | `store.rs:291-370` | ⚠️漂 | `delete_by_id()`（三表删除 + `HybridIndex::remove()` tombstone） | 实际 757-825；tombstone 在 hybrid_search.rs 358-365（`ids[pos].clear()`，与描述一致） |
| 86 | `crates/octos-memory/src/hybrid_search.rs`（纯路径） | ✅ | 倒排索引/BM25 | 路径存在 |
| 91 | `hybrid_search.rs:8-28`（简化） | ✅ | `struct HybridIndex`（inverted/doc_lengths/total_len/avg_dl/ids） | 结构体 8-39；所列字段均在区间内，「简化」声明成立 |
| 104 | `hybrid_search.rs:288-295` | ⚠️漂 | `fn tokenize` | 实际 731-737；代码摘录与源码逐字一致 |
| 120 | `hybrid_search.rs:251-285` | ⚠️漂 | BM25 核心公式 | 实际 `bm25_score` 636-722，公式（K1/B 项）655-661 |
| 126 | `hybrid_search.rs:31-32` | ⚠️漂 | `BM25_K1=1.2` / `BM25_B=0.75` | 实际 83-84 |
| 135 | `hybrid_search.rs:259` | ⚠️漂 | IDF 计算 `((n - df + 0.5)/(df + 0.5) + 1.0).ln()` | 实际 677（dense 路径）/693（sparse 路径）；摘录等价（章稿写 `n as f64`，源码 n 已是 f64） |
| 145 | `hybrid_search.rs:271-284` | ⚠️漂 | epsilon 防 NaN（`max_score < 1e-10` 提前返回空） | 实际 703-706（阈值判断）+ 718-721（归一化）。摘录与源码有出入：源码为 `result.iter().map(\|&(_, s)\| s).fold(0.0f64, f64::max)`，非 `bm25_scores.values().cloned()`，重写时需同步 |
| 175 | `hybrid_search.rs:41-47` | ⚠️漂 | HNSW 参数（M=16/capacity=10_000/ef=200/max_layer=16） | 实际 132-138（`HNSW_MAX_NB_CONNECTION` 等 4 常量）；参数值全部正确 |
| 184 | `hybrid_search.rs:86-98` | ⚠️漂 | 容量 80%/100% 警告 | 实际 277-290（`insert()` 内 `tracing::warn!`）；两档阈值与描述一致 |
| 188 | `hybrid_search.rs:137` | ⚠️漂 | `DistCosine`、similarity = 1 - distance | `DistCosine` 泛型在 20（另 349/424）；`1.0 - n.distance` 在 456-457 |
| 194 | `hybrid_search.rs:297-305` | ⚠️漂 | `fn l2_normalize` | 实际 741-747；摘录与源码逐字一致 |
| 206 | `hybrid_search.rs:301` | ⚠️漂 | 零向量保护 `norm < f32::EPSILON` → `None` | 实际 743 |
| 229 | `hybrid_search.rs:35-37` | ⚠️漂 | `DEFAULT_VECTOR_WEIGHT=0.7` / `DEFAULT_BM25_WEIGHT=0.3` | 实际 92、94（0.7/0.3 不变） |
| 238 | `hybrid_search.rs:72-76` | ⚠️漂 | `pub fn with_weights` | 实际 250-254 |
| 242 | `hybrid_search.rs:221-237` | ⚠️漂 | 融合逻辑（vector×0.7 + bm25×0.3） | 实际 465-481（`has_vectors` 分支）。摘录是语义等价简化：源码按模态分别累加进 `combined`，且 vector_scores 为空时直接用 BM25 分数（L254-256 正文对此描述正确） |
| 264 | `store.rs:171-187` | ⚠️区间 | 空索引退回 redb 扫描 | 171-187 是 `open()` 文档区；实际 `find_relevant_db_scan` 554 起、索引空判定分支 461-467 |
| 272 | `crates/octos-memory/src/memory_store.rs`（纯路径） | ✅ | MemoryStore | 路径存在 |
| 284 | `memory_store.rs:102-147` | ⚠️区间 | `get_memory_context()` 构建 7 天上下文 | 实际 571-573（token 预算版 `get_injectable_context` 583 起）；102-147 是 `write_atomic_with_backup` 等无关代码 |
| 284 | `memory_store.rs:110` | ⚠️区间 | `read_recent(7)` 调用 | 实际 520（`load_sections` 内）；110 处无此调用 |
| 296 | `memory_store.rs:153-241` | ⚠️区间 | entity bank（bank 目录/摘要注入/读写 entity） | 实际：`bank_dir` 673、`list_entities` 685、`read_entity` 718、`write_entity` 734、`get_bank_summary` 785-841、`extract_abstract` 1222-1241；153-241 现为无关代码 |
| 383 | 文首注记：`crates/octos-memory/src/` 目录 + 「1,635 行」 | ✅* | 目录引用正确；但行数自相矛盾 | 章头 L3/L7 写「约 1,750 行」、回顾 L344 写「1,635 行」，两处不一致（spec 口径约 1,600）。`wc -l` 原始总行数 6,428（含测试），建议统一为 tokei 口径并改用同一数字 |

### 摘录 diff 结论（章稿代码块 vs 源码）

- 逐字一致: `tokenize`（L104）、`l2_normalize`（L194）、默认权重常量（L229）、IDF 表达式（L135，仅 `n as f64` 写法差异）。
- 有出入需同步: L145 epsilon 块（变量名/初值与现实现不同）；L242 融合伪代码（语义等价但非逐字，且未体现 `has_vectors` 分支）；L91 结构体（已声明「简化」，可保留但建议补 `hnsw`/`dimension` 字段以引出 §4.5）。

---

## B. 新面必补盘点（spec「新面三处必补」+ 事实边界）

基线 `9c157101` 上三个提交均在 main 祖先链中（`git merge-base --is-ancestor` 全部通过），源码可核对。

### ① `cc6744ba` — BM25 top-k 分区 + dense accumulator（检索热路径改写）

- 文件: `crates/octos-memory/src/hybrid_search.rs` ✅ 存在
- 关键符号与行号:
  - `DENSE_ACCUM_DIVISOR: usize = 8` — L89（查询触达 `n_docs/8` 以上 postings 时切 dense 累加器）
  - `matched_postings` 预估 — L645-649
  - dense 分支（`vec![0.0f64; n_docs]` + `touched` 去重回收）— L671-686；sparse HashMap 分支 — L688-699
  - top-k 分区 `select_nth_unstable_by(limit-1) + truncate` 替代全排序 — L713-716；`by_score_desc`（NaN 视为相等）— L726-728
- 提交说明（实测 commit message）: 高 df 查询（无停用词过滤，`the` 的 df≈n）下消除两遍开销（哈希累加 + 全量排序），**结果不变**，4 个 brute-force oracle 测试；10x 量级
- 补什么: §4.3 检索热路径需新增小节/段落：BM25 打分按 matched_postings 阈值切换 dense/sparse 累加器，top-k 用 `select_nth_unstable_by` 分区而非全排序；注明 cc6744ba
- 章稿现状: ❌ 未提及（全文无「分区」「dense」字样）→ **需补**

### ② `9ad56caa` — `octos memory reindex`（修复缺失/错宽 embedding）

- 文件: `crates/octos-cli/src/commands/memory.rs` ✅ 存在 + `crates/octos-memory/src/store.rs` ✅ 存在
- 关键符号与行号:
  - CLI 入口 `MemoryAction::Reindex { dry_run, data_dir }` — memory.rs L44-51；分发 L95；`run_reindex` — L148-（无 embedder 时直接提示并退出，L156）
  - 工作清单 `episodes_needing_vectors()`（缺失或宽度不符、跳过空摘要）— store.rs L670
  - 回填 `store_embedding()` — store.rs L712（章稿 L74 已提到两阶段写入，但未提 reindex）
- 提交说明: 换 embedding 模型 = 换向量宽度，旧向量不可转换只能再生；此前唯一的「修复」是删 `episodes.redb`；reindex 用已持久化的 `episode.summary` 重新嵌入
- 补什么: §4.7 运维向内容（或 §4.5.4 降级之后）：`octos memory reindex [--dry-run]` 的用途、入口文件、需先停 `octos serve`（store 锁）；注明 9ad56caa
- 章稿现状: ❌ 未提及 `reindex` → **需补**

### ③ `4ccdbe7e` — 向量降级从「可推断」变「可见」

- 文件: `crates/octos-memory/src/hybrid_search.rs` ✅ + `store.rs` ✅（另动 lib.rs 导出）
- 关键符号与行号:
  - `pub struct VectorCoverage { total, vectorized, dimension_mismatches, dimension }` — hybrid_search.rs L48-58；`bm25_only()`/`ratio()`/`has_dimension_mismatch()` — L60-81
  - 计数器 `dimension_mismatches` + `mismatch_logged`（首条警告后只计数）— L36-38
  - `vector_coverage()` — hybrid_search.rs L231-243；store.rs 侧 `pub fn vector_coverage()` — L640
  - 打开时汇总警告「dimension-mismatched embeddings dropped … BM25-only until re-embedded」— store.rs L289-300
- 提交说明: #1816 修了 1536/768 错宽 bug，#1851 让「向量被丢弃、搜索静默变差」变成可查询状态（健康检查可上报），不再靠翻日志推断
- 补什么: §4.5.4 降级策略处增加「降级可见性」：VectorCoverage 状态、错宽向量的计数与启动汇总警告、与 ② reindex 的修复闭环；注明 4ccdbe7e
- 章稿现状: ⚠️ 部分——正文 L254-256 提到 BM25-only 降级行为，但 VectorCoverage/错宽计数/警告完全未提 → **需补**

### ④ spec 事实边界：`guard.rs` 需一段定位

- 文件: `crates/octos-memory/src/guard.rs` ✅ 存在（325 行；spec 列为第六个源文件，边界段要求「需一段定位」）
- 关键符号与行号: `first_threat`（被 memory_store.rs L741 写入闸、L815 bank 行渲染闸调用；`write_entity` 拒绝、`get_bank_summary` 跳过含注入威胁的行）
- 补什么: §4.6 MemoryStore 小节加一段：Memory Bank 内容会进入系统提示，guard.rs 是写入/渲染两侧的内容防线（写入 `write_entity` bail、渲染时逐行与跨行扫描）
- 章稿现状: ❌ 未提及 guard.rs → **需补**
- 备注: guard.rs 非三提交之一，属 spec 事实边界要求；文件存在，无需 master 裁决

### B 节小结

- 新面必补项数: **4**（spec 三提交 + guard.rs 定位段）
- 源码实测不符项: **0**（4 项均能在 `9c157101` 找到文件与符号，无需 master 裁决的 ❌ 项）
- 章稿完全未覆盖 3 项（cc6744ba / 9ad56caa / guard.rs）、部分覆盖 1 项（4ccdbe7e 的降级行为已有、可见性机制缺）

## 其他勘误提示（主表之外，顺手记录）

1. 章头（L3、L7）「约 1,750 行」与本章回顾（L344）「1,635 行」自相矛盾，且 spec 意图段口径是「约 1600 行」——重标行号时一并统一。
2. L62「当前主 Agent loop 实际只会写入 `Success` episode」与 loop_runner.rs 2,474-2,504 实测一致（另 1,218-1,249 有 `save_conversation_episode` 会话摘要路径，章稿 L62 的限定语已覆盖，无需改）。
3. L91 简化结构体未列 `hnsw: Option<Hnsw<'static, f32, DistCosine>>`（L20）与 `dimension`（L24），恰是 §4.4/4ccdbe7e 的伏笔，建议补充。
