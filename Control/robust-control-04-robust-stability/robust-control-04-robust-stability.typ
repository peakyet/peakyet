// Standalone; no shared template or network dependency.
#set document(title: "Robust stability: from uncertain equations to certificates", author: "Amp")
#set page(paper: "a4", margin: (x: 24mm, y: 21mm),
  header: text(size: 9pt, fill: rgb("#5b6470"))[Robust control · Chapter 4],
  footer: context align(right, text(size: 9pt, counter(page).display("1"))))
#set text(font: "Libertinus Serif", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("#1f4e79"))
#let takeaway(body) = block(width: 100%, inset: 10pt, fill: rgb("#edf5f5"),
  stroke: (left: 2pt + rgb("#0f766e")), body)

#text(size: 23pt, weight: "bold", fill: rgb("#1f4e79"))[Robust Stability]

#text(size: 15pt)[From uncertain equations to certificates—and counterexamples]

A stable nominal simulation answers one question about one model. Robust stability asks
whether *every model in a specified family* remains internally stable under the same
controller. The hard part is not taking a larger frequency grid. It is defining that
family correctly, exposing its feedback paths, and knowing what each calculation proves.

#takeaway[
First reading: sections 1–7 derive the route

uncertain equations → cut uncertainty ports → nominal closed loop $M$
→ no boundary singularity → small gain → structured singular value $mu$.

Sections 8–10 explain certificates, witnesses, and advanced qualifications.
Sections 11–14 solve the four book exercises. Numerical searches are labelled as searches;
an upper bound exceeding one is *not* a destabilizing example.
]

= Begin with a physical family, not a block diagram

Suppose a damped oscillator obeys
$ m dot(v) = -c v-k x+u, quad dot(x)=v. $
The nominal mass is $m_0$, but measurements justify
$m=m_0(1+rho p)$, $p in RR$, $|p|<1$, $0<rho<1$. Dividing by the
uncertain mass immediately introduces a rational parameter dependence. Instead write
$ dot(v)=(-c v-k x+u)/m_0-rho w_Delta, quad
  z_Delta=dot(v), quad w_Delta=p z_Delta. $
Substitution recovers the physical equation exactly. The uncertainty is a *constant real
number*, not a new time-varying acceleration signal chosen independently at each instant.
The direct path from $w_Delta$ to $z_Delta$ is $-rho$, so its algebraic inverse needs
$1+rho p != 0$. The assumed mass interval makes precisely this true.

This is the central modeling move: put all known dynamics into an ordinary linear system,
and express the unknown part as $w_Delta=Delta z_Delta$. Always substitute the ports back
into the equations before trusting the resulting model.

#pagebreak()
= What is allowed to vary?

Normalize each uncertainty so its radius is one; put physical sizes in known weights.
These descriptions are different, even if they share a norm bound.

#table(columns: (1fr, 2.6fr), inset: 6pt, stroke: 0.4pt + luma(180),
 [Description], [What it asserts],
 [Real parameter $p I$], [One real constant acts in all repeated locations. For example, the same mass affects several equations.],
 [Complex scalar $delta I$], [A complex value at a frequency; typically the value of one stable dynamic scalar block, repeated identically. A constant complex parameter is a different, complex-coefficient model.],
 [Full block $Delta_j$], [Any matrix of the specified dimensions within its spectral-norm bound. It can couple all channels within that block.],
 [Mixed structure], [A block diagonal combination of real repeated, complex repeated, and full blocks. No couplings between different blocks are allowed.])

For an additive frequency-response envelope, write
$ H=G+W_1 Delta W_2. $
For instance $H=G+W Delta$ with $norm(Delta)_infinity<1$ describes stable dynamic error
whose magnitude is shaped by $W$. A high-pass weight permits more high-frequency error.
It is an assumption about missing dynamics, not a consequence of a few measurements.
The book's mass–spring example varies $m_1,m_2,k$; its mixed MIMO examples combine
constant parameters with such frequency-shaped errors. Their common language is
$ Delta_c = {op("diag")(p_1 I,...,p_(n_r) I,delta_1 I,...,delta_(n_c) I,
  Delta_1,...,Delta_(n_f)): norm(Delta_c)<1}. $
Here $p_j$ is real, $delta_j$ complex, and the full blocks are complex matrices.
For dynamic blocks the actual perturbation belongs to $bb(R)cal(H)_infinity$:
real-rational, proper, and with all poles strictly in the left half-plane.
Its values on $i omega$ must lie in the indicated value set. A proper real-rational
scalar that is real on the whole imaginary axis and stable must be constant: conjugate
symmetry makes it even; any finite pole would have a mirrored unstable pole. Thus the
real blocks in this description really do retain constant real parameters.

*Do not change the set while redrawing it.* Four independent bounded entries are not a
single norm-bounded $2 times 2$ block. Nor do two entries with $|d_1|,|d_2|<1$ describe
the same set as the column constraint $|d_1|^2+|d_2|^2<1$. Repetition, dimensions, and
realness are information, not cosmetic labels.

*Boundary convention throughout.* The book usually uses *open* balls. For a fixed proper
stable rational transfer, requiring its norm to be strictly less than one at every
$omega in RR union {infinity}$ is equivalent to $norm(Delta)_infinity<1$, by compactness
of the extended frequency axis. Replacing $<$ by $<=$ changes the robust-stability
endpoint: a marginal pole is not stable. We state the distinction explicitly below.

#pagebreak()
= Extract the ports from actual signal equations

