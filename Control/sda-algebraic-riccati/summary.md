# Current understanding: SDA for the algebraic Riccati equation

**Artifact:** `Control/sda-algebraic-riccati/sda-algebraic-riccati-deck.html` (draft deck, KaTeX CDN).
The deck is filed with `-deck.html` because the slug has a tracked long-form page in `HEAD`
(`sda-algebraic-riccati.html`). No landing-page card has been added yet; the deck is not discoverable
until all planned sections pass the understanding gate and verification is complete.

**Current section:** 1, `What problem is SDA solving?`, awaiting the user's explain-back and prediction
answer.

## Audience calibration

| Node | Status | Notes |
|---|---|---|
| Basic linear algebra and matrix multiplication | assumed | Needed for block updates and Schur complements. |
| State-space control / LQR | assumed | The deck states the scalar LQR example rather than deriving LQR from scratch. |
| Algebraic Riccati equation as a stabilizing matrix quadratic | main topic | Section 1 teaches the stability-selection role with the scalar example. |
| Schur complement | taught briefly | Planned for section 3, where the SDA inverse appears. |
| Repeated squaring and quadratic convergence | taught briefly | Planned for section 2, using the doubling idea before Riccati updates. |
| Hamiltonian invariant-subspace view | assumed / linked | Section 1 only names it as an alternative route; section 6 connects it back. |

## Outline and frame map

| Section | Planned frames | Status |
|---|---|---|
| 1. What problem is SDA solving? | `#/3` divider, `#/4`-`#/7` content | draft; awaiting gate |
| 2. Repeated squaring | not built | planned, 3-4 frames |
| 3. The discrete Riccati rewrite | not built | planned, 4 frames |
| 4. From CARE to DARE | not built | planned, 4 frames |
| 5. What is preserved, and when it fails | not built | planned, 3-4 frames |
| 6. Connections and sources | not built | planned, 3 frames |

## Running example

Scalar unstable plant:
\[
\dot x=x+u,\qquad J=\int_0^\infty (x^2+u^2)\,dt.
\]
The CARE is
\[
1+2X-X^2=0,\qquad X=1\pm\sqrt2.
\]
The stabilizing solution is \(X_+=1+\sqrt2\). It gives closed loop \(A-GX_+=-\sqrt2<0\); the other root gives \(+\sqrt2\). This example will recur as the smallest CARE and as the target for the Cayley-to-DARE bridge.

Verified by `scripts/scalar_riccati.py`:
```text
X=-0.414213562373095 residual=-2.776e-16 closed_loop=1.414213562373095 stable=False
X=2.414213562373095 residual=0.000e+00 closed_loop=-1.414213562373095 stable=True
selected X=1+sqrt(2)=2.414213562373095
```

## Claims on current frames

- CARE form \(Q+A^*X+XA-XGX=0\) and the invariant-subspace relation are grounded in Poloni, §5.1, equations (37)-(38).
- The scalar example, root selection, and closed-loop stability check were verified by `scripts/scalar_riccati.py`.
- The statement that doubling constructs \(Q_k=X_{2^k}\) from a base fixed-point iteration and gives quadratic convergence is grounded in Poloni, abstract and §2/§4.

## Sources

- Federico Poloni, *Iterative and doubling algorithms for Riccati-type matrix equations: a comparative introduction*, arXiv:2005.08903v1, fetched and read this session. Grounds: CARE definition, Hamiltonian invariant-subspace relation, doubling/SDA lineage, and quadratic-convergence statement.
- E. K.-W. Chu, H.-Y. Fan, W.-W. Lin, *A structure-preserving doubling algorithm for continuous-time algebraic Riccati equations*, Linear Algebra and its Applications 396 (2005) 55-80, DOI `10.1016/j.laa.2004.10.010`; Crossref metadata fetched this session. Planned for section 4's CARE-to-DARE bridge; no frame claim yet.
- B. D. O. Anderson, *Second-order convergent algorithms for the steady-state Riccati equation*, International Journal of Control 28(2) (1978) 295-306, DOI `10.1080/00207177808922455`; Crossref metadata fetched this session. Planned for the historical lineage of doubling algorithms; no frame claim yet.
- T.-M. Huang, R.-C. Li, W.-W. Lin, *Structure-Preserving Doubling Algorithms for Nonlinear Matrix Equations*, SIAM, 2018, DOI `10.1137/1.9781611975369.ch1`; Crossref metadata fetched this session. Planned as the modern book-level reference.

## Verification state

- Scalar CARE numbers run with `python3 Control/sda-algebraic-riccati/scripts/scalar_riccati.py`.
- Headless Firefox screenshots checked frames `#/3`-`#/7` at 1440x900 and the deck at 420x1600. Frame 5 had an overfull box and was shortened; the corrected screenshot has no visible overfull tag. The draft is not ready for the landing-page card.
