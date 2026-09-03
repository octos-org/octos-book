#!/usr/bin/env bash
# verify-en.sh <zh.md> <en.md>  — structural/factual mirror check for book-en
# 中英结构镜像门:标题/代码块/mermaid/表行数相等,引用集合相等,中文数字全在英文,正文无 CJK,禁用词 0,Positioning/Version note 在位。
zh="$1"; en="$2"; fail=0; warn=0
strip(){ awk '/^```/{c=!c;next} !c' "$1"; }
f(){ echo "FAIL: $*"; fail=$((fail+1)); }
w(){ echo "WARN: $*"; warn=$((warn+1)); }
[ -f "$zh" ] && [ -f "$en" ] || { echo "usage: verify-en.sh zh.md en.md"; exit 2; }
hz=$(grep -cE '^#{1,4} ' "$zh"); he=$(grep -cE '^#{1,4} ' "$en"); [ "$hz" = "$he" ] || f "headings zh=$hz en=$he"
cz=$(grep -c '^```' "$zh"); ce=$(grep -c '^```' "$en"); [ "$cz" = "$ce" ] || f "code fences zh=$cz en=$ce"
mz=$(grep -c '^```mermaid' "$zh"); me=$(grep -c '^```mermaid' "$en"); [ "$mz" = "$me" ] || f "mermaid zh=$mz en=$me"
codeblk(){ awk '/^```mermaid/{m=1} /^```/{if(c){print "@@END"};c=!c;if(!c)m=0;next} c&&!m' "$1" | sed -E 's|//.*$||; s|#.*$||'; }
cz=$(codeblk "$zh" | md5); ce=$(codeblk "$en" | md5); [ "$cz" = "$ce" ] || w "code block content differs (mermaid and comments excluded)"
tz=$(grep -c '^|' "$zh"); te=$(grep -c '^|' "$en"); [ "$tz" = "$te" ] || w "table rows zh=$tz en=$te"
rz=$(grep -oE '(crates|octoscode|herdr)/[A-Za-z0-9_./-]+(:[0-9]+(-[0-9]+)?)?' "$zh" | sort -u); re=$(grep -oE '(crates|octoscode|herdr)/[A-Za-z0-9_./-]+(:[0-9]+(-[0-9]+)?)?' "$en" | sort -u)
miss=$(comm -23 <(echo "$rz") <(echo "$re") | wc -l | tr -d ' '); extra=$(comm -13 <(echo "$rz") <(echo "$re") | wc -l | tr -d ' ')
[ "$miss" = 0 ] || { f "refs missing in en: $miss"; comm -23 <(echo "$rz") <(echo "$re") | head -5 | sed 's/^/  - /'; }
[ "$extra" = 0 ] || { f "refs only in en: $extra"; comm -13 <(echo "$rz") <(echo "$re") | head -5 | sed 's/^/  - /'; }
echo "refs: $(echo "$rz" | grep -c .) (equal sets: $([ "$miss$extra" = 00 ] && echo yes || echo no))"
nz=$(strip "$zh" | sed -E 's/U\+[0-9A-Fa-f]{4,6}//g' | grep -oE '[0-9][0-9,]{2,}[0-9]|[0-9]{3,}' | sort -u); nmiss=0; for n in $nz; do grep -qF -- "$n" "$en" || { nmiss=$((nmiss+1)); [ $nmiss -le 5 ] && echo "  - number missing: $n"; }; done
[ "$nmiss" = 0 ] || f "numbers from zh missing in en: $nmiss"
cjk=$(strip "$en" | grep -o '[一-龥]' | wc -l | tr -d ' '); [ "$cjk" = 0 ] || f "CJK chars outside code in en: $cjk"
banned='delve|foster|leverage|utilize|facilitate|empower|streamline|robust|seamless|cutting-edge|paradigm shift|game changer|tapestry|realm|pivotal|multifaceted|meticulous|transformative|elevate|embark|ever-evolving|it.s worth noting|at the end of the day|when it comes to|at its core|in today.s world|the reality is|in order to|let.s dive in'
b=$(strip "$en" | grep -oiE "\\b($banned)\\b" | wc -l | tr -d ' '); [ "$b" = 0 ] || { f "banned words/phrases: $b"; strip "$en" | grep -oiE "\\b($banned)\\b" | sort | uniq -c | sort -rn | head -5 | sed 's/^/  /'; }
em=$(strip "$en" | grep -o '—' | wc -l | tr -d ' '); [ "$em" -le 2 ] || w "em dashes $em > 2"
bold=$(grep -o '\*\*[^*]\+\*\*' "$en" | wc -l | tr -d ' '); [ "$bold" -le 15 ] || w "bold $bold > 15"
case "$en" in *appendix*|*preface*) ;; *) grep -qE '^> \*\*Positioning\*\*' "$en" || f "missing '> **Positioning**' anchor"; grep -qE '^> \*\*Version note\*\*' "$en" || f "missing '> **Version note**' footer";; esac
words=$(strip "$en" | wc -w | tr -d ' '); echo "en words: $words, bold $bold, em dash $em"
echo "RESULT: $fail FAIL(s), $warn WARN(s)"
[ "$fail" = 0 ]
