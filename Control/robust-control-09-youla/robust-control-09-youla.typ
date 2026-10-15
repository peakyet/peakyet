// Standalone: typst compile --root . <this file> <same stem>.pdf
#set document(title: "Youla Parametrization: design the closed loop first", author: "Amp")
#set page(paper: "a4", margin: (x: 24mm, y: 21mm),
  header: text(size: 9pt, fill: rgb("#5b6470"))[Robust control · Chapter 9],
  footer: context align(right, text(size: 9pt, counter(page).display("1"))))
#set text(font: "Libertinus Serif", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("#1f4e79"))
#let takeaway(body) = block(width: 100%, inset: 10pt, fill: rgb("#edf5f5"),
  stroke: (left: 2pt + rgb("#0f766e")), body)

#text(size: 23pt, weight: "bold", fill: rgb("#1f4e79"))[Youla Parametrization]

#text(size: 15pt)[Design the closed loop first; recover the controller second]

Choosing controller coefficients directly has an awkward side effect: a small change can
move a closed-loop pole into the right half-plane. Youla parametrization changes the
design variable. Instead of guessing a stabilizing $K$, choose a *stable transfer
function* $Q$ and recover a controller that stabilizes the plant automatically.

The controller is generally nonlinear in $Q$. The useful surprise is that the
*closed-loop transfer matrices are affine in $Q$*. This note derives that fact in the
easiest setting first, gives concrete examples, and only then introduces the algebra
needed for unstable plants.

#takeaway[
  First reading: sections 1–5 give the idea and the scalar construction. Sections 6–7
  connect it to the book's matrix and state-space formulas. Sections 8–9 solve the two
  exercises. Do not start by memorizing eight coprime-factor symbols.
]

= Start with a stable scalar plant and a physical meaning for Q

For now $g$ is proper and stable. Use ordinary *negative-feedback tracking*:
$ e=r-y, quad u=k e, quad y=g u. $ <eq:tracking>
Lower-case symbols mean scalar transfer functions. A transfer is in
$cal(R H)_infinity$ when it is real-rational, proper, and has all poles strictly in
the open left half-plane. In this note, “stable” always has that strict meaning.

Eliminate the signals:
$ u=k(r-g u) quad ==> quad u=k/(1+g k) r. $
Now give that *closed-loop* map a name:
$ Q:=k/(1+g k)=T_(u r). $ <eq:qmeaning>
Internal stability requires this map to be stable. Solve for $k$ rather than guessing it:
$ Q(1+g k)=k quad ==> quad k=Q/(1-g Q). $ <eq:stableyoula>
That is the stable-plant Youla formula. It is not an unexplained fractional trick:
we chose the desired reference-to-control map and solved the feedback equations backwards.

#pagebreak()
= Why every stable Q works — and what “works” means

Substitute @eq:stableyoula into the actual closed-loop maps:
$ S:=1/(1+g k)=1-g Q, quad T:=g k/(1+g k)=g Q, $
$ k S=Q, quad g S=g(1-g Q). $ <eq:fourmaps>
All four maps are proper and stable because $g$ and $Q$ are. Notice that the possibly
unstable denominator $1-g Q$ of the controller disappeared from the closed-loop maps.

These four maps matter because internal stability is more than “$r -> y$ is stable”.
Inject independent disturbances $d_u$ at the plant input and $d_y$ at the measurement:
$ y=g(u+d_u), quad u=k(r-y-d_y). $
Then $u=Q(r-d_y)-g Q d_u$ and
$y=g Q(r-d_y)+g(1-g Q)d_u$. Thus disturbances cannot expose a hidden unstable
input–output mode. As usual, use minimal plant and controller realizations, or explicitly
check any extra unobservable/uncontrollable states: transfer-function identities cannot
stabilize an unstable state that is absent from the transfer model.

Conversely, every proper internally stabilizing controller gives a stable
$Q=k/(1+g k)$ by @eq:qmeaning, and the algebra recovers the same $k$. This is why the
formula describes *all* stabilizing controllers, not just a clever family of examples.

== The qualification: a realizable controller and a well-posed loop

