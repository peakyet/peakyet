// Standalone: typst compile --root . <this file> <same stem>.pdf
#set document(title: "Robust Performance Analysis: close the physical loops first", author: "Amp")
#set page(paper: "a4", margin: (x: 24mm, y: 21mm),
  header: text(size: 9pt, fill: rgb("#5b6470"))[Robust control · Chapter 6],
  footer: context align(right, text(size: 9pt, counter(page).display("1"))))
#set text(font: "Libertinus Serif", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("#1f4e79"))
#let takeaway(body) = block(width: 100%, inset: 10pt, fill: rgb("#edf5f5"),
  stroke: (left: 2pt + rgb("#0f766e")), body)
#let RH = $cal(R H)_infinity$

#text(size: 23pt, weight: "bold", fill: rgb("#1f4e79"))[Robust Performance Analysis]

#text(size: 15pt)[Close the physical loops before introducing μ]

A loop can stay stable for every allowed model and still amplify the tracking error
too much. Robust performance asks for both survival and useful behavior. The extra
full block in its μ-test is not a new physical uncertainty: it is a way of detecting
an excessive disturbance-to-error gain.

= Start with the signals we can measure

Use negative-feedback tracking with input-multiplicative uncertainty:
$ e=r-y, quad u=K e, quad y=G(u+v), quad q=W u, quad v=Delta q, quad z=V e. $
Thus the actual plant is $G(I+Delta W)$, not $G(I+W Delta)$ in general.
The known stable weights $W,V$ normalize model error and desired performance.
The unknown stable proper $Delta$ satisfies $norm(Delta)_infinity<1$.

There are three different questions, always conditional on nominal internal stability:
#table(columns: (1fr, 2.6fr), inset: 6pt, stroke: 0.4pt + luma(180),
 [Nominal performance], [At $Delta=0$, is $norm(T_(z r)(0))_infinity<1$?],
 [Robust stability], [Is every allowed physical loop well posed and internally stable?],
 [Robust performance], [Are all those loops stable and their weighted gains below one?])

Here is a case separating them without a numerical μ solver:
$ G=1/(s+1), quad K=1, quad W=1.2, quad V=1.2/(s+1). $
Nominally $S=(1+G K)^(-1)=(s+1)/(s+2)$ and $T=G K S=1/(s+2)$.
The nominal gain is $norm(V S)_infinity=0.6$. The uncertainty return gain is
$norm(W T)_infinity=0.6$, so the full unit uncertainty ball is robustly stable.
Yet the allowed constant $Delta=-0.9$ gives
$ T_(z r)(-0.9)=1.2/(s+0.92), quad norm(T_(z r)(-0.9))_infinity=1.304348>1. $
Its physical pole is $-0.92$: this is a *performance failure without instability*.

#takeaway[Good nominal performance and robust stability do not imply robust performance.
 The uncertain model can weaken feedback enough to make a stable error channel too large.]

#pagebreak()
= Cut the uncertainty, then close it in the right order

First close the known controller, leaving $v$ independent. Set $S=(I+G K)^(-1)$.
From $e=r-G K e-G v$ we obtain
$ e=S r-S G v, quad u=K S r-K S G v. $
Therefore the *cut matrix* is
$ mat(q;z)=N mat(v;r), quad
 N=mat(-W K S G, W K S; -V S G, V S). $ <eq:physicalcut>
Both minus signs come from subtracting the plant output at the error junction.
Take $G$ to be $p times m$, $K$ to be $m times p$, $W$ to be $ell times m$,
and $V$ to be $k times p$. Then $v in CC^m$, $q in CC^ell$, $r in CC^p$,
$z in CC^k$, and $Delta$ is $m times ell$. The four blocks of $N$ have sizes
$ell times m$, $ell times p$, $k times m$, $k times p$. This also covers rectangular ports.

More generally write
$ mat(q;z)=mat(A,B;C,F)mat(v;w), quad v=Delta q. $
Here $A$ is the book's uncertainty return matrix $M$, not its state matrix.
Eliminating $q$ in the first equation gives
$ q=(I-A Delta)^(-1) B w, quad
 T_(z w)(Delta)=F+C Delta(I-A Delta)^(-1)B. $ <eq:closure>
