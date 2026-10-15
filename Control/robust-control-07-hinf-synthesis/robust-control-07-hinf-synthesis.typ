// Standalone: typst compile --root . <this file> <same stem>.pdf
#set document(title: "H-infinity synthesis: from energy budgets to a controller", author: "Amp")
#set page(paper: "a4", margin: (x: 24mm, y: 21mm),
  header: text(size: 9pt, fill: rgb("#5b6470"))[Robust control · Chapter 7],
  footer: context align(right, text(size: 9pt, counter(page).display("1"))))
#set text(font: "Libertinus Serif", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("#1f4e79"))
#let takeaway(body) = block(width: 100%, inset: 10pt, fill: rgb("#edf5f5"),
  stroke: (left: 2pt + rgb("#0f766e")), body)

#text(size: 23pt, weight: "bold", fill: rgb("#1f4e79"))[H∞ Synthesis]

#text(size: 15pt)[From an energy budget to an implementable controller]

An $H_infinity$ synthesis routine does not guess controller coefficients until a frequency
plot looks good. It answers a feasibility question: *can any internally stabilizing
controller keep the worst-case disturbance-to-performance gain below $gamma$?*

The main difficulty is not solving a quadratic equation. It is understanding why an
energy inequality leads to that equation, why output feedback needs *two* equations,
and why solving them separately is still not enough.

#takeaway[
  Read sections 1–7 first. The route is:

  signals → energy certificate → state-feedback design → estimation → compatibility
  → an actual controller.

  Section 8 is the numerical workflow; section 9 connects to Youla. Section 10 is a
  separate guide to all eleven book exercises, with advanced proof outlines labelled.
]

= Decide which signals the controller must protect

Use the book's generalized plant, with *positive interconnection* $u=K y$:
$ dot(x)=A x+B_1 w+B_2 u, quad
  z=C_1 x+D_12 u, quad y=C_2 x+D_21 w. $ <eq:plant>
The sign of corrective feedback is inside $K$; there is no extra minus sign at the
connection. For these first formulas $D_11=D_22=0$. General feedthrough is discussed later.

#table(columns: (0.7fr,2.8fr), inset: 6pt, stroke: 0.4pt + luma(180),
  [$w$], [Exogenous inputs: disturbances, references, and measurement noise.],
  [$u$], [Actuator commands chosen by the controller.],
  [$y$], [The measurements the controller can actually use.],
  [$z$], [The quantities being penalized, such as weighted error and control effort.])

Let $T_(z w)=P star.op K$ denote the closed-loop transfer from $w$ to $z$. For an internally
stable finite-dimensional LTI system, with *zero initial state*,
$ norm(T_(z w))_infinity
  =sup_(w in L_2, w != 0) norm(z)_2/norm(w)_2
  =sup_(omega in RR) sigma_max(T_(z w)(i omega)). $
Here $norm(v)_2^2=integral_0^infinity v(t)^T v(t) dif t$. Thus a bound $gamma$ limits
energy amplification, not a particular step-response peak, and not the probability of
an error. Units and relative priorities belong in the weights already absorbed into $P$.

The two requirements are distinct: all internal modes must decay, *and* the transfer
gain must be below $gamma$. A stable-looking transfer after cancelling a hidden unstable
mode does not satisfy the first requirement.

#pagebreak()
= Turn a frequency bound into an energy certificate

First freeze the controller, or forget it entirely. Suppose a fixed system is
$ dot(x)=A_c x+B_c w, quad z=C_c x, $
and ask whether it is stable with $norm(T_(z w))_infinity<gamma$.
Try to account for its stored energy using $V(x)=x^T Pi x$, $Pi=Pi^T>0$. Require
$ dot(V)+z^T z-gamma^2 w^T w<0 $ <eq:dissipation>
for every nonzero pair $(x,w)$. Expanding gives the matrix test
$ mat(A_c^T Pi+Pi A_c+C_c^T C_c, Pi B_c;
      B_c^T Pi, -gamma^2 I)<0. $ <eq:brl>
At $w=0$ it implies $A_c^T Pi+Pi A_c<0$, hence $A_c$ is Hurwitz. Integrating from
$x(0)=0$ gives $norm(z)_2^2<gamma^2 norm(w)_2^2$ for nonzero finite-energy inputs.
Because the matrix inequality has a strict finite-dimensional margin, it also holds
for a slightly smaller positive $gamma'$; this supplies a *uniform* norm gap below $gamma$.

The *strict Bounded Real Lemma* says the converse holds too: stable gain below $gamma$
admits such a positive quadratic certificate. Expansion proves sufficiency; necessity
is the nontrivial theorem (book §§7.2–7.3), not an assumption about a guessed storage.

The lower-right block is negative definite. Its Schur complement is
$ A_c^T Pi+Pi A_c+C_c^T C_c+gamma^(-2) Pi B_c B_c^T Pi<0. $ <eq:ari>
This is a *Riccati inequality*: the last term is quadratic in the unknown $Pi$.
No controller has been designed yet. We have only changed the language of the test.

== A complete scalar check

Take $dot(x)=-3x+w$, $z=2x$. Its exact gain is
$ norm(2/(s+3))_infinity=2/3. $
With $Pi=p>0$, @eq:ari becomes $-6p+4+p^2/gamma^2<0$.
At $gamma=0.8$, choose $p=1$: the left side is $-0.4375$, so the certificate works.
At $gamma=0.6$, even the equality has no real roots: its discriminant is
$36-16/0.6^2<0$. That demand is impossible, agreeing with the exact gain.

At $gamma=0.8$, the equality's roots are $p_-=0.858680$ and $p_+=2.981320$.
Both solve the same algebraic equation, but
$ -3+p_-/0.8^2<0, quad -3+p_+/0.8^2>0. $
The first is the *stabilizing Riccati root*. “Stabilizing” refers to this modified matrix,
not merely the original $A_c=-3$. Root selection is part of the problem.

