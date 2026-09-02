# 附录 A 事实表 — octos 完整 Crate 依赖图数据

- **源码基准 commit**: `9c157101`(`9c1571016e5ea86955b4b3486c04f0359dfff339`,main 分支)
- **统计日期**: 2026-09-03
- **源码仓库**: `/Users/zhangalex/Work/Projects/FW/octos`(只读;本书仓库与源码仓库是两个目录)
- **数据口径**: 与 `assets/ch01-facts.md` 完全一致——依赖边只取各 crate `Cargo.toml` 的 `[dependencies]` 段中的 `octos-*` 条目(**排除** `[dev-dependencies]` 与 `[build-dependencies]`);行数统计 `find crates/<name> -name '*.rs' | xargs wc -l | tail -1`。本表是 ch01-facts 第 1/4/5 节数据的附录视角重排(逐 crate 全路径 + 外部依赖全量),所有数字在本会话于基准 commit 上重新实测。
- **除特别注明外,所有命令均在 octos 源码仓库根执行。**

---

## 1. 汇总数字(与 ch01-facts 交叉核对通过)

| 指标 | 本表实测 | ch01-facts | 结论 |
|---|---|---|---|
| 依赖边总数([dependencies] octos-*) | **63** | 63(§5.1) | ✅ 一致 |
| `ls crates \| wc -l` 顶层条目 | **26** | 26 | ✅ 一致 |
| 其中 octos-* crate | **23** | 23 | ✅ 一致 |
| workspace members(根 Cargo.toml) | **38** | 38(§3.3) | ✅ 一致 |
| 分层数(严格最长路径,L0–L7) | **8** | 8(§4) | ✅ 一致 |
| 行数合计(26 条目) | **700,915** | 700,915(§1.3) | ✅ 一致 |
| 与 ch01-facts 的 diff 数 | **3 处表述差**(数字零冲突,见 §6) | — | 见 §6 |

汇总核对命令:

```bash
cd /Users/zhangalex/Work/Projects/FW/octos
git rev-parse HEAD                              # 9c1571016e5ea86955b4b3486c04f0359dfff339
awk '/^\[dependencies\]/{f=1;next} /^\[/{f=0} f && /^octos-/' crates/*/Cargo.toml | wc -l
# 63(注:crates/app-skills、crates/octos-web、crates/platform-skills 是目录,无顶层 Cargo.toml,awk 跳过)
ls crates | wc -l                               # 26
python3 -c "import tomllib; print(len(tomllib.load(open('Cargo.toml','rb'))['workspace']['members']))"
# 38(成员以 "crates/octos-core" 路径形式书写;逐条核对见 ch01-facts §3.3)
find crates -name '*.rs' | xargs wc -l | tail -1   # 700915 total
```

---

## 2. 逐 crate 数据表(23 个 octos-* crate)

「层」= 严格最长路径层数(1 + max(其 octos-* 依赖的层),零内部依赖 = L0;推导规则与 ch01-facts §4 相同)。
「外部依赖」= `[dependencies]` 段全部非 octos-* 条目,`名称@版本要求`,**加 `*` = feature-gated**(`optional = true`,默认 feature 集不编译)。`workspace = true` 继承的版本已从根 `crates/../Cargo.toml` 的 `[workspace.dependencies]` 解析为实际版本要求;表内「外部依赖数」含 gated 条目。

