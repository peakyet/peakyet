# Interconnections — signals first, fractions second

Chapter 3 of Scherer's *Theory of Robust Control*, pp. 46–65 (local
`.amp/in/book/scherer.pdf`; printed and PDF page numbers coincide). Rewritten as a
standalone Typst note, using chapter 7's standalone typography as the reference;
no deleted teaching-template imports. The note assumes basic LTI state-space and
transfer-matrix knowledge, not prior familiarity with LFTs.

## Explanation progression

1. Cut the controller out; assign external causes `w`, commands `u`, available
   measurements `y`, and performance variables `z`. Derive the ordinary tracking
   interconnection and explain why positive connection `u = Ky` still gives `I + GK`.
2. Solve the instantaneous feedthrough equations. Contrast an algebraically singular
   static loop with a well-posed but exponentially unstable dynamic loop.
3. Eliminate `y,u` step by step; only then name the resulting formula the lower LFT.
   An asymmetric scalar-actuation/two-measurement example checks matrix dimensions
   and noncommuting factor order (`u = 2.6w`, `z = 6.2w`).
4. Define internal stability through the unreduced joint state matrix. Separate
   initial-condition decay from zero-state transfer stability and physical realization
   states from cancelled transfer poles.
5. Use an asymmetric cancellation example, then independent controller-port disturbance
   injection, to derive the nine internal maps. State the precise realization assumptions.
6. Explain stabilization existence via stabilizability from `u` and detectability in `y`.
   Derive the observer construction and both PBH necessity arguments. Explain the
   distinction between a minimal realization of `P22` and the realization inherited
   from the entire plant. Unrestricted existence is not decentralized existence.
7–9. Work all three exercises, including decentralized controller computation.
10. Sources and explicit limits of proof coverage.

The final PDF has **9 pages**. Section starts: 1 on p.1; 2–3 on p.2; 4–5 on p.3;
6 on p.4; 7 on p.5; 8–9 on p.6; 10 and bibliography on p.9. Exercise 3's diagram
is on p.6, derivations on p.7, numerical design and Bode plot on p.8, and the
two-panel state diagnostic and reproduction instructions on p.9.

## Exercises and important corrections

- Exercise 1: complete nine-map reduction with `Q = K(I-P22K)^(-1)`, counterexample
  to testing sensitivity alone, and both directions of the Youla correspondence.
  The book's “free Q” assertion requires `det(I+D22 Q(infinity)) != 0` for proper
  controllers when feedthrough is nonzero. The static counterexample is retained;
  all stable Q are admissible when P22 is strictly proper.
- Exercise 2: all four plants analyzed; answers are a,c,d yes and b no. The rank-two
  integrator residue of b explains why merely listing pole locations is insufficient.
- Exercise 3: full MIMO-order-preserving derivation of Figure 23's open interconnection;
  nonstabilizable and hidden-unstable-controller examples; a single example can meet
  both requested properties. Numerical part uses K2=1 then a sixth-order observer K1,
  so the controller genuinely has the required diagonal information structure.
- Corrected the observer error-coordinate upper-right block to **-B2 F** for
  `e=x-xK`. The old plus sign (also printed in the book) is inconsistent with those
  coordinates, though it does not change the eigenvalue conclusion.
- Corrected the claim that identity-weight LQR gives a basis-independent controller:
  the state weights must transform with the realization. The script fixes both.
- Removed unsupported inherited claims of exact symbolic/Wolfram verification and
  of each of the nine blocks sharing all twelve poles. The reproducible checks here
  are Octave state-space, physical wiring, and direct disturbed-port equations.
- The nine-map theorem's Hautus step and the input-output existence theorem are
  explicitly **proof outlines**. Exercise solutions and the state-space existence
  construction include visible derivations; numerical PBH ranks are numerical evidence,
  not symbolic rank certificates.

## Reproduce and validate

From repository root, using already available tools (nothing installed):

```sh
QT_QPA_PLATFORM=offscreen octave --no-gui Control/robust-control-03-interconnections/scripts/ex3c.m
typst compile --root . Control/robust-control-03-interconnections/robust-control-03-interconnections.typ Control/robust-control-03-interconnections/robust-control-03-interconnections.pdf
```

The script writes `assets/ex3c-bode.svg` and `assets/internal-modes.svg`. Its assertions
check the asymmetric static port solution, the cancellation counterexample's physical
unstable controller states, PBH ranks, physical closure, error-coordinate triangularization,
the LFT, all nine disturbed-port blocks, and the initial-condition cancellation example.
The printed polynomial is rounded for reading; use the full-precision state-space
construction in the script to reproduce the design.

Results on the current stack (Octave control, Typst 0.15.1):

| Check | Result |
|---|---|
| Compilation | exit 0, no warnings |
| PDF | 9 A4 pages |
| Plant formula versus physical state-space construction | max error 2.40e-15 at 3 complex points |
| PBH controllability/detectability at 1,2,+i,-i,0 | rank 6 in every test |
| Physical joint state matrix versus general closure | error 0 |
| Observer error-coordinate triangularization | residual 8.88e-16 |
| Physical closed-loop spectral abscissa | -0.19019 (12 states) |
| Performance transfer versus LFT | max error 2.18e-12 at 3 points |
| Nine-map realization versus original disturbed signal equations | max error 4.07e-11 at 3 points |
| Joint nine-map minimal realization | 12 stable poles, spectral abscissa -0.1902 |
| Refined Bode peak | 24.6570 = 27.84 dB at 1.2535 rad/s |
| DC performance gain | 0 to printed numerical precision |

Review artifacts are in `.amp/in/artifacts/rewrite-03/`: `calculations.log`, empty
`compile.log`, `headings.json`, `margins.txt`, `final-1.png` through `final-9.png`,
and `final-contact.png`. All pages were reviewed in contact sheets with `view_media`;
the diagrams, large matrices, plots and closing page were also reviewed individually.
No clipping/overlap or sparse orphan closing page was found. Text bounding boxes were
checked against 24 mm text margins with a 2.55 pt optical-protrusion allowance; no
word lies outside that tolerance. Slight terminal punctuation/hyphen protrusion is
intentional. This is a text-bound check, supplemented by visual inspection, not a
vector-graphics collision detector.

Only this chapter's source, PDF, script, assets and summary were changed. The landing
page is owned by integration and was not edited. Source PDF and review artifacts
remain locally excluded; scratch is removed at completion. No web sources were needed.
