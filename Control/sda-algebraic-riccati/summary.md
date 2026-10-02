# Structure-Preserving Doubling for the Algebraic Riccati Equations — teaching handoff

**Stage:** question map (revised to the "show before telling" contract; not yet taught)

**Artifact:** `Control/sda-algebraic-riccati/sda-algebraic-riccati.typ`, compiled to
`Control/sda-algebraic-riccati/sda-algebraic-riccati.pdf`, + `sda-algebraic-riccati-demo.html`.

## Audience

An engineer comfortable with state-space linear systems, the LQR statement, and basic matrix
algebra (products, inverses, eigenvalues, spectral radius). No prior exposure to matrix pencils,
deflating subspaces, or the Cayley transform is assumed: section 4 builds the pencil view only as
far as the question needs, and section 5 introduces the shift as a replacement of the data. The
note does not re-derive the Riccati equation from the cost functional; it states the LQR result and
uses it. It covers the discrete equation (DARE) as the algorithm's native setting and the continuous
one (CARE) through the shift. Intended neighbour: the discrete-time QZ route in this repository.

Revise this as answers arrive: a reader who turns out to lack a prerequisite (e.g. what a deflating
subspace is, or why the gain is read off the stabilizing solution) gets a short backfill question or
a new backfill section, not a narrower question on the same idea.

## Route and assessment

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| `<s1>` | 3 | Which of the several symmetric solutions is the controller, and what property of the closed loop singles it out? | The gain comes from the stabilizing solution — the one whose closed loop `A - GX` has every eigenvalue in the open left half-plane; the selection is by the closed-loop spectrum, not by size or sign. | question-ready |
| `<s2>` | 4 | What fixes the digits each plain step gains, and what would one step have to do to gain the digits of many? | The contraction is fixed by the closed-loop spectrum (the slowest pole for the flow, `sigma = rho((I+GX)^{-1}A)` for the recursion); a step must square that factor. The table's constant digits-per-step columns are the phenomenon. | question-ready |
| `<s3>` | 5 | What identity assembles the `2^(k+1)`-term Stein partial sum from the `2^k`-term one, and what recursion follows? | The halving identity `X_{2^(k+1)} = X_{2^k} + (A^T)^{2^k} X_{2^k} A^{2^k}`; keeping `(A_k = A^{2^k}, Q_k)` gives `A_{k+1}=A_k^2`, `Q_{k+1}=Q_k+A_k^T Q_k A_k`, and `Q_k` equals the plain iterate `X_{2^k}` exactly. The term ladder shows the second half is the first half scaled by `(A^T)^{2^k}`. | question-ready |
| `<s4>` | 6 | Why does the three-line update in `(A_k,G_k,Q_k)` keep the same `X` and square the multiplier? | Squaring the symplectic pencil leaves its deflating subspace fixed and raises the induced operator to the `2^k` power (`K_k = K^{2^k}`); the Schur complement `I+G_kQ_k` is the only inverse, and symmetry of `G,Q` closes the recursion. The table's residual column staying at rounding level is the invariance to explain. | question-ready |
| `<s5>` | 7 | What must the shift preserve for the doubling's guarantee to carry over, and why do a handful of steps suffice? | The shift must preserve the solution set (every CARE solution solves the DARE with the transformed data) and carry the stability region, the open left half-plane to the open unit disk, so the stabilizing solution maps to the stabilizing one; iterating returns `X = lim Q_k` (dual `G_k`) because the multiplier collapses like `sigma^{2^k}`, so ~4–5 `O(n^3)` solves and no eigensolver. | question-ready |
| `<s6>` | 8 | Why is there a best shift `tau`, and what does the doubling become when a multiplier reaches modulus one? | The best `tau` balances the two closed-loop multipliers (`tau = sqrt(2)` here); the extremes push a multiplier toward 1, and at `tau = 1` the bridge fails (`A - tau I` singular). At modulus 1 the odd Jordan block makes squaring only linear (`J^{2^k}` has an off-diagonal `2^k`), so the rate degrades to 1/2 and `I + G_kQ_k` can break down; indefinite `Q` can mean no stabilizing solution. | question-ready |
| `<s7>` | 9 | Sources and further reading | n/a — no external sources consulted yet. | n/a |

`question-ready` = sent, awaiting an attempt; `deepened` = a follow-up, hint, research, or demo was
added; `closed` = the reader named the mechanism *and* applied it to the running example; `skipped`
= bypassed without demonstration and still eligible for a retrieval check. A `partial` answer is not
a resting state — keep the section open until it closes or is skipped.

Running example in one sentence: the continuous LQR plant `A = diag(-1,1)`, `B = [1;1]`,
`Q = diag(1,2)`, `R = 1`, whose stabilizing CARE solution is
`X = [[1/2,-1/2],[-1/2,7/2]]`, `K = B'X = [0,3]`, closed loop `A - GX = [[-1,-3],[0,-2]]`
(open-loop poles `-1,+1`; closed-loop `-1,-2`), and whose shift at `tau = 2` gives the DARE data
`A_0 = [[-2/7,6/7],[1/7,-3/7]]`, `G_0 = [[1/7,3/7],[3/7,9/7]]`, `Q_0 = [[3/7,-2/7],[-2/7,20/7]]`
with multiplier `sigma = 1/3` exactly. The expected answers above are teaching notes and are not
copied into the document.

