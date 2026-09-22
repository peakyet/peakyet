#!/usr/bin/env python3
"""Verify one explicit Francis double-shift QZ step on a 4x4 matrix pencil.

The pencil (H, T) is upper Hessenberg / upper triangular.  The script applies
one structure-preserving double-shift QZ step, checks that the step is an
orthogonal equivalence, and compares the generalized eigenvalues before and
after.  Pure Python: no third-party dependencies.

Run:  python3 verify_qz_step.py
      python3 verify_qz_step.py --json     # emit the bulge-chase snapshots
"""

import argparse
import cmath
import json
import math


# --------------------------------------------------------------------------
# small dense linear algebra
# --------------------------------------------------------------------------
def matmul(A, B):
    n, m, k = len(A), len(B[0]), len(B)
    return [[sum(A[i][p] * B[p][j] for p in range(k)) for j in range(m)]
            for i in range(n)]


def transpose(A):
    return [list(r) for r in zip(*A)]


def eye(n):
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def copy(A):
    return [r[:] for r in A]


def norm(x):
    return math.sqrt(sum(v * v for v in x))


def solve(A, b):
    """Gaussian elimination with partial pivoting."""
    n = len(A)
    M = [A[i][:] + [b[i]] for i in range(n)]
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(M[r][c]))
        M[c], M[p] = M[p], M[c]
        piv = M[c][c]
        for k in range(c, n + 1):
            M[c][k] /= piv
        for r in range(n):
            if r != c:
                f = M[r][c]
                for k in range(c, n + 1):
                    M[r][k] -= f * M[c][k]
    return [M[i][n] for i in range(n)]


def inv(A):
    n = len(A)
    cols = [solve(A, [1.0 if i == r else 0.0 for i in range(n)]) for r in range(n)]
    return [[cols[r][i] for r in range(n)] for i in range(n)]


# --------------------------------------------------------------------------
# Householder and Givens transformations
# --------------------------------------------------------------------------
def house(x):
    """Return v, beta with (I - beta v v^T) x = alpha e1."""
    m, nx = len(x), norm(x)
    if nx == 0:
        return [0.0] * m, 0.0
    alpha = -math.copysign(nx, x[0]) if x[0] != 0 else -nx
    v = x[:]
    v[0] -= alpha
    vn2 = sum(t * t for t in v)
    if vn2 == 0:
        return v, 0.0
    return v, 2.0 / vn2


def house_left(A, v, beta, i0):
    """A <- (I - beta v v^T) A, with v placed at rows i0..i0+len(v)-1."""
    m = len(v)
    for j in range(len(A[0])):
        s = sum(v[k] * A[i0 + k][j] for k in range(m))
        for k in range(m):
            A[i0 + k][j] -= beta * v[k] * s


def house_right(A, v, beta, j0):
    """A <- A (I - beta v v^T), with v placed at columns j0..j0+len(v)-1."""
    m = len(v)
    for i in range(len(A)):
        s = sum(v[k] * A[i][j0 + k] for k in range(m))
        for k in range(m):
            A[i][j0 + k] -= beta * s * v[k]


def rot_rows(A, c, s, i0, i1):
    """A <- G A with G = [[c, s], [-s, c]] acting on rows i0, i1."""
    for j in range(len(A[0])):
        a, b = A[i0][j], A[i1][j]
        A[i0][j] = c * a + s * b
        A[i1][j] = -s * a + c * b


def rot_cols(A, c, s, j0, j1):
    """A <- A G with G = [[c, s], [-s, c]] acting on columns j0, j1."""
    for i in range(len(A)):
        a, b = A[i][j0], A[i][j1]
        A[i][j0] = c * a - s * b
        A[i][j1] = s * a + c * b


def rot_cols_T(A, c, s, j0, j1):
    """A <- A G^T with G = [[c, s], [-s, c]] acting on columns j0, j1."""
    for i in range(len(A)):
        a, b = A[i][j0], A[i][j1]
        A[i][j0] = c * a + s * b
        A[i][j1] = -s * a + c * b


