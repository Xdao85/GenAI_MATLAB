# Paper v8 re-execution record

Date: 6 October 2026. MATLAB 24.2.0.2833386 (R2024b) Update 4.

The author-designated MATLAB_code files were copied unchanged for testing. Source SHA-256 hashes are in source_manifest.json. There are 20 initial files, two repaired GPS files and two Q1 helper functions (24 shipped assistant files). The two reference scripts are separate.

| Test | Result |
|---|---|
| 16 field-task files | All execute; numerical values reproduced. DeepSeek Q2.1 analytical direction remains reversed. |
| ChatGPT GPS_Dynamics_GUI_v1 | Syntax failure at line 98: unterminated character vector spanning multiple LaTeX lines. |
| ChatGPT GPS_Dynamics_GUI_v2 | Initializes; update at line 422 and reset at line 510 fail on deleted graphics handles. |
| DeepSeek GPS_Simulation_GUI_v1 | API failure at line 68: uicontrol Interpreter unsupported. |
| DeepSeek GPS_Simulation_GUI_v2 | Initializes; short start/update/stop/reset checks pass. |
| Gemini GPS | Initializes; short start/update/stop check passes. Reset not available/tested. |
| Claude GPS | Initializes; short start/update/pause/reset checks pass. |
| Q1 reference | Executes and reproduces (2.4461, 0, 0) V/m. |
| Q2 reference | Executes; vector errors about 3.09e-10 centered and 4.39e-11 endpoint; right-hand-rule assertions pass. |

## Protocol and limits

Each initial file is invoked by filename in its own folder, with required Q1 helper functions available. Figures start hidden; source contents are not modified. GUI checks invoke Start and five timer updates for timer-based GUIs, then Stop/Pause and Reset where present. Gemini uses a one-second stopper for its blocking simulation loop. The harness observes state changes and callback exceptions. It does not benchmark receiver position error, stochastic repeatability or long-duration stability. Warnings (Gemini LaTeX title/equation and Claude extra legend) are retained in logs. A screenshot-export warning is not counted as a simulation failure.

ChatGPT v2 plots multiple objects on axes without hold on, invalidating earlier handles; this explains the reproducible update/reset errors. DeepSeek v2 animates a prescribed trajectory and computes geometric/noisy pseudoranges but has no receiver position estimator.

To repeat, add this verification folder to the MATLAB path and invoke rerun_v8_initial, rerun_v8_repairs and rerun_v8_dynamic. The scripts use the sibling code/generated and code folders. Logs and JSON results are saved here. Initial and repaired code is preserved, including ChatGPT v1's filename/declaration mismatch. No repair is applied by the harness.

The rerun date is not the original generation date. Original model IDs/settings and conversation transcripts remain unverified. The prior Markdown Q3.m artifact is not used as the author-designated ChatGPT first-prompt source in paper v8.