The inverse must exist as a stable proper transfer, not just at sampled frequencies.
Nominal performance sees only $F$; robust stability sees $A$; robust performance also
depends on $B,C$, which carry uncertainty into the performance channel.

For the book's generalized plant, partition outputs as $(q,z,y)$ and inputs as
$(v,w,u)$, with positive interconnection $u=K y$. Closing this controller first gives
$ N=P_(a a)+P_(a 3)K(I-P_33 K)^(-1)P_(3 a), quad a=(1,2). $
In tracking, $y$ here is the measured error $e$; the physical minus sign is already
in the plant. Closing $Delta$ first and then $K$ gives the same external transfer
as @eq:closure, provided both interconnections are well posed. This is elimination
of the same simultaneous equations, not permission to ignore internal modes.

#figure(image("assets/three-tests.png", width: 92%), caption: [Computed scalar example.
 The nominal and stability curves coincide at DC gain 0.6. Their sum reaches 1.2;
 the actual stable perturbation produces gain 1.304.])

#pagebreak()
= Why a fictitious performance block detects excessive gain

Freeze one frequency. Let $A,B,C,F$ be finite complex matrices, with $F$ of size
$k times p$. Fix a physical $Delta$ for which $I-A Delta$ is nonsingular, and call
the closed performance matrix $H=F+C Delta(I-A Delta)^(-1)B$.
Append a *full complex* matrix $Delta_p in CC^(p times k)$ with $w=Delta_p z$.
It maps the performance output back to its input, so dimensions and direction matter.

Why full? If $H v=sigma u$ for unit singular vectors $u,v$, then
$ Delta_p=sigma^(-1) v u^ast quad ==> quad H Delta_p u=u. $
Thus a gain $sigma>1$ is exposed by a rank-one block of norm $1/sigma<1$.
Conversely, $norm(H)<=1$ and $norm(Delta_p)<1$ imply $norm(H Delta_p)<1$,
so $I-H Delta_p$ is nonsingular. Consequently
$ norm(H)<=1 <=> det(I-H Delta_p)!=0
  quad "for every full" Delta_p "with" norm(Delta_p)<1. $
The artificial block is not an actuator, disturbance model, or real parameter.

== The Main Loop Theorem — finite-matrix version

Let $cal(U)$ be the original block-structured complex uncertainty space, and let
$cal(U)_e="diag"(cal(U),CC^(p times k))$. Use the *open* unit ball for each block.
Then the following are equivalent:

+ For every $Delta in cal(U)$ with $norm(Delta)<1$, the inverse $I-A Delta$ exists
  and $norm(F+C Delta(I-A Delta)^(-1)B)<=1$.
+ For every $Delta_e="diag"(Delta,Delta_p)$ with $norm(Delta_e)<1$,
  $I-N Delta_e$ is nonsingular.

The proof is a Schur complement, keeping its missing factor visible:
$ det(I-N Delta_e)
 =det(I-A Delta) det(I-H Delta_p). $ <eq:det>
For the reverse implication set $Delta_p=0$ first, recovering nonsingularity of
$I-A Delta$; then factor the determinant. The preceding singular-vector argument
recovers the norm bound. No approximation has entered this matrix theorem.

== Boundary conventions are part of the statement

An open perturbation ball corresponds to a *non-strict* bound $norm(H)<=1$.
For a closed ball $norm(Delta_p)<=1$, nonsingularity corresponds to $norm(H)<1$:
at $sigma=1$ the singular-vector block lies exactly on the boundary.
For robust design we normally demand a *uniform strict margin*, stronger than
pointwise strict inequalities on an open physical ball. We will use
$sup_omega mu(N(i omega))<1$ for that purpose. The book's Theorems 6.2–6.4 use
open uncertainty balls and $mu<=1$; they must not be silently rewritten as strict tests.

#pagebreak()
= From the theorem to a usable μ test

For a structured matrix space $cal(U)$ define
$ mu_(cal(U))(X)=1/(inf {norm(E): E in cal(U), det(I-X E)=0}), $
with value zero when no singularizing block exists. The extended space appends the
full performance block, retaining every original repeated/full block separately.
Thus the matrix theorem says
$ mu_(cal(U)_e)(N)<=1 <=>
  mu_(cal(U))(A)<=1 " and " norm(T_(z w)(Delta))<=1
  " for all " norm(Delta)<1. $
