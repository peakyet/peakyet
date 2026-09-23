# Current understanding: the Francis QR step and the QR algorithm

**Page:** [francis-qr-step.html](francis-qr-step.html) · **Category:** Algebra · **Slug:** `francis-qr-step`
**Script:** [`scripts/verify_francis_qr.py`](scripts/verify_francis_qr.py) — dependency-free Python,
`--json` emits the bulge-chase snapshots for the in-page demo.

**Status:** DRAFT. Section 1 is built and taught; sections 2–6 are outlined on the outline
frame but their frames are not written yet. The deck is **not** on `index.html` yet.

**Theme:** `data-theme="beamer"` — the classic blue theme, per the user's explicit choice
(the deck was first drafted in `paper` and the user asked for blue). The skill's default is
now beamer; see "Skill changes" below.

**Audience:** an engineer comfortable with eigenvalues, similarity transformations, and
matrix–vector products, who has never studied the QR iteration. Target: be able to read or
modify eigenvalue code (`dhseqr`/`dlahqr`-style) after the deck.

**Supersedes:** a long-form note `Algebra/francis-qr-step/` that was deleted in commit
`2218f05` (it covered the same standard-QR material; its `verify_francis.py` and
`francis_step.m` were never committed, so none of its numbers were reproducible). The
deleted `Algebra/francis-qz-step/` deck covers the *generalized* problem and is the
follow-on, not a duplicate.

## Section → frame map

| # | Section | Frames | Status |
| --- | --- | --- | --- |
| 1 | Why eigenvalues need their own algorithm | `#/3`–`#/8` | **built, gate passed** |
| 2 | The QR step, and why it is too slow | `#/9`–`#/13` | **built, awaiting gate** |
| 3 | Hessenberg form and the implicit Q theorem | `#/14`– (planned) | outlined only |
| 4 | The Francis double shift | planned | outlined only |
| 5 | Chasing the bulge, deflating, and where it breaks | planned | outlined only |
| 6 | Closing: connections and sources | planned | outlined only |

Frame roles in section 1: `#/3` divider (question + mental model), `#/4` the three routes and
their failure mode, `#/5` power iteration on the running example + the sensitivity ceiling,
`#/6` what the algorithm promises, `#/7` the running example and the Schur-form target,
`#/8` prediction prompt + takeaway.

Frame roles in section 2: `#/9` divider, `#/10` the step defined and applied once to `H0`,
`#/11` the mechanism (`A^k = Q_k R_k`, power iteration on a basis, Figure 3 schematic),
`#/12` the rate law with the measured table and Figure 4, `#/13` prediction prompt + takeaway.

### Section 2 — numbers on the frames

All from `scripts/verify_francis_qr.py`.

| Quantity | Value |
| --- | --- |
| Eigenvalue moduli of `C`, descending | `10, 2.828427, 2.828427, 2` |
| Predicted rate for `\|h(2,1)\|` | `2.828427/10 = 0.282843` |
| Predicted rate for `\|h(4,3)\|` | `2/2.828427 = 0.707107` |
| Predicted rate for `\|h(3,2)\|` | `2.828427/2.828427 = 1.0000000000` — no decay |
| Measured geometric-mean ratios, `k=2..12` | `r21 = 0.284683`, `r43 = 0.713996` |
| `H1` (one unshifted step from `H0`) | rows `[8, 4.29598, 1.43758, −0.10621]`, `[4.53137, −0.05195, −1.32192, −0.04688]`, `[0, 1.95643, −1.94833, 0.87892]`, `[0, 0, −0.88655, −1.99972]` |
| Subdiagonals `H0 → H1` | `5.385165 → 4.531372`, `3.111866 → 1.956426`, `1.174368 → 0.886552` |
| Trace preserved | `4.000000` both times |
| `\|h(3,2)\|` after 200 sweeps | still `2.000000` (while `\|h(2,1)\| = 3.5e−109`) |
| Sweeps for `\|h(2,1)\|, \|h(4,3)\| < 1e−14` | unshifted **94** |

### Section 2 — calibration evidence