An additive component $z=(G+W_1 Delta W_2)w$ is represented by
$ z=G w+W_1 w_Delta, quad z_Delta=W_2 w, quad w_Delta=Delta z_Delta. $
For input-multiplicative error $z=G(I+Delta)w$, use $z_Delta=w$ and
$z=G(w+w_Delta)$. For two-sided error $z=(I+Delta_1)G(I+Delta_2)w$,
use $z_2=w$, $v=G(w+w_2)$, $z_1=v$, $z=v+w_1$ and
$w_j=Delta_j z_j$. This order matters in MIMO systems.

A factor model $z=(G_1+Delta_1)(G_2+Delta_2)^(-1)w$ is clearer before inversion:
$ w=G_2 xi+w_2, quad z=G_1 xi+w_1, quad z_1=z_2=xi. $
If $G_2^(-1)$ is proper, eliminate $xi=G_2^(-1)(w-w_2)$ to form the nominal system.
Otherwise use an appropriate realization and check properness rather than silently
creating differentiators. Rational parameter dependence, as in the mass example, is
handled by the same implicit-equation trick.

For affine state-space dependence, factor each parameter coefficient as
$ mat(A_j,B_j;C_j,D_j)=mat(L_(1 j);L_(2 j))(R_(j 1)\ R_(j 2)). $
Then set $z_j=R_(j 1)x+R_(j 2)w$, $w_j=p_j z_j$, and add
$L_(1j)w_j$ to $dot(x)$ and $L_(2j)w_j$ to the output. The rank of the coefficient
is the needed repetition size in a minimal-rank factorization. One physical parameter
must not become several independent scalar blocks.

== A complete tracking-loop extraction

Let the measured signal obey $y=r-n-d-G u-W w_Delta$, with $u=K y$,
$z_Delta=u$, $w_Delta=Delta u$. To see what the uncertainty sees, set
$r=n=d=0$, cut $Delta$, and solve:
$ u=-K G u-K W w_Delta,
  quad M=-(I+K G)^(-1)K W. $
The minus sign comes from the signal equation; it is not a universal convention for $M$.
For input-multiplicative error the same calculation gives
$M=-(I+K G)^(-1)K G$ instead. In MIMO calculations preserve matrix order.

Multiple uncertain components—including implementation error in $K$—supply multiple
port pairs. Stack their equations and reconnect a block-diagonal $Delta$. Even if two
outputs are summed, keep their ports separate if their bounds are independent. The
block-diagonal structure records independence of allowed choices, not probabilistic
independence. Weights can be absorbed into the known interconnection; the resulting
system must still be a proper generalized plant admitting an internally stabilizing
controller. Arbitrary weights do not automatically preserve this property.

#pagebreak()
= Close the nominal controller before testing robustness

With uncertainty and controller disconnected, write
$ mat(z_Delta;z;y)=P mat(w_Delta;w;u), quad u=K y. $
Here $w,z$ are external/performance ports and $y,u$ controller ports. Closing a
*nominally internally stabilizing* $K$ gives a stable system
$ mat(z_Delta;z)=N mat(w_Delta;w), quad
  N=mat(M,N_12;N_21,N_22). $
Now restore $w_Delta=Delta z_Delta$. Elimination gives
$ z_Delta=(I-M Delta)^(-1)N_12 w, $
$ z=[N_22+N_21 Delta(I-M Delta)^(-1)N_12]w. $
Thus every new feedback difficulty is concentrated in the return difference $I-M Delta$.
Injecting disturbances at the uncertainty ports also exposes this inverse directly.
If $N$ and $Delta$ have stable realizations, a proper stable inverse certifies stability
of the enlarged interconnection. Scherer's Theorem 4.4 transfers this certificate to
the perturbed generalized plant with its controller ports.

== Three checks that must not be conflated

*Well-posedness:* simultaneous algebraic equations have a unique solution at each instant.
For $z_Delta=C x+D_M w_Delta$ and a static $Delta$, this means
$det(I-D_M Delta)!=0$. A singularity at infinity is a failure of properness, even if
no finite-frequency resonance is visible. For the uncertain plant before closing $K$,
the book additionally requires
$ det(I-P_11(infinity)Delta_c)!=0 quad "for every allowed value" Delta_c. $
It is automatic if $P_11$ is strictly proper. For normalized open structured balls it
can itself be tested by $mu(P_11(infinity))<=1$.

*Nominal internal stability:* at $Delta=0$, all internal modes decay. Stable $w$-to-$z$
behavior alone is insufficient: $dot(x)=x$, $z=0$ has a zero transfer but an unstable
state. For a physical realization inspect the full closed-loop state matrix, not a
transfer function after `minreal`. Book-style input/output internal stability uses
independent injections at controller ports; equivalence to all realization poles needs
the usual stabilizability/detectability qualifications.

*Robust internal stability:* these requirements hold for every allowed perturbation.
Nominal stability cannot be replaced by a frequency-norm plot: $1/(s-1)$ has a bounded
imaginary-axis magnitude but is unstable. Always establish the nominal premise first.

#pagebreak()
= Why the imaginary axis is enough: a homotopy proof

Assume $M$ is proper and stable, all $Delta$ are proper stable real-rational, and the
value set $cal(D)_c$ is *star-shaped about zero*: $t Delta_c in cal(D)_c$ for
$0<=t<=1$. Suppose
$ det(I-M(i omega)Delta_c)!=0
  quad (Delta_c in cal(D)_c,\ omega in RR union {infinity}). $ <eq:boundary>
