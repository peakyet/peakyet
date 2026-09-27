#!/usr/bin/env python3
"""Verify every number the note "QZ for the Algebraic Riccati Equation" shows.

Two arithmetics, one problem.
  * exact rationals (fractions.Fraction) for the model: the running example is
    designed backwards from its own solution, so the DARE residual, the pencil,
    its characteristic polynomial and every deflating subspace are exact;
  * double precision for the reduction and the QZ sweeps, i.e. for what a solver
    really computes.

Report blocks are tagged with the page section whose numbers they produce.
Self-tests run first and abort the report if a routine is not an orthogonal
equivalence or does not preserve the pencil.

Run:  python3 Control/qz-algebraic-riccati/scripts/verify_qz_riccati.py
      python3 Control/qz-algebraic-riccati/scripts/verify_qz_riccati.py --json
"""

import argparse
import cmath
import json
import math
import random
import time
from fractions import Fraction as F

FLOPS = [0]                 # multiply-add units, counted by every primitive
BAD = []                    # self-test failures
EPS0 = 2.220446049250313e-16   # distance from 1.0 to the next double


# =========================================================================
# generic matrix arithmetic (runs over Fraction and over float unchanged)
# =========================================================================
def one_of(A):
    return type(A[0][0])(1)


def mm(A, B):
    n, k, m = len(A), len(B), len(B[0])
    FLOPS[0] += 2 * n * m * k
    return [[sum(A[i][p] * B[p][j] for p in range(k)) for j in range(m)]
            for i in range(n)]


def mv(A, x):
    FLOPS[0] += 2 * len(A) * len(x)
    return [sum(A[i][j] * x[j] for j in range(len(x))) for i in range(len(A))]


def tr(A):
    return [list(r) for r in zip(*A)]


def eye(n, one=1.0):
    return [[one if i == j else one * 0 for j in range(n)] for i in range(n)]


def cp(A):
    return [r[:] for r in A]


def add(A, B, s=1):
    return [[A[i][j] + s * B[i][j] for j in range(len(A[0]))]
            for i in range(len(A))]


def scale(A, s):
    return [[s * v for v in r] for r in A]


def f64(A):
    return [[float(v) for v in r] for r in A]


def fvec(x):
    return [float(v) for v in x]


def maxabs(A):
    return max((abs(float(v)) for r in A for v in r), default=0.0)


def frob(A):
    return math.sqrt(sum(float(v) * float(v) for r in A for v in r))


def nrm(x):
    return math.sqrt(sum(float(v) * float(v) for v in x))


def solve(A, b):
    """Gauss-Jordan with partial pivoting; raises if A is singular."""
    n = len(A)
    M = [[A[i][j] for j in range(n)] + [b[i]] for i in range(n)]
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(M[r][c]))
        if M[p][c] == 0:
            raise ZeroDivisionError("singular matrix")
        M[c], M[p] = M[p], M[c]
        piv = M[c][c]
        for k in range(c, n + 1):
            M[c][k] /= piv
        for r in range(n):
            if r != c and M[r][c] != 0:
                f = M[r][c]
                for k in range(c, n + 1):
                    M[r][k] -= f * M[c][k]
    return [M[i][n] for i in range(n)]


def inv(A):
    n = len(A)
    one = one_of(A)
    cols = [solve(A, [one if i == r else one * 0 for i in range(n)])
            for r in range(n)]
    return [[cols[r][i] for r in range(n)] for i in range(n)]


def det(A):
    n = len(A)
    M = cp(A)
    out = one_of(A)
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(M[r][c]))
        if M[p][c] == 0:
            return out * 0
        if p != c:
            out = -out
        M[c], M[p] = M[p], M[c]
        out *= M[c][c]
        for r in range(c + 1, n):
            f = M[r][c] / M[c][c]
            for k in range(c, n):
                M[r][k] -= f * M[c][k]
    return out


def nullspace(A, tol=1e-12):
    """Basis of {x : Ax = 0} from the reduced row echelon form."""
    n, m = len(A), len(A[0])
    M = cp(A)
    piv = []
    r = 0
    for c in range(m):
        if r >= n:
            break
        p = max(range(r, n), key=lambda i: abs(M[i][c]))
        if abs(M[p][c]) <= tol:
            continue
        M[r], M[p] = M[p], M[r]
        d = M[r][c]
        M[r] = [v / d for v in M[r]]
        for i in range(n):
            if i != r and M[i][c] != 0:
                f = M[i][c]
                M[i] = [M[i][k] - f * M[r][k] for k in range(m)]
        piv.append(c)
        r += 1
    basis = []
    for fc in [c for c in range(m) if c not in piv]:
        v = [one_of(M) * 0] * m
        v[fc] = one_of(M)
        for i, pc in enumerate(piv):
            v[pc] = -M[i][fc]
        basis.append(v)
    return basis


# =========================================================================
# the DARE, its pencil, and examples designed backwards from their solution
# =========================================================================
def dare_lhs(A, B, Q, R, X):
    """A'XA - A'XB (R + B'XB)^-1 B'XA + Q - X: zero exactly when X solves the DARE."""
    At = tr(A)
    C = mm(mm(At, X), B)
    D = add(R, mm(mm(tr(B), X), B))
    return add(add(add(mm(mm(At, X), A), Q), scale(mm(C, mm(inv(D), tr(C))), -1)),
               X, -1)


def gain(A, B, R, X):
    """K = (R + B'XB)^-1 B'XA."""
    return mm(inv(add(R, mm(mm(tr(B), X), B))), mm(mm(tr(B), X), A))


def design(P, M, G):
    """Plant (A, Q) whose DARE has solution P with closed-loop multiplier M.

    Read the deflating-subspace identity of section #s2 backwards:
        A = (I + G P) M ,   Q = P - A' P M ,      G = B R^-1 B'  (P, G symmetric)
    Then Q is symmetric without further conditions, since A'PM = M'PM + M'PGPM is
    a sum of two symmetric matrices.  Choose P, M, G rational and so is the plant.
    """
    n = len(P)
    A = mm(add(eye(n, one_of(P)), mm(G, P)), M)
    Q = add(P, scale(mm(mm(tr(A), P), M), -1))
    return A, Q


def pencil(A, Q, G):
    """Sherman pencil of the DARE:  L = [A 0; -Q I],  N = [I G; 0 A']."""
    n = len(A)
    one, zero = one_of(A), one_of(A) * 0
    At = tr(A)
    L = [[zero] * (2 * n) for _ in range(2 * n)]
    N = [[zero] * (2 * n) for _ in range(2 * n)]
    for i in range(n):
        for j in range(n):
            L[i][j] = A[i][j]
            L[i + n][j] = -Q[i][j]
            L[i + n][j + n] = one if i == j else zero
            N[i][j] = one if i == j else zero
            N[i][j + n] = G[i][j]
            N[i + n][j + n] = At[i][j]
    return L, N


def pencil_poly(L, N):
    """Exact coefficients of det(L - z N), ascending powers, by interpolation."""
    d = len(L)
    pts = [F(i, 3) for i in range(d + 1)]
    vals = [det(add(L, scale(N, -t))) for t in pts]
    Vd = [[t ** k for k in range(d + 1)] for t in pts]
    return solve(Vd, vals)


def poly_repr(cs):
    terms = []
    for k, c in enumerate(cs):
        if c == 0:
            continue
        terms.append(("%s*z^%d" % (c, k)) if k > 1 else
                     ("%s*z" % c) if k == 1 else "%s" % c)
    return " + ".join(terms).replace("+ -", "- ")


def poly_mul(a, b):
    """Convolution of two ascending-coefficient polynomials (exact or float)."""
    out = [a[0] * b[0] * 0] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            out[i + j] += x * y
    return out


def deflating_res(L, N, V, Tm):
    """max |L V - N V T|: is span(V) a deflating subspace with spectrum T?"""
    return maxabs(add(mm(L, V), mm(N, mm(V, Tm)), -1))


def diag(zs):
    zero = type(zs[0])(0)
    return [[(z if i == j else zero) for j in range(len(zs))]
            for i, z in enumerate(zs)]


def columnize(cols):
    return [list(r) for r in zip(*cols)]


def top_block(V, n):
    return [r[:n] for r in V[:n]]


def lower_block(V, n):
    """Rows n..2n of a 2n x n deflating basis: the bottom half of the graph [I; X]."""
    return [r[:n] for r in V[n:]]


def cond2(A):
    smax, smin = sigma_max(A), sigma_min(A)
    return float('inf') if smin == 0 else smax / smin


def sigma_all(A):
    """All singular values of a small square/rectangular float matrix, by
    Jacobi eigenvalue sweeps on A'A."""
    G = mm(tr(A), A)
    k = len(G)
    for _ in range(200):
        off = max((abs(G[i][j]) for i in range(k) for j in range(i + 1, k)),
                  default=0.0)
        if off < 1e-18 * max(1.0, maxabs(G)):
            break
        for p in range(k):
            for q in range(p + 1, k):
                if abs(G[p][q]) < 1e-300:
                    continue
                tau = (G[q][q] - G[p][p]) / (2 * G[p][q])
                t = math.copysign(1.0, tau) / (abs(tau) + math.sqrt(1 + tau * tau))
                c, s = 1.0 / math.sqrt(1 + t * t), t / math.sqrt(1 + t * t)
                rotate_sym(G, c, s, p, q)
    return sorted((math.sqrt(max(0.0, G[i][i])) for i in range(k)), reverse=True)


def rotate_sym(G, c, s, p, q):
    k = len(G)
    for i in range(k):
        if i != p and i != q:
            a, b = G[i][p], G[i][q]
            G[p][i] = G[i][p] = c * a + s * b
            G[q][i] = G[i][q] = -s * a + c * b
    app, aqq, apq = G[p][p], G[q][q], G[p][q]
    G[p][p] = c * c * app + 2 * s * c * apq + s * s * aqq
    G[q][q] = s * s * app - 2 * s * c * apq + c * c * aqq
    G[p][q] = G[q][p] = 0.0


# =========================================================================
# double precision kernels: Householder, Givens, HT reduction, QZ sweep
# =========================================================================
def house(x):
    m, nx = len(x), nrm(x)
    if nx == 0:
        return [0.0] * m, 0.0
    alpha = -math.copysign(nx, x[0]) if x[0] != 0 else -nx
    v = x[:]
    v[0] -= alpha
    vn2 = sum(t * t for t in v)
    FLOPS[0] += 3 * m
    return (v, 0.0) if vn2 == 0 else (v, 2.0 / vn2)


def house_left(A, v, beta, i0):
    m = len(v)
    if beta == 0.0:
        return
    FLOPS[0] += 4 * m * len(A[0])
    for j in range(len(A[0])):
        s = sum(v[k] * A[i0 + k][j] for k in range(m))
        for k in range(m):
            A[i0 + k][j] -= beta * v[k] * s


def house_right(A, v, beta, j0):
    m = len(v)
    if beta == 0.0:
        return
    FLOPS[0] += 4 * m * len(A)
    for i in range(len(A)):
        s = sum(v[k] * A[i][j0 + k] for k in range(m))
        for k in range(m):
            A[i][j0 + k] -= beta * s * v[k]


def rot_rows(A, c, s, i0, i1):
    FLOPS[0] += 6 * len(A[0])
    for j in range(len(A[0])):
        a, b = A[i0][j], A[i1][j]
        A[i0][j] = c * a + s * b
        A[i1][j] = -s * a + c * b


def rot_cols(A, c, s, j0, j1):
    FLOPS[0] += 6 * len(A)
    for i in range(len(A)):
        a, b = A[i][j0], A[i][j1]
        A[i][j0] = c * a - s * b
        A[i][j1] = s * a + c * b


