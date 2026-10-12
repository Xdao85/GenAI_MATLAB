from pathlib import Path

import csv,re,hashlib,json

root=Path(__file__).resolve().parents[1]

rows=[]

for r in csv.DictReader((root/'logs/planned_runs.csv').open(encoding='utf-8-sig')):

 if r['prompt_id']!='Q3':continue

 p=root/r['file'];a=r['assistant'];rep=r['rep']

 out={'assistant':a,'prompt_id':'Q3','rep':rep,'version':'v1','rater':'AI-assisted review static source review','assessment_type':'source presence; not runtime feature validity','file':r['file']}

 if not p.exists():

  out.update(C1_equations='',C2_functions='',C3_position_solver='',C4_comments='',evidence='No code supplied; not assessed',sha256='')

 else:

  lines=p.read_text(encoding='utf-8').splitlines()

  def hits(pattern):return [i+1 for i,l in enumerate(lines) if re.search(pattern,l,re.I)]

  eq=hits(r'Interpreter.*latex|pseudorange equation|eqStr1')

  fun=hits(r'MATLAB Functions|functionText|functionReferenceText|Functions Used|MATLAB functions used|function documentation')

  comments=hits(r'^\s*%.*(GUI|LATEX|SIMULATION|VISUAL|SECTION)')

  solver=hits(r'^\s*function .*?(estimatePosition|lsqPosition|solvePosition|solveGPS|wls|gpsSolve)|fminsearch')

  # C3 requires a joint position-and-clock iterative solver in source, not a truth-linearized one-step correction.

  c3=0 if a=='deepseek' and rep in ['1','3'] else 1

  out.update(C1_equations=int(bool(eq)),C2_functions=int(bool(fun)),C3_position_solver=c3,C4_comments=int(bool(comments)),evidence=json.dumps({'equation_lines':eq[:6],'function_explanation_lines':fun[:6],'solver_lines':solver[:6],'section_comment_lines':comments[:8],'solver_limitation':'truth-linearized one-step correction, not iterative joint position-clock solution' if not c3 else 'solver declared; correctness and positioning accuracy unvalidated'},ensure_ascii=False),sha256=hashlib.sha256(p.read_bytes()).hexdigest())

 rows.append(out)

with (root/'results/coverage_static.csv').open('w',encoding='utf-8',newline='') as f:

 w=csv.DictWriter(f,fieldnames=rows[0].keys());w.writeheader();w.writerows(rows)

for r in rows:print(r['assistant'],r['rep'],[r[k] for k in ['C1_equations','C2_functions','C3_position_solver','C4_comments']])

(root/'logs/coverage_rubric.md').write_text('''# Static feature coverage rubric



Reviewer: AI-assisted review, source review on 8 October 2026. This review is distinct from the named desktop reviewer and does not overwrite results/coverage.csv.



C1: source includes GPS equations and requests LaTeX rendering. C2: source contains explanatory MATLAB-function text intended for the GUI. C3: source implements an iterative joint position-and-clock solution from pseudoranges. C4: section comments cover GUI, equations, simulation and visualization. Binary indicators describe inspected source content, not execution, correct rendering, independent initialization, conditioning or validated positioning accuracy. Evidence line numbers and source SHA-256 hashes are in coverage_static.csv. No-code responses are unassessed, not feature failures.



All nine available initial sources include equation/rendering declarations, function explanations and section comments. Seven include iterative position-clock solvers. DeepSeek r1 linearizes at true receiver position and removes known true bias; r3 uses a truth-seeded three-variable one-step solve despite biased pseudoranges. Neither meets C3. Truth-dependent starting guesses in other implementations remain a limitation even where C3 is present.



Runtime evidence overrides any inference of functionality from presence: ChatGPT initialization fails; DeepSeek r2 initialization fails; Claude r1 and DeepSeek r1 have LaTeX warnings; DeepSeek r1/r3 have callback errors. A static 1 cannot be counted as a functioning feature or learning outcome. No aggregate ranking or validated educational rubric is inferred.

''',encoding='utf-8')

