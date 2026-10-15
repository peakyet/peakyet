// Standalone: typst compile --root . <this file> <same stem>.pdf
#set document(title: "Systems, signals, and stability: what a transfer matrix can tell you", author: "Amp")
#set page(paper: "a4", margin: (x: 24mm, y: 21mm),
  header: text(size: 9pt, fill: rgb("#5b6470"))[Robust control · Chapter 1],
  footer: context align(right, text(size: 9pt, counter(page).display("1"))))
#set text(font: "Libertinus Serif", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show heading: set text(fill: rgb("#1f4e79"))
#let takeaway(body) = block(width: 100%, inset: 10pt, fill: rgb("#edf5f5"),
  stroke: (left: 2pt + rgb("#0f766e")), body)

#text(size: 23pt, weight: "bold", fill: rgb("#1f4e79"))[Systems, Signals, and Stability]

#text(size: 15pt)[What a transfer matrix can — and cannot — tell you]

A controller processes signals, not matrices. Before asking whether it is robust,
we must decide what counts as a large signal, what behavior must decay, and whether
our mathematical representation hides something important.

Consider a device with one slow response and one faster, coupled response:
$ dot(x)_1=-x_1+u, quad dot(x)_2=3x_1-2x_2, quad y=x_2. $
The input first changes $x_1$; only then does $x_1$ drive the measured output.
There is memory: two devices receiving the same input now can produce different
outputs if their states differ. The state is the information needed to predict
the future once the future input is specified.

= Start with the device, then choose a representation

For a continuous-time, finite-dimensional linear time-invariant (LTI) device,
$ dot(x)=A x+B u, quad y=C x+D u, quad x(0)=x_0. $ <eq:ss>
Here $x in RR^n$, $u in RR^m$, $y in RR^k$; the matrix sizes are
$A:n times n$, $B:n times m$, $C:k times n$, $D:k times m$.
Inputs are piecewise continuous and locally bounded. Integrating the differential
equation gives
$ x(t)=e^(A t)x_0+integral_0^t e^(A(t-tau))B u(tau) dif tau. $
To verify this formula, differentiate it: the moving upper endpoint supplies $B u(t)$,
and the remaining terms give $A x(t)$. Hence
$ y(t)=C e^(A t)x_0+integral_0^t h(t-tau)u(tau) dif tau+D u(t),
  quad h(t)=C e^(A t)B. $ <eq:conv>
The three terms mean *initial memory*, *accumulated input history*, and *instantaneous
feedthrough*. $h$ is the ordinary impulse-response kernel; $D$ is kept separate,
not treated as an ordinary function at time zero.

#takeaway[Our route: memory → transfer matrix → hidden modes → signal sizes → worst-case
  gains → stability → inversion. Sections 1–6 are the main explanation. The five
  book exercises are a separate worked guide, not prerequisites for reading it.]

#pagebreak()
= A transfer matrix records the zero-state experiment

Let $hat(u)(s)=integral_0^infinity e^(-s t)u(t) dif t$ where it converges.
Taking Laplace transforms of @eq:ss gives
$ (s I-A)hat(x)=x_0+B hat(u), $
$ hat(y)=C(s I-A)^(-1)x_0+G(s)hat(u), quad G(s)=C(s I-A)^(-1)B+D. $
Only when $x_0=0$ does the whole relation become $hat(y)=G hat(u)$.
The transfer matrix describes a *zero-initial-state input–output map*, not every
possible response from a stored initial condition.

For our two-state example,
$ A=mat(-1,0;3,-2), quad B=mat(1;0), quad C=mat(0,1), quad D=0. $
Solving the triangular equations, rather than expanding a matrix inverse,
$ (s+1)hat(x)_1=hat(u), quad (s+2)hat(x)_2=3hat(x)_1, $
so $G(s)=3/((s+1)(s+2))$. For a unit step and zero initial state,
$ x_1(t)=1-e^(-t), quad y(t)=3/2-3e^(-t)+(3/2)e^(-2t). $
The output starts with zero slope: the input must pass through two memories.
Its final value $3/2$ is also $G(0)$, the static gain.