def rot_cols_T(A, c, s, j0, j1):
    FLOPS[0] += 6 * len(A)
    for i in range(len(A)):
        a, b = A[i][j0], A[i][j1]
        A[i][j0] = c * a + s * b
        A[i][j1] = -s * a + c * b


def orth_err(Q):
    return maxabs(add(mm(tr(Q), Q), eye(len(Q)), -1))


def ht_reduce(A, B):
    """Hessenberg-triangular form: U' A V = H, U' B V = R, U and V orthogonal.

    Phase 1 is a left QR of B.  Phase 2 mixes rows of A towards Hessenberg form;
    each such mix kicks one entry below R's diagonal and the matching column mix
    takes it out again.  B is never inverted.
    """
    save = FLOPS[0]
    n = len(A)
    R, U = cp(B), eye(n)
    for k in range(n - 1):
        v, beta = house([R[i][k] for i in range(k, n)])
        house_left(R, v, beta, k)
        house_right(U, v, beta, k)
    H = mm(tr(U), A)
    V = eye(n)
    for j in range(n - 2):
        for i in range(n - 1, j + 1, -1):
            a, b = H[i - 1][j], H[i][j]
            r = math.hypot(a, b)
            if r == 0:
                continue
            c, s = a / r, b / r
            rot_rows(H, c, s, i - 1, i)
            rot_rows(R, c, s, i - 1, i)
            rot_cols_T(U, c, s, i - 1, i)
            p, q = R[i][i - 1], R[i][i]
            r2 = math.hypot(p, q)
            if r2 == 0:
                continue
            c2, s2 = q / r2, p / r2
            rot_cols(H, c2, s2, i - 1, i)
            rot_cols(R, c2, s2, i - 1, i)
            rot_cols(V, c2, s2, i - 1, i)
    used = FLOPS[0] - save
    FLOPS[0] = save
    return H, R, U, V, used


def bw_solve(U, b):
    n = len(U)
    scale = maxabs(U)
    x = [0.0] * n
    for i in range(n - 1, -1, -1):
        if abs(U[i][i]) <= 1e-13 * scale:
            raise ValueError("negligible beta: this block has a multiplier at "
                             "infinity, and the sweep refuses to divide by it")
        x[i] = (b[i] - sum(U[i][j] * x[j] for j in range(i + 1, n))) / U[i][i]
    return x


def pair_trace_det(H, R, i):
    """Trace and determinant of R^-1 H restricted to the 2x2 block at (i, i+1).

    These are the two elementary symmetric functions of the block's multipliers, so
    they are exactly what a double shift needs: p(z) = z^2 - (trace) z + det.  The
    block is read as R^-1 H without inverting anything, using R's own upper
    triangular shape inside the block.  None when a beta is zero, i.e. when this
    block has a multiplier at infinity and no finite shift describes it.
    """
    a11, a12 = H[i][i], H[i][i + 1]
    a21, a22 = H[i + 1][i], H[i + 1][i + 1]
    r11, r12, r22 = R[i][i], R[i][i + 1], R[i + 1][i + 1]
    if abs(r11) < 1e-300 or abs(r22) < 1e-300:
        return None
    m11, m21 = a11 / r11, a21 / r11
    m12 = a12 / r22 - a11 * r12 / (r11 * r22)
    m22 = a22 / r22 - a21 * r12 / (r11 * r22)
    return (m11 + m22, m11 * m22 - m12 * m21)


def qz_step(H, R, record=None, shift=None):
    """One implicit Francis double-shift QZ sweep on a Hessenberg-triangular pair.

    Shift pair = the two multipliers of the trailing 2x2 pencil.  The bulge vector
    is the first column of p(M) with M = H R^-1, built from two triangular solves:
    R is never inverted and M is never formed.  A left reflector clears two entries
    of H's subdiagonal and kicks one into R's; a right reflector removes it.  A
    caller may hand in another (trace, det) pair, which is how the exceptional shift
    in qz_schur breaks a stall.
    """
    n = len(H)
    H, R = cp(H), cp(R)
    Q, Z = eye(n), eye(n)
    walk = []

    def snap(tag):
        if record is None:
            return
        frame = {"tag": tag, "H": cp(H), "R": cp(R),
                 "bulge": [(i + 1, j + 1) for i in range(n)
                           for j in range(n)
                           if i > j + 1 and abs(H[i][j]) > 1e-11]}
        walk.append(frame)
        record.append(frame)

    snap("start")
    sh = shift if shift is not None else pair_trace_det(H, R, n - 2)
    if sh is None:
        sh = (0.0, 0.0)                    # a beta vanished: shift with p(z) = z^2
    s, t = sh
    e1 = [1.0] + [0.0] * (n - 1)
    Hw = mv(H, bw_solve(R, e1))
    HHw = mv(H, bw_solve(R, Hw))
    v = [HHw[i] - s * Hw[i] + (t if i == 0 else 0.0) for i in range(3)]
    vv, beta = house(v)
    house_left(H, vv, beta, 0)
    house_left(R, vv, beta, 0)
    house_right(Q, vv, beta, 0)
    snap("initial-left")
    for j in range(n - 2):
        if j > 0:
            vv, beta = house([H[j + k][j - 1] for k in range(3)])
            house_left(H, vv, beta, j)
            house_left(R, vv, beta, j)
            house_right(Q, vv, beta, j)
            snap("left-%d" % j)
        blk = [[R[j + a][j + b] for b in range(3)] for a in range(3)]
        g = solve(blk, [1.0, 0.0, 0.0])
        ng = nrm(g)
        g = [x / ng for x in g]
        vv, beta = house(g)
        house_right(H, vv, beta, j)
        house_right(R, vv, beta, j)
        house_right(Z, vv, beta, j)
        snap("right-%d" % j)
    j = n - 2
    a, b = H[j][j - 1], H[j + 1][j - 1]
    r = math.hypot(a, b)
    if r:
        c, s2 = a / r, b / r
        rot_rows(H, c, s2, j, j + 1)
        rot_rows(R, c, s2, j, j + 1)
        rot_cols_T(Q, c, s2, j, j + 1)
        snap("last-left")
    a, b = R[j + 1][j], R[j + 1][j + 1]
    r = math.hypot(a, b)
    if r:
        c, s2 = b / r, a / r
        rot_cols(H, c, s2, j, j + 1)
        rot_cols(R, c, s2, j, j + 1)
        rot_cols(Z, c, s2, j, j + 1)
        snap("last-right")
    return H, R, Q, Z, walk, (s, t)


def split_pair(H, R, U, V, i):
    """Split the 2x2 window at rows/columns (i, i+1) when both multipliers are real.

    A double-shift sweep is silent on a 2x2 block: its shift polynomial is exactly
    that block's own characteristic polynomial, so p(M)e1 = 0 by Cayley-Hamilton and
    nothing moves.  Such a block is finished in one rotation pair instead.  Take the
    multiplier z nearer a22/r22 and its eigenvector y; because R is upper triangular
    inside the window, y is an adjugate column of (H - zR), for instance
    (a22 - z*r22, -a21): no division by anything that could be small.  Mixing columns
    by y makes the new column i of H and of R parallel, since H y = z R y, so one row
    rotation then clears both subdiagonals at the same time and the block is two 1x1s.

    Two precautions, both of which the numbers below depend on.  z is polished by the
    pencil's own quotient (Hy.Ry)/(Ry.Ry), because a shift that is only half accurate
    leaves a visible subdiagonal in R afterwards.  And the rotations are tried on a 2x2
    copy first: when the two multipliers nearly coincide no direction is well
    determined, so the block is left whole and the caller is told instead of being
    handed a split that quietly perturbed the pencil.
    """
    a11, a12 = H[i][i], H[i][i + 1]
    a21, a22 = H[i + 1][i], H[i + 1][i + 1]
    r11, r12, r22 = R[i][i], R[i][i + 1], R[i + 1][i + 1]
    c2 = r11 * r22
    if abs(c2) < 1e-300:
        return False                       # an infinite multiplier: not for this kernel
    c1 = r12 * a21 - (a11 * r22 + a22 * r11)
    c0 = a11 * a22 - a12 * a21
    disc = c1 * c1 - 4 * c2 * c0
    if disc < 0.0:
        return False                       # conjugate pair: the block is already settled
    sq = math.sqrt(disc)
    # Stable quadratic: (-c1 +- sq)/(2 c2) cancels when one multiplier is much the
    # smaller, so take the larger root without cancellation and get the other from c0.
    q = -0.5 * (c1 + math.copysign(sq, c1)) if c1 != 0.0 else sq
    if q == 0.0:
        return False
    z1, z2 = q / c2, c0 / q
    target = a22 / r22
    z = z1 if abs(z1 - target) <= abs(z2 - target) else z2
    # Both adjugate columns point along the null vector when z is exact: use the longer.
    y = (0.0, 1.0)
    for _ in range(3):
        u, w = (a22 - z * r22, -a21), (z * r12 - a12, a11 - z * r11)
        y = u if math.hypot(*u) >= math.hypot(*w) else w
        ny = math.hypot(*y)
        if ny == 0.0:
            return False
        y = (y[0] / ny, y[1] / ny)
        hy = (a11 * y[0] + a12 * y[1], a21 * y[0] + a22 * y[1])
        ry = (r11 * y[0] + r12 * y[1], r22 * y[1])
        den = ry[0] * ry[0] + ry[1] * ry[1]
        if den == 0.0:
            return False
        z = (hy[0] * ry[0] + hy[1] * ry[1]) / den
    ny = math.hypot(*y)
    c, s = y[0] / ny, -y[1] / ny
    Hw, Rw = [[a11, a12], [a21, a22]], [[r11, r12], [0.0, r22]]
    rot_cols(Hw, c, s, 0, 1)
    rot_cols(Rw, c, s, 0, 1)
    a, b = Hw[0][0], Hw[1][0]
    r = math.hypot(a, b)
    if r == 0.0:
        return False
    cl, sl = a / r, b / r
    rot_rows(Hw, cl, sl, 0, 1)
    rot_rows(Rw, cl, sl, 0, 1)
    scale = max(maxabs(Hw), maxabs(Rw))
    if scale == 0.0 or max(abs(Hw[1][0]), abs(Rw[1][0])) > 1e-11 * scale:
        return False                       # ill-conditioned split: keep the 2x2 whole
    rot_cols(H, c, s, i, i + 1)
    rot_cols(R, c, s, i, i + 1)
    rot_cols(V, c, s, i, i + 1)
    rot_rows(H, cl, sl, i, i + 1)
    rot_rows(R, cl, sl, i, i + 1)
    rot_cols_T(U, cl, sl, i, i + 1)
    H[i + 1][i] = 0.0
    R[i + 1][i] = 0.0
    return True


