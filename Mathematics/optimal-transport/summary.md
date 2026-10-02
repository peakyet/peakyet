# Current understanding: Optimal Transport

**Artifact:** `Mathematics/optimal-transport/optimal-transport-deck.html` &mdash; a 30-frame Beamer
deck built from the `teach-an-engineer` template (`data-theme="beamer"`, KaTeX from the jsDelivr CDN).
The long-form note `optimal-transport.html` (MathJax, 2.1 MB) owns the plain slug, so the deck files
beside it as `-deck.html`. Frame 1 links the note; frame 30 links the note and the Robotics sibling.

**Audience:** engineer, comfortable with basic algebra, calculus and matrices, new to optimal
transport. Knows what total variation and KL divergence are *for*, so section 1 opens on those
failing rather than on a definition.

**Status: complete as an artifact; the understanding gate is still open.** All seven sections are
written, rendered and numerically verified. Sections 2&ndash;7 were authored in one pass on the user's
"implement the plan" instruction, so **no section has passed the gate** (explain-back plus a
prediction answer, with the frames on screen). Section 1 was announced in an earlier session and is
the natural place to resume it. Read the gate column below as "not yet walked", not as "understood".

## Route and assumptions

- Route chosen without a chat interview: core theory plus computation (Monge &rarr; Kantorovich &rarr;
  duality &rarr; Wasserstein metric &rarr; Sinkhorn), with Brenier / Monge&ndash;Amp&egrave;re /
  Benamou&ndash;Brenier / JKO kept to one closing section.
- One running example survives the whole deck: &mu; = &frac12; at x=0 + &frac12; at x=2,
  &nu; = &frac34; at y=1 + &frac14; at y=5, ground cost c(x,y) = |x&minus;y| (squared cost as the
  variant, doubled masses as the section-3 prediction).
- Prerequisites are probed through the frames' prediction prompts, not an interview. Four prompts:
  frames 6, 10, 14, 27; frame 22 is an interactive discovery demo instead of a prompt.
- Theme stays `beamer`, the skill default; the deck does not inherit the neighbouring note's
  serif/gold paper palette.
- No numpy/scipy in this sandbox, so `scripts/verify_ot.py` is dependency-free (stdlib `fractions`,
  `math`) and is the source of every number on the page.

## Section &rarr; frame map

| Section | Frames | Title | Gate |
|---|---|---|---|
| &ndash; | #/1, #/2 | title, outline | n/a |
| 1 | #/3 &ndash; #/6 | A distance needs geometry | not walked (announced in an earlier session) |
| 2 | #/7 &ndash; #/10 | Monge: reshape by a map | not walked |
| 3 | #/11 &ndash; #/14 | Kantorovich: relax the map into a plan | not walked |
| 4 | #/15 &ndash; #/18 | Duality: prices that certify a plan | not walked |
| 5 | #/19 &ndash; #/23 | The Wasserstein metric, and the line | not walked |
| 6 | #/24 &ndash; #/27 | Sinkhorn: transport at data scale | not walked |
| 7 | #/28 &ndash; #/30 | Where the theory goes, plus Sources | not walked |

Takeaways: &sect;1 #/5, &sect;2 #/10, &sect;3 #/14, &sect;4 #/18, &sect;5 #/23, &sect;6 #/27.
&sect;7 is onward reading plus the Sources frame, so it has none.

## Prerequisite map (probed through frames, not interviewed)

| Node | Status |
|---|---|
| histograms, total variation, KL divergence | assumed; frame #/4 uses them as the thing that fails |
| cost as a sum of mass &times; distance | taught briefly, frame #/5 |
| push-forward of a measure | taught on frame #/8 from the running example |
| linear programs, feasibility, vertices | taught on frames #/12&ndash;#/13, where the m+n&minus;1 vertex count appears |
| LP duality, complementary slackness | taught on frames #/16&ndash;#/17; **unprobed**, the likeliest gap |
| Lipschitz functions, Kantorovich&ndash;Rubinstein | taught on frame #/18 with an explicit extremal f |
| metric axioms, triangle inequality | frame #/20 |
| quantiles and CDFs | frames #/21&ndash;#/23; **unprobed** |
| matrix scaling / exponential tilting | frame #/25; **unprobed** |
| floating-point underflow | frame #/27, from the verifier's own numbers |

## Mechanism and verified numbers

All from `python3 scripts/verify_ot.py` (11 blocks), re-run clean on 2026-09-24, exit 0.

