// symplectic-matrix.typ -- complete teaching note, written on the shared template
// .agents/skills/teach-an-engineer/typst-template/note.typ conventions (note-ilm + teaching.typ).
//
// Every number quoted below is reproduced by scripts/verify_symplectic.py, which also checks
// the symplectic and Hamiltonian identities the note derives.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, hook, check, navy, teal, gray

#show: note-ilm.with(
  title: [Symplectic Matrices in Control],
  authors: "Amp",
  abstract: [
    A symplectic matrix preserves a bilinear form on phase space, and that single algebraic
    condition turns out to rigidify a spectrum, to explain why an undamped mechanical system
    cannot settle, and to sit underneath the Riccati equation that every LQR gain comes from.
    This note builds all of that from one running example: a unit mass on a unit spring,
    first in phase space and then under an LQR cost. We see what the condition $M^T J M = J$
    preserves and forces; why the flow of an undamped system is symplectic while a damped one
    is not; how the condition rigidifies the spectrum and forbids asymptotic stability; how
    the Hamiltonian matrix of an LQR problem hands over the stabilizing Riccati solution
    through an invariant subspace; what a numerical reduction must preserve to compute that
    subspace honestly; and what breaks when a pair of eigenvalues reaches the imaginary axis.
  ],
)

// ---------------------------------------------------------------------------
// shared drawing helpers: one phase plane and one complex plane, both typeset.
#let cell(M, i, j) = M.at(i).at(j)
#let poly(pts, stroke: none, fill: none) = polygon(..pts.map(p => (p.at(0), p.at(1))), stroke: stroke, fill: fill)

// ============================== 1. THE CONDITION ===============================

= What does $M^T J M = J$ preserve? <s1>

Start in the plane, where everything can be drawn. Write a phase-space vector as
$x = mat(q; p)$: position on top, momentum underneath. For two such vectors $u$ and $v$ define

$ omega(u, v) = u^T J v, quad J = mat(0, 1; -1, 0). $ <eq:form>

Work out what this number is for $u = mat(u_q; u_p)$ and $v = mat(v_q; v_p)$:

$ u^T J v = mat(u_q, u_p) mat(v_p; -v_q) = u_q v_p - u_p v_q. $ <eq:det2>

That is exactly the determinant of the $2 times 2$ matrix with columns $u$ and $v$: the *signed
area* of the parallelogram the two vectors span. So in the plane, the bilinear form has a
concrete meaning you can see -- it measures signed parallelogram area. A matrix $M$ is
*symplectic* when

$ M^T J M = J, $ <eq:symp>

and in the plane this says one visible thing: #emph[the area of every parallelogram comes out
of $M$ unchanged]. Not just the area of one particular parallelogram -- every one, because the
identity holds for all pairs $u, v$ at once.

#figure(
  caption: [The unit square (gray) sent through two area-preserving-looking maps. The shear
    (navy) is symplectic: every parallelogram area, including the square's, survives. The
    squeeze (teal) multiplies all areas by $0.96$, and its form defect $norm(M^T J M - J) = 0.04$
    detects exactly that.],
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

The figure contrasts two ways of being area-preserving-in-spirit. The shear
$S = mat(1, 0.8; 0, 1)$ slides the top edge sideways; the square becomes a slanted
parallelogram of the same area, and indeed $S^T J S = J$ exactly. The squeeze
$D = mat(1.6, 0; 0, 0.6)$ stretches one axis and shrinks the other; its determinant is
$1.6 times 0.6 = 0.96$, so areas shrink by $4 percent$, and correspondingly
$norm(D^T J D - J) = 0.04$: the form defect is the area error itself. The rotation by
$30 degree$ also passes, as any rotation must -- it preserves all dot products, hence all
areas.

Now let the algebra hand back what the condition forces. First, $M$ must be invertible, because
$det(M^T J M) = det M^2 dot det J = det J$ gives $det(M)^2 = 1$. Second, the inverse has a
remarkably explicit form. Multiply #ref(<eq:symp>) on the left by $J^{-1} = -J$ and on the
right by $M^{-1}$:

$ J = M^T J M quad ==> quad -J M^{-1} = M^T J quad ==> quad M^{-1} = -J M^T J. $ <eq:inv>

