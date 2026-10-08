// sda-riccati.typ -- a teach-an-engineer note, filled in place from
// .agents/skills/teaching-complex-ideas/typst-template/note.typ.
//
// Every number quoted below is printed by scripts/verify_sda.m. Run it from the
// repository root with
//   octave --no-gui --quiet Control/sda-riccati/scripts/verify_sda.m

#import "/.agents/skills/teaching-complex-ideas/typst-template/teaching.typ": note-ilm, check, navy, teal, gray

#show: note-ilm.with(
  title: [The Structure-Preserving Doubling Algorithm for the Algebraic Riccati Equation],
  authors: "Amp",
  abstract: [
    A linear-quadratic regulator needs the stabilizing solution of an algebraic Riccati equation.
    The classical way to reach it extends the control horizon one step at a time, and it slows
    down badly when the closed loop sits near the stability boundary. This note explains the
    alternative that the doubling algorithm is built on: each step of that horizon recursion is
    one application of a symplectic matrix to the graph of the current cost, so squaring the
    matrix doubles the horizon. Forming the powers directly destroys the answer, so the algorithm
    squares a block *factorization* instead, which is the structure-preserving doubling algorithm
    (SDA). The running example is a unit mass on a unit spring, whose Riccati solution is known in
    closed form, and a Cayley transform at the end reduces the continuous-time equation to the
    discrete one so that a single piece of code solves both.
  ],
  bibliography: bibliography("refs.bib"),
)

// =============================== 1. THE PROBLEM ================================

= The discrete Riccati equation, and the loop that solves it slowly <s1>

A discrete-time plant $x_(k+1) = A x_k + B u_k$ with an infinite-horizon cost
$sum_k (x_k^top Q x_k + u_k^top R u_k)$ is driven optimally by the feedback $u_k = -K x_k$. The
optimal cost from a state $x$ is the quadratic form $x^top X x$, and the cost matrix $X$ solves
the *discrete-time algebraic Riccati equation* (DARE)

$ X = Q + A^top X (I + G X)^(-1) A, quad G = B R^(-1) B^top, quad Q = Q^top >= 0, quad G = G^top >= 0. $ <eq:dare>

Among its solutions, the one a controller needs is the *stabilizing* solution $X_+ >= 0$, whose
closed loop $K = (I + G X_+)^(-1) A$ has every eigenvalue inside the unit circle. The equation is
nonlinear and, written like this, gives no hint where to start; so the first thing to notice is
that it has a direct meaning that suggests a loop.

Let $X_j$ be the optimal cost when the controller has only $j$ steps left to run. Extending a
$j$-step horizon by one step gives the recursion

$ X_(j+1) = Q + A^top X_j (I + G X_j)^(-1) A, quad X_0 = 0, $ <eq:vi>

and the finite-horizon costs increase to the infinite-horizon answer:
$0 = X_0 <= X_1 <= X_2 <= dots -> X_+$. This is the *value iteration*. It is correct and easy,
and it is also slow exactly when the problem is interesting. Each step multiplies the error by
about $sigma = rho((I + G X_+)^(-1) A)$, the spectral radius of the closed loop, so a loop close
to the unit circle -- $sigma$ close to $1$ -- makes the iteration crawl.

*The running problem.* Throughout, the equation is solved on one plant: a unit mass on a unit
spring, actuated by a force -- the phase-space plant of the symplectic-matrix note
(`Control/symplectic-matrix/symplectic-matrix.pdf`, page 6). In discrete form the data are

$ A = mat(0, -2 slash 3; 1, 1 slash 3), quad G = 1/3 mat(1, 1; 1, 1), quad Q = mat(1, 0; 0, 2 slash 3), $ <eq:running>

with $R = 1$ and $B = (1 slash sqrt(3)) mat(1; 1)$, so that $B R^(-1) B^top = G$. Its stabilizing
solution is

$ X_+ = mat(1.912290315, 0.414213562; 0.414213562, 1.352193449), quad sigma = 0.53101006. $ <eq:xplus>

These numbers are not arbitrary: they are the *Cayley image* of the same plant in continuous time,
a reduction derived in #ref(<s7>), so $X_+$ there is the continuous Riccati solution and
#ref(<eq:xplus>) is its exact closed form. Having one plant behind both equations keeps a single
set of numbers running through the whole note. On #ref(<eq:running>) the value iteration needs
$27$ steps to reach machine precision; the doubling algorithm needs six.

= The iterate is a graph, and one step is one application of a matrix <s2>

The horizon recursion #ref(<eq:vi>) looks nonlinear, but it is *linear in a subspace* once the
right object is used. Stack the identity under the current cost,

$ mat(I_n; X_j) in bb(R)^(2n times n), $

and call its span the *graph* of $X_j$. Writing $K_j = (I + G X_j)^(-1) A$, the recursion says two
things at once: $A = (I + G X_j) K_j$ and $X_(j+1) - Q = A^top X_j K_j$. Stacked, they become one
block-matrix equation,

$ mat(A, 0; -Q, I) mat(I; X_(j+1)) = mat(I, G; 0, A^top) mat(I; X_j) K_j. $ <eq:step-blocks>

The first block row is the definition of $K_j$ rearranged; the second is #ref(<eq:vi>). So
#ref(<eq:step-blocks>) carries no new information -- but it lets us isolate the matrix

$ cal(S) = mat(I, G; 0, A^top)^(-1) mat(A, 0; -Q, I), $ <eq:S>

which carries the graph of $X_j$ to the graph of $X_(j+1)$:

$ mat(I; X_(j+1)) = cal(S)^(-1) mat(I; X_j) K_j. $ <eq:step>

