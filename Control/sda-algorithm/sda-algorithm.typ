#set document(title: "The Structure-Preserving Doubling Algorithm", author: "Amp")
#set page(paper: "a4", margin: (x: 22mm, y: 20mm), numbering: "1",
  header: context if counter(page).get().first() > 1 {
    text(size: 9pt, fill: rgb("667085"))[SDA / Riccati equations and horizon doubling]
  })
#set text(font: "Libertinus Serif", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("16324f"))
#show raw: set text(font: "DejaVu Sans Mono", size: 8.5pt)
#let takeaway(body) = block(width: 100%, inset: 10pt,
  fill: rgb("eef6f5"), stroke: (left: 3pt + rgb("157f78")), body)

#text(size: 10pt, fill: rgb("157f78"))[CONTROL THEORY · NUMERICAL LINEAR ALGEBRA]
#v(7pt)
#text(size: 26pt, weight: "bold", fill: rgb("16324f"))[
  The Structure-Preserving\ Doubling Algorithm
]
#v(5pt)
#text(size: 13pt)[Solve a Riccati equation by joining optimal-control blocks]
#v(12pt)
#takeaway[
  Ordinary Riccati iteration adds one time step. SDA joins a block to a copy of
  itself, eliminates their shared boundary, and doubles the effective horizon:
  $1, 2, 4, 8, dots$. The acceleration is a consequence of exact composition.
]

= The problem: how much does the future cost?

Consider the time-invariant, discrete-time linear-quadratic regulator (LQR):
$ x_(t+1) = A x_t + B u_t, quad
  J = 1/2 sum_(t=0)^infinity (x_t^T Q x_t + u_t^T R u_t). $
Here $x_t in bb(R)^n$, $u_t in bb(R)^m$, $Q=Q^T succ.eq 0$, and
$R=R^T succ 0$. The optimal infinite-horizon value is
$V(x)=1/2 x^T P x$. Bellman's principle gives the discrete-time algebraic
Riccati equation (DARE):
$ P = Q + A^T P A - A^T P B (R+B^T P B)^(-1) B^T P A. $ <dare>
We assume $(A,B)$ is stabilizable and $(Q^(1/2),A)$ is detectable. These
standard sufficient conditions ensure a unique positive-semidefinite stabilizing
solution. “Stabilizing” means that the feedback
$ K=(R+B^T P B)^(-1) B^T P A, quad u=-K x $
makes $A-B K$ Schur: all its eigenvalues have modulus less than one.

Set $G=B R^(-1) B^T$. Eliminating the control, or using the matrix inversion
lemma, rewrites @dare as
$ P=Q+A^T P(I+G P)^(-1) A. $ <compact>
Order matters: these are matrices, not scalars. In particular,
$P(I+G P)^(-1)=(I+P G)^(-1)P$.

For a finite horizon of $N$ stages and *zero terminal cost*, let $P_N$ be its
value matrix. Then $P_0=0$ and
$ P_(N+1)=Q+A^T P_N (I+G P_N)^(-1) A. $
Thus ordinary iteration computes horizons $1,2,3,dots$. SDA will compute
$P_1,P_2,P_4,P_8,dots$ without visiting every intermediate horizon.

#pagebreak()
= From optimal-control conditions to doubling

We will derive the state–costate equations from the constrained finite-horizon
LQR problem. The costates are unknown Lagrange multipliers, determined along
with the states and inputs. No terminal price is prescribed, and no part of
the terminal cost is discarded.

== State the finite-horizon problem and its full Lagrangian

Fix $x_0$. Choose the inputs $u_0,dots,u_(N-1)$ and states $x_1,dots,x_N$
to minimize
$ J_N=1/2 sum_(t=0)^(N-1) (x_t^T Q x_t+u_t^T R u_t)
  +1/2 x_N^T F x_N, quad F=F^T succ.eq 0, $ <finite-cost>
subject to $x_(t+1)=A x_t+B u_t$ for $t=0,dots,N-1$. The last term is
the *actual terminal cost*. Set $F=0$ for the zero-terminal-cost problem
whose value matrix is $P_N$ in Section 1. A nonzero $F$ lets us see explicitly
where the terminal boundary condition comes from.

