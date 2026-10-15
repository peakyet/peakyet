// Standalone; compile with typst compile --root . <source> <output>.
#set document(title: "Nominal performance: from requirements to weighted H-infinity", author: "Amp")
#set page(paper: "a4", margin: (x: 24mm, y: 21mm),
  header: text(size: 9pt, fill: rgb("#5b6470"))[Robust control · Chapter 5],
  footer: context align(right, text(size: 9pt, counter(page).display("1"))))
#set text(font: "Libertinus Serif", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("#1f4e79"))
#let takeaway(body) = block(width: 100%, inset: 10pt, fill: rgb("#edf5f5"),
  stroke: (left: 2pt + rgb("#0f766e")), body)

#text(size: 23pt, weight: "bold", fill: rgb("#1f4e79"))[Nominal Performance]

#text(size: 15pt)[From engineering requirements to weighted H∞ bounds]

“Track slowly varying references, reject load disturbances, ignore sensor noise, and
do not overwork the actuator.” None of these sentences specifies a controller. Each
must first become a statement about *which inputs are allowed* and *which outputs
are acceptable*. Weighting is the translation, not an extra tuning trick.

#takeaway[The construction is

physical signals → normalized budgets → weighted closed-loop map → generalized plant.

Internal stability remains a separate requirement. A small weighted transfer norm
does not certify hidden internal modes, step overshoot, or actuator saturation.]

= One norm, two different experiments

Let $G$ be a real-rational, proper, stable transfer matrix, realized with decaying
internal transients. Use Euclidean vector norms and their induced matrix norms.
With zero initial state, its finite-energy gain is
$ norm(G)_infinity = sup_(w in L_2, w != 0) norm(G w)_2/norm(w)_2
  = sup_(omega in RR) sigma_max(G(i omega)). $
The first experiment measures total energy. A persistent sinusoid has infinite
energy, so substituting it in this ratio is invalid. Yet the *same number* governs
its steady-state RMS gain (book Theorems 5.1–5.2).

For the complex exponential $w(t)=a e^(i omega t)$, stability gives
$ z_s(t)=G(i omega)a e^(i omega t), quad
  norm(z_s)_"RMS"/norm(w)_"RMS"=norm(G(i omega)a)/norm(a). $
Here RMS means the square root of the long-time average of $w^*w$; it equals
$norm(a)$ for this complex signal. Maximizing over $a$ selects the largest singular
value at that frequency; maximizing over frequency gives $norm(G)_infinity$.

This is a steady-state statement, not a bound on the maximum instantaneous output.
An initial transient disappears from the long-time average but may matter in a
real tracking maneuver. The energy experiment and the sinusoidal experiment agree
on their worst gain, not on their admissible signals or their transient behavior.

#pagebreak()
= Which sinusoid is worst? Include the endpoints

At a fixed nonzero frequency, choose a unit *right* singular vector $v$ such that
$ G(i omega)v=sigma_max(G(i omega))q, quad norm(q)=norm(v)=1. $
These vectors are generally complex. The physical input is
$w(t)=Re(v e^(i omega t))$: its components can have different phases. Its real
RMS is $norm(v)/sqrt(2)$, and the output RMS is
$norm(G(i omega)v)/sqrt(2)$, so the factor cancels in the gain. Restricting $v$
to real vectors at nonzero frequency incorrectly forbids relative phase shifts.
Equivalently, multiply the real sinusoid by $sqrt(2)$ to obtain unit RMS.

For example, the stable row $G(s)=[1, (1-s)/(1+s)]$ has at $omega=1$ the value
$[1,-i]$. Its complex unit direction $v=(1,i)^T/sqrt(2)$ gives gain $sqrt(2)$.
Every real unit vector gives only gain 1 at this frequency. The missing gain comes
from coordinating the two input phases, not increasing either input budget.

*At zero frequency*, $G(0)$ is real and a real maximizing singular vector exists.
The input is a constant (a step applied from $t=0$), with RMS $norm(a)$, *not*
$norm(a)/sqrt(2)$. The zero-frequency gain is the final-value ratio, not the
step-response peak. For $G(s)=1/(s+1)$ the gain 1 occurs at zero.

