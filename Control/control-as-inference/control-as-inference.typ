// control-as-inference.typ -- a teach-an-engineer question map filled in place from
// .agents/skills/teach-an-engineer/typst-template/note.typ. One deep question per
// section; the expected insights live in summary.md, never here.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

#show: note-ilm.with(
  title: [Control as Inference: Path Integrals for Stochastic Optimal Control],
  authors: "gpt-5-codex",
  abstract: [
    A controlled diffusion is a distribution over trajectories, not a single path. This note
    asks six questions about the path-weight view of stochastic optimal control: what a
    deterministic planner misses, what exponential tilt interacts with a change of path measure,
    what must be normalized, what change of variable linearizes the Hamilton--Jacobi--Bellman
    equation, how the resulting path integral can be estimated without enumerating paths, and
    what fails when noise and control are mismatched or the noise vanishes. The running example
    is a scalar continuous-diffusion plant with additive noise, matched control and noise
    directions, positive noise strength, and quadratic control cost.
  ],
)

// ============================== 1. QUESTION ===============================

= What does a single minimizing trajectory miss? <s1>

#question[For a plant whose state is driven by noise, a deterministic planner compares single
  trajectories. What object must a stochastic planner compare instead, and why can two controls
  that produce the same nominal path have different costs?]

*Running example.* A scalar state $x_t$ follows the controlled diffusion

$ dif x_t = (f(x_t) + G u_t) dif t + sqrt(epsilon) dif W_t, quad epsilon > 0, $ <eq:sde>

where $u_t$ is the control, $G$ maps the control into the state direction, and $W_t$ is a
one-dimensional Wiener process. The finite-horizon cost is

$ J(u) = bb(E)_u [ integral_0^T (ell(x_t) + 1/2 u_t^T R u_t) dif t + Phi(x_T) ], $ <eq:cost>

with $ell$ the running state cost, $Phi$ the terminal cost, and $R$ positive definite. The
discrete-time bridge used in the figures is

$ x_(k+1) = x_k + Delta t (f_k + G u_k) + sqrt(epsilon Delta t) xi_k, quad xi_k ~ cal(N)(0, 1). $ <eq:discrete>

*Facts to reason with.*
- The expectation in #ref(<eq:cost>) is over paths of #ref(<eq:sde>), not over a single trajectory.
- The control may be a feedback law, so $u_t$ can depend on the current state.
- The noise is additive: changing $u_t$ changes the drift, not the diffusion coefficient.
- A nominal path is obtained by setting the noise term in #ref(<eq:discrete>) to zero.

#figure(
  caption: [Two bundles of sample paths from #ref(<eq:discrete>). Inspect how each bundle spreads
    around its nominal path and how the two bundles differ.],
  box(width: 100%, height: 4.4cm)[
    #let x0 = 1.0cm
    #let y0 = 2.2cm
    #let px(t) = x0 + t * 1.15cm
    #let py(v) = y0 - v * 1.6cm
    #place(top + left)[
      #line(start: (px(0), py(-1.1)), end: (px(4.0), py(-1.1)), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #line(start: (px(0), py(-1.1)), end: (px(0), py(1.1)), stroke: 0.8pt + gray)
    ]
    #for i in range(0, 7) {
      let off = (i - 3) * 0.11
      place(top + left)[
        #curve(
          stroke: 0.75pt + navy.lighten(35%),
          curve.move((px(0), py(0.15 + off))),
          curve.line((px(1), py(0.05 + off))),
          curve.line((px(2), py(-0.10 + off))),
          curve.line((px(3), py(-0.18 + off))),
          curve.line((px(4), py(-0.22 + off))),
        )
      ]
    }
    #for i in range(0, 7) {
      let off = (i - 3) * 0.13
      place(top + left)[
        #curve(
          stroke: 0.75pt + teal.lighten(35%),
          curve.move((px(0), py(0.75 + off))),
          curve.line((px(1), py(0.88 + off))),
          curve.line((px(2), py(0.96 + off))),
          curve.line((px(3), py(0.92 + off))),
          curve.line((px(4), py(0.86 + off))),
        )
      ]
    }
    #place(top + left, dx: px(4.0) + 4pt, dy: py(-1.1) - 6pt)[time $t$]
    #place(top + left, dx: px(0) - 0.75cm, dy: py(0.2))[state $x$]
    #place(top + left, dx: px(1.2), dy: py(-0.75))[navy: low control]
    #place(top + left, dx: px(1.2), dy: py(1.15))[teal: high control]
  ],
)

