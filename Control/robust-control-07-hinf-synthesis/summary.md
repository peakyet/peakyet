# H-infinity Synthesis — rewrite summary

**Status:** rewritten after chapters 8–9, in response to the same request for clearer
teaching. Reader comprehension is not yet assessed. Standalone Typst source and
compiled PDF (16 pages), `refs.bib`, one executable `scripts/hinf_example.m`, and
`assets/hinf-example.svg`. The duplicate figure-generation script was removed; the
example script now validates the numbers and regenerates the figure together.

## Teaching progression

The first ten pages are the main explanation. Start with the physical signals and the
positive interconnection u = Ky, then derive a storage inequality and its Riccati Schur
complement. Complete the control/disturbance squares to derive state feedback, explain
Hamiltonian branch selection and inverse coordinates, obtain filtering by duality, and
introduce the coupling condition before assembling the central controller.

A noisy-measurement scalar plant is worked from hand-derived feasibility conditions
through the actual controller and physical closed-loop realization. The numerical
workflow, regularization, game interpretation, and bounded controller family follow.
The distinction between this chapter's norm-ball parameter and chapter 9's affine Youla
coordinates is explicit. Chapter 8's fixed-scaling synthesis step is the natural next use.

The final six pages guide all eleven exercises. The central algebra is developed for
1–5, 8, 10, and 11; the technical existence arguments in 6–7 and endpoint arguments
in 9 are explicitly labelled proof outlines, not advertised as complete proofs.

## Important corrections and examples

- A positive quadratic storage certificate, not a frequency plot, motivates the norm
  test. The introductory transfer 2/(s + 3) has exact norm 2/3 and shows both Riccati roots.
- A Hamiltonian with no imaginary-axis eigenvalues is not by itself sufficient for an
  arbitrary indefinite ARE; the graph subspace and positivity checks remain necessary.
- The running example distinguishes gamma = 0.70 (Riccati failure), 0.72 (both AREs
  pass but coupling fails), and 0.75 (a successful controller).
- The analytic output-feedback infimum is sqrt(3) − 1 = 0.732050807569. Bisection agrees;
  independent `hinfsyn` gives a physical-loop norm of 0.732050812.
- At gamma = 0.75, AK = −4.270995, BK = 3.799590, CK = −0.679623, and the achieved
  norm is 0.749283. The rationalized root also handles gamma = 1 without a 0/0 expression.
- The plotted achieved norm approaches the infimum from **above**, not below. The
  near-optimal central controller has large/fast coefficients, but that is not claimed
  to prove nonattainment for every possible controller or plant.
- The exact-state optimum is 1/sqrt(2), attained at F = −1; it differs from the noisy
  output-feedback threshold. Strict feasibility and non-strict attainment are separated.
- The LQG limit has H-infinity norm 0.921519 and H2 norm **0.696621399**. The latter
  corrects the old truncated-frequency-integral approximation, 0.696402.
- Exercise 9's residual matrix order is derived by subtracting AREs, correcting the
  printed order; noncommuting 2×2 data verify the algebra and branch correspondence.
- Exercise 10 uses X = X0 + tH with AᵀH + HA = −I, not X0 + tI. An asymmetric,
  nonnormal Hurwitz example demonstrates why the old argument failed. The general
  inequalities also correct dimensionally inconsistent transposes in the printed exercise.
- Exercise 11 derives interpolation/Pick constraints and meets an exact lower bound
  with an explicit stable proper matching filter. No claim that a fixed-controller norm
  LMI alone solves synthesis is retained.

## Sources and reproduction

Scherer, *Theory of Robust Control*, chapter 7, pp. 159–216, especially §§7.3, 7.6–7.11,
Theorems 7.13 and 7.40, and exercises 1–11. The printed exercise corrections were
checked on rendered source pages 214–215. No other bibliography entry is presented as
a consulted source.

```sh
octave --no-gui --quiet Control/robust-control-07-hinf-synthesis/scripts/hinf_example.m
typst compile --root . Control/robust-control-07-hinf-synthesis/robust-control-07-hinf-synthesis.typ
```

Numerical assertions pass: branch/coupling boundaries, analytic-vs-bisection optimum,
independent solver, full internal poles, independently eliminated feedback transfers,
state-feedback boundary, nonnormal Lyapunov construction, matrix order, and matching.
The PDF builds without warnings. Rendered pages and the landing card are inspected;
text-margin checks allow normal optical punctuation protrusion.
