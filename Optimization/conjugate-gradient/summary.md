# Conjugate gradients — teaching handoff

Keep this short. It is a handoff, not a transcript and not a prerequisite ledger.

**Stage:** question map (published); Section 1 not yet asked, no reader attempt.

## Audience

Assumed: an engineer new to conjugate gradients, comfortable with basic algebra and calculus —
matrix–vector products, gradients of a quadratic, inner products. No prior Krylov-subspace or
eigen-decomposition fluency assumed; both are introduced on the page in as much detail as the
questions need and no more. Calibrated to zero: nothing on the page relies on knowing what a
condition number *does* in advance, only on its definition.

## Route and assessment

| Section | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|
| `#s1` | Why is the greedy method not done after two exact line searches in 2D, and what property of two successive directions would make it so? | Two unknowns should need two steps (n steps for n unknowns), and that requires \(A\)-orthogonality / conjugacy, \(p_1^{\mathsf T}Ap_0=0\) — not Euclidean orthogonality. The geometric reading: a step along \(p_1\) must leave the error's \(A\)-component along \(p_0\) untouched, so the guarantee earned in step 0 survives. Misconceptions to catch: "perpendicular is enough" (the greedy residuals *are* mutually perpendicular and it still fails); "the step length is not exact"; "n steps is a property of the algorithm, not of the directions". | question-ready |
| `#s2` | What is step \(k\)'s \(A\)-orthogonality guarantee worth after step \(k+1\), and which inner product decides it? | \(\langle e_{k+2},p_k\rangle_A=\langle e_{k+1},p_k\rangle_A+\alpha_{k+1}p_{k+1}^{\mathsf T}Ap_k=\alpha_{k+1}r_{k+1}^{\mathsf T}Ap_k\), and on the example \(r_1^{\mathsf T}Ar_0=-5/3\neq0\), so step 1 reinstates an \(A\)-component along \(p_0\): the earlier guarantee is destroyed. The invariant to maintain is \(A\)-orthogonality to *all* earlier directions, not only to the immediately preceding one. Supporting observation, exact here: \(r_2=(\tfrac16)\,r_0\), i.e. the greedy direction sequence returns to an earlier line. Misconception: reading the run as "rounding" or "slow convergence" rather than a structural loss of a guarantee. | question-ready |
| `#s3` | Why does one correction term suffice, when generic \(A\)-Gram–Schmidt needs every earlier direction? | Two facts: (i) \(r_k^{\mathsf T}p_j=0\) for all \(j<k\); (ii) \(Ap_j\in\mathrm{span}\{r_j,r_{j+1}\}\subseteq\mathrm{span}\{p_0,\dots,p_{j+1}\}\), from \(r_{j+1}=r_j-\alpha_jAp_j\) together with \(p_k=r_k+\beta_kp_{k-1}\). Hence \(p_j^{\mathsf T}Ar_k=r_k^{\mathsf T}Ap_j=0\) for \(j\le k-2\), and only \(j=k-1\) survives. The step (i)→(ii) direction is the crux, and it is why the recurrence is short: \(\beta_k=-p_{k-1}^{\mathsf T}Ar_k/(p_{k-1}^{\mathsf T}Ap_{k-1})\), later reducible to \(r_k^{\mathsf T}r_k/r_{k-1}^{\mathsf T}r_{k-1}\). The symmetry of \(A\) is required for \(p_j^{\mathsf T}Ar_k=r_k^{\mathsf T}Ap_j\) — worth flagging here, since §6 asks for it. Misconceptions: "you must store all previous directions"; treating the conjugate \(p\)'s as Euclidean-orthogonal. | question-ready |
| `#s4` | What does \(x_k\) minimise, over what set, and what do two spectra with the same \(\kappa\) predict? | \(x_k\) minimises the \(A\)-norm of the error, \(\|x-x^\star\|_A=\sqrt{(x-x^\star)^{\mathsf T}A(x-x^\star)}\), over \(x_0+\mathcal K_k(A,r_0)\); at \(k=n\), \(\mathcal K_n=\mathbb R^n\) so \(x_n=x^\star\) exactly, and more generally termination occurs at the number of *distinct* eigenvalues. Prediction: the one-outlier spectrum (two distinct eigenvalues, \(\kappa=1000\)) terminates in 2 steps, the evenly spread one needs on the order of \(\sqrt\kappa\,\ln(2/\varepsilon)\) — so *distribution* matters, not \(\kappa\) alone: isolated outliers and tight clusters are cheap, a uniformly spread spectrum is expensive. Misconception: "cost is a function of the condition number". | question-ready |
| `#s5` | Assemble the procedure, predict its behaviour on the example, and state the per-step cost at scale. | \(r_0=b-Ax_0,\ p_0=r_0\); per step \(\alpha_k=r_k^{\mathsf T}r_k/(p_k^{\mathsf T}Ap_k)\), \(x_{k+1}=x_k+\alpha_kp_k\), \(r_{k+1}=r_k-\alpha_kAp_k\), \(\beta_k=r_{k+1}^{\mathsf T}r_{k+1}/(r_k^{\mathsf T}r_k)\), \(p_{k+1}=r_{k+1}+\beta_kp_k\). On the example: \(x_1=(\tfrac13,\tfrac23)\), \(x_2=(0,1)=x^\star\) — exactly two steps. Cost: one product \(Ap_k\) per step plus two inner products, and only \(x,r,p\) carried — \(O(n)\) storage, versus \(O(n^2)\) memory and \(O(n^3)\) work for a dense factorisation (sparse Cholesky fill-in can be worse still). The stopping test must be chosen by the reader: there is no other termination signal than the size of \(r_k\) (e.g. \(\|r_k\|\le\mathrm{tol}\,\|b\|\)). Misconceptions: expecting a convergence certificate; assuming \(A\) is stored. | question-ready |
| `#s6` | What breaks when \(A\) is symmetric indefinite, and which uses of definiteness does it break? | Immediate breakdown at step 0: \(p_0=r_0=(1,0)\), \(p_0^{\mathsf T}Ap_0=0\), so the step length is undefined; and along that line \(f(t,0)=-t\to-\infty\), so no finite minimiser exists. Definiteness was doing work in: (i) strict convexity / boundedness below — existence and uniqueness of the minimiser; (ii) \(p^{\mathsf T}Ap>0\) — a well-defined \(\alpha\) and a descent step, i.e. no breakdown; (iii) \(\langle u,v\rangle_A=u^{\mathsf T}Av\) being a genuine inner product — the \(A\)-projection and the \(A\)-norm error minimised in §4; (iv) symmetry — the swap \(p_j^{\mathsf T}Ar_k=r_k^{\mathsf T}Ap_j\) behind the short recurrence. Drop symmetry and the one-term recurrence no longer follows; the standard repairs are MINRES for symmetric indefinite, GMRES / BiCGSTAB for nonsymmetric, and preconditioning to compress the spectrum. Misconception: "CG just converges more slowly" rather than "the quantity it divides by need not exist". | question-ready |

