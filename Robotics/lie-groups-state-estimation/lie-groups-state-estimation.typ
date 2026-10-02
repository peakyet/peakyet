// lie-groups-state-estimation.typ -- a teach-an-engineer question map, filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ. One deep question per section;
// the expected insights live in summary.md, never here.
//
// The note follows the selection of material in Sola, Deray & Atchuthan, "A micro Lie theory
// for state estimation in robotics" (arXiv:1812.01537), which is named again in the Sources
// section. It is a question map, not an answer key.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

#show: note-ilm.with(
  title: [Lie Groups for State Estimation in Robotics],
  authors: "deepseek-v4.1-flash",
  abstract: [
    A robot's pose is not a list of numbers: orientations live on a curved set, so averaging,
    subtracting, and nudging them with ordinary vector arithmetic leave that set. This note asks
    nine questions that rebuild state estimation on it. What does the constraint on a rotation do
    to the geometry of the headings? What object captures the directions a rotation can move in?
    How does the exponential map turn a tangent vector back into a rotation, and how do the plus
    and minus operators replace addition and subtraction? When the same increment is written in two
    frames, what map relates them? What replaces the derivative and the chain rule on a curved
    state, and where does a covariance live? How does an ordinary Kalman filter change once its
    state is a pose? And what changes when the state carries a second, unrelated block? All nine
    are posed against one wheeled robot localizing in a plane, so an answer can be checked against
    the robot rather than against this page.
  ],
)

// ============================== 1. QUESTION ===============================

= Why a heading is not a number <s1>

#question[The estimator needs three ordinary vector operations on the robot's heading: average two
  estimates, subtract one from another to form a correction, and add a small step to move it. Which
  of these operations fails to land on a heading, and what property of the set of rotations -- the
  one visible in the constraint $R^T R = I$ -- is responsible? Predict where the average of two
  nearby headings ends up.]

*The running example.* A wheeled robot drives in a plane and estimates its pose

$ M = mat(R, t; 0, 1) in "SE"(2), quad R in "SO"(2), quad t in bb(R)^2, quad R^T R = I, quad
  det R = 1, $ <eq:pose>

with orientation $R$ and position $t$. It measures range and bearing to a few beacons whose
positions are known, and its estimator keeps a mean and a covariance for the pose. Orientation is
the part that is not a vector: in the plane $R = mat(cos theta, -sin theta; sin theta, cos theta)$
is fixed by one angle $theta$, and in three dimensions by a rotation matrix with the same
constraint. Every section below returns to this robot.

*Facts to reason with.*
- $R^T R = I$ says exactly that $R$ is orthogonal, and $det R = 1$ selects the rotations from the
  reflections.
- Products and inverses of rotations are rotations, and the identity is a rotation, so the set is
  closed under the operations an estimator composes.
- Headings are periodic: $theta$ and $theta + 2 pi$ name the same rotation, so a heading has no
  unique numerical value.
- The standard filter stores an estimate as a vector, adds a correction vector to it, and averages
  measurements with a weighted sum.
- The set of planar headings is the unit circle; the set of 3D rotations cannot be drawn, but the
  same reasoning applies to it.

#figure(
  caption: [Two heading estimates on the unit circle, joined by the straight chord. Inspect where
    the chord's midpoint falls, and where a weighted sum of the two headings falls, relative to the
    circle.],
  box(width: 100%, height: 4.3cm)[
    #let cx = 3.7cm
    #let cy = 2.15cm
    #let r = 1.5cm
    #let pt(deg) = (cx + r * calc.cos(deg * 1deg), cy - r * calc.sin(deg * 1deg))
    #place(top + left, dx: cx - r, dy: cy - r)[#circle(radius: r, stroke: 1pt + navy)]
    #place(top + left)[#line(start: pt(25), end: pt(75), stroke: 0.9pt + gray)]
    #place(top + left, dx: pt(25).at(0) - 2.6pt, dy: pt(25).at(1) - 2.6pt)[#circle(radius: 2.6pt, fill: navy)]
    #place(top + left, dx: pt(75).at(0) - 2.6pt, dy: pt(75).at(1) - 2.6pt)[#circle(radius: 2.6pt, fill: teal)]
    #place(top + left, dx: pt(25).at(0) + 0.12cm, dy: pt(25).at(1) - 0.15cm)[$theta_1$]
    #place(top + left, dx: pt(75).at(0) - 0.65cm, dy: pt(75).at(1) - 0.35cm)[$theta_2$]
    #place(top + left, dx: cx - 0.4em, dy: cy + 0.35cm)[$S^1$]
  ],
)

// =============================== 2. NEED ==================================

