#set document(title: "Symplectic Matrices: From Phase Space to Optimal Control", author: "Amp")
#set page(paper: "a4", margin: (x: 21mm, y: 19mm), numbering: "1",
  header: context if counter(page).get().first() > 1 {
    text(size: 9pt, fill: rgb("667085"))[SYMPLECTIC MATRICES / geometry · physics · control]
  })
#set text(font: "Libertinus Serif", size: 10.5pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("16324f"))
#show raw: set text(font: "DejaVu Sans Mono", size: 8pt)
#show math.equation: set block(above: 0.65em, below: 0.65em)
#let insight(body) = block(width: 100%, inset: 10pt,
  fill: rgb("eef6f5"), stroke: (left: 3pt + rgb("157f78")), body)
#let boxed(body) = box(inset: 5pt, stroke: 0.5pt + rgb("157f78"), body)

#text(size: 10pt, fill: rgb("157f78"))[MATHEMATICS · HAMILTONIAN PHYSICS · OPTIMAL CONTROL]
#v(8pt)
#text(size: 27pt, weight: "bold", fill: rgb("16324f"))[
  Symplectic Matrices
]
#parbreak()
#text(size: 15pt)[From phase space to optimal control]
#v(10pt)
#insight[
  A rotation preserves lengths. A symplectic map preserves the pairing between
  a coordinate and its conjugate momentum. This is why the same matrix identity
  appears in planetary motion, optical systems, and the Riccati equation behind LQR.
]

= What can change while the essential geometry stays?

Imagine a cloud of particles described by position $q$ and momentum $p$.
Stretch every position by 2 and compress every momentum by 2:
$ mat(q';p') = underbrace(mat(2,0;0,1/2), S) mat(q;p). $
The circle becomes an ellipse. Lengths change, and the oscillator energy
$H=(q^2+p^2)/2$ generally changes. Yet the oriented area between any two
displacements is unchanged. The shear below has the same property.

#figure(image("assets/canonical-area.png", width: 100%),
  caption: [Three symplectic maps in one degree of freedom. Dashed: original unit
    circle. Filled: its image. Every filled region has area π, but not the same shape.])

Now write $z=(q,p)$, with $q,p in bb(R)^n$, *in that order*, and define
$ J = mat(0,I_n;-I_n,0), quad omega(u,v)=u^T J v
  =u_q^T v_p-u_p^T v_q. $
The alternating bilinear form $omega$ measures canonical pairing; in one degree
of freedom it is the signed area of the parallelogram spanned by $u,v$.
A real $2n times 2n$ matrix $S$ is *symplectic* when
$ boxed(S^T J S=J). $ <definition>
Indeed, $omega(S u,S v)=u^T S^T J S v=omega(u,v)$ for every pair.
In higher dimensions this preserves the *sum* of canonical pairings, not each
coordinate-plane projection separately.

*Reading route.* Pages 2–3 establish the algebra and the connection to flow.
Pages 4–5 use it in physics. Pages 6–9 explain why optimal control needs it.
Page 10 gives reproducible checks and questions. Only linear algebra and basic
ODEs are assumed. All matrices are real unless quantum operators are mentioned.

#pagebreak()
= The algebra: stronger than volume preservation

The set of matrices satisfying @definition is written $"Sp"(2n,bb(R))$.
Since $J^T=-J$ and $J^2=-I$, the defining identity gives
$ S^(-1)=-J S^T J. $ <inverse>
This proves invertibility without assuming it. Products and inverses are
symplectic: $(S_1 S_2)^T J(S_1 S_2)=S_2^T J S_2=J$.

== What does the condition say about the blocks?

For $S=mat(a,b;c,d)$ with $n times n$ blocks, multiplication gives
$ a^T c=c^T a, quad b^T d=d^T b, quad a^T d-c^T b=I. $
Useful building blocks are
$ mat(I,B;0,I) quad (B=B^T), quad
  mat(I,0;C,I) quad (C=C^T), quad
  mat(A,0;0,A^(-T)) quad (A " invertible"). $
Here $A^(-T)=(A^T)^(-1)$. A general position coordinate change must transform
momentum by its *inverse transpose*, not by the same matrix. Otherwise the
canonical pairing changes. These building blocks are not claimed to be a single
global factorization chart for every symplectic matrix.

