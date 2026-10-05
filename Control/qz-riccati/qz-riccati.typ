// qz-riccati.typ -- a teach-an-engineer note, filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ.
//
// Every number quoted below is printed by scripts/verify_qz_riccati.m, which
// also checks the closed forms, their residuals, the closed-loop spectra, and
// the agreement of the three routes. Run it from the repository root with
//   octave --no-gui --quiet Control/qz-riccati/scripts/verify_qz_riccati.m

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, check, navy, teal, gray

#show: note-ilm.with(
  title: [Solving the Algebraic Riccati Equation with the QZ Algorithm],
  authors: "Amp",
  abstract: [
    A linear-quadratic regulator needs the stabilizing solution $P$ of an algebraic Riccati
    equation, and $P$ is the graph of the stable invariant subspace of a matrix built from the
    plant and the cost. That matrix can be the wrong object to hand to an eigensolver: forming
    it demands $R^(-1)$, and the eigenvectors it is usually read from carry almost no
    information when two eigenvalues nearly coalesce. This note follows the alternative the
    libraries actually use: keep the data unfactored in an extended Hamiltonian pencil, let the
    QZ algorithm reduce the pencil to an ordered generalized Schur form, and read $P$ off the
    deflating subspace of the stable part. The running example is a unit mass on a unit spring
    with two cost knobs, each of which has a closed-form solution, so every route can be
    measured against an exact answer: the pencil route holds machine precision where the matrix
    route loses eight digits, and all routes inherit the same conditioning limit when an
    eigenvalue approaches the imaginary axis.
  ],
  bibliography: bibliography("refs.bib"),
)

// =============================== 1. PROBLEM ================================

= The problem, and the object we have to compute <s1>

A linear-quadratic regulator chooses $u$ to minimize

$ J = integral_0^oo (x^T Q x + u^T R u) dif t, quad dot(x) = A x + B u, $ <eq:lqr>

with $Q = Q^T >= 0$ and $R = R^T > 0$. If $(A, B)$ is stabilizable and $(C, A)$ is detectable,
where $Q = C^T C$, the optimal feedback is $u = -R^(-1) B^T P x$ and the symmetric positive
semidefinite $P$ solves the continuous-time algebraic Riccati equation

$ A^T P + P A - P G P + Q = 0, quad G = B R^(-1) B^T, $ <eq:care>

with the closed loop $A - G P$ stable. The whole job is to compute $P$. Written as a quadratic
matrix equation, as above, that job has no obvious starting point: $P$ has $n(n+1) \/ 2$
unknowns, the equation is nonlinear, and where a solution would come from is not visible.

The equation is better read as a statement about a subspace. Define the Hamiltonian matrix

$ H = mat(A, -G; -Q, -A^T). $ <eq:H>

Then $P$ satisfies #ref(<eq:care>) exactly when the graph subspace of $P$,

$ cal(S)_P = "span" mat(I_n; P), quad "satisfies" quad H mat(I_n; P) = mat(I_n; P)(A - G P). $ <eq:graph>

That is one line of block multiplication. The first block row of #ref(<eq:graph>) reads
$A - G P = A - G P$, which is where the closed loop comes from. The second reads
$-Q - A^T P = P(A - G P) = P A - P G P$, and moving everything to one side gives
$-Q - A^T P - P A + P G P = 0$, which is #ref(<eq:care>). So *the Riccati solution is the graph
of an invariant subspace of $H$, and the closed loop is the action of $H$ on that subspace.*
Since the closed loop must be stable, the subspace is the one spanned by the eigenvectors of $H$
belonging to its eigenvalues with negative real part: its *stable invariant subspace*.

From a basis of that subspace, the solution follows without solving #ref(<eq:care>) again.
Partition a basis of the stable subspace into an upper block $X_1$ and a lower block $X_2$, both
in $bb(R)^(n times n)$. Choose the basis to be the graph of $P$, so that $X_2 = P X_1$; then
#ref(<eq:graph>) is exactly the invariance statement for that basis, and the solution is the
matrix division

$ P = X_2 X_1^(-1) $ <eq:elim>

provided $X_1$ is invertible. This elimination is the classical route to the Riccati solution,
and it is also the shape of every method that follows: *a basis of the stable subspace comes
first, and a division turns it into $P$.* The symplectic-matrix note in this repository derives
the same identity with the symplectic form in the foreground, for the same plant
(`Control/symplectic-matrix/symplectic-matrix.pdf`, page 6); what this note needs from it is only
the invariance statement #ref(<eq:graph>) and the division #ref(<eq:elim>).

*The example, and two knobs.* Take a unit mass on a unit spring, actuated by a force:

$ A = mat(0, 1; -1, 0), quad B = mat(0; 1). $ <eq:plant>

The unforced plant is an oscillator with eigenvalues $plus.minus i$, so it sits exactly on the
stability boundary. Two cost choices on this one plant isolate two different difficulties, and
both have closed-form solutions, which is why this plant is worth more here than a random matrix.

Both cost choices below keep the same symmetric structure,
$P = mat(p_(11), p_(12); p_(12), p_(22))$; only its three entries change.

*Cheap state penalty:* $Q = epsilon I$, $R = 1$. Then

$ p_(12) = sqrt(1 + epsilon) - 1, quad p_(22) = sqrt(2 p_(12) + epsilon), \ quad p_(11) = p_(22)(1 + p_(12)). $ <eq:closed1>

As $epsilon -> 0$ the penalty on the state vanishes, the gains go to zero, and the closed-loop
eigenvalues tend to $plus.minus i$ from the left: the controller barely acts and the closed loop
approaches the stability boundary. Measured: $norm(P) = 1.4143 times 10^(-4)$ at
$epsilon = 10^(-8)$, and the closed-loop real part is $-0.70711 sqrt(epsilon)$.

*Cheap control:* $Q = I$, $R = rho$. With the same $P$,

$ p_(12) = sqrt(rho^2 + rho) - rho, quad p_(22) = sqrt(rho (2 p_(12) + 1)), \ quad p_(11) = p_(22)(1 + p_(12) \/ rho). $ <eq:closed2>

Now the *control* is nearly free, the gains saturate, and one closed-loop eigenvalue runs off to
$-oo$ while the other stays at $-1$. Measured: $norm(P) = 1.0100$ at $rho = 10^(-4)$ with
closed-loop eigenvalues ${-99.985, -1.0002}$; at $rho = 3 times 10^(-10)$ the pair is
${-57735, -1}$ and $norm(P) = 1.0000$.

Each closed form is a solution of #ref(<eq:care>) for its own data. The reproducing script
verifies that by its residual -- below $3.7 times 10^(-16)$ in every row it prints -- and by the
negative real part of the closed-loop spectrum. From here on there is an exact answer to measure
every algorithm against, which is the only way to separate a conditioning effect from an
algorithmic one.

*Taken as given.* Invertibility of $R$ for the *statement* #ref(<eq:care>), and stabilizability
and detectability for existence and uniqueness of a stabilizing $P$ @laub1979schur. The Riccati
equation itself is not re-derived beyond #ref(<eq:graph>); the question this note answers is how
the subspace in #ref(<eq:graph>) is computed when the matrix route is unattractive.

