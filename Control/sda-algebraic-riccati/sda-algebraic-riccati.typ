// sda-algebraic-riccati.typ -- a teach-an-engineer question map, filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ. One deep question per section,
// each led by its figure, table, or sidecar demo; the expected insights live in summary.md.
//
// Every number quoted below is an arithmetic consequence of the running example in eq:plant
// or a float64 run of the update in eq:sda, reproduced by scripts/verify_sda_are.py.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

#show: note-ilm.with(
  title: [Structure-Preserving Doubling for the Algebraic Riccati Equations],
  authors: "Amp",
  abstract: [
    A plant with a growing mode forces a controller out of a matrix equation that is quadratic
    in its unknown, so it has several answers and only one of them is the controller. This note
    asks six questions about getting that answer without an eigensolver. Which of the several
    solutions does the gain come from, and what singles it out? Why do the two obvious
    iterations each buy only a fixed number of digits per step? What identity lets the
    $2^(k+1)$-term partial sum of a linear matrix equation be assembled from one $2^k$-term
    partial sum? Why does the update that follows, written only in the data, leave the solution
    where it is while squaring the contraction? How does a continuous-time plant get into a
    discrete-time doubling? And what goes wrong when the shift is chosen badly or a multiplier
    reaches the unit circle? Each question is set up against one two-state LQR problem and one
    figure, table, or sidecar sweep, so an answer can be checked against the problem rather than
    against this page.
  ],
)

// ============================== 1. QUESTION ===============================

= One quadratic matrix equation, several answers <s1>

#question[The gain of the running plant is read off a matrix equation that is quadratic in its
  unknown, so it has more than one symmetric solution, and one mode of the plant grows. Which of
  those solutions does the controller use, and what property of the closed loop singles it out?]

#figure(
  caption: [The plant of #ref(<eq:plant>) before and after the feedback. Inspect which pole the
    feedback moves, which one it leaves where it was, and how far the moved one travels.],
  box(width: 100%, height: 3.05cm)[
    #let px(v) = 2.4cm + (v + 3) * 2.0cm
    #let yopen = 0.95cm
    #let yclosed = 2.2cm
    // the two real axes
    #place(top + left)[
      #line(start: (px(-3), yopen), end: (px(2), yopen), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #line(start: (px(-3), yclosed), end: (px(2), yclosed), stroke: 0.8pt + gray)
    ]
    // the shared pole at -1 does not move: a dashed guide through both rows
    #place(top + left)[
      #line(start: (px(-1), yopen), end: (px(-1), yclosed),
        stroke: (thickness: 0.6pt, dash: "dashed", paint: gray))
    ]
    // the feedback carries +1 to -2
    #place(top + left)[
      #line(start: (px(1), yopen + 3pt), end: (px(-2), yclosed - 3pt),
        stroke: (thickness: 1pt, paint: navy.lighten(25%)))
    ]
    // open-loop poles (top row)
    #place(top + left, dx: px(-1) - 2.6pt, dy: yopen - 2.6pt)[#circle(radius: 2.6pt, fill: navy, stroke: none)]
    #place(top + left, dx: px(1) - 2.6pt, dy: yopen - 2.6pt)[#circle(radius: 2.6pt, fill: navy, stroke: none)]
    // closed-loop poles (bottom row)
    #place(top + left, dx: px(-2) - 2.6pt, dy: yclosed - 2.6pt)[#circle(radius: 2.6pt, fill: teal, stroke: none)]
    #place(top + left, dx: px(-1) - 2.6pt, dy: yclosed - 2.6pt)[#circle(radius: 2.6pt, fill: teal, stroke: none)]
    // labels
    #place(top + left, dx: px(-1) - 0.4em, dy: yopen - 0.95cm)[$-1$]
    #place(top + left, dx: px(1) - 0.4em, dy: yopen - 0.95cm)[$+1$]
    #place(top + left, dx: px(-2) - 0.4em, dy: yclosed + 0.35cm)[$-2$]
    #place(top + left, dx: px(-1) - 0.4em, dy: yclosed + 0.35cm)[$-1$]
    #place(top + left, dx: px(-3) - 1.95cm, dy: yopen - 0.35em)[open loop]
    #place(top + left, dx: px(-3) - 1.95cm, dy: yclosed - 0.35em)[closed loop]
    #place(top + left, dx: px(-0.7), dy: 1.55cm)[$u = -K x$]
  ],
)

