// Standalone: typst compile --root . <this file> <same stem>.pdf
#set document(title: "Robust Performance Synthesis: understanding D–K iteration", author: "Amp")
#set page(paper: "a4", margin: (x: 24mm, y: 21mm),
  header: text(size: 9pt, fill: rgb("#5b6470"))[Robust control · Chapter 8],
  footer: context align(right, text(size: 9pt, counter(page).display("1"))))
#set text(font: "Libertinus Serif", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("#1f4e79"))
#let takeaway(body) = block(width: 100%, inset: 10pt, fill: rgb("#edf5f5"),
  stroke: (left: 2pt + rgb("#0f766e")), body)

#text(size: 23pt, weight: "bold", fill: rgb("#1f4e79"))[Robust Performance Synthesis]

#text(size: 15pt)[Understanding what D–K iteration actually changes]

A controller can be excellent for the nominal model and poor for a slightly different
plant. Chapter 6 gave us a way to *test* that risk; chapter 7 gave us a way to *design*
for an ordinary $H_infinity$ bound. This chapter explains how to use the second tool to
improve the first test.

There are only two moving parts. *The controller $K$ changes the physical closed loop.*
*The scaling $D$ changes how we certify that loop.* Confusing these roles makes the
algorithm look much more mysterious than it is.

#takeaway[
  The route through this note is: define the loop being tested → understand why scaling
  preserves the uncertainty problem → alternate analysis and controller design → check
  what the final number actually proves.
]

= First fix the signals, not the algorithm

Use the negative-feedback tracking convention throughout the examples:
$ e = r-y, quad u=K e, quad y=G(u+v), quad q=W u, quad v=Delta q. $
Thus the true plant from $u$ to $y$ is $G(I+Delta W)$. Here $G$ is the nominal plant,
$W$ is a known uncertainty weight, and $Delta$ is the unknown normalized perturbation.
The performance output is $z=W_p e$. A small $z$ means the specified tracking error is
small, not necessarily that every unweighted signal is small.

*Where do the two loops go?* Close the controller loop first, but leave the uncertainty
ports $v,q$ open. The remaining stable system is called $M_K$:
$ mat(q; z) = M_K mat(v; r), quad v=Delta q. $ <eq:cut>
Nominal internal stability is a prerequisite: an unstable $M_K$ is not rescued by a
small frequency-response plot.

For this tracking configuration, let $S=(I+G K)^(-1)$. Eliminating $e$ gives
$ e=S r-S G v, quad u=K S r-K S G v, $
and hence
$ M_K = mat(-W K S G, W K S; -W_p S G, W_p S). $ <eq:mk>
The top row describes uncertainty feedback; the bottom row describes weighted error.
Keeping the off-diagonal blocks matters: uncertainty changes the error through them.

#pagebreak()
= What exactly are we trying to make smaller than one?

The design requirement has two parts: *every allowed plant is internally stable*, and
*every allowed plant satisfies* $norm(T_(z r)(Delta))_infinity<1$, where $T_(z r)$ denotes
the transfer from $r$ to $z$. Equivalently, the weighted disturbance-to-error energy gain
must be below one uniformly over the uncertainty family.

The Main Loop Theorem packages these two requirements into one structured robustness
test. Append a fictitious full block $Delta_p$ from $z$ back to $r$:
$ Delta_e="diag"(Delta,Delta_p). $
The appended block is a *test device*, not an additional physical modelling error.
A performance channel with gain larger than one can be destabilized by an appropriately
chosen full block of norm below one. This is why performance can be tested as stability
of an extended loop.

For the standard complex, norm-bounded LTI uncertainty setting of chapters 4 and 6,
the target, with a strict margin, is
$ gamma_mu(K):=sup_omega mu_(Delta_e)(M_K(i omega)) < 1. $ <eq:target>
Real constant parameter blocks require extra care; the complex-block test used below
can conservatively overbound them. Frequencies include zero and the limit at infinity.

== An exact criterion is not yet a convenient design method

For a matrix $M$, $mu_(Delta_e)(M)$ is the reciprocal of the smallest structured
perturbation norm that makes $I-M Delta_e$ singular (and is zero if no such perturbation
exists). It is *not defined as an optimization over scalings*. Scalings give an upper
bound on it.

