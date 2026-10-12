# Supplementary materials

Data and code accompanying **From Plausible to Verified: Evaluating GenAI-Generated MATLAB Code in Electromagnetics Education**.

## Observed results

The collection began on 7 October 2026; receipt metadata span 7–8 October. It contains 72 initial responses: 61 code outputs and 11 Gemini no-code service messages. Desktop evaluation used MATLAB **R2024b Update 4 (24.2.0.2833386)** on 8 October. Reference agreement at the tested inputs: Q1 21/22 available files, Q2 21/21 with source-matched geometry, S2 7/9. Initial Q3: 5/9 available GUIs initialized. Four separate one-shot repairs initialized, but missing observations and animation/timer limitations prevent asserting complete dynamic success. These are descriptive cases, not assistant rankings or measured learning gains.

## Read first

| Supplement | Contents |
|---|---|
| [S1 Protocol](S1_protocol.md) | Six prompts, evaluation rules, thresholds, normalization and prompt-design checklist |
| [S2 Field results](S2_field_results.md) | Outcome counts and mapping to labeled vectors/diaries |
| [S3 Source coverage](S3_coverage.md) | Source-only checklist, evidence and limitations |
| [S4 GUI results](S4_gui_results.md) | Initial review, user confirmation, repairs and missing observations |
| [S5 Teaching illustrations](S5_teaching_illustrations.md) | Proposed interfaces moved out of the paper; not validated outcomes |
| [Reproduction instructions](REPRODUCING.md) | Inspect archived results or rerun in a separate copy |
| [Publication notes](PUBLICATION_NOTES.md) | Redactions, manifests and licensing status |

## Data layout

- `prompts/`: six experimental prompts, including S2.
- `responses_raw/`: rendered response captures and JSON code blocks; private chat identifiers are redacted.
- `code_raw/`: extracted generated implementations; `code_eval/`: evaluation copies and isolated function directories.
- `reference/`, `checks/`, `tools/`: reference calculations, MATLAB checks and portable adjudication scripts.
- `results/`: observed desktop CSVs, diaries, screenshots and adjudicated records.
- `logs/`: dispatch/generation metadata, input-only diffs, reviewer notes and historical manifests.
- `original_v1_v2/`: archived pilot, kept separate from repeated-generation rates.
- `figures/`, `illustrations/`: pilot replot and illustrative teaching screenshots.
- `export_manifest.json`: original versus exported hashes; `SHA256SUMS.json`: checksums of the supplementary files.

Historical logs record progress at different times. The results in this README and S2–S4 supersede earlier progress notes. Missing cells, NaN and no-code messages must not be recoded as zeros or passes.
