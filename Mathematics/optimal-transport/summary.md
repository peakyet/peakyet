# Optimal Transport — production summary

**Stage:** Complete
**Artifact:** `Mathematics/optimal-transport/optimal-transport.typ` and `optimal-transport.pdf`
**Scope:** Reconstruct balanced discrete transport and its connection to probability
distances. Derive the one-dimensional W1 cumulative formula for finite distributions.
An optional extension explains entropy regularization and Sinkhorn's scaling updates.
General measure-theoretic proofs, transport duality, and production solver implementations
are outside this introduction.
**Assumed background:** Arithmetic and coordinates on a line. Matrices, summation,
distributions, coupling, and area/integral notation are introduced where used. The
Wasserstein metric theorem and the entropic scaling structure/convergence theorem
are explicitly taken as given with their assumptions and source.
**Running example:** Three units at 0 and one at 3 become two at 1 and two at 4;
unequal source weights make splitting and joint conservation unavoidable.

## Explanation progression

| Section | PDF page | Obstacle addressed | Picture or construction | Essential result explained |
|---|---|---|---|---|
| 1. Moving a shape, one piece at a time | 3 | Coordinating routes to meet a whole shape | Four squares at the start, halfway, and target | Valid plan with total travel cost 7 |
| 2. A grid that keeps every piece accounted for | 4 | Distinguishing route amounts from costs | Labeled route grid with supply/demand sums | Nonnegative entries, fixed marginals, weighted-cost minimization; plans allow splitting |
| 3. From a cheaper plan to a proven optimum | 6 | Improvement versus proof of optimality | Two units exchange destinations | Cost 11 to 7; net-displacement bound and complete scalar feasible family |
| 4. From sand to a distance between distributions | 7 | Probabilities, geometric comparison, and cost conventions | Normalize the running plan; compare one-unit shifts by 1 and 4 | W1 = 1.75; W2 squared = 4.75, W2 ≈ 2.179; the root and metric assumptions |
| 5. Solving transport on a ruler | 9 | Connecting travel distance to cumulative totals | A gate cuts a route; shaded CDF gap; source/target mass strips | Gate conservation, area as distance, ordered matching attains the lower bound |
| 6. How a computer chooses the routes | 12 | Understanding what a solver changes | Three proportional-bar stages of row/column scaling | Linear programming; optional entropy model, Sinkhorn updates, both marginal checks, regularized travel cost 1.847724 |
| 7. Sources and next steps | 15 | Orienting further reading | Source support and connection to the existing motion-planning note | Keep route amounts, conservation, and geometric cost distinct |

Bibliography: page 16. Cover: page 1. Contents: page 2. No demo is needed; static
constructions expose the operations without adding controls or dependencies.

## Follow-ups

- Next revision: None required. A later extension could derive transport duality or
  the entropic scaling structure after introducing constrained optimization.

## Unresolved claims

None within the stated scope.

## Sources consulted

| Source and passage read | Claim or assumptions supported |
|---|---|
| Gabriel Peyré and Marco Cuturi, *Computational Optimal Transport*, arXiv:1803.00567v4, Chapter 2 notation/definitions, §2.3 and Remark 2.11, §2.4 Proposition 2.2, §2.6 Remarks 2.28–2.30; §§4.1–4.2 Proposition 4.1, Proposition 4.3 and updates (4.12)–(4.15); numerical-stability Remark 4.7. [Versioned source](https://arxiv.org/abs/1803.00567v4). | Discrete distributions and couplings, plan versus map, the Kantorovich problem, metric/root assumptions, ordered matching and cumulative formula; entropy convention, positive scaling structure and convergence assumptions, small-regularization limit and underflow considerations. |

The sand example, exact arithmetic, finite gate argument, and figures are derived
in the note rather than borrowed numerical results.

## Checks and deviations

- `python Mathematics/optimal-transport/scripts/verify_optimal_transport.py` passed.
  Exact fractions verify conservation, cost 11 to 7, scalar endpoint/fractional cases,
  squared cost, normalized distances, and the first scaling stages. Exhaustive
  four-unit assignments independently confirm minima 7 and 19. Ordered matching
  agrees with cumulative area for unequal weights, rectangular plans, bidirectional
  motion, equal means with different shapes, zero weights, and identical measures.
- Sinkhorn reaches both marginal errors below 1e-12 in 18 iterations for
  epsilon = 1/ln(2). The computed plan is independently checked against the
  regularized scalar problem's analytic stationary point, not against itself.
- `typst compile --root . Mathematics/optimal-transport/optimal-transport.typ
  Mathematics/optimal-transport/optimal-transport.pdf` builds warning-free with
  Typst 0.15.1. Section page map is 3,4,6,7,9,12,15; total 16 pages.
- Every rendered page was inspected, including route directions, coordinates,
  shaded area widths/heights, mass-strip overlaps, common-scale scaling bars,
  fractions, subscripts, and line/page breaks. Corrected symbolic function
  arguments to remain on the main baseline rather than inside a subscript.
- The new landing card was exercised in headless Chrome: multi-token search,
  Mathematics and Optimization filters, exclusion by Algebra, matching tags/footer,
  dynamic note count, and the PDF's HTTP 200 response. Desktop and 420px captures
  were inspected; the card has no clipping or horizontal overflow.
- The related local motion-planning note exists. The PDF bibliography links the
  version actually consulted. No external package was installed.
- Shared 'Ilm cover, contents, numbered equations, and footers are retained.
  Intentional layout choice: un-justified paragraphs. No unavailable checks.
