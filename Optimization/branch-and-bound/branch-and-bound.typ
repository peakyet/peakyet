#set document(title: "Branch and Bound: Search with a Proof", author: "Amp")
#set page(paper: "a4", margin: (x: 21mm, y: 19mm), numbering: "1",
  header: context if counter(page).get().first() > 1 {
    text(size: 9pt, fill: rgb("667085"))[BRANCH AND BOUND / relax · partition · certify]
  })
#set text(font: "Libertinus Serif", size: 10.5pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("16324f"))
#show raw: set text(font: "DejaVu Sans Mono", size: 8pt)
#show math.equation: set block(above: 0.6em, below: 0.6em)
#let navy = rgb("16324f")
#let teal = rgb("157f78")
#let gray = rgb("667085")
#let rose = rgb("a13a68")
#let insight(body) = block(width: 100%, inset: 10pt,
  fill: rgb("eef6f5"), stroke: (left: 3pt + teal), body)

#text(size: 10pt, fill: teal)[OPTIMIZATION · INTEGER DECISIONS · GLOBAL CERTIFICATES]
#v(8pt)
#text(size: 27pt, weight: "bold", fill: navy)[Branch and Bound]
#parbreak()
#text(size: 15pt)[Search with a proof, not just a good answer]
#v(10pt)
#insight[
  A feasible solution says, “I can do this well.” A bound says, “Nothing in
  this entire region can do better than that.” Branch and bound combines
  these statements to discard whole families of decisions safely.
]

= Why not just solve continuously and round?

Suppose two types of indivisible resource provide two services. One unit of
type $x$ supplies $(2,1)$ units of service and costs 3; one unit of type $y$
supplies $(1,2)$ and costs 2. Both services need at least 5 units. At most
two $x$ units and five $y$ units are available:
$ z^star = min (3x+2y) quad "subject to" quad
  2x+y >= 5, quad x+2y >= 5, $
$ 0 <= x <= 2, quad 0 <= y <= 5, quad x,y in bb(Z). $ <example>

If we allow fractional resources, the two service boundaries meet at
$(x,y)=(5/3,5/3)$ with cost $25/3 approx 8.333$. This is the continuous
*linear programming (LP) relaxation*. Its optimum is not an implementable
decision, but its cost will be useful.

#figure(
  box(width: 100%, height: 6.3cm)[
    #let px(x) = 1cm + x * 2.3cm
    #let py(y) = 5.65cm - y * 0.95cm
    #place(top + left)[#polygon(fill: rgb("e3f1f0"), stroke: 0.8pt + teal,
      (px(0), py(5)), (px(2), py(5)), (px(2), py(1.5)), (px(5/3), py(5/3)))]
    #for x in range(3) {
      for y in range(6) {
        let feasible = 2*x+y >= 5 and x+2*y >= 5
        place(top + left, dx: px(x)-0.045cm, dy: py(y)-0.045cm)[
          #circle(radius: 0.045cm, fill: if feasible {navy} else {rgb("cdd3da")}, stroke: none)
        ]
      }
    }
    #place(top + left)[#line(start: (px(0),py(0)), end: (px(2.35),py(0)), stroke: gray)]
    #place(top + left)[#line(start: (px(0),py(0)), end: (px(0),py(5.5)), stroke: gray)]
    #for x in range(3) {
      place(top + left, dx: px(x)-0.06cm, dy: py(0)+0.13cm)[#text(size: 9pt, str(x))]
    }
    #for y in (1,3,5) {
      place(top + left, dx: px(0)-0.35cm, dy: py(y)-0.12cm)[#text(size: 9pt, str(y))]
    }
    #place(top + left, dx: px(2.45), dy: py(0)-0.12cm)[$x$]
    #place(top + left, dx: px(0)-0.08cm, dy: py(5.7))[$y$]
    #place(top + left, dx: px(5/3)-0.08cm, dy: py(5/3)-0.08cm)[
      #circle(radius: 0.08cm, fill: rose, stroke: none)]
    #place(top + left, dx: px(1)-0.09cm, dy: py(3)-0.09cm)[
      #circle(radius: 0.09cm, fill: teal, stroke: none)]
    #place(top + left, dx: 7cm, dy: 0.5cm)[#text(size: 10pt)[
      *Shading:* LP-feasible region \
      *Dark dots:* feasible integer choices \
      *Pale dots:* infeasible integer choices
    ]]
    #place(top + left, dx: 7cm, dy: 2.1cm)[#text(size: 10pt, fill: rose)[
      LP optimum: $(5/3,5/3)$ \
      Cost: $25/3$ (a lower bound)
    ]]
    #place(top + left, dx: 7cm, dy: 3.5cm)[#text(size: 10pt, fill: teal)[
      Integer optimum: $(1,3)$ \
      Cost: $9$ (to be certified)
    ]]
  ],
  caption: [The continuous region contains all integer choices, plus artificial
    fractional ones. A relaxation enlarges the search space; it does not round it.],
)

