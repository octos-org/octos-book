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
CITE=r'((?:crates|octoscode/src|herdr/src)/[A-Za-z0-9_./-]+\.rs)(?::(\d+)(?:-(\d+))?)?'
refs=set(re.findall(CITE,s))
ROOTS={'octoscode':os.environ['OCTOSCODE_ROOT'],'herdr':os.environ['HERDR_ROOT']}
def srcpath(p):
    top=p.split('/')[0]
    return os.path.join(ROOTS.get(top,root), p[len(top)+1:] if top in ROOTS else p)
for p,a,b in sorted(refs):
    fp=srcpath(p)
    if not os.path.exists(fp): bad(f"path missing {p}"); continue
    n=sum(1 for _ in open(fp,encoding='utf-8',errors='ignore'))
    hi=int(b or a or 0)
    if hi and hi>n: bad(f"line out of range {p}:{a}-{b} (file has {n})")
print(f"refs checked: {len(refs)}")
# 1b symbol anchors: 行号引用邻近的反引号标识符须仍存在于被引文件——全文件消失=FAIL(符号灭绝),在但漂出 ±25 行=WARN(锚点漂移)
IDENT=re.compile(r'`([^`]+)`')
TOK=r'[A-Za-z_][A-Za-z0-9_]*(?:::[A-Za-z_][A-Za-z0-9_]*)*(?:\.[A-Za-z_][A-Za-z0-9_]*)*'
TOKEN=re.compile(r'^(%s)$'%TOK); CALL=re.compile(r'^(%s)\(\)$'%TOK); ASSIGN=re.compile(r'^(%s)\s*='%TOK)
STOP={'null','none','some','ok','err','true','false','yes','no','on','off','self','todo'}
HEX=re.compile(r'^[0-9a-f]{7,40}$')
def idents(t):
    t=t.strip()
    for rx in (TOKEN,CALL,ASSIGN):
        m=rx.match(t)
        if m: return [m.group(1)]
    return []
def paren_group(line,s,e):
    st=[]; best=None
    for i,c in enumerate(line):
        if c in '(（': st.append(i)
        elif c in ')）' and st:
            o=st.pop()
            if o<s and e<=i and (best is None or o>best[0]): best=(o,i)
    return best
def ctx_idents(line,s,e):
    toks=[(m.start(),m.end(),m.group(1)) for m in IDENT.finditer(line)]
    out=[]
    def gap_ok(ts,te):  # 分号/句号跨子句即不归属同一处引用
        gap=line[te:s] if te<=s else line[e:ts]
        return not re.search(r'[。；;]',gap)
    pg=paren_group(line,s,e)
    if pg:
        o,c=pg
        for ts,te,tt in toks:
            if o<ts and te<=c and not (ts<=s<te) and gap_ok(ts,te): out+=idents(tt)
            if te<=o and not line[te:o].strip(): out+=idents(tt)  # 紧邻括号组的标识符(中文「`sym`（cite）」与英文「`sym` (cite)」)
    if '|' in line:
        cells=[(m.start(),m.end()) for m in re.finditer(r'[^|]+',line)]
        ci=next((i for i,(cs,ce) in enumerate(cells) if cs<=s<ce),None)
        if ci is not None:
            for i in ({ci,0} if line.lstrip().startswith('|') else {ci}):
                cs,ce=cells[i]
                for ts,te,tt in toks:
                    if cs<=ts and te<=ce and not (ts<=s<te) and gap_ok(ts,te): out+=idents(tt)
    seen=set(); res=[]
    for t in out:
        seg=re.split(r'::|\.',t)[-1]
        if len(seg)<3 or seg.lower() in STOP or HEX.match(seg) or t in seen: continue
        seen.add(t); res.append(t)
    return res
WIN=25; checked=skipped=drift=0; srccache={}
for ln,line in enumerate(s.splitlines(),1):
    for m in re.finditer(CITE,line):
        p,a,b=m.group(1),m.group(2),m.group(3)
        if not a: continue
        fp=srcpath(p)
        if not os.path.exists(fp): continue
        cands=ctx_idents(line,m.start(),m.end())
        if not cands: skipped+=1; continue
        if fp not in srccache:
            L=open(fp,encoding='utf-8',errors='ignore').read().splitlines(); srccache[fp]=(L,'\n'.join(L))
        L,full=srccache[fp]
        lo,hi2=max(1,int(a)-WIN),min(len(L),int(b or a)+WIN)
        win='\n'.join(L[lo-1:hi2]); found=[]; inwin=False
        for t in cands:
            seg=re.split(r'::|\.',t)[-1]; pat=r'\b%s\b'%re.escape(seg)
            if re.search(pat,full):
                found.append(t)
                if re.search(pat,win): inwin=True
        checked+=1
        # 保守语义:任一候选标识符仍在文件中即不算灭绝(宁漏报不误报)
        if not found:
            bad(f"symbol vanished {p}:{a} (context ids: {', '.join(cands)})")
        elif not inwin:
            drift+=1; seg=re.split(r'::|\.',found[0])[-1]
            at=next(i for i,l in enumerate(L,1) if re.search(r'\b%s\b'%re.escape(seg),l))
            print(f"WARN: symbol drifted {p}:{a} — {found[0]} now at line {at}")
print(f"symbol anchors: checked {checked}, skipped {skipped} (no identifier), drift {drift}")
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
sys.exit(1 if fail else 0)
PY
rc=$?
# 6 mdbook build must pass (run from book repo root if present)
if [ -d "$BOOK/book" ] && command -v mdbook >/dev/null; then (cd "$BOOK/book" && mdbook build >/dev/null 2>&1 && echo "mdbook build: PASS" || { echo "FAIL: mdbook build"; rc=1; }); fi
exit $rc