Introduce a multiplier $lambda_(t+1)$ for each dynamics constraint. With the
sign convention $A x_t+B u_t-x_(t+1)=0$, the *full* Lagrangian is
$ cal(L)=J_N+sum_(t=0)^(N-1)
  lambda_(t+1)^T (A x_t+B u_t-x_(t+1)). $ <lagrangian>
Every constraint residual appears in full, including $-x_(t+1)$. On feasible
trajectories these residuals vanish, so $cal(L)=J_N$.

*Step 1: vary the input.* Only the input cost and its own dynamics residual
depend on $u_t$, so stationarity gives
$ nabla_(u_t) cal(L)=R u_t+B^T lambda_(t+1)=0. $ <stationarity>

*Step 2: vary an interior state.* For $1<=t<=N-1$, $x_t$ appears in three
places: its stage cost, the preceding residual through $-lambda_t^T x_t$,
and the following residual through $lambda_(t+1)^T A x_t$. Therefore
$ nabla_(x_t) cal(L)=Q x_t-lambda_t+A^T lambda_(t+1)=0, $
or $lambda_t=Q x_t+A^T lambda_(t+1)$. This is the *costate recursion*.

*Step 3: vary the terminal state.* There is no stage cost or outgoing
dynamics residual at $t=N$. The terms involving $x_N$ are
$1/2 x_N^T F x_N-lambda_N^T x_N$, giving
$ nabla_(x_N) cal(L)=F x_N-lambda_N=0
  quad ==> quad lambda_N=F x_N. $ <terminal>

*Step 4: vary each multiplier.* This recovers every dynamics constraint:
$ nabla_(lambda_(t+1)) cal(L)=A x_t+B u_t-x_(t+1)=0. $
Together, these equations determine the solution. After eliminating the
states, the objective is strictly convex in the input sequence because
$R succ 0$ and $Q,F succ.eq 0$. Thus these first-order conditions are also
sufficient for the unique optimal input sequence.

#pagebreak()
== Interpret the costate and retain both boundary conditions

The state equation propagates forward, but the costate recursion propagates
backward from @terminal. The boundary conditions are
$ x_0="given", quad lambda_N=F x_N. $
For $F=0$, the terminal condition is $lambda_N=0$; for $F!=0$, neither
$x_N$ nor $lambda_N$ is generally known beforehand. They must be solved
consistently with all the other equations.

Let $V_t (x_t)$ be the optimal remaining cost from time $t$. Bellman's principle
and stationarity imply $lambda_t=nabla V_t (x_t)$ along the optimum. In
particular, the initial value sensitivity is
$ lambda_0:=nabla V_0(x_0)=Q x_0+A^T lambda_1. $ <one-step-costate>
There is no multiplier for a dynamics constraint ending at $x_0$ in
@lagrangian: $x_0$ is fixed. Here $lambda_0$ is defined as a sensitivity,
not obtained by imposing $nabla_(x_0) cal(L)=0$. Differentiating the optimized
Lagrangian with respect to that initial-state parameter gives the expression
above. The costate is therefore a gradient of optimal cost, not a second
physical state.

#takeaway[
  A partial derivative of the Lagrangian treats states, inputs, and multipliers
  as independent variables. It does *not* require that the dynamics remain
  satisfied during that variation. Feasibility is imposed by the multiplier
  equations, and all stationarity and boundary conditions must hold together.
  If instead $x_1$ is fixed while enforcing $x_1=A x_0+B u_0$, the feasible
  inputs are restricted; when $B=1$, $u_0=x_1-A x_0$ is already determined.
]

== Eliminate the input, not the terminal condition

From @stationarity, $u_t=-R^(-1)B^T lambda_(t+1)$. Substitution into
the dynamics gives, with $G=B R^(-1)B^T$,
$ x_(t+1)=A x_t-G lambda_(t+1), quad
  lambda_t=Q x_t+A^T lambda_(t+1). $ <one-step-state>
These are the discrete-time state–costate optimality equations after input
elimination: the discrete-time Pontryagin conditions for LQR. For a single
step, the terminal condition is $lambda_1=F x_1$.
Substitute it into the first equation:
$ (I+G F)x_1=A x_0, quad x_1=(I+G F)^(-1)A x_0. $
The second then gives
$ lambda_0=[Q+A^T F(I+G F)^(-1)A]x_0. $
Thus the one-step value matrix is $Q+A^T F(I+G F)^(-1)A$: the Riccati
update with downstream value matrix $F$. Both the dynamics constraint and
the actual terminal cost have been retained.