#figure(image("assets/basics.svg", width: 100%), caption: [One input, two different
  memories. The coupled state responds later than the directly driven state.
  Right: adding an unmeasured unstable memory leaves this transfer experiment unchanged.])

Every entry of $G$ is *proper rational*: numerator degree does not exceed denominator
degree, so $G(infinity)=D$ is finite. Strictly proper means $D=0$.
Conversely, every proper real-rational matrix has a finite-dimensional realization:
realize each scalar entry with integrator chains, distribute inputs by columns,
and add outputs by rows. Exercise 1 makes this construction explicit.

A realization is not unique. Changing coordinates $z=T x$ for invertible $T$ gives
$(T A T^(-1),T B,C T^(-1),D)$ with exactly the same $G$. Adding a state the
experiment never sees also preserves $G$ — but that is a more consequential change.

#pagebreak()
= Hidden modes: why the realization matters

Append $dot(q)=q+u$, but leave $y=x_2$. With zero initial state and unit input,
$q(t)=e^t-1$ diverges, while $y(t)$ remains the response on the previous page.
The extra mode is driven by the input but unobservable at the output. Alternatively,
$dot(q)=q$ with $y=x_2+q$ gives an observable but uncontrollable mode: it is absent
from the zero-state experiment, yet $q(0)!=0$ changes the output dramatically.

*Controllable* means that inputs can reach every state direction. *Observable* means
that the output history with known input distinguishes every initial state.
An unreachable or invisible direction can be removed without altering $G$.
A realization has the fewest possible states (*minimal*) exactly when it is both
controllable and observable. In the original example,
$ mat(B,A B)=mat(1,-1;0,3), quad mat(C;C A)=mat(0,1;3,-2), $
whose determinants are $3$ and $-3$. Both have full rank: those two memories are needed.

== Three different stability questions

#table(columns: (1fr,2.6fr), inset: 7pt, stroke: 0.4pt + luma(180),
  [*Internal*], [Does every autonomous state decay? For this realization: $A$ is
    Hurwitz, meaning all eigenvalues have strictly negative real part.],
  [*External / transfer*], [Is the proper rational $G$ free of poles in the closed
    right half-plane, after exact cancellations?],
  [*BIBO*], [With $x_0=0$, does every bounded input give a bounded output?])

For finite-dimensional proper rational systems, transfer stability and zero-state
BIBO stability are equivalent (Exercise 5). Internal stability implies both.
The converse fails for the appended $q$: a stable transfer is not a certificate
that every internal variable is safe. If nonzero initial conditions are allowed,
state their role separately; they are not inputs in the gain definitions below.

Full minimality is stronger than needed to recover the converse. It is enough that
uncontrollable and unobservable modes are already stable: these conditions are
*stabilizability* and *detectability*. Equivalently, for every $lambda$ with
$"Re" lambda>=0$,
$ "rank" mat(A-lambda I,B)=n, quad "rank" mat(A-lambda I;C)=n. $
The first test is *full row rank*, the second *full column rank*. They exclude an
unstable mode hidden from either port. Under both tests, stable $G$ implies Hurwitz $A$.
Checking all complex $lambda$, rather than only the closed right half-plane,
gives controllability and observability.

#takeaway[Before cancelling poles, ask what claim is needed. A transfer simplification
  preserves the zero-state output, not the safety of hidden physical states.]

#pagebreak()
= Signal size: a peak budget is not an energy budget

For a vector signal use the Euclidean norm *at each instant*:
$ norm(u)_infinity="ess sup"_(t>=0) sqrt(u(t)^T u(t)), quad
  norm(u)_2=sqrt(integral_0^infinity u(t)^T u(t) dif t). $