#takeaway[The norm bound became a certificate search. It did not become “solve any
  quadratic equation and accept any real root.”]

#pagebreak()
= Design state feedback by completing two squares

Now let the controller see the full state and choose $u=F x$. To keep the algebra visible,
assume the normalized control penalty
$ D_12^T D_12=I, quad D_12^T C_1=0. $ <eq:controlnorm>
Consequently $z^T z=x^T C_1^T C_1 x+u^T u$: performance charges both state error
and control effort, with no cross term. This normalization is not automatic for every plant.

Use storage $V=x^T Y x$, with $Y=Y^T>0$. Before substituting a feedback law,
$ dot(V)+z^T z-gamma^2 w^T w
  =x^T(A^T Y+Y A+C_1^T C_1)x
   +2x^T Y B_2 u+u^T u+2x^T Y B_1 w-gamma^2 w^T w. $
Complete the control and disturbance squares:
$ dot(V)+z^T z-gamma^2 w^T w
  =x^T cal(R)_gamma(Y)x+norm(u+B_2^T Y x)^2
   -gamma^2 norm(w-gamma^(-2) B_1^T Y x)^2, $ <eq:squares>
where
$ cal(R)_gamma(Y):=A^T Y+Y A+C_1^T C_1
  +Y(gamma^(-2) B_1 B_1^T-B_2 B_2^T)Y. $ <eq:controlare>

Read the signs. The controller can eliminate the *positive* square by choosing
$ u=F x, quad F=-B_2^T Y. $ <eq:feedback>
The disturbance maximizes the expression by eliminating the *negative* square.
This explains both the negative control term and the positive disturbance term in the
Riccati equation. They are not interchangeable signs to memorize.

If $Y>0$ and $cal(R)_gamma(Y)<0$, the chosen $F$ gives a strict dissipation
certificate and stabilizes the loop. This strict-inequality formulation is an existence
test for state-feedback synthesis, not just a sufficient recipe. For necessity, apply
the Bounded Real Lemma to any successful $F$; its Riccati expression is
$ cal(R)_gamma(Y)+(F+B_2^T Y)^T(F+B_2^T Y)<0, $
so dropping the nonnegative square gives $cal(R)_gamma(Y)<0$.

== Why use an equality instead?

Numerical Riccati algorithms compute a special solution of $cal(R)_gamma(Y)=0$ rather
than searching the whole strict inequality. Under the book's normalized hypotheses,
stabilizability of $(A,B_2)$, and its no-imaginary-axis-unobservable-mode condition,
the exact state-feedback test is the existence of $Y>=0$ satisfying that equality and
$ A+(gamma^(-2) B_1 B_1^T-B_2 B_2^T)Y " is Hurwitz". $ <eq:gamestability>
Then @eq:feedback works. This is a theorem (book exercise 7), not a consequence of
the square identity alone. The identity with equality gives a non-strict energy bound;
the stabilizing branch and hypotheses supply stability and the strict norm bound.

#pagebreak()
= What a Riccati solver actually selects

For a generic equation
$ A^T Y+Y A+Y R Y+Q=0, quad R=R^T, quad Q=Q^T, $
define the Hamiltonian matrix
$ cal(H)=mat(A,R;-Q,-A^T). $
The apparently nonlinear equation is equivalent to the invariant-subspace identity
$ cal(H) mat(I;Y)=mat(I;Y)(A+R Y). $ <eq:graph>
Indeed, its top row is $A+R Y$; its bottom row is $-Q-A^T Y=Y(A+R Y)$.

If the stable invariant subspace can be written as $mat(U;V)$ with $U$ invertible,
then $Y=V U^(-1)$. Its associated matrix $A+R Y$ is Hurwitz because the subspace
was selected from the left-half-plane eigenvalues. In computation use an ordered
Schur method, solve for the quotient, and check the residual; avoid explicit inversion.

For the control equation, $R=gamma^(-2) B_1 B_1^T-B_2 B_2^T$ can be *indefinite*.
Thus these are separate checks:

+ no Hamiltonian eigenvalues on the imaginary axis;
+ the selected subspace has an invertible, numerically usable top block;
+ the recovered solution is symmetric, positive semidefinite, and has a small residual;
+ the specified Riccati stability matrix is Hurwitz.

The first check alone is not a universal theorem for indefinite Riccati equations.
For example, $A=1$, $R=Q=0$ gives $cal(H)="diag"(1,-1)$: there are no imaginary
eigenvalues, but the stable subspace has $U=0$, and $A+R Y=1$ cannot be stabilized
by any Riccati root. The book's early equivalences impose extra sign and controllability
assumptions; do not carry them silently into a different equation.

== Why does the book sometimes ask for an anti-stabilizing root?

Our $Y$ is the control-cost coordinate used as $Y_infinity$ in Theorem 7.13. Earlier,
Theorem 7.9 uses the inverse coordinate $W=Y^(-1)$ when $Y>0$. Multiplying the
control ARE on both sides by $W$ gives
$ A W+W A^T+gamma^(-2) B_1 B_1^T-B_2 B_2^T+W C_1^T C_1 W=0. $
Its branch matrix is $A+W C_1^T C_1$, and the ARE implies
$ A+W C_1^T C_1
  =-W (A+(gamma^(-2) B_1 B_1^T-B_2 B_2^T)Y)^T W^(-1). $
The eigenvalues are negated. A stabilizing $Y$ therefore corresponds to an
*anti-stabilizing* $W$, with the same physical gain $F=-B_2^T W^(-1)$.
Nothing physically changed stability; only the certificate coordinate changed.
If $Y$ is singular, this inverse coordinate is unavailable, another reason to prefer
the semidefinite formulation in the final theorem.

#pagebreak()
= Estimation is the dual problem — but output feedback needs more