Nearest-integer rounding gives $(2,2)$, cost 10: feasible but not optimal.
Rounding down gives $(1,1)$, which violates both service constraints.
Rounding is a *candidate-generation heuristic*, not a proof of feasibility
or optimality. We will instead certify $(1,3)$ without testing every choice.

*Prerequisites:* linear inequalities and the idea of optimizing a linear function
over a polygon. All bounds below use *minimization* unless stated otherwise.

#pagebreak()
= Two inequalities power the whole method

For a mixed-integer linear program (MILP), only selected components must be
integers. Write
$ z^star = min_(u in F) c^T u, quad
  F = {u : A u <= b, u_i in bb(Z) " for " i in I}. $
The other components are real. A *node* $N$ stores the original constraints
plus the restrictions inherited along its path from the root. Its integer-feasible
set is $F_N$ and its relaxed set is $R_N$, with $F_N subset.eq R_N$.

== A relaxation gives a lower bound

Minimizing over more choices cannot increase the optimal value:
$ ell_N := min_(u in R_N) c^T u <= min_(u in F_N) c^T u =: z_N^star. $ <local-bound>
An infeasible relaxation proves $F_N$ empty. For @example, the root value
$25/3$ can be certified without trusting a plot. Multiply the first service
inequality by $4/3$ and the second by $1/3$ and add:
$ 3x+2y >= (4/3)5 + (1/3)5 = 25/3. $
The point $(5/3,5/3)$ attains this value, proving LP optimality.
This weighted sum is a small *dual certificate*.

== A feasible solution gives an upper bound

An *incumbent* $hat(u) in F$ is the best original-feasible solution found so far.
Its objective $U=c^T hat(u)$ satisfies $z^star <= U$. Initially, use $U=+infinity$
if no feasible solution is known. Here $(0,5)$ is feasible, so start with $U=10$.
It need not lie in the node currently being processed.

== Branching partitions decisions, not guesses

If an optimal LP solution $bar(u)$ has a fractional integer component $bar(u)_j$,
create two children with the inherited constraints and respectively
$ u_j <= floor(bar(u)_j), quad "or" quad u_j >= ceil(bar(u)_j). $ <split>
Every integer value belongs to exactly one child; the fractional LP solution
belongs to neither. The real interval between floor and ceiling contains no
integers, so nothing implementable is lost. At the root, split into $x<=1$
and $x>=2$.

== Three reasons to close a node (fathom or prune)

#table(
  columns: (2.7cm, 5.1cm, 1fr), inset: 7pt, stroke: 0.4pt + rgb("cdd3da"),
  [*Reason*], [*Certificate*], [*Why no search remains*],
  [Infeasibility], [The relaxation is infeasible.], [There is no original-feasible choice here.],
  [Bound], [$ell_N >= U$.], [Every choice costs at least the incumbent.],
  [Integrality], [An optimal LP point satisfies all required integrality constraints.],
  [It attains both bounds for this node. Update the incumbent if better.],
)

