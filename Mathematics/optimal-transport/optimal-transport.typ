#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, navy, teal, gray

#show: note-ilm.with(
  title: [Optimal Transport],
  authors: "Amp",
  abstract: [How can we rearrange a given amount of material into a desired shape
  at the least cost? Four spoonfuls of sand lead to transport plans, conservation
  constraints, and distances between probability distributions. A visual construction
  on a ruler explains why cumulative distributions solve one-dimensional transport.
  An optional computational extension introduces entropy and Sinkhorn scaling.
  The starting prerequisites are arithmetic and coordinates on a line.],
  bibliography: bibliography("refs.bib"),
)
#set par(justify: false)

#let chip(x, y, color) = place(top + left, dx: x - 0.12cm, dy: y - 0.12cm)[
  #rect(width: 0.24cm, height: 0.24cm, fill: color, stroke: none)
]
#let route(x1, y1, x2, y2, color) = {
  let dx = x2 - x1
  let dy = y2 - y1
  let len = calc.sqrt((dx / 1cm) * (dx / 1cm) + (dy / 1cm) * (dy / 1cm))
  let ux = dx / len
  let uy = dy / len
  let tip-x = x2 - 0.2 * ux
  let tip-y = y2 - 0.2 * uy
  place(top + left)[#line(start: (x1, y1), end: (tip-x, tip-y), stroke: 1pt + color)]
  place(top + left)[#polygon(
    fill: color, stroke: none,
    (tip-x, tip-y),
    (tip-x - 0.14 * ux + 0.07 * uy, tip-y - 0.14 * uy - 0.07 * ux),
    (tip-x - 0.14 * ux - 0.07 * uy, tip-y - 0.14 * uy + 0.07 * ux),
  )]
}

= Moving a shape, one piece at a time <s1>

Imagine four equal spoonfuls of sand on a ruler: *three at position 0, one at
position 3*. You want *two at position 1, two at position 4*. You may divide
the sand; nothing may be created or lost. For now, moving one unit one ruler
step costs one unit of effort. How can we reshape the piles with the least effort?

The important constraint is the *whole target shape*. Sending every piece to
its closest destination would send all three units at 0 to position 1, which
only needs two. We must coordinate the trips. The sand picture is also useful
when the objects are probabilities or data rather than physical cargo
@peyre2018computational.

#figure(
  caption: [Follow the four squares from top to bottom. Each square is one unit of sand.
  Arrows show the chosen routes; the middle row illustrates halfway along those routes.
  The target has the same four units, rearranged.],
  box(width: 100%, height: 6.4cm)[
    #let px(x) = 3.2cm + x * 2.6cm
    #let ys = (0.75cm, 2.85cm, 4.95cm)
    #let xs = ((0, 0, 0, 3), (0.5, 0.5, 2, 3.5), (1, 1, 4, 4))
    #let offsets = ((-0.32cm, 0cm, 0.32cm, 0cm), (-0.16cm, 0.16cm, 0cm, 0cm), (-0.16cm, 0.16cm, -0.16cm, 0.16cm))
    #let colors = (navy, navy, teal, navy)
    #for k in range(2) {
      for i in range(4) {
        route(px(xs.at(k).at(i)), ys.at(k) + offsets.at(k).at(i),
          px(xs.at(k + 1).at(i)), ys.at(k + 1) + offsets.at(k + 1).at(i), colors.at(i))
      }
    }
    #for k in range(3) {
      place(top + left, dy: ys.at(k) - 0.3cm)[
        #text(size: 10pt, fill: gray, ("Start", "Along the routes", "Target").at(k))
      ]
      for i in range(4) {
        chip(px(xs.at(k).at(i)), ys.at(k) + offsets.at(k).at(i), colors.at(i))
      }
    }
    #place(top + left)[#line(start: (px(0), 5.85cm), end: (px(4), 5.85cm), stroke: 0.6pt + gray)]
    #for x in range(5) {
      place(top + left)[#line(start: (px(x), 5.8cm), end: (px(x), 5.9cm), stroke: 0.6pt + gray)]
      place(top + left, dx: px(x) - 0.07cm, dy: 6cm)[#text(size: 9pt, str(x))]
    }
  ],
)

Read the arrows as instructions: send *two* units from 0 to 1, *one* from 0
to 4, and *one* from 3 to 4. We call this list a *transport plan*. It meets
both demands: 1 receives two, and 4 receives one plus one.

