# Generalized Eigenvalues and the QZ Algorithm — production summary

**Stage:** complete (full draft delivered). The topic was requested directly, so the
hardest-bridge sample and the full note were produced in one pass: the sample is filed in
`.amp/in/artifacts/qz-bridge-sample.pdf` (source `.typ` beside it) and no reader feedback has
arrived yet. Comprehension is therefore **unassessed**.

**Artifact:** `Algebra/qz-algorithm/qz-algorithm.typ`, compiled to
`Algebra/qz-algorithm/qz-algorithm.pdf` (17 pages); `Algebra/qz-algorithm/refs.bib`;
`Algebra/qz-algorithm/scripts/verify_qz.m` and `Algebra/qz-algorithm/scripts/qz_sweeps.m`
(Octave, standard library only); no demo. Cross-references in the prose point at
`Control/qz-riccati/qz-riccati.pdf`, `Control/symplectic-matrix/symplectic-matrix.pdf` and
`Control/sda-riccati/sda-riccati.pdf` as repository paths in monospace.

**Scope:** the general, dense generalized eigenvalue problem — the pencil `A - lambda B`, the
pair `(alpha, beta)` and the generalized Schur (QZ) decomposition, the Hessenberg-triangular
reduction, the implicit shift and bulge chase, deflation and infinite eigenvalues, and how to
read a library's output. Not attempted: structure-preserving methods for Hamiltonian/symplectic
pencils (named and cross-linked), large sparse problems, singular pencils, and error estimation.

**Assumed background:** matrices, eigenvalues and eigenvectors, unitary/orthogonal
transformations, the QR algorithm in outline, and floating-point rounding. No prior exposure to
pencils, deflating subspaces, or QZ.

**Running example:** a `3 x 3` pencil `A - lambda B_delta` with a complex pair `{i, -i}` and a
third eigenvalue `1/delta`, built by hiding a chosen triangular pencil behind a rotation, so the
exact spectrum `{i, -i, 1/delta}` is known for every `delta` and each algorithm step can be
measured against it. As `delta` shrinks the finite pair stays well-conditioned while `B` becomes
ill-conditioned, and at `delta = 0` the third eigenvalue is infinite.

## Explanation progression

