# Static feature coverage rubric

Reviewer: AI-assisted review, source review on 8 October 2026. This review is distinct from the named desktop reviewer and does not overwrite results/coverage.csv.

C1: source includes GPS equations and requests LaTeX rendering. C2: source contains explanatory MATLAB-function text intended for the GUI. C3: source implements an iterative joint position-and-clock solution from pseudoranges. C4: section comments cover GUI, equations, simulation and visualization. Binary indicators describe inspected source content, not execution, correct rendering, independent initialization, conditioning or validated positioning accuracy. Evidence line numbers and source SHA-256 hashes are in coverage_static.csv. No-code responses are unassessed, not feature failures.

All nine available initial sources include equation/rendering declarations, function explanations and section comments. Seven include iterative position-clock solvers. DeepSeek r1 linearizes at true receiver position and removes known true bias; r3 uses a truth-seeded three-variable one-step solve despite biased pseudoranges. Neither meets C3. Truth-dependent starting guesses in other implementations remain a limitation even where C3 is present.

Runtime evidence overrides any inference of functionality from presence: ChatGPT initialization fails; DeepSeek r2 initialization fails; Claude r1 and DeepSeek r1 have LaTeX warnings; DeepSeek r1/r3 have callback errors. A static 1 cannot be counted as a functioning feature or learning outcome. No aggregate ranking or validated educational rubric is inferred.