If $g$ is strictly proper, every proper stable $Q$ gives a proper $k$, because
$1-g(infinity)Q(infinity)=1$. If $g$ has direct feedthrough, require
$ 1-g(infinity)Q(infinity) != 0. $ <eq:wellposed>
This ensures the inverse needed for the controller is proper and the feedback loop
has no algebraic singularity. Do *not* replace this condition by “$1-g Q$ must have a
stable inverse”. The latter would incorrectly exclude stabilizing controllers that
are themselves unstable.

For example, $g=1/(s+1)$ and $Q=2$ give
$ k=2(s+1)/(s-1), quad S=(s-1)/(s+1), quad k S=2. $
The controller has an unstable pole at $+1$, but the four internal closed-loop maps
are stable. Stabilization concerns the interconnected dynamics, not whether the
disconnected controller is stable. Requiring the controller itself to be stable is
the separate *strong stabilization* problem.

#takeaway[
  “Free stable Q” means stability is built into the design coordinates. It does not
  mean the resulting controller is stable, low-order, small-gain, or well performing.
]

#pagebreak()
= One running example: choose a response, recover a controller

Let $g(s)=1/(s+1)$. Choose
$ Q_a(s)=a/(s+a), quad a>0. $
This is a stable reference-to-control map with DC gain one. The Youla formula gives
$ k_a(s)=a(s+1)/(s(s+a+1)), $
while the closed-loop maps are immediately
$ T_a(s)=a/((s+1)(s+a)), quad S_a(s)=1-T_a(s). $
For $a=1$, the controller is $(s+1)/(s(s+2))$ and
$T_1=1/(s+1)^2$. The controller contains an integrator, but its feedback interconnection
is internally stable. A unit reference step gives
$ y(t)=1-(1+t)e^(-t), quad e(t)=(1+t)e^(-t). $
We did not tune poles of $k$ and then hope the loop was stable: stability followed
from the choice of $Q$.

#figure(image("assets/youla-response.svg", width: 100%),
  caption: [Computed unit-step outputs for three stable parameters $Q_a$. Increasing
    $a$ speeds the reference-to-control filter, but the fixed plant pole at −1 still
    limits the output. All three designs are internally stable by construction.])

== Why not simply demand any desired output transfer T?

Since $T=g Q$, asking for a target $m$ suggests $Q=m/g$. That candidate may be
unstable or improper. A nonminimum-phase zero of $g$ becomes an unstable pole of the
inverse. A strictly proper $g$ requires enough target roll-off to keep $Q$ proper.
Youla parametrization does not remove these physical restrictions; it makes them visible.

For a stable plant with a right-half-plane zero at $z$, every stable $Q$ satisfies
$T(z)=g(z)Q(z)=0$. A target $m(z) != 0$ cannot be matched exactly without leaving
the stable-Q class. Exercise 1 turns that obstruction into a quantitative error bound.

#pagebreak()
= The payoff: feedback design becomes model matching

In the original controller variable, minimizing tracking error means optimizing
$ norm(m-g k/(1+g k))_2, $
subject to internal stability. In Youla coordinates, the identical task becomes
$ inf_(Q in cal(R H)_2) norm(m-g Q)_2 $ <eq:h2problem>
when the controller is required to be strictly proper and $m$ is stable and strictly
proper. Here $cal(R H)_2$ consists of stable strictly proper real-rational functions.
The error is affine in $Q$, and the norm is convex.

For matrices and general disturbance/performance channels, the same principle gives
$ T_(z w)(Q)=T_1+T_2 Q T_3, $ <eq:affine>
where $T_1,T_2,T_3$ are fixed stable transfer matrices built from the plant and one
known stabilizing controller. Products on the left and right of $Q$ are fixed;
there are no hidden $Q$-dependent inverses in this closed-loop expression.

If $Q_a,Q_b$ are stable, then for $theta in [0,1]$ the interpolated transfer
$Q_theta=(1-theta)Q_a+theta Q_b$ is stable, and
$ T(Q_theta)=(1-theta)T(Q_a)+theta T(Q_b). $
This is the geometry behind convex norm design. It is generally *not* true that the
corresponding controller is $(1-theta)K_a+theta K_b$.