*The running example.* A two-state plant $dot(x) = A x + B u$ with

$ A = mat(-1, 0; 0, 1), quad B = mat(1; 1), quad Q = mat(1, 0; 0, 2), quad R = 1 $ <eq:plant>

and cost $J = integral_0^oo (x^T Q x + u^2) dif t$. The first state decays on its own; the second
grows like $e^t$, so feedback is what keeps the state bounded.

*The two equations.* Write $G = B R^(-1) B^T = mat(1, 1; 1, 1)$. The optimal control is a static
feedback $u = -K x$, and the classical LQR result -- used here, not re-derived -- reads the gain
$K$ off a symmetric solution $X$ of

$ K = B^T X, quad A^T X + X A - X G X + Q = 0, $ <eq:care>

the continuous-time algebraic Riccati equation (CARE). Its discrete-time sibling is the equation an
algorithm that doubles actually runs on,

$ X = Q + A^T X A - A^T X B (R + B^T X B)^(-1) B^T X A = Q + A^T X (I + G X)^(-1) A, $ <eq:dare>

the discrete-time algebraic Riccati equation (DARE).

*Facts to reason with.*
- Both equations are quadratic in $X$, so neither is a linear system, and the CARE on #ref(<eq:plant>)
  has several symmetric solutions.
- $A - G X$ is the closed loop of the feedback. A matrix is called stable here when every one of its
  eigenvalues lies in the open left half-plane, and in the discrete case inside the open unit disk.
- The textbook route to a symmetric solution builds the $2n times 2n$ Hamiltonian matrix
  $mat(A, -G; -Q, -A^T)$ and works on it with an ordered Schur decomposition.
- This note asks whether the controller's solution can be had from $n times n$ linear algebra
  alone -- no eigenvalues, no Schur form -- and how many such solves it costs.

// =============================== 2. NEED ==================================

= Why the obvious iterations crawl <s2>

#question[The Riccati equation is a fixed-point equation in disguise, so there are two obvious
  ways to iterate it: integrate the Riccati flow that solves the finite-horizon problem, or iterate
  the recursion #ref(<eq:fp>) from $X_0 = 0$. Both converge, and both are built from steps that are
  individually exact and cheap. Predict what fixes the number of digits each step gains, and what a
  single step would have to do to the error to gain the digits of many plain steps at once.]

#figure(
  caption: [Steps each route needs to drive the relative error of its iterate below
    $10^(-4)$, $10^(-8)$ and $10^(-12)$ on the running example, from
    #emph[scripts/verify_sda_are.py]. Inspect how each column grows with the target, and
    compare the two step sizes.],
  table(
    columns: 3,
    align: center,
    stroke: none,
    inset: 6pt,
    table.header([target error], [Riccati flow, RK4 $dif t = 0.02$], [plain recursion]),
    [$10^(-4)$],  [$249$], [$5$],
    [$10^(-8)$],  [$479$], [$9$],
    [$10^(-12)$], [$710$], [$13$],
  ),
)

*Route one, the flow.* The finite-horizon Riccati differential equation
$dot(Y) = Q + A^T Y + Y A - Y G Y$, started from $Y(0) = 0$, rises to $X$ as the horizon grows.
Near the limit the error obeys $dot(Delta) approx (A - G X)^T Delta + Delta (A - G X)$.

*Route two, the recursion.* Iterating #ref(<eq:dare>) from $X_0 = 0$ gives

$ X_(j+1) = Q + A^T X_j (I + G X_j)^(-1) A, $ <eq:fp>