- **Prediction (`#/13`) — pending.** The prompt asks whether `|h(3,2)|` is stuck merely
  because 15 sweeps is too few; the frame's answer is that its rate is exactly 1.
- The gate for section 2 has not yet been run. The explain-back to ask for: why the
  *number* of sweeps is not the thing to fix, and which two separate defects (cost per sweep,
  rate) sections 3 and 4 address.

### Section 1 — calibration evidence

Prerequisite map for section 1: similarity and `det(A−λI)=0` assumed comfortable (confirmed —
the user reproduced `A'=RQ=QᵀAQ` unprompted); power iteration and backward stability taught
briefly on the frames.

- **Prediction (`#/8`) — correct.** "A' and A have the same eigenvalue since A' = QᵀAQ which is
  the similarity." Follow-up given in the terminal: the identity only collapses to a similarity
  because QR makes `Q` orthogonal, so `Qᵀ = Q⁻¹`; without that, `RQ` has no reason to share a
  spectrum. No frame edit needed — `#/8` already says *orthogonal* similarity.
- **Explain-back (`#/4`) — correct, two sharpenings given.** "Route 1 only gives a
  characteristic polynomial, which is hard to solve when the degree n is large; Route 2 only
  gives the eigenvector of the biggest modulus eigenvalue, but we need all n eigenvalues."
  Sharpened on: (i) route 1's cost is not the whole objection — it substitutes a different
  problem (polynomial root-finding) and discards the matrix, which is the frame's actual claim;
  (ii) power iteration returns the eigenvalue as well as the eigenvector (the Rayleigh quotient
  on `#/5` walks to 10); the limitation is *one* eigenvalue, the largest in modulus, out of `n`.
- No misconception traced back to a frame, so no frame was rewritten.

## Prerequisite map

| Topic | Calibration status | Treatment |
| --- | --- | --- |
| Eigenvalues, similarity transformations, `det(A−λI)=0` | assumed comfortable | recalled in section 1 |
| Householder reflectors, orthogonal elimination, Hessenberg reduction | **taught elsewhere** — link, do not repeat | `#/1` title frame links to [householder-transformations](../householder-transformations/householder-transformations.html) §6–§8 |
| Power iteration | taught briefly | `#/4`, `#/5`, with measured convergence |
| Real Schur form and 2×2 blocks | taught briefly | `#/6`, `#/7` |
| Backward stability | taught briefly | `#/6`, grounded on a measured sensitivity |
| Hessenberg form, bulge chasing, implicit Q theorem | main topic | sections 2–4 |
| Deflation, shift strategy, multishift/AED | main topic | section 5 |

## Running example

The 4×4 circulant `C = circ(1,2,3,4)`:

```
C = [[1,2,3,4],
     [4,1,2,3],
     [3,4,1,2],
     [2,3,4,1]]
```

Circulant ⇒ the DFT diagonalises it, so the eigenvalues are known in closed form:
`λ ∈ {10, −2, −2+2i, −2−2i}`. `trace C = 4 = Σλ`. Chosen because it carries **both** block
kinds the algorithm must produce: a real eigenvalue (→ 1×1 block) and a complex conjugate
pair (→ 2×2 block).

Verified values (all from `scripts/verify_francis_qr.py`):