The middle row is just a way to follow the pieces. The basic transport problem
specifies where they start, where they end, and the cost of each route. It does
not specify travel times or velocities.

Cost is amount × distance, added over the routes. This plan costs

$ 2 times 1 + 1 times 4 + 1 times 1 = 7. $

We have found a valid plan. To decide whether it is the cheapest one, we need
a way to describe *all* valid plans without drawing every grain of sand.

= A grid that keeps every piece accounted for <s2>

A matrix is a rectangular grid of numbers. Here it simply stores the route
amounts we already understand:

$ P = mat(2, 1; 0, 1). $

The first row records sand leaving 0; the second records sand leaving 3.
The first column records sand arriving at 1; the second records sand arriving
at 4. Thus the upper-right entry, 1, is the teal square's route *from 0 to 4*.

#figure(
  caption: [Sum horizontally to account for a starting pile; sum vertically to
  account for a destination. The four central cells are amounts sent along routes.],
  table(
    columns: (3.8cm, 3cm, 3cm, 3cm), align: center, inset: 9pt,
    stroke: 0.5pt + gray,
    [Route amounts], [To 1], [To 4], [Sent],
    [From 0], [2], [1], [*3*],
    [From 3], [0], [1], [*1*],
    [Received], [*2*], [*2*], [*4 total*],
  ),
)

Row totals are the starting piles (3 and 1); column totals are the desired piles
(2 and 2). The entries cannot be negative: a negative shipment is not an amount
of sand. *The grid records movements, not distances.*

For a larger problem, label the sources $i = 1, dots, n$ and destinations
$j = 1, dots, m$. These labels count places; they are not their coordinates.
Let $a_i$ be the amount initially at source $i$, $b_j$ the amount wanted at
destination $j$, and $P_(i j)$ the amount sent between them.

The symbol $sum$ means “add all these terms.” Summing across each row and
down each column says precisely what the figure says:

$ P_(i j) >= 0, quad sum_(j=1)^m P_(i j) = a_i, quad
  sum_(i=1)^n P_(i j) = b_j. $ <eq:conservation>

The row equation applies to every source; the column equation to every
destination. Consequently $sum_i a_i = sum_j b_j$ must hold. This is
*balanced transport*: all material is retained. Unequal totals require changing
the model, for example by explicitly pricing creation or disposal.

Now store the *per-unit costs* in a separate grid, $C$. For our ruler,
subtract coordinates and take the positive distance:

$ C = mat(abs(0-1), abs(0-4); abs(3-1), abs(3-4))
    = mat(1, 4; 2, 1). $

Multiply corresponding entries of $P$ and $C$, then add. This is the same
amount × distance calculation as before. A feasible plan is one satisfying
@eq:conservation. In general the optimization becomes

$ L_C (a,b) = min_(P " feasible")
  sum_(i=1)^n sum_(j=1)^m P_(i j) C_(i j). $ <eq:ot>

Here $min$ asks for the smallest possible value. In words: *choose the route
amounts, keep every supply and demand fixed, and minimize the total cost*.
This is the discrete *Kantorovich formulation* @peyre2018computational.

Why allow a source to send to several destinations? Our pile at 0 contains
three units but the target at 1 only needs two. A rule that sends the entire
pile at each source to a single destination cannot realize this target.
Such a single-destination rule is called a *transport map*; the more flexible
plan allows splitting. Treating individual grains as separate sources could
also describe this example, but that uses a finer representation of the input.

= From a cheaper plan to a proven optimum <s3>

To see what optimization changes, start with a different valid plan:
send one unit from 0 to 1, two from 0 to 4, and one from 3 to 1.
Its cost is $1 + 2 times 4 + 2 = 11$. Keep one 0-to-1 trip and one 0-to-4
trip fixed. We will change only the *other two* units.