= The directions a rotation can move in <s2>

#question[The constraint $R^T R = I$ has to hold at every instant. Differentiating it along a path
  $R(t)$ with $R(0) = I$ forces the velocity into a particular family of matrices. Why is that
  family a genuine vector space -- closed under sums and scalar multiples -- when the rotations
  themselves are not, and what does one element of it describe about the robot?]

*Setup.* Let $R(t)$ be a smooth path of rotations with $R(0) = I$ and $dot(R) = dif R \/ dif t$.
Differentiating $R^T R = I$ and setting $t = 0$ leaves $dot(R) + dot(R)^T = 0$, so the velocity at
the identity is a skew-symmetric matrix. The set of such matrices is the Lie algebra of the group,
written $frak(m)$, and it is the tangent space $T_(cal(E)) cal(M)$ at the identity. In the plane
$frak(m)$ is one-dimensional; in three dimensions it is the space of skew-symmetric $3 times 3$
matrices, in one-to-one correspondence with vectors $omega in bb(R)^3$:

$ [omega]_times = mat(0, -omega_z, omega_y; omega_z, 0, -omega_x; -omega_y, omega_x, 0), quad
  omega = ([omega]_times)^or, $ <eq:hat>

the map $omega |-> [omega]_times$ being the *hat* operator and $[omega]_times |-> omega$ the *vee*
operator.

*Facts to reason with.*
- A skew-symmetric $3 times 3$ matrix has three independent entries, which is why three numbers
  describe it; the planar case has one.
- The robot's angular velocity is the element of $frak(m)$ that describes its instantaneous
  turning.
- The construction works at any rotation $X$, not just the identity: $T_X cal(M)$ is the tangent
  space at $X$.

// =============================== 3. IDEA ==================================

= Wrapping a tangent vector back onto the group <s3>

#question[For a constant angular velocity the path obeys $dot(R) = R [omega]_times$ with
  $R(0) = I$, and its solution is $R(t) = exp(t [omega]_times)$, the exponential map. Why does
  $exp$ land on the group for every $t$ -- what does it do that adding a small matrix $delta R$ did
  not -- and predict which rotation $exp$ returns for a tangent vector of length $pi$.]

*Setup.* The exponential map takes an element of $frak(m)$ to the group,
$exp : frak(m) -> cal(M)$, and $log$ is its inverse. In the plane
$exp(theta J) = mat(cos theta, -sin theta; sin theta, cos theta)$ with $J = mat(0, -1; 1, 0)$. In
three dimensions $exp([omega]_times)$ is defined by the power series

$ exp([omega]_times) = sum_(k = 0)^oo frac(1, k!) [omega]_times^k = I + [omega]_times + 1/2
  [omega]_times^2 + 1/6 [omega]_times^3 + dots.c, $ <eq:exp>

whose closed form is Rodrigues' formula. The capitalized $upright("Exp") : bb(R)^m -> cal(M)$
composes the hat with $exp$ and sends a Cartesian vector $tau$ straight to the group; $upright("Log")$
is its inverse.

*Facts to reason with.*
- $exp(0) = I$, $exp(-v) = exp(v)^(-1)$, and $exp((s + t) v) = exp(s v) exp(t v)$.
- On #ref(<eq:pose>) the robot's heading after turning at rate $omega$ for a time $dif t$ is
  $R exp(omega dif t J)$.
- Only a few powers of $[omega]_times$ are nonzero, so the series in #ref(<eq:exp>) collapses to an
  ordinary $3 times 3$ matrix.
- The closed form of $log$ divides by $sin theta$, and the Jacobians divide by powers of $theta$,
  so the arithmetic needs care near a full turn.