| Quantity | Value |
| --- | --- |
| `det(C − λI)` | `λ⁴ − 4λ³ − 44λ² − 144λ − 160` |
| Hessenberg form `H0` (Householder) | rows `[1, −4.64238, −2.71616, 0.26595]`, `[−5.38516, 6.37931, 1.42755, −0.44446]`, `[0, 3.11187, −1.38520, 1.05398]`, `[0, 0, −1.17437, −1.99411]` |
| `|h(i+1,i)|` of `H0` | `5.385165, 3.111866, 1.174368` |
| Hessenberg defect after reduction | `5.876e−16` |
| Power iteration on `C` (start `(1,2,4,7)`) | error ratio `0.0779 ≈ (2.828/10)²` per step; converges to `10` only |
| Sensitivity demo `[[1,1000],[0,1]]`, `a21: 0 → 1e−16` | eigenvalues move to `1 ± 3.162e−07` |
| Shifts from trailing 2×2 of `H0` | `−1.6896551724 ± 1.0700772862i`; `s = −3.3793103448`, `t = +4.0000000000` (both real) |
| Implicit vs explicit double shift | `‖D·H_exp·D − H_imp‖_F = 9.3e−15`, `D = diag(1,1,1,−1)`; diagonals agree to `0` |
| `Q e1` parallel to `p(H) e1` | max cross-product `1.066e−14` |
| Bulge walk on `H0` (1-based) | `(3,1),(4,1),(4,2)` → `(4,2)` → none |
| Steps to `|h(2,1)|, |h(4,3)| < 1e−14` | unshifted **94**, Wilkinson **20**, Francis double **10** |
| Converged real Schur form (10 steps) | 1×1 `[10]`, 2×2 `[−2±2i]`, 1×1 `[−2]`; `|h(3,2)| = 2.000` (the 2×2 block's own subdiagonal) |
| Flops per double-shift step | `n=8: 2632 vs 960`; `n=16: 20912 vs 4224`; `n=32: 165248 vs 17664`; `n=64: 1311872 vs 72192` (explicit vs implicit) |

## Claims verified by running code

`python3 scripts/verify_francis_qr.py` (stdlib only; the numbers above are its output):

- the Hessenberg reduction is a similarity — trace preserved to 12 digits, defect `5.9e−16`;
- the shift pair is complex conjugate, and `s`, `t` are real;
- the implicit bulge chase equals the explicit `p(H)` double shift up to the ±1 column
  signature the Implicit Q theorem leaves free, and `Q e1 ∥ p(H) e1`;
- `Q` is orthogonal (`6.4e−16`) and `QᵀH Q = H'` (`3.1e−15`);
- the bulge positions at every step of the chase;
- the three convergence tables and the step counts;
- the converged block structure is `1×1 / 2×2 / 1×1` with the expected eigenvalues;
- the explicit/implicit flop counts grow like `n³` / `n²`;
- the unshifted rate table: each falling subdiagonal's measured geometric-mean ratio matches
  its predicted modulus ratio to three decimals, and `|h(3,2)|` stays at `2.000000` through
  200 sweeps because `|λ2| = |λ3|` exactly.

**Not verified, and therefore not claimed anywhere on the pages:** any specific number for
Wilkinson's degree-20 polynomial root-sensitivity story. It was attempted and the root finder
would not converge reliably, so the frame motivates section 1 with the measured sensitivity of
a defective 2×2 Jordan block instead. Do not add the Wilkinson figure without re-verifying it.

## Deliberate boundaries

- Section 1 does **not** claim the characteristic-polynomial route is unstable in general —
  only that it converts the problem into a degree-`n` root-finding problem and discards the
  matrix. No conditioning number is asserted for it.
- The deck works on a real matrix throughout; the complex-input path (`zlahqr`, one complex
  shift per step) is a section 5 remark, not a section.
- Hessenberg reduction, Householder reflectors, and Givens rotations are **not** re-taught;
  the title frame links to the sibling note, which already covers them with flop counts.

## Sources

Fetched this session through `arxiv-mcp-server` and `paper-search-mcp`; identifiers read back
from the servers, not recalled.

| Source | Identifier | Grounds |
| --- | --- | --- |
| J. G. F. Francis, *The QR Transformation: A Unitary Analogue to the LR Transformation — Part 1*, Computer J. 4(3):265–271, 1961 | [10.1093/comjnl/4.3.265](https://doi.org/10.1093/comjnl/4.3.265) | the implicit double-shift step and the Implicit Q theorem (sections 3–4) |
| J. G. F. Francis, *The QR Transformation — Part 2*, Computer J. 4(4):332–345, 1962 | [10.1093/comjnl/4.4.332](https://doi.org/10.1093/comjnl/4.4.332) | the real-arithmetic double shift for complex pairs (section 4) |
| D. S. Watkins, *The QR Algorithm Revisited*, SIAM Review 50(1):133–145, 2008 | [10.1137/060659454](https://doi.org/10.1137/060659454) | the modern pedagogical route: go straight to implicit multishift, bypassing the basic QR algorithm (section 5) |
| D. S. Watkins, *Understanding the QR Algorithm*, SIAM Review 24(4):427–440, 1982 | [10.1137/1024100](https://doi.org/10.1137/1024100) | QR as simultaneous iteration — the mental model behind section 2's convergence rate |
| J. H. Wilkinson, *Global convergence of tridiagonal QR algorithm with origin shifts*, Lin. Alg. Appl. 1(3):409–420, 1968 | [10.1016/0024-3795(68)90017-7](https://doi.org/10.1016/0024-3795(68)90017-7) | shifted QR converges rapidly on symmetric matrices — the historical baseline section 5 contrasts with |
| J. Banks, J. Garza-Vargas & N. Srivastava, *Global Convergence of Hessenberg Shifted QR I: Exact Arithmetic*, arXiv:2111.07976v4 | [arXiv:2111.07976](https://arxiv.org/abs/2111.07976) | read in full this session: Ritz-value shifts can **stagnate**, exceptional shifts escape stagnation, and `κ_V(H)` (eigenvector condition number) sets the convergence rate — section 5's limits |
| J. Banks, J. Garza-Vargas & N. Srivastava, *Global Convergence of Hessenberg Shifted QR II: Numerical Stability*, arXiv:2205.06810 | [arXiv:2205.06810](https://arxiv.org/abs/2205.06810) | the finite-arithmetic dichotomy that resolves the forward-instability question (section 5) |
| K. Braman, R. Byers & R. Mathias, *The Multishift QR Algorithm II: Aggressive Early Deflation*, SIMAX 23(4):948–973, 2002 | [10.1137/s0895479801384585](https://doi.org/10.1137/s0895479801384585) | what LAPACK's `dlaqr5` does beyond the single Francis step (section 5) |
| D. S. Watkins & L. Elsner, *Convergence of algorithms of decomposition type for the eigenvalue problem*, Lin. Alg. Appl. 143:19–47, 1991 | [10.1016/0024-3795(91)90004-g](https://doi.org/10.1016/0024-3795(91)90004-g) | why a bulge-chasing step is a legitimate GR/QR step — the theory under the implicit chase |
| G. H. Golub & C. F. Van Loan, *Matrix Computations*, 4th ed., JHU Press, 2013, ISBN 9781421407944 | publisher, no DOI in Crossref | textbook treatment of Hessenberg reduction and the shifted QR algorithm |

Spot-checked against full text (not just the abstract) this session: arXiv:2111.07976v4 —
the stagnation/exceptional-shift claim and the `κ_V(H)` rate are from its abstract and
§1.1–1.2, read directly.

## Verification state

- Rendered frame by frame at 1440×900 (`#/1` … `#/8`) and once at 420×3200: math renders,
  figures placed, nothing clipped or overlapping, **no `overfull` tag on any built frame**.
- Narrow viewport stacks into a readable document with all overlays shown.
- Not yet done (blocked on the deck being complete): landing-page card, cross-link
  verification over HTTP, and the final pass on sections 2–6.

## Skill changes made this session

`.claude/skills` is a symlink to `.agents/skills`, so these are the checked-in files.

**Overflow check, two false-positive sources** — fixed in
`templates/beamer-deck.html` and in this deck:

1. inline `<span class="mono">` reports `clientWidth === 0`, so every frame that mentions a
   filename was flagged `overfull \hbox`;
2. a last child's bottom margin counts toward the container's `scrollHeight`, so a frame whose
   final `.block` ends with margin was flagged `overfull \vbox` with nothing clipped.

**Theme default made explicit** — the user asked for beamer to be the documented default, so
`data-theme="beamer"` is now stated as the default and `paper` as strictly opt-in in
`SKILL.md` §4, `templates/README.md` (look-and-feel bullet and step 7), and
`references/repo-notes.md` (style contract). The previous wording ("keep `beamer` unless the
user wants the deck to read as part of the note series") is what led this deck to be drafted
in `paper` without asking; the new wording names that failure mode directly.