== Why the determinant is +1, not merely ±1

Taking determinants in @definition gives only $det(S)^2=1$. To fix the sign,
write the two-form $omega=sum_i upright(d) q_i ∧ upright(d) p_i$. Its $n$-fold wedge product
is a nonzero constant multiple of oriented phase-space volume. Because $S$
preserves $omega$, it preserves this top-degree form too; hence $det(S)=1$.
This is an algebraic statement about the map, not an assumption of stability.

For a $2 times 2$ matrix, $S^T J S=det(S)J$, so determinant one is also
*sufficient*. For $2n>=4$ it is not. In ordering $(q_1,q_2,p_1,p_2)$, take
$ D="diag"(2,1,1,1/2). $
Its determinant is one, but
$ omega(D e_1,D e_3)=2 != 1=omega(e_1,e_3). $
One canonical plane expands while another contracts. Total volume survives;
the canonical pairings do not.

== Reciprocal eigenvalues, not automatic stability

Equation @inverse makes $S^(-1)$ similar to $S^T$. Thus the spectrum is closed
under $lambda ↦ 1/lambda$, including algebraic multiplicities. Real entries
also give complex-conjugate pairs. A generic off-axis, off-unit-circle eigenvalue
therefore belongs to a quartet
$ lambda, quad overline(lambda), quad 1/lambda, quad 1/overline(lambda). $
Coincidences reduce the quartet. The squeeze on page 1 has eigenvalues $2,1/2$:
symplectic maps can be unstable. A whole symplectic map cannot be strictly
contracting in all directions; some expansion must compensate contraction.

#insight[
  *Do not substitute a weaker test.* Orthogonality preserves Euclidean lengths;
  determinant one preserves volume; symplecticity preserves canonical pairings.
  They are different conditions. Rotations of a single $(q,p)$ plane happen to
  be both orthogonal and symplectic.
]

#pagebreak()
= Hamiltonian matrices generate symplectic motion

For a smooth physical Hamiltonian $H(q,p)$, Hamilton's equations are
$ dot(q)=nabla_p H, quad dot(p)=-nabla_q H,
  quad dot(z)=J nabla H(z). $
For a quadratic Hamiltonian $H(z)=1/2 z^T K z$ with $K=K^T$,
$ dot(z)=F z, quad F=J K, quad F^T J+J F=0. $ <hamiltonian>
A matrix satisfying the last identity is called *Hamiltonian*. Conversely,
$K=-J F$ is symmetric whenever that identity holds. In block form,
$ F=mat(A,B;C,-A^T), quad B=B^T, quad C=C^T. $
This is a condition on an infinitesimal generator, not on a finite step.

== A proof that explains the distinction

Let $S(t)=e^(t F)$, so $dot(S)=F S$ and $S(0)=I$. Then
$ dif/dif t (S^T J S)=S^T(F^T J+J F)S=0. $
The initial value is $J$, so $S(t)^T J S(t)=J$. The same proof works for a
time-dependent Hamiltonian generator $F(t)$, using its fundamental solution
rather than a single matrix exponential.

#insight[
  *Hamiltonian matrix → differential equation → symplectic transition.*
  $F^T J+J F=0$ describes the generator; $S^T J S=J$ describes the flow.
  Confusing these identities is like confusing angular velocity with a rotation.
]

== The harmonic oscillator: exact motion

For mass $m>0$ and stiffness $k>0$,
$ H= p^2/(2m)+k q^2/2, quad F=mat(0,1/m;-k,0). $
With $nu=sqrt(k/m)$, exponentiation gives
$ S(t)=mat(cos(nu t),sin(nu t)/(m nu);
  -m nu sin(nu t),cos(nu t)). $
This map is symplectic and preserves this particular $H$. For $m=k=1$ it is a
clockwise Euclidean rotation in $(q,p)$; for other parameters its trajectories
are ellipses. Energy preservation is an additional property of this flow, not a
consequence of symplecticity of an arbitrary matrix.

== Nonlinear physics: the Jacobian is symplectic