So the inverse costs no elimination at all -- a transpose and two multiplications by fixed
matrices. That is the first sign that the condition is rigid, not merely restrictive. Third,
$det(M)^2 = 1$ has two roots, but the negative one never occurs for a symplectic matrix: the
set of symplectic matrices is connected (it is the image of a connected group under a
continuous map), and $det$ is continuous and equals $1$ at the identity, so $det M = +1$
always. In the plane, where $M^T J M = (det M) J$ holds for *every* $2 times 2$ matrix $M$
(by #ref(<eq:det2>) applied columnwise), symplectic and determinant-one coincide.

In $2n$ dimensions the two notions separate, and the separation is the point. A matrix with
$det = 1$ preserves the volume of $2n$-dimensional boxes. A symplectic matrix preserves
something finer: the signed area of the parallelogram spanned by $u$ and $v$ *projected onto
each of the $n$ coordinate planes* $(q_1, p_1), dots, (q_n, p_n)$ -- all simultaneously. The example of the $4 times 4$ matrix that doubles $q_1$, halves $p_1$, and leaves
$(q_2, p_2)$ alone has determinant $1$ but sends the $(q_1, p_1)$-area of a parallelogram to
four times itself, so it is not symplectic. Volume preservation is one number's worth of constraint; #ref(<eq:symp>)
is a full matrix identity, $n (2n - 1)$ independent scalar equations' worth.

#check[The map $M = mat(2, 0; 0, 1)$ doubles all $q$-directions and leaves $p$ alone. Is it
  symplectic? Compute $M^T J M$.]

It is not: $M^T J M = mat(0, 2; -2, 0) = 2J$, so parallelogram areas double. Compare the
shear, which moves the top edge without stretching anything, and passes. Stretching one
coordinate is never symplectic; the area has to be paid for elsewhere *in the same
coordinate plane*.

// ============================== 2. THE FLOW ===============================

= Why the undamped flow is symplectic and the damped flow is not <s2>

The running example for the rest of the note is a unit mass on a unit spring. Its energy and
equations are

$ H(q, p) = (q^2 + p^2) / 2, quad dot(x) = J nabla H(x) = mat(dot q; dot p) = mat(p; -q). $ <eq:osc>

The pattern on the right -- velocity from momentum, force from energy -- is the Hamiltonian
form: $dot(x) = J nabla H$ with $nabla H$ the gradient of the energy. Since $H$ is quadratic
here, the system is linear and the flow map $Phi_t$ (the map sending the state at time $0$ to
the state at time $t$) is the matrix exponential $Phi_t = e^(J t)$, because
$nabla^2 H = I$:

$ Phi_t = e^(J t) = mat(cos t, sin t; -sin t, cos t). $ <eq:flow>

#figure(
  caption: [One small square patch of the phase plane at $t = 0$ (gray, near
    $q = 1.1$, $p = -0.05$) and its image under the flow at $t = 1$ (navy). The patch rides
    a rotation by one radian around the energy circle (light gray) and lands as a rotated
    square of the same area -- which #ref(<eq:flow>) guarantees, since a rotation preserves
    every area.],
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

Why must this be so for *any* Hamiltonian system, not just this one? The claim is that
$Phi_t^T J Phi_t = J$ for all $t$. For a linear system the flow is $Phi_t = e^(A t)$, so
differentiate $F(t) = Phi_t^T J Phi_t$ using $dot(Phi)_t = A Phi_t$:

$ dot(F) = (A Phi_t)^T J Phi_t + Phi_t^T J A Phi_t = Phi_t^T (A^T J + J A) Phi_t. $ <eq:df>

Everything now hinges on the bracket. For a Hamiltonian system $A = J S$ with $S = nabla^2 H$
#emph[symmetric] (the energy's second derivative always is). Then

$ A^T J + J A = (J S)^T J + J (J S) = S^T J^T J + J^2 S = S + (-S) = 0. $ <eq:bracket>