# --------------------------------------------------------------------------
# the Francis double-shift QZ step
# --------------------------------------------------------------------------
def qz_step(H, T, record=None):
    """One implicit double-shift QZ step on a Hessenberg-triangular pencil.

    Returns H', T', Q, Z, record, shifts with H' = Q^T H Z and T' = Q^T T Z.
    """
    n = len(H)
    H, T = copy(H), copy(T)
    Q, Z = eye(n), eye(n)

    def snap(label):
        if record is not None:
            record.append({"label": label,
                           "H": [r[:] for r in H],
                           "T": [r[:] for r in T]})

    snap("start")

    # 1. Shifts: eigenvalues of the trailing 2x2 pencil.
    a11, a12 = H[n - 2][n - 2], H[n - 2][n - 1]
    a21, a22 = H[n - 1][n - 2], H[n - 1][n - 1]
    t11, t12 = T[n - 2][n - 2], T[n - 2][n - 1]
    t22 = T[n - 1][n - 1]
    m11 = a11 / t11
    m12 = -a11 * t12 / (t11 * t22) + a12 / t22
    m21 = a21 / t11
    m22 = -a21 * t12 / (t11 * t22) + a22 / t22
    shift_c, shift_d = m11 + m22, m11 * m22 - m12 * m21

    # 2. Bulge vector: first column of (M^2 - c M + d I), M = H T^{-1}.
    #    Computed with two triangular solves; T is never inverted.
    e1 = [1.0 if i == 0 else 0.0 for i in range(n)]
    w = solve(T, e1)                                   # T w = e1
    Me1 = [sum(H[i][j] * w[j] for j in range(n)) for i in range(n)]
    y = solve(T, Me1)                                  # T y = M e1
    M2e1 = [sum(H[i][j] * y[j] for j in range(n)) for i in range(n)]
    v = [M2e1[i] - shift_c * Me1[i] + (shift_d if i == 0 else 0.0)
         for i in range(3)]

    # 3. Initial left Householder, then chase the bulge.
    vv, beta = house(v)
    house_left(H, vv, beta, 0)
    house_left(T, vv, beta, 0)
    house_right(Q, vv, beta, 0)
    snap("initial-left")

    for j in range(0, n - 2):
        if j > 0:
            x = [H[j][j - 1], H[j + 1][j - 1], H[j + 2][j - 1]]
            vv, beta = house(x)
            house_left(H, vv, beta, j)
            house_left(T, vv, beta, j)
            house_right(Q, vv, beta, j)
            snap("left-%d" % j)

        # Right Householder: choose G with T[j:j+3, j:j+3] G e1 ∝ e1.
        block = [[T[j + i][j + k] for k in range(3)] for i in range(3)]
        g0 = solve(block, [1.0, 0.0, 0.0])
        ng = norm(g0)
        g0 = [g / ng for g in g0]
        vv, beta = house(g0)
        house_right(H, vv, beta, j)
        house_right(T, vv, beta, j)
        house_right(Z, vv, beta, j)
        snap("right-%d" % j)

    # 4. Last two columns: Givens rotations.
    j = n - 2
    a, b = H[j][j - 1], H[j + 1][j - 1]
    r = math.hypot(a, b)
    c, s = a / r, b / r
    rot_rows(H, c, s, j, j + 1)
    rot_rows(T, c, s, j, j + 1)
    rot_cols_T(Q, c, s, j, j + 1)
    snap("last-left")

    a, b = T[j + 1][j], T[j + 1][j + 1]
    r = math.hypot(a, b)
    c, s = b / r, a / r
    rot_cols(H, c, s, j, j + 1)
    rot_cols(T, c, s, j, j + 1)
    rot_cols(Z, c, s, j, j + 1)
    snap("last-right")

    return H, T, Q, Z, record, (shift_c, shift_d)


# --------------------------------------------------------------------------
# eigenvalue computation (Faddeev-LeVerrier + Durand-Kerner)
# --------------------------------------------------------------------------
def char_poly(A):
    n = len(A)
    B = eye(n)
    cs = []
    for k in range(1, n + 1):
        AB = matmul(A, B)
        c = sum(AB[i][i] for i in range(n)) / k
        cs.append(c)
        B = [[AB[i][j] - (c if i == j else 0.0) for j in range(n)]
             for i in range(n)]
    return cs


def polyval(cs, z):
    v = 1 + 0j
    for c in cs:
        v = v * z - c
    return v


def roots(cs):
    n = len(cs)
    zs = [(0.4 + 0.9j) ** (k + 1) for k in range(n)]
    for _ in range(300):
        new = []
        for i in range(n):
            num, den = polyval(cs, zs[i]), 1 + 0j
            for j in range(n):
                if j != i:
                    den *= zs[i] - zs[j]
            new.append(zs[i] - num / (den if den != 0 else 1e-30))
        zs = new
    return zs


def generalized_eigenvalues(H, T):
    return roots(char_poly(matmul(H, inv(T))))


