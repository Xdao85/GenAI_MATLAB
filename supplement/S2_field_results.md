# S2 Field results

Reference agreement / available code; three responses planned per assistant–prompt cell.

| Assistant | Q1.1 | Q1.2 | Q2.1 | Q2.2 | S2 |
|---|---|---|---|---|---|
| chatgpt | 3/3 | 3/3 | 3/3 | 3/3 | 2/3 |
| gemini | 1/2 | 2/2 | 2/2 | 1/1 | N/A |
| claude | 3/3 | 3/3 | 3/3 | 3/3 | 3/3 |
| deepseek | 3/3 | 3/3 | 3/3 | 3/3 | 2/3 |

N/A: not assessed; no S2 code available (0/3 planned responses).

Q1: 21/22; Q2: 21/21 (12 centered, nine endpoint geometries); S2: 7/9. Gemini Q1.1 r2 fails parsing. ChatGPT S2 r3 stops at 200% disagreement; DeepSeek S2 r1 stops at its error gate. See `results/field_adjudication.csv` for labeled vectors, geometry, code hashes and external errors; `results/desktop_checks_log.txt` contains the diary. `logs/field_adjudication_20261008.md` documents the review. `results/checks.csv` contains initial execution/candidate output and must not replace semantic vector adjudication. Single-input agreement does not establish general correctness.

## Sensitivity to printed precision

This is a re-analysis of archived labeled vectors, not a new MATLAB experiment. Relative errors below are based on printed output precision; they are not solver accuracy estimates.

| Task | Completed/reference-agreeing files | Median external error (%) | Maximum external error (%) |
|---|---:|---:|---:|
| Q1 | 21 | 7.23508e-05 | 0.159365 |
| Q2 | 21 | 0.000591027 | 0.0448648 |
| S2 | 7 | 2.12649e-05 | 2.15384e-05 |

At an external threshold of 0.1%, 48 of the 52 available field/self-check files meet reference agreement; at 0.5%, 49 do. The differing file is DeepSeek Q1.1 r2, whose printed vector is rounded to [2.45, 0, 0] against a reference near [2.4461, 0, 0], yielding approximately 0.159% relative error. This difference reflects acceptance of rounded textual output, not evidence that the code becomes more accurate at a looser threshold. The parsing failure and two self-check stops remain non-completing at both thresholds. The internal 0.1% S2 disagreement gate is distinct from these external comparisons.
