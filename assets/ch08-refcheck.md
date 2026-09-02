# 第 8 章引用核对表 — 上下文管理对齐 main(octos-book v2)

- **源码基准**: `9c157101`(只读实测)· **日期**: 2026-09-03
- **采集方式**: master 直跑替代执行(peer 通道冻结,黑板批注在案)
- 章稿: `chapters/ch08-context-management.md`

---

## A. 引用核对汇总

- 带行号引用: **35 处**(去重);纯路径引用若干(全部路径存在)
- **❌ 路径不存在: 0**
- **⚠️ 行号越界: 0**(35 处逐条以 `wc -l` 验上界,全部通过)
- **⚠️ 行号漂移/符号核对**: 未逐条比对符号(机械边界检查全过;editor 改稿时以本表路径为准逐处重核,发现漂移按源码实测修正)

引用分布:agent/compaction.rs(5)、compaction.rs(6)、compaction_tiered.rs(3)、prompt_guard.rs(2)、loop_runner.rs(3)、execution.rs(1)、summarizer.rs、prompt_layer.rs、steering.rs、sanitize.rs 等。

命令样板:
```bash
grep -oE 'crates/[A-Za-z0-9_/.-]+\.rs:[0-9-]+' chapters/ch08-context-management.md | sort -u
# 越界检查: 逐条 wc -l 对上界(见正文)
```

## B. 相关源文件现状(写作范围实测)

| 文件 | 行数 | 说明 |
|---|---|---|
| crates/octos-agent/src/compaction.rs | 1,932 | 对话压缩 |
| crates/octos-agent/src/compaction_tiered.rs | 1,271 | 分层压缩 |
| crates/octos-agent/src/prompt_context.rs | 64 | PromptContextPhase 等 |
| crates/octos-agent/src/skills.rs | 942 | 技能层 |
| crates/octos-agent/src/mcp.rs | 707 | MCP |
| crates/octos-agent/src/mcp_auth.rs | 407 | MCP 认证 |
| crates/octos-cli/src/api/context_manager.rs | 4,003 | 上下文管理装配 |

合计 9,326 行。

## C. 新面必补(editor 改稿前核对本表)

以 `specs/ch08-context-management.spec.md`「新面必补/勘误方式」段为准(spec 版本为 rewrite-v2 提交版);本章 spec 重点(黑板第 12 条):分层压缩(compaction_tiered)、recall 工具与记忆衔接、prompt_context 阶段化。spec 点名与源码不符项:无(范围文件全部在位)。

## D. 给 editor 的直接输入

1. 35 处引用路径/边界全过,行号漂移需在改稿时逐处符号核对(grep -n '<符号>' 验证落在引用区间)
2. 章稿若含旧基线数字(行数/模块数),以 §B 实测为准
3. 改稿范围与纪律同 2-r1:先读 .octos/skills 两规范;镜像 book/src/part2/ch08.md