= The eigenvector basis is the wrong object to want <s2>

The classical route to #ref(<eq:elim>) asks the eigensolver for the $n$ eigenvectors of $H$
belonging to eigenvalues with negative real part. That request is far more fragile than the
subspace it is meant to describe.

*The smallest example with the same mechanism.* Perturb a Jordan block:

$ mat(1, 1; 0, 1) + mat(0, 0; epsilon, 0) = mat(1, 1; epsilon, 1). $ <eq:pivot>

Its eigenvalues are $1 plus.minus sqrt(epsilon)$, with unit eigenvectors proportional to
$(1, plus.minus sqrt(epsilon))$. A perturbation of size $epsilon$ therefore splits a double
eigenvalue into two eigenvalues at distance $2 sqrt(epsilon)$, and the two eigenvectors differ
by an angle of order $sqrt(epsilon)$: their overlap is

$ abs(v_1^T v_2) = frac(1 - epsilon, 1 + epsilon), quad "so" quad 1 - abs(v_1^T v_2) = frac(2 epsilon, 1 + epsilon). $ <eq:pivotoverlap>

The script checks both statements against the computed eigenpairs at
$epsilon = 10^(-4), 10^(-8), 10^(-12)$. The exponents are the point: the *eigenvalues* separate
like $sqrt(epsilon)$, while the *eigenvectors* coincide like $1 - O(epsilon)$. An eigenvector
carries a direction, so at small $epsilon$ two eigenvectors that an algorithm must tell apart
differ by $O(epsilon)$ in direction -- much less than the $sqrt(epsilon)$ by which their
eigenvalues separate. What is special to this $2 times 2$ model is that it is not Hamiltonian and
has a single pair; what survives is the $sqrt(epsilon)$ splitting of a coalescing pair and the
faster crowding of its eigenvectors.

*The same mechanism in the running example.* In the cheap-state-penalty knob the pairs near
$plus.minus i$ coalesce as $epsilon -> 0$. The split of the pair that straddles the imaginary
axis is exactly the gap $sqrt(2 p_(12) + epsilon) = sqrt(2 epsilon)(1 + O(epsilon))$, and its two
members lie on opposite sides of the axis -- one stable, one unstable. For the eigenvalue nearest
$+i$ and its nearest twin, the script measures:

#figure(
  kind: "table",
  supplement: [Table],
  caption: [The eigenvector route on the cheap-state-penalty knob. All errors are relative to the
    closed form #ref(<eq:closed1>), computed by `scripts/verify_qz_riccati.m`. Inspect the last
    three columns: at every $epsilon$ the three routes land within a factor of three of one
    another. Here $"relerr"$ means $norm(P_"route" - P) \/ norm(P)$, and $V$ is the full
    matrix of eigenvectors of $H$.],
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    align: (right, right, right, right, right, right, right),
    stroke: 0.4pt,
    table.header(
      [$epsilon$], [$abs("Re" lambda)$], [$1 - abs(v_1^T v_2)$], [$"cond"(V)$],
      [$"relerr"_"eig"$], [$"relerr"_"schur"$], [$"relerr"_"qz"$],
    ),
    [$10^(-4)$], [$7.071 times 10^(-3)$], [$4.249 times 10^(-4)$], [$7.071 times 10^1$], [$5.33 times 10^(-14)$], [$1.18 times 10^(-12)$], [$2.11 times 10^(-13)$],
    [$10^(-6)$], [$7.071 times 10^(-4)$], [$4.250 times 10^(-6)$], [$7.071 times 10^2$], [$3.34 times 10^(-11)$], [$3.02 times 10^(-11)$], [$8.81 times 10^(-11)$],
    [$10^(-8)$], [$7.071 times 10^(-5)$], [$4.250 times 10^(-8)$], [$7.071 times 10^3$], [$8.31 times 10^(-9)$], [$1.73 times 10^(-9)$], [$3.71 times 10^(-9)$],
    [$10^(-12)$], [$7.071 times 10^(-7)$], [$4.250 times 10^(-12)$], [$7.071 times 10^5$], [$2.83 times 10^(-5)$], [$5.28 times 10^(-5)$], [$8.34 times 10^(-5)$],
  ),
) <fig:knob1>