== What convexity does not promise

- The unrestricted stable-Q space is infinite-dimensional. A convex formulation is
  not automatically a finite-dimensional numerical program or an attained optimum.
- A fixed controller-order constraint generally becomes nonconvex in $Q$.
- Arbitrary sparsity constraints on $K$ do not generally become linear constraints
  on $Q$. The triangular exercise below is a special structure-preserving case.
- A norm ball $norm(Q)_infinity<gamma$ is itself convex. The nonlinear closed-loop
  expression in chapter 7's alternative parametrization is due to the different
  coordinates, *not because a norm bound destroys convexity*.
- Frozen-time stable choices do not by themselves prove stability under arbitrary
  switching. A time-varying implementation needs its own realization and stability argument.

For chapter 8, fixing $D$ leaves a convex norm objective in $Q$. Optimizing both
$Q$ and $D$ still leaves the nonlinear coupling $D^(-1)M(Q)D$. Youla coordinates and
D–K iteration address different obstacles.

#takeaway[
  Youla makes the *set of stable closed loops* easy to describe. It does not make
  every engineering constraint convex or guarantee robust performance automatically.
]

#pagebreak()
= Why an unstable plant needs coprime factors

The proof of @eq:fourmaps used the stability of $g$. If $g$ is unstable, a stable $Q$
does not automatically make $g Q$ and $g(1-g Q)$ stable. The missing cancellations
must be enforced in a way that does not hide unstable modes.

== Replace one unstable transfer by two stable transfers

Write $g=n/m$, with $n,m$ proper and stable. They may have right-half-plane *zeros*;
stability restricts poles, not zeros. Require stable proper $x,y$ such that
$ x m+y n=1. $ <eq:bezout>
This is a Bézout identity. It says the pair $n,m$ has no common noninvertible stable
factor. Calling the factors *coprime* means this stable identity exists, not simply
that two ordinary numerator polynomials have no common root.

Why does it matter? If $y_"out"=g u$, write
$u=m xi$, $y_"out"=n xi$. Then @eq:bezout gives
$xi=x u+y y_"out"$. Stable input/output data therefore determine a stable internal
factor coordinate. The representation cannot conceal an unstable coordinate behind
a common cancellation. This is the signal content of the abstract algebra.

== The scalar negative-feedback Youla formula

For any stable proper $q$, define
$ a=x-n q, quad b=y+m q, quad k_q=b/a. $ <eq:coprimeyoula>
Here $q$ is a new free coordinate around the chosen stabilizer; it is not generally
the physical map $T_(u r)$ used for a stable plant. The key cancellation is
$ m a+n b=m(x-n q)+n(y+m q)=m x+n y=1. $
Consequently
$ S=m a, quad k_q S=m b, quad g S=n a, quad T=n b. $ <eq:coprimemaps>
Every internal map is stable and *affine in q*. Require $a$ not identically zero,
$k_q$ proper, and a well-posed feedback interconnection. The controller denominator
$a$ is not required to have a stable inverse.

For completeness, an arbitrary stabilizing $k$ gives
$ q=(x k-y)/(m+n k)
     =x^2 k S+x y(T-S)-y^2 g S. $
The right-hand side is stable and proper because it is built from stable factors and
internally stable loop maps. Substitution recovers $k$ in @eq:coprimeyoula.
Thus in the scalar setting we have shown both directions, not only sufficiency.

#pagebreak()
== Work through an unstable plant without hiding the unstable pole

Take $g=1/(s-1)$. Choose
$ n=1/(s+1), quad m=(s-1)/(s+1), quad x=1, quad y=2. $
Both factors are stable and proper, and $m+2n=1$. The unstable plant pole is
represented by the zero of $m$ at $+1$.

The full stabilizing family is
$ k_q=(2+((s-1)/(s+1))q)/(1-q/(s+1)). $
At $q=0$, $k_0=2$ and the closed-loop pole is −1. At $q=1$,
$ k_1=(3s+1)/s, quad S=s(s-1)/(s+1)^2, quad T=(3s+1)/(s+1)^2. $
The closed-loop poles are both −1. The controller now has integral action, and the
step-tracking error tends to zero. We changed the response while staying in the
stabilizing family.

