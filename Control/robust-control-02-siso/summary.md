# Robustness for SISO Systems — rewritten teaching note

**Status:** standalone rewrite complete; 16-page compiled PDF. Scope: Scherer chapter 2,
printed/PDF pp. 16–45, checked against `.amp/in/book/scherer.pdf` (text extracted locally).
The main reading occupies pp. 1–9; the separate all-ten exercise guide pp. 10–15;
reproduction, evidence levels, and sources are on p. 16. No shared index or other chapter edited.

## Teaching progression

1. Derive negative-feedback signal equations with input disturbance and measurement noise;
   explain S, T, GS, KS by the signals they protect, not names alone.
2. Expose a hidden unstable cancellation; distinguish transfer-interconnection internal stability,
   stability of S alone, minimal realizations, and arbitrary hidden states.
3. Derive Nyquist's N = P − Z with the book's clockwise domain contour and leftward detours.
   Work an unstable one-state process by eigenvalues and Nyquist geometry.
4. Interpret gain, bidirectional phase, and one-direction delay changes separately. Use every
   crossover, then illustrate mixed gain/phase fragility with actual computed curves.
5. Separate the book's fixed-pole-count frequency model from the stable uncertainty-block model.
6. Factor the perturbed denominator to derive weighted small gain and distinguish open/closed
   uncertainty balls, equality endpoints, robust radii, and well-posedness.
7. Derive the SISO performance sum by minimizing the scalar denominator over a disk; work a
   thermal actuator example with an analytic continuous maximum and a relaxed certificate.
8. Analyze a lightly damped flexible satellite, separating covering-class RS, covering-class RP,
   and actual pure-delay boundaries. Explain grids versus continuous norm algorithms and why
   failure of a sufficient upper bound is not proof of failure.

Three reproducible SVG plots: `assets/nyquist.svg`, `assets/thermal.svg`, `assets/satellite.svg`.
The standalone Libertinus/A4 styling follows chapter 7, without deleted teaching templates.

## Consequential corrections

- The earlier summing-junction prose placed the disturbance at the output while using the
  input-disturbance inverse. The rewrite derives the correct matrix from u = Ke + d.
- The earlier “equivalence” omitted nominal S stability from the no-cancellation condition.
  S, GS, KS together are the book's internal transfer stability, not merely external stability.
- Corrected Nyquist sign/orientation reasoning; shifting a curve by 1 never reverses its turns.
- The normalized relative error need not be stable in the book's model: the explicit plants
  1/(s−1) and 1/(s−2) show this and show why arbitrary intermediate plants can add unstable poles.
- Strict uncertainty inequalities support the book's non-strict norm endpoint. A closed ball
  generally requires a strict product bound; an explicit static counterexample explains why.
- Delay error oscillates at high frequency; it does not converge to 2. Proved the sqrt(12)
  cover globally and its optimality only in the fixed-slope first-order family. At zero the
  normalized maximal-delay error tends to −1, so it is not in a strict norm ball.
- Kept exercise damping 0.00396 distinct from Example 2.6's 0.0396. The exercise's apparent
  WT*S typo is identified; the theorem uses WT*T. A weight radius is not a delay multiplier.
- A bad dynamic plant in the covering class is not a demonstrated bad physical delay.
- Exercise 6 now proves that the cancelled zero is simple (derivative 1+a1 ≥ 1).
- Exercise 7 proves the converse count via N ≤ P ≤ m, rather than assuming no cancellations.
- Exercise 8 uses f + epsilon*|z|² for the maximum principle, avoiding the inherited invalid
  strict-circle argument and disconnected-set issue.
- Exercise 9 no longer assumes Delta or its auxiliary factor stable; it is explicitly an
  advanced meromorphic contour proof outline, with the missing technical detail identified.
- Exercise 10 includes equal-degree loops with |L(infinity)| < 1, bounds the correct ratio,
  calls the delayed characteristic function a quasipolynomial, and replaces the incomplete
  Picard claim with a Rouche asymptotic proof locating infinitely many unstable roots.
- Corrected the bibliography's inherited chapter-7 annotation to chapter 2.

## Numerical evidence

