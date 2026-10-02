// symplectic-matrix.typ -- a teach-an-engineer question map, filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ. One deep question per section;
// the expected insights live in summary.md, never here.
//
// Every number quoted below is reproduced by scripts/verify_symplectic.py, which also checks
// the symplectic and Hamiltonian identities the note asks the reader to reason about.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

#show: note-ilm.with(
  title: [Symplectic Matrices in Control],
  authors: "Amp",
  abstract: [
    A symplectic matrix preserves a bilinear form on phase space, and that single algebraic
    condition turns out to rigidify a spectrum, to explain why an undamped mechanical system
    cannot settle, and to sit underneath the Riccati equation that every LQR gain comes from.
    This note asks six questions from zero: what the symplectic condition preserves and forces
    about the inverse and determinant; why the flow of a Hamiltonian system is symplectic while
    a damped one is not; what the spectrum of a symplectic matrix must look like and why that
    rules out asymptotic stability; where a Hamiltonian matrix enters optimal control and how
    its invariant subspace produces the stabilizing Riccati solution; what a numerical reduction
    must preserve to compute that subspace honestly; and what changes when a pair of eigenvalues
    reaches the imaginary axis. The running example is a unit mass on a unit spring, first in
    phase space and then under an LQR cost. Answers are deliberately withheld.
  ],
)

// ---------------------------------------------------------------------------
// shared drawing helpers: one phase plane and one complex plane, both typeset.
#let cell(M, i, j) = M.at(i).at(j)
#let poly(pts, stroke: none, fill: none) = polygon(..pts.map(p => (p.at(0), p.at(1))), stroke: stroke, fill: fill)

// ============================== 1. QUESTION ===============================

= What does the symplectic condition preserve? <s1>

#question[The condition $M^T J M = J$ is a statement about a bilinear form on $bb(R)^(2n)$.
  What does that form measure, what does the condition force about $M^(-1)$ and about $det M$,
  and what does it demand in $2n$ dimensions beyond keeping volume fixed?]

*Running example.* Write a phase-space vector as $x = mat(q; p)$ with $q, p in bb(R)^n$, and let

$ J = mat(0, I_n; -I_n, 0), quad omega(u, v) = u^T J v. $ <eq:form>

A real $2n times 2n$ matrix $M$ is *symplectic* when

$ M^T J M = J. $ <eq:symp>

The form $omega$ is antisymmetric, $omega(u, v) = -omega(v, u)$. For the figures below take
$n = 1$, so $x = mat(q; p)$ is a point of the plane and $J = mat(0, 1; -1, 0)$.

