// Teaching note for Chapter 10 of Scherer, Theory of Robust Control: A Brief Summary and
// Outlook, together with Appendices A (Bisection), B and C (proofs of Theorems 7.1 and 7.2).
// The bisection numbers come from scripts/bisection.m.

#import "/.agents/skills/teaching-complex-ideas/typst-template/teaching.typ": note-ilm, hook, check, navy, teal, gray

#show: note-ilm.with(
  title: [Summary, Outlook, and the Proofs behind the Riccati Tests],
  authors: "Amp",
  abstract: [
    The last chapter of the notes is one page of summary and three short appendices, but the
    appendices carry the weight: they contain the proof of the equivalence between "the
    Hamiltonian has no imaginary eigenvalues", "the Riccati equation has a stabilizing
    solution" and "the Riccati inequality is solvable", which every synthesis formula in
    chapters 7 and 8 rents without owning. We gather the summary into a map of what the notes
    built and what they left open, write out the bisection algorithm of Appendix A and run it
    on the scalar example of chapter 7 (it returns $sqrt(3) - 1$ to eight digits), prove the
    spectral symmetry of a Hamiltonian matrix, and then go through the proof of Theorem 7.2
    in full: the difference identity, the minimality of the stabilizing solution, the
    Lagrangian property of the stable invariant subspace that makes it a graph, and the
    perturbation argument that turns a Riccati inequality into a Riccati equation. Theorem 7.1
    follows by the sign trick of Appendix B. The chapter ends with the outlook the notes
    themselves give: what LMI techniques add beyond the $H_infinity$ bounds used here.
  ],
  bibliography: bibliography("refs.bib"),
)

#let lft = $star.op$
#let Clhp = $bb(C)_<$
#let C0 = $bb(C)_0$
#let RHinf = $cal(R H)_infinity$

#let thm(body) = block(inset: (x: 12pt, y: 10pt), stroke: 0.8pt + navy, fill: navy.lighten(94%), width: 100%)[#body]
#let note(body) = block(inset: (x: 12pt, y: 10pt), stroke: (left: 3pt + gray), fill: rgb("#f7f6f3"), width: 100%)[#body]

= What the notes built, and what they left open <s1>

The book's own summary is four paragraphs, and it is worth restating as a map, because the map
is more useful than any individual result.

#note[
  + *The framework is not the contribution.* The generalized plant captures almost any
    interconnection, and it extends — with less generality — beyond linear systems. Everything
    in the notes is a statement about one plant $P$ and one closed loop $P lft K$.
  + *Analysis is solved for LTI uncertainties.* The structured singular value gives computable
    robust stability and robust performance tests against structured LTI uncertainties.
    Parametric (real) uncertainties can be included, but the computation becomes delicate —
    the exact $mu$ problem is NP-hard, so only bounds are computed.
  + *Nominal synthesis is solved.* Minimizing an $H_infinity$ performance channel has a
    complete solution in terms of two Riccati equations and a coupling condition
    (chapter 7), and every sub-optimal controller is $K_"par" lft Q$ (chapters 7 and 9).
  + *Robust synthesis is not solved.* Minimizing the structured singular value over
    controllers has no satisfactory algorithm; the scalings/controller iteration
    (chapter 8) is the only general method, it gives no optimality guarantee, and it works
    well in practice often enough to be worth using.
  + *The bounds are the limitation.* The notes use $H_infinity$ norm bounds as the whole
    performance language; the outlook (section 6) is what changes when that restriction is
    lifted.
]

= Appendix A: bisection, and how a yes/no test becomes a number <s2>

Every "compute $gamma_"critical"$" in these notes is really a *decision* problem: for a given
$gamma$, either the test passes or it fails. Computing an $H_infinity$ norm (Theorem 7.4),
computing the optimal $H_infinity$ level (Theorem 7.13) and computing the $mu$ upper bound
(chapter 4) are all of this shape. One algorithm converts a decision into a number, and it is
worth writing out because it is used everywhere.

