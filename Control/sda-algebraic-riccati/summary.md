# SDA and the Algebraic Riccati Equation — teaching handoff

**Page:** [sda-algebraic-riccati.html](sda-algebraic-riccati.html) · **Category:** Control ·
**Slug:** `sda-algebraic-riccati` (card chips `control algebra`)
**Script:** [`scripts/verify_sda_are.py`](scripts/verify_sda_are.py) — pure standard-library
Python 3, no numpy, no install step. Flags: `--json` (machine-readable numbers), `--selftest`.
Full run ~1 s.
**Status:** complete draft, all seven sections written, structurally checked, landing card added.
**Renderer:** KaTeX 0.16.11 auto-render (the `templates/note.html` default). One plain note page.

## Audience

An engineer comfortable with state-space linear systems, the LQR statement, and basic matrix
algebra (products, inverses, eigenvalues). No prior exposure to matrix pencils, deflating
subspaces or the Cayley transform is assumed: §4 builds the pencil view only as far as the Claim
needs, and §5 introduces the transform as bookkeeping. The note does *not* re-derive the Riccati
equation from the cost functional — it states the LQR result and uses it. Intended neighbour:
`Control/qz-algebraic-riccati`, which solves the discrete-time Riccati equation directly from a
generalized Schur form; this note is the iterative alternative and cross-links to it in §1, §6, §7.

## Route

| Section | Question it answers | Status |
|---|---|---|
| `#s1` | Which solution of the quadratic Riccati equation is the controller, and what object must be computed? | open |
| `#s2` | Why not just iterate the equation, or integrate the Riccati flow? | open |
| `#s3` | In what smallest case is "square the error" an identity, and what does it become for Riccati? | open |
| `#s4` | Why does a three-line update that never mentions \(X\) leave the answer alone? | open |
| `#s5` | How does a continuous-time plant get into the doubling, and what comes out? | open |
| `#s6` | Change the shift, then change \(\sigma<1\): what breaks first? | open |
| `#s7` | Sources and further reading | n/a |

Chain: an unstable mode whose LQR gain needs one specific solution of a quadratic matrix equation →
both obvious iterations (flow and fixed-point recursion) buy a fixed number of digits per step →
squaring a partial sum is exact on the Stein equation, and on the Riccati equation it becomes a
three-line update in the data → the reason is that the update squares the pencil without moving its
deflating subspace → a Cayley shift moves the CARE into that discrete setting, and five doublings
finish the example → one knob (\(\tau\)) and one hypothesis (\(\sigma<1\)) locate the limits. Six
visible questions for seven headings: §7 legitimately carries none.

## Running example

Continuous-time LQR with `A = diag(-1, 1)` (one decaying mode, one growing mode), `B = [1; 1]`,
`Q = diag(1, 2)`, `R = 1`, so `G = BB' = ones(2,2)`. Stabilizing solution and gain

- `X = [[1/2, -1/2], [-1/2, 7/2]]`, `K = B'X = [0, 3]`, `A - GX = [[-1, -3], [0, -2]]`
  (open-loop poles `-1, +1`; closed-loop poles `-1, -2`), CARE residual exactly `0` in rationals.

Cayley bridge at `tau = 2`: `A0 = [[-2/7, 6/7], [1/7, -3/7]]`,
`G0 = [[1/7, 3/7], [3/7, 9/7]]`, `Q0 = [[3/7, -2/7], [-2/7, 20/7]]`, transformed closed loop
exactly `[[-1/3, 1], [0, 0]]`, so `sigma = 1/3` exactly and the k-th contraction is
`3^(-2^k)`. Every number on the page comes from this one example plus the (cited) critical-case
mechanism in §6.

## Current discussion point

