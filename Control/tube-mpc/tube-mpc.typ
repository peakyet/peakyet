// tube-mpc.typ -- a teach-an-engineer question map filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ. One deep question per
// section; the expected insights live in summary.md, never here.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

#show: note-ilm.with(
  title: [Tube Model Predictive Control],
  authors: "Qwen3.8-Flash-Next",
  abstract: [
    A nominal MPC plan is computed for the disturbance-free model, yet the plant is
    disturbed at every step. This note asks six questions about turning such a plan into a
    guarantee: why a nominal plan says nothing about the real trajectory, what object keeps
    the deviation from drifting, how that object is folded into the constraints, why
    feasibility survives from one step to the next, what sets the size of the resulting
    tube and what a larger tube costs, and what changes when the tube shape is chosen
    online. The running example is a discrete-time double integrator with a bounded additive
    disturbance.
  ],
)

// ============================== 1. QUESTION ===============================

= Why does a plan that ignores the disturbance fail? <s1>

#question[The controller can measure $x_k$ and knows the bound on $w_k$, so it can run MPC on
  the nominal model. Predict whether satisfying the state and input constraints along the
  nominal plan guarantees that the real trajectory also satisfies them. What must be bounded
  for the guarantee to hold, and does the disturbance bound alone bound it?]

*Running example.* A discrete-time double integrator with a bounded additive disturbance,

$ x_(k+1) = A x_k + B u_k + w_k, quad A = mat(1, 1; 0, 1), quad B = mat(0.5; 1), quad w_k in cal(W), $ <eq:plant>

with state $x_k = vec(p_k, v_k) in bb(R)^2$, input $u_k in bb(R)$, and disturbance set
$cal(W) = { w : norm(w)_infinity <= 0.1 }$. The state and input constraints are

$ cal(X) = { x : norm(x)_infinity <= 5 }, quad cal(U) = { u : abs(u) <= 1 }. $ <eq:constraints>

*Facts to reason with.*
- The nominal model MPC plans on is $z_(k+1) = A z_k + B v_k$, and the plan starts from $z_0 = x_0$.
- $A$ has a repeated eigenvalue at $1$: it is not Schur, and $A^i$ does not decay as $i$ grows.
- $w_k$ satisfies the bound in #ref(<eq:plant>) at every step; nothing else about it is known.
- The nominal plan $(z_0, v_0, z_1, v_1, ...)$ satisfies $z_i in cal(X)$ and $v_i in cal(U)$.

// =============================== 2. NEED ==================================

= What keeps the deviation from drifting? <s2>

#question[Feed the controller a correction proportional to the measured deviation: fix a gain
  $K$ and apply $u_k = v_k + K(x_k - z_k)$. The deviation then obeys its own recursion. What
  condition must a bounded set $cal(Z)$ satisfy so that $e_k in cal(Z)$ implies
  $e_(k+1) in cal(Z)$ for every admissible $w_k$? And why does $A + B K$ being Schur not, by
  itself, keep $e_k$ bounded as $k$ grows?]

*Setup.* Let $e_k = x_k - z_k$ and choose $K = mat(-0.5, -1.2)$, so that $A + B K$ is Schur.
The control law $u_k = v_k + K e_k$ turns the deviation into

$ e_(k+1) = (A + B K) e_k + w_k, quad e_0 = 0. $ <eq:error>

*Facts to reason with.*
- $cal(W)$ is compact, convex, and contains the origin.
- For sets $cal(P)$ and $cal(Q)$, write $cal(P) ⊕ cal(Q) = { p + q : p in cal(P), q in cal(Q) }$.
- $A + B K$ is Schur: every eigenvalue of $A + B K$ lies strictly inside the unit disk.
- The disturbance acts at every step, not just once.

#figure(
  caption: [A candidate deviation set $cal(Z)$ (dashed) and, inside it, the image
    $(A + B K) cal(Z)$ together with the disturbance set $cal(W)$. Inspect what has to be
    contained in what for the deviation to still lie in $cal(Z)$ one step later.],
  box(width: 100%, height: 4.4cm)[
    #let x0 = 0.8cm
    #let yT = 0.3cm
    #place(top + left, dx: x0, dy: yT)[
      #rect(width: 5.6cm, height: 3.4cm, stroke: (paint: gray, thickness: 1pt, dash: "dashed"))
    ]
    #place(top + left, dx: x0 + 1.0cm, dy: yT + 0.8cm)[
      #rect(width: 2.6cm, height: 1.8cm, stroke: 1pt + navy, fill: navy.lighten(90%))
    ]
    #place(top + left, dx: x0 + 3.9cm, dy: yT + 2.1cm)[
      #rect(width: 0.9cm, height: 0.9cm, stroke: 1pt + teal, fill: teal.lighten(85%))
    ]
    #place(top + left, dx: x0 + 0.22cm, dy: yT + 0.14cm)[$cal(Z)$]
    #place(top + left, dx: x0 + 1.35cm, dy: yT + 1.55cm)[$(A + B K) cal(Z)$]
    #place(top + left, dx: x0 + 4.95cm, dy: yT + 2.35cm)[$cal(W)$]
  ],
)

