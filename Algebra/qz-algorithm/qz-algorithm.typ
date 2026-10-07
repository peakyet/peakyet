// qz-algorithm.typ -- a teach-an-engineer note, filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ.
//
// Every number quoted below is printed by one of the two scripts beside this file:
//   scripts/verify_qz.m   -- the pencil, its closed form, the two routes, the Schur form,
//                            the pair (alpha,beta), and the library calls
//   scripts/qz_sweeps.m   -- the Hessenberg-triangular reduction and one QZ sweep
// Run from the repository root with
//   octave --no-gui --quiet Algebra/qz-algorithm/scripts/verify_qz.m
//   octave --no-gui --quiet Algebra/qz-algorithm/scripts/qz_sweeps.m

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, check, navy, teal, gray

#show: note-ilm.with(
  title: [Generalized Eigenvalues and the QZ Algorithm],
  authors: "Amp",
  abstract: [
    A generalized eigenvalue is a number $lambda$ with $A x = lambda B x$ for two square
    matrices. It refuses to be an eigenvalue of any single matrix once $B$ is singular, and
    there is then no $B^(-1) A$ to form, yet the spectrum is perfectly well defined and may
    contain an infinite eigenvalue. This note is about the object that takes the place of
    $B^(-1) A$ -- the *pencil* $A - lambda B$, whose eigen-information is stored as a pair
    $(alpha, beta)$ -- and about the algorithm the libraries run to compute it: the QZ
    (generalized Schur) decomposition, which drives both matrices triangular with one unitary
    transformation on each side. A three-by-three pencil with a complex pair of eigenvalues and
    a tunable light mode gives exact eigenvalues to check every step. It shows the finite pair
    holding machine precision while the second matrix becomes singular, an infinite eigenvalue
    surviving where $B^(-1) A$ does not exist, and the pair representation holding finite data
    where the ratio overflows. The note reduces the pencil to Hessenberg-triangular form with
    real numbers, explains the implicit shift and bulge chase of the iteration, and closes with
    the library call and how to read its output. Scope: dense, general pencils. Structure
    preserving methods for Hamiltonian or symplectic pencils, and large sparse problems, are
    named but not attempted.
  ],
  bibliography: bibliography("refs.bib"),
)

// --------------------------------------------------------------------------- figure helpers
#let tintN = rgb("#e8eef7")
#let tintR = rgb("#fdeceb")
#let tintT = rgb("#e6f4f2")

// a small matrix of content with highlighted cells: hl is an array of (row, col, fill)
#let matN(r0, r1, r2, hl: ()) = {
  let one(i, j, v) = {
    let f = hl.find(x => x.at(0) == i and x.at(1) == j)
    if f == none { text(size: 8.5pt)[#v] }
    else { box(fill: f.at(2), inset: 2pt)[#text(size: 8.5pt)[#v]] }
  }
  block(stroke: 0.4pt + gray, inset: 3pt, table(
    columns: 3, align: center + horizon, row-gutter: 4pt, column-gutter: 5pt,
    one(0,0,r0.at(0)), one(0,1,r0.at(1)), one(0,2,r0.at(2)),
    one(1,0,r1.at(0)), one(1,1,r1.at(1)), one(1,2,r1.at(2)),
    one(2,0,r2.at(0)), one(2,1,r2.at(1)), one(2,2,r2.at(2)),
  ))
}

// a pattern grid for the bulge pictures: each row is an array of "x", "0", or "+"
#let pattern(rows) = {
  let glyph(g) = if g == "+" { text(size: 10pt, fill: teal, weight: "bold")[+] }
                 else if g == "0" { text(size: 10pt, fill: gray)[0] }
                 else { text(size: 10pt, fill: navy)[×] }
  block(stroke: 0.4pt + gray, inset: 3pt, table(
    columns: rows.at(0).len(), align: center + horizon, row-gutter: 4pt, column-gutter: 9pt,
    ..rows.flatten().map(glyph),
  ))
}

#let cap(s) = figure.caption(s)

// ============================== 1. THE OBJECT ===============================

= An eigenvalue can belong to two matrices at once <s1>

The eigenvalue problem every engineer meets first is $A x = lambda x$: one matrix, one
number, one direction. The object of this note replaces one matrix by two, $A x = lambda B x$,
and that single change moves the eigenvalue out of any one matrix and into the *pair*.

*Where the pair comes from.* A linear descriptor system

$ E dot(x) = A x $ <eq:descriptor>

has modes $x(t) = e^(lambda t) v$ when $A v = lambda E v$: the growth rate $lambda$ and the
shape $v$ are a generalized eigenvalue and eigenvector of the pair $(A, E)$. Eliminating
$lambda$ leaves a polynomial condition, $det(A - lambda E) = 0$, in which the two matrices
appear only together. Write the *matrix pencil*

$ A - lambda B $ <eq:pencil>

and the condition is that the pencil is singular: the eigenvalue is the $lambda$ that makes
$A - lambda B$ lose rank. When $B = I$ this is the ordinary eigenproblem; in general it is not
the eigenproblem of $B^(-1) A$ or of any other single matrix, and the rest of the note is about
respecting that.

*The example, and its exact spectrum.* To be able to check every step, take a pencil whose
answer we know. Start in a basis where it is easy: an undamped unit oscillator (a rotation
block) sitting next to a scalar mode,

$
S_0 = mat(0, -1, 0; 1, 0, 0; 0, 0, 1), quad
T_0 = mat(1, 0, 0; 0, 1, 0; 0, 0, delta).
$

The oscillator block contributes $lambda^2 + 1 = 0$, that is $lambda = plus.minus i$, and the
scalar pair gives $lambda = 1 \/ delta$. So

$ det(S_0 - lambda T_0) = (lambda^2 + 1)(1 - delta lambda), quad "spectrum" quad
  { i, -i, 1 \/ delta }, $ <eq:closedform>

and as the mode's "inertia" $delta$ goes to zero its rate $1\/delta$ runs off to infinity. The
basis is deliberately a coupling-free one; the pair the algorithm actually receives is the
same pencil written in coordinates where the light mode couples to the oscillator. A rotation
$U$ of the $(1,3)$ plane, $U = mat(c, 0, -s; 0, 1, 0; s, 0, c)$ with $c = s = 1 \/ sqrt(2)$,
produces the dense pair

$
A = U S_0 U^T = mat(0.5, -0.7071, -0.5; 0.7071, 0, 0.7071; -0.5, -0.7071, 0.5), quad
B = U T_0 U^T = mat(0.75, 0, 0.25; 0, 1, 0; 0.25, 0, 0.75). $ <eq:dense>

(Evaluated at $delta = 1\/2$; $delta$ enters only through $T_0$.) Because $U$ is orthogonal,
$det(A - lambda B) = det(S_0 - lambda T_0)$: the change of
coordinates moves the numbers inside the matrices and leaves the spectrum alone. The script
checks #ref(<eq:closedform>) at three values of $lambda$ to $3.6 times 10^(-15)$, and checks
that the computed eigenpairs satisfy $A v = lambda B v$ to a relative residual of
$2.5 times 10^(-16)$.

$delta$ is the one knob. It tunes the smallest singular value of $B$, hence how nearly singular
the pencil is; it does not move the complex pair. The figure tracks the three eigenvalues as
$delta$ shrinks.

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The spectrum of the example as $delta$ falls. The complex pair stays at $plus.minus i$;
    the third eigenvalue is $1 \/ delta$, moving right and reaching infinity at $delta = 0$. Inspect
    that only the third eigenvalue moves: tuning $delta$ changes the conditioning of $B$, not the
    oscillator.],
  box(width: 100%, height: 4.4cm)[
    #let ax0 = 1.1cm
    #let bare = 5.0cm
    #let px(x) = ax0 + x * bare / 6
    #let py(y) = 2.1cm - y * 1.15cm
    #place(top + left)[#line(start: (ax0, py(0)), end: (px(6.2), py(0)), stroke: 0.6pt + gray)]
    #place(top + left)[#line(start: (px(0), py(1.42)), end: (px(0), py(-1.42)), stroke: 0.6pt + gray)]
    #place(top + left, dx: px(0) + 2pt, dy: py(1.15))[#text(size: 8pt, fill: gray)[$i$]]
    #place(top + left, dx: px(0) + 2pt, dy: py(-1.3))[#text(size: 8pt, fill: gray)[$-i$]]
    #place(top + left, dx: px(0) - 0.35cm, dy: py(0) + 0.02cm)[#text(size: 8pt, fill: gray)[$0$]]
    #place(top + left, dx: px(2) - 0.2cm, dy: py(0) + 0.12cm)[#text(size: 8pt, fill: gray)[$2$]]
    #place(top + left, dx: px(4) - 0.2cm, dy: py(0) + 0.12cm)[#text(size: 8pt, fill: gray)[$4$]]
    // the complex pair (all delta)
    #place(top + left, dx: px(0) - 2.4pt, dy: py(1) - 2.4pt)[#circle(radius: 2.4pt, fill: navy)]
    #place(top + left, dx: px(0) - 2.4pt, dy: py(-1) - 2.4pt)[#circle(radius: 2.4pt, fill: navy)]
    // the third eigenvalue for delta = 1, 1/2, 1/4
    #for x in (1, 2, 4) {
      place(top + left, dx: px(x) - 2.4pt, dy: py(0) - 2.4pt)[#circle(radius: 2.4pt, fill: teal)]
    }
    #place(top + left, dx: px(4.35), dy: py(0.62))[#text(size: 8pt, fill: teal)[$1 \/ delta$]]
    #place(top + left, dx: px(5.25), dy: py(0) - 0.42cm)[#text(size: 9pt, fill: gray)[$-> infinity$]]
    #place(top + left, dx: px(0) + 0.12cm, dy: py(1.2))[#text(size: 8pt, fill: navy)[$plus.minus i$ (all $delta$)]]
  ],
) <fig:spectrum>