The left-hand μ is not the μ of $A$, nor the ordinary norm of $N$.

== Hypotheses for the dynamic conclusion

Use a finite-dimensional, proper, *internally stable* cut realization $N$; stable
proper LTI uncertainty with the stated complex block structure; nominal stability;
and well posed feedback at infinity. The book's family is all $Delta in RH$ whose
values belong to the structured open unit ball for every
$omega in RR union {infinity}$. Continuity on this compactified axis gives
$norm(Delta)_infinity<1$ for each member, but not one common gap for the entire family.

Under these standard complex-block hypotheses the robust stability theorem combined
with the Main Loop Theorem yields the book's non-strict test at *every* frequency.
A uniform strict test
$ sup_(omega in RR union {infinity}) mu_(cal(U)_e)(N(i omega))<1 $ <eq:strict>
certifies robust stability and a uniform performance gap for the closed unit family
as well. It also ensures well posedness at infinity. To justify the dynamic step one
uses the nominal stable loop, a homotopy in perturbation size, exclusion of imaginary-axis
and infinity singularities, and the complex-block frequency interpolation theorem.
This is a *proof outline*, not a proof of that interpolation theorem.

Real constant uncertain parameters are a smaller, different family. Replacing them
by complex dynamic blocks is a sufficient conservative test, not an exact necessity.
A hidden unstable plant/controller mode is likewise not cured by an apparently stable
cancelled transfer $N$. Check realizations and all internal channels first.

== Which numerical conclusions are legitimate?

An upper bound $u(omega)>=mu(N(i omega))$ *uniformly below one* certifies success.
An upper bound above one proves only that this certificate failed. A verified lower
bound above one proves existence of a singularizing extended block of norm below one.
It may indicate physical instability *or* excessive performance gain. A separate
robust-stability certificate excludes the first alternative. Validate a computed
witness by its block norms and the residual $sigma_min(I-N Delta_e)$.

A plotting grid cannot prove a universal-frequency statement: it can miss a narrow
peak, DC, or infinity. A single verified violating frequency can disprove a universal
bound; successful samples need continuous-frequency verification or rigorous envelopes.

#pagebreak()
= Scaling is a certificate, not a change of plant

For square blocks choose positive definite $D$ commuting with every $Delta_e$.
Then $I-N Delta_e$ is similar to $I-D^(-1)N D Delta_e$, and small gain gives
$ mu_(cal(U)_e)(N)<=inf_(D in cal(D)) norm(D^(-1)N D)_2. $
The subscript 2 is a matrix singular-value norm. A full square uncertainty block
admits only scalar multiples of identity in this positive commutant; a repeated
scalar block admits richer positive definite scalings. For rectangular full blocks
use matching input/output metrics, not a dimensionally impossible similarity.

Consider two scalar complex blocks and the asymmetric static cut matrix
$ N=mat(0.2,4;0.08,0.3), quad D="diag"(sqrt(50),1). $
The scaled off-diagonal entries both equal $sqrt(0.32)$. Thus
$ lambda:=norm(D^(-1)N D)_2=(0.5+sqrt(1.29))/2 approx 0.817891. $
This is also exact μ: $Delta_e=I/lambda$ singularizes $I-N Delta_e$,
since the number is $N$'s Perron eigenvalue. The unscaled norm is $4.01649$.
So a failed unscaled upper bound can coexist with a successful exact test.

#figure(image("assets/asymmetric-scaling.png", width: 92%), caption: [Computed singular
 values versus scaling ratio. The optimum balances 4 against 0.08, rather than
 pretending the two channels are physically symmetric.])

== Keep uncertainty radius and performance level separate

To certify physical uncertainty radius $alpha$ and performance level $beta$, test
$ mu_(cal(U)_e)(N "diag"(alpha I,beta^(-1)I))<=1. $
This is the book's Lemma 6.3 with normalized blocks. An unscaled upper bound
$mu(N)<=gamma$ instead guarantees performance at most $gamma$ only for physical
radius $1/gamma$. It does *not* guarantee gain $gamma$ on the original unit family.

