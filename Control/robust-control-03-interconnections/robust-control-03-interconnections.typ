// Standalone; compile from repository root with typst compile --root .
#set document(title: "Interconnections: signals before fractions", author: "Amp")
#set page(paper: "a4", margin: (x: 24mm, y: 21mm),
  header: text(size: 9pt, fill: rgb("#5b6470"))[Robust control · Chapter 3],
  footer: context align(right, text(size: 9pt, counter(page).display("1"))))
#set text(font: "Libertinus Serif", size: 10.5pt)
#set par(justify: true, leading: 0.55em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#let navy = rgb("#1f4e79")
#let teal = rgb("#0f766e")
#let gray = rgb("#5b6470")
#show heading: set text(fill: navy)
#let hook(body) = block(width: 100%, inset: 10pt, fill: rgb("#edf5f5"),
  stroke: (left: 2pt + teal), body)
#let check = hook

#text(size: 23pt, weight: "bold", fill: navy)[Interconnections]

#text(size: 15pt)[Signals first, fractions second]

A feedback diagram is a set of simultaneous equations, not a recipe for multiplying
transfer functions around a circle. First decide who owns each signal. Then ask whether
the equations define a causal system. Only then ask whether its stored energy decays.

#hook[The route: cut the controller out → assign ports → solve the instantaneous loop
  → eliminate signals → test hidden dynamics → ask whether stabilization is possible.
  The final three sections solve all three book exercises, including a decentralized design.]

#let RH = $cal(R H)_infinity$
#let lft = $star.op$

// ---------- drawing helpers for the native block diagrams ----------
#let W = 0.8pt + gray
#let seg(a, b) = place(top + left, line(start: a, end: b, stroke: W))
#let head(p, dir) = {
  let (x, y) = p
  let h = 0.17cm
  let w = 0.07cm
  let pts = if dir == "r" { ((x, y), (x - h, y - w), (x - h, y + w)) } else if dir == "l" {
    ((x, y), (x + h, y - w), (x + h, y + w))
  } else if dir == "d" { ((x, y), (x - w, y - h), (x + w, y - h)) } else {
    ((x, y), (x - w, y + h), (x + w, y + h))
  }
  place(top + left, polygon(fill: gray, stroke: none, ..pts))
}
#let wire(..ps) = {
  let p = ps.pos()
  for i in range(p.len() - 1) { seg(p.at(i), p.at(i + 1)) }
}
#let arr(..ps) = {
  let p = ps.pos()
  wire(..p)
  let a = p.at(-2)
  let b = p.at(-1)
  let dir = if b.at(0) > a.at(0) { "r" } else if b.at(0) < a.at(0) { "l" } else if b.at(1) > a.at(1) { "d" } else { "u" }
  head(b, dir)
}
#let blk(x, y, w, h, body, col: navy) = place(top + left, dx: x, dy: y, box(
  width: w, height: h, stroke: 0.9pt + col, fill: col.lighten(90%), radius: 3pt,
  align(center + horizon, body),
))
#let sumj(x, y) = {
  let r = 0.17cm
  place(top + left, dx: x - r, dy: y - r, circle(radius: r, stroke: W, fill: white))
  seg((x - 0.1cm, y), (x + 0.1cm, y))
  seg((x, y - 0.1cm), (x, y + 0.1cm))
}
#let node(x, y) = place(top + left, dx: x - 0.05cm, dy: y - 0.05cm, circle(radius: 0.05cm, fill: gray))
#let lb(x, y, body) = place(top + left, dx: x, dy: y, text(size: 10pt, body))

