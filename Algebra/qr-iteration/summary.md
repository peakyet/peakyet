# QR Iteration — teaching handoff

**Page:** [qr-iteration.html](qr-iteration.html) · **Category:** Algebra · **Slug:** `qr-iteration`
**Script:** [`scripts/verify_qr_iteration.py`](scripts/verify_qr_iteration.py) — pure standard-library
Python, run before use. Every number on the page is its output; its `selftest()` runs first and
aborts the report if any step routine fails to be an orthogonal similarity.

**Status:** complete draft, structurally checked, layout-audited, landing card added.
**Renderer:** KaTeX 0.16.11 auto-render (the `templates/note.html` default). No deck, no
`data-theme`; one plain note page.

**Audience:** an engineer comfortable with matrix–vector products, orthogonality, and the
eigenvalue idea. No prior exposure to QR iteration or to Hessenberg reduction assumed. Goal:
be able to read `dlahqr`-style code and explain why the shift is there.

## Section → question map

| # | Question the section resolves | Anchor |
| --- | --- | --- |
| 1 | One eigenvalue is easy. How do we get all of them? | [#s1](qr-iteration.html#s1) |
| 2 | Why can we not simply iterate on all four directions at once? | [#s2](qr-iteration.html#s2) |
| 3 | What single step advances and re-orthonormalises at once? | [#s3](qr-iteration.html#s3) |
| 4 | Why must the subdiagonal decay, and how fast? | [#s4](qr-iteration.html#s4) |
| 5 | What does the procedure cost, and what does it produce here? | [#s5](qr-iteration.html#s5) |
| 6 | What breaks when a pair of eigenvalues shares a magnitude? | [#s6](qr-iteration.html#s6) |
| 7 | Sources and further reading | [#s7](qr-iteration.html#s7) |

Chain: tangible four-eigenvalue matrix → simultaneous iteration collapses → the requirement
(advance + re-orthonormalise) → factor/swap/repeat *is* that requirement → linear rate
`|λ_{i+1}/λ_i|` predicted and measured → shift destroys the ratio, cost stays `O(n²)` → a complex
pair floors the ratio and costs a 2×2 block. One existing need per new idea; no section opens with
a concept.

## Running example

One family, two acts. \(S=Q\,\mathrm{diag}(5,3,2,1)\,Q^{\mathsf T}\) built from four rational
Givens rotations, so \(S\) has rational entries and the spectrum \(\{1,2,3,5\}\) is exact by
construction with all four moduli distinct. Then \(H_0=Q_0^{\mathsf T}SQ_0\), the Householder
Hessenberg form, which is where all iteration actually runs. Act two changes one condition: the
companion matrix of \((x-5)(x^2+2x+5)\), spectrum \(\{5,-1\pm2i\}\), to expose the complex-pair
limit.

## Numbers on the page (all from `scripts/verify_qr_iteration.py`)

- **Example:** \(S\) trace 11, determinant 30; \(H_0\) subdiagonal
  \(1.360241,1.060226,0.779118\); predicted ratios \(3/5,2/3,1/2\).
- **§2 collapse:** worst |cos| between un-reorthonormalised columns after 0,1,2,4,8 sweeps =
  \(0,0.757250,0.957995,0.998704,0.999995\).
- **§3:** one QR step on dense \(S\) leaves \(0.763\) of mass below the subdiagonal; one step from
  \(H_0\) leaves \(2.4\cdot10^{-16}\) and gives the \(A_1\) printed on the page.
- **§4:|§** measured unshifted subdiagonal ratios at sweeps 20/40/60 = \(0.6000/0.6667/0.5000\),
  matching \(3/5,2/3,1/2\). Figure 3 uses the 16 frame `log10` trajectories.
- **§5:** sweeps to finish, threshold \(10^{-11}\): unshifted **67**, Rayleigh **12**, Wilkinson
  **7**. Rayleigh \(\sigma\): \(2.433069\to3.000000\) by sweep 8. Cost per sweep: \(364\) units at
  \(n=8\), \(1\,571\,836\) at \(n=512\), ratio to \(n^2\) converging to \(5.996\).
- **§6:** complex example under Rayleigh — sweep 40 gives \(|h_{32}|=9.40\cdot10^{-1}\),
  \(|h_{21}|=1.60\cdot10^{-16}\), trailing 2×2 trace \(-2.000000\). Double shift leaves a block with
  trace \(-2.00000000\), determinant \(+5.00000000\).
- **§6 Implicit Q:** \(p(H)\boldsymbol e_1=(1.40909491,-2.65877037,-1.44216344,1.4\cdot10^{-16})\);
  angle to the first column of the implicit \(Q\) is \(8.5\cdot10^{-7}\) degrees, to the explicit
  \(Q\) is 0, and the two resulting steps differ by \(\|H_\text{imp}-H_\text{exp}\|_{\max}=1.1\cdot10^{-15}\).
- **Demo:** 16 unshifted frames, 13 shifted frames with deflation, embedded as literals in the page.

## Sources and what they ground (all resolved this session)

| Source | Grounds |
| --- | --- |
| Francis, *The QR Transformation* 1–2 (1961–62), [10.1093/comjnl/4.3.265](https://doi.org/10.1093/comjnl/4.3.265), [10.1093/comjnl/4.4.332](https://doi.org/10.1093/comjnl/4.4.332) — metadata via Crossref | the QR step, the double shift, the real-arithmetic path (§3, §6) |
| Kublanovskaya, *On some algorithms for the solution of the complete eigenvalue problem* (1962), [10.1016/0041-5553(63)90168-X](https://doi.org/10.1016/0041-5553(63)90168-X) — metadata via Crossref | independent discovery / attribution (§1) |
| Parlett, *Convergence of the QR algorithm* (1965), [10.1007/BF01397692](https://doi.org/10.1007/BF01397692) — metadata via Crossref | the linear law `\|h_{i+1,i}\| ~ \|λ_{i+1}/λ_i\|^k` and its ordering assumptions (§4) |
| Wilkinson, *Global convergence of tridiagonal QR algorithm with origin shifts* (1968), [10.1016/0024-3795(68)90017-7](https://doi.org/10.1016/0024-3795(68)90017-7) — metadata via Crossref | the shifted iteration's convergence and the Wilkinson shift (§5) |
| Watkins, *Understanding the QR Algorithm* (1982), [10.1137/1024100](https://doi.org/10.1137/1024100) — abstract read | QR as simultaneous iteration, `A_k = Q_k^T A Q_k` (§2, §3) |
| Watkins, *The QR Algorithm Revisited* (2008), [10.1137/060659454](https://doi.org/10.1137/060659454) — abstract read | the implicit-multishift route that practice uses (§5, §6) |
| Banks, Garza-Vargas, Srivastava, *Global Convergence of Hessenberg Shifted QR I* (2021), arXiv:2111.07976 — abstract read in full, plus arXiv:2205.06810 and arXiv:2205.06804 | the claim that rapid non-symmetric convergence is recent and conditional on bounded eigenvector condition number, with an exceptional shift (§6) |
| Reference LAPACK `dlahqr.f` | the exceptional-shift branch before the Francis double-shift loop (§6) |

Suggested further reading (not consulted): Golub & Van Loan, *Matrix Computations*, 4th ed., ch. 7–8;
Wilkinson, *The Algebraic Eigenvalue Problem*, 1965.

## Checks performed

- `python3 scripts/verify_qr_iteration.py` run before use, twice: once plain and once with
  `--json`. Its self-tests check every routine is an orthogonal similarity (`‖QᵀHQ − H'‖ ~ 1e-15`,
  `‖QᵀQ − I‖~ 1e-16`), stays Hessenberg, and preserves the characteristic polynomial (relative
  residual ~1e-15) across \(n=4,5,6,8\) and 60 consecutive sweeps. The report aborts if they fail.
- Every number quoted above re-derived in a separate audit pass against the script's routines.
- `grep -n 'FILL:'` empty; nav anchors vs heading ids diff empty; 7 sections, 6 questions (the
  sources heading has none, as intended); no `../` asset refs; 47 KB page.
- Both inline scripts pass `node --check`. The demo was additionally driven through all 28
  (sweep × mode) states under a stubbed canvas: no exceptions, no non-finite geometry.
- The landing card was machine-checked: `data-tags` and the visible pills agree exactly, `data-field`
  equals the `.foot` text, and every card `href` on the page resolves to an existing file. The
  search box finds the note for "qr iteration", "eigenvalues qr", "rayleigh", "complex pair" and
  "subdiagonal"; the algebra and control chips include it, and a bogus extra token excludes it
  (multi-token AND behaves).
- Headless Chrome (not Firefox — `firefox` is no longer installed on this machine, see below),
  1440×9000 and 420×11000: math renders, all four figures place and label correctly, sticky TOC
  works, the demo canvas lays out in both wide and stacked narrow form. Figure 3's polyline
  coordinates were regenerated from the script rather than eyeballed after the first capture
  showed visibly wrong slopes.
- Landing card added and its `href` resolves to an existing file. The earlier cross-link to the
  `Algebra/qz-algorithm` note was dropped when that note was removed from the repo.

## Deliberate boundaries / unresolved

- §6's "no real shift can make such a block triangular" is stated as the structural reason and is
  demonstrated by the stalled \(|h_{32}|\) table; the general proof is not reproduced on the page.
- The §6 complex example's trailing 2×2 is nilpotent, so a naive shift from it is 0. The page says
  so and switches to the Rayleigh shift; the exceptional-shift machinery is described from
  `dlahqr.f` but not demonstrated numerically.
- The convergence Claim in §4 is stated for matrices with a full eigenvector set and strictly
  ordered moduli. Nonsymmetric convergence without that ordering is attributed to the
  Banks–Garza-Vargas–Srivastava sequence; the papers were read only at abstract level, and the page
  says the guarantees are "more delicate" rather than quoting a theorem.
- Figure 2 is a schematic of the collapse (the numbers in its caption are the measured cosines);
  it is not a projection of the actual 4-D trajectory.
- Only square, real matrices are treated. The generalized problem \(Ax=\lambda Bx\) is out of
  scope (the `Algebra/qz-algorithm` note that used to cover it was removed).
- **Disclosed:** `firefox` was used for the first captures and then disappeared from the machine
  mid-session (`/usr/bin/firefox` gone, `google-chrome-stable` present). All captures after that
  point are Chrome. Layout was not cross-checked in a second engine.

## Open teaching point

Nothing taught yet — this is the first handoff for this note. The natural entry question is
[`#s1`](qr-iteration.html#s1): *one eigenvalue is easy, so what does it take to get all four?*
