# Symplectic Matrices in Control — teaching handoff

Keep this short. It is a handoff, not a transcript and not a prerequisite ledger.

**Stage:** question map

**Artifact:** `Control/symplectic-matrix/symplectic-matrix.typ`, compiled to
`Control/symplectic-matrix/symplectic-matrix.pdf`, + `symplectic-matrix-demo.html`.

## Audience

An engineer new to symplectic matrices, comfortable with basic linear algebra, calculus, and the
idea of a state-space model. No prior exposure to Hamiltonian mechanics, the Riccati equation, or
numerical matrix algorithms is assumed; the note defines each object as it needs it. The LQR
statement is used, not re-derived.

## Route and assessment

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| `<s1>` | 3 | What does $M^TJM=J$ preserve, and what does it force about $M^{-1}$ and $\det M$? | The form $\omega(u,v)=u^TJv$ is preserved, so $M^{-1}=-JM^TJ$ is symplectic and $(\det M)^2=1$ (in fact $\det M=+1$); in $2n$ dimensions it preserves each of the $n$ coordinate-plane areas, not only the total volume. Misconception to watch: that $\det M=1$ characterises symplectic matrices — true only for $n=1$. | question-ready |
| `<s2>` | 4 | Why is a Hamiltonian flow symplectic, and what does damping change? | Differentiating $\Phi_t^TJ\Phi_t$ gives $\Phi_t^T(\nabla^2H\,J^T+J\nabla^2H)\Phi_t$, which vanishes because $\nabla^2H$ is symmetric and $J^T=-J$; so the form is conserved at every $t$. Damping makes the Jacobian no longer $J\times$(symmetric), the flow stops being symplectic, and area contracts as $\det\Phi_t=e^{-ct}$. Misconception: that symplecticity is the same as energy conservation. | question-ready |
| `<s3>` | 5 | Which other eigenvalues must accompany $\lambda$ in a symplectic matrix, and why is that fatal for asymptotic stability? | $M^T=JM^{-1}J^{-1}$ is similar to $M^{-1}$, and $\sigma(M^T)=\sigma(M)$, so $\sigma(M)=\sigma(M^{-1})$: $\lambda,1/\lambda,\bar\lambda,1/\bar\lambda$ all appear. Hence $|\lambda|$ and $1/|\lambda|$ both occur and no symplectic matrix has its whole spectrum inside the unit circle. Misconception: confusing the reciprocal pairs of a symplectic matrix with the $\pm$ pairs of a Hamiltonian matrix. | question-ready |
| `<s4>` | 6 | What structure does the LQR Hamiltonian matrix inherit, and how does it produce the stabilizing Riccati solution? | $(JH)^T=JH$, so $\sigma(H)=-\sigma(H)$ and, with no imaginary-axis eigenvalues, exactly $n$ are in the open LHP and their eigenvectors span an $n$-dimensional invariant subspace. A stacked basis $\begin{bmatrix}X_1\\X_2\end{bmatrix}$ with $X_1$ invertible expands the invariance relation into two block equations whose elimination gives $P=X_2X_1^{-1}$, symmetric, solving the CARE, with $A-GP=X_1\Lambda X_1^{-1}$ stable. Assessment focus: the reader should get the elimination, not just name the subspace. | question-ready |
| `<s5>` | 7 | Why is an ordinary Schur decomposition the wrong tool, and what must the reduction preserve? | An ordinary Schur basis is unitary and knows nothing about $J$; it may interleave stable and unstable eigenvalues and its upper block may be nearly singular although $P$ is well conditioned. A symplectic-orthogonal $U$ with $U^TJU=J$ keeps the form, and the Hamiltonian Schur form (with $T_{22}=-T_{11}^T$) puts the stable subspace in the leading block, so the computed $P$ keeps the symmetry the equation demands. | question-ready |
| `<s6>` | 8 | What happens as the state penalty shrinks to zero? | The LHP and RHP halves of $\sigma(H)$ migrate onto the imaginary axis; at $\epsilon=0$ all four eigenvalues are $\pm i$, the stable subspace is not separated from the unstable one, $X_1$ is singular, and $P=X_2X_1^{-1}$ is undefined. The CARE then has the unique symmetric solution $P=0$, whose closed loop is $A$ itself — only marginally stable — so no stabilizing solution exists. | question-ready |

