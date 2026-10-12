# Reproduction instructions

## Inspect the archived evidence

Read S1–S4 before running anything. The observed desktop version was MATLAB R2024b Update 4. Generated code may fail parsing or callbacks; those failures are study outcomes. No dependency installation or network access is needed for inspecting the CSVs and diaries. MATLAB-generated GUI code is not assumed safe or correct solely because it is archived.

## Rerun in a separate copy

Copy this repository to a new working directory first. The original runners write into `results/` and some generated scripts use `close all`; avoid overwriting the archived evidence or mixing working figures with the experiment. Set the MATLAB Current Folder to that copy, then run in MATLAB desktop:

```matlab
addpath(fullfile(pwd,'checks'))
run_all_checks
run_gui_reviews
run_gui_repairs
```

The GUI experiment requires observed Start, ≥3-second visible motion, Stop/Pause and Reset; do not substitute MATLAB -batch for desktop observations. `run_gui_reviews` may skip already recorded rows. In the rerun copy, preserve archived CSVs under new names before starting a fresh review; do not treat their previous entries as new observations. Keep source code, evaluation inputs and failure messages unchanged. Refer to the checkers' comments and S1 for labels.

Python 3 source adjudication tools use the standard library and resolve this folder from their own location. Run them only in the rerun copy because they regenerate output CSVs:

```text
python tools/adjudicate_fields.py
python tools/audit_coverage.py
```

These scripts reproduce source/diary interpretation; they do not rerun assistant generation or independently validate a new GUI session. Fresh generation would require new chats, recorded modes and an explicitly defined study protocol.