The point to carry forward: the spectrum has a piece that is finite and fixed, a piece that
runs to infinity, and no single matrix in sight that owns either.

= Inverting $B$ is the wrong first move <s2>

If $B$ happens to be invertible, the pencil hides no difficulty at all: multiply $A x =
lambda B x$ by $B^(-1)$ and the generalized problem becomes the standard one

$ (B^(-1) A) x = lambda x. $ <eq:naive>

So why not always form $B^(-1) A$ and hand it to the QR algorithm? Two reasons, and the
example makes both concrete.

*First, $B$ need not be invertible.* At $delta = 0$ the second matrix of #ref(<eq:dense>) is
$B = U "diag"(1,1,0) U^T$, of rank $2$ and determinant $0$: there is no $B^(-1) A$ to form. The
pencil, however, is still perfectly regular -- $det(A - lambda B) = (lambda^2+1)$ is not
identically zero -- and it has exactly two finite eigenvalues and one infinite one. A library
asked for the eigenvalues of the pair returns them:

#figure(
  kind: "table",
  supplement: [Table],
  caption: [The two routes at the singular endpoint. `B \ A` cannot be formed; the pair's
    eigenvalues include an infinite one. Printed by `scripts/verify_qz.m`.],
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    stroke: 0.4pt,
    table.header([quantity], [$delta = 1\/2$], [$delta = 0$]),
    [$abs(det B)$], [$0.375$], [$0$],
    [$"rank"(B)$], [$3$], [$2$],
    [the ratio route $B^(-1) A$], [defined], [*not defined*],
    [$"eig"(A, B)$], [${2, i, -i}$], [${i, -i, infinity}$],
  ),
) <fig:singular>

*Second, even when $B$ is invertible, $B^(-1) A$ is the wrong matrix to perturb.* As $delta$
shrinks the entries of $B^(-1) A$ grow like $1 \/ delta$, and the rounding error of a
backward-stable eigensolver is proportional to the norm of the matrix it was given. The
*relative* error of the finite pair therefore rises roughly like $epsilon_m \/ delta$, where
$epsilon_m = 2.2 times 10^(-16)$ is the unit roundoff, even though the finite pair is a
well-conditioned eigenvalue of the pencil. The QZ route, which never forms
$B^(-1) A$, holds it at machine precision.