The book's §6.6 example reports 2.72 as an upper bound and a lower bound above 2.71:
these concern radii $1/2.72$ and $1/2.71$, respectively. Its robust-stability bound
below 2.7 rules out physical instability at radius $1/2.71$, so the lower result is
a performance violation there. Those are book-reported bounds, not computations
reproduced here. Chapter 8 uses scaling to alternate analysis with chapter 7's synthesis;
chapter 9 offers stable closed-loop design coordinates. Neither changes these logical directions.

#pagebreak()
= Exercise 1 — derive the tracking result, not just its formula

These are parts (a)–(d) of the exercise on book p. 156. Assume nominal internal
stability throughout; otherwise no performance test alone can establish stabilization.

== (a) Generalized plant and the three tests

Keep the book's ordering $(q,z,e)$ from inputs $(v,r,u)$:
$ P=mat(0,0,W; -V G,V,-V G; -G,I,-G), quad u=K e. $
Closing $K$ gives @eq:physicalcut, with
$ M_1=W K(I+G K)^(-1), quad M_2=V(I+G K)^(-1), quad
 N=mat(-M_1 G,M_1;-M_2 G,M_2). $
The open-ball, non-strict tests are respectively
$ mu_(cal(U))(-M_1 G)<=1, quad norm(M_2)<=1, quad mu_(cal(U)_e)(N)<=1 $
at every frequency. The minus sign can be removed from μ for this phase-symmetric
complex family, but not from the physical feedback equations.

== (b) Scalar rank-one reduction and an actual failure witness

In SISO, $N=mat(M_1;M_2)mat(-G,1)$ has rank one. For two scalar blocks,
the determinant lemma gives
$ det(I-N "diag"(delta,eta))=1+G M_1 delta-M_2 eta. $
For $|delta|,|eta|<=r$, the largest magnitude of the last two terms is
$r(|G M_1|+|M_2|)$; independent phases align them to equal one at the threshold.
Therefore, exactly,
$ mu_(cal(U)_e)(N)=|W T|+|V S|. $ <eq:scalar>
The book's condition (6.1) is $|W T|+|V S|<=1$ at every frequency. It is the
*sum*, not two separate bounds below one. The page-1 example has both individual
tests at 0.6 but sum 1.2. At DC choose $delta=-0.9$: the physical return remains
nonsingular while the error gain exceeds one. Choosing $W=0.4$ instead gives
sum 0.8 and certifies robust performance. Choosing $W=3$ preserves nominal gain
0.6 but loses robust stability (for example $delta=-0.9$ gives physical pole $+0.7$).

How can ordinary $H_infinity$ design help? A sufficient design target is
$ norm(mat(sqrt(2) W T; sqrt(2) V S))_infinity<1, $
because $a+b<=sqrt(2)sqrt(a^2+b^2)$. A less restrictive search introduces
$0<theta<1$ and tests the stack $(W T/sqrt(theta),V S/sqrt(1-theta))$.
Its squared norm dominates $(|W T|+|V S|)^2$ by Cauchy–Schwarz.
A fixed $theta$ is generally conservative across frequency; solving one such
$H_infinity$ problem is not an exact general μ-synthesis algorithm.

#takeaway[The full performance block selects both input direction and phase. That is why
 separate nominal and stability tests miss the way error amplification and uncertainty cooperate.]

#pagebreak()
= Exercise 1 continued — why the MIMO case is different

== (c) Derive the condition-number bound

Suppose $G$ is square and has a proper inverse; interpret the estimate at frequencies
where the inverse is finite. Write $N=L R$, $L=mat(M_1;M_2)$, $R=mat(-G,I)$.
Sylvester's determinant identity reduces a possible singularity to
$ det(I-N "diag"(D_1,D_2))
 =det(I+G D_1 M_1-D_2 M_2). $
If both full blocks have norm at most $r$, the perturbing term has norm bounded by
$ r(norm(G)norm(M_1)+norm(M_2))
 <=r(norm(G)norm(G^(-1))norm(M_1 G)+norm(M_2)). $
For this expression below one, the reduced inverse exists by the Neumann series.
Taking the reciprocal radius proves the exercise's upper bound
$ mu(N)<=kappa_2(G)norm(M_1 G)+norm(M_2), quad
 kappa_2(G)=norm(G)norm(G^(-1)). $