# --------------------------------------------------------------------------
# running example and report
# --------------------------------------------------------------------------
def running_example():
    T = [[2.0, 0.5, 0.2, 0.1],
         [0.0, 1.5, 0.3, 0.2],
         [0.0, 0.0, 1.0, 0.4],
         [0.0, 0.0, 0.0, 0.5]]
    C = [[4.0, 1.0, 0.0, 0.0],
         [1.0, 3.0, 1.0, 0.0],
         [0.0, 1.0, 2.0, 1.0],
         [0.0, 0.0, -1.0, 2.0]]
    return matmul(T, C), T


def fmt(A):
    return "\n".join("  [" + ", ".join("% .6f" % x for x in r) + "]" for r in A)


def max_abs(pred):
    return max(abs(v) for v in pred)


def structure_error(H, T):
    n = len(H)
    below_hess = max(abs(H[i][j]) for i in range(n) for j in range(n) if i > j + 1)
    below_diag = max(abs(T[i][j]) for i in range(n) for j in range(n) if i > j)
    return below_hess, below_diag


def orth_error(Q):
    n = len(Q)
    G = matmul(transpose(Q), Q)
    return max(abs(G[i][j] - (1.0 if i == j else 0.0))
               for i in range(n) for j in range(n))


def report():
    H0, T0 = running_example()
    rec = []
    H1, T1, Q, Z, rec, shifts = qz_step(H0, T0, rec)

    sub0 = [abs(H0[i + 1][i]) for i in range(3)]
    sub1 = [abs(H1[i + 1][i]) for i in range(3)]
    bh, bt = structure_error(H1, T1)
    Qt = transpose(Q)
    resH = max_abs([matmul(matmul(Qt, H0), Z)[i][j] - H1[i][j]
                    for i in range(4) for j in range(4)])
    resT = max_abs([matmul(matmul(Qt, T0), Z)[i][j] - T1[i][j]
                    for i in range(4) for j in range(4)])
    ev0 = generalized_eigenvalues(H0, T0)
    ev1 = generalized_eigenvalues(H1, T1)

    # Deflation of the trailing 2x2 block over five steps.
    H, T = H0, T0
    trail = []
    for k in range(6):
        trail.append(abs(H[2][1]))
        if k < 5:
            H, T, _, _, _, _ = qz_step(H, T)

    print("Francis double-shift QZ step -- verification")
    print("running example: n=4, H upper Hessenberg, T upper triangular")
    disc = shifts[0] * shifts[0] - 4 * shifts[1]
    mu = complex(shifts[0] / 2, math.sqrt(max(0.0, -disc)) / 2)
    print("shifts from the trailing 2x2 pencil: mu = %.3f +/- %.3fi"
          % (mu.real, mu.imag))
    print()
    print("H0 =\n" + fmt(H0))
    print("T0 =\n" + fmt(T0))
    print()
    print("subdiagonal |H[i+1,i]| before: " + " ".join("%.6f" % x for x in sub0))
    print("subdiagonal |H[i+1,i]| after : " + " ".join("%.6f" % x for x in sub1))
    print()
    print("structure after the step")
    print("  max |H[i,j]|, i>j+1 : %.3e" % bh)
    print("  max |T[i,j]|, i>j   : %.3e" % bt)
    print("orthogonality")
    print("  ||Q^T Q - I|| : %.3e" % orth_error(Q))
    print("  ||Z^T Z - I|| : %.3e" % orth_error(Z))
    print("backward error")
    print("  ||Q^T H0 Z - H1|| : %.3e" % resH)
    print("  ||Q^T T0 Z - T1|| : %.3e" % resT)
    print()
    def fmt_c(z):
        if abs(z.imag) < 1e-9:
            return "%.10g" % z.real
        return "%.10g%+.10gi" % (z.real, z.imag)

    print("generalized eigenvalues of (H,T)")
    print("  before: " + ", ".join(fmt_c(z) for z in sorted(ev0, key=lambda z: (z.real, z.imag))))
    print("  after : " + ", ".join(fmt_c(z) for z in sorted(ev1, key=lambda z: (z.real, z.imag))))
    print()
    print("deflation of the trailing 2x2 block: |H[2,1]| over 5 steps")
    for k, val in enumerate(trail):
        print("  k=%d %.6e" % (k, val))

    return rec, shifts


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", action="store_true",
                    help="emit the bulge-chase snapshots as JSON")
    args = ap.parse_args()
    rec, shifts = report()
    if args.json:
        print("\nJSON")
        print(json.dumps({"snapshots": rec, "shifts": shifts}))
