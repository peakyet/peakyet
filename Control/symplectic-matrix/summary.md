# Symplectic Matrices in Control — teaching handoff

Keep this short. It is a handoff, not a transcript and not a prerequisite ledger.

**Stage:** complete explanation (converted from the earlier question map on request; all
former "expected insights" are now derived in the note itself).

**Artifact:** `Control/symplectic-matrix/symplectic-matrix.typ`, compiled to
`Control/symplectic-matrix/symplectic-matrix.pdf`, + `symplectic-matrix-demo.html`.

## Audience

An engineer new to symplectic matrices, comfortable with basic linear algebra, calculus, and the
idea of a state-space model. No prior exposure to Hamiltonian mechanics, the Riccati equation, or
numerical matrix algorithms is assumed; the note defines each object as it needs it. The LQR
statement is used, not re-derived.

## Route and assessment

| Section | PDF page | What it establishes | Key derivation the reader can follow |
|---|---|---|---|
| `<s1>` | 3 | What $M^TJM=J$ preserves and forces | $\omega(u,v)=u_qv_p-u_pv_q$ is signed parallelogram area; shear passes, squeeze's defect = its area error; $M^{-1}=-JM^TJ$; $\det M=+1$ (connectedness argument); in $2n$ dimensions $n(2n-1)$ scalar conditions, not just volume. Check: scaling map is $2J$, not symplectic. |
| `<s2>` | 5 | Why Hamiltonian flow is symplectic, damping is not | $\dot F=\Phi_t^T(A^TJ+JA)\Phi_t$; with $A=JS$, $S$ symmetric, the bracket is $S+(-S)=0$. Damped bracket $A_c^TJ+JA_c=cJ\neq0$; area contracts as $e^{-ct}$. Check: not symplectic at *any* $t>0$. |
| `<s3>` | 7 | The spectrum rigidity | $M^{-1}=-JM^TJ=JM^TJ^{-1}$ chains into $\sigma(M)=\sigma(M^{-1})$; quartet $\lambda,1/\lambda,\bar\lambda,1/\bar\lambda$; no asymptotic stability. Check: $\lambda=0.5+0.5i$ forces $1\pm i$ partners. |
| `<s4>` | 9 | Hamiltonian matrix → Riccati solution | $JH=\begin{pmatrix}-Q&-A^T\\-A&G\end{pmatrix}$ symmetric; $\sigma(H)=-\sigma(H)$; block equations from $HX=X\Lambda$; $A-GP=X_1\Lambda X_1^{-1}$; eliminating $X_1$ gives the CARE; $u^TJ Hv$ argument gives $X^TJX=0$, hence $P=P^T$. Check: arbitrary subspace fails. |
| `<s5>` | 12 | What a reduction must preserve | Two demands: eigenvalue separation and preservation of the $J$-structure; Hamiltonian Schur form $T_{22}=-T_{11}^T$ writes the spectral symmetry into the shape. Check: wrong ordering yields the *antistabilizing* solution. |
| `<s6>` | 14 | When an eigenvalue lands on the imaginary axis | $\epsilon\to0$: LHP pair slides to $\pm i$, $P\to0$, closed loop $A$ marginally stable; $X_1$ loses invertibility; stabilizing solution exists iff no imaginary-axis eigenvalues. Check: real part scales linearly with $\epsilon$. |

Running example throughout: a unit mass on a unit spring, $H(q,p)=(q^2+p^2)/2$ and
$\dot x=J\nabla H$ in phase space, then the same oscillator actuated and penalized under an LQR
cost with $Q=\epsilon I$, $R=1$.

The `PDF page` column is the deep-link map, refreshed from
`typst eval ... query(heading.where(level: 1))`. Re-run it after any change to headings or prose.

## Sources consulted

- V. I. Arnold, *Mathematical Methods of Classical Mechanics* — symplectic group and
  Hamiltonian flow background (general; no specific claim cited to a page).
- The `<s4>`/`<s5>` construction follows Laub, *A Schur method for solving algebraic Riccati
  equations* (1979), with the structure-preserving descent via Byers, *A Hamiltonian QR
  algorithm* (1983), and Benner–Mehrmann on symplectic methods. Cited in the note's Sources
  section as provenance, not as load-bearing derivations — the derivations are done in the note.
- `refs.b`** not yet created: if a later revision needs page-level grounding, add it then.

## Checks

- Build — `typst compile --root . Control/symplectic-matrix/symplectic-matrix.typ
  Control/symplectic-matrix/symplectic-matrix.pdf` exited 0 with no warnings; 16 pages.
- Structural — no `FILL:` slots, no `"../` paths; 6 sections + Sources; all `#check` answers
  visible below their prompts.
- Numbers — all quoted values re-verified against `scripts/verify_symplectic.py` (defects
  0 / 0 / 0.04; $\Phi_1$ rotation and $\det=1$; $e^{-0.5}=0.6065$; $P(1)=\begin{pmatrix}1.9123&0.4142\\0.4142&1.3522\end{pmatrix}$;
  char. poly $x^4+x^2+2$; quartet products $=1$; $\epsilon$ migration table).
- Rendered — pages 3–16 rasterized and inspected during revision. Fixed during review: a leftover
  placeholder in the $\dot F$ derivation, a broken $(JH)^T$ display (now a proper numbered
  equation), an "H = J·op(JH)" slip (now $H=-J(JH)$), a wrong "quarter-turn" caption (flow at
  $t=1$ is one radian), and a check answer that called the RHP pair "stable."
- Demo — unchanged from the previous revision; parse-checked previously, not re-rendered here
  (no browser on PATH; see prior summary notes).
- Could not run — no fresh browser render of the demo this session.

## Notes

- No deviation from `typst-template/note.typ` or the 'Ilm defaults.
- The demo belongs to `<s2>` (page 5); the note names it there.
- The note still does not develop the doubling side of the Riccati story; that lives in the
  separate `sda-riccati` note.