A nonlinear flow $phi_t$ is not a matrix. Its tangent map
$S(t)=D phi_t(z_0)$ satisfies
$ dot(S)=J nabla^2 H(phi_t(z_0))S, quad S(0)=I. $
Since the Hessian is symmetric, the same argument proves $S(t)^T J S(t)=J$.
This local statement is what “the nonlinear flow is symplectic” means. For an
autonomous $H$, $dot(H)=nabla H^T J nabla H=0$ as well. With explicit time
dependence, symplecticity survives even though $dot(H)=partial_t H$ need not vanish.

*Where it stops.* Add linear drag to a unit-mass oscillator:
$F=mat(0,1;-k,-gamma)$ with $gamma>0$. Then $F^T J+J F=-gamma J$, and
$S(t)^T J S(t)=e^(-gamma t)J$. Dissipation contracts phase area. The damped
physical system is not symplectic in these canonical coordinates.

#pagebreak()
= Why numerical physics cares about this identity

For the normalized oscillator $dot(q)=p$, $dot(p)=-q$, ordinary explicit Euler
updates both coordinates from the old state:
$ E_h=mat(1,h;-h,1), quad det(E_h)=1+h^2. $
Every step expands area, and, more strongly for this example,
$ H_(j+1)=(1+h^2)H_j. $
The simulated orbit spirals outward even though the real oscillator does not.

Instead *kick* momentum first, then *drift* position using the new momentum:
$ p_(j+1)=p_j-h q_j, quad q_(j+1)=q_j+h p_(j+1). $
This is symplectic Euler, with matrix
$ S_h=mat(1-h^2,h;-h,1)
  =mat(1,h;0,1)mat(1,0;-h,1), quad S_h^T J S_h=J. $
Each factor is a symplectic shear. The method preserves exactly the quadratic
quantity
$ tilde(H)_h=1/2(q^2+p^2-h q p), $ <modified>
as direct substitution shows. This is *not* the original energy.

#figure(image("assets/oscillator.png", width: 100%),
  caption: [Starting at (q,p) = (1,0), with h = 0.2. Left: the first 100 explicit
    Euler steps versus the exact circle and 300 symplectic steps. Right: energy
    over all 300 steps. The logarithmic axis makes Euler's exponential drift visible.])

When $abs(h)<2$, @modified is positive definite, so its constant level sets
bound the numerical trajectory. With $h=0.2$, $H_0=1/2$, it implies
$ 1/1.1 <= H_j/H_0 <= 1/0.9. $
At step 300, explicit Euler gives $H_300/H_0=1.04^300 approx 128825$.
The symplectic method oscillates within the stated bounds. But for $abs(h)>2$
the eigenvalues of $S_h$ leave the unit circle: *symplectic does not mean stable
for any step size*. At $abs(h)=2$ a defective boundary case permits growth.

For general separable mechanics $H=T(p)+V(q)$, use the second-order
kick–drift–kick (Störmer–Verlet) scheme:
$ p_(j+1/2)=p_j-h/2 nabla V(q_j), quad
  q_(j+1)=q_j+h nabla T(p_(j+1/2)), $
$ p_(j+1)=p_(j+1/2)-h/2 nabla V(q_(j+1)). $
It composes exact subflows, so it is symplectic. Under appropriate smoothness,
step-size, and bounded-orbit assumptions, backward error analysis explains
excellent long-time energy behavior via a nearby modified Hamiltonian—not exact
conservation of the original energy or an exact trajectory @hairer2010 @hairer2006.

#pagebreak()
= Three physical settings, one canonical structure

== Classical mechanics and molecular dynamics

For coupled masses, let $M=M^T succ 0$ and $K=K^T succ.eq 0$:
$ H(q,p)=1/2 p^T M^(-1)p+1/2 q^T K q, quad
  F=mat(0,M^(-1);-K,0). $
The off-diagonal blocks are symmetric, hence $F$ is Hamiltonian. In nonlinear
molecular or celestial mechanics replace the quadratic potential by $V(q)$.
Symplectic integration preserves the canonical structure over many oscillations
or orbits. It does not remove force-model error, close-encounter difficulties,
phase error, or the need to choose an adequate step size.

An important coordinate caveat: canonical momentum is $p=M dot(q)$ in this
simple model. A vector of positions and velocities is not automatically in
standard symplectic coordinates. Likewise, charged-particle canonical momentum
contains the vector potential; mechanical momentum alone changes the form.

== Paraxial ray optics and accelerator transfer matrices

In air (refractive index normalized to one), use transverse displacement $q$ and
normalized canonical ray momentum $p$, the small ray angle. A drift of length $ell$
and a thin focusing lens of focal length $f != 0$ have normalized matrices
$ D(ell)=mat(1,ell;0,1), quad L(f)=mat(1,0;-1/f,1). $
Their product is symplectic. The lens changes momentum according to position;
the drift changes position according to momentum. These are precisely the
shears used in kick–drift integration @paschotta.

For a centered ensemble with covariance $Sigma$, a linear map gives
$ Sigma'=S Sigma S^T, quad det(Sigma')=det(Sigma). $
Thus the rms phase-space emittance $epsilon=sqrt(det(Sigma))$ is invariant
in one canonical plane. This does not say that beam width is fixed: a narrow
beam can have a wider angular spread. Coupled multi-plane systems can exchange
projected emittances. At refractive-index interfaces, angle alone is not the
canonical momentum; index factors must be included before applying this test.