Right-multiplying by the invertible $K_j$ does not change a set of columns, so
$"span" mat(I; X_(j+1)) = cal(S)^(-1) "span" mat(I; X_j)$. *One step of the value iteration is one
application of $cal(S)^(-1)$ to the graph of the current cost.* This is the representation change
the rest of the note rests on: the horizon recursion is replaced by a fixed linear map acting on
subspaces.

To see that action, take the smallest case. Drop to one state, $n = 1$, and use the scalar problem
$A = 1.2$, $G = 1$, $Q = 0.1$. Here the graph of $X_j$ is a single line through the origin, the
line spanned by $(1, X_j)$, and $cal(S)^(-1)$ moves that line toward one fixed line. #ref(<fig:graphs>) draws
the successive lines for $j = 0, 1, dots, 8$, together with the two invariant lines of $cal(S)$.
The lines rotate onto the line that solves the equation and stop there; the matrix case is the same
dynamics acting on $n$-dimensional graphs instead of lines, and the reader should keep this picture
for the rest of the argument.

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The value iteration as a sequence of subspaces, in the scalar case $A = 1.2$,
    $G = 1$, $Q = 0.1$. Each solid navy ray is the graph of one
    $X_j$; the operation from one ray to the next is "apply $cal(S)^(-1)$, then rescale so the top
    entry is $1$". The dashed navy line is the graph of $X_+$ -- an invariant line of $cal(S)$ --
    and the rays rotate onto it, crowding together as they arrive, which is the linear convergence
    of #ref(<eq:vi>). The dashed teal line is $cal(S)$'s other invariant line, which the iteration
    pushes away. The scalar case is used here only because a graph can be drawn as a line; the
    non-commuting order of the matrix updates is what the $2 times 2$ running example tests.],
  box(width: 100%, height: 6.6cm)[
    // axes
    #place(top + left)[#line(start: (5.5cm, 4.9cm), end: (10.6cm, 4.9cm), stroke: 0.5pt + gray)]
    #place(top + left)[#line(start: (6.5cm, 1.5cm), end: (6.5cm, 6.3cm), stroke: 0.5pt + gray)]
    // invariant lines
    #place(top + left)[#line(start: (4.026cm, 6.597cm), end: (8.974cm, 3.203cm), stroke: (paint: navy, thickness: 0.8pt, dash: "dashed"))]
    #place(top + left)[#line(start: (3.531cm, 4.467cm), end: (9.469cm, 5.333cm), stroke: (paint: teal, thickness: 0.8pt, dash: "dashed"))]
    // successive graphs
    #let o = (6.5cm, 4.9cm)
    #for p in ((10.000, 4.900), (9.983, 4.552), (9.910, 4.113), (9.782, 3.685), (9.644, 3.362), (9.537, 3.161), (9.469, 3.046), (9.430, 2.986), (9.409, 2.954)) {
      place(top + left)[#line(start: o, end: (p.at(0) * 1cm, p.at(1) * 1cm), stroke: 0.9pt + navy)]
    }
    // dots at tips
    #for p in ((10.000, 4.900), (9.910, 4.113), (9.409, 2.954)) {
      place(top + left, dx: p.at(0) * 1cm - 1.5pt, dy: p.at(1) * 1cm - 1.5pt)[#circle(radius: 1.5pt, fill: navy)]
    }
    #place(top + left, dx: 6.5cm - 1.5pt, dy: 4.9cm - 1.5pt)[#circle(radius: 1.5pt, fill: black)]
    // labels
    #place(top + left, dx: 10.45cm, dy: 4.72cm)[$X_0$]
    #place(top + left, dx: 10.35cm, dy: 3.86cm)[$X_2$]
    #place(top + left, dx: 9.72cm, dy: 2.52cm)[$X_8$]
    #place(top + left, dx: 6.7cm, dy: 2.90cm)[#text(fill: navy, size: 9pt)[graph of $X_+$]]
    #place(top + left, dx: 7.4cm, dy: 5.85cm)[#text(fill: teal, size: 9pt)[other invariant line]]
  ],
) <fig:graphs>

The fixed map $cal(S)$ is not arbitrary: with $J = mat(0, I; -I, 0)$ it satisfies
$cal(S)^top J cal(S) = J$, which makes it *symplectic*.

*The closed loop is $cal(S)$ on the stable subspace.* At the solution the one-step relation stops
moving. Put $X_j = X_(j+1) = X_+$ and $K = (I + G X_+)^(-1) A$ in #ref(<eq:step>); using
$A = (I + G X_+) K$ and $X_+ - Q = A^top X_+ K$, the two blocks of #ref(<eq:step-blocks>) assemble
into

$ mat(A, 0; -Q, I) mat(I; X_+) = mat(I, G; 0, A^top) mat(I; X_+) K, quad "so" quad cal(S) mat(I; X_+) = mat(I; X_+) K. $ <eq:invariance>

The graph of $X_+$ is therefore an invariant subspace of $cal(S)$, and on it $cal(S)$ acts as the
matrix $K$. That matrix is the closed-loop state matrix, not a new object. The optimal gain is
$K_"lqr" = (R + B^top X_+ B)^(-1) B^top X_+ A$, and the push-through identity
$B (R + B^top X_+ B)^(-1) B^top X_+ = (I + G X_+)^(-1) G X_+$ turns $A - B K_"lqr"$ into exactly $K$:

$ A - B K_"lqr" = [I - (I + G X_+)^(-1) G X_+] A = (I + G X_+)^(-1) A = K. $ <eq:closedloop>

So #ref(<eq:invariance>) reads: *the closed-loop state matrix is $cal(S)$ restricted to the graph of
$X_+$*, written in the basis $mat(I; X_+)$.

