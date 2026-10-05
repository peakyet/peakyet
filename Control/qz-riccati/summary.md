# QZ and the Algebraic Riccati Equation — production summary

**Stage:** complete (full draft delivered). The owner asked for the oracle's plan to be implemented
directly, so the hardest-bridge sample discussion was merged into the delivery: the sample is filed
in `.amp/in/artifacts/qz-riccati-bridge-sample.pdf` and no reader feedback has arrived yet.
Comprehension is therefore **unassessed**.

**Artifact:** `Control/qz-riccati/qz-riccati.typ`, compiled to
`Control/qz-riccati/qz-riccati.pdf` (19 pages); `Control/qz-riccati/refs.bib`;
`Control/qz-riccati/scripts/verify_qz_riccati.m`,
`Control/qz-riccati/scripts/trace_qz_pencil.m` and
`Control/qz-riccati/scripts/qz_sweeps.m` (Octave, standard library only); no demo — nothing
here is clarified by a slider, and a pencil-block manipulator would exceed the demo ceiling in
`references/repo-notes.md`. Cross-link used in the prose:
`Control/symplectic-matrix/symplectic-matrix.pdf#page=6`.

**Scope:** how the stabilizing CARE solution is read off the stable deflating subspace of an
extended Hamiltonian pencil, and what ordering that pencil with QZ buys over forming the
Hamiltonian matrix and factorizing it. Not attempted: the discrete-time equation, descriptor
systems and the cross term `S` beyond one sentence, large sparse problems, and condition or error
estimation for `P`.

**Assumed background:** state space, eigenvalues and singular values, the LQR statement, and
floating-point rounding. No prior exposure to matrix pencils.

**Running example:** a unit mass on a unit spring, `A = [0 1; -1 0]`, `B = [0; 1]`, with two cost
knobs — `Q = eps*I, R = 1` and `Q = I, R = rho` — each with a closed-form solution, so every route
is measured against an exact answer and a conditioning effect can be told apart from an algorithmic
one.

## Explanation progression