// =============================== 3. IDEA ==================================

= How is the tube folded into the constraints? <s3>

#question[Once $x_k = z_k + e_k$ with $e_k in cal(Z)$, the state and input constraints must hold
  for the real trajectory, but the optimizer chooses only the nominal $z_k$ and $v_k$. What must
  $z_k$ and $v_k$ satisfy so that $x_k in cal(X)$ and $u_k in cal(U)$ hold for *every*
  $e_k in cal(Z)$? And why can a single scalar margin on $cal(X)$ and $cal(U)$ not replace the
  same $cal(Z)$ everywhere?]

*Setup.* The tube is the family of sets $z_k ⊕ cal(Z)$ swept along the nominal plan, so the real
state satisfies $x_k in z_k ⊕ cal(Z)$. The applied input is $u_k = v_k + K e_k$ with
$e_k in cal(Z)$.

*Facts to reason with.*
- $cal(Z)$ is a bounded set containing the origin; for the running example it is a polytope,
  not a disk, so its image $K cal(Z) = { K e : e in cal(Z) }$ is an interval whose width is set by
  the corners of $cal(Z)$.
- $cal(X)$ and $cal(U)$ are the sets in #ref(<eq:constraints>).
- The optimizer chooses $z_k$ and $v_k$; $e_k$ is whatever the disturbance produces.
- The condition on $z_k$ alone must hold simultaneously for all $e_k in cal(Z)$.

#figure(
  caption: [A one-dimensional slice of the running example along $p$: the tube of half-width
    $zeta$ around each nominal point, the state-constraint boundary, and the tightened
    boundary. Inspect which set the nominal points must stay inside.],
  box(width: 100%, height: 4.6cm)[
    #let x0 = 0.9cm
    #let yb = 2.7cm
    #let sc = 0.92cm
    #let px(t) = x0 + (t + 6.0) * sc
    #place(top + left, dx: 0cm, dy: yb)[
      #line(start: (px(-6), 0pt), end: (px(6.4), 0pt), stroke: 0.8pt + gray)
    ]
    #place(top + left, dx: px(6.5), dy: yb - 0.24cm)[$p$]
    #place(top + left, dx: 0cm, dy: yb)[
      #line(start: (px(-5), -1.1cm), end: (px(-5), 1.1cm), stroke: 1pt + gray)
      #line(start: (px(5), -1.1cm), end: (px(5), 1.1cm), stroke: 1pt + gray)
    ]
    #place(top + left, dx: px(-5) + 0.08cm, dy: yb + 0.9cm)[$cal(X)$]
    #place(top + left, dx: px(5) + 0.08cm, dy: yb + 0.9cm)[$cal(X)$]
    #place(top + left, dx: 0cm, dy: yb)[
      #line(start: (px(-3.5), -0.9cm), end: (px(-3.5), 0.9cm), stroke: 1pt + navy)
      #line(start: (px(3.5), -0.9cm), end: (px(3.5), 0.9cm), stroke: 1pt + navy)
    ]
    #place(top + left, dx: px(-3.5) + 0.08cm, dy: yb + 0.72cm)[tightened]
    #place(top + left, dx: px(3.5) - 1.55cm, dy: yb + 0.72cm)[tightened]
    #for z in (-2.0, -0.9, 0.2, 2.0) {
      place(top + left, dx: px(z) - 1.5 * sc, dy: yb - 0.28cm)[
        #rect(width: 3.0 * sc, height: 0.56cm, fill: navy.lighten(88%))
      ]
    }
    #for z in (-2.0, -0.9, 0.2, 2.0) {
      place(top + left, dx: px(z) - 0.07cm, dy: yb - 0.07cm)[
        #circle(radius: 0.07cm, fill: navy)
      ]
    }
    #place(top + left, dx: 0cm, dy: yb - 0.95cm)[
      #line(start: (px(2.0), 0pt), end: (px(3.5), 0pt), stroke: 0.7pt + gray)
      #line(start: (px(2.0), -0.1cm), end: (px(2.0), 0.1cm), stroke: 0.7pt + gray)
      #line(start: (px(3.5), -0.1cm), end: (px(3.5), 0.1cm), stroke: 0.7pt + gray)
    ]
    #place(top + left, dx: px(2.75) - 0.12cm, dy: yb - 1.42cm)[$zeta$]
  ],
)

// =============================== 4. WHY ===================================

= Why does feasibility survive the disturbance? <s4>

#question[At each step the controller solves the nominal problem on the tightened constraints
  and applies the first input plus the correction. Take the plan that was feasible at time $k$
  and shift it forward by one step. Which shifted sequence is a candidate at time $k+1$, and
  what must the terminal set $cal(X)_f$ satisfy for that candidate to be feasible? Why does the
  disturbance not break the argument?]

