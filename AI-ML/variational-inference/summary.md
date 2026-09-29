# Variational inference — teaching handoff

**Stage:** question map (published, rendering cleanly); teaching is mid-route at `s5`.

**Artifact:** `AI-ML/variational-inference/variational-inference.typ`, compiled to
`AI-ML/variational-inference/variational-inference.pdf`. No demo sidecar.

## Audience

An engineer who has done maximum likelihood and knows what a posterior density is, comfortable with
single-variable calculus and basic matrix algebra, but who has never written an ELBO. The logit
scale, the multivariate normal, and relative entropy are used on the page and defined there. The
only place curvature is leaned on is section 5, which the note flags as a second-order picture. The
reader met so far is unusually numerate: they redo the arithmetic between sections and check the
note's numbers.

## Route and assessment

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| `s1` | 3 | How does joint-peak / p(D) grow with d independent coins, and why does that ratio defeat a local search, a fine grid, and a uniform sample alike at d = 100? | The ratio is 2.9351 per coin, so (2.9351)^d — 5.8e46 at d = 100 — while the normalizer itself is trivial here, exactly (1/11)^d. p(D) is a *volume* correction, not a hard integral: the posterior's mass occupies a geometrically vanishing part of (0,1)^d, so anything that sees only heights (local search), spends resolution uniformly (100^d grid), or samples uniformly (hit probability ~2.9351^-d) fails for the same reason. Misconception to catch: "the trouble is that the integral is analytically difficult." | asked before a context compaction; attempt not recovered |
| `s2` | 4 | A chain cancels p(D) in every ratio: which two things does it still not hand you that section 1's closed form does, and what property does the changed prior destroy? | No normalizer, hence no event probabilities and no marginal likelihood for model comparison; and no density object — only m serially correlated draws, costing m evaluations of eq:tilt x eq:lik, judged trustworthy from inside the list itself. The destroyed property is conjugacy: Beta -> Beta(a+7, b+3) keeps the answer in the family, while a normal prior on phi = logit theta (a logistic-normal prior on theta) is not conjugate to the binomial. | asked before compaction; attempt not recovered |
| `s3` | 5 | Substitute eq:bayes into eq:relent, sort the q-dependent pieces from the q-independent one, say which you can now compute for the tilted model and which you give up, and why giving it up cannot change which member of Q wins. | KL(q, p(theta|D)) = int q log q - int q log p(theta,D) + log p(D). Only the last term is unevaluable and it carries no q, so it shifts every score by the same constant and cannot reorder Q. Everything else is closed form under a Beta q: the two digamma expectations of log theta and log(1-theta), the entropy, and eq:tilt's own log-density. The negative of the q-dependent part is the ELBO. Watch for "the dropped term is small" — it is not small and not approximate, it is exactly absent, which is why the result is a bound. | asked before compaction; attempt not recovered |
| `s4` | 6 | Combine the decomposition with the two facts: what relation must L(q) and log p(D) satisfy, when is it an equality, and what do stopping, "more iterations", and "a richer family" each certify? | log p(D) = L(q) + KL(q, p(theta|D)) >= L(q), equality iff q equals the posterior almost everywhere, which no member of Q does for the tilted model. Stopping certifies a stationary point of L within Q and therefore the same ordering of KL values within Q, but says nothing about the size of that KL because the offset log p(D) is off stage. More iterations cannot buy past the family's ceiling; only a richer family moves the ceiling, and the bound cannot tell you how far below it you sit. This is the unobserved-confounding step: the score optimized and the quantity wanted differ by an unknown constant. | asked before compaction; attempt not recovered |
| `s5` | 7 | Which of the three widths does each converged factor carry and what in the procedure decides it; what mass does the fitted product put where the contour has none, and which feature of the contour is beyond any choice of the twelve factors? | Each factor ends at 0.103 — the width of one coordinate given the other eleven — because when only theta_j moves the surviving term is the full conditional log p(theta_j | theta_-j, D), whose precision is P_jj. A cycling product fit is a product of full conditionals, not of marginals, and it never converges to the marginal width. The note's first bullet (a factor is the fit's own marginal) is the trap: the fit's marginal is not the truth's. Second half: the product puts mass in the off-diagonal corners of the rectangle the two teal rules span (one coin high, one low) where the tilted contour has almost none, and no product can carry the contour's tilt — every member of the family has zero pairwise correlation, so the 45-degree elongation and the 2.73 axis ratio are structurally unavailable. | question-ready |
| `s6` | 8 | Fit Q in both relative-entropy directions against the two-bump truth: where does each put its mean and spread, what in each integral forces that, and which report is more dangerous when a colleague samples from the bump you ignored? | Min KL(q ‖ p) is the ELBO direction and is mode-seeking: q log(q/p) diverges wherever q sits in the valley (p ~ 0.156), so the cheapest fit retreats inside one bump — Beta(26.69, 22.80), mean 0.539, sd 0.070, against a truth of mean 0.687, sd 0.161 — and drops the 0.85 bump outright. Min KL(p ‖ q) is mass-covering: truth mass where q ~ 0 costs infinity, so it straddles — Beta(5.46, 2.48), mean 0.688, sd 0.155 — at the price of real mass in the valley, where no coin lives. The ELBO report is the more dangerous one: its error is a confident dismissal of an outcome carrying about half the posterior mass, and its narrow interval hides that a second bump exists; the reverse fit's error sits in a region the colleague will never sample from, though its valley mass would corrupt any rule that reads the shape rather than the moments. Require the mechanism to come from the weighting inside each integral, not from a slogan. | question-ready |

