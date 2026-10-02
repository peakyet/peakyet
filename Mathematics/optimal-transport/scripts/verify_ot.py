#!/usr/bin/env python3
"""Checks behind the numbers printed on optimal-transport-deck.html.

Dependency-free on purpose: any python3 runs it, no numpy.

    python3 scripts/verify_ot.py

Each block prints exactly the figures that appear on a frame, in deck order, so a
reader can re-check a claim without redoing the arithmetic by hand.
"""
import itertools
import math
from fractions import Fraction as Q

# ---------- running example ----------
# two source atoms and two target atoms on one axis
XS, MUS = [Q(0), Q(2)], [Q(1, 2), Q(1, 2)]
YS, NUS = [Q(1), Q(5)], [Q(3, 4), Q(1, 4)]


def block_blind():
    """Frame 4: TV and KL are set by overlap; W1 sees the distance."""
    print("[1] shifting one unit of mass along a line")
    print("   shift k | total variation | KL(p||q) | W1")
    for k in (1, 2, 3):
        tv = 0.5 * (1.0 + 1.0)            # disjoint spikes: TV is saturated
        kl = float("inf")                 # q vanishes where p has its mass
        print(f"        {k} | {tv:15.3f} | {kl:>10} | {k:.3f}")
    print("   overlapping supports instead: N(0,1) vs N(m,1)")
    print("     m   KL = m^2/2   W2 = |m|")
    for m in (0.1, 1.0, 5.0):
        print(f"   {m:5} {m * m / 2:13.4f} {abs(m):10.4f}")
    print()


def block_no_map():
    """Frame 6/7: no deterministic map realizes the target marginals."""
    print("[2] the running example admits no transport map")
    print(f"   source masses {MUS} at x={XS}, target masses {NUS} at y={YS}")
    reach = set()
    for assign in itertools.product(range(len(YS)), repeat=len(XS)):
        lands = [Q(0)] * len(YS)
        for i, j in enumerate(assign):
            lands[j] += MUS[i]
        reach.add(tuple(lands))
    for a in sorted(reach):
        print("   a map could deliver", [str(v) for v in a])
    print("   target", [str(v) for v in NUS], "is in that set?",
          tuple(NUS) in reach, "-> Monge is infeasible here")
    print()


def block_lp():
    """Frame 8/9: the Kantorovich LP for the same data, solved exactly."""
    print("[3] Kantorovich on the same data, cost |x-y|")
    C = [[abs(a - b) for b in YS] for a in XS]
    print("   cost matrix C_ij =", [[str(v) for v in row] for row in C])
    # gamma = [[3/4 - a, a - 1/4], [a, 1/2 - a]] with a = gamma_21 in [1/4, 1/2]
    best = None
    for num in range(0, 2001):
        a = Q(num, 2000)
        g = [[Q(3, 4) - a, a - Q(1, 4)], [a, Q(1, 2) - a]]
        if any(v < 0 for row in g for v in row):
            continue
        cost = sum(g[i][j] * C[i][j] for i in range(2) for j in range(2))
        if best is None or cost < best[0]:
            best = (cost, a, g)
    print("   feasible plans form a segment: a = gamma_21 in [1/4, 1/2]")
    print("   cost(a) = 1 + 2a, so the optimum is at a = 1/4")
    print(f"   optimum cost = {best[0]} = {float(best[0]):.4f} at a = {best[1]}")
    print("   optimal plan  =", [[str(v) for v in row] for row in best[2]])
    nz = sum(1 for row in best[2] for v in row if v != 0)
    print(f"   nonzeros = {nz}, and m+n-1 = {2 + 2 - 1} (a vertex of the LP)")
    # same data, squared distance -> W2
    C2 = [[(a - b) ** 2 for b in YS] for a in XS]
    best2 = None
    for num in range(0, 2001):
        a = Q(num, 2000)
        g = [[Q(3, 4) - a, a - Q(1, 4)], [a, Q(1, 2) - a]]
        if any(v < 0 for row in g for v in row):
            continue
        cost = sum(g[i][j] * C2[i][j] for i in range(2) for j in range(2))
        if best2 is None or cost < best2[0]:
            best2 = (cost, a, g)
    print(f"   with squared cost: W2^2 = {best2[0]} = {float(best2[0]):.6f},"
          f" W2 = {math.sqrt(float(best2[0])):.6f}, same plan (a = {best2[1]})")
    print()