The bound rule includes equality because we seek *one* optimum. If the goal is
to enumerate all optimal solutions, discarding ties can lose other optima.
The integrality rule requires an *optimal* relaxed point, not just any integer
point encountered during the LP solve @gleixner2018.

#insight[
  “No feasible point found” is not “infeasible.” “This branch looks expensive”
  is not a lower bound. Every pruning decision needs a valid certificate.
]

#pagebreak()
= A complete five-node search

Keep the starting incumbent $(0,5)$, cost 10. We deliberately explore the
right-hand branch first so that all three closing rules appear. Bounds in the
tree are *raw LP values*, without the integer-objective strengthening on page 5.

#figure(
  box(width: 100%, height: 7.4cm)[
    #let node(x, y, body, color: navy) = place(top + left, dx: x, dy: y)[
      #block(width: 4.5cm, height: 1.5cm, inset: 7pt,
        fill: rgb("f7f9fb"), stroke: 0.8pt + color, radius: 4pt)[
        #set text(size: 9.5pt)
        #align(center, body)
      ]
    ]
    #place(top + left)[#line(start: (8.25cm,1.5cm), end: (2.6cm,2.8cm), stroke: gray)]
    #place(top + left)[#line(start: (8.25cm,1.5cm), end: (10.8cm,2.8cm), stroke: gray)]
    #place(top + left)[#line(start: (10.8cm,4.3cm), end: (6.8cm,5.65cm), stroke: gray)]
    #place(top + left)[#line(start: (10.8cm,4.3cm), end: (13.3cm,5.65cm), stroke: gray)]
    #place(top + left, dx: 3.6cm, dy: 1.75cm)[$x<=1$]
    #place(top + left, dx: 10.5cm, dy: 1.75cm)[$x>=2$]
    #place(top + left, dx: 7.1cm, dy: 4.75cm)[$y<=1$]
    #place(top + left, dx: 12.8cm, dy: 4.75cm)[$y>=2$]
    #node(6cm,0cm, [*R · root* \
      $(x,y)=(5/3,5/3)$ \
      $ell_R=25/3$ · branch on $x$])
    #node(0.35cm,2.8cm, [*A · processed last* \
      $(x,y)=(1,3), ell_A=9$ \
      Integer optimum · $U:10 arrow.r 9$], color: teal)
    #node(8.55cm,2.8cm, [*B · processed first* \
      $(x,y)=(2,3/2), ell_B=9$ \
      $9<10$ · branch on $y$])
    #node(4.55cm,5.65cm, [*C · child of B* \
      $x=2, y<=1$ \
      Infeasible · close], color: rose)
    #node(11.05cm,5.65cm, [*D · child of B* \
      $(x,y)=(2,2), ell_D=10$ \
      $10>=U$ · close by bound], color: gray)
  ],
  caption: [Processing order R, B, C, D, A. Every child inherits all constraints
    above it. Node letters identify regions, not the order of processing.],
)

*R.* The root LP has cost $25/3<10$, so it cannot be pruned. Its $x$ value
is fractional; branch using @split.

*B.* Since the original upper bound is $x<=2$, adding $x>=2$ fixes $x=2$.
Then $2x+y>=5$ requires $y>=1$, and $x+2y>=5$ requires $y>=3/2$.
The minimum is at $y=3/2$, with cost 9. It is fractional and strictly below
the incumbent, so split into $y<=1$ and $y>=2$.

*C.* Here $x+2y<=2+2=4<5$. Even the relaxation is infeasible: close C.

*D.* Here $x=2$, and the cheapest $y>=2$ is 2. Its LP bound is 10, equal
to the incumbent. Close D by bound. The LP point also happens to be integer;
the bound test is already sufficient.

*A.* With $x<=1$, the first constraint gives $y>=5-2x$, hence
$ 3x+2y >= 3x+2(5-2x)=10-x >= 9. $
The integer point $(1,3)$ attains 9 and meets the other constraint. Replace
the incumbent by $(1,3)$ and close A by integrality. No open nodes remain:
*the incumbent is globally optimal, with cost 9*.

