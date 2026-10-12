# S1 Protocol and prompt specification

The pilot contains 20 initial and two repaired files; original generation metadata are incomplete. The repeated collection contains four assistants × six prompts × three new chats = 72 initial responses. Replicates are r1–r3. See `prompts/` for the complete Q1.1, Q1.2, Q2.1, Q2.2, Q3 and S2 specifications. S2 fixes centered-wire geometry and requests independent analytical/numerical solutions, direction checks and a 0.1% disagreement gate. Displayed model labels and modes are recorded in `logs/generation_log.csv`; interface labels do not independently identify the backend.

Only Q1/Q2 input values were normalized in evaluation copies; diffs are archived in `logs/`. The source-selected geometry was retained. A code-bearing response is available; a service message is not a MATLAB failure. Field completion requires execution and labeled vectors. External review compares those vectors to geometry-matched reference vectors at 0.5% relative error. This operational threshold accommodates rounded diary output; it is not a statistically calibrated accuracy bound. S2 also requires both vectors to agree externally. A self-check stop remains a non-completing solution even when it detects its own discrepancy. Tested references are nonzero; no zero-field absolute tolerance was validated.

GUI review separates initialization, Start, ≥3-second visible updates, Stop/Pause and Reset. Numeric changes do not establish animation. Blank callback fields and missing durations remain unknown. Initial initialization failures received one same-chat repair; v2 outcomes are separate and excluded from initial rates. Source review is a distinct, AI-assisted checklist, not a validated educational rubric.

## Prompt-design checklist moved from the main paper

| Element | Specification | Error addressed |
|---|---|---|
| Context | Course level, MATLAB release, toolboxes | Unsupported API |
| Physical model | Governing equations | Incorrect or simplified physics |
| Geometry | Coordinates, endpoints, orientation, SI units | Silent assumptions |
| Verification | External vector, direction, error tolerance | Sign errors or shared wrong models |
| Visualization | Plot, labels, axes and scale | Misleading graphics |
| Code constraints | Strings, local functions, UI framework, persistent handles | Parsing/API/callback failures |
| Documentation | Assumptions and equation-to-code comments | Unexplained implementations |

The checklist is proposed teaching practice; its educational effectiveness has not been evaluated.
