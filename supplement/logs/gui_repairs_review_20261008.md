# One-shot repaired GUI review

Four genuine same-chat repairs were generated on 8 October, then tested by named desktop reviewer Quy in MATLAB R2024b Update 4. All four initialized. This is separate from initial initialization 0/3 ChatGPT, 3/3 Claude, 2/3 DeepSeek and three Gemini no-code responses.

- ChatGPT r1 v2: Start, Update, Stop and Reset marked 1; diary contains no recorded error. Evidence/duration were not filled, so a documented >=3-second animation pass is not asserted.
- ChatGPT r2 v2: initialization 1; all callback fields missing. The diary has no error, but this is not evidence that callbacks were exercised.
- ChatGPT r3 v2: callback fields 1, but reviewer explicitly states only numeric values update and the image does not change. This note prevents classifying full dynamic-animation success. After screenshot shows Ready/time=0 following the review and is not a time sequence proving movement.
- DeepSeek r2 v2: initialization 1; all callbacks marked 0. Diary repeatedly logs TimerFcn failure: `XData` is not accessible on `matlab.graphics.GraphicsPlaceholder`. Reviewer also reports equations difficult to see because of colors. The after screenshot is on Status, so it cannot independently adjudicate equation readability.

Repair outcomes are reported without overwriting the original CSV, changing initial rates or silently fixing generated code. No further repair is sent under the one-shot protocol. Missing observations and notes that contradict binary labels remain explicit. These observations demonstrate that all four initial initialization errors were overcome, while full functionality is not established for all repairs.
