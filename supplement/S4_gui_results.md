# S4 GUI and repair outcomes

Initial availability: ChatGPT 3/3, Gemini 0/3, Claude 3/3, DeepSeek 3/3. Initial initialization: ChatGPT 0/3, Claude 3/3, DeepSeek 2/3. Gemini supplies no code. Named desktop reviewer: Quy.

Use `results/gui_checks_rerun_20261008_093529.csv`, the corresponding diaries, `logs/Q3_desktop_review_20261008.md` and separate `logs/gui_author_confirmation_20261008.json`. Claude ≥3-second observation was author-confirmed; r1 has a LaTeX warning. DeepSeek r1 has timer/LaTeX errors and unresolved Update/Stop fields; r3 fails Start on deleted graphics. The literal author reply “Update=0/1, Stop=0/1” is ambiguous and is not interpreted as pass.

All four one-shot repairs initialize. ChatGPT r1 callback labels pass but duration is unrecorded; r2 callback fields are missing; r3 has passing labels with an explicit note that only numbers update, not the image. DeepSeek r2 has all callback fields 0 and repeated GraphicsPlaceholder.XData timer failures; the reviewer reports poorly visible equations. See `results/gui_repairs.csv`, `results/gui_repair_adjudication.csv` and `logs/gui_repairs_review_20261008.md`.

Reconciled notes do not overwrite original observations. Screenshots are single frames, not proof of animation. Missing fields and durations prevent claiming full dynamic success. Repairs are excluded from initial rates; no further repair was performed under the one-shot protocol.