*The two spectra.* Two facts now fix the eigenvalues. #ref(<eq:invariance>) makes $sigma(K)$ a
subset of $sigma(cal(S))$. Symplecticity forces $sigma(cal(S))$ to be closed under
$lambda |-> 1/lambda$ and conjugation: if $lambda$ is an eigenvalue then so are $1/lambda$,
$overline(lambda)$, and $1/overline(lambda)$. Since the closed loop is stable, $sigma(K)$ lies
inside the unit circle, so it is exactly the inside half of $sigma(cal(S))$, and the outside half is
its reciprocal conjugate:

$ sigma(cal(S)) = sigma(K) union { 1/overline(lambda) : lambda in sigma(K) }. $ <eq:spectrum-split>

For #ref(<eq:running>) the four eigenvalues are

$ 0.10998 plus.minus 0.51950 i quad ("modulus" 0.53101), \
  "and" quad 0.39002 plus.minus 1.84237 i quad ("modulus" 1.88320). $

and the inside pair is the closed loop, $sigma(K) = { 0.10998 plus.minus 0.51950 i }$, with
$1 slash 0.53101 = 1.88320$ recovering the outside pair. That is why the error shrinks by about
$0.531$ per value-iteration step, and why the graphs slide onto the *stable* subspace. One
convention to keep straight: $mat(I; X_+)$ is a basis of the invariant subspace, not a basis of
eigenvectors, and it is not orthogonal; the eigenvalues agree because $K$ represents the action of
$cal(S)$ on that subspace in this basis, and it is the subspace, not the basis, that the iteration
approaches.

= Squaring doubles the horizon <s3>

Apply #ref(<eq:step>) twice: the graph of $X_j$ becomes the graph of $X_(j+1)$, then the graph of
$X_(j+2)$. So $cal(S)^(-2)$ moves the horizon by two, and applying the argument $k$ times gives the
whole idea:

$ "span" mat(I; X_(2^k)) = cal(S)^(-2^k) "span" mat(I; 0). $ <eq:power>

Each squaring doubles the number of value-iteration steps that have been taken. The answer is
identical -- #ref(<eq:power>) is an identity, not an approximation -- but it is reached in $k$
squarings instead of $2^k$ steps, and the number of *operations* is what matters. The obstacle is
that the squaring has to be done in the right representation, and the obvious one fails. #ref(<fig:spectrum>)
shows why the squaring works at all: on the spectrum, squaring raises each inside eigenvalue to a
higher power, so it races to $0$, while each outside eigenvalue races to $infinity$. That is the
separation the value iteration performs one shadow of per step, now performed $2^k$ times over.

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The spectrum of $cal(S)$ under squaring. The solid circle is $abs(lambda) = 1$; the
    dashed circle is $abs(lambda) = 1 slash 0.531 = 1.883$. The four eigenvalues are
    $lambda, overline(lambda)$ inside (navy) and $1 slash lambda, 1 slash overline(lambda)$
    outside (teal). The small navy dots are successive squares
    $lambda, lambda^2, lambda^4, lambda^8$: squaring walks the inside eigenvalue to the origin at
    a rate that doubles every step. The teal arrows are the mirror effect on the outside pair,
    which runs to infinity. This is the mechanism the value iteration performs one step at a time
    and doubling performs $2^k$ steps at a time.],
  box(width: 100%, height: 6.2cm)[
    #let cx = 7.2cm
    #let cy = 3.0cm
    #let s  = 1.0cm
    #let px(re) = cx + re * s
    #let py(im) = cy - im * s
    #place(top + left)[#line(start: (px(-2.1), py(0)), end: (px(2.2), py(0)), stroke: 0.6pt + gray)]
    #place(top + left)[#line(start: (px(0), py(-2.55)), end: (px(0), py(2.55)), stroke: 0.6pt + gray)]
    #place(top + left, dx: px(0) - 1.0cm, dy: py(0) - 1.0cm)[#circle(radius: 1.0cm, stroke: 0.9pt + gray)]
    #place(top + left, dx: px(0) - 1.883cm, dy: py(0) - 1.883cm)[#circle(radius: 1.883cm, stroke: (paint: gray, thickness: 0.6pt, dash: "dashed"))]
    #place(top + left)[#line(start: (px(0.109976), py(0.519497)), end: (px(-0.257782), py(0.114264)), stroke: 0.9pt + navy)]
    #place(top + left)[#line(start: (px(-0.257782), py(0.114264)), end: (px(0.053395), py(-0.058911)), stroke: 0.9pt + navy)]
    #place(top + left)[#line(start: (px(0.053395), py(-0.058911)), end: (px(-0.000619), py(-0.006291)), stroke: 0.9pt + navy)]
    #place(top + left)[#line(start: (px(0.109976), py(-0.519497)), end: (px(-0.257782), py(-0.114264)), stroke: 0.9pt + navy)]
    #place(top + left)[#line(start: (px(-0.257782), py(-0.114264)), end: (px(0.053395), py(0.058911)), stroke: 0.9pt + navy)]
    #place(top + left, dx: px(0.109976) - 2pt, dy: py(0.519497) - 2pt)[#circle(radius: 2pt, fill: navy)]
    #place(top + left, dx: px(0.109976) - 2pt, dy: py(-0.519497) - 2pt)[#circle(radius: 2pt, fill: navy)]
    #place(top + left, dx: px(-0.257782) - 1.6pt, dy: py(0.114264) - 1.6pt)[#circle(radius: 1.6pt, fill: navy)]
    #place(top + left, dx: px(-0.257782) - 1.6pt, dy: py(-0.114264) - 1.6pt)[#circle(radius: 1.6pt, fill: navy)]
    #place(top + left, dx: px(0.053395) - 1.3pt, dy: py(-0.058911) - 1.3pt)[#circle(radius: 1.3pt, fill: navy)]
    #place(top + left, dx: px(0.053395) - 1.3pt, dy: py(0.058911) - 1.3pt)[#circle(radius: 1.3pt, fill: navy)]
    #place(top + left, dx: px(-0.000619) - 1pt, dy: py(-0.006291) - 1pt)[#circle(radius: 1pt, fill: navy)]
    #place(top + left, dx: px(0.390024) - 2.4pt, dy: py(1.842373) - 2.4pt)[#circle(radius: 2.4pt, fill: teal)]
    #place(top + left, dx: px(0.390024) - 2.4pt, dy: py(-1.842373) - 2.4pt)[#circle(radius: 2.4pt, fill: teal)]
    #place(top + left)[#line(start: (px(0.471), py(2.224)), end: (px(0.590), py(2.787)), stroke: 1.1pt + teal)]
    #place(top + left)[#line(start: (px(0.471), py(-2.224)), end: (px(0.590), py(-2.787)), stroke: 1.1pt + teal)]
    #place(top + left, dx: px(0.109976) + 4pt, dy: py(0.519497) - 0.55em)[$lambda$]
    #place(top + left, dx: px(0.109976) + 4pt, dy: py(-0.519497) + 0.1em)[$overline(lambda)$]
    #place(top + left, dx: px(0.390024) + 5pt, dy: py(1.842373) + 0.05em)[$1 slash overline(lambda)$]
    #place(top + left, dx: px(0.390024) + 5pt, dy: py(-1.842373) - 0.6em)[$1 slash lambda$]
    #place(top + left, dx: px(-0.78), dy: py(0.75))[#text(size: 8pt, fill: gray)[$abs(lambda)=1$]]
    #place(top + left, dx: px(-0.36), dy: py(-0.30))[#text(size: 9pt)[$0$]]
    #place(top + left, dx: px(1.95) - 0.4em, dy: py(0) - 0.2em)[#text(size: 9pt, fill: gray)[Re]]
    #place(top + left, dx: px(0) + 3pt, dy: py(2.5))[#text(size: 9pt, fill: gray)[Im]]
    #place(top + left, dx: px(-1.55), dy: py(-1.15))[#text(size: 9pt, fill: navy)[$lambda^(2^j) -> 0$]]
    #place(top + left, dx: px(0.75), dy: py(-2.4))[#text(size: 9pt, fill: teal)[$-> oo$]]
  ],
) <fig:spectrum>