#pagebreak()

== Join two steps and eliminate their shared boundary

The first step and the second step obey, respectively,
$ x_1=A x_0-G lambda_1, quad lambda_0=Q x_0+A^T lambda_1, $
$ x_2=A x_1-G lambda_2, quad lambda_1=Q x_1+A^T lambda_2. $
These are consecutive equations from the *same* optimal-control problem,
with terminal condition $lambda_2=F x_2$. The interior multiplier $lambda_1$
is shared because it belongs to the constraint ending at $x_1$; it is also
the costate at the beginning of the second step. We will eliminate the
interior pair $(x_1,lambda_1)$, while leaving the terminal condition intact.

*Step 1: eliminate the interior costate.* Substitute the second step's
$lambda_1$ into the first step's state equation:
$ x_1=A x_0-G(Q x_1+A^T lambda_2)
  =A x_0-G Q x_1-G A^T lambda_2. $
Set $W=I+G Q$ and collect the $x_1$ terms:
$ W x_1=A x_0-G A^T lambda_2, quad
  x_1=W^(-1)A x_0-W^(-1)G A^T lambda_2. $

*Step 2: substitute into the terminal state equation.*
$ x_2=A x_1-G lambda_2
  =(A W^(-1)A)x_0-(G+A W^(-1)G A^T)lambda_2. $
Thus define $E_2=A W^(-1)A$ and $G_2=G+A W^(-1)G A^T$.

*Step 3: substitute into the initial costate equation.* First,
$ lambda_0=Q x_0+A^T (Q x_1+A^T lambda_2). $
After replacing $x_1$ and collecting terms,
$ lambda_0=(Q+A^T Q W^(-1)A)x_0
  +A^T (I-Q W^(-1)G)A^T lambda_2. $
Define $H_2=Q+A^T Q W^(-1)A$. The terminal-costate coefficient simplifies via
$ I-Q W^(-1)G=(I+Q G)^(-1), quad
  A^T (I+Q G)^(-1)A^T=E_2^T. $
The inverse identity is proved in Section 2.7. The two-step block has the
*same shape* as one step:
$ x_2=E_2 x_0-G_2 lambda_2, quad lambda_0=H_2 x_0+E_2^T lambda_2. $
*Close the boundary-value problem.* We have not solved the original
optimization until we also impose $lambda_2=F x_2$. Thus
$ x_2=(I+G_2 F)^(-1)E_2 x_0, $
$ lambda_0=[H_2+E_2^T F(I+G_2 F)^(-1)E_2]x_0. $
For $F=0$, this reduces to $lambda_0=H_2 x_0$, so $H_2=P_2$.

#pagebreak()
== See the two-step elimination in numbers

Use the running scalar example $A=1.1$, $B=Q=R=1$, so $G=1$.
At the shared boundary,
$ x_1=1.1 x_0-lambda_1, quad lambda_1=x_1+1.1 lambda_2. $
Substitute the second equation into the first:
$ x_1=1.1 x_0-x_1-1.1 lambda_2
  quad ==> quad x_1=0.55 x_0-0.55 lambda_2. $
Recover the terminal state:
$ x_2=1.1 x_1-lambda_2
  =0.605 x_0-1.605 lambda_2. $
Recover the initial costate, using $lambda_1=x_1+1.1 lambda_2$:
$ lambda_0=x_0+1.1 lambda_1
  =x_0+1.1(x_1+1.1 lambda_2)
  =1.605 x_0+0.605 lambda_2. $
So the whole two-step problem is summarized by
$ E_2=0.605, quad G_2=1.605, quad H_2=1.605. $
The interior variables $x_1,lambda_1$ have disappeared. If there is no terminal
cost, $lambda_2=0$; then $lambda_0=1.605 x_0$ and the optimized two-step
value is $V_2(x_0)=1/2 dot 1.605 x_0^2$. This is why $H_2$ is the
finite-horizon Riccati solution, not just an arbitrary coefficient.