If $x$ is not measured, try an observer for
$ dot(x)=A x+B_1 w, quad z=C_1 x, quad y=C_2 x+D_21 w. $
Use the book's sign convention
$ dot(hat(x))=A hat(x)+L(C_2 hat(x)-y), quad hat(z)=C_1 hat(x). $
With $xi=x-hat(x)$, subtract the equations:
$ dot(xi)=(A+L C_2)xi+(B_1+L D_21)w, quad e=C_1 xi. $
Thus observer design asks for stable error dynamics and gain from $w$ to *estimation
error* $e$ below $gamma$. Transpose that transfer matrix. It becomes a state-feedback
problem with the substitutions
$ (A,B_1,B_2,C_1,D_12) -> (A^T,C_1^T,C_2^T,B_1^T,D_21^T). $
The dual normalization is $B_1 D_21^T=0$, $D_21 D_21^T=I$. The corresponding filter ARE is
$ A X+X A^T+B_1 B_1^T
  +X(gamma^(-2) C_1^T C_1-C_2^T C_2)X=0, $ <eq:filterare>
with $X>=0$ and $A+X(gamma^(-2) C_1^T C_1-C_2^T C_2)$ Hurwitz. The observer gain is
$L=-X C_2^T$. As on the control side, appropriate detectability and regularity hypotheses
are needed for the ARE characterization; this is not a formula for arbitrary plant data.

== Why not just combine the two independently?

In LQG, the control and filtering Riccati equations can be solved independently. At a
finite $H_infinity$ bound, the same adversarial input affects what must be controlled
*and* what can be inferred. Estimation and control must fit within one performance budget.
Two individually successful Riccati solutions need not be compatible.

The extra condition is
$ rho(X Y)<gamma^2, $ <eq:coupling>
where $rho$ is spectral radius. Since $X,Y>=0$, the nonzero eigenvalues of $X Y$
are those of the symmetric positive-semidefinite $X^(1/2)Y X^(1/2)$. Hence the condition
can also be read as
$ I-gamma^(-2) X^(1/2)Y X^(1/2)>0. $
It is a strict compatibility margin, not a third Riccati equation and not a replacement
for either equation's stability test. It makes
$ Z=(I-gamma^(-2) X Y)^(-1) $ <eq:z>
well defined. $Z$ need not be symmetric. Keep its matrix ordering exactly as written.

#takeaway[State feedback answers “can I control with perfect information?”
  Filtering answers “can I estimate what matters?” The coupling test asks whether those
  two solutions can be assembled at the *same* bound.]

#pagebreak()
= Assemble the central controller

Here is the normalized two-Riccati result (book Theorem 7.13), in one place. Assume

+ $D_11=D_22=0$, $D_12^T D_12=I$, $D_12^T C_1=0$,
  $D_21 D_21^T=I$, $B_1 D_21^T=0$;
+ $(A,B_2)$ is stabilizable and $(A,C_2)$ is detectable;
+ $(A,B_1)$ has no uncontrollable modes on the imaginary axis and $(A,C_1)$ has
  no unobservable modes there.

Then a proper LTI controller internally stabilizing $P$ with $norm(P star.op K)_infinity<gamma$
exists *if and only if* the filter ARE @eq:filterare and the control ARE
$cal(R)_gamma(Y)=0$ have their specified stabilizing solutions $X,Y>=0$ and
@eq:coupling holds. With $Z$ from @eq:z, one such controller is
$ dot(x)_K=A_K x_K+B_K y, quad u=C_K x_K, $
$ A_K=A-Z X C_2^T C_2+(gamma^(-2) B_1 B_1^T-B_2 B_2^T)Y, $
$ B_K=Z X C_2^T, quad C_K=-B_2^T Y, quad D_K=0. $ <eq:central>
The controller has a realization with the plant's state dimension. A transfer-function
reduction may lower that order; there is no need to promise it is always minimal.

== Read the formula as an observer with a worst-case correction

Set $F=-B_2^T Y$, $L=-X C_2^T$, and $hat(A)=A+gamma^(-2) B_1 B_1^T Y$.
The same controller is
$ dot(hat(x))=hat(A)hat(x)+B_2 u+Z L(C_2 hat(x)-y), quad u=F hat(x). $
It resembles the ordinary observer/state-feedback construction, but has two important
changes: the worst-case drift correction in $hat(A)$, and the coupling factor $Z$ in
the injection gain. Dropping either generally gives a different controller with no
guarantee at the requested level. This is *not* the ordinary independent LQG separation.

As $gamma -> infinity$, the adversarial terms vanish and $Z -> I$, provided the
usual stabilizing LQG solutions exist. The equations reduce to the control and filter
Riccati equations of LQG. $X$ and $Y$ at finite $gamma$ are not automatically stochastic
covariances: the derivation was a deterministic worst-case energy argument.

== Check the loop you actually connected

For $D_K=D_11=D_22=0$, the complete closed-loop realization is
$ A_c=mat(A,B_2 C_K;B_K C_2,A_K), quad B_c=mat(B_1;B_K D_21), $
$ C_c=mat(C_1,D_12 C_K), quad D_c=0. $ <eq:physical>
Check *all* eigenvalues of $A_c$ before any pole–zero cancellation, and compute the
$H_infinity$ norm of this realization. A Riccati residual is not a substitute for
checking that the correct signs, signal ordering, and controller were implemented.

#pagebreak()
= One plant, from hand calculation to a controller

Consider a scalar state with unit process disturbance $d$ and measurement noise $v$:
$ dot(x)=-x+d+u, quad y=x+v, quad z=mat(x;u), quad w=mat(v;d). $ <eq:example>
We want small state excursions without unlimited actuator effort, using only the noisy
measurement. In @eq:plant this means
$ A=-1, quad B_1=mat(0,1), quad B_2=1, quad
  C_1=mat(1;0), quad D_12=mat(0;1), quad C_2=1, quad D_21=mat(1,0). $