= The powers cannot be formed directly <s4>

The most direct reading of #ref(<eq:power>) is to build $cal(S)$, square it $k$ times, and read
$X_(2^k)$ off the result. That reading is numerically hopeless, and #ref(<fig:spectrum>) shows why: the inside
eigenvalues are raised to $0.531^(2^k)$ and vanish, the outside ones to $1.883^(2^k)$ and explode.
After a few squarings the matrix has entries spanning hundreds of orders of magnitude, and the
small entries that carry $X_+$ have been rounded away. #ref(<tab:power>) measures this on #ref(<eq:running>):
the explicit power is fine for two squarings, has lost six digits by the fifth, and is numerically
singular by the sixth. Since the arithmetic is in double precision, more squaring does not help:
the accurate information is destroyed *before* the iteration has converged.

#figure(
  kind: "table",
  supplement: [Table],
  caption: [Forming $cal(S)^(-2^k)$ explicitly against keeping it factored, on #ref(<eq:running>).
    Column 2 is the error of the explicit power; column 3 is the error of the iterate extracted from
    it. At $k = 6$ the explicit power has lost the answer entirely. Printed by
    `scripts/verify_sda.m`.],
  table(
    columns: (auto, auto, auto),
    align: (right, right, right),
    stroke: 0.4pt,
    table.header([$k$], [explicit power error], [factored-form error]),
    [$0$], [$4.119 times 10^(-16)$], [$3.413 times 10^(-16)$],
    [$1$], [$1.052 times 10^(-15)$], [$8.546 times 10^(-16)$],
    [$2$], [$1.141 times 10^(-14)$], [$7.756 times 10^(-15)$],
    [$3$], [$2.903 times 10^(-13)$], [$2.134 times 10^(-13)$],
    [$4$], [$7.403 times 10^(-11)$], [$5.847 times 10^(-11)$],
    [$5$], [$3.350 times 10^(-6)$], [$2.758 times 10^(-6)$],
    [$6$], [$4.506 times 10^(+3)$], [(matrix singular)],
  ),
) <tab:power>

= Squaring the factorization instead <s5>

The repair is to never form the power, and to square the *representation* of $cal(S)^(-1)$ instead.
The representation to square is the block form $cal(S)$ already has. For every $k$ there are
matrices $A_k, G_k, Q_k$ with

$ cal(S)^(-2^k) = mat(A_k, 0; -Q_k, I)^(-1) mat(I, G_k; 0, A_k^top), quad A_0 = A, quad G_0 = G, quad Q_0 = Q, $ <eq:ansatz>

and for $k = 0$ this is exactly #ref(<eq:S>) with $cal(S)^(-1)$ in place of $cal(S)$. Two facts
make #ref(<eq:ansatz>) do all the work. First, applying it to the starting vector recovers the
iterate:

$ cal(S)^(-2^k) mat(I; 0) = mat(A_k^(-1); Q_k A_k^(-1)) = mat(I; Q_k) A_k^(-1), quad "so" quad Q_k = X_(2^k). $ <eq:qk>

The second block row is the answer, written straight off the factorization. Second, the block form
is closed under squaring, so squaring #ref(<eq:ansatz>) again produces the same shape with new
data $A_(k+1), G_(k+1), Q_(k+1)$ from the old. Once those three updates are known, the algorithm is
complete, and it never touches a badly conditioned power.

*Deriving the updates.* A symplectic matrix $W$ of the shape on the right of #ref(<eq:ansatz>)
has its standard-symplectic-form data recoverable from its blocks. Writing
$W = mat(W_(11), W_(12); W_(21), W_(22))$ and expanding
$mat(A', 0; -Q', I)^(-1) mat(I, G'; 0, A'^top)$ gives $W_(11) = A'^(-1)$,
$W_(12) = A'^(-1) G'$, $W_(21) = Q' A'^(-1)$, hence

