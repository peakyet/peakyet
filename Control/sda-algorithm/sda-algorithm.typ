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
= The missing object: a block with two boundary variables

Before introducing a block formula, we will derive it from a one-step
optimization problem. No prior knowledge of costates is needed.

== One decision, with a price on the terminal state

We know $x_0$, choose $u_0$, and obtain $x_1=A x_0+B u_0$. Besides the
stage cost, the next state may incur costs later. To understand how a later
cost influences this decision, first attach a simple *linear terminal cost*
$lambda_1^T x_1$, with $lambda_1 in bb(R)^n$ prescribed. Define
$ W_1(x_0;lambda_1)=min_(u_0) [
  1/2 x_0^T Q x_0+1/2 u_0^T R u_0
  +lambda_1^T(A x_0+B u_0)]. $ <one-step-cost>
The vector $lambda_1$ is a terminal *price*: changing $x_1$ by $delta x_1$
changes this terminal cost by $lambda_1^T delta x_1$. A positive price in a
direction encourages an input that reduces the terminal state in that
direction. The linear cost is a device for describing the boundary response;
we have not replaced the infinite-horizon objective by a linear objective.

*Step 1: optimize the input.* Differentiate the bracket in @one-step-cost
with respect to $u_0$, holding $x_0$ and $lambda_1$ fixed:
$ R u_0+B^T lambda_1=0
  quad ==> quad u_0^star=-R^(-1)B^T lambda_1. $
Since $R succ 0$, the objective is strictly convex in $u_0$, so this stationary
point is its unique minimizer. Substitute into the dynamics:
$ x_1=A x_0+B u_0^star
  =A x_0-B R^(-1)B^T lambda_1
  =A x_0-G lambda_1. $ <one-step-state>
This is the first boundary equation: *dynamics plus optimality*.

*Step 2: ask how the optimized cost changes with the initial state.*
Substituting $u_0^star$ into @one-step-cost gives
$ W_1(x_0;lambda_1)=1/2 x_0^T Q x_0
  +lambda_1^T A x_0-1/2 lambda_1^T G lambda_1. $
The last term comes from adding the input cost
$+1/2 lambda_1^T G lambda_1$ and the input-dependent terminal cost
$-lambda_1^T G lambda_1$. Define the initial marginal cost by
$ lambda_0:=nabla_(x_0) W_1(x_0;lambda_1)
  =Q x_0+A^T lambda_1. $ <one-step-costate>
“Costate” is the name for this marginal-cost vector; it is not another
physical state. Both equations are now derived, not assumed:

#takeaway[
  Given the initial state $x_0$ and terminal price $lambda_1$, optimality gives
  $ x_1=A x_0-G lambda_1, quad lambda_0=Q x_0+A^T lambda_1. $
  They describe how one optimized step relates its two boundaries.
]

#pagebreak()
== Recover the Riccati update from a quadratic downstream cost

Suppose the actual downstream value is $V_"next"(x_1)=1/2 x_1^T P x_1$.
Its gradient is $lambda_1=P x_1$. This price is now *unknown until we find
the optimal terminal state*. The stationarity equations still apply: by the
chain rule, differentiating $V_"next"(A x_0+B u_0)$ with respect to $u_0$
gives $B^T P x_1=B^T lambda_1$.

Close the boundary relation with $lambda_1=P x_1$:
$ x_1=A x_0-G P x_1
  quad ==> quad x_1=(I+G P)^(-1)A x_0. $
Then @one-step-costate becomes
$ lambda_0=[Q+A^T P(I+G P)^(-1)A]x_0. $
The coefficient is exactly the Riccati update in Section 1. We are writing
the same optimization in a more flexible form: before choosing the downstream
cost, leave its gradient as a boundary variable.

== Join two steps and eliminate their shared boundary

The first step and the second step obey, respectively,
$ x_1=A x_0-G lambda_1, quad lambda_0=Q x_0+A^T lambda_1, $
$ x_2=A x_1-G lambda_2, quad lambda_1=Q x_1+A^T lambda_2. $
The same $lambda_1$ appears in both: the second step's optimized cost is the
downstream cost seen by the first step. Its derivative with respect to $x_1$
is precisely the price the first step needs.

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
$ lambda_0=Q x_0+A^T(Q x_1+A^T lambda_2). $
After replacing $x_1$ and collecting terms,
$ lambda_0=(Q+A^T Q W^(-1)A)x_0
  +A^T(I-Q W^(-1)G)A^T lambda_2. $
Define $H_2=Q+A^T Q W^(-1)A$. The terminal-price coefficient simplifies via
$ I-Q W^(-1)G=(I+Q G)^(-1), quad
  A^T(I+Q G)^(-1)A^T=E_2^T. $
The inverse identity is proved in Section 2.6. The two-step block has the
*same shape* as one step:
$ x_2=E_2 x_0-G_2 lambda_2, quad lambda_0=H_2 x_0+E_2^T lambda_2. $

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
Recover the initial price, using $lambda_1=x_1+1.1 lambda_2$:
$ lambda_0=x_0+1.1 lambda_1
  =x_0+1.1(x_1+1.1 lambda_2)
  =1.605 x_0+0.605 lambda_2. $
So the whole two-step problem is summarized by
$ E_2=0.605, quad G_2=1.605, quad H_2=1.605. $
The interior variables $x_1,lambda_1$ have disappeared. If there is no terminal
cost, $lambda_2=0$; then $lambda_0=1.605 x_0$ and the optimized two-step
value is $V_2(x_0)=1/2 dot 1.605 x_0^2$. This is why $H_2$ is the
finite-horizon Riccati solution, not just an arbitrary coefficient.

== Only now introduce the general block

One optimized step has a linear boundary relation. We have shown that joining
two steps and eliminating the shared boundary preserves its form. Repeating
the same operation joins two two-step blocks into a four-step block, then two
four-step blocks into an eight-step block. This motivates the notation
$ x_N=E_N x_0-G_N lambda_N, quad
  lambda_0=H_N x_0+E_N^T lambda_N. $ <block>
These are *boundary relations*, not an uncontrolled forward state transition:
prescribe $x_0$ and $lambda_N$, and they return the optimized $x_N$ and
the initial marginal cost $lambda_0$.

- $E_N$ transmits the initial state across the optimized block.
- $G_N$ describes how a terminal price changes its terminal state.
- $H_N$ is the initial value curvature when $lambda_N=0$.

For zero terminal cost, $lambda_N=0$ and $lambda_0=H_N x_0$. But the
zero-terminal-cost optimal value is $1/2 x_0^T P_N x_0$, whose gradient is
$P_N x_0$. Therefore $H_N=P_N$. The one-step coefficients are
$(E_1,G_1,H_1)=(A,B R^(-1)B^T,Q)$, directly from
@one-step-state and @one-step-costate.

#takeaway[
  A block accepts an initial state and a terminal marginal cost. Optimality
  determines the terminal state and the initial marginal cost. SDA joins two
  identical blocks and eliminates their shared boundary, keeping only three
  matrices. No inverse of $A$ is required.
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
$ lambda_0=H x_0+E^T(H x_N+E^T lambda_(2N)) $
$ lambda_0=(H+E^T H W^(-1)E)x_0
  +E^T(I-H W^(-1)G)E^T lambda_(2N). $
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
Since $G,H$ are symmetric, $W^T=I+H G$, so the terminal-price coefficient
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