Notice $S(1)=0$. That zero cancels the unstable pole in $g S$ within the internally
stabilized interconnection. The coprime identity guarantees the relevant internal
maps are stable; merely inspecting a simplified $T$ would not supply that guarantee.

== A deliberately bad factorization

For the stable plant $g=1$, take $n=m=s/(s+1)$. Both factors are stable and their
ratio is one, but they are not coprime over $cal(R H)_infinity$. If stable $x,y$
satisfied $x m+y n=1$, evaluating at $s=0$ would give $0=1$.

The external data $u=y_"out"=1$ would require $xi=(s+1)/s$, which is not stable.
The common zero on the stability boundary concealed a nonstable factor coordinate.
This simple example explains why “choose any stable numerator and denominator”
is not sufficient.

= The book's matrix formulas: an explicit convention change

The scalar derivations above use $e=r-y$. The algebraic theorem in the book instead
uses *positive interconnection*:
$ y=G u+d_y, quad u=K y+d_u, $
so the internal inverse is $mat(I,-K;-G,I)^(-1)$ and the characteristic expression is
$I-G K$. A negative-feedback controller from the earlier sections corresponds to
$K=-k$ when connected directly to the plant output with zero reference.

#takeaway[
  Never move the minus sign silently. In negative tracking:
  $Q_-=k/(1+g k)$, $k=Q_-/(1-g Q_-)$.
  In positive interconnection:
  $Q_+=K/(1-G K)$, $K=Q_+/(1+G Q_+)$ for a stable scalar plant.
]

#pagebreak()
== What the eight factor symbols are doing

For the remainder of the matrix discussion, use the book's positive convention.
Let $G$ have $m$ inputs and $p$ outputs. A double coprime factorization consists of
stable matrices with
$ G=N M^(-1)=tilde(M)^(-1)tilde(N), $
$ mat(tilde(X),-tilde(Y);-tilde(N),tilde(M))
  mat(M,Y;N,X)=I. $ <eq:double>
Here $M,tilde(X)$ are $m times m$, $tilde(M),X$ are $p times p$,
$N,tilde(N)$ are $p times m$, and $Y,tilde(Y)$ are $m times p$.
The identity packages several Bézout equations into one stable change of coordinates.
For example, $tilde(X)M-tilde(Y)N=I$, while
$tilde(N)M=tilde(M)N$. The latter is a compatibility relation; neither product is
generally equal to $G$.

Theorem 9.13 then says
$ K_Q=(tilde(X)+Q tilde(N))^(-1)(tilde(Y)+Q tilde(M)),
  quad Q in cal(R H)_infinity, $ <eq:matrixyoula>
with a compatible $m times p$ parameter and an invertible denominator. In the proper
LTI setting keep the well-posedness/properness condition as well. At $Q=0$ this
returns the chosen stabilizer $tilde(X)^(-1)tilde(Y)$.

*Why it works.* The perturbed stable pair still satisfies the same Bézout identity:
$ (tilde(X)+Q tilde(N))M-(tilde(Y)+Q tilde(M))N=I. $
That fixed identity is the matrix replacement for $m a+n b=1$. Expanding the internal
closed-loop inverse gives the affine formula
$ mat(I,-K_Q;-G,I)^(-1)
  =mat(M tilde(X),M tilde(Y);N tilde(X),N tilde(Y)+I)
  +mat(M;N)Q mat(tilde(N),tilde(M)). $
This equation is the result worth recognizing. The controller formula contains an
inverse involving $Q$, but the internally closed system does not.

== Why the abstract ring language appears in the book

In the finite-dimensional continuous-time case, the ring is $cal(R H)_infinity$:
stable proper rational functions are the allowed coefficients. A *unit* is a stable
proper square transfer with a stable proper inverse. Two coprime representations
of the same plant differ by such an invertible stable coordinate change.

The ring formulation allows other meanings of stability and other system classes.
It is useful generality, but it is not a prerequisite for understanding the physical
stable-plant construction. For actual LTI realizations, stabilizability and detectability
let state feedback and an observer construct the double coprime data.