Running example: one coin with unknown bias theta, ten flips, seven heads, uniform prior, so
p(D | theta) = 120 theta^7 (1 - theta)^3 and the exact posterior is Beta(8, 4). Section 2 replaces
the prior with a standard normal on phi = logit theta; section 5 moves to twelve coins under a
+0.99-correlated logit prior; section 6 swaps that prior for an equal mixture of Normal(0, 0.3^2)
and Normal(1.8, 0.3^2) on the same logit scale.

Keep expected insights here as teaching notes. Do not copy them into the question map.

## Current discussion point

The reader is attempting `s5` and has been computing the twelve-coin Laplace covariance by hand.
Their last message reported a posterior covariance with diagonal 0.11121 and off-diagonal -0.01628
for the +0.99 prior, and claimed the nearest-neighbour ("chain") prior is essentially exactly
solvable. Neither holds — see below, and answer with arithmetic rather than assertion. Next message:
`variational-inference.pdf#page=7` with the section 5 question quoted, and nothing more of the
expected insight than the correction itself requires.

## Unresolved or research-needed claims

- `s5` — the reader's matrix is not a covariance at all: a 12-by-12 equicorrelated matrix with
  diagonal 0.11121 and off-diagonal -0.01628 has variance of the sum
  12(0.11121) + 12 x 11(-0.01628) = -0.8144, an impossible negative number. This settles it without
  reference to the model.
- `s5` — for an equicorrelated prior plus diagonal data precision the posterior precision is
  alpha I + beta (ones')(ones') with alpha = 102.4998, beta = -8.3263, so
  P^-1 = (1/alpha)(I - (beta/(alpha + 12 beta))(ones')(ones')) gives diagonal 0.04119 and
  off-diagonal +0.03144, i.e. correlation +0.763 — the note's 0.203 and +0.763. The off-diagonal must
  be positive: the data never couples two coins, so the sign comes from inverting a prior precision
  whose off-diagonal is negative.
- `s5` — "the chain is approximately exactly solvable" is not what the sweep shows. At n = 10 the
  mean-field/marginal variance ratio is 0.605 for the chain against 0.814 for the dense prior, so the
  sparse prior is fit *worse* here; both approach 1 as data accumulate (0.961 against 0.996 at
  n = 100). Not claimed on the page; needed only if the reader returns to prior structure.