Directly optimizing $gamma_mu(K)$ is difficult: the destabilizing perturbation is
structured, the worst frequency is unknown, and the closed-loop matrix depends
nonlinearly on the controller. There is no general-purpose global solution supplied by
the chapter. This does not mean $mu$ is never exactly computable; special structures have
exact formulas. It means that the general structured synthesis problem is not reduced to
the ordinary $H_infinity$ machinery of chapter 7.

Instead, design for the computable sufficient condition
$ mu_(Delta_e)(M_K(i omega))
  <= inf_(D in cal(D)) norm(D^(-1) M_K(i omega) D)_2. $ <eq:bound>
The subscript 2 here means the largest singular value of a *matrix at one frequency*.
The $H_infinity$ norm is the supremum of that value over frequency for a stable system.

#takeaway[
  An upper bound below one certifies success. An upper bound above one means
  *this certificate did not succeed*. It is not a proof of robust-performance failure,
  and certainly not a proof that no controller can succeed.
]

#pagebreak()
= Why is changing D legitimate?

Suppose the uncertainty has two independent scalar channels and a full performance
block. An admissible scaling is
$ D="diag"(d_1,d_2,d_p I), quad d_1,d_2,d_p>0. $
It commutes with every allowed $Delta_e$. Therefore
$ D^(-1)(I-M Delta_e)D = I-(D^(-1)M D)Delta_e, $
so the scaled and original interconnections become singular for exactly the same
uncertainties. Small gain applied to the scaled matrix gives the bound in @eq:bound.

In signal terms, define $tilde(q)=D^(-1)q$ and $tilde(v)=D^(-1)v$ on the extended ports.
The uncertainty relation remains $tilde(v)=Delta_e tilde(q)$. We changed the rulers
used to measure internal signals, not the plant, the uncertainty budget, or the physical
performance weight $W_p$.

== A two-by-two calculation worth doing once

Take a fixed-frequency matrix and two independent complex scalar uncertainties:
$ M=mat(0,10; 0.01,0), quad Delta_e="diag"(delta_1,delta_2). $
Its unscaled norm is 10, so unscaled small gain says nothing useful. But
$ det(I-M Delta_e)=1-0.1 delta_1 delta_2. $
Destabilization requires $delta_1 delta_2=10$. The smallest possible
$max(|delta_1|,|delta_2|)$ is $sqrt(10)$, so $mu(M)=1/sqrt(10) approx 0.3162$.

Now set $D="diag"(d,1)$. Then
$ D^(-1)M D=mat(0,10/d; 0.01d,0), $
whose largest singular value is $max(10/d,0.01d)$. Balance the two terms:
$ 10/d=0.01d quad ==> quad d=sqrt(1000), quad norm(D^(-1)M D)_2=sqrt(0.1). $
The scaling recovers the exact answer in this example. *Nothing physical improved*:
the matrix was already robust, but the original norm obscured that fact.

== Which scalings are allowed?

- An independent *full* uncertainty block allows a scalar multiple of the identity.
- A *repeated scalar* block $delta I$ allows a matrix scaling within that repeated block.
- Blocks must retain their structure; an arbitrary mixing of channels is not allowed.

A common scalar multiplier on all of $D$ cancels from $D^(-1)M D$. Consequently the
performance-block scaling can be normalized to $I$. For the example above, our
$"diag"(d_1,d_2,d_p,d_p)$ is equivalently $"diag"(d_1/d_p,d_2/d_p,1,1)$.

#pagebreak()
= The algorithm: one variable fixed at a time

Write the joint surrogate as
$ J(K,D)=sup_omega norm(D(omega)^(-1) M_K(i omega) D(omega))_2. $
There are two different jobs hiding in this expression.

== D-step: analyze the controller you already have

Hold $K=K_j$ fixed. At each frequency, search the admissible scalings for a small
largest singular value. Record both the bound and a scaling that achieves it.
This step changes *only the certificate*. A better D-step does not change a step response.
One can formulate a fixed-frequency bound test using positive definite commuting
matrices and an LMI; a grid search alone is not an exact optimizer.

== Fit: turn frequency data into a realizable weight

The samples $D(omega_k)$ are not yet a transfer matrix. To use ordinary $H_infinity$
synthesis, construct a structured real-rational $hat(D)(s)$ that is proper and stable,
with a proper stable inverse. For independent scalar blocks, one commonly fits stable
minimum-phase scalar weights to the required magnitude profiles. Their phase is not
an extra physical uncertainty: diagonal unit-modulus phases give unitary changes of
coordinates and leave singular values unchanged.

