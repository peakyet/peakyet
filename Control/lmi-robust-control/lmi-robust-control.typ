// lmi-robust-control.typ -- a teach-an-engineer question map filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ. One deep question per
// section; the expected insights live in summary.md, never here.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

#show: note-ilm.with(
  title: [Linear Matrix Inequalities for Robust Control],
  authors: "Qwen3.8-Flash-Next",
  abstract: [
    A plant whose matrices depend on an unknown but bounded operator can be nominally
    stable yet fail somewhere in its uncertainty set. This note asks six questions about
    certifying such a family with linear matrix inequalities: what a certificate must
    quantify over, why no finite set of parameter values can decide it, what extra object
    makes the "for all" constraint affine, why one bound covers the whole family and
    whether it is conservative, how a state-feedback controller changes the problem class,
    and what changes when the uncertainty is structured or repeated. The running example is
    a linear-fractional plant with one norm-bounded uncertainty block.
  ],
)

// ============================== 1. QUESTION ===============================

= Why does a nominal certificate say nothing about a family? <s1>

#question[A Lyapunov certificate is a single quadratic function of the state. What must
  hold for one such function to certify a whole family of plants rather than one member,
  and why does a $P$ that satisfies the nominal Lyapunov inequality fail to certify the
  family even when it happens to certify some other member?]

*Running example.* Consider the linear-fractional plant

$ accent(x, dot) = A x + B_w w, quad z = C_z x, quad w = Delta z, quad norm(Delta)_2 <= 1, $ <eq:plant>

with $x in bb(R)^n$, $w in bb(R)^m$, $z in bb(R)^p$, known matrices $A$, $B_w$, $C_z$, and
an unknown constant operator $Delta in bb(R)^(m times p)$ of spectral norm at most one.
Eliminating the loop $w = Delta z$ gives the uncertain closed loop

$ accent(x, dot) = (A + B_w Delta C_z) x = A(Delta) x, quad A(Delta) in cal(A) := { A + B_w Delta C_z : norm(Delta)_2 <= 1 }. $ <eq:family>

*Facts to reason with.*
- $A$ is Hurwitz; $B_w$ and $C_z$ are fixed and known.
- $Delta$ is constant in time but its value is unknown; only the bound $norm(Delta)_2 <= 1$ is available.
- A quadratic Lyapunov candidate is $V(x) = x^T P x$ with $P = P^T succ 0$, and along #ref(<eq:family>) it has $accent(V, dot) = x^T(A(Delta)^T P + P A(Delta))x$.
- The nominal plant corresponds to $Delta = 0$ and its Lyapunov inequality is $A^T P + P A prec 0$.
- A scalar instance: $A = mat(-1, 0; 0, -2)$, $B_w = mat(1; 1)$, $C_z = mat(0.8, 0.8)$, and a
  scalar $delta in [-1, 1]$. The nominal plant is stable, yet at $delta = 1$ the closed loop
  $mat(-0.2, 0.8; 0.8, -1.2)$ has determinant $-0.4 < 0$ and is unstable.

// =============================== 2. NEED ==================================

= Why can no finite parameter sample decide the question? <s2>

#question[The robust condition must hold at every point of the uncertainty set. For each
  fixed $Delta$ it is one matrix inequality, so it can be tested at any finite list of
  values. Why can no finite list ever stand in for the whole set, and where does the
  obstruction live: in the size of the set, in how the unknowns enter, or in both?]

*The robust condition.* We want a common certificate $P$ with

$ A(Delta)^T P + P A(Delta) prec 0 quad "for all" quad norm(Delta)_2 <= 1, $ <eq:robust>

and expanding $A(Delta)$ from #ref(<eq:family>) gives

$ A(Delta)^T P + P A(Delta) = A^T P + P A + C_z^T Delta^T B_w^T P + P B_w Delta C_z. $ <eq:expand>

*Facts to reason with.*
- For each fixed $Delta$, #ref(<eq:robust>) is a single matrix inequality affine in $P$.
- The admissible set ${\ Delta : norm(Delta)_2 <= 1 }$ is a continuum; for a matrix ball the
  extreme points are the entire boundary, not a finite set of corners.
- In #ref(<eq:expand>) the term $P B_w Delta C_z$ multiplies the unknown certificate $P$ by the
  unknown operator $Delta$.
- A grid or vertex check tests #ref(<eq:robust>) only at the listed values of $Delta$.

#figure(
  caption: [The admissible set $norm(Delta)_2 <= 1$ drawn as a disk, with several sample
    points marked. Inspect what the marked points determine about the set, and what they
    leave untested.],
  box(width: 100%, height: 4.0cm)[
    #let cx = 3.4cm
    #let cy = 2.0cm
    #place(top + left, dx: cx - 1.5cm, dy: cy - 1.5cm)[
      #circle(radius: 1.5cm, fill: navy.lighten(88%), stroke: 0.9pt + gray)
    ]
    #for (dx, dy) in ((0.0cm, 1.5cm), (1.5cm, 0.0cm), (0.0cm, -1.5cm), (-1.5cm, 0.0cm),
                      (1.06cm, 1.06cm), (-1.06cm, -1.06cm), (1.06cm, -1.06cm), (0.55cm, 0.9cm)) {
      place(top + left, dx: cx + dx - 0.07cm, dy: cy + dy - 0.07cm)[
        #circle(radius: 0.07cm, fill: teal)
      ]
    }
    #place(top + left, dx: cx - 2.15cm, dy: cy - 0.15cm)[$Delta_1$]
    #place(top + left, dx: cx + 1.75cm, dy: cy - 0.15cm)[$Delta_2$]
    #place(top + left, dx: cx - 0.9cm, dy: cy + 1.75cm)[$norm(Delta)_2 <= 1$]
  ],
)