// =============================== 2. NEED ==================================

= What exponential tilt interacts with the change of path measure? <s2>

#question[The controlled path measure differs from the uncontrolled one by a Radon--Nikodym
  derivative. What exponential tilt of the path cost #ref(<eq:cost>) makes the control-dependent
  part of that derivative and the running control cost interact, and what relation between $R$ and
  $G$ is required for the interaction to depend only on the noise?]

*Path measures.* Let $bb(P)_0$ be the path measure of the uncontrolled dynamics

$ dif x_t = f(x_t) dif t + sqrt(epsilon) dif W_t, $ <eq:uncontrolled>

and let $bb(P)_u$ be the path measure of the controlled dynamics #ref(<eq:sde>). For the additive
noise in #ref(<eq:sde>), the Radon--Nikodym derivative is

$ frac(dif bb(P)_u, dif bb(P)_0)(omega)
  = exp( integral_0^T frac((G u_t)^T, sqrt(epsilon)) dif W_t
    - 1/2 integral_0^T frac(norm(G u_t)^2, epsilon) dif t ). $ <eq:girsanov>

*Facts to reason with.*
- The running control cost in #ref(<eq:cost>) is $1/2 u_t^T R u_t$.
- The Girsanov factor #ref(<eq:girsanov>) contains $G u_t$ and the noise strength $epsilon$.
- In the scalar running example, $G = 1$, $R = 1$, and $epsilon > 0$.
- The terminal cost $Phi(x_T)$ depends on the path and does not contain $u_T$ explicitly.

// =============================== 3. IDEA ==================================

= What must be normalized? <s3>

#question[A positive path weight assigns a number to each trajectory. What operation turns that
  weight into a distribution over trajectories, and what does the resulting normalization constant
  represent when the weight is built from a control cost?]

*Path weights.* Let $w(omega) > 0$ be a candidate weight on paths. A constant $Z$ makes
$p(omega) = w(omega) / Z$ a probability density over paths. The path space here is the space of
continuous trajectories on $[0, T]$, so sums over finitely many paths are replaced by an integral
over an infinite-dimensional space.

*Facts to reason with.*
- $Z$ is a single positive number, not a function of the path.
- The normalized weight $p$ assigns more mass to paths with larger $w$.
- The running example keeps the same state cost, terminal cost, control cost, and noise strength as
  #ref(<eq:cost>) and #ref(<eq:girsanov>).
- A control law changes the distribution of paths, so two different controls generally produce two
  different normalized weights.

#figure(
  caption: [Positive path weights $w_i$ for five trajectories. Inspect the bars and the dashed
    level marked $?$; the question asks what the missing constant means, not which bar is largest.],
  box(width: 100%, height: 3.8cm)[
    #let x0 = 1.2cm
    #let y0 = 2.7cm
    #for i in range(0, 5) {
      let h = (0.45 + 0.18 * i) * 1cm
      place(top + left, dx: x0 + i * 1.35cm, dy: y0 - h)[
        #rect(width: 0.65cm, height: h, fill: navy.lighten(20%))
      ]
      place(top + left, dx: x0 + i * 1.35cm + 0.12cm, dy: y0 + 2pt)[$w_#(i+1)$]
    }
    #place(top + left)[
      #line(start: (x0 - 0.35cm, y0 - 0.55cm), end: (x0 + 6.2cm, y0 - 0.55cm),
        stroke: (thickness: 0.8pt, dash: "dashed", paint: teal))
    ]
    #place(top + left, dx: x0 + 6.3cm, dy: y0 - 0.75cm)[$?$]
    #place(top + left)[
      #line(start: (x0 - 0.35cm, y0), end: (x0 + 6.2cm, y0), stroke: 0.8pt + gray)
    ]
  ],
)