Here is why each piece moves the way it does. $(J S)^T = S^T J^T = -S J$: the symmetry of $S$
lets it pass through the transpose, and $J^T = -J$ flips the sign. Then $-S J J = -S (-I) = S$.
Meanwhile $J (J S) = J^2 S = -S$. So the two terms are $S$ and $-S$: they cancel. So
$dot(F) = 0$, and since $F(0) = J$, the form
$J$ is carried intact by the flow at every time. The structural feature responsible is
precisely the pairing in $dot(x) = J nabla H$: one antisymmetric factor $J$, one symmetric
factor $nabla^2 H$, arranged so that the form's time derivative is antisymmetric-in-motion
versus symmetric-in-curvature and the two kill each other.

Dissipation breaks the pairing. Add viscous damping $c > 0$:

$ dot(q) = p, quad dot(p) = -q - c p, quad A_c = mat(0, 1; -1, -c). $ <eq:damped>

Run the same test. The bracket #ref(<eq:bracket>) needs $A_c = J S$ for a symmetric $S$; no
such $S$ exists here, so compute the bracket directly:
$A_c^T J = mat(1, 0; c, 1)$ and $J A_c = mat(-1, -c; 0, -1)$, so

$ A_c^T J + J A_c = mat(0, -c; c, 0) = c J, $ <eq:damped-bracket>

which is zero only when $c = 0$. The leftover is not of the canceling form: the healthy
pattern is "antisymmetric matrix times symmetric matrix," and damping's contribution resists
being written that way. That leftover is exactly what destroys the conservation. The visible
consequence: areas contract
geometrically, at the rate given by Liouville's formula
$det e^(A_c t) = e^(tr A_c dot t) = e^(-c t)$ -- at $c = 0.5$ the area of
any patch has shrunk to $e^(-0.5) = 0.6065$ after one unit of time. The damped system still
converges to rest; the undamped one never does, and the next section shows that this is not an
accident of this example but a theorem.

Open #raw("Control/symplectic-matrix/symplectic-matrix-demo.html") beside this note and move
the stiffness, damping, and integrator controls to watch the same patch and its area ratio.

#check[For the damped system with $c = 0.5$, is the flow $Phi_t$ symplectic for some small
  $t > 0$? Use the bracket $A_c^T J + J A_c$.]

No. If $Phi_t$ were symplectic for one $t_0$, differentiating #ref(<eq:df>) backward would
still force the bracket to vanish at $t = 0$ (the derivative $dot(F)(0) = A_c^T J + J A_c$
is independent of $t$), giving $mat(0, -c; c, 0) = 0$, a contradiction for $c > 0$. The flow
is symplectic at no positive time whatsoever -- symmetry is lost instantly, not gradually.

// ============================== 3. SPECTRUM ===============================

= How the condition rigidifies the spectrum <s3>

The inverse formula #ref(<eq:inv>) is the lever. Read it as a similarity:

$ M^{-1} = -J M^T J = J M^T J^{-1}, $ <eq:sim>

$M^{-1}$ is similar to $M^T$. And $M$ is always similar to $M^T$ (a matrix and its transpose
share the characteristic polynomial). Chaining the equalities:

$ sigma(M^{-1}) = sigma(M^T) = sigma(M). $ <eq:spec>

The spectrum of $M$ equals the spectrum of its inverse. If $lambda$ is an eigenvalue, so is
$1 / lambda$. And because a symplectic matrix is real, $overline(lambda)$ is an eigenvalue
too. Putting the two facts together, eigenvalues come in *quartets*:

$ lambda, quad 1/lambda, quad overline(lambda), quad 1/overline(lambda). $ <eq:quartet>

Whenever one eigenvalue sits somewhere in the complex plane, three more occupy fixed positions
in the same matrix's spectrum: the reciprocal point across the real axis, the mirror across
the unit circle, and both combined. The figure shows two unrelated symplectic matrices, and in
each spectrum the quartet structure is plainly visible.

#figure(
  caption: [Eigenvalues of two symplectic matrices: $M_1 = Phi_1$ of #ref(<eq:osc>) (navy,
    both on the unit circle) and $M_2 = e^(H_2)$ for a $4 times 4$ Hamiltonian $H_2$ (teal).
    For $M_2$, the two visible points $0.1111 + 0.6853 i$ and $0.2306 + 1.4218 i$ are
    reciprocals of each other: $0.1111 + 0.6853 i = 1 / (0.2306 + 1.4218 i)$ (product
    $0.2306 times 0.1111 + 1.4218 times 0.6853 = 1.0000$). Each teal point also has its
    conjugate partner, drawn.],
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