*At infinite frequency*, properness gives $G(i omega) -> D$. Infinity is a limit,
not a realizable sinusoid. For $G(s)=s/(s+1)$,
$ |G(i omega)|=omega/sqrt(1+omega^2)<1 $ for every finite positive $omega$,
but $norm(G)_infinity=1$. Thus use a *supremum*, not a guaranteed finite-frequency
maximum. Frequencies approaching infinity approach the bound. A dense finite
frequency grid alone does not prove an $H_infinity$ bound.

== Why adding frequencies cannot make the gain worse

For pairwise distinct frequencies, let $w=sum_j a_j e^(i omega_j t)$.
Time-averaged cross terms vanish, giving
$ norm(w)_"RMS"^2=sum_j norm(a_j)^2, quad
  norm(z_s)_"RMS"^2=sum_j norm(G(i omega_j)a_j)^2
  <= norm(G)_infinity^2 sum_j norm(a_j)^2. $
One sinusoid already attains or approaches the supremum. For real sums, use DC
plus positive-frequency real sinusoids; each nonzero-frequency term contributes
$norm(a_j)^2/2$. Do not count a conjugate pair twice under that convention.

#takeaway[A worst-case disturbance chooses both a frequency and a coordinated
spatial/phase direction. Looking only at individual transfer entries can miss it.]

#pagebreak()
= Weights have two different jobs

Write the physical closed-loop map as $z=F w$, where $F=S(P,K)$ in the book's
notation. Do not confuse this interconnection symbol with sensitivity $S$ below.
Choose stable proper real-rational filters and define
$ w=W_w tilde(w), quad tilde(z)=W_z z, quad
  tilde(z)=W_z F W_w tilde(w). $
Then, for the internally stable closed loop,
$ norm(tilde(w))_"RMS"<=1 => norm(tilde(z)_s)_"RMS"<=1
  quad arrow.l.r quad norm(W_z F W_w)_infinity<=1. $
The equivalence is for all finite sinusoidal sums, or alternatively for all
finite-energy inputs with the corresponding energy norm.

#table(columns: (1fr, 2.8fr), inset: 7pt, stroke: 0.4pt + luma(180),
  [Input shaper $W_w$], [Large magnitude means *more physical input is allowed*
  for a unit normalized input. A low-pass shaper models predominantly slow disturbances.],
  [Output weight $W_z$], [Large magnitude means *less physical output is tolerated*.
  It measures output relative to an error allowance.])

For scalar weights, at a frequency where their product is nonzero,
$ |F(i omega)| <= 1/|W_z(i omega)W_w(i omega)|. $
Thus the tolerated envelope is the *inverse* of the output weight, not the weight
itself. A constant error tolerance $epsilon$ requires $W_z=1/epsilon$.
A desired envelope need not have a stable proper rational inverse; practical
weights approximate it while preserving a valid realization.

== A factor-of-ten error in interpretation

Suppose $F=0.2$ and the disturbance amplitude allowance is $A=0.1$, while the
output tolerance is $E=0.05$. Choose $W_w=A$, $W_z=1/E=20$:
$ norm(W_z F W_w)=20 times 0.2 times 0.1=0.4<=1. $
The largest physical output is $0.02$, safely below $0.05$.
If instead $A=1$, the same tolerance requires $|F|<=0.05$; the actual map fails
with weighted gain 4. Using $W_z=E$ would report the misleading value $0.01$.
Worse, replacing the small input shaper $A=0.1$ by its inverse would report 40
and reject the feasible first requirement. These are different physical problems.

For matrix weights, keep the order: at each frequency the input set is
$ {W_w a : norm(a)<=1} $ and the acceptable output set is
$ {z : norm(W_z z)<=1}. $ These are complex amplitude ellipsoids (possibly
degenerate or unbounded). No invertibility assumption is needed for the weighted
map itself; a zero or singular weight simply leaves some directions untested.

#pagebreak()
= Tracking, disturbance rejection, and actuator effort

