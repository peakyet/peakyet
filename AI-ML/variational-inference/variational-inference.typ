// variational-inference.typ -- a teach-an-engineer question map, filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ. One deep question per section;
// the expected insights live in summary.md, never here.
//
// Every number quoted below is an arithmetic consequence of the model in eq:lik or a
// quadrature of it, reproduced by scripts/posterior_points.py.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

#show: note-ilm.with(
  title: [Variational Inference: Ten Flips and an Unknown Bias],
  authors: "Weifeng Zeng",
  abstract: [
    Fitting a Bayesian model means describing a posterior density, and for nearly every model
    worth fitting you can evaluate that density's numerator wherever you like and still not have
    a probability. This note asks six questions about what to do in that position: what a density
    still lacks once all of its values are known, why conjugate algebra and a sampling chain each
    stop short, which quantity an approximation can be optimized on with the missing number
    nowhere in it, what the resulting bound guarantees and what it keeps out of view, what a
    product family cannot carry, and what a one-bump fit does to a two-bump truth. All six are
    posed against a single coin model whose exact posterior is known, so any answer the reader
    gives can be checked against it rather than against this page.
  ],
)

// ============================== 1. QUESTION ===============================

= One curve, and the number it does not tell you <s1>

#question[#ref(<eq:bayes>) hides the whole difficulty in a single number. In figure 1 the joint
  density it comes from peaks at about $0.27$, and in this one-coin case that number is
  reachable by hand. Predict how the *ratio* between the joint's value at its peak and the value
  of that number grows when the model carries $d$ independent copies of this coin instead of
  one, and then explain why the growth of that ratio -- not the difficulty of doing the
  integral -- is what defeats a local search, a fine grid, and a uniform random sample alike
  once $d$ reaches a hundred.]

*The running example.* A coin has an unknown bias $theta$ in the open interval $(0, 1)$. You
observe $D$: ten flips, seven heads, three tails, with the order not recorded. The likelihood is

$ p(D | theta) = binom(10, 7) theta^7 (1 - theta)^3 = 120 theta^7 (1 - theta)^3 $ <eq:lik>

Take the prior to be uniform on $(0, 1)$, so the joint density $p(theta, D) = p(D | theta)
p(theta)$ is exactly the curve plotted below. Bayes's rule then reads

$ p(theta | D) = frac(p(D | theta) p(theta), p(D)) quad "with" quad p(D) = integral_(0)^1
  p(D | theta) p(theta) dif theta $ <eq:bayes>

*Facts to reason with.*
- With the uniform prior the integral in #ref(<eq:bayes>) is a Beta function: the posterior is
  $"Beta"(8, 4)$, with mean $2/3$, mode $7/10$, and standard deviation about $0.131$. This note
  is built so that you always have one case whose truth you can look up.
- Take $d$ coins, each flipped ten times with seven heads, all independent under the uniform
  prior. Then the joint density is the product of $d$ copies of #ref(<eq:lik>) and $p(D)$ is the
  $d$-th power of the one-coin integral.
- A grid that resolves each latent coordinate at 100 levels evaluates $100^d$ joint densities.
- A density value is a value *per unit of the coordinate*, not a probability: no event and no
  density value can be read off the other, and the joint of the $d$-coin model is a density on
  the whole cube $(0, 1)^d$ at once.