#figure(
  caption: [The unit square in the $(q, p)$ plane and its image under two linear maps. Inspect
    what each image does to area, and how the shear image differs from the squeeze image.],
  box(width: 100%, height: 5.2cm)[
    #let panel(ox, oy, sc, M, name, col) = {
      let P(x, y) = (ox + x * sc, oy - y * sc)
      place(top + left)[#line(start: P(-1.25, 0), end: P(1.55, 0), stroke: 0.6pt + gray)]
      place(top + left)[#line(start: P(0, -1.25), end: P(0, 1.25), stroke: 0.6pt + gray)]
      let sq = ((-0.5, -0.5), (0.5, -0.5), (0.5, 0.5), (-0.5, 0.5))
      place(top + left)[#poly(sq.map(p => P(p.at(0), p.at(1))), stroke: 0.8pt + gray, fill: none)]
      let im = sq.map(p => (cell(M, 0, 0) * p.at(0) + cell(M, 0, 1) * p.at(1),
                            cell(M, 1, 0) * p.at(0) + cell(M, 1, 1) * p.at(1)))
      place(top + left)[#poly(im.map(p => P(p.at(0), p.at(1))), stroke: 1.2pt + col, fill: col.transparentize(85%))]
      place(top + left, dx: ox - 1.6cm, dy: oy + 1.15cm)[#text(size: 9pt)[#name]]
      place(top + left, dx: ox - 1.6cm, dy: oy - 1.15cm)[#text(size: 8pt)[$q$]]
      place(top + left, dx: ox + 0.35cm, dy: oy - 1.15cm)[#text(size: 8pt)[$p$]]
    }
    #panel(3.0cm, 2.7cm, 1.55cm, ((1, 0.8), (0, 1)), [shear: area 1.00], navy)
    #panel(10.0cm, 2.7cm, 1.55cm, ((1.6, 0), (0, 0.6)), [squeeze: area 0.96], teal)
  ],
)

*Facts to reason with.*
- For $n = 1$ the identity $M^T J M = (det M) J$ holds for every $2 times 2$ matrix $M$.
- The shear $S = mat(1, 0.8; 0, 1)$ has $det S = 1$ and $norm(S^T J S - J) = 0$.
- The rotation by $30 degree$ has $det = 1$ and $norm(M^T J M - J) = 0$.
- The squeeze $D = mat(1.6, 0; 0, 0.6)$ has $det D = 0.96$ and $norm(D^T J D - J) = 0.04$.
- $J$ itself satisfies $J^T = -J$, $J^2 = -I$, and $J^(-1) = -J$.

// =============================== 2. NEED ==================================

= Why is the flow of a Hamiltonian system symplectic? <s2>

#question[For $dot(x) = J nabla H(x)$ the flow map $Phi_t$ is symplectic for every $t$. Why
  must that be so, and which structural feature of the right-hand side is responsible? What
  does adding damping change, and what stays true of the undamped flow no matter how long it
  runs?]

*Running example.* A unit mass on a unit spring has energy

$ H(q, p) = (q^2 + p^2) / 2, quad J = mat(0, 1; -1, 0), quad dot(x) = J nabla H(x) = mat(p; -q). $ <eq:osc>

Write $Phi_t$ for the flow map, the map sending $x(0)$ to $x(t)$. Near any point the flow is
governed by the Jacobian of the right-hand side,

$ nabla(J nabla H)(x) = J nabla^2 H(x), quad nabla^2 H = mat(1, 0; 0, 1), $ <eq:jac>

and $nabla^2 H$ is symmetric. For a linear system $dot(x) = A x$ the flow map is $Phi_t = e^(A t)$.

#figure(
  caption: [The phase plane of #ref(<eq:osc>) with one small square patch at $t = 0$ and its
    image under the flow at $t = 1$, both on the orbit through the patch center. Inspect the
    shape and the area of the image.],
  box(width: 100%, height: 5.0cm)[
    #let cx = 4.2cm
    #let cy = 2.5cm
    #let sc = 1.5cm
    #let P(x, y) = (cx + x * sc, cy - y * sc)
    #let R = ((0.5403, 0.8415), (-0.8415, 0.5403))
    #place(top + left)[#line(start: P(-1.7, 0), end: P(1.9, 0), stroke: 0.6pt + gray)]
    #place(top + left)[#line(start: P(0, -1.5), end: P(0, 1.5), stroke: 0.6pt + gray)]
    #place(top + left, dx: cx - 1.1011 * sc, dy: cy - 1.1011 * sc)[#circle(radius: 1.1011 * sc, stroke: 0.6pt + gray, fill: none)]
    #let sq = ((0.9, -0.25), (1.3, -0.25), (1.3, 0.15), (0.9, 0.15))
    #place(top + left)[#poly(sq.map(p => P(p.at(0), p.at(1))), stroke: 0.8pt + gray, fill: gray.transparentize(88%))]
    #let im = sq.map(p => (cell(R, 0, 0) * p.at(0) + cell(R, 0, 1) * p.at(1),
                          cell(R, 1, 0) * p.at(0) + cell(R, 1, 1) * p.at(1)))
    #place(top + left)[#poly(im.map(p => P(p.at(0), p.at(1))), stroke: 1.2pt + navy, fill: navy.transparentize(85%))]
    #place(top + left, dx: cx - 2.2cm, dy: cy + 1.85cm)[#text(size: 9pt)[initial patch (gray) and its image at $t = 1$ (navy)]]
    #place(top + left, dx: cx - 1.7cm, dy: cy - 1.3cm)[#text(size: 8pt)[$q$]]
    #place(top + left, dx: cx + 0.4cm, dy: cy - 1.3cm)[#text(size: 8pt)[$p$]]
  ],
)

*Facts to reason with.*
- For #ref(<eq:osc>), $Phi_1 = mat(0.5403, 0.8415; -0.8415, 0.5403)$, so
  $norm(Phi_1^T J Phi_1 - J) approx 1.1 times 10^(-16)$ and $det Phi_1 = 1$.
- Adding damping gives $dot(q) = p$, $dot(p) = -q - c p$ with $c > 0$, and $det Phi_t = e^(-c t)$;
  at $c = 0.5$, $det Phi_1 = 0.6065$.
- Open #raw("Control/symplectic-matrix/symplectic-matrix-demo.html") beside this note and move
  the stiffness, damping, and integrator controls to watch the same patch and its area ratio.

// =============================== 3. IDEA ==================================

= What does symplecticity force on the spectrum? <s3>

#question[Take two unrelated symplectic matrices of the same size. If $lambda$ is an eigenvalue
  of one of them, which other complex numbers must also be eigenvalues of that same matrix?
  Why does that rigidity make it impossible for an asymptotically stable linear system to have
  a symplectic state-transition matrix?]

