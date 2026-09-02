spec: task
name: "Ch7. 安全纵深:沙箱 fail-closed、注入防御与能力授予(v2 重写)"
inherits: project
tags: [part2, security, sandbox, grant, rewrite-v2]
depends: [ch06-tool-system]
estimate: 2d
---

## 意图

重写第 7 章。2026-09-02 的沙箱层有五个 `Sandbox` 后端(bwrap / Landlock 助手 / sandbox-exec /
Docker / AppContainer)加 `NoSandbox` 与 `RefusingSandbox` 两个哨兵实现;`eb7c7221`(#2196)
让显式选择却无法兑现的模式 fail-closed、Auto 降级变响;`ffcde205` 让 cargo 授权默认 lock-only。
更大的变化是 `crates/octos-fleet/src/grant.rs` 的 `WorkerGrant` 能力模型(network / tools / fs / issue 1976 的按路径写围栏)——它必须先在本章立住,Ch16 才能只讲装配。本章按「沙箱 → 命令与派发策略
→ 注入与脱敏 → 能力授予」四层写安全纵深。必须纠正 `crates/octos-sandbox` 是 Landlock/seccomp
平台助手二进制而非沙箱子系统。

## 决策

- 事实表先行: `assets/ch07-facts.md` 列出 sandbox/ 六个文件的行数与首行文档、`SandboxMode` 与 `MountMode` 变体、七个 `impl Sandbox for` 位置、`WorkerGrant` / `FsGrant` / `NetworkGrant` / `GrantError` 的行号与字段、`eb7c7221` 与 `ffcde205` 改动文件;每项附命令
- 沙箱: `crates/octos-agent/src/sandbox/mod.rs`(`pub trait Sandbox` 约 :443、`SandboxMode` :423、`NoSandbox` :500、`RefusingSandbox` :914)、`bwrap.rs`、`landlock.rs`(委托 `octos-sandbox` 助手)、`macos.rs`、`docker.rs`、`windows.rs`;Auto 检测顺序按 `SandboxMode::Auto` 文档注释写
- fail-closed: 以 `eb7c7221` 为主线讲「显式模式不可兑现 ⇒ RefusingSandbox 拒绝执行并给模型可见的拒绝文本」与「Auto 降级发出响亮告警」;引用 mod.rs 相应行号
- cargo 授权: `ffcde205` 的 lock-only 默认与 `allow_network` 门控,引用 `coding_tools.rs` 与 mod.rs
- 命令与派发策略: `crates/octos-agent/src/policy.rs`(命令审批策略、ShellTool SafePolicy)、`dispatch_policy.rs`(MCP-agent 派发前策略门)、`permissions.rs`(机器人工具的监督安全分级,一段带过)
- 注入与脱敏: `prompt_guard.rs`(注入检测)、`sanitize.rs`(工具输出脱敏)、`tools/ssrf.rs`(SSRF);旧稿 7.2-7.4 结构保留,行号逐条重标
- 能力授予: `crates/octos-fleet/src/grant.rs` 的 `WorkerGrant { network, tools, fs, write_fence(#1976) }`、`FsGrant`、`NetworkGrant`、`validate`;与 Ch6 `write_grant.rs` 的关系写明;装配过程「详见第 16 章」
- 事实纠正: `crates/octos-sandbox/src/main.rs` 是平台助手二进制(macOS 上 no-op 直通),真沙箱在 `crates/octos-agent/src/sandbox/`
- 图表: 安全纵深四层图、`SandboxMode` 解析与 fail-closed 决策流、`WorkerGrant` 结构图
- 工程决策侧栏: 为什么从「尽力而为的沙箱」改成 fail-closed
- 镜像同步: `book/src/part2/ch07.md` 与 `chapters/ch07-*.md` 内容一致
- 分析基线: octos main @ 9c157101

## 边界

### 允许修改
- octos-book/chapters/ch07-*.md
- octos-book/book/src/part2/ch07.md
- octos-book/assets/ch07-*

### 禁止做
- 不讲 fleet worker 的封闭注册表装配(Ch16)
- 不修改 octos 源码仓库
- 不把 `crates/octos-sandbox` 描述为沙箱子系统

## 排除范围

- 具体云厂商的容器编排
- 认证与多租户(Ch15)

## 完成条件

场景: 事实表可复现
  测试: review_ch07_facts_sheet
  假设 `assets/ch07-facts.md` 已生成
  当 逐条重跑其中记录的命令
  那么 六个 sandbox 文件、七个 impl 位置、grant.rs 四个类型的行号与命令输出一致

场景: 五后端两哨兵齐全
  测试: review_ch07_backends
  当 阅读沙箱小节
  那么 五个后端与 `NoSandbox`、`RefusingSandbox` 各有一句话定位与 `impl Sandbox for` 行号
  并且 Auto 检测顺序与 `SandboxMode::Auto` 文档注释一致

场景: fail-closed 语义准确
  测试: review_ch07_fail_closed
  当 阅读 fail-closed 小节与决策流图
  那么 写明显式模式不可兑现时的拒绝路径与 Auto 降级告警
  并且 引用 `eb7c7221` 与 mod.rs 实际行号

场景: WorkerGrant 模型立住
  测试: review_ch07_worker_grant
  当 阅读能力授予小节
  那么 `WorkerGrant` 四个字段各有含义与默认值说明
  并且 #1976 写围栏的三种取值(None / Some(空) / Some(列表))语义写明
  并且 引用 `grant.rs` 实际行号

场景: 事实纠正写明
  测试: review_ch07_sandbox_crate_fact
  当 在正文检索 octos-sandbox
  那么 每处都表述为平台助手二进制
  并且 引用 `crates/octos-sandbox/src/main.rs` 顶部文档

场景: 引用零失效
  测试: review_ch07_refs_valid
  当 提取正文全部 `crates/...rs:行号` 引用并对照当前源码
  那么 每个路径存在
  并且 每个行号区间不超过文件总行数
  并且 区间内确实含所述符号

场景: 注入与脱敏小节行号重标
  测试: review_ch07_injection_refs
  当 对照 `prompt_guard.rs`、`sanitize.rs`、`tools/ssrf.rs`
  那么 旧稿 7.2-7.4 保留的每个引用行号均更新为当前值
