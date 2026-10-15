// Standalone: typst compile --root . <this file> <same stem>.pdf
#set document(title: "SISO robustness: what a feedback loop can promise", author: "Amp")
#set page(paper: "a4", margin: (x: 24mm, y: 21mm),
  header: text(size: 9pt, fill: rgb("#5b6470"))[Robust control · Chapter 2],
  footer: context align(right, text(size: 9pt, counter(page).display("1"))))
#set text(font: "Libertinus Serif", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("#1f4e79"))
#let takeaway(body) = block(width: 100%, inset: 10pt, fill: rgb("#edf5f5"),
  stroke: (left: 2pt + rgb("#0f766e")), body)

#text(size: 23pt, weight: "bold", fill: rgb("#1f4e79"))[Robustness for SISO Systems]

#text(size: 15pt)[What a feedback loop can promise]

A controller does not act on the true plant model. It acts on an error signal. The model
is our tool for predicting whether that action corrects the error or amplifies it.
Robust control asks how wrong the prediction may be before stability or performance is lost.

#takeaway[Read sections 1–8 as one argument: signals → hidden modes → Nyquist geometry
  → margins → model sets → small gain → performance → a delayed satellite.
  Section 9 is a separate worked guide to all ten exercises on book pp. 42–45.
  Background: rational transfer functions, eigenvalues, and basic complex analysis.]

= Derive the signals before naming the functions

Use *negative feedback*, with an input disturbance $d$ and measurement noise $n$:
$ e=r-y-n, quad u=K e+d, quad y=G u. $ <eq:signals>
Here $u$ is the total plant input, not just the controller output. Solving the equations,
$ (1+G K)e=r-G d-n. $
Define the loop gain $L=G K$, sensitivity $S=(1+L)^(-1)$, and complementary
sensitivity $T=L(1+L)^(-1)$. Then
$ e=S r-G S d-S n, quad u=K S r+S d-K S n, $
$ y=T r+G S d-T n, quad S+T=1. $ <eq:maps>
These identities explain what each function measures. Small $S$ gives good reference
tracking and rejection of output disturbances; small $G S$ rejects plant-input disturbances.
Small $T$ limits transmission of measurement noise to the physical output. Small $K S$
limits the command demanded by references and noise. A low tracking error alone says
nothing about actuator saturation.

For a reference sinusoid at frequency $omega$, the steady-state error amplitude is
$|S(i omega)|$ times its amplitude. Thus high loop gain usually helps tracking:
$|L|$ large gives $S approx 1/L$ and $T approx 1$. At high frequency, where sensing
is noisy and the model is poor, one instead wants $T$ small. Since $S+T=1$, they cannot
both be small at the same frequency. This is an algebraic conflict, before any optimization.

All rational models below are real and proper. “Stable” means proper with poles strictly
in the left half-plane. Well-posedness additionally requires
$1+G(infinity)K(infinity)!=0$: otherwise the instantaneous feedback equations cannot
be solved causally. Zero initial conditions are implicit in transfer equations.

#pagebreak()
= Stability must include the signals you did not plot

Set $n=0$ in @eq:signals. The two equations at the summing junctions give
$ mat(1,G;-K,1) mat(e;u)=mat(r;d), quad
  mat(e;u)=mat(S,-G S;K S,S) mat(r;d). $ <eq:inverse>
*Internal stability of the transfer interconnection* means that every entry of this inverse
is stable: $S$, $G S$, and $K S$. Then $T=1-S$ is stable too. Stability of $S$ alone
is only stability of one observed input–output channel.

For minimal plant and controller realizations, this is equivalent to the autonomous
closed-loop state matrix being Hurwitz. For arbitrary nonminimal realizations, hidden
unstable states must be checked separately: no transfer test can see a state that is
unreachable and unobservable even before feedback.

== Why an unstable cancellation is not a cure

Let $G=1/(s-1)$ and $K=(s-1)/(s+2)$. The product reduces to $L=1/(s+2)$, giving
$ S=(s+2)/(s+3), quad K S=(s-1)/(s+3), quad
  G S=(s+2)/((s-1)(s+3)). $
The reference-to-error plot looks stable. But an input disturbance still excites the plant's
growing mode at $s=1$. The zero of the controller prevented that mode from appearing
in the reduced product; it did not remove the plant state. Cancelling a stable pole is
not the same danger, although approximate cancellation can still harm transients.

For a general check, write $G=N_G/D_G$, $K=N_K/D_K$, each pair coprime, and retain
the *unreduced interconnection polynomial*
$ p=D_G D_K+N_G N_K. $
Then
$ mat(S,-G S;K S,S)=1/p
    mat(D_G D_K,-N_G D_K;D_G N_K,D_G D_K). $ <eq:polynomial>
If $p$ is Hurwitz and the loop is well posed, every entry is stable. Conversely, if
$p(lambda)=0$ in the closed right half-plane, coprimeness prevents all three distinct
numerators from vanishing there: at least one entry exposes that bad root.

This yields the useful version of book Theorem 2.24: internal stability is equivalent
to *both* stability of $S$ *and* absence of closed-right-half-plane pole–zero cancellation
when forming $G K$. Absence of cancellation by itself does not stabilize anything.

#takeaway[Check the unreduced states or all internal transfer channels first. Frequency
  robustness tests will assume this nominal internal stability; they cannot repair its absence.]

#pagebreak()
= Nyquist counts unstable modes without solving for them

Why should a curve around $-1$ know the roots of a characteristic polynomial? Because
the closed-loop poles are zeros of $1+L$, while the open-loop poles are its poles.
The argument principle converts their difference into a winding number.

