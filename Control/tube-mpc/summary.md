# Tube MPC — teaching handoff

**Stage:** question map

**Artifact:** `Control/tube-mpc/tube-mpc.typ`, compiled to `Control/tube-mpc/tube-mpc.pdf`.

## Audience

Assumes an engineer new to tube MPC, comfortable with basic algebra and calculus, matrix algebra,
discrete-time linear systems, and the idea of a Lyapunov function. No prerequisite interview was
used. Familiarity with nominal MPC is helpful but not assumed; the first question re-establishes
the setting from the plant.

## Route and assessment

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| `<s1>` | 3 | Does a nominal plan guarantee the real trajectory satisfies the constraints, and does the disturbance bound alone bound what must be bounded? | Expected: no guarantee. The deviation $e_k=x_k-z_k=\sum_{i=0}^{k-1}A^{k-1-i}w_i$ accumulates, and here $A$ has a repeated eigenvalue at 1, so $A^i$ grows linearly and the position error grows like $k^2$ in the worst case. What must be bounded is the *set* the deviation lies in, not the disturbance magnitude; a small $w$-bound does not make the deviation small. Watch for "a small bound is safe", "check constraints at the worst case per step", or treating each step independently. | question-ready |
| `<s2>` | 4 | What must a bounded set $\mathcal Z$ satisfy so that $e_k\in\mathcal Z\Rightarrow e_{k+1}\in\mathcal Z$ for every admissible $w$, and why is $A+BK$ Schur not enough? | Expected: robust positive invariance, $(A+BK)\mathcal Z\oplus\mathcal W\subseteq\mathcal Z$; the natural object is the minimal such set, the closure of $\bigoplus_{i\ge0}(A+BK)^i\mathcal W$. Schur means $e_k\to0$ only when $w\equiv0$; with a persistent bounded $w$ the error converges to a bounded set, and Schur does not make an arbitrary candidate set invariant. Watch for "stable closed loop ⇒ error stays bounded ⇒ done" and for taking $\mathcal Z=\mathcal W$. | question-ready |
| `<s3>` | 5 | What must $z_k,v_k$ satisfy so constraints hold for every $e_k\in\mathcal Z$, and why not a scalar margin? | Expected: the Pontryagin difference, $z_k\in\mathcal X\ominus\mathcal Z=\{z:z\oplus\mathcal Z\subseteq\mathcal X\}$ and $v_k\in\mathcal U\ominus K\mathcal Z$, because $u_k=v_k+Ke_k$ with $e_k\in\mathcal Z$. These are exact, whereas one scalar margin is either conservative or unsafe once $\mathcal Z$ is anisotropic (a polytope, so $K\mathcal Z$'s width is set by the corners, not the "radius"). Watch for shrinking by $\|w\|_\infty$ or by a ball of the disturbance radius. | question-ready |
| `<s4>` | 6 | Which shifted plan is a candidate at $k+1$, what must $\mathcal X_f$ satisfy, and why does the disturbance not break the argument? | Expected: the shifted plan $(z_{1|k},\dots,z_{N|k})$ extended by the terminal law $u=K_fz$; $\mathcal X_f$ must lie in the tightened constraints and be positively invariant under the nominal closed loop with $K_f$, so the tail stays feasible. Feasibility persists because the nominal successor $z_{1|k}$ is already inside the tightened set and $e_1=(A+BK)e_0+w_0\in\mathcal Z$, so the realized $x_1$ satisfies the constraints. Watch for "no terminal set is needed" and for missing the invariance requirement on $\mathcal X_f$. | question-ready |
| `<s5>` | 7 | What sets the tube size, which two quantities move in opposite directions, and what does a simpler shape cost? | Expected: a larger $K$ makes $A+BK$ more contractive (smaller $\mathcal Z$) but enlarges $K\mathcal Z$ (more input tightening), while a larger $\mathcal Z$ tightens the state constraint; the two tightenings pull against each other. The smallest feasible $\mathcal Z$ is the minimal invariant set, an infinite Minkowski sum that is hard to compute exactly, so one uses an outer approximation (few-facet polytope, ellipsoid), paying conservatism for tractability. Watch for "take the minimal set for free" and "a bigger gain is always better". | question-ready |
| `<s6>` | 8 | With $\mathcal Z_k=\alpha_k\mathcal Z$, what must be added for invariance, and what makes a free $\mathcal Z_k$ nonconvex? | Expected: invariance becomes a constraint on the scalars, $\alpha_{k+1}\ge$ (contraction factor from $(A+BK)$ and $\mathcal Z$) $\cdot\,\alpha_k +$ (a constant from $\mathcal W$), which is affine in $\alpha$ and keeps the problem convex; letting each $\mathcal Z_k$ be free makes the support-function form $h_{\mathcal Z_{k+1}}(d)\ge h_{(A+BK)\mathcal Z_k}(d)+h_{\mathcal W}(d)$ bilinear in the decision variables, hence nonconvex. Watch for "just add $\mathcal Z_k$ as variables" without noticing the nonconvexity, or for a claim that the general variable tube is still an LMI. | question-ready |

Running example: the discrete-time double integrator $x_{k+1}=Ax_k+Bu_k+w_k$ with
$A=\begin{smallmatrix}1&1\\0&1\end{smallmatrix}$, $B=(0.5,1)^T$, $\|w\|_\infty\le0.1$,
$\|x\|_\infty\le5$, $|u|\le1$; the ancillary gain is $K=(-0.5,-1.2)$, for which $A+BK$ has
eigenvalues $\approx0.435$ and $\approx0.115$.

Expected insights are teaching notes only and are not copied into the question-map PDF.

## Current discussion point

Question map published. Next, send `Control/tube-mpc/tube-mpc.pdf#page=3` and ask the `<s1>`
question.

## Unresolved or research-needed claims

- `<s1>` — the running example's worst-case error growth (position error like $k^2$ from the
  repeated eigenvalue at 1) should be checked with one small script before it is stated to the
  reader as a number rather than used only as motivation.