For SISO $kappa_2=1$, recovering the exact sum. For a full uncertainty block,
robust stability controls $norm(M_1 G)$; nominal performance controls $norm(M_2)$.
Even both below one do not force their condition-number-weighted sum below one.
The estimate is sufficient, not a claim that a large condition number necessarily
causes failure for every orientation of $M_1,M_2$.

== (d) An explicit arbitrarily bad family — no random search

Let $h>=1$, and choose
$ G="diag"(h,h^(-1)), quad M_1=G^(-1), quad M_2=I,
 quad J=mat(0,1;1,0). $
Then $norm(M_1 G)=norm(M_2)=1$, while $kappa_2(G)=h^2$.
Use unit-norm blocks $D_1=-J$, $D_2=J$. The nonzero eigenvalues of
$N "diag"(D_1,D_2)$ equal those of
$ -G D_1 M_1+D_2 M_2=G J G^(-1)+J
   =mat(0,h^2+1;h^(-2)+1,0). $
They are $plus.minus(h+h^(-1))$. Scaling both blocks by $1/(h+h^(-1))$
therefore singularizes $I-N Delta_e$ exactly, proving
$ mu(N)>=h+h^(-1). $
For any requested $gamma>0$, choosing $h>=max(1,gamma)$ suffices. With
$h=10$ and 100, the verified lower bounds are 10.1 and 100.01, with witness
norms 0.0990099 and 0.00999900. The script checks the smallest singular value
of $I-N Delta_e$, rather than interpreting a failed upper bound as a counterexample.

The matrices satisfy the exercise's non-strict individual bounds. If strict individual
margins are desired, replace both $M_1,M_2$ by $c M_1,c M_2$ with any fixed
$0<c<1$; μ scales to at least $c(h+h^(-1))$, still unbounded.
This is a matrix counterexample for the stated *two full blocks*, not a claim about
a family of repeated real parameters. Setting $M_2=0$ would destroy the coupling
and reduce μ to one in this construction.

#pagebreak()
= Exercise 2 — model the uncertainty family before designing

Book pp. 156–158 use $G=1/(0.05s+1)^2$, $H=200/(10s+1)$, and a disturbance
added *between* $G$ and $H$, with gain 0.5. Define $P_0=H G$ and $D_0=0.5H$.
The physical equations are
$ e=r-P_0(u+v)-D_0 d, quad u=K e, quad q=W u, quad v=Delta q. $
The disturbance path is $D_0$, not $0.5P_0$. In this scalar case the order of
$Delta,W$ commutes; that accident should not be generalized to matrices.

== (a) A proper uncertainty envelope and its limitation

The stated envelope is 1% at low frequency, at most 100% at 30 rad/s, then a
40 dB/decade rise. An ideal squared-zero weight is improper. We use the declared
proper regularization
$ W=0.01(1+s/omega_1)^2/(1+s/1000)^2, quad omega_1=30/sqrt(99)=3.015113. $
It has $W(0)=0.01$, $|W(30i)|=0.999101$, and a 39.17 dB/decade rise from
30 to 300 rad/s. Above 1000 rad/s it levels toward 1100. Hence it is an
approximate finite-band interpretation, *not an envelope for an unbounded asymptotic
40 dB/decade rise*. All subsequent margins refer to this particular proper weight.
Nor does a smooth rising weight stay exactly at 1% on an entire low-frequency interval.

The unweighted generalized plant, with outputs $(q,e)$ and inputs $(v,r,d,u)$, is
$ mat(0,0,0,W; -P_0,1,-D_0,-P_0). $

#figure(image("assets/ex2-W.png", width: 65%), caption: [The actual proper uncertainty weight.])

== (b) Static gains: nominal stability is not robustness

For $K=k$, the full nominal characteristic polynomial is
$ 0.025s^3+1.0025s^2+10.1s+1+200k. $
Routh–Hurwitz gives $1.0025 times 10.1>0.025(1+200k)$, hence within $[1,3]$
exactly $1<=k<2.02005$ is stable. Equality has imaginary-axis poles.
#table(columns: (1fr,1fr,1fr,1fr), inset: 5pt, stroke: 0.4pt + luma(180),
 [$k$], [$max Re(p)$], [Sampled $max |W T|$], [Error bandwidth],
 [1], [−2.4924], [0.7320], [8.636 rad/s],
 [1.5], [−1.1334], [2.557], [10.85 rad/s],
 [2], [−0.0400], [100.6], [12.69 rad/s])