We use essential supremum so isolated values at jumps do not change a norm. For
continuous signals it equals the ordinary supremum; piecewise-continuous endpoint
values may be chosen consistently. $norm(u)_2^2$ is energy; $norm(u)_2$ is its square
root. There is no stochastic expectation here.

A scalar rectangular pulse of height $a$ and duration $T$ has peak $|a|$ and
$L_2$ norm $|a|sqrt(T)$. Thus height 2 for 0.25 seconds has peak 2 and norm 1;
height 0.5 for 16 seconds has peak 0.5 and norm 2. Which is worse depends on the budget.

For $x_0=0$, define the induced gains
$ gamma_"peak"=sup_(0<norm(u)_infinity<infinity) norm(G u)_infinity/norm(u)_infinity,
  quad gamma_"energy"=sup_(0<norm(u)_2<infinity) norm(G u)_2/norm(u)_2. $
Here $G u$ means the time-domain response, not pointwise multiplication.
The supremum ranges over whole input histories. Each gain is the smallest uniform
constant in its corresponding input–output inequality.

In this finite-dimensional rational setting, mapping every $L_2$ input to an $L_2$
output is also equivalent to transfer stability (a standard result invoked here).
Thus peak and energy agree on this qualitative test, but not on the numerical gain.

== A signal can arrange constructive addition in time

Take the stable scalar transfer
$ H(s)=(s-1)/((s+1)(s+2))=-2/(s+1)+3/(s+2). $
Its kernel $h(t)=-2e^(-t)+3e^(-2t)$ changes sign at $r=ln(3/2)$.
For any bounded scalar input,
$ |y(T)|<=norm(u)_infinity integral_0^T |h(r)| dif r. $
Choose $u(t)="sign" h(T-t)$ for $0<=t<=T$: the input reverses the kernel's
signs in reverse time, making every contribution at $T$ positive. Therefore
$ gamma_"peak"=integral_0^infinity |h(r)| dif r=5/6. $
Indeed $integral_0^r h=1/6$ at the sign change, while $integral_0^infinity h=-1/2$;
the absolute integral is $2(1/6)-(-1/2)=5/6$.
This is a computable time-domain formula for stable, strictly proper SISO systems,
not a maximum of a frequency response. With scalar feedthrough $d$, add $|d|$.
For vector signals the instantaneous Euclidean convention matters: do not silently
replace it with a componentwise maximum or a matrix row-sum formula.

#pagebreak()
= Energy gain: the worst frequency and the worst direction

For a stable proper transfer matrix,
$ gamma_"energy"=norm(G)_infinity:=sup_(omega in RR) sigma_max(G(i omega)). $
At each frequency the largest singular value chooses the input direction with the
largest Euclidean amplification. The frequency supremum then chooses the worst
oscillation rate. This formula is the $H_infinity$ norm on $cal(R H)_infinity$,
the real-rational, proper, stable transfer matrices.

Why energy? Fourier transformation preserves squared norm up to a factor $1/(2pi)$.
At each frequency, $norm(G(i omega)hat(u))<=sigma_max(G(i omega))norm(hat(u))$.
Square, integrate, and apply Parseval: $norm(y)_2<=norm(G)_infinity norm(u)_2$.
Long finite bursts of the worst oscillation approach this bound; Exercise 2 explains
the phase choice and the limiting argument. An infinite sinusoid is not an $L_2$ input.

For the sign-changing example on the previous page, put $z=omega^2$:
$ |H(i omega)|^2=(z+1)/((z+1)(z+4))=1/(z+4). $
Its energy gain is $1/2$, smaller than its peak gain $5/6$. A long nearly constant
pulse approaches the energy gain. A sign-switched history instead exploits the
positive and negative lobes of the kernel to make a large instantaneous peak.