For a discrete system $x_(k+1) = M x_k$, asymptotic stability means every eigenvalue inside
the unit circle. The quartet rule forbids it outright: if $|lambda| < 1$ then $|1/lambda| > 1$,
so an eigenvalue strictly inside the circle drags a partner strictly outside. The best a
symplectic matrix can do is keep its whole spectrum *on* the unit circle (as $M_1$ does), or
split it half-in half-out (as $M_2$ does). Translated back to mechanics: an undamped
Hamiltonian system cannot have all its modes decay. This is the spectrum-level statement of
"frictionless systems do not settle," and it holds no matter how the energy is shaped, because
only #ref(<eq:symp>) was used.

#check[An eigenvalue of a symplectic matrix is reported as $0.5 + 0.5 i$. Which other numbers
  must be in the spectrum, and why can the matrix not be asymptotically stable?]

The quartet #ref(<eq:quartet>) also contains $0.5 - 0.5 i$ (conjugate), $1/(0.5 + 0.5 i) =
1 - i$, and $1 + i$ -- magnitudes $0.7071$ and $1.4142$, one inside the circle and one
outside. No symplectic matrix is asymptotically stable: the reciprocal partner always
escapes.

// ============================== 4. CONTROL ===============================

= The Hamiltonian matrix of an LQR problem and its stable subspace <s4>

Now put the same oscillator under a cost. The LQR problem: choose $u$ to minimize

$ integral_0^oo (x^T Q x + u^2) dif t, quad dot(x) = A x + B u, $ <eq:lqr>

with the running-example data $A = mat(0, 1; -1, 0)$, $B = mat(0; 1)$, $Q = epsilon I$, $R = 1$.
The classical result -- used here, not re-derived -- is that the optimal control is
$u = -K x$ with $K = B^T P$ for the *stabilizing* symmetric solution $P$ of the algebraic
Riccati equation

$ A^T P + P A - P G P + Q = 0, quad G = B R^{-1} B^T = mat(0, 0; 0, 1). $ <eq:care>

The equation is quadratic in $P$, nonlinear, and nothing in its statement hints at the
symplectic structures of the first three sections. The bridge is a $2n times 2n$ matrix built
from the problem data:

$ H = mat(A, -G; -Q, -A^T). $ <eq:ham>

$H$ is *Hamiltonian*, meaning $J H$ is symmetric (with the $2n times 2n$ form
$J = mat(0, I; -I, 0)$):

$ J H = mat(0, I; -I, 0) mat(A, -G; -Q, -A^T) = mat(-Q, -A^T; -A, G), $ <eq:jh>

which is symmetric, because $Q$ and $G$ are. So $H = -J (J H)$ (using $J^2 = -I$) is exactly
the "antisymmetric times symmetric"
pattern from Section 2, at the matrix level: the same pairing that made flows symplectic.

The Hamiltonian identity has an immediate spectral consequence, proved the same way as
#ref(<eq:spec>) but with a minus sign. For Hamiltonian $H$, one checks
$H^T = J H J^{-1} dot (-1)$ -- precisely, $-H = J H^T J^{-1}$ -- so $H$ is similar to $-H$, and

$ sigma(H) = -sigma(H): quad lambda in sigma(H) quad ==> quad -lambda in sigma(H). $ <eq:ham-sym>

With real $H$, the full pattern is the quartet $lambda, overline(lambda), -lambda,
-overline(lambda)$: reflection through the origin has joined the picture. Where the symplectic
*matrix* of Section 3 paired points across the unit circle, the Hamiltonian *matrix* pairs
them across the imaginary axis. If no eigenvalue of $H$ lies on that axis, the $2n$
eigenvalues split evenly: exactly $n$ in the open left half-plane, $n$ in the open right
half-plane. For the running example at $epsilon = 1$ the characteristic polynomial is
$x^4 + x^2 + 2$, with roots $plus.minus 0.6761 plus.minus 0.9783 i$ -- two left, two right,
as promised.