Then $(I-M Delta)^(-1)$ is proper and stable for every allowed $Delta$.
The statement reduces a family of dynamic feedback problems to matrix nonsingularity;
it does *not* reduce the frequency continuum to a finite grid.

Here is the finite-dimensional proof, including the assumption that prevents roots
escaping through infinity. Fix one allowed $Delta$ and realize the stable product as
$ M Delta=C(s I-A)^(-1)B+D, quad A " Hurwitz". $
For every $t in [0,1]$, the infinity case of @eq:boundary makes $I-t D$ invertible.
Define the continuous matrix family
$ A(t)=A+B(I-t D)^(-1)t C. $
The block determinant identity yields
$ det(I-t M(s)Delta(s))
  =det(I-t D) det(s I-A(t))/det(s I-A). $ <eq:homotopy>
At $t=0$, $A(0)=A$ is Hurwitz. If the inverse at $t=1$ were unstable, then because
the denominator has no closed-right-half-plane zeros, $A(1)$ would have an eigenvalue
there. A continuous finite matrix family has continuous eigenvalues as a multiset;
equivalently its spectral abscissa is continuous. Its first exit from the Hurwitz region
must therefore have an eigenvalue $i omega_0$. At that point @eq:homotopy contradicts
@eq:boundary with the allowed value $t Delta(i omega_0)$.

This proof uses a *stable realization of the product*, not an informal claim that
arbitrary transfer zeros cannot jump. On the compact interval the inverse of $I-t D$
is bounded; a pole cannot disappear to infinity unnoticed. It also explains why
star-shapedness matters: every intermediate feedback loop must remain in the family.
Convexity is sufficient but stronger than needed. Frequency-dependent star-shaped
value sets work as well; use the appropriate set at each frequency.

The book's related Lemma 4.6 runs this argument backward: if a stable $P$ has
$norm(P)_infinity<=1$, a proper controller $K$ has no imaginary-axis poles and
$norm(K(i omega))<1$ including infinity, and $K$ internally stabilizes $P$, then
$K$ itself is stable. The strict product bound prevents boundary crossings while
the feedback is removed. The controller is not assumed stable in that lemma;
the internally stable closed loop supplies the starting point. This is a proof
outline of the reverse homotopy, not a second proof of the lemma.

#takeaway[
The result is a sufficient robust-stability test for a general extracted plant.
Nonsingularity of the uncertainty-port inverse is not automatically a necessary test
for internal stability of every *reduced* perturbed plant: extraction can introduce
redundant channels or cancellations. A proposed destabilizer must be checked against
the actual interconnection. Section 10 returns to this qualification.
]

#pagebreak()
= Full-block uncertainty: derive small gain and its sharpness

The easiest way to exclude $1$ from the spectrum of $M Delta_c$ is
$ rho(M Delta_c)<=norm(M Delta_c)<=norm(M)norm(Delta_c)<1. $
Here $norm(dot)$ is the spectral norm, not the Frobenius norm. Thus for open full-block
uncertainty $norm(Delta)_infinity<r$, stability follows from
$ norm(M)_infinity<=1/r. $ <eq:sg>
The strictness is supplied by the open uncertainty ball. This is the small-gain theorem;
it is also sufficient for any smaller structured family inside that ball.

Why is it exact for one complex full block? At a fixed frequency let
$M v=sigma u$, with unit left/right singular vectors. Set
$ Delta_0=v u^ast/sigma. $
Then $M Delta_0 u=u$ and $norm(Delta_0)=1/sigma$. Thus no larger matrix-value ball can
exclude singularity. At a positive finite frequency, stable real-rational all-pass
interpolation realizes the required complex vector action with this norm. At zero or
infinity a real matrix singular-vector choice suffices for real $M$.
Consequently, for stable rational full-block dynamic errors,
@eq:sg is necessary and sufficient for a proper stable return-difference inverse
for *all errors in the open ball*. This is not a theorem about all errors being real
constants, nor about arbitrary structured blocks.

For scalar interpolation, if $d_0=rho e^(i theta)$ is needed at $omega_0>0$, try
$ delta(s)=epsilon rho (s-beta)/(s+beta), quad beta>0, quad epsilon in {-1,1}. $
Its magnitude is $rho$ at every frequency. Choose the sign and $beta$ to match the phase;
for $epsilon=1$ and $0<theta<pi$, $beta=omega_0 tan(theta/2)$. A complex constant
$d_0$ is *not* an admissible real-rational perturbation by itself. Full matrix
interpolation generally needs vector/component all-pass factors, not one universal
scalar factor multiplying an arbitrary complex matrix.

== The boundary is a mathematical choice

For the *closed* full-block ball $norm(Delta)_infinity<=r$, the corresponding exact
test is $norm(M)_infinity<1/r$. Equality permits the singular-vector destabilizer at
the peak. As a scalar example, $M=1/(s+1)$ and $delta=1$ give a pole at zero.
All real constants $|delta|<1$ instead give the stable pole $-1+delta$.
The open family is robustly stable at radius one, but lacks a uniform decay margin as
$delta$ approaches one. “Robust for the open ball” does not mean “uniformly separated
from instability on its closure.”

#pagebreak()
= Structure changes the answer: an asymmetric worked example

Consider the stable two-state realization
$ dot(x)=-x+w_Delta, quad z_Delta=T x, quad
  T=mat(0,4;1/4,0), quad M(s)=T/(s+1). $