Nothing taught yet — this is the first handoff. Entry point is
[`#s1`](sda-algebraic-riccati.html#s1): *the gain is one particular solution of a quadratic matrix
equation, and the question is what to compute and with what.* Teach one section at a time from its
`#sN` anchor; the chat carries the deep link and the question, not a parallel lesson.

## Numbers on the page (all from `scripts/verify_sda_are.py`)

- **§1:** `X`, `K = [0,3]`, exact CARE residual `[[0,0],[0,0]]`; open-loop eigenvalues `+1, -1`;
  closed-loop `-1, -2`; `X` eigenvalues `3.5811, 0.4189`.
- **§2:** Riccati flow, RK4 with `dt = 0.02`, 1300 steps: digits `3.16, 6.63, 10.10, 13.58, 14.88`
  at `t = 4, 8, 12, 16, 20`; `1e-12` reached at `t = 14.20` (step 710, ~2840 Riccati-map
  evaluations); measured rate `~0.87` digits per unit time against the predicted `e^{-2t}`.
- **§3:** SDA on the transformed data, `k = 0..5`: `||A_k||_F = 1.01, 3.9e-1, 4.4e-2, 5.4e-4,
  8.2e-8, 1.9e-15`; digits of `Q_k` `0.70, 1.60, 3.50, 7.32, 14.91, 15.9`; measured multiplier
  equals `3^(-2^k)` at every `k` (`3.3e-1, 1.1e-1, 1.2e-2, 1.5e-4, 2.3e-8, 5.4e-16`); `X` still
  solves the Riccati equation with data `(A_k, G_k, Q_k)` (residual `<= 5e-16`); `Q_k` matches the
  `2^k`-th plain iterate to `<= 4.5e-16`; `||K_k - K_0^(2^k)|| <= 2e-29` for `k <= 5`.
- **§3 baby case (Stein):** squared Smith `Q_k` equals the explicit `2^k`-term sum to
  `<= 4.4e-16` for `k <= 6`, with `rho(A) = 0.688` so plain partial sums gain `0.33` digits/step.
- **§5:** steps to `1e-12`: SDA `4`, plain fixed point `13`, Riccati flow `710` RK4 steps;
  `|X - Q_4| = 4.4e-15`, CARE residual at `Q_4` `8.6e-15`, residual at the exact `X` `1.9e-16` in
  float64 and exactly `0` in rationals.
- **§6:** `sigma(tau) = 0.778, 0.600, -, 0.172, 0.333, 0.600, 0.778, 0.882, 0.939` for
  `tau = 0.25, 0.5, 1, sqrt2, 2, 4, 8, 16, 32` (no bridge at `tau = 1` because `A` has an
  eigenvalue at `+1`); SDA steps to `1e-12`: `6, 5, -, 4, 4, 5, 6, 7, 8`; plain steps:
  `58, 29, -, 9, 13, 28, 57, 114, 227`; interior optimum at `tau = sqrt(2)` with
  `sigma = 3 - 2*sqrt(2) = 0.17157`. Critical-case mechanism: `||J^(2^k)||_F` for a unit-modulus
  `2x2` Jordan block runs `1.732, 2.449, 4.243, 8.124, 16.062, ...` against `2^k`.
- **Self-test:** 24 random discrete-time Riccati problems, `n = 2..4`: SDA iterate equals the
  `2^k`-th fixed-point iterate, `X` still solves every doubled problem, residuals below `1e-8`;
  `self-test verdict: PASS`.

## Unresolved gaps

- The critical case (§6) is **cited, not computed**: `||J^(2^k)||_F ~ 2^k` is verified here as the
  mechanism, but no Riccati instance with a genuine unit-circle multiplier is constructed on the
  page. The rate-`1/2` statement is Chiang et al. (2009) as reported by Poloni §4.2.
- Lin and Xu (2006) is cited for the doubling transformation and the convergence theory; only its
  abstract and result statement were read, not the proofs, and the note says so.
- The `tau` heuristic (golden-section search) is attributed via Poloni §5.2 to Chu, Fan and Lin
  (2005), whose paper itself was not obtained.
- Breakdown of `I + G_k Q_k` is stated and cited (Huang, Kuo, Lin and Shieh 2024); no breakdown
  instance is exhibited.
- Large-scale low-rank variants (dSDA with truncation) are named as an alternative only; they are
  outside this note's scope.
- The note does not re-derive the LQR result, the existence/uniqueness of the stabilizing solution
  (Lancaster–Rodman), or the symplectic eigenvalue pairing; all three are stated as facts.

## Sources → claims

| Read | Grounds |
|---|---|
| F. Poloni, *Iterative and doubling algorithms for Riccati-type matrix equations: a comparative introduction*, GAMM-Mitt. 43 (2020), doi:10.1002/gamm.202000018, arXiv:2005.08903v1 — §2 (Stein, squared Smith, linear rate of the plain iterations), §4.2 (eq. 23–35: the discrete update, `Q_k = X_{2^k}`, the ratio `sigma`, the critical rate `1/2`), §5 (eq. 37–43: the CARE, the Cayley transform, the shift's dangers) | the DARE/CARE statements, the plain iteration and its rate, the three-line SDA map, `Q_k = X_{2^k}`, `K_k = K^(2^k)`, the critical-case rate, the Cayley bridge and the `tau` warning (Sections 2–6) |
| Z.-C. Guo, E. K.-W. Chu, X. Liang, W.-W. Lin, *A decoupled form of the structure-preserving doubling algorithm with low-rank structures*, arXiv:2005.08288 — §1–2, eq. (4) SDA recursions, eq. (5) Cayley starting data, and the `A_k -> 0, G_k -> Y, Q_k -> X` statement | the exact form of the update used in §3, the starting data in §5, and the convergence wording in §3/§6 |
| W.-W. Lin, S.-F. Xu, *Convergence analysis of structure-preserving doubling algorithms for Riccati-type matrix equations*, SIAM J. Matrix Anal. Appl. 28(1):26–39, 2006, doi:10.1137/040617650 — abstract and result statement | the name and nature of the doubling transformation for symplectic pencils, and that a unified convergence theory exists for the Claim in §4 (§4, §7) |
| C.-Y. Chiang, E. K.-W. Chu, C.-H. Guo, T.-M. Huang, W.-W. Lin, S.-F. Xu, *Convergence analysis of the doubling algorithm for several nonlinear matrix equations in the critical case*, SIAM J. Matrix Anal. Appl. 31(2):227–247, 2009, doi:10.1137/080717304 — result statement | convergence at least linear with rate `1/2` in the critical case (§6) |
| E. K.-W. Chu, H.-Y. Fan, W.-W. Lin, *A structure-preserving doubling algorithm for continuous-time algebraic Riccati equations*, Linear Algebra Appl. 396:55–80, 2005, doi:10.1016/j.laa.2004.10.010 — metadata | the CARE algorithm and the golden-section shift heuristic, as reported in Poloni §5.2 (§5, §6) |
| E. K.-W. Chu, H.-Y. Fan, W.-W. Lin, C.-S. Wang, *Structure-preserving algorithms for periodic discrete-time algebraic Riccati equations*, Int. J. Control 77(8):767–788, 2004, doi:10.1080/00207170410001714988 — metadata | the modern attribution of the discrete-time doubling algorithm, via Poloni §4.2 (§3, §7) |
| B. D. O. Anderson, *Second-order convergent algorithms for the steady-state Riccati equation*, Int. J. Control 28:295–306, 1978, doi:10.1080/00207177808922455 — abstract | the earliest cited source for the doubling idea and its system-theoretic meaning (§7) |
| T.-M. Huang, Y.-C. Kuo, W.-W. Lin, S.-F. Shieh, *Structure-preserving doubling algorithms that avoid breakdowns for algebraic Riccati-type matrix equations*, SIAM J. Matrix Anal. Appl. 45(1):59–83, 2024, doi:10.1137/23M1551791 — abstract | the breakdown of `I + G_k Q_k` and the parametrized repair (§6) |

Suggested further reading, labelled on the page as not consulted: Lancaster & Rodman, *Algebraic
Riccati Equations* (OUP, 1995); Chiang, Chu & Lin, *Structure-Preserving Doubling Algorithms for
Nonlinear Matrix Equations* (SIAM, 2018, ISBN 978-1-611975-35-2). In-repo companion:
[`Control/qz-algebraic-riccati`](../qz-algebraic-riccati/qz-algebraic-riccati.html) (§1, §6, §7).

## Checks

- `python3 scripts/verify_sda_are.py` run before use; the random-problem self-test reports
  `self-test verdict: PASS` (24 problems, `n = 2..4`, iterates matched, invariance and residuals
  checked). Every number quoted above was re-read from that report rather than asserted.
- Structure: `grep -n 'FILL:'` empty; nav anchors and heading ids match exactly (diff empty,
  7 and 7); 7 headings, 6 visible `Question:` callouts (§7 has none); the only `../` references
  are the three intentional cross-links to `Control/qz-algebraic-riccati`.
- The demo script was exercised headlessly over every `tau` on its slider and `k = 0..5`:
  no exceptions, the canvas repaints, and the metrics at `tau = 2` reproduce the §3 table's digits
  (`0.70, 1.60, 3.50, 7.32, 14.91, 15.9`) with `sigma = 0.33333` and `max|X - Q_k| = 4.9e-16`.
  One bug found this way (`Xk` initialised as a 1x2) and fixed before shipping; the demo's step
  association order was then aligned with the script's so the two agree.
- Rendering, headless Chrome (`google-chrome-stable`) at 1440 and at 500 (the narrowest layout
  width this browser window honours; a 420 window still laid out at 485 px, so the 500 px capture
  is the honest narrow check): KaTeX renders, all three figures and the canvas draw, no document
  overflow (`scrollWidth == clientWidth`), and the scrollable `.eq`, `.table-wrap` and `pre`
  containers are the only elements wider than their box, which is the template's intended design.
- Landing page, probed in the browser against the live filter code: `32 notes · 7 fields`,
  `cnt-algebra = 3`, `cnt-control = 17`; the card appears for `doubling`, `sda riccati`,
  `riccati care` and is hidden for a bogus token; the algebra and control chips include it,
  robotics and tools exclude it; `data-field` equals the `.foot` text and `data-tags` equals the
  11 visible pills exactly.
- **Unavailable:** `firefox` is not installed, so every capture is headless Chrome and the layout
  was not cross-checked in a second engine. Chrome does not scroll to `#fragment` for
  `--screenshot`, so `#s5` was verified structurally (anchor present, in `nav.toc`, in order) plus
  by cropping the full-page render, not by a deep-link capture.

## Notes

- Deviations from `templates/note.html`, all additive and deliberate: three figures rather than
  two; two `table-wrap` tables (the §3 convergence rows and the §6 `tau` sweep); a `pre` listing of
  the algorithm; and a demo placed in §5 with **two** controls (`k` and `tau`) rather than one,
  because the shift is the section's other variable. The template's stylesheet, sticky TOC markup
  and scroll-spy script are unchanged.
- The page is ASCII-only apart from `&mdash;`-style entities and the figures' short SVG labels, and
  uses US spelling, matching the other notes in the series.
- All arithmetic is the script's own: exact `Fraction` arithmetic for the example and the Cayley
  data (residual exactly zero), float64 for the iterations, the flow and the random self-test.