For a nonzero terminal weight, take $x_0=1$ and $F=1$. The terminal
condition is $lambda_2=x_2$, not an independently chosen multiplier.
The condensed equations give
$ x_2=0.605-1.605 x_2
  quad ==> quad x_2=0.605/2.605 approx 0.232246, $
$ lambda_0=1.605+0.605 x_2 approx 1.745509. $
This explicitly closes the two-step optimal-control problem with its
quadratic terminal cost.

== Only now introduce the general block

One optimized step has a linear boundary relation. We have shown that joining
two steps and eliminating the shared boundary preserves its form. Repeating
the same operation joins two two-step blocks into a four-step block, then two
four-step blocks into an eight-step block. This motivates the notation
$ x_N=E_N x_0-G_N lambda_N, quad
  lambda_0=H_N x_0+E_N^T lambda_N. $ <block>
These are *boundary relations*, not an uncontrolled forward state transition:
they condense the state–costate equations by eliminating interior variables.
They must still be combined with the original endpoint conditions
$x_0="given"$ and $lambda_N=F x_N$. Leaving $lambda_N$ symbolic during
elimination does not make it a prescribed terminal price.

- $E_N$ transmits the initial state across the optimized block.
- $G_N$ couples the terminal costate to the terminal state.
- $H_N$ is the initial value curvature when $lambda_N=0$.

For zero terminal cost, $lambda_N=0$ and $lambda_0=H_N x_0$. But the
zero-terminal-cost optimal value is $1/2 x_0^T P_N x_0$, whose gradient is
$P_N x_0$. Therefore $H_N=P_N$. The one-step coefficients are
$(E_1,G_1,H_1)=(A,B R^(-1)B^T,Q)$, directly from
@one-step-state and @one-step-costate.

#takeaway[
  A block is a condensed system of optimality equations, not a replacement
  objective. SDA eliminates interior states and costates while retaining the
  original endpoint conditions. For zero terminal cost, $lambda_N=0$ and
  the block coefficient $H_N$ is the finite-horizon value matrix $P_N$.
]

#pagebreak()
== Derive the three doubling updates without skipping the algebra

For a current $N$-step block, temporarily write its coefficients as $(E,G,H)$;
here $G$ is the *current block coefficient*, not necessarily the original
$B R^(-1)B^T$. Two identical copies of @block give
$ x_N=E x_0-G lambda_N, quad lambda_0=H x_0+E^T lambda_N, $
$ x_(2N)=E x_N-G lambda_(2N), quad
  lambda_N=H x_N+E^T lambda_(2N). $
*Step 1: eliminate the shared costate, just as for two steps.*
$ x_N=E x_0-G(H x_N+E^T lambda_(2N)). $
With $W=I+G H$, collect terms:
$ (I+G H)x_N=E x_0-G E^T lambda_(2N). $ <midpoint>
Thus $x_N=W^(-1)E x_0-W^(-1)G E^T lambda_(2N)$.

*Step 2: collect the two coefficients in the terminal state.*
$ x_(2N)=E x_N-G lambda_(2N)
  =(E W^(-1)E)x_0-(G+E W^(-1)G E^T)lambda_(2N). $
Reading off the coefficients gives $E_+=E W^(-1)E$ and
$G_+=G+E W^(-1)G E^T$.

*Step 3: collect the two coefficients in the initial costate.*
$ lambda_0=H x_0+E^T (H x_N+E^T lambda_(2N)) $
$ lambda_0=(H+E^T H W^(-1)E)x_0
  +E^T (I-H W^(-1)G)E^T lambda_(2N). $
Hence $H_+=H+E^T H W^(-1)E$. To identify the remaining coefficient as
$E_+^T$, we need two identities, not commutativity.

*Step 4: justify the inverse identities.* First,
$ (I+G H)G=G(I+H G)
  quad ==> quad W^(-1)G=G(I+H G)^(-1). $
This follows by multiplying on the left by $W^(-1)$ and on the right by
$(I+H G)^(-1)$. Next, insert this identity and use
$H G=(I+H G)-I$:
$ I-H W^(-1)G
  =I-H G(I+H G)^(-1)=(I+H G)^(-1). $