- [1] &delta;&sub;0 vs &delta;<sub>k</sub>: TV = 1.000 and KL = inf for k = 1,2,3 while W&#8321; =
  1,2,3. Overlapping supports instead: N(0,1) vs N(m,1) gives KL = m&sup2;/2 = 0.005 / 0.5 / 12.5
  against W&#8322; = |m| = 0.1 / 1 / 5. &rarr; frame #/4.
- [2] No Monge map for the running example: a map can only deliver (1,0), (&frac12;,&frac12;) or
  (0,1), never (&frac34;,&frac14;). &rarr; frames #/6, #/8.
- [2b] Matched masses &nu; = (&frac12;,&frac12;): the uncrossed map bills 2 (squared 5), the crossed
  one 3 (squared 13). &rarr; frame #/9.
- [3] Kantorovich, C = [[1,5],[1,3]]: feasible plans are the segment a = &gamma;&sub;21 &isin;
  [&frac14;,&frac12;], cost(a) = 1+2a, so W&#8321; = 1.5 at a = &frac14; with plan
  [[&frac12;,0],[&frac14;,&frac14;]]; 3 nonzeros = m+n&minus;1, i.e. an LP vertex. Squared cost:
  W&#8322;&sup2; = 3, W&#8322; = 1.732051, same plan. &rarr; frame #/13.
- [3b] Every mass doubled (&mu;=(1,1), &nu;=(1.5,0.5)): bill 3.0000 at a = &frac12;, plan
  [[1,0],[&frac12;,&frac12;]] &mdash; exactly twice the earlier bill, so the splitting fraction does
  not move. &rarr; frame #/14's prediction.
- [4] Dual certificate at the W&#8321; optimum: &phi; = (0,0), &psi; = (1,3); route slacks 0, 2, 0, 0;
  revenue = 1.5 = primal optimum, so the plan is certified. &rarr; frame #/17.
- [4b] Shifting the whole price list by k &isin; {0,1,&minus;2} keeps it dual feasible and leaves the
  revenue at 1.5000 &mdash; only price *differences* are observable, which is why a critic is trained
  up to a constant. &rarr; frame #/18.
- [4c] The KR potential f = &minus;dist(&sdot;,{0,2}): values 0, &minus;1, 0, &minus;3; steepest slope
  1.0000 on a 0.02 grid; &int;f d(&mu;&minus;&nu;) = 1.5000 = W&#8321;, so f is extremal.
  &rarr; frame #/18's figure.
- [5] Uncrossing identity |x&sub;1&minus;y&sub;2| + |x&sub;2&minus;y&sub;1|
  &minus;|x&sub;1&minus;y&sub;1| &minus;|x&sub;2&minus;y&sub;2|
  = 2&thinsp;max(0, min(x&sub;2,y&sub;2)&minus;max(x&sub;1,y&sub;1)): 0 counterexamples over integers
  in [&minus;6,6]. &rarr; frame #/21.
- [5b] x = [&minus;2,0,1,4,7], y = [&minus;1,1,2,3,9]: sorted bills 6, the minimum over all 120
  matchings (worst 26); at p=2 sorted is 8 against 44 for crossing the last two legs; crossing only
  those two costs 12 at p=1. The overlap is 7&minus;4 = 3, so the surcharge is 2&times;3 = 6, which is
  12&minus;6. &rarr; frames #/21 and #/22, whose demo defaults print sum 6.00, W1 1.2000, W2 1.2649.
- [6] Quantile formula on U[0,2] vs U[1,3]: W&#8321; = W&#8322; = 1.000000. &rarr; frame #/23.
- [7] Sinkhorn, naive and log-domain, tolerance 1e-11: &epsilon;=1 &rarr; 13 sweeps, 1.586955, plan
  [.4565,.0435,.2935,.2065], entropy 1.179839; 0.3 &rarr; 22, 1.501265; 0.1 / 0.03 / 0.01 &rarr; 22,
  1.500000. At &epsilon; = 0.003 / 0.001 / 0.0001 the naive scaling underflows after **1** sweep
  (marginal error 0.25 &rarr; 0.75) while the log-domain loop still returns 1.500000 in 22 sweeps.
  &rarr; frames #/25, #/26, #/27.

## Sources

Every identifier below was resolved while writing the deck; the three arXiv items were downloaded to
`/tmp` and read from the PDF rather than from a listing. No PDF or extracted text is in the repo, and
the deck links public URLs only.