The normalized assumptions hold. Both Riccati equations reduce to
$ -2a+(gamma^(-2)-1)a^2+1=0. $
The stabilizing root, written without a removable singularity at $gamma=1$, is
$ X=Y=a(gamma)=1/(1+sqrt(2-gamma^(-2))), quad gamma>1/sqrt(2). $ <eq:root>
Its branch eigenvalue is $-sqrt(2-gamma^(-2))<0$. This verifies the root selection,
not just substitution into the quadratic.

== Three requests with three different answers

#table(columns: (0.75fr,2.5fr), inset: 7pt, stroke: 0.4pt + luma(180),
  table.header([Requested $gamma$],[Why it succeeds or fails]),
  [0.70], [No real stabilizing Riccati root: $2-gamma^(-2)<0$.],
  [0.72], [Both AREs have stabilizing roots, but $a^2/gamma^2>1$: coupling fails.],
  [0.75], [Both roots pass, $a=0.679623$, and $a^2/gamma^2=0.821133<1$.])

The output-feedback threshold is therefore *not* the point where either individual
Riccati equation first becomes solvable. It is where $a(gamma)=gamma$. Since
$ gamma+sqrt(2gamma^2-1)=1, $
squaring within the relevant interval gives
$ gamma^2+2gamma-2=0, quad gamma_* =sqrt(3)-1=0.7320508076 dots. $
The feasible strict bounds are $gamma>gamma_*$. This is an infimum over controllers;
the feasibility theorem makes no promise of a finite controller at the endpoint.

== Write down the controller at gamma = 0.75

Substitution into @eq:central gives
$ A_K=-4.270995, quad B_K=3.799590, quad C_K=-0.679623, quad D_K=0. $
Thus $K(s)=C_K B_K/(s-A_K)$ has a *negative* transfer gain. This is the corrective
sign inside $u=K y$, not a reason to insert a second minus sign in the feedback command.
The physical closed-loop norm is $0.749283<0.75$. The requested certificate level
and the achieved norm are close in this case, but are not the same number.

#pagebreak()
== What changes as we demand better performance?

#figure(image("assets/hinf-example.svg", width: 100%),
  caption: [Computed from the physical plant/controller interconnection. Left: compatibility
    becomes tight at $gamma_*$. Right: the achieved norm stays below each feasible
    requested bound but above the optimal infimum, approaching $gamma_*$ from above.])

#table(columns: (0.6fr,0.75fr,0.9fr,1fr,0.95fr), inset: 6pt,
  align: center, stroke: 0.4pt + luma(180),
  table.header([$gamma$],[$a$],[$a^2/gamma^2$],[$A_K$],[Actual norm]),
  [0.7321],[0.731867],[0.999365],[-1152.160],[0.732100],
  [0.75],[0.679623],[0.821133],[-4.270995],[0.749283],
  [1.00],[0.500000],[0.250000],[-1.666667],[0.860380],
  [1.20],[0.466721],[0.151270],[-1.692514],[0.885374],
  [2.00],[0.430501],[0.046333],[-1.774292],[0.910936],
  [$infinity$],[0.414214],[0],[-1.828427],[0.921519])

The near-endpoint norm rounds to the requested bound in the table; the unrounded
computation is still strictly below it. As $gamma -> gamma_*^+$, the denominator
of $Z=(1-a^2/gamma^2)^(-1)$ tends to zero. Both $A_K$ and $B_K$ become large in
magnitude. The controller acquires fast dynamics; asking for nearly optimal performance
can be numerically and physically expensive. These numbers demonstrate that issue for
the central family, not a universal proof that every plant's optimum must be high-gain.

If the exact state were available, $u=f x$ gives
$ norm(T_(z d))_infinity=sqrt(1+f^2)/(1-f), quad f<1. $
Its squared value minus $1/2$ is $(f+1)^2/(2(1-f)^2)$, so its minimum is exactly
$1/sqrt(2)$ at $f=-1$. The noisy-output problem has the larger threshold $sqrt(3)-1$.
This makes the extra cost of limited information concrete.

At $gamma=infinity$, $a=sqrt(2)-1$ and the central controller is the LQG limit. Its
$H_infinity$ norm is $0.921519$, while its $H_2$ norm is $0.696621$. They measure different
things. The latter is computed by the Lyapunov-based norm routine, not by a truncated
frequency integral that misses energy near zero and infinity.

#pagebreak()
= Use the theorem as a design workflow, not as a black box

The feasible set of requested bounds is upward closed: if one controller achieves
$gamma_0$, it achieves every larger bound too. This is why bisection is justified.

+ Build $P$ from the actual signals and weights. Check dimensions and the feedback sign.
+ Find an infeasible lower bound and a feasible upper bound. For each midpoint, solve
  both AREs on the specified branches; check residuals, semidefiniteness, and branch stability.
+ Reject the midpoint if either Riccati test fails or $rho(X Y)>=gamma^2$.
+ If all tests pass, construct $K$, check the complete closed-loop poles and actual norm,
  and lower the feasible upper bound. Stop with a tolerance, not at a singular endpoint.
+ Inspect actuator gains, sensitivity, and time responses as engineering checks in addition
  to the certificate. A weighted energy bound alone does not guarantee no saturation.

In exact arithmetic these tests decide feasibility under the theorem's hypotheses. Near
the boundary a solver can have numerical difficulty. Report that separately from a
mathematical infeasibility certificate, and retain a useful safety margin.

== General feedthrough and non-normalized data

For a fixed closed-loop system $z=C_c x+D_c w$, the strict Bounded Real LMI is
$ mat(A_c^T Pi+Pi A_c+C_c^T C_c, Pi B_c+C_c^T D_c;
      B_c^T Pi+D_c^T C_c, D_c^T D_c-gamma^2 I)<0, quad Pi>0. $
It includes the necessary high-frequency condition $norm(D_c)<gamma$.
Do not use the zero-feedthrough formulas unchanged on arbitrary plant matrices.
General regular synthesis routines account for feedthrough, cross terms, and scalings.
Their standard assumptions include stabilizability/detectability, full column rank of
$D_12$, full row rank of $D_21$, and the appropriate plant pencils having full rank at
every imaginary frequency (book §7.9).