Higher gain improves low-frequency rejection but moves a resonance toward instability.
The last two gains violate the full-complex stability test at explicit frequencies.
Successful grid samples alone would not prove robustness.

#pagebreak()
= Exercise 2(c) — nominal design with a missed target

The book requests disturbance attenuation 100 up to 0.1 rad/s; step error below
$10^(-4)$; the *error* bandwidth (first $|S|=1/sqrt(2)$ crossing from below)
between 10 and 20 rad/s; and step-error overshoot below 7%.
Weights alone do not encode bandwidth or step overshoot exactly.

Use the allowed first-order shape $a(s/b+1)/(s/c+1)$ for both input channels:
$ W_r=3 times 10^5 (s/8+1)/(s/0.001+1), quad
 W_d=8000(s/3+1)/(s/0.1+1), quad rho=10^(-4). $
The script feeds $r=W_r hat(r)$, $d=W_d hat(d)$, measures the physical error $e$,
and penalizes $(e,rho u)$. For exogenous inputs $(hat(r),hat(d))$, the resulting
closed transfer is
$ T_c=mat(S W_r,-S D_0 W_d;rho K S W_r,-rho K S D_0 W_d). $
This specifies exactly where the weights enter: input weights multiply channels;
they are not outputs called $W_r e$ and $W_d e$ simultaneously.

Octave's `hinfsyn(P,1,1)` gives a six-state controller and achieved synthesis gain
about 42.71. That value is not below one and is not a certificate that the four
engineering specifications all hold. Direct physical-loop checks give:
#table(columns: (2fr,1fr,1.3fr), inset: 6pt, stroke: 0.4pt + luma(180),
 [Quantity], [Achieved], [Requested],
 [$max_(0<=omega<=0.1)|D_0 S|$], [0.00756], [≤ 0.01],
 [$|S(0)|$], [$approx 5 times 10^(-5)$], [$<10^(-4)$],
 [First error crossing], [56.8 rad/s], [10–20 rad/s: *missed*],
 [Output overshoot / error undershoot], [3.35%], [< 7%])

#figure(image("assets/ex2-c.png", width: 87%), caption: [Nominal design.
 The disturbance target is met but the error bandwidth is much too high.])

For a unit reference, $e(t)=1-y(t)$: a 3.35% output overshoot corresponds to error
undershoot near $-0.0335$. Error starts at one because the plant is strictly proper;
its peak above the nearly zero final value is not a meaningful conventional overshoot
percentage. This note reports output overshoot/error undershoot explicitly, rather
than silently identifying a plot of $y$ with a plot of $e$.
The book's wording is ambiguous on that point. No infeasibility claim is made:
this fixed-weight demonstration is a partial design, not a solution meeting all four targets.

#pagebreak()
= Exercise 2(d,e) — test the physical loop, then compare designs

== (d) Stability margin and a real-rational destabilizer

The scalar full-block margin is $gamma^*=1/norm(W T)_infinity$, for the specified
family $norm(Delta)_infinity<gamma^*$. A continuous-frequency norm algorithm gives
$norm(W T)_infinity approx 30.45$ near 581.7 rad/s, hence $gamma^* approx 0.03284$.
This is a margin in *normalized* uncertainty, not a 3.28% relative plant error at all
frequencies. The physical relative error is $Delta W$.

At a peak frequency choose a real stable all-pass block
$ Delta(s)=c(alpha-s)/(alpha+s), quad alpha approx 171.1. $
Its norm is exactly $c$. Match its phase to $-1/(W T)$; if the desired phase
requires a sign, retain that sign explicitly. Here the displayed positive-sign
choice works. At $c=gamma^*$ it puts a boundary root near the imaginary axis.
For $c=1.2gamma^*,1.5gamma^*,2gamma^*$, the *full physical-loop* rightmost poles
are approximately $+39.08,+89.89,+160.7$. The script retains all plant, weight,
perturbation and controller states in this check, independently of polynomial cancellation.