- L. V. Kantorovich, *On the Translocation of Masses*, Management Science 5(1), 1958 &mdash;
  DOI 10.1287/mnsc.5.1.1. Grounds section 3's relaxation and the framing of frames
  #/11&ndash;#/13.
- Y. Brenier 1991, Comm. Pure Appl. Math. 44(4), 375&ndash;417 &mdash; DOI 10.1002/cpa.3160440402.
  Frame #/29's "the map is a gradient": the abstract states the polar factorization
  u = &nabla;&Psi;&compfn;s with s measure-preserving and names Monge&ndash;Amp&egrave;re, which is
  what that frame and its neighbour claim.
- J.-D. Benamou &amp; Y. Brenier 2000, Numer. Math. 84(3), 375&ndash;393 &mdash;
  DOI 10.1007/s002110050002. Frame #/29's fluid-mechanics formulation.
- R. Jordan, D. Kinderlehrer &amp; F. Otto 1998, SIAM J. Math. Anal. 29(1), 1&ndash;17 &mdash;
  DOI 10.1137/S0036141096303359. Frame #/29's gradient-flow reading; the abstract's own words are a
  time step governed by the Wasserstein metric and steepest descent of a free energy.
- R. Sinkhorn 1964, Ann. Math. Statist. 35(2), 876&ndash;879 &mdash; DOI 10.1214/aoms/1177703591;
  Sinkhorn &amp; Knopp 1967, Pacific J. Math. 21(2), 343&ndash;348 &mdash; DOI 10.2140/pjm.1967.21.343.
  The scaling theorem behind frame #/25's loop.
- M. Cuturi, *Sinkhorn Distances* &mdash; arXiv:1306.0895 (read from the v1 PDF). Grounds the
  strict-convexity statement and the linear-rate scaling claim on frames #/25 and #/26.
- G. Peyr&eacute; &amp; M. Cuturi, *Computational Optimal Transport* &mdash; DOI 10.1561/2200000073
  (Found. Trends ML 11(5&ndash;6), 2019; the journal version of arXiv:1803.00567). Sections 3, 5 and 6:
  LP form, vertex structure, Sinkhorn complexity.
- M. Cuturi &amp; G. Peyr&eacute;, *Semidual Regularized Optimal Transport* &mdash;
  DOI 10.1137/18M1208654 (SIAM Review 60(4), 2018). Why frame #/18 prefers one potential to two fee
  lists.
- G. Carlier, V. Duval, G. Peyr&eacute; &amp; B. Schmitzer &mdash; DOI 10.1137/15M1050264 (SIMA
  49(2), 2017). The &Gamma;-convergence limit on frame #/26, stated for the squared Euclidean cost
  exactly as the frame says it.
- S. Eckstein &amp; M. Nutz &mdash; DOI 10.1137/21M145505X (SIMA 54(6), 2022). Frame #/26's hedge that
  the rate analysis is still moving.
- M. Arjovsky, S. Chintala &amp; L. Bottou, WGAN &mdash; arXiv:1701.07875, whose PDF says
  "Kantorovich&ndash;Rubinstein duality &hellip; supremum over all 1-Lipschitz functions"; Gulrajani
  et al., WGAN-GP &mdash; arXiv:1704.00028. Frame #/18's critic reading.
- C. Villani, *Optimal Transport: Old and New*, ch. 3 "The founding fathers of optimal transport"
  &mdash; DOI 10.1007/978-3-540-71050-9_3. Historical framing for sections 2&ndash;4.
- Dropped rather than cited, because they could not be verified in this environment: arXiv:1803.00567
  (superseded by its journal DOI above), 2212.06000, 1811.05527 (superseded by its SIAM DOI),
  1310.04375, 1712.07822. Nothing on the page depends on them.

MCP notes: `arxiv-mcp-server` is not loaded in this session; `paper-search-mcp`'s `search_unpaywall`
returns `[]` for `10.48550/arXiv.*` and `get_crossref_paper_by_doi` came back empty, so DOI metadata
came from `search_crossref` by title. `download_with_fallback(source="arxiv", use_scihub=False,
save_path="/tmp/...")` is what worked for full text.

## Verification state

- `scripts/verify_ot.py` re-run 2026-09-24: 11 blocks, exit 0, every number above reproduces.
- **All 30 frames rendered headlessly at 1440&times;900** with `#/N`, which reveals every overlay: no
  `overfull` badge on any frame. Frames #/27 and #/29 needed real content trims to get there, so
  re-measure with `scripts/check_overfull.sh $(seq 1 30)` after any edit. The badge only says
  "something clips"; a `/tmp` variant of the deck that paints the frame body's measured overflow as a
  pixel bar was what turned the two fixes into arithmetic instead of guessing.
