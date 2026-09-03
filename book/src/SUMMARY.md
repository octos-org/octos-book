# 目录

[前言](./preface.md)

---

# 第一部分：地基 — Rust + AI Agent 的设计哲学

- [第 1 章：为什么是 Rust？为什么是 Agent OS？](./part1/ch01.md)
- [第 2 章：octos-core：用类型系统定义领域语言](./part1/ch02.md)
- [第 3 章：octos-llm：驯服 LLM Provider 的混乱](./part1/ch03.md)
- [第 4 章：octos-memory：混合搜索的工程实现](./part1/ch04.md)

---

# 第二部分：引擎 — Agent 运行时深度解析

- [第 5 章：Agent Loop：一次对话的完整生命周期](./part2/ch05.md)
- [第 6 章：工具系统：内置工具的设计模式](./part2/ch06.md)
- [第 7 章：安全纵深：沙箱 fail-closed、注入防御与能力授予](./part2/ch07.md)
- [第 8 章：上下文管理：让 Agent 在有限窗口中高效工作](./part2/ch08.md)
- [第 9 章：扩展机制：Skills 与 Plugins 双轨制](./part2/ch09.md)
- [第 10 章：Harness：校验器、事件 ABI 与 Schema 版本化](./part2/ch10.md)

---

# 第三部分：平台 — 从单机到多租户

- [第 11 章：octos-bus：多频道消息抽象](./part3/ch11.md)
- [第 12 章：并发模型：三层调度的生产实现](./part3/ch12.md)
- [第 13 章：octos-pipeline：DOT 图驱动的工作流引擎](./part3/ch13.md)
- [第 14 章：运行模式与配置体系](./part3/ch14.md)
- [第 15 章：生产化：存储、服务、运维面与多租户](./part3/ch15.md)
- [第 16 章：Fleet：可恢复的计划执行内核](./part3/ch16.md)
- [第 17 章：Swarm：契约扇出与聚合门禁](./part3/ch17.md)
- [第 18 章：Goal 与 Peer：把目标从上下文里搬出来](./part3/ch18.md)

---

# 第四部分：双环 — 外环驱动内环

- [第 19 章：octoscode：终端客户端与 UI Protocol](./part4/ch19.md)
- [第 20 章：OctoLoop：外环协议 OLP v2](./part4/ch20.md)
- [第 21 章：herdr 与外环运维实务](./part4/ch21.md)

---

# 附录

- [附录 A：octos 完整 Crate 依赖图](./appendix/a-crate-graph.md)
- [附录 B：工具速查表](./appendix/b-tool-reference.md)
- [附录 C：配置参考](./appendix/c-config-reference.md)
- [附录 D：Feature Flags 一览](./appendix/d-feature-flags.md)
- [附录 E：从源码构建与贡献指南](./appendix/e-contributing.md)
- [附录 F:OLP v2 协议速查](appendix/f-olp-cheatsheet.md)