#let pair-panel(improved) = box(width: 7.2cm, height: 4.4cm)[
  #let px(x) = 0.35cm + x * 1.6cm
  #place(top + left)[#text(weight: "bold", size: 10pt,
    if improved { "After: exchange their destinations" } else { "Before: two expensive routes" })]
  #for (x, label) in ((0, "0"), (3, "3")) {
    chip(px(x), 0.85cm, navy)
    place(top + left, dx: px(x) - 0.07cm, dy: 0.4cm)[#text(size: 9pt, label)]
  }
  #for (x, label) in ((1, "1"), (4, "4")) {
    chip(px(x), 3.05cm, teal)
    place(top + left, dx: px(x) - 0.07cm, dy: 3.25cm)[#text(size: 9pt, label)]
  }
  #if improved {
    route(px(0), 0.98cm, px(1), 2.9cm, navy)
    route(px(3), 0.98cm, px(4), 2.9cm, navy)
    place(top + left, dx: 0.1cm, dy: 3.8cm)[#text(size: 10pt)[Distance: 1 + 1 = *2*]]
  } else {
    route(px(0), 0.98cm, px(4), 2.9cm, gray)
    route(px(3), 0.98cm, px(1), 2.9cm, gray)
    place(top + left, dx: 0.1cm, dy: 3.8cm)[#text(size: 10pt)[Distance: 4 + 2 = *6*]]
  }
]

#figure(
  caption: [Each panel follows the same two units. Each source still sends one and each
  destination still receives one. Exchanging their destinations saves four ruler steps.
  Arrow direction means travel from the upper position to the lower position.],
  grid(columns: (1fr, 1fr), gutter: 0.5cm, pair-panel(false), pair-panel(true)),
)

This swap preserves every pile total. Its only effect is to replace two
costly trips with two short trips. The full plan's cost falls from 11 to 7:

$ mat(1, 2; 1, 0) -> mat(2, 1; 0, 1). $

Now we have a reason for the improvement, but we still need a reason no other
plan beats 7. Add the positions of all four units. Initially the sum is
$3 times 0 + 1 times 3 = 3$; finally it is $2 times 1 + 2 times 4 = 10$.
So the sand must make *seven net steps to the right*.

Any leftward movement would add travel that must be compensated by extra
rightward movement. Total distance therefore cannot be less than seven.
Our plan moves every unit rightward and uses exactly seven steps. It attains
that unavoidable lower bound, so *7 is the optimal cost*. This argument also
allows splitting sand into arbitrarily small pieces: each piece contributes
its amount multiplied by its displacement.

There is also a way to solve this example by bookkeeping alone. Call the
upper-left entry $t$. The first row must sum to 3, so the upper-right entry
is $3-t$. The first column must sum to 2, so the lower-left entry is $2-t$.
Finally the second row must sum to 1, giving the last entry $t-1$:

$ P(t) = mat(t, 3-t; 2-t, t-1), quad 1 <= t <= 2. $

The bounds come from keeping all four entries nonnegative. Fractional values
of $t$ are allowed. Substitute these route amounts into the cost:

$ t + 4(3-t) + 2(2-t) + (t-1) = 15 - 4t. $

Increasing $t$ by one lowers cost by four: exactly the exchange in the
picture. Taking the largest allowed value, $t=2$, gives the minimum cost 7.

= From sand to a distance between distributions <s4>

For probability distributions, divide every amount here by four: the total
mass becomes one. A *distribution* records where that one unit is located.
It can describe probabilities: 3/4 at position 0 means a randomly selected
piece starts there with probability 3/4. The data are now

$ a = (3/4, 1/4), quad b = (1/2, 1/2), quad
  P^star = mat(1/2, 1/4; 0, 1/4). $

The coordinates remain $x=(0,3)$ and $y=(1,4)$. Weights alone do not say
where the mass is. Two distributions with the same weights at different
locations can be far apart.

You may see the compact notation

$ mu = 3/4 delta_0 + 1/4 delta_3, quad
  nu = 1/2 delta_1 + 1/2 delta_4. $

Read $delta_x$ as “one unit concentrated at position $x$.” The letters
$mu$ and $nu$ name the whole distributions, combining locations and weights.
There is no need to treat a point mass as an ordinary smooth function.

After normalization, each plan entry is a fraction of the whole population.
It is the probability of the paired event “starts at $x_i$ and finishes at
$y_j$.” A plan with these prescribed starting and ending probabilities is
also called a *coupling*. Its average travel distance is

$ sum_(i,j) P_(i j) abs(x_i-y_j). $

Minimizing that average gives the *1-Wasserstein distance*, written $W_1$:

$ W_1 (mu,nu) = 1/2 times 1 + 1/4 times 4 + 1/4 times 1 = 7/4 = 1.75. $

