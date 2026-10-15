# Chapter 1 — Systems, Signals, and Stability

Rewritten as a first encounter with the subject, using Scherer's *Theory of Robust
Control*, chapter 1, printed/PDF pp. 6–15. The note is standalone Typst, styled after
chapter 7; it no longer imports the deleted teaching template. No prior knowledge
of chapters 1–6 is assumed. Linear algebra and elementary differential equations
are assumed. There is no separate cover, contents page, or bibliography-only page.

## Teaching progression and page map

| PDF page | Purpose |
| --- | --- |
| 1 | A coupled two-state device motivates memory; derive the state response and separate initial memory, convolution, and feedthrough. |
| 2 | Derive the zero-state transfer relation and a step response; plot the visible states and an appended hidden unstable state. Explain properness and realization nonuniqueness. |
| 3 | Distinguish controllability, observability, minimality, internal stability, transfer stability, and zero-state BIBO. Explain the weaker stabilizability/detectability conditions and correct PBH ranks. |
| 4 | State Euclidean-in-time signal conventions, essential supremum, squared energy versus its square root, and induced gains. A sign-changing scalar kernel gives peak gain 5/6 by constructive addition in time. |
| 5 | Explain why energy gain is a frequency/singular-direction supremum. Plot the kernel and frequency magnitude; the same device has energy gain 1/2. A non-diagonal MIMO example gives 1+sqrt(2), not the largest entry gain. |
| 6 | Separate algebraic, proper, and stable inversion. Derive the inverse realization from the signal equations; explain the square/stable assumptions and the realization-test hypotheses. |
| 7 | Exercise 1: `sysic` wiring, explicit nine-state equations, sharing one memory, and a minimal-degree lower bound of eight. |
| 8 | Exercise 2: Parseval inequality and real, phase-correct, finite-energy bursts; justify transient/tail estimates and the diagonal sequence for a nonattained supremum. |
| 9 | Exercises 3–4: step-input attainment of scalar continuous peak gain; discrete Toeplitz row sums and an alternating-sign example with feedthrough. |
| 10 | Exercise 5: BIBO equivalence using a stable minimal realization and genuinely bounded counterinputs; reproduction commands and source. |

## Consequential corrections to the previous note

- BIBO and gains refer to **zero initial state**. A stable transfer does not force an
  arbitrary realization's A to be Hurwitz. The BIBO proof uses a stable minimal
  realization, so hidden unstable modes are not accidentally ruled out.
- A right-half-plane pole is exposed with a **bounded step**, not an exponentially
  growing input falsely called bounded. Imaginary-axis poles use bounded resonance.
- Exercise 3's constant input **does attain the induced peak gain** as a ratio of
  signal suprema. The output need not reach its supremum at a finite instant. The
  a=0 case is handled separately rather than divided by zero.
- Stabilizability uses full **row** rank of [A-lambda I, B], correcting the printed
  book typo and the old note. D has size k-by-m, not the book's k-by-n typo.
- Peak gain is not “uncomputable”: in stable scalar continuous time it is the
  absolute kernel integral plus absolute feedthrough; in scalar discrete time it
  is the absolute Markov-parameter sum. Neither is generally the frequency maximum.
- Sharpness for MIMO energy gain uses Re(v exp(i omega t)), retaining complex
  component phases, not a real vector times a common cosine. Infinite frequency
  is handled by finite frequencies and a diagonal sequence, not a sinusoid at infinity.
- The determinant-one unstable counterexample is transcribed correctly: its lower
  diagonal entry is (s+2)/(s+1). Stability of G and nonsingular G(infinity) are explicit.

The five exercise derivations are worked, not advertised as a reconstruction of all
background theory. Minimal realization theory and Fourier–Parseval are explicitly
invoked; the separate qualitative L2-stability equivalence is stated as a standard
result, not claimed proved. There are no unlabeled advanced proof outlines.

## Reproduction and independently checked numbers

From the repository root:

```sh
octave --no-gui --quiet Control/robust-control-01-basics/scripts/ex1.m
typst compile --root . Control/robust-control-01-basics/robust-control-01-basics.typ Control/robust-control-01-basics/robust-control-01-basics.pdf
```

The script uses installed Octave control, assertions, quadrature, exact matrix
exponential propagation, Lyapunov tail integration, and deterministic SVG output
(no plotting backend or package installation). It regenerates both checked-in figures.

- Exercise 1 transfer errors at s=0.5,1,2,3: 2.220e-16, 5.551e-17,
  1.110e-16, 0; additional complex-point assertions pass at tolerance 1e-12.
  Block Hankel rank and `minreal` both give 8 states from 9.
- Coupled step response agrees with Octave `step` to 8.216e-15;
  y(6)=1.492572959789.
- Sign-changing kernel zero: 0.405465108108. Absolute integral:
  0.833333333333=5/6. Independently computed H-infinity norm: 0.500000000000.
  Exact sign-aligned propagation gives y(8)=0.832662576880.
- Constant pulses of durations 10,100,1000, **including the infinite output tail**,
  give energy-gain ratios 0.487339717267, 0.498748433581, 0.499874984371.
- MIMO singular gain: 2.414213562373; normalized direction:
  [0.382683432365, 0.923879532511].
- Inverse examples b=-1 and b=3 have poles +1 and -3; inverse-product assertions
  at complex points pass at tolerance 1e-12.
- Discrete horizon 6 row-sum norm and attained output both equal 4.187500000000;
  infinite-horizon limit is 4.25.

Matlab Robust Control Toolbox is unavailable: the `sysic` wiring example has **not**
been run. Its entrywise hand realization and reduction are verified with Octave.

## Build and visual review

- Typst 0.15.1: successful build, no warnings; final PDF has **10 pages**.
- All ten pages rendered and inspected with `view_media`, including both two-panel
  plots, the exercise matrices, and the closing page. No sparse continuation,
  orphan heading, clipped equation, or bibliography-only page remains.
- `pdftotext -bbox` checks every extracted word against 24 mm horizontal margins,
  with 3 pt optical punctuation allowance; no content overflow. Reference extraction
  contains no unresolved `(?)` markers. SVG plots were also checked in rendered pages.
- Final review artifacts: `.amp/in/artifacts/rewrite-01/page-01.png` through
  `page-10.png`, `numerics.txt`, `build.txt`, and `layout.txt`.
- Scratch under `.amp/in/rewrite-01/` was removed after verification.

## Suggested landing-card description

Start with a device that remembers its past, then learn what its state equations
and transfer matrix reveal—and what hidden modes can conceal. Worked examples and
plots distinguish peak from energy amplification, internal from BIBO stability,
and algebraic inversion from a stable, implementable inverse. Includes all five
chapter exercises and reproducible Octave checks.
