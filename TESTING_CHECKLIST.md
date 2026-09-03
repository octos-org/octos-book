# octos 手工测试 Checklist

> 基于 octos v0.1.0 源码分析生成。测试前确保已 `cargo build --all-features`。

## 1. CLI 基础（`octos chat`）

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 1.1 | 基本对话 | `octos chat` → 输入 "hello" | 正常回复 | ☐ |
| 1.2 | 多轮对话 | 连续发 3 条消息 | 上下文连贯 | ☐ |
| 1.3 | 退出命令 | 分别输入 `exit` / `quit` / `/exit` / `/quit` / `:q` | 正常退出 | ☐ |
| 1.4 | 指定模型 | `octos chat --model claude-sonnet-4` | 使用指定模型 | ☐ |
| 1.5 | Provider 自动检测 | 只设 `--model gpt-4o`，不设 `--provider` | 自动选 openai | ☐ |
| 1.6 | 单消息模式 | `octos chat -m "2+2=?"` | 输出结果后退出 | ☐ |
| 1.7 | 迭代上限 | `--max-iterations 3`，请求复杂任务 | 3 轮后停止 | ☐ |
| 1.8 | Verbose | `octos chat -v` | 显示 token 计数、工具详情 | ☐ |
| 1.9 | 无 API Key | 不设环境变量直接启动 | 给出明确错误提示 | ☐ |

---

## 2. 工具系统

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 2.1 | read_file | 请求读取已知文件 | 正确返回内容 | ☐ |
| 2.2 | write_file | 请求写入文件 | 文件被创建 | ☐ |
| 2.3 | edit_file | 请求替换文件中的字符串 | 精确替换 | ☐ |
| 2.4 | shell | 请求执行 `echo hello` | 返回 "hello" | ☐ |
| 2.5 | glob | 请求查找 `*.rs` 文件 | 返回匹配列表 | ☐ |
| 2.6 | grep | 请求搜索文件内容 | 返回匹配行 | ☐ |
| 2.7 | list_dir | 请求列出目录 | 返回目录内容 | ☐ |
| 2.8 | web_search | 请求搜索一个话题 | 返回搜索结果 | ☐ |
| 2.9 | web_fetch | 请求获取某网页 | 返回网页内容 | ☐ |
| 2.10 | git | 请求 `git status`（需 feature: git） | 返回仓库状态 | ☐ |
| 2.11 | 工具并行 | 请求同时读 3 个文件 | 并行执行、一次返回 | ☐ |
| 2.12 | 工具策略 deny | 配置 `tool_policy.deny: ["shell"]` | shell 被拒绝 | ☐ |
| 2.13 | 工具策略 allow | 配置 `tool_policy.allow: ["read_file"]` | 只能用 read_file | ☐ |
| 2.14 | Provider 级策略 | `tool_policy_by_provider.gemini.deny: ["diff_edit"]` | gemini 不能用 diff_edit | ☐ |
| 2.15 | Context tag filter | 配置 `context_filter: ["code"]` | 只显示 code 标签工具 | ☐ |

---

