# Lie Groups for State Estimation in Robotics — teaching handoff

Keep this short. It is a handoff, not a transcript and not a prerequisite ledger.

**Stage:** question map

**Artifact:** `Robotics/lie-groups-state-estimation/lie-groups-state-estimation.typ`, compiled to
`Robotics/lie-groups-state-estimation/lie-groups-state-estimation.pdf` (12 pages). No sidecar demo.

## Audience

An engineer new to Lie theory but comfortable with basic linear algebra and calculus — matrices,
orthogonality, derivatives, Gaussians. Calibrated to someone who has met a Kalman filter and a
rotation matrix but has not seen a manifold treatment of them.

## Route and assessment

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| `<s1>` | 3 | Which vector operations fail on a heading, and what does `RᵀR = I` do to the set? | The set of rotations is a curved manifold, not a vector space: a weighted average/chord midpoint leaves the circle, and `R + δR` violates the constraint. The constraint is what curves the set. Misconception: componentwise averaging of angles or treating a rotation matrix as a 9-vector. | question-ready |
| `<s2>` | 4 | Why is the family of velocities a vector space when the group is not, and what is one element? | Differentiating `RᵀR = I` forces `ṘRᵀ` skew-symmetric; skew matrices are closed under `+` and scalar multiples, so the tangent space at the identity (Lie algebra) is a genuine vector space — first order is linear though the group is not. An element is the angular velocity. Misconception: that the group is globally linear. | question-ready |
| `<s3>` | 5 | Why does `exp` land on the group for every `t`, and where does a tangent vector of length π go? | `exp` of a skew matrix stays orthogonal because `exp(A)ᵀ = exp(Aᵀ) = exp(−A) = exp(A)⁻¹`; the series preserves the constraint, unlike `R + δR`. Length π is a half turn (the antipode). Misconception: that `exp` is just a reparametrized additive update, or that it is injective. | question-ready |
| `<s4>` | 6 | Why do `⊕`/`⊖` play the roles of `+`/`−`, and why must residuals live in the tangent space? | `X ⊕ τ = X·Exp(τ)` and `Y ⊖ X = Log(X⁻¹Y)` give the manifold a local vector-space structure; a small `τ` behaves like a vector because `Exp` is a local diffeomorphism with differential `I` at `0`. Innovation and correction are tangent vectors, hence ordinary. Misconception: that `⊖` is a matrix difference. | question-ready |
| `<s5>` | 7 | Why must an adjoint exist, and why does an estimator need it? | The adjoint `Ad_X` (linearization of conjugation `Y ↦ XYX⁻¹`) exists because the group is non-commutative, so a local increment at `X` and one at the identity differ. Needed to compose motions in different frames and to move covariances body↔world. Misconception: that body and world increments are equal (true only for planar rotations). | question-ready |
| `<s6>` | 8 | Why is the manifold Jacobian a matrix, what does it map, and why a chain rule? | The right Jacobian maps tangent vectors (vector spaces) to tangent vectors, so it is an ordinary `n×m` matrix; the chain rule composes them, and a few elementary blocks (exp, log, inverse, composition, action) generate all others. Misconception: applying the ordinary chain rule without the manifold Jacobian. | question-ready |
| `<s7>` | 9 | Where must a mean and covariance live, and how does a nonlinear map propagate it? | The mean is a group element and the covariance lives in the tangent space at the mean (local) or identity (global); propagation is `Σ_Y ≈ J Σ_X Jᵀ`. Misconception: placing covariance on group elements, where `X − X̄` is undefined. | question-ready |
| `<s8>` | 10 | What do the ESKF steps become, and why does the innovation stay a vector? | Replace `+`/`−` by `⊕`/`⊖` and use manifold Jacobians; the gain `K = PHᵀ(HPHᵀ+N)⁻¹` keeps its form, and the innovation is a tangent vector hence ordinary. Misconception: that the Kalman gain itself changes. | question-ready |
| `<s9>` | 11 | What do `⊕`/`⊖` do to a pose-plus-bias state, and what does the Jacobian become? | A composite manifold acts block by block; the Jacobian gains columns for the extra block; the estimator works because the blocks are independent. Misconception: treating the composite as a single group. | question-ready |