#figure(
  caption: [The tangent line at the identity of the circle, a tangent vector on it, and the point
    the exponential map sends that vector to. Inspect which point of the circle the far end
    reaches, and what must be true of that point for the result to be a rotation.],
  box(width: 100%, height: 4.3cm)[
    #let cx = 3.2cm
    #let cy = 2.15cm
    #let r = 1.5cm
    #let idp = (cx + r, cy)
    #let tip = (cx + r, cy - 1.5cm)
    #let th = 1.0
    #let wp = (cx + r * calc.cos(th * 1rad), cy - r * calc.sin(th * 1rad))
    #place(top + left, dx: cx - r, dy: cy - r)[#circle(radius: r, stroke: 1pt + navy)]
    #place(top + left)[#line(start: (cx + r, cy - 2.0cm), end: (cx + r, cy + 2.0cm), stroke: 0.8pt + gray)]
    #place(top + left)[#line(start: idp, end: tip, stroke: 1.4pt + teal)]
    #place(top + left)[
      #curve(
        stroke: (thickness: 0.9pt, dash: "dashed", paint: gray),
        curve.move(tip),
        curve.cubic((cx + r + 0.55cm, cy - 1.5cm), (wp.at(0) + 0.55cm, wp.at(1) - 0.25cm), wp),
      )
    ]
    #place(top + left, dx: cx + r - 2.6pt, dy: cy - 2.6pt)[#circle(radius: 2.6pt, fill: navy)]
    #place(top + left, dx: wp.at(0) - 2.6pt, dy: wp.at(1) - 2.6pt)[#circle(radius: 2.6pt, fill: teal)]
    #place(top + left, dx: cx + r + 0.12cm, dy: cy - 1.0cm)[$tau$]
    #place(top + left, dx: wp.at(0) + 0.08cm, dy: wp.at(1) - 0.45cm)[$exp(tau)$]
    #place(top + left, dx: cx + 0.35cm, dy: cy - 0.15cm)[$cal(E)$]
  ],
)

// =============================== 4. WHY ===================================

= Adding and subtracting on the robot's pose <s4>

#question[Given $exp$ and $log$, define $X plus.o tau = X compose upright("Exp")(tau)$ and
  $tau = Y minus.o X = upright("Log")(X^(-1) compose Y)$. Why do these two operations play the roles
  of $+$ and $-$ for the estimator, and why must a correction and a residual both be expressed in
  the tangent space rather than as differences of group elements?]

*Setup.* The right-plus and right-minus operators combine a group element with a vector in its
tangent space. The vector $tau in bb(R)^m$ is the increment and $X$ is the base point. Reversing the
order gives the left versions, $tau plus.o X$ and $X minus.o tau$, which live in the tangent space
at the identity.

*Facts to reason with.*
- $X plus.o 0 = X$, and $X plus.o tau$ is a group element for every $tau$.
- The estimator's correction step is $hat(X) <- hat(X) plus.o delta X$, and its residual is
  $z = y minus.o hat(y)$; both $delta X$ and $z$ are ordinary vectors.
- The order of the operands matters because the group is not commutative; the convention here is
  right-plus and right-minus throughout.
- $Y minus.o X$ and $X^(-1) compose Y$ carry the same information, one as a vector and one as a
  group element.

// ============================== 5. METHOD =================================

= The same increment in two frames <s5>

#question[The same small motion can be written as a local increment at $X$ or as an increment at the
  identity: $X plus.o tau = tau' plus.o X$ for some $tau'$. The map between $tau$ and $tau'$ is
  linear and is called the adjoint. Why must such a map exist -- what makes the two increments
  differ -- and why does an estimator need it when it composes motions or moves a covariance
  between the body frame and the world frame?]

*Setup.* For a group element $X$ the adjoint is the map $upright("Ad")_X : bb(R)^m -> bb(R)^m$
defined by $tau' = upright("Ad")_X tau$, and it can be written as a matrix
$bold(upright("Ad"))_X$. It is the linearization of the conjugation $Y |-> X compose Y compose
X^(-1)$ at the identity.

*Facts to reason with.*
- $upright("Ad")_X$ is linear in $tau$, and
  $upright("Ad")_(X Y) = upright("Ad")_X upright("Ad")_Y$.
- For a planar rotation the adjoint is the identity; for a 3D rotation it rotates the angular
  velocity vector; for a pose it mixes rotation and translation.
- A local perturbation of $X$ and the global perturbation that produces the same $Y$ are related by
  the adjoint, and so are their covariances.
- Composing two motions expressed in different frames requires moving one increment into the frame
  of the other.

// ============================ 6. JACOBIANS ================================

= Derivatives that obey a chain rule <s6>

#question[For a function $f : cal(M) -> cal(N)$ between manifolds, the ordinary derivative has no
  meaning because $f(X + h) - f(X)$ does not. Using $plus.o$ and $minus.o$, the right Jacobian is
  defined by a limit. Why is the result an ordinary matrix, what does it map between, and why does
  it satisfy a chain rule that lets every Jacobian be assembled from a few elementary blocks?]

*Setup.* The right Jacobian of $f$ at $X$ is

$ (dif f(X)) \/ (dif X) = lim_(tau -> 0) frac(f(X plus.o tau) minus.o f(X), tau) in
  bb(R)^(n times m), $ <eq:jac>

and it maps a tangent vector at $X$ to a tangent vector at $f(X)$. The elementary blocks are the
Jacobians of $exp$, of $log$, of inversion, of composition, and of the group action; the right
Jacobian of $exp$ is written $J_r(tau)$. The chain rule composes them.

