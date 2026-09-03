# Ch6 补深度报告(ch06-depth-spawn)

- 目标文件:`chapters/ch06-tool-system-draft.md`(仅此一个文件被改动,git status 可证;book/ 镜像未动,master 统一同步;未 commit)
- 源码基准:`/Users/zhangalex/Work/Projects/FW/octos` @ `9c157101`(只读亲测,与事实表一致)
- 事实表:`assets/ch06-facts.md`(commit `552be31`)

## 补写段落清单(五处,共 +19 行,正文 4,565 → 6,014 汉字)

1. **能力域 × 策略分组两套坐标系**(6.1,`TOOL_GROUPS` 前)
   动机:spec 决策段要求讲 ToolPolicy 分组,但初稿只按文件域叙事;补一段说明 `TOOL_GROUPS`(`policy.rs:187`,`ToolGroupInfo` 在 `:179-183`,实测 10 组)按 LLM 可见入口而非文件名分组,两套不重合的三组实例(group:fs 五入口、bash 归 runtime、group:sessions 横跨两域),并讲 `group:delegated`(`:307`)的超集不变量、无组内组展开、守护测试 `group_delegated_supersets_session_spawn_family` 与已发生的漂移记录、以及故意不收 shell 的 confinement boundary 表述。

2. **为什么按域拆文件**(6.1.8 后新增小节「为什么按域拆文件,而不是一个大文件」)
   动机:spec 要求每域加一层「为什么这样设计」;统一在域速览收尾处回答拆分判据——域内共享不变量(resolve_path 归一、no-follow 读写、tool_output_limit 截断)与依赖方向,域间威胁模型隔离(SSRF 对路径,互不引用),以 spawn.rs 5,309 行与 registry.rs 3,581 行为两个极端反例。

3. **ToolRegistry 字段沉积顺序 + specs() 排序契约**(6.3 开头)
   动机:任务点名的「registry.rs 骨架展开」;用注释里的 issue 编号讲字段演化(spawn_only `:164-166`、live_catalog `:179` #1148、invalidate_cache `:1086`、live_catalog_handle `:1420`、internal_hidden `:206`、mcp_services #1886),再讲 `specs()` 排序(`:746`)——HashMap 迭代序会打穿 provider prompt 缓存(Anthropic cache_control 前缀首段),排序把实现细节变成对外契约。

4. **clear_spawn_only 方向性 + task_handle 信封**(6.3.3)
   动机:曝光控制语义补全——`clear_spawn_only`(`registry.rs:355`)的父子方向性(父拦截、子放行,曝光控制是每注册表状态而非工具固有属性),`spawn_only_handle_message`(`:388`)的 M10 Phase 4 信封(task_handle、expected_files、read_with: read_task_output 五种读法),完整输出仍走 SubAgentOutputRouter,只改模型侧可见性。

5. **estimate_json_size 的非分配设计**(6.5 第一道闸)
   动机:任务点名;对比 `to_string().len()` 的等大分配,讲递归走查 Value 树的按节点计字节(字符串内容+转义+引号、数组 2+元素+逗号、对象键长+3+子树),零分配零拷贝,边界检查类代码的形状。

另:版本演化说明追加「补深度记录」,记初稿字数、五处补写与亲测行号来源。

## 新增行号亲测清单(全部在 octos @ 9c157101 实测)

| 引用 | 实测 |
|---|---|
| `TOOL_GROUPS` / `ToolGroupInfo` | policy.rs:187 / :179-183(grep 实证 10 组) |
| `group:delegated` 定义 | policy.rs:307-331 |
| `group_delegated_supersets_session_spawn_family` 测试 | policy.rs:580-596(注释记录漂移史) |
| `expand_group` 扁平切片 | policy.rs:`fn expand_group`(静态切片,无组内组) |
| `spawn_only`/`spawn_only_messages`/`live_catalog`/`internal_hidden` 字段 | registry.rs:164-166 / :179 / :206 |
| `invalidate_cache` / `live_catalog_handle` / `refresh_live_catalog` | registry.rs:1086 / :1420 / :1429 |
| `mark_spawn_only` / `mark_internal_hidden` / `clear_spawn_only` | registry.rs:299 / :324 / :355 |
| `spawn_only_handle_message` | registry.rs:388 |
| `specs()` 全量注释与排序 | registry.rs:700(注释 :706-711)、:746 |
| `MAX_ARGS_SIZE = 1_048_576` / `estimate_json_size` | registry.rs:1133 / :95-119 |
| `parse_tool_args` 全问题报错 + #1765/#1690 | args.rs:1-30 / :75-97 / :102 |
| `TOOL_INPUT_ERROR_MAX_BYTES = 4096` | tools/mod.rs:59 |

## 自查表

| 项 | 结果 | 预算 |
|---|---|---|
| 正文汉字(去代码块口径) | **6,014** | ≥5,000 ✅ |
| 代码占比 | 约 15.9%(304→323 行,代码块未增) | ≤1/3 ✅ |
| 「——」 | 0 | ≤2 ✅ |
| 加粗 | 3 | ≤15(规范 ≤10)✅ |
| 黑话(赋能/抓手/闭环/打通/沉淀/助力/践行/势能/组合拳) | 零命中 | 零 ✅ |
| mermaid | 4 块,未改动,块闭合完整 | 不破坏 ✅ |
| 修改文件 | 仅 chapters/ch06-tool-system-draft.md | 单文件 ✅ |
| book/ 镜像 | 未动 | master 统一同步 ✅ |
| commit | 未 commit | 留给 master ✅ |

## 纪律说明

- 一处英文夹杂「缓存 economics」在自查时改为「缓存成本」。
- spec 的 review_ch06_domain_grouping 要求每工具恰归一域:沿用事实表归属,未改动初稿分组表。
- LRU 相关词检索仅出现在「已删除」的历史说明段(RFC-0 `172fb2be`),未复述 find_evictable/ToolLifecycle 机制。