#thm[
  *Bisection (Appendix A).* Fix $epsilon > 0$ and an initial interval $[a_1, b_1]$ with
  $a_1 <= gamma_"critical" <= b_1$. Given $[a_j, b_j]$, test
  $gamma_"critical" < (a_j + b_j)\/2$. If the test says yes, take
  $[a_(j+1), b_(j+1)] = [a_j, (a_j + b_j)\/2]$; if it says no, take
  $[a_(j+1), b_(j+1)] = [(a_j + b_j)\/2, b_j]$. Stop when $b_(j+1) - a_(j+1) <= epsilon$, and
  report any point of the interval.
]

Each step halves the interval, so the number of steps grows like
$log_2((b_1 - a_1)\/epsilon)$: doubling the accuracy costs one extra test. The only requirement
on the underlying decision problem is that it be *monotone* — that pass/fail switch exactly
once as $gamma$ grows. That is what the theorems supply: Theorem 7.13 fails below the optimal
level and holds above it, so bisection applies.

As a check we run it on the scalar plant of chapter 7, whose optimal level we know in closed
form: the two indefinite Riccati equations collapse to one quadratic, the coupling condition
becomes $X_infinity < gamma$, and solving $X_infinity = gamma$ gives $gamma_* = sqrt(3) - 1$.
Bisecting on the decision "both Riccati equations have stabilizing solutions with
$rho(X_infinity Y_infinity) < gamma^2$" from $[0.6, 5]$ gives

#table(columns: 4, align: (center,)*4, stroke: 0.4pt + gray.lighten(60%),
  table.header([$j$], [$a_j$], [$b_j$], [$b_j - a_j$]),
  [1],  [0.600000000], [5.000000000], [4.4e0],
  [5],  [0.600000000], [0.875000000], [2.8e-1],
  [10], [0.728906250], [0.737500000], [8.6e-3],
  [15], [0.731860352], [0.732128906], [2.7e-4],
  [20], [0.732044983], [0.732053375], [8.4e-6],
  [22], [0.732049179], [0.732051277], [2.1e-6]),

with final midpoint $0.732050753$ against the exact $sqrt(3) - 1 = 0.732050808$ — an error of
$5.5 dot 10^(-8)$ after $22$ tests. The script is `scripts/bisection.m`. The example also shows
what bisection does *not* do: it returns a number, not a controller, and it cannot tell which
of the three conditions of Theorem 7.13 failed for a $gamma$ below the optimum.

= The shape of a Hamiltonian matrix <s3>

The proofs in Appendices B and C use one structural fact, and it explains why the Riccati
theory is a theory about the imaginary axis.

#thm[
  + The *Hamiltonian* structure is $J H$ symmetric, where
    $ J = mat(0, -I; I, 0). $
  + _Consequence_ (*Lemma C.1*): if $H$ has $k$ eigenvalues in $bb(C)_<$ it has exactly $k$
    in $bb(C)_>$ (with multiplicity), and vice versa.
]

The proof of the lemma is three lines and is the kind of computation worth doing once. With $J$
as above, $J H = (J H)^T = H^T J^T = -H^T J$, so $J H J^(-1) = -H^T$: the matrix $H$ is
*similar* to $-H^T$. Similar matrices have the same characteristic polynomial, so

$ det(H - s I) = det(-H^T - s I) = det(H^T + s I) = det(H + s I) = det(H - (-s) I), $

using that $H$ has even size and that $det(-M) = (-1)^(2n) det(M) = det(M)$. So the spectrum
of $H$ is symmetric about the origin of the imaginary axis: if $lambda$ is an eigenvalue of
multiplicity $k$, so is $-lambda$. This is why a Hamiltonian matrix either has eigenvalues on
the imaginary axis or splits them evenly into $n$ stable and $n$ unstable ones — and only in
the second case can the Riccati equation be solved.

= Appendix C: the proof of Theorem 7.2 <s4>