- `<s4>` — the recursive-feasibility and terminal-set argument should be grounded in an
  authoritative source before it is asserted as a theorem (Mayne, Seron & Raković, *Robust model
  predictive control of constrained linear systems with bounded disturbances*, Automatica 2005;
  or Rawlings, Mayne & Diehl, *Model Predictive Control*). Not yet consulted.
- `<s2>`,`<s5>` — the minimal robust positively invariant set as the closure of
  $\bigoplus_{i\ge0}(A+BK)^i\mathcal W$, and the standard outer-approximation schemes (Rakovic et
  al.), should be confirmed against a source before being stated as a result.
- `<s6>` — the homothetic/variable-tube formulation and its convexity property should be checked
  against a source (Raković, Kouvaritakis & Cannon and related) before it is stated.

## Sources consulted

None yet; the question map makes no external claims.

## Checks

- Build — `typst compile --root . Control/tube-mpc/tube-mpc.typ Control/tube-mpc/tube-mpc.pdf`
  exited 0 with no warnings; PDF page count is 9.
- Structural — no `FILL:` slots; 7 level-1 headings and exactly 6 `#question` boxes; no
  `#takeaway`, `#intuition`, or `#claim`; no `../` paths; section-to-page map `3,4,5,6,7,8,9`,
  matching the contents page.
- Answer-free — the PDF carries the running example, facts, notation, three figures, and the
  questions only; no expected insight, worked solution, or conclusion.
- Rendered — all nine PDF pages rasterized and inspected; headings, callouts, numbered equations,
  the three vector figures, captions, and footers are placed and unclipped; the three figures were
  re-rendered after label fixes (the `p` axis label, both `X` and both `tightened` boundary labels,
  and the $\zeta$ dimension marking a tube half-width).
- Demo — no demo.
- Stage-specific — landing card added in `index.html` for `Control/tube-mpc/tube-mpc.pdf` with
  `data-category="control optimization"`; `href` resolves to the committed PDF.
- Checks not run — no browser available here, so the landing page's card rendering and filters
  were not opened; the card structure was matched to the neighbouring `lmi-robust-control` card.

## Notes

- The `authors` slot keeps the template's shipped slug `Qwen3.8-Flash-Next`; change it if another
  model owns the note.
- Three inline Typst vector figures were added (the invariance schematic in section 2, the 1D
  constraint-tightening slice in section 3, the two-tube contrast in section 5); no note-local
  `assets/` directory is used.
- No `refs.bib` and no citations in this source-free first pass.