The numbers behind the table: the straddling pair's eigenvectors have overlap
$1 - abs(v_1^T v_2) = 4.25 epsilon$, so at $epsilon = 10^(-8)$ they agree to eight digits; the
pair's real part is $abs("Re" lambda) = 0.70711 sqrt(epsilon)$, so at $epsilon = 10^(-8)$ its
stable and unstable members differ in real part by $1.4 times 10^(-4)$; and
$"cond"(V) = 0.707 \/ sqrt(epsilon)$, rising from $7.07 times 10^1$ at $epsilon = 10^(-4)$ to
$7.07 times 10^5$ at $epsilon = 10^(-12)$.

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The spectrum of $H$ in the cheap-state-penalty knob. Left: the four eigenvalues for
    $epsilon = 10^(-2)$ (teal) and $epsilon = 10^(-8)$ (navy). Each pair straddles the imaginary
    axis, and at this scale the $epsilon = 10^(-8)$ pair has collapsed onto it. Right: the two
    quantities that decide whether a pair can be told apart, on logarithmic axes, at
    $epsilon = 10^(-2), 10^(-4), dots, 10^(-12)$. Inspect the slopes: the eigenvalue gap closes
    like $sqrt(epsilon)$ (teal) while the eigenvectors crowd together like $epsilon$ (navy).],
  grid(columns: (1fr, 1fr), gutter: 1.0em,
    [
      #box(width: 100%, height: 5.0cm)[
        #let w = 6.4cm
        #let h = 4.6cm
        #let cx = 0.5 * w
        #let px(re) = cx + re / 0.12 * (h / 2)
        #let py(im) = h / 2 - im / 1.3 * (h / 2)
        #place(top + left)[#line(start: (px(-0.12), py(0)), end: (px(0.12), py(0)), stroke: 0.6pt + gray)]
        #place(top + left)[#line(start: (px(0), py(-1.3)), end: (px(0), py(1.3)), stroke: 0.6pt + gray)]
        #for (re, im, col) in (
            (-0.070666690, -0.999996891, teal), (0.070666690, -0.999996891, teal),
            (0.070666690, 0.999996891, teal), (-0.070666690, 0.999996891, teal),
            (0.000070711, -1.0, navy), (0.000070711, 1.0, navy),
            (-0.000070711, -1.0, navy), (-0.000070711, 1.0, navy),
          ) {
          place(top + left, dx: px(re) - 2.6pt, dy: py(im) - 2.6pt)[#circle(radius: 2.6pt, fill: col)]
        }
        #place(top + left, dx: px(0.075), dy: py(1.03))[#text(size: 8pt, fill: teal)[$epsilon = 10^(-2)$]]
        #place(top + left, dx: px(0.030), dy: py(0.86))[#text(size: 8pt, fill: navy)[$epsilon = 10^(-8)$]]
        #place(top + left, dx: px(0.012), dy: py(1.24))[#text(size: 8pt, fill: gray)[$+i$]]
        #place(top + left, dx: px(0.012), dy: py(-1.30))[#text(size: 8pt, fill: gray)[$-i$]]
        #place(top + left, dx: px(-0.112), dy: py(-0.09))[#text(size: 8pt, fill: gray)[$"Re"$]]
      ]
    ],
    [
      #box(width: 100%, height: 5.0cm)[
        #let w = 6.4cm
        #let x0 = 0.62cm
        #let y0 = 3.9cm
        #let ytop = 0.4cm
        // x maps log10(eps) in [-12, -1]; y maps log10(value) in [-12, 0]
        #let ex(t) = x0 + (t + 12) / 11 * (w - x0 - 0.25cm)
        #let ey(t) = y0 - (t + 12) / 12 * (y0 - ytop)
        #place(top + left)[#line(start: (x0, y0), end: (w - 0.25cm, y0), stroke: 0.6pt + gray)]
        #place(top + left)[#line(start: (x0, y0), end: (x0, ytop), stroke: 0.6pt + gray)]
        #place(top + left)[#line(
            start: (ex(-12), ey(-5.8495)),
            end: (ex(-1), ey(-0.3495)),
            stroke: (paint: gray, thickness: 0.6pt, dash: "dashed"),
          )]
        #let series = (
            (-2, -0.8497, -1.3803),
            (-4, -1.8495, -3.3717),
            (-6, -2.8495, -5.3716),
            (-8, -3.8495, -7.3716),
            (-10, -4.8495, -9.3716),
            (-12, -5.8495, -11.3716),
          )
        #for (lx, lgap, lov) in series {
          place(top + left, dx: ex(lx) - 2.4pt, dy: ey(lgap) - 2.4pt)[#circle(radius: 2.4pt, fill: teal)]
          place(top + left, dx: ex(lx) - 2.4pt, dy: ey(lov) - 2.4pt)[#circle(radius: 2.4pt, fill: navy)]
        }
        #place(top + left, dx: x0 + 0.08cm, dy: y0 + 0.10cm)[#text(size: 7.5pt, fill: gray)[$10^(-12) quad -> quad 10^(-1) " in " epsilon$]]
        #place(top + left, dx: 0.04cm, dy: ey(0) - 0.1cm)[#text(size: 7.5pt, fill: gray)[$1$]]
        #place(top + left, dx: 0.04cm, dy: ey(-6) - 0.1cm)[#text(size: 7.5pt, fill: gray)[$10^(-6)$]]
        #place(top + left, dx: 0.04cm, dy: ey(-12) - 0.34cm)[#text(size: 7.5pt, fill: gray)[$10^(-12)$]]
        #place(top + left, dx: x0 + 0.55cm, dy: 1.15cm)[#text(size: 7.5pt, fill: teal)[gap $sqrt(2 epsilon)$]]
        #place(top + left, dx: x0 + 0.30cm, dy: 2.75cm)[#text(size: 7.5pt, fill: navy)[overlap $4.25 epsilon$]]
      ]
    ],
  ),
) <fig:spectrum>

*Reading the table honestly.* The obvious guess is that the eigenvector route is the inaccurate
one. It is not, in this example. At $epsilon = 10^(-8)$ the three routes give relative errors
$8.31 times 10^(-9)$, $1.73 times 10^(-9)$ and $3.71 times 10^(-9)$: all within a factor of
three of $2.2 times 10^(-16)$ divided by $epsilon$, which is $2.2 times 10^(-8)$. The reason is
that the errors of two nearly parallel eigenvectors largely cancel in the ratio
$X_2 X_1^(-1)$: here the stable subspace is a well-conditioned graph (the unit-norm graph basis
of the stable subspace, and also the pair of stable eigenvectors, have smallest singular value
$1.000$ at $epsilon = 10^(-8)$). The eigenvector route's accuracy in this example
is therefore not evidence that it is safe; it is a cancellation that the formulation does not
promise. What the formulation *does* promise is weaker and more useful: the stable invariant
subspace exists whenever no eigenvalue lies on the imaginary axis, with no requirement that $H$
be diagonalizable or that a chosen basis be well separated.

#check[Before reading on: from #ref(<fig:knob1>), does the eigenvector route return a less
  accurate $P$ than the ordered-Schur route here?]

Answer, immediately: no. The three columns are the same size to within a factor of three. The
eigenvector route is fragile, not visibly wrong, in this example.

*The repair, and it is not QZ.* Laub's observation was that the *subspace* is what the problem
defines, so one should get a basis of it from orthogonal transformations rather than from
eigenvectors: reorder the real Schur form of $H$ so the eigenvalues with negative real part lead,
then read the graph off the leading columns @laub1979schur. He was blunt about the motivation:
"the use of eigenvectors is often highly unsatisfactory from a numerical point of view and the
present method uses the so-called and much more numerically attractive Schur vectors." Concretely,
if

$ H U = U T, quad U = mat(U_(11), U_(12); U_(21), U_(22)), quad T = mat(T_(11), T_(12); 0, T_(22)) $ <eq:schurform>

with $U$ orthogonal and the eigenvalues of $T_(11)$ in the open left half plane, then the leading
$n$ columns of $U$ span the stable invariant subspace and, when $U_(11)$ is invertible,

$ P = U_(21) U_(11)^(-1). $ <eq:schurP>

That is the same division as #ref(<eq:elim>), with a basis that is orthonormal by construction and
needs no eigenvector decomposition. Measured at $R = 1$ for $epsilon = 10^(-2)$ and $10^(-6)$,
this route and the pencil route of the next two sections agree to
$norm(P_q - P_s) \/ norm(P) = 1.08 times 10^(-14)$ and $7.30 times 10^(-11)$: the machinery
below does not change the answer here. It changes what the algorithm can be *given*.

= When forming the Hamiltonian is itself the loss <s3>

The cheap-control knob breaks a different step: forming $H$. Its off-diagonal blocks are $Q$ and
$G$, and $G = B R^(-1) B^T$ calls for the inverse of the control weight. When $R$ is small, the
entries of $G$ are large and their rounding error is amplified by the same small number.

Concretely, in the running example the $(2,2)$ entry of $G$ is $1 \/ rho$. Storing it as a
floating-point number injects an absolute error of about $epsilon_m$ divided by $rho$, where
$epsilon_m = 2.2 times 10^(-16)$ is the unit roundoff, while the rest of $H$ has entries of order
one. So the matrix handed to the Schur route is already perturbed by that amount before the
algorithm starts, and the relative error of the computed $P$ is observed to track
$epsilon_m \/ rho$: the digits lost are, roughly, the digits of $1 \/ rho$.