Now the step that turns this into a Riccati solution. Take the $n$ left-half-plane
eigenvectors of $H$; they span an $n$-dimensional *invariant subspace* -- a subspace that $H$
maps into itself. Stack a basis of it as two $n times n$ blocks:

$ H mat(X_1; X_2) = mat(X_1; X_2) Lambda, quad "Re" "eig"(Lambda) < 0. $ <eq:invsub>

Multiply the block rows out, using #ref(<eq:ham>):

$ A X_1 - G X_2 = X_1 Lambda quad "and" quad -Q X_1 - A^T X_2 = X_2 Lambda. $ <eq:blocks>

Assume for now $X_1$ invertible (this is the generic case; Section 6 shows exactly when it
fails) and set $P = X_2 X_1^{-1}$. Three things happen at once.

*Stability.* Multiply the first block equation by $X_1^{-1}$ on the right:

$ A - G P = X_1 Lambda X_1^{-1}. $ <eq:cloop>

The closed-loop matrix $A - G P$ is similar to $Lambda$, hence has exactly the stable
spectrum. The candidate $P$ delivers a stabilizing controller.

*Riccati.* The second block equation, with $X_2 = P X_1$ and
$X_2 Lambda = P X_1 Lambda = P (A - G P) X_1$ by #ref(<eq:cloop>), reads
$-Q X_1 - A^T P X_1 = P (A - G P) X_1$. Cancel $X_1$:

$ A^T P + P A - P G P + Q = 0. $ <eq:care-derived>

$P$ satisfies the Riccati equation -- the cancellation of $X_1$ is the whole trick, and it is
why $P$ is defined as $X_2 X_1^{-1}$ in the first place.

*Symmetry.* The Riccati solution must be symmetric; here the symplectic structure finally
cashes in. Take two eigenvectors $H u = lambda u$ and $H v = mu v$ from the stable subspace.
Form $u^T J H v$ two ways, using first $H v = mu v$ and then the symmetry of $J H$
(Section 2's identity, now for the matrix $H$):

$ u^T J H v = mu dot u^T J v = (J H u)^T v = lambda dot u^T J^T v = -lambda dot u^T J v. $

Comparing ends: $(mu + lambda) dot u^T J v = 0$. For two stable eigenvalues, $lambda + mu$
has negative real part, hence is not zero -- so $u^T J v = 0$ for every pair of stable
eigenvectors. Applying this to the columns of $mat(X_1; X_2)$:

$ X^T J X = 0 quad "with" quad X = mat(X_1; X_2) quad <==> quad X_1^T X_2 = X_2^T X_1. $ <eq:lagrange>

(A subspace whose basis satisfies $X^T J X = 0$ is called *Lagrangian*; the identity above is
its algebra.) Then $P = X_2 X_1^{-1}$ has transpose
$P^T = X_1^{-T} X_2^T = X_1^{-T} X_1^T X_2 X_1^{-1} = X_2 X_1^{-1} = P$. Symmetric, solving
the equation, stabilizing: the construction delivers exactly the matrix the LQR theorem asks
for. For the running example at $epsilon = 1$ it produces
$P = mat(1.9123, 0.4142; 0.4142, 1.3522)$ and the closed loop
$A - G P$ with eigenvalues $-0.6761 plus.minus 0.9783 i$ -- the left half of $sigma(H)$, as
#ref(<eq:cloop>) predicted.

#figure(
  caption: [The block layout of #ref(<eq:ham>) for the running example, each block labeled by
    the problem data it carries. The diagonal blocks $A$ and $-A^T$ mirror each other; the
    off-diagonal blocks $-G$ and $-Q$ are symmetric -- this is the matrix-level image of
    "antisymmetric times symmetric."],
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

#check[Suppose the stable invariant subspace had been spanned by
  $mat(X_1; X_2) = mat(1, 0; 0, 1; 1, 0; 0, 1)$ (i.e. $X_1 = I_2$ stacked above $X_2 = I_2$).
  What controller does $P = X_2 X_1^{-1}$ give, and what is wrong with it?]

