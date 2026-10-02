// qz-riccati.typ -- a teach-an-engineer question map, filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ. One deep question per
// teaching section; the expected insights live in summary.md, never here.
//
// Every number on the page is exact rational arithmetic reproduced by
// scripts/verify_qz_are.py, run from the repository root.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

#show: note-ilm.with(
  title: [The Pencil Behind the Riccati Equation],
  authors: "Amp",
  abstract: [
    Solving an algebraic Riccati equation by QZ trades one quadratic problem for a linear
    problem of twice the size, and then chooses a half of it. This note asks seven questions
    about that trade, with the continuous and discrete equations side by side throughout:
    which of an equation's solutions is the gain, where the linear object is hiding, why a
    pencil is asked for instead of a matrix, what a generalized Schur run returns before any
    choice is made, what its sweeps preserve, what the stages cost, and where the guarantee
    stops. Everything is posed against one two-state plant whose solutions, multipliers and
    closed loops are printed exactly, so an answer can be checked against arithmetic rather
    than against this page.
  ],
)

// ============================ 1. TWO SOLUTIONS ============================

= Two exact solutions, one gain <s1>

#question[Each equation below has two symmetric solutions and both are printed exactly. Name
  the mechanism that picks one of the two as the LQR gain, and say what the other one does to
  the closed loop. Second half: these equations are quadratic in $P$, while the cost they come
  from is convex in $u$. Explain why those two facts are not in tension -- and what a reader
  who expects a quadratic matrix equation to have one answer has to give up.]

#figure(
  kind: table,
  caption: [The two exact solutions of each equation, the gain each one produces, and the
    multipliers of the loop it closes. Read across a row: one plant, one weighting, one
    solution, one closed loop.],
  text(size: 10pt)[
    #table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      stroke: (x: none, y: 0.5pt + gray.lighten(45%)),
      inset: (x: 7pt, y: 3pt),
      table.header([*Equation*], [*Solution $P$*], [*Gain $K$*], [*Closed-loop multipliers*]),
      [continuous], [$I$], [$(3, 0)$], [$(-7, -1/2)$],
      [continuous], [$"diag"(-5/9, 1)$], [$(-5/3, 0)$], [$(7, -1/2)$],
      [discrete], [$I$], [$(3/5, 0)$], [$(1/5, -1/2)$],
      [discrete], [$"diag"(-1/15, 1)$], [$(-1, 0)$], [$(5, -1/2)$],
    )
  ],
)

*The plant.* Two states, one input, written in an orthonormal eigenbasis of $A$:

$ A = mat(2, 0; 0, -1/2), quad B = mat(3; 0), quad R = 1, quad G = B R^-1 B' = mat(9, 0; 0, 0) $ <eq:plant>

so the unstable mode ($2$) is the actuated one and the stable mode ($-1/2$) is not. In the
coordinates where $A$ is not diagonal the same plant reads $A = 1/10 mat(11, -12; -12, 4)$ with
$B = 1/5 mat(12; -9)$, and the two weightings used below become
$Q_c = 1/25 mat(89, -48; -48, 61)$ and $Q_d = 1/500 mat(327, 36; 36, 348)$.

*The two equations,* in the symmetric unknown $P$, with the gain and closed loop each produces:

$ A' P + P A - P G P + Q_c = 0, quad K_c = B' P, quad A_"cl" = A - G P $ <eq:care>
$ P = A' P (I + G P)^-1 A + Q_d, quad K_d = (R + B' P B)^-1 B' P A, quad A_"cl" = A - B K_d $ <eq:dare>

*The facts.* Primes are transposes. A closed loop is *stable* when its multipliers lie in the
open left half-plane (continuous) or the open unit disk (discrete). All numbers are exact and
reproduced by #raw("scripts/verify_qz_are.py").

- Continuous, $Q_c = mat(5, 0; 0, 1)$: #ref(<eq:care>) holds at $P = I$ with gain $K_c = (3, 0)$
  and closed-loop multipliers $(-7, -1/2)$; and at $P = mat(-5/9, 0; 0, 1)$ with closed-loop
  multipliers $(7, -1/2)$.