| crate | 层 | Rust 行数 | 依赖的 octos-*([dependencies]) | 外部依赖数 |
|---|---|---|---|---|
| octos-core | L0 | 22,313 | —(零内部依赖) | 7 |
| octos-plugin | L0 | 5,165 | —(零内部依赖) | 7 |
| octos-sandbox | L0 | 1,468 | —(零内部依赖) | 2 |
| octos-bus | L1 | 42,767 | octos-core | 31 |
| octos-llm | L1 | 35,087 | octos-core | 14 |
| octos-memory | L1 | 6,428 | octos-core | 11 |
| octos-diagnostics | L1 | 2,243 | octos-core | 4 |
| octos-store | L1 | 2,664 | octos-core | 12 |
| octos-fleet | L1 | 16,888 | octos-core | 8 |
| octos-wasm | L1 | 883 | octos-core | 5 |
| octos-agent | L2 | 191,985 | octos-core, octos-bus, octos-memory, octos-llm, octos-plugin | 47 |
| octos-services | L2 | 3,223 | octos-core, octos-llm, octos-bus | 11 |
| octos-embed-llama | L2 | 911 | octos-llm | 5 |
| octos-pipeline | L3 | 32,799 | octos-core, octos-agent, octos-plugin, octos-llm, octos-memory | 10 |
| octos-swarm | L3 | 4,980 | octos-agent | 11 |
| octos-dora-mcp | L3 | 11 | octos-agent | 0 |
| octos-fleet-worker | L3 | 6,842 | octos-agent, octos-core, octos-fleet, octos-llm, octos-memory | 5 |
| octos-workflows | L4 | 1,059 | octos-core, octos-agent, octos-pipeline | 6 |
| octos-server | L5 | 21 | octos-core, octos-agent, octos-llm, octos-bus, octos-store, octos-services, octos-workflows, octos-pipeline, octos-plugin | 22 |
| octos-cli | L5 | 307,299 | octos-core, octos-bus, octos-llm, octos-memory, octos-agent, octos-diagnostics, octos-store, octos-services, octos-workflows, octos-pipeline, octos-swarm, octos-plugin, octos-fleet, octos-fleet-worker, octos-embed-llama | 55 |
| octos-ffi | L6 | 1,372 | octos-core, octos-agent, octos-llm, octos-memory, octos-cli, octos-embed-llama | 4 |
| octos-uniffi | L7 | 465 | octos-ffi | 1 |
| octos-pyo3 | L7 | 756 | octos-ffi | 1 |

行数生成命令(逐 crate,示例,其余同式;26 条目全量清单见 ch01-facts §1.3,本表全部复算一致):

```bash
cd /Users/zhangalex/Work/Projects/FW/octos
find crates/octos-core -name '*.rs' | xargs wc -l | tail -1   # 22313
find crates/octos-cli   -name '*.rs' | xargs wc -l | tail -1  # 307299
```

依赖边生成命令(对每个 crate;`.workspace = true` 后缀条目按 ch01 口径截取包名,如 `octos-fleet.workspace` 计为 `octos-fleet`):

```bash
cd /Users/zhangalex/Work/Projects/FW/octos
awk '/^\[dependencies\]/{f=1;next} /^\[/{f=0} f && /^octos-/{print FILENAME": "$1}' crates/*/Cargo.toml
```

非 octos-* 目录(3 个):`crates/app-skills`(14 个技能二进制目录,无顶层 Cargo.toml;12,098 行)、`crates/platform-skills`(1 个技能二进制 voice;1,188 行)、`crates/octos-web`(TypeScript 前端,0 个 .rs 文件;非 workspace member)。三者 `[dependencies]` 的 octos-* 依赖均为 0(15 个技能二进制唯一 octos-* 出现是 4 个 harness-starter 的 `[dev-dependencies]`,不计入,同 ch01-facts §3.2)。

---

## 3. 依赖边全量清单(63 条,Mermaid 源边)

方向:`A --> B` 表示 A 依赖 B。与 ch01-facts §5.1 逐条一致;括号内为该 crate 边数。