One transparent regularization adds channels rather than hiding their effect:
$ dot(x)=A x+B_1 w+epsilon w_1+B_2 u, $
$ z_"aug"=mat(C_1 x+D_11 w+D_12 u;epsilon x;epsilon u), $
$ y=C_2 x+D_21 w+epsilon w_2+D_22 u. $
The controller still sees the same measurement dimension and drives the same actuators.
The full autonomous plant/controller matrix is unchanged: new external inputs and
penalized outputs do not add internal states. Thus internal stability is unchanged.
For each fixed stabilizing $K$, the augmented norm is at least the original one and
converges to it as $epsilon ->0$. A strict bound for the original problem survives for
sufficiently small $epsilon$; a bound for the augmented problem also protects the original.
An arbitrary finite $epsilon$ nevertheless changes the optimization problem.

#pagebreak()
= Two deeper readings: a game and a family of controllers

== The energy identity is also a zero-sum game

With $cal(R)_gamma(Y)=0$, integrate @eq:squares from $x(0)=xi$:
$ x(T)^T Y x(T)-xi^T Y xi
  +integral_0^T (norm(z)^2-gamma^2 norm(w)^2) dif t $
$ =integral_0^T norm(u+B_2^T Y x)^2 dif t
   -gamma^2 integral_0^T norm(w-gamma^(-2) B_1^T Y x)^2 dif t. $
The controller minimizes the payoff and the disturbance maximizes it. Their candidate
strategies are $u_*=-B_2^T Y x$ and $w_*=gamma^(-2) B_1^T Y x$. Together they give
@eq:gamestability, so the saddle trajectory decays and both inputs have finite energy.
For this pair the infinite-horizon payoff equals $xi^T Y xi$.

For arbitrary finite-energy $w$, the stabilizing $u_*$ guarantees payoff at most that
value. Under the book's game hypotheses, including observability of $(A,C_1)$, the
converse minimax/maximin equalities require the admissibility arguments of Theorems
7.20, 7.26, and 7.27. Opposite squares alone do not justify interchanging an infimum
and a supremum for arbitrary strategies.

The inner-system construction in §7.11 repackages this balance as a lossless channel:
an inner stable transfer preserves $L_2$ energy. It allows the performance condition to
be transferred to a free stable bounded parameter. Its role is an exact change of
interconnection coordinates, not an approximation or an extra physical component.

== Central means the zero member of a whole family

Let $F=-B_2^T Y$, $L=-X C_2^T$, and let $A_K$ be as in @eq:central. Define
$ K_"par"=mat(A_K,-Z L,Z B_2;F,0,I;-C_2,I,0). $
The book's Theorem 7.40 states that all internally stabilizing controllers meeting the
strict bound have the form
$ K=K_"par" star.op Q_gamma, quad
  Q_gamma in cal(R H)_infinity, quad norm(Q_gamma)_infinity<gamma. $
Here $cal(R H)_infinity$ means real-rational, proper, with all poles strictly in the
left half-plane. The lower LFT means that the second output of $K_"par"$ is sent through
$Q_gamma$ and returned at its second input. Its lower-right feedthrough is zero, so
the connection is well posed for proper $Q_gamma$. Setting $Q_gamma=0$ recovers the
central controller. The realized order is at most the plant order plus the parameter order.

#takeaway[Do not confuse this norm-ball parameter with chapter 9's unrestricted Youla
  parameter. Here the parameter makes the *performance constraint* simple; the physical
  closed-loop map is generally fractional, not affine, in it. Chapter 9 uses different
  coordinates to make the stable closed-loop map affine.]

This is the handoff to chapter 8: each fixed-scaling controller step is an $H_infinity$
synthesis problem. The two-Riccati theorem does not itself choose uncertainty scalings
or solve the joint structured robust-performance problem.

#pagebreak()
= Exercise guide: mechanisms before technical details

This guide covers the eleven exercises on pp. 211–216. Exercises 1–5, 8, 10, and 11
have the central algebra worked out below; exercises 6, 7, and the endpoint part of 9
include explicitly identified proof outlines. The technical existence and boundary
arguments are not presented as full proofs. First understand the design route above.

== Exercise 1 — symmetry, reality, and uniqueness of the stabilizing root

Let $X$ solve $A^T X+X A+X R X+Q=0$, initially allowing complex nonsymmetric $X$,
and let $M=A+R X$ be Hurwitz. Subtract the transposed equation. For $Delta=X-X^T$,
$ M^T Delta+Delta M=0. $
Its only solution is zero: $e^(M^T t) Delta e^(M t)$ is constant and tends to zero.
Thus $X=X^T$. If $X_1,X_2$ are symmetric stabilizing solutions, subtraction gives
$ (A+R X_1)^T(X_1-X_2)+(X_1-X_2)(A+R X_2)=0. $
The same exponential argument proves uniqueness, since both coefficient matrices are
Hurwitz. The complex conjugate $bar(X)$ is another symmetric stabilizing solution for
real data, so uniqueness implies $bar(X)=X$. No separate claim about a real Hamiltonian
subspace is needed.

== Exercise 2 — detect hidden unstable modes with the right rank tests

The lemma concerns every $lambda$ in the *closed right half-plane*, not just imaginary
frequencies. Its two tests are full column rank of
$ mat(A-lambda I,B_2;C_1,D_12) $
and full row rank of
$ mat(A-lambda I,B_1;C_2,D_21). $
To see the first test's role, suppose the complete closed-loop matrix has an unstable
or marginal eigenvector $mat(x;eta)$ invisible at $z$. With $u=C_K eta+D_K C_2 x$,
the plant equations give $(A-lambda I)x+B_2 u=0$ and $C_1 x+D_12 u=0$.
Full column rank forces $x=u=0$. Then $A_K eta=lambda eta$ and $C_K eta=0$.
A detectable controller realization excludes such a nonzero $eta$.
The row-rank test, applied dually, excludes modes unreachable from $w$ if the controller
realization is stabilizable. Therefore no closed-right-half-plane mode is hidden from
the $w -> z$ transfer. Minimal controller realizations satisfy both requirements.

