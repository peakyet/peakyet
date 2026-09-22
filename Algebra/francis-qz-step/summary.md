# Current understanding: the Francis QZ step

**Page:** [francis-qz-step.html](francis-qz-step.html) · **Category:** Algebra · **Slug:** `francis-qz-step` · **Field:** Numerical Linear Algebra

**Audience:** an engineer comfortable with eigenvalues, matrix factorizations, and the shape of the QR algorithm, but new to the generalized eigenvalue problem and to QZ. The requested emphasis is the **Francis-style double-shift step inside QZ** — the implicit bulge chase on a Hessenberg–triangular pencil.

**Teaching state:** the full deck is written and verified; the section-by-section understanding gate has not yet been run. Section 1 is ready to teach from frame `#/3` (divider) or `#/4` (first content frame).

## Prerequisite map

| Topic | Calibration status | Treatment in the deck |
| --- | --- | --- |
| Eigenvalues, eigenvectors, characteristic polynomial | assumed | used directly in section 1 |
| Orthogonal matrices, Householder reflectors, Givens rotations | assumed, linked | section 2 links to the Householder note; sections 3–4 use both |
| Standard QR algorithm: shifts, bulges, Hessenberg form | taught briefly | section 3 recalls the QR step before generalizing it |
| Generalized eigenvalue problem \(Ax=\lambda Bx\), singular \(B\), infinite eigenvalues | main topic | section 1, motivated by the 2×2 example |
| Hessenberg–triangular reduction | main topic | section 2 |
| Implicit double-shift QZ step and the three-entry bulge vector | main topic | section 3 |
| Left/right bulge chase | main topic | section 4 |
| Shifts, deflation, convergence, multishift/AED | supporting | section 5 |
| Dense vs sparse eigensolvers, rational QZ | supporting | section 6 |

## Running example

The deck uses one running pencil, already in Hessenberg–triangular form:

\[
H_0=\begin{bmatrix}
8.5 & 3.7 & 0.8 & 0.4\\
1.5 & 4.8 & 1.9 & 0.7\\
0 & 1.0 & 1.6 & 1.8\\
0 & 0 & -0.5 & 1.0
\end{bmatrix},
\qquad
T_0=\begin{bmatrix}
2 & 0.5 & 0.2 & 0.1\\
0 & 1.5 & 0.3 & 0.2\\
0 & 0 & 1 & 0.4\\
0 & 0 & 0 & 0.5
\end{bmatrix}.
\]

It was built as \(H_0=T_0C\) with

\[
C=\begin{bmatrix}4&1&0&0\\1&3&1&0\\0&1&2&1\\0&0&-1&2\end{bmatrix},
\]

so \(T_0^{-1}H_0=C\). The trailing \(2\times2\) pencil supplies the double shift \(\mu=2\pm i\). The generalized eigenvalues of \((H_0,T_0)\) are approximately

\[
1.790987787\pm0.6940270197i,\qquad 2.700416827,\qquad 4.7176076.
\]

One explicit QZ step with the shifts \(2\pm i\) gives:

| quantity | value |
| --- | --- |
| subdiagonal magnitudes before | \(1.5,\ 1.0,\ 0.5\) |
| subdiagonal magnitudes after | \(0.459957,\ 0.327123,\ 0.271671\) |
| \(\lVert Q^{\mathsf T}H_0Z-H_1\rVert\) | \(2.109\times10^{-15}\) |
| \(\lVert Q^{\mathsf T}T_0Z-T_1\rVert\) | \(4.441\times10^{-16}\) |
| \(\lVert Q^{\mathsf T}Q-I\rVert\) | \(7.772\times10^{-16}\) |
| \(\lVert Z^{\mathsf T}Z-I\rVert\) | \(6.661\times10^{-16}\) |
| eigenvalues before and after | agree to ten digits |

Deflation of the trailing \(2\times2\) block, measured by \(|H_{2,1}|\) (1-indexed), falls over five steps:

| \(k\) | 0 | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- | --- |
| \(|H_{2,1}|\) | \(1.0\) | \(3.271229\times10^{-1}\) | \(6.158937\times10^{-2}\) | \(6.665401\times10^{-4}\) | \(1.892124\times10^{-6}\) | \(1.105472\times10^{-12}\) |

## Claims verified by running code

`python3 scripts/verify_qz_step.py` (pure Python, no third-party dependencies) checks:

- the QZ step preserves the Hessenberg–triangular structure to machine precision;
- the accumulated transformations are orthogonal to machine precision;
- the backward errors \(\lVert Q^{\mathsf T}H_0Z-H_1\rVert\) and \(\lVert Q^{\mathsf T}T_0Z-T_1\rVert\) are at the \(10^{-15}\) level;
- the generalized eigenvalues before and after the step agree to ten digits;
- the trailing subdiagonal deflates to \(1.1\times10^{-12}\) in five steps.

