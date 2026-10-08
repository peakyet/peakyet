// pomdp.typ -- a teaching-complex-ideas note. The belief update is the spine; the deep
// application is the POMDP inside EPSILON (Ding et al., T-RO 2022), whose note lives at
// Robotics/epsilon-planning/epsilon-planning.html.
//
// Build from the repository root:
//   typst compile --root . Robotics/pomdp/pomdp.typ Robotics/pomdp/pomdp.pdf
//
// Every number quoted below is either an exact consequence of the two-state tiger problem
// defined in section 1 or is taken from the cited paper; scripts/tiger_check.py reproduces
// the tiger arithmetic.

#import "/.agents/skills/teaching-complex-ideas/typst-template/teaching.typ": note-ilm, hook, check, navy, teal, gray

#show: note-ilm.with(
  title: [POMDP: Acting on a Belief, Not a Guess],
  authors: "Amp",
  bibliography: bibliography("refs.bib"),
  abstract: [
    An MDP hands the agent the state; a POMDP hides it and hands back an observation. This note
    follows one thread through that change: the agent's knowledge becomes a probability
    distribution over states, Bayes's rule moves the distribution, and every decision is read off
    it. The first half builds the belief, shows why acting on the most likely state can be far
    worse than paying to observe, and writes the belief-space Bellman equation whose search tree
    explodes. The second half is the part an operational planner actually keeps: the factored
    transition that turns one joint model into an ego model times a driver model per other agent
    -- which makes prediction the belief-update step inside planning -- and the guided observation
    branching that shrinks the belief tree enough to search in real time. The application is the
    POMDP inside the EPSILON driving planner.
  ],
)

= The state is gone <s1>

A Markov decision process gives the agent a state $s$, a transition model $T(s'|s,a)$, a reward
$R(s,a)$, and the assumption that the agent *sees* $s$ at every step. Optimal behavior is then a
function of the state: a policy $pi(s)$, and a value $V(s)$ that the policy tries to maximize. A
POMDP deletes exactly one thing -- the sight of the state -- and keeps everything else.

The smallest problem in which that deletion matters is the *tiger problem*. Two doors stand in
front of the agent; behind one is a tiger, behind the other a reward. The agent cannot see behind
the doors. It can open a door, or it can listen for a growl. Listening is cheap and informative but
imperfect.

#table(
  columns: (auto, 1fr, 1fr),
  inset: 7pt,
  align: (left, left, left),
  [*Action*], [*Reward*], [*Observation*],
  [open left], [$+10$ if the tiger is right, $-100$ if it is left], [none],
  [open right], [$+10$ if the tiger is left, $-100$ if it is right], [none],
  [listen], [$-1$], [growl from the left with $0.85$ if the tiger is left, else $0.15$],
)

Listening leaves the world alone. Opening a door ends the episode and the tiger is placed again at
random, so after opening a door the agent knows nothing about the next one.

#hook[At the moment the agent must act, what does it actually know? It has never seen the state.
  Every observation is in the past, and the state itself is unobservable. So the agent's knowledge
  is *not* a state -- it is a set of probabilities over states. What happens to a policy when the
  object it reads is a distribution rather than a point?]

= A belief, and the rule that moves it <s2>

Formally a POMDP is a tuple $⟨X, A, Z, T, O, R⟩$: states $X$, actions $A$,
observations $Z$, a transition model $T(x_(t-1), a_t, x_t) = p(x_t | x_(t-1), a_t)$, an
observation model $O(x_t, z_t) = p(z_t | x_t)$, and a reward $R : X times A -> RR$. Because the
state is not seen, the agent carries a *belief* $b$, a probability distribution over $X$, and moves
it after acting and observing. Bayes's rule gives the move:

$ b_t(x_t) = eta O(x_t, z_t) integral_(x_(t-1) in X) T(x_(t-1), a_t, x_t) b_(t-1)(x_(t-1)) dif x_(t-1) . $ <eq:update>

Read the three pieces in order. The prior $b_(t-1)$ is pushed forward by the motion model $T$ to
say where the state probably went; the observation model $O$ scores each candidate state by how
well it explains what was actually seen; the normalizer $eta$ makes the result a distribution
again. Every POMDP belief update is this one equation @ding2021epsilon.