#pagebreak()
= Build the affine closed loop with an observer, not a giant matrix

Consider the generalized plant with no control-to-measurement feedthrough:
$ dot(x)=A x+B_1 w+B_2 u, $
$ z=C_1 x+D_11 w+D_12 u, quad y=C_2 x+D_21 w. $
Assume $(A,B_2)$ stabilizable and $(A,C_2)$ detectable. Choose $F,L$ with
$A+B_2 F$ and $A+L C_2$ Hurwitz. The observer sign is written to match the book:
$ dot(hat(x))=A hat(x)+B_2u-L(y-C_2hat(x)). $
Define an innovation $v=y-C_2hat(x)$ and add a stable correction $q=Q v$:
$ u=F hat(x)+q, quad q=Q v. $ <eq:observer>
The fixed observer and feedback around the Q-port are the system called $J$ in
$K=J star.op Q$. The lower LFT notation means
$J_11+J_12Q(I-J_22Q)^(-1)J_21$; it is only an interconnection shorthand.

Let the estimation error be $epsilon=x-hat(x)$. Subtract the observer dynamics:
$ dot(epsilon)=(A+L C_2)epsilon+(B_1+L D_21)w. $
Crucially, $q$ cancels from this equation: both plant and observer know the applied
input. Next write the remaining equations in $(x,epsilon)$ coordinates:
$ dot(x)=(A+B_2F)x-B_2F epsilon+B_1w+B_2q, $
$ z=(C_1+D_12F)x-D_12F epsilon+D_11w+D_12q, $
$ v=C_2epsilon+D_21w. $
The map from $(w,q)$ to $(z,v)$ is therefore stable and has the form
$ mat(z;v)=mat(T_1,T_2;T_3,0)mat(w;q). $
The bottom-right zero is the whole point: $q$ does not feed back into its own driving
innovation $v$. Closing $q=Q v$ gives exactly
$ z=(T_1+T_2 Q T_3)w. $
This is a constructive explanation of Theorem 9.16's affine formula. The double
coprime theorem supplies the *completeness*: varying stable $Q$ in this observer
architecture describes all proper internally stabilizing controllers, not just some.

If $y=C_2x+D_21w+D_22u$, include the known direct term in the observer. The book's
properness condition is $det(I+D_22Q(infinity)) != 0$. When $D_22=0$ it disappears.
We used this zero-feedthrough case to avoid hiding the central idea in algebraic-loop
corrections. Unlike the stable-plant $Q$ of section 1, this $Q$ maps *innovation to
correction*, not reference to control.

#pagebreak()
= Exercise 1: H₂ model matching, with the missing steps supplied

The exercise on pp. 238–239 of @schererTheoryRobustControl returns to *negative tracking*
@eq:tracking. The stable scalar plant is $g$, the stable strictly proper target is $m$,
and the controller must be strictly proper. The sign of the matching error
$z=y-m r$ does not affect its norm.

== (a) Closed-loop transfers; (b) the inner product

Elimination gives $T_(u r)=k/(1+g k)$ and $T_(y r)=g k/(1+g k)$.
On strictly proper rational functions without imaginary-axis poles, define
$ ⟨ f,h ⟩ =1/(2pi) integral_(-infinity)^infinity
    f(i omega) overline(h(i omega)) dif omega. $
Strict properness makes the integral finite. Sesquilinearity and conjugate symmetry
follow from the integral. If $⟨ f,f ⟩=0$, continuity implies
$f(i omega)=0$ everywhere, so the rational function is zero. Thus this is an inner
product and its induced norm is the stated frequency-domain 2-norm.

== (c) Stable and antistable parts are orthogonal

Partial fractions uniquely split any such function as $f=f_s+f_u$, where $f_s$ has
only left-half-plane poles and $f_u$ has only right-half-plane poles. Both are strictly
proper. Define $f_u^"∼"(s)=overline(f_u(-overline(s)))$. Its poles are in the left
half-plane and it equals $overline(f_u(i omega))$ on the imaginary axis.