#figure(
  kind: "table",
  supplement: [Table],
  caption: [The cheap-control knob: $Q = I$, $R = rho$, measured against the closed form
    #ref(<eq:closed2>). "matrix route" forms $G = B R^(-1) B^T$ and runs the ordered Schur route
    on $H$; "pencil route" keeps $B$ and $R$ inside the extended pencil of #ref(<eq:pencil>)
    and orders its generalized Schur form. Inspect the two error columns: they separate as $rho$
    shrinks, and at $rho = 0$ the matrix route has no value to compute.],
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (right, right, right, right, right),
    stroke: 0.4pt,
    table.header(
      [$rho$], [$norm(P)$], [$"relerr"_"matrix"$], [$"relerr"_"pencil"$], [digits recovered],
    ),
    [$10^(-4)$], [$1.0100$], [$3.09 times 10^(-13)$], [$2.65 times 10^(-16)$], [$3.1$],
    [$10^(-6)$], [$1.0010$], [$1.09 times 10^(-10)$], [$1.14 times 10^(-15)$], [$5.0$],
    [$3 times 10^(-8)$], [$1.0002$], [$1.56 times 10^(-9)$], [$5.52 times 10^(-16)$], [$6.5$],
    [$3 times 10^(-10)$], [$1.0000$], [$2.21 times 10^(-7)$], [$1.17 times 10^(-15)$], [$8.3$],
    [$0$], [—], [no finite value], [still a regular pencil], [—],
  ),
) <fig:knob2>

The pencil route holds relative errors of $10^(-16)$ to $10^(-15)$ across the whole table --
machine precision, with no degradation as $rho$ shrinks -- while the matrix route tracks
$2.2 times 10^(-16)$ divided by $rho$ to within a factor of ten. At $rho = 0$ the comparison
stops being about accuracy: $B R^(-1) B^T$ is not finite, so there is no matrix $H$ to factorize,
while the same data still defines a regular pencil whose QZ form exists. Measured for exactly
that data: a $5 times 5$ pencil with $2$ finite and $3$ infinite eigenvalues.

This is the documented reason the pencil formulation is standard. Van Dooren introduced the
generalized eigenvalue route for precisely this data @vandooren1981generalized, and Benner and
Sima state the point in one sentence: "the deflating subspace approach using the extended pencils
yields better numerical accuracy if $R$ is ill-conditioned as rounding errors introduced by
forming $R^(-1)$ are avoided" @benner2003slicot. They make the same point on the discrete side:
"the symplectic matrix can only be formed if $A$ is nonsingular ... it is preferable to work with
the symplectic pencil", an objection that also applies to the descriptor matrix $E$.

*What has changed conceptually.* Nothing about the eigenvalues: the pencil of the next section has
the same finite eigenvalues as $H$. What changes is that $R$ is never inverted, and that a singular
$R$ -- a singular *pencil* -- is a representable object rather than a failure. That is what the QZ
algorithm, unlike a QR iteration on a single matrix, is built to process.

= The extended pencil and its deflating subspace <s4>

The eigenvalue problem that keeps the data unfactored is a *generalized* one: find $lambda$ and
$v != 0$ with

$ M v = lambda N v, quad "that is" quad (M - lambda N) v = 0. $ <eq:gep>

The pencil $M - lambda N$ carries a *pair* $(alpha, beta)$ instead of a single number:
$lambda = alpha \/ beta$ when $beta != 0$, and the pair $(alpha, 0)$ is an infinite
eigenvalue, a legitimate answer rather than an error. The pencil is called regular when
$det(M - lambda N)$ does not vanish identically. Nothing here requires $N$, or any block of it,
to be invertible -- exactly the property that forming $G = B R^(-1) B^T$ destroyed.

For the Riccati equation the pencil is built by keeping $B$ and $R$ as blocks. With the state
split as before and the control carried along as a third block, take

$ M - lambda N = mat(A, 0, B; -Q, -A^T, 0; 0, B^T, R) - lambda mat(I, 0, 0; 0, I, 0; 0, 0, 0). $ <eq:pencil>

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The two objects for the same data. Left: the matrix route forms $G$ first, which
    means applying $R^(-1)$ and merging the result with $B$. Right: the extended pencil keeps
    $A$, $B$, $Q$, $R$ as separate blocks and adds only identity blocks, so no inverse is formed
    anywhere. Inspect which route can still be assembled when $R$ is singular: only the right
    one.],
  grid(columns: (1fr, 1fr), gutter: 1.2em,
    [
      #align(center)[
        #table(
          columns: 2, stroke: 0.5pt, align: center + horizon,
          table.cell(fill: navy.transparentize(88%))[$A$],
          table.cell(fill: teal.transparentize(82%))[$-G = -B R^(-1) B^T$],
          table.cell(fill: teal.transparentize(82%))[$-Q$],
          table.cell(fill: navy.transparentize(88%))[$-A^T$],
        )
        #v(4pt)
        #text(size: 9pt)[$H$: the shaded blocks are *formed*; $R^(-1)$ touches every entry of $G$]
      ]
    ],
    [
      #align(center)[
        #table(
          columns: 3, stroke: 0.5pt, align: center + horizon,
          table.cell(fill: navy.transparentize(90%))[$A$],
          table.cell(fill: gray.transparentize(88%))[$0$],
          table.cell(fill: teal.transparentize(84%))[$B$],
          table.cell(fill: teal.transparentize(84%))[$-Q$],
          table.cell(fill: navy.transparentize(90%))[$-A^T$],
          table.cell(fill: gray.transparentize(88%))[$0$],
          table.cell(fill: gray.transparentize(88%))[$0$],
          table.cell(fill: teal.transparentize(84%))[$B^T$],
          table.cell(fill: teal.transparentize(84%))[$R$],
        )
        #v(4pt)
        #text(size: 9pt)[$M - lambda N$: teal blocks are the data as given; no inverse]
      ]
    ],
  ),
) <fig:pencilblocks>

Why this pencil answers the Riccati equation is a one-line elimination. Write a null vector with
blocks $x_1$, $x_2$, $u$ in the order of #ref(<eq:pencil>). The third block row is
$B^T x_2 + R u = 0$, so $u = -R^(-1) B^T x_2$. The second is $-Q x_1 - A^T x_2 = lambda x_2$,
and the first becomes $A x_1 - G x_2 = lambda x_1$. Setting $x_2 = P x_1$ in the first gives
$lambda = A - G P$ applied to $x_1$; putting the same relation in the second gives
$0 = Q + A^T P + P(A - G P) = Q + A^T P + P A - P G P$, which is #ref(<eq:care>). So the finite
eigenvalues of #ref(<eq:pencil>) are the eigenvalues of $H$, and the graph subspace of the Riccati
solution, #ref(<eq:graph>), is a *deflating subspace* of the pencil: a subspace $Z$ with
$M Z = N Z S$ for some $S$, the generalization of an invariant subspace to a pencil. Note what the
elimination above is *not*: it is not what the algorithm does. Solving
$u = -R^(-1) B^T x_2$ would invert $R$ again, so the algorithm never solves for $u$; it removes
the third block by an orthogonal transformation instead. The script's check of this whole
construction is indirect but decisive: at $R = 1$, where the pencil reduces to the standard
problem, the pencil route and the ordered-Schur route on $H$ agree to $1.08 times 10^(-14)$
relative. SLICOT documents the same reduction: "a standard eigenproblem is solved in the
continuous-time case if $G$ is given" @slicot_sb02od.

