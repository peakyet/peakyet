# Bayesian inference — teaching handoff

**Stage:** question map (published, rendering cleanly); teaching not started.

**Artifact:** `Mathematics/bayesian-inference/bayesian-inference.typ`, compiled to
`Mathematics/bayesian-inference/bayesian-inference.pdf` (13 pages, four figures, four tables). No
demo sidecar. Answers to all six questions are below and appear nowhere in the note.

## Audience

An engineer who has multiplied a likelihood by a prior and integrated the product once, and who is
comfortable with single-variable calculus, the Gamma function, and the Binomial density. Everything
the note uses is defined in it: the Beta density, the Beta function, the Beta-binomial marginal, a
log-uniform hyperprior, and an expected-squared-error risk. No MCMC, no measure theory, no matrix
algebra. The reader met in the earlier notes is numerate and redoes the arithmetic; this note is
built so that the arithmetic is redoable, since every answer is a fraction of small integers.

## Route and assessment

Page numbers are for the current PDF and must be refreshed after any edit.

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| `s1` | 3 | The label is `Beta(3, 5)`, ten coins, ten flips each, counts `0,1,2,3,3,4,5,5,6,8`. Which number is shared by all ten posterior means; what is the ratio between the extreme coins' stamped gap and their raw gap of 0.8, and why is it the same ratio for any pair; what does `Beta(12, 20)` give; and what can be said about the coin with no heads? | Every posterior is `Beta(3+h, 15-h)`, so the shared number is `alpha + beta + m = 18` = the label's 8 flips plus the coin's 10. The mean is `(3+h)/18 = (5/9)(h/10) + (4/9)(3/8)`: weight `m/(m+alpha+beta) = 5/9` on the coin's own frequency and `4/9` on the label's mean. Any two coins differ by `(h-h')/18`, so the extreme gap is `8/18 = 0.4444` against `0.8`, ratio exactly `5/9`; the ratio is pair-independent because the label's contribution `18` cancels in a difference. `Beta(12, 20)` has `alpha+beta = 32`: weight `10/42 = 0.2381`, extreme gap `8/42 = 0.1905`, and the 0-head coin at `12/42 = 0.2857` against `1/6`. The 0-head coin gets `1/6 = 0.1667` with sd `0.0855`: the label refuses the raw frequency's claim of bias 0 with zero uncertainty. Misconceptions to catch: "the column is centred by the pooled frequency 0.37" (the centre is the label's mean 0.375, and the two are 0.005 apart only by coincidence of this data set) and "the columns are pooled toward the average of the ten counts" (they are pooled toward the label). | question-ready |
| `s2` | 5 | With the label gone and a log-uniform hyperprior on `(alpha, beta)` over `[0.1, 40]`, what can one coin say about the box; which does the ten-coin hyperposterior pin better, the centre or the width; does `Beta(3,5)` survive; and does dropping the label make each coin's answer narrower or wider? | One coin narrows *where* the population sits (`alpha/(alpha+beta)` 68 percent width `0.414` against the hyperprior's `0.863`) but not *how wide it is* (`log(alpha+beta)` 68 percent width `2.889` against `2.955`), and it always asks for the tightest population the box allows: mode on the corner `(17.70, 40.00)`, 68 percent set touching all four edges, `0.278` of its mass above `alpha+beta = 20` against the ten coins' `0.114`. The ten coins pin the centre much better than the strength: `0.863 -> 0.142` (a factor of 6.1) against `2.955 -> 1.671` (1.8), and the strength's upper tail still reaches `28.38` inside a box allowing `80`. The label survives with room: `(2.98, 5.00)` sits inside the 68 percent set (log posterior `-22.06` against the level `-23.17`), the coins' own population mean is `0.3709` against the label's `0.375`, and the coins' own column moves no coin by more than `0.0145` (the 0-head coin: `0.1522` against `1/6`). Dropping the label makes every answer **wider**, not narrower: total sds `0.1064` at `h=0` (against `0.0855`) and `0.1395` at `h=8` (against `0.1118`), because each coin's answer now inherits the uncertainty about the population. Misconception: "learning the label from data is free extra precision". Second misconception: the hyperprior's *box* is not innocent — the mode is robust, but the posterior mean of `alpha+beta` runs `7.96 / 9.85 / 12.25` and the evidence differs by `0.86` nats across `[0.2,20] / [0.1,40] / [0.05,80]`. | question-ready |
| `s3` | 7 | Why is the answer "add the label's counts"? Does batching change it; what does the 120-order fact force about a likelihood; and which of the two Beta functions decides the shape of a belief and which the probability of a record? | The product `theta^h (1-theta)^(10-h) * theta^2 (1-theta)^4` has exponents that add, so the posterior is the Beta with the summed parameters and no batching can matter: multiplication is commutative, so one batch of ten, two of five, and ten of one give the same posterior. A posterior can see only `h` and `t = 10 - h`; all 120 orders of a 3-head record give one posterior, so a likelihood is a function of the parameter, not the probability of a record. The posterior's normalizer `B(3+h, 15-h)` makes a *belief* a density; the *record's* probability needs the likelihood's own normalizer: `P(h) = C(10,h) B(3+h, 15-h) / B(3,5)`, and for the 0-head coin `B(3,15)/B(3,5) = 7/136 = 0.05147`. Misconception to catch: "the posterior's constant is the probability of the data" — it is a different constant of the same product. | question-ready |
| `s4` | 8 | The label's answer is affine in the frequency. Where does each risk curve peak; which estimator wins on average under the label and by what factor; which wins the worst case; and which of those answers is a theorem about the method and which is a fact about this label? | Frequency: peaks at `theta = 1/2`, value `1/40 = 0.025`, zero at both ends. Label: minimum at its own mean `0.0072338`, rising to `1/36 = 0.02778` at `theta = 0` and `25/324 = 0.07716` at `theta = 1`. So the label's middle is better than anything the frequency can do, and the label's worst case (`25/324`) is 3.1x the frequency's peak (`1/40`) — the curves cross at the roots of `432 theta^2 - 352 theta + 45 = 0`, i.e. `0.1588` and `0.6560`. Average risk under the label: `5/432 = 0.011574` against `1/48 = 0.020833`, a factor of exactly 1.8 for the label. The label's *average* win is the theorem (its answer is the posterior-mean minimizer of posterior expected squared error); the *worst-case* loss is a fact about where this label's mass sits, and moving the label's mean moves the second risk term's centre. The reading to require: a label is a bet on where the box's biases live, the risk curve is the price list of that bet, and the price is only worth paying on the part of the interval the box actually uses. | question-ready |
| `s5` | 10 | The three prices under the label; why a fresh coin's price is the label's mean; whether the ten successive prices of the 0-head coin multiply to its record probability; and which of the label / the mixture of labels / a plug-in is the predictive, with what happens in a one-coin box. | Prices `(3+h)/(18+n)`: `0.6111` for the 8-head coin, `1/6 = 0.1667` for the 0-head coin, and `3/8 = 0.375` for a fresh coin, which is the label's own mean because a fresh coin's bias is drawn from the label and no record speaks about it; under the ten coins' own verdict they become `0.6218`, `0.1522` and `0.3709`. The ten one-step prices of the 0-head coin are `(5+n)/(8+n)`, `n = 0..9`, and their product is `7/136 = 0.05147`, the record probability of section 3 — the coherence check that the prices must pass. The mixture is the predictive; the plug-in at the single modal population is the approximation that drops the label's own uncertainty. Ten coins: mixture sd `2.4525`, `P(h>=7) = 0.1437`, `P(<=1) = 0.2097` against the plug-in's `2.3105`, `0.1317`, `0.1933` — a few percent, because the ten coins have largely fixed the label. One coin: mixture sd `3.0057` and `P(h>=7) = 0.1855` against the plug-in's `1.5660` and `0.0190`, a factor of 9.8 in the tail, because the one-coin hyperposterior is nearly flat along the box and the corner population `(17.70, 40.00)` claims a tightness no single coin established. Misconception: "plugging in the most likely label is the answer" — it is a point estimate of the model, and it understates extreme outcomes exactly when the model is least known. | question-ready |
| `s6` | 11 | A hand-stuffed box with two kinds of coin, fitted with the same one-shape population: where does the fit put mass the truth does not, which model wins each box's evidence and which two models are the same distribution, why does the hyperprior lose to a model with no hyperparameter, and what could none of this have told you? | The fit is `Beta(0.593, 0.593)`, a symmetric U: `0.1760` on 0 heads and `0.1760` on 10 against the truth's `0.0984` (1.8x too extreme at both ends) and `0.0636` on exactly 5 heads against `0.0085`, a factor of **7.5** in the middle — where the truth has almost nothing. One hump can imitate two clumps only by bending its mass to the ends of the interval, so it does not place the clumps at 0.15 and 0.85 and it keeps a plateau in the middle. Evidence: on the label's box the labelled population and six independent `Beta(3,5)` coins tie at `-22.0635` — they are the *same* distribution of the counts, i.e. a labelled population and a prior on each coin are one statement; the two-point population wins the hand-stuffed box (`-22.8268`, ahead of the free-uniform model by 1.15 nats) and loses the other by 2.6. The hyperprior loses on the first box because a model's evidence is the average of the counts' probability over its own prior, so it pays for every shape it allows: narrowing the box to `[0.9, 1.1]` recovers `-23.9767` against the uniform shape's `-23.9790`, and widening it costs monotonically (`-23.9456` at `[0.5,2]`, `-24.6300` at `[0.2,20]`, `-25.1024` at `[0.1,40]`, `-25.4883` at `[0.05,80]`). A free-coin model's score is mostly its prior (`-23.9790` uniform, `-22.0635` with `Beta(3,5)`, `-22.6060` with `Beta(6,10)`). What none of it could see: the evidence ranks the models you wrote down; the two-point model wins only because it was in the list, and the U-shaped misfit looks confident and even adaptive — its `P(<=1) = 0.2637` is close to the truth's `0.2722` — with the error showing up only in the middle, where figure 4 puts it. Misconception: "a Bayes factor measures which model is true" — it measures which prior bet on the data best. | question-ready |

Running example: one box, ten coins, ten flips each, heads `0, 1, 2, 3, 3, 4, 5, 5, 6, 8` (37 of
100), and a label that says each coin's bias is drawn from `Beta(3, 5)`. Section 2 removes the label
and infers `(alpha, beta)` under a log-uniform hyperprior on `[0.1, 40]`. Section 4 scores the
label's answer against the raw frequency by expected squared error. Section 5 prices a next flip for
a recorded coin and for a fresh one. Section 6 replaces the box with a hand-stuffed box of five
coins at 0.15 and five at 0.85, counts `0, 1, 1, 2, 2, 8, 8, 9, 9, 10`, and compares five models of
the same counts by their marginal likelihoods.

Keep expected insights here as teaching notes. Do not copy them into the question map.

## Unresolved or research-needed claims

- The note never names a theorem it has not proved in finite form. If the reader asks for
  "de Finetti", the note's own identity is the finite version: a labelled population and an
  independent prior on each coin give the same distribution of counts (`-22.0635` twice in table 4),
  and what a *learned* population adds is that the coins share `(alpha, beta)`. A source would be
  needed before making any statement about lineage, attribution, or an infinite exchangeable
  sequence.
- The hyperprior is a log-uniform box, chosen for arithmetic rather than for principle. The note
  shows what the choice costs (`0.86` nats across a fourfold widening) but does not compare it with
  a reference prior. If the reader asks "what should the hyperprior be", that is a research step,
  not a re-derivation.
- `scripts/pooling_checks.py` uses a `361 x 361` grid in `(log alpha, log beta)`, so the mode is
  reported to about 2 percent in `alpha` and `beta` and the 68 percent extents to about one grid
  cell (`0.023` in log units). The two-factory quadrature uses a `241 x 241` grid on `(l, h)`. Both
  reproduce the closed forms in the note exactly; a denser grid changes no quoted digit, and any
  quoted digit that changes should be re-derived rather than patched.
- The evidence numbers are sensitive to the box's edges by construction (that is section 6's point),
  so no quoted nats figure should be repeated without its box.

## Sources consulted

None. The note makes no claim about prior work, attribution, or the history of any method, and no
`refs.bib` exists beside it. Every number on the page is arithmetic on `Beta(3, 5)` and the ten
counts, or a quadrature of a density those two define, printed by `scripts/pooling_checks.py`. If an
answer starts citing Bishop, Murphy, Gelman-Carlin-Stern-Dunson-Vehtari-Rubin, Schervish, or de
Finetti on conjugacy, shrinkage, posterior predictive checks, or exchangeability, load the passage
first and add the entry then.

| Source and passage read | Grounds |
|---|---|
| None | — |

## Checks

- Build — `typst compile --root . Mathematics/bayesian-inference/bayesian-inference.typ` exits 0
  with no warnings; 13 pages. The note imports the shared style vocabulary from
  `.agents/skills/teaching-complex-ideas/typst-template/teaching.typ`, as the other Typst notes do.
- Regression — the shared template was missing from the working tree (deleted in `705ad77`), which
  made all 22 Typst notes fail on its import; re-adding it brings every one of them back. Verified by
  compiling all 24 `.typ` files to a scratch directory (22 notes plus the two template files, all
  exit 0), by comparing each rebuilt page count against its committed PDF (all equal), and by
  rasterizing page 3 of `variational-inference`, `tube-mpc`, `optimal-transport` and
  `lmi-robust-control` against the committed PDFs: `magick compare -metric RMSE` reports 0 on every
  one, so the restored file reproduces the published rendering and no committed PDF needed
  rebuilding. This note's own PDF is unchanged by the switch to the shared import: RMSE 0 on all 13
  pages against the build that carried the vocabulary inline.
- Structural — no `FILL:` slots; 7 level-1 headings (six questioned sections plus Sources) and 6
  `#question` boxes; no `"../"` paths; 8 equations, all referenced except `eq:beta`, which is the
  definition the first reference points at.