With two states, one number is enough. Write $b = P("tiger is left")$, so $1-b$ is the probability
of the other case and the possible beliefs form the interval $[0,1]$ -- the *belief simplex* for
two states. Listening does not move the tiger, so the observation model alone updates the belief.
A growl from the left arrives with probability $P("growl left") = 0.85 b + 0.15(1-b) = 0.15 + 0.7 b$
and leaves

$ b' = frac(0.85 b, 0.15 + 0.7 b) , quad b'' = frac(0.15 b, 0.85 - 0.7 b) . $ <eq:tigeru>

Start from $b = 0.6$: a growl on the left arrives with probability $0.57$ and moves the belief to
$b' = 0.8947$; a growl on the right arrives with probability $0.43$ and moves it to $b'' = 0.2093$.
The two numbers $0.8947$ and $0.2093$ -- not the growl, and not the old $0.6$ -- are the agent's new
knowledge. That is the object a policy has to read.

#figure(
  caption: [The belief update of #ref(<eq:tigeru>) as a map. The prior sits on the lower axis;
    each possible growl moves it to one point on the upper axis. The state never appears, only
    these two candidate posteriors and the probabilities that choose between them.],
  box(width: 100%, height: 4.0cm)[
    #let px(b) = 1.6cm + 11.6cm * b
    #place(top + left)[#line(start: (px(0), 1.1cm), end: (px(1), 1.1cm), stroke: 0.7pt + gray)]
    #place(top + left)[#line(start: (px(0), 3.1cm), end: (px(1), 3.1cm), stroke: 0.7pt + gray)]
    // prior
    #place(top + left, dx: px(0.6) - 1.6pt, dy: 3.1cm - 1.6pt)[#circle(radius: 1.6pt, fill: navy)]
    #place(top + left, dx: px(0.6) - 0.55cm, dy: 3.1cm + 0.16cm)[#text(size: 8.5pt, fill: navy)[prior $b = 0.6$]]
    // posteriors
    #place(top + left, dx: px(0.2093) - 1.6pt, dy: 1.1cm - 1.6pt)[#circle(radius: 1.6pt, fill: teal)]
    #place(top + left, dx: px(0.8947) - 1.6pt, dy: 1.1cm - 1.6pt)[#circle(radius: 1.6pt, fill: teal)]
    #place(top + left, dx: px(0.2093) - 0.9cm, dy: 1.1cm - 0.5cm)[#text(size: 8.5pt, fill: teal)[$b'' = 0.2093$]]
    #place(top + left, dx: px(0.8947) - 0.5cm, dy: 1.1cm - 0.5cm)[#text(size: 8.5pt, fill: teal)[$b' = 0.8947$]]
    // the two moves
    #place(top + left)[#line(start: (px(0.6), 3.0cm), end: (px(0.2093), 1.25cm), stroke: 0.8pt + teal)]
    #place(top + left)[#line(start: (px(0.6), 3.0cm), end: (px(0.8947), 1.25cm), stroke: 0.8pt + teal)]
    #place(top + left, dx: px(0.28), dy: 2.35cm)[#text(size: 8.5pt, fill: gray)[growl right, $0.43$]]
    #place(top + left, dx: px(0.68), dy: 2.35cm)[#text(size: 8.5pt, fill: gray)[growl left, $0.57$]]
    // axis ends
    #place(top + left, dx: px(0) - 0.12cm, dy: 1.1cm + 0.12cm)[#text(size: 8pt, fill: gray)[$0$]]
    #place(top + left, dx: px(1) - 0.12cm, dy: 1.1cm + 0.12cm)[#text(size: 8pt, fill: gray)[$1$]]
    #place(top + left, dx: px(0) - 0.12cm, dy: 3.1cm + 0.12cm)[#text(size: 8pt, fill: gray)[$0$]]
    #place(top + left, dx: px(1) - 0.12cm, dy: 3.1cm + 0.12cm)[#text(size: 8pt, fill: gray)[$1$]]
    #place(top + left, dx: px(1) + 0.16cm, dy: 1.0cm)[#text(size: 8pt, fill: gray)[$b$]]
    #place(top + left, dx: px(1) + 0.16cm, dy: 3.0cm)[#text(size: 8pt, fill: gray)[$b$]]
  ],
)