For example, $hat(d)(s)=c(s+a)/(s+b)$ with $a,b,c>0$ has a stable pole, a stable zero,
and finite nonzero limits at zero and infinity. Both it and its inverse are proper
and stable. A constant positive $d$ is the simplest possible fit, of order zero.

The important check is the *scaled bound after fitting*, not just whether a curve
looks smooth. A small absolute fitting error can matter greatly if a scaling or its
inverse is poorly conditioned.

== K-step: design a new physical controller

Let $cal(K)$ denote the internally stabilizing controllers. Hold $hat(D)$ fixed and solve
$ inf_(K in cal(K))
  norm(hat(D)^(-1) M_K hat(D))_infinity. $
This is a standard weighted $H_infinity$ problem. Scale only the external uncertainty
and performance ports of the generalized plant; keep the measurement and control ports
in their original units. The resulting controller acts on the *original* physical loop.

#figure(
  grid(columns: (1fr, auto, 1fr), gutter: 8pt, align: center + horizon,
    block(inset: 10pt, stroke: rgb("#0f766e"))[
      *Fixed K* \
      analyze → choose D → fit
    ], [→],
    block(inset: 10pt, stroke: rgb("#1f4e79"))[
      *Fixed fitted D* \
      $H_infinity$ synthesis → new K
    ]),
  caption: [Repeat with the new controller. Re-analyze the original uncertainty
    structure after each physical change; stop at a verified bound below one or at stagnation.])

#pagebreak()
= What decreases, and what does not follow?

Imagine exact alternating minimization in one common admissible class, with no fitting
error. Since the old value remains feasible at each update,
$ J(K_j,D_(j+1)) <= J(K_j,D_j), $
$ J(K_(j+1),D_(j+1)) <= J(K_j,D_(j+1)). $
These inequalities are *non-strict*. If the current controller and scaling are already
best responses to each other, neither step improves anything.

The nonnegative objective values then converge. That does not prove convergence of
the controllers, convergence of the scalings, or local or global optimality. The joint
problem is not made convex by solving its two easier subproblems in turn.

In a practical frequency-dependent implementation, fitting changes the object between
the two steps. Approximate synthesis, finite frequency grids, and later controller
reduction introduce further discrepancies. Recompute the final bound rather than
assuming ideal monotonicity survived these operations.

#table(columns: (1.1fr, 2.4fr), inset: 7pt, stroke: 0.4pt + luma(180),
  table.header([*Observation*], [*What it licenses you to say*]),
  [Stable scaled loop, $H_infinity$ bound $<1$],
  [Robust performance is certified for the stated uncertainty model.],
  [Sampled bound $<1$],
  [The sampled frequencies pass; intersample peaks still need checking.],
  [D-upper-bound $>1$],
  [No certificate from that bound. Failure remains unproved.],
  [Admissible uncertainty produces a weighted gain $>1$],
  [A counterexample proves failure for that controller.],
  [Iteration stagnates],
  [This run stopped improving; feasibility or optimality is not settled.])

== Why not fit a very high-order D?

A dynamic fit enlarges the weighted synthesis plant, because both $hat(D)$ and
$hat(D)^(-1)$ enter. Standard full-order synthesis can therefore produce a controller
with order on the scale of $"order"(P)+2"order"(hat(D))$ before cancellations and
reduction. This is an order-cost warning, not a universal equality for a minimal
controller. If the controller is reduced afterwards, the reduced controller must be
checked again against the original uncertainty and performance requirements.

== Why chapter 9 will not make D–K iteration obsolete

Youla coordinates can make $M_K$ affine in a stable parameter $Q$. For a *fixed*
scaling, a norm objective is then convex in $Q$. But optimizing the similarity
$D^(-1)M(Q)D$ jointly over $Q$ and $D$ still couples the variables nonlinearly.
Chapter 9 removes the stabilization constraint from the design coordinates; it does
not remove the structured-robustness difficulty.

#pagebreak()
= Worked exercise: why exact decoupling is fragile

This is the exercise on pp. 222–223 of @schererTheoryRobustControl. All times below are
in *minutes*, all frequencies in radians per minute. The plant and weights are
$ G(s)=G_0/(75s+1), quad G_0=mat(87.8,-86.4;108.2,-109.6), $
$ W(s)=(s+0.1)/(0.5s+1) I, quad Delta="diag"(Delta_1,Delta_2), quad norm(Delta)_infinity<1. $
The two channels have independent stable, real-rational dynamic perturbations. They
are not required to be real-valued at each frequency. A constant real diagonal
perturbation is one allowed special case.

