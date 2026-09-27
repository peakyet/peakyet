# QZ Algorithm and the Algebraic Riccati Equation — teaching handoff

**Page:** [qz-algebraic-riccati.html](qz-algebraic-riccati.html) · **Category:** Control ·
**Slug:** `qz-algebraic-riccati`
**Script:** [`scripts/verify_qz_riccati.py`](scripts/verify_qz_riccati.py) — pure standard-library
Python (no numpy), run before use. Its `selftest()` runs first on random pencils and the report
prints `self-test verdict: PASS` only if every kernel step is a verified orthogonal equivalence.
Flags: `--section sN`, `--json` (the demo's precomputed table), `--no-selftest`. Full run ~2.5 min.

**Status:** complete draft, all seven sections written, structurally checked, landing card added.
**Renderer:** KaTeX 0.16.11 auto-render (the `templates/note.html` default). One plain note page,
no deck.

## Audience

An engineer comfortable with state-space control and the LQR gain, and with matrix-vector products,
orthogonality and the eigenvalue idea. Assumes no prior exposure to matrix pencils, Schur forms or
the QZ algorithm. The QR iteration note is the intended neighbour: it covers the ordinary Schur form,
which is this note's `N = I` special case. Goal: read a `dgges`/`dtgexc`-style Riccati solve and know
which of its outputs deserves to be trusted.

## Route

| Section | Question it answers | Status |
|---|---|---|
| `#s1` | The DARE is quadratic, so it has several answers and the plant is unstable. What decides which one is the gain, and what object must be computed? | open |
| `#s2` | Where is the linear problem hiding inside the quadratic equation? | open |
| `#s3` | Why not just take two eigenvectors of `N^{-1}L`? | open |
| `#s4` | What does the generalized Schur form give that an eigenvector list does not? | open |
| `#s5` | What are the steps, what do they return here, and what do they cost against iterating the recursion? | open |
| `#s6` | Change one input at a time: which change breaks the answer, which only looks dangerous, and which quantity tells you the difference? | open |
| `#s7` | Sources and further reading | n/a |

Chain: a quadratic equation with four candidate answers and one unstable mode → the optimality
conditions are a linear relation between two matrices, a pencil, and its deflating subspaces are the
answers (all six enumerated in rationals) → eigenvectors fail twice over, `N` singular and the basis
badly conditioned → an orthogonal equivalence of the pencil plus block reordering, with the Claim and
its two hypotheses → the six-step procedure, its answer, its cost, and the recursion's rate → five
single-input changes locating the limits. One need per new idea; nothing introduced before a question
calls for it.

## Running example

`A = [[1/2, 1], [1, 1/2]]`, `B = [1; 1]`, `R = [1]`, `Q = [[1/2, -1/4], [-1/4, 1/2]]`, designed from
the answer `P = I` so every claim is checkable in rationals. Open-loop multipliers `1.5, -0.5`;
`G = [[1, 1], [1, 1]]`; the pencil `L = [[A, 0], [-Q, I]]`, `N = [[I, G], [0, A']]` has
`det(L - zN) = -(3/16)(4z^2 - 1)(z^2 - 4)` with multipliers `2, -1/2, -2, 1/2`; the answers are
`K = [1/2, 1/2]` and closed loop `[[0, 1/2], [1/2, 0]]`. Section 6 changes one input at a time and
keeps this same construction.

## Current discussion point

Nothing taught yet — this is the first handoff. Entry point is
[`#s1`](qz-algebraic-riccati.html#s1): *the equation is quadratic and the plant is unstable, so what
decides which answer is the gain, and what kind of object do we have to compute?* Teach one section at
a time from its `#sN` anchor; the chat carries the deep link and the question, not a parallel lesson.

## Numbers on the page (all from `scripts/verify_qz_riccati.py`)

- **§1:** `P = I`, `K = [1/2, 1/2]`, DARE residual at `P` exactly `0` in rationals.
- **§2:** `det L = det N = det A = -3/4`; all six 2-of-4 selections solved exactly: `{2, -1/2}` gives
  `X = [[7/16, -9/16], [-9/16, 7/16]]`, `K = [-1/4, -1/4]`, `max|T| = 2`; `{-1/2, 1/2}` gives `X = I`,
  `max|T| = 1/2`; the other four have `det V1 = 0` exactly and are not graphs.
- **§3(a):** singular plant `A = [[3/4, 3/4], [3/4, 3/4]]`, `det N = det A = 0`, `det(L - zN)` cubic
  (one multiplier at infinity); the exact pair `{0, 1/2}` gives `|X - P| = 0`.
- **§3(b):** family `M = [[1/2, c], [0, 49/100]]` with `X = I` for every `c`; `kappa(V4)` up to
  `3.53e3`, `sin(graph)` down to `1e-4`, both error columns tracking `eps/sin`.
- **§4:** HT 875 units, six sweeps 3664 units, equivalence `2.0e-15`/`1.5e-16`, orthogonality
  `1.0e-15`; five swaps with chordal gaps `1.0, 0.6, 0.6, 1.0, 0.8`; `|det R11| = 1.875`,
  `|det V11| = 0.500`; `|V11 T V11^{-1} - M| = 6.9e-15` against `|T - M| = 0.5`.
- **§5:** `X = I` to `3.3e-15`, residual `4.1e-15`, `K = [0.5, 0.5]`, closed loop `0.500, 0.500`; cost
  rows `n = 2..20` (sweeps 6..524, sweep units `3.7e3..1.0e7`, `|X - P|` at most `4.1e-12`); the
  Riccati recursion from `X = 0` converges linearly with ratio `0.2500 = rho(M)^2`, 22 steps for
  `1e-12`.
- **§6(a):** `Q = diag(0, q2)` double integrator; `X = diag(0, x)` with
  `x = (q2 + sqrt(q2^2 + 4 q2))/2` (float agreement `8.1e-14`), `K = [0, x/(1+x)]`, closed loop
  `1/(1+x)` and `1` exactly; residuals at `1e-16` throughout while the multiplier gap is `0` to
  `6.7e-16`.
- **§6(b):** `1e-13` diagonal noise on the `q2 = 0` pencil: moduli move by `1.49e-8`, and the count
  strictly inside the disk comes out `2, 2, 2, 2, 0, 1` over six draws; the `0` draw refuses
  (`ok = False`).
- **§6(c):** `diag(1/2, 1/2 + eps)` down to `eps = 1e-15`: gap `5.8e-16`, nothing refuses, every row
  `ok = True`, `|X - P|` between `4.7e-16` and `2.7e-13`.
- **§6(d):** Jordan pencil `M = [[1/2, eta], [0, 1/2]]`, multipliers `1/2, 1/2, 2, 2` for every `eta`;
  `dim ker(L - zN)` is 2 at `eta = 0` and 1 at `eta = 1` (exact). Only `eta = 0` reorders. `eta = 1`
  refuses and returns a *different* valid DARE solution: residual `8.7e-15`, `|X - P| = 5.766`, closed
  loop `2.000, 2.000`. At `eta = 1e-6`: `|X - P| = 1.17e12`, residual `2.1e11`.
- **§6(e):** `|X - X'| = 3.22e-15` on the running example; at `c = 100`, `2.13e-12` against
  `|X - P| = 6.64e-10` and residual `2.15e-8`.
- Scale limit quoted in §6: `n = 24` (48x48 pencil) burns all 960 allowed sweeps, leaves 24 blocks of
  size 2, makes 0 swaps, `ok = False`, `|X - P| = 7.2e15` in about 54 s.
- **Demo (§2):** the four-multiplier selection widget is driven by `--json`, all six choices
  precomputed in rationals; nothing is fitted at display time.

## Sources → claims

| Read | Grounds |
|---|---|
| Moler & Stewart, *An Algorithm for Generalized Matrix Eigenvalue Problems*, SIAM J. Numer. Anal. 10(2) (1973) 241-256, [10.1137/0710024](https://doi.org/10.1137/0710024) — abstract read | the three stages (HT reduction, double-shift sweeps, no inversion of `N` or its subblocks); "reduces to [QR] when B = I"; attention to degeneracies when `N` is singular (§3a, §4, §5 steps 1-3) |
| Van Dooren, *A Generalized Eigenvalue Approach for Solving Riccati Equations*, SIAM J. Sci. Stat. Comput. 2(2) (1981) 121-135, [10.1137/0902010](https://doi.org/10.1137/0902010) — abstract read | orthonormal bases for any deflating subspace of a regular pencil, ordering imposed after the factorization (§4 Claim, §5 steps 4-6) |
| Laub, *A Schur method for solving algebraic Riccati equations*, IEEE TAC 24(6) (1979) 913-921, [10.1109/TAC.1979.1102178](https://doi.org/10.1109/TAC.1979.1102178); and *Invariant Subspace Methods for the Numerical Solution of Riccati Equations*, in *The Riccati Equation* (Springer, 1991) 163-196, [10.1007/978-3-642-58223-3_7](https://doi.org/10.1007/978-3-642-58223-3_7) | the invariant-subspace statement of the problem that §2 formalizes and §5 turns into a procedure |
| Lancaster & Rodman, *Discrete Algebraic Riccati Equations and Matrix Pencils*, ch. 16 of *Algebraic Riccati Equations* (Oxford, 1995) 331-344, [10.1093/oso/9780198537953.003.0015](https://doi.org/10.1093/oso/9780198537953.003.0015) — chapter abstract read, quoted verbatim | §2's pencil and §3(a): dropping the invertibility of `A` via the `J`-unitary pencil, and the eigenvalue at infinity "which cannot arise in a classical eigenvalue problem" |
| Kågström, *A Direct Method for Reordering Eigenvalues in the Generalized Real Schur form of a Regular Matrix Pair (A, B)*, in *Linear Algebra for Large Scale and Real-Time Applications* (Springer, 1993) 195-218, [10.1007/978-94-015-8196-7_11](https://doi.org/10.1007/978-94-015-8196-7_11) | the adjacent-block exchange as its own numerical problem, and when not to attempt it (§4 stage 3, §5 step 4, §6c-d) |
| Camps, Mastronardi, Vandebril & Van Dooren, *Swapping 2x2 blocks in the Schur and generalized Schur form*, J. Comput. Appl. Math. 373 (2020) 112274, [10.1016/j.cam.2019.05.022](https://doi.org/10.1016/j.cam.2019.05.022) | why a `2x2` diagonal block is the awkward unit of a real-arithmetic reordering (§4 "a sweep can be silent", §6d refused splits) |
| Byers & Benner, *A structure-preserving method for generalized algebraic Riccati equations based on pencil arithmetic*, ECC 2003, 957-962, [10.23919/ECC.2003.7085082](https://doi.org/10.23919/ECC.2003.7085082) | the structure-preserving alternative named in §6(e) |
| *Structure-Preserving Doubling Algorithms for Nonlinear Matrix Equations*, SIAM, 2018, ch. 3-4, [10.1137/1.9781611975369.ch3](https://doi.org/10.1137/1.9781611975369.ch3) and [ch. 4](https://doi.org/10.1137/1.9781611975369.ch4) | the doubling family behind the quadratic-convergence aside at the end of §5. Cited by title: CrossRef returns no author metadata for the record |
| Reference LAPACK [`dtgexc.f`](https://github.com/Reference-LAPACK/lapack/blob/master/SRC/dtgexc.f) — source read | the refusal wording: `INFO = 1` means the exchange "would be too far from generalized Schur form; the problem is ill conditioned" (§4, §6d) |

Suggested further reading, labelled on the page as not consulted: Golub & Van Loan, *Matrix
Computations*, 4th ed.; Stewart, *Matrix Algorithms II: Eigensystems*; Higham, *Accuracy and Stability
of Numerical Algorithms*, 2nd ed. Cross-linked in-repo:
[`Algebra/qr-iteration`](../../Algebra/qr-iteration/qr-iteration.html) (§4 cost aside, §7).

## Unresolved gaps

- §6(b)'s amplification is reported as measured (`1e-13` of data moves a modulus by `1.49e-8`); the
  page says "not Lipschitz at a multiple root" and does not prove an exponent.
- The infinite-multiplier deflation §3(a) needs is described but not implemented in this kernel; the
  page discloses that the float pipeline *refuses* there and that the exact result is a statement
  about the pencil, not about the sweeps.
- `dhgeqz.f` internals were not read; only `dtgexc.f`'s `INFO` contract is quoted, and no LAPACK source
  is cited for the sweep arithmetic itself.
- The stabilizing-solution theory (existence, uniqueness, detectability) is tested numerically and
  nowhere proved; §6(a) demonstrates the failure mode rather than stating the theorem.
- No continuous-time (CARE / Hamiltonian) treatment, and no large-scale or low-rank route beyond
  naming it.

## Checks

- `python3 scripts/verify_qz_riccati.py` run in full three times before use: `self-test verdict: PASS`
  (21 kernel checks on random pencils, `n = 3..6`, 8 cases, each step verified as an orthogonal
  equivalence). Every number on the page was re-read off that report; the §6(a) closed form plus gain
  and closed-loop rows, and the §6(d) nullspace dimensions, were added to the script and re-run rather
  than asserted. The §6 block was byte-identical across runs; only the wall-clock seconds in §5 moved
  (0.19-0.20, 3.27-3.28, n=24 54.4-54.6 s), so the page now quotes the last run and says the seconds
  vary.
- `grep -n 'FILL:'` empty; nav anchors and heading ids match exactly (7 each); 7 sections, 6 visible
  `Question:` callouts (§7 legitimately has none); the only `../` references are the two intentional
  cross-links to `../../Algebra/qr-iteration/`, which is how this repo links across categories.
- The demo script was extracted and driven under a stubbed DOM and canvas through all 16 checkbox
  states: no exceptions, no non-finite geometry, and each two-tick state reproduces the exact table on
  the page (`{2,-1/2}` gives det `−16`, `K = [-1/4, -1/4]`, "graph, unstable"; four states report "not a
  graph"). The rendered canvas and metrics were then re-checked in the browser at the default state.
- Headless Chrome captures at 1440 (page height 20723 px) and 420 (about 31100 px), inspected band by
  band:
  math renders, Figure 3's dots sit on the `|z| = 1` rule with no label collisions, the five §6 tables
  scroll inside `.table-wrap` on mobile, and nothing clips. `--screenshot` with a `#s6` fragment
  captured a blank viewport (Chrome does not scroll for it), so anchors were verified structurally and
  by cropping the full-page render instead of by a deep-link capture.
- Landing card, probed in the browser against the live filter code: default counts `31 notes · 7
  fields`, `cnt-algebra = 2`, `cnt-control = 16`; the card is shown for queries "riccati", "qz",
  "generalized schur", "deflating subspace", "lqr pencil", "riccati qz schur" (multi-token AND) and
  hidden for a bogus token; the algebra and control chips include it, robotics and tools exclude it;
  `data-field` equals the `.foot` text and `data-tags` equals the visible pills exactly.
- `python3 -m http.server` on a loopback port: `index.html`, the note and the cross-linked QR note all
  return 200 (needed an unsandboxed run; the sandbox blocks listening).
- **Unavailable:** `firefox` is not installed on this machine, so every capture is headless Chrome
  (`google-chrome-stable`). Layout was not cross-checked against a second engine.

## Notes

- Deviations from the template, all additive: the interactive demo sits in §2 rather than §5 (the
  selection demo is what carries that argument, and §5 got a run-command block instead), three
  figures rather than two, and §6 runs (a)-(e) instead of one varied case, because the point of the
  section is that different conditions fail differently.
- The page is ASCII-only, uses `&mdash;` / `&ndash;` / `&hellip;` entities instead of literal Unicode,
  and US spelling, matching the other notes in the series.
- All arithmetic is the script's own: a standard-library QZ (HT reduction, double-shift sweeps,
  rehearsed `2x2` splits, adjacent-block swaps) plus an exact rational pencil solver for the cases
  where float should not be trusted.