#figure(
  caption: [The joint density $p(theta, D)$ of #ref(<eq:lik>), sampled every $0.05$ in $theta$
    and drawn between the samples; the dashed rule marks the peak. Inspect what this curve's
    height is, and what it is not.],
  box(width: 100%, height: 5cm)[
    #let pts = ((0.0, 0.0), (0.05, 0.0), (0.1, 0.0), (0.15, 0.0001), (0.2, 0.0008),
      (0.25, 0.0031), (0.3, 0.009), (0.35, 0.0212), (0.4, 0.0425), (0.45, 0.0746),
      (0.5, 0.1172), (0.55, 0.1665), (0.6, 0.215), (0.65, 0.2522), (0.7, 0.2668),
      (0.75, 0.2503), (0.8, 0.2013), (0.85, 0.1298), (0.9, 0.0574), (0.95, 0.0105),
      (1.0, 0.0))
    #let px(t) = 1.3cm + t * 12.4cm
    #let py(v) = 4.15cm - v * 11.3cm
    #place(top + left)[
      #line(start: (px(0), py(0)), end: (px(0), py(0.30)), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #line(start: (px(0), py(0)), end: (px(1.06), py(0)), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #line(start: (px(0.7), py(0)), end: (px(0.7), py(0.2668)),
        stroke: (thickness: 0.7pt, dash: "dashed", paint: gray))
    ]
    #place(top + left)[
      #curve(stroke: 1.3pt + navy,
        curve.move((px(pts.at(0).at(0)), py(pts.at(0).at(1)))),
        ..pts.slice(1).map(p => curve.line((px(p.at(0)), py(p.at(1))))))
    ]
    #place(top + left)[
      #line(start: (px(0), py(0.1)), end: (px(0.012), py(0.1)), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #line(start: (px(0), py(0.2)), end: (px(0.012), py(0.2)), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #line(start: (px(0), py(0.3)), end: (px(0.012), py(0.3)), stroke: 0.8pt + gray)
    ]
    #place(top + left, dx: px(0) - 2.5em, dy: py(0.1) - 0.45em)[$0.1$]
    #place(top + left, dx: px(0) - 2.5em, dy: py(0.2) - 0.45em)[$0.2$]
    #place(top + left, dx: px(0) - 2.5em, dy: py(0.3) - 0.45em)[$0.3$]
    #place(top + left, dx: px(0.7) - 0.15em, dy: py(0) + 2pt)[$0.7$]
    #place(top + left, dx: px(0.5) - 0.45em, dy: py(0) + 2pt)[$0.5$]
    #place(top + left, dx: px(0.72), dy: py(0.2668) - 1.6em)[peak of the joint]
    #place(top + left, dx: px(0) - 4.6em, dy: py(0.30) - 1.4em)[joint density $p(theta, D)$]
    #place(top + left, dx: px(1.02) - 2.9em, dy: py(0) + 2pt)[bias $theta$]
  ],
)

// =============================== 2. NEED ==================================

= The two routes that already exist <s2>

#question[A Markov chain never evaluates $p(D)$: it compares posterior values with each other,
  and in every such comparison the unknown number cancels. Say which two things the chain still
  cannot hand you that the closed form of section 1 can, and name the property that the change
  of prior below destroys -- the property that made the closed form available in the first
  place.]

*Route one, conjugate algebra.* A $"Beta"(a, b)$ prior on $theta$ produces a
$"Beta"(a + 7, b + 3)$ posterior from the data above: the answer is two numbers, and the
normalizer arrives with them. Section 1 used $a = b = 1$.

*The change.* Work instead on the logit scale,

$ phi = log (theta / (1 - theta)) quad "so" quad theta = 1 / (1 + exp(-phi)) $ <eq:logit>

and put a standard normal prior on $phi$. Written as a density on the bias, that prior is

$ p(theta) = frac(1, theta (1 - theta)) · frac(1, sqrt(2 pi)) exp(-1/2 log
  (theta / (1 - theta))^2) $ <eq:tilt>

*Facts to reason with.*
- The tilted prior is fully specified and normalized as a density on $phi$; it is not a Beta
  density, and neither is the posterior it produces. The tilted posterior is still a single
  bump, but its peak sits near $theta = 0.66$ rather than $0.7$, and its $p(D)$ has no closed
  form. Both statements are quadrature results, reproduced by
  #emph[scripts/posterior_points.py].
- *Route two, a sampling chain.* To move from a current state $theta_t$ to a proposal
  $theta'$, the chain forms a ratio $p(theta' | D) / p(theta_t | D)$ and accepts on the strength
  of it. By #ref(<eq:bayes>) that ratio is a ratio of joint densities, so $p(D)$ appears on
  neither side. What comes out the other end is a list of parameter values in which consecutive
  entries depend on each other, so a list of length $m$ costs at least $m$ evaluations of
  #ref(<eq:tilt>) times #ref(<eq:lik>), and the list is judged to be trustworthy from the
  contents of the list itself.

// =============================== 3. IDEA ==================================

= Choosing the shape of the answer first <s3>

#question[Let $Q$ be the family of $"Beta"(alpha, beta)$ densities with $alpha > 1$ and
  $beta > 1$, and score a candidate $q$ by the relative entropy of #ref(<eq:relent>) with $q$ in
  the first slot. Substitute #ref(<eq:bayes>) into that integral and sort the result into the
  pieces that depend on $q$ and the piece that does not. Report which pieces you can now
  evaluate for the tilted model of section 2, which single piece you have to give up on, and why
  giving it up cannot change which member of $Q$ wins.]

*The measure.* The relative entropy between a candidate $q$ and a target density $p$ is

$ "KL"(q, p) = integral_(0)^1 q(theta) log (q(theta) / p(theta)) dif theta $ <eq:relent>

*Facts to reason with.*
- Every member of $Q$ is strictly positive on $(0, 1)$, has a single interior peak, and has a
  finite log-normalizer, so #ref(<eq:relent>) is finite against the tilted posterior as well.
- On the log scale, the joint is a sum of two computable pieces:
  $log p(theta, D) = log p(D | theta) + log p(theta)$, with both terms readable off
  #ref(<eq:lik>) and #ref(<eq:tilt>) at any $theta$ in $(0, 1)$.