== Quadratic quantum mechanics: preserving commutators

Let $hat(z)=(hat(q),hat(p))$ obey the canonical commutation relations
$ [hat(z)_i,hat(z)_j]=upright(i) ℏ J_(i j). $
For a real linear transformation $hat(z)'=S hat(z)$,
$ [hat(z)'_i,hat(z)'_j]=upright(i) ℏ (S J S^T)_(i j). $
This equals the original commutator matrix exactly when $S$ is symplectic
($S J S^T=J$ is equivalent to @definition). Evolution under a quadratic
Hamiltonian therefore produces symplectic transformations of quadratures.
The squeeze $q'=a q$, $p'=p/a$ narrows one uncertainty while enlarging the other;
it is not a way to violate the uncertainty principle. Quantum states evolve
unitarily; their *real quadrature coordinates* transform symplectically. These
are different levels of description @weedbrook.

#insight[
  The applications differ, but the question is identical: does the evolution
  preserve the canonical relation between each coordinate and its conjugate?
  “Energy preserving” and “volume preserving” do not capture the whole contract.
]

#pagebreak()
= Why a stabilizing controller creates a Hamiltonian system

Consider continuous-time LQR with $x in bb(R)^n$, $u in bb(R)^m$:
$ dot(x)=A x+B u, quad
  cal(J)=1/2 integral_0^infinity (x^T Q x+u^T R u) dif t, $
where $Q=Q^T succ.eq 0$ and $R=R^T succ 0$. Assume $(A,B)$ is stabilizable
and $(Q^(1/2),A)$ is detectable. These sufficient hypotheses give a unique
positive-semidefinite stabilizing Riccati solution. It need not be positive
definite when some stable directions carry no state cost @tedrake.

Introduce a costate $lambda$, the marginal future cost of changing $x$.
The optimal-control Hamiltonian (a scalar function, not a physical energy) is
$ cal(H)(x,u,lambda)=1/2 x^T Q x+1/2 u^T R u+lambda^T(A x+B u). $
Stationarity in $u$ gives $R u+B^T lambda=0$. Set $G=B R^(-1) B^T$; after
eliminating $u$, the reduced Hamiltonian is
$ cal(H)_*(x,lambda)=1/2 x^T Q x+lambda^T A x-1/2 lambda^T G lambda. $
Its canonical equations are
$ dot(x)=A x-G lambda, quad dot(lambda)=-Q x-A^T lambda, $
or
$ dif/dif t mat(x;lambda)
  = underbrace(mat(A,-G;-Q,-A^T), F_L) mat(x;lambda). $ <lqrflow>
Because $G,Q$ are symmetric, $F_L^T J+J F_L=0$. The full state–costate
transition $e^(t F_L)$ is therefore symplectic. The costate is *not* physical
momentum, but it plays the same canonical mathematical role.

== The Riccati equation is an invariant-graph condition