== (e) Add the uncertainty channel, with the same weights

Inputs are now $(hat(r),hat(d),v,u)$; outputs are $(e,q,rho u,e)$, with the final
$e$ sent to the controller. Minimize the ordinary $H_infinity$ norm of the three
penalty outputs using the same $W_r,W_d,rho$. This unscaled surrogate gives an
eight-state controller and gain about 322.7. *That large objective proves neither
robust performance nor its failure.* A separate continuous-frequency check of
$norm(W T)_infinity approx 0.6457<1$ certifies robust stability for the normalized
unit ball. Its margin is about 1.549, much larger than the nominal design's 0.03284.

#figure(image("assets/ex2-e.png", width: 81%), caption: [Augmented design:
 $|W T|$ now stays below one, at the expense of nominal error performance.])

The achieved error is about $3.74 times 10^(-4)$ at DC, the low-frequency
disturbance gain 0.0567, the error bandwidth 6.50 rad/s, and output overshoot/error
undershoot 34.9%. These values miss the original targets. This comparison illustrates
the cost for these two designs, not a theorem that every robust controller must pay
that cost. Both nominal physical realizations are checked for all internal modes.

#pagebreak()
= A reliable analysis workflow and reproducibility record

Start by naming the disturbance, error, command and uncertainty signals, with units.
Absorb desired bounds into stable weights and declare the normalized uncertainty
family. Close the controller first. Check that its *realization*, including retained
controller modes, is internally stable and its direct-feedthrough loop well posed.
Then derive the cut matrix from the signal equations, and only then choose a μ structure.

#table(columns: (1fr,2.4fr), inset: 7pt, stroke: 0.4pt + luma(180),
 [To establish…], [Use…],
 [Nominal performance], [A continuous-frequency norm bound on $F$.],
 [Robust stability], [A structured μ upper certificate on $A$, or a validated physical counterexample.],
 [Robust performance], [An extended-structure μ upper certificate on all of $N$.],
 [A failure], [A validated singularizing structured block, or an actual allowed physical loop whose gain or internal poles violate the demand.],
 [Only an inconclusive result], [A failed upper bound, a coarse grid, or an unvalidated lower-bound iterate.])

The exact scalar reduction and the MIMO determinant construction in this note are
derived algebraically. The dynamic μ theorem is invoked with its hypotheses and its
proof outline labelled. General μ bounds are not automatically exact, and real-parameter
families do not acquire complex-block necessity by notation.

== Run the computations

From the repository root, run Octave on the three scripts in this note's `scripts/`:
`analysis.m`, `ex1d.m`, and `ex2.m`. They use the installed control package, with
no additional installation. The first script checks physical-loop versus cut-loop
frequency responses and plots the two teaching examples. The second verifies explicit
two-full-block singularity witnesses. The third builds both generalized plants,
reports full physical-loop eigenvalues, runs synthesis and continuous-frequency
$H_infinity$ norms, and regenerates the three exercise figures.

The exercise's response crossings, finite-band disturbance maxima and transient peaks
are sampled numerical measurements. The full-loop eigenvalues and the control package's
continuous-frequency norm solver provide independent numerical checks, not exact
interval-arithmetic proofs. For design (c), independent complex signal algebra and
state-space sensitivity differ by up to $2.1 times 10^(-6)$ in absolute gain; its
near-cancelling slow modes limit the useful low-frequency digits. Hence the DC error
is reported only as approximately $5 times 10^(-5)$. Design (e)'s discrepancy is below
$6 times 10^(-13)$. The exact Routh threshold and matrix witnesses provide algebraic
checks. Cancelled high-order polynomial roots alone do not certify internal stability.

== Sources and limits of this rewrite

Primary source: C. Scherer, #emph[Theory of Robust Control], chapter 6, printed/PDF
pp. 144–158: problem hypotheses (144–147), Main Loop Theorem and scaling (148–150),
dynamic test and summary (150–152), illustrative bounds (152–155), and Exercises 1–2
(156–158). The §6.6 numerical bounds are quoted as book results, not newly reproduced.
The physical-signal derivations and deterministic asymmetric examples here are original
worked explanations of those results. Chapters 7–9 of this knowledge base provide
the subsequent synthesis and closed-loop parametrization context.