Running example: \(A=\begin{bmatrix}3&1\\1&2\end{bmatrix}\), \(b=(1,2)^{\mathsf T}\), \(x_0=0\), target
\(x^\star=(0,1)^{\mathsf T}\), \(\kappa=2.618034\), eigenvalues \((5\pm\sqrt5)/2\). Every section
returns to it; §6 replaces it with the symmetric indefinite
\(A=\begin{bmatrix}0&1\\1&0\end{bmatrix}\), \(b=(1,0)^{\mathsf T}\), \(x_0=0\).

Keep expected insights here as teaching notes. Do not copy them into the HTML question map.

## Current discussion point

Stopped at `#s1`, before any reader attempt. Next message should deliver the page link and the
Section 1 question only — no property named, no numbers.

## Unresolved or research-needed claims

- `#s4` — the finite-termination statement (termination at the number of distinct eigenvalues), the
  Krylov-minimisation identity \(\min_{x\in x_0+\mathcal K_k}\|x-x^\star\|_A\), and the bound
  \(\|e_k\|_A\le2\big(\frac{\sqrt\kappa-1}{\sqrt\kappa+1}\big)^k\|e_0\|_A\) are standard but are recalled,
  not sourced. Check Golub & Van Loan ch. 11 or Saad ch. 6 (both currently listed on the page only as
  *not consulted* further reading) before stating either as fact to the reader.
- `#s4` — the claimed \(\approx\sqrt\kappa\) step count for the evenly-spread spectrum is the usual
  reading of the Chebyshev bound at a fixed tolerance; if the reader pushes on it, both the bound and
  the tolerance dependence need the check above.
- `#s2` — "the greedy direction sequence returns to an earlier line" (\(r_2\parallel r_0\)) is verified
  exactly for this 2D example. The general statement that 2D steepest descent is asymptotically a
  2-cycle in direction space should be checked before being generalised to the reader.
- `#s6` — the breakdown claim is verified by exact computation on the instance. Which repair suits
  which failure (MINRES / GMRES / BiCGSTAB, and PCG's relaxation of definiteness to self-adjointness in
  the \(M^{-1}\)-inner product) is recalled, not sourced; confirm before recommending one.
- `#s1`–`#s5` all assume exact arithmetic. The floating-point loss of conjugacy, and the resulting gap
  between the n-step guarantee and practical iteration counts, is not raised anywhere on the page — a
  candidate follow-up if the reader's §4 or §5 answer reaches for it.

