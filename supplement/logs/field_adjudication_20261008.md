# Adjudicated field results — 8 October 2026

Reviewer: AI-assisted review source-and-diary audit. Results use the original MATLAB R2024b desktop diary; no generated code was changed or re-executed. Semantic labels identify output vectors; coordinate and direction-only vectors are excluded. Printed precision is retained, so relative errors refer to logged rounded values. All compared nonzero vectors use Euclidean relative error <=0.005. Sources and hashes are retained per row.

Q1: 21/22 available files completed and their total-field outputs agree for the single symmetric input. Q2: 21/21 available files completed and their field vectors agree with their source-defined geometry. S2: 7/9 available files completed and both separately labeled numerical/analytical vectors agree with the centered external reference; each contains a direction check and the prescribed disagreement gate. ChatGPT r3 and DeepSeek r1 stopped at their self-check gates, which is a detected inconsistency, not a silent success. Gemini Q1.1 r2 failed parsing.

Q2 geometry ledger: ChatGPT all six centered; Gemini Q2.1 r1/r2 endpoint and Q2.2 r3 centered; Claude all six endpoint; DeepSeek Q2.1 r1 endpoint, remaining five centered. These choices were inspected in conductor limits/source descriptions and compared with the corresponding independent closed form. They are not errors where original prompts left endpoints unspecified.

| Assistant | Prompt | Confirmed vectors / available code | No-code / 3 planned |
|---|---|---:|---:|
| chatgpt | Q1.1 | 3/3 | 0/3 |
| chatgpt | Q1.2 | 3/3 | 0/3 |
| chatgpt | Q2.1 | 3/3 | 0/3 |
| chatgpt | Q2.2 | 3/3 | 0/3 |
| chatgpt | S2 | 2/3 | 0/3 |
| gemini | Q1.1 | 1/2 | 1/3 |
| gemini | Q1.2 | 2/2 | 1/3 |
| gemini | Q2.1 | 2/2 | 1/3 |
| gemini | Q2.2 | 1/1 | 2/3 |
| gemini | S2 | 0/0 | 3/3 |
| claude | Q1.1 | 3/3 | 0/3 |
| claude | Q1.2 | 3/3 | 0/3 |
| claude | Q2.1 | 3/3 | 0/3 |
| claude | Q2.2 | 3/3 | 0/3 |
| claude | S2 | 3/3 | 0/3 |
| deepseek | Q1.1 | 3/3 | 0/3 |
| deepseek | Q1.2 | 3/3 | 0/3 |
| deepseek | Q2.1 | 3/3 | 0/3 |
| deepseek | Q2.2 | 3/3 | 0/3 |
| deepseek | S2 | 2/3 | 0/3 |

These descriptive counts must not be interpreted as general reliability, a model ranking or a causal prompt benefit. All comparisons use one input configuration per task. Self-check agreement alone does not prove general correctness. Q2/S2 geometry differs between endpoint and centered outputs, and no-code outputs limit matched comparisons.