def qz_schur(A, B, tol=1e-13, max_sweeps=600, keep_walks=True):
    """Reduce a pair to generalized real Schur form: S = U\' A V, R = U\' B V.

    Sweeps are applied to the bottom-most unreduced diagonal block only, and a block
    releases its pieces as soon as a subdiagonal becomes negligible: that is what
    keeps a sweep at O(m^2) and stops converged corners being revisited.  Each
    sweep's two factors act on the whole pencil, not just on the block, because the
    converged blocks above it share the block's columns.

    A shift strategy is part of the algorithm, not a detail: a trailing double shift
    can sit on a block and shrink nothing, so a stalled block switches to the
    *exceptional* shift taken from the block's leading 2x2, exactly as LAPACK's
    DHGEQZ does.  Without it this kernel stalls on pencils of order 32 and above.
    """
    n = len(A)
    H, R, U, V, f_ht = ht_reduce(A, B)
    f_sweep = 0
    log, walks = [], []
    sweeps = 0
    settled = set()
    active, stall, floor = None, 0, None
    while sweeps < max_sweeps:
        rng = bottom_block(H, R, tol, settled)
        if rng is None:
            break
        i0, i1 = rng
        m = i1 - i0
        if m == 2:
            before = FLOPS[0]
            if split_pair(H, R, U, V, i0):
                sweeps += 1
                f_sweep += FLOPS[0] - before
                log.append({"sweep": sweeps, "block": [i0, i1], "shift": None,
                            "split": True,
                            "sub": [abs(H[i + 1][i]) for i in range(n - 1)]})
                continue
            settled.add(i0)                # a real conjugate pair with a zero beta
            continue
        Hw = [[H[i0 + i][i0 + j] for j in range(m)] for i in range(m)]
        Rw = [[R[i0 + i][i0 + j] for j in range(m)] for i in range(m)]
        # has this block's smallest subdiagonal shrunk since the last check?
        small = min((abs(Hw[i + 1][i]) / max(1e-300, max(maxabs(Hw), maxabs(Rw)))
                     for i in range(m - 1)), default=0.0)
        if (i0, i1) != active or small < 0.75 * (floor or 0.0):
            active, stall, floor = (i0, i1), 0, small
        else:
            stall += 1
        exc = stall >= 10 and m >= 3
        if stall >= 40:
            stall = 0                      # let the ordinary shift have another run
        before = FLOPS[0]
        rec = [] if keep_walks else None
        H2, R2, Q, Z, walk, sh = qz_step(Hw, Rw, record=rec,
                                         shift=pair_trace_det(Hw, Rw, 0) if exc else None)
        f_sweep += FLOPS[0] - before
        window_left(H, Q, i0, i1)
        window_left(R, Q, i0, i1)
        window_right(H, Z, i0, i1)
        window_right(R, Z, i0, i1)
        window_right(U, Q, i0, i1)
        window_right(V, Z, i0, i1)
        sweeps += 1
        log.append({"sweep": sweeps, "block": [i0, i1], "shift": sh,
                    "split": False,
                    "exc": exc,
                    "sub": [abs(H[i + 1][i]) for i in range(n - 1)]})
        if keep_walks:
            walks.append(rec)
    block_ranges(H, R, tol)
    return H, R, U, V, sweeps, log, (f_ht, f_sweep), walks


def deflatable(H, i, tol):
    """Is H(i+1, i) negligible *relative to its own 2x2 neighbourhood*?

    A global-max tolerance is unreachable on a badly scaled pencil, which is why
    production codes compare a subdiagonal against the diagonals around it.
    """
    local = abs(H[i][i]) + abs(H[i + 1][i + 1]) + abs(H[i][i + 1])
    if local == 0.0:
        local = max(abs(v) for r in (H[i], H[i + 1]) for v in r)
    return abs(H[i + 1][i]) <= tol * local


def beta_small(R, i, tol):
    """Does row i of R carry a negligible beta, i.e. a multiplier at infinity?

    When the plant's A is singular, det N = 0 and the pencil has a multiplier at
    infinity, whose beta sits on R's diagonal at about 1e-17 of the pencil norm.
    Note what this is NOT: a licence to cut there.  Cutting a block means throwing
    away the Hessenberg subdiagonal at that position, and when that subdiagonal is
    genuinely significant the cut changes the spectrum -- it silently turns a 0 and
    an infinity into two wrong finite multipliers.  So the kernel only *detects* the
    case and refuses to sweep it; the infinite-multiplier deflation that LAPACK's
    DHGEQZ and the later FQZ codes do is out of scope here, and #s3 says so.
    """
    scale = maxabs(R)
    return scale == 0.0 or abs(R[i][i]) <= tol * scale


def block_ranges(H, R, tol):
    """Cut the pencil at every negligible subdiagonal (zeroing them in place)."""
    n = len(H)
    cuts = [i for i in range(n - 1) if deflatable(H, i, tol)]
    for i in cuts:
        H[i + 1][i] = 0.0
    out, start = [], 0
    for i in cuts:
        out.append((start, i + 1))
        start = i + 1
    out.append((start, n))
    return out


def bottom_block(H, R, tol, settled=()):
    """The bottom-most block that still needs work, or None when the pencil is done.

    The blocks are the cuts that block_ranges makes at negligible subdiagonals.  A 1x1
    is finished, and so is a 2x2 carrying one conjugate pair, because a *real* Schur
    form keeps such a pair whole; anything larger, and a 2x2 with two real
    multipliers, still needs a step.  `settled` is the set of block starts the caller
    already knows this kernel cannot reduce (an infinite multiplier), so that a
    degenerate corner ends the sweep loop instead of spinning in it.
    """
    for (i0, i1) in reversed(block_ranges(H, R, tol)):
        if i1 - i0 < 2 or i0 in settled:
            continue
        if i1 - i0 == 2 and trailing_pair_is_complex(H, R, i0):
            continue
        return (i0, i1)
    return None


def window_left(A, Q, i0, i1):
    """A[i0:i1, :] <- Q' A[i0:i1, :] : one sweep's left factor, over every column.

    The converged blocks above the active window share its columns, so a sweep
    changes them as well.
    """
    m, cols = i1 - i0, len(A[0])
    FLOPS[0] += 2 * m * m * cols
    new = [[sum(Q[k][i] * A[i0 + k][j] for k in range(m)) for j in range(cols)]
           for i in range(m)]
    for i in range(m):
        A[i0 + i][:] = new[i]


def window_right(A, Z, i0, i1):
    """A[:, i0:i1] <- A[:, i0:i1] Z : one sweep's right factor, over every row."""
    m, rows = i1 - i0, len(A)
    FLOPS[0] += 2 * m * m * rows
    for r in range(rows):
        snap = [A[r][i0 + j] for j in range(m)]
        for j in range(m):
            A[r][i0 + j] = sum(snap[k] * Z[k][j] for k in range(m))


def trailing_pair_is_complex(H, R, i0):
    """Do the two multipliers of the 2x2 block (i0, i0+1) form a conjugate pair?"""
    sh = pair_trace_det(H, R, i0)
    if sh is None:
        return True                        # a zero beta: treat it as settled
    tt, de = sh
    return tt * tt - 4 * de < 0.0


def chordal(p, q):
    """Chordal distance between homogeneous eigenvalues (alpha, beta)."""
    a1, b1 = p
    a2, b2 = q
    n1, n2 = math.hypot(a1, b1), math.hypot(a2, b2)
    if n1 == 0 or n2 == 0:
        return 0.0
    return abs(a1 * b2 - a2 * b1) / (n1 * n2)


def swap_pair(S, R, U, V, j, detail=None):
    """Exchange the 1x1 blocks in rows j and j+1 of a generalized Schur form.

    Right rotation first.  Inside the 2x2 window, multiplier 2's eigenvector is a
    null vector of beta2*S - alpha2*R, and for a singular 2x2 upper-triangular
    matrix that null vector is an adjugate column: the cross product
    (-(b2 s12 - a2 r12), b2 s11 - a2 r11).  No division, so nothing can blow up
    except when the two homogeneous pairs are proportional.  After the column mix,
    the new column j of S and of R are parallel, so one row rotation zeroes both
    subdiagonal entries at once and triangularity is restored.
    """
    a2, b2 = S[j + 1][j + 1], R[j + 1][j + 1]
    p = -(b2 * S[j][j + 1] - a2 * R[j][j + 1])
    q = b2 * S[j][j] - a2 * R[j][j]
    if detail is not None:
        detail["gap"] = chordal((S[j][j], R[j][j]), (a2, b2))
    ny = math.hypot(p, q)
    if ny == 0.0:
        return False
    # rot_cols puts col j0 -> c*col j0 - s*col j1, so the mix runs along (p, q) only
    # with this sign.
    c, s = p / ny, -q / ny
    rot_cols(S, c, s, j, j + 1)
    rot_cols(R, c, s, j, j + 1)
    rot_cols(V, c, s, j, j + 1)
    # The two matrices' new column j are parallel, so one row rotation, built from
    # S's own column, clears the subdiagonal of both at once.
    a, b = S[j][j], S[j + 1][j]
    r = math.hypot(a, b)
    if r == 0.0:
        return False
    cl, sl = a / r, b / r
    rot_rows(S, cl, sl, j, j + 1)
    rot_rows(R, cl, sl, j, j + 1)
    rot_cols_T(U, cl, sl, j, j + 1)
    S[j + 1][j] = 0.0
    R[j + 1][j] = 0.0
    return True


def sort_blocks(S, R, U, V, key, trace=None):
    """Bubble the diagonal blocks into key order, adjacent swaps only.

    Blocks are the unit of reordering: a 2x2 diagonal block is one conjugate pair
    and cannot be split.  Swapping a 1x1 with a 2x2 block needs a generalized
    Sylvester solve (LAPACK's DTGEXC), which this kernel does not implement, so it
    reports failure instead of corrupting the form.
    """
    swaps = 0
    for _ in range(4 * len(S) * len(S)):
        bl = blocks_of(S)
        ks = [key(S, R, b) for b in bl]
        inv = next((i for i in range(len(bl) - 1) if ks[i] > ks[i + 1]), None)
        if inv is None:
            return True, swaps
        if bl[inv][1] == 1 and bl[inv + 1][1] == 1:
            d = {}
            if not swap_pair(S, R, U, V, bl[inv][0], d):
                return False, swaps
            if trace is not None:
                trace.append(dict(at=inv, gap=d["gap"]))
            swaps += 1
        else:
            return False, swaps
    return False, swaps


def blocks_of(S, tol=1e-11):
    """Diagonal blocks of a real generalized Schur form: (start, size)."""
    n = len(S)
    out = []
    i = 0
    while i < n:
        if i + 1 < n and abs(S[i + 1][i]) > tol:
            out.append((i, 2))
            i += 2
        else:
            out.append((i, 1))
            i += 1
    return out


def modulus_key(S, R, blk):
    """Ordering key: spectral radius of the block's multipliers."""
    i, sz = blk
    if sz == 1:
        a, b = S[i][i], R[i][i]
        return abs(a / b) if abs(b) > 1e-300 else 1e300
    da = S[i][i] * S[i + 1][i + 1] - S[i][i + 1] * S[i + 1][i]
    db = R[i][i] * R[i + 1][i + 1] - R[i][i + 1] * R[i + 1][i]
    return math.sqrt(abs(da / db)) if abs(db) > 1e-300 else 1e300


def check(name, got, tol, extra=""):
    ok = got <= tol
    if not ok:
        BAD.append("%s: %.3e > %.1e" % (name, got, tol))
    print("  %-40s %10.3e %s %s" % (name, got, "ok" if ok else "FAIL", extra))
    return ok


def head(title):
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def mat_repr(A, label="", exact=True):
    if label:
        print("  " + label)
    for r in A:
        if exact:
            print("     " + "  ".join("%7s" % str(v) for v in r))
        else:
            print("     " + "  ".join("%14.8f" % float(v) for v in r))


def sigma_min(A):
    s = sigma_all(A)
    return s[-1] if s else 0.0


def sigma_max(A):
    s = sigma_all(A)
    return s[0] if s else 0.0


def sin_between(u, v):
    """|sin| of the angle between two vectors (scale-free)."""
    du = math.sqrt(sum(x * x for x in u))
    dv = math.sqrt(sum(x * x for x in v))
    ip = sum(u[i] * v[i] for i in range(len(u))) / (du * dv)
    return math.sqrt(max(0.0, 1.0 - ip * ip))