#figure(image("assets/gains.svg", width: 100%), caption: [Same stable device, different
  questions. Left: the signed kernel and the area that determines scalar peak gain.
  Right: the frequency magnitude whose maximum determines energy gain.])

== MIMO means choosing a direction, not a large entry

Let $G(s)=M/(s+1)$ with $M=mat(1,2;0,1)$. Then
$ M^T M=mat(1,2;2,5), quad lambda_(max)=3+2sqrt(2), $
so $norm(G)_infinity=1+sqrt(2)=2.414214$, at zero frequency. The worst unit input
direction is proportional to $mat(1;1+sqrt(2))$, not either coordinate axis.
The largest individual entry has gain only 2. Coordinated inputs can do worse.

#takeaway[The infinity on $norm(G)_infinity$ names a supremum over frequency.
  It does *not* mean that this is the induced peak-to-peak signal gain.]

#pagebreak()
= Inversion: can the device be undone in real time?

Suppose a square stable device maps $w$ to $z$. Algebraic invertibility means
$det G$ is not identically zero. A usable exact inverse must also be *proper* and
*stable*: it must not differentiate arbitrary bounded measurements or amplify a
hidden inverse mode without bound.

#table(columns: (1fr,1.1fr,1.5fr), inset: 7pt, stroke: 0.4pt + luma(180),
  table.header([Stable device $G$],[Algebraic inverse],[Obstruction]),
  [$1/(s+2)$],[$s+2$],[Improper: requires differentiation.],
  [$(s-1)/(s+2)$],[$(s+2)/(s-1)$],[Proper, but pole at $+1$.],
  [$(s+3)/(s+2)$],[$(s+2)/(s+3)$],[Proper and stable.])

For *square, stable, proper* $G$, the exact test is:
$ G(infinity) " is nonsingular, and " det G(s) " has no zeros for Re " s>=0. $
The first condition prevents a pole of the inverse at infinity. The second prevents
finite unstable inverse poles. To see sufficiency, use
$G^(-1)="adj"(G)/det G$. The adjugate entries are sums of products of stable
entries. The reciprocal determinant has neither forbidden finite poles nor a pole
at infinity. Necessity follows from $G G^(-1)=I$, including its limit at infinity.
Stability of $G$ is essential: for
$ G=mat((s+1)/(s+2),1/(s-1);0,(s+2)/(s+1)), $
the determinant is 1 but the inverse's off-diagonal entry is $-1/(s-1)$.

== Derive the inverse realization from the signals

Start with $dot(x)=A x+B w$, $z=C x+D w$. If $D$ is nonsingular,
$ w=D^(-1)z-D^(-1)C x, $
$ dot(x)=(A-B D^(-1)C)x+B D^(-1)z. $
Thus the inverse realization is
$ (A-B D^(-1)C, B D^(-1), -D^(-1)C, D^(-1)). $
For the stable scalar family $G=(s+b)/(s+2)$, use
$A=-2$, $B=1$, $C=b-2$, $D=1$. The inverse state matrix is $-b$.
The examples in the table correspond to $b=-1$ and $b=3$.

If the original realization is stabilizable and detectable, the inverse realization
is too: the new state matrix is both a state-feedback perturbation $A+B(-D^(-1)C)$
and an output-injection perturbation $A+(-B D^(-1))C$; the new input/output matrices
differ by invertible port scalings. The two PBH ranks are therefore unchanged.
Hence, with this assumption, a stable proper inverse exists exactly
when $D$ is invertible and $A-B D^(-1)C$ is Hurwitz. Without the assumption an
irrelevant hidden unstable state could make the matrix test fail for a stable inverse.

#takeaway[Carry three questions forward: which internal modes decay, which signal
  norm is being bounded, and whether an inverse is actually stable and proper.]

#pagebreak()
= Worked exercise guide — separate from the main route

These are the five exercises on book pp. 14–15. The Matlab-specific command is
documented but not executed here; the numerical checks use installed Octave control.