- Discrete, $Q_d = mat(3/5, 0; 0, 3/4)$: #ref(<eq:dare>) holds at $P = I$ with gain
  $K_d = (3/5, 0)$ and closed-loop multipliers $(1/5, -1/2)$; and at $P = mat(-1/15, 0; 0, 1)$
  with closed-loop multipliers $(5, -1/2)$.
- In each domain the two solutions differ in one entry, and one of them is positive definite.

// ======================== 2. THE LINEAR OBJECT ============================

= Where is the linear object hiding? <s2>

#question[State the property of $H$ that makes the graph of $P$ an invariant subspace exactly
  when $P$ satisfies #ref(<eq:care>), and the matching property of the pair $(L, N)$ for
  #ref(<eq:dare>). Then say why #ref(<eq:ctchar>) carries only even powers of $z$ while
  #ref(<eq:dtchar>) reads the same backwards, and what those two symmetries leave a solver free
  to choose -- and not free to choose -- out of the four multipliers.]

#figure(
  caption: [The four multipliers of each pencil, joined in pairs. Navy joins the two partners
    belonging to the actuated mode, teal the two partners belonging to the unactuated one; each
    arc connects the two numbers it relates. Inspect what operation takes one partner to the
    other.],
  box(width: 100%, height: 6.0cm)[
    #let x0 = 0.7cm
    #let W = 14.2cm
    #let cl = -8.0
    #let ch = 8.0
    #let xc(v) = x0 + (v - cl) / (ch - cl) * W
    #let dl = -2.5
    #let dh = 5.5
    #let xd(v) = x0 + (v - dl) / (dh - dl) * W
    #let yc = 2.2cm
    #let yd = 5.0cm
    #let arc(xa, xb, y, h, c) = place(top + left)[
      #curve(
        stroke: 1.1pt + c,
        curve.move((xa, y)),
        curve.cubic((xa + (xb - xa) * 0.25, y - h), (xb - (xb - xa) * 0.25, y - h), (xb, y)),
      )
    ]
    #let dot(x, y, c) = place(top + left, dx: x - 2.75pt, dy: y - 2.75pt)[
      #rect(width: 5.5pt, height: 5.5pt, radius: 50%, fill: c)
    ]
    // --- continuous panel
    #place(top + left, dx: x0, dy: yc - 1.85cm)[#text(size: 9.5pt)[continuous: multipliers of $H$]]
    #place(top + left)[#line(start: (x0, yc), end: (x0 + W, yc), stroke: 0.8pt + gray)]
    #arc(xc(-7), xc(7), yc, 1.35cm, navy)
    #arc(xc(-0.5), xc(0.5), yc, 0.72cm, teal)
    #dot(xc(-7), yc, navy)
    #dot(xc(7), yc, navy)
    #dot(xc(-0.5), yc, teal)
    #dot(xc(0.5), yc, teal)
    #place(top + left, dx: xc(-7) - 0.32cm, dy: yc + 0.12cm)[$-7$]
    #place(top + left, dx: xc(7) - 0.15cm, dy: yc + 0.12cm)[$+7$]
    #place(top + left, dx: xc(-0.5) - 0.62cm, dy: yc + 0.12cm)[$-1/2$]
    #place(top + left, dx: xc(0.5) - 0.35cm, dy: yc + 0.58cm)[$+1/2$]
    // --- discrete panel
    #place(top + left, dx: x0, dy: yd - 1.85cm)[#text(size: 9.5pt)[discrete: multipliers of $(L, N)$]]
    #place(top + left)[#line(start: (x0, yd), end: (x0 + W, yd), stroke: 0.8pt + gray)]
    #arc(xd(0.2), xd(5), yd, 1.35cm, navy)
    #arc(xd(-2), xd(-0.5), yd, 0.72cm, teal)
    #dot(xd(-2), yd, teal)
    #dot(xd(-0.5), yd, teal)
    #dot(xd(0.2), yd, navy)
    #dot(xd(5), yd, navy)
    #place(top + left, dx: xd(-2) - 0.32cm, dy: yd + 0.12cm)[$-2$]
    #place(top + left, dx: xd(-0.5) - 0.62cm, dy: yd + 0.12cm)[$-1/2$]
    #place(top + left, dx: xd(0.2) - 0.35cm, dy: yd + 0.58cm)[$1/5$]
    #place(top + left, dx: xd(5) - 0.15cm, dy: yd + 0.12cm)[$5$]
  ],
)