*Facts to reason with.*
- Perturbations compose through the Jacobian: $f(X plus.o tau) approx f(X) plus.o J tau$ for small
  $tau$.
- The right Jacobian of $exp$ has a closed form built from $sin theta$, $cos theta$, and powers of
  $theta$.
- The chain rule holds: the Jacobian of a composition is the product of the Jacobians of its parts.
- The blocks are generic: they hold for every group in the family of #ref(<eq:pose>), not one at a
  time.

// =========================== 7. UNCERTAINTY ===============================

= Where the covariance lives <s7>

#question[A Gaussian needs a mean and a covariance, but the naive
  $Sigma = bb(E)[(X - overline(X))(X - overline(X))^T]$ is meaningless because $X - overline(X)$ is
  not defined. Where must the mean and the covariance live for the distribution to be well defined,
  and how does a nonlinear map propagate the covariance?]

*Setup.* With $plus.o$ and $minus.o$ the perturbation of $X$ is a vector,
$X = overline(X) plus.o tau$ with $tau ~ cal(N)(0, Sigma)$ and $Sigma in bb(R)^(m times m)$. The
covariance can be expressed in the tangent space at the mean (local) or at the identity (global);
the two are related by the adjoint.

*Facts to reason with.*
- $m$ is the number of degrees of freedom of the state, so $Sigma$ has the size of a well-defined
  Gaussian even though the state does not.
- For a function $f$, the covariance propagates as $Sigma_Y approx J Sigma_X J^T$ with $J$ the right
  Jacobian of #ref(<eq:jac>).
- The ellipse that $Sigma$ describes sits in the tangent plane and wraps onto the manifold.
- On #ref(<eq:pose>) the pose covariance is $3 times 3$ in the plane.

// ============================ 8. ESTIMATOR ================================

= The estimator, written on the manifold <s8>

#question[Take the standard error-state Kalman filter. Its prediction and correction steps use
  ordinary $+$ and $-$ and a Kalman gain. Replacing those by $plus.o$ and $minus.o$, and computing
  the Jacobians with the manifold blocks, what do the two steps become -- and why does the
  innovation stay an ordinary vector even though the state does not?]

*Setup.* The state is $X in "SE"(2)$ with error state $delta X in bb(R)^3$ and covariance $P$. The
prediction applies the control $u$ as $X <- X plus.o u$; the correction forms the innovation
$z = y minus.o hat(y)$, the gain $K = P H^T (H P H^T + N)^(-1)$, and updates
$X <- X plus.o (K z)$.

*Facts to reason with.*
- The gain's formula is unchanged from the ordinary filter; only $H$ is now a manifold Jacobian.
- A landmark-based smoother writes every residual as a $minus.o$ between a measurement and a
  prediction, and linearizes each with the blocks of #ref(<eq:jac>).
- The same recipe serves a pose, a rotation, or a direction: the group changes, the operators do
  not.

// ============================ 9. COMPOSITE ================================

= When the state is more than one group <s9>

#question[The estimator now also estimates an unknown sensor bias, so its state is a pose together
  with a vector: $cal(X) = (X, c)$ with $X in "SE"(2)$ and $c in bb(R)^2$. What must $plus.o$ and
  $minus.o$ do to such a state, what does the Jacobian of #ref(<eq:jac>) become, and why does the
  estimator still work when the two blocks have nothing to do with each other?]

*Setup.* A composite manifold is a tuple of independent manifolds,
$cal(M) = lr((cal(M)_1, dots, cal(M)_M))$, with the identity, inverse, composition, and
$plus.o$/$minus.o$ acting block by block. On #ref(<eq:pose>) the state $cal(X) = (X, c)$ pairs the
pose with a bias; the measurement depends on both, so its Jacobian gains a column for the bias.

*Facts to reason with.*
- The blocks do not interact: composing $(X_1, c_1)$ with $(X_2, c_2)$ composes each coordinate on
  its own.
- The exponential of a composite is the tuple of the blocks' exponentials.
- A measurement residual is still a single $minus.o$ on the composite state.
- The self-calibrating smoother of the paper estimates the bias and the trajectory together.

// ============================== 10. SOURCES ===============================

= Sources and further reading

This question map follows the selection of material in Joan Solà, Jeremie Deray, and Dinesh
Atchuthan, *A micro Lie theory for state estimation in robotics*,
#link("https://arxiv.org/abs/1812.01537")[arXiv:1812.01537], which the reader may consult for the
full derivations and the reference tables of the common groups. No other external source has been
consulted, and the note itself makes no claim about prior work, attribution, or the history of any
method. The expected answers to the nine questions are kept in #emph[summary.md] rather than in the
document.