- Under a $q$ in $Q$, the three integrals $integral_(0)^1 q(theta) log theta dif theta$,
  $integral_(0)^1 q(theta) log (1 - theta) dif theta$, and
  $integral_(0)^1 q(theta) log q(theta) dif theta$ are available in closed form; so is
  $integral_(0)^1 q(theta) dif theta$, which is one.
- The family $Q$ is fixed before any data is seen, and never revisited afterwards in this note.

// =============================== 4. WHY ===================================

= What the bound buys, and what it keeps out of view <s4>

#question[Write $cal(L)(q)$ for the $q$-dependent part you isolated in section 3, and take the
  two facts below as given. Combine them with the decomposition you found. What relation must
  $cal(L)(q)$ and $log p(D)$ satisfy for every $q$ in $Q$, and what would have to be true of $q$
  for that relation to hold as an equality? Then the practical half: you run the optimizer,
  $cal(L)$ climbs, and the climbs stop. Say what stopping certifies about $q$ inside $Q$, what it
  certifies about $q$ against the true posterior, and why "more iterations" and "a richer
  family" are not interchangeable responses to a fit you dislike.]

*Facts to reason with.*
- A relative entropy is never negative, and it is zero only where its two densities agree
  almost everywhere.
- In the tilted model of section 2, $log p(D)$ is not computable. In the uniform-prior model of
  section 1 it is computable by hand, which makes that first case the only place in this note
  where a claim about the relation you are looking for can be checked numerically.
- The tilted posterior is not a member of $Q$, so no $q$ in $Q$ makes
  $"KL"(q, p(theta | D))$ zero there.

// ============================== 5. METHOD =================================

= Twelve coins, and what a product cannot carry <s5>

#question[#ref(<eq:prod>) is the family being fitted to the twelve-coin model, and figure 2 is
  the posterior's own one-sigma contour for one pair of coins, drawn from the computed
  covariance rather than from a sketch. Predict two things about the fit the cycling procedure
  converges to. First, which of the three widths listed in the facts each fitted factor ends up
  with -- and what about the procedure decides that. Second, what the fitted product density
  puts mass on that the plotted contour does not, and which feature of the contour no choice of
  the twelve factors could ever reproduce.]

*The model.* Twelve coins, each flipped ten times. Six came up heads seven times, six came up
heads three times. Put a multivariate normal prior on the twelve logits of #ref(<eq:logit>):
mean zero, unit standard deviations, and correlation $+0.99$ between every pair -- one shared
factor, twelve coins cut from nearly the same stock. The approximating family is a product of
one-dimensional factors,

$ q(theta_1, ..., theta_12) = product_(j=1)^(12) q_j(theta_j) $ <eq:prod>

*Facts to reason with.*
- Integrating #ref(<eq:prod>) over every coordinate except $theta_j$ leaves $q_j$ exactly, so a
  factor is the fit's own marginal for that coordinate whatever the truth is there.
- The usual optimizer here never touches the twelve factors at once: it improves one factor
  $q_j$ with the other eleven held at their current shapes, then cycles through the twelve
  again.
- Work at the posterior's own curvature, which is Gaussian here. Every coin's posterior
  marginal standard deviation is $0.203$ and every pair's posterior correlation is $+0.763$.
  Three widths are then available for a single factor: that marginal $0.203$, the standard
  deviation of one coin's logit *given* one named partner, which is $0.131$, and of one coin
  *given* all other eleven, which is $0.103$.
- The prior is strong enough that the pooled fit barely separates the coins: the twelve
  posterior means are $theta approx 0.505$ for the seven-head coins and $theta approx 0.495$ for
  the three-head ones.

All numbers here, including the contour, come from #emph[scripts/mean_field_checks.py].