## 3. 安全

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 3.1 | SafePolicy deny | 请 Agent 执行 `rm -rf /` | 被拒绝 | ☐ |
| 3.2 | SafePolicy ask | 请 Agent 执行 `sudo ls` | 非交互模式下拒绝 | ☐ |
| 3.3 | Fork bomb 拦截 | 请 Agent 执行 `:(){:\|:&};:` | 被拒绝 | ☐ |
| 3.4 | dd 拦截 | 请 Agent 执行 `dd if=/dev/zero of=/dev/sda` | 被拒绝 | ☐ |
| 3.5 | mkfs 拦截 | 请 Agent 执行 `mkfs.ext4 /dev/sda` | 被拒绝 | ☐ |
| 3.6 | SSRF localhost | `web_fetch("http://localhost:8080")` | 被阻断 | ☐ |
| 3.7 | SSRF 私有 IP | `web_fetch("http://192.168.1.1")` | 被阻断 | ☐ |
| 3.8 | SSRF AWS metadata | `web_fetch("http://169.254.169.254")` | 被阻断 | ☐ |
| 3.9 | SSRF IPv6 回环 | `web_fetch("http://[::1]:8080")` | 被阻断 | ☐ |
| 3.10 | SSRF IPv4-mapped IPv6 | `web_fetch("http://[::ffff:192.168.1.1]")` | 被阻断 | ☐ |
| 3.11 | SSRF DNS 失败 | `web_fetch("http://nonexistent.invalid")` | 阻断（fail-closed） | ☐ |
| 3.12 | 符号链接保护 | 创建 symlink → `/etc/passwd`，请求 read_file | 被拒绝（ELOOP） | ☐ |
| 3.13 | 路径穿越 | 请求读取 `../../etc/passwd` | 被拒绝 | ☐ |
| 3.14 | 凭据脱敏 OpenAI | 工具输出含 `sk-proj-abcdefghijk...` | `sk-p...[credential-redacted]` | ☐ |
| 3.15 | 凭据脱敏 AWS | 工具输出含 `AKIAIOSFODNN7EXAMPLE` | 脱敏 | ☐ |
| 3.16 | 凭据脱敏 GitHub | 工具输出含 `ghp_xxxxxxxxxxxx` | 脱敏 | ☐ |
| 3.17 | Base64 URI 清理 | 工具输出含 `data:image/png;base64,xxx...` | `[base64-data-redacted]` | ☐ |
| 3.18 | Prompt 注入检测 | 工具输出含 "ignore previous instructions" | `[injection-blocked:SystemOverride]` | ☐ |
| 3.19 | 沙箱 macOS | sandbox-exec 下 `cat /etc/shadow` | 被拒绝 | ☐ |
| 3.20 | 沙箱 Linux | bwrap 下 `ls /root` | 被拒绝 | ☐ |
| 3.21 | 环境变量清理 | 子进程检查 `LD_PRELOAD` | 已移除 | ☐ |
| 3.22 | SBPL 注入防护 | cwd 含括号 `(` `)` | 拒绝执行并报错 | ☐ |

---

## 4. LLM Provider

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 4.1 | Anthropic Claude | `--model claude-sonnet-4` | 正常对话 | ☐ |
| 4.2 | OpenAI GPT | `--model gpt-4o` | 正常对话 | ☐ |
| 4.3 | Google Gemini | `--model gemini-2.5-flash` | 正常对话 | ☐ |
| 4.4 | DeepSeek | `--model deepseek-chat` | 正常对话 | ☐ |
| 4.5 | Ollama 本地 | `--model ollama-llama3` | 本地模型对话 | ☐ |
| 4.6 | 流式输出 | 观察 token 逐步显示 | 实时流式 | ☐ |
| 4.7 | 429 自动重试 | 频繁请求触发限流 | 自动退避重试 | ☐ |
| 4.8 | Failover | 配置 fallback_models，主 Provider 不可用 | 自动切换 | ☐ |
| 4.9 | 自定义 base_url | 设置代理 URL | 请求发到代理 | ☐ |
| 4.10 | api_type 覆盖 | `api_type: "anthropic"` + 自定义 base_url | 用 Anthropic 协议 | ☐ |
| 4.11 | TTFT 自适应超时 | 大量 token 输入 | 不因首 token 等待超时 | ☐ |
| 4.12 | Sub-providers | 配置 sub_providers → spawn 时使用 | 子 Agent 用指定模型 | ☐ |

---

## 5. 记忆系统

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 5.1 | save_memory | 请 Agent "记住我喜欢 Python" | 写入日期文件 | ☐ |
| 5.2 | recall_memory | 请 Agent "我之前说过什么编程语言？" | 找到 Python 记忆 | ☐ |
| 5.3 | Episode 存储 | 完成任务后检查 episodes.redb | Episode 被存储 | ☐ |
| 5.4 | 7 天窗口 | 确认系统提示含近 7 天笔记 | 已注入 | ☐ |
| 5.5 | 长期记忆 | 编辑 MEMORY.md → 重启 | 下次对话可见 | ☐ |
| 5.6 | Entity Bank | 创建 `bank/entities/rust.md` | recall 时可检索 | ☐ |
| 5.7 | 混合搜索降级 | 无 embedding provider | BM25-only 仍然工作 | ☐ |

---