*The linear objects.* With $A$, $B$, $R$ of #ref(<eq:plant>) and the weightings of section 1:

$ H = mat(A, -G; -Q_c, -A'), quad L = mat(A, 0; -Q_d, I), quad N = mat(I, G; 0, A') $ <eq:pencils>

The *graph* of $P$ is the set of pairs $(x, P x)$, that is, the column span of $V = mat(I; P)$.
A subspace $W$ is *invariant* for $H$ when $H W subset.eq W$, and *deflating* for the pair
$(L, N)$ when $L W subset.eq N W$; for one multiplier $mu$, deflating means $L v = mu N v$ on
that subspace.

*The two characteristic polynomials,* both exact. The continuous one is read off $H$ itself; the
discrete one is the *pencil* determinant, which needs no inverse:

$ "det"(z I - H) = z^4 - frac(197,4) z^2 + frac(49,4) = (z^2 - 49)(z^2 - 1/4) $ <eq:ctchar>
$ "det"(z N - L) = -z^4 + frac(27,10) z^3 + 11 z^2 + frac(27,10) z - 1 \
  = -(z^2 - frac(26,5) z + 1)(z^2 + frac(5,2) z + 1) $ <eq:dtchar>

*The facts.* #ref(<eq:ctchar>) has multipliers $plus.minus 7$ and $plus.minus 1/2$; #ref(<eq:dtchar>) has
$1/5$, $5$, $-1/2$, $-2$. Each quadratic factor belongs to one mode of #ref(<eq:plant>): the
actuated mode contributes $plus.minus 7$ and the pair $(1/5, 5)$, the unactuated mode contributes
$plus.minus 1/2$ and the pair $(-1/2, -2)$. The closed-loop pairs printed in section 1 are two of the
four multipliers in each domain.

// ======================= 3. A MATRIX OR A PAIR? ==========================

= Why not just invert N? <s3>

#question[A deflating basis is a $2n$-by-$n$ matrix $V = mat(V_1; V_2)$ split into a state block
  $V_1$ and a costate block $V_2$, and a selection of $n$ multipliers becomes a solution only
  through $P = V_2 V_1^(-1)$. Say which single multiplier of the running continuous pencil, and
  which single multiplier of the running discrete one, comes with a $V_1$ that cannot be inverted,
  and hence which four of the six two-element selections in each domain are not graphs at all. Then
  take the changed plant #ref(<eq:dead>): name what a list of ordinary eigenvalues of $N^(-1) L$
  would have to throw away there, what has to be carried in its place so that all four multipliers
  are still representable, and what the deflating *subspace* fixes even when $V_2 V_1^(-1)$ does
  not.]

#figure(
  kind: table,
  caption: [The deflating directions of the running pencils and the state block each direction
    carries. A selection of two directions has one block per direction; inspect which pairs of
    blocks could stand side by side as the columns of an invertible $V_1$.],
  text(size: 10pt)[
    #table(
      columns: (auto, auto, auto),
      align: (left, center, center),
      stroke: (x: none, y: 0.5pt + gray.lighten(45%)),
      inset: (x: 7pt, y: 3pt),
      table.header([*Pencil*], [*Multiplier $mu$*], [*State block of its direction*]),
      [continuous], [$-7$], [$(1, 0)$],
      [continuous], [$+7$], [$(-9/5, 0)$],
      [continuous], [$-1/2$], [$(0, 1)$],
      [continuous], [$+1/2$], [$(0, 0)$],
      [discrete], [$1/5$], [$(1, 0)$],
      [discrete], [$5$], [$(-15, 0)$],
      [discrete], [$-1/2$], [$(0, 1)$],
      [discrete], [$-2$], [$(0, 0)$],
    )
  ],
)

