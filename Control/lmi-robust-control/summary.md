# LMI for Robust Control — teaching handoff

**Stage:** question map

**Artifact:** `Control/lmi-robust-control/lmi-robust-control.typ`, compiled to
`Control/lmi-robust-control/lmi-robust-control.pdf`.

## Audience

Assumes an engineer new to robust control, comfortable with basic algebra and calculus, matrix
algebra, and the idea of a Lyapunov function. No prerequisite interview was used.

## Route and assessment

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| `<s1>` | 3 | What must a certificate hold for to cover a family, and why does a nominal $P$ fail? | Expected: one common quadratic Lyapunov function — a single $P\succ0$ with $A(\Delta)^TP+PA(\Delta)\prec0$ for *every* admissible $\Delta$ at once. The nominal inequality is only the $\Delta=0$ slice, so it constrains none of the other members. Watch for reasoning that picks a different $P$ per $\Delta$ or treats stability of $A$ as sufficient. | question-ready |
| `<s2>` | 4 | Why can no finite parameter sample decide the robust condition? | Expected: both obstructions. The matrix ball has no finite vertex set (its extreme points are the whole boundary), so no finite list of constraints implies the rest; and the expression is bilinear in $(P,\Delta)$, so the feasible set is nonconvex and one cannot take a finite maximum over $\Delta$. Sampling certifies only the sampled points. Watch for "just use a fine grid" or "check the corners". | question-ready |
| `<s3>` | 5 | What matrix object makes the infinite constraint affine, and what must it satisfy relative to $\Delta$? | Expected: a free positive matrix multiplier (a scaling / S-procedure variable) that bounds the cross term $G+G^T$ by a completing-square or Young-type inequality, e.g. $G+G^T \preceq PB_wXB_w^TP + C_z^T\Delta^TX^{-1}\Delta C_z$; the multiplier must commute with $\Delta$ so that $\Delta^TX^{-1}\Delta\preceq X^{-1}$ follows from $\Delta^T\Delta\preceq I$. Watch for an ansatz with no free matrix, or a multiplier that does not commute with $\Delta$. | question-ready |
| `<s4>` | 6 | Can the single bound reject a robustly stable family, and what decides it? | Expected: for a *single* quadratic constraint $\Delta^T\Delta\preceq I$ the passage from "for all $\Delta$" to the multiplier inequality is lossless (the S-procedure has no gap), so no certificate is lost; a gap appears only once the admissible set is two or more independent quadratic constraints. Watch for "a sufficient condition is always conservative" and for missing that one quadratic form is the special, tight case. | question-ready |
| `<s5>` | 7 | Which terms does the change of variables linearize, which stay coupled, and what problem class results? | Expected: the congruence $Q=P^{-1}$ with $Y_c=KQ$ linearizes the controller terms ($Q(A+B_2K)^T = QA^T+Y_c^TB_2^T$), but the multiplier term $QC_z^TYC_zQ$ still contains $Q$ twice and $Y$, $Y^{-1}$ remain coupled; the synthesis problem is an LMI only after the multiplier is fixed or restricted, and otherwise a bilinear matrix inequality solved by iteration (D–K / alternating scalings). Watch for claiming synthesis is a plain LMI in $(P,K,Y)$. | question-ready |
| `<s6>` | 8 | What happens with two independent uncertainty blocks, and does fixing the multiplier restore exactness? | Expected: the single scalar multiplier is conservative; the multiplier must become block-diagonal with the same block structure as $\Delta$ (D-scales), but because the admissible set is now two quadratic constraints the S-procedure has a gap, so even the full multiplier test is only sufficient — a $\mu$-type upper bound, typically improved by iteration. Watch for assuming the block-diagonal multiplier is exact. | question-ready |

Running example: a linear-fractional plant $\dot x = Ax + B_w w$, $z = C_z x$, $w=\Delta z$ with
$\|\Delta\|_2\le 1$, plus a control channel $B_2u$ in sections 5–6; a scalar instance with
$A=\mathrm{diag}(-1,-2)$, $B_w=(1,1)$, $C_z=(0.8,0.8)$ is nominally stable but unstable at
$\delta=1$.

Expected insights are teaching notes only and are not copied into the question-map PDF.

## Current discussion point

Question map published. Next, send `Control/lmi-robust-control/lmi-robust-control.pdf#page=3` and
ask the `<s1>` question.

## Unresolved or research-needed claims

- `<s4>` — the losslessness of the multiplier test for a single full uncertainty block, and the
  gap once there are two or more independent blocks, must be grounded in an authoritative source
  before it is asserted to the reader (Boyd et al., *Linear Matrix Inequalities in System and
  Control Theory*; the S-procedure / $\mu$ literature). Not yet consulted.
- `<s5>` — the precise problem class of robust state-feedback synthesis (LMI once the scaling is
  fixed, BMI otherwise) should be checked against a source before being stated as a result rather
  than asked as a question.
- `<s3>` — the exact commutation requirement for the scaling bound should be confirmed against a
  source if this section is deepened.

## Sources consulted

None yet; the question map makes no external claims.

## Checks

- Build — `typst compile --root . Control/lmi-robust-control/lmi-robust-control.typ Control/lmi-robust-control/lmi-robust-control.pdf` exited 0 with no warnings; PDF page count is 9.
- Structural — no `FILL:` slots; 7 level-1 headings and exactly 6 `#question` boxes; no `#takeaway`, `#intuition`, or `#claim`; no `../` paths; section-to-page map `3,4,5,6,7,8,9`.
- Answer-free — the PDF carries setup, tools (a scalar Young inequality), one figure, and the questions only; no expected insight, worked solution, or conclusion. Each section's setup avoids resolving the previous section's question.
- Rendered — all 9 PDF pages rasterized at 100 dpi and inspected; equations, the figure, captions, and footers are placed and unclipped; the contents page agrees with the section-to-page map.
- Demo — no demo.
- Stage-specific — landing card added in `index.html` for `Control/lmi-robust-control/lmi-robust-control.pdf` with `data-category="control optimization"`; served on `http://localhost:8137/index.html`, the card appears, and its PDF `href` returns HTTP 200.
- Checks not run — none.

## Notes

- The `authors` slot uses the template's shipped slug `Qwen3.8-Flash-Next`; change it if another model owns the note.
- One inline Typst vector figure was added (the uncertainty disk in section 2); no note-local `assets/` directory is used.
- No `refs.bib` and no citations in this source-free first pass.