## 6. 扩展机制

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 6.1 | Skill 加载 | 创建 `skills/test/SKILL.md` | 出现在技能列表 | ☐ |
| 6.2 | Skill 覆盖 | 项目级 skill 覆盖同名内置 | 使用项目级 | ☐ |
| 6.3 | Skill 可用性检查 | `requires_bins: ["nonexistent"]` | available=false | ☐ |
| 6.4 | Plugin 加载 | 创建 manifest.json + 可执行文件 | 工具注册 | ☐ |
| 6.5 | Plugin SHA-256 校验 | manifest 有 sha256，改二进制 | 加载失败 | ☐ |
| 6.6 | Plugin 无 sha256 | manifest 没有 sha256 字段 | 加载成功 + 警告 | ☐ |
| 6.7 | Plugin 100MB 限制 | 超大可执行文件 | 拒绝加载 | ☐ |
| 6.8 | Plugin 符号链接拒绝 | 可执行文件是 symlink | 拒绝 | ☐ |
| 6.9 | MCP Stdio | 配置 command + args | 工具发现 + 可调用 | ☐ |
| 6.10 | MCP HTTP | 配置 url | 工具发现 + 可调用 | ☐ |
| 6.11 | MCP 1MB 限制 | 服务器返回超大响应 | 截断并报错 | ☐ |
| 6.12 | MCP Schema 深度 | Schema 嵌套 > 10 层 | 验证失败 | ☐ |
| 6.13 | MCP 工具名保护 | MCP 工具名为 "shell" | 注册被拒（保护名） | ☐ |
| 6.14 | Gating 检查 | `requires_bins: ["python"]`，无 python | 跳过，不致命 | ☐ |
| 6.15 | spawn_only | 调用 spawn_only 工具 | 后台执行，立即返回 | ☐ |
| 6.16 | Plugin extras | manifest 含 mcp_servers / hooks | extras 正确加载 | ☐ |

---

## 7. Gateway 模式（`octos gateway`）

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 7.1 | Telegram 接入 | 配置 bot token → 发消息 | Agent 回复 | ☐ |
| 7.2 | Discord 接入 | 配置 bot token → 发消息 | Agent 回复 | ☐ |
| 7.3 | Slack 接入 | 配置 WebSocket → 发消息 | Agent 回复 | ☐ |
| 7.4 | 会话隔离 | 两个用户同时对话 | 各自独立上下文 | ☐ |
| 7.5 | 消息分片 Telegram | Agent 回复超 4000 字符 | 自动分多条 | ☐ |
| 7.6 | 消息分片 Discord | Agent 回复超 1900 字符 | 自动分多条 | ☐ |
| 7.7 | `/new` 命令 | 发 `/new` | 新会话开始 | ☐ |
| 7.8 | 空闲超时 | 会话 30 分钟无消息 | Actor 回收 | ☐ |
| 7.9 | 并发限制 | 同时 11 个活跃会话（limit=10） | 第 11 个等待 | ☐ |
| 7.10 | Profile 模式 | 配置多 profile → 子账号 | 各自独立 Provider/提示 | ☐ |
| 7.11 | 流式编辑 | Telegram 支持编辑的频道 | 消息逐步更新 | ☐ |
| 7.12 | JSONL 持久化 | 重启 gateway | 会话历史恢复 | ☐ |
| 7.13 | 10MB 文件限制 | 超长对话 | 文件大小受限 | ☐ |
| 7.14 | Abort 触发 | 发送 "停" / "stop" / "cancel" | Agent 中止当前任务 | ☐ |
| 7.15 | 多语言 abort | 发送 "やめて" / "стоп" | 对应语言中止确认 | ☐ |

---

## 8. Serve 模式（`octos serve`）

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 8.1 | 启动 | `octos serve` | 监听 127.0.0.1:8080 | ☐ |
| 8.2 | REST API | `curl /api/sessions` | 返回 JSON | ☐ |
| 8.3 | SSE 流式 | POST `/api/chat` | 流式事件返回 | ☐ |
| 8.4 | Dashboard | 浏览器打开 localhost:8080 | Web UI 加载 | ☐ |
| 8.5 | Auth token | 无 token 请求 | 401 Unauthorized | ☐ |
| 8.6 | 绑定地址 | `--host 0.0.0.0` | 外部可访问 | ☐ |
| 8.7 | 默认只绑本地 | 不加 --host | 外部无法访问 | ☐ |

---

## 9. Pipeline

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 9.1 | DOT 解析 | 提供 DOT 格式工作流 | 正确解析节点和边 | ☐ |
| 9.2 | Shell Handler | 节点执行 `cargo test` | 命令执行 + 结果传递 | ☐ |
| 9.3 | Codergen Handler | 节点用 LLM 生成代码 | Agent 执行 | ☐ |
| 9.4 | Noop Handler | 空操作节点 | 输入直接传递到输出 | ☐ |
| 9.5 | Human Gate | 暂停等待审批 | 5 分钟超时 | ☐ |
| 9.6 | 条件边 | pass → deploy / fail → rollback | 正确路由 | ☐ |
| 9.7 | Checkpoint 断点 | Pipeline 中断后恢复 | 从断点继续 | ☐ |
| 9.8 | per-node 模型 | 不同节点用不同 model | 各自使用指定模型 | ☐ |
| 9.9 | DynamicParallel | fan-out 到 N 个 worker | 并行执行 + join_all | ☐ |
| 9.10 | Graph 验证 | 提供有环的 DOT | 验证失败 | ☐ |