$ A' = W_(11)^(-1), quad G' = W_(11)^(-1) W_(12), quad Q' = W_(21) W_(11)^(-1). $ <eq:extract>

Now square #ref(<eq:ansatz>). With $M_k = mat(A_k, 0; -Q_k, I)$ and
$N_k = mat(I, G_k; 0, A_k^top)$, the square is $M_k^(-1) N_k M_k^(-1) N_k$, and the middle factor
is a single product, because $M_k^(-1) = mat(A_k^(-1), 0; Q_k A_k^(-1), I)$:

$ N_k M_k^(-1) = mat((I + G_k Q_k) A_k^(-1), G_k; A_k^top Q_k A_k^(-1), A_k^top). $ <eq:middle>

Multiplying by $M_k^(-1)$ on the left and $N_k$ on the right and reading off the three blocks of
#ref(<eq:extract>) gives the updates

$ A_(k+1) &= A_k (I + G_k Q_k)^(-1) A_k, \
  G_(k+1) &= G_k + A_k G_k (I + Q_k G_k)^(-1) A_k^top, \
  Q_(k+1) &= Q_k + A_k^top (I + Q_k G_k)^(-1) Q_k A_k. $ <eq:sda>

The two forms in the middle line agree because of the identity
$(I + G_k Q_k)^(-1) G_k = G_k (I + Q_k G_k)^(-1)$, which is just
$(I + G_k Q_k) G_k = G_k (I + Q_k G_k)$ inverted, and its transpose. For instance the second term of
$G_(k+1)$ is $A_k (I + G_k Q_k)^(-1) G_k A_k^top = A_k G_k (I + Q_k G_k)^(-1) A_k^top$. The result
#ref(<eq:sda>) is the *structure-preserving doubling algorithm* (SDA): three coupled matrix
identities and one matrix inverse per step, with no squaring of an ill-conditioned power. Each
$cal(S)^(-2^k)$ is symplectic by construction, so $A_k, G_k, Q_k$ stay symmetric in the pattern the
equation demands, and $Q_k$ stays symmetric positive semidefinite at every step
@chu2004pdare, @chu2005sda.

#check[
  Compute the first SDA update by hand for a scalar problem with $A = a$, $G = g$, $Q = q$, and
  compare it with running one value-iteration step twice. What does the formula give for $A_1$?
]
With $A_k = a$, $G_k = g$, $Q_k = q$, #ref(<eq:sda>) gives
$A_1 = a (1 + g q)^(-1) a = a^2 slash (1 + g q)$, $G_1 = g + a^2 g slash (1 + q g)$, and
$Q_1 = q + a^2 q slash (1 + q g)$. Running #ref(<eq:vi>) twice from $X_0 = 0$ gives
$X_1 = q$ and $X_2 = q + a^2 q slash (1 + g q)$, which is $Q_1$: the update reproduces two value
steps in one, as #ref(<eq:qk>) promises.

= The running example <s6>

On #ref(<eq:running>) the iterates do what the argument promises. #ref(<tab:iterates>) lists the first few. Its
fifth column is the difference between $Q_k$ and the value iteration's own $2^k$-th iterate: it is
machine precision at every $k$, so #ref(<eq:qk>) is an identity, not an approximation, even though
only $k$ squarings were taken. The sixth column shows both methods arriving: the doubling iterates
reach $X_+$ at $k = 5$ and the algorithm stops after six squarings, while the value iteration needs
$27$ steps. #ref(<fig:work>) plots the two against the work they cost. The value iteration is a straight
line on this scale, because each step multiplies the error by the same $0.531$; the doubling
iterates fall off a cliff, because each step squares what the previous one achieved.

