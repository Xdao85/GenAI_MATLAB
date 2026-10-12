# Static review of fresh responses

These observations concern the preserved response text/code. They are not MATLAB execution results or reliability rates.

- Gemini Q1.1 r2: the primary code block contains a second script inserted inside an unfinished `fprintf` string, including a literal Markdown fence. Preserve this malformed block; do not select the later fragment as a replacement answer.
- DeepSeek Q1.2 r1: the sample output in prose has negative components, while the default inputs place P between a positive charge at [0,0,0] and a negative charge at [1,1,1]. The two fields both point toward positive x/y/z at this P. Check the actual printed result against the prose separately from normalized-input correctness.
- DeepSeek Q2.1 r2: the note says Bmag can reverse sign with observation height. With positive current and ordered wire ends, s/sqrt(rho^2+s^2) is monotone, so the endpoint difference stays positive for rho > 0. Current reversal changes direction; changing Pz alone does not reverse the azimuthal direction.
- DeepSeek Q2.1 r3: the optional y-z field map assigns Bx to its plotted z component, although Bz is zero for this geometry. This optional block is preserved but is not concatenated to the primary script for execution scoring.
- DeepSeek Q2.2 r1: the expected-output prose describes -x/-y at P=(0.5,0.5,0) for +z current. The right-hand rule gives -x/+y. The primary numerical code uses cross(dl,r_vec), so inspect its computed vector independently of this explanation.
- ChatGPT Q2.1 r1: inspect the conductor plotting call with scalar x/y and a two-element z vector in MATLAB. Record any actual plotting error without repairing the initial evaluation copy.

No score is assigned from these notes. Service messages without code remain separate from generated-code failures.

- DeepSeek S2 r1: the finiteWireB implementation divides cross(R1,R2) by its squared norm, but the direction vectors are not normalized consistently with the endpoint projection formula. For this two-metre wire, inspection predicts a factor-of-two disagreement with the independent integral; verify actual printed vectors before classifying.
- ChatGPT S2 r3: the analytical formula uses [dy,-dx,0], whereas cross([0,0,dz],R) in the numerical integral points [-dy,dx,0]. Its own error gate should expose the reversal; preserve both vectors and the stopping error.
- ChatGPT Q3 r1/r2/r3: multiline single-quoted LaTeX text appears in all three primary files. Do not silently join these strings; record the actual initialization error before one same-chat repair.
- ChatGPT Q3 r2: no hold-on call protects consecutively created plot3 handles, and axes limits are smaller than the orbital radius. Inspect retained handles and satellite visibility after any separately recorded repair.
- DeepSeek Q3 r1: the apparent position solution linearizes at the known true user position and subtracts the known true clock bias; it is a noisy perturbation about truth, not an independent receiver fix. The spatial Jacobian sign is also inconsistent with the stated separation vector.
- DeepSeek Q3 r2: every satellite has zero initial phase, giving a planar constellation at startup; code uses RGBA line colors, which require a MATLAB compatibility check. Sub-metre accuracy is claimed in prose without execution evidence.
- DeepSeek Q3 r3: a three-variable single-step solve uses the true position as its initial guess, omits the clock unknown despite biased pseudoranges, and uses the opposite spatial Jacobian sign. Repeated plot3 calls also lack hold-on, including Reset. Displayed normal-equation text is not a complete nonlinear GPS position solution.
