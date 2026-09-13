# SDA (Structure-Preserving Doubling Algorithm) for the Algebraic Riccati Equation — summary

**Deliverable:** `sda-algebraic-riccati.html` (self-contained page, KaTeX from CDN, two interactive demos, all
numbers machine-verified). **Demos:** `demos/sda_verify.py`, `demos/diag_sda.py` (numpy/scipy;
run with `uv run --with numpy --with scipy python demos/sda_verify.py`).

## Reader calibration (asked before writing)
- LQR/ARE origin: can derive it → page does not re-derive the Riccati equation.
- Matrix tools: all except Schur complements → §2 is a dedicated primer (Schur complement as
  block Gaussian elimination).
- Hamiltonian/invariant-subspace method: comfortable → compared against, not taught.
- Repeated squaring & quadratic convergence: teach both → §3 builds them from scratch
  (Fibonacci by squaring, digit-count definition of quadratic convergence).

## The mental model delivered
1. **Rewrite, don't solve.** Each SDA step replaces the Riccati equation by an equivalent one
   (same stabilizing solution) whose data is closer to trivial. ~10 rewrites → machine precision.
2. **Baby case (Stein: X = AᵀXA + Q):** self-substitution gives X = (A^{2^k})ᵀXA^{2^k} +
   Σ_{i<2^k}(Aᵀ)^iQA^i. Squared Smith: A_{k+1}=A_k², Q_{k+1}=Q_k+A_kᵀQ_kA_k. Verified:
   Q_k is *identically* the 2^k-term partial sum (8.5e-15).
3. **DARE (X = Q + AᵀX(I+GX)⁻¹A):** the fixed-point iteration is (inverse) subspace iteration on
   the symplectic matrix S = [[I,G],[0,Aᵀ]]⁻¹[[A,0],[−Q,I]], whose inside-disk invariant
   subspace is im[I;X★], with closed-loop E = (I+GX★)⁻¹A. SDA maintains the factored form
   S^{−2^k} = [[A_k,0],[−Q_k,I]]⁻¹[[I,G_k],[0,A_kᵀ]]; squaring it = one block elimination
   (Schur complement) ⇒ the updates, with T_k = (I+G_kQ_k)⁻¹ shared:
   **A' = A·T·A, G' = G + A·T·G·Aᵀ, Q' = Q + Aᵀ·Q·T·A** (Q *before* T — this placement is what
   keeps Q' symmetric; pinned down numerically against the explicit S⁻² in diag_sda.py).
4. **Structure preserved:** doubling lemma (DARE(A_k,G_k,Q_k) has the same X★; residuals ~1e-14);
   G_k,Q_k symmetric PSD forever; spectrum of I+G_kQ_k real in [1,∞) (verified: min Re 1.0000,
   max|Im| = 0); A_k→0, G_k→C★ (dual, quadratic), Q_k↑X★ monotone; Q_k = X_{2^k} exactly
   (3e-15); nothing overflows unlike raw S^{−2^k}.
5. **CARE via Cayley (Chu–Fan–Lin 2005):** pencil (𝓗+τI, 𝓗−τI), μ ↦ (μ+τ)/(τ−μ) maps the LHP
   (the [I;X★] half) into the unit disk; block elimination of the pencil gives
   A₀ = I + 2τ(A_τ+GA_τ^{-ᵀ}Q)⁻¹, G₀ = 2τA_τ⁻¹G(A_τᵀ+QA_τ⁻¹G)⁻¹, Q₀ = 2τ(A_τᵀ+QA_τ⁻¹G)⁻¹QA_τ⁻¹
   (A_τ = A−τI), symmetric, PSD; then the same 3-line SDA. Verified: DARE residual of X★ 1.2e-13,
   closed-loop ρ = max Cayley image (0.6328), pencil spectrum equivalence 2.6e-13.
   τ: U-shaped optimum (verified 10/9/7/6/6/8/10 steps for τ=0.05…30), singular at τ∈spec(A).
6. **Numerics:** one inverse per step, spectrally trapped in [1,∞); warm-startable; low-rank
   Woodbury variants reach O(n)/step (Li–Chu–Lin–Weng: n=20,209, 204M unknowns, 45 s).
   Failure modes: imaginary-axis eigenvalues (rate degrades to linear ½), τ singularities,
   unimodular DARE eigenvalues, dense fill-in of A_k.
7. **Connection:** SDA = matrix-sign iteration with structure-preserving bookkeeping
   (verified |Cay(𝓗₁) − S²| = 1.7e-10).

## Verified headline numbers (all from sda_verify.py, float64)
- DARE n=4, ρ(A)=0.85, ρ(E)=0.719: SDA digits −0.9, −0.5, −0.0, 1.1, 3.4, 8.0, 13.7 (k=0..6);
  fixed point at j=k: −0.9 … 0.8 (linear, ≈0.28 digits/step).
- Stein n=4, ρ(A)=0.93: doubling digits reach 6.3 at k=7 while plain Smith has −1.2 at j=8.
- CARE n=4, τ=1: SDA digits −1.4 … 12.7 (k=6), final CARE residual 4.7e-13.
- Scalar worked example a=g=q=1, τ=2: triple (−1,2,2) → Q_k = 2, 2.4, 2.4142012, 2.4142135624,
  machine — x★ = 1+√2. Digits 0.4, 1.9, 4.9, 11.0, 16.
- Fibonacci by squaring: 5 squarings → F₃₂ = 2,178,309; 20 vs 1,048,575 products for F₁₀₄₈₅₇₆.

## Sources used
Poloni 2020 (arXiv:2005.08903) comparative introduction (main structural reference);
Chu–Fan–Lin, LAA 396 (2005) 55–80 (CARE bridge + τ heuristics); Lin–Xu, SIMA 28 (2006)
(convergence theory); Chu–Fan–Lin–Wang, IJC 77 (2004) (modern SDA); Anderson, IJC 28 (1978)
295–306 (origin); Li–Chu–Lin–Weng (large-scale low-rank SDA); Lancaster–Rodman (theory).