Two facts about $b$ carry the rest of this note. First, $b_t$ is a *sufficient statistic* for the
whole history: given $b_t$, no earlier action or observation changes the best thing to do, which is
why a policy may be written $pi(b)$ alone, and why the belief follows a Markov process of its own.
Second, the integral in #ref(<eq:update>) runs over the whole state space: only in small models is
it a hand computation, and at scale it is approximated -- by a particle filter, by an assumed
family, or, as the second half of this note shows, by freezing the expensive part. The sidecar
`pomdp-demo.html` in this folder lets you drag $b$ and watch the update move it.

= Why a guess is not enough <s3>

The tempting shortcut is to act on the larger of $b$ and $1-b$. Here is what it costs. Opening the
left door yields $+10$ only when the tiger is right, so its expected value is $10 - 110 b$; opening
the right yields $110 b - 100$. The best immediate action is therefore

$ A(b) = max(10 - 110 b, 110 b - 100) = -45 + 110 abs(b - 1/2) . $ <eq:greedy>

At $b = 0.6$ the most likely state is "tiger left," the greedy action is to open the right door, and
it expects $A(0.6) = -34$: acting on the guess loses $34$.

Now value the alternative: pay $1$ to listen, then open the better door. Its value is the listening
cost plus the growl-weighted average of acting on the two updated beliefs,