#let exercise(name, body) = block(
  breakable: false,
  inset: (x: 10pt, y: 8pt),
  stroke: (left: 3pt + gray),
  fill: rgb("#f7f6f3"),
  width: 100%,
)[*#name* #body]

= Cut the controller out and assign ownership <s1>

The open-loop interconnection is everything left after removing the controller, not
necessarily a physical plant alone. It includes sensors, weights, summing junctions,
and fixed feedback paths. “Open” means open at the chosen controller ports; fixed
loops inside it must already be well posed. Chapter 3 of @schererTheoryRobustControl
organizes these potentially complicated equations around four signals:

#table(columns: (0.6fr, 3fr), inset: 6pt, stroke: 0.4pt + luma(180),
  [$w$], [External causes: references, disturbances, noise. Not selected by the controller.],
  [$u$], [Commands: the controller's outputs, treated as independent inputs while the loop is cut.],
  [$y$], [Available measurements: the controller's inputs, not every state or performance variable.],
  [$z$], [Performance variables: what the designer wants small; not automatically measured.])

This ownership matters: feeding back $z$ when only $y$ is available changes the problem.
Stacking several scalar signals makes a vector; scalar component blocks do not make
the overall interconnection SISO.

*The tracking loop as the running example* @schererTheoryRobustControl[pp. 46--48]. A
plant $G$ is controlled by $u = K y$ with $y = r - (G u + d) - n$, and the tracking error is
$e = (G u + d) - r$: output minus reference, unlike chapter 2's measured error.
Sort the signals by role: exogenous $w = (d, n, r)$, which the
controller cannot influence; the controlled output $z = e$, which defines success; the
control input $u$; the measurement $y$. With the controller removed, the loop is a plain
linear map

$ mat(e; y) = mat(I, 0, -I, G; -I, -I, I, -G) mat(d; n; r; u), $ <eq:track>

so $P_(11) = mat(I, 0, -I)$, $P_(12) = G$, $P_(21) = mat(-I, -I, I)$, $P_(22) = -G$.
Closing $u = K y$ and simplifying yields the familiar
$e = mat(S, -T, -S) mat(d; n; r)$ with $S = (I + G K)^(-1)$, $T = G K (I + G K)^(-1)$.
Every other block diagram in robust control is processed the same way.

#hook[The convention is *positive interconnection* $u=K y$. Ordinary negative tracking
  feedback is already encoded in $y=r-G u-d-n$, hence $P_(22)=-G$ and the familiar
  denominator is $I+G K$. Do not add another minus sign. Even here, checking only
  $S$ is not an internal-stability test without noncancellation assumptions.]

#pagebreak()
= Can the instantaneous equations be solved? <s2>

*The general framework* @schererTheoryRobustControl[pp. 48--50]. Any interconnection,
once the controller is cut out, reads

$ mat(z; y) = P mat(w; u) = mat(P_(11), P_(12); P_(21), P_(22)) mat(w; u), quad u = K y, $ <eq:P>

with a stabilizable and detectable realization

$ dot(x) = A x + B_1 w + B_2 u, quad z = C_1 x + D_(11) w + D_(12) u, quad y = C_2 x + D_(21) w + D_(22) u, $ <eq:Pss>

and a controller $dot(x)_K = A_K x_K + B_K u_K$, $y_K = C_K x_K + D_K u_K$, also
stabilizable and detectable. Even a loop of SISO blocks gives a MIMO $P$, because signals
are stacked.

These assumptions concern *all* inputs $(w,u)$ and outputs $(z,y)$. They allow extra
stable hidden states, but no unstable uncontrollable or unobservable states. Minimal
(controllable and observable) realizations suffice and simplify computation. Never
silently replace a physical realization by its minimal transfer realization when
checking physical internal stability: cancellation could discard the very mode at issue.

At a fixed instant the states are already known. Write $u_0=C_K x_K$ and
$y_0=C_2 x+D_(21)w$. The unknown instantaneous signals solve
$ u=u_0+D_K y, quad y=y_0+D_(22)u, $
$ mat(I,-D_K;-D_(22),I) mat(u;y)=mat(u_0;y_0). $
Unique solutions for all states and inputs require
$ M:=mat(I,-D_K;-D_(22),I) " nonsingular". $ <eq:wp>
Equivalently $I-D_(22)D_K$ is nonsingular (Schur complement). This is *algebraic
well-posedness*, not a statement about decay over time. For proper rational $P,K$ it
is equivalent to $I-P_(22)K$ having a proper rational inverse.

*Two contrasting checks.* If $y=w+2u$ and $u=y/2$, then $y=w+y$: no solution for
$w!=0$, infinitely many for $w=0$. This is not merely an unstable system; it fails to
define an ordinary causal system. If instead $dot(x)=x+u$, $y=x$, $u=0$, then
$D_(22)=0$ and the loop is perfectly well posed, yet $x(t)=exp(t)x(0)$ grows.
When $D_(22)=0$, every proper controller is well posed; stability remains a separate task.

= Eliminate signals, then name the lower LFT

Start with the signal equations, at zero initial state:
$ z=P_(11)w+P_(12)u, quad y=P_(21)w+P_(22)u, quad u=K y. $
Substitute the third into the second, solve, and substitute into the first:
$ (I-P_(22)K)y=P_(21)w, quad y=(I-P_(22)K)^(-1)P_(21)w, $
$ u=K(I-P_(22)K)^(-1)P_(21)w, $
$ z=(P_(11)+P_(12)K(I-P_(22)K)^(-1)P_(21))w. $
Only now introduce a name for this result:
$ P lft K := P_(11)+P_(12)K(I-P_(22)K)^(-1)P_(21). $ <eq:lft>
This is the *lower linear fractional transformation*, also written $F_l(P,K)$.
It is a compact name for elimination, not a new physical operation. For the tracking
equations it gives exactly $mat(S,-T,-S)$.

*An asymmetric port check.* Take scalar $w,z,u$ but a two-component measurement:
$z=w+2u$, $y=mat(3;5)w+mat(1;2)u$, $K=mat(1/10,1/5)$.
Then $u=1.3w+0.5u$, so $u=2.6w$, $z=6.2w$.
Here $P_(22)K$ is $2 times 2$, whereas $K P_(22)=0.5$ is scalar. Both inverse
forms give the same answer, using
$K(I-P_(22)K)^(-1)=(I-K P_(22))^(-1)K$.
One must preserve factor order: matrices cannot be commuted as in SISO arithmetic.
The upper LFT, used later for uncertainty, closes the other ports:
$Delta lft P=P_(22)+P_(21)Delta(I-P_(11)Delta)^(-1)P_(12)$.

= Stability is about the joint state, not one output

*Definition (internal stability)* @schererTheoryRobustControl[p. 51]. $K$ stabilizes $P$
if #ref(<eq:wp>) holds and

$ cal(A) := mat(A, 0; 0, A_K) + mat(B_2, 0; 0, B_K) mat(I, -D_K; -D_(22), I)^(-1) mat(0, C_K; C_2, 0) $ <eq:Acl>

is Hurwitz. $cal(A)$ is the state matrix of the closed loop in the joint state
$(x, x_K)$. Thus with $w=0$, *every initial plant and controller state decays
exponentially*. Transfer matrices instead describe zero-initial-state responses;
cancelling a pole there does not remove stored energy from the physical system.
Only $(A, B_2, C_2, D_(22))$ and the controller enter this matrix. For $D_(22) = 0$ it
reduces to $mat(A + B_2 D_K C_2, B_2 C_K; B_K C_2, A_K)$. The book's Example 3.4 applies
this to the tracking loop with $G = 200\/((10 s + 1)(0.05 s + 1)^2)$.

#figure(
  caption: [The closed loop $P lft K$ with test signals injected at both controller
    ports (after Scherer's Figure 22). Internal stability asks for a stable map from
    $(w, v_1, v_2)$ to $(z, u, v)$, not only from $w$ to $z$.],
  box(width: 100%, height: 5.4cm)[
    #blk(5.2cm, 0.3cm, 4.0cm, 2.2cm)[$P = mat(P_(11), P_(12); P_(21), P_(22))$]
    #blk(6.2cm, 3.7cm, 2.0cm, 1.0cm, col: teal)[$K$]
    // w in, z out
    #arr((12.6cm, 0.9cm), (9.2cm, 0.9cm))
    #lb(11.8cm, 0.35cm)[$w$]
    #arr((5.2cm, 0.9cm), (1.4cm, 0.9cm))
    #lb(1.5cm, 0.35cm)[$z$]
    // y out, down to sum with v2, into K
    #wire((5.2cm, 1.9cm), (3.0cm, 1.9cm))
    #arr((3.0cm, 1.9cm), (3.0cm, 4.03cm))
    #lb(4.0cm, 1.35cm)[$y$]
    #sumj(3.0cm, 4.2cm)
    #arr((1.0cm, 4.2cm), (2.83cm, 4.2cm))
    #lb(1.1cm, 3.65cm)[$v_2$]
    #arr((3.17cm, 4.2cm), (6.2cm, 4.2cm))
    #lb(4.3cm, 3.65cm)[$v = y + v_2$]
    // K out, sum with v1, up into P
    #arr((8.2cm, 4.2cm), (11.03cm, 4.2cm))
    #sumj(11.2cm, 4.2cm)
    #arr((11.2cm, 5.4cm), (11.2cm, 4.37cm))
    #lb(11.45cm, 4.75cm)[$v_1$]
    #wire((11.2cm, 4.03cm), (11.2cm, 1.9cm))
    #arr((11.2cm, 1.9cm), (9.2cm, 1.9cm))
    #lb(11.4cm, 2.75cm)[$u = K v + v_1$]
  ],
) <fig:loop>

= Why $w -> z$ is not enough: expose the internal maps <s3>

$P lft K$ stable does not imply $cal(A)$ Hurwitz: the closed-loop realization need
not be stabilizable or detectable, so an unstable mode can be hidden from the
channel $w -> z$. For a concrete asymmetric cancellation take
$dot(x)_1=x_1+w$, $dot(x)_2=x_2+2w$, $z=2x_1-x_2$.
The zero-state map $w->z$ is zero, but $x(0)=mat(1;0)$ gives $z(t)=2exp(t)$.
The two unstable paths cancel only for a particular input pattern. The full open-loop
realizations in the theorem below satisfy stabilizability/detectability; their
*closed-loop performance channel* need not. Exercise 3b gives an example satisfying
those open-loop assumptions.

Inject independent disturbances at the ports:
$ u=K v+v_1, quad v=y+v_2. $
These test signals are probes, not additional controller information. With
$S_y=(I-P_(22)K)^(-1)$ and $S_u=(I-K P_(22))^(-1)$, direct elimination gives
$ v=S_y P_(21)w+S_y P_(22)v_1+S_y v_2, $
$ u=K S_y P_(21)w+S_u v_1+K S_y v_2. $
The identity $I+K S_y P_(22)=S_u$ explains the direct $v_1->u$ term.
Finally use $z=P_(11)w+P_(12)u$. This derives, rather than guesses, the nine maps.

*Theorem 3.5 / Corollary 3.6* @schererTheoryRobustControl[pp. 55--57]. $K$ stabilizes $P$
iff $I - P_(22) K$ has a proper inverse and all nine blocks of

$ mat(z; u; v) = mat(
  P lft K, P_(12) (I - K P_(22))^(-1), P_(12) K (I - P_(22) K)^(-1);
  K (I - P_(22) K)^(-1) P_(21), (I - K P_(22))^(-1), K (I - P_(22) K)^(-1);
  (I - P_(22) K)^(-1) P_(21), (I - P_(22) K)^(-1) P_(22), (I - P_(22) K)^(-1)
) mat(w; v_1; v_2) $ <eq:nine>

are in #RH (proper, real-rational, with poles strictly in the left half-plane).
*Proof outline of the theorem:* the realization of the map
$(w, v_1, v_2) -> (z, u, v)$ has state matrix exactly $cal(A)$ of #ref(<eq:Acl>), and it
*is* stabilizable and detectable (Hautus test, using that both $P$ and $K$ are). For such
realizations, a stable transfer matrix forces a Hurwitz state matrix.

For the tracking loop the lower-right $2 times 2$ block is the familiar "gang of four"
$(I + K G)^(-1)$, $K (I + G K)^(-1)$, $-(I + G K)^(-1) G$, $(I + G K)^(-1)$.

= Generalized plants: when can $P$ be stabilized at all? <s4>

Not every $P$ admits a stabilizing $K$. In the book's Example 3.8,
$P = mat(1, 1\/s; 1, 1\/(s+1))$: the integrator sits in $P_(12)$ but not in $P_(22)$,
so feedback from $y$ never "sees" it, and one of $P_(12) (1 - K P_(22))^(-1)$ or
$P_(12) (1 - K P_(22))^(-1) K$ always keeps the pole at $0$
@schererTheoryRobustControl[p. 58].

*Definition.* $P$ is a *generalized plant* if at least one $K$ stabilizes it
@schererTheoryRobustControl[p. 59].

*Theorem 3.10 (state-space test).* With #ref(<eq:Pss>) stabilizable and detectable,
$P$ is a generalized plant iff $(A, B_2)$ is stabilizable and $(A, C_2)$ is detectable.
For the "if" part pick $F$, $L$ with $A + B_2 F$ and $A + L C_2$ Hurwitz; the observer-based
controller

$ dot(x)_K = (A + B_2 F + L C_2 + L D_(22) F) x_K - L y, quad u = F x_K $ <eq:obs>

is obtained by estimating $x$ from $y-D_(22)u$: choose
$dot(x)_K=A x_K+B_2 u-L(y-C_2 x_K-D_(22)u)$ and $u=F x_K$.
At $w=0$, put $e=x-x_K$. Direct subtraction gives
$ dot(x)=(A+B_2 F)x-B_2 F e, quad dot(e)=(A+L C_2)e. $
Thus $cal(A) tilde.equiv mat(A + B_2 F, -B_2 F; 0, A + L C_2)$.
The off-diagonal minus sign follows from $x_K=x-e$; only the two Hurwitz diagonal
blocks determine the eigenvalues. Since $D_K=0$, well-posedness is automatic.
For "only if": if $A x = lambda x$, $C_2 x = 0$, then
$cal(A) mat(x; 0) = lambda mat(x; 0)$, so $"Re" lambda < 0$; $(A, C_2)$ is detectable.

#check[The book leaves stabilizability of $(A, B_2)$ as a task. Prove it in the same way.]

Take a left eigenvector: $x^* A = lambda x^*$, $x^* B_2 = 0$, $x != 0$. In #ref(<eq:Acl>)
the row vector $mat(x^*, 0)$ annihilates the factor $mat(B_2, 0; 0, B_K)$, hence
$mat(x^*, 0) cal(A) = mat(x^* A, 0) = lambda mat(x^*, 0)$. So $lambda$ is an eigenvalue of
the Hurwitz matrix $cal(A)$ and $"Re" lambda < 0$: every uncontrollable mode of $(A, B_2)$
is stable.

*Theorem 3.12 (input-output test)* @schererTheoryRobustControl[pp. 60--61]. Let $K$ be
*any* controller that stabilizes $y = P_(22) u$ (one always exists). Then $P$ is a
generalized plant iff this $K$ stabilizes $P$, i.e. renders all nine blocks of
#ref(<eq:nine>) stable. One candidate $K$ thus decides the question. Here “stabilizes
$P_(22)$” refers to a minimal (or stabilizable/detectable) realization of that transfer
matrix, not the possibly nonminimal realization inherited from all of $P$.
Otherwise the assertion that a stabilizer always exists would be false.

*Why this test works (outline).* If $P$ is a generalized plant, the state-space test
makes $(A,B_2,C_2,D_(22))$ stabilizable/detectable. No unstable mode can then disappear
when it is reduced to a minimal realization of $P_(22)$. A controller stabilizing this
channel stabilizes the same unstable modes of the whole system. Conversely, passing
all nine tests is already the definition's input-output characterization.

Existence here allows *unrestricted* dynamic output feedback. It does not promise
diagonal, low-order, static, or stable controllers; structural constraints require
additional work, as Exercise 3c demonstrates.

*Tracking loop revisited* @schererTheoryRobustControl[pp. 62--63]. With a minimal
realization $(A_G, B_G, C_G, D_G)$ of $G$, #ref(<eq:track>) has $A = A_G$,
$B_2 = B_G$, $C_2 = -C_G$; controllability and observability of $G$ make it a generalized
plant. In input-output form: any $K$ that stabilizes $-G$ makes all nine blocks stable,
because $P_(11)$, $P_(21)$ are constant and $P_(12) = G$ only appears in
$G (I + K G)^(-1)$ and $G K (I + G K)^(-1) = I - (I + G K)^(-1)$.

*Workflow.* Extract $P$; test the generalized-plant property (state space or one
stabilizing $K$ for $P_(22)$); design $K$; closed loop $= P lft K$ with realization
built from #ref(<eq:Acl>).

= Exercise 1: stable $P$ and the Youla parameter <s5>

#exercise[Exercise 1.][Let $P$ be stable. (a) Show $K$ stabilizes $P$ iff
  $I - P_(22) K$ has a proper inverse and $K (I - P_(22) K)^(-1)$ is stable. Is the same
  true with $(I - P_(22) K)^(-1)$ instead? (b) Show that ${ P lft K : K "stabilizes" P }$
  equals the set of all $P_(11) + P_(12) Q P_(21)$, $Q in #RH$, and relate $K$ and $Q$.]

*(a)* Assume $I - P_(22) K$ has a proper inverse and put

$ Q := K (I - P_(22) K)^(-1) = (I - K P_(22))^(-1) K, $ <eq:Q>

the second form by the push-through identity. Then

$ (I - P_(22) K)^(-1) = I + P_(22) Q, quad (I - K P_(22))^(-1) = I + Q P_(22). $ <eq:id>

Indeed $(I - P_(22) K)^(-1) - I = (I - P_(22) K)^(-1) P_(22) K = P_(22) (I - K P_(22))^(-1) K = P_(22) Q$,
and symmetrically $(I - K P_(22))^(-1) - I = K (I - P_(22) K)^(-1) P_(22) = Q P_(22)$.
Substituting #ref(<eq:Q>)–#ref(<eq:id>) into #ref(<eq:nine>), the nine blocks become

$ mat(
  P_(11) + P_(12) Q P_(21), P_(12) (I + Q P_(22)), P_(12) Q;
  Q P_(21), I + Q P_(22), Q;
  (I + P_(22) Q) P_(21), (I + P_(22) Q) P_(22), I + P_(22) Q
). $ <eq:nineQ>

Every entry is a sum of products of blocks of $P$ and $Q$. If $Q in #RH$ and $P in #RH$
they are all stable, so $K$ stabilizes $P$ by Corollary 3.6. Conversely, if $K$
stabilizes $P$, then $Q$ is the $(2,3)$ block and is stable. One test replaces nine.

*With $(I - P_(22) K)^(-1)$ instead: false.* Take $P = mat(0, 1; 1, 0)$ (stable,
$P_(22) = 0$) and $K = 1\/(s - 1)$. Then $(I - P_(22) K)^(-1) = 1$ is stable, but
$K (I - P_(22) K)^(-1) = K$ and even $P lft K = K$ are unstable. The reason: $(I - P_(22)K)^(-1) = I + P_(22) Q$
only sees $Q$ through $P_(22)$, which can annihilate (here: entirely) the unstable part of $Q$.

*(b)* "$subset$": if $K$ stabilizes $P$, $Q$ from #ref(<eq:Q>) lies in #RH and
$P lft K = P_(11) + P_(12) Q P_(21)$ by definition #ref(<eq:lft>). Moreover
$I + P_(22) Q = (I - P_(22) K)^(-1)$ has the proper inverse $I - P_(22) K$.

"$supset$": given $Q in #RH$ with $I + P_(22)(infinity) Q(infinity)$ nonsingular, define

$ K := Q (I + P_(22) Q)^(-1), $ <eq:KofQ>

which is proper. Then
$I - P_(22) K = (I + P_(22) Q - P_(22) Q)(I + P_(22) Q)^(-1) = (I + P_(22) Q)^(-1)$, whose
inverse $I + P_(22) Q$ is proper, and
$K (I - P_(22) K)^(-1) = Q (I + P_(22) Q)^(-1) (I + P_(22) Q) = Q in #RH$. By (a), $K$
stabilizes $P$, and $P lft K = P_(11) + P_(12) Q P_(21)$.

The maps #ref(<eq:Q>) and #ref(<eq:KofQ>) are mutual inverses, so $K <-> Q$ is a
bijection between stabilizing controllers and admissible Youla parameters, and the
closed loop is *affine* in $Q$.

*Caveat on "free" $Q$.* The side condition $det(I + P_(22)(infinity) Q(infinity)) != 0$
is genuinely needed when $D_(22) != 0$: for the static $P = mat(0, 1; 1, -1)$ one has
$P lft K = K\/(1 + K)$, which never equals $1 = P_(11) + P_(12) dot 1 dot P_(21)$ (the value
for $Q = 1$). When $P_(22)$ is strictly proper, the most common case, the condition is
void and $Q$ ranges over all of #RH.

= Exercise 2: which $P$ are generalized plants? <s6>

#exercise[Exercise 2.][All signals scalar. Which of
  $ P_a = mat(1/(s+1), 1/(s+2); 1/(s+3), 1/s), quad P_b = mat(1/(s^2+s), 1/(s+2); 1/(s+3), 1/s), $
  $ P_c = mat(1/(s+1), 1/(s^2+2s); 1/(s+3), 1/s), quad P_d = mat(1/(s+1), 1/(s+2); 1/(s+3), 1/s^2) $
  define a generalized plant?]