Choose the book's contour $Gamma$: it surrounds the right half-plane *clockwise*,
with small detours into the left half-plane around imaginary-axis poles so those poles
remain inside. It avoids all poles. Let $P$ count the enclosed poles of $L$, $Z$ the
zeros of $1+L$, and $N$ the net counterclockwise turns of $L(Gamma)$ around $-1$.
Then
$ N=1/(2 pi) Delta_Gamma arg(1+L)=P-Z. $ <eq:nyquist>
The clockwise orientation of the *domain* supplies the minus sign relative to the
usual positively oriented argument principle. Translating the image curve by $1$
does not reverse its orientation. A counterclockwise turn remains counterclockwise.

Provided the curve avoids $-1$, $L(infinity)!=-1$, and the outer radius contains all
relevant roots, $S$ is stable exactly when $N=P$. For rational $L$ the radius may be
taken to infinity. If $G K$ has no unstable cancellations, $P$ is the sum of the
unstable/marginal pole counts of $G$ and $K$, and this becomes an internal-stability test.

== A one-pole example you can solve both ways

Take an unstable scalar process $dot(x)=x+u$, $y=x$, and proportional feedback
$u=k(r-y)$. Then $L=k/(s-1)$ and the autonomous pole is $1-k$. For $k>1$ it is stable.
The image of the imaginary axis is the circle
$ (Re L+k/2)^2+(Im L)^2=(k/2)^2. $
It passes through $0$ and $-k$. With the clockwise right-half-plane contour the
circle is traversed counterclockwise. It encloses $-1$ exactly for $k>1$, giving
$N=1=P$. At $k=1$ the curve passes through $-1$, which is the closed-loop pole at zero.
At $0<k<1$ there are no encirclements, so $Z=P-N=1$: the feedback was too weak.

This example also explains why “no encirclement of $-1$” is not a universal stability
rule. It is correct only when the open loop has no unstable poles to compensate.
For an integrator or a flexible satellite, the small contour detours matter; a cropped
plot of $L(i omega)$ alone omits them. Count a *closed, oriented contour*, not an
unoriented sketch.

In robust analysis we continuously deform this curve. If it cannot touch $-1$ and its
relevant pole count does not change, its winding number cannot change either. This
topological observation is the bridge from classical margins to the weighted test.

#pagebreak()
= Classical margins are restricted directions of model error

A real gain change $L mapsto k L$, $k>0$, stretches the Nyquist curve radially. At a
negative-real-axis crossing, loss of stability can occur at $k=-1/L(i omega)$.
The gain margins are the endpoints of the stable interval containing $k=1$; enumerate
all crossings and check which intervals are stable, including possible endpoints at infinity.

A constant phase change rotates the curve. Only points with $|L|=1$ can then hit $-1$.
The symmetric phase margin considers rotation in *both* directions. It need not equal
the tolerance to a physical delay, which adds lag $-omega tau$ rather than a constant phase.
For a nominally stable, strictly proper loop, list every positive unit-gain crossing and form
$ tau_j=((arg L(i omega_j)+pi) "mod" (2 pi))/omega_j. $ <eq:delay>
The first positive candidate is the first delay stability boundary, subject to checking
degenerate crossings. Angles are in radians. A single $phi_m/omega_c$ is valid only
when that crossing really supplies the earliest lag-induced encounter.

The satellite in section 8 has *three* crossings: $omega=0.4378,0.9407,1.0879$ rad/s.
Their positive-delay candidates are $1.2664,5.3456,0.7669$ s. Choosing the first
crossing would overstate the delay tolerance by 65%. A negative signed angular clearance
at the middle crossing does not mean this nominal loop is unstable.

#figure(image("assets/nyquist.svg", width: 78%), caption: [Book Example 2.10, a zoom
  of the positive/negative-frequency traces. The dangerous point is −1 on the real axis;
  this plot is geometry, not a complete Nyquist contour or a pole-count certificate.])

Mixed gain and phase changes can pass between the directions tested separately. For the
book's fifth-order loop (coefficients in `scripts/figures.m`), a frequency search finds
$min |1+L| approx 0.36976$ near $3.0574$ rad/s. The complex multiplier
$c approx 1.31921-0.39697i$ makes $c L=-1$ there: gain $1.37765$ and phase $-16.747°$
act *together*. The nominal characteristic roots have maximum real part $-0.15904$.
Applied separately, that gain and that phase give maximum root real parts $-0.22457$
and $-0.08727$: each alone is stable. These are numerical checks, not symbolic margins.

For stable $S$, the exact geometric identity is
$ norm(S)_infinity=1/(inf_(omega in RR union {infinity}) |1+L(i omega)|). $
This measures absolute loop displacement from $-1$, not distance from the origin.
$norm(T)_infinity$ instead measures amplification of *relative* loop error, as we now derive.

#pagebreak()
= Specify a set of possible plants, not a vague percentage

Suppose the real plant is $H$. At a frequency where $G!=0$, write the relative error
$ (H-G)/G=H/G-1. $
A stable, proper nonzero weight $W$ assigns a frequency-dependent allowance. A high-pass
weight represents good low-frequency identification and poorer high-frequency knowledge.
An uncertainty weight has units of relative error, while a performance weight is a
reciprocal allowance for a specified signal.

There are two useful uncertainty classes; they must not be silently identified.

*The book's class* (Definition 2.11) consists of proper rational $H$ with the same
number of open-right-half-plane poles as $G$, identical imaginary-axis poles including
multiplicity, and
$ |H(i omega)/G(i omega)-1|<|W(i omega)| $ <eq:cover>
where $W!=0$, including the limiting value at infinity. At zeros of $W$ use the
matching/limiting convention $H/G=1$; ratios at poles or zeros of $G$ are interpreted
by removable limits. These are *strict* frequency inequalities. Pole-count restrictions
are restrictions on $H$, not “unstable poles of a stable perturbation.”