$ L(b) = -1 + P("growl left") A(b') + P("growl right") A(b'') . $ <eq:listen>

Substituting #ref(<eq:tigeru>) collapses this to

$ L(b) = -46 + 110 ( abs(0.5 b - 0.075) + abs(0.5 b - 0.425) ) , $ <eq:listenclosed>

which is *flat* at $L(b) = -7.5$ for every $b$ between $0.15$ and $0.85$. At $b = 0.6$ one growl
moves the agent from $-34$ to $-7.5$, so the guess is beaten by $26.5$: the growl's information is
worth $27.5$, and observing it costs $1$.

#figure(
  caption: [Two-step value over the belief interval. Navy: act now, $A(b)$, the best door opened
    on the current belief. Teal: listen once then act, $L(b)$, flat at $-7.5$ across the middle.
    Where teal lies above navy -- about $0.159 < b < 0.841$ -- the best two-step policy pays $1$ to
    observe instead of acting on the better guess. At $b = 0.6$: guess $-34$, observe $-7.5$.],
  box(width: 100%, height: 5.5cm)[
    #let px(b) = 2.0cm + 11.4cm * b
    #let py(v) = 0.5cm + (12 - v) * 4.2cm / 62
    #place(top + left)[#line(start: (px(0), py(12.5)), end: (px(0), py(-50)), stroke: 0.7pt + gray)]
    #place(top + left)[#line(start: (px(0), py(0)), end: (px(1.02), py(0)), stroke: 0.7pt + gray)]
    #place(top + left)[#line(start: (px(0), py(10)), end: (px(0.5), py(-45)), stroke: 1.1pt + navy)]
    #place(top + left)[#line(start: (px(0.5), py(-45)), end: (px(1), py(10)), stroke: 1.1pt + navy)]
    #place(top + left)[#line(start: (px(0), py(9)), end: (px(0.15), py(-7.5)), stroke: 1.1pt + teal)]
    #place(top + left)[#line(start: (px(0.15), py(-7.5)), end: (px(0.85), py(-7.5)), stroke: 1.1pt + teal)]
    #place(top + left)[#line(start: (px(0.85), py(-7.5)), end: (px(1), py(9)), stroke: 1.1pt + teal)]
    #for x in (0.15909, 0.84091) {
      place(top + left)[#line(start: (px(x), py(0)), end: (px(x), py(0) - 0.14cm), stroke: 0.7pt + gray)]
      place(top + left, dx: px(x) - 0.42cm, dy: py(0) + 0.06cm)[#text(size: 7.5pt, fill: gray)[#if x < 0.5 { [0.159] } else { [0.841] }]]
    }
    #place(top + left)[#line(start: (px(0.6), py(0)), end: (px(0.6), py(-34)), stroke: (paint: gray, thickness: 0.6pt, dash: "dashed"))]
    #place(top + left, dx: px(0.6) - 1.5pt, dy: py(-34) - 1.5pt)[#circle(radius: 1.5pt, fill: navy)]
    #place(top + left, dx: px(0.6) - 1.5pt, dy: py(-7.5) - 1.5pt)[#circle(radius: 1.5pt, fill: teal)]
    #place(top + left, dx: px(0) - 0.12cm, dy: py(0) + 0.10cm)[#text(size: 8pt, fill: gray)[$0$]]
    #place(top + left, dx: px(0.5) - 0.25cm, dy: py(0) + 0.10cm)[#text(size: 8pt, fill: gray)[$0.5$]]
    #place(top + left, dx: px(0.6) - 0.25cm, dy: py(0) + 0.42cm)[#text(size: 8pt, fill: gray)[$0.6$]]
    #place(top + left, dx: px(1) - 0.12cm, dy: py(0) + 0.10cm)[#text(size: 8pt, fill: gray)[$1$]]
    #place(top + left, dx: px(1) + 0.14cm, dy: py(0) - 0.10cm)[#text(size: 8pt, fill: gray)[$b$]]
    #place(top + left, dx: 0.35cm, dy: py(10) - 0.13cm)[#text(size: 8pt, fill: gray)[$10$]]
    #place(top + left, dx: 0.35cm, dy: py(0) - 0.13cm)[#text(size: 8pt, fill: gray)[$0$]]
    #place(top + left, dx: 0.20cm, dy: py(-7.5) - 0.13cm)[#text(size: 8pt, fill: gray)[$-7.5$]]
    #place(top + left, dx: 0.20cm, dy: py(-45) - 0.13cm)[#text(size: 8pt, fill: gray)[$-45$]]
    #place(top + left, dx: px(0.30), dy: py(-30))[#text(size: 8.5pt, fill: navy)[act now, $A(b)$]]
    #place(top + left, dx: px(0.17), dy: py(-3.0))[#text(size: 8.5pt, fill: teal)[listen then act, $L(b)$]]
    #place(top + left, dx: px(0.62), dy: py(-41))[#text(size: 8.5pt, fill: navy)[guess: $-34$]]
  ],
)

Two things follow. First, the greedy rule is not slightly off; it is off by the whole value of the
observation: over the broad interval $0.159 < b < 0.841$ no policy that reads only the better guess
can act correctly, because reading the guess throws away exactly the information that says whether a
growl is worth its price. Second, the value of a belief is not the value of its most likely state
but the upper envelope of the lines the alternative policies draw over the simplex -- two for the
doors, three for listen-then-act -- so it is *piecewise-linear and convex* in $b$. That is the
general shape of a POMDP value function, a maximum over one linear piece per *policy tree*, and what
the exact algorithms manipulate @kaelbling1998planning.

= The tree the update grows <s4>

Because the belief is a sufficient statistic, a POMDP is an MDP whose state space is the belief
simplex. Its optimal value obeys a Bellman equation, but with a second expectation inside: after
choosing an action the agent must average over the observations it might receive, each leading to a
different belief.

$ V^*(b) = max_(a in A) { integral_X b(x) R(x, a) dif x + gamma integral_Z p(z | b, a) V^*(tau(b, a, z)) dif z } . $ <eq:bellman>

Here $tau(b,a,z)$ is the update #ref(<eq:update>) written as a function of the belief, the action, and
the observation. Unrolling #ref(<eq:bellman>) does not produce a sequence of actions; it produces a
*tree*. Each node is a belief. Its children are reached by an action edge, then an observation edge,
and the tree alternates between the two. A policy is a whole tree: at every belief node, which
action to take.

#figure(
  caption: [The belief tree. Square nodes are the agent's action choices, round nodes are the
    beliefs after an observation. Each level doubles the branches, once over actions and once over
    observations, so a depth-$H$ search has $|A|^H |Z|^H$ leaves -- before the agents multiply
    anything.],
  box(width: 100%, height: 6.2cm)[
    #let rootx = 1.05cm
    #let rooty = 3.05cm
    #let ax = 4.05cm
    #let ay = (1.6cm, 4.6cm)
    #let bx = 7.1cm
    #let by = (0.9cm, 2.4cm, 3.7cm, 5.2cm)
    #place(top + left, dx: rootx - 4pt, dy: rooty - 4pt)[#circle(radius: 4pt, fill: navy)]
    #place(top + left, dx: rootx - 0.5cm, dy: rooty + 0.10cm)[#text(size: 8.5pt, fill: navy)[$b_(t_0)$]]
    #for k in (0, 1) {
      place(top + left)[#line(start: (rootx, rooty), end: (ax, ay.at(k)), stroke: 0.7pt + gray)]
      place(top + left, dx: ax - 0.15cm, dy: ay.at(k) - 0.15cm)[#rect(width: 0.30cm, height: 0.30cm, stroke: 0.8pt + gray, fill: white)]
    }
    #place(top + left, dx: 2.1cm, dy: 2.05cm)[#text(size: 8.5pt, fill: gray)[$a_1$]]
    #place(top + left, dx: 2.1cm, dy: 4.05cm)[#text(size: 8.5pt, fill: gray)[$a_2$]]
    #for k in (0, 1) {
      for m in (0, 1) {
        place(top + left)[#line(start: (ax, ay.at(k)), end: (bx, by.at(2 * k + m)), stroke: 0.7pt + gray)]
        place(top + left, dx: bx - 4pt, dy: by.at(2 * k + m) - 4pt)[#circle(radius: 4pt, fill: navy)]
      }
    }
    #place(top + left, dx: 5.55cm, dy: 1.25cm)[#text(size: 8.5pt, fill: gray)[$z_1$]]
    #place(top + left, dx: 5.60cm, dy: 2.75cm)[#text(size: 8.5pt, fill: gray)[$z_2$]]
    #place(top + left, dx: 5.55cm, dy: 3.85cm)[#text(size: 8.5pt, fill: gray)[$z_1$]]
    #place(top + left, dx: 5.60cm, dy: 5.35cm)[#text(size: 8.5pt, fill: gray)[$z_2$]]
    #for k in (0, 1, 2, 3) {
      place(top + left)[#line(start: (bx + 4pt, by.at(k)), end: (8.4cm, by.at(k)), stroke: 0.6pt + gray)]
    }
    #place(top + left, dx: 8.55cm, dy: 3.05cm)[#text(size: 12pt, fill: gray)[$dots$]]
    #place(top + left, dx: 8.55cm, dy: 3.45cm)[#text(size: 8.5pt, fill: gray)[depth $H$]]
  ],
)

The count is the problem. Forward-simulating $5$ seconds at $0.2$ seconds per step is $25$ decision
points; nine primitive controls per step give $9^25 approx 7 times 10^23$ action sequences before a
single observation is branched. With other agents in the scene, each carrying its own hidden state,
the product only grows. The formalism is right and the search is infeasible, so a usable planner
keeps the formalism and attacks the branching. The rest of this note is how.

= Many agents, one factored transition <s5>

Driving adds the other cars. The full state is $x_t = {x^0_t, x^1_t, dots, x^N_t}$, with $i = 0$ the
ego vehicle and each $x^i_t$ holding position, velocity, acceleration, heading, and steering. For
the surrounding vehicles $x^i_t$ also hides what cannot be observed -- their *intention* and their
*aggressiveness*. Only the ego can be commanded, so the action of the whole problem is just the ego
action, $a_t = a^0_t$.

The joint transition $p(x_t | x_(t-1), a_t)$ is not something anyone can write down directly. The
step that makes it usable is to give every other agent its own action and assume the instantaneous
transitions are independent @ding2021epsilon:

$ p(x_t | x_(t-1), a_t) approx underbrace(p(x^0_t | x^0_(t-1), a^0_t), "ego") product_(i=1)^N integral_(A^i) underbrace(p(x^i_t | x^i_(t-1), a^i_t), "kinematics") underbrace(p(a^i_t | x_(t-1)), "driver model") dif a^i_t . $ <eq:factor>

Read the factors. The ego factor is ordinary motion under the chosen action. Each other agent
factors into a low-level *kinematic* model of how its state evolves under an action, and a
high-level *driver model* $p(a^i_t | x_(t-1))$ that says what action it chooses. The driver model is
the whole interaction physics: it takes the *joint* state as input, so what agent $i$ does depends
on where everyone -- including the ego -- is. The kinematic factors are independent; the driver
models are not.

Assume also that observations are independent across agents, $p(z_t | x_t) = product_(i=0)^N p(z^i_t | x^i_t)$.
Then the belief update #ref(<eq:update>) factors into one term per agent:

$ b_t (x_t) = eta dot p(z^0_t | x^0_t) integral_(X^0) p(x^0_t | x^0_(t-1), a^0_t) b^0_(t-1)(x^0_(t-1)) dif x^0_(t-1) \ times product_(i=1)^N p(z^i_t | x^i_t) integral_(X^i A^i) p(x^i_t | x^i_(t-1), a^i_t) p(a^i_t | x_(t-1)) b^i_(t-1)(x^i_(t-1)) dif a^i_t dif x^i_(t-1) . $ <eq:bfactor>

The product looks like a set of independent updates, but it is not: the driver models $p(a^i_t | x_(t-1))$
read the joint state, so each agent's belief is updated against what everyone else is believed to be
doing. That coupling is the interaction, and it is why this factorization is not the same as
predicting each car alone.

The consequence is the sentence that ties this note to the planner. The hidden states are estimated
from observations during the belief update, and estimating a hidden state from observations *is*
behavior prediction. Prediction is not a module that runs before planning; it is the belief-update
step inside planning, and a pipeline that predicts first and plans afterward has thrown away the
conditioning on the ego's own future actions @ding2021epsilon.

#figure(
  caption: [The factored transition of #ref(<eq:factor>). One joint model becomes the ego
    transition times, for each other agent, a kinematic model times a driver model. The driver
    model reads the whole joint state $x_(t-1)$, so it is where agents feel each other; the
    kinematics alone would leave them independent.],
  box(width: 100%, height: 5.0cm)[
    #place(top + left, dx: 0.5cm, dy: 1.5cm)[
      #rect(width: 4.2cm, height: 1.8cm, stroke: 0.8pt + gray, radius: 3pt, fill: rgb("#f8fafc"))[
        #align(center + horizon)[$p(x^0_t | x^0_(t-1), a^0_t)$ \ #text(size: 8pt, fill: gray)[ego transition]]
      ]
    ]
    #place(top + left, dx: 4.85cm, dy: 2.1cm)[#text(size: 13pt, fill: gray)[$times$]]
    #place(top + left, dx: 5.5cm, dy: 0.7cm)[
      #rect(width: 8.2cm, height: 3.7cm, stroke: 0.8pt + gray, radius: 3pt, fill: rgb("#f8fafc"))[
        #align(center + top)[#text(size: 9pt)[$product_(i=1)^N$, one factor per other agent]]
      ]
    ]
    #place(top + left, dx: 5.8cm, dy: 1.35cm)[
      #rect(width: 7.6cm, height: 1.0cm, stroke: 0.7pt + gray, radius: 3pt, fill: white)[
        #align(center + horizon)[$p(x^i_t | x^i_(t-1), a^i_t)$ \ #text(size: 8pt, fill: gray)[kinematics]]
      ]
    ]
    #place(top + left, dx: 5.8cm, dy: 2.75cm)[
      #rect(width: 7.6cm, height: 1.2cm, stroke: 0.7pt + teal, radius: 3pt, fill: rgb("#f5fbfa"))[
        #align(center + horizon)[$p(a^i_t | x_(t-1))$ \ #text(size: 8pt, fill: teal)[driver model]]
      ]
    ]
    #place(top + left, dx: 9.6cm, dy: 4.55cm)[#text(size: 8.5pt, fill: teal)[reads the whole joint state $x_(t-1)$]]
    #place(top + left)[#line(start: (9.6cm, 4.5cm), end: (9.6cm, 3.95cm), stroke: 0.9pt + teal)]
  ],
)