We prove: for symmetric $Q$, $R >= 0$ and stabilizable $(A, R)$, the following are equivalent —
(a) the Hamiltonian $H = mat(A, R; -Q, -A^T)$ has no eigenvalue on the imaginary axis; (b) the
ARE $A^T X + X A + X R X + Q = 0$ has a (unique) stabilizing solution $X_-$; (c) the ARI
$A^T X + X A + X R X + Q < 0$ has a symmetric solution. If so, every solution of the ARE or ARI
satisfies $X_- <= X$.

=== Step 0: the difference identity, and minimality of $X_-$

#thm[
  *Identity (C.1).* For any two symmetric $Z, Y$,
  $ (A^T Z + Z A + Z R Z + Q) - (A^T Y + Y A + Y R Y + Q) \
    = (A + R Y)^T (Z - Y) + (Z - Y)(A + R Y) + (Z - Y) R (Z - Y). $
]

This is Lemma 7.24 of chapter 7 and it is verified by expanding the right-hand side. Its
importance is that it is *linear* in the difference $Z - Y$ except for one term, which is
$>=$ 0 when $R >= 0$.

Take $Z = X$ (any solution of the ARE or ARI, so the left side is $<= 0$) and $Y = X_-$ (a
stabilizing solution, so the left side is exactly $0$ if $X$ solves the ARE and $<= 0$ if it
solves the ARI). Dropping the non-negative term $Delta R Delta$ leaves

$ 0 >= (A + R X_-)^T Delta + Delta (A + R X_-), quad Delta := X - X_-. $

Since $A + R X_-$ is stable, $Delta >= 0$: the stabilizing solution is the *smallest* one. Two
consequences follow immediately. First, $X_-$ is the unique stabilizing solution: if $X_1, X_2$
both stabilize then each is the smallest, so $X_1 <= X_2$ and $X_2 <= X_1$. Second, the ARI
cannot be solvable while the ARE has no stabilizing solution below it, which is half of
(c) $arrow.r$ (b).

=== Step 1: (a) implies (b)

This is the constructive direction and the one worth reading closely. Since $H$ has no
imaginary eigenvalues, Lemma C.1 splits its spectrum evenly: $n$ eigenvalues in $bb(C)_<$ and
$n$ in $bb(C)_>$. Take an ordered Schur decomposition

$ T^* H T = mat(M, M_12; 0, M_22) $

with $M$ ($n times n$) stable and $M_22$ anti-stable, and let $Z$ be the first $n$ columns of
$T$, so that

$ H Z = Z M. $

Partition $Z = mat(U; V)$ into two $n times n$ blocks. The technical heart is to show that $U$
is invertible; then $X_- := V U^(-1)$ is the stabilizing solution. Three facts are proved in
order.

*(i) The stable subspace is Lagrangian: $V^* U = U^* V$.* From $H Z = Z M$ we get
$Z^* J H Z = Z^* J Z M$. The left side is Hermitian (because $J H$ is symmetric), so the right
side is too: taking adjoints and using $J^* = -J$ and $(Z^* J Z)^* = -Z^* J Z$,
$ (Z^* J Z) M = (Z^* J H Z)^* = M^*(Z^* J Z)^* = -M^*(Z^* J Z). $
Rearranged this is the Lyapunov equation
$M^* (Z^* J Z) + (Z^* J Z) M = 0$, whose only solution is zero because $M$ is stable. Expanding
$Z^* J Z = 0$ with
$J = mat(0, -I; I, 0)$ gives exactly $V^* U = U^* V$.

*(ii) $U x = 0$ implies $R V x = 0$ and $U M x = 0$.* If $U x = 0$, the first block row of
$H Z = Z M$ reads $U M x = (A U + R V) x = R V x$. Left-multiplying by $x^* V^*$ and using (i)
plus $U x = 0$ turns the left side into $x^* V^* R V x$ and the other route into $0$; since
$R >= 0$ that forces $R V x = 0$, and then $U M x = 0$ as well.