- Exercise 1 eigenvalues: 1, −0.381966, −2.618034. Alpha ±0.001 moves the unstable pole
  by approximately ∓0.0002, consistent with the analytic derivative −1/5.
- Example 2.10: sampled closest distance 0.369757894 at 3.0574182 rad/s. Combined multiplier
  1.3192126−0.3969725i hits −1. Its gain 1.3776462 and phase −16.74739° separately remain
  stable (max root real parts −0.224573784 and −0.087265226); nominal value −0.159043807.
- Thermal RP exact maximum sqrt(1+0.6²/15) = 1.011928851 at sqrt(624) = 24.979992 rad/s.
  Relaxed Wp=0.8 has analytic continuous upper bound 0.814862.
- Satellite nominal max root real part −0.2070; continuous SLICOT ||W_0.25*T|| = 0.380542334,
  relative solver tolerance 1e−9; reciprocal radius 2.6278.
- All three unit-gain crossings checked both by sign-change refinement and polynomial root
  enumeration: 0.437820231, 0.940682791, 1.087921900 rad/s. Delay candidates 1.2663885,
  5.3455740, 0.7668651 s; residuals below 5e−15. At the earliest crossing Re(ds/dtau)=0.0916306 > 0.
- Covering-class RS delay threshold approximately 0.6720 s, not the actual 0.7668651 s margin.
- RP grid/refinement index 0.8095 at delay cover 0.25 s. Independently, a continuous SLICOT
  stacked norm gives sqrt(2)*||[Wp*S;W*T]|| = 0.851515352 < 1, certifying a sufficient RP bound.
- Covering-class RP threshold approximately 0.3781 s; bandwidth parameter threshold 0.20066 rad/s.
- At cover 0.5 s, explicit stable perturbation −0.9990(s−0.6601)/(s+0.6601) gives a stable
  perturbed loop (max root real part −0.0361) but weighted error peak approximately 1.7057 > 1.

## Build and visual validation

Run from repository root:
```sh
octave --no-gui --quiet Control/robust-control-02-siso/scripts/ex1.m
octave --no-gui --quiet Control/robust-control-02-siso/scripts/satellite_delay.m
octave --no-gui --quiet Control/robust-control-02-siso/scripts/figures.m
typst compile --root . Control/robust-control-02-siso/robust-control-02-siso.typ Control/robust-control-02-siso/robust-control-02-siso.pdf
```

All scripts pass, including added assertions. Typst compiles warning-free, 16 pages.
All-page text bounding boxes checked against 24 mm side margins with about 2 pt optical
protrusion allowance: no overflow. Sparse continuation pages found on the initial build were
eliminated by resizing figures and tightening the satellite table, not by shrinking body text.
Rendered representative pages 1, 4, 6, 7, 8, 9, 10, 11, 15, 16 were inspected using `view_media`,
including every plot page and the final page. Inspection also caught and corrected ambiguous
Typst absolute-value fraction syntax and grouped differential denominators.

Review artifacts: `.amp/in/artifacts/rewrite-02/` contains `page-01.png`, `page-04.png`,
`page-06.png`, `page-07.png`, `page-08.png`, `page-09.png`, `page-10.png`, `page-11.png`,
`page-15.png`, `page-16.png`, `numerics.txt`, `figures.txt`, `ex1.txt`, `build.txt`, and `layout.txt`.

## Limits

The RP threshold searches and fifth-order distance are grid-plus-refinement results, not
interval-certified extrema; passing RP at 0.25 s does have an independent continuous numerical
upper bound. SLICOT is floating point, not exact formal certification. The delay extension is
qualified, and equality at the covering delay threshold is not separately certified for the
irrational family. Exercise 9 remains a labelled advanced proof outline. No nonlinear,
saturation, identification, or sampled-data implementation guarantee is claimed. No package
installs, commits, demos, external web research, or shared-file edits were needed.

## Suggested landing-card paragraph

Derive sensitivity from the feedback signals, see why hidden unstable cancellations invalidate
good-looking plots, and turn Nyquist margins into weighted small-gain and robust-performance
tests. Worked thermal and flexible-satellite examples distinguish true delay margins from
uncertainty-cover guarantees, with reproducible plots and all ten chapter exercises.