whose error contracts by $sigma^2$ per step, where $sigma = rho((I + G X)^(-1) A) < 1$ and $rho$ is
the spectral radius. The table's recursion column is this iteration on the transformed data of
section 5, and the flow column is the differential equation on the data of #ref(<eq:plant>).

*Facts to reason with.*
- The closed-loop poles of the running example are $-1$ and $-2$; the transformed problem of
  section 5 has multiplier $sigma = 1/3$.
- One step of either route costs $O(n^3)$ work and advances the iterate index by one.
- Both routes stay inside $n times n$ linear algebra; the cost being examined here is the number of
  steps, not the work in a step.

// =============================== 3. IDEA ==================================

= Squaring a partial sum <s3>

#question[Strip the quadratic term out and the equation becomes the linear Stein equation
  $X = A^T X A + Q$ with $rho(A) < 1$, whose solution is the sum $sum_(i >= 0) (A^T)^i Q A^i$.
  Iterating $X_(j+1) = A^T X_j A + Q$ from zero produces the partial sums of that series. What
  identity lets the $2^(k+1)$-term partial sum be assembled from one $2^k$-term partial sum, and
  what recursion on the data does that identity give?]

#figure(
  caption: [The partial sums of the Stein series, one row per $k$: row $k$ holds the $2^k$ terms
    $(A^T)^i Q A^i$ with $i = 0, ..., 2^k - 1$, in order. Inspect how the row for $k + 1$ is
    built from the row for $k$.],
  box(width: 100%, height: 4.0cm)[
    #{
      let cellw = 0.78cm
      let cellh = 0.46cm
      let x0 = 1.75cm
      let rowh(k) = 0.45cm + k * 0.82cm
      for k in range(4) {
        place(top + left, dx: 0.1cm, dy: rowh(k) + 0.1cm)[$2^#k$ terms]
        for i in range(calc.pow(2, k)) {
          place(top + left, dx: x0 + i * (cellw + 1.2pt), dy: rowh(k))[
            #rect(width: cellw, height: cellh, fill: navy.lighten(78% - k * 6%), stroke: 0.4pt + gray)
          ]
          place(top + left, dx: x0 + i * (cellw + 1.2pt) + 0.28cm, dy: rowh(k) + 0.09cm)[$#i$]
        }
      }
    }
  ],
)

*Setup.* For the Stein equation the iterate from $X_0 = 0$ is exactly

$ X_j = sum_(i = 0)^(j-1) (A^T)^i Q A^i, quad "so" quad X - X_j = (A^T)^j X A^j. $ <eq:stein>

The error is one constant factor per step and nothing more.

*Facts to reason with.*
- $X_(2^k)$ is a partial sum with $2^k$ terms, and every term is built from $A$ and $Q$.
- The jump must be exact: whatever identity assembles the larger sum introduces no approximation.
- On a $2 times 2$ Stein equation with $rho(A) = 0.688$ the plain partial sums gain about $0.325$
  digits per step.

// =============================== 4. WHY ===================================

= Why the update never mentions the unknown <s4>

#question[Put the quadratic term back. The doubling can be written entirely in the data
  $(A_k, G_k, Q_k)$, with no reference to the unknown $X$, as #ref(<eq:sda>). Why does the same $X$
  solve the Riccati equation at every $k$, and why is the contraction of the $k$-th problem the
  $2^k$-th power of the first one's?]