*(iii) $U$ is invertible.* If not, (ii) shows $"ker"(U)$ is a nonzero $M$-invariant subspace,
so it contains an eigenvector: there is $x != 0$ with $M x = lambda x$ and $U x = 0$. The
second block row of $H Z = Z M$ reads $(-Q U - A^T V) x = V M x = lambda V x$, i.e.
$A^T V x = -lambda V x$. Since $M$ is stable, $Re(-lambda) > 0$, and (ii) gave $R^T V x = 0$;
stabilizability of $(A, R)$ now forces $V x = 0$. With $U x = 0$ this makes $Z x = 0$, hence
$x = 0$ because $Z$ has full column rank — a contradiction.

So $U$ is invertible. Because $V^* U = U^* V$, the matrix $X_- = V U^(-1)$ is Hermitian:
$(V U^(-1))^* = U^(-*) V^* = V U^(-1)$ using (i). To see that $X_-$ solves the ARE and
stabilizes, divide $H Z = Z M$ by $U$ on the right:

$ H mat(I; X_-) = mat(I; X_-) (U M U^(-1)). $

The first block row gives $A + R X_- = U M U^(-1)$, which is stable. The second block row gives
$-Q - A^T X_- = X_- (A + R X_-)$, which is the ARE. Finally, $X_-$ is *real*: the data are
real, so conjugating the ARE and the stability condition shows $bar(X)_-$ is also a stabilizing
solution, and uniqueness forces $X_- = bar(X)_-$.

=== Step 2: (b) implies (a)

A one-line similarity. If $X_-$ solves the ARE and $A + R X_-$ is stable,

$ H mat(I, 0; X_-, I) = mat(I, 0; X_-, I) mat(A + R X_-, R; 0, -(A + R X_-)^T). $

So $H$ is similar to a block-triangular matrix whose diagonal blocks are $A + R X_-$ and
$-(A + R X_-)^T$, both stable or anti-stable: $H$ has no imaginary eigenvalues. (This is also
the identity behind the graph picture of chapter 7: the graph $mat(I; X_-)$ is invariant under
$H$.)

=== Step 3: (a) implies (c)

A continuity argument. Perturb $Q -> Q + epsilon I$ and call the Hamiltonian $H_epsilon$.
Eigenvalues depend continuously on the entries of a matrix, so for all small $epsilon > 0$ the
matrix $H_epsilon$ still has no imaginary eigenvalues. By Step 1 applied to $Q + epsilon I$,
there is a symmetric $X$ with $A^T X + X A + X R X + Q + epsilon I = 0$, which gives the strict
ARI (c).

=== Step 4: (c) implies (b)

Let $Y$ satisfy the strict ARI and set $P := A^T Y + Y A + Y R Y + Q < 0$. The claim is that
the ARE

$ (A + R Y)^T Delta + Delta (A + R Y) + Delta R Delta + P = 0 $

has a *stabilizing* solution $Delta$. If it does, the difference identity (C.1) shows that
$X := Y + Delta$ solves the original ARE and that $A + R X = (A + R Y) + R Delta$ is stable,
which is (b). The existence of $Delta$ is where chapter 7's Lemma 7.3 is used: $(A + R Y, R)$
is stabilizable, $R >= 0$, and $P < 0$ makes $(A, P)$ observable (since $P$ is definite),
so $(A + R Y, P)$ has no unobservable mode on the imaginary axis; Lemma 7.3 then says the
Hamiltonian of the $Delta$-equation has no imaginary eigenvalues, and Step 1 (already proved)
supplies $Delta$. This closes the cycle (a) $arrow.r$ (b) $arrow.r$ (a) and
(a) $arrow.r$ (c) $arrow.r$ (b), and the sandwich $X_- <= X$ from Step 0 finishes the
theorem. $square$

= Appendix B: Theorem 7.1 from Theorem 7.2 <s5>

Theorem 7.1 differs from Theorem 7.2 only in assuming $(A, R)$ *controllable* instead of
stabilizable, and concluding the existence of the *anti-stabilizing* solution $X_+$ in addition
to $X_-$. The reduction is a sign change: observe that