Use Theorem 3.12: stabilize $P_(22)$ with some $K$, then check #ref(<eq:nine>). All
$P_(22)$ are strictly proper, so well-posedness is automatic.

*$P_a$, $P_b$, $P_c$ ($P_(22) = 1\/s$).* $K = -1$ stabilizes $1\/s$:
$S := (1 - P_(22) K)^(-1) = s\/(s+1)$, $K S = -s\/(s+1)$, $S P_(22) = 1\/(s+1)$, all stable
(scalars, so $(1 - K P_(22))^(-1) = S$). The remaining blocks are

$ P lft K = P_(11) - P_(12) P_(21) s/(s+1), quad P_(12) S, quad P_(12) K S, quad K S P_(21), quad S P_(21). $ <eq:ex2>

- $P_a$: $P_(11)$, $P_(12)$, $P_(21)$ stable, so all of #ref(<eq:ex2>) is stable.
  *Generalized plant.*
- $P_b$: $P_(12)$, $P_(21)$ are stable, but
  $P lft K = 1\/(s(s+1)) - s\/((s+1)(s+2)(s+3))$ keeps the pole at $0$ from $P_(11)$.
  *Not a generalized plant.* The integrator lives in the channel $w -> z$ as well as in
  $u -> y$; the residue of $P_b$ at $0$ is $mat(1, 0; 0, 1)$ (rank 2), so a minimal
  realization has *two* integrator states, and only one of them is reachable from $u$.
