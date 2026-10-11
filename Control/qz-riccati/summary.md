# QZ and the Algebraic Riccati Equation — production summary

**Stage:** complete (full draft delivered). The owner asked for the oracle's plan to be implemented
directly, so the hardest-bridge sample discussion was merged into the delivery: the sample is filed
in `.amp/in/artifacts/qz-riccati-bridge-sample.pdf` and no reader feedback has arrived yet.
Comprehension is therefore **unassessed**.

**Artifact:** `Control/qz-riccati/qz-riccati.typ`, compiled to
`Control/qz-riccati/qz-riccati.pdf` (26 pages); `Control/qz-riccati/refs.bib`;
`Control/qz-riccati/scripts/verify_qz_riccati.m`,
`Control/qz-riccati/scripts/trace_qz_pencil.m`,
`Control/qz-riccati/scripts/qz_sweeps.m` and
`Control/qz-riccati/scripts/dare_sweeps.m` (Octave, standard library only); no demo — nothing
here is clarified by a slider, and a pencil-block manipulator would exceed the demo ceiling in
`references/repo-notes.md`. Cross-link used in the prose:
`Control/symplectic-matrix/symplectic-matrix.pdf#page=6`.

**Scope:** how the stabilizing CARE solution is read off the stable deflating subspace of an
extended Hamiltonian pencil, and what ordering that pencil with QZ buys over forming the
Hamiltonian matrix and factorizing it, plus the discrete-time equation (DARE) as the same recipe
with one block changed. Not attempted: descriptor systems and the cross term `S`, large sparse
problems, condition or error estimation for `P`, and for the discrete case existence and uniqueness
of the stabilizing solution and the deadbeat case.

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
| s3 | 8 | "Why not just build `H` and use that fix?" | Table 2 (`rho` values, both routes, including `rho = 0`) and Table 3 (what a singular `R` does: the three cases, keyed on whether a free direction of `R` acts on the state) | Forming `G = B R^{-1} B^T` costs the digits of `1/rho`; the pencil holds machine precision; at `rho = 0` the matrix route has no value to compute and the pencil — though still regular — is one stable pair short of `n`, so there is no `P` to read: a regular pencil is not a solvable problem |
| s4 | 10 | New representation: an eigenvalue as a ratio `alpha/beta`, an eigenvector as a deflating subspace `M Z = N Z S` | Figure 2 (the two objects, blocks annotated by what each route inverts) and the QR deflation; the stable eigenvector `[x; Px; -R^{-1}B^T Px]` and the annihilation `Q_2^T (B;0;R) = 0` that explains the deflation | The extended pencil keeps `B` and `R` as blocks; its finite eigenvalues are `H`'s; its stable deflating subspace is the graph of `P`; the deflation drops the control band because `Q_2` is built orthogonal to it, leaving `M_d [I;P] = N_d [I;P] (A - GP)`; deflating first is worth two digits (`cond` 1.41 against 1154 for the truncated full `Z`) |
| s5 | 13 | QZ as an opaque library name | The iteration's three stages; Figure 3 (ordered generalized Schur form; partition of `Z`); Table 4, Figure 4 and Table 5 (the trace: pairs by stage, the ordered `S`, `T`, and `U11`, `U21`, `P` with the diagnostics); Figure 5 (the read-off drawn: the full pencil's ordered `Z`, the control band the deflation removes, the `2n times n` graph basis, and the one solve to `P`); the defect table | Unitary `Q, Z` give triangular `(S, T)` with pairs `alpha/beta`; ordering selects `Re(alpha/beta) < 0`; the columns of `Z` turn that list of eigenvalues into a subspace; `U21 = P U11` is what makes it a graph, and `P = U21 U11^{-1}` is one solve; the defect is a tripwire, not a bound |
| s5, run | 17 | "What does the algorithm actually do?" — the stages stay prose | Table 6 (the recorded rotation sequence of the Hessenberg–triangular reduction); Figure 6 (the same reduction as four numeric panels, with the entries phase 2 removes shaded); Figure 7 (one exact QZ step on the `2 times 2` trailing pencil: the shift's eigenvector direction drawn in the plane, the two rotations, the triangular result, the ratios `2.000000` and `-1.000000`) | Each left rotation in the reduction fills exactly one entry of `B` below its diagonal and the paired right rotation removes it; the elementary step is the same right-then-left pair of rotations that orders the pencil, verified as an exact equivalence to `5.99e-16`; the implicit double-shift sweep between the two ends is deliberately not implemented |
| s6 | 19 | Discrete time looks like a separate theory | Figure 8 (left: the pencil's eigenvalues in reciprocal pairs about the unit circle, the inside ones navy and equal to the closed-loop poles; right: the two eigenvector directions of the scalar pencil in the state plane, the stable one being the graph of `P`, read off as a slope); Table 7 (three instances measured) | One block changes (`A^T` for `I`), so `R^(-1)` becomes `(R + B^T P B)^(-1)`, the criterion becomes `abs(alpha) < abs(beta)`; the control coordinate of the stable eigenvector is `-lambda R^(-1) B^T P` so the deflation is what leaves the graph, verified by `M_d [I;P] = N_d [I;P] A_cl`; the scalar instance has the exact answer `2 + sqrt(5)` with the reciprocal pair visible as palindromic coefficients; singular `A` is covered although the symplectic matrix `S` is not |
| s7 | 23 | Believing QZ is a universal accuracy fix | The buy claim with its numbers; Table 8 (knob, what degrades, what limits) | The pencil holds `1e-15`-ish as `rho` falls; near-axis eigenvalues are a conditioning limit every route inherits; scipy refuses; structure-preserving methods are out of scope |
| s8 | 25 | Where each claim comes from | Sources | (see below) |

## Follow-ups

- Added on request after the first delivery: section 5 now states the iteration's three stages in
  prose and carries the whole route written out for the running example (Table 3, Figure 4,
  Table 4), with its own companion script `scripts/trace_qz_pencil.m`; the section-to-page map and
  the figure and table numbers above were refreshed afterwards.
- Added after the reader asked for the algorithm itself rather than prose: section 5 now also runs
  the two ends of the machinery on real data — `scripts/qz_sweeps.m` records the
  Hessenberg–triangular reduction rotation by rotation (Table 5, Figure 5) and performs one exact
  `2 times 2` QZ step (Figure 6), and the note states plainly that the implicit double-shift sweep
  between them is not implemented (Moler–Stewart / LAPACK `dhgeqz` own it).
- Added on request ("also add the part to introduce how to solve a DARE"): section 6 introduces the
  discrete-time equation as the same recipe with the `(2,2)` block of the second matrix changed from
  `I` to `A^T`, and carries it out with `scripts/dare_sweeps.m` — the scalar instance solved from
  the three block rows with the exact answer `2 + sqrt(5)`, Figure 8's two panels, and Table 7's
  three measured instances including a singular `A` where the symplectic matrix does not exist. The
  landing card and page map were refreshed (s6 at page 17).
- Added on request ("after we solve the generalized Hamiltonian matrix, how to get the graph in
  `R^{2n x n}`… how to deflate it?"): section 4 now ends with the mechanism — the stable eigenvector
  `[x; Px; -R^{-1}B^T Px]`, the annihilation `Q_2^T (B;0;R) = 0` that erases the control coordinate,
  the graph identity `M_d [I;P] = N_d [I;P] (A - GP)`, and the measured price of skipping the
  deflation — and section 5 gains Figure 5, which draws the `(2n+m)` ordered `Z`, the control band
  the deflation removes, the `2n times n` graph basis and the one solve to `P` on the trace
  instance's own numbers. `scripts/trace_qz_pencil.m` prints every number in that figure (the
  annihilation `8.9e-17`, `U21 = P U11` to `2.4e-19`, the graph identity `4.7e-13`, the eigenvector
  checks, and the no-deflation comparison `cond` 1154 / `4.2e-14` against 1.41 / `9.9e-16`).
- Added on request ("if R is singular ... is there a chance to get a stable eigenvalue? will it enter
  the leading n columns after ordering?"): the note's `R = 0` discussion was incomplete — it called
  the leftover infinite pairs harmless, which they are, without saying that the finite side is
  short. Section 3 now carries Table 3 (the three cases of a singular `R`: nonsingular / free
  direction acts / free direction dead-and-singular-pencil), the correction that a regular pencil is
  not a solvable problem, and the two structural facts that make the count a usable check (the
  finite spectrum is closed under `lambda -> -lambda`, and its degree is at most `rank N = 2n`).
  Section 4's deflation paragraph gained the full-column-rank condition and the shortfall remark,
  and the recipe now counts the selected pairs. `scripts/verify_qz_riccati.m` section H prints every
  number in Table 3, including the forced read-off at `R = 0` (`P = mat(0,-1;0,0)`, `||P-P^T|| = 1`,
  `B^T P B = 0`) and the fix for the dead-control case (`P` back to the `R = 1` answer to `1.3e-15`).
- Open offer, not authorized work: an interactive HTML stepper replayed from the recorded reduction
  states of section 5, or a proper implicit bulge-chase implementation.
- Next revision: reader feedback on the hardest bridge (the pencil and its deflating subspace). If
  the bridge does not land, the likely repairs are a worked `M Z = N Z S` line on the 2x2 Jordan
  toy, or printing one explicit `(alpha, beta)` pair from the running example.
- Optional, if the reader wants an exercise: a `#check` in s3 asking what happens at `rho = 0`.

## Unresolved claims

- The scipy statements in s4, s5 and s6 (the pencil with its `E` and `S` blocks, the deflation
  comment, the `LinAlgError` message and its threshold, and for the discrete case the `iuc` sort
  key and the back-substitution from the leading block of the stable subspace) come from the SciPy
  v1.18.0 documentation pages for `solve_continuous_are` and `solve_discrete_are` and from
  `scipy/linalg/_solvers.py` on GitHub's main branch, all read but not executed — scipy is not
  installed on this machine, and no scipy number is quoted in the note. The note's own
  `scripts/dare_sweeps.m` reproduces the discrete recipe in Octave instead. Re-read those passages
  before any revision that depends on them.
- One discrepancy inside that source: the Notes of `solve_discrete_are` print the second matrix of
  the pencil with `B` in its `(1,3)` block, where the code's own deflation of "the R column"
  projects that slot away, so it cannot affect the recipe or the result. The note therefore states
  the discrete pencil from the recipe it verifies numerically, not from the displayed block.

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
| SciPy v1.18.0 `solve_discrete_are` documentation (Notes) and `scipy/linalg/_solvers.py` on GitHub main (the `solve_discrete_are` body) | the discrete pencil for `E = I`, `S = 0`; the deflation comment "Deflate the pencil by the R column ala Ref.1" (the same reduction as #ref(<eq:deflate>)); `sort='iuc'`; the back-substitution for `X = U10 U00^{-1}`; the final symmetrization; the `LinAlgError` for eigenvalues near the unit circle |
| SLICOT `SB02OD` documentation (purpose, method) | the extended Hamiltonian pencil, deflating subspaces via QZ, `X = Y2 Y1^{-1}`, "a standard eigenproblem is solved in the continuous-time case if `G` is given", the singular-`R` remark |

No source was needed for the algebra of s1 and s4, which is derived in the note and checked
numerically. No further reading is listed in the note beyond Golub & Van Loan and the CAREX/DAREX
collections, which are labelled there as not consulted.

## Checks and deviations

- **Build** — `typst compile --root . Control/qz-riccati/qz-riccati.typ
  Control/qz-riccati/qz-riccati.pdf` exits 0 with no warnings; 26 pages; section-to-page map
  `3,5,8,10,13,19,23,25`.
- **Structural** — no `FILL:` slots; no `"../` paths; every captioned figure carries an explicit
  `kind`/`supplement`, so numbering is consistent and non-colliding: Table 1, Figure 1, Table 2,
  Figure 2, Figure 3, Table 3, Table 4, Figure 4, Table 5, Figure 5, Table 6, Figure 6, Figure 7,
  Figure 8, Table 7, Table 8.
- **Discrete script** — `octave --no-gui --quiet Control/qz-riccati/scripts/dare_sweeps.m` prints
  every number in Figure 8 and Table 7: the scalar pencil's roots `2.6180339887` and `0.3819660113`
  with product `1` and the stable eigenvector `[1; 4.2360679775]` equal to the closed form
  `2 + sqrt(5)`; the double integrator's `P = [[2.9471, 2.3692],[2.3692, 4.6131]]` with DARE residual
  `9.3e-15`, symmetry defect `4.4e-16`, closed-loop radius `0.422082440385`, agreement with the
  Riccati recursion to `6.4e-15` in 22 steps, the symplectic matrix's defect `0` and its spectrum
  matching the deflated pencil to `3.2e-15`, and the paired moduli `2.3692 times 0.4221 = 1`; the
  graph identity `norm(M_d G - N_d G A_"cl")` at `1.0e-14` (nonsingular `A`) and `1.9e-15` (singular
  `A`), with the pencil's four eigenvalues equal to the closed-loop poles and their reciprocals to
  `2.1e-15`; the singular case `A = [[1,1],[0,0]]` giving `P = [[3,2],[2,3]]` exactly with residual
  `1.9e-15`, closed-loop radius `0.5`, a regular pencil at 20 of 20 random probes, and 2 infinite
  eigenvalues of which the deflated `4 times 4` keeps 1.
- **Sweep script** — `octave --no-gui --quiet Control/qz-riccati/scripts/qz_sweeps.m` prints every
  number in Table 6, Figure 6 and Figure 7: the reduction's recorded fills (`0.0000`, `0.5774`,
  `0.7071`), the final pair with `A` below-band `9.6e-17` and `B` `5.6e-17`, orthogonality
  `4.51e-16` / `2.22e-16` and equivalence `4.84e-16` / `2.32e-16`; the `2 times 2` step with the
  shift pair `(-0.894427, -0.447214)`, eigenvector angle `1.0560` rad, result below-diagonal
  `2.2e-16` / `0.0`, reconstruction `5.99e-16` / `1.42e-16`, and ratios `2.000000`, `-1.000000`.
  The script is deliberately limited to the reduction and the elementary step; the implicit
  double-shift sweep is not implemented, and the note says so.
- **Trace script** — `octave --no-gui --quiet Control/qz-riccati/scripts/trace_qz_pencil.m` prints
  the extended pencil, the pairs at each stage, the deflated pencil's conditioning, the ordered
  `S`, `T`, `Z`, `U11`, `U21`, `P` and the diagnostics; every value in Tables 4 and 5 and in
  Figures 4 and 5 was
  read from its output (ratios `-999.9985, +999.9985, -1.000002, +1.000002` unordered, the stable
  pair first after ordering, `cond(U11) = 1.4149`, symmetry defect `4.382e-16`, CARE residual
  `4.745e-13`, orthogonality `1.272e-15` and `8.044e-16`, `P` agreeing with the closed form to
  `9.88e-16`). Figure 5's added checks come from the same run: the annihilation
  `norm(Q_2^T (B;0;R)) = 8.890e-17`, the graph relation `norm(U21 - P U11) = 2.397e-19`, the graph
  identity `norm(M_d G - N_d G (A - GP)) = 4.747e-13`, the eigenvector checks (`x2 = P x1` to
  `2.966e-17`, `u = -R^{-1}B^T x2` to `2.876e-11`), and the no-deflation comparison
  (`cond = 1154.3` and `|P - closed| = 4.187e-14` against `1.4149` and `9.890e-16`). It uses the real QZ, so `S` and `T` are the real quasi-upper-triangular pair; the
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
- **Singular-R cases (section H)** — the same script prints Table 3's numbers: for the running
  example, `R = 1` and `R = 1e-14` give 4 finite of `2n = 4` with 2 stable of `n = 2` and `P` to
  `1e-16`, while `R = 1e-16` and `R = 0` give 2 finite of 4 with only 1 stable; `B = I` at `R = 0`
  gives 0 finite of 6; a 3-state instance whose free direction acts gives 4 finite of 6 with 2
  stable of 3. The `lambda -> -lambda` symmetry of the finite spectrum holds to a relative
  `5.0e-16` in the well-conditioned cases and to `2.7e-11` at `R = 1e-14` (only the `1e7`-scale
  pairs lose digits), measured on the deflated spectrum. A free direction that neither costs nor
  acts makes 2 of `2n+m` rows/columns vanish, so
  the square pencil is singular: regular at 0 of 20 probes, with `||M (0;0;e2)|| = 0`, and deleting
  that control restores the `R = 1` answer to `1.33e-15`. Taking the first `n` columns at `R = 0`
  anyway returns `P = mat(0,-1;0,0)`, `||P - P^T|| = 1`, `B^T P B = 0`.
  The measured reason the note leans on the count and the symmetry rather than on invariance: any
  leading block of a triangular Schur form is a deflating subspace, so the count-right case
  (`R = 1e-6`: 2 selected of 2, defect `4.8e-16` against `||U11^T U21|| = 0.500`) and the
  count-short case (`R = 0`: 1 selected of 2, defect `7.07e-1` against `0.707`, i.e. all of it,
  with `B^T P B = 0`) differ only in the count and in that defect -- which is the quantity scipy
  tests before returning.
- **Rendered pages** — pages 3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 and 19 inspected as
  images (100-150 dpi), and the figures rendered in isolation at 150 dpi and inspected; pages 9
  (Table 3), 15 (Table 5 with Figure 5) and 10 (the section 4 mechanism paragraphs) were
  re-inspected after their revisions, and page 13 was re-checked once the numbering shifted; the remaining pages were checked by their extracted text, their line counts and the
  column-overflow check below. Fixed during
  review: a stray comma that rendered above every caption (a `],` closing a content block inside
  markup); inline fractions replaced with `/` so the line spacing stopped blowing up; two tall
  inline block columns replaced with prose; Figure 1's log panel given a bottom tick label. After
  the reader reported an overlap on page 4: the two-column block for the two cost knobs was
  replaced by full-width two-line displays, with the shape of `P` stated once in prose.
- **Column overflow** — a text-box check (`.amp/in/scratch/overflow_check.py`, built on
  `pdftotext -bbox-layout`) takes the document's own word boxes to fix the text edges (70.9pt and
  526.6pt across the A4 text block) and reports any word past them, which is how Typst lets content
  overrun the column in silence. Before the fix, page 4 had 18 words outside the column with `xMax`
  up to 595.5pt, i.e. reaching the paper edge; after it, zero words are outside on all 26 pages and
  every page's maximum `xMax` is at most 526.6pt. The check reads text only, so the drawn figures
  still rest on the visual inspection above.
- **Figure review** — the discrete figure's two panels (now Figure 8) were redrawn twice to answer
  what the first render showed: the annotation `abs(lambda) = 1` collided with the
  outside-eigenvalue label, and the unstable direction was drawn as a ray so nearly horizontal that
  it read as the axis. Figure 5 needed the same treatment: its merged grey cell wrapped into
  "UN-ST A-BLE", and its read-off row fragmented the relation across cells; both were fixed and the
  re-render inspected. In the final renders the eigenvalue pairs, the dashed radial links, the
  slope guides at `(1, P)`, the control band and the `U21 = P U11` solve all carry the reasoning of
  the paragraphs beside them.
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
  long sections leave part-empty pages — the tails at 7, 12, 14 and 22, plus the figure page 24 —
  kept
  for series consistency rather than turning off `chapter-pagebreak` for this one note; (iii) no
  interactive demo, and the sweep script stops short of the implicit iteration instead of shipping
  an unverified one; (iv) the two structural figures are tables shown as figures.
- **Could not run** — scipy (not installed): the scipy behaviour quoted in s4, s5 and s6 is
  documented
  behaviour, not executed here. The landing page was rendered in Chrome 154 (see the card check)
  but only through a `file://` copy, because Chrome in this sandbox cannot connect to the local
  HTTP server; the served URL was still checked with `curl` (HTTP 200 for `index.html` and for the
  card's PDF).