With $D_12^+=(D_12^T D_12)^(-1)D_12^T$, eliminate $u$ from the first nullspace equations:
$ (A-B_2 D_12^+ C_1-lambda I)x=0, quad (I-D_12 D_12^+)C_1 x=0. $
That is exactly the PBH detectability test for the pair stated in the exercise. Transposing
gives the stabilizability test with $D_21^+=D_21^T(D_21 D_21^T)^(-1)$.
Do not extend this conclusion to a controller with an arbitrary hidden unstable state.

#pagebreak()
== Exercises 3–5 — why the LQ value is quadratic and obeys an ARE

Let $dot(x)=A x+B u$, $x(0)=xi$, with $(A,B)$ stabilizable, and let
$ q(x,u)=mat(x;u)^T mat(Q,S;S^T,R)mat(x;u), quad Q=Q^T, quad R=R^T>=0. $
Write $J(xi,u)=integral_0^infinity q dif t$ for admissible $u,x in L_2$, and assume
$v(xi)=inf_u J(xi,u)>-infinity$ for every $xi$.

*3(a–c): scaling and concatenation.* The zero trajectory gives $v(0)<=0$. Any negative
cost from zero could be multiplied by arbitrarily large squared amplitude, contradicting
finiteness, so $v(0)=0$. Concatenate a finite trajectory with an $epsilon$-optimal tail:
$ v(x(t_1))<=integral_(t_1)^(t_2) q dif t+v(x(t_2)). $
Taking the infimum over the first segment and using near-optimal complete trajectories
gives equality in the dynamic-programming principle. No optimizer needs to exist.

*3(d): the parallelogram mechanism.* Adding/subtracting two admissible trajectories and
using quadraticity gives
$ v(xi+eta)+v(xi-eta)<=2v(xi)+2v(eta). $
Apply the same construction to near-optimal trajectories from $xi+eta$ and $xi-eta$,
then halve their sum/difference, to obtain the reverse inequality. Scaling also gives
$v(a xi)=a^2 v(xi)$. A fixed stabilizing feedback gives the upper bound
$v(xi)<=c norm(xi)^2$. The nonnegative parallelogram form $c norm(xi)^2-v(xi)$
is bounded on a finite-dimensional unit ball by its values on a basis, supplying
the required local boundedness. Polarization then gives $v(xi)=xi^T K xi$, $K=K^T$.

*4: differentiate the optimality inequality.* The short-time expansion is
$ 0<=q(x,u)+dif/dif t(x^T K x). $
Hence the exercise's block LMI holds. Notice the *plus* sign before the derivative.
For any other symmetric LMI solution $X$, integrate its inequality to obtain
$ xi^T X xi<=integral_0^infinity q dif t, $
since $x(t)->0$ for $x,dot(x) in L_2$. Infimizing gives $X<=K$. Reversing the
derivative inequality would give the wrong conclusion.

*5(a–b): remove cross terms and take a Schur complement.* With $R>0$, put
$ hat(u)=R^(1/2)(u+R^(-1) S^T x), quad tilde(Q)=Q-S R^(-1) S^T. $
Then $q=x^T tilde(Q)x+norm(hat(u))^2$ and
$dot(x)=(A-B R^(-1) S^T)x+B R^(-1/2)hat(u)$. This is a bijection of admissible
pairs and costs. For normalized $S=0,R=I$, the block LMI is equivalent to
$ g(X):=A^T X+X A-X B B^T X+Q>=0. $

*5(c–e): the equality comes from zero residual value.* For the finite-horizon Riccati
solution $P(T)=0$, the correct square identity is
$ integral_0^T (norm(C x)^2+norm(u)^2) dif t
  =xi^T P(0)xi+integral_0^T norm(u+B^T P x)^2 dif t. $
It proves the minimum and its feedback. If that minimum is zero for every initial state,
nonnegativity forces $C xi=0$ for every $xi$, hence $C=0$. Finally factor
$g(K)=C^T C$ and shift to $hat(u)=u+B^T K x$. The original infinite-horizon
value minus $xi^T K xi$ is precisely the infimum of
$integral(norm(C x)^2+norm(hat(u))^2)$. It is zero. Every finite-horizon minimum
is bounded by this nonnegative infinite-horizon infimum, so it too is zero. Thus
$C=0$ and $g(K)=0$: the value matrix satisfies the ARE.

== Exercise 6 — the strong solution is the largest ARI solution (proof outline)

“Strong” permits imaginary-axis eigenvalues of $M=A-B B^T X_s$; “stabilizing” does not.
For $Delta=X-X_s$, subtraction gives
$ g(X)=M^T Delta+Delta M-Delta B B^T Delta>=0. $
If $M$ is strictly Hurwitz, the Lyapunov integral immediately yields $Delta<=0$.
For a merely strong solution that argument is not valid: the integral may not converge.
One must handle the marginal modes using stabilizability, or pass through a vanishing
positive cost regularization. This is the technical step in the book's kernel/modal hint.

A useful alternative proof route is the stabilizing LQ value. Once a strong $X_s$ is
known, completion of squares gives cost
$ xi^T X_s xi+integral_0^infinity norm(u+B^T X_s x)^2 dif t. $
The stabilizable marginal modes of $M$ can be stabilized with arbitrarily small residual
energy, so the infimum is $xi^T X_s xi$. Exercise 4(b) then bounds every ARI solution
by $X_s$. Conversely the maximal ARE solution must be strong: a right-half-plane modal
block would allow an upward ARE perturbation. Thus two strong solutions bound each
other and coincide.