$P = I_2$, so $K = B^T P = mat(0, 1)$ and the closed loop is $A - G P = mat(0, 1; -1, -1)$,
which is stable -- but $P$ would also have to satisfy #ref(<eq:care>), and the subspace here
is not an invariant subspace of the true $H$: its columns are not eigenvector combinations
for the stable pair $-0.6761 plus.minus 0.9783 i$. The construction is only as
good as the subspace: an arbitrary stable-looking $X_1, X_2$ satisfies neither the Riccati
equation nor, generally, the Lagrangian identity #ref(<eq:lagrange>).

// ============================== 5. NUMERICS ===============================

= What a numerical reduction must preserve <s5>

The construction of Section 4 needs one thing from linear algebra: the stable invariant
subspace of $H$. The standard route is a Schur decomposition -- an orthogonal change of basis
$Q$ making $Q^* H Q = T$ upper triangular. But an ordinary Schur decomposition is the wrong
instrument here, for a reason worth seeing precisely. Two demands collide.

The first demand is #emph[separation]. The Schur form is triangular, and its diagonal carries
the eigenvalues in whatever order the algorithm happens to produce them. The stable subspace
is spanned by the leading columns of $Q$ *only if* the first $n$ diagonal entries of $T$ are
exactly the stable eigenvalues. Nothing in the ordinary Schur iteration promises that order:
it may interleave stable and unstable eigenvalues along the diagonal, in which case the
"leading block" is a mixture and the $P$ read off from it is meaningless.

The second demand is #emph[structure]. The Riccati solution's symmetry came from the
Lagrangian identity #ref(<eq:lagrange>), which came from the form $J$. An orthogonal $Q$
preserves the Euclidean form -- $Q^* Q = I$ -- but knows nothing about $J$; after reduction,
the relation between the $(1, 2)$ and $(2, 1)$ blocks of $H$ that made everything work is no
longer visible, and roundoff can drift it arbitrarily far. The computed $P$ then fails to be
exactly symmetric, not by a rounding-scale error in the entries but by loss of the property
the equation is about.

A Hamiltonian Schur decomposition fixes both at once by restricting the allowed
transformations:

#figure(
  table(
    columns: 3,
    align: (left, left, left),
    inset: 6pt,
    stroke: 0.5pt + gray,
    [*Reduction*], [*Transformed form*], [*Basis and what it is built from*],
    [ordinary Schur], [$Q^* H Q = T$, $Q$ unitary, $T$ triangular], [columns of $Q$; stable and unstable eigenvalues may be interleaved along the diagonal],
    [Hamiltonian Schur], [$U^T H U = mat(T_11, T_12; 0, -T_11^T)$, $U$ symplectic-orthogonal], [first $n$ columns of $U$; the bottom-left block is zero and $T_22 = -T_11^T$ links the diagonal blocks through the form],
  ),
)

The transformation $U$ is required to satisfy $U^T J U = J$ -- Section 1's condition, applied
to the change of basis itself. This is the same move as throughout the note: the form is the
invariant, so only form-preserving maps may be used. Under such a $U$, the transformed $H$
remains Hamiltonian, and the Hamiltonian Schur *form* above makes the structure explicit:
the $(2, 1)$ block is zero and the $(2, 2)$ block is $-T_11^T$, the mirror of the $(1, 1)$
block -- #ref(<eq:ham-sym>) written into the shape of the matrix. The eigenvalue order is no
longer incidental: the leading block carries exactly one member of each $plus.minus$ pair,
and algorithms (orthogonal symplectic Hessenberg--Schur iterations, following Laub's method
and its descendants) arrange for it to be the stable one. Then the first $n$ columns of $U$,
stacked as $mat(X_1; X_2)$, span the stable invariant subspace with the Lagrangian identity
holding up to rounding, and $P = X_2 X_1^{-1}$ comes out symmetric and well-conditioned
whenever the problem itself is. The step that reads $P$ off needs $X_1$ invertible and not
nearly singular -- a demand the ordinary Schur route can violate silently even when $P$ is
perfectly fine.

#check[An ordinary Schur decomposition of the running-example $H$ returns $T$ whose first two
  diagonal entries are $+0.6761 plus.minus 0.9783 i$ (the right-half-plane pair). What does
  $P = X_2 X_1^{-1}$ from the leading columns compute?]