If $Delta=op("diag")(delta_1,delta_2)$, then
$ det(I-M(s)Delta)=1-delta_1 delta_2/(s+1)^2. $
For real constant errors the *full* state matrix is $-I+Delta T$, with poles
$ -1 plus.minus sqrt(delta_1 delta_2). $
Independent complex dynamic blocks of radii $r_1,r_2$ have the same open-ball robust
boundary $r_1 r_2=1$: below or on this radius boundary, the product of actual open-ball
errors is strictly smaller than one; above it real positive constants already witness
failure. Testing the two blocks separately would miss the entire interaction.

With equal radii, the structured margin is one. Treating the same channels as one
arbitrary full block gives $norm(M)_infinity=4$ and margin $1/4$ instead. The full-block
witness $Delta=mat(0,0;1/4,0)$ has norm $1/4$ and produces actual poles $0,-1$; it is
*not diagonal*. The conservative answer came from allowing a new physical coupling.

#figure(image("assets/asymmetric.svg", width: 100%), caption: [Computed by
 `scripts/teaching.m`. Left: full-block gain versus diagonal-complex $mu$.
 Right: unequal diagonal radius boundary; the stable side is below the hyperbola.])

At the stable corner $(delta_1,delta_2)=(0.2,4)$ the poles are
$-0.105572809,-1.894427191$. At $(0.3,4)$ they are
$+0.095445115,-2.095445115$: a verified unstable example, not an inference from an upper
bound. For *open* radii $(0.3,4)$ this corner is excluded, but slightly smaller constants
still have product above one and are unstable. The unit corner $(1,1)$ is marginal;
it belongs to the closed unit ball, not the open one.

This example also explains weighting. Unequal radii mean $Delta=R hat(Delta)$,
$R=op("diag")(r_1,r_2)$. Test $M R$ with normalized $hat(Delta)$, or the equivalent
structured $R M$ test by determinant cyclicity. Do not compare an unweighted plot to
different block radii.

#pagebreak()
= The structured singular value measures the first singularity

Let $cal(S)$ be the *unbounded* block-structured linear space (real repeated, complex
repeated, and full blocks). Define
$ mu_cal(S)(M_c)=
  cases(0 & "if no structured singularizer exists",
  (min_{Delta_0 in cal(S),\ det(I-M_c Delta_0)=0} norm(Delta_0))^(-1) & "otherwise"). $
The minimum is attained when finite: the singular set is closed and a minimizing
sequence is bounded in a finite-dimensional space. The open normalized value set is
$cal(D)_c={Delta_c in cal(S):norm(Delta_c)<1}$.

Writing $r_*=1/mu$ (with $1/0=infinity$), every structured perturbation of norm
*strictly less than* $r_*$ leaves $I-M_c Delta_c$ nonsingular. A minimum-norm
singularizer has norm *equal to* $r_*$ and lies on the boundary, not inside the open
radius-$r_*$ ball. Thus
$ det(I-M_c Delta_c)!=0 quad "for all" Delta_c in cal(D)_c
  quad arrow.l.r.double quad mu_cal(S)(M_c)<=1. $
For the closed normalized ball the corresponding test is $mu<1$.
The book subscripts $mu$ by the normalized set; this note uses its structure $cal(S)$
to avoid confusing the open set with the unbounded minimization domain.

The physical interpretation is now immediate. For the book's structured dynamic class,
the proper-stable-inverse test is
$ mu_cal(S)(M(i omega))<=1 quad "for all" omega in RR union {infinity}. $
For a radius $r$, replace one by $1/r$. The common uncertainty inflation margin is
$(sup_omega mu_cal(S)(M(i omega)))^(-1)$; the supremum itself is the *inverse* margin.
For a general extracted plant this remains a sufficient robust internal-stability
certificate, with the qualification of section 10 on necessity.

== Three exact special cases, not three interchangeable norms

A single real repeated scalar block gives $mu=rho_RR(M_c)$, the largest modulus of
a *real* eigenvalue (zero if none). A single complex repeated scalar block gives
$mu=rho(M_c)$. A single full block gives $mu=sigma_max(M_c)$.
For the diagonal-complex asymmetric example,
$mu(M(i omega))=1/sqrt(1+omega^2)$, whereas $norm(M(i omega))=4/sqrt(1+omega^2)$.

Enlarging the allowed set can only increase $mu$. On compatible square block structures,
$rho_RR(M_c)<=mu(M_c)<=norm(M_c)$; if there are no real blocks,
$rho(M_c)<=mu(M_c)$. A complex spectral radius need not be a lower bound when real
blocks are present. At endpoints $omega=0,infinity$, real-rational errors take real
values; the exact structured dynamic theorem uses a limiting small-$mu$ argument when
a complex value witness cannot be interpolated there directly.

#pagebreak()
= D-scalings: why an upper certificate can be conservative

If an invertible $D$ commutes with every allowed square uncertainty block, then
$ det(I-M_c Delta_c)=det(I-D^(-1)M_c D Delta_c). $
Apply small gain in these new internal coordinates:
$ mu(M_c)<=U(M_c):=inf_D norm(D^(-1)M_c D). $ <eq:dscale>
Changing coordinates does not add a physical perturbation. It changes the norm used to
prove that *none* can close a unit-gain feedback path.
For repeated scalar blocks, the commuting $D$ blocks can be arbitrary invertible
matrices. For full uncertainty blocks they must be scalar multiples of the identity.
This is the opposite pattern from the uncertainty structure.