This is how a distance *between points* becomes a distance *between whole
distributions* @peyre2018computational. The material need not actually move;
the cheapest hypothetical rearrangement measures how different the distributions are.

#let shift-panel(destination) = box(width: 7.1cm, height: 3cm)[
  #let px(x) = 0.45cm + x * 1.5cm
  #place(top + left)[#text(size: 10pt)[One unit: 0 to #destination]]
  #chip(px(0), 1cm, navy)
  #chip(px(destination), 1cm, teal)
  #route(px(0), 1cm, px(destination), 1cm, gray)
  #place(top + left)[#line(start: (px(0), 1.6cm), end: (px(4), 1.6cm), stroke: 0.6pt + gray)]
  #for x in range(5) {
    place(top + left, dx: px(x) - 0.06cm, dy: 1.7cm)[#text(size: 9pt, str(x))]
  }
  #place(top + left, dy: 2.35cm)[#text(size: 10pt)[$W_1 = #destination$]]
]
#figure(
  caption: [The same amount is moved in both cases. A location-aware comparison
  sees that the right-hand move is four times as far.],
  grid(columns: (1fr, 1fr), gutter: 0.5cm, shift-panel(1), shift-panel(4)),
)

If we compared the two histograms bin by bin on positions 0,1,2,3,4, either
move above would remove one from bin 0 and add one to a new bin. The sum of
absolute bin differences would be 2 in either case. That comparison counts
changed mass but has no notion of the distance between bins. Transport
retains that geometric information through $C$.

Even the mean position is insufficient. Half the mass at $-1$ and half at
$1$ has mean 0; a single unit at 0 also has mean 0. Yet transforming the
first into the second costs $1/2 times 1 + 1/2 times 1=1$. Shape matters
beyond the mean.

== Why squared distance needs a square root

Suppose one trip is twice as far. Ordinary distance makes it twice as
expensive; squared distance makes it four times as expensive. The cost
choice expresses what the comparison should penalize.

For any $p >= 1$, use a genuine distance $d(x,y)$ between points, raise it
to the power $p$, minimize, then take the $p$th root:

$ W_p (mu,nu) = (min_(P " feasible") sum_(i,j) P_(i j) d(x_i,y_j)^p)^(1/p). $

For $p=2$, the root converts a mean squared travel distance into a root
mean squared travel distance. For our four-unit example the squared cost
of $P(t)$ is $55-18t$, so the same endpoint $t=2$ minimizes it. After
normalization,

$ W_2 (mu,nu)^2 = (2 times 1^2 + 1 times 4^2 + 1 times 1^2)/4 = 19/4,
  quad W_2 (mu,nu) = sqrt(19)/2 approx 2.179. $

Do not call 19/4 the $W_2$ distance: it is its *square*. The root matters for
the rules of distance. For point masses at 0,1,2, squared travel costs would
give 4 for 0-to-2 but only 1+1 via 1, violating the rule that a direct distance
cannot exceed the sum of two intermediate distances. The rooted values give
2 and 1+1 instead.

We take the general metric theorem as given: with a ground metric and finite
$p$th moments, $W_p$ is symmetric, is zero exactly for identical distributions,
and satisfies the triangle inequality @peyre2018computational. A finite
$p$th moment means the average $p$th power of distance to a fixed point is
finite. For finitely many points this is automatic. An arbitrary cost matrix
does not automatically define a Wasserstein distance. Also, different plans
can attain the same minimum; a unique distance value does not imply a unique plan.

= Solving transport on a ruler <s5>

The line has an extra gift: we can order all the positions. Draw a vertical
gate at coordinate $r$. Count how much mass is on its left before and after
transport. If the starting side has too much, the excess must cross rightward;
if it has too little, that deficit must cross leftward.

Call the mass at or to the left of $r$ in $mu$ the *cumulative distribution*
$F_mu (r)$. “Cumulative” just means we keep adding mass as the gate moves
right. Define $F_nu (r)$ the same way for the target. These are running totals,
not the heights of the original piles.

At a gate between 1 and 3, the starting mass on the left is 3/4; the target
mass is 1/2. Thus 1/4 must cross to the right. In the optimal plan it is
precisely the teal 0-to-4 route. No mass crosses back to the left.