#figure(
  caption: [The data of the $k$-th problem of #ref(<eq:sda>) and the residual of the original
    solution $X$ in that problem's Riccati equation, from #emph[scripts/verify_sda_are.py].
    Inspect which columns move with $k$ and which one does not.],
  table(
    columns: 4,
    align: center,
    stroke: none,
    inset: 6pt,
    table.header([$k$], [$norm(A_k)_F$], [$sigma_k$], [residual of $X$]),
    [0], [$1.01 times 10^0$],  [$3.33 times 10^(-1)$], [$1.92 times 10^(-16)$],
    [1], [$3.86 times 10^(-1)$], [$1.11 times 10^(-1)$], [$4.84 times 10^(-16)$],
    [2], [$4.36 times 10^(-2)$], [$1.24 times 10^(-2)$], [$4.84 times 10^(-16)$],
    [3], [$5.39 times 10^(-4)$], [$1.52 times 10^(-4)$], [$5.00 times 10^(-16)$],
    [4], [$8.21 times 10^(-8)$], [$2.32 times 10^(-8)$], [$4.81 times 10^(-16)$],
    [5], [$1.91 times 10^(-15)$], [$5.40 times 10^(-16)$], [$4.81 times 10^(-16)$],
  ),
)

*The update.* From $A_0 = A$, $G_0 = G$, $Q_0 = Q$,

$ A_(k+1) = A_k (I + G_k Q_k)^(-1) A_k, \
  G_(k+1) = G_k + A_k (I + G_k Q_k)^(-1) G_k A_k^T, \
  Q_(k+1) = Q_k + A_k^T Q_k (I + G_k Q_k)^(-1) A_k. $ <eq:sda>

*Facts to reason with.*
- The multiplier of a DARE with data $(A, G, Q)$ is $K = (I + G X)^(-1) A$, the matrix that carries
  the state through one closed-loop step.
- A Riccati equation is also a statement about a subspace. If $X$ solves #ref(<eq:dare>), then

  $ mat(A, 0; -Q, I) mat(I; X) = mat(I, G; 0, A^T) mat(I; X) K, $ <eq:pencil>

  so the block column $mat(I; X)$ is a deflating subspace of the pencil formed by the two blocks in
  #ref(<eq:pencil>), and $K$ is the operator that pencil induces on it.
- The only inverse in #ref(<eq:sda>) is $I + G_k Q_k$, and $G$ and $Q$ are symmetric.

// ============================== 5. METHOD =================================

= Getting a continuous plant into a discrete doubling <s5>

#question[The update #ref(<eq:sda>) doubles a discrete-time Riccati equation, but the running
  plant is continuous. A shift $tau > 0$ is applied to the plant's data, and the transformed
  problem of the running example has multiplier $sigma = 1/3$. What must that shift preserve for
  the doubling's guarantee to carry over, and why does the run in the table reach $X$ in a handful
  of steps?]

#figure(
  caption: [The update #ref(<eq:sda>) run on the transformed data of #ref(<eq:data>), one row per
    step, from #emph[scripts/verify_sda_are.py]. Inspect how the agreement with $X$ and the
    residual move as $k$ advances.],
  table(
    columns: 3,
    align: center,
    stroke: none,
    inset: 6pt,
    table.header([$k$], [digits of $Q_k$ agreeing with $X$], [residual of $Q_k$]),
    [0], [$0.70$],  [$1.92 times 10^(-16)$],
    [1], [$1.60$],  [$4.84 times 10^(-16)$],
    [2], [$3.50$],  [$4.84 times 10^(-16)$],
    [3], [$7.32$],  [$5.00 times 10^(-16)$],
    [4], [$14.91$], [$4.81 times 10^(-16)$],
    [5], [$15.88$], [$4.81 times 10^(-16)$],
  ),
)

*The bridge.* Choose a shift $tau > 0$ for which $A_tau = A - tau I$ is invertible and set

$ K_tau = A_tau^T + Q A_tau^(-1) G, quad A_0 = I + 2 tau (K_tau^T)^(-1), \
  G_0 = 2 tau A_tau^(-1) G K_tau^(-1), quad Q_0 = 2 tau K_tau^(-1) Q A_tau^(-1). $ <eq:cayley>

The shift replaces each eigenvalue $lambda$ by $lambda_tau = (lambda + tau) / (lambda - tau)$, and
#ref(<eq:cayley>) is the corresponding replacement of the CARE's data.

*The running example.* At $tau = 2$ the transformed data are exactly