The running example: a wheeled robot in a plane estimating its pose `M ∈ SE(2)` (orientation
`R ∈ SO(2)`, position `t ∈ ℝ²`) from range-bearing measurements to known beacons; the 3D case
(`SO(3)`, `SE(3)`) is the same construction.

Keep expected insights here as teaching notes. Do not copy them into the question map.

## Current discussion point

Not started. Send `<s1>` next: page 3, question "The estimator needs three ordinary vector
operations on the robot's heading…".

## Unresolved or research-needed claims

- `<s3>`/`<s6>` — the closed forms of `Log(R)` and of the right Jacobian `J_r`, and the exact
  singular angles: the matrix `Log` closed form is `0/0` at `θ = π`; `J_r` is singular at `θ = 2π`
  (its determinant is `2(1 − cos θ)/θ²`). These are stated only qualitatively in the note; verify
  the exact statements against the paper's Appendix B (eqs. 135, 143–146) before deepening `<s3>`
  or `<s6>`.
- `<s2>` — that the Lie bracket is deliberately omitted (the paper makes the same choice); confirm
  if a reader asks about it.

## Sources consulted

| Source and passage read | Grounds |
|---|---|
| J. Solà, J. Deray, D. Atchuthan, *A micro Lie theory for state estimation in robotics*, arXiv:1812.01537 (v9, 8 Dec 2021) — the whole paper, read for scope and notation: §II (groups, tangent space, exp/log, ⊕/⊖, adjoint), §III (Jacobians, chain rule, blocks), §IV (composite manifolds), §V (ESKF, SAM, self-calibration), Appendices A–E (formulas). | The selection of material, the running example (2D localization with beacons), and the notation (`⊕`, `⊖`, `Exp`/`Log`, `Ad`). No claim in the note is attributed to it; the note itself makes no external claims. |

No other external source has been consulted. The note's Sources section names this paper as the
source of its selection of material.

## Checks

- build — `typst compile --root . Robotics/lie-groups-state-estimation/lie-groups-state-estimation.typ
  Robotics/lie-groups-state-estimation/lie-groups-state-estimation.pdf` exited 0 with no warnings;
  12 pages.
- structural — no `FILL:` slots; 10 level-1 headings, 9 `#question` boxes (Sources has none); no
  answer-revealing box; no `../` paths; section-to-page map `3,4,5,6,7,8,9,10,11,12` refreshed and
  matched against the contents page (checked a page other than the first: `<s5>` → page 7).
- answer-free — no intuition, takeaway, claim, worked solution, or conclusion in the note.
- rendered — all 12 pages rasterized and inspected: cover and contents correct; equations, the two
  figures (s1 chord, s3 tangent/exp), captions, and footers placed; nothing clipped or wider than
  the text column. `bar(X)` was found rendering as `|X|` and replaced with `overline(X)`.
- demo — no demo.
- stage-specific — landing card added to `index.html` in the Robotics group
  (`Robotics/lie-groups-state-estimation/lie-groups-state-estimation.pdf`, `data-category="robotics
  math"`); `href` resolves to the committed PDF. Not re-rendered in a browser (none on PATH here).
- checks that could not run — none besides the browser render of the landing page.

## Notes

- Intentional deviations: none from `note.typ`; the 'Ilm defaults (A4, 12pt, no bibliography
  rendered) are kept. The note is filed under `Robotics` while the existing legacy HTML note on the
  same paper lives under `Mathematics`; the two coexist by decision, the HTML page keeping its own
  renderer and class names (never converted).
- Model slug on the cover: `deepseek-v4.1-flash`.