To make every sign explicit, use a SISO negative-feedback loop
$ y_p=G u+d, quad y_m=y_p+n, quad u=C(r-y_m), quad e=r-y_p. $
Here $d$ is an *output* disturbance and $n$ is sensor noise. Define
$ S=1/(1+G C), quad T=G C/(1+G C), quad S+T=1. $
Eliminating the loop gives
$ e=S r-S d+T n, quad
  y_p=T r+S d-T n, quad u=C S(r-d-n). $
If $d$ entered at the plant input, its output channel would instead be $G S$.
If error meant $r-y_m$, its noise channel would be $-S$, not $T$.
Signal location and the definition of “error” are part of the specification.

Slow tracking and output-load rejection ask for small $S$ at low frequency.
Sensor-noise rejection asks for small $T$ at high frequency. Low-frequency
$S$ small also makes $T$ close to 1: this is how an *upper* bound on one channel
enforces approximate transmission in its complement. It is not an independent
lower singular-value constraint imposed by an upper norm bound.

With $w=(d,n,r)^T$, $W_w=op("diag")(W_d,W_n,W_r)$, one useful normalized map is
$ M=mat(-W_e S W_d, W_e T W_n, W_e S W_r;
  -W_u C S W_d, -W_u C S W_n, W_u C S W_r). $
The first output row penalizes error, the second actuator command. Constant
$W_u=1/u_"allow"$ puts effort in units of its allowance. A dynamic $W_u$ can
penalize fast actuator activity more strongly. The bound $norm(M)_infinity<=1$
is an RMS/energy effort budget, *not* the pointwise saturation constraint
$|u(t)|<=u_"max"$ for arbitrary inputs.

== A concrete loop, not a synthesis claim

Take $G=1/(s+1)$ and $C=9$. Then
$ S=(s+1)/(s+10), quad T=9/(s+10), quad C S=9(s+1)/(s+10). $
Use $W_S=2/(s+0.2)$, $W_T=(s+1)/(2(s+10))$, and $W_u=0.1$.
Here $W_S S$ permits $|S(0)|<=0.1$ and relaxes with frequency;
$W_T$ penalizes high-frequency $T$ more than low-frequency $T$.
The familiar mixed-sensitivity stack $[W_S S; W_T T; W_u C S]$ has gain
about 1.00505: it *fails* a unit joint bound even though each channel individually
passes. The next page explains why. These weights are an illustrative test, not
an assertion that this controller optimizes them.

#pagebreak()
= A joint budget is not several independent budgets

For normalized inputs $w_1,w_2,w_3$, the unit ball
$ sum_j norm(w_j)_"RMS"^2<=1 $
is a *smaller* uncertainty set than three separate unit bounds. It implies each
individual norm is at most 1, but the converse fails. Three separate squared
bounds $<=1/3$ imply the joint bound, not conversely. These inclusions concern
*input sets*: protecting the bigger set is the stronger performance requirement.

Consider the static row $z=0.6 w_1+0.6 w_2$. Its gain for a stacked unit input
is $sqrt(0.6^2+0.6^2)=0.848528$, so a unit output tolerance passes.
With *independent* unit inputs, coherent $w_1=w_2=1$ gives $z=1.2$: it fails.
Testing each channel alone gives 0.6 and misses their cooperation.

The same issue appears when *outputs* are stacked. For a scalar input and two
outputs $z_1=z_2=0.8w$, each separate gain is 0.8, but the stack gain is
$sqrt(2) times 0.8=1.131371$. In general, for $m$ blocks,
$ max_j norm(M_j)_infinity <= norm(mat(M_1; dots; M_m))_infinity
  <= sqrt(sum_j norm(M_j)_infinity^2). $
The upper bound need not be attained: different channels can peak at different
frequencies or input directions. A unit stack bound guarantees every individual
bound, but is usually more demanding. Allocate budgets deliberately rather than
silently replacing separate requirements with a stack.

#figure(image("assets/budgets.png", width: 100%), caption: [Actual computations for
the loop on the previous page. Left: physical sensitivity and its inverse-weight
ceiling. Right: every weighted channel stays at or below 1, but their Euclidean
stack exceeds 1 near DC. Endpoint calculations, not the grid alone, certify this.])