For the asymmetric example take $D=op("diag")(1,t)$:
$ D^(-1)T D=mat(0,4t;1/(4t),0). $
At $t=1/4$ both off-diagonal magnitudes become one, so the scaling upper bound agrees
with the directly derived $mu=1$. Equalizing the two directions measures the closed
cycle, not just the large one-way gain of four.

== Why this becomes an LMI, not a search over arbitrary matrices

For fixed $gamma>0$, $norm(D^(-1)M_c D)<gamma$ is equivalent to
$ M_c Q M_c^ast<gamma^2 Q, quad Q=D D^ast>0. $ <eq:lmi>
The structure of $Q$ is positive Hermitian full blocks on repeated uncertainties and
positive scalar identity blocks on full uncertainties. At *fixed* $gamma$ this is
linear in $Q$; bisection on $gamma$ gives the infimum upper bound. Joint minimization
in $(gamma,Q)$ is not itself a linear matrix inequality. Numerical solver residuals
and a strict feasibility margin matter. An infimum need not be attained by a finite
well-conditioned scaling.

#takeaway[
There are four different objects:

• A sampled frequency plot: values at finitely many points, not a continuum proof.
• $mu$: the exact smallest structured singularizing size, inverted.
• A D-scaling upper bound $U$: if valid over all frequencies and $U<=1$, it certifies
  the open uncertainty family. If $U>1$, the result is inconclusive.
• A lower witness $Delta_0$: its structure, norm, and singularity residual supply
  concrete evidence. After dynamic realization and a full-loop pole check, it may
  prove actual robust-stability failure.
]

#pagebreak()
= Advanced qualifications: real multipliers, continuity, cancellations

== Why real uncertainty permits stronger certificates

A Hermitian separator $Pi$ proves nonsingularity if
$ mat(Delta_c;I)^ast Pi mat(Delta_c;I)>=0, quad
  mat(I;M_c)^ast Pi mat(I;M_c)<0 $
for all allowed $norm(Delta_c)<1/gamma$. Indeed a singularity gives
$x=M_c y$, $y=Delta_c x$, $x!=0$; the same vector $(y,x)$ would have both nonnegative
and negative quadratic form. This is a complete proof of sufficiency.

For square blocks the book chooses
$ Pi=mat(-gamma^2 Q,S;S^ast,Q), $
where $Q$ has the commuting positive structure above, and $S$ has skew-Hermitian blocks
only on *real repeated* uncertainties. On a real block, the cross term is
$p S+p S^ast=0$; the remaining form is $(1-gamma^2 p^2)Q>=0$.
This adds valid real-parameter information that ordinary D-scaling discards. On complex
blocks set $S=0$. For fixed $gamma$ the separator test is again an LMI. Rectangular
full blocks can be handled by dimensionally appropriate graph separators; ordinary
commuting square similarity scalings are not a formula for that case.

The deep exactness theorem (book Theorem 4.20) says the optimal *extended* multiplier
bound equals $mu$ if $2(n_r+n_c)+n_f<=3$. This is a sufficient complexity condition,
not an “if and only if” for any particular matrix. Above it gaps can exist, but need
not exist. With real blocks the theorem refers to the extended bound, not plain
D-scaling. The book's final three-structure example contrasts a full-block case with
repeated-complex and repeated-real cases whose computed upper/lower curves separate.
This exactness theorem is quoted, not proved here.

== Sampling can miss more than a narrow smooth peak

For one real repeated block and $M_m=mat(1,m;-m,1)$, $mu(M_m)=0$ when $m!=0$ but
$mu(M_0)=1$. Real eigenvalues disappear under an arbitrarily small nonreal split.
Thus real-$mu$ can jump, and a frequency grid can miss an isolated dangerous frequency.
With no real blocks $mu$ is continuous, but a finite plot still cannot exclude an
unsampled peak. Use analytic frequency bounds, interval enclosures, or a validated
global method for a theorem-level claim; refinement alone is numerical evidence.

== A singularity is first a witness at the uncertainty ports

At $omega_0>0$, keep the real parameter blocks constant; interpolate complex scalar
blocks by all-pass factors. For a full block with kernel-vector pieces $u_j,v_j$,
only $Delta_j(i omega_0)u_j=v_j$ is needed, with norm at most
$norm(v_j)/norm(u_j)$. If $u_j=0$, then $v_j=0$ and choose the zero block.
Endpoint interpolation and the general full-block construction require additional
arguments (book §§4.8.3, 4.9.3); this is a *proof outline*, not their full proof.
Finally check the unreduced interconnection. Scherer §4.7.4 gives rank conditions
ensuring that a finite-frequency singularity survives reduction; without them hidden
cancellation is possible. We use full state-matrix pole calculations for the examples
instead of asserting necessity for every arbitrary extraction.

#pagebreak()
= Exercise 1: build the book loop, then measure its margins

Book pp. 133–134 continue the Figure-23 interconnection on p. 65. Its components are
$ G_1=1, quad G_2=1/(s-1), quad G_3=(s+1)/(s^2+1), quad
  G_4=0, quad G_5=1/s, quad G_6=1, quad G_7=(s+2)/((s+3)(s-2)). $
The six-state $1 times 2$ controller on p. 133 is transcribed verbatim in `scripts/ex1.m`.
For reproducibility without the diagram, its input is $(y_1,y_2)$ and its output $a$,
and the actual equations with *both* errors cut out are
$ e=w-z, quad q=e+W_1 w_1, quad z=G_7 a, quad W_1=(s-2)/(s+2), $
$ x_2=G_2(q+w_2), quad y_1=x_2-G_5 a, quad y_2=G_3 q-G_5 a, $
$ a=K_1 y_1+K_2 y_2, quad z_1=e, quad z_2=x_2, quad
  w_1=Delta_1 z_1, quad w_2=delta_2 z_2. $
