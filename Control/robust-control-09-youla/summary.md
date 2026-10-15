# Youla Parametrization — rewrite summary

**Status:** rewritten in response to confusion with the earlier chapter; reader
comprehension is not yet assessed. Standalone Typst source and compiled PDF (13 pages),
with `refs.bib`, executable `scripts/examples.m`, and `assets/youla-response.svg`.

## Teaching progression

1. Start with a stable scalar plant in ordinary negative-feedback tracking. Define Q as
   the reference-to-control transfer and solve the signal equations for the controller.
2. Prove internal stability using all four closed-loop maps. Separate properness,
   well-posedness, internal stability, and stability of the controller itself.
3. Work a one-parameter family of stable Q's and plot the physical step responses.
   Explain affine model matching and when it does, or does not, produce a convex problem.
4. Introduce coprime factors only when an unstable plant makes them necessary. Derive
   scalar Youla in both directions and work an unstable first-order plant explicitly.
5. Mark the switch to the book's positive interconnection convention. Give the matrix
   double Bézout identity and Youla formula, then derive the affine closed-loop map from
   an observer-based innovation/correction construction.
6. Solve both exercises: H₂ projection and filtered inversion, followed by the
   lower-triangular controller construction and both directions of its correspondence.
7. Finish with a table separating the settings and their sign conventions. The abstract
   ring lemmas are not all reproduced; this is a derivation-first teaching rewrite.

## Corrections and checked examples

- A stable plant can be internally stabilized by an unstable controller. Conversely, a
  stable parameter still needs the stated properness and well-posedness conditions.
- For g = 1/(s − 1), the scalar factors give k = 2 at q = 0 and
  k = (3s + 1)/s at q = 1; both loops are checked directly.
- Exercise 1 is an **H₂ orthogonal projection**, not a Nehari/H-infinity distance
  problem. The example projection error is 1/sqrt(2); filtered-inverse errors decrease
  through 0.288675, 0.154303, and 0.070360.
- Exercise 2(c)'s stabilizability/detectability condition concerns **existence** of a
  triangular stabilizer, not whether every proposed controller is stabilizing.
- The exercise's printed controller generator omits the observer term LC, even at
  zero feedthrough. With A = B = C = 1 and F = L = −2, the printed K = −4/(s + 1)
  gives characteristic polynomial s² + 3 in the positive interconnection: not Hurwitz.
  The corrected K = −4/(s + 3) gives (s + 1)². The note supplies the full feedthrough
  corrections consistent with Theorem 9.16 and shows the observer derivation.
- Matrix-factor order in the inverse Youla formula is checked with noncommuting
  triangular matrices, not inferred from a scalar simplification.
- The observer-based affine map is compared numerically with the actual feedback
  interconnection, including nonzero direct feedthrough.

## Sources and validation

Scherer, *Theory of Robust Control*, chapter 9, pp. 224–240, especially Theorems 9.13
and 9.16 and the two exercises on pp. 238–240. Other bibliography entries are not
presented as consulted sources. Corrections above were checked against the printed
exercise and the theorem rather than silently changing the source formulas.

Run from the repository root:

```sh
octave --no-gui --quiet Control/robust-control-09-youla/scripts/examples.m
typst compile --root . Control/robust-control-09-youla/robust-control-09-youla.typ
```

All numerical assertions and the warning-free Typst build pass. The script regenerates
the figure. Rendered pages were inspected and PDF text checked against page margins.