- **Figure geometry checked with the browser's own `getBBox`.** A `/tmp` copy walks every
  `svg[role=img]` on load and reports any child whose box leaves its `viewBox`; the deck currently
  reads `svg-ok`, which also covers the demo's generated dots, labels, ticks and arcs. This caught two
  real defects that no amount of eyeballing had found:
  frame #/21's Figure 7 drew the `y=9` target at `cx=458` inside a 450-wide viewBox, so that dot and
  the end of one red arc were clipped, and the two panels ran on different scales; both panels now use
  16 px per unit with a single anchor each. Frame #/18's axis tick labels sat at `y=252` in a 250-tall
  viewBox and are now at 245, with the dashed rules shortened to match.
  Note that the naive version of this sweep also flags KaTeX's internal `<svg viewBox="0 0 400000 548">`
  fragments, so scope it to `role="img"`.
- Frames #/4, #/8, #/13, #/18, #/21, #/25 and #/27 were additionally inspected at full size for label
  collisions; the bars on #/8 and the certificate plot on #/18 read cleanly.
- Frame #/22's demo was exercised headlessly by injecting control state through a URL query into a
  `/tmp` copy of the deck: defaults give `sorted: sum 6.00, W1 1.2000, W2 1.2649`; ticking `reverse
  the pairing` appends `| reversed bill 26.00`; `src5=0.5` gives sum 10.50 / W1 2.1000 / W2 2.5788,
  and `src1=3.5` with the reverse box ticked gives 5.50 / 1.1000 / 1.2845 / reversed 23.50 &mdash; each
  matching an independent recomputation of block [5b]'s model. Source labels now lift a row when two
  atoms come within 26 units, which is what the near-coincident injection checked. What was *not*
  done: pressing keys or dragging a real thumb; the deck's own `input`/`change` listeners were driven
  programmatically.
- Text on #/27 now says "Log-domain: 22 sweeps" rather than "both columns", because block [7] shows the
  naive loop dying on its **first** sweep; the earlier wording credited it with 22.
- Narrow viewport 420&times;1600, which forces the template's stacked reader layout: every frame body
  reports zero horizontal and zero vertical spill, and `main` measures 354 CSS px wide, so nothing
  clips. The outline's gloss now drops below its title at that width. Reader mode is the same code
  path; the `r` key itself was not pressed.
- Repo wiring: the landing-page card is in `#grid` after the note's own card, and a walk of every
  relative `href` across all 33 pages of the site found **0 dangling links**. The hero recomputes to
  32 notes / 7 fields, the `math` chip counts 7, and searching "optimal transport" returns the motion
  planning note, the long-form note, and this deck.
- Removed the template's dead placeholder demo wiring (it referenced a `demo-slider` that this deck does
  not have); `grep -i draft` over the file is now empty, and the outline on frame #/2 still matches the
  seven sections as written.
- Print CSS is the template's unchanged (`@page 1280px 720px`, one slide per page, overlays revealed).
  Reviewed statically only; no PDF was produced.
- KaTeX renders on every frame containing `\(...\)` or `\[...\]`, including `\underbrace`,
  `pmatrix` and `\operatorname{dist}`; no `ParseError` text appears in the renders. No `<text>` node
  inside an SVG carries KaTeX delimiters (grep-checked), and the file has no stray carriage returns.
- Cross-links: frame 1 &rarr; `../../index.html` and `optimal-transport.html`; frame 30 &rarr;
  `optimal-transport.html` and `../../Robotics/mpot-sinkhorn-step/mpot-sinkhorn-step.html`. All
  resolve through the local server. The long-form note was not modified.

## Next (teaching, not building)

1. Walk &sect;1's gate: open #/3&ndash;#/6, ask for the frame #/6 prediction &mdash; which of the
   three reachable delivery patterns is nearest (&frac34;,&frac14;), and why none of them is it
   &mdash; then the explain-back against frame #/5.
2. Then &sect;2&ndash;&sect;7 in order, same loop. Where an answer shows a real gap, teach the gap on
   its own frame rather than in the terminal; LP/convex duality on frames #/16&ndash;#/17 is the best
   candidate.
3. If a later section exposes a flaw in an earlier one, revise those frames and refresh this file.