== Exercise 1 — build a realization, then remove redundant memory

The requested matrix is
$ G(s)=mat(1/s,1/(s+1)^2,s/(s+1);
 (s^2-3s+5)/(2s^3+4s+1),1/s,1/(s+1)). $
To use Matlab `sysic`, make six SISO blocks, distribute each input down its column,
and sum each row. The following is the wiring, with `s=tf('s')`:
```matlab
g11=1/s; g12=1/(s+1)^2; g13=s/(s+1);
g21=(s^2-3*s+5)/(2*s^3+4*s+1); g22=1/s; g23=1/(s+1);
systemnames='g11 g12 g13 g21 g22 g23';
inputvar='[u{3}]';
outputvar='[g11+g12+g13; g21+g22+g23]';
input_to_g11='[u(1)]'; input_to_g21='[u(1)]';
input_to_g12='[u(2)]'; input_to_g22='[u(2)]';
input_to_g13='[u(3)]'; input_to_g23='[u(3)]';
Gstack=ss(sysic); Gmin=minreal(Gstack);
```
Matlab Robust Control Toolbox is not available, so this snippet is not a claimed
execution result. Here is a fully specified hand realization, independently checked
by `scripts/ex1.m`. It uses nine states:
$ dot(x)_1=u_1, quad dot(x)_2=x_3, quad dot(x)_3=-x_2-2x_3+u_2, $
$ dot(x)_4=-x_4+u_3, quad dot(x)_5=x_6, quad dot(x)_6=x_7, $
$ dot(x)_7=-(1/2)x_5-2x_6+u_1, quad dot(x)_8=u_2, quad dot(x)_9=-x_9+u_3, $
$ y_1=x_1+x_2-x_4+u_3, quad y_2=(5/2)x_5-(3/2)x_6+(1/2)x_7+x_8+x_9. $
For example, $s hat(x)_5=hat(x)_6$ and $s hat(x)_6=hat(x)_7$ give
$hat(x)_5=hat(u)_1/(s^3+2s+1/2)$. Its output coefficients produce exactly the
requested cubic fraction. Also $u_3-x_4$ gives $s/(s+1)$: the feedthrough sign is positive.

States $x_4$ and $x_9$ obey identical driven equations, so with zero initial conditions
they are the same signal. Replace both by one state $z$, read as $-z+u_3$ in $y_1$
and $z$ in $y_2$: eight states suffice. Why not fewer? At zero the residue has rank 2,
requiring two states. At $-1$ the entry $G_12$ has pole order 2, while the minor
formed from columns 2 and 3 has pole order 3 (its leading term is $1/(s+1)^3$).
Thus at least three local states are needed there. The cubic has three distinct
roots, none cancelled by its numerator, contributing three more. The lower bound
is $2+3+3=8$, attained by the shared-state construction. `minreal` agrees.

#pagebreak()
== Exercise 2 — prove the energy bound and explain sharpness

Assume $G$ is stable and proper and $x_0=0$. Extend signals by zero to negative time.
For arbitrary $L_2$ signals, $hat(u)(i omega)$ denotes the Fourier transform in the
$L_2$ sense; a pointwise improper Laplace integral on the boundary need not exist.
The symbol $*$ means conjugate transpose. The singular-value inequality gives
$ hat(y)^*hat(y)=hat(u)^*G^*G hat(u)<=norm(G)_infinity^2 hat(u)^*hat(u) $
almost everywhere. Integrating yields the exercise's frequency-integral inequality.
Parseval then gives
$ norm(y)_2^2=(1/(2pi))integral_(-infinity)^infinity hat(y)^*hat(y) dif omega
 <=norm(G)_infinity^2 norm(u)_2^2. $
Consequently $gamma_"energy"<=norm(G)_infinity$.