*Facts to reason with.*
- For a discrete linear system $x_(k+1) = M x_k$, asymptotic stability means every eigenvalue of
  $M$ lies strictly inside the unit circle.
- $M_1 = Phi_1$ from #ref(<eq:osc>) is symplectic with $det M_1 = 1$ and eigenvalues
  $0.5403 plus.minus 0.8415 i$, both of modulus $1$.
- $M_2 = e^(H_2)$ for $H_2 = mat(0, 1, 0, 0; -2, -0.2, 0, -1; -0.5, 0, 0, 2; 0, 0, -1, 0.2)$ is
  symplectic with $det M_2 = 1$ and eigenvalues
  $0.1111 plus.minus 0.6853 i$ and $0.2306 plus.minus 1.4218 i$.
- Both satisfy $norm(M_i^T J M_i - J) < 10^(-15)$.

#figure(
  caption: [Eigenvalues of the two symplectic matrices $M_1$ (navy) and $M_2$ (teal) in the
    complex plane, with the unit circle. Inspect the arrangement of the points relative to the
    circle and to one another.],
  box(width: 100%, height: 6.0cm)[
    #let cx = 5.6cm
    #let cy = 2.7cm
    #let sc = 1.35cm
    #let P(re, im) = (cx + re * sc, cy - im * sc)
    #let dot(z, col) = place(top + left, dx: P(z.at(0), z.at(1)).at(0) - 2.6pt, dy: P(z.at(0), z.at(1)).at(1) - 2.6pt)[
      #circle(radius: 2.6pt, fill: col, stroke: none)
    ]
    #place(top + left)[#line(start: P(-2.0, 0), end: P(2.0, 0), stroke: 0.6pt + gray)]
    #place(top + left)[#line(start: P(0, -1.9), end: P(0, 1.9), stroke: 0.6pt + gray)]
    #place(top + left, dx: cx - sc, dy: cy - sc)[#circle(radius: 1.0 * sc, stroke: 0.8pt + gray, fill: none)]
    #for z in ((0.5403, 0.8415), (0.5403, -0.8415)) { dot(z, navy) }
    #for z in ((0.1111, 0.6853), (0.1111, -0.6853), (0.2306, 1.4218), (0.2306, -1.4218)) { dot(z, teal) }
    #place(top + left, dx: 1.2cm, dy: cy + 2.85cm)[#text(size: 9pt)[unit circle; navy $M_1$, teal $M_2$]]
    #place(top + left, dx: cx - 2.0cm, dy: cy + 0.05cm)[#text(size: 8pt)[$"Re"$]]
    #place(top + left, dx: cx + 0.15cm, dy: cy - 1.85cm)[#text(size: 8pt)[$"Im"$]]
  ],
)

// =============================== 4. WHY ===================================

= Where does a Hamiltonian matrix enter control? <s4>