def block_dual():
    """Frame 10: a price list that certifies optimality."""
    print("[4] dual certificate for the |x-y| optimum")
    C = [[abs(a - b) for b in YS] for a in XS]
    phi = [Q(0), Q(0)]
    psi = [Q(1), Q(3)]
    print("   pickup fee  phi =", [str(v) for v in phi])
    print("   delivery fee psi =", [str(v) for v in psi])
    for i in range(2):
        for j in range(2):
            slack = C[i][j] - phi[i] - psi[j]
            print(f"   route x={XS[i]}->y={YS[j]}: c={C[i][j]}, phi+psi={phi[i] + psi[j]},"
                  f" slack={slack} {'(tight)' if slack == 0 else ''}")
    rev = sum(MUS[i] * phi[i] for i in range(2)) + sum(NUS[j] * psi[j] for j in range(2))
    print(f"   revenue = sum mu phi + sum nu psi = {rev} = the optimal cost -> certified")
    print()


def block_uncrossing():
    """Frame 11: the 1-D uncrossing identity, checked exhaustively."""
    print("[5] uncrossing identity on integers in [-6,6]")
    bad = 0
    for x1, x2, y1, y2 in itertools.permutations(range(-6, 7), 4):
        if not (x1 < x2 and y1 < y2):
            continue
        lhs = abs(x1 - y2) + abs(x2 - y1) - abs(x1 - y1) - abs(x2 - y2)
        rhs = 2 * max(0, min(x2, y2) - max(x1, y1))
        if lhs != rhs:
            bad += 1
    print("   |x1-y2|+|x2-y1|-|x1-y1|-|x2-y2| == 2*max(0, min(x2,y2)-max(x1,y1))")
    print("   counterexamples found:", bad)
    print()


def block_quantile():
    """Frame 11: W_p on the line as an L^p distance between quantile functions."""
    print("[6] quantile formula, U[0,2] vs U[1,3]")
    N = 200_001
    w1 = w2 = 0.0
    for k in range(N):
        t = (k + 0.5) / N
        qm, qn = 2 * t, 2 * t + 1          # F^{-1} of the two uniforms
        w1 += abs(qm - qn) / N
        w2 += (qm - qn) ** 2 / N
    print(f"   int|Q_mu-Q_nu| dt = {w1:.6f} (= W1), sqrt(int(...) dt) = {math.sqrt(w2):.6f} (= W2)")
    print()