// =============================== 3. IDEA ==================================

= What extra object makes the infinite constraint affine? <s3>

#question[The obstruction is the cross term $C_z^T Delta^T B_w^T P + P B_w Delta C_z$, a sum
  $G + G^T$ of a product of the unknowns. What matrix generalization of the scalar
  inequality below bounds this term by an expression affine in the certificate, and what
  must that new object satisfy relative to $Delta$ before the bound $Delta^T Delta prec.eq I$
  can be turned into a statement about $Delta$ alone?]

*The goal.* Replace the quantified family #ref(<eq:robust>) by a single matrix inequality in
the certificate and one added variable, so that feasibility can be decided in one shot.

*Facts to reason with.*
- For scalars and any $gamma > 0$,

  $ 2 u v <= gamma u^2 + gamma^(-1) v^2. $ <eq:young>

- The uncertain cross term in #ref(<eq:expand>) is $G + G^T$ with $G = P B_w Delta C_z$, and
  $G + G^T$ is symmetric.
- The only information available about $Delta$ is $Delta^T Delta prec.eq I$.
- The new object must keep the final inequality affine in the unknowns.

// =============================== 4. WHY ===================================

= Why should one bound cover every value of the uncertainty? <s4>

#question[The test you built bounds the uncertain cross term once, yet it must hold for
  every admissible $Delta$. Could that test reject a family that is in fact robustly
  stable? What single feature of the constraint $Delta^T Delta prec.eq I$ decides whether
  the bound can lose anything, and what change to the uncertainty set would make it lose?]

*Setup.* The bound replaces the quantified requirement #ref(<eq:robust>) by one matrix
inequality in the certificate and the added object. The admissible set of the running example
is the single quadratic constraint $Delta^T Delta prec.eq I$.

*Facts to reason with.*
- A sufficient test can be conservative: it may fail even though some certificate exists.
- The bound was obtained from a quadratic inequality in $Delta$, so it is itself one
  quadratic form in the uncertainty.
- The uncertainty here is one full block, so its admissible set is one quadratic constraint.
- A test that is conservative loses certificates rather than gaining them.

// ============================== 5. METHOD =================================

= What does the method produce, and where does a controller enter? <s5>

#question[With the added object in place, analysis becomes one matrix inequality in the
  certificate and that object. Now add a state-feedback controller $u = K x$, so the closed
  loop contains $B_2 K$ next to $P$. A congruence by $Q = P^(-1)$ and the substitution
  $Y_c = K Q$ remove the controller from the products. Which terms does that substitution
  linearize, which terms stay coupled, and what class of problem does the result become?]

*Setup.* Augment the plant #ref(<eq:plant>) with a control channel,

$ accent(x, dot) = A x + B_2 u + B_w w, quad z = C_z x, quad w = Delta z, quad norm(Delta)_2 <= 1, $ <eq:control>

and look for $u = K x$ such that the closed loop $A + B_2 K + B_w Delta C_z$ satisfies the
robust condition for every admissible $Delta$. Let $Y succ 0$ be the added object; carrying it
through the bound gives the condition

$ (A + B_2 K)^T P + P (A + B_2 K) + P B_w Y^(-1) B_w^T P + C_z^T Y C_z prec 0. $ <eq:synthesis>

*Facts to reason with.*
- #ref(<eq:synthesis>) is affine in $P$ and affine in $K$, but contains the product $P B_2 K$
  and the product $P B_w Y^(-1) B_w^T P$.
- Congruence by $Q = P^(-1)$ and the substitution $Y_c = K Q$ rewrite $Q(A + B_2 K)^T$ as
  $Q A^T + Y_c^T B_2^T$ and $(A + B_2 K) Q$ as $A Q + B_2 Y_c$.
- The added object still appears as $Y$ and $Y^(-1)$, and the term $Q C_z^T Y C_z Q$ contains
  $Q$ twice.
- The uncertainty is still one full block.

// ============================== 6. LIMITS =================================

= What changes when the uncertainty is structured or repeated? <s6>

#question[So far the uncertainty is one full block. Replace it by two independent scalar
  blocks, $Delta = mat(delta_1 I_(m_1), 0; 0, delta_2 I_(m_2))$ with $abs(delta_1) <= 1$ and
  $abs(delta_2) <= 1$. What happens to the guarantee of the test, what must change about the
  added object, and does that change restore exactness?]

*Setup.* Keep the plant #ref(<eq:control>) and the condition, but let the uncertainty be
block-diagonal with two independent blocks of sizes $m_1$ and $m_2$,

$ Delta = mat(delta_1 I_(m_1), 0; 0, delta_2 I_(m_2)), quad abs(delta_1) <= 1, quad abs(delta_2) <= 1. $ <eq:structured>

*Facts to reason with.*
- The test so far used one added object, sized for the single block.
- The admissible set is now the intersection of two constraints, $delta_1^2 <= 1$ and
  $delta_2^2 <= 1$, that are not a single quadratic form.
- The added object must stay positive definite.
- The test must still be a single matrix inequality in the certificate and that object.

// ============================== 7. SOURCES ================================

= Sources and further reading

No external sources have been consulted yet; this note makes no external claims.