*Notation.* Columns of $V$ are deflating directions, so $L V = N V D$ for a diagonal $D$ when all
$n$ of them are finite; the graph of $P$ is the special case $V = mat(I; P)$. One direction is
defined only up to scale, and a subspace only up to a choice of basis.

*The running pencil, inverted.* Here $"det" N = "det" A = -1$, so $N^(-1) L$ exists as an ordinary
matrix and its four eigenvalues are $1/5$, $5$, $-1/2$ and $-2$. Each eigenvalue names one
direction, and the table above lists the state block that direction carries; the continuous rows
list the same four directions with the blocks they carry there. A selection of two directions is a
graph exactly when the two blocks placed side by side form an invertible $2$-by-$2$ matrix.

*A changed plant.* Replace $A$ by $A_0 = "diag"(2, 0)$, leaving $B$, $G$ and $Q_d$ as in
#ref(<eq:plant>). Then $"det" N = 0$ and $N$ has rank $3$, and the pencil determinant drops in degree:

$ "det"(z N_0 - L_0) = -2 z^3 + frac(52,5) z^2 - 2 z $ <eq:dead>

Its three finite roots are $1/5$, $5$ and $0$; the direction at $0$ has state block $(0, 4/3)$ and
the fourth direction, the one no root of #ref(<eq:dead>) names, has state block $(0, 0)$.

// ================== 4. THE GENERALIZED SCHUR FORM ========================

= What does the generalized Schur form give? <s4>

#question[The definition below is a factorization of a *pair*, and a run of the algorithm that
  produces it returns several objects at once. List what a QZ run hands back on the running discrete
  pencil before any decision about stability has been made, and say which of those objects, if any,
  is the answer to #ref(<eq:dare>). Then explain how the sentence "keep the multipliers inside the
  unit circle" has to become a statement about the first two columns of a single matrix -- and why
  a pair of multipliers that are complex conjugates cannot be separated by any such statement.]