```text
# octos-agent (5)
octos-agent --> octos-core
octos-agent --> octos-bus
octos-agent --> octos-memory
octos-agent --> octos-llm
octos-agent --> octos-plugin
# octos-bus (1)
octos-bus --> octos-core
# octos-cli (15)
octos-cli --> octos-core
octos-cli --> octos-bus
octos-cli --> octos-llm
octos-cli --> octos-memory
octos-cli --> octos-agent
octos-cli --> octos-diagnostics
octos-cli --> octos-store
octos-cli --> octos-services
octos-cli --> octos-workflows
octos-cli --> octos-pipeline
octos-cli --> octos-swarm
octos-cli --> octos-plugin
octos-cli --> octos-fleet
octos-cli --> octos-fleet-worker
octos-cli --> octos-embed-llama
# octos-diagnostics (1)
octos-diagnostics --> octos-core
# octos-dora-mcp (1)
octos-dora-mcp --> octos-agent
# octos-embed-llama (1)
octos-embed-llama --> octos-llm
# octos-ffi (6)
octos-ffi --> octos-core
octos-ffi --> octos-agent
octos-ffi --> octos-llm
octos-ffi --> octos-memory
octos-ffi --> octos-cli
octos-ffi --> octos-embed-llama
# octos-fleet (1)
octos-fleet --> octos-core
# octos-fleet-worker (5)
octos-fleet-worker --> octos-agent
octos-fleet-worker --> octos-core
octos-fleet-worker --> octos-fleet
octos-fleet-worker --> octos-llm
octos-fleet-worker --> octos-memory
# octos-llm (1)
octos-llm --> octos-core
# octos-memory (1)
octos-memory --> octos-core
# octos-pipeline (5)
octos-pipeline --> octos-core
octos-pipeline --> octos-agent
octos-pipeline --> octos-plugin
octos-pipeline --> octos-llm
octos-pipeline --> octos-memory
# octos-pyo3 (1)
octos-pyo3 --> octos-ffi
# octos-server (9)
octos-server --> octos-core
octos-server --> octos-agent
octos-server --> octos-llm
octos-server --> octos-bus
octos-server --> octos-store
octos-server --> octos-services
octos-server --> octos-workflows
octos-server --> octos-pipeline
octos-server --> octos-plugin
# octos-services (3)
octos-services --> octos-core
octos-services --> octos-llm
octos-services --> octos-bus
# octos-store (1)
octos-store --> octos-core
# octos-swarm (1)
octos-swarm --> octos-agent
# octos-uniffi (1)
octos-uniffi --> octos-ffi
# octos-wasm (1)
octos-wasm --> octos-core
# octos-workflows (3)
octos-workflows --> octos-core
octos-workflows --> octos-agent
octos-workflows --> octos-pipeline
```

计数核对:5+1+15+1+1+1+6+1+5+1+1+5+1+9+3+1+1+1+1+3 = **63 条**。
机器核对(ch01 同式):`awk '/^\[dependencies\]/{f=1;next} /^\[/{f=0} f && /^octos-/' crates/*/Cargo.toml | wc -l` → **63**。

注:`crates/octos-cli/Cargo.toml` 中 `octos-fleet.workspace`、`octos-fleet-worker.workspace` 与 `crates/octos-fleet-worker/Cargo.toml` 中 5 条 `.workspace = true` 条目均为 workspace 继承写法,按包名归一计数(ch01 同口径)。全仓 7 条带后缀条目实测清单:

```bash
cd /Users/zhangalex/Work/Projects/FW/octos
grep -rn '^octos-.*\.workspace' crates/*/Cargo.toml
# crates/octos-cli/Cargo.toml:            octos-fleet.workspace = true
# crates/octos-cli/Cargo.toml:            octos-fleet-worker.workspace = true
# crates/octos-fleet-worker/Cargo.toml:   octos-agent.workspace = true / octos-core.workspace = true
#                                         octos-fleet.workspace = true / octos-llm.workspace = true / octos-memory.workspace = true
```

---

## 4. 分层归属(L0–L7,8 层)

层 = 1 + max(其所有 octos-* 依赖的层),零内部依赖者为 L0;技能目录与前端不计入(ch01-facts §4 同规则)。**各层成员与 ch01-facts §4 完全一致**:

| 层 | crate(判定依据 = 最长依赖链) |
|---|---|
| L0 基础层 | octos-core, octos-plugin, octos-sandbox(三者零 octos-* 依赖;sandbox 独立助手二进制,不被依赖) |
| L1 原语层 | octos-bus, octos-llm, octos-memory, octos-diagnostics, octos-store, octos-fleet, octos-wasm(只依赖 L0) |
| L2 运行时层 | octos-agent, octos-services(最深依赖 L1), octos-embed-llama(→octos-llm) |
| L3 编排层 | octos-pipeline, octos-swarm, octos-dora-mcp, octos-fleet-worker(四者均直接依赖 octos-agent) |
| L4 工作流层 | octos-workflows(→octos-pipeline L3) |
| L5 集成层 | octos-server, octos-cli(均 →octos-workflows L4) |
| L6 嵌入核心层 | octos-ffi(→octos-cli L5、octos-embed-llama L2 等) |
| L7 绑定层 | octos-uniffi, octos-pyo3(均只依赖 octos-ffi L6) |
| 能力层(不计层数) | app-skills(14 个能力二进制)、platform-skills/voice、octos-web(前端,非 Rust) |

