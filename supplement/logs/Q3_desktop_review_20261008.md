# Q3 initial-code desktop review — 8 October 2026

Initial-code repeat review, not new generations or repaired outputs. Reviewer: Quy. MATLAB R2024b Update 4.

| Assistant | Available code | Initialization | Start | Update | Stop | Reset |
|---|---:|---:|---:|---:|---:|---:|
| chatgpt | 3 | 0/3 observed | unobserved | unobserved | unobserved | unobserved |
| gemini | 0 | unobserved | unobserved | unobserved | unobserved | unobserved |
| claude | 3 | 3/3 observed | 3/3 observed | 3/3 observed | 3/3 observed | 3/3 observed |
| deepseek | 3 | 2/3 observed | 1/2 observed | 0/1 observed | 0/1 observed | 1/2 observed |

Gemini returned three service messages without code; do not label these MATLAB initialization failures. ChatGPT source parse-error lines: 165, 223 and 83. DeepSeek r2 fails assigning the function reference to TextArea.Value at generated-source line 110. CSV error_line can refer to runner or library frames; use the full error report to locate generated-source errors.

Claude r1: reviewer explicitly reports a LaTeX rendering error, despite passing callback labels. All observation-duration fields remain placeholders; update labels do not yet establish the planned >=3-second observation. DeepSeek r1 Update and Stop remain missing. No full dynamic success rate or feature-coverage score is inferred.

All initial files and first desktop CSV are preserved. One same-chat repair is permitted only for each of the four initial initialization failures. Repairs require separate capture and desktop tests.

## Independent evidence reconciliation

The direct user confirmation establishes >=3 seconds for all three Claude runs. Original CSV duration placeholders are preserved. Claude r1 diary confirms invalid LaTeX interpreter syntax. DeepSeek r1 diary additionally confirms invalid LaTeX syntax and `Error while evaluating TimerFcn for timer timer-1: Value must be a handle.` Therefore its dynamic test contains an observed callback error, even though update_ok was left NaN. Stop remains unobserved. DeepSeek r3 diary identifies `GPS_Simulation/startSim` line 229, `Invalid or deleted object`, corroborating the recorded Start failure. Do not reinterpret other zero-valued controls as separately proven implementation errors without their own diary evidence.

Three available initialization PNGs were visually inspected. Claude r1 and DeepSeek r1 exports capture graphics rather than the complete app; UI export warnings explain why they cannot demonstrate equation-panel rendering or callback success. DeepSeek r3 shows an empty scene despite an initialized GUI. Absence of after screenshots is an evidence limitation, not an additional code failure.