Suppose the value function is $V(x)=1/2 x^T P x$, with $P=P^T$. Then
$lambda=nabla V=P x$. For this relation to persist under @lqrflow,
$ P dot(x)=dot(lambda), quad P(A-G P)x=-Q x-A^T P x. $
Because this must hold for every $x$,
$ boxed(A^T P+P A-P G P+Q=0). $ <care>
This is the continuous-time algebraic Riccati equation (CARE). Equivalently,
$ F_L mat(I;P)=mat(I;P)(A-G P). $ <graph>
The $n$-dimensional graph $lambda=P x$ is invariant, and its internal dynamics
are $dot(x)=(A-G P)x$. The optimal feedback is $u=-R^(-1)B^T P x$.

#insight[
  There is no contradiction between symplectic flow and stabilization.
  The *full* 2n-dimensional state–costate flow has contracting and expanding
  directions. Optimality selects the n-dimensional stable graph. The physical
  closed-loop state evolves on that graph and can contract.
]

The Hamiltonian generator has eigenvalue symmetry about zero (and conjugation
for real data). With no imaginary-axis eigenvalues, its stable and unstable
subspaces both have dimension $n$. The LQR assumptions above identify the stable
one with the graph of the stabilizing $P$.

#pagebreak()
= How stable subspaces turn into a feedback gain

Let columns of $Z=mat(U;V)$ span the stable invariant subspace of $F_L$,
with $U,V in bb(R)^(n times n)$. If $U$ is nonsingular, then $x=U c$,
$lambda=V c$, so
$ P=V U^(-1). $
Numerically, solve $P U=V$ rather than explicitly forming an inverse.
Use an ordered Schur decomposition (or a suitable pencil/QZ method), not a raw
collection of individually computed eigenvectors near multiple eigenvalues
@laub1979 @scipycare.

== Why is the result symmetric?

For any stable vectors $z_1,z_2$, both $e^(t F_L)z_i$ tend to zero. Their
canonical pairing is constant, so
$ z_1^T J z_2=(e^(t F_L)z_1)^T J(e^(t F_L)z_2) arrow.r 0. $
Hence $Z^T J Z=U^T V-V^T U=0$. Multiplying by $U^(-T)$ and $U^(-1)$ gives
$P=P^T$. An $n$-dimensional subspace with all such pairings zero is called
*Lagrangian*. Thus symmetry of the Riccati matrix is a geometric fact.

== A scalar unstable plant: choose the correct root

Take $dot(x)=x+u$, $Q=R=1$. Then
$ F_L=mat(1,-1;-1,-1), quad 2P-P^2+1=0,
  quad P_+=1+sqrt(2), quad P_-=1-sqrt(2). $
Both roots have zero Riccati residual. But $A-G P_+=-sqrt(2)$ is stable, whereas
$A-G P_-=+sqrt(2)$ is unstable. The correct branch matters more than merely
solving the polynomial.

#figure(image("assets/riccati-geometry.png", width: 100%),
  caption: [Left: the stable and unstable invariant graphs for the scalar plant
    above; dots on the stable line approach the origin. Right: a different plant,
    the pure integrator, whose finite-horizon value curvature grows with the remaining horizon.])

== A two-state example with a checkable exact answer

For the double integrator,
$ A=mat(0,1;0,0), quad B=mat(0;1), quad Q=I_2, quad R=1, $
$ P=mat(sqrt(3),1;1,sqrt(3)), quad K=B^T P=mat(1,sqrt(3)). $
Substitution verifies @care. Closed-loop poles are
$-sqrt(3)/2 plus.minus upright(i)/2$, strictly in the left half-plane. The script
checks this answer against Octave's `care`, the graph identity @graph, and the
symplectic identity for a nonzero-time transition.

#pagebreak()
= Finite-horizon control: Riccati as a moving graph

Now minimize the running LQR cost on $[0,T]$ plus
$1/2 x(T)^T P_f x(T)$, with $P_f=P_f^T succ.eq 0$. The terminal condition is
$lambda(T)=P_f x(T)$, and the time-dependent value is
$V(t,x)=1/2 x^T P(t)x$. Differentiating $lambda(t)=P(t)x(t)$ gives
$ dot(P)x+P(A-G P)x=-Q x-A^T P x, $
so
$ -dot(P)=A^T P+P A-P G P+Q, quad P(T)=P_f. $ <dre>
This equation is integrated *backward from T*. Reversing that direction without
changing the sign solves a different problem.

