from pathlib import Path

import csv,re,math,json,hashlib

root=Path(__file__).resolve().parents[1]

s=re.sub(r'<[^>]*>','',(root/'results/desktop_checks_log.txt').read_text(encoding='utf-8',errors='replace'))

marks=list(re.finditer(r'(?m)^(chatgpt|gemini|claude|deepseek) (Q1\.1|Q1\.2|Q2\.1|Q2\.2|S2) r([123])\s*$',s))

segments={(m[1],m[2],m[3]):s[m.end():marks[i+1].start() if i+1<len(marks) else len(s)] for i,m in enumerate(marks)}

num=r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?'

refs={'q1':[2*8.9875517923e9*2e-9/(6**1.5),0,0],'mid':[-9.141924341e-8,1.3712886512e-7,0],'end':[-5.610366841e-8,8.415550262e-8,0]}

rows=[]

for r in csv.DictReader((root/'results/checks.csv').open(encoding='utf-8-sig')):

 key=(r['assistant'],r['prompt_id'],r['rep']);pid=key[1];path=root/r['file'];source=path.read_text(encoding='utf-8')

 geo='q1' if pid.startswith('Q1') else 'mid'

 if pid.startswith('Q2') and (key[0]=='claude' or key[0]=='gemini' and pid=='Q2.1' or key==('deepseek','Q2.1','1')):geo='end'

 vec=[];evidence=[];seg=segments.get(key,'')

 if r['executed']=='1':

  component={}

  for ln,line in enumerate(seg.splitlines(),1):

   component_match=re.search(r'\b[BE]([xyz])\s*=\s*('+num+')',line)

   if component_match:

    component[component_match[1]]=float(component_match[2])

    if all(c in component for c in 'xyz'):

     vec.append([component[c] for c in 'xyz']);evidence.append('labeled Bx/By/Bz component group');component={}

    continue

   if pid.startswith('Q1'):

    if not re.search(r'E(?:_total|_net|tot| tot)?\s*(?:vector|at P)?\s*[:=]|Total field E|Electric Field E|Total electric field at P',line,re.I):continue

    if re.search(r'^\s*E[12]\b|^\s*\|E|Magnitude|Point P|Position P',line):continue

   else:

    if not re.search(r'\bB(?:_ref|_num)?\b|B vector',line) or not ('T' in line):continue

    if re.search(r'^In |Expected|direction|Direction|phi_hat|Current',line):continue

   match=re.search(r'\[([^\]]+)\]',line) or re.search(r'\(([^\)]+)\)',line)

   if match:

    vals=re.findall(num,match[1])

    if len(vals)==3:vec.append(list(map(float,vals)));evidence.append(line.strip())

  assert vec,(key,'No semantically labeled output')

 ref=refs[geo];norm=math.sqrt(sum(x*x for x in ref));errs=[math.sqrt(sum((x-y)**2 for x,y in zip(v,ref)))/norm for v in vec]

 passed=bool(vec) and all(e<=.005 for e in errs)

 status='reference_agreement' if passed else 'execution_failed' if r['executed']=='0' else 'reference_disagreement'

 rows.append({**{k:r[k] for k in ['assistant','prompt_id','rep','version','file','executed']},'geometry':geo,'vectors_json':json.dumps(vec),'max_relative_error':max(errs) if errs else '', 'classification':status,'reviewer':'AI-assisted review source-and-diary audit','evidence':' | '.join(evidence) if evidence else r['error_message'].splitlines()[0],'code_sha256':hashlib.sha256(path.read_bytes()).hexdigest()})

with (root/'results/field_adjudication.csv').open('w',encoding='utf-8',newline='') as f:

 w=csv.DictWriter(f,fieldnames=rows[0].keys());w.writeheader();w.writerows(rows)

from collections import Counter

print(Counter(r['classification'] for r in rows))

for a in ['chatgpt','gemini','claude','deepseek']:

 for pid in ['Q1.1','Q1.2','Q2.1','Q2.2','S2']:

  sub=[r for r in rows if r['assistant']==a and r['prompt_id']==pid]

  print(a,pid,sum(r['classification']=='reference_agreement' for r in sub),'/',len(sub),[(r['rep'],r['geometry'],r['max_relative_error']) for r in sub])

