# S3 Static source coverage

Reviewer: AI-assisted review, source inspection on 8 October 2026, separate from desktop reviewer Quy. C1: GPS equation/LaTeX declarations. C2: explanatory function text. C3: iterative joint position-clock solver. C4: section comments.

All nine initial code sources contain C1, C2 and C4; seven meet C3. DeepSeek r1 linearizes around true position and removes known bias; r3 uses a truth-seeded three-variable one-step calculation despite biased pseudoranges. Neither meets C3. Truth-dependent initialization in other sources also limits interpretation.

Evidence: `results/coverage_static.csv`, source lines/hashes and `logs/coverage_rubric.md`. The blank human template `results/coverage.csv` remains unchanged. No-code responses are unassessed. Presence is not correct rendering, functional behavior, positioning accuracy or learning effectiveness. No inter-rater agreement or educational validation was measured.
