# The Pencil Behind the Riccati Equation — teaching handoff

**Stage:** question map (revised — visual-first per section, answer leaks removed)

**Artifact:** `Algebra/qz-riccati/qz-riccati.typ`, compiled to
`Algebra/qz-riccati/qz-riccati.pdf`. No sidecar demo: no section's question becomes attemptable only
by moving a parameter, so the setup is carried by figures and tables instead.

## Audience

An engineer comfortable with state-space linear systems, the LQR statement, matrix products and
inverses, and eigenvalues. No prior exposure to matrix pencils, deflating subspaces, or the
generalized Schur form is assumed: section 2 introduces the pencil only as far as the question
needs, and section 4 defines the QZ factorization before asking what a run returns. The note does
not re-derive either Riccati equation from the cost functional; it states the LQR result and uses
it. The continuous and discrete equations are carried side by side against one two-state plant, so
the running example is the same object in both domains.

Revise this as answers arrive: a reader who lacks a prerequisite (what a deflating subspace is, why
the gain is read off the stabilizing solution) gets a short backfill question or a new backfill
section, not a narrower question on the same idea.

## Route and assessment

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| `<s1>` | 3 | Which of the two exact symmetric solutions is the LQR gain, and why is a quadratic matrix equation not in tension with a convex cost in `u`? | The stabilizing solution — the one whose closed loop has every multiplier in the open left half-plane (or open unit disk) — is the controller; the other solution makes the closed loop unstable. The cost is convex in the control `u`, while the algebraic Riccati equation is a nonlinear system in `P`; convexity of the control problem does not make the matrix equation's solution set a singleton, and the selection is by the closed-loop spectrum. | question-ready |
| `<s2>` | 4 | What invariance makes the graph of `P` an invariant (deflating) subspace exactly when `P` solves the equation, and what do the two spectral symmetries leave free? | `H[I;P] = [I;P](A-GP)` (graph invariant for `H`) holds exactly when `P` solves CARE; `L[I;P] = N[I;P]A_cl` (graph deflating for the pair) holds exactly when `P` solves DARE. Hamiltonian symmetry gives `z <-> -z` in `det(zI-H)` (only even powers); symplectic symmetry makes `det(zN-L)` self-reciprocal, giving `mu <-> 1/mu`. A solver may choose the stable half, but only a deflating subspace closed under the pairing, not an arbitrary `n`-subset. | question-ready |
| `<s3>` | 5 | Which multiplier has a non-invertible state block, and what must replace a plain eigenvalue list when `N` is singular? | Continuous `+1/2` and discrete `-2` carry a zero state block, so any selection containing them (or containing both partners of one mode) is not a graph: four of six selections fail. When `N` is singular, `N^{-1}L` throws away the infinite multiplier; the pair `(alpha, beta)` must be carried so `beta = 0` still represents it. The deflating subspace stays defined even when `V_2 V_1^{-1}` does not. | question-ready |
| `<s4>` | 6 | What does a QZ run return on the discrete pencil before any stability decision, and how does "keep the multipliers inside the unit circle" become a statement about columns of `Z`? | It returns orthogonal `Q, Z`, quasi-upper-triangular `S` (1x1/2x2 diagonal blocks) and upper-triangular `T`, plus the generalized eigenvalues of the diagonal blocks — and no selection. None of those objects is the answer to DARE by itself. The selection is a deflating subspace spanned by leading columns of `Z` after reordering the diagonal blocks; complex-conjugate pairs form one 2x2 block and cannot be split, so the statement must keep them together. | question-ready |
| `<s5>` | 7 | What does a sweep preserve, why can the shift not be read off `S` alone or `T` alone, and which entry must vanish for each of the two deflations? | Each sweep is a pair of orthogonal transformations applied to `(S,T)`, preserving the generalized eigenvalues and the sparsity patterns (`S` Hessenberg, `T` triangular) while driving one subdiagonal entry toward zero. The shift comes from the trailing 2x2 sub-pencil, a generalized eigenvalue of `(S,T)`, so it depends on both matrices. For `-2` (finite) the subdiagonal entry `s_{43}` must vanish; for the unnamed infinite multiplier the diagonal entry `t_{44}` must vanish (`beta = 0`). | question-ready |
| `<s6>` | 8 | Which stage dominates the arithmetic, which decides the digits in `P`, and what does the pencil route give up against the two foils? | The reduction/sweep stages dominate the count, `O(n^3)` on the `2n`-by-`2n` pair; the digits in `P` are decided by the extraction stage, through the conditioning/separation of the selected deflating subspace (how far the selected half sits from the other half), not by the flop count. They differ because cost is an arithmetic count while digit loss is a conditioning property. Against the two foils, the pencil route gives up staying `n`-by-`n`; the fixed-point recursion keeps `n`-by-`n` work and the doubling route keeps quadratic convergence, while the pencil route keeps backward stability and handles singular `N`/infinite multipliers uniformly. | question-ready |
| `<s7>` | 9 | Sort the five one-input changes and name the quantity that decides each verdict. | The separation of the selected half from the rest (the gap across the split) decides each verdict. (a) `G = 0` leaves no stabilizing answer: the stabilizing selection is not a graph. (b) `Q_c = diag(0,1)` leaves a graph solution that is not the LQR gain (gain `(0,0)`, unstable closed loop) beside the stabilizing one. (c) `A = diag(2,0)` makes `N` singular and introduces an infinite multiplier, which the pencil handles without a special case — the decomposition shrugs it off. (d) negative penalty shrinks the separation, so the returned `P` loses accuracy; (d-limit) puts a multiplier on the imaginary axis, the gap closes, and no stabilizing answer remains. | question-ready |
| Sources | 10 | Sources and further reading | n/a — no external sources consulted yet. | n/a |