- Answer-free — re-read after the layout pass. Removed in that pass: a fact stating where each risk
  curve peaks (it answered `s4`'s first question), a fact stating that records with the same heads
  count share a posterior (it answered `s3`'s parts one and two), and the `s2` closing paragraph's
  numbers, which answered `s2`'s fourth question; the numbers moved into the facts list, where they
  are inputs to a reading question instead of the reading itself.
- Rendered — all 13 pages rasterized and inspected. Fixed in this pass: the Beta-function display
  overlapped `Gamma(a+b)` at the right margin (the two definitions are now separate equations); the
  `s5` price display ran into its equation number (shortened, `x_"next"` collapsed to `"H"`); every
  figure's vertical tick labels rendered as the literal letter `v` instead of numbers; figure 1's
  y-axis name collided with the top tick and its x-axis name with the last tick, and its two legend
  lines overlapped each other; figure 3's y-axis name collided with the top tick; all four figures'
  in-plot annotations sat on the curves they label and three of them were quoted text. Page fills
  were then measured per page (content bottom over text area): 0.81, 0.97 for `s1`, 0.98, 0.75 for
  `s2`, 0.87 for `s3`, 0.84, 0.44 for `s4`, 0.98 for `s5`, 0.86, 0.58 for `s6`, 0.28 for Sources —
  in the same range as the published variational-inference note (0.41 to 0.98 per page).
- Numeric — `scripts/pooling_checks.py` runs clean, standard library only, in about 30 s, and its
  part G re-derives each identity by a route that shares no code with parts A-F: the stamped
  posterior's mean and sd by numerical integration of the product density on a `400001`-point grid
  (agreement to 10 decimal places), the one-step prices by the augmentation route
  `P(h+1 in m+1) * (h+1)/(m+1) / P(h in m)`, all 120 orderings of a 3-head record (identical
  probabilities), and the risk closed form against the sum over binomial counts (worst disagreement
  `8.3e-17`). Key numbers it prints: `(3+h)/18`, the spread ratio `5/9`, modes `(2.21, 3.76)` and
  `(17.70, 40.00)`, widths `0.863/0.142` and `2.955/1.671`, `1/48` against `5/432`, `1/40` against
  `25/324`, roots `0.1588/0.6560`, `7/136`, the evidence table, and the two-factory predictive.
- Landing card — one new card in `#grid` pointing at the compiled PDF, `data-category="math ai"`,
  `data-field="Mathematics"`, tags covering inference, conjugacy, shrinkage, exchangeability,
  predictive, evidence, and Occam.
- Demo — none. Every question here wants arithmetic or a still figure the reader inspects; a
  parameter slider would put the answers on the page.
- Environment — `@preview/ilm:2.1.1` resolves from the local Typst cache, so a machine without
  network needs that package fetched once before the build reproduces. `pdftoppm` and ImageMagick
  were used for the raster inspection.

## Notes

- All four figures are drawn from `line`, `curve`, `circle`, `rect`, and `place` rather than exported
  assets, because every coordinate in them is a number the note also states. Their box heights
  (4.0 to 4.7 cm) are tuned so that each section's figure shares a page with its section's prose or
  table; re-check the page map if the prose grows by more than a line or two.
- `s1`'s table groups coins by their count and keeps a `coins` column so a reader can still check
  each of the ten posteriors against the note's arithmetic.
- The note's title names the two objects the questions are about. A title that stated the insight
  ("the prior is the population") would answer `s6`'s second part before the reader reaches it.
- Section 2's closing paragraph deliberately carries no numbers now: the risk is the reader skimming
  it for the box-sensitivity answer that the fourth question asks for.