*The stable-block class* starts from $H=G(1+W Delta)$ with
$Delta in cal(R H)_infinity$ and $norm(Delta)_infinity<1$. Here
$cal(R H)_infinity$ means real-rational proper stable functions. It is often a convenient
subset of the book's model, but admissibility also requires that $1+W Delta$ not cancel
any unstable or imaginary-axis poles of $G$.

The distinction is substantive: let
$ G=1/(s-1), quad H=1/(s-2), quad W=1.1/(s+2). $
Both plants have one unstable pole and meet the frequency bound, since
$ Delta=(H/G-1)/W=(s+2)/(1.1(s-2)), quad norm(Delta(i RR))_infinity=1/1.1<1. $
This $Delta$ is *unstable*. It belongs to a frequency description of the book's class,
not to a stable uncertainty block. With $K=3$, both endpoint loops are stable, yet the
intermediate plant $(1-t)G+t H$ generally has *two* unstable poles. An arbitrary
straight-line homotopy of plants need not stay in the prescribed pole-count class.

In practice, first validate that the physical parameter family is covered. The resulting
disk model normally contains many additional dynamic plants. A test exact for that larger
class may be conservative for the original parameter family. This is a modeling cost,
not a defect in the theorem.

#takeaway[Always state: stable block or pole-count model? Strict or closed bound?
  Rational dynamics or delays? Each choice changes what an endpoint or a failed test means.]

#pagebreak()
= Derive weighted small gain from the feedback denominator

Assume $K$ internally stabilizes nominal $G$, $W$ is stable proper, and the interconnections
are well posed. For $H=G(1+W Delta)$,
$ 1+H K=(1+L)(1+W T Delta), quad
  S_H=(1+H K)^(-1)=S/(1+W T Delta). $ <eq:factor>
The uncertain feedback is therefore a second loop: the stable nominal map
$M=W T$ feeds the uncertainty block. If $Delta$ is stable and
$norm(M)_infinity norm(Delta)_infinity<1$, then $1+M Delta$ cannot vanish in the
closed right half-plane. Indeed the maximum modulus theorem extends the boundary
gain bound into the right half-plane, and $|M Delta|<1$ excludes the value $-1$.
The same strict inequality at infinity prevents algebraic ill-posedness.

For *every stable block with norm strictly below one*, the exact scalar test is
$ norm(W T)_infinity<=1. $ <eq:rs>
Necessity has a useful mechanism. If $|M(i omega_0)|>1$, choose
$delta_0=-1/M(i omega_0)$, with $|delta_0|<1$. A stable real all-pass factor times
a real gain can interpolate this complex value at the conjugate frequencies
$plus.minus i omega_0$ (exercise 5). Then $1+M Delta=0$ at that frequency. There
is an admissible perturbation causing a boundary pole, not merely a large nominal response.

For the book's larger pole-count class, Theorem 2.13 gives the same exact test, under
nominal internal stability. Its sufficiency uses Nyquist and fixed endpoint pole counts,
not the assertion that the normalized $Delta$ is stable. Necessity additionally avoids
cancelling plant poles by a narrow stable interpolation filter (book pp. 30–33).
These are important qualifications to the elementary stable-block proof above.

== Equality is a convention, not a numerical tolerance

For a *closed* stable-block ball $norm(Delta)_infinity<=1$, the safe general criterion is
$norm(M)_infinity<1$, not $<=1$. Example: $G=1$, $K=1$, $W=2$ gives $T=1/2$,
$M=1$. Every strict-block perturbation is safe, but $Delta=-1$ makes $H=-1$ and
$1+H K=0$. Equality of the product bound can therefore destroy well-posedness.
Special closed-ball cases can survive equality (exercise 6); they need a separate proof.

With an open uncertainty allowance $r|W|$, the largest robust radius is
$r_*=1/norm(W T)_infinity$. At $r=r_*$ every *strictly interior* model is stable,
but the family need not have a uniform stability margin. For closed balls the same
number is generally a supremum, not an included endpoint.

Geometrically @eq:rs says $|W L|<=|1+L|$ at every frequency: the open disk of possible
loop values centered at $L$ cannot contain $-1$. This is precisely the mixed gain/phase
protection that separate classical margins do not provide.

#pagebreak()
= Performance spends part of the same distance budget

A stable proper weight $W_p$ expresses the desired error envelope:
$ norm(W_p S)_infinity<=1 quad <==> quad abs(S(i omega))<=1/abs(W_p (i omega)). $
Large low-frequency $|W_p|$ demands accurate tracking; a small high-frequency weight
allows error where measurement noise or uncertainty makes feedback unwise. This is an
energy/sinusoidal-gain specification, not a guarantee on step overshoot or saturation.

At a fixed frequency let $a=W_p S$, $b=W T$. From @eq:factor,
$ abs(W_p S_H)=abs(a)/abs(1+b delta). $
When $|b|<1$, the infimum of $|1+b delta|$ over $|delta|<1$ is $1-|b|$:
choose $delta$ with phase opposing $b$, and let its magnitude tend to one. Hence
robust stability *and* robust performance for the book's strict class are equivalent to
$ |W_p S|+|W T|<=1 quad "at every frequency, including infinity". $ <eq:rp>
This is Theorem 2.21. The boundary case $|b|=1$ forces $a=0$ under this test; handle
zero weights by limits. A single constant complex $delta$ is only frequency geometry;
the all-pass interpolation argument supplies an actual real dynamic perturbation when
the inequality is violated. For a closed uncertainty ball, use strict margin for stability.

The geometry is now $|W_p|+|W L|<=|1+L|$. Performance reserves a disk around $-1$;
uncertainty reserves a disk around $L$. They must not overlap. Checking nominal
performance and robust stability separately is necessary but not sufficient: $0.7+0.6>1$.