#figure(
  kind: "table",
  supplement: [Table],
  caption: [Relative error of the finite pair ${i, -i}$, from `scripts/verify_qz.m`. The ratio
    route $B^(-1) A$ degrades roughly as $epsilon_m \/ delta$; the pencil route stays at machine
    precision. Inspect the last two columns: the gap is the digits that forming $B^(-1) A$ loses.],
  table(
    columns: (auto, auto, auto, auto),
    align: (right, right, right, right),
    stroke: 0.4pt,
    table.header([$delta$], [$kappa(B)$], [$"eig"(B^(-1) A)$ error], [$"eig"(A, B)$ error]),
    [$1$], [$1.0 times 10^0$], [$1.39 times 10^(-16)$], [$1.11 times 10^(-16)$],
    [$1\/2$], [$2.0 times 10^0$], [$8.95 times 10^(-16)$], [$1.94 times 10^(-16)$],
    [$10^(-2)$], [$1.0 times 10^2$], [$7.25 times 10^(-15)$], [$2.37 times 10^(-16)$],
    [$10^(-4)$], [$1.0 times 10^4$], [$2.67 times 10^(-13)$], [$2.22 times 10^(-16)$],
    [$10^(-8)$], [$1.0 times 10^8$], [$3.98 times 10^(-9)$], [$4.96 times 10^(-24)$],
    [$10^(-12)$], [$1.0 times 10^12$], [$1.08 times 10^(-6)$], [$1.36 times 10^(-20)$],
    [$10^(-16)$], [$2.6 times 10^16$], [$4.14 times 10^(-1)$], [$2.24 times 10^(-16)$],
  ),
) <fig:accuracy>

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The same table as a picture, on logarithmic axes. The teal series (the ratio route
    $B^(-1) A$) rises along the steep dashed guide $epsilon_m \/ delta$ as $delta$ falls: the digits
    lost are roughly the digits of $1\/delta$. The navy series (the pencil route) lies on the
    machine-precision floor, the horizontal dashed line at $epsilon_m$. Numbers from
    `scripts/verify_qz.m`.],
  box(width: 100%, height: 5.2cm)[
    #let x0 = 1.6cm
    #let y0 = 4.4cm
    #let ytop = 0.5cm
    #let w = 10.8cm
    // x: log10(delta) from -16 (left) to 0 (right); y: log10(err) from -17 (bottom) to 0 (top)
    #let ex(t) = x0 + (t + 16) / 16 * w
    #let ey(t) = y0 - (t + 17) / 17 * (y0 - ytop)
    #place(top + left)[#line(start: (x0, y0), end: (x0 + w, y0), stroke: 0.6pt + gray)]
    #place(top + left)[#line(start: (x0, y0), end: (x0, ytop), stroke: 0.6pt + gray)]
    #place(top + left)[#line(start: (x0, ey(-16)), end: (x0 + w, ey(-16)), stroke: (paint: gray, thickness: 0.5pt, dash: "dashed"))]
    #place(top + left)[#line(start: (ex(-15.66), ey(0)), end: (ex(0), ey(-15.66)), stroke: (paint: gray, thickness: 0.5pt, dash: "dashed"))]
    #let series = (
      (-16, -0.383, -15.65), (-12, -5.97, -19.9), (-8, -8.40, -23.3),
      (-4, -12.57, -15.65), (-2, -14.14, -15.63), (-0.301, -15.05, -15.71), (0, -15.86, -15.95),
    )
    #for (lx, lr, lq) in series {
      let lq2 = calc.max(lq, -17)
      place(top + left, dx: ex(lx) - 2.2pt, dy: ey(lr) - 2.2pt)[#circle(radius: 2.2pt, fill: teal)]
      place(top + left, dx: ex(lx) - 2.2pt, dy: ey(lq2) - 2.2pt)[#circle(radius: 2.2pt, fill: navy)]
    }
    #place(top + left, dx: x0 - 0.52cm, dy: ey(0) - 0.14cm)[#text(size: 7pt, fill: gray)[$10^0$]]
    #place(top + left, dx: x0 - 0.62cm, dy: ey(-8) - 0.14cm)[#text(size: 7pt, fill: gray)[$10^(-8)$]]
    #place(top + left, dx: ex(-16) - 0.15cm, dy: y0 + 0.06cm)[#text(size: 7pt, fill: gray)[$10^(-16)$]]
    #place(top + left, dx: ex(0) - 0.25cm, dy: y0 + 0.06cm)[#text(size: 7pt, fill: gray)[$10^0$]]
    #place(top + left, dx: x0 + w - 0.35cm, dy: y0 + 0.34cm)[#text(size: 7pt, fill: gray)[$delta$]]
    #place(top + left, dx: x0 - 0.15cm, dy: ytop - 0.05cm)[#text(size: 7pt, fill: gray)[error]]
    #place(top + left, dx: ex(-4.6), dy: ey(-13.4))[#text(size: 7.5pt, fill: navy)[pencil (QZ)]]
    #place(top + left, dx: ex(-6.2), dy: ey(-8.9))[#text(size: 7.5pt, fill: teal)[$B^(-1) A$]]
    #place(top + left, dx: ex(-14.2), dy: ey(-1.6))[#text(size: 7pt, fill: gray)[$epsilon_m \/ delta$]]
    #place(top + left, dx: ex(-13.4), dy: ey(-16) - 0.36cm)[#text(size: 7pt, fill: gray)[$epsilon_m$]]
  ],
) <fig:accuracyplot>

*What QZ does not buy.* It is worth saying plainly, because the table invites the opposite
reading: the *large* eigenvalue $1\/delta$ is genuinely ill-conditioned in the pencil, and no
algorithm computes it accurately once $delta$ is small. Measured on the same runs, its relative
error is $4.4 times 10^(-13)$ (ratio route) and $4.7 times 10^(-13)$ (pencil route) at
$delta = 10^(-4)$, and $3.3 times 10^(-5)$ against $4.7 times 10^(-5)$ at $delta = 10^(-12)$:
the two routes agree, because both are now limited by the pencil itself. QZ protects the
well-conditioned part of the spectrum; it does not manufacture conditioning that the pencil
does not have. This is the same lesson the Riccati note in this repository reaches from the
other direction (`Control/qz-riccati/qz-riccati.pdf`, section 7).

There is one more reason the libraries keep the pair rather than the ratio, and it is a
representation argument rather than an accuracy argument. LAPACK stores an eigenvalue as
$alpha \/ beta$ and warns that "the quotients $alpha\/beta$ may easily over- or underflow, and
$beta$ may even be zero" @lapack_dggev. In the decoupled coordinates the third pair is exactly
$(1, delta)$: at $delta = 10^(-309)$ the two numbers are finite, but their ratio $1\/delta$
overflows a double. The pair survives as data where the ratio does not.

#check[At $delta = 0$, what does a `B \ A` solver return, and what does an eigenvalue call on the pair return?]

Its answer, visibly below: `B \ A` has no value to compute -- a solver either refuses or warns
that the matrix is singular to machine precision -- while the pair returns the two finite
eigenvalues $plus.minus i$ and reports the third as infinite. Nothing about the *problem*
became singular; only the chosen route did.

= Two triangles, and the pair $(alpha, beta)$ <s3>

The classical Schur decomposition makes a single matrix triangular by a unitary similarity; the
generalized version makes *both* matrices triangular by a unitary transformation on each side.
There exist unitary $Q$ and $Z$ with

$ Q^* A Z = S, quad Q^* B Z = T, quad S, T "upper triangular" $ <eq:qz>

in complex arithmetic; for real $A, B$ there is a real version in which $T$ is upper triangular
and $S$ is only *quasi*-upper-triangular, with $2 times 2$ blocks where the spectrum is complex.
This is the generalized Schur, or QZ, decomposition. (Some texts write the factors the other way
round, $Q^* A Z = T$ and $Q^* B Z = S$; only the naming differs. This note calls the first
matrix's image $S$ and the second's $T$, so the pairs run $(S_(i i), T_(i i))$.)

Why triangles are enough is a one-line determinant. Since $Q$ and $Z$ are unitary,
$det(Q) det(Z^*) = c$ has unit modulus, and $S - lambda T$ is triangular, so

$ det(A - lambda B) = det(Q) det(S - lambda T) det(Z^*) = c product_i (S_(i i) - lambda T_(i i)). $ <eq:detfactor>

A nonzero constant $c$ does not move the roots, so the degree-$n$ polynomial on the left has
exactly the roots of the product: $n$ linear factors read off the diagonals of $S$ and $T$.
Writing each factor as a pair,

$ (alpha_i, beta_i) = (S_(i i), T_(i i)), quad
  lambda_i = alpha_i \/ beta_i quad (beta_i != 0), quad "and" quad lambda_i = infinity quad (beta_i = 0, alpha_i != 0), $ <eq:pair>

we have the whole spectrum, finite and infinite, without a single division that could fail.
This is the representation the rest of the note uses: an eigenvalue is not a number the
algorithm converges to, it is a *pair* on the diagonal, and only the user's final step (if any)
turns it into a ratio. The pair is also exactly what LAPACK returns, as $alpha$, $beta$.
The factorization also groups the spectrum: because $S$ and $T$ are triangular (quasi-triangular
in the real form), the leading $k$ columns of $Z$ together with the leading $k$ of $Q$ already form
a closed block carrying the first $k$ pairs and nothing else, provided $k$ does not cut across a
$2 times 2$ block. Section 6 defines what those columns span -- a *deflating subspace* on each
side, a pair of spaces rather than one -- and ordering is what chooses which pairs sit in that
leading block.

*Read the example.* For $delta = 1\/2$ the complex QZ of #ref(<eq:dense>) is essentially
diagonal; the script's run gives the diagonal pairs