#check[In #ref(<eq:bfactor>), which factor is the only place where one agent's state can change
  another agent's motion?]
The driver model $p(a^i_t | x_(t-1))$. The kinematic factor $p(x^i_t | x^i_(t-1), a^i_t)$ involves
only agent $i$, so all coupling between agents enters through the action each one chooses, and the
driver model chooses it from the joint state.

= From a policy tree to one decision <s6>

A solved belief tree is still a tree; the motion planner downstream wants one decision. The bridge
is to walk the tree down its most likely path. At each belief node the planner takes the action with
the largest action value, then the observation that action is most likely to produce, and repeats:

$ a^*_t = op("argmax")_(a in A) Q^*(b_(t-1), a) , quad z^*_t = op("argmax")_(z in Z) p(z | b_(t-1), a^*_t) . $ <eq:trace>

Following those two rules from the root yields a trace of beliefs, actions, and observations,
$cal(S)_t = [b^*_t, a^*_(t+1), z^*_(t+1), b^*_(t+1), dots]$. Each belief in the trace is then
collapsed to its most likely state,

$ x_t = op("argmax")_x b^*_t (x) , $ <eq:mode>

and the sequence of collapsed states for every agent becomes the decision
$cal(D)_t = [x_(t+1), dots, x_(t+H)]$ handed to the motion planner @ding2021epsilon.