== A thermal loop: stable uncertainty need not preserve the error target

Normalize time and temperature so $dot(x)=-x+u$, $y=x$, and choose $K=3$.
Then $S=(s+1)/(s+4)$, $T=3/(s+4)$. Take $W=0.2$, a 20% dynamic actuator-error
allowance (including static gain changes, but also phase changes).
Robust stability is easy: $norm(W T)_infinity=0.15$. But for $W_p=1$,
$ |S|+|W T|=(sqrt(omega^2+1)+0.6)/sqrt(omega^2+16). $
Put $t=sqrt(omega^2+1)>=1$. Differentiating $(t+0.6)/sqrt(t^2+15)$ gives its maximum
at $t=25$, namely $sqrt(1+0.6^2/15)=1.011929$ at $omega=sqrt(624)=24.9800$.
Thus robust performance fails even though nominal performance has norm one and robust
stability has ample margin. The uncertainty can rotate phase as well as change gain.

If $W_p=0.8$ instead, Cauchy–Schwarz gives the *continuous* certificate
$ (0.8t+0.6)/sqrt(t^2+15)<=sqrt(0.8^2+0.6^2/15)=0.814862<1. $
This relaxed specification is robustly feasible. Conversely a failed sufficient bound
would not prove infeasibility: for example $|a|+|b|<=sqrt(2)sqrt(|a|^2+|b|^2)$ is an
upper bound, not an equality. Failure of its stacked-norm test only says “undecided.”

#pagebreak()
== Read the curves, then decide what they establish

#figure(image("assets/thermal.svg", width: 78%), caption: [Thermal loop. Tracking
  improves at low frequency, while $T$ transmits low-frequency reference and noise.
  The purple robust-performance budget slightly exceeds one at high frequency.])

A plot samples frequencies. Even a million samples can miss a narrow resonance or a
tail maximum. For a stable scalar rational transfer $F$, a continuous norm computation
can use a Hamiltonian-based algorithm, or solve for all stationary points of
$|F(i omega)|^2$ as a rational function of $omega^2$, and compare $omega=0,infinity$.
Such methods still use floating-point tolerances; they are not interval-arithmetic proofs.

The sum in @eq:rp is not itself the magnitude of one scalar rational transfer. Our
satellite script uses a dense logarithmic search plus local maximization; it supplies
strong numerical evidence, not a continuous certificate. The thermal example's analytic
maximum is stronger. A sampled value *above* one, by contrast, is already a valid
counterexample frequency (allowing for numerical error); no missing peak can undo it.

= A delayed flexible satellite: three distinct boundaries

For exercises 4–5 use the actual printed plant, not its ten-times-more-damped worked example:
$ G=0.036(s+25.28)/(s^2(s^2+0.00396s+1)), $
$ K=(7.9212(s+0.1818)(s^2-0.2244s+0.8981)) /
       ((s^2+3.899s+4.745)(s^2+1.039s+3.395)). $
There is an attitude double integrator and a lightly damped flexible mode; the dynamics
are not a symmetric single resonance. The nominal unreduced closed-loop poles have
maximum real part $-0.2070$. A measurement delay $tau$ changes the loop to
$e^(-s tau)L$. For stability this is equivalent to putting the delay in the plant;
the physical reference/output maps differ if one also changes where the reference is delayed.

For all delays $0<=tau<=h$, use the first-order cover
$ W_h=s h/(1+s h/sqrt(12)), quad
  |e^(-i omega tau)-1|<|W_h (i omega)| quad (omega!=0). $ <eq:delayweight>
It matches the first-order low-frequency error and overbounds the oscillatory high-frequency
error. A pure delay is not rational and has no single value at infinity; the exercise
explicitly permits the sufficient delay extension. The rational model-set theorem is not
being applied literally to it. Exercise 4 below verifies the cover and its endpoint issue.

#pagebreak()
#figure(image("assets/satellite.svg", width: 78%), caption: [Same satellite and controller.
  Blue spends only the stability budget. Orange and purple add weighted tracking error.
  A 0.50 s uncertainty cover violates performance before it violates robust stability.])

Use the book's performance weight
$ W_p=((s/sqrt(5)+omega_B)/(s+omega_B sqrt(10^(-3))))^2, quad omega_B=0.1. $
At zero its magnitude is $1000$, so the allowed error is $0.001$; at infinity its
magnitude is $1/5$, allowing sensitivity up to $5$. Its bandwidth parameter is a
specification parameter, not automatically the physical closed-loop −3 dB bandwidth.

#table(columns: (2.5fr,1fr), inset: 5pt, stroke: 0.4pt + luma(180),
  table.header([Question],[Computed answer]),
  [Nominal $norm(S)_infinity$, $norm(T)_infinity$],[2.4331, 1.8286],
  [$norm(W_(0.25) T)_infinity$; reciprocal uncertainty radius],[0.3805; 2.6278],
  [Largest $h$ passing covering-class RS test],[0.6720 s],
  [First actual pure-delay crossing],[0.7669 s],
  [RP budget at $h=0.25$],[0.8095],
  [Largest $h$ passing covering-class RP test],[0.3781 s],
  [Largest $omega_B$ at $h=0.25$ passing RP],[0.20066 rad/s])

The rational stability norm is also checked by SLICOT at relative tolerance $10^(-9)$.
At $h=0.25$, its stacked norm gives the continuous RP upper bound
$sqrt(2) norm(mat(W_p S;W_h T))_infinity=0.851515<1$.
The sharper RP maxima and thresholds are grid-plus-refinement estimates. Polynomial
root enumeration checks all three unit-gain crossings; their delay residuals are below
$10^(-12)$ and the first moves rightward. No nominal unstable cancellation occurs.