== Part (a): interpret the uncertainty

$ |w(0)|=0.1, quad |w(i)| approx 0.899, quad |w(10i)| approx 1.961, quad |w(infinity)|=2. $
Thus the input-channel relative error is small at low frequency and can be very
large at high frequency. A bound greater than 100% does not mean literally no model
information; it means the allowed relative discrepancy exceeds the nominal magnitude.
Diagonal uncertainty changes the two input channels independently; it does not allow
an arbitrary cross-channel perturbation.

== Part (b): start with the tempting controller

The exercise proposes $K_beta=(beta/s)G^(-1)$ for
$beta in {0.1,0.3,0.5,0.7}$. Since $G K_beta=K_beta G=(beta/s)I$,
$ S=s/(s+beta)I, quad T=I-S=beta/(s+beta)I. $
For a simultaneous unit step in both references, the nominal error in each output is
$e^(-beta t)$. The 2% settling time is $-ln(0.02)/beta approx 3.912/beta$:
about $39.1,13.0,7.82,5.59$ minutes. Faster nominal response looks free.

Choose the exercise's weight
$ W_p(s)=alpha (s+beta)/(s+10^(-6)) I. $
Then $W_p S=alpha s/(s+10^(-6)) I$, so the nominal performance norm is exactly
$alpha$. At $alpha=1$ it reaches the non-strict boundary; it has no strict margin.

The uncertainty-return matrix is $-W K_beta S G=-w beta/(s+beta)I$. Its structure is
diagonal, so the robust-stability test reduces to the scalar norm:
#table(columns: 5, inset: 6pt, stroke: 0.4pt + luma(180),
  table.header([$beta$], [0.1], [0.3], [0.5], [0.7]),
  [$norm(w beta/(s+beta))_infinity$], [0.100], [0.263], [0.402], [0.520])
All four controllers are robustly stable. That still says nothing about whether the
stable perturbed loop tracks well.

#pagebreak()
== The mechanism: inversion amplifies unequal input errors

$G_0$ has condition number about 141.7. Its inverse creates large input combinations
whose effects almost cancel. Unequal gain errors disturb that cancellation.

Take $Delta="diag"(-0.99,0)$, a constant real uncertainty with norm 0.99.
At DC it reduces the first input-channel gain by $0.99 times 0.1=9.9%$.
It is *not* a 1% gain error. At other frequencies its physical effect includes the
dynamics of $w(s)$.

Let $h_j=1+delta_j w(s)$ and $f_j=s/(s+beta h_j)$. Direct substitution gives
$ S_Delta=G_0 "diag"(f_1,f_2) G_0^(-1). $ <eq:bad>
Nominally the two $f_j$ are identical and the similarity cancels. With only the first
input perturbed, $f_1 != f_2$, and the nearly singular $G_0$ matters again.
For a reference step in direction $mat(1;1)$, the first error component combines the
two scalar step-error responses with coefficients about 7.42 and −6.42. Their sum is
one, but a small difference between the two responses is multiplied by a large number.

For $beta=0.5$, simulation gives
#table(columns: (1.5fr,1fr,1fr), inset: 7pt, stroke: 0.4pt + luma(180),
  table.header([*Quantity*], [*Nominal*], [*Bad uncertainty*]),
  [Error at $t=2$], [$(0.368,0.368)$], [$(1.546,1.820)$],
  [Largest error, $0<=t<=60$], [$(1,1)$], [$(3.230,3.825)$],
  [Smallest error, same window], [approximately $(0,0)$], [$(-0.610,-0.775)$])
The error should decay from one. Instead it first grows dramatically and then changes
sign. The poles remain stable; this is bad performance, not instability.

== Separate the picture from a proof of weighted-performance failure

A step plot is not an $H_infinity$ test: an infinite-duration step is not an
$L_2$ input. To disprove the specified weighted norm bound, inspect
$W_p S_Delta(i omega)$ for the *same admissible uncertainty*. The script reports a
frequency with largest singular value above one at $alpha=1$. That is an actual
counterexample to the performance specification.

For comparison, numerical frequency-by-frequency D-upper-bound analysis of the nominal
cut gives approximately $3.90,6.19,7.61,8.65$ for the four gains at $alpha=1$.
These sampled upper bounds alone would be inconclusive; the explicit uncertainty
provides the missing failure evidence. The script prints both quantities separately.