$ (1, 0.5) -> 2, quad (i, 1) -> i, quad (-i, 1) -> -i, $ <eq:pairs1>

and the transformation is unitary and exact to machine precision: $norm(Q^* Q - I) = 5.3 times 10^(-16)$,
$norm(Q^* A Z - S) = 8.1 times 10^(-16)$. At $delta = 0$, where $B$ has lost its rank, the same
call returns

$ (i, 1) -> i, quad (-i, 1) -> -i, quad (-1, 0) -> infinity. $ <eq:pairs0>

The third pair is the infinite eigenvalue: $beta = 0$ is not a failure, it is the answer.

*The real form, and a trap.* Real drivers keep the arithmetic real and therefore cannot put a
complex eigenvalue on the diagonal. They return a $2 times 2$ block instead. For $delta = 1\/2$
the real QZ gives

$
S = mat(1, 0, 0; 0, 0, 1; 0, -1, 0), quad T = mat(0.5, 0, 0; 0, 1, 0; 0, 0, 1),
$

whose $2 times 2$ block $mat(0, 1; -1, 0)$ pairs with the identity block of $T$ to give
$lambda^2 + 1$, i.e.\ the pair $plus.minus i$. The trap is the obvious mistake: *do not read
the diagonal of a $2 times 2$ block as two eigenvalues.* Its diagonal is $(0, 0)$ here, and
$(0,0)$ would suggest a double eigenvalue at zero. A complex pair is the generalized
eigenvalue of the whole block, and a library reports it as a block, or as the $alpha_i$,
$beta_i$ list with the imaginary part flagged -- never as two independent diagonal ratios.

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The generalized Schur form. Left: the shape of the factorization #ref(<eq:qz>) --
    a unitary transformation from each side, both matrices triangular, and the spectrum on the
    diagonals. Right: the alternative reading the algorithm can return, a $2 times 2$ block whose
    generalized eigenvalues are a complex pair. Inspect that only the diagonal (left) or the
    block (right) carries eigenvalues; everything above is coupling and carries none.],
  grid(columns: (1fr, 1fr), gutter: 1.2em,
    [
      #align(center)[
        #table(
          columns: 3, stroke: 0.4pt, align: center + horizon,
          table.cell(colspan: 3, fill: navy.transparentize(90%))[$Q^*$ ... $A$ ... $Z$ = $S$],
          table.cell(colspan: 3, fill: navy.transparentize(90%))[$Q^*$ ... $B$ ... $Z$ = $T$],
        )
        #v(6pt)
        #table(
          columns: 3, stroke: 0.4pt, align: center + horizon,
          table.cell(fill: tintN)[$alpha_1$], [$*$], [$*$],
          [$0$], table.cell(fill: tintN)[$alpha_2$], [$*$],
          [$0$], [$0$], table.cell(fill: tintN)[$alpha_3$],
        )
        #v(3pt)
        #text(size: 8.5pt, fill: gray)[$S$: the diagonal pairs with]
        #v(2pt)
        #table(
          columns: 3, stroke: 0.4pt, align: center + horizon,
          table.cell(fill: tintT)[$beta_1$], [$*$], [$*$],
          [$0$], table.cell(fill: tintT)[$beta_2$], [$*$],
          [$0$], [$0$], table.cell(fill: tintT)[$beta_3$],
        )
        #v(3pt)
        #text(size: 8.5pt, fill: gray)[$T$: $lambda_i = alpha_i \/ beta_i$]
      ]
    ],
    [
      #align(center)[
        #table(
          columns: 2, stroke: 0.4pt, align: center + horizon,
          table.cell(fill: tintN)[$s_(11)$], table.cell(fill: tintN)[$s_(12)$],
          table.cell(fill: tintN)[$s_(21)$], table.cell(fill: tintN)[$s_(22)$],
        )
        #v(4pt)
        #table(
          columns: 2, stroke: 0.4pt, align: center + horizon,
          table.cell(fill: tintT)[$t_(11)$], table.cell(fill: tintT)[$t_(12)$],
          [$0$], table.cell(fill: tintT)[$t_(22)$],
        )
        #v(2pt)
        #text(size: 8.5pt)[a real $2 times 2$ block: solve the $2 times 2$ pencil]
        #v(4pt)
        #text(size: 8.5pt, fill: gray)[here $mat(0, 1; -1, 0)$, $I$ $->$ $plus.minus i$]
      ]
    ],
  ),
) <fig:schurform>

= Reducing the pencil without losing the triangle <s4>

The QZ decomposition #ref(<eq:qz>) is found in two movements. The first is a fixed, finite
amount of work -- a reduction to a special form -- and the second is an iteration on that form.
This section is the reduction; the next is the iteration. The reduction is where a pencil,
unlike a single matrix, needs a two-sided touch, and it is the one step worth seeing in full.

*Why reduce at all.* Iterating directly on a full pencil would cost $O(n^3)$ per step. If
instead $A$ is upper Hessenberg (zero below the first subdiagonal) and $B$ is upper triangular,
each iteration step touches only $O(n^2)$ entries, and the whole cost is dominated by the
one-time $O(n^3)$ reduction. It is the same economics as reducing a matrix to Hessenberg form
before the QR algorithm. The reduction's other job is to expose the zero structure that tells
the iteration when a piece has converged.

*Phase one: triangularize $B$.* A QR factorization of $B$ from the left,
$B = Q_0 R$, makes $R = Q_0^T B$ triangular; applying the same $Q_0^T$ to $A$ leaves the pencil
equivalent, because

$ Q_0^T (A - lambda B) = (Q_0^T A) - lambda (Q_0^T B). $ <eq:phase1>

For the example at $delta = 1\/2$ this is a two-Householder step and gives $B$ triangular and
$A$ still full:

$ A_1 = mat(-0.3162, 0.8944, 0.3162; -0.7071, 0, -0.7071; -0.6325, -0.4472, 0.6325), quad
  B_1 = mat(-0.7906, 0, -0.4743; 0, -1, 0; 0, 0, 0.6325). $

*Phase two: Hessenbergize $A$ without spoiling $B$.* Now $A_1$ still has an entry below its
band -- $A_1(3,1) = -0.6325$ -- and it must go. The way to remove it is a rotation of rows $2$
and $3$ from the left. But that same rotation acts on $B_1$, whose rows $2$ and $3$ then mix;
the zero at $B_1(3,2)$ fills in:

$ B_1 = mat(-0.7906, 0, -0.4743; 0, -1, 0; 0, 0, 0.6325)
  quad -> quad
  mat(-0.7906, 0, -0.4743; 0, 0.7454, -0.4216; 0, -0.6667, -0.4714). $