#takeaway[0.6720 s is a sufficient delay guarantee obtained from a larger uncertainty
  set, not the actual delay margin. Failure of that cover test above 0.6720 s does not
  prove that the physical delay is unstable. Likewise 0.3781 s is not a demonstrated
  physical-delay performance boundary.]

For the stated $0.25$ s delay, both requirements pass with useful numerical margin.
Retain the controller for these linear specifications, subject to actuator and model
validation. If the uncertainty allowance grows, either relax the performance requirement
or redesign; do not extrapolate a gain margin into a tracking guarantee.

#pagebreak()
= Exercise guide: all ten, with the technical gaps identified

The following follows the actual exercise statements on pp. 42–45. Worked arguments
are given where short; the general pole-count homotopy in exercise 9 is labelled an
advanced outline. This guide is separate from the main reading, not a prerequisite for it.

== Exercise 1 — compute before cancelling

The book's system matrices mean $A_G=mat(0,1;-2,-3)$, $B_G=mat(0;1)$,
$C_G=mat(alpha,-1)$, $D_G=0$; the controller has $A_K=B_K=C_K=1$, $D_K=0$.
For the product driven by $e$, with state ordered $(x_G,x_K)$,
$ A_L=mat(0,1,0;-2,-3,1;0,0,1), quad B_L=mat(0;0;1), quad
  C_L=mat(alpha,-1,0), quad D_L=0. $
The inverse of $1+L$ has realization
$ A_S=A_L-B_L C_L=mat(0,1,0;-2,-3,1;-alpha,1,1), $
$ B_S=B_L, quad C_S=-C_L, quad D_S=1. $
Its state matrix is also the physical closed-loop matrix. Direct elimination gives
$ L=(alpha-s)/((s+1)(s+2)(s-1)), $
$ p=s^3+2s^2-2s+alpha-2, quad S=((s+1)(s+2)(s-1))/p. $
At $alpha=1$, $p=(s-1)(s^2+3s+1)$. The state eigenvalues are
$1,-0.381966,-2.618034$, so this realization is not Hurwitz. Reduced transfers are
$ S=((s+1)(s+2))/(s^2+3s+1), quad G S=-1/(s^2+3s+1), $
$ K S=((s+1)(s+2))/((s-1)(s^2+3s+1)). $
Only the last exposes the unstable mode. With $alpha=1.001$ or $0.999$, the unstable
root becomes $0.9998$ or $1.0002$ and the cancellation in $S$ disappears. In fact
implicit differentiation at $(s,alpha)=(1,1)$ gives $(dif s)/(dif alpha)=-1/5$, explaining
the numbers. The instability was present even before perturbation. `scripts/ex1.m`
checks the unreduced eigenvalues and the reduced channel denominators.

== Exercise 2 — choose the disturbance location correctly

*(a)* The signal equations @eq:signals with $n=0$ give @eq:inverse, including the minus sign in
$-G S$. Putting $d$ at the *output* instead would give a different transfer matrix;
it would not be Figure 16's experiment. Multiplication verifies the inverse because
$S+G K S=1$ and the off-diagonal products cancel.

*(b)* The plant/controller pair of section 2 has stable $S$ and $K S$ but unstable
$G S$. It is the required example with only entry $(1,2)$ unstable. *(c)* If $G$ is stable
and $K S$ is stable, then $S=1-G(K S)$ and $G S$ are stable. Conversely internal
stability includes $K S$. Thus for stable $G$, one channel suffices; the argument
depends on stability of $G$, not merely on properness or nominal output tracking.

#pagebreak()
== Exercise 3 — signs and contour detours

Apply the argument principle to $f=1+L$ on the clockwise contour of section 3.
It gives @eq:nyquist, $N=P-Z$, with $P=n_(0+)$ when all axis poles are included
by leftward detours. There are no boundary zeros because the image avoids $-1$.
For sufficiently small detours any axis zeros would lie on the enclosed straight-axis
part, and would violate that condition; the limit contour therefore checks them too.
At infinity $L(infinity)!=-1$ ensures a proper inverse. Hence stability is exactly
$Z=0$, or $N=n_(0+)$. Avoiding $-1$ *alone* does not imply $Z=0$.

== Exercise 4 — derive the delay cover, then interpret the margin

*(a)* In the family $W_h=s h/(1+s h/c)$, the low-frequency slope is fixed to match
the delay. Put $x=|omega|h$. The delay magnitude is $2|sin(x/2)|$, not a function
converging to $2$ at infinity. The weight magnitude is $x/sqrt(1+x^2/c^2)$.
Expansion gives $2sin(x/2)=x-x^3/24+O(x^5)$ and
$|W_h|=x-x^3/(2c^2)+O(x^5)$, so coverage near zero requires $c^2>=12$.

For $c^2=12$ the global strict inequality also holds. If $x>=sqrt(6)$, the weight
is at least $2$, and strictness follows (at $x=sqrt(6)$ the sine is strictly below one).
For $0<x<=sqrt(6)$ put $y=x/2$, $t=y^2<=3/2$. The alternating cosine series gives
$ sin^2 y<=t-t^2/3+2t^3/45<t/(1+t/3), $
since the difference in the second inequality is
$t^3(1/(9(1+t/3))-2/45)>0$. Taking square roots proves the cover.
It is tight *within this fixed-slope first-order family*, not a unique best weight
over all dynamical orders. Since $|W_h (i omega)|$ increases with $h$, it also covers
every smaller delay.