== A nonlinear matrix equation hidden inside a linear flow

Let a symplectic transition from time $t_0$ to $t_1$ have blocks
$ mat(x_1;lambda_1)=mat(a,b;c,d)mat(x_0;lambda_0). $
If $lambda_0=P_0 x_0$, then
$ x_1=(a+b P_0)x_0, quad lambda_1=(c+d P_0)x_0. $
Whenever $a+b P_0$ is invertible, the propagated graph is
$ boxed(P_1=(c+d P_0)(a+b P_0)^(-1)). $ <mobius>
This fractional-linear (Möbius) update is the graph-coordinate version of a
linear state–costate transition. A symplectic map takes Lagrangian subspaces to
Lagrangian subspaces, so $P_1$ remains symmetric whenever this chart exists.
Symplecticity *alone* does not guarantee positive semidefiniteness for arbitrary
maps, time directions, or initial graphs.

To enforce the terminal condition in the constant-coefficient case, propagate
*from T back to t*:
$ mat(X(t);Y(t))=e^((t-T)F_L)mat(I;P_f), quad P(t)=Y(t)X(t)^(-1). $
The sign $t-T<=0$ is essential. If the top block loses invertibility, the
subspace may remain well-defined even though this graph coordinate becomes
singular. For standard finite-horizon LQR with the stated nonnegative costs,
the value remains finite on a finite interval; graph singularities are more
general Riccati phenomena, not inevitable LQR blow-up.

== A complete scalar finite-horizon calculation

For $dot(x)=u$, $Q=R=1$, and $P_f=0$, set $tau=T-t>=0$.
Here $F_L=mat(0,-1;-1,0)$ and $F_L^2=I$, giving
$ e^(-tau F_L)=mat(cosh(tau),sinh(tau);sinh(tau),cosh(tau)). $
Apply it to the terminal graph $mat(1;0)$:
$ X=cosh(tau), quad Y=sinh(tau), quad P(t)=tanh(T-t). $
Indeed $dot(P)=P^2-1$, $P(T)=0$, and $P(t) arrow.r 1$ as the remaining horizon
grows. The corresponding feedback is $u=-tanh(T-t)x$. With no terminal penalty,
control weakens as the endpoint approaches because there is less future state
cost left to avoid. This is the curve on page 7, right.

*Numerical limitation.* Long products of state–costate transitions contain both
growing and decaying modes. Forming one huge exponential and dividing its blocks
can lose accuracy. Subspace reorthogonalization, graph reinitialization, or
specialized Riccati methods are preferable for difficult long horizons.

#pagebreak()
= Discrete-time control: symplectic matrices and pencils

For $x_(k+1)=A x_k+B u_k$ with stage cost
$1/2(x_k^T Q x_k+u_k^T R u_k)$, the optimality conditions are
$ u_k=-R^(-1)B^T lambda_(k+1), quad
  lambda_k=Q x_k+A^T lambda_(k+1). $
Again put $G=B R^(-1)B^T$. Then
$ x_(k+1)=A x_k-G lambda_(k+1). $
Notice the mixed time indices: replacing $lambda_(k+1)$ by $lambda_k$ does
not give the correct discrete optimality equations.

== When A is invertible: an ordinary symplectic transfer

Eliminate $lambda_(k+1)=A^(-T)(lambda_k-Q x_k)$ to obtain
$ mat(x_(k+1);lambda_(k+1))=S_d mat(x_k;lambda_k), $
$ S_d=mat(A+G A^(-T)Q,-G A^(-T);-A^(-T)Q,A^(-T)). $
It is symplectic; one proof factors it as
$ S_d=mat(I,-G;0,I)mat(A,0;0,A^(-T))mat(I,0;-Q,I). $
Each factor is one of the blocks on page 2. On an invariant graph $lambda_k=P x_k$,
$ x_(k+1)=(I+G P)^(-1)A x_k=(A-B K)x_k, $
where $K=(R+B^T P B)^(-1)B^T P A$. Substitution in the costate equation yields
$ P=Q+A^T P(I+G P)^(-1)A $
$ P=Q+A^T P A-A^T P B(R+B^T P B)^(-1)B^T P A. $ <dare>
This is the DARE. The stabilizing graph selects the eigenvalues of $S_d$ *inside
the unit circle*; their reciprocals lie outside. Continuous-time stability uses
the left half-plane, not the unit disk.