#figure(
  kind: "table",
  supplement: [Table],
  caption: [The doubling iterates on #ref(<eq:running>). Each row is one squaring, "work" column 1.
    Column 5 measures exactness: $Q_k$ against the value iteration's own $2^k$-th iterate, which is
    roundoff at every $k$. Column 6 measures convergence: the same $Q_k$ against $X_+$. Steps are
    counted by the common rule "the iterate stops changing by more than $10^(-14)$ relative to its
    norm". Printed by `scripts/verify_sda.m`.],
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (right, right, right, right, right, right),
    stroke: 0.4pt,
    table.header([$k$], [$Q_k "(1,1)"$], [$Q_k "(1,2)"$], [$Q_k "(2,2)"$], [$norm(Q_k - X_(2^k))$], [$norm(Q_k - X_+)$]),
    [$0$], [$1.000000$], [$0.000000$], [$0.666667$], [--], [$1.283$],
    [$1$], [$1.571429$], [$0.285714$], [$1.142857$], [$5.6 times 10^(-17)$], [$4.394 times 10^(-1)$],
    [$2$], [$1.880000$], [$0.400000$], [$1.333333$], [$2.8 times 10^(-16)$], [$4.245 times 10^(-2)$],
    [$3$], [$1.912094$], [$0.414106$], [$1.352050$], [$3.2 times 10^(-16)$], [$2.865 times 10^(-4)$],
    [$4$], [$1.912290$], [$0.414214$], [$1.352193$], [$3.2 times 10^(-16)$], [$9.621 times 10^(-9)$],
    [$5$], [$1.912290$], [$0.414214$], [$1.352193$], [$2.4 times 10^(-16)$], [$5.027 times 10^(-16)$],
  ),
) <tab:iterates>

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [Error against the work, on #ref(<eq:running>). The horizontal axis counts matrix
    inversions -- one per value-iteration step, one per squaring. The navy curve is the value
    iteration; the teal markers are the doubling iterates, which are the *same* errors reached at
    work $k$ instead of $2^k$. The value iteration is a straight line of slope $log_10 0.531$; the
    doubling curve steepens because each step squares the previous error. On this problem the
    value iteration needs $27$ inversions to reach $X_+$ and doubling needs six.],
  box(width: 100%, height: 6.4cm)[
    #let x0 = 1.5cm
    #let dx = 0.30cm
    #let yt = 0.45cm
    #let dy = 0.3030cm
    #let pxj(j) = x0 + j * dx
    #let pyL(L) = yt + (1.0 - L) * dy
    // axes
    #place(top + left)[#line(start: (x0, pyL(1.0)), end: (x0, pyL(-15.5)), stroke: 0.6pt + gray)]
    #place(top + left)[#line(start: (x0, pyL(-15.5)), end: (pxj(34), pyL(-15.5)), stroke: 0.6pt + gray)]
    #for j in (0, 8, 16, 24, 32) {
      place(top + left, dx: pxj(j) - 1.4em, dy: pyL(-15.5) + 2pt)[#text(size: 8pt, fill: gray)[#j]]
    }
    #for L in (0, -5, -10, -15) {
      place(top + left, dx: x0 - 1.5em, dy: pyL(L) - 0.5em)[#text(size: 8pt, fill: gray)[#L]]
    }
    // value iteration curve
    #place(top + left)[#curve(
      stroke: 1.1pt + navy,
      curve.move((pxj(0), pyL(0.3828))),
      curve.line((pxj(1), pyL(0.1081))),
      curve.line((pxj(2), pyL(-0.3572))),
      curve.line((pxj(3), pyL(-0.8464))),
      curve.line((pxj(4), pyL(-1.3721))),
      curve.line((pxj(5), pyL(-1.9646))),
      curve.line((pxj(6), pyL(-2.4430))),
      curve.line((pxj(7), pyL(-3.0786))),
      curve.line((pxj(8), pyL(-3.5429))),
      curve.line((pxj(9), pyL(-4.1609))),
      curve.line((pxj(10), pyL(-4.6676))),
      curve.line((pxj(11), pyL(-5.2248))),
      curve.line((pxj(12), pyL(-5.8034))),
      curve.line((pxj(13), pyL(-6.2953))),
      curve.line((pxj(14), pyL(-6.9261))),
      curve.line((pxj(15), pyL(-7.3886))),
      curve.line((pxj(16), pyL(-8.0168))),
      curve.line((pxj(17), pyL(-8.5076))),
      curve.line((pxj(18), pyL(-9.0831))),
      curve.line((pxj(19), pyL(-9.6425))),
      curve.line((pxj(20), pyL(-10.1498))),
      curve.line((pxj(21), pyL(-10.7712))),
      curve.line((pxj(22), pyL(-11.2362))),
      curve.line((pxj(23), pyL(-11.8709))),
      curve.line((pxj(24), pyL(-12.3489))),
      curve.line((pxj(25), pyL(-12.9414))),
      curve.line((pxj(26), pyL(-13.4783))),
      curve.line((pxj(27), pyL(-14.0016))),
      curve.line((pxj(28), pyL(-14.6265))),
      curve.line((pxj(29), pyL(-15.0135))),
      curve.line((pxj(30), pyL(-15.5481))),
      curve.line((pxj(31), pyL(-15.4775))),
      curve.line((pxj(32), pyL(-15.4775))),
    )]
    // doubling markers
    #place(top + left)[#curve(
      stroke: (paint: teal, thickness: 1.1pt, dash: "dashed"),
      curve.move((pxj(0), pyL(0.1081))),
      curve.line((pxj(1), pyL(-0.3572))),
      curve.line((pxj(2), pyL(-1.3721))),
      curve.line((pxj(3), pyL(-3.5429))),
      curve.line((pxj(4), pyL(-8.0168))),
      curve.line((pxj(5), pyL(-15.2987))),
    )]
    #for p in ((0, 0.1081), (1, -0.3572), (2, -1.3721), (3, -3.5429), (4, -8.0168), (5, -15.2987)) {
      place(top + left, dx: pxj(p.at(0)) - 2pt, dy: pyL(p.at(1)) - 2pt)[#circle(radius: 2pt, fill: teal)]
    }
    // labels
    #place(top + left, dx: pxj(6), dy: pyL(-2.0))[#text(size: 9pt, fill: navy)[value iteration]]
    #place(top + left, dx: pxj(6), dy: pyL(-12.6))[#text(size: 9pt, fill: teal)[doubling]]
    #place(top + left, dx: pxj(13) - 1.6em, dy: pyL(-15.5) + 0.30cm)[#text(size: 8.5pt, fill: gray)[matrix inversions]]
    #place(top + left, dx: x0 - 1.4em, dy: pyL(1.0) - 0.6em)[#text(size: 8.5pt, fill: gray)[$log_10 norm(X - X_+)$]]
  ],
) <fig:work>

*Why the gap widens.* The advantage of doubling is not that it saves a constant factor; it is that
the two methods pay different prices for the same accuracy. #ref(<tab:epsilon>) repeats #ref(<eq:running>)
with the state penalty shrunk to $Q = epsilon I$, which pulls the closed loop toward the unit
circle. As $sigma -> 1$ the value iteration's line in #ref(<fig:work>) flattens and its step count grows
without bound -- it is a fixed-step method chasing a slow mode -- while the doubling count grows
only like $log_2$ of that, because each squaring doubles the horizon. The sidecar demo
`Control/sda-riccati/sda-riccati-demo.html` lets you drag $sigma$ and watch the two curves separate
directly.