#figure(
  caption: [The dashed gate at 2 cuts the long teal route. Source mass on its
  left is 3/4, target mass is 1/2: exactly 1/4 must leave this side. Line labels
  give route amounts, not distances.],
  box(width: 100%, height: 4.8cm)[
    #let px(x) = 2cm + x * 2.7cm
    #place(top + left, dy: 0.2cm)[#text(size: 10pt)[Start]]
    #place(top + left, dy: 3.5cm)[#text(size: 10pt)[Target]]
    #place(top + left)[#line(start: (px(2), 0.2cm), end: (px(2), 4.2cm), stroke: (paint: gray, thickness: 0.8pt, dash: "dashed"))]
    #place(top + left, dx: px(2) + 0.1cm)[#text(size: 9pt)[gate at 2]]
    #chip(px(0), 0.8cm, navy)
    #chip(px(3), 0.8cm, navy)
    #chip(px(1), 3.6cm, teal)
    #chip(px(4), 3.6cm, teal)
    #route(px(0), 0.8cm, px(1), 3.6cm, navy)
    #route(px(0), 0.8cm, px(4), 3.6cm, teal)
    #route(px(3), 0.8cm, px(4), 3.6cm, navy)
    #place(top + left, dx: px(0) - 0.3cm, dy: 0.2cm)[#text(size: 10pt)[0: 3/4]]
    #place(top + left, dx: px(3) - 0.3cm, dy: 0.2cm)[#text(size: 10pt)[3: 1/4]]
    #place(top + left, dx: px(1) - 0.3cm, dy: 3.9cm)[#text(size: 10pt)[1: 1/2]]
    #place(top + left, dx: px(4) - 0.3cm, dy: 3.9cm)[#text(size: 10pt)[4: 1/2]]
    #place(top + left, dx: 2.2cm, dy: 2cm)[#text(size: 10pt, fill: navy)[1/2]]
    #place(top + left, dx: 7.8cm, dy: 2.5cm)[#text(size: 10pt, fill: teal)[1/4]]
    #place(top + left, dx: 12cm, dy: 2cm)[#text(size: 10pt, fill: navy)[1/4]]
  ],
)

At any gate, rightward crossing amount minus leftward crossing amount is
$F_mu (r)-F_nu (r)$, fixed by the distributions. The *total* crossing amount
is at least $abs(F_mu (r)-F_nu (r))$. Sending material both ways wastes travel
without helping the required net transfer.

== Count each trip by the gates it crosses

A trip from 0 to 4 crosses every gate in an interval of width 4. Its
contribution to total distance is its amount multiplied by that width.
Instead of adding trip by trip, we can therefore add *gate by gate*: crossing
amount × a small width, over the whole ruler. This counts exactly the same
travel, simply in a different order.

The cumulative totals for our example have three nonzero gaps:

#figure(
  caption: [Navy is the starting cumulative total; teal is the target cumulative
  total. The shaded gap height is the necessary crossing amount. Multiply each
  height by its interval width to obtain area, hence transport cost.],
  box(width: 100%, height: 5.8cm)[
    #let px(x) = 1.6cm + x * 2.8cm
    #let py(v) = 4.5cm - v * 3.2cm
    #place(top + left, dx: 1.6cm)[#text(size: 10pt, fill: navy)[Starting running total]]
    #place(top + left, dx: 8cm)[#text(size: 10pt, fill: teal)[Target running total]]
    #for (x, width, bottom, top-v) in ((0, 1, 0, 0.75), (1, 2, 0.5, 0.75), (3, 1, 0.5, 1)) {
      place(top + left, dx: px(x), dy: py(top-v))[
        #rect(width: width * 2.8cm, height: (top-v - bottom) * 3.2cm, fill: rgb("#e3f1f0"), stroke: none)
      ]
    }
    #place(top + left)[#line(start: (px(-0.25), py(0)), end: (px(4.5), py(0)), stroke: 0.7pt + gray)]
    #place(top + left)[#line(start: (px(-0.25), py(0)), end: (px(-0.25), py(1.1)), stroke: 0.7pt + gray)]
    #place(top + left)[#curve(stroke: 1.6pt + navy,
      curve.move((px(-0.25), py(0))), curve.line((px(0), py(0))),
      curve.line((px(0), py(0.75))), curve.line((px(3), py(0.75))),
      curve.line((px(3), py(1))), curve.line((px(4.5), py(1))))]
    #place(top + left)[#curve(stroke: 1.6pt + teal,
      curve.move((px(-0.25), py(0))), curve.line((px(1), py(0))),
      curve.line((px(1), py(0.5))), curve.line((px(4), py(0.5))),
      curve.line((px(4), py(1))), curve.line((px(4.5), py(1))))]
    #for x in range(5) {
      place(top + left, dx: px(x) - 0.08cm, dy: py(0) + 0.12cm)[#text(size: 9pt, str(x))]
    }
    #for v in (0, 0.5, 0.75, 1) {
      place(top + left, dx: 0cm, dy: py(v) - 0.15cm)[#text(size: 9pt, str(v))]
    }
    #place(top + left, dx: px(0.18), dy: py(0.4))[$3/4$]
    #place(top + left, dx: px(1.6), dy: py(0.68))[$1/4$]
    #place(top + left, dx: px(3.18), dy: py(0.8))[$1/2$]
    #place(top + left, dx: 1.6cm, dy: 5.2cm)[#text(size: 10pt)[Areas: (3/4) × 1 + (1/4) × 2 + (1/2) × 1 = 7/4]]
  ],
)