逐 crate 层数(可复算):core=0, plugin=0, sandbox=0;bus=1, llm=1, memory=1, diagnostics=1, store=1, fleet=1, wasm=1;agent=2, services=2, embed-llama=2;pipeline=3, swarm=3, dora-mcp=3, fleet-worker=3;workflows=4;server=5, cli=5;ffi=6;uniffi=7, pyo3=7。

---

## 5. 外部依赖明细表(按 crate,含版本与 feature-gate 标注)

`*` 后缀 = feature-gated(`optional = true`,由 crate 的 `[features]` 控制,默认不编译)。版本要求来自 `[workspace.dependencies]`(继承)或 crate 内联写法,均逐字摘自基准 commit。

| crate(Cargo.toml 全路径) | 外部依赖(名称@版本要求,`*` = optional/gated) |
|---|---|
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-core/Cargo.toml | serde@1, serde_json@1, chrono@0.4, uuid@1, eyre@0.6, tracing@0.1, sha2@0.10 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-plugin/Cargo.toml | serde@1, serde_json@1, eyre@0.6, tracing@0.1, which@7, tokio@1, metrics@0.24 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-sandbox/Cargo.toml | clap@4, eyre@0.6 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-bus/Cargo.toml | tokio@1, lru@0.16, async-trait@0.1, serde@1, serde_json@1, chrono@0.4, chrono-tz@0.10, uuid@1, cron@0.15, eyre@0.6, tracing@0.1, metrics@0.24, futures@0.3, reqwest@0.12, serde_yml@0.0.12, subtle@2, sha2@0.10, aes@0.8, cbc@0.1, base64@0.22;gated: teloxide@0.17*, serenity@0.12*, tokio-tungstenite@0.26*, axum@0.8*, async-imap@0.11*, tokio-rustls@0.26*, rustls@0.23*, rustls-native-certs@0.8*, webpki-roots@0.26*, lettre@0.11*, mailparse@0.16* |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-llm/Cargo.toml | async-trait@0.1, reqwest@0.12, tokio@1, serde@1, serde_json@1, eyre@0.6, futures@0.3, secrecy@0.10, tracing@0.1, base64@0.22, chrono@0.4, redb@2, metrics@0.24, jsonwebtoken@9 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-memory/Cargo.toml | regex@1, redb@2, tokio@1, serde@1, serde_json@1, chrono@0.4, uuid@1, eyre@0.6, tracing@0.1, hnsw_rs@0.3, bincode@1 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-diagnostics/Cargo.toml | serde@1, serde_json@1, eyre@0.6;gated: reqwest@0.12* |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-store/Cargo.toml | chrono@0.4, eyre@0.6, serde@1, serde_json@1, sha2@0.10, base64@0.22, tracing@0.1, redb@2, uuid@1, tokio@1, getrandom@0.2, constant_time_eq@0.3 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-fleet/Cargo.toml | eyre@0.6, redb@2, rusqlite@0.32, serde@1, serde_json@1, tokio@1, tracing@0.1, uuid@1 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-wasm/Cargo.toml | serde@1, serde_json@1, wasm-bindgen@0.2, serde-wasm-bindgen@0.6, js-sys@0.3 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-agent/Cargo.toml | async-trait@0.1, tokio@1, serde@1, serde_json@1, toml@0.8, chrono@0.4, eyre@0.6, tracing@0.1, metrics@0.24, glob@0.3, globset@0.4, shlex@1, which@7, dunce@1, regex@1, ignore@0.4, futures@0.3, reqwest@0.12, rmcp@1.8, tokio-util@0.7, oauth2@5, reqwest_rmcp@0.13(内联表,`package = "reqwest"` 重命名,default-features = false + features = ["rustls"]), tiny_http@0.12, webbrowser@1, keyring@3, url@2, htmd@0.5, dirs@5, sha2@0.10, flate2@1, tar@0.4, libc@0.2, base64@0.22, chromiumoxide@0.9, pdf-extract@0.9, tempfile@3, lettre@0.11, redb@2, hound@3;gated: gix@0.79*, similar@2*, tree-sitter@0.24*, tree-sitter-rust@0.23*, tree-sitter-python@0.23*, tree-sitter-javascript@0.23*, tree-sitter-typescript@0.23*, symphonia@0.5* |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-services/Cargo.toml | chrono@0.4, eyre@0.6, serde@1, serde_json@1, tokio@1, tracing@0.1, reqwest@0.12, flate2@1, tar@0.4, dirs@5, futures@0.3 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-embed-llama/Cargo.toml | eyre@0.6, async-trait@0.1, tracing@0.1;gated: llama-cpp-2@0.1*, self_cell@1* |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-pipeline/Cargo.toml | async-trait@0.1, tokio@1, serde@1, serde_json@1, eyre@0.6, futures@0.3, tracing@0.1, chrono@0.4, regex@1, glob@0.3 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-swarm/Cargo.toml | async-trait@0.1, chrono@0.4, eyre@0.6, metrics@0.24, redb@2, serde@1, serde_json@1, tokio@1, tracing@0.1, uuid@1, sha2@0.10(`sha2.workspace = true` 继承,`crates/octos-swarm/Cargo.toml:21`) |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-dora-mcp/Cargo.toml | (无外部依赖,仅 octos-agent) |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-fleet-worker/Cargo.toml | async-trait、eyre、serde_json、tokio、tracing——五条均为 `名称.workspace = true` 继承写法(`crates/octos-fleet-worker/Cargo.toml:12-16`),版本要求在根 `[workspace.dependencies]` |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-workflows/Cargo.toml | chrono@0.4, eyre@0.6, serde@1, serde_json@1, tokio@1, tracing@0.1 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-server/Cargo.toml | async-trait@0.1, serde@1, serde_json@1, tokio@1, tracing@0.1, chrono@0.4, eyre@0.6, uuid@1, metrics@0.24;gated(HTTP 层 `api` feature): axum@0.8*, tower-http@0.6*, tokio-util@0.7*, futures@0.3*, tokio-tungstenite@0.26*, rustls@0.23*, rustls-native-certs@0.8*, rust-embed@8*, metrics-exporter-prometheus@0.16*, lettre@0.11*, rand@0.8*, sysinfo@0.34*, subtle@2* |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-cli/Cargo.toml | async-trait@0.1, clap@4, clap_complete@4, dirs@5, serde@1, serde_json@1, colored@2, chrono@0.4, iana-time-zone@0.1, tokio@1, eyre@0.6, uuid@1, color-eyre@0.6, tracing@0.1, tracing-subscriber@0.3, tracing-appender@0.2, rustyline@15, reqwest@0.12, url@2, sha2@0.10, fs2@0.4, getrandom@0.2, constant_time_eq@0.3, percent-encoding@2, open@5, zip@2, quick-xml@0.37, image@0.25, regex@1, tempfile@3, base64@0.22, toml@0.8, agent-client-protocol@1.2.0, keyring@3, flate2@1, qrcode@0.14, chacha20poly1305@0.10, argon2@0.5, tar@0.4, metrics@0.24, redb@2(`redb.workspace = true` 继承,`crates/octos-cli/Cargo.toml:112`);gated: subtle@2*, axum@0.8*, tower-http@0.6*, tokio-util@0.7*, futures@0.3*, tokio-tungstenite@0.26*, rustls@0.23*, rustls-native-certs@0.8*, rust-embed@8*, metrics-exporter-prometheus@0.16*, lettre@0.11*, rand@0.8*, teloxide@0.17*, sysinfo@0.34* |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-ffi/Cargo.toml | tokio@1, serde@1, serde_json@1, libc@0.2 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-uniffi/Cargo.toml | uniffi@0.29 |
| /Users/zhangalex/Work/Projects/FW/octos/crates/octos-pyo3/Cargo.toml | gated: pyo3@0.23*(features = ["abi3-py39"]) |