Thus $delta_2=p-1$ moves the pole in $G_2$ from one to $p$.
Here $x_2$ denotes the output/state of the scalar realization
$dot(x)_2=x_2+q+w_2$. The nominal loop, retaining all plant/controller/weight states,
has spectral abscissa $-0.149616$.

An independent elimination checks the state-space assembly. Define
$ H=(K_1 G_2+K_2 G_3)/(1+(K_1+K_2)G_5), quad
  J=K_1 G_2/(1+(K_1+K_2)G_5). $
Then $a=H q+J w_2$, so
$ M=mat(-G_7 H W_1/(1+G_7 H),-G_7 J/(1+G_7 H);
 G_2 W_1/(1+G_7 H),G_2(1-G_7 J/(1+G_7 H))). $ <eq:ex1M>
Both $z_1,z_2$ are state-dependent, so $M(infinity)=0$: there is *no* direct
$w_2$-to-$z_1$ term. A spurious direct term would leave the separate one-block tests
unchanged but corrupt their joint trade-off.

== Dynamic versus real additive error in $G_1$

The peak of $|M_11(i omega)|$ is $7.55237734$ at
$omega=1.56190800$, giving the numerical open dynamic radius $0.13240864$.
For a real constant, $1/M_11(i omega)$ must be real. Search the real-axis crossings,
including zero and infinity, and choose the smallest magnitude: the radius is
$0.18049401$ at $omega=1.18738012$, with a *positive* critical constant.
The Nyquist interpretation is that real constants can only move along real rays,
whereas dynamic errors can supply phase at the peak frequency.

The dynamic boundary witness is approximately
$ Delta_1(s)=0.13240864 (s-1.3050)/(s+1.3050). $
Using unrounded coefficients, the full augmented state matrix has a conjugate pair
on the axis at $plus.minus 1.56190800 i$. The real constant $Delta_1=0.18049401$
similarly produces $plus.minus 1.18738012 i$. These boundary witnesses are not members
of the corresponding *open* critical-radius balls. They show where asymptotic stability
is first lost and why any larger radius cannot work. The figures/searches give numerical
margin estimates, not formal global certificates.

#pagebreak()
== Exercise 1(a–b): pole errors and unequal budgets

For a real pole perturbation, the first relevant real-axis crossing of $M_22$ gives
$ delta_2=-0.42560843, quad p=0.57439157, quad omega=0.26342726. $
Rebuilding $G_2=1/(s-p)$ and closing the full controller confirms a marginal pair at
$plus.minus 0.26342726 i$. Allowing a *constant complex pole shift* instead gives the
numerical radius $1/norm(M_22)_infinity=0.24976616$, since
$norm(M_22)_infinity=4.00374494$. This is a complex-coefficient plant family, not the
same as a real physical pole family. Real-rational dynamic scalar errors can reproduce
the interior-frequency critical value, but need a dynamic realization rather than a
constant complex coefficient. There is no set inclusion between unequal-radius real
intervals and complex disks merely from comparing their radii.

For part (b), let $Delta_1$ be dynamic of radius $r_1$ and $delta_2$ a real constant
of radius $r_2$. Expanding the two-by-two determinant gives the critical first-block value
$ d_1(omega,d_2)=(1-M_22 d_2)/
  (M_11(1-M_22 d_2)+M_12 M_21 d_2). $ <eq:trade>
For each fixed $r_2$, minimize $|d_1|$ over $omega$ and real $|d_2|<r_2$;
the result bounds the admissible $r_1$. At a vanishing denominator use the original
determinant, not a floating-point division. Pure second-block crossings are included
separately. For equal radii, minimize
$ max(|d_1(omega,d_2)|,|d_2|). $
The script samples 20,000 frequencies and a real-parameter grid, then independently
refines the equal-radius boundary by multistart local search. This is a *numerical*
boundary search, not a certified global optimization.

#figure(image("assets/ex1.svg", width: 100%), caption: [Exercise 1 computations.
 Left: return gain for the additive uncertainty. Right: sampled trade-off for one
 dynamic block and one real pole shift, with the direct term corrected to zero.])

Local refinement gives a common radius $0.1059211491$ at $omega=1.6170771252$
and $delta_2=+0.1059211491$ (not the inherited $0.108259$). The dynamic witness is
$Delta_1(s)=0.1059211491(s-1.3960924657)/(s+1.3960924657)$.
Representative sampled pairs are $(r_1,r_2)=(0.02,0.4022)$,
$(0.05,0.3346)$, $(0.08,0.2112)$, $(0.10,0.1298)$, and $(0.13,0.0096)$.
Endpoints recover the separate margins $(0,0.42560843)$ and $(0.13240864,0)$.
The allowable pole error falls as dynamic error consumes the feedback margin.
The script also constructs an all-pass $Delta_1$ and real $delta_2$ from the refined
joint boundary and prints *all* augmented closed-loop poles. This distinguishes an
actual marginal closed loop from a determinant-only numerical candidate.

#pagebreak()
= Exercise 2: rationally perturbed matrices, with well-posedness retained

