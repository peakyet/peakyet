# Control as Inference — teaching handoff

**Stage:** question map

**Artifact:** `Control/control-as-inference/control-as-inference.typ`, compiled to `Control/control-as-inference/control-as-inference.pdf`.

## Audience

Assumes an engineer new to stochastic optimal control, comfortable with basic algebra, calculus, probability, and ordinary differential equations. No prerequisite interview was used.

## Route and assessment

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| `<s1>` | 3 | What object must a stochastic planner compare instead of a single nominal trajectory, and why can controls with the same nominal path differ in cost? | Expected: the cost is an expectation over a path measure, so controls matter through the induced distribution and its path weights. Watch for nominal-trajectory or deterministic-planner reasoning. | question-ready |
| `<s2>` | 4 | What exponential tilt of the path cost interacts with the Radon–Nikodym derivative, and what relation between `R` and `G` is needed for the interaction to depend only on noise? | Expected: tilt by `exp(-J/epsilon)`; the matched case `R = G^T G` lets the control term in the tilt cancel the quadratic Girsanov term up to a noise-only factor. Watch for assuming an arbitrary `R` works. | question-ready |
| `<s3>` | 5 | What operation turns a positive path weight into a distribution, and what does the normalization constant represent for a control cost? | Expected: divide by `Z = integral w`; `Z` is a partition function / free-energy normalizer, with KL-control meaning. Watch for treating `Z` as per-path or optional. | question-ready |
| `<s4>` | 6 | What change of variable removes the HJB nonlinearity, and how is the optimal control recovered from the transformed variable? | Expected: use a log/exponential transform of the value function, turning the nonlinear HJB equation into a linear backward/Feynman–Kac equation; recover control from a gradient of the log transform. Watch for minimizing over `u` but leaving the value equation nonlinear. | question-ready |
| `<s5>` | 7 | Which reference drift makes sample weights computable, and which part of the weight controls variance growth with the horizon? | Expected: choose a reference/proposal drift, simulate from it, and use a Radon–Nikodym weight times the exponential cost tilt; variance depends on the weight distribution, with horizon growth tied to the log-weight/action. Watch for Monte Carlo error being only `1/sqrt(N)`. | question-ready |
| `<s6>` | 8 | What fails when `R != G^T G`? What fails as `epsilon -> 0`? Which failure is construction-level versus estimator-level? | Expected: mismatching leaves uncancelled control cost in the path weight/action; `epsilon -> 0` makes the measures/weights degenerate and separates deterministic-limit issues from Monte Carlo variance. Watch for assuming the matched formula persists. | question-ready |

Running example: a scalar continuous-diffusion plant with additive noise, matched control/noise directions, positive noise strength, and quadratic control cost.

Expected insights are teaching notes only and are not copied into the question-map PDF.

## Current discussion point

Question map published. Next, send `Control/control-as-inference/control-as-inference.pdf#page=3` and ask the `<s1>` question.

## Unresolved or research-needed claims

None. This first pass is intentionally source-free and makes no external claims.

## Sources consulted

None yet; the question map makes no external claims.

## Checks

- Build — `typst compile --root . Control/control-as-inference/control-as-inference.typ Control/control-as-inference/control-as-inference.pdf` exited 0 with no warnings; PDF page count is 9.
- Structural — no `FILL:` slots; 7 level-1 headings and exactly 6 `#question` boxes; no `#takeaway`, `#intuition`, or `#claim`; no `../` paths; section-to-page map `3,4,5,6,7,8,9`.
- Answer-free — the PDF gives setup, equations, and questions only; no expected insight, worked solution, or conclusion.
- Rendered — all 9 PDF pages rasterized at 110 dpi and inspected; equations, figures, captions, and footers are placed and unclipped. Spot-checked page 5 with `pdftotext`.
- Demo — no demo.
- Stage-specific — landing card added for `Control/control-as-inference/control-as-inference.pdf` with `data-category="control ai"` and `data-tags` containing `control` and `ai`; local static-server check confirmed the card is served and the PDF link returns HTTP 200.
- Checks not run — none.

## Notes

- No `refs.bib` and no citations in this source-free first pass.
- Two inline Typst vector figures were added; no note-local `assets/` directory is used.