// =============================== 4. WHY ===================================

= What change of variable linearizes the HJB equation? <s4>

#question[The Hamilton--Jacobi--Bellman equation #ref(<eq:hjb>) is nonlinear because of the
  quadratic term in the gradient of the value function. What change of variable removes that
  nonlinearity, and how is the optimal control recovered from the transformed variable?]

*Value function.* Let $v(t, x)$ be the value function for #ref(<eq:cost>) and #ref(<eq:sde>) on
$[t, T]$. The Hamilton--Jacobi--Bellman equation is

$ -partial_t v(t, x)
  = min_u { ell(x) + 1/2 u^T R u
    + (f(x) + G u)^T nabla v(t, x)
    + epsilon/2 Delta v(t, x) }, $ <eq:hjb>

with terminal condition

$ v(T, x) = Phi(x). $ <eq:terminal>

*Facts to reason with.*
- $nabla v$ and $Delta v$ are taken with respect to the state $x$.
- The minimization over $u$ is inside the equation; the minimizer is a function of $nabla v$.
- In the scalar running example, $G = 1$, $R = 1$, and $epsilon > 0$.
- The terminal condition #ref(<eq:terminal>) is fixed by $Phi$.

// ============================== 5. METHOD =================================

= How can the path integral be estimated without enumerating paths? <s5>

#question[The path integral involves an expectation over an infinite-dimensional path space. If a
  simulator can draw trajectories from a reference process, which reference drift makes the sample
  weights computable for the running example, and which part of the weight determines how quickly
  the estimator's variance grows with the horizon?]

*Reference process.* Suppose the simulator can draw paths from

$ dif x_t = b(x_t) dif t + sqrt(epsilon) dif W_t $ <eq:reference>

for a chosen drift $b$. An expectation under one path measure can be rewritten as an expectation
under another by multiplying each sampled path by a Radon--Nikodym weight.

*Facts to reason with.*
- The reference drift $b$ in #ref(<eq:reference>) is a modeling choice.
- The noise strength $epsilon$ and the terminal time $T$ are fixed in the running example.
- A Monte Carlo estimate from $N$ independent paths has error that decreases like $1/sqrt(N)$.
- The variance of the estimate depends on the distribution of the path weights, not only on $N$.

// ============================== 6. LIMITS =================================

= What breaks when matching fails or noise vanishes? <s6>

#question[The matched case has $R = G^T G$ and $epsilon > 0$. Remove one condition at a time:
  when the control directions and noise directions no longer match, what fails? When $epsilon -> 0$,
  what fails? Which failure belongs to the path-weight construction, and which belongs to the Monte
  Carlo estimator?]

*Two perturbations.* Keep the plant #ref(<eq:sde>), the cost #ref(<eq:cost>), and the Girsanov
factor #ref(<eq:girsanov>). The matched case is $R = G^T G$ with $epsilon > 0$. The mismatched case
keeps $epsilon > 0$ but allows $R != G^T G$. The small-noise case keeps $R = G^T G$ but takes
$epsilon -> 0$.

*Facts to reason with.*
- The control cost uses $R$; the path-measure change uses $G$.
- The Girsanov factor #ref(<eq:girsanov>) contains $1/sqrt(epsilon)$ and $1/epsilon$.
- As $epsilon -> 0$, the diffusion term in #ref(<eq:sde>) vanishes and the plant approaches a
  deterministic system.
- The normalized path weight from section 3 is still defined for every $epsilon > 0$.

// ============================== 7. SOURCES ================================

= Sources and further reading

No external sources have been consulted yet; this note makes no external claims.