Since $G,H$ are symmetric, $W^T=I+H G$, so the terminal-costate coefficient
in $lambda_0$ is $E^T W^(-T)E^T=(E W^(-1)E)^T=E_+^T$.
The new block again has form @block, with the standard SDA updates
$ E_+=E(I+G H)^(-1)E, quad
  G_+=G+E G(I+H G)^(-1)E^T, $
$ H_+=H+E^T H(I+G H)^(-1)E. $ <updates>

#takeaway[
  Initialize $(E_0,G_0,H_0)=(A,B R^(-1)B^T,Q)$ and apply these updates
  simultaneously. We now switch notation: the subscript $k$ indexes
  *doublings*, not horizon length. Iteration $0$ represents one step;
  iteration $k$ represents $2^k$ steps, so $H_k=P_(2^k)$.
  The zero terminal condition is imposed only at the end of the *whole*
  horizon, not at the internal boundary between its two halves.
]

#pagebreak()
= What structure survives the doubling?

== Symmetry, positivity, and a monotone value

Suppose $G,H$ are symmetric positive semidefinite. Although $I+G H$ need not
be symmetric, it is nonsingular: $G H$ has nonnegative real eigenvalues
(its nonzero eigenvalues coincide with those of $H^(1/2)G H^(1/2)$).
Moreover,
$ H(I+G H)^(-1)
  =H^(1/2)(I+H^(1/2)G H^(1/2))^(-1)H^(1/2) succ.eq 0. $
This identity remains valid for singular $H$; no inverse of $H$ is needed.
The analogous identity holds for $G(I+H G)^(-1)$. Therefore @updates preserves
symmetry and positivity, and
$ H_+ succ.eq H, quad G_+ succ.eq G. $
The first inequality has an optimal-control interpretation: adding nonnegative
stage costs cannot reduce the zero-terminal-cost optimal value. Under our LQR
assumptions, $H_k$ increases to the stabilizing $P$.

== The symplectic connection, without assuming invertible dynamics

Let $J=mat(0,I;-I,0)$, and write the boundary relation as a matrix pencil:
$ M mat(x_0;lambda_0)=L mat(x_N;lambda_N), quad
  M=mat(E,0;-H,I), quad L=mat(I,G;0,E^T). $
For symmetric $G,H$, direct multiplication gives
$ M J M^T=L J L^T=mat(0,E;-E^T,0). $
This is the symplectic matrix-pair structure that the doubling retains in exact
arithmetic. If $E$ is invertible, $S=L^(-1)M$ is an ordinary symplectic
state–costate transition: $S^T J S=J$. The pair formulation and SDA still make
sense when $E$ is singular; forming that transition is unnecessary.

== Why convergence accelerates

The discrete Riccati map has derivative at its stabilizing solution
$ D cal(F)_P[Delta]=A_c^T Delta A_c, quad
  A_c=(I+G P)^(-1)A=A-B K. $
Since $A_c$ is Schur, ordinary iteration converges geometrically asymptotically.
For any fixed $r$ with $rho(A_c)<r<1$, sufficiently large horizons admit a
bound of the form $norm(P-P_N)<=C r^(2N)$. Sampling at $N=2^k$ gives
$ norm(P-H_k)<=C r^(2 dot 2^k). $
This explains the quadratic-type convergence in the doubling index; a bound
alone is not an exact error recurrence. The formal SDA convergence analysis is
given in Section 2 of @chu2004. Modes close to the unit circle can delay the
fast asymptotic regime. Structure preservation is not a guarantee of perfect
conditioning or of exact symmetry in floating-point arithmetic.

#pagebreak()
= A scalar example you can check by hand

Take $A=1.1$, $B=Q=R=1$. Then $G=1$ and
$ p=1+(1.21p)/(1+p), quad p^2-1.21p-1=0. $
The positive solution is
$ p_star=(1.21+sqrt(1.21^2+4))/2=1.773770721741 dots $
Its closed-loop multiplier is $1.1/(1+p_star) approx 0.39657$, inside the unit
circle. The negative root is not the stabilizing solution.

Write the scalar SDA variables as $(e,g,h)$. Each iteration uses
$ d=1+g h, quad e_+=e^2/d, quad
  g_+=g+e^2 g/d, quad h_+=h+e^2 h/d. $
Starting at $(1.1,1,1)$, the first update is
$(e_+,g_+,h_+)=(0.605,1.605,1.605)$. The next $h$ is
$1.605+0.605^2 dot 1.605/(1+1.605^2) approx 1.769280206374$.