外部依赖扫描生成命令(逐 crate 列出 `[dependencies]` 段非 octos-* 条目):

```bash
cd /Users/zhangalex/Work/Projects/FW/octos
awk '/^\[dependencies\]/{f=1;next} /^\[/{f=0} f && !/^octos-/ && !/^#/ && /=/ {print FILENAME": "$1}' crates/*/Cargo.toml
# 279 条(= §2「外部依赖数」列合计;`名称.workspace = true` 与 `{ workspace = true }` 写法由 $1 取名归一;
#  注:octos-cli 内部依赖 octos-embed-llama 的一条 optional 条目被 ^octos- 排除,与 §2 的 55 一致;
#  octos-agent 的 reqwest_rmcp 为单行内联表,其表内 url 等键不产生额外命中)
```

feature-gated 依赖核对命令(optional = true 逐条定位):

```bash
cd /Users/zhangalex/Work/Projects/FW/octos
awk '/^\[dependencies\]/{f=1;next} /^\[/{f=0} f && /optional = true/ {print FILENAME": "$0}' crates/*/Cargo.toml
# 命中 52 行,分布:octos-agent 8、octos-bus 11、octos-cli 15、octos-diagnostics 1、
# octos-embed-llama 2、octos-ffi 1、octos-pyo3 1、octos-server 13、其余 crate 0
# (octos-cli 与 octos-ffi 各多出的 1 行是内部依赖 octos-embed-llama 的 optional 条目,
#  非外部依赖,故 §5 各 crate 的 gated 外部依赖表未计入)
```

