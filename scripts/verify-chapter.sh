#!/usr/bin/env bash
# usage: verify-chapter.sh <chapter.md> [octos-root]
# 外环机械复验:引用路径/行号、锚点、去味指标、Mermaid 边 vs Cargo 依赖、mdbook build。
# 源码仓库根目录:参数 2 > $OCTOS_ROOT > 本仓库同级的 ../octos;octoscode/herdr 同理($OCTOSCODE_ROOT/$HERDR_ROOT)。
BOOK=$(cd "$(dirname "$0")/.." && pwd)
ch=$1; root=${2:-${OCTOS_ROOT:-$BOOK/../octos}}
export OCTOSCODE_ROOT=${OCTOSCODE_ROOT:-$BOOK/../octoscode} HERDR_ROOT=${HERDR_ROOT:-$BOOK/../herdr}
python3 - "$ch" "$root" <<'PY'
import sys,re,os,subprocess
ch,root=sys.argv[1],sys.argv[2]; s=open(ch,encoding='utf-8').read(); fail=0
def bad(m): 
    global fail; fail+=1; print("FAIL:",m)
# 1 refs
refs=set(re.findall(r'((?:crates|octoscode/src|herdr/src)/[A-Za-z0-9_./-]+\.rs)(?::(\d+)(?:-(\d+))?)?',s))
ROOTS={'octoscode':os.environ['OCTOSCODE_ROOT'],'herdr':os.environ['HERDR_ROOT']}
for p,a,b in sorted(refs):
    top=p.split('/')[0]
    fp=os.path.join(ROOTS.get(top,root), p[len(top)+1:] if top in ROOTS else p)
    if not os.path.exists(fp): bad(f"path missing {p}"); continue
    n=sum(1 for _ in open(fp,encoding='utf-8',errors='ignore'))
    hi=int(b or a or 0)
    if hi and hi>n: bad(f"line out of range {p}:{a}-{b} (file has {n})")
print(f"refs checked: {len(refs)}")
# 2 anchors
for k in ['> **定位**','版本演化','延伸阅读','思考题','```mermaid']:
    if k not in s: bad(f"missing {k}")
# 3 de-slop
dash=s.count('——'); bold=s.count('**')//2
if dash>2: bad(f"—— count {dash} > 2")
if bold>10: print(f"WARN: bold {bold} > 10")
for w in ['值得注意的是','众所周知','综上所述','总而言之','赋能','抓手','闭环','沉淀','助力','不得不说','说实话']:
    if w in s: bad(f"slop word {w} x{s.count(w)}")
for t in ['10 个 crate','13 万行','14 个内置工具','14 个消息频道','91 个 REST']:
    if t in s: bad(f"stale number {t}")
# 4 size
code=re.findall(r'```.*?```',s,flags=re.S); cl=sum(len(c) for c in code); prose=re.sub(r'```.*?```','',s,flags=re.S)
cjk=len(re.findall(r'[一-鿿]',prose)); ratio=cl/len(s)
print(f"CJK prose chars {cjk}, code ratio {ratio*100:.1f}%")
if not (4500<=cjk<=11000): print(f"WARN: prose size {cjk} outside 5000-10000")
if ratio>0.30: bad(f"code ratio {ratio*100:.1f}% > 30%")
# 5 mermaid edges vs Cargo deps (octos-* --> octos-*)
alias={m.group(1):m.group(2) for m in re.finditer(r'^\s*([A-Za-z0-9_]+)\[(octos-[a-z0-9-]+)',s,flags=re.M)}
raw=re.findall(r'^\s*([A-Za-z0-9_-]+)\s*-->\s*([A-Za-z0-9_-]+)\s*$',s,flags=re.M)
edges=set((alias.get(a,a),alias.get(b,b)) for a,b in raw)
edges=set(e for e in edges if e[0].startswith('octos-') and e[1].startswith('octos-'))
if edges:
    import glob,tomllib
    deps={}
    for ct in glob.glob(os.path.join(root,'crates/*/Cargo.toml')):
        try: d=tomllib.load(open(ct,'rb'))
        except Exception: continue
        name=d.get('package',{}).get('name'); 
        if not name: continue
        ds=set(d.get('dependencies',{}).keys())|set(d.get('dependencies',{}).keys())
        deps[name]=ds
    okc=0
    for a,b in edges:
        a2,b2=a.replace('_','-'),b.replace('_','-')
        if b2 in deps.get(a2,set()) or a2 in deps.get(b2,set()): okc+=1
        else: bad(f"mermaid edge not in Cargo deps: {a}-->{b}")
    print(f"mermaid edges checked: {len(edges)}, ok {okc}")
print("RESULT:", "PASS" if fail==0 else f"{fail} FAIL(s)")
PY
# 6 mdbook build must pass (run from book repo root if present)
if [ -d "$BOOK/book" ] && command -v mdbook >/dev/null; then (cd "$BOOK/book" && mdbook build >/dev/null 2>&1 && echo "mdbook build: PASS" || echo "FAIL: mdbook build"); fi
