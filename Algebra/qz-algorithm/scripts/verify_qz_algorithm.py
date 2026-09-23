#!/usr/bin/env python3
"""Verify every number the deck "QZ Algorithm and the Francis QR Step" shows.

Act 1 (Francis QR step) runs on the circulant C = circ(1,2,3,4), whose
eigenvalues are known in closed form: 10, -2, -2 +- 2i.

Act 2 (QZ) runs on the pencil (C, B) with B = 3I + C/2.  C and B commute and
share the DFT eigenvectors, so the generalized eigenvalues are the pairwise
ratios lambda / (3 + lambda/2), i.e. 5/4, -1, (-2 +- 6i)/5.

Pure Python: no third-party dependencies.

Run:  python3 verify_qz_algorithm.py
      python3 verify_qz_algorithm.py --json     # bulge-chase demo snapshots
"""

import argparse
import cmath
import json
import math
import random

FLOPS = [0]  # multiply-add units; see flop_note() at the bottom


# --------------------------------------------------------------------------
# small dense linear algebra
# --------------------------------------------------------------------------
def matmul(A, B):
    n, m, k = len(A), len(B[0]), len(B)
    FLOPS[0] += 2 * n * m * k
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


def fro(A):
    return math.sqrt(sum(v * v for r in A for v in r))


def max_abs(A):
    return max(abs(v) for r in A for v in r)


