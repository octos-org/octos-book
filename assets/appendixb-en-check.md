# 附录 B 英文版 C1 机械校验报告(appendixb-en-check)

- 校验人:peer appendixb-en-check(isolated worktree,branch main,未 commit)
- 日期:2026-09-03
- 对象:`chapters/appendix-b-tool-reference.md`(231 行)↔ `book-en/src/appendix/b-tool-reference.md`(230 行)
- 基线:worktree HEAD = `816ca5f`,`git status` 干净(两侧文件与主仓定稿一致,未做任何修改)
- 结论速览:**6/6 PASS,总判定 PASS(可定稿)**

---

## 1. verify-en.sh 结构校验 — **PASS**

命令:

```bash
bash ~/.octos/outer/verify-en.sh chapters/appendix-b-tool-reference.md book-en/src/appendix/b-tool-reference.md
```

输出(全文):

```
refs: 44 (equal sets: yes)
en words: 3160, bold 3, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
```

exit code = 0。标题数、代码围栏数、mermaid 数、表格行数、refs 集合、数字缺失、CJK 残留、违禁词、em dash、bold 全部通过,0 FAIL 0 WARN。

## 2. 数字集合比对 — **PASS(无需豁免)**

命令(与 verify-en.sh 同口径:剔除代码块、剥 `U+XXXX`、取 ≥3 位数字,sort -u 后双向 comm):

```bash
strip(){ awk '/^```/{c=!c;next} !c' "$1"; }
nz=$(strip chapters/appendix-b-tool-reference.md | sed -E 's/U\+[0-9A-Fa-f]{4,6}//g' | grep -oE '[0-9][0-9,]{2,}[0-9]|[0-9]{3,}' | sort -u)
ne=$(strip book-en/src/appendix/b-tool-reference.md | sed -E 's/U\+[0-9A-Fa-f]{4,6}//g' | grep -oE '[0-9][0-9,]{2,}[0-9]|[0-9]{3,}' | sort -u)
comm -23 <(echo "$nz") <(echo "$ne")   # zh 有 en 无
comm -13 <(echo "$nz") <(echo "$ne")   # en 有 zh 无
```

输出:两侧各 **59** 个数字 token,`comm -23` 与 `comm -13` 均**为空 → 缺失 0 / 多余 0**。无需单位制等值豁免。

重点注册名数字(脚本正则不捕 2 位数,另手工逐 token 计数):

| token | zh | en |
|---|---|---|
| 80 | 6 | 6 |
| 60 | 4 | 4 |
| 20 | 8 | 8 |
| 15 | 3 | 3 |

两侧逐处对应(如 L102 计数核对句"…= 核心 60,admin 20,合计 80"↔"= 60 core, plus 20 admin, 80 total")。

## 3. 源码引用集合比对 — **PASS**

命令:

```bash
rz=$(grep -oE '(crates|octoscode|herdr)/[A-Za-z0-9_./-]+(:[0-9]+(-[0-9]+)?)?' "$zh" | sort -u)
re=$(grep -oE '(crates|octoscode|herdr)/[A-Za-z0-9_./-]+(:[0-9]+(-[0-9]+)?)?' "$en" | sort -u)
diff <(echo "$rz") <(echo "$re")
```

输出:**zh refs 44 = en refs 44,diff 为空(集合相等)**。B 自报 12 条与实测相符(B 中无 octoscode/herdr 前缀,全部为 crates/ 路径)。

简报提示的短名改写确认:en L148 有一处不带路径的裸名 —— "…is a native file tool (`crates/octos-agent/src/tools/apply_patch.rs`), **outside coding_tools.rs**"(zh 对应位置为全路径 `crates/octos-agent/src/tools/coding_tools.rs`)。因该裸名不匹配 refs 正则,不影响集合;`coding_tools` token 两侧各 15 次,一一对位。**refs 集合仍相等,确认无误捕损失。**

## 4. 固定标签同位 — **PASS**

| 标签 | zh 行号 | en 行号 |
|---|---|---|
| 定位 / **Positioning** | L3 | L3 |
| 版本演化说明 / **Version note** | L230 | L230 |

两侧均 `> **…**` 引用块、同位(L3 头部 / L230 尾注)。尾注基线一致:octos main @ `9c157101`(2026-09-03 实测),数据源 `assets/appendixB-facts.md`(commit `ad387d1`)。

## 5. 表行数逐一对照 — **PASS**

各表 `^|` 行块范围与行数,两侧完全一致(awk 按连续 `|` 行分组):

| 表 | zh 范围/行数 | en 范围/行数 | 数据行 |
|---|---|---|---|
| B.1 主表(80 注册名) | L19–100,82 `|` 行 | L19–100,82 `|` 行 | **80**(82 = 表头 1 + 分隔 1 + 数据 80) |
| B.3 P0 对照表 | L164–174,11 行 | L164–174,11 行 | **9**(表头 1 + 分隔 1 + 数据 9;P0 十项以散文列出,表中 3 个 P0 成员 + 6 个带排除理由的 shim) |
| B.4 fleet 子表一(BASE/GRANTABLE/WEB) | L185–189,5 行 | L185–189,5 行 | **3**(BASE_TOOLS 默认 7 / GRANTABLE 可授 9 / WEB_TOOLS 网络 2) |
| B.4 fleet 子表二(allow_list 展开) | L195–201,7 行 | L195–201,7 行 | **5** |
| B.5 feature 门表(附加核验) | L209–214,6 行 | L209–214,6 行 | **4**(编译期 git/ast + 运行期 read_window/read_paging_probe,与 B.5 "2+2" 自述一致) |

附加机械核验:

- 主表 80 个注册名逐行提取(`^\| \`([^`]+)\``)后 `diff`:**顺序与集合完全一致,无重名**(`sort -u | wc -l` = 80)。
- B.2 十域导览为散文+L102 计数核对句(11+5+6+5+4+10+13+1+5=60,admin 20,合计 80),两侧数字一致,无表。
- B.3 P0 十名散文列举两侧逐名一致:`apply_patch, exec_command, write_stdin, update_plan, request_user_input, spawn_agent, send_input, resume_agent, wait_agent, close_agent`。

## 6. mdbook 构建 — **PASS**

命令:

```bash
cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
```

输出:**0**(构建成功,HTML 写出至 `book-en/book`;日志仅 INFO 级,无 WARN/ERROR)。

---

## 总判定

| # | 校验项 | 结果 |
|---|---|---|
| 1 | verify-en.sh | PASS(0 FAIL / 0 WARN) |
| 2 | 数字集合 | PASS(缺失 0 / 多余 0;80/60/20/15 计数全对位) |
| 3 | 源码引用集合 | PASS(44=44,diff 空;短名一处不影响集合) |
| 4 | 固定标签同位 | PASS(L3 / L230 同位) |
| 5 | 表行数 | PASS(80 / 9 / 3 / 5 [+4] 逐表一致) |
| 6 | mdbook 构建 | PASS(0 WARN/ERROR) |

**总判定:PASS —— 附录 B 英文版可定稿。**

*本报告为唯一产出文件;worktree 未做任何 commit,未改动两侧被校验文件。*