*(b)* Multiplication by $e^(-s tau)$ adds no finite poles or zeros, so the satellite's
double pole at zero and open-right-half-plane pole count are unchanged. At zero,
the relative error and $W_h$ both vanish. However
$lim_(s->0) (e^(-s h)-1)/(W_h (s))=-1$.
Thus the normalized block lies on the *closed* unit-ball boundary, not in the strict
stable rational ball. Moreover delay is irrational. The exercise's extension is needed.
One safe justification for a strict passing test is to enlarge $h$ slightly while
retaining $norm(W_h T)<1$; the enlarged cover makes the normalized zero-frequency
value strictly smaller than one. More directly the strict product small-gain theorem
extends to bounded analytic causal delay blocks. An exact equality threshold requires
additional limiting analysis and is not being certified here for the delay family.

*(c–d)* Section 8 answers the numerical questions. The printed exercise's expression
$norm(W_h S)$ omits the loop factor; Theorem 2.13 requires $W_h T$,
not $W_h S$. The radius $2.6278$ scales the entire weight, not time itself. The
maximum delay passing that nonlinear weight test is about $0.6720$ s; actual first
crossing is $0.7669$ s. For $0.25$ s keep the controller on the stated linear evidence,
but also check performance, actuator authority, and that the identified model is covered.

#pagebreak()
== Exercise 5 — produce a bad plant, not just a failed bound

*(a–c)* With $W_p$ as in section 8, maximize
$q_h(omega)=|W_p S|+|W_h T|$. The refined search returns $0.8095$ at
$omega=1.2383$ for $h=0.25$, and the thresholds $h approx 0.3781$ s and
$omega_B approx 0.20066$ rad/s. All are for damping $0.00396$, not $0.0396$.
The index increases pointwise with $h$ and with $omega_B$ for this weight, justifying
the scalar threshold searches. The script's local refinement does not prove every
maximum was found; zero and infinity limits and a broad grid must still be considered.

*(d)* Choose $h=0.5$. At the violating frequency $omega_0=1.2274$, set
$u_0=1+L(i omega_0)$ and $v_0=W_h (i omega_0)L(i omega_0)$. Numerically
$|W_p|=0.2066$, $|u_0|=0.4805$, $|v_0|=0.3597$. The phase choice
$ delta_0=0.999 exp(i(arg u_0-arg v_0+pi)) $
opposes $v_0$ to $u_0$ and gives $|u_0+delta_0 v_0|=0.1212<|W_p|$.
To realize it with real dynamics choose $alpha=plus.minus |delta_0|$ and
$ beta=i omega_0 (alpha-delta_0)/(alpha+delta_0), quad
  Delta(s)=alpha (s-beta)/(s+beta). $
The ratio makes $beta$ real; choose the sign giving $beta>0$. The resulting stable
all-pass times a gain has constant boundary magnitude $0.999<1$. Here it is
$ Delta(s) approx -0.9990(s-0.6601)/(s+0.6601). $
Then $H=G(1+W_h Delta)$ is in the rational uncertainty class: it has no new unstable
poles, and $1+W_h (0)Delta(0)=1$ preserves the satellite's double integrator. Its
closed-loop polynomial has maximum root real part $-0.0361$; a frequency search gives
$norm(W_p S_H)_infinity approx 1.7057$. Already the value at $omega_0$ exceeds one,
so this is a constructive performance counterexample without needing a norm certificate.
It is *not* proof that a physical delay of $0.5$ s violates performance: this $H$ is
a different dynamic plant in the larger cover class.

== Exercise 6 — a closed-ball endpoint that really is safe

*(a)* $G_0=1/s$, $K=1$ gives $T=1/(s+1)$ and $norm(T)_infinity=1$.
*(b)* For real stable rational $Delta$ with norm at most one and $Delta(0)=-1$,
write $Delta=-1+a_1 s+O(s^2)$. The maximum modulus theorem gives
$|Delta(h)|<=1$ for small real $h>0$; expanding shows $a_1>=0$.
Equivalently $(1+Delta)/(1-Delta)$ has nonnegative real part and derivative $a_1/2$
at zero. The constant case $Delta=-1$ satisfies this too.

*(c)* $S_Delta=s/(s+1+Delta(s))$. In the closed right half-plane, a denominator
zero requires $|Delta(s)|=|1+s|<=1$, which forces $s=0$. If $Delta(0)!=-1$,
even that zero is absent. Otherwise the derivative of the denominator at zero is
$1+a_1>=1$, so the zero is *simple* and is removed by the numerator. The inverse
is proper because $Delta$ is proper and $s$ dominates at infinity. Hence $S_Delta$
is stable for the entire closed ball. This special cancellation concerns a changing
plant pole; it is not a license to cancel an unstable mode in a fixed physical realization.

#pagebreak()
== Exercise 7 — internal Nyquist uses the uncancelled pole count

*(a)* The identity @eq:polynomial proves the equivalence. If $S$ is stable but $p$ has
a root $lambda$ in the closed right half-plane, then $D_G(lambda)D_K(lambda)=0$;
also $N_G(lambda)N_K(lambda)=0$. Coprimeness within each factor forces a cross
cancellation: either $N_G=D_K=0$ or $N_K=D_G=0$ at that point. With no such
cancellation, no bad root of $p$ can exist. Conversely, if a cross cancellation occurs,
say $N_G(lambda)=D_K(lambda)=0$, then $D_G(lambda)N_K(lambda)!=0$. Entry $K S$
in @eq:polynomial has a pole there, so internal stability fails.

*(b)* Let $m$ count all closed-right-half-plane poles of $G$ and $K$, before multiplying,
and let $P$ count poles of the reduced $L$. Then $P<=m$. Nyquist always gives
$N=P-Z<=P<=m$. Therefore $N=m$ forces *both* $Z=0$ and $P=m$, which excludes
unstable cancellations. This proves the converse as well as the forward implication;
one cannot simply assume the equality of the two pole counts when proving it.
As always, exclude the point $-1$ on the complete contour and require well-posedness
at infinity. Those qualifications are necessary even if omitted from a short exercise statement.