def block_sinkhorn():
    """Frame 12/13: Sinkhorn scaling, and where the naive form breaks."""
    print("[7] Sinkhorn on the running example, cost matrix [[1,5],[1,3]]")
    mu = [0.5, 0.5]
    nu = [0.75, 0.25]
    C = [[1.0, 5.0], [1.0, 3.0]]

    def naive(eps, tol=1e-11, cap=200_000):
        K = [[math.exp(-C[i][j] / eps) for j in range(2)] for i in range(2)]
        u, v = [1.0, 1.0], [1.0, 1.0]
        for t in range(cap):
            for i in range(2):
                s = sum(K[i][j] * v[j] for j in range(2))
                u[i] = mu[i] / s if s else 0.0
            for j in range(2):
                s = sum(K[i][j] * u[i] for i in range(2))
                v[j] = nu[j] / s if s else 0.0
            plan = [[u[i] * K[i][j] * v[j] for j in range(2)] for i in range(2)]
            err = max(max(abs(sum(plan[i]) - mu[i]) for i in range(2)),
                      max(abs(sum(plan[i][j] for i in range(2)) - nu[j]) for j in range(2)))
            if err < tol or any(p == 0.0 for row in plan for p in row):
                return t + 1, sum(plan[i][j] * C[i][j] for i in range(2) for j in range(2)), err, plan
        return None, None, None, None

    def logdomain(eps, tol=1e-11, cap=200_000):
        f, g = [0.0, 0.0], [0.0, 0.0]

        def lse(vals):
            m = max(vals)
            return m + math.log(sum(math.exp(x - m) for x in vals))

        for t in range(cap):
            for i in range(2):
                f[i] = math.log(mu[i]) - lse([-C[i][j] / eps + g[j] for j in range(2)])
            for j in range(2):
                g[j] = math.log(nu[j]) - lse([-C[i][j] / eps + f[i] for i in range(2)])
            plan = [[math.exp(f[i] + g[j] - C[i][j] / eps) for j in range(2)] for i in range(2)]
            err = max(max(abs(sum(plan[i]) - mu[i]) for i in range(2)),
                      max(abs(sum(plan[i][j] for i in range(2)) - nu[j]) for j in range(2)))
            if err < tol:
                return t + 1, sum(plan[i][j] * C[i][j] for i in range(2) for j in range(2)), err, plan
        return None, None, None, None

    print("     eps | naive: iters, cost, marginal err | log-domain: iters, cost, err")
    for eps in (1.0, 0.3, 0.1, 0.03, 0.01, 0.003, 0.001, 0.0001):
        n1 = naive(eps)
        n2 = logdomain(eps)
        c1 = "underflow" if n1[1] is None or n1[2] > 1e-6 else f"{n1[1]:.6f}"
        print(f"  {eps:>7g} | {str(n1[0]):>5s} {c1:>14s} {n1[2]:.1e}"
              f" | {str(n2[0]):>5s} {n2[1]:.6f} {n2[2]:.1e}")
    _, cost, _, plan = naive(1.0)
    ent = -sum(p * math.log(p) for row in plan for p in row if p > 0)
    print(f"   at eps=1 the plan is {[round(p, 4) for row in plan for p in row]}"
          f" (entropy {ent:.6f}), while eps=0.1 returns the LP vertex [.5, 0, .25, .25]")
    print()


def block_monge_feasible():
    """Frames 8-9: the map exists once the atoms carry equal mass, and the crossed one loses."""
    print("[2b] the same supports with matched masses: now a map exists")
    XM = [Q(0), Q(2)]
    YM = [Q(1), Q(5)]
    nu_m = [Q(1, 2), Q(1, 2)]
    print("   mu = (1/2, 1/2) at x = (0, 2), nu = (1/2, 1/2) at y = (1, 5)")
    for assign in itertools.product(range(2), repeat=2):
        lands = [Q(0), Q(0)]
        for i, j in enumerate(assign):
            lands[j] += MUS[i]
        cost = sum(MUS[i] * abs(XM[i] - YM[assign[i]]) for i in range(2))
        square = sum(MUS[i] * abs(XM[i] - YM[assign[i]]) ** 2 for i in range(2))
        feas = "feasible" if lands == nu_m else "misses nu"
        print(f"   T: x0->y{assign[0]}, x1->y{assign[1]}  delivers {[str(v) for v in lands]}"
              f"  {feas}  cost |x-y|: {cost} = {float(cost):.4f}"
              f"  cost |x-y|^2: {square} = {float(square):.4f}")
    print("   the uncrossed map (x0->y0, x1->y1) wins under both costs")
    print()


def block_lp_scaling():
    """Frame 14: doubling every mass doubles W1, and the plan shape does not move."""
    print("[3b] the running example with every mass doubled")
    mu2 = [2 * m for m in MUS]
    nu2 = [2 * n for n in NUS]
    print("   mu =", [str(v) for v in mu2], " nu =", [str(v) for v in nu2],
          " (total mass 2 on each side)")
    best = None
    for num in range(0, 4001):
        a = Q(num, 4) / 2000 * Q(1, 2) + Q(1, 4)      # sweep a over [1/4, 3/4]
        gam = [[nu2[0] - a, mu2[0] - nu2[0] + a], [a, mu2[1] - a]]
        if min(min(r) for r in gam) < 0:
            continue
        cost = sum(mu2[i] * 0 + gam[i][j] * abs(XS[i] - YS[j])
                   for i in range(2) for j in range(2))
        if best is None or cost < best[0]:
            best = (cost, a, gam)
    print(f"   optimum = {best[0]} = {float(best[0]):.4f} at a = {best[1]}"
          "  (exactly twice W1 = 3/2, same split)")
    print("   plan =", [[str(v) for v in r] for r in best[2]])
    print("   total mass is 2 on each side, not 1: OT is homogeneous in mass, so the")
    print("   optimum scales by 2 and the split inside the plan is unchanged")
    print()