- $P_c$: $P_(12) = 1\/(s(s+2))$ is unstable, but $P_(12) S = 1\/((s+1)(s+2))$,
  $P_(12) K S = -1\/((s+1)(s+2))$ and
  $P lft K = 1\/(s+1) - 1\/((s+1)(s+2)(s+3))$ are stable; so are the others.
  *Generalized plant.* Here the residue at $0$ is $mat(0, 1\/2; 0, 1)$ (rank 1): one
  integrator, reachable from $u$ and visible in $y$.

*$P_d$ ($P_(22) = 1\/s^2$).* $K = -1$ fails ($s^2 + 1$). Take the lead controller
$K = -(3 s + 1)\/(s + 3)$:
$1 - P_(22) K = (s^3 + 3 s^2 + 3 s + 1)\/(s^2 (s+3)) = (s+1)^3\/(s^2(s+3))$, so
$S = s^2 (s+3)\/(s+1)^3$, $K S = -s^2 (3 s + 1)\/(s+1)^3$, $S P_(22) = (s+3)\/(s+1)^3$, all
stable. $P_(11)$, $P_(12)$, $P_(21)$ are stable, so every block of #ref(<eq:nine>) is a product
of stable factors. *Generalized plant.*

*Answer:* $P_a$, $P_c$, $P_d$ are generalized plants; $P_b$ is not. Rule of thumb: every
unstable pole of $P$ must appear in $P_(22)$ with its full multiplicity (McMillan
degree), so that it is both reachable from $u$ and visible in $y$.