The product $f_s f_u^"∼"$ has no poles in the right half-plane and decays at least
as $1/|s|^2$. Closing the imaginary-axis contour to the right gives zero. Hence
$⟨ f_s,f_u ⟩=0$. This proves orthogonality; uniqueness also follows because
the intersection of the two pole classes is zero.

== (d) Use Q rather than optimizing the controller directly

From sections 1–2, $T_(y r)=g Q$ and every stable $Q$ gives internal stability.
Since $g$ is proper, a strictly proper $Q$ has $g(infinity)Q(infinity)=0$, so
$k=Q/(1-g Q)$ is strictly proper. Conversely, a strictly proper stabilizing $k$ gives
strictly proper stable $Q=k/(1+g k)$. Thus the design problem is precisely
$ inf_(Q in cal(R H)_2) norm(g Q-m)_2. $
No stability of the controller's own denominator inverse is assumed.

#pagebreak()
== (e) A stable inverse: exact matching or a limiting sequence

If $g^(-1)$ is stable and proper, choose $Q_*=g^(-1)m$. It is stable and strictly
proper, and the error is zero. Recover
$ k_*=g^(-1)m/(1-m). $
Because $m$ is strictly proper, the denominator has nonzero limit at infinity, so
the controller is proper. Its poles need not all be stable.

If $g^(-1)$ has no unstable poles but is improper, first check whether
$Q_0=g^(-1)m$ is nevertheless strictly proper. If so, the same exact solution works.
Improperness of $g^(-1)$ alone does *not* rule out attainment.

Otherwise choose an integer $r$ large enough that, for every $eta>0$,
$ Q_eta=g^(-1)m/(1+eta s)^r $
is strictly proper. It is stable and gives $g Q_eta=m/(1+eta s)^r$. On the imaginary
axis the low-pass factor has magnitude at most one, tends pointwise to one as
$eta -> 0$, and
$ |m((1+i eta omega)^(-r)-1)|^2 <= 4|m|^2. $
Dominated convergence then yields $norm(g Q_eta-m)_2 -> 0$. Recovering $k_eta$ by
the stable-plant formula produces almost-optimal stabilizing controllers. Since
$g != 0$, exact matching uniquely requires $Q=g^(-1)m$; if it is not strictly proper,
the zero infimum is not attained in this controller class.

== (f)–(h) A nonminimum-phase zero: project away the impossible part

Now assume $g$ has no zeros on the imaginary axis *or at infinity*, as in the exercise.
Factor $g=g_i g_o$, where $g_i$ is inner ($|g_i(i omega)|=1$) and $g_o$ and
$g_o^(-1)$ are stable and proper. The no-zero-at-infinity assumption is important:
it is not valid to assume a proper stable inverse for an arbitrary strictly proper outer factor.

Set $x=g_o Q$. Multiplication by the unit $g_o$ is a bijection on
$cal(R H)_2$, so
$ inf_Q norm(g Q-m)_2=inf_x norm(g_i x-m)_2
  =inf_x norm(x-r)_2, quad r=m/g_i. $
Here $r(s)$ is an auxiliary transfer function, not the reference signal from the
tracking diagram. Split $r=r_s+r_u$ using part (c). Orthogonality gives
$ norm(x-r)_2^2=norm(x-r_s)_2^2+norm(r_u)_2^2. $
Therefore
$ x_*=r_s, quad Q_*=g_o^(-1)r_s, quad
  k_*=g_o^(-1)r_s/(1-g_i r_s), $
$ inf norm(g Q-m)_2=norm(r_u)_2. $
This is *H₂ orthogonal projection*, not the $H_infinity$ Nehari-distance problem.
The two approximation theories are related, but their distances are not interchangeable.

#pagebreak()
== A concrete projection you can check by hand

Choose $g=(s-1)/(s+1)$ and $m=1/(s+1)$. The plant is stable but has a zero at $+1$.
Here $g_i=g$, $g_o=1$, and
$ r=m/g_i=1/(s-1), quad r_s=0, quad r_u=1/(s-1). $
Thus $Q_*=0$, $k_*=0$, and the best achievable matching-error norm is
$norm(r_u)_2=1/sqrt(2)$. Doing nothing is optimal for this particular target and
unpenalized H₂ tracking objective: the target lies entirely in the inaccessible
antistable component after the inner transformation.