| Section | PDF page | Obstacle addressed | Picture or construction | Essential result explained |
|---|---|---|---|---|
| s1 | 3 | The CARE read as a formula to plug into rather than an object with structure | The plant and its two knobs with closed forms; the graph-subspace identity | The stable invariant subspace of `H` gives `P = X2 X1^{-1}`, and the closed loop is `H`'s action on that subspace |
| s2 | 5 | "The numbers came out why not use eigenvectors?" | Table 1 (four values of `eps`, three routes); Figure 1 (spectrum migration, and the gap and overlap laws on log axes) | The straddling pair's eigenvectors differ by `O(eps)` while its eigenvalues split as `sqrt(eps)`; here all three routes sit within a factor of three of `eps_m/eps`; the repair is a subspace basis (ordered Schur), not QZ |
| s3 | 8 | "Why not just build `H` and use that fix?" | Table 2 (`rho` values, both routes, including `rho = 0`) | Forming `G = B R^{-1} B^T` costs the digits of `1/rho`; the pencil holds machine precision; at `rho = 0` the matrix route has no value to compute |
| s4 | 9 | New representation: an eigenvalue as a ratio `alpha/beta`, an eigenvector as a deflating subspace `M Z = N Z S` | Figure 2 (the two objects, blocks annotated by what each route inverts) and the QR deflation | The extended pencil keeps `B` and `R` as blocks; its finite eigenvalues are `H`'s; its stable deflating subspace is the graph of `P`; the control block is deflated before ordering |
| s5 | 11 | QZ as an opaque library name | The iteration's three stages; Figure 3 (ordered generalized Schur form; partition of `Z`); Table 3, Figure 4 and Table 4 (the trace: pairs by stage, the ordered `S`, `T`, and `U11`, `U21`, `P` with the diagnostics); the defect table | Unitary `Q, Z` give triangular `(S, T)` with pairs `alpha/beta`; ordering selects `Re(alpha/beta) < 0`; `P = U21 U11^{-1}` by substitution; the defect is a tripwire, not a bound |
| s5, run | 13 | "What does the algorithm actually do?" — the stages stay prose | Table 5 (the recorded rotation sequence of the Hessenberg–triangular reduction); Figure 5 (the same reduction as four numeric panels, with the entries phase 2 removes shaded); Figure 6 (one exact QZ step on the `2 times 2` trailing pencil: the shift's eigenvector direction drawn in the plane, the two rotations, the triangular result, the ratios `2.000000` and `-1.000000`) | Each left rotation in the reduction fills exactly one entry of `B` below its diagonal and the paired right rotation removes it; the elementary step is the same right-then-left pair of rotations that orders the pencil, verified as an exact equivalence to `5.99e-16`; the implicit double-shift sweep between the two ends is deliberately not implemented |
| s6 | 16 | Believing QZ is a universal accuracy fix | The buy claim with its numbers; Table 6 (knob, what degrades, what limits) | The pencil holds `1e-15`-ish as `rho` falls; near-axis eigenvalues are a conditioning limit every route inherits; scipy refuses; structure-preserving methods are out of scope |
| s7 | 18 | Where each claim comes from | Sources | (see below) |

## Follow-ups

- Added on request after the first delivery: section 5 now states the iteration's three stages in
  prose and carries the whole route written out for the running example (Table 3, Figure 4,
  Table 4), with its own companion script `scripts/trace_qz_pencil.m`; the section-to-page map and
  the figure and table numbers above were refreshed afterwards.
- Added after the reader asked for the algorithm itself rather than prose: section 5 now also runs
  the two ends of the machinery on real data — `scripts/qz_sweeps.m` records the
  Hessenberg–triangular reduction rotation by rotation (Table 5, Figure 5) and performs one exact
  `2 times 2` QZ step (Figure 6), and the note states plainly that the implicit double-shift sweep
  between them is not implemented (Moler–Stewart / LAPACK `dhgeqz` own it). Open offer, not
  authorized work: an interactive HTML stepper replayed from the recorded reduction states, or a
  proper implicit bulge-chase implementation.
- Next revision: reader feedback on the hardest bridge (the pencil and its deflating subspace). If
  the bridge does not land, the likely repairs are a worked `M Z = N Z S` line on the 2x2 Jordan
  toy, or printing one explicit `(alpha, beta)` pair from the running example.
- Optional, if the reader wants an exercise: a `#check` in s3 asking what happens at `rho = 0`.

## Unresolved claims

- The scipy statements in s4 and s5 (the pencil with its `E` and `S` blocks, the deflation comment,
  the `LinAlgError` message and its threshold) come from the SciPy v1.18.0 documentation and from
  `scipy/linalg/_solvers.py` on GitHub's main branch, both read but not executed — scipy is not
  installed on this machine. Re-read those two passages before any revision that depends on them.

## Sources consulted

| Source and passage read | Claim or assumptions supported |
|---|---|
| Laub 1979, abstract and section I; Theorems 4-6 discussion | the eigenvector basis is often numerically unsatisfactory; an ordered real Schur form supplies a basis in any desired order; the graph elimination and the symmetry of `P` |
| Van Dooren 1981 (as cited by scipy for the deflation, eq. (55)) | the generalized eigenvalue formulation, the extended pencil that keeps `B` and `R`, and the QR deflation |
| Arnold & Laub 1984, abstract | the generalized-eigenproblem framework for continuous and discrete Riccati equations, balancing, and a Newton-type refinement |
| Moler & Stewart 1973, abstract | the QZ algorithm and its handling of a singular second matrix: "no inversions of `B` or its submatrices are used" |
| Benner 2001 (as cited by scipy's reference list) | balancing the pencil, the step that improves the QZ accuracy |
| Benner, Mehrmann & Xu 1998, title and abstract | structure-preserving Hamiltonian and symplectic eigenvalue methods as the tool near or on the axis |
| Benner & Sima 2003, sections on methods and solvers | "rounding errors introduced by forming `R^{-1}` are avoided" with the extended pencil; the symplectic matrix needs a nonsingular `A` while the symplectic pencil does not; `X = U21 U11^{-1}` |
| SciPy v1.18.0 `solve_continuous_are` documentation (Notes, references) | the extended pencil `H - lambda J` with `E` and `S` blocks, QZ, the `U2 U1^{-1}` symmetry condition, the `LinAlgError` description, the balancing reference |
| SLICOT `SB02OD` documentation (purpose, method) | the extended Hamiltonian pencil, deflating subspaces via QZ, `X = Y2 Y1^{-1}`, "a standard eigenproblem is solved in the continuous-time case if `G` is given", the singular-`R` remark |

No source was needed for the algebra of s1 and s4, which is derived in the note and checked
numerically. No further reading is listed in the note beyond Golub & Van Loan and the CAREX/DAREX
collections, which are labelled there as not consulted.

## Checks and deviations

- **Build** — `typst compile --root . Control/qz-riccati/qz-riccati.typ
  Control/qz-riccati/qz-riccati.pdf` exits 0 with no warnings; 19 pages; section-to-page map
  `3,5,8,9,11,16,18`.
- **Structural** — no `FILL:` slots; no `"../` paths; every captioned figure carries an explicit
  `kind`/`supplement`, so numbering is consistent and non-colliding: Table 1, Figure 1, Table 2,
  Figure 2, Figure 3, Table 3, Figure 4, Table 4, Table 5, Figure 5, Figure 6, Table 6.
- **Sweep script** — `octave --no-gui --quiet Control/qz-riccati/scripts/qz_sweeps.m` prints every
  number in Table 5, Figure 5 and Figure 6: the reduction's recorded fills (`0.0000`, `0.5774`,
  `0.7071`), the final pair with `A` below-band `9.6e-17` and `B` `5.6e-17`, orthogonality
  `4.51e-16` / `2.22e-16` and equivalence `4.84e-16` / `2.32e-16`; the `2 times 2` step with the
  shift pair `(-0.894427, -0.447214)`, eigenvector angle `1.0560` rad, result below-diagonal
  `2.2e-16` / `0.0`, reconstruction `5.99e-16` / `1.42e-16`, and ratios `2.000000`, `-1.000000`.
  The script is deliberately limited to the reduction and the elementary step; the implicit
  double-shift sweep is not implemented, and the note says so.
- **Trace script** — `octave --no-gui --quiet Control/qz-riccati/scripts/trace_qz_pencil.m` prints
  the extended pencil, the pairs at each stage, the deflated pencil's conditioning, the ordered
  `S`, `T`, `U11`, `U21`, `P` and the diagnostics; every value in Tables 3 and 4 and in Figure 4 was
  read from its output (ratios `-999.9985, +999.9985, -1.000002, +1.000002` unordered, the stable
  pair first after ordering, `cond(U11) = 1.4149`, symmetry defect `4.382e-16`, CARE residual
  `4.745e-13`, orthogonality `1.272e-15` and `8.044e-16`, `P` agreeing with the closed form to
  `9.88e-16`). It uses the real QZ, so `S` and `T` are the real quasi-upper-triangular pair; the
  verifier keeps Octave's complex QZ, and a comparison showed the two agree on the note's error
  levels to within a factor of a few (e.g. `8.81e-11` against `5.58e-11` at `eps = 1e-6`).
- **Numbers** — `octave --no-gui --quiet Control/qz-riccati/scripts/verify_qz_riccati.m` prints
  every quoted value. Checked there: both closed forms solve their CARE (residual at most
  `3.62e-16`) with stable closed loops; the pencil route and the ordered-Schur route agree to
  `1.08e-14` (eps `1e-2`) and `7.30e-11` (eps `1e-6`) relative; the `eps` table and the `rho` table
  match the note row for row; the tripwire table was recomputed over 100 random pencil roundings;
  the 2x2 Jordan toy's gap and overlap match `2 sqrt(eps)` and `2 eps/(1+eps)`; and section G covers
  the deflation: 4 finite and 1 infinite pair becoming 4 and 0 at `R = 1e-6`, 2 finite and 3
  infinite at `R = 0` of which the deflated 4x4 keeps 2, the smallest singular value of the deflated
  second matrix (`7.07e-1`, `1.00e-6`, and `9.46e-9` with `R = diag(1, 1e-8)`), a regularity probe
  at `R = 0` (`det(alpha H - beta J)` nonzero at 5 of 5 random pairs, which grounds the "still a
  regular pencil" row of Table 2), and a second size (full 8x8: 6 finite, 2 infinite; deflated 6x6:
  6 finite, 0 infinite; finite eigenvalues agreeing to `8.0e-10` relative). That probe also
  corrected s4: the deflated pencil at `R = 0` keeps two infinite pairs rather than leaving the
  ordering problem with none.
- **Rendered pages** — pages 3, 4, 5, 6, 9, 10, 11, 12, 13, 14 and 15 inspected as images
  (100-110 dpi), and the figures rendered in isolation at 150 dpi and inspected; the remaining pages
  were checked by their extracted text, their line counts and the column-overflow check below. Fixed during
  review: a stray comma that rendered above every caption (a `],` closing a content block inside
  markup); inline fractions replaced with `/` so the line spacing stopped blowing up; two tall
  inline block columns replaced with prose; Figure 1's log panel given a bottom tick label. After
  the reader reported an overlap on page 4: the two-column block for the two cost knobs was
  replaced by full-width two-line displays, with the shape of `P` stated once in prose.
- **Column overflow** — a text-box check (`.amp/in/scratch/overflow_check.py`, built on
  `pdftotext -bbox-layout`) takes the document's own word boxes to fix the text edges (70.9pt and
  526.6pt across the A4 text block) and reports any word past them, which is how Typst lets content
  overrun the column in silence. Before the fix, page 4 had 18 words outside the column with `xMax`
  up to 595.5pt, i.e. reaching the paper edge; after it, zero words are outside on all 19 pages and
  every page's maximum `xMax` is at most 526.6pt. The check reads text only, so the drawn figures
  still rest on the visual inspection above.