**注(与 spec 完成条件对应)**:octos-server 的 gated 依赖组即其 HTTP 层 `api` feature(axum/tower-http/tokio-tungstenite/rust-embed 等 13 项),server-core 不 gated——与该 crate `description`「Server-core is ungated; the HTTP layer is behind the `api` feature.」一致(`crates/octos-server/Cargo.toml:7`)。

---

## 6. 与 assets/ch01-facts.md 的交叉核对结果

**核对范围**:ch01-facts §1.1 汇总、§1.2 逐 crate 行数与依赖列、§1.3 行数清单、§3.3 members、§4 分层、§5.1 边清单。
**核对方式**:本会话在基准 commit `9c157101` 上对每项数字重新实测(命令均见上文各节),再与 ch01-facts 对应值逐一比对。

**数字结论:零冲突。** 边数 63、crate 数 26(顶层)/23(octos-*)/38(members)、层数 8(L0–L7)、行数合计 700,915、26 个条目逐 crate 行数、63 条边逐条、各层成员——全部一致。

**表述差 3 处(数字零冲突,仅为详略/视角差,不构成事实矛盾)**:

1. **octos-swarm 外部依赖列**:ch01-facts §1.2 因表格空间未展开外部依赖(其依赖列只列 octos-*);本表 §5 实测 octos-swarm 有 11 项外部依赖(含 redb、sha2 等,见 `crates/octos-swarm/Cargo.toml:15,21`)。属本表新增信息,非矛盾。
2. **octos-fleet-worker 外部依赖写法**:ch01-facts 未列其外部依赖;本表 §5 注明其 5 条外部依赖全部是 `名称.workspace = true` 继承写法(`crates/octos-fleet-worker/Cargo.toml:12-16`),版本要求在根 `[workspace.dependencies]`。属补充说明,非矛盾。
3. **app-skills/platform-skills/octos-web 的处理**:ch01-facts §1.2 将三者(共 26 条目)列入总表但标注「不计入核心库分层」;本表 §2 只列 23 个 octos-* crate,三者的行数与依赖结论(零 `[dependencies]` octos-* 边)以文字重述并引用 ch01-facts §1.3/§3.2,不重复建行。两表口径互补,非矛盾。

除上述 3 处外,两表无任何不一致。

---

## 7. 引用全路径自检(AGENTS.md 第 7 条)

本文件所有 `.rs` 引用均为全路径(本文件正文实际仅以完整绝对路径/仓内相对路径形式引用 Cargo.toml 与 Cargo.toml 行号,无短 `.rs` 引用)。自检命令与输出:

```bash
grep -o -E '[A-Za-z0-9_./-]+\.rs(:[0-9]+)?' assets/appendixA-facts.md \
  | grep -v -E '^(octoscode|crates|herdr)/' | wc -l
# 0
```

---

## 8. 验证级别声明(AGENTS.md 第 8 条)

- **验证级别**: verified——本表全部数字在本会话内、于 octos 仓库 `/Users/zhangalex/Work/Projects/FW/octos` 基准 commit `9c157101` 上用上文命令实测;交叉核对对象 `assets/ch01-facts.md`(其基准同为 9c157101,统计日期 2026-09-02)。
- **三视角 review**: 本文件为纯数据表(非章节正文),按附录视角自查 1 轮:fact-checker(全部数字可复现,0 问题)、structure-editor(汇总→逐 crate→边→层→外部依赖→交叉核对顺序,0 问题)、tech-reviewer(口径与 ch01 一致、dev-deps 排除、workspace 继承归一说明齐全,0 问题)。计数:0 Blocker / 0 Major / 0 Minor。