#insight[
  If A is processed first, it immediately sets $U=9$. Node B then closes by
  $ell_B=9>=U$ without creating C or D: three LP solves rather than five.
  Search order changes the work, not the validity of the final certificate.
]

#pagebreak()
= The algorithm and why it cannot lose a better answer

The following exact-arithmetic version assumes finite bounds on all integer
variables and that every feasible node LP has a finite, attained optimum.
Continuous variables need not be integral. A node carries its complete path
restrictions and a lower bound inherited from its parent until re-solved.

```text
open = {root}; incumbent = none; U = +infinity
root.stored_lower_bound = -infinity
while open is not empty:
    remove a node N from open
    if its stored lower bound >= U: continue
    solve the LP relaxation of N
    if the LP is infeasible: continue
    ell = optimal LP objective; v = optimal LP point
    if ell >= U: continue
    if every integer-designated component of v is integer:
        incumbent = v; U = ell
        continue
    choose a fractional integer component v[j]
    add N with u[j] <= floor(v[j]) to open, bound = ell
    add N with u[j] >= ceil(v[j])  to open, bound = ell
if incumbent exists: return incumbent, globally optimal
else: return infeasible
```

*Heuristics are optional.* At any point, a heuristic may supply another
original-feasible point and improve $U$. It must check every original constraint,
not merely integrality. This can dramatically increase pruning without changing
the proof. Conversely, a partial LP solve may supply a valid dual bound, but
an arbitrary primal LP iterate is not a lower-bound certificate.

== The coverage invariant

At every completed iteration, every original-feasible point is either in an
open node, or in a closed region proved unable to beat the current incumbent.
This holds initially because the root covers the whole problem.

- *Branching preserves coverage:* the two integer child sets partition the
  parent's integer set.
- *Infeasibility removes nothing feasible.*
- *Bound pruning removes no strict improvement:* for all $u in F_N$,
  $c^T u >= ell_N >= U$.
- *Integrality closes a solved region:* if an optimal relaxed point is
  original-feasible, its objective equals $z_N^star$. Updating $U$ retains
  a solution at least as good as every point there.

Later improvements only decrease $U$, so earlier pruning remains valid.
When the open set is empty, nothing can beat the incumbent. With no incumbent,
empty coverage instead certifies infeasibility.

== Why termination needs assumptions

A branch on a fractional integer component strictly shrinks that component's
integer interval in both children. Finite integer ranges imply finite depth
and a finite tree. When every integer variable is fixed, the remaining LP
solves the node exactly. Binary variables can still produce a full tree with
up to $2^(n+1)-1$ nodes for $n$ variables: *correctness is not a polynomial-time
guarantee*.

An unbounded LP relaxation is not, by itself, an unboundedness certificate
for the integer problem: the integer problem may be infeasible. For example,
$x=1/2$, $x in bb(Z)$, and unrestricted real $y$ give an infeasible integer
problem, although minimizing $y$ in the relaxation is unbounded. Production
solvers must distinguish this from the finite-node-LP case above.

#pagebreak()
= What a solver's bounds and gap actually mean

The bound of the *current node* is not necessarily a global lower bound. Other
open branches may contain cheaper solutions. Let $cal(A)$ be the open frontier,
including any node being processed, and let $ell_N$ be each node's certified
bound. Until solved, a child can safely retain its parent's bound. Define
$ L = min {U, min_(N in cal(A)) ell_N}, quad L <= z^star <= U. $ <global-bound>
Take the minimum over an empty frontier as $+infinity$. Then $L=U$ on
exhaustion if an incumbent exists. Including $U$ avoids reporting a “lower
bound” above the already solved optimum when all remaining nodes are worse.

For our five-node traversal, if only the selected node's LP is solved:

#table(
  columns: (5cm, 1fr, 1fr, 1fr), inset: 7pt, stroke: 0.4pt + rgb("cdd3da"),
  [*Checkpoint*], [*Global $L$*], [*Incumbent $U$*], [*Absolute gap*],
  [Root solved], [$25/3$], [10], [$5/3$],
  [B, C, D finished; A still open], [$25/3$], [10], [$5/3$],
  [A solved; frontier empty], [9], [9], [0],
)