= Exercise 3: the interconnection of Figure 23 <s7>

#figure(
  caption: [Scherer's Figure 23, redrawn. Controller blocks in teal; the summing
    junction after $K_1, K_2$ produces $a = u_1 + u_2$, which feeds both $G_7$ and $G_5$.
    Signs at the left and middle junctions are minus where marked.],
  box(width: 100%, height: 6.0cm)[
    // rows: 0.5 top, 1.6, 2.9 main, 4.2, 5.3 bottom
    #blk(2.0cm, 2.55cm, 1.0cm, 0.7cm)[$G_1$]
    #blk(3.9cm, 1.25cm, 1.0cm, 0.7cm)[$G_2$]
    #blk(3.9cm, 3.85cm, 1.0cm, 0.7cm)[$G_3$]
    #blk(6.6cm, 0.15cm, 1.0cm, 0.7cm)[$G_4$]
    #blk(6.6cm, 1.25cm, 1.0cm, 0.7cm, col: teal)[$K_1$]
    #blk(6.6cm, 2.55cm, 1.0cm, 0.7cm)[$G_5$]
    #blk(6.6cm, 3.85cm, 1.0cm, 0.7cm, col: teal)[$K_2$]
    #blk(6.6cm, 4.95cm, 1.0cm, 0.7cm)[$G_6$]
    #blk(9.3cm, 2.55cm, 1.0cm, 0.7cm)[$G_7$]
    #sumj(1.3cm, 2.9cm)
    #sumj(5.7cm, 1.6cm)
    #sumj(5.7cm, 4.2cm)
    #sumj(8.6cm, 2.9cm)
    // w into S0, S0 -> G1
    #arr((0.1cm, 2.9cm), (1.13cm, 2.9cm))
    #lb(0.15cm, 2.35cm)[$w$]
    #arr((1.47cm, 2.9cm), (2.0cm, 2.9cm))
    #lb(1.45cm, 2.35cm)[$e$]
    // G1 -> branch
    #wire((3.0cm, 2.9cm), (3.4cm, 2.9cm))
    #node(3.4cm, 2.9cm)
    #lb(3.05cm, 2.95cm)[$q$]
    #arr((3.4cm, 2.9cm), (3.4cm, 1.6cm), (3.9cm, 1.6cm))
    #arr((3.4cm, 2.9cm), (3.4cm, 4.2cm), (3.9cm, 4.2cm))
    // G2 -> S1 -> K1
    #arr((4.9cm, 1.6cm), (5.53cm, 1.6cm))
    #arr((5.87cm, 1.6cm), (6.6cm, 1.6cm))
    #lb(6.0cm, 1.05cm)[$y_1$]
    #arr((4.9cm, 4.2cm), (5.53cm, 4.2cm))
    #arr((5.87cm, 4.2cm), (6.6cm, 4.2cm))
    #lb(6.0cm, 4.3cm)[$y_2$]
    // K outputs into S3
    #arr((7.6cm, 1.6cm), (8.6cm, 1.6cm), (8.6cm, 2.73cm))
    #lb(7.85cm, 1.05cm)[$u_1$]
    #arr((7.6cm, 4.2cm), (8.6cm, 4.2cm), (8.6cm, 3.07cm))
    #lb(7.85cm, 4.3cm)[$u_2$]
    // S3 -> G7 and S3 -> G5
    #arr((8.77cm, 2.9cm), (9.3cm, 2.9cm))
    #lb(8.85cm, 2.35cm)[$a$]
    #arr((8.43cm, 2.9cm), (7.6cm, 2.9cm))
    // G5 -> junction -> S1 (up) and S2 (down), minus
    #wire((6.6cm, 2.9cm), (5.7cm, 2.9cm))
    #node(5.7cm, 2.9cm)
    #arr((5.7cm, 2.9cm), (5.7cm, 1.77cm))
    #arr((5.7cm, 2.9cm), (5.7cm, 4.03cm))
    #lb(5.82cm, 1.75cm)[$-$]
    #lb(5.82cm, 3.6cm)[$-$]
    // G7 -> z, feedback taps through G4 and G6
    #arr((10.3cm, 2.9cm), (12.4cm, 2.9cm))
    #lb(12.0cm, 2.35cm)[$z$]
    #node(11.3cm, 2.9cm)
    #arr((11.3cm, 2.9cm), (11.3cm, 0.5cm), (7.6cm, 0.5cm))
    #arr((6.6cm, 0.5cm), (1.3cm, 0.5cm), (1.3cm, 2.73cm))
    #arr((11.3cm, 2.9cm), (11.3cm, 5.3cm), (7.6cm, 5.3cm))
    #arr((6.6cm, 5.3cm), (1.3cm, 5.3cm), (1.3cm, 3.07cm))
    #lb(0.85cm, 2.15cm)[$-$]
    #lb(0.85cm, 3.25cm)[$-$]
  ],
) <fig:23>

