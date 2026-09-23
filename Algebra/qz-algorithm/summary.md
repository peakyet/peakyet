# QZ Algorithm and the Francis QR Step — teaching handoff

**Page:** [qz-algorithm.html](qz-algorithm.html) · **Category:** Algebra · **Slug:** `qz-algorithm`
**Script:** [`scripts/verify_qz_algorithm.py`](scripts/verify_qz_algorithm.py) — pure Python, no third-party dependencies. Every number on the frames is its output; `--json` emits the bulge-chase snapshots embedded in the two demos.

**Status:** complete draft, layout-audited, on the landing page. Teaching not started — begin at [`#/4`](qz-algorithm.html#/4).
**Theme:** `data-theme="beamer"` (default). Landing card: `algebra control optimization`, "Numerical Linear Algebra".

**Audience:** an engineer comfortable with eigenvalues, similarity transforms, and matrix–vector products (power iteration and backward stability are taught in-line). No prior exposure to the QR iteration, the generalized problem, or QZ assumed. Goal: read or modify `dlahqr`/`dhgeqz`-style code afterwards.

## Section → frame map

| # | Section | Frames | Contents |
| --- | --- | --- | --- |
| 1 | Two eigenvalue problems | `#/3`–`#/7` | `#/4` three naive routes and their failure; `#/5` the pencil and why never \(B^{-1}\) (**predict**); `#/6` running pencil + Figure 1 targets; `#/7` the orthogonal-only promise |
| 2 | Reduce once | `#/8`–`#/10` | `#/9` Hessenberg form (\(H_0\) numbers); `#/10` Hessenberg–triangular form (two phases, no inversion) |
| 3 | The Francis QR step | `#/11`–`#/19` | `#/12` unshifted rates (**predict** setup); `#/13` stuck subdiagonal (**predict**); `#/14` shifts and the double shift; `#/15` Implicit Q theorem (**predict**); `#/16` the step + cost table; `#/17` bulge chase + Figure 2; `#/18` chase demo; `#/19` counts + real Schur form |
| 4 | The QZ step | `#/20`–`#/24` | `#/21` what changes (**predict**); `#/22` alternating chase + Figure 3; `#/23` chase demo; `#/24` deflation table + generalized real Schur |
| 5 | Cost, limits, connections, sources | `#/25`–`#/28` | `#/26` production adds / limits; `#/27` LAPACK + control links; `#/28` sources |

Prediction prompts and their answers (answers behind `data-fragment`): `#/5` finite vs infinite eigenvalues of the \(2\times2\) pencil; `#/13` why \(|h(3,2)|\) sits at 2.000; `#/15` that only \(p(H)\boldsymbol e_1\) is needed; `#/21` the \(T\)-bulge created by a left reflector.

## Running example

One family, two acts: \(C=\mathrm{circ}(1,2,3,4)\) (DFT-diagonalized, \(\lambda\in\{10,-2,-2\pm2i\}\)) and the pencil \((C,B)\) with \(B=3I+\tfrac12 C\). Because \(B\) is a polynomial in \(C\), the generalized eigenvalues are pairwise ratios \(\mu=\lambda/(3+\lambda/2)=\tfrac54,\,-1,\,\tfrac{-2\pm 6i}{5}\) — closed form, so every number on the deck is checkable by hand. Both acts produce \(1\times1/2\times2/1\times1\) block structure.

## Numbers on the frames (all from `scripts/verify_qz_algorithm.py`)

**Act 1 (Francis QR on \(H_0=Q^\top CQ\)):**
- power iteration from \((1,2,4,7)\): error ratio \(0.078\approx(2.83/10)^2\); Jordan demo \(\begin{bmatrix}1&1000\\10^{-16}&1\end{bmatrix}\mapsto 1\pm3.16\cdot10^{-7}\)
- unshifted rates (geometric means, sweeps 2–12): \(0.2816/1.0051/0.7112\) vs predicted \(|\lambda_{i+1}/\lambda_i| = 0.2828/1.0/0.7071\); after 200 sweeps \(|h(2,1)|=2\cdot10^{-44}\), \(|h(4,3)|=10^{-30}\), \(|h(3,2)|=2.000000\)
- sweeps to split \((2,1),(4,3)\): unshifted **88**, real Rayleigh shift **19**, Francis double **10**
- trailing-\(2\times2\) pair \(\sigma=-1.6897\pm1.0701i\) → \(s=-3.3793\), \(t=4.0\); bulge vector \(p(H)\boldsymbol e_1=(33.379,-57.937,-16.758,0)\) (entry 4 vanishes exactly)
- bulge walk (below-band): \(\{(3,1),(4,1),(4,2)\}\to\{(4,2)\}\to\varnothing\); implicit vs explicit double shift \(\|D H_{\mathrm{exp}}D-H_{\mathrm{imp}}\|_F=8.2\cdot10^{-15}\) (here \(D=I\)); \(Q\boldsymbol e_1\parallel p(H)\boldsymbol e_1\) to \(3.6\cdot10^{-15}\)
- converged: \([10]\mid\begin{bmatrix}-2&-2\\2&-2\end{bmatrix}\leftrightarrow-2\pm2i\mid[-2]\), block subdiagonal \(2.000\)
- ops per double step (mult-add units): \(n=64\) **2.64M explicit vs 161k implicit** (doubling \(n\): ×8 vs ×4 → \(n^3\) vs \(n^2\)); full table \(n=8,16,32,64\) in the script output

**Act 2 (QZ on \((C,B)\)):**
- HT reduction: \(\|U^\top CV-H\|_{\max}=8.9\cdot10^{-16}\), \(\|U^\top BV-T\|_{\max}=1.3\cdot10^{-15}\); \(H,T\) printed on `#/24`; subdiagonals of \(H\): \(3.658,\,3.300,\,2.178\)
- trailing-\(2\times2\) pencil shifts \(\mu=-0.2463\pm0.2149i\); one step → \(3.018,\,3.067,\,1.060\); off-structure \(\sim2\cdot10^{-16}\); backward errors \(1.8\cdot10^{-15}\) (\(H\)), \(8.9\cdot10^{-16}\) (\(T\)); eigenvalues unchanged
- QZ bulge walk: \(\varnothing\to\{(3,1)\}\to\{(3,1),(4,1),(4,2)\}\to\{(4,2)\}\to\varnothing\) (alternating left/right reflectors; 7 snapshots in the demo)
- deflation table (`#/24`): \(|H(4,3)|\) collapses cubically first (\(2.18\to8.6\cdot10^{-13}\) in 4 sweeps); after exact deflation the shifts hit the pair and \(|H(2,1)|\) collapses cubically (\(0.184\to1.8\cdot10^{-4}\to1.6\cdot10^{-13}\)); \(|H(3,2)|\to2.683\). **7 sweeps** total.
- converged blocks: \(\tfrac{-10}{-8}=\tfrac54\), \(\tfrac{-0.894\pm2.683i}{2.236}=\tfrac{-2\pm6i}{5}\), \(\tfrac{-2}{2}=-1\) — exactly the closed form.

## Sources and what they ground (all resolved this session)

| Source | Grounds |
| --- | --- |
| Francis, *The QR Transformation* 1–2 (1961–62), [10.1093/comjnl/4.3.265](https://doi.org/10.1093/comjnl/4.3.265), [10.1093/comjnl/4.4.332](https://doi.org/10.1093/comjnl/4.4.332) — metadata verified via Crossref | implicit double shift, Implicit Q theorem, real-arithmetic double shifts (§3) |
| Moler & Stewart, *An Algorithm for Generalized Matrix Eigenvalue Problems* (1973), [10.1137/0710024](https://doi.org/10.1137/0710024) — abstract read | QZ; degeneracies of singular \(B\); "no inversions of \(B\) or its submatrices" (§1–2, §4) |
| Watkins, *Understanding the QR Algorithm* (1982), [10.1137/1024100](https://doi.org/10.1137/1024100) — abstract read | QR as simultaneous iteration (§3) |
| Watkins, *The QR Algorithm Revisited* (2008), [10.1137/060659454](https://doi.org/10.1137/060659454) — abstract read | the modern implicit-multishift route; Hessenberg-shifted-QR convergence subtleties (§5) |
| Ward, *The Combination Shift QZ Algorithm* (1975), [10.1137/0712062](https://doi.org/10.1137/0712062) — abstract read | combination shifts; infinite eigenvalues under exact arithmetic (§4–5) |
| Kågström & Kressner, *Multishift Variants of the QZ Algorithm with AED* (2007), [10.1137/05064521X](https://doi.org/10.1137/05064521X) — abstract read | multishift QZ + aggressive early deflation; ∞-eigenvalue deflation (§5) |
| Bujanović, Karlsson & Kressner, *A Householder-Based Algorithm for HT Reduction* (2018), [10.1137/17M1153637](https://doi.org/10.1137/17M1153637) — abstract read | the HT reduction phase; classical reduction uses Givens pairs (§2) |
| LAPACK `dhgeqz.f` / `dlahqr.f` — sources read this session ([dhgeqz.f](https://github.com/Reference-LAPACK/lapack/blob/master/SRC/dhgeqz.f)) | production sweep: `DLARFG(3,…)` 3×3 Householders, "Last elements: Use Givens rotations"; `dlahqr`'s "Exceptional shift" then "Francis' double shift" blocks (§3, §5) |

Suggested further reading (not consulted): Golub & Van Loan, *Matrix Computations*, 4th ed., 2013, ch. 7 (ISBN 9781421407944) · Wilkinson, *The Algebraic Eigenvalue Problem*, 1965.

## Checks performed

- `python3 scripts/verify_qz_algorithm.py` run before use — every frame number above is its output (structure residuals, orthogonality, eigenvalue preservation, implicit≡explicit match, bulge walks, deflation tables, flop counts).
- `?fit` audit (headless Chrome): 28 frames, **no `overfull` tag**, max fill 89% (`#/18`, `#/22`); all frames ≤ 89% after trims. Figures' SVG text switched to plain text — KaTeX auto-render was swallowing `\(...\)` inside `<text>` nodes (labels rendered as "for", "the -bulge"); fixed and re-verified in Figure 1 and Figure 3 pixel captures.
- Visual captures checked at 1440×900: frames 4, 6 (Figure 1), 16, 22 (Figure 3), plus a 420px narrow stack — math renders, figures placed, labels clear after the spacing fix. Figure 2's final pixels were confirmed via DOM text extraction rather than a clean capture (the session's image display kept serving stale frames); its only defect class (SVG math) was the one already fixed and re-checked on Figures 1/3.
- Demos wired and rendered: DOM shows `stage 1/4: start` and `stage 1/7: start` with the matrix tables populated from `--json` snapshots; KaTeX produced 91 formula nodes.
- Internal links (`../householder-transformations/…`, `../../Control/h2-control/…`, `../../Optimization/lmi/…`, `../../Optimization/interior-point-method/…`, `../../index.html`) point at existing files; HTTP cross-check of the landing card done after the card was added.

## Deliberate boundaries / unresolved

- The single-shift comparison on `#/19` is a **real Rayleigh shift** (\(\sigma=h_{nn}\)), labelled as such. Wilkinson's shift rule with a complex pair would need complex arithmetic; not implemented, not claimed.
- Stagnation/exceptional-shift *literature* (e.g. Banks–Garza-Vargas–Srivastava) was not consulted this session; `#/26` grounds the exceptional-shift claim in `dlahqr`'s source only.
- Infinite eigenvalues appear as the \(T(i,i)\to0\) story and the \(2\times2\) mini-pencil on `#/5`; the running pencil has nonsingular \(B\), so ∞-deflation machinery is described (Ward; Kågström–Kressner) but not demonstrated numerically.
- Teaching progress: none yet. Section gates not run.

## Open teaching point

Start at [`#/4`](qz-algorithm.html#/4) (first content frame). Its guiding question: *of the three tempting routes on \(C\) — characteristic polynomial, power iteration, sensitivity — which one actually fails for a reason the algorithm can fix, and which one is a hard limit?* The deck's first prediction prompt follows on `#/5`.