Let $Delta=op("diag")(delta_1,...,delta_m)$ be real with $norm(Delta)<1$, and
$ A_Delta=A+B Delta(I-D Delta)^(-1)C, quad
  Sigma(s)=D+C(s I-A)^(-1)B. $
The request is to test nonsingularity, continuous-time stability, and discrete-time
stability of $A_Delta$, *and in each case* nonsingularity of $I-D Delta$.
All $mu$ values here use the real diagonal structure.

The common derivation uses the block matrix
$ cal(B)(s)=mat(s I-A,-B Delta;-C,I-D Delta). $
Taking its determinant by the two Schur complements gives, wherever defined,
$ det(s I-A_Delta)det(I-D Delta)
  =det(s I-A)det(I-Sigma(s)Delta). $ <eq:detid>
The identity extends as a polynomial/rational identity, but it does not define
$A_Delta$ at a singular $I-D Delta$. Dropping that condition is an invalid cancellation.

== (a) Both matrices nonsingular

At $Delta=0$, necessarily $A$ is nonsingular. At $s=0$, @eq:detid then proves the test
$ det(A)!=0, quad mu(D)<=1, quad mu(D-C A^(-1)B)<=1. $
The middle condition is essential. For example take scalar $A=1$, $B=2$, $C=1$,
$D=2$. Then $D-C A^(-1)B=0$, so its $mu$ is zero, yet $I-D Delta=0$ at
$Delta=1/2$, inside the open unit interval. The rational expression
$A_Delta=1/(1-2 Delta)$ is undefined there. This counterexample corrects the inherited
test, which omitted well-posedness in part (a).

== (b) All eigenvalues in the open left half-plane

The answer is
$ A " Hurwitz", quad mu(Sigma(i omega))<=1
  quad "for every" omega in RR union {infinity}. $
The endpoint gives $mu(D)<=1$. Necessity follows from @eq:detid and nominal stability.
For sufficiency fix any real $Delta$ and use $t Delta$, $0<=t<=1$: well-posedness keeps
$A_(t Delta)$ continuous, and a first unstable eigenvalue must cross the imaginary axis,
contradicting the determinant test. This proof uses *constant real parameters* throughout;
it does not replace them with independently selectable frequency values.

== (c) All eigenvalues in the open unit disk

Replace the imaginary axis by the unit circle, but retain the separate infinity test:
$ rho(A)<1, quad mu(D)<=1, quad
  mu(Sigma(z))<=1 quad "for all" |z|=1. $
Along the same homotopy, a continuous eigenvalue leaving the disk must cross its circle.
The circle does not contain infinity; it cannot by itself ensure that $A_Delta$ is
defined. `ex23.m` numerically checks @eq:detid at a generic complex $s$ and at zero.
Those checks detect sign/transcription errors; the displayed determinant argument,
not a random test, establishes the identity and the three tests.

#pagebreak()
= Exercise 3: a complete rank-one calculation

For real $a,b in RR^m$, retain the real diagonal structure of Exercise 2. The determinant
lemma says
$ det(I-a b^T Delta)=1-b^T Delta a=1-sum_j a_j b_j delta_j. $
Let $c_j=a_j b_j$ and $L=sum_j |c_j|$. If the determinant vanishes,
$ 1=abs(sum_j c_j delta_j)<=L max_j |delta_j|. $
Thus every singularizer has norm at least $1/L$. If $L>0$, equality is attained by
$ delta_j=op("sign")(c_j)/L. $
Zero products may be assigned zero, so there is no need to assume every entry is
nonzero. We have derived, not estimated,
$ mu(a b^T)=sum_j |a_j b_j|. $
If $L=0$, the determinant is identically one for all diagonal perturbations and $mu=0$.

For $a=(1.3,-2.1,0.4)^T$ and $b=(-0.7,1.1,2)^T$,
$c=(-0.91,-2.31,0.8)^T$ and $L=4.02$. The explicit singularizer is
$ Delta_*=op("diag")(-1,-1,1)/4.02, quad norm(Delta_*)=0.248756219. $
The script's independently constrained numerical search agrees to eight decimals.
Unlike a bare reported lower bound, the formula identifies which signs cooperate.
The answer is not $max_j |a_j b_j|$: the perturbation is spread over all coordinates.
For the open radius-$1/4.02$ ball the singularizer is excluded, so nonsingularity
still holds for every member; for the corresponding closed ball it fails.

== A practical workflow after the derivations

+ State the physical family, its real/dynamic/repeated/full structure, and whether
  the bounds are open or closed. An inaccurate family invalidates a perfect computation.
+ Derive ports by substitution. Check dimensions, signs, feedthrough, and weights.
+ Verify nominal internal stability and plant/controller well-posedness before computing
  frequency gains. Keep the full physical state realization for pole checks.
+ Select a full-block gain test only if that is the intended family. Otherwise use
  structure, with D or extended real-multiplier upper certificates.
+ Treat frequency samples as reconnaissance. Include zero and infinity; refine peaks
  and real-axis crossings, and state how the continuum is controlled—or that it is not.
+ If an upper bound exceeds one, do not announce instability. Seek a lower witness,
  verify its structure/norm/singularity, realize it dynamically if required, and close
  the actual loop. Report marginal versus strictly unstable poles accurately.

This workflow applies equally to the book's SISO tracking examples, coupled real MIMO
actuator errors, and multiple dynamic uncertainties. Single-block experiments reveal
individual sensitivities; only the joint structured test addresses simultaneous errors.

#pagebreak()
= Exercise 4: an upper bound that is exact here, and one that is not