Running example: a unit mass on a unit spring, $H(q,p)=(q^2+p^2)/2$ and $\dot x=J\nabla H$ in phase
space, then the same oscillator actuated and penalized under an LQR cost with $Q=\epsilon I$, $R=1$.

The `PDF page` column is the deep-link map, refreshed from
`typst eval ... query(heading.where(level: 1))`. Re-run it after any change to headings or prose.

## Current discussion point

The question map is filed and no section has been taught yet. Send `<s1>` first:
`Control/symplectic-matrix/symplectic-matrix.pdf#page=3` with the section-1 question text. The
sidecar demo `Control/symplectic-matrix/symplectic-matrix-demo.html` belongs to `<s2>` (page 4) and
should be named with that message.

## Unresolved or research-needed claims

- `<s4>`/`<s5>` — the stable-invariant-subspace construction for the CARE and the Hamiltonian
  (symplectic) Schur algorithm are used as facts. If the reader asks for grounding, cite the
  primary sources: Laub, *A Schur method for solving algebraic Riccati equations* (1979), and
  Byers, *A Hamiltonian QR algorithm* (1983) / Benner–Mehrmann–Xu on symplectic methods.
- `<s2>`/`<s6>` — the modified-Hamiltonian reading of symplectic integrators is not in the note;
  if needed, Hairer–Lubich–Wanner, *Geometric Numerical Integration*.
- No claim in the document itself needs a citation at this stage.

## Sources consulted

None yet; the question map makes no external claims.

## Checks

- Build — `typst compile --root . Control/symplectic-matrix/symplectic-matrix.typ
  Control/symplectic-matrix/symplectic-matrix.pdf` exited 0 with no warnings; 9 pages.
- Structural — no `FILL:` slots; 6 `#question[` boxes for 7 level-1 headings (6 teaching + Sources);
  no takeaway/intuition/claim blocks; no `"../` paths.
- Answer-free — re-read after the figure fixes: no intuition, takeaway, worked solution, or
  conclusion block; the s4 expected relation $P=X_2X_1^{-1}$ and the s6 outcome are absent from
  the note and live only here.
- Rendered — pages 3–8 rasterized and inspected; each section's heading, question box, figure or
  table, equations, and caption sit correctly, nothing clipped or wider than the text column.
  Figure-placement bug found and fixed: a `circle` placed at `top+left` centres on its own bounding
  box, so the unit circles in `<s2>`/`<s3>` were offset; both now use explicit `dx/dy`. The `<s3>`
  legend and the `<s6>` table header were moved/rewritten to stop overlapping the plot and to drop
  stray quotes.
- Figures and demo — every figure's rendered page inspected. The demo is 115 lines with one inline
  script, no external asset, no `../`; its script parses under `node --check` and its flow-map core
  was driven in Node for `(k,c)` and all three integrators (area ratio 1.000000 for RK4 and
  symplectic Euler at $c=0$, 1.8167 for explicit Euler; 0.0498 / 0.0461 / 0.0864 at $c=0.5$).
- Stage-specific — landing card added and its `href` resolved against the compiled PDF; the note's
  own numbers re-checked against `scripts/verify_symplectic.py`.
- Could not run — no browser is on `PATH` here, so the demo was parse-checked and its numerics
  exercised in Node but **not rendered**; open
  `http://localhost:8000/Control/symplectic-matrix/symplectic-matrix-demo.html` to confirm the
  canvas, and move each control.

## Notes

- No deviation from `typst-template/note.typ` or the 'Ilm defaults; no extra 'Ilm option was
  needed.
- The demo carries three controls (two sliders and an integrator `select`) and one monospace
  readout, inside the ceiling.
- `Control/sda-algebraic-riccati/` already treats the doubling side of the Riccati equation; this
  note deliberately stays on the symplectic/Hamiltonian structure and does not repeat it. A
  relative link between the two PDFs would need `../`, which the note contract forbids, so no
  cross-link is placed.
