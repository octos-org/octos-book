# 第 9 章引用核对表 — 扩展机制对齐 main(octos-book v2)

- **源码基准**: `9c157101`(只读实测)· **日期**: 2026-09-03
- **采集方式**: master 直跑替代执行(peer 通道冻结,黑板批注在案)
- 章稿: `chapters/ch09-extension.md`

---

## A. 引用核对汇总

- 带行号引用: **50 处**(去重);纯路径引用若干
- **❌ 路径不存在: 0**
- **⚠️ 行号越界: 0**(50 处逐条 `wc -l` 验上界,OVERFLOW_FLAG=0)
- **⚠️ 行号漂移**:机械边界全过;editor 改稿时逐处符号核对(grep -n 验证引用符号落在区间)

命令样板:
```bash
grep -oE 'crates/[A-Za-z0-9_/.-]+\.rs:[0-9-]+' chapters/ch09-extension.md | sort -u
```

## B. 范围文件实测(扩展机制相关)

| 文件/目录 | 行数 | 说明 |
|---|---|---|
| crates/octos-agent/src/plugins/(8 文件) | 14,675 合计 | 插件子系统(mod/manifest/loader/install/extras/http_discovery/tool 3,219/tool_tests 4,406) |
| crates/octos-agent/src/skills.rs | 942 | 技能层(与 ch08 交叉) |
| crates/octos-agent/src/mcp.rs | 707 | MCP |
| crates/octos-agent/src/mcp_auth.rs | 407 | MCP 认证 |
| crates/octos-agent/src/tools/{recall,read_file,registry}.rs | 见 ch06-facts | recall 工具 |

## C. 新面必补(黑板第 12 条重点,已实测)

1. **rmcp 迁移**: `crates/octos-agent/Cargo.toml:41-44`——`# MCP over the official rmcp SDK. Client: stdio + streamable-HTTP + OAuth 2.1.` + `rmcp = { version = "1.8", ... }`。章稿若仍写旧 SDK/自研客户端,须改写为 rmcp 1.8(stdio + streamable-HTTP + OAuth 2.1)。
2. **skill layering**: skills.rs(942 行)+ plugins/ 分层;spec 决策段细节为准。
3. **mcp_servers / sub_providers**: 配置面在 crates/octos-cli/src/config.rs,editor 亲测行号(grep -n 'mcp_servers\|sub_providers')。

spec 点名与源码不符项:**无**(rmcp/skills/plugins/config 全部在位)。

## D. 给 editor 的直接输入

1. 50 处引用边界全过;行号漂移逐处符号核对后修正
2. rmcp 迁移叙述以 §C.1 实测为准(Cargo.toml:41-44)
3. 改稿纪律同 2-r1;镜像 book/src/part2/ch09.md
