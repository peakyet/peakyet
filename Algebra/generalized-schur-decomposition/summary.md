# Generalized Schur (QZ) Decomposition — teaching summary

**Page:** [generalized-schur-decomposition.html](generalized-schur-decomposition.html) · **Topic:** generalized Schur decomposition (QZ) for the
pencil \(A - \lambda B\) · **Date:** 2026-09-14

## Audience calibration (DFS over the prerequisite tree)

| Prerequisite | Status | Consequence for the page |
| --- | --- | --- |
| Standard eigenproblem: eigenvectors, characteristic polynomial, invariant subspaces, defectiveness | **Confirmed comfortable** | Build freely; only name-check Jordan/Weierstrass |
| Schur form \(A = QTQ^*\), unitary matrices, QR algorithm idea, why triangular is the safe target | **Confirmed comfortable** | Build freely; cross-link `../givens-rotations`, `../householder-transformations`, `../condition-number` |
| Matrix pencils / \(Ax = \lambda Bx\), regularity, infinite eigenvalues | **Confirmed gap** | Taught first-class in §1 (motivation, regular vs singular, \((\alpha,\beta)\) homogeneous pairs) |
| Backward error, condition numbers, why unitary transforms | **Confirmed gap** | Taught first-class in §2 (governing bound: forward ≲ κ × backward; formula checked numerically) |
| IEEE double representation & rounding | **Rusty** | 60-second float refresher callout with real outputs at the top of §2 |

## Running examples

1. **3-DOF spring chain with a massless node** (carries the whole page):
   \(K\) tridiagonal, \(M = \operatorname{diag}(1,1,0)\).
   \(\det(K-\omega^2 M) = 2\lambda^2 - 7\lambda + 4\) (degree drop → infinite eigenvalue);
   finite \(\omega^2 = (7\pm\sqrt{17})/4 \approx \{0.7192, 2.7808\}\).
   QZ returns \(T, S\) triangular with \(\beta = (\,0.9558,\ 0.9358,\ 0)\) and
   \(\lambda = (2.7808,\ 0.7192,\ \infty)\); deflating pair check
   \(\|Kz_1 - t_{11}q_1\| = 0\), \(\|Mz_1 - s_{11}q_1\| = 1.1 \times 10^{-16}\).
2. **2-DOF miniature with \(m_2 = \varepsilon\)**: \(A = U\operatorname{diag}(1.5,2.5)U^{\mathsf T}\),
   \(B = U\operatorname{diag}(1,\varepsilon)U^{\mathsf T}\), \(U\) = rotation by 0.7.
   Exact eigenvalues \(\{1.5,\ 2.5/\varepsilon\}\), \(\kappa(\lambda_1) = 1\),
   \(\kappa(\lambda_2) = 1/\varepsilon\). Drives the naive-vs-QZ interactive demo and Figure 3.

## Verified claims & assets (all run on this machine, `.venv-qz`)

- `scripts/verify_demos.py` — sympy determinant/roots; LAPACK `zgges` QZ of (K, M) with
  residuals ~1e-16; hand-written Hessenberg–triangular reduction (exact on the permuted pair);
  naive-vs-QZ sweep; condition-number bound experiment (observed ≤ bound, 200 trials).
- `scripts/gen_figures.py` — `assets/degenerate-det.svg`, `assets/error-vs-eps.svg`,
  `scripts/qz_table.json` (QZ + Python-float naive values for the live demo).
- `scripts/short_demo.py` — the runnable snippet quoted on the page (output pasted verbatim).
- Node cross-check: the page's JS 2×2 float path reproduces the Python values **bit-exactly**
  for every slider stop with \(\varepsilon > 0\); at \(\varepsilon = 0\) both are pure
  det-noise (~1e-17) garbage, so the demo labels that stop "undefined" and shows live `det(B)`.
- Sources checked: Moler & Stewart 1973 (original QZ paper); Moler's 2023 blog (0/0, infinite
  eigenvalues, "spectrum is the entire complex plane"); LAPACK `dhgeqz`/`dgges` docs ((α, β)
  convention, double-shift QZ, 1×1/2×2 blocks); Higham & Higham SIMAX 1998 (κ formula,
  "deflating subspaces … appropriate generalization of invariant subspaces").

## Prediction prompts on the page

1. §1: degree-3 pencil with a degree-2 determinant → lost eigenvalue? (→ it went to ∞)
2. §2: which step burns the digits in `eig(inv(B) @ A)`? (→ forming \(B^{-1}A\) itself)
3. §4: QZ reports \(\alpha = \beta = 0\) — software bug? (→ singular pencil signature)

## Current understanding / open follow-ups

- Reader is new to pencils and to backward-error thinking; both get full-depth treatment and
  the takeaways are written to stand alone.
- Not covered (deliberately): Krylov methods for large sparse pencils, structured/Hermitian
  QZ variants, Kronecker canonical form details, reordering internals (`xTGSEN`).
- If the reader asks about the symmetric-definite case in more depth, extend §5 with the
  Cholesky/Crawford reduction and the `*SYGV` family.
