# Desktop field check receipt — 8 October 2026

Source: results/checks.csv and desktop_checks_log.txt. MATLAB R2024b Update 4.

52 code-bearing field/self-check files are represented; 49 reached the end of execution. This is not yet a verified physical-correctness rate. All candidate-vector classifications require manual confirmation.

Observed errors:
- chatgpt S2 r3: Error using S2_r3 (line 106)
- gemini Q1.1 r2: Error: <a href="matlab: opentoline('[LOCAL_ROOT]\code_eval\gemini\Q11_r2.m',40,9)">File: Q11_r2.m Line: 40 Column: 9</a>
- deepseek S2 r1: Error using S2_r1 (line 48)

GUI initialization and callback results are still pending in results/gui_checks.csv. No repairs or GUI success rates are inferred from this receipt.
