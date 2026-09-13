# Current understanding: the Francis (implicit double-shift) QR step

*Audience: an engineer who is comfortable with eigenvalues/similarity, knows Gram–Schmidt QR but not
Householder reflectors, and has never studied the QR iteration. Goal: implement or modify eigenvalue
code (LAPACK `dhseqr`/`dlahqr`-style).* — Everything below was verified by running code, not assumed.

---

## The one-sentence version

Finding eigenvalues = building an orthogonal similarity that reveals them on the diagonal (Schur form);
the Francis step is one cheap, all-real-arithmetic pass that performs a **double QR shift with a
complex-conjugate pair of shifts** — without ever forming the complex matrix or the product
matrix — by computing only the *first column* of that product and chasing the resulting "bulge" down the
matrix; the **Implicit Q theorem** certifies that this shortcut reproduces the explicit step exactly.

## Prerequisite map (what this explanation stands on)

| Topic | Status in this explainer | Where |
|---|---|---|
| Eigenvalues, similarity | assumed comfortable | everything |
| Schur decomposition + real 2×2 blocks | taught briefly | §2 |
| Power / inverse iteration | taught briefly (convergence ratios) | §3 |
| Householder reflectors (vs Gram–Schmidt) | taught fully (sign choice, stability) | §4 |
| Basic QR iteration + shifts | taught fully (linear vs cubic convergence) | §5–6 |
| Hessenberg form, bulge chase, Implicit Q theorem | main topic | §7 |

## The mechanism (what a Francis step actually does)

State: upper Hessenberg matrix `H` (bandwidth 1), real; trailing 2×2 block `B = [[h(n-1,n-1), h(n-1,n)],[h(n,n-1), h(n,n)]]`.

1. **Shifts (Wilkinson).** Eigenvalues of `B`; take:
   - complex pair → use both `mu, conj(mu)` (this is the "double shift");
   - real pair → use the one closer to `h(n,n)` (single shift; LAPACK squares it).
   LAPACK computes them scaled (divide block by `s = Σ|entries|`, `tr = (h11+h22)/2`,
   `det = (h11-tr)(h22-tr) − h12*h21`, imag = sqrt(|det|) when complex).

2. **First column only.** With `mu = x + iy`, the product `N = (H−mu)(H−conj(mu)) = (H−x)² + y²` is real
   and Hessenberg-dependent: `N e1` needs only entries `{h11,h21,h12,h22,h32}` (a 3×2 corner):
   `N e1 = ( h11² + h21·h12 − 2x·h11 + (x²+y²),  h21(h11+h22−2x),  h21·h32 )ᵀ`.
   LAPACK scales by `|h11−x|+|y|+|h21|` to avoid overflow, normalizes by the L1 norm → vector `V`.
   *Verified:* for the 5×5 example, `N e1 = (5,2,1)`, LAPACK-formula `V = (0.625, 0.25, 0.125)` — match
   to 1e-16.

3. **First reflector.** Householder `G1` (3×3) from `V` (`beta = −sign(V1)·‖V‖`), applied as a
   similarity `G1·H·G1`. Creates exactly 3 entries below the subdiagonal (the *bulge*), e.g.
   (3,1),(4,1),(4,2) in 1-based indexing.

4. **Chase.** For k = 2..n−1: read the (≤3) off-band entries in column k−1, build the reflector that
   zeroes them, apply on both sides. Each reflector is 3×3 (2×2 at the end). The bulge pattern measured
   on a 6×6: (3,1)(4,1)(4,2) → (4,2)(5,2)(5,3) → (5,3)(6,3)(6,4) → (6,4) → gone. Cost O(n) flops per
   reflector ⇒ O(n²) per step, all real.

5. **Guarantee (Implicit Q theorem).** If `QᵀAQ` is upper Hessenberg with positive subdiagonal, then
   `Q` (and the result) is uniquely determined by its first column `Q e1`. Both the explicit double
   shift (Q from QR of `N`) and the implicit one have first column ∝ `N e1` and Hessenberg output ⇒ they
   are the same step. *Verified:* `‖A_implicit − A_explicit‖_F = 8.3e-15` (5×5), `6.2e-15` (6×6);
   first columns match to 3e-16.

## Worked example (5×5, verified)

```
A = [[1,2,3,4,5],[1,1,1,1,1],[0,1,2,1,1],[0,0,1,0,-1],[0,0,0,2,0]]
eig(A) = {3.79056, −0.259498±1.23247i, 0.364220±0.930148i}   (Wolfram cross-check)
trailing 2×2 [[0,−1],[2,0]] → shifts ±1.414214 i  (complex pair → true double shift)
12 double-shift steps (trace preserved at 4.0):
  h11 → 3.79056      |h21| → 2.2e-12      |h43| → 3.5e-104     bottom 2×2 → −0.25950±1.23247i
```

## Convergence facts (measured)

- Unshifted QR on a 6×6 symmetric tridiagonal: linear, ~|h56| 0.229 → 1.5e-56 in 199 iterations.
- Same matrix + Wilkinson shift: 2.6e-3 → 1.1e-10 → 1.7e-26 → 3.8e-42 (cubic; exponent triples/step).
- Real shift on a complex pair: oscillates, never converges (must use the conjugate pair).
- Exceptional shifts: LAPACK uses ad-hoc shifts every 10 iterations (KEXSH=10; DAT1=3/4, DAT2=−0.4375).

## Implementation notes (what LAPACK does on top)

- Pre-reduce to Hessenberg once (`dgehrd`, O(n³)); each Francis step then O(n²); total O(n³).
- Deflation: when a subdiagonal entry is negligible (absolute + Ahues–Tisseur relative criteria), split
  the problem and shrink the active window; standardize converged 2×2 blocks with `dlanv2`.
- `zlahqr` (complex input): single complex shift per step, no double shift needed.
- Modern large-matrix path: small-bulge **multishift** QR (`dlaqr5`, Braman–Byers–Mathias) — batch of
  shifts, wider bulge, blocked updates, aggressive early deflation.
- Iteration cap ITMAX = 30·max(10, n).

## Open questions / limits worth knowing

- No unconditional proof that the *pure* Wilkinson-shift iteration converges globally for arbitrary
  non-symmetric matrices — hence exceptional shifts; rigorous global-convergence analysis is recent
  (Batterson–Smillie line of work).
- Non-normal (near-Jordan) matrices: eigenvalues still found (similarity invariants), but accuracy is
  bounded by eigenvalue condition numbers, which can be ≫ ‖A‖ε.

## Reproducing everything

- `scripts/verify_francis.py` — dependency-free Python: all identities, bulge traces, convergence data.
- `scripts/demo_francis.mjs` + `scripts/test_demo.mjs` — the page's demo core, cross-checked in Node.
- `scripts/francis_step.m` — MATLAB version of the worked example (same algorithm; outputs here were
  produced by the identical Python code).
- `francis-qr-step.html` — the full figure-driven explainer with interactive steppers.