This area gives a lower bound for any plan. To attain it, we need a plan
that never sends mass in opposite directions across the same gate.

== Build such a plan by consuming piles in order

Start with the leftmost source and leftmost unfilled target. Send the smaller
of the remaining source amount and target demand. If the source empties,
advance to the next source; if the target fills, advance to the next target.
If both happen, advance both. Continue until all mass is assigned.

For the normalized example, send 1/2 from 0 to 1. Target 1 fills; source 0
still has 1/4. Send that remainder from 0 to 4, then send 1/4 from 3 to 4.
This is our original plan reconstructed by an algorithm.

#figure(
  caption: [A common strip counts mass from 0 to 1. Source 0 occupies the first
  3/4; target 1 occupies only the first 1/2. The overlap widths are the route
  amounts: 1/2, 1/4, 1/4. The middle slice must split away from the pile at 0.],
  box(width: 100%, height: 4.1cm)[
    #let px(r) = 3cm + r * 11cm
    #for (y, split, first-label, second-label) in ((0.8cm, 0.75, "source 0", "source 3"), (2.2cm, 0.5, "target 1", "target 4")) {
      place(top + left, dx: px(0), dy: y)[#rect(width: split * 11cm, height: 0.55cm, fill: navy, stroke: none)]
      place(top + left, dx: px(split), dy: y)[#rect(width: (1-split) * 11cm, height: 0.55cm, fill: teal, stroke: none)]
      place(top + left, dx: px(0) + 0.2cm, dy: y + 0.07cm)[#text(size: 10pt, fill: white, first-label)]
      place(top + left, dx: px(split) + 0.2cm, dy: y + 0.07cm)[#text(size: 10pt, fill: white, second-label)]
    }
    #for r in (0, 0.5, 0.75, 1) {
      place(top + left)[#line(start: (px(r), 1.4cm), end: (px(r), 2.1cm), stroke: (paint: gray, thickness: 0.8pt, dash: "dashed"))]
      place(top + left, dx: px(r) - 0.15cm, dy: 3.1cm)[#text(size: 10pt, str(r))]
    }
    #place(top + left, dy: 0.87cm)[#text(size: 10pt)[Start]]
    #place(top + left, dy: 2.27cm)[#text(size: 10pt)[Target]]
    #place(top + left, dx: 3cm, dy: 3.65cm)[#text(size: 10pt)[Horizontal coordinate here counts mass, not position on the ruler.]]
  ],
)

Why does this construction attain the bound? It pairs earlier source mass
with earlier target mass. Two opposed crossings at a gate would instead pair
a left source with a right target and a right source with a left target,
reversing that order. Our construction never does that. At every gate the
crossing is entirely in the direction needed by the net deficit. Thus its
crossing amount equals the absolute cumulative gap, and the lower bound is
attained.

#block(breakable: false)[
We have derived, for finite distributions on the real line with ordinary
distance cost,

$ W_1 (mu,nu) = integral_(-oo)^oo abs(F_mu (r)-F_nu (r)) dif r. $ <eq:cdf>
]

The integral means the *total area* of the gap. In our finite example it is
just the sum of three rectangles. The same formula extends to continuous
distributions with finite first moments @peyre2018computational. There one
has smooth or partly smooth running totals, and integration replaces summing
rectangle areas. This particular shortcut is for $W_1$ on a line, not a
formula for squared cost or general multidimensional transport.

The ordered matching method also minimizes $d^p$ on a line for $p >= 1$
@peyre2018computational. We have supplied the gate proof only for $p=1$;
the more general result uses convexity of the powered distance.

= How a computer chooses the routes <s6>

For general finite point sets, use the same three ingredients: starting
amounts, ending amounts, and pairwise costs. Coordinates can be two-dimensional
positions, colors, or feature vectors, provided the cost expresses the
comparison you intend. Changing that cost changes what “similar” means.

The objective in @eq:ot is linear: each route amount is multiplied by a fixed
cost and the contributions are added. The constraints are also linear sums.
This makes it a *linear program*. A transport or linear-programming solver
can find the optimum to its numerical tolerance. The special one-dimensional
construction is often simpler when its assumptions apply. A general solver
must check all row and column totals, not just whether the total mass is right.

The numerical examples in this note are reproduced by
`scripts/verify_optimal_transport.py`, using Python's standard library.

== Optional extension: why add entropy?

This extension explains a common computational alternative. The core
transport problem above is already complete. We will use one stated
structural theorem to explain how this alternative is computed.

For probability mass, entropy measures how spread out the route probabilities
are. Its useful sign convention here is

$ H(P) = -sum_(i,j) P_(i j) (ln P_(i j)-1), $

with $0 ln 0$ interpreted as 0. The function $ln$ is the natural logarithm,
the inverse of the exponential $e^x$. The extra $-1$ changes entropy only by
the fixed total mass; it does not change which plan wins. Splitting a
probability into smaller positive entries increases this entropy.

Keep the same exact constraints, but minimize

$ sum_(i,j) P_(i j) C_(i j) - epsilon H(P), quad epsilon > 0. $ <eq:regularized>

The first term rewards short trips; the second rewards spreading the plan.
The parameter $epsilon$ chooses the tradeoff and has the same units as the
per-unit cost. A positive value generally gives some mass to routes absent
from the unregularized optimum. It does *not* relax conservation.

For finite costs and strictly positive source and target weights, the
regularized problem has a unique positive solution of the form

$ P_(i j) = u_i K_(i j) v_j, quad K_(i j) = e^(-C_(i j)/epsilon). $ <eq:scaling>

We take this structure theorem, and the convergence of the scaling method
below under these assumptions, from §4.2 of @peyre2018computational. The
derivation uses constrained optimization; it is not assumed knowledge in
this introduction. Zero-weight sources or destinations can first be removed.

The exponential converts cost into a positive *preference weight*: expensive
routes get small weights. $K$ alone is not a transport plan because its row
and column totals usually differ from the required amounts. The positive
factors $u_i$ and $v_j$ multiply each row and each column to fix those totals.

== Derive the two scaling updates

Hold the column factors $v_j$ fixed. The sum of row $i$ in @eq:scaling is
$u_i sum_j K_(i j)v_j$. To make it equal $a_i$, divide the wanted amount by
the current sum before its row factor:

$ u_i <- a_i / (sum_j K_(i j) v_j). $

Then hold these row factors fixed. Column $j$ has sum
$v_j sum_i u_i K_(i j)$. Set it to $b_j$ by the same reasoning:

$ v_j <- b_j / (sum_i u_i K_(i j)). $

Initialize all $v_j=1$, and alternate. These are *Sinkhorn's updates*.
Fixing rows can disturb columns; fixing columns can disturb rows. Repeating
is necessary until *both* sets of totals are sufficiently close to their targets.

To see the action with simple fractions, choose $epsilon=1/ln 2$ for our
distance matrix. Then $K_(i j)=2^(-C_(i j))$, so

$ K = mat(1/2, 1/16; 1/4, 1/2). $

Its row totals are 9/16 and 3/4, while we need 3/4 and 1/4. Multiply row one
by 4/3 and row two by 1/3. The new grid is

$ P^"row" = mat(2/3, 1/12; 1/12, 1/6). $

Now rows are right, but columns total 3/4 and 1/4. To obtain 1/2 in each,
multiply column one by 2/3 and column two by 2:

$ P^"col" = mat(4/9, 1/6; 1/18, 1/3). $

Columns are right; row totals are now 11/18 and 7/18. Neither of these
intermediate grids is the finished answer.

#figure(
  caption: [Bar width is route amount, on the same scale in every stage. Navy
  goes to destination 1; teal goes to destination 4. Row scaling stretches or
  shrinks a whole bar. Column scaling changes every segment of the same color.
  The printed totals reveal why one pass cannot satisfy both constraints.],
  box(width: 100%, height: 7.6cm)[
    #let stages = (
      ("A. Cost preferences K", ((0.5, 0.0625), (0.25, 0.5)), ("9/16", "3/4"), "Arrivals: 3/4, 9/16"),
      ("B. Fix the starting piles", ((2/3, 1/12), (1/12, 1/6)), ("3/4", "1/4"), "Arrivals: 3/4, 1/4"),
      ("C. Fix the arrivals", ((4/9, 1/6), (1/18, 1/3)), ("11/18", "7/18"), "Arrivals: 1/2, 1/2"),
    )
    #for (k, stage) in stages.enumerate() {
      let y = k * 2.5cm
      place(top + left, dy: y)[#text(size: 10pt, weight: "bold", stage.at(0))]
      for i in range(2) {
        let yy = y + 0.5cm + i * 0.55cm
        let row = stage.at(1).at(i)
        place(top + left, dx: 0.3cm, dy: yy)[#text(size: 10pt)[from #(if i==0 { "0" } else { "3" })]]
        place(top + left, dx: 4.2cm, dy: yy)[#rect(width: row.at(0) * 8cm, height: 0.35cm, fill: navy, stroke: none)]
        place(top + left, dx: 4.2cm + row.at(0) * 8cm, dy: yy)[#rect(width: row.at(1) * 8cm, height: 0.35cm, fill: teal, stroke: none)]
        place(top + left, dx: 11.2cm, dy: yy)[#text(size: 10pt)[row total: #(stage.at(2).at(i))]]
      }
      place(top + left, dx: 4.2cm, dy: y + 1.7cm)[#text(size: 10pt, stage.at(3))]
    }
  ],
)

At convergence, the script computes, for this $epsilon$,

$ P_epsilon approx mat(0.475569, 0.274431; 0.024431, 0.225569). $

Both row and column totals now match the required distributions. Its *travel
cost* is approximately 1.847724, above the exact $W_1=1.75$. The extra
leftward route from 3 to 1 is accepted in exchange for increased entropy.
The full regularized objective also includes the entropy term, so it is
a different number from this travel cost.

== What the approximation guarantees, and what to check

In the finite problem, as $epsilon$ tends to zero the regularized travel
cost tends to the unregularized optimum. If several plans minimize that
cost, regularization selects the one with maximal entropy in the limit
@peyre2018computational. Small $epsilon$ also makes exponentials very small:
naive arithmetic can underflow. Numerical implementations often work with
logarithms of the factors instead; this note's moderate example does not need that.

After every full row/column update, check the largest absolute row error
and the largest absolute column error. A correct column total alone is not
a stopping rule. Moreover, a small marginal error certifies feasibility to
tolerance, not unregularized optimality: $epsilon$ still changes the objective.
The regularized objective and the regularized plan's travel cost are not
automatically Wasserstein distances.

The practical choice is now concrete: use ordered matching for the applicable
line problem, a transport linear program for the original finite objective,
or Sinkhorn for the explicitly regularized problem. In every case the same
route grid connects supply, demand, geometry, and cost.

= Sources and next steps <s7>

Gabriel Peyré and Marco Cuturi's _Computational Optimal Transport_
@peyre2018computational supports the terminology and formulations used here:
Chapter 2 for distributions, plans and maps; §2.4 for Wasserstein's metric
properties; §2.6 for ordered matching and cumulative distributions; and
§§4.1–4.2 for entropy, scaling, convergence, and numerical stability.
The numerical example, gate proof for finite $W_1$, and explanatory figures
are worked out in this note.

The central construction to retain is the route grid. Its entries say *how
much*, its row and column totals say *what must be conserved*, and the cost
grid says *which movements are expensive*. Minimizing those movements gives
a way to compare entire distributions while respecting where their mass lives.

For an application after these foundations, the site's
#link("https://peakyet.github.io/peakyet/Robotics/mpot-sinkhorn-step/mpot-sinkhorn-step.html")[Motion Planning via Optimal Transport]
note uses a Sinkhorn step inside a robot motion-planning method. It assumes
more optimization background than this introduction.