#figure(
  caption: [The four multipliers of each pencil against the boundary they are judged by. Navy marks
    the actuated mode, teal the unactuated one, and nothing is selected. Distances are true to
    scale, so the teal pair sits one fourteenth of the way out to the navy pair; on the right,
    radius is drawn as $sqrt(abs(mu))$ so a multiplier and its partner both fit.],
  box(width: 100%, height: 6.4cm)[
    #let ly = 2.9cm
    #let cx1 = 2.7cm
    #let cx2 = 11.3cm
    #let sc = 0.30cm
    #let rc = 1.15cm
    #let rad(m) = rc * calc.sqrt(m)
    #let dot(dx, dy, c) = place(top + left, dx: dx, dy: dy)[
      #rect(width: 5.5pt, height: 5.5pt, radius: 50%, fill: c)
    ]
    // left panel: the imaginary axis
    #place(top + left)[
      #line(start: (cx1 - 2.6cm, ly), end: (cx1 + 2.6cm, ly), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #line(start: (cx1, ly - 2.1cm), end: (cx1, ly + 2.1cm), stroke: 1.2pt + navy)
    ]
    #dot(cx1 - 7 * sc - 2.75pt, ly - 2.75pt, navy)
    #dot(cx1 + 7 * sc - 2.75pt, ly - 2.75pt, navy)
    #dot(cx1 - 0.5 * sc - 2.75pt, ly - 2.75pt, teal)
    #dot(cx1 + 0.5 * sc - 2.75pt, ly - 2.75pt, teal)
    #place(top + left, dx: cx1 - 7 * sc - 0.4cm, dy: ly - 1.9em)[$-7$]
    #place(top + left, dx: cx1 + 7 * sc - 0.3cm, dy: ly - 1.9em)[$+7$]
    #place(top + left)[
      #line(start: (cx1 - 0.5 * sc, ly + 2.5pt), end: (cx1 - 0.5 * sc, ly + 0.42cm), stroke: 0.6pt + gray)
    ]
    #place(top + left)[
      #line(start: (cx1 + 0.5 * sc, ly + 2.5pt), end: (cx1 + 0.5 * sc, ly + 0.85cm), stroke: 0.6pt + gray)
    ]
    #place(top + left, dx: cx1 - 0.5 * sc - 0.95cm, dy: ly + 0.85em)[$-1/2$]
    #place(top + left, dx: cx1 + 0.5 * sc + 0.2cm, dy: ly + 2.1em)[$+1/2$]
    #place(top + left, dx: cx1 - 2.6cm, dy: 0.1cm)[imaginary axis]
    // right panel: the unit circle
    #place(top + left)[
      #line(start: (cx2 - 3.2cm, ly), end: (cx2 + 3.2cm, ly), stroke: 0.8pt + gray)
    ]
    #place(top + left, dx: cx2 - rc, dy: ly - rc)[
      #circle(radius: rc, stroke: 1.2pt + navy, fill: none)
    ]
    #dot(cx2 + rad(5.0) - 2.75pt, ly - 2.75pt, navy)
    #dot(cx2 + rad(0.2) - 2.75pt, ly - 2.75pt, navy)
    #dot(cx2 - rad(0.5) - 2.75pt, ly - 2.75pt, teal)
    #dot(cx2 - rad(2.0) - 2.75pt, ly - 2.75pt, teal)
    #place(top + left, dx: cx2 + rad(5.0) - 0.3cm, dy: ly - 1.9em)[$5$]
    #place(top + left, dx: cx2 - rad(2.0) - 0.4cm, dy: ly - 1.9em)[$-2$]
    #place(top + left, dx: cx2 + rad(0.2) + 0.15cm, dy: ly + 0.9em)[$1/5$]
    #place(top + left, dx: cx2 - rad(0.5) - 0.75cm, dy: ly + 0.9em)[$-1/2$]
    #place(top + left, dx: cx2 - 3.2cm, dy: 0.1cm)[unit circle $abs(mu) = 1$]
  ],
)

*The form.* There are orthogonal $Q$ and $Z$, both $2n$-by-$2n$, with

$ Q' L Z = S, quad Q' N Z = T, $ <eq:qz>

where $S$ is *quasi-upper-triangular* -- upper triangular except for $1$-by-$1$ and $2$-by-$2$
diagonal blocks -- and $T$ is upper triangular. The multipliers are the generalized eigenvalues of
the diagonal blocks: a $1$-by-$1$ block of $S$ over the entry below it in $T$ gives one multiplier,
and a $2$-by-$2$ block gives two. Writing a block as $(alpha, beta)$, the multiplier is
$mu = alpha / beta$, and $beta = 0$ is what an infinite multiplier looks like in #ref(<eq:qz>).

*The two pencils.* #ref(<eq:qz>) is stated for $(L, N)$. The continuous pair is the same object
with one block fixed: $H$ is the pencil $(H, I_{2n})$, and every statement above about $S$ and $T$
becomes a statement about $Q' H Q$ alone.

*What the form keeps.* $Q$ and $Z$ are orthogonal, so #ref(<eq:qz>) is an equivalence of pairs
rather than a similarity of one matrix: both matrices are re-coordinated at once and the multiset of
multipliers is untouched. And because $S$ and $T$ are triangular *in the same order*, the span of the
first $k$ columns of $Z$ is deflating for $(L, N)$ whenever $k$ ends at a block boundary.

// ==================== 5. REDUCTION AND SWEEPS ============================

= How do the sweeps get there? <s5>

#question[Each sweep of a QZ run is one pair of orthogonal transformations, applied to $S$ and to
  $T$ together, chosen so that one marked entry shrinks. Say what such a step has to leave
  unchanged -- about the pair, about the multipliers, and about the two sparsity patterns in
  #ref(<fig:hess>) -- and why the number it shifts by cannot be read off $S$ alone or off $T$
  alone. Then, on the running discrete pencil, name the quantity that has to go small for $-2$ to
  split off as a block of its own, and the quantity that has to go small for the multiplier of
  #ref(<eq:dead>) that no root names to split off.]

