# Appendix E 英文版 C2 去味读校报告

- 日期:2026-09-02
- 对象:`book-en/src/appendix/e-contributing.md`(208 行)
- 规则:`.octos/skills/trilingual-collab-en.md`
- 前置:appendixe-en-check 已核结构/数字/引用双侧一致(缺失 0 / 冲突 0)
- 迭代预算:25(实用 5)

## 判定

**通过(PASS)**。附录 E 英文版整体已是低 AI 味技术文体:全文仅 1 处命中修改范式,其余 6 类范式全部零命中。1 处修改后 verify-en 0 FAIL、mdbook 构建 0 WARN/ERROR。

## 逐范式命中清单

| 范式 | 命中数 | 说明 |
|------|--------|------|
| 禁用词表(delve/foster/leverage/utilize/robust/seamless/pivotal 等 24 词) | 0 | 全词形 grep 零命中 |
| hedging 前缀(Actually/Honestly/clearly 等 11 词) | 0 | `really/just/literally/genuinely/honestly/simply/actually/truly/fundamentally/importantly/crucially` 零命中 |
| colon reveal(冒号后接悬念句) | 0 | 全文冒号均为列表/代码块/表格引入(L40/44/51/57/63/75/100/139/145/168/178),合法保留 |
| recap ending(回声式收尾) | 0 | 结尾为 project-structure 树形代码块,落在具体事实上,无 "In conclusion"/总结回声段 |
| 顿号(、)/全角标点/CJK 残留 | 0 | perl 全非 ASCII 扫描:仅 `→`(x2,RED→GREEN→REFACTOR 术语)、`≥`(工具链要求)、box-drawing 字符(树形图),均合法 |
| em dash ≤2 | 0(=0,合规) | 全文 0 个 em dash |
| bold 撒粉 | 0 | 仅 3 处 bold = L141-143 **RED/GREEN/REFACTOR** 术语标签,中文版同款,非强调撒粉 |

## 修改明细(共 1 处)

### 修改 1:L40 —— 清除 "Note that" 喉音前缀

- 前:`These commands match `CLAUDE.md` and the baseline CI checks. Note that `cargo build --workspace` builds workspace members but does not automatically enable `octos-cli/api`. To run `octos serve`, build or install the CLI with the `api` feature enabled.`
- 后:`These commands match `CLAUDE.md` and the baseline CI checks. `cargo build --workspace` builds workspace members but does not automatically enable `octos-cli/api`. To run `octos serve`, build or install the CLI with the `api` feature enabled.`
- 依据:trilingual-collab-en.md Patterns #2(throat-clearing)。中文源 L40 对应句为「注意:……」的陈述句,英文去掉标记词后论断不变、无新增/删节。

## 边界核查

- 命令块(cargo/git/mdbook/脚本)逐字符未动;
- 路径(`crates/...`、`scripts/...`)与全部数字(26 members、1.85.0、2024、resolver 2 等)未动;
- 未新增中文版没有的论断,未删节(verify-en refs 相等集确认)。

## 复验输出

```
$ bash scripts/verify-en.sh chapters/appendix-e-contributing.md book-en/src/appendix/e-contributing.md
refs: 1 (equal sets: yes)
en words: 929, bold 3, em dash 0
RESULT: 0 FAIL(s), 0 WARN(s)
verify-en exit=0

$ cd book-en && mdbook build 2>&1 | grep -cE 'WARN|ERROR'
0
```

## 备考(未修改,留档)

- L44 "currently recommend"、L145 "In practice":中文源对应「当前推荐」「实践上」均为原文论断的一部分,非 hedging 副词,按硬边界(不删节)保留。
- 全文使用直引号、无 smart quotes;标题无 emoji、无非 ASCII。