$ A^T X + X A + X R X + Q = (-A)^T (-X) + (-X)(-A) + (-X) R (-X) + Q, \
  quad A + R X = -((-A) + R(-X)). $

So "$X$ is a stabilizing solution for $(A, R, Q)$" is the same statement as "$-X$ is an
anti-stabilizing solution for $(-A, R, Q)$". Applying Theorem 7.2 with $-A$ in place of $A$
gives:

#thm[
  *Corollary B.1 (book).* Suppose the hypotheses of Theorem 7.2 hold but $(-A, R)$ is only
  stabilizable. Then (a) $H$ has no imaginary eigenvalues, (b) the ARE has an anti-stabilizing
  solution $X_+$, and (c) the ARI has a symmetric solution are equivalent, and every solution
  satisfies $X <= X_+$.
]

Controllability of $(A, R)$ gives stabilizability of both $(A, R)$ and $(-A, R)$, so Theorem 7.2
applied to $(A, R)$ gives $X_-$ with $X_- <= X$, and Corollary B.1 gives $X_+$ with
$X <= X_+$: together, Theorem 7.1. The book notes that with only stabilizability of $(A, R)$
the anti-stabilizing solution generally fails to exist — a subtlety the Riccati machinery of
chapter 7 has to respect when it fixes which solution of each Riccati equation defines the
central controller.

= The outlook: what linear matrix inequalities add <s6>

The last page of the book is a list, and it is honest about the boundary of what was proved
here: every result in these notes is about *LTI controllers, LTI uncertainties, and
$H_infinity$ bounds*. Relaxing each of the three is what the LMI framework is for.

+ *A richer performance language.* Instead of one $H_infinity$ bound, one can impose
  $H_2$ constraints (stochastic noise reduction), positive-real (passivity) conditions, and
  amplitude constraints on selected channels, all in one optimization. The reason is that the
  closed-loop transfer matrix depends *affinely* on the controller once it is parametrized by the
  Youla parameter of chapter 9 — exactly the affine dependence $T_1 + T_2 Q T_3$ — so these
  requirements become convex, LMI-representable conditions in $Q$.
+ *Multi-objective design.* Because the constraints are convex in $Q$, different
  specifications on different channels can be traded off in a single problem instead of by
  iterating on weights.
+ *Uncertainties beyond LTI.* Time-varying parametric, nonlinear static and nonlinear dynamic
  uncertainties can be covered by *integral quadratic constraints*, which generalize the
  scalings of chapters 4 and 8: the scaling multiplier is replaced by a multiplier that
  certifies an integral inequality between the uncertainty's input and output. The $D$-scaling
  step of the scalings/controller iteration becomes a search over multipliers.
+ *Gain scheduling.* The same machinery gives a systematic way to design controllers that
  switch with a measured scheduling variable, with stability guaranteed over the schedule —
  the practical counterpart of the switching application listed in chapter 9.

#note[
  *Where the open problem is.* The single unresolved item in the notes is robust *synthesis*:
  minimizing the structured singular value over controllers. Everything else in the list above
  is a solved (convex) problem once the robustness requirement is dropped or replaced by a
  multiplier test. The scalings/controller iteration remains the only general method, and it
  is a coordinate descent, not an algorithm with a guarantee.
]

= Sources and further reading <s7>

The only source read for this note is @schererTheoryRobustControl: page 241 for the summary and
outlook, Appendix A (page 242) for the bisection algorithm, Appendix B (pages 242–243) for the
reduction of Theorem 7.1 to Theorem 7.2, and Appendix C (pages 243–246) for the proof of
Theorem 7.2, including Lemma C.1 and the difference identity (C.1). The bisection table was
produced by the note's own script `scripts/bisection.m` in Octave, not taken from the book.

*Further reading, not consulted.* @boyd1994lmis is the standard reference for the LMI
framework and the multi-objective and IQC extensions described in the outlook section;
@zhouDoyleGlover1996 is the standard textbook for the Riccati theory proved in the appendices.
Neither was read while writing this note.