*Sharpness construction and convergence argument.* First choose a finite
$omega_0>0$ and a complex unit right singular vector $v$ for $G(i omega_0)$.
Use a real input burst
$ u_T(t)=cases("Re"(v e^(i omega_0 t)) & 0<=t<=T, 0 & "otherwise"). $
It is important to take the real part *after* including $v$: different input
components may need different phases. A real vector times a common cosine does
not generally realize a complex singular direction.

During the burst, the output is its sinusoidal steady state
$"Re"(G(i omega_0)v e^(i omega_0 t))$ plus a decaying transient. Justify this
using a stable realization of $G$: the complex particular state is
$(i omega_0 I-A)^(-1)B v e^(i omega_0 t)$; its initial mismatch evolves under
$e^(A t)$. Both the initial transient energy and the post-burst tail energy are
bounded independently of $T$, because that particular state is bounded and $A$
is Hurwitz. A nonminimal unstable realization is unnecessary for this argument.

For any complex vector $a$ and fixed positive $omega_0$,
$ integral_0^T norm("Re"(a e^(i omega_0 t)))^2 dif t
  =(T/2)norm(a)^2+O(1). $
This follows by expanding the sine and cosine squares: their averages are $1/2$,
and all oscillatory integrals stay bounded. Transient cross terms are also bounded
by exponential integrability. Therefore
$ norm(G u_T)_2^2=(T/2)norm(G(i omega_0)v)^2+O(1), quad
  norm(u_T)_2^2=T/2+O(1). $
Their ratio tends to $sigma_max(G(i omega_0))^2$.

At $omega_0=0$, choose a real singular vector and a constant pulse; the leading
energies are $T norm(G(0)v)^2$ and $T$. If the supremum is approached only at
infinite frequency, choose *finite* frequencies $omega_j$ approaching it, then
choose each burst long enough to be within $1/j$ of that frequency's gain. The same
diagonal choice works for any nonattained supremum. Thus a sequence of real,
finite-energy inputs approaches $norm(G)_infinity$, proving the reverse inequality.

#pagebreak()
== Exercise 3 — a worst input need not hit its peak at a finite time

For $dot(x)=a x+u$, $y=x$, $x(0)=0$, and $a<0$,
$ |y(t)|<=norm(u)_infinity integral_0^t e^(a r) dif r
  =norm(u)_infinity (1-e^(a t))/(-a). $
The unit step $u(t)=1$ gives equality at every time and
$ norm(y)_infinity=sup_(t>=0)(1-e^(a t))/(-a)=1/|a|. $
Therefore $gamma_"peak"=1/|a|$, and *the step is a worst input*.
The output never reaches its supremum at a finite instant, but its signal norm
equals that supremum. Nonattainment of a maximum in time is not nonattainment of
the induced gain by an input. The input need not have finite energy in this exercise.

For $a=0$, the same bounded input gives $y(t)=t$. For $a>0$ it gives
$y(t)=(e^(a t)-1)/a$. Both are unbounded: the peak gain is infinite.

== Exercise 4 — discrete-time peak gain from absolute row sums

Assume real SISO data, $x_0=0$, and all eigenvalues of $A$ strictly inside the unit disk.
Set $h_0=D$, $h_j=C A^(j-1)B$ for $j>=1$. Iteration gives
$ y_k=sum_(j=0)^k h_j u_(k-j), quad
  mat(y_0;y_1;dots;y_m)=
  mat(h_0,0,dots,0;h_1,h_0,dots,0;dots,dots,dots,dots;h_m,h_(m-1),dots,h_0)
  mat(u_0;u_1;dots;u_m). $
Call the displayed Toeplitz matrix $M_m$. The induced vector infinity norm is its
maximum absolute row sum. Row $k$ sums to $sum_(j=0)^k |h_j|$; these partial sums
are nondecreasing, so the last row is largest. The bound is sharp: choose
$u_(m-j)="sign" h_j$, $0<=j<=m$, to align every term in $y_m$.
Extending this finite input by zeros makes a valid infinite bounded input. Hence
$ gamma_"peak"=sup_m norm(M_m)_infinity=|D|+sum_(j=0)^infinity |C A^j B|. $
The series converges because powers of a stable finite matrix admit a geometric
bound (with a slightly larger decay factor if there are Jordan blocks).