#question[The LQR problem replaces the plant with a $2n times 2n$ matrix built from $A$, $B$,
  $Q$, and $R$. What structural property does that matrix inherit from the problem, and how
  does the property deliver the stabilizing solution of the Riccati equation -- why exactly
  $n$ of its eigenvalues are the ones to keep, and what does an invariant subspace have to do
  with the symmetric solution?]

*Running example.* The same oscillator, now actuated and penalized: $dot(x) = A x + B u$ with

$ A = mat(0, 1; -1, 0), quad B = mat(0; 1), quad Q = epsilon I, quad R = 1, quad
  J_"c" = integral_0^oo (x^T Q x + u^2) dif t. $ <eq:lqr>

Write $G = B R^(-1) B^T = mat(0, 0; 0, 1)$. The optimal control is $u = -K x$, the classical LQR
result -- used here, not re-derived -- reads $K = B^T P$ off a symmetric solution $P$ of

$ A^T P + P A - P G P + Q = 0, $ <eq:care>

and the controller's solution is the one whose closed loop $A - G P$ is stable. The matrix

$ H = mat(A, -G; -Q, -A^T) $ <eq:ham>

is called the Hamiltonian matrix of the problem.

#figure(
  caption: [The block layout of #ref(<eq:ham>) for the running example, each block labeled by
    the problem data it carries. Inspect how the four blocks pair up and which of them is
    symmetric.],
  box(width: 100%, height: 4.0cm)[
    #let bx = 1.4cm
    #let by = 0.8cm
    #let w = 3.1cm
    #let h = 1.25cm
    #let blk(i, j, lab, col) = place(top + left, dx: bx + j * (w + 0.15cm), dy: by + i * (h + 0.15cm))[
      #rect(width: w, height: h, stroke: 1pt + col, fill: col.transparentize(90%), radius: 2pt)[
        #align(center + horizon)[#text(size: 9pt)[#lab]]
      ]
    ]
    #blk(0, 0, [$A$], navy)
    #blk(0, 1, [$-B R^(-1) B^T$], teal)
    #blk(1, 0, [$-Q$], teal)
    #blk(1, 1, [$-A^T$], navy)
    #place(top + left, dx: bx + 2 * w + 1.0cm, dy: by + h + 0.35cm)[#text(size: 9pt)[$H in bb(R)^(4 times 4)$]]
  ],
)

*Facts to reason with.*
- $H$ satisfies $(J H)^T = J H$ with the $4 times 4$ form $J = mat(0, I_2; -I_2, 0)$.
- For $epsilon = 1$ the characteristic polynomial of #ref(<eq:ham>) is $x^4 + x^2 + 2$, with
  roots $plus.minus 0.6761 plus.minus 0.9783 i$: two in the open left half-plane, two in the
  open right half-plane, none on the imaginary axis.
- If $H$ has no eigenvalues on the imaginary axis, its eigenvectors for the $n$
  left-half-plane eigenvalues span an $n$-dimensional invariant subspace. Writing a basis of it
  as a stacked block $mat(X_1; X_2)$ with $X_1, X_2 in bb(R)^(n times n)$, the relation
  $H mat(X_1; X_2) = mat(X_1; X_2) Lambda$ holds for the stable $Lambda$.

// ============================== 5. METHOD =================================

= What must the numerical reduction preserve? <s5>

#question[The stable invariant subspace of $H$ is usually reached through a Schur decomposition
  of $H$. Why is an ordinary Schur decomposition of $H$ the wrong instrument for this problem,
  and what must the transformation preserve so that the computed solution has the symmetry the
  Riccati equation demands and the stable eigenvalues the controller needs?]

#figure(
  caption: [Two reductions of the same Hamiltonian matrix. Inspect what each one guarantees
    about the transformed matrix and about the basis it hands back.],
  table(
    columns: 3,
    align: (left, left, left),
    inset: 6pt,
    stroke: 0.5pt + gray,
    [*Reduction*], [*Transformed form*], [*Basis and what it is built from*],
    [ordinary Schur], [$Q^* H Q = T$, $Q$ unitary, $T$ triangular], [columns of $Q$; stable and unstable eigenvalues may be interleaved],
    [Hamiltonian Schur], [$U^T H U = mat(T_11, T_12; 0, -T_11^T)$, $U$ symplectic-orthogonal], [first $n$ columns of $U$; the blocks are linked by the form],
  ),
)

