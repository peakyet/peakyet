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

The value matrix alone describes the zero-terminal-cost case. To join blocks,
we need a summary that also accepts a terminal costate $lambda_N$: the gradient
of the downstream value with respect to $x_N$. An $N$-step block has relations
$ x_N = E_N x_0-G_N lambda_N, quad
  lambda_0=H_N x_0+E_N^T lambda_N. $ <block>
These are *boundary relations*, not a forward state transition: we prescribe
$x_0$ and $lambda_N$, then recover $x_N$ and $lambda_0$.

- $E_N$ transmits the initial state across the optimized block.
- $G_N$ measures how a terminal costate changes its terminal state.
- $H_N$ is the initial value curvature when $lambda_N=0$; hence $H_N=P_N$.

For one step, stationarity and the costate equation are
$ R u_0+B^T lambda_1=0, quad lambda_0=Q x_0+A^T lambda_1. $
Substitute $u_0=-R^(-1)B^T lambda_1$ into the dynamics. Comparing with @block
gives $E_1=A$, $G_1=G$, $H_1=Q$. This needs no inverse of $A$.

== Join two identical blocks

Temporarily omit the horizon subscript. Two copies of @block give
$ x_N=E x_0-G lambda_N, quad lambda_0=H x_0+E^T lambda_N, $
$ x_(2N)=E x_N-G lambda_(2N), quad
  lambda_N=H x_N+E^T lambda_(2N). $
Eliminate the shared costate in the first relation:
$ (I+G H)x_N=E x_0-G E^T lambda_(2N). $ <midpoint>
Define $W=I+G H$. Then substitute
$x_N=W^(-1)E x_0-W^(-1)G E^T lambda_(2N)$ into the two outer relations.
For the initial costate, use
$I-H W^(-1)G=(I+H G)^(-1)$; for the terminal state, use
$W^(-1)G=G(I+H G)^(-1)$. The result again has form @block, with
$ E_+ = E(I+G H)^(-1)E, $
$ G_+ = G+E G(I+H G)^(-1)E^T, $
$ H_+ = H+E^T H(I+G H)^(-1)E. $ <updates>

#takeaway[
  Initialize $(E_0,G_0,H_0)=(A,B R^(-1)B^T,Q)$ and apply these updates
  simultaneously. The iteration index $k$ now means a horizon of $2^k$:
  $H_k=P_(2^k)$. Subscripts hereafter index *doublings*, not time steps.
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