#exercise[Exercise 3.][For @fig:23, with possibly MIMO $G_j$ and $K_j$: (a) compute $P$
  in terms of $G_j$; (b) find SISO examples $P_1$ that is no generalized plant, and $P_2$
  with a $K$ that makes $P_2 lft K$ stable without stabilizing $P_2$; can $P_1 = P_2$?
  (c) for the data below show $P$ is a generalized plant, design a stabilizing $K$,
  explain the check, and plot $|P lft K|$.]

*(a) Open-loop description.* Cut the controller: inputs $w$, $u = mat(u_1; u_2)$;
outputs $z$, $y = mat(y_1; y_2)$; the controller is block diagonal,
$K = "diag"(K_1, K_2)$. Read off the diagram, keeping the order of factors:

$ a = u_1 + u_2, quad z = G_7 a, quad e = w - (G_4 + G_6) z, quad q = G_1 e, $
$ y_1 = G_2 q - G_5 a, quad y_2 = G_3 q - G_5 a. $

There is no algebraic loop once $u$ is fixed: $z$ depends on $u$ only. Substituting,
$q = G_1 w - G_1 (G_4 + G_6) G_7 (u_1 + u_2)$, and with

$ H_j := G_j G_1 (G_4 + G_6) G_7 + G_5, quad j = 2, 3, $ <eq:H>