*Facts to reason with.*
- The Riccati solution must be symmetric, $P = P^T$, and its closed loop must be the stable one;
  both are properties of the *subspace*, not of any one basis of it.
- The step that reads the Riccati solution off the stable subspace needs its upper block to be
  invertible and well-conditioned.
- An ordinary Schur decomposition may return the stable eigenvalues in any positions, and its
  basis is normalized for orthogonality, not for the relation between the two blocks.
- A symplectic-orthogonal $U$ satisfies $U^T J U = J$ exactly, and Hamiltonian Schur reductions
  are computed by orthogonal symplectic Hessenberg--Schur iterations.

// ============================== 6. LIMITS =================================

= What happens when an eigenvalue lands on the imaginary axis? <s6>

#question[Weaken the state penalty toward zero. What happens to the Hamiltonian spectrum, to
  the stabilizing solution of the Riccati equation, and to the invariant-subspace step that was
  supposed to produce it? What does the position of the spectrum say about whether a stabilizing
  Riccati solution exists?]

*Facts to reason with.* Keep #ref(<eq:lqr>) and #ref(<eq:ham>) but let $Q = epsilon I$ shrink.
The figure and table below report the left-half-plane member of the closed-loop pair for
decreasing $epsilon$; the full spectrum of $H$ is that pair together with its conjugates and
their negations.

#figure(
  caption: [The left-half-plane members of $sigma(H)$ as $epsilon$ decreases, and the same
    numbers in the table. Inspect where the points end up and how the real part behaves.],
  box(width: 100%, height: 5.2cm)[
    #let cx = 3.6cm
    #let cy = 2.6cm
    #let sc = 1.9cm
    #let P(re, im) = (cx + re * sc, cy - im * sc)
    #let dot(z) = place(top + left, dx: P(z.at(0), z.at(1)).at(0) - 2.6pt, dy: P(z.at(0), z.at(1)).at(1) - 2.6pt)[
      #circle(radius: 2.6pt, fill: navy, stroke: none)
    ]
    #place(top + left)[#line(start: P(-1.5, 0), end: P(0.5, 0), stroke: 0.6pt + gray)]
    #place(top + left)[#line(start: P(0, -1.15), end: P(0, 1.15), stroke: 0.6pt + gray)]
    #for (re, im) in ((-0.6761, 0.9783), (-0.2223, 0.9997), (-0.0707, 1.0), (0.0, 1.0)) {
      dot((re, im))
      dot((re, -im))
    }
    #place(top + left, dx: cx - 1.3cm, dy: cy + 1.3cm)[#text(size: 9pt)[$"Re" lambda$]]
    #place(top + left, dx: cx + 0.1cm, dy: cy - 1.15cm)[#text(size: 9pt)[$"Im" lambda$]]
    #place(top + left, dx: 7.4cm, dy: 1.5cm)[
      #table(columns: 3, align: (left, left, left), inset: 5pt, stroke: 0.5pt + gray,
        [$epsilon$], [$lambda$ of $sigma(H)$ in the LHP], [$abs(lambda)$],
        [$1$], [$-0.6761 + 0.9783 i$], [$1.1892$],
        [$0.1$], [$-0.2223 + 0.9997 i$], [$1.0241$],
        [$0.01$], [$-0.0707 + 1.0000 i$], [$1.0025$],
        [$0$], [$0 + 1.0000 i$], [$1.0000$],
      )
    ]
  ],
)

*Facts to reason with.*
- At $epsilon = 0$ the Riccati equation #ref(<eq:care>) becomes
  $A^T P + P A - P G P = 0$, which $P = 0$ satisfies, and the closed loop is then $A$ itself,
  with eigenvalues $plus.minus i$.

// ============================== 7. SOURCES ================================

= Sources and further reading

No external sources have been consulted yet; this note makes no external claims. Every number
above is arithmetic on the running example, reproduced by
#raw("Control/symplectic-matrix/scripts/verify_symplectic.py").