#figure(
  caption: [The sparsity a sweep works on, for $n = 2$: $S$ upper Hessenberg, $T$ upper triangular,
    one pair of orthogonal transformations applied to both. The outlined $2$-by-$2$ corner is where
    the shift is taken from; the shaded cell is the entry a sweep drives toward zero.],
  box(width: 100%, height: 5.0cm)[
    #let cs = 0.9cm
    #let y0 = 1.1cm
    #let x1 = 0.7cm
    #let x2 = 8.6cm
    #let hess = ((1, 1, 1, 1), (1, 1, 1, 1), (0, 1, 1, 1), (0, 0, 1, 1))
    #let tri = ((1, 1, 1, 1), (0, 1, 1, 1), (0, 0, 1, 1), (0, 0, 0, 1))
    #let grid(x, pat, c1) = {
      for i in range(4) {
        for j in range(4) {
          place(top + left, dx: x + j * cs, dy: y0 + i * cs)[
            #rect(width: cs, height: cs, stroke: 0.5pt + gray,
              fill: if pat.at(i).at(j) == 1 { c1 } else { white })
          ]
        }
      }
    }
    #grid(x1, hess, navy.lighten(80%))
    #grid(x2, tri, teal.lighten(80%))
    #place(top + left, dx: x1 + 2 * cs, dy: y0 + 2 * cs)[
      #rect(width: 2 * cs, height: 2 * cs, stroke: 1.4pt + navy, fill: none)
    ]
    #place(top + left, dx: x2 + 2 * cs, dy: y0 + 2 * cs)[
      #rect(width: 2 * cs, height: 2 * cs, stroke: 1.4pt + navy, fill: none)
    ]
    #place(top + left, dx: x1 + 2 * cs, dy: y0 + 3 * cs)[
      #rect(width: cs, height: cs, stroke: 0.5pt + gray, fill: teal.lighten(40%))
    ]
    #place(top + left, dx: x1 + 2 * cs - 0.12cm, dy: y0 + 4 * cs + 0.25em)[$s_(43)$]
    #place(top + left, dx: x2 + 2 * cs - 0.12cm, dy: y0 + 4 * cs + 0.25em)[$t_(44)$]
    #place(top + left, dx: x1, dy: 0.25cm)[$S$: upper Hessenberg]
    #place(top + left, dx: x2, dy: 0.25cm)[$T$: upper triangular]
  ],
) <fig:hess>

*The two shapes.* A run does not start from $L$ and $N$ as written in #ref(<eq:pencils>). It spends
one orthogonal equivalence on the pair first, reaching *generalized Hessenberg form*: $S$ upper
Hessenberg, meaning zero below the first subdiagonal, and $T$ upper triangular. Every later sweep is
a step that keeps both shapes, and the trailing corner of the pair is where the next multiplier is
decided.

*The shift.* The trailing $2$-by-$2$ sub-pencil is the outlined corner of #ref(<fig:hess>): rows and
columns $3$ and $4$ of $S$ together with rows and columns $3$ and $4$ of $T$. That sub-pencil has two
generalized eigenvalues, and they are the only numbers a sweep can be shifted by. Neither $2$-by-$2$
corner means anything on its own -- $s_(43)$ and $t_(44)$ are read against each other, not separately.

*The exit.* A multiplier *splits off* when the working pair decouples into two smaller pairs, after
which the sweeps continue on the leading part alone. Two different entries of the pair can do that
decoupling, and the running pencil has one multiplier whose partner sits at the far end of the
modulus scale and one whose state block is zero, so the two cases are not the same event.

// ================= 6. THE PROCEDURE AND ITS COST =========================

= The procedure, the gain, and what it costs <s6>

