# POMDP: Acting on a Belief, Not a Guess — teaching handoff

**Stage:** complete note (published-ready); belief update is the spine, EPSILON is the deep
application.

**Artifact:** `Robotics/pomdp/pomdp.typ`, compiled to `Robotics/pomdp/pomdp.pdf`; 13 pages.
Bibliography `refs.bib`; numbers reproduced by `scripts/tiger_check.py`. Demo sidecar
`pomdp-demo.html` (belief-update slider).

## Audience

An engineer who knows MDPs (`T`, `R`, `V`, discounting) and Bayes's rule, confirmed by the reader.
No POMDP background assumed. The reader asked for the application to go deep into the POMDP that the
EPSILON driving planner uses.

## Route and assessment

| Section | PDF page | What it establishes | Why it is there |
|---|---|---|---|
| `s1` The state is gone | 3 | MDP recap; the tiger problem and its rewards/observations | Smallest model where hiding the state changes the decision; no POMDP formalism yet |
| `s2` A belief, and the rule that moves it | 4 | POMDP tuple; the belief; Bayes update (Eq. 1); two-state belief simplex; the tiger update; sufficiency | The spine. All later sections move or query this update |
| `s3` Why a guess is not enough | 5 | Greedy value `A(b)`; listen-then-act value `L(b)`; the flat −7.5 region; crossovers 0.159/0.841; value of information 27.5; PWLC value | The validated bridge from the review sample. A guess is not a state |
| `s4` The tree the update grows | 6 | Belief-space Bellman (Eq. 6); policy is a tree; `9^25 ≈ 7e23` explosion | Names why exact search is infeasible, motivating s5–s7 |
| `s5` Many agents, one factored transition | 7–8 | Joint state and hidden states; only ego acts; factored transition (Eq. 7); factored belief update (Eq. 8); the driver model as the only coupling; "prediction is the belief-update step"; check exercise | The core of the EPSILON formulation (paper §IV) |
| `s6` From a policy tree to one decision | 9 | Trace extraction (Eq. 9), mode collapse (Eq. 10), the decision `D_t` | How a solved tree becomes one output for the motion planner |
| `s7` Making it real-time: guided observation branching | 10 | Remaining uncertainty; semantic action = center-line; categorical intention belief; conditional focused branching; the frozen-hidden-state assumption and what stays closed-loop | The efficiency mechanism (paper §V-C, §VII-C) |
| `s8` What is exact, and what was traded away | 11 | Separates the exact belief update from the approximate search | Honest accounting of assumptions, per the skill |
| `s9` Sources and further reading | 12 | Source support; unconsulted further reading labeled | — |

## Expected insights and traps

- The decision variable is the belief, not the MAP state. At `b = 0.6` the guess loses 34 and
  observing first loses 7.5. Trap: reading "the guess" as merely less accurate — it is off by the
  whole value of the observation (26.5 net, 27.5 gross).
- `L(b)` is flat at −7.5 on `[0.15, 0.85]` because listening's information has the same worth across
  the middle. It meets the greedy V at 0.159/0.841. Trap: assuming the listen region is narrow.
- The POMDP value function is a maximum of lines (one per policy tree), hence convex and
  piecewise-linear. Trap: treating "value of a belief" as a weighted average of state values.
- In the factored transition the kinematics are per-agent but the driver model reads the *joint*
  state; that single factor is the interaction. Trap: reading Eq. 7 as independent agents.
- Predicting and planning are not two modules: the hidden states are estimated *by* the belief
  update, so prediction is the belief-update step. Trap: calling a predict-then-plan stack "a
  POMDP".
- The frozen hidden state during forward simulation kills mid-horizon mind-changing but not
  interaction (actions still depend on the simulated previous state, so rollouts stay closed-loop).
  Trap: concluding the simulation is open-loop.

## Sources consulted

| Source and passage read | Grounds |
|---|---|
| Ding, Zhang, Chen, Shen, *IEEE T-RO* 38(2):1118–1138, 2022 (arXiv:2108.07993), §IV "Problem Formulation" | POMDP tuple; belief update Eq. (1); policy/Bellman; trace extraction and mode collapse; joint state, hidden states, ego-only action; factored transition Eq. (2); observation independence and factored belief update Eq. (3); prediction-is-belief-update claim |
| Same, §V-C "Guided Observation Branching" | Monte Carlo/particle-filter baseline; ego-observable and noise-free assumptions; deterministic semantic action; hidden states frozen during simulation; `O(|Z|^d)` cost; semantic action = center-line; scenarios and belief weights; CFB and critical-agent selection |
| Same, §V-F "Policy Selection", §VII-C "Intention Estimator" | Belief-weighted scenario score and parallel policy evaluation; center-line encoder + LSTM + softmax, NLL loss, class count independent of road |
| Kaelbling, Littman, Cassandra, *Artificial Intelligence* 101(1–2):99–134, 1998, §5.1 | Tiger problem definition and the one-step/two-step policy observation that listening beats acting under uncertainty |

## Checks

- Build — `typst compile --root .` exits 0 with no warnings; 13 pages.
- Page map — `s1` 3, `s2` 4, `s3` 5, `s4` 6, `s5` 7 (continues 8), `s6` 9, `s7` 10, `s8` 11,
  `s9` 12, Bibliography 13; cover 1, contents 2. Each section fits its page except `s5`, which runs
  to page 8 with Figure 4 and the check exercise.
- Rendered — all 13 pages rasterized and inspected. Fixed in this pass: Figure 5's boxes no longer
  overflow (labels shortened and wrapped inside fixed boxes); Figure 2 rescaled to 5.5 cm so `s3`
  fits one page; `s2` and `s3` prose trimmed to remove near-empty spill pages; Figure 3's "depth H"
  label moved off the dot column.
- Numeric — `scripts/tiger_check.py` (standard library only) prints b=0.6 → `P(growl left)=0.57`,
  `b'=0.894737`, `b''=0.209302`, `A=-34`, `L=-7.5`, value of growl 27.5, net 26.5, flat region
  `[0.15, 0.85]`, crossovers 0.159091/0.840909; it asserts the closed form Eq. (5) against the
  direct recursion at seven beliefs.
- Structural — no `FILL:` slots; five figures, each `#ref`'d in prose; one `#hook` (s1), one `#check`
  (s5) with its answer visible below; no `"../"` paths.
- Landing card — one new card in `#grid` pointing at the compiled PDF, with `data-category`,
  `data-field`, `data-tags`; hero and per-field counts unchanged otherwise.
- Demo — `pomdp-demo.html` exercises the belief update: a belief slider and an observation select
  redraw the prior, the two candidate posteriors, and the update arrow; checked in
  `google-chrome-stable` headless at two slider positions.
- Environment — `@preview/ilm:2.1.1` resolves from the local Typst cache.

## Notes

- Placement: `Robotics/pomdp/`, as the theory note beside `Robotics/epsilon-planning/`, whose card
  already carries a `pomdp` tag. Card categories are `robotics ai control`, matching the epsilon
  note.
- Figure 3's branch count is presented as arithmetic (25 steps × 9 controls), not as a claim from
  the paper.
- The `9^25` and `O(|Z|^d)` figures are the only order-of-magnitude statements; the latter is the
  paper's, the former is arithmetic.