*Setup.* The nominal problem over horizon $N$ uses the tightened constraints
$z_i in cal(X)_"tight"$ and $v_i in cal(U)_"tight"$, and the terminal constraint
$z_N in cal(X)_f$. At time $k$ it returns $(z_(0|k), v_(0|k), ..., z_(N|k))$, and the controller
applies $u_k = v_(0|k) + K(x_k - z_(0|k))$.

*Facts to reason with.*
- The nominal successor of $z_(0|k)$ is $z_(1|k) = A z_(0|k) + B v_(0|k)$.
- The error satisfies $e_1 = x_1 - z_(1|k) = (A + B K) e_0 + w_0$, with $e_0 in cal(Z)$.
- A linear terminal control law $u = K_f z$ is available for extending a plan past step $N$.
- The shifted plan already supplies $N$ nominal points; only the point after the last one needs
  a tail.

// ============================== 5. METHOD =================================

= What sets the size of the tube, and what does a larger tube cost? <s5>

#question[The gain $K$ and the set $cal(Z)$ are fixed before any optimization runs. How does the
  choice of $K$ change the size of $cal(Z)$, and which two quantities move in opposite
  directions as the tube grows? Why is it not enough to simply take the smallest set that
  satisfies the condition of the previous question, and what is paid for replacing it by a
  simpler shape?]

*Setup.* Keep the running example. The tube $cal(Z)$ satisfies
$(A + B K) cal(Z) ⊕ cal(W) subset.eq cal(Z)$, and the tightened constraints are what the
optimizer sees.

*Facts to reason with.*
- $K$ enters both the closed-loop matrix $A + B K$ and the input tightening through $K cal(Z)$.
- For any Schur $A + B K$ and bounded $cal(W)$ there is a smallest closed set satisfying the
  condition, and it is generally not a disk.
- A polytope with few facets, or an ellipsoid, can be used as an outer approximation of that
  set.
- $cal(X)_"tight"$ shrinks as $cal(Z)$ grows, and $cal(U)_"tight"$ shrinks as $K cal(Z)$ grows.

#figure(
  caption: [The same disturbance set $cal(W)$ handled with two ancillary gains $K_1$ and $K_2$.
    Inspect how the width of each tube and the range of the ancillary control $K e$ change
    together.],
  box(width: 100%, height: 4.0cm)[
    #let x0 = 1.0cm
    #place(top + left, dx: x0, dy: 0.7cm)[
      #rect(width: 8.0cm, height: 1.3cm, fill: navy.lighten(88%), stroke: 0.8pt + navy)
    ]
    #place(top + left, dx: x0, dy: 1.35cm)[
      #line(start: (0pt, 0pt), end: (8.0cm, 0pt), stroke: (paint: navy, thickness: 1pt, dash: "dashed"))
    ]
    #place(top + left, dx: x0 + 8.25cm, dy: 1.12cm)[$K_1$]
    #place(top + left, dx: x0, dy: 2.8cm)[
      #rect(width: 8.0cm, height: 0.55cm, fill: teal.lighten(85%), stroke: 0.8pt + teal)
    ]
    #place(top + left, dx: x0, dy: 3.075cm)[
      #line(start: (0pt, 0pt), end: (8.0cm, 0pt), stroke: (paint: teal, thickness: 1pt, dash: "dashed"))
    ]
    #place(top + left, dx: x0 + 8.25cm, dy: 2.85cm)[$K_2$]
  ],
)

// ============================== 6. LIMITS =================================

= What changes when the tube shape is chosen online? <s6>

#question[So far $K$ and $cal(Z)$ are fixed offline and only the nominal plan is optimized. A
  less conservative design lets the tube itself vary, for instance $x_k in z_k ⊕ alpha_k cal(Z)$
  with a fixed shape $cal(Z)$ and scalars $alpha_k >= 0$ chosen online. What must be added to the
  optimization to keep the invariance condition true at every step, and what makes the more
  general choice of a free set $cal(Z)_k$ hard to keep convex?]

*Setup.* Let the tube at step $k$ be $z_k ⊕ alpha_k cal(Z)$ with $alpha_k >= 0$ chosen online,
and apply the tightening of the previous question with $alpha_k cal(Z)$ in place of $cal(Z)$. The
invariance requirement must hold along the horizon.

*Facts to reason with.*
- For a compact set $cal(S)$, its support function is $h_(cal(S))(d) = max_(s in cal(S)) d^T s$.
- $cal(P) ⊕ cal(Q)$ has $h_(cal(P) ⊕ cal(Q))(d) = h_(cal(P))(d) + h_(cal(Q))(d)$, and
  $cal(P) subset.eq cal(Q)$ exactly when $h_(cal(P))(d) <= h_(cal(Q))(d)$ for every direction $d$.
- A common design keeps the shape $cal(Z)$ fixed and scales it, so the tube is determined by the
  scalars $alpha_k$.
- In the general design each $cal(Z)_k$ is itself a decision variable.

// ============================== 7. SOURCES ================================

= Sources and further reading

No external sources have been consulted yet; this note makes no external claims.