Two things are worth naming. The output is a *trace*, not a single action, because the motion
planner needs to know not only where the ego should go but what everyone else is expected to do
over the horizon. And following the most likely observation is a choice: it commits to the nominal
branch of the tree rather than keeping the whole contingent policy. For a planner that will re-plan
in $50$ milliseconds, the nominal branch is the part worth passing on.

= Making it real-time: guided observation branching <s7>

After all this machinery the only uncertainty left is the other agents' hidden states -- their
intentions, which the planner cannot observe. Even so, sampling intention combinations is
exponential: with $N$ agents and a few intentions each, a naive POMDP solver branches over
$O(|Z|^d)$ observation sequences. EPSILON's answer is to shrink that branching with domain
knowledge @ding2021epsilon, and it starts by making the belief cheap to represent.

*One number per agent, over geometric candidates.* A driver's *semantic action* $phi^i_t$ is the
center-line it is pursuing, so its hidden state is a categorical belief over the candidate
center-lines near it. A deliberately small network -- a 1-D convolution over sampled center-line
points, an LSTM over the vehicle's recent trajectory, and a softmax head -- outputs that
distribution. Because the classes are geometric candidates rather than fixed labels, a new road
just means new candidates, with no retraining.

*Then branch only where it is dangerous.* This is conditional focused branching. Condition on the
ego policy under evaluation, and forward-simulate once with every other agent assigned its
most-likely (MAP) intention. Most cars never come near the ego's path, and for them the MAP guess
is fine. The few whose simulated future *does* threaten the maneuver are the *critical* agents;
those are re-simulated with their intentions swapped, one alternative at a time. A policy's score
is the belief-weighted average over that handful of scenarios, so the observation space that was
$O(|Z|^d)$ becomes a few evaluations.

