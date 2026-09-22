# Current understanding: quasi-Newton methods

**Page:** [quasi-newton-method.html](quasi-newton-method.html) · **Category:** Optimization · **Slug:** `quasi-newton-method`

**Audience:** an engineer comfortable with multivariable Newton methods, matrix–vector products and positive-definite matrices, and iterative optimization vocabulary. The requested emphasis is **BFGS-first intuition**, with DFP, SR1, and L-BFGS placed around the central mechanism.

## Prerequisite map

| Topic | Calibration status | Treatment in the note |
| --- | --- | --- |
| Gradients, Hessians, and quadratic Taylor models | confirmed comfortable | assumed; Newton's direction is recalled briefly |
| Linear systems, inverse matrices, quadratic forms, SPD matrices | confirmed comfortable | used directly, with ellipse geometry as reinforcement |
| Descent directions, line searches, convexity, local/global convergence | confirmed comfortable | used directly; the Wolfe curvature role is explained |
| Curvature pairs \((s_k,y_k)\) and the secant equation | main topic | derived from gradient differences and taught visually |
| BFGS rank-two update and positive-definite preservation | main topic | taught in depth in inverse-Hessian form |
| DFP, SR1, and L-BFGS | supporting variants | compared after BFGS is established |

## Running example

The whole note uses

\[
f(x)=\tfrac12x^\top A x-b^\top x,
\qquad
A=\begin{bmatrix}4&1\\1&2\end{bmatrix},
\quad b=\begin{bmatrix}1\\1\end{bmatrix},
\quad x_0=\begin{bmatrix}2\\-1\end{bmatrix}.
\]

The exact minimizer is \(x^\star=A^{-1}b=(1/7,3/7)\), with \(f(x^\star)=-2/7\). Starting from \(H_0=I\) and using exact line searches:

| quantity | exact value |
| --- | --- |
| \(g_0\), \(p_0\) | \((6,-1)\), \((-6,1)\) |
| \(\alpha_0\) | \(37/134\) |
| \(x_1\) | \((23/67,-97/134)\) |
| \(s_0^\top y_0\) | \(1369/134>0\) |
| \(\alpha_1\) | \(134/259\) |
| \(x_2\) | \((1/7,3/7)=x^\star\) |
| \(s_1^\top y_1\) | \(2209/938>0\) |
| \(H_2\) | \(A^{-1}=\bigl[\begin{smallmatrix}2/7&-1/7\\-1/7&4/7\end{smallmatrix}\bigr]\) |

The interactive demo applies exact line searches to gradient descent, Newton, and BFGS on this same quadratic. It shows their paths, the selected iterate, numerical metrics, and an ellipse proportional to the current inverse-curvature model.

## Claims verified by running code

`python3 scripts/verify_quasi_newton.py` uses exact rational arithmetic and checks:

- the minimizer and objective values;
- both BFGS step lengths and iterates;
- positive curvature products \(s_k^\top y_k\);
- both inverse secant equations \(H_{k+1}y_k=s_k\);
- symmetry and positive definiteness of every inverse model;
- two-step termination and exact recovery \(H_2=A^{-1}\).

The note's browser demo independently implements the same objective, gradients, exact line search, and inverse-BFGS formula in JavaScript. Browser rendering and interaction checks are recorded in the delivery report rather than assumed here.

## Deliberate boundaries

- The note treats smooth unconstrained optimization. Constrained quasi-Newton updates appear only through the link to the SNOPT/SQP note.
- The finite-termination story is explicitly limited to strictly convex quadratics with exact line searches and exact arithmetic.
- Stochastic quasi-Newton methods, bound-constrained L-BFGS-B, and detailed convergence proofs are left for future notes.
- The direct-Hessian BFGS formula is shown, but the inverse form \(H_k\) drives the explanation and demo.