*Deflation.* The pencil #ref(<eq:pencil>) is $(2n + m) times (2n + m)$ where $m$ is the number of
controls. When $R$ is nonsingular it has exactly $m$ infinite eigenvalues, all of them contributed
by the last block, so only $2n$ of them are finite; before ordering anything, the algorithm
compresses that cost direction away. Let $M_c$ be the last $m$ columns of $M$, that is the stacked
blocks $B$, $0$, $R$, and take a QR decomposition

$ M_c = Q mat(R_1; 0), quad "then" quad tilde(M) - lambda tilde(N) = Q_2^T (M - lambda N) mat(I_(2n); 0), $ <eq:deflate>

where $Q_2$ is $Q$ with its first $m$ columns dropped. The result is a $2n times 2n$ pencil with
the same finite eigenvalues and none infinite. This is van Dooren's reduction; scipy's
`solve_continuous_are` performs it with the comment "deflate the pencil to 2m x 2m ala Ref.1,
eq.(55)" @scipy_are. The script measures the counts for the running example, where $m = 1$: $4$
finite and $1$ infinite at $R = 10^(-6)$, becoming $4$ and $0$ after the deflation. At $R = 0$ the
same data gives $2$ finite and $3$ infinite, of which the deflated $4 times 4$ pencil keeps $2$ --
harmless, because a pair with $beta = 0$ never satisfies $"Re"(alpha \/ beta) < 0$ and so is never
selected.

The deflated second matrix is not the identity, and it inherits the conditioning of $R$: its
smallest singular value is $7.07 times 10^(-1)$ at $R = 1$, $1.00 times 10^(-6)$ at $R = 10^(-6)$,
and $9.46 times 10^(-9)$ for $R = "diag"(1, 10^(-8))$ at a second size the script checks. QZ
touches that matrix only with unitary transformations, so it never inverts it. That is section 3's
eight-digit loss seen at the level of the algorithm: forming $G = B R^(-1) B^T$ *is* inverting this
block.

= What the QZ algorithm computes <s5>

The QZ algorithm is the generalized eigenvalue problem's answer to the QR algorithm
@molerstewart1973algorithm: it reduces a *pair* of matrices to triangular form with two unitary
transformations,

$ Q^T (M - lambda N) Z = S - lambda T, quad S, T "upper triangular", quad Q, Z "unitary", $ <eq:qz>

the pairs $(S_(i i), T_(i i))$ on the diagonals being the eigenvalues $alpha \/ beta$. Because
$Q$ and $Z$ are unitary, no matrix is inverted and no column of the pencil is privileged. Moler
and Stewart's abstract states the property the Riccati problem needs: "no inversions of $B$ or
its submatrices are used" -- their $B$ is the pencil's second matrix, which is $N$ here. In
floating point the pencil is balanced first, which is what makes the computed subspace accurate
for badly scaled data @benner2001symplectic.

*How the iteration gets there.* Three things happen before any eigenvalue is read off, and none of
them divides by a matrix. First the pair is reduced to *Hessenberg-triangular* form: $N$ is driven
to upper triangular by transformations from the left, $M$ to upper Hessenberg from the left, and
each left transformation that spoils $N$ is repaired from the right. That is $O(n^3)$ once. Then
comes the iteration itself @molerstewart1973algorithm: a double shift is taken from the trailing
$2 times 2$ block *of the pencil*, applied implicitly by a small orthogonal transformation, and the
bulge it creates is chased down the Hessenberg band with rotations applied on both sides so that
$T$ stays triangular -- each sweep $O(n^2)$, and when $N = I$ this is exactly the QR algorithm
with double shifts. Last, convergence is decided by the *pair* rather than by one matrix: a
subproblem splits off when the sub-diagonal coupling of $S$ is negligible against the neighbouring
diagonal entries of both $S$ and $T$, and a pair with $T_(i i) = 0$ and $S_(i i) != 0$ is infinite
and is deflated out of the way. That last event is the only place where $beta = 0$ ever appears.

The second ingredient is *ordering*. A QZ driver such as LAPACK's `dgges`, reachable as `ordqz`
in Octave and MATLAB and as `scipy.linalg.ordqz`, takes a selection rule and moves the selected
pairs to the leading diagonal blocks by further unitary transformations. The rule used for the
Riccati equation selects the pairs with $"Re"(alpha \/ beta) < 0$ (Octave's `'lhp'`, LAPACK's
`sort` keyword). After ordering, the first $n$ columns of $Z$ are a unitary basis of the stable
deflating subspace, and the solution is read off them.

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The ordered generalized Schur form. Left: $S$ and $T$ after QZ, with the selected
    stable pairs moved to the leading block by unitary transformations. Right: the conforming
    partition of $Z$. Only the final, small system $U_(11)^T P^T = U_(21)^T$ touches $U_(11)$,
    and it is solved by substitution; the defect $norm(U_(11)^T U_(21) - U_(21)^T U_(11))$
    measures the symmetry that $P$ should have.],
  grid(columns: (1fr, 1fr), gutter: 1.2em,
    [
      #align(center)[
        #table(
          columns: 2, stroke: 0.5pt, align: center + horizon,
          table.cell(fill: navy.transparentize(86%))[$S_(11), T_(11)$],
          table.cell(fill: gray.transparentize(90%))[$S_(12), T_(12)$],
          table.cell(fill: gray.transparentize(90%))[$0$],
          table.cell(fill: gray.transparentize(92%))[$S_(22), T_(22)$],
        )
        #v(4pt)
        #text(size: 9pt)[$n$ stable pairs first, by unitary reordering]
      ]
    ],
    [
      #align(center)[
        #table(
          columns: 2, stroke: 0.5pt, align: center + horizon,
          table.cell(fill: navy.transparentize(86%))[$U_(11)$],
          table.cell(fill: gray.transparentize(92%))[$U_(12)$],
          table.cell(fill: navy.transparentize(86%))[$U_(21)$],
          table.cell(fill: gray.transparentize(92%))[$U_(22)$],
        )
        #v(4pt)
        #text(size: 9pt)[$P = U_(21) U_(11)^(-1)$, a solve rather than an inverse]
      ]
    ],
  ),
) <fig:qzform>

*The whole route written out.* `scripts/trace_qz_pencil.m` prints every stage of that recipe for
the running example at $R = 10^(-6)$; the numbers below are its output. The pairs arrive in an
arbitrary order, and the two steps of the recipe act on that list:

#figure(
  kind: "table",
  supplement: [Table],
  caption: [The pairs $(alpha, beta)$ as ratios, in the order QZ produced them, after the QR
    deflation, and after the ordering rule. Inspect what each step does to the list: the deflation
    removes the infinite pair, and the ordering moves the two stable ratios -- the closed loop --
    to the front. Printed by `scripts/trace_qz_pencil.m`.],
  table(
    columns: (auto, auto),
    align: (left, left),
    stroke: 0.4pt,
    table.header([stage], [ratios $alpha \/ beta$, in order]),
    [the full pencil, $2n + m = 5$], [$-999.9985$, $+999.9985$, $-1.000002$, $+1.000002$, $oo$],
    [after the QR deflation, $2n = 4$], [$-999.9985$, $+999.9985$, $+1.000002$, $-1.000002$],
    [after ordering, $"Re"(alpha \/ beta) < 0$ first], [$-999.9985$, $-1.000002$, $+999.9985$, $+1.000002$],
    [closed loop of the computed $P$], [$-999.9985$, $-1.000002$],
  ),
) <fig:pairs>