def block_dual_shift():
    """Frame 17: the price list is only pinned down up to an additive constant."""
    print("[4b] shifting the whole price list leaves the certificate intact")
    phi = [Q(0), Q(0)]
    psi = [Q(1), Q(3)]
    C = [[abs(a - b) for b in YS] for a in XS]
    for k in (Q(0), Q(1), Q(-2)):
        ok = all(phi[i] + k + psi[j] - k <= C[i][j] for i in range(2) for j in range(2))
        rev = sum(MUS[i] * (phi[i] + k) for i in range(2)) \
            + sum(NUS[j] * (psi[j] - k) for j in range(2))
        print(f"   add {k} to every pickup fee, subtract it from every delivery fee:"
              f" dual feasible={ok}, revenue = {rev} = {float(rev):.4f}")
    print("   revenue is unchanged because both sides carry total mass 1; only price")
    print("   *differences* are observable, which is why a critic is trained up to a constant")
    print()


def block_sort_match():
    """Frame 21: on the line the optimal matching is the sorted one, at any cost exponent."""
    print("[5b] five-point example, all 120 matchings compared")
    x = [Q(-2), Q(0), Q(1), Q(4), Q(7)]
    y = [Q(-1), Q(1), Q(2), Q(3), Q(9)]
    print("   x =", [str(v) for v in x], " y =", [str(v) for v in y])
    for p in (1, 2):
        best, worst = None, None
        for perm in itertools.permutations(range(5)):
            cost = sum(abs(a - y[b]) ** p for a, b in zip(x, perm))
            best = cost if best is None or cost < best else best
            worst = cost if worst is None or cost > worst else worst
        sorted_cost = sum(abs(a - b) ** p for a, b in zip(x, y))
        print(f"   p={p}: sorted match = {sorted_cost} = {float(sorted_cost):.4f},"
              f" min over all 120 = {best}, worst = {worst},"
              f" sorted is optimal: {sorted_cost == best}")
    crossed = [0, 1, 2, 4, 3]          # swap the last two targets: 4->9 and 7->3
    for p in (1, 2):
        c = sum(abs(a - y[b]) ** p for a, b in zip(x, crossed))
        print(f"   crossing only the last two legs: p={p} cost = {c}"
              f" vs {float(sum(abs(a - b) ** p for a, b in zip(x, y))):.4f} sorted")
    print()


def block_potential():
    """Frame 18: the same certificate read as one 1-Lipschitz function."""
    print("[4c] the Kantorovich-Rubinstein potential for the running example")
    pts = {Q(0): Q(0), Q(1): Q(-1), Q(2): Q(0), Q(5): Q(-3)}

    def f(x):                      # piecewise linear between the nodes, slope +-1 outside
        xs = sorted(pts)
        if x <= xs[0]:
            return pts[xs[0]] - (xs[0] - x)
        if x >= xs[-1]:
            return pts[xs[-1]] - (x - xs[-1])
        for a, b in zip(xs, xs[1:]):
            if a <= x <= b:
                return pts[a] + (pts[b] - pts[a]) * (x - a) / (b - a)
        raise AssertionError

    lam = max(abs(f(x + Q(1, 50)) - f(x)) * 50 for x in [Q(i, 10) for i in range(-60, 90)])
    print("   f(0)=0, f(1)=-1, f(2)=0, f(5)=-3, linear in between")
    print(f"   steepest slope found on a 0.02 grid: {lam:.4f} -> 1-Lipschitz: {lam <= 1}")
    val = sum(MUS[i] * f(XS[i]) for i in range(2)) - sum(NUS[j] * f(YS[j]) for j in range(2))
    print(f"   int f d(mu - nu) = {val} = {float(val):.4f}  (W1 = 3/2, so f is extremal)")
    print("   pairing f = phi on sources and f = -psi on targets recovers block [4]'s prices")
    print()


if __name__ == "__main__":
    for fn in (block_blind, block_no_map, block_monge_feasible, block_lp,
               block_lp_scaling, block_dual, block_dual_shift, block_potential,
               block_uncrossing, block_sort_match, block_quantile, block_sinkhorn):
        fn()