def cofactor_null(M):
    """Null vector of a rank-(n-1) matrix by Cramer: an adjugate column, in float.

    The textbook way to get one eigenvector of a pencil.  Row i of the cofactor matrix
    is column i of the adjugate, and M adj(M) = det(M) I, so when det(M) = 0 every
    *column of the adjugate* is a null vector of M; we take the longest one.  (Taking
    column j of the cofactor matrix instead gives a null vector of M', a left
    eigenvector, which is the easy mistake here and is not what a graph needs.)
    Cofactors are (n-1)x(n-1) determinants, so this route cancels exactly when the
    eigenvector is ill-determined -- which is the property being measured against QZ.
    """
    n = len(M)
    best, bestn = None, -1.0
    for i in range(n):
        col = []
        for j in range(n):
            Mi = [[M[r][c] for c in range(n) if c != j]
                  for r in range(n) if r != i]
            col.append(((-1) ** (i + j)) * det(Mi))
        nn = nrm(col)
        if nn > bestn:
            best, bestn = col, nn
    return [v / bestn for v in best]


# =========================================================================
# the running example (#s1, #s2) and the pipeline (#s4, #s5)
# =========================================================================
def running():
    """x_{k+1} = A x_k + b u_k, cost x'Qx + u^2 -- all rationals, answer P = I."""
    P = eye(2, F(1))
    M = [[F(0), F(1, 2)], [F(1, 2), F(0)]]
    G = [[F(1), F(1)], [F(1), F(1)]]
    A, Q = design(P, M, G)
    return dict(P=P, M=M, G=G, A=A, Q=Q, B=[[F(1)], [F(1)]], R=[[F(1)]])


def exact_spectrum(ex):
    """Exact multipliers of the pencil: (coefficients, values, number at infinity).

    det(L - zN) is a polynomial of degree *at most* 2n, and it really can lose
    degree: the coefficient of z^{2n} is det N, which vanishes when the plant's A
    does (Lancaster-Rodman: that is the pencil's way of announcing an eigenvalue at
    infinity).  The missing degree is reported separately instead of being divided
    away.  Each surviving candidate is snapped to a Fraction and then verified in
    rationals by det(L - zN) = 0, so nothing unverified reaches the page; None marks
    a multiplier that is not real.
    """
    L, N = pencil(ex["A"], ex["Q"], ex["G"])
    cs = pencil_poly(L, N)
    full = len(cs) - 1
    d = full
    while d > 0 and cs[d] == 0:
        d -= 1
    ninf = full - d                       # degree lost = multipliers at infinity
    if d == 0:
        return cs, [], full
    lead = cs[d]
    zs = roots([-float(cs[d - 1 - k] / lead) for k in range(d)])
    out = []
    for z in zs:
        f = F(z.real).limit_denominator(10 ** 7)
        if abs(z.imag) > 1e-7:
            out.append(None)
            continue
        out.append(f if det(add(L, scale(N, -f))) == 0 else None)
    return cs, out, ninf


def exact_mults(ex):
    """The finite exact multipliers, as (coefficients, values)."""
    cs, zs, _ = exact_spectrum(ex)
    return cs, zs


def selection(ex, zs):
    """Everything about one multiplier selection, in exact arithmetic."""
    L, N = pencil(ex["A"], ex["Q"], ex["G"])
    n = len(ex["A"])
    cols = [nullspace(add(L, scale(N, -z)), tol=0)[0] for z in zs]
    V = columnize(cols)
    V1, V2 = top_block(V, n), lower_block(V, n)
    X = mm(V2, inv(V1))
    Tm = diag(zs)
    K = gain(ex["A"], ex["B"], ex["R"], X)
    cl = eig(f64(add(ex["A"], scale(mm(ex["B"], K), -1))))
    return dict(V=V, X=X, sym=maxabs(add(X, tr(X), -1)),
                dres=deflating_res(L, N, V, Tm),
                rres=F_resid(ex, X), clmax=max(abs(z) for z in cl),
                detV1=det(V1), K=K,
                sinangle=sin_between(fvec(cols[0]), fvec(cols[1])) if n == 2 else None)


def graph_det(ex, zs):
    """Exact determinant of the top block of a selection's deflating basis.

    This is the quantity step 5 of the procedure tests: the selection is the graph of
    a matrix X if and only if it is nonzero, and in rationals it is exactly zero when
    the selection is not.
    """
    L, N = pencil(ex["A"], ex["Q"], ex["G"])
    n = len(ex["A"])
    V = columnize([nullspace(add(L, scale(N, -z)), tol=0)[0] for z in zs])
    return det(top_block(V, n))


def F_resid(ex, X):
    """DARE residual for an exact or float X."""
    return maxabs(dare_lhs(ex["A"], ex["B"], ex["Q"], ex["R"], X))


def eig(A):
    return roots(char_poly(A))


def char_poly(A):
    n = len(A)
    B = eye(n)
    cs = []
    for k in range(1, n + 1):
        AB = mm(A, B)
        c = sum(AB[i][i] for i in range(n)) / k
        cs.append(c)
        B = [[AB[i][j] - (c if i == j else 0.0) for j in range(n)]
             for i in range(n)]
    return cs


def roots(cs):
    """Roots of z^n - cs[0] z^(n-1) - ... - cs[n-1] by Durand-Kerner."""
    n = len(cs)
    zs = [(0.4 + 0.9j) ** (k + 1) for k in range(n)]
    for _ in range(800):
        new = []
        for i in range(n):
            num, den = polyval(cs, zs[i]), 1 + 0j
            for j in range(n):
                if j != i:
                    den *= zs[i] - zs[j]
            new.append(zs[i] - num / (den if den != 0 else 1e-30))
        zs = new
    return zs


def polyval(cs, z):
    v = 1 + 0j
    for c in cs:
        v = v * z - c
    return v


def solve_dare_qz(ex, sort_key=None, trace=None, keep_walks=True, max_sweeps=600):
    """The whole orthogonal route in double precision.  Returns a dict of results."""
    A, Q, G = f64(ex["A"]), f64(ex["Q"]), f64(ex["G"])
    B, R = f64(ex["B"]), f64(ex["R"])
    n = len(A)
    L, N = pencil(A, Q, G)
    S, Rr, U, V, sweeps, log, flops, walks = qz_schur(L, N, max_sweeps=max_sweeps,
                                                      keep_walks=keep_walks)
    pairs0 = [(S[i][i], Rr[i][i]) for i in range(2 * n)]
    ok, swaps = sort_blocks(S, Rr, U, V,
                            sort_key or modulus_key,
                            trace=trace)
    pairs = [(S[i][i], Rr[i][i]) for i in range(2 * n)]
    V1 = [[V[i][j] for j in range(n)] for i in range(2 * n)]
    V11 = [r[:n] for r in V1[:n]]
    V21 = [r[:n] for r in V1[n:]]
    X = mm(V21, inv(V11))
    S11 = [[S[i][j] for j in range(n)] for i in range(n)]
    R11 = [[Rr[i][j] for j in range(n)] for i in range(n)]
    Tm = mm(inv(R11), S11)                      # A V1 = B V1 T with T = R11^-1 S11
    Lfull, Nfull = pencil(f64(ex["A"]), f64(ex["Q"]), f64(ex["G"]))
    return dict(S=S, R=Rr, U=U, V=V, V1=V1, X=X, ok=ok, sweeps=sweeps, swaps=swaps,
                log=log, flops=flops, pairs0=pairs0, pairs=pairs, Tm=Tm,
                defres=maxabs(add(mm(Lfull, V1),
                                  scale(mm(Nfull, mm(V1, Tm)), -1))),
                r11det=abs(det(R11)), v1det=abs(det(V11)),
                bw=maxabs(add(mm(tr(U), mm(L, V)), S, -1)),
                bw2=maxabs(add(mm(tr(U), mm(N, V)), Rr, -1)),
                ortho=max(orth_err(U), orth_err(V)),
                tri=max((abs(S[i][j]) for i in range(2 * n)
                         for j in range(2 * n) if i > j + 1), default=0.0),
                triR=max((abs(Rr[i][j]) for i in range(2 * n)
                          for j in range(2 * n) if i > j), default=0.0),
                sym=maxabs(add(X, tr(X), -1)),
                dres=maxabs(dare_lhs(A, B, Q, R, X)),
                kerr=(maxabs(add(X, f64(ex["P"]), -1)) if "P" in ex else None),
                condV1=cond2(V11))


def doubling(ex, iters=8):
    """Plain DARE fixed-point (the cheap ancestor of the SDA note's doubling)."""
    A, B, Q, R = f64(ex["A"]), f64(ex["B"]), f64(ex["Q"]), f64(ex["R"])
    n = len(A)
    P = eye(n, 0.0)
    out = []
    for k in range(iters):
        P = add(dare_lhs(A, B, Q, R, P), P)      # lhs = A'PA - ... + Q - P
        out.append((k + 1, maxabs(add(P, f64(ex["P"]), -1))))
    return P, out


def symplectic(A, Q, G):
    """The matrix form of the same recurrence, N^-1 L: needs N invertible."""
    L, N = pencil(A, Q, G)
    return mm(inv(N), L)