The last row is the check: the two ratios the ordering put first are the closed-loop spectrum of
the $P$ that comes out, which the script reads from $A - G P$ independently.

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The ordered generalized Schur form of the deflated pencil, rounded to four decimals, as
    printed by `scripts/trace_qz_pencil.m`. Inspect the triangularity and the shaded leading
    $2 times 2$ submatrix, which is the stable half the answer is read from. With all four
    eigenvalues real, every diagonal entry is a pair $(S_(i i), T_(i i))$; a complex conjugate pair
    would arrive as an unreduced $2 times 2$ block instead of two diagonal entries.],
  grid(columns: (1fr, 1fr), gutter: 1.0em,
    [
      #align(center)[
        #table(
          columns: 4, stroke: 0.4pt, align: right,
          table.cell(fill: navy.transparentize(86%))[$-1.4142$],
          table.cell(fill: navy.transparentize(86%))[$-0.5003$],
          table.cell(fill: gray.transparentize(93%))[$-0.2888$],
          table.cell(fill: gray.transparentize(93%))[$0.4078$],
          table.cell(fill: navy.transparentize(86%))[$0$],
          table.cell(fill: navy.transparentize(86%))[$-0.8659$],
          table.cell(fill: gray.transparentize(93%))[$0.8330$],
          table.cell(fill: gray.transparentize(93%))[$0.2361$],
          [$0$], [$0$], [$1.2474$], [$0.1266$],
          [$0$], [$0$], [$0$], [$0.6547$],
        )
        #v(3pt)
        #text(size: 9pt)[$S$]
      ]
    ],
    [
      #align(center)[
        #table(
          columns: 4, stroke: 0.4pt, align: right,
          table.cell(fill: navy.transparentize(86%))[$0.0014$],
          table.cell(fill: navy.transparentize(86%))[$-0.5003$],
          table.cell(fill: gray.transparentize(93%))[$0.8659$],
          table.cell(fill: gray.transparentize(93%))[$0.0008$],
          table.cell(fill: navy.transparentize(86%))[$0$],
          table.cell(fill: navy.transparentize(86%))[$0.8659$],
          table.cell(fill: gray.transparentize(93%))[$0.5003$],
          table.cell(fill: gray.transparentize(93%))[$0.0005$],
          [$0$], [$0$], [$0.0012$], [$-0.7559$],
          [$0$], [$0$], [$0$], [$0.6547$],
        )
        #v(3pt)
        #text(size: 9pt)[$T$]
      ]
    ],
  ),
) <fig:stform>

#figure(
  kind: "table",
  supplement: [Table],
  caption: [What the recipe reads off that ordered form, and the diagnostics that come with it,
    printed by `scripts/trace_qz_pencil.m` at $R = 10^(-6)$. The closed form is the one from
    #ref(<eq:closed2>).],
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    stroke: 0.4pt,
    table.header([quantity], [value], [what it says]),
    [$U_(11)$], [$mat(0.001000, -0.706753; -0.999999, -0.000707)$],
    [$"cond" = 1.4149$: the graph is isolated],
    [$U_(21)$], [$mat(0.000002, -0.707460; -0.001000, -0.000707)$], [the lower half of the same $Z$],
    [$P = U_(21) U_(11)^(-1)$], [$mat(1.000999, 0.000999; 0.000999, 0.001001)$], [the answer],
    [closed form #ref(<eq:closed2>)], [$mat(1.000999, 0.000999; 0.000999, 0.001001)$],
    [agrees to $9.88 times 10^(-16)$ relative],
    [symmetry defect], [$4.382 times 10^(-16)$], [$P$ is symmetric to machine precision],
    [CARE residual], [$4.745 times 10^(-13)$], [it solves the equation it came from],
    [orthogonality of $Q$, $Z$], [$1.272 times 10^(-15)$, $8.044 times 10^(-16)$],
    [only orthogonal transformations were used],
  ),
) <fig:trace>

The $P$ that comes out is symmetric only up to the computation. scipy's implementation checks
exactly this and refuses to return a plausible-looking answer when the check fails: its docstring
notes that "the fail conditions are linked to the symmetry of the product $U_2 U_1^(-1)$ and
condition number of $U_1$", and the source raises `LinAlgError` with the message "the associated
Hamiltonian pencil has eigenvalues too close to the imaginary axis" when the antisymmetry defect
of $U_(11)^T U_(21)$ exceeds a threshold @scipy_are.

*How much does the defect tell you?* Less than an error bound. Perturbing the extended pencil by
100 random roundings and re-running the route, the script measures both the true relative error of
$P$ and the defect:

#grid(columns: (1fr, 1fr), gutter: 1.4em,
  [
    #table(
      columns: 3, align: (right, right, right), stroke: 0.4pt,
      table.header([$epsilon$], [$"relerr"(P)$], [defect]),
      [$10^(-4)$], [$1.91 times 10^(-12)$], [$3.45 times 10^(-14)$],
      [$10^(-6)$], [$1.76 times 10^(-10)$], [$3.21 times 10^(-13)$],
      [$10^(-8)$], [$1.66 times 10^(-8)$], [$3.01 times 10^(-12)$],
      [$10^(-10)$], [$1.31 times 10^(-6)$], [$2.98 times 10^(-11)$],
    )
  ],
  [
    The defect moves with the error -- both grow as $epsilon$ falls, the error by nearly six
    orders of magnitude and the defect by three -- but the defect is $10^1$ to $10^5$ times
    *smaller* than the error, so it is not a bound and not an estimate. Its value is as a
    tripwire: it costs almost nothing, it is not fooled by a badly conditioned subspace, and
    scipy turns it into a refusal instead of a wrong answer.
  ],
)

*The algorithm, run.* `scripts/qz_sweeps.m` executes the two ends of that machinery on real data and
prints every number below.

*First the reduction.* Take the damped-oscillator instance ($A = mat(0, 1; -1, -2)$, $Q = I$,
$R = 1$), whose deflated pencil is $4 times 4$ with a well-conditioned second matrix, and reduce it
to Hessenberg-triangular form. Phase 1 makes $B$ triangular with Householders from the left; phase 2
then zeroes the entries of $A$ below its sub-diagonal one at a time, bottom-up, and each such left
rotation fills *exactly one* entry of $B$ below its diagonal -- the sub-diagonal $(i, i-1)$ -- which
the paired right rotation removes:

