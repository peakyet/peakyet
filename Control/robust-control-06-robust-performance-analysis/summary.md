# Robust performance analysis — rewritten teaching note

Standalone source plus compiled 11-page PDF, following Scherer chapter 6, printed/PDF
pp. 144–158. Assumes the rewritten uncertainty and performance-weighting chapters.
This is analysis, not an assertion that an arbitrary synthesis run meets its targets.

## Teaching progression

1. A stable physical perturbation separates nominal performance, robust stability and
   robust performance: both individual gains are 0.6, yet the actual error gain exceeds 1.
2. Cut the uncertainty only after closing the controller. Derive every sign, matrix
   dimension and the physical closure before introducing LFT/μ notation.
3. Derive the fictitious full performance block with singular vectors; prove the
   finite-matrix Main Loop Theorem by a Schur complement, retaining both determinant factors.
4. Distinguish the book's open-ball/non-strict theorem from a uniform strict certificate.
   State dynamic interpolation, nominal internal stability and infinity hypotheses.
5. Explain scaling by an asymmetric exact example, then separate physical uncertainty
   radius from desired performance level. An upper bound above one remains inconclusive.
6. Work Exercise 1(a–d), including deterministic arbitrarily bad MIMO witnesses, and
   Exercise 2(a–e), reporting exactly what two illustrative designs achieve and miss.

Five generated figures: `assets/three-tests.png`, `asymmetric-scaling.png`, `ex2-W.png`,
`ex2-c.png`, `ex2-e.png`. No external assets, package installs or shared templates.

## Important corrections and qualifications

- For input-multiplicative uncertainty the plant is G(I+ΔW); do not commute matrix
  weights. The physical cut has both negative entries −WKSG and −VSG.
- The auxiliary block is a full complex performance block, not another real physical
  parameter. The exact complex dynamic theorem is not an exact test for a smaller
  real-constant family merely by changing labels.
- A bound μ(N) ≤ γ changes both the performance level and admissible uncertainty
  radius. It does not guarantee gain γ on the original unit family.
- The Exercise 2 disturbance enters between G and H, so its path is 0.5H, not 0.5HG.
- The chosen proper uncertainty weight approximates the requested finite-band rise;
  it cannot cover an indefinitely rising asymptotic 40 dB/decade envelope.
- Exercise 2(c) misses the requested bandwidth. Part (e) certifies robust stability,
  but misses the original performance targets; neither is called a complete successful
  design. No infeasibility claim or claim of exhaustive tuning is made.
- Output overshoot is explicitly error undershoot for e=1−y; the wording “error
  overshoot” is ambiguous for an error starting at one and converging nearly to zero.
- Physical state eigenvalues retain controller, plant and uncertainty modes. High-order
  cancelled polynomial roots are diagnostic, not an internal-stability certificate.

## Reproduce and numerical evidence

From the repository root:

```sh
QT_QPA_PLATFORM=offscreen octave --no-gui --quiet Control/robust-control-06-robust-performance-analysis/scripts/analysis.m
octave --no-gui --quiet Control/robust-control-06-robust-performance-analysis/scripts/ex1d.m
QT_QPA_PLATFORM=offscreen octave --no-gui --quiet Control/robust-control-06-robust-performance-analysis/scripts/ex2.m
typst compile --root . Control/robust-control-06-robust-performance-analysis/robust-control-06-robust-performance-analysis.typ
```

All scripts pass in the integrated run.

- Scalar witness Δ=−0.9: physical pole −0.92, gain 1.30434782609;
  physical-loop/cut-loop discrepancy 2.56e−16.
- Asymmetric N: unscaled norm 4.01649220409, exact scaled norm/μ 0.81789083458,
  ratio √50, singularizing-witness residual 5.08e−17.
- Exercise 1(d), h=10 and 100: μ lower bounds 10.1 and 100.01;
  explicit two-full-block witness residuals 6.36e−17 and 2.93e−16.
- Exercise 2 Routh threshold **2.02005** exactly; k=1,1.5,2 sampled |WT| peaks
  0.7320, 2.557, 100.6. The last two are explicit violating frequencies.
- Nominal design (c): synthesis objective 42.71, six-state controller, full physical
  spectral abscissa −0.00106810981. Low-frequency disturbance gain 0.00756, DC error
  approximately 5e−5, error bandwidth 56.8 rad/s (requested 10–20), output overshoot
  3.35%. The objective above one is not a performance certificate.
- Continuous-frequency norm, solver relative tolerance 1e−7: ||WT||=30.45302604
  at 581.7436797 rad/s, normalized radius 0.0328374592. All-pass phase parameter
  about 171.1. At the boundary, return-difference residual 2.3e−13 and full-state
  rightmost real part about 5.0e−7 (floating-point marginal candidate, not a strictly
  unstable certificate). At 1.2/1.5/2 times the radius, physical rightmost real parts
  +39.08085/+89.88860/+160.65993 give large-gap instability witnesses.
- Augmented design (e): eight-state controller, synthesis objective 322.7,
  ||WT||=0.6457227588 at 25.76099139, margin 1.548652245. DC error 0.0003743,
  low-frequency disturbance gain 0.0567, bandwidth 6.50 rad/s, output overshoot 34.9%:
  robust stability improves but the original nominal targets are missed.

## Verification and limits

Typst 0.15.1 compiles warning-free. All 11 pages rendered and contact-sheet reviewed;
all five plot pages and the closing page receive full-size review. All-page text margin
checks pass with 3 pt optical punctuation allowance. Integrated logs and final page
renders: `.amp/in/artifacts/rewrite-integration/`.

Response crossings, finite-band maxima and transient peaks are sampled measurements;
continuous H∞ norms use floating-point SLICOT, not interval proof. Design (c)'s
near-cancelling slow modes cause up to 2.06e−6 absolute disagreement between independent
frequency algebra and the state-space sensitivity; its low-frequency digits are limited.
Design (e)'s discrepancy is below 6e−13. The dynamic interpolation theorem is invoked
with a labelled proof outline, not reproved. Section 6.6's 2.71/2.72 values are quoted
book results, not newly reproduced computations. No successful all-target design,
nonlinear/actuator guarantee, publication or deployment is claimed.