#question[The five stage names below are the whole solve, and the answer they return is an
  $n$-by-$n$ matrix produced from a $2n$-by-$2n$ pair. Predict which stage dominates the arithmetic
  as $n$ grows, and which single stage decides how many correct digits the returned $P$ keeps --
  then say why those two cannot be the same stage. Second half: against the two foils at the bottom
  of this page, what does the pencil route give up, and what does each foil keep that the pencil
  route does not?]

#figure(
  caption: [The five stages of a solve and the object each one passes on, with the two other routes
    below. Inspect which objects are $n$-by-$n$ and which are $2n$-by-$2n$, and what each route
    carries from one step to the next.],
  box(width: 100%, height: 5.2cm)[
    #let bw = 2.42cm
    #let bh = 0.78cm
    #let gap = 0.62cm
    #let y0 = 0.7cm
    #let names = ("Build", "Reduce", "Sweep", "Reorder", "Extract")
    #let objs = (
      [$2n times 2n$],
      [$2n times 2n$],
      [$2n times 2n$],
      [$2n times n$],
      [$n times n$],
    )
    #for i in range(5) {
      let x = 0.1cm + i * (bw + gap)
      place(top + left, dx: x, dy: y0)[
        #rect(width: bw, height: bh, radius: 2pt, stroke: 0.9pt + navy, fill: navy.lighten(93%))[
          #align(center + horizon)[#text(size: 9.5pt)[#names.at(i)]]
        ]
      ]
      place(top + left, dx: x, dy: y0 + bh + 0.14cm)[
        #box(width: bw)[#align(center)[#text(size: 8.5pt, fill: gray)[#objs.at(i)]]]
      ]
      if i < 4 {
        place(top + left, dx: x + bw - 0.02cm, dy: y0 + bh / 2 - 0.42cm)[
          #text(size: 11pt, fill: gray)[$arrow.r$]
        ]
      }
    }
    #place(top + left, dx: 0.1cm, dy: y0 + bh + 1.45cm)[
      #text(size: 9pt, fill: gray)[two other routes:]
    ]
    #place(top + left, dx: 0.1cm, dy: y0 + bh + 1.85cm)[
      #text(size: 9.5pt)[fixed-point recursion -- keeps an $n times n$ iterate, one step at a time]
    ]
    #place(top + left, dx: 0.1cm, dy: y0 + bh + 2.25cm)[
      #text(size: 9.5pt)[squaring -- keeps an $n times n$ iterate, $2^k$ steps at once]
    ]
  ],
)

*The stages, named.* A solve that ends in #ref(<eq:qz>) passes through five stages, and only their
names matter here. *Build* the pair $(L, N)$, or the pencil $(H, I)$, from $A$, $B$, $R$, $Q$.
*Reduce* the pair to generalized Hessenberg form by one orthogonal equivalence. *Sweep*: the shifted
steps of section 5, deflating each multiplier that splits off, until #ref(<eq:qz>) holds. *Reorder*
the diagonal blocks so the $n$ selected multipliers are the leading ones, and read $V$ off the
leading columns of $Z$. *Extract* $P = V_2 V_1^(-1)$ and the gain.

*Sizes.* The pair is $2n$-by-$2n$ and the answer is $n$-by-$n$: the object the reader keeps has a
quarter of the entries of the object the sweeps act on. Every stage but the last is built out of
orthogonal transformations applied to that $2n$-by-$2n$ pair, and one such transformation costs on
the order of the cube of the side it acts on, while a block exchange costs on the order of the
square of the block it moves.

*Two foils.* The recursion of #ref(<eq:dare>) can be iterated as it stands,
$P_(k+1) = Q_d + A' P_k (I + G P_k)^(-1) A$ from $P_0 = Q_d$; on the running example its first three
iterates are $"diag"(3/5, 3/4)$, $"diag"(39/40, 15/16)$ and $"diag"(1953/1955, 63/64)$, and it climbs
to $P = I$ without ever forming a $4$-by-$4$ object. And the same recursion can be *squared* rather
than iterated, replacing the pencil by the pencil of $2^k$ steps -- the route taken up in
#raw("Control/sda-algebraic-riccati/sda-algebraic-riccati.pdf").