#figure(
  kind: "table",
  supplement: [Table],
  caption: [The recorded rotation sequence of the reduction, from `scripts/qz_sweeps.m`. Inspect the
    last column: each left rotation creates one entry of $B$ below its diagonal, and the right
    rotation that follows removes it, so $B$ is triangular again before the next entry of $A$ is
    touched.],
  table(
    columns: (auto, auto, auto, auto),
    align: (left, left, left, right),
    stroke: 0.4pt,
    table.header([step], [left rotation on rows], [zeroes], [$B$ entry filled]),
    [1], [$(3, 4)$], [$A_(4 1)$], [$0.0000$],
    [2], [$(2, 3)$], [$A_(3 1)$], [$0.5774$],
    [3], [$(3, 4)$], [$A_(4 2)$], [$0.7071$],
  ),
) <fig:reduce>

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The same reduction in pictures, from `scripts/qz_sweeps.m`. Top: after phase 1, $B$ is
    triangular and $A$ is full -- the shaded cells of $A$ are the entries below its band that phase 2
    has to remove. Bottom: after phase 2, $A$ is upper Hessenberg and $B$ is still upper triangular.
    Both panels carry the real numbers; the verification is
    $norm(Q^T M Z - A) = 4.84 times 10^(-16)$ and $norm(Q^T N Z - B) = 2.32 times 10^(-16)$ with $Q$,
    $Z$ orthogonal to $4.51 times 10^(-16)$.],
  grid(columns: (1fr, 1fr), gutter: 1.0em,
    [
      #align(center)[
        #table(
          columns: 4, stroke: 0.4pt, align: right,
          [$0$], [$1$], [$0$], [$0$],
          table.cell(fill: teal.transparentize(84%))[$0.7071$], [$1.4142$], [$0$], [$0.7071$],
          table.cell(fill: teal.transparentize(84%))[$1$], [$0$], [$0$], [$-1$],
          [$0$], table.cell(fill: teal.transparentize(84%))[$1$], [$1$], [$-2$],
        )
        #v(3pt)
        #text(size: 9pt)[$A$ after phase 1]
      ]
    ],
    [
      #align(center)[
        #table(
          columns: 4, stroke: 0.4pt, align: right,
          [$1$], [$0$], [$0$], [$0$],
          [$0$], [$-0.7071$], [$0$], [$0$],
          [$0$], [$0$], [$-1$], [$0$],
          [$0$], [$0$], [$0$], [$-1$],
        )
        #v(3pt)
        #text(size: 9pt)[$B$ after phase 1]
      ]
    ],
    [
      #align(center)[
        #table(
          columns: 4, stroke: 0.4pt, align: right,
          [$0$], [$-0.7071$], [$-0.4082$], [$0.5774$],
          [$1.2247$], [$-0.5774$], [$0$], [$0.7071$],
          [$0$], [$1.6330$], [$-0.7071$], [$-1$],
          [$0$], [$0$], [$2.0412$], [$0.5774$],
        )
        #v(3pt)
        #text(size: 9pt)[$A$, final]
      ]
    ],
    [
      #align(center)[
        #table(
          columns: 4, stroke: 0.4pt, align: right,
          [$1$], [$0$], [$0$], [$0$],
          [$0$], [$0.8660$], [$-0.1667$], [$0.2357$],
          [$0$], [$0$], [$-0.9428$], [$-0.1667$],
          [$0$], [$0$], [$0$], [$0.8660$],
        )
        #v(3pt)
        #text(size: 9pt)[$B$, final]
      ]
    ],
  ),
) <fig:reduction>

*Then one QZ step, exactly.* On a $2 times 2$ pencil the step is a single pair of rotations, and
every number is visible. The script takes the trailing $2 times 2$ block of the reduced pair above,
whose eigenvalues are $-1$ and $2$; it uses the pair nearest the diagonal ratio, $(alpha, beta) =
(-0.894427, -0.447214)$ with $alpha \/ beta = 2$, and computes that pair's eigenvector direction
$(0.4924, 0.8704)$ -- the angle $1.0560$ radians drawn below. The right rotation $Z_2$ turns that
direction into the first coordinate, which makes the first columns of $A_2 Z_2$ and $B_2 Z_2$
parallel; one left rotation $Q_2$ then makes both matrices triangular, so the pair
$Q_2 A_2 Z_2$, $Q_2 B_2 Z_2$ below is again Hessenberg-triangular -- in fact triangular, since it is
only $2 times 2$:

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [One exact QZ step on the $2 times 2$ trailing pencil of #ref(<fig:reduction>), printed
    by `scripts/qz_sweeps.m`. Left: the eigenvector direction of the chosen shift (navy) inside the
    unit circle, with the angle the right rotation turns it. Right: the pencil, the two rotations,
    and the transformed pair. Inspect the last line: the two ratios on the diagonal are $2.000000$
    and $-1.000000$ -- the shift has moved to the front, which is deflation and ordering at once --
    and the step is an exact orthogonal equivalence, since undoing both rotations returns the
    original pencil to $5.99 times 10^(-16)$.],
  grid(columns: (1fr, 1.35fr), gutter: 1.0em,
    [
      #box(width: 100%, height: 3.6cm)[
        #let w = 3.6cm
        #let c = 1.85cm
        #place(top + left)[#circle(radius: 1.1cm, stroke: 0.5pt + gray, fill: none)]
        #place(top + left)[#line(start: (c - 1.1cm, c), end: (c + 1.1cm, c), stroke: 0.5pt + gray)]
        #place(top + left)[#line(start: (c, c - 1.1cm), end: (c, c + 1.1cm), stroke: 0.5pt + gray)]
        #place(top + left)[#line(start: (c, c), end: (c + 0.8 * 0.4924 * 1.1cm, c - 0.8 * 0.8704 * 1.1cm), stroke: 1.2pt + navy)]
        #place(top + left, dx: c + 0.05cm, dy: c - 1.35cm)[#text(size: 8pt, fill: gray)[$v = (0.4924, 0.8704)$]]
        #place(top + left, dx: c + 0.15cm, dy: c - 0.55cm)[#text(size: 8pt, fill: navy)[$1.0560 " rad"$]]
      ]
    ],
    [
      #table(
        columns: (auto, auto),
        align: (left, right),
        stroke: 0.4pt,
        [$2 times 2$ pencil, $A_2 =$], [$mat(-0.7071, -1.0000; 2.0412, 0.5774)$],
        [and $B_2 =$], [$mat(-0.9428, -0.1667; 0, 0.8660)$],
        [its eigenvalues], [$-1$, $2$],
        [right rotation $Z_2 =$], [$mat(0.4924, -0.8704; 0.8704, 0.4924)$],
        [left rotation $Q_2 =$], [$mat(-0.6286, 0.7777; -0.7777, -0.6286)$],
        [$Q_2 A_2 Z_2 =$], [$mat(1.9384, -1.2380; 0, 0.8424)$],
        [$Q_2 B_2 Z_2 =$], [$mat(0.9692, -0.1326; 0, -0.8424)$],
        [ratios on the diagonal], [$2.000000$, $-1.000000$],
      )
    ],
  ),
) <fig:qzstep>

*What is not run here.* The sweep that a library performs *between* those two ends -- the implicit
double shift with its bulge chase, which does the same arithmetic in $O(n^2)$ per sweep instead of
$O(n^3)$ -- is not implemented in this note's script. It is the one piece the reference
implementations own, and the piece the closing paragraph tells the reader not to write by hand; the
script stops at the reduction and at the elementary step, whose behavior it verifies. The bulge
chase is the same pair of rotations as #ref(<fig:qzstep>) applied down a Hessenberg band, repeated
until the sub-diagonals vanish @molerstewart1973algorithm.