$ A_0 = mat(-2/7, 6/7; 1/7, -3/7), quad G_0 = mat(1/7, 3/7; 3/7, 9/7), quad
  Q_0 = mat(3/7, -2/7; -2/7, 20/7), $ <eq:data>

and the transformed problem has multiplier $sigma = 1/3$. One step of #ref(<eq:sda>) is one
$n times n$ inverse plus a handful of products, and the run needs no eigensolver and no stabilizing
initial guess.

// ============================== 6. LIMITS =================================

= Where the guarantee stops <s6>

#question[The shift $tau$ in #ref(<eq:cayley>) is free, and the table records the multiplier it
  produces. Why is there a best $tau$, and what goes wrong as $tau$ moves away from it in either
  direction? Then change the hypothesis $sigma < 1$: what does the doubling become when a
  closed-loop multiplier reaches modulus one?]

Open #raw("sda-algebraic-riccati-demo.html") beside this note to move $tau$ and watch the two
closed-loop multipliers as they change.

#figure(
  caption: [The multiplier $sigma(tau)$ of the transformed problem as the shift moves, from
    #emph[scripts/verify_sda_are.py]. Inspect where the bridge stops existing and how $sigma$
    behaves on either side of it.],
  table(
    columns: 10,
    align: center,
    stroke: none,
    inset: 4pt,
    table.header(
      [$tau$], [$0.25$], [$0.5$], [$1$], [$sqrt(2)$], [$2$], [$4$], [$8$], [$16$], [$32$],
    ),
    [$sigma$], [$0.778$], [$0.600$], [--], [$0.172$], [$0.333$], [$0.600$], [$0.778$], [$0.882$], [$0.939$],
  ),
)

*The knob.* Same plant, same algorithm, different $tau$. The transformed closed-loop multipliers
$abs((lambda_i + tau) / (lambda_i - tau))$ depend on $tau$, and the table records the resulting
$sigma(tau)$.

*Facts to reason with.*
- At $tau = 1$ the bridge does not merely perform badly: $A - tau I$ is singular because $A$ has an
  eigenvalue at $+1$, so #ref(<eq:cayley>) has no inverse to use.
- A multiplier of modulus exactly $1$ is possible, and its smallest instance is a $2 times 2$ Jordan
  block $J = mat(lambda, 1; 0, lambda)$ with $abs(lambda) = 1$.
- Every step of #ref(<eq:sda>) must invert $I + G_k Q_k$, and that matrix can become singular or
  badly conditioned along the way.
- The signs of $Q$ and $G$ are hypotheses too: with an indefinite $Q$ there are problems with no
  stabilizing solution at all.

// ============================== 7. SOURCES ================================

= Sources and further reading

No external sources have been consulted yet, and this note makes no claim about prior work,
attribution, or the history of any method. Every quantity stated above is either an arithmetic
consequence of #ref(<eq:plant>) or a float64 run of #ref(<eq:sda>), reproduced by
#emph[scripts/verify_sda_are.py]; the sidecar #emph[sda-algebraic-riccati-demo.html] sweeps the
shift. The expected answers to the six questions, and the reading that would ground them, are kept
in #emph[summary.md] rather than in the document.

// Unconsulted suggestions:
//
// - F. Poloni, *Iterative and doubling algorithms for Riccati-type matrix equations: a comparative
//   introduction*, GAMM-Mitteilungen 43 (2020), arXiv:2005.08903.
// - E. K.-W. Chu, H.-Y. Fan and W.-W. Lin, *A structure-preserving doubling algorithm for
//   continuous-time algebraic Riccati equations*, Linear Algebra Appl. 396 (2005).
// - W.-W. Lin and S.-F. Xu, *Convergence analysis of structure-preserving doubling algorithms for
//   Riccati-type matrix equations*, SIAM J. Matrix Anal. Appl. 28(1) (2006).
// - C.-Y. Chiang et al., *Convergence analysis of the doubling algorithm ... in the critical case*,
//   SIAM J. Matrix Anal. Appl. 31(2) (2009).