#figure(
  table(columns: (auto, auto, 1fr, 1fr), align: (center, center, right, right),
    inset: 7pt, stroke: (bottom: 0.4pt + rgb("d5dde5")),
    table.header([*Iteration*], [*Horizon*], [*$H_k$*], [*Absolute error*]),
    [0], [1], [1.000000000000], [$7.738 times 10^(-1)$],
    [1], [2], [1.605000000000], [$1.688 times 10^(-1)$],
    [2], [4], [1.769280206374], [$4.491 times 10^(-3)$],
    [3], [8], [1.773767969365], [$2.752 times 10^(-6)$],
    [4], [16], [1.773770721740], [$1.030 times 10^(-12)$],
    [5], [32], [1.773770721741], [$2.220 times 10^(-16)$],
  ),
  caption: [Double-precision Octave results. After five doublings the error
    reaches the floating-point floor; further squaring cannot add reliable digits.],
)

*A visual measure: correct decimal digits.* The bar length below represents
$-log_10(abs(p_star-H_k))$, capped at 16. Each iteration eventually gains
roughly twice as many digits, until rounding dominates.
#v(5pt)
#for (k, digits) in ((0, 0.11), (1, 0.77), (2, 2.35), (3, 5.56), (4, 11.99), (5, 15.65)) {
  grid(columns: (40pt, 1fr, 45pt), column-gutter: 7pt,
    align(right)[$k=#k$],
    block(width: digits / 16 * 100%, height: 12pt, fill: rgb("157f78")),
    text(size: 9pt)[#digits],
  )
  v(5pt)
}
#v(4pt)
The speedup is in *iteration count*, not in matrix size. In the dense case,
each doubling still requires $O(n^3)$ arithmetic and $O(n^2)$ storage.

#pagebreak()
= Implementation: solve systems and check the original problem

The following Octave/MATLAB loop implements @updates. The transpose solve
uses $(I+G H)^T=I+H G$; it does not assume $G H=H G$.

```matlab
G = B * (R \ B'); H = Q; E = A;
G0 = G; n = size(A, 1); converged = false;
tol = 1e-12; maxit = 50;
for k = 1:maxit
    W = eye(n) + G*H;
    U = W \ E;
    V = W' \ E';
    En = E*U;
    Gn = G + E*G*V;
    Hn = H + E'*H*U;
    % All right-hand sides above use OLD E, G, H.
    E = En; G = Gn; H = Hn;
    % Remove only roundoff-level antisymmetric components.
    G = (G+G')/2; H = (H+H')/2;
    T = A'*H*((eye(n)+G0*H) \ A);
    residual = norm(Q + T - H, 'fro');
    scale = max(1, norm(Q,'fro') + norm(T,'fro') ...
                   + norm(H,'fro'));
    K = (R+B'*H*B) \ (B'*H*A);
    stable = max(abs(eig(A-B*K))) < 1;
    if residual/scale < tol && stable
        converged = true; break;
    end
end
if ~converged, error('SDA failed validation'); end
P = H;
```

*Why these checks?* A small increment can mean convergence or stagnation.
The residual tests the original DARE, while the stability check distinguishes
the stabilizing solution from other algebraic solutions. A small residual is
not a forward-error certificate for an ill-conditioned problem; near-unit-circle
eigenvalues also need a more careful stability assessment than this teaching loop.
Symmetrization removes rounding noise, not an incorrect matrix ordering.

*A noncommuting check.* With
$ A=mat(1.1,0.3;0,0.95), quad B=mat(0.2;1), quad
  Q=mat(2,0.4;0.4,1), quad R=0.7, $
eight raw SDA updates (without symmetrization) gave a Frobenius difference of
$2.2 times 10^(-15)$ from Octave's `dare` solution and an absolute compact-form
residual of $6.3 times 10^(-16)$. Unlike the scalar example, this checks matrix order.

*Scope.* These formulas are for the standard positive-semidefinite DARE.
Continuous-time, indefinite, descriptor, and large sparse problems need suitable
transformations or specialized variants, not blind reuse of this initialization.

#bibliography("refs.bib", title: "Further reading", style: "ieee")