Finally, this is what a library routine actually is. MATLAB's `care`, SLICOT's `SB02OD` and
scipy's `solve_continuous_are` all call the same generalized Schur machinery. The engineering
content is choosing the pencil and reading the deflating subspace; the QZ iteration itself is the
one piece of this note one should *not* write by hand.

= What this buys, and what it does not <s6>

*What it buys, stated so it can be checked.* For the running example with $Q = I$ and $R = rho$,
forming $G = B R^(-1) B^T$ in double precision and running the ordered Schur route returns $P$
with relative error $3.09 times 10^(-13)$ at $rho = 10^(-4)$, $1.09 times 10^(-10)$ at
$rho = 10^(-6)$, $1.56 times 10^(-9)$ at $rho = 3 times 10^(-8)$ and $2.21 times 10^(-7)$ at
$rho = 3 times 10^(-10)$; the deflated QZ route on the extended pencil returns
$2.65 times 10^(-16)$, $1.14 times 10^(-15)$, $5.52 times 10^(-16)$ and $1.17 times 10^(-15)$ on
the same data. At $rho = 0$ the matrix route has nothing to compute, while the pencil is regular
with $2$ finite and $3$ infinite eigenvalues. Every number in this paragraph is printed by
`scripts/verify_qz_riccati.m`, so it can be falsified by running it.

*What it is not.* It is not an answer to near-axis eigenvalues. The tempting claim is that QZ is
more accurate than the eigenvector or ordered-Schur routes when the Hamiltonian spectrum straddles
the imaginary axis. In the cheap-state-penalty knob it is not: the relative errors of the three
routes at $epsilon = 10^(-8)$ are $8.31 times 10^(-9)$, $1.73 times 10^(-9)$ and
$3.71 times 10^(-9)$, all within a factor of three of $2.2 times 10^(-16)$ divided by $epsilon$,
and at $epsilon = 10^(-12)$ they are $2.83 times 10^(-5)$, $5.28 times 10^(-5)$ and
$8.34 times 10^(-5)$. The limit is the data, not the algorithm: the pair straddling the axis has a
gap that closes like $sqrt(epsilon)$, the absolute error in $P$ is of order
$epsilon_m \/ "gap"$, and since $norm(P)$ itself is only of order $sqrt(epsilon)$, the
relative error grows like $1 \/ epsilon$. At $epsilon = 10^(-16)$ the problem's own relative
condition number is of order $10^(16)$ and no route returns a meaningful relative answer.

Two further statements that are *not* true, worth ruling out because both are natural guesses after
seeing the pencil:

- QZ does not make an eigenvalue on the imaginary axis tractable. If an eigenvalue of $H$ lies
  exactly on the axis, the stable and unstable deflating subspaces are not separated, there is no
  stabilizing $P$, and the best closed loop available is only marginally stable; scipy raises
  rather than returning a value. The tool for spectra close to or on the axis is a
  structure-preserving Hamiltonian or symplectic method, which computes a *structured*
  decomposition and keeps its accuracy @benner1998numerically -- genuinely outside this note's
  scope.
- The pencil is not a different answer. With $R$ invertible its finite eigenvalues are those of
  $H$, and the computed $P$ agrees with the matrix route to $1.08 times 10^(-14)$ relative at
  $epsilon = 10^(-2)$. What the pencil changes is the class of data the algorithm can accept.

*The recipe, once.* Assemble the extended pencil #ref(<eq:pencil>); balance it; deflate the control
block by QR as in #ref(<eq:deflate>); run an ordered QZ with $"Re"(alpha \/ beta) < 0$; set
$P = U_(21) U_(11)^(-1)$ by substitution; check the antisymmetry defect and $"cond"(U_(11))$; if a
solution is wanted to maximal accuracy, refine it by a Newton step, which Arnold and Laub give for
the generalized problem @arnoldlaub1984generalized. Everything except the last solve is unitary,
and the one matrix that must be inverted is the one the answer itself depends on.

*What this note did not attempt.* The discrete-time equation (same deflating-subspace recipe with
the symplectic pencil, and no $A^(-1)$), descriptor systems and the cross term $S$ (both are extra
blocks in the same pencil), large sparse problems (a different class of methods), and error
estimation for $P$ (SLICOT's `SB02RD` provides it; the defect of #ref(<fig:qzform>) is not it).

#figure(
  kind: "table",
  supplement: [Table],
  caption: [The two knobs, the route that degrades in each, and the limit that survives both. The
    matrix route and the pencil route are the same algorithm up to which data reaches the QZ; the
    conditioning limit is a property of the Riccati equation, not of either route.],
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    stroke: 0.4pt,
    table.header([knob], [what degrades], [what limits accuracy]),
    [cheap state penalty $Q = epsilon I$],
    [the eigenvectors of the coalescing pair: overlap $1 - O(epsilon)$, gap $sqrt(epsilon)$],
    [the gap: relative error of order $1 \/ epsilon$ times $epsilon_m$],
    [cheap control $R = rho$],
    [$G = B R^(-1) B^T$: the rounding of $R^(-1)$ is baked into $H$ before the algorithm runs],
    [nothing, here: the pencil route holds $10^(-16)$ to $10^(-15)$ down to $rho = 3 times 10^(-10)$],
  ),
) <fig:summary>

= Sources and further reading <s7>

The classical eigenvector route to #ref(<eq:elim>), the fragility of that basis, and the ordered
Schur repair of section 2 are Laub's @laub1979schur; the same paper proves the symmetry of $P$ that
the defect check of section 5 appeals to. The extended pencil, the deflating-subspace formulation
and the QR deflation #ref(<eq:deflate>) are van Dooren's @vandooren1981generalized, which is also
the reference scipy's `solve_continuous_are` cites for that step. The generalized eigenproblem
framework for Riccati equations -- including the balancing and iterative refinement that make it a
software package, partly out of scope here -- is Arnold and Laub @arnoldlaub1984generalized. The QZ
algorithm itself, and the "no inversions" property quoted in section 5, is Moler and Stewart
@molerstewart1973algorithm. The statement used in section 3, that the extended pencil avoids
forming $R^(-1)$, together with the remark that the symplectic matrix form needs $A$ invertible
while the pencil does not, is Benner and Sima's survey of the SLICOT solvers @benner2003slicot; the
balancing step of section 5 is Benner @benner2001symplectic. The software behaviour in sections 4
and 5 -- the extended pencil with its $E$ and $S$ blocks, the deflation, `ordqz` with the
left-half-plane sort, and the `LinAlgError` raised when the pencil's eigenvalues approach the axis
-- is scipy's documentation and source @scipy_are, and the "standard eigenproblem if $G$ is given"
statement is SLICOT's `SB02OD` documentation @slicot_sb02od. The structure-preserving alternative
mentioned in section 6 is Benner, Mehrmann and Xu @benner1998numerically.

Not consulted, and offered only as pointers for going further: Golub and Van Loan's *Matrix
Computations* for the generalized Schur decomposition as textbook material, and the CAREX/DAREX
benchmark collections (Abels and Benner, SLICOT working notes) for larger test problems.

All quoted numbers come from `scripts/verify_qz_riccati.m`, which is also the check that the two
closed forms of section 1 solve the Riccati equation for their own data.