## Sources consulted

None yet; the question map makes no external claims. Hestenes & Stiefel (1952), Shewchuk (1994),
Golub & Van Loan, and Saad appear on the page only as labelled-not-consulted further reading.

## Checks

- Structural — `grep -n 'FILL:'` empty; `nav.toc` anchors and `<h1|h2 id>` ids diff empty; 7 `h2`
  sections (6 teaching + sources); 6 `<strong>Question:</strong>` callouts; no `Intuition:`,
  `Takeaway:`, or `Claim:` block; no `../` or remote raster asset references. All run, all clean.
- **Markup balance — this is the check the first pass missed, and it hid a real defect.** §3's
  orthogonality equation contained a literal `(j<k)`. The HTML tokenizer reads `<k)` as the start of
  a tag name, so the bogus element swallowed the equation's own `</div>` and every element from §4 to
  §7 became a *child of the `.eq` div* — rendered centred, on the grey equation background, under one
  continuous left rule. Grep-based checks cannot see this and it read as "plausible" at a glance
  because the `.callout` boxes already have left rules; a reader spotted it before I did. Fixed by
  writing `&lt;` (the repo's existing convention — see `Control/sda-algebraic-riccati`), and the pass
  now runs a real parser check: `html.parser` with a void-element list, asserting no tag mismatch, no
  unclosed element, and no `<` outside a well-formed tag once `<script>`/`<style>` bodies and comments
  are stripped. Clean.
- Any future revision that puts `<`, `>` or `&` inside math must re-run that parser check.
- Running-example arithmetic — recomputed in exact rational arithmetic by a throwaway script (not
  committed, not needed on the page): steepest descent gives \(x_1=(\tfrac13,\tfrac23)\),
  \(x_2=(0,\tfrac56)\), \(x_3=(\tfrac1{18},\tfrac{17}{18})\), \(x_4=(0,\tfrac{35}{36})\);
  \(r_1^{\mathsf T}r_0=r_2^{\mathsf T}r_1=0\); \(r_2=\tfrac16 r_0\); \(r_1^{\mathsf T}Ar_0=-\tfrac53\). CG gives
  \(x_1=(\tfrac13,\tfrac23)\) and \(x_2=(0,1)\) in exactly two steps. Indefinite instance:
  \(p_0^{\mathsf T}Ap_0=0\) at step 0. Consistent with every number drawn or stated.
- Figure geometry — Figure 1's ellipse semi-axes and rotation recomputed from \(\lambda_1=(5+\sqrt5)/2\)
  and \(q_1\propto(1,0.618034)\); Figure 3's hyperbola paths generated from \(x_1(x_2-1)=c\) and
  pre-clipped to the visible window. Two defects found by rendering and fixed: Figure 3's branches sat
  too far from their asymptotes at the original scale (redrawn at 80&nbsp;px/unit with the origin moved
  left, so the hyperbola shape reads), and Figure 2's \(r_2\) label landed on the \(r_0\) shaft (arrows
  rescaled to 110&nbsp;px/unit and the label moved below-right of the tip).
- Rendering — done, with **Chrome 154 headless**, not Firefox (no Firefox on this machine; Chrome's
  absence from `$PATH` under the tool's classifier was worked around by spawning
  `/usr/bin/google-chrome-stable` from Node, same binary). Inspected at 1440&nbsp;px (full page, plus
  1:1 crops of all three figures) and 420&nbsp;px (full page, plus a mid-page crop). Math renders;
  figures are placed, labelled, and unclipped; the sticky TOC scrolls and highlights; no overlap or
  clipping found in either width; headings and inline math wrap rather than overflow at 420&nbsp;px.
- Landing card — `index.html` re-rendered headless and its computed DOM read back: `#stat-notes` 33,
  `#stat-fields` 7, `#cnt-optimization` 9, `#cnt-algebra` 4, each one higher than before the card was
  added where expected, so the new card is counted once and in both its chips.
- Stage-specific — not applicable: the question-map pass added no script, demo, computed on-page
  number, or changed deep link.

## Notes

- Intentional deviation from `templates/note.html`: no `Intuition:`, `Takeaway:`, or `Claim:` callouts
  anywhere, per the question-map rule. The only callout on the page is each section's opening
  `<strong>Question:</strong>`.
- Three inline-SVG figures, no demo, no `scripts/` directory. §3's and §4's reasoning is exact and
  hand-checkable on the 2×2 example, so no computed table was needed and none was committed.
- Section 6 deliberately changes one assumption (positive definiteness) and keeps everything else —
  same quadratic, same gradient, same step-length fraction — so that the failure is attributable.