This is not a numerical failure and not a general statement that nonminimum-phase
plants should not be controlled. It is the exact solution to *this* objective.
For any nonzero stable strictly proper $Q$,
$ norm(g Q-m)_2^2=norm(Q)_2^2+1/2 > 1/2. $
This example is also a useful guard against dropping $g_i$ from the recovered
controller denominator or confusing the H₂ projection with an $H_infinity$ approximation.

= Exercise 2: triangular controllers and triangular Q

The exercise on pp. 239–240 uses the book's *positive* interconnection, not negative
tracking. The plant is lower block triangular:
$ P=mat(P_11,0;P_21,P_22). $
In this section the $P_22$ symbol means the *second diagonal subsystem* of this
structured plant, not the feedback block of the previous generalized plant.

== (a) Stable triangular P

If $P$ is stable and $K$ internally stabilizes it, let
$ Q=K(I-P K)^(-1). $
Solving gives $K=(I+Q P)^(-1)Q=Q(I+P Q)^(-1)$. Products and rational inverses of
invertible lower block-triangular matrices preserve the zero upper-right block.
Thus lower-triangular $K$ implies lower-triangular $Q$, and conversely, subject to
properness and well-posedness. The formula works for matrices without commuting
$P$ and $Q$; use the push-through identity as written.

== (b) What the missing upper-right plant channel means in state space

Take a minimal realization with $C_1(s I-A)^(-1)B_2=0$. Its Markov parameters give
$C_1 A^j B_2=0$ for all nonnegative $j$. The reachable subspace
$cal(C)_2="span"{B_2,A B_2,...,A^(n-1)B_2}$ is $A$-invariant and every one of
its vectors is invisible to $C_1 A^j$ for all $j$. Thus it lies in the *unobservable
subspace*, not just in $"ker" C_1$.

#pagebreak()
Choose a basis with $cal(C)_2$ in the *second* state block and a complement first.
Invariance and invisibility give
$ A=mat(A_11,0;A_21,A_22), quad B=mat(B_11,0;B_21,B_22), $
$ C=mat(C_11,0;C_21,C_22), quad D=mat(D_11,0;D_21,D_22). $
This is a cascade: subsystem 1 may drive subsystem 2, but subsystem 2 cannot drive
subsystem 1.

== (c) Correct the existence statement before proving it

As printed, the exercise says a specified $K$ stabilizes $P$ iff four plant pairs
are stabilizable/detectable. That cannot be literal: properties of the plant cannot
make every chosen controller stabilizing. The useful correct statement is:

#takeaway[
  A lower-triangular internally stabilizing controller *exists* iff the diagonal
  pairs $(A_11,B_11)$ and $(A_22,B_22)$ are stabilizable and the diagonal pairs
  $(A_11,C_11)$ and $(A_22,C_22)$ are detectable.
]

For a given lower-triangular controller realization, reorder the full closed-loop
states as $(x_1,x_1^K,x_2,x_2^K)$. The closed-loop state matrix is lower block
triangular; its diagonal blocks are the two local plant/controller closed loops.
It is Hurwitz *iff those two diagonal closed-loop matrices are Hurwitz*.
Necessity follows because each local loop must be stabilizable/detectable.
Sufficiency follows by constructing local observer-based stabilizers and arranging
them triangularly. Off-diagonal terms do not change the eigenvalues of this cascade.
This is not a claim that off-diagonal terms never affect general PBH rank tests.

== (d) Construct the triangular Youla generator

Pick block-diagonal gains $F="diag"(F_1,F_2)$ and $L="diag"(L_1,L_2)$ stabilizing
the diagonal pairs with the sign convention $A+B F$, $A+L C$ Hurwitz. The full matrices
are lower triangular with Hurwitz diagonals, so are Hurwitz too.