For existence, start from an ARI solution $X_0$, shift the dynamics to
$A-B B^T X_0$, and use nonnegative running state cost $g(X_0)$. The stabilizing LQ
value gives a strong residual solution $Z>=0$; then $X_s=X_0+Z$ solves the original
ARE. Constructing that LQ value as a limit and proving the marginal-mode assertions
are the parts of this outline not reproved here. If $Q>=0$, $X_0=0$ is available and
maximality gives $X_s>=0$.

== Exercise 7 — weak observability hypotheses (proof outline)

The desired control ARE and gain are @eq:controlare and @eq:feedback. Scaling the
disturbance by $1/gamma$ puts the problem at unit bound. If the relevant control-cost
solution is positive definite, the inverse-coordinate argument of section 4 reduces it
to Theorem 7.9. But positivity may fail when stable modes are invisible to $C_1$.
Do not invert a possibly singular solution.

The correct reduction first separates the *stable unobservable* part. In coordinates
isolating that invariant part one has
$ A=mat(A_o,0;A_21,A_s), quad C_1=mat(C_o,0), $
where $A_s$ is Hurwitz for that removed part. Solve on the remaining subsystem and
extend the cost matrix with a zero block on the removed states. The closed-loop and
game stability matrices are triangular with the untouched stable block $A_s$.
This gives a semidefinite solution without an illegal inversion. Any unobservable
unstable modes must remain in the Riccati problem, not be discarded. Completing the
necessity proof uses the corresponding stabilizing Riccati existence theorem.

== Exercise 8 — general control penalties

Let $R_u=D_12^T D_12>0$, $N=C_1^T D_12$, and set
$ u=-R_u^(-1)N^T x+R_u^(-1/2)hat(u). $
Then the state penalty is $C_1^T C_1-N R_u^(-1)N^T$, and applying the normalized
construction yields
$ A^T Y+Y A+gamma^(-2)Y B_1 B_1^T Y+C_1^T C_1
  -(Y B_2+N)R_u^(-1)(B_2^T Y+N^T)=0, $
with $F=-R_u^(-1)(B_2^T Y+N^T)$ and branch matrix
$A+B_2 F+gamma^(-2)B_1 B_1^T Y$. The imaginary-axis pencil condition ensures the
projected state penalty has no invisible marginal modes, so exercise 7 gives the
weaker rank hypothesis asked for. An imaginary-axis invariant zero does *not* make
every closed-loop norm infinite; it makes this particular strict Riccati equivalence
require care. Stable loops can have zeros on that axis.

== Exercise 9 — the Riccati existence boundary is not always the design boundary

Use the inverse coordinate $W(gamma)$ from section 4; this is the exercise's $Y_+(gamma)$.
Let $W_0=W(infinity)$ and $M_0=A+W_0 C_1^T C_1$, which is anti-Hurwitz.
For $E=W_0-W(gamma)$, subtract the two inverse AREs:
$ (-M_0)E+E(-M_0)^T+E C_1^T C_1 E+gamma^(-2)B_1 B_1^T=0. $
This is the dual Bounded Real ARE for the *stable* residual system with state matrix
$-M_0$. Its stabilizing branch corresponds to the anti-stabilizing branch for $W$.
It identifies the boundary
$ gamma_"min"=norm(C_1(s I+A+W_0 C_1^T C_1)^(-1)B_1)_infinity. $
The printed exercise places $W_0$ on the other side of $C_1^T C_1$. The subtraction
above fixes the matrix order; the two orders need not agree. The executable example
checks this with noncommuting 2×2 matrices rather than a scalar case.

Inside the open domain, differentiating the inverse ARE gives
$ M_gamma dot(W)+dot(W) M_gamma^T=2gamma^(-3)B_1 B_1^T,
  quad M_gamma=A+W(gamma)C_1^T C_1. $
Since $M_gamma$ is anti-Hurwitz,
$ dot(W)=integral_0^infinity e^(-M_gamma t)(2gamma^(-3)B_1 B_1^T)e^(-M_gamma^T t) dif t>=0. $
The Lyapunov operator is invertible there, also giving smoothness.

*Endpoint interpretation and proof outline.* The inverse ARE exists on
$(gamma_"min",infinity)$, but state-feedback feasibility additionally needs $W(gamma)>0$.
The endpoint symbols in parts (c–e) must be read as appropriate one-sided limits, not
as a claim that the branch matrix stays strictly anti-Hurwitz there. If the lower
endpoint limit is positive definite, its finite gain can attain the *non-strict*
optimal norm. If positivity first becomes possible at a singular limit, the infimal
state-feedback gains must become unbounded under the exercise's hypotheses. The proof
uses a bounded-subsequence argument plus a separate stabilization of the limiting
marginal modes; continuity of eigenvalues alone is not enough. That boundary proof
is not reconstructed here.

Our scalar plant illustrates the first case for *state feedback*: $W_0=1+sqrt(2)$,
$M_0=sqrt(2)$, $gamma_"min"=1/sqrt(2)$, and the endpoint $W=1$ gives the finite
optimal gain $F=-1$. The output-feedback central family, by contrast, meets a *coupling*
boundary at the larger $sqrt(3)-1$. These are different obstacles.

== Exercise 10 — the general ARIs and a correct large-storage argument

At bound one let $D_c=(D_12^T D_12)^(-1)D_12^T$ and
$D_r=D_21^T(D_21 D_21^T)^(-1)$. Normalize the control penalty as in exercise 8
and normalize the dual measurement penalty. The two *inverse-coordinate* ARIs are
$ A_u Y+Y A_u^T+Y Q_u Y+R_u<0, $
$ A_y^T X+X A_y+X Q_y X+R_y<0, $
where
$ A_u=A-B_2 D_c C_1, quad Q_u=C_1^T(I-D_12 D_c)C_1, $
$ R_u=B_1 B_1^T-B_2(D_12^T D_12)^(-1)B_2^T, $
$ A_y=A-B_1 D_r C_2, quad Q_y=B_1(I-D_r D_21)B_1^T, $
$ R_y=C_1^T C_1-C_2^T(D_21 D_21^T)^(-1)C_2. $
Together with $X>0$, $Y-X^(-1)>0$, these are the exercise's general two-ARI
criterion. Here $X,Y$ are *not* the $X_infinity,Y_infinity$ coordinates of Theorem
7.13. The displayed products also correct dimensionally inconsistent transposes in
the printed second inequality. Completing squares derives the terms; the two-ARI
output-feedback theorem supplies the existence/construction equivalence.