- **Card** — added to `index.html` next to the symplectic-matrix card with
  `data-category="control algebra optimization"`, `data-field="Control Theory"` and a matching
  pill list. Verified in Chrome 154 (headless) by driving the page's own controls on a copy that
  drops the `async` CDN MathJax tag (this sandbox has no network, and that tag delays the load
  event; the page body contains no math delimiters, so no visible layout depends on it). Measured:
  `#stat-notes` 34, `#cnt-control` 19, `#cnt-optimization` 10, `#cnt-algebra` 2; the new card is
  index 2 in the grid, initially visible on page 1, its `.read` estimated as "1 min read", and
  `data-tags` equals the visible pills; searches for `deflating-subspace`, `riccati qz` and
  `pencil schur` each return exactly this note, `zzz` returns none; the Control, Optimization and
  Algebra chips include it and Robotics and Tools exclude it; no JavaScript errors. The card's
  `href` resolves to the committed PDF (HTTP 200 from the local server). Screenshots at 980px and
  1440px widths inspected; the card and its amber "Numerical Control" tag render in the same row
  as the symplectic-matrix card.
- **Deep link** — the cross-reference to `Control/symplectic-matrix/symplectic-matrix.pdf#page=6`
  was checked against that note's own heading map (`3,4,5,6,7,8,9`), so page 6 is its section on the
  LQR Hamiltonian.
- **Deviations** — (i) explicit `kind`/`supplement` on every captioned figure, so that the figure
  and table counters do not collide; (ii) sections start on new pages as the preset supplies, so the
  long sections leave part-empty pages — the tails at 7, 10 and 17, plus the figure page 12 — kept
  for series consistency rather than turning off `chapter-pagebreak` for this one note; (iii) no
  interactive demo, and the sweep script stops short of the implicit iteration instead of shipping
  an unverified one; (iv) the two structural figures are tables shown as figures.
- **Could not run** — scipy (not installed): the scipy behaviour quoted in s4 and s5 is documented
  behaviour, not executed here. The landing page was rendered in Chrome 154 (see the card check)
  but only through a `file://` copy, because Chrome in this sandbox cannot connect to the local
  HTTP server; the served URL was still checked with `curl` (HTTP 200 for `index.html` and for the
  card's PDF).
