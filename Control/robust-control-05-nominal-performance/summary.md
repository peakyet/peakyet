# Chapter 5 — Nominal performance specifications

## Scope and source

Standalone eight-page teaching note based on Scherer, *Theory of Robust Control*,
Chapter 5, printed/PDF pp. 136–143. Source checked from the local authoritative
PDF text, including Theorems 5.1–5.2 and Hypothesis 5.3/Lemma 5.4. No web sources.
Chapter 5 has **no book exercises**. The final three solved self-checks and all
numerical examples are original teaching additions, not attributed exercises.
The note uses Chapter 7's standalone A4/Libertinus/navy/teal style, with no deleted
shared-template dependency. `refs.bib` is unchanged.

## Teaching progression and PDF page map

Each numbered section starts on the corresponding PDF page (1–8):

1. Energy gain versus persistent-sinusoid steady-state RMS gain: same norm,
   different signal classes; no step-peak guarantee.
2. Construct the worst singular-vector direction; complex phases and real RMS
   factors; real DC vectors and the infinite-frequency feedthrough limit;
   orthogonality proof for finite sums.
3. Input shaping versus inverse output envelopes, physical units, feasible and
   infeasible interpretations of the same numbers, amplitude ellipsoids.
4. Explicit tracking-loop signs and signal locations; S, T and CS; error and
   actuator-effort specification, with a concrete stable loop.
5. Stacked input sets versus independent budgets; stacked output requirements
   versus separate channel bounds; generated two-panel frequency plot.
6. Noncommuting matrix weights, phase-sensitive model matching, an exact dynamic
   model-matching peak and endpoint checks.
7. Algebraic generalized-plant augmentation; stable cascade state argument;
   limits of the common-P22 argument and a hidden unstable-state counterexample.
8. Three solved self-checks (incompatible S/T demands, budget allocation, scaling),
   reproducible workflow and bibliography. No trailing bibliography-only page.

## Consequential corrections to the previous note

- The stacked unit input ball is smaller, not larger, than independent unit
  balls; protecting independent full-size inputs is the stronger demand.
  Bounds of 1/3 concern **squared** individual RMS values.
- Real sinusoids have the 1/sqrt(2) RMS factor at nonzero frequency; DC does not.
  Complex right singular vectors encode physically realizable relative phases.
- Matrix-weight order cannot be replaced by a scalar reciprocal ceiling.
- Equal P22 alone does not establish internal equivalence of arbitrary nonminimal
  realizations. The note supplies stable-realization/topology assumptions and
  distinguishes these from the book's generalized-plant hypothesis.
- No claim that an optimum must hug every frequency of a selected envelope.
- RMS actuator effort is not a pointwise saturation guarantee.

## Executable examples and evidence

Run `octave --no-gui --quiet Control/robust-control-05-nominal-performance/performance_examples.m`.
The script regenerates `assets/budgets.png` and passes all assertions:

- G=1/(s+1), C=9: S=(s+1)/(s+10), T=9/(s+10), CS=9S.
- Weights WS=2/(s+.2), WT=(s+1)/(2(s+10)), Wu=.1.
- Exact stacked norm: **1.005049750**, versus grid **1.005037811**.
  DC squared gain is 1.010125; effort limit is .9. A nonnegative polynomial
  certificate H(0)D−N proves the global upper bound, independently of the grid.
  The stack is not assumed monotone; its channels trade dominance.
- Static joint-input row gain .848528137 versus independent-input output 1.2.
- Static output stack gain 1.131370850 although each channel gain is .8.
- Correct matrix-weight order gives norm 1; the reordered product gives 2.
- Complex phase direction gives sqrt(2), whereas real directions give 1 at ω=1.
- Dynamic model-matching gain is exactly 1/3 at ω=sqrt(2); derivative algebra
  checks the peak, and Octave verifies its value.

## Build and visual QA

`typst compile --root . Control/robust-control-05-nominal-performance/robust-control-05-nominal-performance.typ Control/robust-control-05-nominal-performance/robust-control-05-nominal-performance.pdf`

Compiled successfully with **zero warnings**, eight A4 pages. All eight pages
rendered at 1200-pixel long edge; full contact sheet inspected. Plot page 5,
representative mathematical prose page 7 and final page 8 inspected individually
with `view_media`: no clipped equations, overlaps or orphan pages.

Artifacts: `.amp/in/artifacts/rewrite-05/` contains `octave.log`, empty successful
`build.log`, `page-1.png` through `page-8.png`, and `contact.png`.
Bounding-box audit: body left edge 68.03 pt, nominal right edge 527.24 pt;
maximum text right edge 529.29 pt is 2.05 pt optical punctuation/hyphen overhang,
within a 3 pt allowance. No true horizontal margin violations.

## Limitations and integration

Examples test nominal specifications; they do not synthesize a controller, certify
robust performance, or test actuator saturation. No installs or commits. Shared
index and other chapters were not edited. Scratch directory was removed after QA.

Suggested landing-card paragraph:

Translate tracking, disturbance rejection, noise suppression and actuator effort
into weighted H∞ specifications. Distinguish signal shaping from inverse error
envelopes, separate from stacked budgets, and scalar from directional matrix
weights; then build a generalized plant with the right internal-stability
assumptions. Includes computed examples and three solved self-checks.