#figure(
  kind: "table",
  supplement: [Table],
  caption: [The same plant with $Q = epsilon I$ and $R = 1$, reduced to discrete form by the Cayley
    transform of #ref(<s7>) with $tau = 1$. As the closed-loop radius $sigma$ approaches $1$, the
    value iteration's step count explodes while the doubling count grows like its logarithm. Steps
    use the same rule as #ref(<tab:iterates>), and the exact solution agrees with the continuous closed form to
    at worst $1.8 times 10^(-13)$. Printed by `scripts/verify_sda.m`.],
  table(
    columns: (auto, auto, auto, auto),
    align: (right, right, right, right),
    stroke: 0.4pt,
    table.header([$epsilon$], [$sigma$], [value iteration steps], [doubling steps]),
    [$10^(-1)$], [$0.802133$], [$73$], [$8$],
    [$10^(-2)$], [$0.931827$], [$209$], [$9$],
    [$10^(-4)$], [$0.992954$], [$1752$], [$13$],
    [$10^(-6)$], [$0.999293$], [$14252$], [$16$],
    [$10^(-8)$], [$0.999929$], [$109945$], [$19$],
  ),
) <tab:epsilon>

= The continuous equation by the same code <s7>

Everything so far was discrete. The same machinery solves the continuous-time Riccati equation,
and the bridge is a *Cayley transform*; this is the reduction the CARE version of SDA is built on
@chu2005sda. The continuous-time equation for the plant $dot(x) = A_c x + B_c u$ with cost
$integral_0^oo (x^top Q_c x + u^top R_c u) dif t$ is

$ A_c^top P + P A_c - P G_c P + Q_c = 0, quad G_c = B_c R_c^(-1) B_c^top, $ <eq:care>

whose stabilizing solution $P$ has the closed loop $A_c - G_c P$ in the left half-plane. Its
stable subspace is the one belonging to the left-half-plane eigenvalues of the Hamiltonian matrix
$cal(H) = mat(A_c, -G_c; -Q_c, -A_c^top)$, and it is the graph of $P$ -- the continuous analogue of
#ref(<eq:step>).

The reduction uses the Möbius map

$ c(lambda) = (lambda + tau) slash (lambda - tau) quad (tau > 0), $ <eq:cayleydef>

which sends the left half-plane into the unit disk and the right half-plane outside it. Applied to
the Hamiltonian, $c(cal(H)) = (cal(H) - tau I)^(-1) (cal(H) + tau I)$ is a symplectic matrix, and
because $c$ is a rational function it maps invariant subspaces to invariant subspaces:
$cal(H) mat(I; P) = mat(I; P)(A_c - G_c P)$ implies
$c(cal(H)) mat(I; P) = mat(I; P) c(A_c - G_c P)$. The map puts the stable eigenvalues inside the
circle -- #ref(<fig:cayley>) -- so the graph of $P$ is the stable subspace of $c(cal(H))$. Writing
$c(cal(H))$ in the standard symplectic form #ref(<eq:ansatz>) produces a discrete Riccati problem
with the same solutions:

$ mat(A_d, G_d; -Q_d, A_d^top) = mat(A_c - tau I, -G_c; Q_c, A_c^top - tau I)^(-1) mat(A_c + tau I, -G_c; Q_c, A_c^top + tau I). $ <eq:reduction>

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The Cayley transform acting on the spectrum, for the running plant with $tau = 1$. Left:
    the Hamiltonian's eigenvalues, a stable pair in the left half-plane (navy) and its mirror pair in
    the right half-plane (gray). Right: their images under $c(lambda) = (lambda + tau) slash (lambda - tau)$,
    which lie inside and outside the unit circle respectively (navy and gray again). The map moves
    the *stable* set, the left half-plane, into the unit disk, so the stable graph of $P$ on the left
    is the stable graph of the same $P$ on the right. This is why the discrete data of #ref(<eq:running>)
    and the continuous equation #ref(<eq:care>) have one solution.],
  box(width: 100%, height: 6.6cm)[
    // left panel: continuous spectrum
    #let lx = 3.0cm
    #let ly = 3.5cm
    #let ls = 1.35cm
    #place(top + left)[#line(start: (1.0cm, ly), end: (5.2cm, ly), stroke: 0.5pt + gray)]
    #place(top + left)[#line(start: (lx, 0.6cm), end: (lx, 6.2cm), stroke: (paint: gray, thickness: 0.7pt))]
    #place(top + left, dx: lx - 0.6761*ls - 2.4pt, dy: ly - 0.9783*ls - 2.4pt)[#circle(radius: 2.4pt, fill: navy)]
    #place(top + left, dx: lx - 0.6761*ls - 2.4pt, dy: ly + 0.9783*ls - 2.4pt)[#circle(radius: 2.4pt, fill: navy)]
    #place(top + left, dx: lx + 0.6761*ls - 2.4pt, dy: ly - 0.9783*ls - 2.4pt)[#circle(radius: 2.4pt, fill: gray)]
    #place(top + left, dx: lx + 0.6761*ls - 2.4pt, dy: ly + 0.9783*ls - 2.4pt)[#circle(radius: 2.4pt, fill: gray)]
    #place(top + left, dx: 1.0cm, dy: ly - 0.85cm)[#text(size: 9pt, fill: navy)[$"Re" lambda < 0$]]
    #place(top + left, dx: lx + 1.02cm, dy: ly - 0.85cm)[#text(size: 9pt, fill: gray)[$"Re" lambda > 0$]]
    #place(top + left, dx: 1.5cm, dy: 0.45cm)[#text(size: 9.5pt)[Hamiltonian $cal(H)$]]
    // right panel: discrete spectrum
    #let rx = 10.6cm
    #let ry = 3.5cm
    #let rs = 1.35cm
    #place(top + left)[#line(start: (8.8cm, ry), end: (12.6cm, ry), stroke: 0.5pt + gray)]
    #place(top + left)[#line(start: (rx, 0.6cm), end: (rx, 6.2cm), stroke: 0.5pt + gray)]
    #place(top + left, dx: rx - rs, dy: ry - rs)[#circle(radius: rs, stroke: 0.9pt + gray)]
    #place(top + left, dx: rx + 0.109976*rs - 2.4pt, dy: ry - 0.51950*rs - 2.4pt)[#circle(radius: 2.4pt, fill: navy)]
    #place(top + left, dx: rx + 0.109976*rs - 2.4pt, dy: ry + 0.51950*rs - 2.4pt)[#circle(radius: 2.4pt, fill: navy)]
    #place(top + left, dx: rx + 0.390024*rs - 2.4pt, dy: ry - 1.84237*rs - 2.4pt)[#circle(radius: 2.4pt, fill: gray)]
    #place(top + left, dx: rx + 0.390024*rs - 2.4pt, dy: ry + 1.84237*rs - 2.4pt)[#circle(radius: 2.4pt, fill: gray)]
    #place(top + left, dx: 9.0cm, dy: 0.45cm)[#text(size: 9.5pt)[symplectic $c(cal(H))$]]
    // the map
    #place(top + left)[#line(start: (5.9cm, ly), end: (7.5cm, ly), stroke: 1.0pt + gray)]
    #place(top + left)[#polygon((7.5cm, ly), (7.2cm, ly - 0.10cm), (7.2cm, ly + 0.10cm), fill: gray)]
    #place(top + left, dx: 6.35cm, dy: ly - 0.95cm)[#text(size: 9pt)[$c(lambda)$]]
    #place(top + left, dx: 4.45cm, dy: 5.75cm)[#text(size: 8.5pt, fill: gray)[LHP $->$ unit disk]]
  ],
) <fig:cayley>