| Section | PDF page | Obstacle addressed | Picture or construction | Essential result explained |
|---|---|---|---|---|
| s1 | 3 | "An eigenvalue is a number of one matrix" | Figure 1 (the spectrum as `delta` falls: `±i` fixed, `1/delta` running to infinity) and the closed form `det(S0 - lambda T0) = (lambda^2+1)(1-delta lambda)` | A generalized eigenvalue belongs to the pair; the example's dense `(A, B)` is the coupling-free pencil under an orthogonal change of coordinates, so the answer is known exactly |
| s2 | 5 | "Why not just form `B^-1 A`?" | Table 1 (the singular endpoint), Table 2 and Figure 2 (the accuracy gap on the finite pair), the "pair, not the ratio" argument | `B^-1 A` needs an inverse that may not exist and perturbs the wrong matrix: the finite pair's error grows like `eps/delta` while the pencil route stays at machine precision; the large eigenvalue is genuinely ill-conditioned in both; the pair outlives the ratio's overflow (LAPACK convention) |
| s3 | 7 | New representation: an eigenvalue as a pair, both matrices triangular | Figure 3 (the factorization and the 2x2-block alternative) and the computed pairs `(1,0.5)->2`, `(i,1)->i`, `(-i,1)->-i` | `Q*AZ=S`, `Q*BZ=T` triangular; `det(A-lambda B)=c prod(S_ii - lambda T_ii)`; finite `alpha/beta`, infinite at `beta=0`; a real driver returns a 2x2 block, whose diagonal is *not* the eigenvalues |
| s4 | 9 | The paired rotation: a left rotation that cleans `A` spoils `B` | Figure 4 (the phase-two matrices with the navy zero created in `A` and the rose fill it causes in `B`, then repaired) and the recorded rotation sequence | Phase 1 (QR of `B`) then phase 2 (Hessenbergize `A`); every left rotation fills exactly one entry of `B` below its diagonal and the paired right rotation clears it, acting on columns the left rotation never touched |
| s5 | 11 | The iteration is opaque; and is a two-sided step even legitimate? | Figure 5 (the real double-shift bulge chase on `H` and `T`, alternating), Table 3 (one sweep's moving magnitudes), equation (16) | A shift from the trailing 2x2 pencil (taken through `T^-1`, so the vector is the first column of `(M - s1 I)(M - s2 I)`, `M = H T^-1`) hands a 3-wide bulge to the same paired rotations; when a subdiagonal vanishes the problem deflates; a zero diagonal of `T` is an infinite eigenvalue; `Q^T M Q = S P^-1` shows the two-sided step is the implicit Q theorem on the pencil; the script's single-shift variant converges in 7 sweeps |
| s6 | 14 | "What do I actually call?" | the recipe list, the Octave call, and the measured `eig(A,B)` outputs | `eig`/`qz`/`ordqz` over `dggev`/`dgges`; balance, reduce, iterate, read the pairs, order by adjacent-block swaps (generalized Sylvester equation for a complex pair); eigenvectors come from `Z`; QZ is dense `O(n^3)`, not structure-preserving, and not an accuracy guarantee |
| s7 | 16 | Provenance | Sources | (see below) |

## Follow-ups

- **Revision 1 (reader questions, four items).** The reader asked (1) whether phase-two reduction
  uses Givens or Householder for `n > 3`, (2) whether the shift is always a Francis double step,
  (3) whether different left/right transformations violate the implicit Q theorem, and (4) how
  reordering moves selected pairs to the leading block. The answers required three additions and
  one correction:
  - *Correction (correctness bug).* Section 5 stated the double-shift vector as the first column
    of `(H - s1 T)(H - s2 T)`. That is wrong: the implicit QZ double-shift vector is the first
    column of `(M - s1 I)(M - s2 I)` with `M = H T^{-1}`, i.e. `(H - s1 T) T^{-1} (H - s2 T)
    T^{-1} e1`. Checked numerically on the reduced example: the true vector and the first column
    of `(M - s1 I)(M - s2 I)` agree to 0 degrees, while the note's old formula is 28.5 degrees
    off. The single-shift sweep in `qz_sweeps.m` is unaffected, because for `e1` the `T^{-1}`
    factor is a scalar (`T^{-1}e1 = e1/t11`).
  - *Addition (Q3).* A new paragraph "Why two sides are legitimate" (+ equation (16)) shows
    `Q^T H Z = S`, `Q^T T Z = P` imply `Q^T M Q = S P^{-1}` for `M = H T^{-1}`: an ordinary
    Hessenberg similarity for `Q`, with `Z` then fixed by the RQ factorization of `Q^T T`. The
    two-sided step is the implicit Q theorem applied to the pencil, not a departure from it.
  - *Addition (Q1).* Section 4's "general pattern" now names Givens rotations (bottom-up per
    column) and explains why a Householder would spread the fill in `B` instead of one entry.
  - *Addition (Q4).* Section 6's ordering item now gives the adjacent-block-swap mechanism and
    the generalized Sylvester equation `S11 R - L S22 = gamma S12`, `T11 R - L T22 = gamma T12`.
  - Q2 (always the double shift for a real driver; single complex shift for a complex driver) was
    answered in chat and is already consistent with the note (`DHGEQZ` documents the double-shift
    method); no note change was needed beyond citing `DHGEQZ`.
- **Revision 2 (reader asked for the reordering algorithm step by step).** Added subsection 6.1
  "Moving a block to the front: the swap in detail" (equation (17)): the adjacent-block-swap
  setting; the two-Givens swap for two real 1x1 blocks (scalars `F = s22 t11 - t22 s11`,
  `G = s22 t12 - t22 s12`); and the four steps for a swap involving a 2x2 block (the generalized
  Sylvester equation, `Q1` from a QR of `[-L; gamma I]`, `Z1` from an RQ of `[gamma I, R]`, the
  two re-triangularizations with the smaller `S21` chosen, and the acceptance threshold). Reads
  from `DTGEXC`/`DTGEX2`; verified the outcome with Octave's `ordqz` on the running example (the
  2x2 complex block moves to the front, `T` gains the 1x1 at the bottom, eigenvalues preserved,
  `Q2`, `Z2` orthogonal to `1e-15`). No page change (fits s6): still 17 pages, map
  `3,5,7,9,11,14,16`.
