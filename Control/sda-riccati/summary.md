# The Structure-Preserving Doubling Algorithm for the Algebraic Riccati Equation — production summary

**Stage:** complete (full draft delivered). The owner asked to proceed straight to the complete note
after the hardest-bridge sample, so the feedback stage was merged into delivery: the sample is filed
in `.amp/in/artifacts/sda-bridge-sample.pdf` and no reader feedback has arrived. Comprehension is
therefore **unassessed**.

**Artifact:** `Control/sda-riccati/sda-riccati.typ`, compiled to
`Control/sda-riccati/sda-riccati.pdf` (17 pages); `Control/sda-riccati/refs.bib`;
`Control/sda-riccati/scripts/verify_sda.m` (Octave, standard library only);
`Control/sda-riccati/sda-riccati-demo.html` (94 lines, one inline script, one canvas, one slider).
Cross-links used in prose: the companion `Control/qz-riccati/qz-riccati.pdf` ("the companion QZ
note") and the shared plant with `Control/symplectic-matrix/symplectic-matrix.pdf`.

**Scope:** how the discrete-time Riccati equation is solved by squaring a symplectic matrix, why the
matrix powers cannot be formed directly, and how squaring a block factorization gives the
structure-preserving doubling algorithm (SDA); then how a Cayley transform reduces the continuous
equation to the same discrete form so one piece of code solves both. Not attempted: the general
DARE with a cross term `S`, descriptor systems and singular `A` beyond a pointer to the pencil
picture, large sparse problems and the low-rank/decoupled variants, and error or condition
estimation for the solution.

**Assumed background:** state space and the LQR statement, eigenvalues, and the idea of an invariant
subspace. No prior exposure to SDA, the Cayley transform, or the matrix sign function.

**Running example:** a unit mass on a unit spring. Its continuous Riccati solution has a closed
form, and its Cayley image is the discrete problem the doubling algorithm runs on, so one exact
answer `P` measures every step and both equations share it. A separate scalar case is used only to
draw the graph geometry of the first sections, because a graph is a line when `n = 1`.

## Explanation progression

| Section | PDF page | Obstacle addressed | Picture or construction | Essential result explained |
|---|---|---|---|---|
| s1 | 3 | The DARE read as a nonlinear formula with no starting point | The value iteration and its cost-to-go meaning; the running data and its exact solution | The horizon recursion converges linearly at rate `sigma`, which is near 1 when the loop is near the boundary |
| s2 | 4 (Fig. 1 on 5) | "The recursion is nonlinear, why a matrix?" | Figure 1: successive graph lines under `S^{-1}` rotating onto the stable line; then the invariance identity (Eq. 9) and the two-spectra relation (Eq. 11) | One value step is one application of `S^{-1}` to the graph; `S` is symplectic, and its restriction to the graph of `X_+` is the closed-loop state matrix `(I+GX_+)^{-1}A`, so `sigma(S) = sigma(K) u {1/bar-lambda}` |
| s3 | 7 (Fig. 2) | "How does squaring solve it?" | Figure 2: the spectrum under squaring, inside eigenvalues spiralling to 0, outside to infinity | `S^{-2^k}` lands on `X_{2^k}`; squaring doubles the horizon |
| s4 | 8 | "Why not just square the matrix?" | Table 1: explicit power vs factored form at `k = 0..6` | The power's condition number grows like `3.55^(2^k)`; the wrong representation destroys the answer |
| s5 | 9 | The step that replaces squaring a power by squaring a factorization | The block extraction `(A', G', Q')` from `W`, and the product `N_k M_k^{-1}` | The SDA update (Eq. 15), derived from the factorization and the push-through identity |
| s6 | 11 (Fig. 3) | "Does it actually save work, and by how much?" | Table 2 (exactness and convergence), Figure 3 (error against work), Table 3 (`sigma -> 1`) | `Q_k = X_{2^k}` to roundoff; 6 squarings against 27 steps here and 19 against 109 945 at `sigma = 0.9999` |
| s7 | 13 (Fig. 4) | "What about the continuous-time equation?" | Figure 4: the Cayley Möbius map sending the Hamiltonian spectrum's stable half into the unit disk | The Cayley image is a DARE with the same solution; SDA returns the closed-form `P` without an eigensystem |
| s8 | 15 | Limits, assumptions, and neighbours | Prose plus two `#check` boxes with visible answers | Degradation to linear rate 1/2 at `sigma = 1`; the invertible-`A` and existence assumptions; sign function, Newton, Schur/QZ comparisons |
| s9 | 16 | Where each claim comes from | Sources and further reading | Attribution only |

## Follow-ups

- Next revision: reader feedback on the visual bridge (Figure 1's line fan and Figure 4's spectra).
  If Figure 1 does not land, the likely repair is to animate or step the individual rays; if the
  Cayley figure is unclear, add the image points of the second eigenvalue explicitly.
- Optional: a worked singular-`A` case on the pencil, which the note only points at.

## Unresolved claims

- The degradation to "linear with rate `1 slash 2`" when `sigma = 1` is quoted from Poloni's prose
  section 4.2 (read) and attributed there; it is not independently reproduced here. Re-read that
  passage before any revision that leans on it harder.

## Sources consulted

| Source and passage read | Claim or assumptions supported |
|---|---|
| Poloni, *Iterative and doubling algorithms for Riccati-type matrix equations* (arXiv:2005.08903), full LaTeX body: Introduction, Stein/Lyapunov, sections 4 (DARE) and 5 (CARE), section 8 | The "squaring variant" framing; the symplectic matrix (26) and invariance (25); the factorization (30) and the update (33); the identity `Q_k = X_{2^k}`; the Cayley reduction (40) and the claim that it preserves solutions and the stabilizing one; the sign-iteration relation (43); the `sigma = 1` caveat |
| Chu, Fan, Lin, Wang, *Structure-Preserving Algorithms for Periodic Discrete-Time Algebraic Riccati Equations*, Int. J. Control 77(8) (2004), abstract and section 2 excerpt | Attribution of the structure-preserving doubling algorithm for DAREs, and that it preserves the symplectic form at each step |
| Chu, Fan, Lin, *A Structure-Preserving Doubling Algorithm for Continuous-Time Algebraic Riccati Equations*, LAA 396 (2005), abstract/metadata | Attribution of the Cayley reduction of the CARE to a DARE before applying SDA |
| Anderson, *Second-Order Convergent Algorithms for the Steady-State Riccati Equation*, Int. J. Control 28(2) (1978), metadata | Attribution of the original doubling algorithm for the discrete steady-state Riccati equation |

No source was needed for the block-algebra derivation of section 5 or the closed form of section 7,
which are derived and checked numerically. The further-reading list in the note is labelled as not
consulted.

## Checks and deviations

- **Build** — `typst compile --root . Control/sda-riccati/sda-riccati.typ
  Control/sda-riccati/sda-riccati.pdf` exits 0 with no warnings; 17 pages; section-to-page map
  `3,4,7,8,9,11,13,15,16`.
- **Structural** — no `FILL:` slots; no `"../` paths; every captioned figure/table carries an
  explicit `kind`/`supplement`, so the counters do not collide (Figures 1-4, Tables 1-3).
- **Numbers** — `octave --no-gui --quiet Control/sda-riccati/scripts/verify_sda.m` prints every
  quoted value. Checked there: the closed form solves the CARE (`3.14e-16`); the Cayley image at
  `tau = 1` is symmetric and its solution equals the continuous `P` (`3.33e-16`); the spectrum is
  `0.10998 +- 0.51950i` and `0.39002 +- 1.84237i` with moduli in reciprocal pairs; Table 1's
  explicit/factored errors and the singular `k = 6`; Table 2's `Q_k` entries with exactness
  `<= 3.3e-16` and convergence to `5.0e-16`; the value-iteration log10-error series behind Figure 3;
  Table 3's step counts at `sigma -> 1`; the shift sweep (`tau = 1, 2` fastest at six steps, others
  within two); the push-through identity (`4.8e-17`); and three random `3x3` DAREs where SDA and the
  value iteration agree to `1.5e-15`. Fixed during review: Table 2 originally mixed an exactness
  column with a convergence column (both labelled as the same quantity), and the value-iteration
  step counts depended on the reference used; both now use one stated rule ("the iterate stops
  changing by more than `1e-14` relative to its norm") and the exact closed-form reference.
- **§2 addition (on owner request)** — added the invariance identity `S (I; X_+) = (I; X_+) K`, the
  reduction of the closed-loop state matrix `A - B K_lqr = (I + G X_+)^(-1) A`, and the spectrum
  relation `sigma(S) = sigma(K) u {1/bar-lambda : lambda in sigma(K)}` as Eqs. (9)-(11). The identity
  needs no new number: the script already prints `sigma((I+GP)^{-1}A)` as the inside eigenvalues of
  `S`. Fixed while adding: `lr{...}` renders literally as "lr{...}" in Typst 0.15 (plain `{...}` is
  the brace), and the eigenvalue display's equation number collided, so that display was split over
  two lines. Recompiled and inspected pages 5-6.
- **Explicit kinds** — all four figures now carry `kind: "figure"`/`supplement: [Figure]` as well as
  the three tables, so the counters are explicit rather than defaulted; numbering is Figure 1-4 and
  Table 1-3.
- **Rendered pages** — pages 5, 6 (the §2 addition), 8 (Table 1), 11 (Table 2 and Figure 3) and 13
  (Figure 4) inspected as images in the final layout, and the remaining pages by their extracted text
  and the column check below. Fixed during review: Figure 1
  was re-centred and its dashed-line labels moved off the ray fan; Figure 3's axis label spilled
  into its caption and was moved inside the box; Figure 4's point offsets now use the true
  eigenvalues times the panel scale. Earlier, `bar(lambda)` was rendering as `abs(lambda)`; the
  conjugate accent is `overline(lambda)`.
- **Column overflow** — `.amp/in/scratch/overflow_check.py` reports 0 words outside the text column
  on all 17 pages.
- **Demo** — `Control/sda-riccati/sda-riccati-demo.html` is 94 lines, one inline script, one canvas,
  one range input, one monospace readout, no external asset and no `../`; the inline script parses
  under `node --check`. Driven in Chrome (headless): default `sigma = 0.900` reads
  "value iteration: 263 steps ... doubling: 9 steps", and setting the slider to `0.985` redraws to
  "value iteration: 1829 steps ... doubling: 11 steps", so the control changes the output.
- **Card** — added to `index.html` after the QZ-riccati card with
  `data-category="control algebra optimization"`, `data-field="Control Theory"`, and matching tags
  and pills. Driven in Chrome (headless, offline copy): `#stat-notes` 35, `#cnt-control` 20,
  `#cnt-optimization` 11, `#cnt-algebra` 3; the card is counted in Control, Optimization and Algebra
  and excluded by Tools; searches for `sda` and `doubling riccati` return it, `zzz` returns none;
  `data-tags` equals the visible pills; the card renders in the third grid slot. Its `href` resolves
  to the committed PDF (HTTP 200 from a local server).
- **Deviations** — (i) explicit `kind`/`supplement` on every captioned object; (ii) sections start on
  new pages as the preset supplies, so some tail pages are part-empty; (iii) Figure 1 uses a scalar
  example for drawability, with the matrix case verified numerically; (iv) no index of figures.
- **Could not run** — none.