def pair_error(zs):
    """How far the spectrum is from the exact lambda <-> 1/lambda pairing."""
    order = sorted(zs, key=lambda z: -abs(z))
    m = len(order)
    return max((abs(order[i] * order[m - 1 - i] - 1) for i in range(m // 2)),
               default=0.0)


def design_float(P, M, G):
    n = len(P)
    A = mm(add(eye(n, 1.0), mm(G, P)), M)
    Q = add(P, scale(mm(mm(tr(A), P), M), -1))
    return A, Q


# =========================================================================
# self-test: the kernels must be orthogonal equivalences that preserve pencils
# =========================================================================
def rand_case(n, seed):
    rng = random.Random(seed)
    # diagonally dominant symmetric => positive definite, so the graph of P really
    # is the stabilizing subspace and the test can compare against it
    L = [[(rng.uniform(2.0, 4.0) if i == j else rng.uniform(-0.4, 0.4))
          for j in range(i + 1)] for i in range(n)]
    L = [[L[i][j] if j <= i else L[j][i] for j in range(n)] for i in range(n)]
    P = L
    bcol = [[rng.choice([-1.0, 1.0])] for _ in range(n)]
    G = mm(bcol, tr(bcol))
    # lower triangular with a real diagonal: then the pencil spectrum is real and
    # the 1x1-only kernel in sort_blocks is the one being exercised.  The diagonal
    # entries are sampled from a separated set on purpose: they are the pencil's
    # stable multipliers (and 1/mu the unstable ones), and two nearly coincident
    # multipliers make even the *idea* of a single eigenvector ill-posed, which is a
    # different question -- see the note's section on changed conditions.
    diags = rng.sample([0.30, 0.42, 0.55, 0.68, 0.79, 0.88], n)
    M = [[(diags[i] if i == j else
           (rng.uniform(-0.5, 0.5) if j < i else 0.0)) for j in range(n)]
         for i in range(n)]
    A, Q = design_float(P, M, G)
    return dict(A=f64(A), Q=f64(Q), G=f64(G), B=f64(bcol), R=[[1.0]], P=f64(P))


def selftest():
    head("SELFTEST   kernels on random pencils (n = 3..6, 8 cases)")
    W = {}

    def worst(tag, val):
        W[tag] = max(W.get(tag, 0.0), val)

    for seed in range(8):
        n = (seed % 4) + 3
        c = rand_case(n, seed)
        L, N = pencil(c["A"], c["Q"], c["G"])
        m = 2 * n
        H, R, U, V, _ = ht_reduce(L, N)
        sc = 1.0 + maxabs(H) + maxabs(R)
        worst("ht below-Hessenberg", max((abs(H[i][j]) for i in range(m)
                                         for j in range(m) if i > j + 1),
                                        default=0.0) / sc)
        worst("ht R not triangular", max((abs(R[i][j]) for i in range(m)
                                          for j in range(m) if i > j),
                                         default=0.0) / sc)
        worst("ht equivalence L", maxabs(add(mm(tr(U), mm(L, V)), H, -1)) / sc)
        worst("ht equivalence N", maxabs(add(mm(tr(U), mm(N, V)), R, -1)) / sc)
        worst("ht orthogonality", max(orth_err(U), orth_err(V)))
        S, R2, U2, V2, sw, log, fl, _ = qz_schur(L, N)
        sc = 1.0 + maxabs(S) + maxabs(R2)
        worst("qz below-band", max((abs(S[i][j]) for i in range(m)
                                    for j in range(m) if i > j + 1),
                                   default=0.0) / sc)
        worst("qz sweeps<400", 0.0 if sw < 399 else 1.0)
        worst("qz equivalence L", maxabs(add(mm(tr(U2), mm(L, V2)), S, -1)) / sc)
        worst("qz equivalence N", maxabs(add(mm(tr(U2), mm(N, V2)), R2, -1)) / sc)
        worst("qz orthogonality", max(orth_err(U2), orth_err(V2)))
        trace = []
        mods0 = sorted(moduli(S, R2))
        ok, nsw = sort_blocks(S, R2, U2, V2, modulus_key, trace=trace)
        worst("reorder succeeded", 0.0 if ok else 1.0)
        sc = 1.0 + maxabs(S) + maxabs(R2)
        worst("reorder equivalence", maxabs(add(mm(tr(U2), mm(L, V2)), S, -1)) / sc)
        worst("reorder equivalence N", maxabs(add(mm(tr(U2), mm(N, V2)), R2, -1)) / sc)
        worst("reorder orthogonality", max(orth_err(U2), orth_err(V2)))
        worst("reorder below-band", max((abs(S[i][j]) for i in range(m)
                                        for j in range(m) if i > j + 1),
                                       default=0.0) / sc)
        mods = moduli(S, R2, ordered=True)
        # how much the diagonal order *descends* anywhere: 0 when it is ascending
        worst("reorder ascending", max((max(0.0, mods[i] - mods[i + 1])
                                        for i in range(len(mods) - 1)), default=0.0))
        worst("reorder keeps spectrum", max(abs(a - b) for a, b in
                                           zip(mods0, sorted(mods))))
        X = mm([r[:n] for r in V2[n:]], inv([r[:n] for r in V2[:n]]))
        nx = max(1.0, maxabs(X))
        worst("X symmetric", maxabs(add(X, tr(X), -1)) / nx)
        worst("X solves DARE", maxabs(dare_lhs(c["A"], c["B"], c["Q"], c["R"], X)) / nx)
        worst("X is the stabilizing one", maxabs(add(X, c["P"], -1)) / nx)
        Mx = add(c["A"], scale(mm(c["B"], gain(c["A"], c["B"], c["R"], X)), -1))
        worst("closed loop inside disk",
              max(0.0, max(abs(z) for z in eig(Mx)) - 1.0))
    for tag in sorted(W):
        check(tag, W[tag], 3e-12)
    print("  self-test verdict:", "PASS" if not BAD else "FAIL " + "; ".join(BAD))
    return not BAD


def moduli(S, R, ordered=False):
    """Moduli of the multipliers of a (quasi-)triangular pencil, block by block.

    ordered=True keeps the order the diagonal blocks appear in, which is what an
    ordering check needs; the default sorts them.
    """
    out = []
    for i, sz in blocks_of(S):
        if sz == 1:
            out.append(abs(S[i][i] / R[i][i]) if abs(R[i][i]) > 1e-300
                       else float('inf'))
        else:
            zs = pair_roots(S, R, i)
            out += [abs(z) for z in zs]
    return out if ordered else sorted(out)


def pair_roots(S, R, i):
    """The two multipliers of a 2x2 diagonal block, as complex numbers."""
    a11, a12 = S[i][i], S[i][i + 1]
    a21, a22 = S[i + 1][i], S[i + 1][i + 1]
    r11, r12, r22 = R[i][i], R[i][i + 1], R[i + 1][i + 1]
    m11, m21 = a11 / r11, a21 / r11
    m12 = a12 / r22 - a11 * r12 / (r11 * r22)
    m22 = a22 / r22 - a21 * r12 / (r11 * r22)
    tt, de = m11 + m22, m11 * m22 - m12 * m21
    sq = cmath.sqrt(tt * tt - 4 * de)
    return [(tt + sq) / 2, (tt - sq) / 2]


# =========================================================================
# report blocks: one per page section.  Every number the note prints comes
# from here, so the note quotes only output that this script reproduces.
# =========================================================================
def fs(x):
    """Short exact-rational string."""
    return str(x)


def pick_selections(ex):
    """Every choice of n multipliers out of 2n, solved in exact rationals.

    Returns (coefficients of det(L - zN) ascending, multipliers, rows) where a row
    is (indices, chosen multipliers, solution dict or a reason string).
    """
    from itertools import combinations
    cs, zs = exact_mults(ex)
    n = len(ex["A"])
    rows = []
    for pick in combinations(range(len(zs)), n):
        sel = [zs[i] for i in pick]
        if any(z is None for z in sel):
            rows.append((pick, sel, "non-real multiplier"))
            continue
        try:
            rows.append((pick, sel, selection(ex, sel)))
        except ZeroDivisionError:
            rows.append((pick, sel, "not a graph: det V1 = %s exactly"
                         % fs(graph_det(ex, sel))))
    return cs, zs, rows


def cdist(z, w):
    """Chordal distance between two multipliers, complex allowed."""
    return abs(z - w) / (math.hypot(1.0, abs(z)) * math.hypot(1.0, abs(w)))


def block_multipliers(S, R):
    """The pencil's multipliers, grouped by the diagonal block that carries them."""
    out = []
    for i, sz in blocks_of(S):
        if sz == 1:
            b = R[i][i]
            out.append([complex(S[i][i] / b) if abs(b) > 1e-300 else complex(1e300)])
        else:
            out.append(pair_roots(S, R, i))
    return out


def block_gap(S, R):
    """Tightest chordal distance between multipliers the form keeps in different blocks.

    This is the gap a split or a swap has to be able to resolve: multipliers inside
    one 2x2 block are not separated by anything, so they do not count here.
    """
    sets = block_multipliers(S, R)
    return min([cdist(z, w) for a in range(len(sets))
                for b in range(a + 1, len(sets))
                for z in sets[a] for w in sets[b]], default=0.0)


def sym_basis(n):
    """Frobenius-orthonormal basis of the symmetric n x n matrices."""
    out = []
    for i in range(n):
        for j in range(i, n):
            D = [[0.0] * n for _ in range(n)]
            D[i][j] = 1.0
            if i != j:
                D[j][i] = 1.0
            nr = math.sqrt(sum(v * v for r in D for v in r))
            out.append([[v / nr for v in r] for r in D])
    return out


def riccati_map(ex, X):
    """One step of the DARE fixed-point map X -> Q + A'X(I+GX)^-1 A, in float."""
    A, B, Q, R = f64(ex["A"]), f64(ex["B"]), f64(ex["Q"]), f64(ex["R"])
    return add(dare_lhs(A, B, Q, R, X), X)


def linearized_map(ex):
    """The Riccati map's derivative at the answer, by central differences.

    Its spectrum is the set of products of closed-loop multipliers, which is what
    decides the ratio a fixed-point iteration settles into.  Computed rather than
    quoted so the page can put the observed ratio next to the predicted one.
    """
    D = sym_basis(len(ex["P"]))
    P = f64(ex["P"])
    h = 1e-6
    J = [[0.0] * len(D) for _ in D]
    for jd, Dj in enumerate(D):
        diff = [[(riccati_map(ex, add(P, scale(Dj, h)))[i][j]
                  - riccati_map(ex, add(P, scale(Dj, -h)))[i][j]) / (2 * h)
                 for j in range(len(Dj))] for i in range(len(Dj))]
        for id, Di in enumerate(D):
            J[id][jd] = sum(Di[i][j] * diff[i][j]
                            for i in range(len(Di)) for j in range(len(Di)))
    return J, eig(J)


def r_s1():
    head("#s1   the plant, the cost, and the answer the note chases")
    ex = running()
    mat_repr(ex["A"], "A   (x_{k+1} = A x_k + B u_k)")
    mat_repr(ex["Q"], "Q   (state cost, symmetric but NOT diagonal)")
    mat_repr(ex["G"], "G = B R^-1 B'  with B = [1;1], R = [1]")
    print("  designed from P = I and closed loop M =")
    mat_repr(ex["M"])
    print("  DARE residual at X = P, in rationals:", F_resid(ex, ex["P"]))
    print("  open-loop eigenvalues of A:",
          ["%.4f" % z.real for z in eig(f64(ex["A"]))])
    K = gain(ex["A"], ex["B"], ex["R"], ex["P"])
    print("  gain K = (R+B'XB)^-1 B'XA at X = P:  [[%s, %s]]" % (K[0][0], K[0][1]))
    CL = add(ex["A"], scale(mm(ex["B"], K), -1))
    print("  closed loop A - BK = M:", CL == ex["M"],
          ["%s" % fs(v) for r in CL for v in r])
    print("  multipliers of the closed loop:", ["%s" % fs(z) for z in eig(ex["M"])])
    return ex


def r_s2(ex=None):
    head("#s2   the pencil, its spectrum, and the solutions it hides")
    ex = ex or running()
    L, N = pencil(ex["A"], ex["Q"], ex["G"])
    mat_repr(L, "pencil L = [A 0; -Q I]")
    mat_repr(N, "pencil N = [I G; 0 A']")
    print("  det L = %s   det N = %s   det A = %s" % (det(L), det(N), det(ex["A"])))
    cs, zs, rows = pick_selections(ex)
    print("  det(L - z N) = " + poly_repr(cs))
    monic = [c / cs[len(cs) - 1] for c in cs]
    print("  divided by the leading coefficient: " + poly_repr(monic))
    # the factorisation is expanded back and compared with the pencil's own
    # polynomial, so the page quotes a checked identity rather than a typed one
    p1 = poly_mul([F(-1), F(0), F(4)], [F(-4), F(0), F(1)])
    p2 = poly_mul(poly_mul([F(-1, 2), F(1)], [F(1, 2), F(1)]),
                  poly_mul([F(-2), F(1)], [F(2), F(1)]))
    p2 = [F(4) * c for c in p2]
    scaled = [F(-16, 3) * c for c in cs]
    print("  multiplied by -16/3:  4z^4 - 17z^2 + 4 = (4z^2 - 1)(z^2 - 4)"
          " = 4(z - 1/2)(z + 1/2)(z - 2)(z + 2)")
    print("  expanded back: (4z^2-1)(z^2-4) -> " + poly_repr(p1))
    print("                 4*prod(z-z_i)   -> " + poly_repr(p2))
    print("                 -16/3*det(L-zN)  -> " + poly_repr(scaled))
    print("  the three agree exactly:", p1 == p2 == scaled)
    print("  multipliers:", [fs(z) for z in zs])
    print("  reciprocal pairing:", [(fs(z), fs(1 / z)) for z in zs])
    print("  graph identity:  L [I;X] = N [I;X] T   <=>   A = (I+GX)T  and  X = A'XT + Q")
    print("\n  every choice of 2 multipliers out of 4, solved in exact arithmetic:")
    print("  %-10s %-16s %-10s %-9s %-8s %s" %
          ("choice", "multipliers", "symmetric", "max|T|", "residual", "X"))
    for pick, sel, s in rows:
        lab = "{%s}" % ",".join(fs(z) for z in sel)
        if not isinstance(s, dict):
            print("  %-10s %-16s %s" % (",".join(str(i) for i in pick), lab, s))
            continue
        xs = " ".join("[%s %s]" % (fs(r[0]), fs(r[1])) for r in s["X"])
        print("  %-10s %-16s %-10s %-9.4g %-8s %s" %
              (",".join(str(i) for i in pick), lab,
               "yes" if s["sym"] == 0 else "no", s["clmax"], s["rres"], xs))
    return dict(cs=cs, zs=zs, rows=rows)


def ill_cond_family(cval):
    """P = I, M = [[1/2, c],[0, 49/100]], G = ones: multipliers fixed, vectors worse.

    The closed loop keeps the same two multipliers for every c, because M stays
    lower triangular; only its eigenvector directions change.  So c measures the
    conditioning of the deflating subspaces while the answer X = P stays put.
    """
    P = eye(2, F(1))
    M = [[F(1, 2), F(cval)], [F(0), F(49, 100)]]
    G = [[F(1), F(1)], [F(1), F(1)]]
    A, Q = design(P, M, G)
    return dict(A=A, Q=Q, G=G, B=[[F(1)], [F(1)]], R=[[F(1)]], P=P, M=M)


def singular_plant():
    """P = I, M = [[1/4,1/4],[1/4,1/4]]: a dead-beat mode, so det A = 0."""
    P = eye(2, F(1))
    M = [[F(1, 4), F(1, 4)], [F(1, 4), F(1, 4)]]
    G = [[F(1), F(1)], [F(1), F(1)]]
    A, Q = design(P, M, G)
    return dict(A=A, Q=Q, G=G, B=[[F(1)], [F(1)]], R=[[F(1)]], P=P, M=M)


def r_s3():
    head("#s3   why eigenvectors one at a time are the wrong tool")
    ex = running()
    L, N = pencil(ex["A"], ex["Q"], ex["G"])
    print("  the matrix form would need N^-1:  det N = %s (so it exists for this plant)"
          % det(N))
    es = singular_plant()
    Ls, Ns = pencil(es["A"], es["Q"], es["G"])
    print("  (a) singular plant: det A = %s, det N = %s, det L = %s"
          % (det(es["A"]), det(Ns), det(Ls)))
    print("      N^-1 L does not exist; the pencil still does")
    mat_repr(es["A"], "      A")
    mat_repr(es["Q"], "      Q  (positive definite, det = %s)" % det(es["Q"]))
    cs, zs, ninf = exact_spectrum(es)
    print("      det(L - zN) = " + poly_repr(cs))
    print("      degree %d instead of 4 -> %d multiplier(s) at infinity"
          % (len(cs) - 1 - ninf, ninf))
    print("      finite multipliers:", [fs(z) for z in zs])
    try:
        sol = solve_dare_qz(es, keep_walks=False, max_sweeps=2000)
        print("      orthogonal route: sweeps=%d reordered=%s  |X-P| = %.3e res = %.3e"
              % (sol["sweeps"], sol["ok"], sol["kerr"], sol["dres"]))
        print("      |z| after ordering:",
              ["%.4g" % m for m in moduli(sol["S"], sol["R"])])
    except ValueError as err:
        print("      orthogonal route as implemented here: refuses, %s" % err)
        print("      (an infinite multiplier needs its own deflation test; out of scope)")
    # what the pencil itself says, in rationals: the stable pair is still a graph
    stable = sorted([z for z in zs if z is not None and abs(z) < 1], key=abs)[:2]
    s = selection(es, stable)
    print("      exact arithmetic on the pair %s: |X - P| = %s, DARE residual = %s"
          % ([fs(z) for z in stable],
             maxabs(add(s["X"], es["P"], -1)), s["rres"]))
    print("      deflating identity for that basis: max|L V - N V T| = %s" % s["dres"])
    print("  (b) same multipliers, worse eigenvectors: M = [[1/2, c],[0, 49/100]]")
    print("  %6s %11s %12s %13s %13s %11s %11s %11s" %
          ("c", "kappa(V4)", "sin(all)", "|X_cof-I|", "|X_qz-I|", "sin(graph)",
           "cond(V11)", "eps/sin"))
    out = []
    for cval in [0, 1, 3, 10, 30, 100]:
        e = ill_cond_family(cval)
        Lf, Nf = pencil(e["A"], e["Q"], e["G"])
        cs3, zs3 = exact_mults(e)
        cols = [nullspace(add(Lf, scale(Nf, -z)), tol=0)[0] for z in zs3]
        V4 = f64(columnize(cols))
        kap = cond2(V4)
        ss = min(sin_between(fvec(cols[i]), fvec(cols[j]))
                 for i in range(4) for j in range(i + 1, 4))
        # the two stable multipliers, which is the pair the gain actually needs
        want = sorted(zs3, key=abs)[:2]
        idx = [zs3.index(z) for z in want]
        cof = [cofactor_null(f64(add(Lf, scale(Nf, -float(z))))) for z in want]
        Vc = [[cof[0][i], cof[1][i]] for i in range(4)]
        try:
            Xc = mm([r[:2] for r in Vc[2:]], inv([r[:2] for r in Vc[:2]]))
            ec = maxabs(add(Xc, f64(e["P"]), -1))
        except ZeroDivisionError:
            ec = float("nan")
        sq = solve_dare_qz(e, keep_walks=False)
        s12 = sin_between(fvec(cols[idx[0]][:2]), fvec(cols[idx[1]][:2]))
        print("  %6d %11.3e %12.3e %13.3e %13.3e %11.3e %11.3e %11.3e" %
              (cval, kap, ss, ec, sq["kerr"], s12, sq["condV1"], EPS0 / s12))
        out.append(dict(c=cval, kappa=kap, sin_all=ss, cof=ec, qz=sq["kerr"],
                        sin12=s12, condV1=sq["condV1"], sym=float(sq["sym"]),
                        floor=EPS0 / s12, dres=float(sq["dres"])))
    print("      X = I is the answer for every c; kappa(V4) is the eigenvector matrix")
    print("      of the whole 4x4 pencil, sin(all) the tightest angle between any two")
    print("      deflating vectors, sin(graph) the angle between the two top halves of")
    print("      the two stable deflating vectors, cond(V11) the condition of the block")
    print("      that both routes have to invert (it is 1 here because X = I forces")
    print("      V21 = V11 and V is orthogonal), eps/sin = EPS0/sin(graph) the floor")
    print("      that any subspace-based route must sit at or above")
    print("      read them together: the two error columns grow like 1/sin(graph) while")
    print("      cond(V11) stays at 1, so the amplification is the problem's own, not the")
    print("      inversion's.  Both routes pay it (constants differ, and here the")
    print("      cofactor one is the smaller); what only the pencil route avoids is")
    print("      forming N^-1 L and its eigenvector matrix -- and when det N = 0 that")
    print("      step is not even defined (part (a)).")
    return out


def r_s4(ex=None):
    head("#s4   the pencil walking through the three forms")
    ex = ex or running()
    n = len(ex["A"])
    m = 2 * n
    L, N = pencil(f64(ex["A"]), f64(ex["Q"]), f64(ex["G"]))
    H, Rr, U, V, f_ht = ht_reduce(L, N)
    sc = 1.0 + maxabs(H) + maxabs(Rr)
    print("  stage 1  dense pair -> Hessenberg-triangular   (%.0f multiply-add units)"
          % f_ht)
    mat_repr(H, "  H", exact=False)
    mat_repr(Rr, "  T", exact=False)
    print("     U'L V - H = %.2e   U'N V - T = %.2e   orthogonality %.2e   below-band %.2e"
          % (maxabs(add(mm(tr(U), mm(L, V)), H, -1)) / sc,
             maxabs(add(mm(tr(U), mm(N, V)), Rr, -1)) / sc,
             max(orth_err(U), orth_err(V)),
             max((abs(H[i][j]) for i in range(m) for j in range(m) if i > j + 1),
                 default=0.0) / sc))
    S, R2, U2, V2, sw, log, fl, walks = qz_schur(L, N)
    sc = 1.0 + maxabs(S) + maxabs(R2)
    print("  stage 2  Francis sweeps -> generalized real Schur form (%d sweeps, "
          "%.0f units)" % (sw, fl[1]))
    mat_repr(S, "  S", exact=False)
    mat_repr(R2, "  R", exact=False)
    print("     diagonal multipliers alpha/beta:")
    for i in range(m):
        print("        z_%d = %+.8f" % (i, S[i][i] / R2[i][i]))
    print("     equivalence %.2e %.2e   orthogonality %.2e   R subdiagonal %.2e"
          % (maxabs(add(mm(tr(U2), mm(L, V2)), S, -1)) / sc,
             maxabs(add(mm(tr(U2), mm(N, V2)), R2, -1)) / sc,
             max(orth_err(U2), orth_err(V2)),
             max((abs(R2[i + 1][i]) for i in range(m - 1)), default=0.0) / sc))
    print("     sweep log (block, shift trace/det, smallest |subdiag| in block):")
    for e in log:
        i0, i1 = e["block"]
        subs = [e["sub"][i] for i in range(i0, i1 - 1)] or [0.0]
        print("       %2d  rows %d-%d  shift (%+.6f, %+.6f)  min sub %.3e%s" %
              (e["sweep"], i0, i1 - 1, e["shift"][0] if e["shift"] else 0.0,
               e["shift"][1] if e["shift"] else 0.0, min(subs),
               "  [split]" if e.get("split") else ""))
    print("     deflating-subspace identity, exact arithmetic, per admissible choice:")
    cs, zs, rows = pick_selections(ex)
    for pick, sel, s in rows:
        if isinstance(s, dict):
            print("        {%s}: max|L V - N V T| = %s   (basis from rationals)" %
                  (",".join(fs(z) for z in sel), s["dres"]))
    trace = []
    ok, nsw = sort_blocks(S, R2, U2, V2, modulus_key, trace=trace)
    sc = 1.0 + maxabs(S) + maxabs(R2)
    print("  stage 3  ordering the blocks (ascending |z|): %d adjacent swaps, ok=%s"
          % (nsw, ok))
    mat_repr(S, "  S reordered", exact=False)
    mat_repr(R2, "  R reordered", exact=False)
    print("     chordal gap crossed by each swap (this is what reordering costs):")
    for i, t in enumerate(trace):
        print("        swap %d at rows %d: gap %.6f" % (i, t["at"], t["gap"]))
    print("     equivalence %.2e %.2e  orthogonality %.2e" %
          (maxabs(add(mm(tr(U2), mm(L, V2)), S, -1)) / sc,
           maxabs(add(mm(tr(U2), mm(N, V2)), R2, -1)) / sc,
           max(orth_err(U2), orth_err(V2))))
    S11 = [[S[i][j] for j in range(n)] for i in range(n)]
    R11 = [[R2[i][j] for j in range(n)] for i in range(n)]
    V11 = [r[:n] for r in V2[:n]]
    V21 = [r[:n] for r in V2[n:]]
    Tm = mm(inv(R11), S11)
    print("  the two invertibility tests the Claim needs: |det R11| = %.3e, "
          "|det V11| = %.3e" % (abs(det(R11)), abs(det(V11))))
    print("  T = R11^-1 S11:", ["%+.8f" % v for r in Tm for v in r])
    # T is the closed loop written in the QZ's own orthonormal basis, M in the graph
    # basis: comparing them entrywise would be a category error.  Change basis first.
    Tg = mm(mm(V11, Tm), inv(V11))
    print("  the same operator in the graph basis, V11 T V11^-1:",
          ["%+.8f" % v for r in Tg for v in r])
    print("  the closed loop it was designed from:",
          ["%s" % fs(v) for r in ex["M"] for v in r])
    print("  |V11 T V11^-1 - M| = %.3e   (basis change matters: |T - M| entrywise is "
          "%.3e and means nothing)"
          % (maxabs(add(Tg, f64(ex["M"]), -1)), maxabs(add(Tm, f64(ex["M"]), -1))))
    GX = add(eye(n, 1.0), mm(f64(ex["G"]), mm(V21, inv(V11))))
    print("  graph identity A = (I+GX) T, in the graph basis: |A - (I+GX) V11 T V11^-1| "
          "= %.3e" % maxabs(add(f64(ex["A"]), mm(GX, Tg), -1)))
    print("  X = V21 V11^-1:", ["%+.10f" % v for r in mm(V21, inv(V11)) for v in r])
    return dict(stages=[(H, Rr), (S, R2)], log=log, trace=trace, sweeps=sw,
                swaps=nsw, ok=ok, Tm=Tm, f_ht=fl[0], f_sw=fl[1])


def scaled_case(n, seed=1):
    """A backwards-designed DARE of order n whose multipliers are separated.

    Used for the cost table only: P diagonally dominant (so it is the stabilizing
    solution), closed loop lower triangular with a spread-out diagonal, one input.
    """
    rng = random.Random(seed)
    Ld = [[(2.5 + 0.1 * i if i == j else rng.uniform(-0.4, 0.4))
           for j in range(i + 1)] for i in range(n)]
    Ld = [[Ld[i][j] if j <= i else Ld[j][i] for j in range(n)] for i in range(n)]
    P = Ld
    b = [[1.0] for _ in range(n)]
    G = mm(b, tr(b))
    M = [[(0.30 + 0.02 * i if i == j else
           (rng.uniform(-0.5, 0.5) if j < i else 0.0)) for j in range(n)]
         for i in range(n)]
    A, Q = design_float(P, M, G)
    return dict(A=A, Q=Q, G=G, B=b, R=[[1.0]], P=P)


def selection_key(chosen, tol=1e-4):
    """Ordering key that floats a chosen set of multipliers into the leading block.

    This is how the page's demo walks all C(2n, n) selections: it needs an ordering
    of the diagonal blocks, not a modulus, so the key answers "is every multiplier
    of this block one of the chosen ones".
    """
    want = [complex(float(z)) for z in chosen]

    def key(S, R, blk):
        i, sz = blk
        if sz == 1:
            zs = [S[i][i] / R[i][i] if abs(R[i][i]) > 1e-300 else 1e300]
        elif sz == 2:
            zs = pair_roots(S, R, i)
        else:
            return 1e300
        for z in zs:
            if min(abs(complex(z) - w) for w in want) > tol * max(1.0, abs(z)):
                return 1.0
        return 0.0
    return key


def r_s5(ex=None):
    head("#s5   the whole procedure, its answer, and what it costs")
    ex = ex or running()
    sol = solve_dare_qz(ex)
    n = len(ex["A"])
    print("  pipeline on the running example (%dx%d pencil)" % (2 * n, 2 * n))
    print("     sweeps=%d (%d exceptional shifts, %d block splits)  swaps=%d" %
          (sol["sweeps"], sum(1 for e in sol["log"] if e.get("exc")),
           sum(1 for e in sol["log"] if e.get("split")), sol["swaps"]))
    print("     multiply-add units: Hessenberg-triangular %.0f, sweeps %.0f" %
          (sol["flops"][0], sol["flops"][1]))
    print("     equivalence errors %.2e %.2e   orthogonality %.2e" %
          (sol["bw"], sol["bw2"], sol["ortho"]))
    print("     |det R11| = %.3e   |det V11| = %.3e   cond(V11) = %.3e" %
          (sol["r11det"], sol["v1det"], sol["condV1"]))
    print("     X from the reordered deflating subspace:")
    mat_repr(sol["X"], exact=False)
    print("     |X - P| = %.3e   DARE residual = %.3e   |X - X'| = %.3e" %
          (sol["kerr"], sol["dres"], sol["sym"]))
    K = gain(f64(ex["A"]), f64(ex["B"]), f64(ex["R"]), sol["X"])
    print("     gain K = [[%.8f, %.8f]]   (exact answer [1/2, 1/2])"
          % (K[0][0], K[0][1]))
    CL = add(f64(ex["A"]), scale(mm(f64(ex["B"]), K), -1))
    print("     closed-loop |z| = %s   (open-loop |z| = %s)" %
          (["%.6f" % abs(z) for z in eig(CL)],
           ["%.4f" % abs(z) for z in eig(f64(ex["A"]))]))
    print("\n  cost, as counted multiply-add units on the 2n x 2n pencil")
    print("  %4s %7s %8s %11s %12s %8s %11s %9s" %
          ("n", "pencil", "sweeps", "HT units", "sweep units", "swaps", "|X-P|", "secs"))
    costs = []
    for nn in (2, 3, 4, 6, 8, 12, 16, 20):
        c = running() if nn == 2 else scaled_case(nn, 11)
        t0 = time.perf_counter()
        s = solve_dare_qz(c, keep_walks=False, max_sweeps=40 * nn)
        dt = time.perf_counter() - t0
        print("  %4d %7d %8d %11.0f %12.0f %8d %11.2e %9.2f" %
              (nn, 2 * nn, s["sweeps"], s["flops"][0], s["flops"][1], s["swaps"],
               s["kerr"], dt))
        costs.append(dict(n=nn, sweeps=s["sweeps"], ht=s["flops"][0],
                          sw=s["flops"][1], swaps=s["swaps"], kerr=s["kerr"],
                          secs=dt, ok=s["ok"]))
    print("     every row above converged: sweeps below the cap of 40 per pencil order, "
          "ok=%s" % all(c["ok"] for c in costs))
    print("\n  where this kernel stops: the same family at n = 24 (48x48 pencil)")
    t0 = time.perf_counter()
    s24 = solve_dare_qz(scaled_case(24, 11), keep_walks=False, max_sweeps=40 * 24)
    dt24 = time.perf_counter() - t0
    print("     sweeps=%d of the %d cap, swaps=%d, ok=%s, |X-P| = %.3e (%.1f s)"
          % (s24["sweeps"], 40 * 24, s24["swaps"], s24["ok"], s24["kerr"], dt24))
    print("     blocks left standing: %s   (block sizes, smallest cross-block gap %.2e)"
          % ([sz for _, sz in blocks_of(s24["S"])], block_gap(s24["S"], s24["R"])))
    print("     this kernel has no aggressive early deflation, so a stalled interior")
    print("     block costs the whole pencil a sweep; LAPACK's DGGES + DTGEXC is the")
    print("     production answer and is what the counts here are shaped after")
    print("\n  what iterating the Riccati recursion itself would do, from X = 0:")
    Pf, seq = doubling(ex, iters=10)
    for k, err in seq:
        print("     step %2d: |X - P| = %.4g" % (k, err))
    ratios = [seq[i][1] / seq[i - 1][1] for i in range(1, len(seq))]
    rho = max(abs(z) for z in eig(f64(ex["M"])))
    print("     error ratios, last three: %s" % ["%.4f" % r for r in ratios[-3:]])
    J, lams = linearized_map(ex)
    print("     derivative of the Riccati map at X = P, |eig| = %s" %
          ["%.4f" % abs(z) for z in sorted(lams, key=lambda z: -abs(z))])
    print("     the closed loop is M with |z| = %s, so the predicted rate is "
          "rho(M)^2 = %.4f and the measured one is %.4f" %
          (["%.4f" % abs(z) for z in eig(f64(ex["M"]))], rho ** 2,
           max(abs(z) for z in lams)))
    need = math.ceil(math.log(1e-12 / seq[-1][1]) / math.log(rho ** 2))
    print("     it DOES converge here (the plant is detectable, A being unstable is the")
    print("     case that needs the solver, not the case that breaks the iteration) --")
    print("     but only linearly: %d more steps for another decade-and-a half of "
          "digits, %d in all" % (need, 10 + need))
    print("     %d steps of the recursion vs %d sweeps + %d swaps, each sweep O((2n)^2)"
          % (10 + need, sol["sweeps"], sol["swaps"]))
    print("     quadratic convergence is what the doubling family (Schaerer's method, and")
    print("     the structure-preserving LRT of Poloni-Gubinelli) buys instead: #s7")
    print("     The same pencil, but with the ordinary Schur form (N = I), is what the")
    print("     QR iteration builds: cross-link Algebra/qr-iteration in the note.")
    return dict(sol=sol, costs=costs, recur=seq, stalls24=dict(
        sweeps=s24["sweeps"], ok=s24["ok"], kerr=s24["kerr"], secs=dt24))


def on_circle(q2):
    """A = [[1,1],[0,1]], B = [0;1], R = 1, Q = diag(0, q2): the undamped double step.

    A's multiplier 1 is double and on the unit circle, and the second state is the
    only one the cost sees.  As q2 -> 0 the four multipliers of the pencil collapse
    onto z = 1, so the inside/outside decision that the ordering depends on runs out
    of gap to decide with.
    """
    A = [[F(1), F(1)], [F(0), F(1)]]
    B = [[F(0)], [F(1)]]
    Q = [[F(0), F(0)], [F(0), F(q2)]]
    return dict(A=A, Q=Q, G=mm(B, tr(B)), B=B, R=[[F(1)]])


def near_multiple(eps):
    """P = I, closed loop diag(1/2, 1/2 + eps): two multipliers about to coincide."""
    P = eye(2, F(1))
    M = [[F(1, 2), F(0)], [F(0), F(1, 2) + F(eps)]]
    G = [[F(1), F(1)], [F(1), F(1)]]
    A, Q = design(P, M, G)
    return dict(A=A, Q=Q, G=G, B=[[F(1)], [F(1)]], R=[[F(1)]], P=P)


def jordan_case(eta):
    """P = I, closed loop [[1/2, eta],[0, 1/2]]: one multiplier, and eta decides
    whether it keeps two eigenvectors (eta = 0) or shares one (eta != 0).

    The pencil's multipliers are 1/2 and 2, each with algebraic multiplicity 2, for
    every eta; only at eta = 0 is each of them geometrically double as well.  That is
    the single distinction the deflating-subspace route cares about, and the table
    below shows why.
    """
    P = eye(2, F(1))
    M = [[F(1, 2), F(eta)], [F(0), F(1, 2)]]
    G = [[F(1), F(1)], [F(1), F(1)]]
    A, Q = design(P, M, G)
    return dict(A=A, Q=Q, G=G, B=[[F(1)], [F(1)]], R=[[F(1)]], P=P, M=M)


def r_s6():
    head("#s6   changed conditions, and where the guarantee stops")
    print("  (a) the weight goes to zero: Q = diag(0, q2) on the double integrator")
    print("  %10s %26s %12s %13s %11s" %
          ("q2", "ordered moduli", "|X| max", "DARE res", "2nd-3rd gap"))
    scan = []
    for q2 in ["1/10", "1/100", "1/10000", "1/1000000", "0"]:
        e = on_circle(F(q2))
        s = solve_dare_qz(e, keep_walks=False, max_sweeps=400)
        ms = moduli(s["S"], s["R"], ordered=True)
        gap = ms[2] - ms[1] if len(ms) > 2 else 0.0
        print("  %10s %-26s %12.4g %13.2e %11.2e" %
              (q2, " ".join("%.6f" % m for m in ms), maxabs(s["X"]), s["dres"], gap))
        scan.append(dict(q2=q2, mods=ms, xn=maxabs(s["X"]), dres=s["dres"],
                         gap=gap, kerr=s["kerr"]))
    print("     the same rows, with the gain and the closed loop it defines:")
    for q2 in ["1/10", "1/100", "1/10000", "1/1000000", "0"]:
        e = on_circle(F(q2))
        s = solve_dare_qz(e, keep_walks=False, max_sweeps=400)
        X, A64, B64 = s["X"], f64(e["A"]), f64(e["B"])
        K = f64(gain(A64, B64, f64(e["R"]), X))
        cl = sorted(abs(z) for z in eig(add(A64, scale(mm(B64, K), -1))))
        off = max(abs(X[0][0]), abs(X[0][1]), abs(X[1][0]))
        x2 = X[1][1]
        qf = float(F(q2))
        root = 0.5 * (qf + math.sqrt(qf * qf + 4.0 * qf))
        print("       q2 = %-10s X = diag(0, %.6f) with the other three entries %10.2e,"
              " K = [0, %.6f]" % (q2, x2, off, K[0][1]))
        print("       %-14s closed loop |z| = %.6f, %.6f   1/(1+x) = %.6f"
              % ("", cl[0], cl[1], 1.0 / (1.0 + x2)))
        print("       %-14s x = (q2+sqrt(q2^2+4 q2))/2 gives %.6f, difference %.2e"
              % ("", root, abs(root - x2)))
    print("     |X| tracks sqrt(q2): the stabilizing solution is not bounded below")
    print("     once (A, Q^{1/2}) stops being detectable")
    print("     and the double multiplier at |z| = 1 is the unpenalized position mode:")
    print("     A v = v for v = (1,0) while Q^{1/2} v = 0 for every q2, so (A, Q^{1/2})")
    print("     is undetectable at q2 = 1/10 too; the closed loop keeps |z| = 1 exactly.")
    print("\n  (b) rounding-size noise on a pencil whose multipliers sit on the circle")
    e0 = on_circle(F(0))
    L0, N0 = pencil(f64(e0["A"]), f64(e0["Q"]), f64(e0["G"]))
    rng = random.Random(0)
    for k in range(6):
        Lp = [[(L0[i][j] + (rng.uniform(-1, 1) * 1e-13 if i == j else L0[i][j]))
              for j in range(4)] for i in range(4)]
        S, R, U, V, sw, log, fl, w = qz_schur(Lp, N0, keep_walks=False)
        ok, nsw = sort_blocks(S, R, U, V, modulus_key)
        ms = moduli(S, R, ordered=True)
        print("     noise %d: |z| - 1 = %s  inside the disk: %d of 4  ordering ok=%s" %
              (k, " ".join("%+.3e" % (m - 1.0) for m in ms),
               sum(1 for m in ms if m < 1.0), ok))
    print("\n  (c) two multipliers about to coincide: closed loop diag(1/2, 1/2 + eps)")
    print("  %12s %12s %10s %8s %12s %14s" %
          ("eps", "gap (chordal)", "sweeps", "2x2 kept", "reordered ok", "|X - P|"))
    for eps in ["1/10", "1/100", "1/1000", "1/100000", "1/10000000",
                "1/1000000000000", "1/1000000000000000"]:
        e = near_multiple(F(eps))
        s = solve_dare_qz(e, keep_walks=False, max_sweeps=400)
        n2 = sum(1 for _, sz in blocks_of(s["S"]) if sz == 2)
        print("  %12s %12.3e %10d %8d %12s %14.3e" %
              (eps, block_gap(s["S"], s["R"]), s["sweeps"], n2, s["ok"], s["kerr"]))
    print("     nothing refuses here: the multipliers get as close as 1e-15 apart and")
    print("     each keeps its own eigenvector, so the subspace the ordering needs is")
    print("     still spanned by directions that exist.  Coincidence is not the")
    print("     difficulty; a *shared* eigenvector is.")
    print("\n  (d) the same pencil with a SHARED eigenvector: closed loop [[1/2, eta],[0, 1/2]]")
    print("     multipliers of the pencil are 1/2, 1/2, 2, 2 for every eta (exact):")
    ej = jordan_case(F(0))
    csj, zsj = exact_mults(ej)
    print("       eta = 0:", [fs(z) for z in zsj])
    ej = jordan_case(F(1))
    csj, zsj = exact_mults(ej)
    print("       eta = 1:", [fs(z) for z in zsj])
    for tag, ev in [("0", F(0)), ("1", F(1))]:
        Lj, Nj = pencil(jordan_case(ev)["A"], jordan_case(ev)["Q"], jordan_case(ev)["G"])
        for z in [F(1, 2), F(2)]:
            dl = len(nullspace(add(Lj, scale(Nj, -z)), tol=0))
            print("       at eta = %s the nullspace of (L - %s N) has dimension %d, so the"
                  " multiplier %s has algebraic multiplicity 2 and geometric multiplicity %d"
                  % (tag, fs(z), dl, fs(z), dl))
    print("  %8s %12s %8s %9s %6s %12s %11s %18s" %
          ("eta", "gap (chordal)", "sweeps", "2x2 kept", "ok", "|X - P|", "DARE res",
           "closed-loop |z|"))
    lim = []
    for eta in ["0", "1/1000", "1/100", "1/1000000", "1", "100"]:
        e = jordan_case(F(eta))
        s = solve_dare_qz(e, keep_walks=False, max_sweeps=400)
        n2 = sum(1 for _, sz in blocks_of(s["S"]) if sz == 2)
        K = gain(f64(e["A"]), f64(e["B"]), f64(e["R"]), s["X"])
        cl = ["%.3f" % abs(z) for z in eig(add(f64(e["A"]),
              scale(mm(f64(e["B"]), K), -1)))]
        print("  %8s %12.3e %8d %9d %6s %12.3e %11.2e %18s" %
              (eta, block_gap(s["S"], s["R"]), s["sweeps"], n2, s["ok"], s["kerr"],
               s["dres"], " ".join(cl)))
        lim.append(dict(eta=eta, gap=block_gap(s["S"], s["R"]), sweeps=s["sweeps"],
                        n2=n2, ok=s["ok"], kerr=s["kerr"], dres=s["dres"], cl=cl))
    print("     eta = 0 is the only row that reorders: each multiplier keeps two")
    print("     eigenvectors, so the stable deflating subspace is spanned by vectors")
    print("     the kernel is allowed to name one at a time.")
    print("     The eta = 1 row is the dangerous one: reordering FAILS (ok = False, the")
    print("     2x2 block is kept whole, exactly as LAPACK's DTGEXC answers INFO = 1 on")
    print("     an ill-conditioned swap) and the X it hands back is a *different*")
    print("     solution of the same DARE -- residual 8.7e-15, closed loop 2, 2.  A tiny")
    print("     residual cannot tell a correct selection from a wrong one; the ordering")
    print("     flag and the closed-loop moduli can, which is why step 6 of the")
    print("     procedure is a check and not a formality.")
    print("     eta = 1/1000000 fails the other way: the block will not split, V11 comes")
    print("     out nearly singular, and both the error and the residual blow up.")
    print("\n  (e) what is NOT preserved: symmetry and the deflating structure")
    ex = running()
    s = solve_dare_qz(ex, keep_walks=False)
    print("     |X - X'| = %.3e  (the exact answer is symmetric; the subspace route"
          % s["sym"])
    print("      never promises that),  |X - P| = %.3e" % s["kerr"])
    e = ill_cond_family(100)
    s2 = solve_dare_qz(e, keep_walks=False)
    print("     on the ill-conditioned family at c = 100:  |X - X'| = %.3e," % s2["sym"])
    print("      |X - P| = %.3e,  DARE residual = %.3e" % (s2["kerr"], s2["dres"]))
    return dict(scan=scan)


def demo_json():
    """The data behind the page's selection demo: all C(2n, n) choices, exactly.

    Each entry carries the rational X from the pencil's own deflating subspace, the
    double-precision X that the QZ pipeline returns for the same ordering, and the
    numbers that say whether the choice is a graph at all.
    """
    ex = running()
    cs, zs, rows = pick_selections(ex)
    out = []
    for pick, sel, s in rows:
        row = dict(ids=list(pick), mults=[fs(z) for z in sel],
                   floats=[float(z) for z in sel])
        if isinstance(s, dict):
            row.update(X=[[fs(a) for a in r] for r in s["X"]],
                       Xf=[[float(a) for a in r] for r in s["X"]],
                       symmetric=(s["sym"] == 0), clmax=s["clmax"],
                       dres=str(s["rres"]), dres_deflating=str(s["dres"]),
                       detV1=str(s["detV1"]),
                       K=[[fs(a) for a in r] for r in s["K"]],
                       sin=s["sinangle"])
        else:
            row.update(X=None, symmetric=None, detV1=str(graph_det(ex, sel)), note=s)
        q = solve_dare_qz(ex, sort_key=selection_key(sel), keep_walks=False)
        row["qz"] = dict(ok=q["ok"], X=[[float(a) for a in r] for r in q["X"]],
                         condV1=q["condV1"], v1det=q["v1det"], r11det=q["r11det"],
                         dres=q["dres"], sym=q["sym"],
                         clmax=max(abs(z) for z in eig(
                             add(f64(ex["A"]),
                                 scale(mm(f64(ex["B"]),
                                         gain(f64(ex["A"]), f64(ex["B"]),
                                              f64(ex["R"]), q["X"])), -1)))))
        out.append(row)
    sol = solve_dare_qz(ex, keep_walks=False)
    return dict(mults=[fs(z) for z in zs],
                poly=[fs(c) for c in cs],
                selections=out,
                pipeline=dict(X=[[float(a) for a in r] for r in sol["X"]],
                              kerr=sol["kerr"], dres=sol["dres"], sym=sol["sym"],
                              sweeps=sol["sweeps"], swaps=sol["swaps"],
                              condV1=sol["condV1"],
                              T=[[float(a) for a in r] for r in sol["Tm"]],
                              K=[float(a) for r in gain(f64(ex["A"]), f64(ex["B"]),
                                                        f64(ex["R"]), sol["X"])
                                 for a in r]))


def main():
    ap = argparse.ArgumentParser(
        description="Produce every number the note "
                    "'QZ for the Algebraic Riccati Equation' shows.")
    ap.add_argument("--json", action="store_true",
                    help="print the demo/pipeline data as JSON instead of the report")
    ap.add_argument("--section", default="all",
                    help="run one report block: s1..s6")
    ap.add_argument("--no-selftest", action="store_true",
                    help="skip the kernel self-test")
    args = ap.parse_args()
    if not args.no_selftest:
        if not selftest():
            print("\nSELF-TEST FAILED -- the numbers below are not trustworthy.")
            return 1
    if args.json:
        print(json.dumps(demo_json()))
        return 0
    ex = r_s1()
    todo = ["s2", "s3", "s4", "s5", "s6"] if args.section == "all" else [args.section]
    for tag in todo:
        if tag == "s2":
            r_s2(ex)
        elif tag == "s3":
            r_s3()
        elif tag == "s4":
            r_s4(ex)
        elif tag == "s5":
            r_s5(ex)
        else:
            r_s6()
    print("\nall blocks above come from this script; "
          "run: python3 Control/qz-algebraic-riccati/scripts/verify_qz_riccati.py")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