- Next revision: reader feedback on the hardest bridge (the paired rotation of s4, the sample's
  subject). If it does not land, likely repairs are a second worked entry of phase two on a
  `4 x 4` pencil, or a one-line animation of the left/right pair in the sidecar-demo format.
- Open offer, not authorized work: an interactive HTML stepper over the recorded reduction of
  `qz_sweeps.m` (the existing goal is met by the static Figure 4; a demo was judged to add little
  beyond the static accuracy plot and to risk the demo ceiling).
- Optional, if the reader wants it: a `#check` in s3 that asks which pair of a listed `(S, T)`
  is infinite, with the answer below.

## Unresolved claims

- The statement that the finite pair `{i, -i}` is a well-conditioned eigenvalue of the pencil is
  supported empirically (the QZ route returns it to machine precision for `delta` down to
  `10^-16`, Table 2) but no formal eigenvalue-condition-number calculation was carried out. If a
  revision needs the sharper claim, compute Stewart's condition number for the pair explicitly.
- The real double-shift chase (Figure 5) is drawn from Golub and Van Loan and from Arbenz's
  slides, not executed. The executed iteration is the complex single-shift variant, which the note
  states. A future revision that implements the real double shift should replace the schematic
  with recorded states.

## Sources consulted

| Source and passage read | Claim or assumptions supported |
|---|---|
| Moler & Stewart 1973, abstract | the QZ algorithm for `Ax = lambda Bx`, attention to a singular `B`, "no inversions of `B` or its submatrices are used", reduction to QR at `B=I` |
| Golub & Van Loan, *Matrix Computations* 4th ed., §7.7 (table of contents and section) | the generalized Schur decomposition, the Hessenberg-triangular reduction, the implicit double-shift step, the bulge chase, and "the QZ step is a QR step on `A B^-1`" |
| Arbenz, ETH lecture 5, QZ section | the same decomposition and reduction; the double-shift bulge pattern (the `+` placements in Figure 5); the deflation of a zero diagonal of the second matrix |
| LAPACK `dggev` documentation | the pair output `(ALPHAR, ALPHAI, BETA)`, `lambda = (ALPHAR + i ALPHAI)/BETA`, the warning that the quotient may over-/underflow while `alpha`, `beta` stay in range, and the `beta = 0` convention (quoted in s2) |
| Ward 1981, abstract | balancing the generalized eigenvalue problem before a QZ-type solver |
| LAPACK `DGGHRD` and `DHGEQZ` sources (purpose and inner loops), read in revision 1 | phase-two reduction is a product of Givens rotations, bottom-up per column; the real driver is the double-shift QZ method, and it builds the 3-vector shift from a handful of local entries of `H` and `T` |
| Kågström 1993, via the `DTGEXC`/`DTGEX2` source and the LAWN87 abstract, read in revision 1 | reordering by adjacent-block swaps; the generalized Sylvester equation for swapping a block that holds a complex pair; a Givens rotation for two real 1x1 blocks |

No source was needed for the algebra of s3 and s4 or the closed form of s1, which are derived in
the note and checked numerically. Suggested further reading is labelled as not consulted.

## Checks and deviations

- **Build** — `typst compile --root . Algebra/qz-algorithm/qz-algorithm.typ
  Algebra/qz-algorithm/qz-algorithm.pdf` exits 0 with no warnings; 17 pages (revision 1 added a
  paragraph and an equation); section-to-page map `3,5,7,9,11,14,16`.
- **Shift vector (revision 1)** — `octave` comparison on the reduced `delta = 1/2` pair: the true
  implicit double-shift vector, the first column of `(M - s1 I)(M - s2 I)` with `M = H/T`, and the
  recomputed first column of `(H - s1 T) T^{-1} (H - s2 T) T^{-1}` agree to 0.0 degrees, while
  the formula the note originally printed, `(H - s1 T)(H - s2 T) e1`, is 28.5 degrees away.
  Section 5 now states the correct one; `eq:implicitq`'s identity `Q^T H Z = S`, `Q^T T Z = P`
  implies `Q^T (H T^{-1}) Q = S P^{-1}` was checked on the same reduced pair.