Let
$ M_c=mat(12,-3,2;-1,7,8;5,3,-1), quad Delta=op("diag")(Delta_1,delta_2). $
Here $Delta_1 in CC^(2 times 2)$ and $delta_2 in CC$.
There are two full complex blocks. A commuting scaling is $D=op("diag")(1,1,t)$,
$t>0$. Partition $M_c=mat(M_1,M_12;M_21,M_2)$ and define
$ M(t)=mat(M_1,t M_12;M_21/t,M_2)=D^(-1)M_c D. $
With $n_f=2$, $n_r=n_c=0$, Theorem 4.20 guarantees that the infimum spectral-norm
scaling bound equals $mu$. The restriction in part (a) requires no `mu` routine:
compute $sigma_max(M(t))=sqrt(max op("eig")(M(t)^ast M(t)))$, scan $t$ in a loop,
and refine the search interval; this part uses no optimization toolbox.

The result is $mu=13.07548948$ at $t approx 1.322549$.
These are numerical decimals, not a rigorous optimizer enclosure. `teaching.m`
independently constructs a two-block singularizer of norm $0.0764789824$: lower bound
$13.0754878$, residual $3 dot 10^(-16)$. The randomized lower search in `ex4.m`
is only a heuristic; theoretical exactness comes from the two-full-block theorem.

#figure(image("assets/scaling.svg", width: 55%), caption: [Computed scaling curves.
 The spectral optimum is tight by the two-full-block theorem; minimizing the larger
 Frobenius norm solves a different optimization and gives a looser certificate.])

For part (b), write $alpha=norm(M_12)_F$, $beta=norm(M_21)_F$, and
$c=norm(M_1)_F^2+norm(M_2)_F^2$. Direct expansion gives
$ norm(M(d))_F^2=c+alpha^2 d^2+beta^2/d^2. $
If $alpha,beta>0$, differentiation or arithmetic–geometric mean gives
$ d_*=sqrt(beta/alpha), quad inf_(d>0)norm(M(d))_F=sqrt(c+2 alpha beta). $
Here $alpha=sqrt(68)$, $beta=sqrt(34)$, $c=204$, so
$d_*=2^(-1/4)=0.84089642$ and the upper bound is $17.32531449$.
Since $sigma_max<=norm(dot)_F$, this bounds—but need not equal—$mu$.
If exactly one off-diagonal norm vanishes, the infimum $sqrt(c)$ is approached only
as $d->0$ or $d->infinity$. If both vanish, every $d>0$ is optimal.

#pagebreak()
= Source map, reproducibility, and scope of the claims

This note follows Carsten W. Scherer, _Theory of Robust Control_ (Stuttgart, 2018),
Chapter 4, printed/PDF pp. 66–135, in the supplied authoritative PDF. No external
web sources or software installations are needed. The chapter's progression is:

#table(columns: (1fr,2.8fr), inset: 6pt, stroke: 0.4pt + luma(180),
 [Book pages], [Where the material appears here],
 [66–85], [Sections 1–3, 7: tracking, real MIMO interaction, parametric/dynamic/mixed/full uncertainty, normalized value sets.],
 [85–98], [Sections 3–4: subsystem extraction, joint block-diagonal structure, generalized plant, weights, robust versus nominal stability.],
 [98–106], [Sections 4–5, 10: stable inverse, homotopy, boundary reduction, and the cancellation qualification.],
 [106–122], [Sections 6–8, 10: scalar and full-block tests, structured singular value, block weights, and dynamic witnesses.],
 [122–133], [Sections 8–10, 14: monotonicity, continuity, lower/upper bounds, LMI/scaling/separator construction, and low-complexity exactness.],
 [133–135], [Sections 11–14: all four exercises, including both additional parts of Exercise 1.])

Run from the repository root:
```sh
QT_QPA_PLATFORM=offscreen octave --no-gui \
  Control/robust-control-04-robust-stability/scripts/ex1.m
octave --no-gui Control/robust-control-04-robust-stability/scripts/ex23.m
octave --no-gui Control/robust-control-04-robust-stability/scripts/ex4.m
QT_QPA_PLATFORM=offscreen octave --no-gui \
  Control/robust-control-04-robust-stability/scripts/teaching.m
typst compile --root . \
  Control/robust-control-04-robust-stability/robust-control-04-robust-stability.typ
```

The executable files contain the controller matrices, state assemblies, search grids,
all-pass constructions, determinant checks, lower-witness construction, and all three
computed SVG figures. `summary.md` records the actual run and layout checks.

*Proof status.* The signal eliminations, stable-product homotopy, small-gain sufficiency,
rank-one formula, determinant tests for Exercise 2, commuting-scaling/LMI derivation,
separator sufficiency, and Frobenius minimization are derived here. Full-block matrix
interpolation, endpoint small-$mu$ arguments, and the extended-bound exactness theorem
are outlined or quoted, not fully proved. The endpoint reference named by the book is
A. L. Tits and M. K. H. Fan, “On the small-$mu$ theorem,” _Automatica_ 31 (1995),
1199–1201. General cancellation rank conditions remain in book §4.7.4; we do not
claim a necessary test for every redundant extracted plant.

*Numerical status.* Exercise 1 margins and the trade-off are grid/local-refinement
estimates, supported by independent signal calculations and unreduced pole witnesses,
not certified global bounds. Exercise 4 has a theoretical exactness result for its
variational formula plus numerical upper/lower agreement. No sampled plot in this
note is promoted to a proof over a continuous frequency or parameter domain.