There is a second issue in the printed exercise: its generator has state matrix
$A+B F$, missing the observer term $L C$ even when $D=0$. This is not harmless.
For $A=B=C=1$, $F=L=-2$, its $Q=0$ controller is $-4/(s+1)$ and the positive-feedback
characteristic polynomial is $s^2+3$, not Hurwitz. Adding $L C$ gives
$-4/(s+3)$ and closed-loop polynomial $(s+1)^2$.

Use the corrected generator from Theorem 9.16, including the plant feedthrough $D$:
$ dot(xi)=(A+B F+L C+L D F)xi+L y-(B+L D)q, $
$ u=-F xi+q, quad v=(C+D F)xi+y-D q, quad q=Q v. $
In the book's realization notation this is
$ Y=mat(A+B F+L C+L D F,L,-(B+L D);-F,0,I;C+D F,I,-D). $
When $D=0$, only the missing $L C$ correction remains. The realization notation has
a shared state matrix in the top-left, two input groups in the top row, and two
output groups in the remaining rows.

For the second diagonal subsystem $D_22=0$, since $P_22$ is strictly proper. The
first diagonal block may have feedthrough, so retain the condition
$det(I+D Q(infinity)) != 0$. The corrected $Y$ gives $K=Y star.op Q$ and all
proper stabilizing controllers with this qualification. To verify stability directly,
let $epsilon=x+xi$ and note that $v=C epsilon$ in the undisturbed plant loop.
Then $dot(epsilon)=(A+L C)epsilon$ and
$dot(x)=(A+B F)x-B F epsilon+B q$. The same stable triangular construction as in
section 7 applies. This also shows exactly why the omitted observer term matters.

== (e) Show both directions of the triangular correspondence

All four $Y_(i j)$ are lower block triangular, because their state, input, and output
matrices have the cascade pattern. If $Q$ is lower triangular, then
$ K=Y_11+Y_12 Q(I-Y_22Q)^(-1)Y_21 $
is lower triangular by closure under multiplication, addition, and rational inversion.

Conversely, let $K$ be lower triangular and internally stabilizing. Invert the
parametrization in two stages:
$ Z=Y_12^(-1)(K-Y_11)Y_21^(-1), $
$ Z=Q(I-Y_22 Q)^(-1)=(I-Q Y_22)^(-1)Q, $
$ Q=(I+Z Y_22)^(-1)Z. $
The last identity follows by multiplying $(I-Q Y_22)Z=Q$ and rearranging.
The ordering of the matrix factors matters. Each rational inverse retains the
lower-triangular pattern, so $Z$ and then $Q$ are triangular. The completeness of
the Youla theorem supplies *stability* of this recovered Q; triangular algebra alone
does not prove stability of any inverse used along the way.

= What to retain, and what not to memorize

#table(columns: (1.1fr,2fr), inset: 7pt, stroke: 0.4pt + luma(180),
  table.header([*Setting*],[*Meaning and formula*]),
  [Stable scalar plant, negative tracking],
  [$Q=T_(u r)$; $k=Q/(1-g Q)$; $S=1-g Q$, $T=g Q$.],
  [Unstable scalar plant, negative tracking],
  [Use $g=n/m$, $x m+y n=1$; $k=(y+m q)/(x-n q)$.],
  [Generalized plant, observer coordinates],
  [Stable Q maps innovation to correction; $T_(z w)=T_1+T_2 Q T_3$.],
  [Book's positive interconnection],
  [Use $I-G K$, not $I+G K$; do not import the negative-tracking sign unchanged.])

The free parameter labels a *stable closed-loop degree of freedom*. Changing the
base stabilizer or factors changes these coordinates, not the achievable stable loops.

== Reproduce the numerical examples

```sh
octave --no-gui --quiet \
  Control/robust-control-09-youla/scripts/examples.m
```
The script checks all numerical examples, including the observer-based affine formula,
and regenerates the figure.

#text(size: 9.5pt)[
*Source.* Based on chapter 9, pp. 224–240 of @schererTheoryRobustControl, especially Theorems
9.13 and 9.16. Examples, derivations, and exercise corrections are developed here;
not every abstract ring lemma is reproduced.

#bibliography("refs.bib", title: none)
]