== Exercise 8 — why boundary bounds control the whole half-plane

*(a)* A continuous subharmonic $f$ satisfies the circle mean inequality. On any
compact set $K$, perturb it to $f_epsilon(z)=f(z)+epsilon |z|^2$. If this attained
its maximum at an interior point $z$, choose a small circle inside $K$ and inside the
open right half-plane. The mean of $|z+r e^(i t)|^2$ is $|z|^2+r^2$. Thus the
subharmonic inequality for $f$ implies
$ f_epsilon(z)<=1/(2 pi) integral_0^(2 pi) f_epsilon(z+r e^(i t)) dif t-epsilon r^2, $
contradicting maximality. Its maximum is therefore on the boundary. Let $epsilon$
decrease to zero to get $sup_K f=sup_(partial K)f$. Points of $K$ on the imaginary
axis are boundary points automatically; disconnected sets cause no difficulty.

*(b)* Cauchy–Schwarz gives $|x^*M y|<=norm(M y)<=norm(M)$ for unit vectors.
Choose a maximizing right singular vector $y$ and $x=M y/norm(M y)$ (the zero
matrix is trivial) to attain equality. Thus $norm(M)=max |x^*M y|$.

*(c)* At a chosen center $z$, fix maximizing unit vectors $x,y$. Analyticity of
$g(w)=x^*G(w)y$ gives the scalar mean inequality for $|g|$. On the surrounding
circle, $|g(w)|<=norm(G(w))$, so
$ norm(G(z))<=1/(2 pi) integral_0^(2 pi) norm(G(z+r e^(i t))) dif t. $
This directly proves subharmonicity without invoking an unjustified supremum rule.

*(d)* Apply (a) to closed right half-disks. A proper rational stable matrix tends
uniformly to $G(infinity)$ on the large semicircle; its norm is already a limit of
imaginary-axis values. Sending the radius to infinity proves
$ sup_(Re z>=0) norm(G(z))=sup_(omega in RR) norm(G(i omega))=norm(G)_infinity. $
This is the analytic fact behind small gain, not evidence supplied by a Bode grid.

#pagebreak()
== Exercise 9 — pole-count preservation (advanced proof outline)

Here $Delta$ has no imaginary-axis poles and $|Delta(i omega)|<1$, including infinity,
but is *not assumed stable*. Keep this distinction: the exercise addresses exactly
the case where the elementary stable-block proof is insufficient. Put $T=L/(1+L)$,
$F=1+T W Delta$ and $L_Delta=L(1+W Delta)$.

*(a)* Since $T,W,Delta$ are analytic on the axis and proper, $F$ has no poles there
or at infinity. The strict boundary inequality $|T W Delta|<1$ gives $F!=0$ there,
so its inverse has no poles there either. This says nothing yet about right-half-plane
zeros or poles of $F$.

*(b)* At an axis pole $lambda$ of $L$, analytically extended $T(lambda)=1$. Therefore
$1+W(lambda)Delta(lambda)=F(lambda)!=0$, and that pole survives with its full
multiplicity. Away from those poles, multiplying by an axis-analytic factor creates
no new axis poles. We do *not* need $1+W Delta$ to be nonzero everywhere on the axis;
it may vanish at points where $L$ is finite.

*(c)* Use the identity $1+L_Delta=(1+L)F$. The strict boundary bound makes the
image of $F$ lie in the open disk centered at $1$ with radius $1$ on the limiting
Nyquist boundary, so its winding about zero is zero. On sufficiently large outer
arcs and sufficiently small detours the strict inequality persists by properness and
continuity, even though $F$ may have poles *inside*. The meromorphic argument principle
then gives equality of the differences “zeros minus poles” for $1+L_Delta$ and $1+L$.
Now $S=1-T$ is stable by hypothesis, and $S_Delta$ is stable by the additional
assumption in (c), so neither denominator function has zeros in the open right half-plane.
Their pole counts there must consequently agree. Adding $1$ does not alter finite
poles, hence $L$ and $L_Delta$ have the same open-right-half-plane pole count.

This outlines the contour argument, with the detour construction as in book pp. 30–31.
It does not replace a full contour parametrization proof. In particular one must not
infer that $F$ is stable from its boundary values: unstable poles of $Delta$ can persist.

*A useful warning from the model set.*

The plants $1/(s-1)$ and $1/(s-2)$ in section 5 show why this exercise is needed.
With $K=3$, their sensitivities are $(s-1)/(s+2)$ and $(s-2)/(s+1)$, both stable.
But $(1-t)G+t H$ for $0<t<1$ has denominator $(s-1)(s-2)$ and numerator
$s-2+t$. Its closed-loop characteristic polynomial is $s^2-4+3t$, with a positive
root $sqrt(4-3t)$. Thus every intermediate model is unstable in feedback, despite
stable endpoints and despite a small boundary relative-error plot.

The failure is the extra unstable plant pole in the intermediate models, not a paradox
in small gain. Fixing the pole count is essential when frequency error bounds are
used without a stable-block assumption. This is why the book's proof separates the
boundary homotopy argument from its final endpoint pole-count argument.

#pagebreak()
== Exercise 10 — delays add infinitely many roots, but not arbitrarily

Let proper $L_0=N/D$ be in coprime form and $tau>0$. Write
$ L_tau=L_0 e^(-s tau), quad p_tau=D+N e^(-s tau). $
$p_tau$ is an entire *quasipolynomial*, not in general a polynomial.

*(a)* $S_tau=D/p_tau$. If $D(lambda)=p_tau(lambda)=0$, then
$N(lambda)e^(-lambda tau)=0$, impossible by coprimeness. So no finite zeros of
$p_tau$ cancel, and its closed-right-half-plane zeros are exactly the poles in question.