#figure(
  caption: [The posterior for the logits of coins 1 and 7, one standard deviation of the
    computed covariance, plus each coordinate's own marginal interval as a teal rule just
    outside its axis. Inspect the contour against the square the two rules span.],
  box(width: 100%, height: 5.2cm)[
    #let x0 = 5.4cm          // left edge of the plot square
    #let y0 = 4.6cm          // baseline
    #let w = 3.7cm           // square side, in cm
    #let px(t) = x0 + t * w
    #let py(v) = y0 - v * w  // values grow upward
    // one-sigma contour from the computed covariance; axes span +-0.28 in logit units
    #let ell = ((0.8752, 0.8055), (0.8312, 0.8261), (0.7671, 0.8221), (0.6873, 0.7939),
      (0.5970, 0.7434), (0.5025, 0.6737), (0.4102, 0.5898), (0.3263, 0.4975),
      (0.2566, 0.4030), (0.2061, 0.3127), (0.1779, 0.2329), (0.1739, 0.1688),
      (0.1945, 0.1248), (0.2384, 0.1041), (0.3025, 0.1080), (0.3823, 0.1363),
      (0.4727, 0.1870), (0.5673, 0.2566), (0.6596, 0.3404), (0.7434, 0.4327),
      (0.8130, 0.5273), (0.8637, 0.6177), (0.8920, 0.6975), (0.8959, 0.7616))
    #place(top + left)[
      #polygon(fill: navy.lighten(82%), stroke: (paint: navy, thickness: 1pt),
        ..ell.map(v => (px(v.at(0)), py(v.at(1)))))
    ]
    #place(top + left)[
      #line(start: (px(0), py(0)), end: (px(0), py(1.0)), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #line(start: (px(0), py(0)), end: (px(1.0), py(0)), stroke: 0.8pt + gray)
    ]
    // the two zero lines, which is where a logit of 0 -- a fair coin -- sits
    #place(top + left)[
      #line(start: (px(0.5), py(0)), end: (px(0.5), py(1.0)),
        stroke: (thickness: 0.6pt, dash: "dashed", paint: gray))
    ]
    #place(top + left)[
      #line(start: (px(0), py(0.5)), end: (px(1.0), py(0.5)),
        stroke: (thickness: 0.6pt, dash: "dashed", paint: gray))
    ]
    // each coordinate's own marginal interval, drawn outside the plot square
    #place(top + left)[
      #line(start: (px(0.1723), y0 + 0.22cm), end: (px(0.8973), y0 + 0.22cm),
        stroke: (thickness: 2pt, paint: teal, cap: "round"))
    ]
    #place(top + left)[
      #line(start: (x0 - 0.22cm, py(0.1027)), end: (x0 - 0.22cm, py(0.8277)),
        stroke: (thickness: 2pt, paint: teal, cap: "round"))
    ]
    #place(top + left, dx: px(1.0) - 0.25em, dy: y0 + 0.14cm)[$phi_1$]
    #place(top + left, dx: x0 - 0.6em, dy: py(1.0) - 0.95em)[$phi_7$]
    #place(top + left, dx: px(0.5) + 0.12cm, dy: py(1.0) - 0.15cm)[fair coin, $phi = 0$]
  ],
)

// ============================== 6. LIMITS =================================

= Two bumps, one bump, and which way the entropy points <s6>

#question[Change one condition: replace the single-bump prior #ref(<eq:tilt>) with the
  two-bump one below, so the tilted posterior has two comparable bumps. Fit the same family $Q$
  twice -- once with the relative entropy of #ref(<eq:relent>), once with its two densities
  exchanged. Predict where each fit places its mean and how wide it makes its spread, and say
  what about each integral forces that outcome. Last: you must report one of the two fits as
  your uncertainty about $theta$, and a colleague then simulates ten flips from a coin drawn
  from the bump your report ignored. Which of the two reports is the more dangerous, and why?]

*The change.* Let the logit $phi$ come from an equally weighted mixture of two normals,

$ p(phi) = 1/2 · "Normal"_(0, 0.3^2)(phi) + 1/2 · "Normal"_(1.8, 0.3^2)(phi) $ <eq:twobump>

where $"Normal"_(m, s^2)$ is the density of a normal with mean $m$ and standard deviation $s$,
so #ref(<eq:twobump>) puts one bump on the logit scale at $phi = 0$, that is $theta = 0.5$, and
another at $phi = 1.8$, that is $theta approx 0.855$.

*Facts to reason with.*
- Against the same ten-flip data, the posterior under #ref(<eq:twobump>) has a bump near
  $theta = 0.54$ and a bump near $theta = 0.85$, with roughly half the posterior mass on each
  side of $theta = 0.68$ and a deep valley between them: the density falls to about $0.16$ in
  the valley against peak heights of $2.96$ and $5.39$. These are quadrature results, from the
  same script.
- Every $q$ in $Q$ has one interior peak, so the truth is not in $Q$; the fit has to choose
  something to be wrong about.
- $"KL"(q, p) != "KL"(p, q)$: the two directions weight the same disagreement differently, and
  #ref(<eq:relent>) shows where the $q$ sits in that weighting.

// ============================== 7. SOURCES ================================

= Sources and further reading

No external sources have been consulted for this note, and it makes no claim about prior work,
attribution, or the history of any method. Every quantity stated above is either an arithmetic
consequence of the model in #ref(<eq:lik>) or a numerical quadrature of a density defined here.
The one-coin numbers come from #emph[scripts/posterior_points.py] and the twelve-coin numbers from
#emph[scripts/mean_field_checks.py]. The expected answers to the six
questions, and the reading that would ground them, are kept in #emph[summary.md] rather than in the
document.