$ mat(z; y_1; y_2) = mat(0, G_7, G_7; G_2 G_1, -H_2, -H_2; G_3 G_1, -H_3, -H_3) mat(w; u_1; u_2). $ <eq:P23>

Dimension constraints implied by the diagram: $u_1$, $u_2$ and $a$ share one dimension;
$y_1$ and $y_2$ must have equal dimension, since the same $G_5 a$ is subtracted from both;
$G_4, G_6$ map $z$ into the dimension of $w$. Note $P_(11) = 0$ and $P_(12) = mat(G_7, G_7)$:
both control inputs act through the same channel. The numerical state-space build for
part (c) agrees with this formula to $2.4 times 10^(-15)$ at three complex test points.

*(b) Examples.* *$P_1$, no generalized plant:* $G_1 = G_3 = G_7 = 1$,
$G_2 = 1\/(s - 1)$, $G_4 = G_5 = G_6 = 0$. Then

$ P_1 = mat(0, 1, 1; 1/(s-1), 0, 0; 1, 0, 0). $

Since $P_(22) = 0$, the block $(I - P_(22) K)^(-1) P_(21) = P_(21)$ of #ref(<eq:nine>)
contains $1\/(s-1)$ for *every* $K$: the unstable $G_2$ is driven by $w$ and cannot be
influenced by $u$ because $G_4 = G_6 = 0$ cut the path from $u$ back to $G_2$.

*$P_2$, stable $P_2 lft K$ without stabilization:* $G_1 = G_2 = G_3 = G_7 = 1$,
$G_4 = G_5 = G_6 = 0$, so $P_2 = mat(0, 1, 1; 1, 0, 0; 1, 0, 0)$, which is stable and hence a
generalized plant ($K = 0$ stabilizes it). Take $K_1 = 1\/(s - 1)$, $K_2 = -1\/(s - 1)$.
Then $P_2 lft K = mat(1, 1) "diag"(K_1, K_2) mat(1; 1) = K_1 + K_2 = 0$, stable, yet
$K (I - P_(22) K)^(-1) = K$ is unstable, so $K$ does not stabilize $P_2$
(Exercise 1a). The unstable controller modes cancel at the junction producing $a$, but
$u_1$ and $u_2$ individually grow without bound.

*Can $P_1 = P_2$?* Yes. For $P_1$ above and $K = 0$, $P_1 lft K = P_(11) = 0$ is
stable, while no controller at all stabilizes $P_1$. So the same interconnection
serves both roles, which shows sharply that a stable $w -> z$ map certifies nothing.

*(c) Data.* $G_1 = 1$, $G_2 = 1\/(s-1)$, $G_3 = (s+1)\/(s^2+1)$, $G_4 = 0$,
$G_5 = 1\/s$, $G_6 = 1$, $G_7 = (s+2)\/((s+3)(s-2))$, so $H_j = G_j G_7 + 1\/s$ in
#ref(<eq:H>).

*Generalized plant.* Build a realization #ref(<eq:Pss>) from realizations of
$G_7$ (2 states), $G_2$ (1), $G_3$ (2), $G_5$ (1), with $x = (x_7, x_2, x_3, x_5)$:
$dot(x)_7 = A_7 x_7 + B_7 a$, $dot(x)_2 = A_2 x_2 + B_2^G (w - C_7 x_7)$, likewise $x_3$,
$dot(x)_5 = a$, and $B_2 = mat(b_a, b_a)$ with $b_a$ the input column of $a$. All blocks
are strictly proper, so $D_(22) = 0$. The eigenvalues of $A$ are
$1, 2, plus.minus i, 0, -3$. Numerically, $(A, mat(B_1, B_2))$ is controllable and
$(A, mat(C_1; C_2))$ observable (ranks 6 = $n$), so the realization is minimal, and the
Hautus matrices $mat(A - lambda I, B_2)$ and $mat(A - lambda I; C_2)$ have rank 6 at each of
$lambda = 1, 2, plus.minus i, 0$. By Theorem 3.10, $P$ is a generalized plant. The
structure explains why: $a$ reaches every mode (directly for $G_7$, $G_5$; via $z = G_7 a$
for $G_2$, $G_3$), the $G_2$ mode is seen in $y_1$, the $G_3$ modes in $y_2$, and the
integrator in both.

