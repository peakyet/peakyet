# Robust stability — rewritten teaching note

Standalone Typst source and compiled 16-page PDF. Source: Scherer, *Theory of
Robust Control*, chapter 4, printed/PDF pp. 66–135. No shared template dependency.

## Reading route

Physical mass uncertainty → real/dynamic/repeated/full families → extract ports by
substitution → close the nominal controller → well-posedness and internal stability
→ stable-product homotopy → full-block small gain → asymmetric structured example
→ μ → D-scaling and real multipliers → all four exercises.

The main reading occupies pages 1–10; exercises pages 11–15; source map, reproduction
commands and proof limitations page 16. Assumes chapters 1–3, not prior knowledge of
the entire robust-control theory. Open and closed uncertainty balls are distinguished.

## Consequential corrections

- A failed upper bound is inconclusive, not an instability proof. A frequency-grid
  maximum is not a global continuous-frequency certificate.
- Preserve real constant parameters, repetition, independent bounds and matrix order.
  Complex dynamic errors are not interchangeable with real physical parameters.
- The homotopy proof explicitly prevents poles escaping through infinity by retaining
  well-posedness throughout the continuous finite-dimensional state-matrix family.
- For arbitrary redundant uncertainty extractions, singularity of the uncertainty-port
  inverse need not prove instability of the reduced physical plant. Examples retain
  the unreduced physical states for pole checks.
- Exercise 1's spurious direct w2-to-z1 term was removed. Separate block margins were
  unchanged, but the corrected joint equal radius is **0.1059211491**, not 0.108259.
- Exercise 2(a) now includes μ(D) ≤ 1. The example A=1, B=2, C=1, D=2 shows why
  nonsingularity at s=0 alone does not ensure the rationally perturbed matrix is defined.
- The low-complexity exactness result concerns the extended real-multiplier bound,
  not automatically plain D-scaling for real blocks. Frobenius scaling remains only
  an upper bound even when spectral D-scaling is exact.

## Reproduce

From the repository root, with installed Octave/control:

```sh
QT_QPA_PLATFORM=offscreen octave --no-gui --quiet Control/robust-control-04-robust-stability/scripts/ex1.m
octave --no-gui --quiet Control/robust-control-04-robust-stability/scripts/ex23.m
octave --no-gui --quiet Control/robust-control-04-robust-stability/scripts/ex4.m
QT_QPA_PLATFORM=offscreen octave --no-gui --quiet Control/robust-control-04-robust-stability/scripts/teaching.m
typst compile --root . Control/robust-control-04-robust-stability/robust-control-04-robust-stability.typ
```

The scripts regenerate `assets/ex1.svg`, `asymmetric.svg`, and `scaling.svg`.
All scripts exit successfully in the integrated run. Numerical results:

- Asymmetric example: full gain 4 versus diagonal μ=1. Actual poles at (0.2,4):
  −0.105572809 and −1.894427191; at (0.3,4): +0.095445115 and −2.095445115.
  The non-diagonal full-block witness has norm 0.25 and actual poles −1,0.
- Exercise 1: nominal spectral abscissa −0.149616; dynamic radius 0.13240864;
  real radius 0.18049401; real pole-shift radius 0.42560843; complex radius 0.24976616.
  Independent signal-elimination residual 4.201e−13. Refined mixed radius 0.1059211491
  at ω=1.6170771252, real shift +0.1059211491. Full augmented poles include
  8.216e−15 ± 1.6170771252i; determinant residual 6.077e−17.
- Exercise 2 determinant residuals 8.46e−16 and 3.82e−16 at zero.
- Exercise 3: μ=4.02; explicit witness norm 0.248756218905; residual 2.209e−17.
- Exercise 4: spectral scaling 13.075489479901 at t=1.322548857321;
  independent SVD witness lower bound 13.075487786689, residual 3.011e−16.
  Frobenius optimum t=0.84089642 gives upper bound 17.32531449, not μ.

## Verification and limits

Typst 0.15.1 compiles warning-free. All pages rendered and reviewed in a contact sheet;
plot/equation pages receive full-size review. The orphan Frobenius formula was brought
back onto Exercise 4's page without shrinking body text. All-page text margin audit
passes with 3 pt allowance for optical punctuation. Final artifacts and independent
rerun logs are under `.amp/in/artifacts/rewrite-integration/`.

Exercise 1 margins/trade-offs are grid and local-refinement estimates, supported by
actual physical pole witnesses, not certified global optimizations. Numerical decimals
are floating point. Full-block interpolation, endpoint small-μ arguments and general
cancellation-rank results are outlined or referred to the book; extended-multiplier
exactness is quoted, not proved. No claim that every theorem is fully reproved.
No installs, commits, publication or changes outside this chapter were made by its worker.