The browser demo on frame `#/25` is generated from the same script's `--json` output and steps through the seven snapshots `start, initial-left, right-0, left-1, right-1, last-left, last-right`.

## Section-to-frame map

| Section | Frames | Purpose |
| --- | --- | --- |
| 1. The pencil problem | `#/3`–`#/6` | why \(B^{-1}A\) is the wrong object; singular \(B\), infinite eigenvalues |
| 2. Hessenberg–triangular form | `#/7`–`#/10` | the two-phase strategy and the HT reduction |
| 3. The Francis QZ step | `#/11`–`#/14` | the double-shift polynomial on \(HT^{-1}\), the three-entry bulge vector |
| 4. Chasing the bulge | `#/15`–`#/18` | alternating left/right rotations; structure preservation |
| 5. Shifts, deflation, convergence | `#/19`–`#/22` | trailing \(2\times2\) shifts, deflation criteria, cost and convergence |
| 6. Worked example, limits, sources | `#/23`–`#/29` | real numbers, interactive demo, modern variants, sources |

## Sources

Every identifier below was resolved during this session. The QZ description, the two-phase structure, and the deflation criterion were checked against the full text of `arXiv:1802.04094`; the production sweep structure (3×3 Householders, final Givens rotations) was checked against the LAPACK `DHGEQZ` source. The Moler–Stewart and Francis records were resolved through Crossref; the Moler–Stewart abstract grounds the no-inversion and singular-\(B\) claims.

| Source | Identifier | Claim it grounds |
| --- | --- | --- |
| J. G. F. Francis, *The QR Transformation*, Parts 1–2 (1961–62) | [10.1093/comjnl/4.3.265](https://doi.org/10.1093/comjnl/4.3.265), [10.1093/comjnl/4.4.332](https://doi.org/10.1093/comjnl/4.4.332) | the implicit double-shift QR step that the QZ step generalizes (section 3) |
| C. B. Moler & G. W. Stewart, *An Algorithm for Generalized Matrix Eigenvalue Problems* (1973) | [10.1137/0710024](https://doi.org/10.1137/0710024) | QZ; attention to singular \(B\); no inversions of \(B\) or its submatrices (sections 1 and 3) |
| R. C. Ward, *The Combination Shift QZ Algorithm* (1975) | [10.1137/0712062](https://doi.org/10.1137/0712062) | combination shifts; infinite eigenvalues (section 5) |
| B. Kågström & D. Kressner, *Multishift Variants of the QZ Algorithm with Aggressive Early Deflation* (2007) | [10.1137/05064521x](https://doi.org/10.1137/05064521x) | multishift QZ and AED (sections 5–6) |
| Z. Bujanović, L. Karlsson & D. Kressner, *A Householder-based algorithm for Hessenberg-triangular reduction* (2018) | [arXiv:1710.08538](https://arxiv.org/abs/1710.08538) | the HT reduction phase; the Givens-rotation cost of the classical reduction (section 2) |
| D. Camps, K. Meerbergen & R. Vandebril, *A rational QZ method* (2018) | [arXiv:1802.04094](https://arxiv.org/abs/1802.04094) | the classical QZ two-phase description, HT form, generalized Schur form, and the deflation criterion (sections 2, 4, 5) |
| M. Myllykoski, *Algorithm 1019: A Task-based Multi-shift QR/QZ Algorithm with Aggressive Early Deflation* (2021) | [10.1145/3495005](https://doi.org/10.1145/3495005) | modern multi-shift QR/QZ scheduling (section 6) |
| LAPACK `DHGEQZ` | [source](https://github.com/Reference-LAPACK/lapack/blob/master/SRC/dhgeqz.f) | the production double-shift QZ sweep: 3×3 Householders plus final Givens rotations (section 4) |

## Verification state

- **Rendering:** all 29 frames were measured with headless Chrome on the deck's fixed 1280×720 canvas; no `overfull \vbox` or `overfull \hbox` tag remains.
- **Narrow layout:** rendered at 420×2200; frames stack and reflow, with horizontal scrolling confined to wide equations.
- **Wiring:** the landing-page card is added under `#grid`; the card's `href`, `data-category`, `data-field`, and `data-tags` are filled.
- **Cross-links:** `../householder-transformations/householder-transformations.html`, `../../Optimization/lmi/lmi.html`, `../../Control/h2-control/h2-control.html`, and `../../Optimization/interior-point-method/interior-point-method.html` all resolve to existing files.
- **Research hygiene:** PDFs and extracted text were kept under `/tmp`; no research downloads were added to the repository.
- **Open gate:** the user has not yet answered the section 1 prediction prompt or confirmed the section 1 explanation. The deck should be taught from frame `#/3` onward before any section is marked understood.