The middle row is intentionally unchanged: A has not been solved, so it still
carries the root bound. Knowing that B costs at least 9 does not prove that A
does. Solving both child relaxations earlier would permit $L=9$ sooner.
With exact nested relaxations, inherited bounds never decrease, and $U$ never
increases; this makes the *absolute* gap nonincreasing.

== Stop early with a meaningful guarantee

For finite bounds, if $U-L<=epsilon$, then
$ 0 <= U-z^star <= U-L <= epsilon. $
This is an absolute suboptimality guarantee in the objective's units. A common
relative gap is $abs(U-L)/abs(U)$ for $U!=0$. Solvers have their own conventions
at zero and infinity; check the documentation. Relative gaps can even increase
as absolute gaps decrease when the incumbent approaches zero. Adding a constant
to the objective changes the relative gap but not the optimizer or absolute gap.
The log's *Incumbent*, *BestBd*, and *Gap* are the practical interface to these
certificates @gurobi-log.

At a time limit, report the feasible incumbent, the best global bound, the
remaining gap, and the termination status. With no incumbent, no implementable
solution has been certified. “Not proven optimal” does not mean “infeasible.”

== A useful strengthening when the objective is integer-valued

If *every feasible objective value is an integer*, a valid bound $L$ improves
to $ceil(L)$. Our root bound becomes $ceil(25/3)=9$. Thus *any* feasible
point of cost 9 already proves optimality, even with open nodes. Do not apply
this when continuous variables or nonintegral costs destroy objective integrality.

== Floating point is not exact arithmetic

Implementations use feasibility, integrality, and gap tolerances. A value near
an integer is not automatically a feasible rounded solution; substitute the
candidate into the original constraints. Poor scaling and very large big-$M$
constants can make tolerance effects consequential. Solver-certified optimality
is normally relative to these numerical tolerances; exact rational certificates
or independently checked bounds are needed for an exact proof.

#pagebreak()
= How to make the search smaller

Branch and bound separates *finding an answer* from *proving that nothing is
better*. Better incumbents push $U$ down. Stronger relaxations push $L$ up.
Either can close the same gap, but only the second addresses a weak proof bound.

== Stronger formulations and cutting planes

A *valid inequality* keeps all original-feasible points but may remove fractional
ones. Adding the two service constraints in @example gives
$ 3x+3y>=10, quad x+y>=10/3. $
Because $x+y$ is an integer at every original-feasible point,
$ x+y>=4 $ <cut>
is valid. It removes the root fractional solution, whose coordinate sum is
$10/3<4$. This is a simple rounded aggregation (a Chvátal–Gomory cut).
With @cut, the root LP already solves the integer problem:
$ 3x+2y = (2x+y)+(x+y) >= 5+4=9. $
The point $(1,3)$ attains 9. One strengthened LP replaces the five-node tree.
*Branch-and-cut* adds valid inequalities during branch and bound; this is the
basic architecture of modern MILP solvers @gleixner2018.

#insight[
  A cut removes fractional artifacts without removing legal decisions.
  A branch splits legal decisions into separate subproblems.
  Neither operation is allowed to delete a potentially better feasible answer.
]

Avoid unnecessarily large big-$M$ values in logical models. For example, the
activation relation $0<=w<=M b$, $b in {0,1}$, relaxes to $w<=M b$ with
$0<=b<=1$. If useful output $w=10$ is possible and $M=10^6$, the LP can
“activate” it with $b=10^(-5)$, severely underpaying any activation cost.
Tight valid bounds or suitable indicator formulations can be much stronger.

== Two different selection decisions

- *Which open node next?* Depth-first search uses little frontier memory and
  often reaches candidate solutions quickly. Best-bound search chooses the
  smallest $ell_N$ to focus on the global proof bottleneck; it may store many nodes.