- `s5` — the three widths are Laplace quantities. The 0.1031 that the mean-field iteration reaches on
  the true logistic-normal model agrees with the curvature value 0.1030 because ten flips keeps each
  logit near-linear. A reader who objects that this is not exact is right; the agreement is a property
  of this data size, not a theorem.
- `s6` — which Beta is "forward" is easy to state backwards. The anchor is
  log p(D) = ELBO + KL(q ‖ p); the script prints gap == KL(q ‖ p) as True for both fits, and the
  ELBO-optimal one is the narrow fit at mean 0.539.
- The corner ratios used in chat (product/truth ~3.6e17 at (0.9, 0.1)) are normalization-sensitive and
  stay out of the document.

## Sources consulted

None yet; the question map makes no claim about prior work, attribution, or method lineage. Every
number on the page is arithmetic on eq:lik or a quadrature of a density defined in the note, produced
by the two scripts in `scripts/`. No `refs.bib`. If an answer starts citing Bishop, Murphy,
Blei-Jordan-Beal, or Wainwright-Jordan on the KL-direction or mean-field fixed-point results, load
the passage first and add the entry then.

| Source and passage read | Grounds |
|---|---|
| None | — |

## Checks

- Build — `typst compile --root .` exits 0 with no warnings; 9 pages. Section-to-page map refreshed
  after the last edit (s1=3, s2=4, s3=5, s4=6, s5=7, s6=8, Sources=9) and spot-checked against
  `pdftotext` on page 7.
- Structural — no `FILL:` slots; 7 level-1 headings and 6 `#question` boxes (one per teaching
  section, none in Sources); no `#takeaway`, `#intuition`, or `#claim` block; no `"../"` paths.
- Answer-free — re-read after the layout pass. Section 3 and 4's earlier accuracy/entropy numbers were
  removed, and section 5 lists three widths without saying which one a cycling fit reaches.
- Rendered — pages 1-9 rasterized and inspected. Fixed in this pass: figure 1 no longer floats onto a
  near-empty page of its own and shares page 3 with section 1; figure 2's axis labels no longer collide
  with the contour and share page 7 with section 5. The note went from 11 pages with two mostly-empty
  ones to 9 pages, one per section plus cover and contents.
- Numeric — `scripts/posterior_points.py` (peak 0.2668, p(D) = 1/11, ratio 2.9351^d, Beta(8,4)
  moments, tilted mode 0.664 and mean 0.6388, two-bump modes 0.538/0.849, valley 0.156, mass split
  0.494/0.506) and `scripts/mean_field_checks.py` parts A-C both run clean, standard library only.
  Section 5 is now reproduced by the right script: part C was switched to the note's rho = 0.99 and a
  closed-form rank-one check added, which matches the 12-by-12 numeric inversion to five decimals and
  prints both covariance eigenvalues positive. Part B cross-checks the free energy against Monte Carlo
  to about 0.01 nat, and parts A's gaps satisfy log p(D) - ELBO == KL(q ‖ p).
- Landing card — one new card in `#grid`, pointing at the compiled PDF; `data-category`, `data-field`,
  and `data-tags` feed the hero and per-field counts.
- Demo — none. The contour question wants a still figure the reader inspects, and the rho/prior-structure
  sweep is already tabulated in `scripts/` and run in chat.
- Environment — `@preview/ilm:2.1.1` resolves from the local Typst cache, so a machine without network
  needs that package fetched once before the build reproduces.

## Notes

- Both figures are drawn from `line`, `curve`, `polygon`, and `place` rather than an exported asset,
  because every coordinate in them is a number the note also states. Their box heights (5cm and 5.2cm)
  are tuned so each section still fits one page; re-check the page map if the prose grows.
- Sources states what is true at this stage: no external source consulted, and it points at
  `summary.md` for the expected answers.
- Section 5's "three widths" fact stays unlabeled on purpose. Naming which width the coordinate update
  reaches would delete the question.