At DC, the squared stack gain is exactly
$ 1^2+0.045^2+0.09^2=1.010125. $
The script proves its squared magnitude never exceeds the DC value using a
nonnegative polynomial in $omega^2$. Its exact norm is $sqrt(1.010125)=1.005050$,
attained at zero, while the effort channel approaches 0.9 at infinity.

#pagebreak()
= Matrix weights are geometry, not scalar ceilings

A scalar weight commutes with a scalar transfer. Matrix weights generally do
not commute, and bounding products of their norms is only a sufficient test.
At one frequency (or for these constant stable transfers), take
$ F=mat(0,1;1,0), quad W_z=mat(2,0;0,1), quad W_w=mat(1,0;0,1/2). $
The correct map is
$ W_z F W_w=mat(0,1;1,0), quad norm(W_z F W_w)=1. $
But moving the input weight through $F$ gives
$ W_z W_w F=mat(0,2;1/2,0), quad norm(W_z W_w F)=2. $
The first direction is allowed amplitude 1 and lands in the output direction
with tolerance 1. The second is allowed amplitude $1/2$ and lands in the output
direction with tolerance $1/2$. Both are exactly acceptable. Reordering loses
this directional correspondence and declares a feasible requirement infeasible.
Likewise, $norm(W_z)norm(F)norm(W_w)=2$ is a conservative bound, not the answer.

== Matching a desired response includes phase

Sometimes “small output” is the wrong objective: the output should resemble a
specified stable proper model $W_m$. Require
$ norm(W_1 (F-W_m) W_2)_infinity<=gamma, quad gamma>0. $
Replace $W_1$ by $W_1/gamma$ to normalize the threshold to 1. Subtract the model
*before* taking magnitudes: $|F|-|W_m|$ is not $|F-W_m|$.
For instance, $F=-1$ and $W_m=1$ have identical Bode magnitudes but discrepancy
2, so a tolerance of 0.1 fails by a factor of 20. Model matching controls complex
frequency-response error, hence amplitude *and* phase indirectly.

A dynamic exact check: if $F=1/(s+1)$ and $W_m=2/(s+2)$, then
$ F-W_m=-s/((s+1)(s+2)), quad
  |F(i omega)-W_m(i omega)|^2
  =omega^2/((omega^2+1)(omega^2+4)). $
Putting $x=omega^2$, differentiation gives a numerator $4-x^2$, so the peak
occurs at $omega=sqrt(2)$ with gain $1/3$. An unweighted tolerance 0.4 passes;
0.3 fails. Here both endpoints have zero discrepancy: looking only at DC and
high-frequency limits would miss the violation.

#takeaway[Weights normalize tolerances; they do not guarantee feasibility.
Check both frequency and direction, and examine the physical unweighted responses
after design. A norm minimizer need not “hug” the entire envelope.]

#pagebreak()
= Build the generalized plant without changing the feedback

Use the book's positive interconnection $u=K y$ (the corrective sign is inside
$K$). Partition the physical open loop as
$ mat(z;y)=mat(P_11,P_12;P_21,P_22) mat(w;u), quad
  F=P_11+P_12 K(I-P_22 K)^(-1)P_21. $
With $w=W_2 tilde(w)$ and performance output
$tilde(z)=W_1(z-W_m w)$, direct substitution gives
$ tilde(P)=mat(W_1(P_11-W_m)W_2, W_1 P_12;
  P_21 W_2, P_22). $
Closing the same controller yields
$ S(tilde(P),K)=W_1(S(P,K)-W_m)W_2. $
Thus model matching and weighted gain bounds ($W_m=0$) share the same synthesis
format. No inverse weights need be implemented. The reference-model branch is
driven by the same physical exogenous input $w$, not by controller output.

== When does this preserve the stabilizer class?

The unchanged $P_22$ preserves the controller's measurement-to-actuation feedback
equations and its algebraic well-posedness condition. This is *not*, by itself,
a theorem about arbitrary state-space realizations. Internal stability also tests
autonomous states that can be invisible in every displayed transfer matrix.