- *Which variable to branch on?* A simple rule chooses a fractional component
  close to a half-integer. Strong branching tentatively solves candidate child
  LPs; pseudocosts estimate their bound gains from earlier branches. Stronger
  decisions cost more per node, so fewer nodes need not mean less time.

Warm starts, presolve, domain propagation, primal heuristics, and cuts all help.
Node count alone is not a solver-independent performance measure.

== Beyond MILP: the bound must remain global

For convex mixed-integer models, convex relaxations or valid dual bounds can
replace LPs. In nonconvex nonlinear problems, merely dropping integrality and
running a local optimizer does *not* yield a valid lower bound: a local minimum
may be above a better feasible point. Spatial branch and bound subdivides
continuous domains and uses globally valid underestimators; convergence also
needs bounds that tighten as regions shrink @boyd2018.

In robotics, a discrete obstacle-side, contact-mode, or task-assignment choice
can sit above a continuous trajectory problem. Branching organizes these choices;
convex subproblems may bound them. A locally solved nonlinear trajectory is a
candidate, not a global bound. In real-time mixed-integer MPC, a small cost gap
does not by itself certify closed-loop safety or recursive feasibility.

#pagebreak()
#set text(size: 10pt)
#set par(leading: 0.5em)
= Reproduce the numbers, then test your understanding

The accompanying `scripts/verify.m` uses Octave's existing GLPK interface; no
additional package is required. From the repository root:

```sh
octave --no-gui --quiet Optimization/branch-and-bound/scripts/verify.m
typst compile Optimization/branch-and-bound/branch-and-bound.typ
```

It solves the five node relaxations and the cut-strengthened root; independently
enumerates all 18 integer assignments in the box; compares each finite node
bound with that node's true integer optimum; and checks the cut on every
feasible integer assignment. Its expected headline results are:

#table(
  columns: (5.5cm, 1fr), inset: 7pt, stroke: 0.4pt + rgb("cdd3da"),
  [*Problem*], [*Checked result*],
  [Root relaxation], [$(5/3,5/3)$, value $25/3$],
  [B: $x=2$], [$(2,3/2)$, value 9],
  [C: $x=2$, $y<=1$], [Infeasible],
  [D: $x=2$, $y>=2$], [$(2,2)$, value 10],
  [A: $x<=1$], [$(1,3)$, value 9],
  [Root plus $x+y>=4$], [$(1,3)$, value 9],
  [Full integer enumeration], [Unique optimum $(1,3)$, value 9],
)

These are numerical cross-checks, not a replacement for the exact certificates
derived above. The script checks the educational example; it is not a production
branch-and-bound implementation.

== Questions that expose common mistakes

+ *Min versus max.* For a maximization problem, which bound comes from a
  relaxation, and when can a node be pruned?
+ *A misleading current node.* The incumbent is 100. Two open minimization
  nodes have bounds 95 and 70. Can you claim an absolute gap of 5?
+ *Equality.* If $ell_N=U$, can you close the node when seeking one optimum?
  What changes when enumerating all optima?
+ *A failed rounding heuristic.* If every rounded LP point is infeasible,
  what can you conclude about the original problem?
+ *A new objective.* Replace the cost by $3x+2.1y$. Can you still strengthen
  the root bound simply by taking its ceiling?

*Answers.* (1) The relaxation supplies an upper bound; the incumbent supplies
a lower bound. Prune when the node's upper bound is no greater than the incumbent.
(2) No: the global bound is 70, so the certified absolute gap is 30.
(3) Yes for one optimum; not in general for all optima, since ties can live there.
(4) Nothing about infeasibility: only that the heuristic failed.
(5) No: integer decisions no longer guarantee integer-valued costs; for example,
$(1,3)$ costs 9.3. A different known objective lattice could support a different
rounding rule, but not the integer ceiling rule as stated.

#insight[
  *The method in one sentence:* maintain a feasible incumbent and valid bounds,
  partition every unresolved decision, and stop only when the remaining regions
  are proved irrelevant or the certified gap is small enough.
]

#bibliography("refs.bib", style: "ieee", title: "Sources and further reading")
