# Robust Performance Synthesis — rewrite summary

**Status:** rewritten in response to confusion with the earlier chapter; reader
comprehension is not yet assessed. Standalone Typst source and compiled PDF (9 pages),
with `refs.bib`, executable `scripts/distillation.m`, and `assets/redesign.svg`.

## Teaching progression

1. Begin with negative-feedback signal equations and distinguish the physical controller
   K from the certificate scaling D. Derive the uncertainty/performance cut matrix.
2. Separate structured singular value from its D-scaling upper bound. A bound below one
   certifies success; a bound above one is inconclusive. Use an asymmetric 2×2 calculation
   to show what changing a norm's coordinates accomplishes.
3. Explain the frequencywise D-step, stable rational fitting, and fixed-D controller
   synthesis. Ideal alternating minimization is non-increasing, not strictly decreasing;
   practical fits and solver outputs must be checked independently.
4. Work the distillation exercise from nominal decoupling through robust-stability and
   robust-performance tests, then show an actual restricted controller redesign.
5. Compare the physical step responses and directional controller gains. Close with four
   distinctions to retain rather than another list of formulas.

## Computed exercise and limitations

- The DC plant matrix has condition number 141.732. Exact nominal inversion therefore
  amplifies the weak direction severely.
- For beta = 0.1, 0.3, 0.5, 0.7, the robust-stability norms are 0.100000, 0.263119,
  0.402027, 0.520384, while sampled robust-performance upper bounds at alpha = 1 are
  3.8966, 6.1924, 7.6133, 8.6532.
- Failure is established separately using admissible Delta = diag(-0.99, 0): the actual
  weighted gains at frequency 0.1 exceed one for all four controllers. Because the
  uncertainty weight has DC gain 0.1, this is a **9.9% DC input-gain reduction**, not 1%.
- The redesign explicitly relaxes the specification to alpha = 0.1, beta = 0.5. It uses
  **two constant-D/controller update attempts**, an order-zero restriction of D-fitting;
  it is not a dynamic D–K implementation and does not meet the original alpha = 1 brief.
- Initial continuous scaled norm: 32.602516226. The first sixth-order controller gives
  0.791033815. The second D-step gives 0.791033502; its controller candidate gives
  0.791034198, so the incumbent is retained rather than claiming numerical improvement.
- The resulting bound below 0.7911 certifies the relaxed robust-performance specification
  for the stated uncertainty family, subject to numerical accuracy. The finite-grid
  D-search is not claimed to attain a global optimum.
- For the same selected uncertainty, the nominal decoupler's step errors peak at
  (3.230, 3.825), whereas the redesign peaks at (1, 1). The redesign still undershoots;
  robust performance does not imply monotone step responses.
- Corrected nominal 2% settling time: -log(0.02)/beta.

## Sources and validation

Scherer, *Theory of Robust Control*, chapter 8, pp. 217–223, including the exercise on
pp. 222–223. Examples and computations are developed here; other bibliography entries
are not presented as consulted sources.

Run from the repository root:

```sh
octave --no-gui --quiet Control/robust-control-08-robust-performance-synthesis/scripts/distillation.m
typst compile --root . Control/robust-control-08-robust-performance-synthesis/robust-control-08-robust-performance-synthesis.typ
```

The script checks norms with explicit accuracy, closed-loop poles, controller updates,
and step responses, and regenerates the figure. Both numerical checks and the warning-free
Typst build pass. Rendered pages were inspected and PDF text checked against page margins.