*Part (b), fully.* Given Hurwitz $A$ and symmetric $Q$, solve
$ A^T H+H A=-I, quad A^T X_0+X_0 A=-Q. $
Then $H>0$, and $X=X_0+t H$ satisfies
$ A^T X+X A+Q=-t I<0. $
For sufficiently large $t>0$, it also satisfies $X>alpha I$ for any prescribed real
$alpha$. Adding $t I$ instead is not valid: Hurwitz does not imply $A+A^T<0$.
For example $A=mat(-1,10;0,-2)$ is Hurwitz but its symmetric part has a positive
eigenvalue. This asymmetric example is checked in the script.

*Part (c).* If $D_21$ is square, $Q_y=0$. If $A_y$ is Hurwitz, part (b) supplies
arbitrarily large positive $X$ satisfying its now-linear ARI. For any fixed $Y>0$
solving the control ARI, choose $X>Y^(-1)$; then $X^(-1)<Y$, so coupling also
holds. Only the control-side inequality remains to be tested.

== Exercise 11 — unstable zeros become interpolation constraints

Use $P=mat(h,-g;1,0)$ so that $P star.op f=h-g f$. Since this is a stable feedforward
plant, internal stability amounts to $f in cal(R H)_infinity$. If $e=h-g f$, every
right-half-plane zero $z_j$ of $g$ enforces $e(z_j)=h(z_j)$: a stable $f$ cannot
cancel that condition with an unstable pole. Conversely a stable proper $e$ satisfying
these interpolation conditions makes $f=(h-e)/g$ stable and proper, because $g(infinity)=1$
and the only inverse poles are its stated simple right-half-plane zeros.

The strict scalar Nevanlinna–Pick criterion for an error norm below $gamma$ is
$ cal(P)_(j k)=(gamma^2-h(z_j) overline(h(z_k)))/(z_j+overline(z_k)),
  quad cal(P)>0. $ <eq:pick>
At $gamma=1$ this is the exercise's matrix. The remaining argument connects it to
the Lyapunov equation, rather than asserting that a fixed-controller norm LMI by
itself solves model matching.

Choose modal coordinates for the inverse-zero matrix
$ A_0=A_g-B_g C_g="diag"(z_1,dots,z_k), quad B_g=bb(1). $
Simple zeros and minimality allow this normalization; use conjugate modal coordinates
for nonreal zeros, with Hermitian products rather than real transposes. The Sylvester
equation
$ A_0 U-U A_h=B_g C_h $
gives row by row $e_j^T U=C_h(z_j I-A_h)^(-1)$, hence
$e_j^T U B_h=h(z_j)$. The Lyapunov equation for the general bound is
$ A_0 V+V A_0^*=gamma^2 B_g B_g^*-U B_h B_h^* U^*. $
In entries this is
$ (z_j+overline(z_k))V_(j k)=gamma^2-h(z_j)overline(h(z_k)), $
so $V=cal(P)$. Since $A_0$ is anti-Hurwitz, its Lyapunov solution is unique.
Thus the positivity criterion on $V$ in part (b) is exactly the Pick test in part (e).
The associated single Lyapunov *inequality* may be written
$ A_0 V+V A_0^*-(gamma^2 B_g B_g^*-U B_h B_h^* U^*)<0, quad V>0. $
It is feasible iff the equality solution is positive: subtract its small positive
anti-Hurwitz Lyapunov solution for one direction; compare the equality and inequality
solutions by the Lyapunov integral for the other. The interpolation theorem is the
nontrivial sufficiency result being invoked here, not an elementary algebraic identity.

*One zero, exact answer.* Let $g=(s-1)/(s+1)$ and $h=2/(s+2)$. Then $e(1)=2/3$.
Every stable error has $norm(e)_infinity>=|e(1)|=2/3$, while
$ f=-2(s+1)/(3(s+2)) quad ==> quad h-g f=2/3. $
This stable proper $f$ attains the non-strict optimum. The Pick entry is
$(gamma^2-4/9)/2$, positive precisely for strict bounds $gamma>2/3$. The boundary
matrix is singular even though a finite optimal matching filter exists. Again, a
strict feasibility test is not a theorem that the non-strict optimum is unattainable.

= Keep the design logic in view

Signals and weights define “good.” Storage certifies energy gain. Completing squares
extracts feedback; duality gives estimation; coupling joins them. Finally check the
full internal dynamics and the achieved norm, not just the requested certificate level.

== Reproduce the examples

From the repository root, using Octave's installed `control` package:
```sh
octave --no-gui --quiet \
  Control/robust-control-07-hinf-synthesis/scripts/hinf_example.m
```
This checks the scalar storage example, branch/coupling boundaries, bisection, physical
loop formulas, and selected exercise calculations, regenerates the figure, and checks
the analytic optimum against `hinfsyn`. Norms use a continuous-system algorithm with
explicit tolerance, not only a frequency grid.

#text(size: 9.5pt)[
*Source.* Scherer, chapter 7, pp. 159–216, especially §§7.3, 7.6–7.11, Theorems 7.13
and 7.40, and the eleven exercises, @schererTheoryRobustControl. Examples and teaching
derivations are developed here. This is not a reproduction of every technical proof;
the outline labels identify the main omissions.

#bibliography("refs.bib", title: none)
]