For the running plant -- unit mass, unit spring, $A_c = mat(0, 1; -1, 0)$, $B_c = mat(0; 1)$, with
$Q_c = I$ and $R_c = 1$ -- the reduction #ref(<eq:reduction>) with $tau = 1$ returns exactly the
discrete data of #ref(<eq:running>), and its solution is the closed form

$ p_(12) = sqrt(2) - 1, quad p_(22) = sqrt(2 p_(12) + 1), quad p_(11) = p_(22)(1 + p_(12)), $ <eq:closedform>

the same expression the companion QZ note solves for (`Control/qz-riccati/qz-riccati.pdf`, page 3).
The doubling algorithm on the discrete data
returns $P = mat(1.912290315, 0.414213562; 0.414213562, 1.352193449)$ to $5.0 times 10^(-16)$: the
continuous equation has been solved without ever building its Hamiltonian eigensystem. The
parameter $tau$ is free, subject only to $A_c - tau I$ being invertible; different choices give
different discrete data and the same solution. On this plant $tau = 1$ or $2$ is fastest (six
squarings) and $tau = 0.25$ or $10$ costs two more, with every choice accurate to roundoff.

= Where the method is limited, and where it sits <s8>

The method's one real weakness is inherited, not algorithmic. When $A_c - G_c P$ has an eigenvalue
on the imaginary axis, or $K$ an eigenvalue on the unit circle, $sigma = 1$ and no method can
separate the stable subspace from the unstable one; the value iteration stalls outright and SDA
degrades from quadratic to linear with rate $1 slash 2$ @poloni2020doubling. The $epsilon$ rows of
#ref(<tab:epsilon>) are the healthy side of that boundary: they show the cost rising smoothly as $sigma -> 1$,
not a cliff.

Two assumptions are worth stating. The factorization #ref(<eq:ansatz>) and the reduction
#ref(<eq:reduction>) both need $A$ (and $A_c - tau I$) invertible; when $A$ is singular the same
argument runs on a matrix pencil, which is exactly the deflating-subspace picture of the companion
QZ note. And $X_+$ exists and is unique under stabilizability and detectability, taken as given
here.

Finally, SDA is one member of a family. The matrix sign function computes the same stable subspace
by iterating $cal(H)_(k+1) = (cal(H)_k + tau^2 cal(H)_k^(-1)) slash 2$, which is doubling with the
Cayley step pushed to the very end; Newton's method converges quadratically too but approaches
$P$ from above, while SDA approaches from below; and the ordered Schur and QZ methods of the
companion note are direct rather than iterative @poloni2020doubling. SDA is attractive when $n$ is
moderate and dense: each step is a handful of $n times n$ matrix operations, it is short enough to
write down, and it needs no eigenvalue decomposition.

#check[
  The running example has $sigma = 0.531$. Roughly how many value-iteration steps does each
  doubling step save, and why does that ratio keep growing?
]
Each squaring replaces $2^k$ value steps by one, and the errors satisfy
$e_(k) approx C e_(k-1)^2$, so the *ratio* of saved work grows with the accuracy already attained:
doubling is quadratic in the number of steps, the value iteration linear. That is why the gap
between the two curves in #ref(<fig:work>) widens as they descend.

= Sources and further reading <s9>

The structure-preserving doubling algorithm and its continuous-time reduction are due to
Chu, Fan, Lin and Wang @chu2004pdare, @chu2005sda, building on Anderson's doubling algorithm for
the steady-state discrete Riccati equation @anderson1978second. The presentation of both as
"squaring variants" of a fixed-point iteration, with the factorization #ref(<eq:ansatz>) and the
convergence caveats, follows the comparative introduction by Poloni @poloni2020doubling. The
convergence of the algorithm under weaker hypotheses than stabilizability and detectability, and
its behavior when $sigma = 1$, are in the same reference and in the original papers.

Not consulted, and listed only as pointers: the textbook treatment of discrete Riccati theory in
Lancaster and Rodman, *Algebraic Riccati Equations*; the SLICOT and MATLAB `dare` implementations;
and the low-rank and decoupled variants for large sparse problems, which are a different regime
from the dense problems this note addresses.
