"""Reproduce the note's numbers and check cases that separate common OT mistakes.

Run from the repository root:
    python Mathematics/optimal-transport/scripts/verify_optimal_transport.py
Only the Python standard library is required.
"""
from fractions import Fraction as F
from itertools import permutations
from math import exp, isclose, log, sqrt


def ordered_plan(xs, a, ys, b):
    """Sorted, one-dimensional matching of arbitrary nonnegative equal mass."""
    assert len(xs) == len(a) and len(ys) == len(b)
    assert list(xs) == sorted(xs) and list(ys) == sorted(ys)
    assert all(v >= 0 for v in (*a, *b)) and sum(a) == sum(b)
    left, right = list(a), list(b)
    p = [[F(0) for _ in b] for _ in a]
    i = j = 0
    while i < len(a) and j < len(b):
        amount = min(left[i], right[j])
        p[i][j] += amount
        left[i] -= amount
        right[j] -= amount
        if left[i] == 0:
            i += 1
        if right[j] == 0:
            j += 1
    assert all(v == 0 for v in (*left, *right))
    assert list(map(sum, p)) == list(a)
    assert [sum(row[j] for row in p) for j in range(len(b))] == list(b)
    return p


def travel(p, xs, ys, power=1):
    return sum(p[i][j] * abs(x-y) ** power
               for i, x in enumerate(xs) for j, y in enumerate(ys))


def cumulative_area(xs, a, ys, b):
    """Integrate the exact cumulative gap over the union of support locations."""
    support = sorted(set((*xs, *ys)))
    result = F(0)
    for lo, hi in zip(support, support[1:]):
        source = sum(v for x, v in zip(xs, a) if x <= lo)
        target = sum(v for y, v in zip(ys, b) if y <= lo)
        result += abs(source-target) * (hi-lo)
    return result


def errors(p, a, b):
    return (max(abs(sum(row)-ai) for row, ai in zip(p, a)),
            max(abs(sum(row[j] for row in p)-bj) for j, bj in enumerate(b)))


def sinkhorn(a, b, costs, epsilon, tolerance=1e-12):
    """The exact row/column factor updates printed in the optional extension."""
    k = [[exp(-c/epsilon) for c in row] for row in costs]
    v = [1.0] * len(b)
    for iteration in range(1, 10001):
        u = [ai/sum(k[i][j]*v[j] for j in range(len(b)))
             for i, ai in enumerate(a)]
        v = [bj/sum(u[i]*k[i][j] for i in range(len(a)))
             for j, bj in enumerate(b)]
        p = [[u[i]*k[i][j]*v[j] for j in range(len(b))] for i in range(len(a))]
        if max(errors(p, a, b)) < tolerance:
            return p, iteration
    raise RuntimeError("Both marginals did not converge within 10000 iterations")


def main():
    xs, ys = (0, 3), (1, 4)
    a, b = (F(3, 4), F(1, 4)), (F(1, 2), F(1, 2))
    p = ordered_plan(xs, a, ys, b)
    assert p == [[F(1, 2), F(1, 4)], [F(0), F(1, 4)]]
    assert travel(p, xs, ys) == cumulative_area(xs, a, ys, b) == F(7, 4)
    assert travel(p, xs, ys, 2) == F(19, 4)

    # Exhaustively compare all equal-spoonful assignments, independently of the solver.
    source_units, target_units = (0, 0, 0, 3), (1, 1, 4, 4)
    for power, expected in ((1, 7), (2, 19)):
        assert min(sum(abs(x-y)**power for x, y in zip(source_units, target))
                   for target in permutations(target_units)) == expected
    for t in (F(1), F(3, 2), F(7, 4), F(2)):
        unnormalized = [[t, 3-t], [2-t, t-1]]
        assert list(map(sum, unnormalized)) == [3, 1]
        assert travel(unnormalized, xs, ys) == 15-4*t
        assert travel(unnormalized, xs, ys, 2) == 55-18*t

    # Same means hide nonzero travel; net displacement is not a general optimum.
    for xs2, a2, ys2, b2, expected in (
        ((-1, 1), (F(1, 2), F(1, 2)), (0,), (F(1),), F(1)),
        ((0, 4), (F(1, 2), F(1, 2)), (1, 3), (F(1, 2), F(1, 2)), F(1)),
        ((-2, 0, 5), (F(1, 5), F(3, 10), F(1, 2)), (-1, 2), (F(3, 5), F(2, 5)), F(23, 10)),
        ((0, 0, 3), (F(0), F(3), F(1)), (1, 4), (F(2), F(2)), F(7)),
        ((0, 3), a, (0, 3), a, F(0)),
    ):
        p2 = ordered_plan(xs2, a2, ys2, b2)
        assert travel(p2, xs2, ys2) == cumulative_area(xs2, a2, ys2, b2) == expected

    # Exact scaling stages: conservation of total mass alone is insufficient.
    k = [[F(1, 2), F(1, 16)], [F(1, 4), F(1, 2)]]
    row = [[v*scale for v in r] for r, scale in zip(k, (F(4, 3), F(1, 3))) ]
    assert row == [[F(2, 3), F(1, 12)], [F(1, 12), F(1, 6)]]
    col = [[r[0]*F(2, 3), r[1]*2] for r in row]
    assert col == [[F(4, 9), F(1, 6)], [F(1, 18), F(1, 3)]]
    assert errors(row, a, b) == (0, F(1, 4))
    assert errors(col, a, b) == (F(5, 36), 0)

    costs = [[1, 4], [2, 1]]
    epsilon = 1/log(2)
    regularized, iterations = sinkhorn(a, b, costs, epsilon)
    # Independently minimize the scalar regularized problem via its stationary equation.
    # Write z=P21: P=[[.5-z,.25+z],[z,.25-z]]. The stationary condition is
    # (.5-z)(.25-z)=16*z*(.25+z), i.e. 15*z*z+4.75*z-.125=0.
    z = (sqrt(481)-19)/120
    reference = [[0.5-z, 0.25+z], [z, 0.25-z]]
    assert max(abs(regularized[i][j]-reference[i][j])
               for i in range(2) for j in range(2)) < 1e-11
    assert isclose(travel(regularized, xs, ys), 1.75+4*z, abs_tol=1e-11)
    assert max(errors(regularized, a, b)) < 1e-12
    # Smaller epsilon reduces excess travel on this unique-optimum example.
    colder, _ = sinkhorn(a, b, costs, 0.5)
    assert 1.75 < travel(colder, xs, ys) < travel(regularized, xs, ys)

    print("Exact cost: 7; W1: 1.75; W2 squared: 4.75; W2:", f"{sqrt(19)/2:.6f}")
    print("CDF area and ordered matching agree on asymmetric, bidirectional, zero-weight, and identical cases.")
    print("First row and column scaling stages verified as exact fractions.")
    print("Sinkhorn epsilon = 1/ln(2), iterations:", iterations)
    print("Regularized plan:", [[round(v, 6) for v in r] for r in regularized])
    print("Regularized travel cost:", f"{travel(regularized, xs, ys):.6f}")
    print("Both marginal errors:", errors(regularized, a, b))


if __name__ == "__main__":
    main()