`question-ready` = sent, awaiting an attempt; `deepened` = a follow-up, hint, research, or demo was
added; `closed` = the reader named the mechanism *and* applied it to the running example; `skipped`
= bypassed without demonstration and still eligible for a retrieval check. A `partial` answer is not
a resting state — keep the section open until it closes or is skipped.

Running example in one sentence: the two-state plant `A = diag(2, -1/2)`, `B = [3;0]`, `R = 1`,
`G = B R^{-1} B' = diag(9,0)`, with continuous weighting `Q_c = diag(5,1)` and discrete weighting
`Q_d = diag(3/5, 3/4)`; its CARE has the two symmetric solutions `P = I` (stabilizing, gain
`(3,0)`, closed loop `(-7,-1/2)`) and `P = diag(-5/9, 1)` (gain `(-5/3,0)`, closed loop
`(7,-1/2)`), and its DARE has the two solutions `P = I` (stabilizing, gain `(3/5,0)`, closed loop
`(1/5,-1/2)`) and `P = diag(-1/15, 1)` (gain `(-1,0)`, closed loop `(5,-1/2)`). All numbers are
exact rationals reproduced by `scripts/verify_qz_are.py`. The expected answers above are teaching
notes and are not copied into the document.

## Observed misconceptions

- None observed yet — nothing has been taught.

## Retrieval and transfer

- Planned (scheduled, not yet run): after `<s4>`, return to `<s1>` and ask which of the two solutions
  a chosen deflating subspace is preserving, and how the reader knows it is the controller's one.
- Planned transfer check after `<s5>`: ask what changes when the trailing 2x2 block has a complex
  conjugate pair rather than two real multipliers, and which deflation test then applies.

## Current discussion point

Nothing taught yet — this is the first handoff of the revised map. Entry point is
`qz-riccati.pdf#page=3` (`<s1>`): *which of the two exact symmetric solutions is the LQR gain, and
why is a quadratic matrix equation not in tension with a convex cost in `u`?* To resume: resend this
page link and question, and skip every `closed` section (none yet).

## Unresolved or research-needed claims

- `<s2>` — the invariance/deflating equivalences are shown on the running example; the general
  Hamiltonian/symplectic symmetry statements and the spectral-pairing facts are standard and are to
  be grounded in a numerical-linear-algebra source if the reader asks for a proof.
- `<s4>` — the QZ form and the block reordering statement rest on the generalized Schur
  decomposition theory (Golub–Van Loan; Stewart); the note poses them as definitions and questions,
  so a citation is needed only if deepened.
- `<s5>` — the shifted-QZ sweep, the shift from the trailing sub-pencil, and the deflation criteria
  are standard algorithm facts; ground in Golub–Van Loan or the LAPACK `dgges` documentation before
  presenting them as a proof.
- `<s6>` — the `O(n^3)` stage count and the conditioning-driven accuracy of `P` are stated at the
  level of the running example; ground the general flop count and backward-error statement if asked.
- `<s7>` — the five changed cases are exact results of `scripts/verify_qz_are.py`, not of an
  external source.

## Sources consulted

None yet; the question map makes no external claims.

## Checks

- build — `typst compile --root . Algebra/qz-riccati/qz-riccati.typ
  Algebra/qz-riccati/qz-riccati.pdf` exited 0 with no warnings; 10 pages (cover, contents, seven
  sections, Sources).
- structural — no `FILL:` slots; 7 teaching level-1 headings and 7 `#question` boxes; note-local
  paths only, no `../`; section-to-page map `3,4,5,6,7,8,9,10` read from the rendered contents page.
- visual-first — every teaching section now leads with a figure or table: Table 1 (`<s1>`), Figure 1
  (`<s2>`), Table 2 (`<s3>`), Figure 2 (`<s4>`), Figure 3 (`<s5>`), Figure 4 (`<s6>`), Table 3
  (`<s7>`).
- answer-free — no `#takeaway`/`#intuition`/`#claim` block. The three leaks present in the previous
  revision were removed: the "take the stable half as the selected set" sentence and the gap
  measurements in `<s6>`; the enumeration of which selections are graphs in `<s3>`; and the
  "section 6's gap numbers move with the rows" sentence and the `split distance 2/5` cell in
  `<s7>`. The stabilizing-selection rule, the invariance mechanism, the QZ return value, the
  shift/deflation criteria, the cost/accuracy split, and the five-row verdicts are not stated as
  conclusions.
- rendered — all pages 3–10 rasterized and inspected: question boxes, numbered equations, the four
  figures and the three tables are placed; nothing clipped or wider than the text column; the
  earlier two-line orphan page and orphaned table caption were fixed by tightening the `<s2>` figure
  and dropping the redundant changed-plant table.
- script — `python3 Algebra/qz-riccati/scripts/verify_qz_are.py` exits 0 and reproduces the exact
  residuals, characteristic polynomials, per-mode multipliers, per-selection gains, six-selection
  tables, gap measurements, and the five changed cases. The script gained the per-selection gain
  column that Table 1 now prints.
- demo — none filed: no question is attemptable only by moving a parameter.
- checks that could not run — none.

## Notes

- Revision of an existing Typst question map in place. Changes from the prior revision: author
  corrected to the writing agent (`Amp`); a leading figure/table added to `<s1>`, `<s2>`, `<s3>`,
  `<s6>`; the `<s4>` and `<s5>` figures moved ahead of their prose; answer-revealing sentences
  removed. No `refs.bib` yet, so the `bibliography:` line stays commented.