// ================= 7. WHERE THE GUARANTEE STOPS ==========================

= Where does the guarantee stop? <s7>

#question[Each row of #ref(<tab:limits>) changes one input of the running example and prints what
  the pencil and the equation then do. Sort the five rows: which change leaves no stabilizing answer
  at all, which leaves an answer that is not the LQR gain, and which the decomposition shrugs off as
  though nothing had happened. Then name the one quantity in the decomposition that decides each of
  those three verdicts, and say what you would have measured on the plant before any row was changed, to know in
  advance how much of the answer to trust.]

*What is held fixed.* $A$, $B$, $R$ and the other domain's weighting stay as in
#ref(<eq:plant>), and exactly one entry of one input changes per row. "Graph" means what it meant in section 3: a selection whose
$V_1$ is invertible, so that $P = V_2 V_1^(-1)$ exists.

#figure(
  kind: table,
  caption: [Five one-input changes. Every $P$ printed here makes its own equation's residual exactly
    zero, by arithmetic and not by rounding. Read the rows as data: nothing here says which of them
    is a controller.],
  text(size: 10pt)[
    #table(
      columns: (20%, 18%, 32%, 30%),
      align: (left, left, left, left),
      stroke: (x: none, y: 0.5pt + gray.lighten(45%)),
      inset: (x: 4pt, y: 3pt),
      table.header([*Change*], [*Multipliers*], [*Graph solutions*], [*Closed loops*]),
      [(a) continuous: $G$ to zero, so the unstable mode loses its input],
      [$plus.minus 2$, $plus.minus 1/2$],
      [one: $"diag"(-5/4, 1)$],
      [$(2, -1/2)$],

      [(b) continuous: $Q_c$ to $"diag"(0, 1)$, so the unstable mode stops being penalized],
      [$plus.minus 2$, $plus.minus 1/2$],
      [two: $"diag"(4/9, 1)$ and $"diag"(0, 1)$],
      [$(-2, -1/2)$, gain $(4/3, 0)$; and $(2, -1/2)$, gain $(0, 0)$],

      [(c) discrete: $A$ to $"diag"(2, 0)$, one plant mode goes dead],
      [$1/5$, $5$, $0$ and one more, unnamed by #ref(<eq:dead>)],
      [two: $"diag"(1, 3/4)$ and $"diag"(-1/15, 3/4)$],
      [$(1/5, 0)$ and $(5, 0)$],

      [(d) continuous: $Q_c$ to $"diag"(-11/25, 1)$, the penalty on the actuated mode turns negative],
      [$plus.minus 1/5$, $plus.minus 1/2$],
      [two, both positive definite: $"diag"(11/45, 1)$, $"diag"(1/5, 1)$],
      [$(-1/5, -1/2)$ and $(1/5, -1/2)$],

      [(d-limit): $Q_c$ to $"diag"(-4/9, 1)$, that pair reaches the imaginary axis],
      [$0$ twice, $plus.minus 1/2$],
      [one: $"diag"(2/9, 1)$],
      [$(0, -1/2)$, with one direction at the repeated multiplier],
    )
  ],
) <tab:limits>

*The data behind the rows.* In (c) the block $N$ is singular, of rank $3$, and the pencil
determinant has degree $3$; in (a) and (d-limit) the number of graph selections drops from two to
one, and in (d-limit) the repeated multiplier carries a single deflating direction.

// =============================== 8. SOURCES ===============================

= Sources and further reading

No external source has been consulted for this note, and it makes no claim about prior work,
attribution, or the history of the QZ algorithm, of the deflating-subspace description of a Riccati
equation, or of any flop count. Everything stated on the page is either a definition, a property of
the objects defined here, or an exact rational computation on the running example, reproduced by
#raw("Algebra/qz-riccati/scripts/verify_qz_are.py"), which is run from the repository root and prints
the residuals, both characteristic polynomials, the per-mode multipliers, the six-selection table for
each domain, and the five changed cases of #ref(<tab:limits>).

Unconsulted suggestions: none yet.