- **Reordering (revision 2)** — Octave `ordqz` on the `delta = 1/2` real Schur form with a
  selection of the 2x2 block: the block moves to the leading position (`T` becomes
  `diag(1,1,0.5)` with the 1x1 at the bottom), the three eigenvalues are unchanged, and the
  returned `Q2`, `Z2` are orthogonal to `1e-15`. The swap's own transformation is not
  re-implemented (the note cites `DTGEXC`/`DTGEX2` for the construction); only its outcome is
  executed here.
- **Structural** — no `FILL:` slots; no `"../` paths; every captioned figure carries an explicit
  `kind`/`supplement`, so numbering is consistent: Figure 1 (spectrum), Table 1 (singular
  endpoint), Table 2 (accuracy), Figure 2 (accuracy plot), Figure 3 (Schur form), Figure 4
  (reduction), Figure 5 (bulge chase), Table 3 (one sweep).
- **verify_qz.m** — prints every number in s1, s2 and s3: closed form checked at three `lambda`
  to `3.6e-15`; eigenpair residual `2.5e-16`; Table 1 and Table 2 exactly as printed;
  `rank(B)=2`, `det(B)=0` at `delta=0`; the complex pairs `(1,0.5)->2`, `(i,1)->i`, `(-i,1)->-i`
  at `delta=1/2` and `(i,1)->i`, `(-i,1)->-i`, `(-1,0)->infinity` at `delta=0`; orthogonality
  `5.3e-16`/`4.2e-16`, equivalence `8.1e-16`/`5.6e-16`; the real form's 2x2 block
  `[[0,1],[-1,0]]` with `T_2 = I` giving `±i`; the pair `(1, 1e-309)` finite against an
  overflowing ratio; `eig(A,B)` residuals and the `-Inf` third value at `delta=0`.
- **qz_sweeps.m** — prints every number in s4 and s5: the phase-one and phase-two matrices shown
  in #ref(<fig:reduction>) (left rotation `c=-0.7454, s=-0.6667` filling `B(3,2)=-0.6667`;
  right rotation `c=-0.5774, s=-0.8165`), sub-band `0.0` and below-diagonal `4.1e-17`,
  orthogonality `9.2e-16`/`0`, equivalence `6.0e-16`/`7.8e-16`; the sweep's moving magnitudes
  `0.7276`, `0.8333`, `0.6623`, `0`; convergence in 7 sweeps with sub-band `2.1e-25` and
  below-diagonal `7.4e-18`.
- **Executed snippets** — the exact Octave listing in s6 (`eig`, `qz`, `ordqz(S,T,Q,Z,'lhp')`)
  was run in Octave 11.3.0 and works. The Python listing was replaced by a prose pointer
  (scipy is not installed here, so a published runnable listing could not be executed).
- **Rendered pages inspected** — pages 3,4 (spectrum), 5,6 (tables and accuracy plot),
  7,8 (Schur form and block), 9,10 (reduction), 11,12,13 (bulge chase, sweep table,
  convergence), 14 (recipe and code), 15,16 (sources, bibliography). All figures, tables,
  labels, and highlighted cells were read back; the spectrum axis overflow, the equation-label
  collision, the accuracy-guide slope, the bulge alternation, and the code-comment wrap were
  corrected after inspection.
- **Landing page** — served at `http://localhost:8010/index.html`; the new card is the first in
  `#grid`, its `href` resolves (HTTP 200), and the page's own counters give `36` notes,
  `algebra = 4`, `math = 8`, and `7` distinct fields. Card attributes (`data-category="algebra
  math"`, `data-field="Algebra"`, ten `data-tags` matching the ten pills) match the filter's
  expectations.
- **Deviations** — the real double-shift chase is a reference-faithful schematic, not executed
  (the executed iteration is a complex single shift, as s5 states); no interactive demo was
  built; scipy not installed, so the Python call is prose only. No other check was skipped.