*(b)* Put $c=L_0(infinity)$ and suppose $|c|<1$. Choose $q$ with $|c|<q<1$.
For sufficiently large $|s|$ in the closed right half-plane,
$|L_0(s)e^(-s tau)|<=|L_0(s)|<q$, uniformly in $tau>=0$. Thus $1+L_tau$ has no
zeros outside a fixed disk. There are finitely many inside because $p_tau$ is a
nonzero entire function and zeros cannot accumulate in a compact set. This includes
the equal-degree case $0<|c|<1$; strict properness is *not* implied by $|c|<1$.

*(c)* Outside that disk, $|S_tau|<=1/(1-q)$. Inside, $D/p_tau$ is continuous and
bounded if $p_tau$ has no closed-right-half-plane zeros. It is analytic in the open
half-plane. Bound the *ratio*, rather than relying on a polynomial degree argument
for $1/p_tau$ alone.

*(d)* $M|1-e^(-i omega tau)|<=M|omega|tau<=M R tau$. Choose
$tau_0=1/(2M R)$ to obtain a strict bound even on the closed interval $[0,tau_0]$.

*(e)* By (b), all potentially bad roots remain in one fixed disk for every small delay.
On its closed right-half-disk, $p_tau->p_0=D+N$ uniformly as $tau->0$. Since
$p_0$ has no zeros there, its continuous modulus has a positive minimum. Uniform
convergence makes $p_tau$ nonzero there for sufficiently small delay. Combined with
the tail exclusion this proves the claim. This is also the rigorous “no roots arriving
from infinity” argument behind the finite-frequency Nyquist delay computation.

*(f)* If $|c|>1$, the limiting high-frequency equation is $e^(s tau)=-c$, with roots
$ s_k=(log(abs(c))+i(arg(-c)+2 pi k))/tau. $
Every root has positive real part $log(abs(c))/tau$. To make the approximation rigorous,
take disjoint circles of fixed radius $epsilon<min(log(abs(c))/tau,pi/tau)$ around $s_k$.
On each circle $|e^(s tau)+c|$ has a positive minimum independent of $k$.
Because $L_0(s)-c=O(1/abs(s))$, it is smaller than that minimum for large $|k|$.
Rouché's theorem gives a root of $e^(s tau)+L_0(s)$ in every such circle. These are
zeros of $p_tau$ (away from the finitely many rational poles), all in the right half-plane.
So in fact infinitely many unstable roots exist for every positive delay. This elementary
asymptotic argument avoids an incomplete use of Picard: Picard alone does not locate
roots in the desired half-plane. The borderline $|c|=1$ is deliberately not decided.

#pagebreak()
= A reproducible analysis, and what it does not certify

The design logic is now a single chain. Specify where disturbances enter. Test all
internal channels before simplifying. Use Nyquist to understand stability changes.
Choose an uncertainty set that actually covers the plant error. Then ask separately
whether the entire set is stable and whether its error remains within the chosen envelope.

For this chapter's examples, run from the repository root:
```sh
octave --no-gui --quiet Control/robust-control-02-siso/scripts/ex1.m
octave --no-gui --quiet Control/robust-control-02-siso/scripts/satellite_delay.m
octave --no-gui --quiet Control/robust-control-02-siso/scripts/figures.m
typst compile --root . \
  Control/robust-control-02-siso/robust-control-02-siso.typ \
  Control/robust-control-02-siso/robust-control-02-siso.pdf
```

`ex1.m` checks the physical state matrix, not only a minimalized sensitivity.
`satellite_delay.m` computes characteristic roots, algebraically checked unit-gain crossings,
delay crossing residuals and directions, the rational stability norm with the installed
Octave control/SLICOT algorithm, a continuous RP upper bound, the RP searches, and a bad plant.
`figures.m` regenerates the three SVG plots from transfer coefficients and checks the
thermal example's analytic maximum. No external figure or package install is needed.

Three levels of evidence should remain distinct:

+ *Analytic results:* the thermal maxima, the delay cover, the scalar disk geometry,
  and the worked complex-analysis arguments hold on continuous domains.
+ *Continuous rational numerical algorithm:* the SLICOT norm check treats all
  frequencies with a stated solver tolerance. It is stronger than a grid but still
  floating-point computation, not a machine-verified exact certificate.
+ *Grid and refinement:* the displayed plots, RP thresholds and fifth-order Nyquist
  distance locate and illustrate behavior. The sampled counterexample frequency proves
  violation with a large numerical gap; passing values are numerical evidence unless
  supported by an independent continuous bound.

The satellite's delay extension and exercise 9's general contour proof are explicitly
qualified. Actuator saturation, nonlinearities, sampled implementation, and uncertainty
identification are not certified by these linear calculations. Nor does a failure for
the dynamic disk class imply that every physical parameter or pure delay model fails.

== Source and onward connection

The authoritative source consulted is Scherer, *Theory of Robust Control*, chapter 2,
pp. 16–45 (PDF page equals printed page), @schererTheoryRobustControl. In particular:
pp. 17–20 supply the signals and contour convention; pp. 22–26 the classical margins;
pp. 27–39 the model set and exact SISO tests; pp. 40–41 internal stability; pp. 42–45
all ten exercises. The examples, corrections, derivations, and numerical checks above
were developed against those statements, not copied as unverified inherited answers.

The next chapter replaces this special scalar loop by a general interconnection.
The scalar sum-of-moduli performance test does *not* carry over unchanged to MIMO;
structure matters. What survives is the habit: name the internal signals, define the
uncertainty, prove stability, and only then interpret a gain bound.

#text(size: 9.5pt)[#bibliography("refs.bib", title: none)]