A safe implementation retains the original plant states and appends *Hurwitz*
realizations of the proper stable input shapers, output filters, and model.
No appended state feeds back from a weighted performance output to $y$ or $u$.
After eliminating a well-posed algebraic loop and ordering states as input
shapers → physical closed loop → model/output filters, the state matrix is block
triangular with the original closed-loop matrix and Hurwitz diagonal blocks.
The model is a stable branch driven by the shaper; it may be placed before the
output filter. Therefore the augmented matrix is Hurwitz *if and only if* the
original closed-loop matrix is Hurwitz. Stable unobservable appended modes are
harmless; cancellations of unstable hidden states are not.

In the book's language, Hypothesis 5.3 requires both interconnections to be
generalized plants; Lemma 5.4 then invokes the Chapter 3 internal-stability test
to identify their stabilizing controllers via the common $P_22$. Check that
hypothesis, or use the explicit stable cascade argument above. Do not extend
the lemma to arbitrary nonminimal realizations merely because their transfers
have the same lower-right block.

For a counterexample, append an unconnected state $dot(q)=q$ to an otherwise
stable weighted plant. All transfer blocks, including $P_22$, are unchanged,
yet no controller stabilizes that state. Likewise, implementing a “stable”
weight by unstable pole-zero cancellation is not a Hurwitz realization. An ideal
integrator weight is not stable either: use a leaky approximation or analyze
the augmented stabilization problem explicitly rather than quoting equivalence.

#pagebreak()
= Three worked self-checks and a reproducible workflow

*Chapter 5 contains no book exercises.* These are original checks with solutions,
chosen to distinguish interpretations that can lead to different design decisions.

== Is the specification impossible before synthesis starts?

Ask for $|S(0)|<=0.1$ and $|T(0)|<=0.2$ in the tracking loop. Can clever
weighting make both feasible?

*Solution.* No. Since $S+T=1$, the triangle inequality would imply
$1<=|S(0)|+|T(0)|<=0.3$. These constant DC requirements contradict the loop
identity, regardless of controller order. Requesting small $S$ at low frequency
and small $T$ at high frequency avoids this immediate contradiction, though it
does not guarantee a feasible design for the given plant.

== Convert an individual allowance into a joint one

Two output channels must each have gain at most 0.8. Does this certify their
unit stack requirement? How can one certify it using only individual bounds?

*Solution.* No: the constant map $(0.8,0.8)^T$ is a counterexample. Individual
bounds $b_1,b_2$ suffice if $b_1^2+b_2^2<=1$; equal allocation requires
$b_1=b_2=1/sqrt(2)$. This is sufficient, not necessary for an arbitrary dynamic
map: its peaks may not occur together. Compute the actual stacked singular value
when conservatism matters.

== What does scaling a weight actually do?

A fixed controller achieves $norm(W_1(F-W_m)W_2)_infinity=0.6$. Replace $W_1$
by $2W_1$. Does the controller become unstable? Does it pass the unit test?

*Solution.* With the stable realizations and external topology just described,
stability is unchanged. The new norm is exactly 1.2, so performance fails.
The allowable physical discrepancy was halved. Scaling a requirement does not
improve the physical loop; it changes the ruler used to judge it.

== Run and audit

The adjacent #raw("performance_examples.m") uses Octave's control package. Run
it from any directory with #raw("octave --no-gui --quiet <path>/performance_examples.m").
It recreates #raw("assets/budgets.png"), checks the matrix products, phase-direction
example, budget counterexamples and model-matching peak, and verifies the mixed
stack by a nonnegative-polynomial certificate as well as a frequency grid.
The plot is evidence of the shapes; endpoint and algebraic checks supply what a
finite grid cannot prove. There is no controller synthesis or robust-uncertainty
claim here: these are *nominal* specifications preparing the next chapters.

The source is Chapter 5, pp. 136–143, of @schererTheoryRobustControl.
The numerical examples, actuator-effort extension and realization counterexample
are explanatory additions. No external research was needed.

#bibliography("refs.bib")