#figure(
  caption: [Conditional focused branching. The ego policy is fixed, every agent is simulated once
    at its most likely intention, the agents that threaten the maneuver are identified, and only
    those have their intentions unfolded. The policy score is the belief-weighted average over the
    resulting scenarios.],
  box(width: 100%, height: 4.8cm)[
    #let bx(w, h, fill: rgb("#f8fafc"), stroke: gray, body) = rect(width: w, height: h, stroke: 0.8pt + stroke, radius: 3pt, fill: fill, body)
    #let y0 = 1.5cm
    #place(top + left, dx: 0.4cm, dy: y0)[
      #bx(2.5cm, 1.5cm)[#align(center + horizon)[#text(size: 8.5pt)[ego policy $pi$]]]
    ]
    #place(top + left, dx: 3.4cm, dy: y0)[
      #bx(2.9cm, 1.5cm)[#align(center + horizon)[#text(size: 8.5pt)[MAP simulation \ of all agents]]]
    ]
    #place(top + left, dx: 6.8cm, dy: y0)[
      #bx(3.6cm, 1.5cm, fill: rgb("#f5fbfa"), stroke: teal)[#align(center + horizon)[#text(size: 8.5pt)[unfold critical \ agents' intentions]]]
    ]
    #place(top + left, dx: 10.9cm, dy: y0)[
      #bx(3.1cm, 1.5cm)[#align(center + horizon)[#text(size: 8.5pt)[belief-weighted \ score]]]
    ]
    #place(top + left, dx: 6.8cm, dy: y0 + 1.62cm)[#text(size: 8pt, fill: gray)[low-risk agents keep their MAP intention]]
    #let harrow(x1, x2, y) = {
      place(top + left)[#line(start: (x1, y), end: (x2, y), stroke: 0.9pt + gray)]
      place(top + left)[#polygon((x2, y), (x2 - 0.16cm, y - 0.07cm), (x2 - 0.16cm, y + 0.07cm), fill: gray)]
    }
    #harrow(2.95cm, 3.35cm, y0 + 0.75cm)
    #harrow(6.35cm, 6.75cm, y0 + 0.75cm)
    #harrow(10.45cm, 10.85cm, y0 + 0.75cm)
  ],
)