#pagebreak()
= Part (c): actually redesign the controller

To keep the computation transparent and reproducible, use the *restricted constant-D
version* of the iteration. Constants are order-zero proper stable weights with proper
stable inverses. This is a valid, more conservative subset of the dynamic-scaling
method; it is not a frequency-dependent fit masquerading as one.

Fix $beta=0.5$ in $W_p$ and relax $alpha$ to 0.1. This makes the allowed weighted-error
envelope ten times looser than at $alpha=1$. We are not claiming that the original
specification has been achieved.

== Assemble the synthesis plant from the signal equations

With rows ordered as $(q,z,e)$ and columns as $(v,r,u)$, the generalized plant is
$ P=mat(0,0,W; -W_p G,W_p,-W_p G; -G,I,-G), quad u=K e. $
Closing $K$ gives exactly @eq:mk. No negative sign is added to $K$: the negative feedback
already appears in the last row of $P$.

Start with $K_0=K_(0.5)$. At each of two iterations:
+ Choose $D="diag"(d_1,d_2,1,1)$ to reduce the worst scaled singular value of the current
  loop on a frequency grid. Search over $log(d_1),log(d_2)$ to preserve positivity.
+ Form $P_D="diag"(D^(-1),I) P "diag"(D,I)$ and run Octave's `hinfsyn(P_D,2,2)`.
+ Independently evaluate the continuous-frequency $H_infinity$ norm of
  $D^(-1) M_K D$ and check nominal closed-loop poles. Do not turn the grid maximum into
  an all-frequency claim.

The first scaling is approximately $"diag"(1.655,1.652,1,1)$. Its initial bound is
about 32.60: a *constant* scaling is a poor certificate for the inversion controller
over the entire frequency band. The controller update is the important improvement:
it produces a sixth-order controller with continuous-frequency scaled norm about
*0.7911*, below one. The second pair of updates stagnates at essentially the same
value; solver-level differences in the sixth decimal are not meaningful improvement.
The script retains the incumbent if a candidate is worse under the new scaling.

This is a robust-performance certificate for the relaxed specification and the entire
stated diagonal uncertainty family, subject to numerical solver accuracy. It is not
merely a successful test against the selected bad uncertainty. Since the bound is below
one even with constant D, no dynamic fit is necessary to certify this particular design.

#pagebreak()
== Compare what changed physically

#figure(image("assets/redesign.svg", width: 100%),
  caption: [Computed, not sketched. Left: error in output 2 for a simultaneous unit
    reference step under $Delta="diag"(-0.99,0)$. Right: the two singular-value curves
    of the redesigned controller; the largest one sets the worst-direction gain.
    Nominal decoupling has large gain in the weak plant direction.])

For the same bad uncertainty, the redesigned errors have maxima about $(1,1)$ and
minima about $(-0.017,-0.217)$ over 60 minutes. At two minutes they are about
$(0.132,-0.086)$ instead of $(1.546,1.820)$. Thus the dramatic initial growth is gone,
although output 2 still changes sign. Robust performance is not a promise of monotone
step responses.

The frequency plot is as important as the step plot: the redesigned controller no
longer insists on the exact inverse gain in every plant direction. It trades the
nominal decoupling recipe for a worst-case weighted design. The selected step is an
illustration; the scaled $H_infinity$ bound is the family-wide evidence.

== Reproduce the exercise

From the repository root, with Octave's installed `control` package:
```sh
octave --no-gui --quiet \
  Control/robust-control-08-robust-performance-synthesis/scripts/distillation.m
```
The script reproduces all reported numbers, pole checks, and this figure. Its
finite-grid D-search is not claimed to be globally optimal.

= Keep these four statements distinct

+ *K changes the loop; D changes the certificate.*
+ *A successful upper bound proves success; an unsuccessful upper bound does not prove failure.*
+ *Ideal alternating minimization is non-increasing; practical fitting and numerical
  synthesis must be checked, and stagnation is not optimality.*
+ *Relaxing a weight changes the question being answered.* Always report the weight
  together with the final robustness number.

#text(size: 9.5pt)[
*Source.* Based on chapter 8, pp. 217–223 of @schererTheoryRobustControl. The examples and
computations are developed here. Dynamic D-fitting is explained, not implemented;
the executable exercise uses constant scalings.

#bibliography("refs.bib", title: none)
]