For an asymmetric check take $A=-1/2$, $B=1$, $C=2$, $D=1/4$.
The kernel is $1/4,2,-1,1/2,-1/4,dots$, so
$ gamma_"peak"=1/4+2/(1-1/2)=17/4=4.25. $
At horizon $m$, the exact row sum is $4.25-4(1/2)^m$. For $m=6$ it is $4.1875$;
the sign-aligned input attains this value at sample 6. Simply using a positive
constant input would miss the alternating signs and give a smaller steady output.

#pagebreak()
== Exercise 5 — prove zero-state BIBO equivalence carefully

We prove the theorem for the book's finite-dimensional proper rational setting,
with zero initial state. Properness is automatic in @eq:ss; no differentiator case
needs to be added to this theorem.

*Stable transfer implies BIBO.* Take a minimal realization $(A_r,B_r,C_r,D)$
of $G$, not necessarily the originally supplied realization. Since $G$ is stable,
$A_r$ is Hurwitz. There exist $M,alpha>0$ such that
$norm(e^(A_r t))<=M e^(-alpha t)$. Therefore the kernel is integrable and
$ norm(y(t))<=lr((norm(D)+integral_0^infinity norm(C_r e^(A_r r)B_r) dif r))
  norm(u)_infinity, $
where the parenthesis is at most $norm(D)+norm(C_r)M norm(B_r)/alpha$.
The zero-state outputs of the original and reduced realizations agree, so the
bound applies even if the original realization has unstable hidden modes.
One must not infer “$G$ stable implies $A$ Hurwitz” without the extra hypotheses.

*BIBO implies stable transfer.* Suppose an entry $g_(i j)$ has a pole
$lambda$ with nonnegative real part. Only input channel $j$ is needed.
If there is any pole in the open right half-plane, use a scalar unit step on that
channel. Its output transform is $g_(i j)(s)/s$; no pole in the open right
half-plane is cancelled by division by $s$. The corresponding exponential-polynomial
term grows without bound. Real poles give growing real exponentials; conjugate
nonreal poles give growing oscillations. Thus this bounded input violates BIBO.

If there are no open-right-half-plane poles but a pole $i omega_0$ on the imaginary
axis, use the bounded complex input $e^(i omega_0 t)$. Division by $s-i omega_0$
increases that pole's order from $r>=1$ to $r+1$, yielding a nonzero term
proportional to $t^r e^(i omega_0 t)$ in the output. This is unbounded.
At least one of the *real* inputs $cos(omega_0 t)$ and $sin(omega_0 t)$ has an
unbounded real output, since the complex response is the real response plus $i$
times the imaginary response. At $omega_0=0$, use the constant input directly.
So no closed-right-half-plane pole is possible. Since $G$ is already proper, it
must be stable. This proves both directions.

== Reproduce and keep the distinctions straight

Run from the repository root:
```sh
octave --no-gui --quiet Control/robust-control-01-basics/scripts/ex1.m
typst compile --root . Control/robust-control-01-basics/robust-control-01-basics.typ
```
The script checks realizations, norms, inverse poles, step responses, and discrete
row sums; it regenerates both figures without extra packages beyond Octave control.
The numerical checks corroborate examples, not the general proofs.

#text(size: 9.5pt)[*Source.* Scherer, chapter 1, pp. 6–15,
@schererTheoryRobustControl. The route, examples, figures, and worked derivations
are developed here. Standard realization/minimality and Fourier–Parseval results
are invoked, not reproved. The book's stabilizability rank typo is corrected to
full row rank. Matlab `sysic` remains unexecuted.
#bibliography("refs.bib", title: none)]