def mat_sub(A, B):
    return [[A[i][j] - B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def matvec(A, x):
    FLOPS[0] += 2 * len(A) * len(x)
    return [sum(A[i][j] * x[j] for j in range(len(x))) for i in range(len(A))]


def solve_tri(A, b):
    """Back substitution for upper-triangular A."""
    n = len(A)
    x = [0.0] * n
    for i in range(n - 1, -1, -1):
        s = b[i] - sum(A[i][j] * x[j] for j in range(i + 1, n))
        x[i] = s / A[i][i]
    return x


def solve(A, b):
    """Gaussian elimination with partial pivoting (small demos only)."""
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
    """v, beta with (I - beta v v^T) x = alpha e1."""
    m, nx = len(x), norm(x)
    if nx == 0:
        return [0.0] * m, 0.0
    alpha = -math.copysign(nx, x[0]) if x[0] != 0 else -nx
    v = x[:]
    v[0] -= alpha
    vn2 = sum(t * t for t in v)
    FLOPS[0] += 3 * m
    if vn2 == 0:
        return v, 0.0
    return v, 2.0 / vn2


def house_left(A, v, beta, i0):
    """A <- (I - beta v v^T) A, v living in rows i0..i0+len(v)-1."""
    m = len(v)
    FLOPS[0] += 2 * m * len(A[0]) + 2 * m * len(A[0])
    for j in range(len(A[0])):
        s = sum(v[k] * A[i0 + k][j] for k in range(m))
        for k in range(m):
            A[i0 + k][j] -= beta * v[k] * s


def house_right(A, v, beta, j0):
    """A <- A (I - beta v v^T), v living in columns j0..j0+len(v)-1."""
    m = len(v)
    FLOPS[0] += 2 * m * len(A) + 2 * m * len(A)
    for i in range(len(A)):
        s = sum(v[k] * A[i][j0 + k] for k in range(m))
        for k in range(m):
            A[i][j0 + k] -= beta * s * v[k]


def rot_rows(A, c, s, i0, i1):
    """A <- G A with G = [[c, s], [-s, c]] on rows i0, i1."""
    FLOPS[0] += 6 * len(A[0])
    for j in range(len(A[0])):
        a, b = A[i0][j], A[i1][j]
        A[i0][j] = c * a + s * b
        A[i1][j] = -s * a + c * b


def rot_cols(A, c, s, j0, j1):
    """A <- A G with G = [[c, s], [-s, c]] on columns j0, j1."""
    FLOPS[0] += 6 * len(A)
    for i in range(len(A)):
        a, b = A[i][j0], A[i][j1]
        A[i][j0] = c * a - s * b
        A[i][j1] = s * a + c * b


def rot_cols_T(A, c, s, j0, j1):
    """A <- A G^T with G = [[c, s], [-s, c]] on columns j0, j1."""
    FLOPS[0] += 6 * len(A)
    for i in range(len(A)):
        a, b = A[i][j0], A[i][j1]
        A[i][j0] = c * a + s * b
        A[i][j1] = -s * a + c * b


def below_band(H):
    """1-based positions strictly below the Hessenberg band."""
    n = len(H)
    return [(i + 1, j + 1) for i in range(n) for j in range(n)
            if i > j + 1 and abs(H[i][j]) > 1e-12]


def orth_error(Q):
    n = len(Q)
    G = matmul(transpose(Q), Q)
    return max(abs(G[i][j] - (1.0 if i == j else 0.0))
               for i in range(n) for j in range(n))


# --------------------------------------------------------------------------
# eigenvalues (Faddeev-LeVerrier + Durand-Kerner)
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
    return cs  # p(z) = z^n - cs[0] z^{n-1} - ... - cs[n-1]


def polyval(cs, z):
    v = 1 + 0j
    for c in cs:
        v = v * z - c
    return v


def roots(cs):
    n = len(cs)
    zs = [(0.4 + 0.9j) ** (k + 1) for k in range(n)]
    for _ in range(400):
        new = []
        for i in range(n):
            num, den = polyval(cs, zs[i]), 1 + 0j
            for j in range(n):
                if j != i:
                    den *= zs[i] - zs[j]
            new.append(zs[i] - num / (den if den != 0 else 1e-30))
        zs = new
    return zs


def eigvals(A):
    return roots(char_poly(A))


def gen_eigvals(H, T):
    return eigvals(matmul(H, inv(T)))


def fmt_c(z):
    if abs(z.imag) < 1e-9:
        return "%.10g" % z.real
    return "%.10g%+.10gi" % (z.real, z.imag)


def fmt(A):
    return "\n".join("  [" + ", ".join("% .6f" % x for x in r) + "]" for r in A)


def sorted_eigs(zs):
    return sorted(zs, key=lambda z: (round(z.real, 6), round(z.imag, 6)))


# --------------------------------------------------------------------------
# Act 1: reduction, QR iteration, the Francis double-shift step
# --------------------------------------------------------------------------
def circulant(row):
    n = len(row)
    return [[row[(j - i) % n] for j in range(n)] for i in range(n)]


def hessenberg_reduce(A):
    """Householder similarity: returns H, Q with Q^T A Q = H, Q orthogonal."""
    n = len(A)
    H, Q = copy(A), eye(n)
    for k in range(n - 2):
        x = [H[i][k] for i in range(k + 1, n)]
        v, beta = house(x)
        house_left(H, v, beta, k + 1)
        house_right(H, v, beta, k + 1)
        house_right(Q, v, beta, k + 1)   # Q <- Q V  =>  Q^T A Q = H
    return H, Q


def qr_step_unshifted(H):
    """One unshifted QR step on upper Hessenberg H via Givens rotations."""
    n = len(H)
    R = copy(H)
    rots = []
    for i in range(n - 1):
        a, b = R[i][i], R[i + 1][i]
        r = math.hypot(a, b)
        c, s = (a / r, b / r) if r else (1.0, 0.0)
        rot_rows(R, c, s, i, i + 1)
        rots.append((c, s, i))
    for c, s, i in rots:
        rot_cols_T(R, c, s, i, i + 1)    # R <- R G^T = R Q
    return R


def qr_step_shifted(H, sigma):
    """One shifted QR step (real shift sigma) on upper Hessenberg H."""
    n = len(H)
    R = copy(H)
    for i in range(n):
        R[i][i] -= sigma
    rots = []
    for i in range(n - 1):
        a, b = R[i][i], R[i + 1][i]
        r = math.hypot(a, b)
        c, s = (a / r, b / r) if r else (1.0, 0.0)
        rot_rows(R, c, s, i, i + 1)
        rots.append((c, s, i))
    for c, s, i in rots:
        rot_cols_T(R, c, s, i, i + 1)    # R <- R G^T = R Q
    for i in range(n):
        R[i][i] += sigma
    return R


def trailing_pair_shifts(H):
    """Wilkinson-style double shift: eigenvalues of the trailing 2x2 block.

    Returns (s, t) with p(x) = x^2 - s x + t = (x - mu1)(x - mu2).
    """
    n = len(H)
    a, b = H[n - 2][n - 2], H[n - 2][n - 1]
    c, d = H[n - 1][n - 2], H[n - 1][n - 1]
    s = a + d
    t = a * d - b * c
    return s, t


def bulge_vector(H, s, t):
    """First column of p(H) = H^2 - s H + t I, kept to its first 3 entries.

    p(H) e1 has support in rows 1..3 whenever H is upper Hessenberg.
    """
    n = len(H)
    e1 = [1.0] + [0.0] * (n - 1)
    He1 = matvec(H, e1)
    H2e1 = matvec(H, He1)
    v = [H2e1[i] - s * He1[i] + (t if i == 0 else 0.0) for i in range(min(3, n))]
    return v, He1, H2e1


def francis_double_step(H, s, t, record=None):
    """One implicit Francis double-shift step on upper Hessenberg H.

    p(x) = x^2 - s x + t.  Builds Q1 from p(H) e1 alone, then chases the
    bulge with 3x3 Householder reflectors (Givens when 2 rows remain).
    Returns H', Q with H' = Q^T H Q, and the bulge walk.
    """
    n = len(H)
    H = copy(H)
    Q = eye(n)
    walk = []

    def snap(label):
        walk.append((label, below_band(H)))
        if record is not None:
            record.append({"label": label, "H": [r[:] for r in H]})

    v, He1, H2e1 = bulge_vector(H, s, t)
    snap("start")
    vv, beta = house(v)
    house_left(H, vv, beta, 0)
    house_right(H, vv, beta, 0)
    house_right(Q, vv, beta, 0)
    snap("initial")

    for j in range(1, n - 1):
        m = min(3, n - j)
        x = [H[j + k][j - 1] for k in range(m)]
        if m == 3:
            vv, beta = house(x)
            house_left(H, vv, beta, j)
            house_right(H, vv, beta, j)
            house_right(Q, vv, beta, j)
        else:
            a, b = x[0], x[1]
            r = math.hypot(a, b)
            c, s_ = (a / r, b / r) if r else (1.0, 0.0)
            rot_rows(H, c, s_, j, j + 1)
            rot_cols_T(H, c, s_, j, j + 1)   # H <- G H G^T
            rot_cols_T(Q, c, s_, j, j + 1)
        snap("chase-%d" % j)

    return H, Q, walk, (v, He1, H2e1)


def householder_qr(A):
    """Dense QR: returns Q, R with A = Q R."""
    n = len(A)
    R = copy(A)
    Q = eye(n)
    for k in range(n):
        x = [R[i][k] for i in range(k, n)]
        v, beta = house(x)
        house_left(R, v, beta, k)
        house_left(Q, v, beta, k)
    return transpose(Q), R   # house_left built Q^T


def explicit_double_step(H, s, t):
    """Explicit double shift: QR-factor p(H), set H' = Q^T H Q."""
    n = len(H)
    H2 = matmul(H, H)
    pH = [[H2[i][j] - s * H[i][j] + (t if i == j else 0.0) for j in range(n)]
          for i in range(n)]
    Q, _R = householder_qr(pH)
    return matmul(matmul(transpose(Q), H), Q), Q


def subdiag_mags(H):
    n = len(H)
    return [abs(H[i + 1][i]) for i in range(n - 1)]


def converged(H, tol=1e-14):
    """|H(2,1)| and |H(n,n-1)| below tol: the outer couplings have split."""
    n = len(H)
    scale = max(1.0, fro(H))
    return abs(H[1][0]) < tol * scale and abs(H[n - 1][n - 2]) < tol * scale


def act1():
    print("=" * 72)
    print("ACT 1 -- the Francis QR step on C = circ(1,2,3,4)")
    print("=" * 72)
    C = circulant([1.0, 2.0, 3.0, 4.0])
    closed = [10.0, -2.0, -2.0 + 2j, -2.0 - 2j]
    cs = char_poly(C)
    print("char poly coeffs (c1..c4): " + ", ".join("%.6f" % c for c in cs))
    for z in closed:
        print("  |p(%.6g%+.6gi)| = %.3e" % (z.real, z.imag, abs(polyval(cs, z))))
    print("eigvals (Durand-Kerner): " +
          ", ".join(fmt_c(z) for z in sorted_eigs(eigvals(C))))
    print("trace C = %.6f  (sum of closed-form eigs = 4)" %
          sum(C[i][i] for i in range(4)))

    # power iteration
    x = [1.0, 2.0, 4.0, 7.0]
    nx = norm(x)
    x = [v / nx for v in x]
    rayleighs = []
    for k in range(8):
        y = matvec(C, x)
        lam = sum(x[i] * y[i] for i in range(4))
        ny = norm(y)
        x = [v / ny for v in y]
        rayleighs.append(lam)
    print("power iteration (start 1,2,4,7) Rayleigh quotients:")
    print("  " + " ".join("%.6f" % r for r in rayleighs))
    err = [abs(r - 10.0) for r in rayleighs]
    print("  error ratios k=1..6: " +
          " ".join("%.4f" % (err[k + 1] / err[k]) for k in range(6)))

    # 2x2 Jordan sensitivity
    J = [[1.0, 1000.0], [1e-16, 1.0]]
    print("sensitivity [[1,1000],[1e-16,1]] eigvals: " +
          ", ".join(fmt_c(z) for z in sorted_eigs(eigvals(J))))

    # Hessenberg reduction
    H0, Qr = hessenberg_reduce(C)
    chk = max_abs(mat_sub(matmul(transpose(Qr), matmul(C, Qr)), H0))
    print("Hessenberg reduction: ||Q^T C Q - H||_max = %.3e, ||Q^T Q - I|| = %.3e"
          % (chk, orth_error(Qr)))
    print("H0 =\n" + fmt(H0))
    print("subdiagonal |h(i+1,i)| of H0: " +
          " ".join("%.6f" % v for v in subdiag_mags(H0)))

    # unshifted QR iteration: rate table
    H = copy(H0)
    hist = [subdiag_mags(H)]
    for _ in range(12):
        H = qr_step_unshifted(H)
        hist.append(subdiag_mags(H))
    print("unshifted QR: |h(i+1,i)| over sweeps 0..12")
    for k, row in enumerate(hist):
        print("  k=%2d " % k + " ".join("%.6e" % v for v in row))
    mods = sorted((abs(z) for z in eigvals(C)), reverse=True)
    for i in range(3):
        ratios = [hist[k + 1][i] / hist[k][i]
                  for k in range(2, 12) if hist[k][i] > 0]
        gm = math.exp(sum(math.log(r) for r in ratios) / len(ratios))
        pred = mods[i + 1] / mods[i]
        print("  |h(%d,%d)|: measured geometric-mean ratio over k=2..12: %.6f,"
              " predicted |l%d/l%d| = %.6f"
              % (i + 2, i + 1, gm, i + 2, i + 1, pred))

    # 200 unshifted sweeps: the middle subdiagonal
    H = copy(H0)
    for _ in range(200):
        H = qr_step_unshifted(H)
    print("after 200 unshifted sweeps: |h(2,1)| = %.6e, |h(3,2)| = %.6f, |h(4,3)| = %.6e"
          % (abs(H[1][0]), abs(H[2][1]), abs(H[3][2])))

    # step counts
    def count_steps(step, label):
        H = copy(H0)
        k = 0
        while not converged(H) and k < 500:
            H = step(H)
            k += 1
        print("  %-28s steps to deflate (2,1),(4,3): %d" % (label, k))
        return k, H

    print("step counts (tol 1e-14 * scale):")
    count_steps(qr_step_unshifted, "unshifted")
    count_steps(lambda M: qr_step_shifted(M, M[-1][-1]), "single real shift (Rayleigh)")

    def fr_step(M):
        s, t = trailing_pair_shifts(M)
        return francis_double_step(M, s, t)[0]
    k_fr, H_fr = count_steps(fr_step, "Francis double shift")

    # one Francis step in detail: shifts, bulge vector, walk, implicit vs explicit
    s, t = trailing_pair_shifts(H0)
    disc = s * s - 4 * t
    mu = complex(s / 2, math.sqrt(max(0.0, -disc)) / 2)
    print("trailing-2x2 shifts: mu = %s, so s = %.10f, t = %.10f"
          % (fmt_c(mu), s, t))
    v, He1, H2e1 = bulge_vector(H0, s, t)
    print("bulge vector p(H)e1 (first 3 entries): " +
          " ".join("%.6f" % x for x in v))
    print("  support beyond row 3 of full p(H)e1 would be: rows 4..n of H^2 e1 - s H e1")
    rest = [H2e1[i] - s * He1[i] for i in range(3, 4)]
    print("  entry 4 of p(H)e1 (should vanish): %.3e" % rest[0])

    rec = []
    H1, Q1, walk, _ = francis_double_step(H0, s, t, rec)
    print("bulge walk (below-Hessenberg-band positions after each stage):")
    for label, pos in walk:
        print("  %-10s %s" % (label, pos if pos else "none"))
    print("  ||Q^T Q - I|| = %.3e, ||Q^T H0 Q - H1||_max = %.3e"
          % (orth_error(Q1), max_abs(mat_sub(matmul(transpose(Q1), matmul(H0, Q1)), H1))))
    Qe1 = [Q1[i][0] for i in range(4)]
    pv = matvec(matmul(H0, H0), [1, 0, 0, 0])
    e1 = [1.0, 0, 0, 0]
    He1f = matvec(H0, e1)
    pv = [pv[i] - s * He1f[i] + (t if i == 0 else 0.0) for i in range(4)]
    cross = [Qe1[1] * pv[2] - Qe1[2] * pv[1],
             Qe1[2] * pv[0] - Qe1[0] * pv[2],
             Qe1[0] * pv[1] - Qe1[1] * pv[0]]
    print("  Q e1 parallel to p(H) e1: max |cross| = %.3e" % max(abs(c) for c in cross))

    H_exp, Q_exp = explicit_double_step(H0, s, t)
    # Q_imp = Q_exp * D with D = diag(+-1)  =>  H_imp = D H_exp D
    D = []
    for j in range(4):
        col_i = [Q1[i][j] for i in range(4)]
        col_e = [Q_exp[i][j] for i in range(4)]
        dot = sum(a * b for a, b in zip(col_i, col_e))
        D.append(1.0 if dot >= 0 else -1.0)
    H_exp_signed = [[D[i] * H_exp[i][j] * D[j] for j in range(4)] for i in range(4)]
    print("implicit vs explicit double shift:")
    print("  signature D = %s" % D)
    print("  ||D H_exp D - H_imp||_F = %.3e" % fro(mat_sub(H_exp_signed, H1)))

    # converged real Schur form from the Francis iteration
    H = copy(H0)
    k = 0
    while not converged(H) and k < 500:
        s, t = trailing_pair_shifts(H)
        H = francis_double_step(H, s, t)[0]
        k += 1
    print("converged after %d Francis steps; H_inf =\n%s" % (k, fmt(H)))
    print("  |h(3,2)| of the converged form = %.6f  (the 2x2 block's own subdiagonal)"
          % abs(H[2][1]))
    print("  eigvals: " + ", ".join(fmt_c(z) for z in sorted_eigs(eigvals(H))))

    # flop counts: explicit vs implicit, n = 8, 16, 32, 64
    print("operation counts (multiply-add units) for one double-shift step:")
    print("   n    explicit(p(H)=QR)   implicit(Francis)")
    for n in (8, 16, 32, 64):
        rnd = random.Random(n)
        M = [[0.0] * n for _ in range(n)]
        for i in range(n):
            for j in range(i - 1, n):
                M[i][j] = rnd.uniform(-1, 1)
        ss, tt = trailing_pair_shifts(M)
        FLOPS[0] = 0
        explicit_double_step(M, ss, tt)
        fe = FLOPS[0]
        FLOPS[0] = 0
        francis_double_step(M, ss, tt)
        fi = FLOPS[0]
        print("  %3d          %9d          %9d" % (n, fe, fi))

    return H0, s, t, rec


# --------------------------------------------------------------------------
# Act 2: HT reduction and the Francis QZ step on the pencil (C, 3I + C/2)
# --------------------------------------------------------------------------
def qz_reduce(A, B):
    """Hessenberg-triangular reduction of the pencil (A, B).

    Returns H, T, U, V with U^T A V = H (upper Hessenberg),
    U^T B V = T (upper triangular), U, V orthogonal.
    Phase 1: QR-factor B from the left.  Phase 2: Givens pairs -- a row mix
    that Hessenbergizes A creates one entry under T's diagonal, and a column
    mix immediately restores T's triangularity.
    """
    n = len(A)
    # phase 1: U1^T B = T triangular (left QR), A <- U1^T A
    T = copy(B)
    U1 = eye(n)
    for k in range(n - 1):
        x = [T[i][k] for i in range(k, n)]
        v, beta = house(x)
        house_left(T, v, beta, k)
        house_right(U1, v, beta, k)      # U1 <- U1 V  =>  B = U1 T
    U = U1                               # U^T B = T
    A = matmul(transpose(U), A)          # left equivalence only
    V = eye(n)

    # phase 2: Hessenbergize A, keep T triangular
    for j in range(n - 2):
        for i in range(n - 1, j + 1, -1):
            # zero A(i, j) with a row mix on (i-1, i)
            a, b = A[i - 1][j], A[i][j]
            r = math.hypot(a, b)
            if r == 0:
                continue
            c, s = a / r, b / r
            rot_rows(A, c, s, i - 1, i)
            rot_rows(T, c, s, i - 1, i)  # creates T(i, i-1)
            rot_cols_T(U, c, s, i - 1, i)  # U <- U G^T
            # restore T's triangularity with a column mix on (i-1, i)
            p, q = T[i][i - 1], T[i][i]
            r2 = math.hypot(p, q)
            if r2 == 0:
                continue
            c2, s2 = q / r2, p / r2
            rot_cols(A, c2, s2, i - 1, i)
            rot_cols(T, c2, s2, i - 1, i)
            rot_cols(V, c2, s2, i - 1, i)
    return A, T, U, V


def qz_step(H, T, record=None):
    """One implicit Francis double-shift QZ step on a Hessenberg-triangular pencil.

    Shift pair = eigenvalues of the trailing 2x2 pencil.  The bulge vector is
    the first column of p(M), M = H T^{-1}, obtained by two triangular solves --
    T is never inverted and M is never formed.  The chase alternates left
    reflectors (H's bulge) and right reflectors (T's triangularity).
    Returns H', T', Q, Z, snapshots, (s, t).
    """
    n = len(H)
    H, T = copy(H), copy(T)
    Q, Z = eye(n), eye(n)
    walk = []

    def snap(label):
        walk.append((label, below_band(H)))
        if record is not None:
            record.append({"label": label, "H": [r[:] for r in H],
                           "T": [r[:] for r in T]})

    snap("start")

    # shifts from the trailing 2x2 pencil
    a11, a12 = H[n - 2][n - 2], H[n - 2][n - 1]
    a21, a22 = H[n - 1][n - 2], H[n - 1][n - 1]
    t11, t12 = T[n - 2][n - 2], T[n - 2][n - 1]
    t22 = T[n - 1][n - 1]
    m11 = a11 / t11
    m12 = -a11 * t12 / (t11 * t22) + a12 / t22
    m21 = a21 / t11
    m22 = -a21 * t12 / (t11 * t22) + a22 / t22
    s, t = m11 + m22, m11 * m22 - m12 * m21   # p(x) = x^2 - s x + t

    # bulge vector: first column of (M^2 - s M + t I), M = H T^{-1}
    e1 = [1.0] + [0.0] * (n - 1)
    w = solve_tri(T, e1)                       # T w = e1        -> w = T^{-1} e1
    Me1 = matvec(H, w)                         # M e1
    y = solve_tri(T, Me1)                      # T y = M e1      -> y = T^{-1} M e1
    M2e1 = matvec(H, y)                        # M^2 e1
    v = [M2e1[i] - s * Me1[i] + (t if i == 0 else 0.0) for i in range(3)]

    vv, beta = house(v)
    house_left(H, vv, beta, 0)
    house_left(T, vv, beta, 0)
    house_right(Q, vv, beta, 0)
    snap("initial-left")

    for j in range(0, n - 2):
        if j > 0:
            x = [H[j + k][j - 1] for k in range(3)]
            vv, beta = house(x)
            house_left(H, vv, beta, j)
            house_left(T, vv, beta, j)
            house_right(Q, vv, beta, j)
            snap("left-%d" % j)

        # right reflector: T[j:j+3, j:j+3] g proportional to e1
        block = [[T[j + a][j + b] for b in range(3)] for a in range(3)]
        g0 = solve(block, [1.0, 0.0, 0.0])
        ng = norm(g0)
        g0 = [g / ng for g in g0]
        vv, beta = house(g0)
        house_right(H, vv, beta, j)
        house_right(T, vv, beta, j)
        house_right(Z, vv, beta, j)
        snap("right-%d" % j)

    # final two columns: Givens rotations
    j = n - 2
    a, b = H[j][j - 1], H[j + 1][j - 1]
    r = math.hypot(a, b)
    c, s_ = a / r, b / r
    rot_rows(H, c, s_, j, j + 1)
    rot_rows(T, c, s_, j, j + 1)
    rot_cols_T(Q, c, s_, j, j + 1)
    snap("last-left")

    a, b = T[j + 1][j], T[j + 1][j + 1]
    r = math.hypot(a, b)
    c, s_ = b / r, a / r
    rot_cols(H, c, s_, j, j + 1)
    rot_cols(T, c, s_, j, j + 1)
    rot_cols(Z, c, s_, j, j + 1)
    snap("last-right")

    return H, T, Q, Z, walk, (s, t)


def act2():
    print()
    print("=" * 72)
    print("ACT 2 -- QZ on the pencil (C, B), B = 3I + C/2")
    print("=" * 72)
    C = circulant([1.0, 2.0, 3.0, 4.0])
    B = [[3.0 * (1.0 if i == j else 0.0) + 0.5 * C[i][j] for j in range(4)]
         for i in range(4)]
    closed = [1.25, -1.0, (-2.0 + 6j) / 5, (-2.0 - 6j) / 5]
    print("closed-form gen. eigenvalues: " +
          ", ".join(fmt_c(z) for z in sorted_eigs(closed)))
    print("  (lambda of C divided by 3 + lambda/2: 10/8, -2/2, (-2+2i)/(2+i), conj)")

    # the infinite-eigenvalue mini example, for the slide's 2x2 story
    A2 = [[2.0, 0.0], [0.0, 1.0]]
    B2 = [[1.0, 0.0], [0.0, 0.0]]
    print("mini pencil A = diag(2,1), B = diag(1,0): det(A - l B) = (2-l)*1")
    print("  one finite eigenvalue (l = 2) and one at infinity; B is singular.")

    H, T, U, V = qz_reduce(C, B)
    resA = max_abs(mat_sub(matmul(matmul(transpose(U), C), V), H))
    resB = max_abs(mat_sub(matmul(matmul(transpose(U), B), V), T))
    below_hess = max([abs(H[i][j]) for i in range(4) for j in range(4) if i > j + 1] + [0.0])
    below_diag = max([abs(T[i][j]) for i in range(4) for j in range(4) if i > j] + [0.0])
    print("HT reduction: ||U^T C V - H||_max = %.3e, ||U^T B V - T||_max = %.3e"
          % (resA, resB))
    print("  ||U^T U - I|| = %.3e, ||V^T V - I|| = %.3e" % (orth_error(U), orth_error(V)))
    print("  structure: max below Hessenberg band %.3e, max below T's diagonal %.3e"
          % (below_hess, below_diag))
    print("H =\n" + fmt(H))
    print("T =\n" + fmt(T))
    print("gen eigvals of (H,T): " +
          ", ".join(fmt_c(z) for z in sorted_eigs(gen_eigvals(H, T))))
    print("subdiagonal |H(i+1,i)| of H: " + " ".join("%.6f" % v for v in subdiag_mags(H)))

    # one QZ step in detail
    rec = []
    H1, T1, Q, Z, walk, (s, t) = qz_step(H, T, rec)
    disc = s * s - 4 * t
    mu = complex(s / 2, math.sqrt(max(0.0, -disc)) / 2)
    print("trailing-2x2 pencil shifts: mu = %s, s = %.6f, t = %.6f"
          % (fmt_c(mu), s, t))
    print("subdiagonal |H(i+1,i)| before: " +
          " ".join("%.6f" % v for v in subdiag_mags(H)))
    print("subdiagonal |H(i+1,i)| after : " +
          " ".join("%.6f" % v for v in subdiag_mags(H1)))
    print("structure after the step: below band %.3e, below T diag %.3e"
          % (max([abs(H1[i][j]) for i in range(4) for j in range(4) if i > j + 1] + [0.0]),
             max([abs(T1[i][j]) for i in range(4) for j in range(4) if i > j] + [0.0])))
    print("  ||Q^T Q - I|| = %.3e, ||Z^T Z - I|| = %.3e" % (orth_error(Q), orth_error(Z)))
    print("  ||Q^T H Z - H1||_max = %.3e, ||Q^T T Z - T1||_max = %.3e"
          % (max_abs(mat_sub(matmul(matmul(transpose(Q), H), Z), H1)),
             max_abs(mat_sub(matmul(matmul(transpose(Q), T), Z), T1))))
    ev0, ev1 = gen_eigvals(H, T), gen_eigvals(H1, T1)
    print("  gen eigvals before: " + ", ".join(fmt_c(z) for z in sorted_eigs(ev0)))
    print("  gen eigvals after : " + ", ".join(fmt_c(z) for z in sorted_eigs(ev1)))
    print("QZ bulge walk (below-Hessenberg-band positions in H):")
    for label, pos in walk:
        print("  %-12s %s" % (label, pos if pos else "none"))

    # iterate with exact deflation to block form
    n = 4
    Hk, Tk = copy(H), copy(T)
    trail = []
    k = 0
    while k < 80:
        trail.append(subdiag_mags(Hk))
        # exact deflation: negligible couplings are set to zero and split the pencil
        for i in range(n - 1):
            sc = (abs(Hk[i][i]) + abs(Hk[i + 1][i + 1]) +
                  abs(Tk[i][i]) + abs(Tk[i + 1][i + 1]))
            if abs(Hk[i + 1][i]) <= 1e-14 * sc:
                Hk[i + 1][i] = 0.0
        # blocks = maximal runs of nonzero subdiagonals
        blocks, i = [], 0
        while i < n:
            j = i
            while j < n - 1 and Hk[j + 1][j] != 0.0:
                j += 1
            blocks.append((i, j))
            i = j + 1
        active = []
        for lo, hi in blocks:
            m = hi - lo + 1
            if m < 2:
                continue
            if m == 2:
                # a complex conjugate pair is a legitimate terminal block
                a11, a12 = Hk[lo][lo], Hk[lo][lo + 1]
                a21, a22 = Hk[lo + 1][lo], Hk[lo + 1][lo + 1]
                t11, t12 = Tk[lo][lo], Tk[lo][lo + 1]
                t22 = Tk[lo + 1][lo + 1]
                m11 = a11 / t11
                m12 = -a11 * t12 / (t11 * t22) + a12 / t22
                m21 = a21 / t11
                m22 = -a21 * t12 / (t11 * t22) + a22 / t22
                disc = (m11 + m22) ** 2 - 4 * (m11 * m22 - m12 * m21)
                if disc < 0:
                    continue
                raise RuntimeError("2x2 real block: not expected in this example")
            active.append((lo, hi))
        if not active:
            break
        for lo, hi in active:
            m = hi - lo + 1
            Hb = [row[lo:hi + 1] for row in Hk[lo:hi + 1]]
            Tb = [row[lo:hi + 1] for row in Tk[lo:hi + 1]]
            Hb, Tb, _, _, _, _ = qz_step(Hb, Tb)
            for a in range(m):
                for b in range(m):
                    Hk[lo + a][lo + b] = Hb[a][b]
                    Tk[lo + a][lo + b] = Tb[a][b]
        k += 1
    trail.append(subdiag_mags(Hk))
    print("deflation table |H(2,1)|, |H(3,2)|, |H(4,3)| over sweeps:")
    for i, row in enumerate(trail):
        print("  k=%d " % i + " ".join("%.6e" % v for v in row))
    print("converged after %d QZ sweeps (with exact deflation)" % k)
    print("H_inf =\n" + fmt(Hk))
    print("T_inf =\n" + fmt(Tk))
    print("  |H(3,2)| of the converged form = %.6f  (2x2 block's own subdiagonal)"
          % abs(Hk[2][1]))
    print("  gen eigvals: " + ", ".join(fmt_c(z) for z in sorted_eigs(gen_eigvals(Hk, Tk))))

    return H, T, rec


# --------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", action="store_true",
                    help="emit the bulge-chase demo snapshots as JSON")
    args = ap.parse_args()
    H0, s1, t1, rec1 = act1()
    H, T, rec2 = act2()
    if args.json:
        print("\nJSON")
        print(json.dumps({"qr_chase": rec1, "qz_chase": rec2}))


if __name__ == "__main__":
    main()