== Singular dynamics: do not force an inverse that does not exist

Many legitimate systems have singular $A$, including sampled models with
zero modes. Keep the optimality relations as a matrix pair:
$ M mat(x_k;lambda_k)=L mat(x_(k+1);lambda_(k+1)), $
$ M=mat(A,0;-Q,I), quad L=mat(I,G;0,A^T). $
Direct multiplication gives the symplectic-pair identity
$ M J M^T=L J L^T=mat(0,A;-A^T,0). $
The generalized eigenproblem $M v=mu L v$ describes its modes. If $L$ is
invertible it reduces to $S_d=L^(-1)M$; otherwise use the pencil $M-mu L$ and
a generalized Schur/QZ method. Under the standard discrete stabilizability and
detectability assumptions, its stable deflating subspace represents the
stabilizing solution. Production solvers may use an *extended* pencil rather
than this reduced pair @scipydare.

This connects directly to the site's
#link("../../Control/sda-algorithm/sda-algorithm.pdf")[SDA note]
and #link("../qz-algorithm/qz-algorithm.pdf")[QZ note]: doubling composes optimal-control
blocks while retaining the pair structure; QZ isolates a stable deflating subspace
without forming $L^(-1)M$.

#pagebreak()
= What to check in practice

*Coordinates first.* Identify the ordering and the actual canonical variables.
Interleaving $(q_1,p_1,q_2,p_2,...)$ permutes $J$; positions and velocities may
require a different form. A failed test with the wrong $J$ says little.

*Test the right object.* For a transition test $S^T J S-J$; for a generator test
$F^T J+J F$; for a pair test $M J M^T-L J L^T$. Evaluate scaled residuals,
not exact floating-point equality. For example,
$ r_S=norm(S^T J S-J)_F/(norm(S)_2^2 norm(J)_F+norm(J)_F). $
A small residual is a useful diagnostic, not a certificate of a small distance
to the symplectic group when matrices are badly scaled or ill-conditioned.

*For Riccati solutions, also test the branch.* Check symmetry, the CARE/DARE
residual, and the poles of $A-B K$. A zero equation residual does not distinguish
the stabilizing and destabilizing solutions. Poor separation near the imaginary
axis or unit circle, and an ill-conditioned upper subspace block, make the
problem numerically sensitive @scipycare @scipydare.

== Reproduce the figures and numerical checks

The companion script uses the existing Octave `control` package. From the
repository root:
```sh
QT_QPA_PLATFORM=offscreen octave --no-gui --quiet \
  Mathematics/symplectic-matrices/scripts/verify_and_plot.m
typst compile Mathematics/symplectic-matrices/symplectic-matrices.typ
```
It regenerates all three figures and checks: the four-dimensional counterexample;
the oscillator's exact modified invariant and both sides of the step-size
stability boundary; the exact double-integrator LQR solution; the finite-horizon
hyperbolic formula; an asymmetric discrete-time graph; a singular-dynamics pair;
and the optical transfer identity. No simulation-derived number is used as an
independent expected answer.

== Three questions to test understanding

+ *Does a symplectic squeeze preserve oscillator energy?* No: $(1,0)$ becomes
  $(2,0)$, so $(q^2+p^2)/2$ increases from $1/2$ to $2$ although canonical area stays fixed.
+ *Can every pole of a symplectic matrix be strictly inside the unit circle?*
  No: reciprocal pairing forbids it. A closed-loop controller contracts on a
  stable graph, not throughout the entire state–costate space.
+ *Why is the LQR value Hessian symmetric?* The value is a scalar Hessian;
  equivalently, its graph is Lagrangian. The latter explanation remains visible
  even when computing the solution from an invariant subspace.

#insight[
  *The unifying picture:* canonical pairing → Hamiltonian generator → symplectic
  flow → preserved Lagrangian subspaces → symmetric Riccati graphs. Physics
  uses the full flow; optimal control selects the stable graph inside it.
]

#set text(size: 8.5pt)
#set par(leading: 0.4em)
#bibliography("refs.bib", title: [Sources and further reading], style: "ieee")