The fill is exactly one entry, at $(3,2)$, just below the diagonal. It is repaired by a
rotation of *columns* $2$ and $3$ from the right, which zeroes that entry. The repair does not
undo the left rotation: the left rotation cleared column $1$ of $A$, the right rotation touches
columns $2$ and $3$, and the two index sets are disjoint. That is the whole trick, and it is
why the reduction is *paired*:

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The paired rotations of phase two, on the running example from `scripts/qz_sweeps.m`.
    Panel 1: after the left rotation, $A$'s entry $(3,1)$ is gone (navy) and $B$ has gained the
    single entry $(3,2)$ (rose). Panel 2: the right rotation clears $B(3,2)$ and leaves $A$'s zero
    alone, because it operates on columns $2$ and $3$ while the zero is in column $1$. The result
    is Hessenberg over triangular.],
  grid(columns: (1fr, 1fr), gutter: 1.4em,
    [
      #align(center)[
        #grid(columns: (auto, auto), gutter: 0.8em,
          matN(([$-0.3162$], [$0.8944$], [$0.3162$]), ([$0.9487$], [$0.2981$], [$0.1054$]), ([$0$], [$0.3333$], [$-0.9428$]), hl: ((2,0,tintN),)),
          matN(([$-0.7906$], [$0$], [$-0.4743$]), ([$0$], [$0.7454$], [$-0.4216$]), ([$0$], [$-0.6667$], [$-0.4714$]), hl: ((2,1,tintR),)),
        )
        #v(2pt)
        #text(size: 8.5pt)[after the left rotation]
      ]
    ],
    [
      #align(center)[
        #grid(columns: (auto, auto), gutter: 0.8em,
          matN(([$-0.3162$], [$-0.2582$], [$-0.9129$]), ([$0.9487$], [$-0.0861$], [$-0.3043$]), ([$0$], [$-0.9623$], [$0.2722$])),
          matN(([$-0.7906$], [$-0.3873$], [$0.2739$]), ([$0$], [$-0.7746$], [$-0.3651$]), ([$0$], [$0$], [$0.8165$])),
        )
        #v(2pt)
        #text(size: 8.5pt)[after the paired right rotation]
      ]
    ],
  ),
) <fig:reduction>

*The general pattern, and why rotations rather than reflectors.* Phase two walks down the columns
of $A$ and, within each column, from the bottom up, using a *Givens rotation of two adjacent rows
at a time*. A Householder reflector on rows $k+1:n$ would zero the whole sub-column
$A(k+2:n, k)$ in one blow -- and would also turn those rows of $B$ into a dense block below its
diagonal, so the repair would stop being local and would spread. A rotation of rows $(i-1, i)$
that clears $A(i, k)$ does the opposite: it fills exactly one entry of $B$, the $(i, i-1)$ entry
just below its diagonal, and the paired rotation of columns $(i-1, i)$ clears it. The cleared
entry of $A$ sits in column $k <= i-2$, so the column rotation, acting on columns $i-1$ and $i$,
never refills it. Every left rotation has exactly one right partner, and the whole reduction is a
product of such rotations -- the form the libraries implement @lapack_dgghrd.

The script verifies the example end to end: after the two phases, $A$ is Hessenberg and $B$
triangular to $4.1 times 10^(-17)$, the accumulated $Q, Z$ are unitary to $9.2 times 10^(-16)$,
and $Q^T A Z$, $Q^T B Z$ reproduce the reduced pair to $6.0 times 10^(-16)$ and
$7.8 times 10^(-16)$. The reduction has cost $O(n^3)$ and has changed no eigenvalue.

= The iteration: a shift, a bulge, and a chase <s5>

The iteration is the part that actually drives the pencil to triangular form. It is the QR
algorithm's step, transplanted to the pencil and done without ever forming a quotient.

*The QR step it generalizes.* For a single Hessenberg matrix $H$, one QR step chooses a scalar
shift $mu$ -- usually an eigenvalue of the trailing $2 times 2$ block -- forms the first column
of $H - mu I$, applies a Householder transformation that sends it to a multiple of $e_1$, and
then chases the *bulge* the Householder left behind down the band with further rotations until
the Hessenberg shape is restored. Convergence shows up as a vanishing subdiagonal entry, which
deflates the problem into two smaller ones. The QZ step is this step applied to the pencil, in
the sense that it mirrors one QR step on $A B^(-1)$ -- but $A B^(-1)$ is never formed, precisely
so that the argument of section 2 does not arise.

*The step, and where the bulge comes from.* Take the pencil in Hessenberg-triangular form with
$T$ invertible. A real driver's step is the one a double-shift QR step would take on the single
matrix $M = H T^(-1)$ -- which is upper Hessenberg, and which the algorithm never forms. The two
shifts $sigma_1, sigma_2$ are the eigenvalues of the trailing $2 times 2$ *pencil*, which are
also the eigenvalues of $M$'s trailing block. The step begins with the first column of
$(M - sigma_1 I)(M - sigma_2 I)$; since $M - sigma I = (H - sigma T) T^(-1)$, that column is
$(H - sigma_1 T) T^(-1) (H - sigma_2 T) T^(-1) e_1$. It has only three nonzero entries, because
$M$ is Hessenberg and $(M - sigma_2 I) e_1$ is supported on two coordinates, and it can be
assembled from a handful of leading entries of $H$ and $T$ without ever forming $T^(-1)$; LAPACK
builds exactly this $3$-vector @lapack_dhgeqz. A single $3 times 3$ Householder sends it to a
multiple of $e_1$. Applying that Householder from the left is exactly the situation at the end of
section 4 -- it puts entries below the band -- except that now the offending entries are produced
by the *shift*, in a patch three wide. The same paired right rotations repair $T$, and the
leftover in $H$ is a *bulge* that is chased one step down the band by the same left/right couple,
until it falls off the bottom.

*Why two sides are legitimate.* The single-matrix QR step is a similarity, $Q^T H Q$; the QZ step
is an *equivalence*, $Q^T (A - lambda B) Z$, with generally different $Q$ and $Z$. That does not
break the implicit Q theorem; it is the theorem applied to the pencil. With $M = H T^(-1)$
($T$ nonsingular), $Q^T H Z = S$ and $Q^T T Z = P$ together give

$ Q^T M Q = S P^(-1), $ <eq:implicitq>

an ordinary *similarity* of the single matrix $M$ into upper Hessenberg form. So $Q$ is the
orthogonal factor of a Hessenberg reduction of $M$ and is fixed, up to column signs, by its first
column $Q e_1$ -- the usual implicit Q theorem -- while $Z$ is then forced by the requirement
that $Q^T T Z$ be triangular, that is, $Z$ is the orthogonal factor of an RQ factorization of
$Q^T T$. The right transformations are the price of never forming $T^(-1)$; they add no free
parameter. Two consequences of the same identity: the shift has to reach the pencil through
$T^(-1)$ (so it is the first column above, not $(H - sigma_1 T)(H - sigma_2 T) e_1$, which points
elsewhere), and the argument assumes $T$ nonsingular -- a zero diagonal of $T$, an infinite
eigenvalue, is deflated before it applies.