## Demo

`Control/sda-algebraic-riccati/sda-algebraic-riccati-demo.html` — one canvas, one `tau` slider, one
readout, filed for `<s6>` because "why is there a best `tau`" only becomes attemptable by sweeping
it. It plots the two closed-loop multiplier curves `|(lambda_i + tau)/(lambda_i - tau)|` for
`lambda = -1, -2`, marks the shift at which `A - tau I` is singular, and reads out
`sigma = max`. Its readout reproduces the `sigma(tau)` table exactly at every tabulated `tau`.

## Current discussion point

Nothing taught yet. Entry point is `sda-algebraic-riccati.pdf#page=3` (`<s1>`): *which of the
several symmetric solutions is the controller, and what property of the closed loop singles it
out?* To resume: resend this page link and question, and skip every `closed` section (none yet).

## Unresolved or research-needed claims

- `<s2>` — the closed-loop rate statements (`e^{-2t}` for the flow, `sigma^2` per step for the
  recursion) are shown by the running example; the general statement that the rate is the spectral
  gap is to be grounded in Poloni §2 if the reader asks for a proof.
- `<s4>` — the invariance claim (same `X` at every `k`) and `K_k = K^{2^k}` rest on the
  symplectic-pencil doubling theory (Lin–Xu); the note states them as questions, so a citation is
  needed only if deepened.
- `<s5>` — the shift's starting data and the statement that every CARE solution solves the DARE are
  from Chu–Fan–Lin; verify the exact formulas against the source before presenting them as a proof.
- `<s6>` — the critical-case rate `1/2` (Chiang–Chu–Guo–Huang–Lin–Xu) and the golden-section shift
  heuristic (Chu–Fan–Lin) are not yet sourced; the breakdown/parametrized-repair remark
  (Huang–Kuo–Lin–Shieh) is likewise unsourced.
- The step-count comparisons (SDA 4 vs plain 13 vs flow 710 RK4 steps to `1e-12`) are float64
  results of `scripts/verify_sda_are.py`, not of any external source.

## Sources consulted

None yet; the question map makes no external claims.

## Checks

- build — `typst compile --root . Control/sda-algebraic-riccati/sda-algebraic-riccati.typ` exited 0
  with no warnings; 9 pages (cover, contents, seven sections, one section per page).
- structural — no `FILL:` slots; 7 level-1 headings and 6 `#question` boxes (Sources carries none);
  no answer-revealing `#takeaway`/`#intuition`/`#claim` block; no `../`; section-to-page map
  `3,4,5,6,7,8,9` refreshed.
- answer-free — every section now leads with its visual (Figure 1 pole movement, Table 1 route step
  counts, Figure 2 term ladder, Table 2 `k`-th-problem data, Table 3 the run, Table 4 `sigma(tau)`
  plus the demo), and the revised sections were re-checked against their own setup. Fixes made in
  this pass: `<s2>` table header no longer forward-references an equation; `<s5>` no longer states
  that the shift preserves the CARE solution set or maps the left half-plane onto the unit disk;
  `<s6>` no longer states that squaring fails to push a unit-modulus multiplier inside the disk.
- rendered — pages 3–8 rasterized at 100 dpi and inspected: question boxes, numbered equations,
  Figures 1–2 and Tables 1–4 are placed and nothing is clipped or wider than the text column.
- figures and demo — Figure 1 (pole movement) and Figure 2 (term ladder) inspected as rendered;
  Tables 1–4 read back against `scripts/verify_sda_are.py`; demo 91 lines, one inline script, no
  external reference (ceiling checks pass) and driven control-by-control in a stubbed canvas.
- stage-specific — `scripts/verify_sda_are.py` extended with section K (steps to `1e-4/1e-8/1e-12`
  for the flow and the recursion) and re-run; self-test still `PASS`. Landing card unchanged: its
  `href` still resolves to the compiled PDF and its description still matches the note.
- checks that could not run — no browser on `PATH`, so the demo was parse-checked and driven in a
  stubbed canvas (readout verified against the `sigma(tau)` table) but not rendered as a page.

## Notes

- Intentional deviation: Figures 1–2 and Tables 1–4 carry numbers from the running example and from
  `scripts/verify_sda_are.py` (a float64 run). They present the phenomenon to inspect (pole
  movement, constant digits per step, the doubling ladder, the collapse of `A_k` and `sigma_k`, the
  shape of `sigma(tau)`) and state no conclusion, which the question-map contract permits.
- `sda-algebraic-riccati-demo.html` is the one sanctioned sidecar demo; it stays answer-free (axis
  labels and a readout only, no statement of where the best `tau` is).
- The note replaces the deleted legacy HTML note `Control/sda-algebraic-riccati/sda-algebraic-riccati.html`
  and its landing card; the card points at the compiled PDF.