One assumption inside the simulation is doing a lot of work and should be said plainly. During the
forward simulation, the other agents' hidden states are *not* updated: each keeps the intention it
started with. The reason is the exponential blow-up above -- updating them inside the simulation
costs $O(|Z|^d)$ -- and in practice fixing them anticipates the future well. What is *not* frozen is
the interaction: every agent's action at each step depends on the simulated state of the previous
step, so the rollout is still closed-loop and every car still reacts to what the others just did.
What is given up is a car changing its mind mid-horizon; its average reaction is instead baked into
the driver model. The same paper adds a safety mechanism precisely because that prior model can be
wrong about an over-aggressive driver @ding2021epsilon.

= What is exact, and what was traded away <s8>

It is worth separating the two layers of this note, because they have different statuses.

The belief update #ref(<eq:update>) is exact -- it is Bayes's rule, and #ref(<eq:bfactor>) is what it
becomes under independent kinematics and a joint driver model. Nothing is approximated in writing it
down. What is approximated is the *search*: a depth-$H$ belief tree is replaced by a handful of
closed-loop rollouts, the hidden states are frozen during a rollout, semantic actions are treated as
deterministic given the hidden state, and the ego's observations are assumed noise-free. Each
choice buys real-time behavior and costs something identifiable -- no mid-horizon mind-changing, a
belief that is a categorical guess over candidate lanes rather than a full distribution, and a
nominal trace instead of a contingent policy.

That is the honest summary of how a POMDP reaches a car. The first half of this note is the theory
that makes the belief the right state; the second half is the set of approximations that makes
searching it affordable. The full system around these pieces -- the action-space branching, the
spatio-temporal corridor, and the safety mechanism -- is the subject of
#link("../epsilon-planning/epsilon-planning.html")[#underline[#text(fill: navy)[its own note in this repository]]].

= Sources and further reading <s9>

The POMDP tuple, the belief update #ref(<eq:update>), the factored transition #ref(<eq:factor>), the
factored belief update #ref(<eq:bfactor>), the trace extraction #ref(<eq:trace>) and mode collapse
#ref(<eq:mode>), and the guided observation branching of section 7 are from W. Ding, L. Zhang,
J. Chen, and S. Shen, "EPSILON: An Efficient Planning System for Automated Vehicles in Highly
Interactive Environments," *IEEE Transactions on Robotics* 38(2):1118--1138, 2022
@ding2021epsilon. The tiger problem, its reward and observation models, and the observation that
listening beats acting under uncertainty are from L. P. Kaelbling, M. L. Littman, and A. R.
Cassandra, "Planning and acting in partially observable stochastic domains," *Artificial
Intelligence* 101(1--2):99--134, 1998, section 5.1 @kaelbling1998planning. Every number on this page
is recomputed from the tiger model rather than quoted, and `scripts/tiger_check.py` reproduces them.

Unconsulted suggestions for the reader, not used to support any claim here: the point-based POMDP
solvers (PBVI, POMCP) for the exact and approximate branches of the value function, and the earlier
guided-branching paper by the same group for the origin of conditional focused branching.
