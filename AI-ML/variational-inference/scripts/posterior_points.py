"""Reproduce the one-coin numbers quoted in variational-inference.typ.

Section 5's twelve-coin numbers, its covariance, and figure 2's contour come from
mean_field_checks.py, not from this file.

Run from the repository root:

    python3 AI-ML/variational-inference/scripts/posterior_points.py

Only the standard library is used. The model is the note's running example: a coin with
bias theta, ten flips with seven heads, so the likelihood kernel is theta^7 (1 - theta)^3.
Densities on (0, 1) are normalized by trapezoidal quadrature on a 2000-point grid; the
grid is fine enough that the printed figures are stable in the last shown digit.
"""

import math

N = 2000
GRID = [i / (N - 1) for i in range(1, N - 1)]  # the open interval (0, 1)
STEP = GRID[1] - GRID[0]
LIK = lambda t: t ** 7 * (1 - t) ** 3  # binom(10, 7) = 120 dropped: a constant


def logit(t: float) -> float:
    return math.log(t / (1 - t))


def normal(x: float, mu: float, sigma: float) -> float:
    return math.exp(-0.5 * ((x - mu) / sigma) ** 2) / (sigma * math.sqrt(2 * math.pi))


def normalize(density):
    values = [density(t) for t in GRID]
    area = sum(values) * STEP
    return [v / area for v in values]


def modes(values):
    return [
        GRID[k]
        for k in range(1, len(values) - 1)
        if values[k] > values[k - 1] and values[k] > values[k + 1]
    ]


def at(values, target):
    k = min(range(len(values)), key=lambda i: abs(GRID[i] - target))
    return values[k], GRID[k]


def mass_below(values, cut):
    return sum(v * STEP for v, t in zip(values, GRID) if t < cut)


def invert(mat):
    """Invert a small square matrix by Gauss-Jordan elimination (standard library only)."""
    n = len(mat)
    a = [row[:] + [1.0 if i == j else 0.0 for j in range(n)] for i, row in enumerate(mat)]
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(a[r][col]))
        a[col], a[pivot] = a[pivot], a[col]
        pv = a[col][col]
        a[col] = [v / pv for v in a[col]]
        for r in range(n):
            if r != col and a[r][col]:
                f = a[r][col]
                a[r] = [v - f * w for v, w in zip(a[r], a[col])]
    return [row[n:] for row in a]


def main() -> None:
    print("== s1: uniform prior, joint p(theta, D) = 120 theta^7 (1 - theta)^3 ==")
    joint = lambda t: 120 * LIK(t)
    peak = max(joint(t) for t in GRID)
    z = sum(joint(t) * STEP for t in GRID)
    print(f"  peak of the joint          = {peak:.4f} at theta = {at([joint(t) for t in GRID], 0.7)[1]:.3f}")
    print(f"  p(D) = integral of joint   = {z:.6f}   (Beta function: 120 * B(8,4) = 1/11 = {1 / 11:.6f})")
    print(f"  peak / p(D) for one coin   = {peak / z:.4f}")
    print(f"  posterior Beta(8,4): mean  = {8 / 12:.4f}, mode = {(8 - 1) / (12 - 2):.4f}, "
          f"sd = {math.sqrt(8 * 4 / (12 ** 2 * 13)):.4f}")
    print("  ratio (peak / p(D)) as a function of d independent coins:")
    for d in (1, 12, 50, 100):
        print(f"    d = {d:>3}: {(peak / z) ** d:.3e}")

    print("\n== s1 figure 1: samples every 0.05, for the drawn curve ==")
    print("  " + ", ".join(f"({t / 20:.2f}, {joint(t / 20):.4f})" for t in range(0, 21)))

    print("\n== s2: logit tilt, prior Normal(0, 1) on phi = logit(theta) ==")
    tilted = normalize(lambda t: LIK(t) * normal(logit(t), 0.0, 1.0) / (t * (1 - t)))
    ms = modes(tilted)
    print(f"  modes of the tilted posterior: {[round(m, 3) for m in ms]} (unimodal: {len(ms) == 1})")
    print(f"  peak sits at theta = {ms[0]:.3f}, pulled from 0.700 toward the prior's 0.500")
    print(f"  mean = {sum(v * t * STEP for v, t in zip(tilted, GRID)):.4f}")

    print("\n== s6: two-bump logit prior, mixture of Normal(0, 0.3^2) and Normal(1.8, 0.3^2) ==")
    prior = lambda t: (
        0.5 * normal(logit(t), 0.0, 0.3) + 0.5 * normal(logit(t), 1.8, 0.3)
    ) / (t * (1 - t))
    bumps = normalize(lambda t: LIK(t) * prior(t))
    ms = modes(bumps)
    print(f"  modes: {[round(m, 3) for m in ms]}")
    for m in ms:
        h, where = at(bumps, m)
        print(f"    peak height {h:.2f} at theta = {where:.3f}")
    low, high = min(ms), max(ms)
    floor = min(v for v, t in zip(bumps, GRID) if low + 0.05 < t < high - 0.05)
    print(f"  valley floor between the bumps: {floor:.3f}")
    print(f"  mass below theta = 0.68: {mass_below(bumps, 0.68):.3f}, above: {1 - mass_below(bumps, 0.68):.3f}")


if __name__ == "__main__":
    main()