---

## 10. 配置与 Hooks

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 10.1 | 配置优先级 | CLI 参数 > 项目 .octos/ > 全局 ~/.config/octos/ | 正确覆盖 | ☐ |
| 10.2 | 热加载 prompt | 运行中修改 system_prompt | 5 秒内生效 | ☐ |
| 10.3 | 热加载 max_history | 运行中修改 max_history | 5 秒内生效 | ☐ |
| 10.4 | 运行时模型切换 | 使用 model_check 工具 | SwappableProvider 切换 | ☐ |
| 10.5 | 配置解析失败 | config.json 语法错误 | 保留旧配置 + 警告 | ☐ |
| 10.6 | before_tool_call | Hook exit 1 | 工具被阻止 | ☐ |
| 10.7 | after_tool_call | Hook exit 0 | 正常记录 | ☐ |
| 10.8 | Hook exit 2 (修改) | Hook stdout 返回修改后的参数 | 参数被替换 | ☐ |
| 10.9 | Hook 超时 | Hook 执行超 5s | Hook 被 kill | ☐ |
| 10.10 | Circuit breaker | Hook 连续失败 3 次 | 自动禁用 + 警告 | ☐ |
| 10.11 | Hook 敏感数据 | shell 工具的 hook payload | 参数为 `{"redacted": true}` | ☐ |
| 10.12 | Hook argv 执行 | 命令含空格和特殊字符 | 不经 shell 解释 | ☐ |
| 10.13 | Hook tilde 展开 | `~/hook.sh` | 正确展开为 home 路径 | ☐ |
| 10.14 | Feature flags | `cargo build` 无 `--features api` | serve 不可用 | ☐ |

---

## 11. 循环检测与预算

| # | 功能 | 测试步骤 | 预期结果 | Pass? |
|---|------|---------|---------|-------|
| 11.1 | 循环检测 长度 1 | Agent 重复调用同一工具 3 次 | 注入警告消息 | ☐ |
| 11.2 | 循环检测 长度 2 | A→B→A→B→A→B | 检测到 AB 循环 | ☐ |
| 11.3 | 循环检测 长度 3 | A→B→C 重复 3 次 | 检测到 ABC 循环 | ☐ |
| 11.4 | 迭代上限 | 达到 max_iterations | 停止并返回 | ☐ |
| 11.5 | Token 预算 | 配置 max_tokens=1000 | 超限后停止 | ☐ |
| 11.6 | 墙钟超时 | 配置 max_timeout=10s | 超时后停止 | ☐ |
| 11.7 | 优雅关停 | Ctrl+C | 完成当前步骤后退出 | ☐ |
| 11.8 | Context compaction | 长对话触发阈值 | 旧消息被压缩为摘要 | ☐ |
| 11.9 | 压缩保留边界 | 检查压缩后最近 6 条完整 | 未被压缩 | ☐ |
| 11.10 | 工具组不分割 | 压缩不在 Assistant→Tool 中间切 | 保持配对完整 | ☐ |

---

## 测试环境准备

```bash
# 构建（全功能）
cd /path/to/octos
cargo build --all-features

# 设置 Provider（至少一个）
export ANTHROPIC_API_KEY="sk-ant-..."
# 或
export OPENAI_API_KEY="sk-..."

# 准备测试工作区
mkdir -p /tmp/octos-test && cd /tmp/octos-test
echo "hello world" > test.txt
mkdir -p .octos
```

## 测试结论

| 模块 | 总计 | Pass | Fail | Skip |
|------|------|------|------|------|
| CLI 基础 | 9 | | | |
| 工具系统 | 15 | | | |
| 安全 | 22 | | | |
| LLM Provider | 12 | | | |
| 记忆系统 | 7 | | | |
| 扩展机制 | 16 | | | |
| Gateway | 15 | | | |
| Serve | 7 | | | |
| Pipeline | 10 | | | |
| 配置与 Hooks | 14 | | | |
| 循环检测与预算 | 10 | | | |
| **总计** | **137** | | | |