#figure(
  kind: "figure",
  supplement: [Figure],
  caption: [The chase, schematically, on an $n times 6$ pencil (the pattern a real double-shift
    step produces). $times$ is a nonzero, $0$ a structural zero, and $+$ an entry that violates
    Hessenberg-triangular form -- the bulge. The left Householder spoils both matrices; the paired
    right rotations restore $T$ and push the bulge into $H$; the left rotations restore $H$ and
    push what is left into $T$; repeating walks the bulge down and off the bottom. This is the
    paired rotation of section 4 again, now applied to a bulge rather than to a fixed entry.],
  grid(columns: (auto, 1fr, 1fr, 1fr, 1fr), gutter: 0.6em, row-gutter: 0.6em, align: horizon,
    [], [#align(center)[#text(size: 8pt)[before]]], [#align(center)[#text(size: 8pt)[left Householder]]],
    [#align(center)[#text(size: 8pt)[right rotations]]], [#align(center)[#text(size: 8pt)[chase one step]]],
    [#align(right + horizon)[#text(size: 9pt)[$H$]]],
    align(center)[#pattern((("x","x","x","x","x","x"), ("x","x","x","x","x","x"), ("0","x","x","x","x","x"), ("0","0","x","x","x","x"), ("0","0","0","x","x","x"), ("0","0","0","0","x","x")))],
    align(center)[#pattern((("x","x","x","x","x","x"), ("x","x","x","x","x","x"), ("+","x","x","x","x","x"), ("0","0","x","x","x","x"), ("0","0","0","x","x","x"), ("0","0","0","0","x","x")))],
    align(center)[#pattern((("x","x","x","x","x","x"), ("x","x","x","x","x","x"), ("+","x","x","x","x","x"), ("+","+","x","x","x","x"), ("0","0","0","x","x","x"), ("0","0","0","0","x","x")))],
    align(center)[#pattern((("x","x","x","x","x","x"), ("x","x","x","x","x","x"), ("0","x","x","x","x","x"), ("0","0","x","x","x","x"), ("0","0","0","x","x","x"), ("0","0","0","0","x","x")))],
    [#align(right + horizon)[#text(size: 9pt)[$T$]]],
    align(center)[#pattern((("x","x","x","x","x","x"), ("0","x","x","x","x","x"), ("0","0","x","x","x","x"), ("0","0","0","x","x","x"), ("0","0","0","0","x","x"), ("0","0","0","0","0","x")))],
    align(center)[#pattern((("x","x","x","x","x","x"), ("+","x","x","x","x","x"), ("+","+","x","x","x","x"), ("0","0","0","x","x","x"), ("0","0","0","0","x","x"), ("0","0","0","0","0","x")))],
    align(center)[#pattern((("x","x","x","x","x","x"), ("0","x","x","x","x","x"), ("0","0","x","x","x","x"), ("0","0","0","x","x","x"), ("0","0","0","0","x","x"), ("0","0","0","0","0","x")))],
    align(center)[#pattern((("x","x","x","x","x","x"), ("0","x","x","x","x","x"), ("0","+","x","x","x","x"), ("0","+","+","x","x","x"), ("0","0","0","0","x","x"), ("0","0","0","0","0","x")))],
  ),
) <fig:bulge>

#figure(
  kind: "table",
  supplement: [Table],
  caption: [One sweep on the reduced $delta = 1\/2$ pair, from `scripts/qz_sweeps.m`. The shift
    $mu = 0.5 + 0.5 i$ is the trailing pencil's eigenvalue nearest $H_(3 3)\/T_(3 3)$; the numbers
    are the magnitudes of the moving entry at each stage. This is the complex single-shift form of
    the step; a real driver takes both trailing eigenvalues at once, which is why its bulge is
    three wide and it can stay in real arithmetic.],
  table(
    columns: (auto, auto),
    align: (left, right),
    stroke: 0.4pt,
    table.header([stage of one sweep], [bulge magnitude]),
    [shift from the trailing $2 times 2$ pencil], [$mu = 0.5 + 0.5 i$],
    [left Householder: $T$ gains $(2,1)$], [$0.7276$],
    [right rotation: $H$ gains $(3,1)$], [$0.8333$],
    [left rotation chases it: $T$ gains $(3,2)$], [$0.6623$],
    [paired right rotation: bulge gone], [$0$],
  ),
) <fig:sweep>

*Convergence and deflation.* After each sweep the algorithm inspects the subdiagonal coupling:
when $|H(i+1, i)|$ is negligible beside its neighbouring diagonal entries of $H$ *and* $T$, that
entry is set to zero and the pencil splits into an upper and a lower block, each solved on its
own. This is deflation, the same idea as in the QR algorithm. A zero on the diagonal of $T$ is
handled separately: it means an infinite eigenvalue, and if it is not at the bottom it is chased
out of the way (a diagonal version of the same rotation pattern) so that the iteration can
continue on the finite part. Running the script's single-shift sweep to convergence on the reduced $delta=1\/2$ pair takes
*seven* sweeps and returns the spectrum to full precision: the computed eigenvalues are
${2, -i, +i}$, and the pair is triangular to $2.1 times 10^(-25)$ below $A$'s band and
$7.4 times 10^(-18)$ below the diagonal of $B$.

The implementation in `scripts/qz_sweeps.m` covers the reduction of section 4 in full and one
sweep of the form above; the schematic #ref(<fig:bulge>) shows the real double-shift variant
that library drivers use, whose inner rotations are the same pair. The note is explicit about
which is which: the numbers are from executed code, the wide-bulge pattern is the documented
library variant @golubvanloan, and the implicit double shift itself is left to the library.

= Using it <s6>

The recipe, and then where to find it. Everything below is a dense $O(n^3)$ computation.

+ *Assemble the pencil.* Whatever produces the problem -- a descriptor system, a quadratic
  eigenvalue problem, a Riccati equation -- hand the algorithm two matrices $A$ and $B$, not
  their product and not an inverse.
+ *Balance* (the driver does this for you). Balancing improves the accuracy of badly scaled
  pencils by permutations and two-sided diagonal scaling before the iteration @ward1981balancing.
+ *Reduce* to Hessenberg-triangular form, then *iterate* with the implicit shift and chase,
  deflating as subdiagonals vanish, exactly as sections 4 and 5 describe.
+ *Read the pairs* $(alpha_i, beta_i)$ from the diagonals. The finite eigenvalues are
  $alpha_i \/ beta_i$; $beta_i = 0$ is an infinite eigenvalue. In the real form, a complex
  conjugate pair is a $2 times 2$ block, not two diagonals.
+ *Order*, if you want a particular subset first. `ordqz`/`dgges` take a selection rule and move
  the chosen pairs to the leading block by further unitary transformations -- the step the
  Riccati note uses to put the stable eigenvalues first. The move is a sequence of *adjacent-block
  swaps*: swapping two real $1 times 1$ blocks is one Givens rotation, while swapping a block that
  holds a complex pair requires solving the small generalized Sylvester equation
  $S_(11) R - L S_(22) = gamma S_(12)$, $T_(11) R - L T_(22) = gamma T_(12)$ and building two
  orthogonal factors from its solution, all applied to both sides so the Schur form is restored
  with the blocks exchanged @kagstrom1993reordering. Bubbling the chosen pairs to the front one
  swap at a time leaves the leading columns of the accumulated $Q$ and $Z$ spanning the
  corresponding left and right deflating subspaces; a swap that would be too ill-conditioned is
  reported rather than performed silently.

*What a deflating subspace is.* The ordering step named an object the drivers compute but the note
has not yet defined. For a pencil, the analogue of an invariant subspace is a *pair* of subspaces of
equal dimension, one on each side @monov2004reducing:

$ dim X = dim Y = k, quad A X subset.eq Y, quad B X subset.eq Y, $ <eq:deflating>

where $A X$ means $\{A x : x in X\}$. Equivalently, with basis matrices $X_1$ of $X$ and $Y_1$ of
$Y$, there are $k times k$ matrices with $A X_1 = Y_1 A_(11)$ and $B X_1 = Y_1 B_(11)$, so the
pencil restricted to the pair is the small regular pencil $(A_(11), B_(11))$ and its eigenvalues are
a subset of the spectrum of $(A, B)$ @oara1997deflating. The pair is called *deflating*, and its two
members are the *right* subspace $X$ and the *left* one $Y$ -- the names subsection 6.1 uses for
$R$ and $L$.

Two readings make the definition concrete. Put $B = I$: then $B X subset.eq Y$ is free, $Y$ can be
taken to be $X$, and the condition collapses to $A X subset.eq X$, an ordinary *invariant subspace*
-- one matrix is the special case. And a single direction is never enough on its own: a generalized
eigenvector $w$, one with $A w = lambda B w$, gives the pair
$(X, Y) = ("span"(w), "span"(A w))$, whereas an eigenvector of $A$ alone satisfies $A X subset.eq X$ but
in general sends $B X$ somewhere else entirely. What the pair buys is the deflation itself: given
$X$ and $Y$, orthonormal bases of them can be completed to unitary $Q$ and $Z$ whose leading $k$
columns hold $(A_(11), B_(11))$ and whose trailing columns hold the rest, because then
$Q^* A Z$ and $Q^* B Z$ are block upper triangular. That is the certificate the algorithm tests:
$S_(k+1, k) = 0$ means the leading columns already have the property, the pencil splits, and each
half is solved on its own, which is the deflation of section 5
@kagstrom2006multishift @stewart1990perturbation.

*Measured.* On the example's pair ${i, -i}$ at $delta = 1\/2$ the script reproduces all of it:
$dim(A X + B X) = 2 = dim X$, the induced $2 times 2$ pencil with eigenvalues ${i, -i}$, then
orthonormalization with $norm(Q^* Q - I) = 5.0 times 10^(-16)$ and lower-left blocks
$3.1 times 10^(-16)$ and $2.6 times 10^(-16)$ in $Q^* A Z$ and $Q^* B Z$, the leading block holding
${i, -i}$ and the trailing one holding $2$. The same script tests the definition on a tiny pencil
that has nothing hidden in it, $A = mat(1, 1; 0, 2)$, $B = mat(1, 0; 1, 1)$, with eigenvalues
$1 plus.minus i$: an eigenvector of $A$ gives $dim(A X + B X) = 2 != 1$ and is therefore *not* a
deflating direction, while a generalized eigenvector gives $1$, and $"span"(A w)$ sits
$24.1 degree$ away from $"span"(w)$ -- the two members of the pair are genuinely different subspaces.

One trap hides in the running example: there $B$ acts as the identity on the ${i, -i}$ block
($norm(B X_1 - X_1) = 2.2 times 10^(-16)$), so that particular pair has $X = Y$ and a one-matrix
intuition would appear to survive. The tiny pencil is the honest test of the two-sided definition.

== Moving a block to the front: the swap in detail

The drivers move a selected pair by *adjacent-block swaps* and bubble it forward. Write the two
adjacent diagonal blocks as $(S_(11), T_(11))$ of size $n_1$ and $(S_(22), T_(22))$ of size
$n_2$, each $1$ or $2$, with coupling $S_(12), T_(12)$. A swap is a pair of orthogonal matrices
$Q_1, Z_1$ with

$
Q_1^T mat(S_(11), S_(12); 0, S_(22)) Z_1 = mat(tilde(S)_(11), tilde(S)_(12); 0, tilde(S)_(22)), quad
Q_1^T mat(T_(11), T_(12); 0, T_(22)) Z_1 = mat(tilde(T)_(11), tilde(T)_(12); 0, tilde(T)_(22)),
$ <eq:swap>

where the leading block carries the eigenvalues the trailing block had. Only this small block is
touched directly; the same $Q_1, Z_1$ are then applied to the coupling rows and columns of the
rest of the pencil.

*Two real $1 times 1$ blocks.* Form the two scalars $F = s_(22) t_(11) - t_(22) s_(11)$ and
$G = s_(22) t_(12) - t_(22) s_(12)$, take the Givens rotation $(c, s)$ that sends $(F, G)$ to a
multiple of $e_1$, and apply it from the right to columns $1$ and $2$. A second rotation --
built from $(s_(11), s_(21))$ if $abs(s_(22)) >= abs(t_(22))$ and from $(t_(11), t_(21))$
otherwise -- is applied from the left to restore triangularity. When $T = I$ this is exactly the
standard Schur reordering of a single matrix.

*The Sylvester equation, briefly.* An equation $A X - X B = C$ with known $A, B, C$ and unknown
$X$ is a *Sylvester equation*: linear in $X$, with the scalar prototype $a x - x b = c$, whose
solution is $x = c \/ (a - b)$. Vectorizing turns it into a linear system of size $n^2$, and the
operator $X |-> A X - X B$ has eigenvalues $lambda_i(A) - lambda_j(B)$; so it has one unique
solution exactly when $A$ and $B$ share no eigenvalue, and the smallest such difference measures
how ill-conditioned that solution is. In the swap, $X$ is what turns coupling into a change of
basis: for the $2 times 2$ case above, $x = c \/ (a - b)$ is exactly the quantity the rotation
angle is built from. The pencil doubles the bookkeeping: it is transformed on both sides, so
there is a right deflating subspace (parametrized by $R$) and a left one (parametrized by $L$),
and $S v = lambda T v$ couples the two matrices into the two equations below. The blocks can be
exchanged only when their spectra are disjoint, and the *size* of the solution is precisely the
swap's conditioning -- the quantity the threshold test below checks.

*Why the equation has that form.* The swap wants a basis whose first directions are the invariant
directions of the block that is moving up, and writing such a direction as a *graph* over the block
structure is what produces the equation. In the scalar case $M = mat(a, c; 0, b)$, let the direction
belonging to the eigenvalue $b$ be $v = mat(-x; 1)$, with $x$ unknown. Imposing $M v = b v$ gives
$-a x + c = -b x$, that is

$ a x - x b = c. $ <eq:sylvesterscalar>

The Sylvester equation *is* the eigenvector equation. In the block case $M = mat(A, C; 0, B)$ the
graph is $mat(-X; I)$, whose bottom block forces the invariant action to be $B$:

$ mat(A, C; 0, B) mat(-X; I) = mat(-X; I) B, quad "that is" quad -A X + C = -X B, $ <eq:sylvesterblock>

which is $A X - X B = C$. The two terms are matched because the graph is acted on from the left by
$A$ and from the right by its own block $B$; a *similarity* -- the same basis on both sides --
would instead give the commutator $A X - X A$, the Lyapunov equation of control theory. For a
pencil the direction satisfies $S v = lambda T v$ for *two* matrices, so the single invariance
condition becomes one per matrix, exactly the two equations above; and the two-sided transformation
is why there is a right unknown $R$ and a left one $L$. The script checks both readings on tiny
examples: $M v = b v$ exactly for $x = -0.3333$, and $M mat(-X; I) = mat(-X; I) B$ to
$2.2 times 10^(-16)$.

*From the solution to the rotation.* The solution parametrizes the invariant direction, and the
swap is that direction made into a basis. In the scalar case the direction is $v = mat(-x; 1)$, and
the orthogonal matrix whose first column is $v \/ norm(v)$ is a rotation,

$ G = 1 \/ sqrt(1 + x^2) mat(-x, -1; 1, -x). $ <eq:rotate2>

Because $M v = b v$, multiplying the first unit vector gives $G^T M G e_1 = b e_1$; hence the first
column of $G^T M G$ is $(b, 0)$ and the diagonal comes out swapped:

$ G^T M G = mat(b, *; 0, a). $ <eq:rotate2b>

For $a = 1, c = 1, b = 4$ this gives $x = -0.3333$, $norm(G^T G - I) = 1.1 times 10^(-16)$, and a
diagonal of $(4, 1)$. The block case for a single matrix is the same move: the invariant subspace is
the graph $mat(-X; I)$, orthonormalizing it supplies the leading columns of $G$, and $G^T M G$ swaps
the blocks -- the script finds leading eigenvalues ${4, 5}$ (the old $B$), trailing ${1, 3}$ (the old
$A$), and a lower-left block of $6.2 times 10^(-16)$.

A pencil cannot do this with one rotation. Its generalized eigenvalues are invariant under an
*equivalence* $Q_1^T (S, T) Z_1$ with $Q_1 != Z_1$, and a single similarity would in general neither
keep $T$ triangular nor exchange the blocks -- which is exactly why the algorithm solves for two
unknowns $R$ and $L$ rather than one $X$. The two factors are built one per side, $Q_1$ from the
left graph of $L$ and $Z_1$ from the right graph of $R$, and a third transformation re-triangularizes
$T$ after they are applied.

*When a $2 times 2$ block is involved.* The swap is then read off the two deflating subspaces,
which is where the *generalized* Sylvester equation enters. In order:

+ Solve $S_(11) R - L S_(22) = gamma S_(12)$ and $T_(11) R - L T_(22) = gamma T_(12)$ for $R, L$;
  the scaling $gamma$ keeps the solution in range.
+ Build $Q_1$ from a QR factorization of $mat(-L; gamma I_(n_2))$, and $Z_1$ from an RQ
  factorization of $[gamma I_(n_1), R]$.
+ Apply $Q_1^T (S, T) Z_1$. The coupling is now in the wrong place and $T$ is no longer
  triangular; restore it two ways -- an RQ factorization of the $T$-part and a QR factorization
  of the $T$-part -- and keep whichever leaves the smaller residual $(2,1)$ block of $S$.
+ Accept the swap only if that residual is below a threshold of order
  $20 epsilon_m norm((S_(11), T_(11), S_(22), T_(22)))$; otherwise the two pairs are too close to
  separate and the driver reports the pencil as ill-conditioned rather than return a bad ordering.

A block moved $k$ places costs $k$ such swaps, each a fixed-size solve plus $O(n)$ work on the
rest of the pencil @kagstrom1993reordering.

*In code.* The pencil of #ref(<eq:dense>) is one call from an eigenvalue list, and the same
call works at $delta = 0$ where $B^(-1) A$ does not exist:

```octave
[V, D] = eig(A, B);                           % eigenvalues and eigenvectors
[S, T, Q, Z] = qz(A, B);                      % the generalized Schur form
[Ar, Br, Qr, Zr] = ordqz(S, T, Q, Z, 'lhp');  % reorder: stable pairs first
```

(The Octave/MATLAB `ordqz` shown takes the factors from `qz`; MATLAB's form is
`ordqz(A, B, keyword)`. In Python, `scipy.linalg.eig(A, B)`, `scipy.linalg.qz(A, B)` and
`scipy.linalg.ordqz` expose the same three calls.)

The underlying drivers are LAPACK's `dggev` (eigenvalues, optionally vectors) and `dgges`
(Schur form, with ordering). Measured on the example at $delta = 1\/2$, `eig(A, B)` returns
${2, i, -i}$ with eigenpair residuals of $7.6 times 10^(-16)$; at $delta = 0$ it returns
${i, -i, -infinity}$. The second input is doing real work in both calls; that is the whole
point.

*What QZ is not.* It is not a way to get eigenvectors for free: the generalized eigenvectors
are the columns of the $Z$ factor (and the left ones from $Q$), so a driver asked only for
eigenvalues does not pay for them. It is not a large-sparse method; its cost is dense $O(n^3)$,
and a sparse generalized problem needs a Krylov or shift-invert method that never forms $S$ or
$T$. It is not structure-preserving: for a Hamiltonian or symplectic pencil the QZ form is a
valid but unphysical decomposition, and the structured methods that keep the pairing of the
spectrum are a different subject. The Riccati note here applies QZ where the structure happens
to help (`Control/qz-riccati/qz-riccati.pdf`); the symplectic and doubling notes
(`Control/symplectic-matrix/symplectic-matrix.pdf`, `Control/sda-riccati/sda-riccati.pdf`)
take the structured road. And it is not an accuracy guarantee: section 2 measured the limit
that the pencil's own conditioning sets, which no algorithm removes.

= Sources and further reading <s7>

The QZ algorithm, its generalization from QR, and the property this note leans on in section 2
-- "particular attention is paid to the degeneracies which result when $B$ is singular. No
inversions of $B$ or its submatrices are used" -- are Moler and Stewart's @molerstewart1973algorithm.
The generalized Schur decomposition, the Hessenberg-triangular reduction, the implicit
double-shift step and its bulge chase, and the "QZ step is a QR step on $A B^(-1)$" reading are
Golub and Van Loan, *Matrix Computations*, 4th edition, section 7.7 @golubvanloan; the lecture
slides of Arbenz state the same decomposition and reduction as the note does
@arbenz_ewp. The real double-shift pattern drawn in #ref(<fig:bulge>) follows those two
sources. The pair output $(alpha_i, beta_i)$, the warning that the quotient may over- or
underflow while $alpha$ and $beta$ stay in range, and the $beta = 0$ convention are LAPACK's
`dggev` documentation @lapack_dggev; the names `qz`, `ordqz`, `dgges` are the MATLAB/Octave
and LAPACK interface names for the same three computations. The Givens rotations of the
Hessenberg-triangular reduction, and the real driver's double-shift step and its local
construction of the shift vector of #ref(<eq:implicitq>), are LAPACK's `DGGHRD` and `DHGEQZ`,
which this note read @lapack_dgghrd @lapack_dhgeqz. The reordering of section 6 -- adjacent-block
swaps and the generalized Sylvester equation -- is Kågström's direct method
@kagstrom1993reordering. Balancing before the QZ iteration is Ward @ward1981balancing.

The deflating subspace of section 6 is quoted from Monov and Tsatsomeros, who define it as the
subspace pair $A L subset.eq M$, $B L subset.eq M$ together with the block-triangular reduction it
produces @monov2004reducing, and from Oară and Van Dooren, whose basis-matrix form carries an
induced *regular* pencil and reduces to the ordinary invariant-subspace definition when one of the
two matrices is the identity @oara1997deflating. The vanishing-subdiagonal certificate
$S_(k+1, k) = 0$ is stated in that form by Kågström and Kressner, who attribute it to Stewart and
Sun's *Matrix Perturbation Theory*, chapter VI @kagstrom2006multishift @stewart1990perturbation --
the textbook itself was not consulted here.

Not consulted, and offered only as pointers for going further: Stewart's *Matrix Algorithms,
Volume II* (chapter 4 on the generalized eigenproblem) and the CAREX/DAREX collections of
Riccati benchmarks. No generated data was needed; every number in this note is printed by the
two Octave scripts beside it.