It computes the *antistabilizing* solution: the invariant subspace now belongs to the
unstable eigenvalues, so the resulting $P$ solves the Riccati equation but makes
$A - G P$ have the unstable spectrum $plus.minus 0.6761 plus.minus 0.9783 i$. The equation
has several symmetric solutions; only ordering the reduction correctly selects the
controller. This is why eigenvalue ordering, not just accuracy, is part of the numerical
contract.

// ============================== 6. LIMITS ===============================

= When an eigenvalue lands on the imaginary axis <s6>

Every step so far had one hypothesis quietly doing load-bearing work: $H$ has no eigenvalues
on the imaginary axis. It bought the clean split of #ref(<eq:ham-sym>) into left/right halves,
and it is exactly what makes the stable invariant subspace -- and with it $P$ -- exist. So
watch what happens as the state penalty shrinks. Keep #ref(<eq:lqr>) and #ref(<eq:ham>) but
let $Q = epsilon I$ with $epsilon -> 0$. The table and figure track the left-half-plane
member of the closed-loop pair; the full spectrum of $H$ is that pair together with its
conjugates and their negations.

#figure(
  caption: [The left-half-plane eigenvalues of $H$ as $epsilon$ decreases: from
    $-0.6761 plus.minus 0.9783 i$ at $epsilon = 1$ the pair slides toward the imaginary axis
    and lands on $plus.minus i$ at $epsilon = 0$. The real part, which is what separates
    stable from unstable, goes to zero.],
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

The mechanism behind the migration: at $epsilon = 0$ the Riccati equation #ref(<eq:care>)
becomes $A^T P + P A - P G P = 0$, and $P = 0$ solves it. The closed loop is then $A$ itself,
with eigenvalues $plus.minus i$ -- the undamped oscillator of Section 2, which we already knew
cannot be moved by any feedback that costs nothing to leave alone. On the Hamiltonian side,
the four eigenvalues of #ref(<eq:ham-sym>) collide in pairs on the imaginary axis: the
left-half-plane member and its right-half-plane mirror meet at the same point, and the split
into "$n$ stable, $n$ unstable" loses its meaning -- there are no left and right halves to
count into.

The subspace construction then fails at its stated assumption. With the stable and unstable
eigenvalues merged, there is no $n$-dimensional invariant subspace of stable eigenvectors to
span, no $Lambda$ with spectrum in the open left half-plane, and $X_1$ loses its invertibility
-- indeed for $epsilon = 0$ the "solution" collapses to $P = X_2 X_1^{-1} = 0$ with the
closed loop marginally stable, not asymptotically. The general statement: a stabilizing
solution of the Riccati equation exists precisely when $H$ has no imaginary-axis eigenvalues;
its position in the complex plane is not a numerical curiosity but the exact boundary between
"the controller exists" and "it does not." This is also why practical LQR design never uses
$Q = 0$: an unweighted state returns the marginal system, and any reduction method (Section 5)
would see colliding eigenvalues where the splitting it relies on has dissolved.

#check[At $epsilon = 0.01$, the LHP eigenvalue is $-0.0707 + 1.0000 i$. Roughly how far, in
  real part, does the pair sit from the imaginary axis, and what does the Hamiltonian Schur
  reduction face as $epsilon$ shrinks further?]

The real part is $-0.0707$, and it scales roughly linearly with $epsilon$ (compare
$-0.2223$ at $epsilon = 0.1$). The reduction must separate eigenvalues whose real parts
differ by $O(epsilon)$: as the collision approaches, the invariant subspace becomes
increasingly sensitive, and the computed $X_1$ grows toward singularity -- the well-conditioned
regime of Section 5 shrinks with $epsilon$.

// ============================== 7. SOURCES ================================

= Sources and further reading

The symplectic-group and Hamiltonian-flow material is classical (Arnold, *Mathematical
Methods of Classical Mechanics*); the invariant-subspace construction of the Riccati solution
follows Laub, *A Schur method for solving algebraic Riccati equations* (1979), and the
structure-preserving reduction of Section 5 descends from Laub's method via Byers, *A
Hamiltonian QR algorithm* (1983), and the symplectic-method literature of Benner, Mehrmann,
and coauthors. Every number above is arithmetic on the running example, reproduced by
#raw("Control/symplectic-matrix/scripts/verify_symplectic.py").