*Design.* Theorem 3.10's observer controller #ref(<eq:obs>) applied to the 2-input,
2-output $P$ gives a *full* $2 times 2$ $K$, which stabilizes $P$ in the sense of the
definition but cannot be built in @fig:23: there $K_1$ sees only $y_1$ and $K_2$ only
$y_2$. Realizing separate copies of a centralized controller can introduce hidden
unstable duplicate states; it is not a valid shortcut to decentralized stabilization.
We therefore design $K = "diag"(K_1, K_2)$ directly, in two steps:

+ Choose $K_2 = 1$ (static, so $K_1$ and $K_2$ share no poles). Closing $u_2 = y_2$ gives
  $A' = A + b_a C_(2,2)$, where $C_(2,2)$ is the $y_2$ row of $C_2$. It is needed: with $K_2 = 0$ the
  modes $plus.minus i$ of $G_3$ would be invisible to $K_1$.
+ For the SISO loop $(A', b_a, C_(2,1))$, which is controllable and observable (ranks 6), apply
  #ref(<eq:obs>) with LQR gains (weights $I$ and $1$) for $F$ and the dual problem for $L$:
  $dot(xi) = (A' + b_a F + L C_(2,1)) xi - L y_1$, $u_1 = F xi$.

The resulting sixth-order controller is

$ K_1 (s) = (479.08 s^5 + 1557.5 s^4 + 722.32 s^3 + 1247.6 s^2 + 977.12 s - 626.62) / (s^6 + 15.301 s^5 - 371.51 s^4 - 1087.4 s^3 + 272.67 s^2 - 1079.7 s + 641.85), $

with poles $-27.40$, $14.77$, $-3.17$, $0.506$, $-0.0043 plus.minus 0.994 i$. An unstable
controller is allowed; only internal stability matters.

*Check.* (i) #ref(<eq:wp>): $D_(22) = 0$, so it holds ($det = 1$). (ii) $cal(A)$ from
#ref(<eq:Acl>), $12 times 12$, has eigenvalues
$-3.076 plus.minus 0.862 i$, $-2.898$, $-0.338 plus.minus 1.129 i$,
$-0.190 plus.minus 1.029 i$, $-1.842 plus.minus 0.456 i$, $-0.734$, $-0.743$, $-1.034$:
largest real part $-0.190$, so $K$ stabilizes $P$. (iii) Physical substitution
$a=F xi+y_2$, $dot(xi)=A_1 xi-L y_1$ reproduces the full state matrix exactly;
the error-coordinate triangularization has residual $8.9 times 10^(-16)$.
(iv) The full disturbed port map agrees with direct solution of its signal equations
to $4.1 times 10^(-11)$ at three complex points. Its joint minimal realization has
12 stable poles; this is not a claim that each individual block has all 12 poles.
(v) The realization of $P lft K$ matches
#ref(<eq:lft>) evaluated pointwise (error $2.2 times 10^(-12)$).

#figure(
  caption: [Bode magnitude of the closed loop $P lft K$ ($w -> z$) for the design of
    Exercise 3c. Peak $24.66$ ($27.8$ dB) at $omega approx 1.25$ rad/s; zero DC gain;
    roll-off $-40$ dB/decade.],
  image("assets/ex3c-bode.svg", width: 88%),
) <fig:bode>

*Reading the plot.* $P lft K (0) = 0$ for *every* stabilizing $K$: internal stability
makes the maps from $w$ to $y_1$, $q = w - z$ and $a = u_1 + u_2$ stable, and
$s^(-1) a = G_5 a = G_2 q - y_1$. Since $G_2$ is analytic at $0$, the right side is
bounded near $s = 0$, so the map $w -> a$ must vanish at $s = 0$, and so does
$z = G_7 a$. The large
resonant peak near $omega approx 1$ (close to the $G_3$ poles $plus.minus i$ and to the
lightly damped closed-loop pair $-0.19 plus.minus 1.03 i$) shows that this design only
achieves stability; shaping $|P lft K|$ is the subject of the performance chapters.

#figure(image("assets/internal-modes.svg", width: 100%), caption: [Two computed
  diagnostics. Left: the asymmetric cancellation example has zero zero-state output
  but an exponentially growing initial-state response. Right: Exercise 3c moves the
  physical joint-state modes into the left half-plane. A magnitude plot alone cannot
  supply either initial-condition or hidden-mode information.])

*Reproduce.* From the repository root:
`octave --no-gui Control/robust-control-03-interconnections/scripts/ex3c.m`
(GNU Octave 11.3 with the `control` package; it prints every number above and writes
both SVG plots). Use the state-space construction, not the rounded polynomial above,
as the reproducible controller specification. The script replaces MATLAB's `sysic` by an explicit
state-space build and uses `lqr` for $F$ and $L$, so it runs without the Robust Control
Toolbox. With identity LQR state weights, even the designed transfer controller depends
on the realization basis. A coordinate change preserves the design only if the weights
are transformed consistently. The supplied script fixes the basis and weights together.

= Sources and further reading

All theory statements, equation forms, and exercise statements follow Chapter 3 of
@schererTheoryRobustControl (pp. 46--65), read from the PDF. The exercise solutions,
counterexamples, the decentralized design in Exercise 3c, and the remark on the Youla
side condition are derived here, with reproducible Octave numerical checks (see
`summary.md`). The nine-map theorem and input-output existence theorem have proof
outlines, not full Hautus-test proofs. No other sources were consulted.

#bibliography("refs.bib")
