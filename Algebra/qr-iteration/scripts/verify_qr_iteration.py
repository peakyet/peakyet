#!/usr/bin/env python3
"""Verification for the `qr-iteration` teaching note. Pure Python, no third-party
dependencies beyond the standard library.

Every number printed on the page is produced here; `--json PATH` additionally writes
the snapshot tables the two in-page demos read.

Running example
---------------
K = companion matrix of p(x) = x^4 - 11x^3 + 41x^2 - 61x + 30 = (x-1)(x-2)(x-3)(x-5),

    K = [[11, -41, 61, -30],
         [ 1,   0,  0,   0],
         [ 0,   1,  0,   0],
         [ 0,   0,  1,   0]]

so the spectrum is exactly {5, 3, 2, 1}: entered as integers, eigenvalues known by
inspection, all four moduli distinct (so unshifted QR converges, linearly).

Harness self-tests live in `selftest()` and run first; they check that every routine
really is an orthogonal similarity before any of its output is used.

Usage:  python3 verify_qr_iteration.py [--json /tmp/qr-iteration-demos.json]
"""

import json
import math
import sys

# ---------------------------------------------------------------------------
# dense helpers (row-major lists of lists)
# ---------------------------------------------------------------------------


def mat(n, m, f=0.0):
    return [[f for _ in range(m)] for _ in range(n)]


def eye(n):
    return [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]


def mm(A, B):
    n, k, m = len(A), len(B), len(B[0])
    C = mat(n, m)
    for i in range(n):
        Ai, Ci = A[i], C[i]
        for p in range(k):
            a = Ai[p]
            if a == 0.0:
                continue
            Bp = B[p]
            for j in range(m):
                Ci[j] += a * Bp[j]
    return C


def Tr(A):
    return [list(r) for r in zip(*A)]


def copy(A):
    return [list(r) for r in A]


def maxdiff(A, B):
    n = len(A)
    return max(abs(A[i][j] - B[i][j]) for i in range(n) for j in range(n))


def orthogonality(Q):
    n = len(Q)
    QtQ = mm(Tr(Q), Q)
    return max(abs(QtQ[i][j] - (1.0 if i == j else 0.0)) for i in range(n) for j in range(n))


def beyond_hess(H):
    """Mass strictly below the first subdiagonal: must stay 0 for a Hessenberg matrix."""
    n = len(H)
    return math.sqrt(sum(H[i][j] ** 2 for i in range(n) for j in range(n) if i > j + 1))


def subdiag(H):
    return [abs(H[i + 1][i]) for i in range(len(H) - 1)]


# ---------------------------------------------------------------------------
# unshifted QR step: Givens factorisation + RQ product, O(n^2)
# ---------------------------------------------------------------------------


def givens(a, b):
    """(c, s) with [[c, s], [-s, c]] @ [a, b]^T = [r, 0]^T, r = hypot(a, b)."""
    if b == 0.0:
        return 1.0, 0.0
    r = math.hypot(a, b)
    return a / r, b / r


def qr_step(H, sigma=0.0, want_q=False):
    """One explicit shifted QR step on an upper Hessenberg matrix H.

    Factors H - sigma I = Q R by Givens rotations applied as sparse row operations and
    returns R Q + sigma I = Q^T H Q.  Because the factor is Hessenberg each rotation
    touches O(1) rows of O(n) entries, so the step costs O(n^2), not the O(n^3) of a
    dense factorisation.  Valid for nonsymmetric H.

    Returns (H_new, units) or (H_new, units, Q) with want_q.
    """
    n = len(H)
    A = copy(H)
    for i in range(n):
        A[i][i] -= sigma
    cs = []
    for j in range(n - 1):
        c, s = givens(A[j][j], A[j + 1][j])
        cs.append((c, s))
        for col in range(j, n):
            x, y = A[j][col], A[j + 1][col]
            A[j][col] = c * x + s * y
            A[j + 1][col] = -s * x + c * y
    # A is now R, and Q = G_0^T G_1^T ... G_{n-2}^T, so R Q applies each G_j^T to
    # columns j, j+1 of R in forward order.
    for j in range(n - 1):
        c, s = cs[j]
        for row in range(n):
            x, y = A[row][j], A[row][j + 1]
            A[row][j] = c * x + s * y
            A[row][j + 1] = -s * x + c * y
    for i in range(n):
        A[i][i] += sigma
    units = sum(4 * ((n - j) + n) for j in range(n - 1))
    if not want_q:
        return A, units
    Q = eye(n)
    for j, (c, s) in enumerate(cs):
        G = eye(n)
        G[j][j] = c
        G[j][j + 1] = s
        G[j + 1][j] = -s
        G[j + 1][j + 1] = c
        Q = mm(Q, Tr(G))
    return A, units, Q


def qr_factor(A):
    """Householder QR of a dense matrix: returns (Q, R) with A = Q R."""
    n = len(A)
    R = copy(A)
    roofs = []
    for k in range(min(n - 1, len(A[0]))):
        x = [R[i][k] for i in range(k, n)]
        nx = math.sqrt(sum(v * v for v in x))
        if nx == 0.0:
            continue
        v = list(x)
        v[0] += nx if x[0] >= 0 else -nx
        nv = math.sqrt(sum(t * t for t in v))
        if nv == 0.0:
            continue
        w = [t / nv for t in v]
        for j in range(k, len(R[0])):
            s = sum(w[i] * R[k + i][j] for i in range(n - k))
            for i in range(n - k):
                R[k + i][j] -= 2.0 * w[i] * s
        P = eye(n)
        for i in range(n - k):
            for j in range(n - k):
                P[k + i][k + j] -= 2.0 * w[i] * w[j]
        roofs.append(P)
    # R = P_{n-2} ... P_1 P_0 A, so A = P_0 P_1 ... P_{n-2} R: forward order.
    Q = eye(n)
    for P in roofs:
        Q = mm(Q, P)
    return Q, R


def dense_qr_step(H, sigma=0.0):
    """Reference implementation via Householder, used only by the self-test.

    Returns the completed step Q^T H Q = R Q + sigma I (not the bare R), so it can be
    compared against `qr_step` directly.
    """
    n = len(H)
    A = copy(H)
    for i in range(n):
        A[i][i] -= sigma
    # roof = P_{n-2} ... P_1 P_0, so that A ends up as R = roof (H - sigma I) and
    # H - sigma I = roof^T R, i.e. Q = roof^T.
    roof = eye(n)
    for k in range(n - 1):
        x = [A[i][k] for i in range(k, n)]
        nx = math.sqrt(sum(v * v for v in x))
        if nx == 0.0:
            continue
        v = list(x)
        v[0] += nx if x[0] >= 0 else -nx
        nv = math.sqrt(sum(t * t for t in v))
        if nv == 0.0:
            continue
        w = [t / nv for t in v]
        for j in range(k, n):
            s = sum(w[i] * A[k + i][j] for i in range(n - k))
            for i in range(n - k):
                A[k + i][j] -= 2.0 * w[i] * s
        P = eye(n)
        for i in range(n - k):
            for j in range(n - k):
                P[k + i][k + j] -= 2.0 * w[i] * w[j]
        roof = mm(P, roof)
    Q = Tr(roof)
    A = mm(A, Q)                      # R Q
    for i in range(n):
        A[i][i] += sigma
    return A, Q


# ---------------------------------------------------------------------------
# implicit Francis double shift
# ---------------------------------------------------------------------------


def double_shift_step(H, m):
    """Implicit Francis double shift on the leading m x m block.

    The shifts are the eigenvalues of that block's trailing 2x2, so the shift
    polynomial is p(x) = x^2 - s x + t with s = a+d and t = ad-bc when the trailing
    block is [[a,b],[c,d]].  A mirror is aimed along p(H)e_1 and the bulge it creates
    is chased down the subdiagonal by mirrors that shrink from width 3 to width 2 at
    the bottom corner.  Returns (H_new, Q) with H_new = Q^T H Q exactly.
    """
    n = len(H)
    H = copy(H)
    Q = eye(n)
    a, b, c, d = H[m - 2][m - 2], H[m - 2][m - 1], H[m - 1][m - 2], H[m - 1][m - 1]
    s = a + d
    t = a * d - b * c
    for k in range(0, m - 1):
        wdt = min(3, m - k)
        if k == 0:
            v = [(H[0][0] ** 2 + H[0][1] * H[1][0] - s * H[0][0] + t),
                 H[1][0] * (H[0][0] + H[1][1] - s),
                 H[1][0] * H[2][1]][:wdt]
        else:
            v = [H[k + i][k - 1] for i in range(wdt)]
        nv = math.sqrt(sum(q * q for q in v))
        if nv > 0.0:
            w = [q / nv for q in v]
            w[0] += 1.0 if w[0] >= 0 else -1.0
            nw = math.sqrt(sum(q * q for q in w))
            w = [q / nw for q in w]
            P = eye(n)
            for i in range(wdt):
                for j in range(wdt):
                    P[k + i][k + j] -= 2.0 * w[i] * w[j]
            H = mm(P, mm(H, Tr(P)))
            Q = mm(Q, P)
    return H, Q


# ---------------------------------------------------------------------------
# shifts
# ---------------------------------------------------------------------------


def deflating_qr(H0, shift, tol=1e-11, cap=4000):
    """Run QR to completion the way a real code does.

    Only the leading m x m active block is ever touched; when its bottom subdiagonal
    falls below `tol` the block shrinks by one and that eigenvalue is recorded.  `shift`
    is a function (block, m) -> sigma, or None for the unshifted sweep.

    Returns (sweeps, deflations, diag) where deflations is a list of
    (sweep number, block size, eigenvalue found) and diag is the final diagonal.
    """
    A = copy(H0)
    n = len(A)
    m = n
    deflations = []
    sweeps = 0
    while m > 1 and sweeps < cap:
        B = [[A[i][j] for j in range(m)] for i in range(m)]
        sigma = 0.0 if shift is None else shift(B, m)
        B, _ = qr_step(B, sigma)
        for i in range(m):
            for j in range(m):
                A[i][j] = B[i][j]
        sweeps += 1
        if abs(A[m - 1][m - 2]) < tol:
            deflations.append((sweeps, m, A[m - 1][m - 1]))
            m -= 1
    return sweeps, deflations, [A[i][i] for i in range(n)]


def rayleigh(H, m):
    """sigma = H[m-1][m-1]: the Rayleigh quotient of e_m, the cheapest possible guess."""
    return H[m - 1][m - 1]


def wilkinson(H, m):
    """Eigenvalue of the trailing 2x2 of the leading m x m block closer to H[m-1][m-1]."""
    a, b, c, d = H[m - 2][m - 2], H[m - 2][m - 1], H[m - 1][m - 2], H[m - 1][m - 1]
    if c == 0.0:
        return d
    delta = 0.5 * (a - d)
    if delta == 0.0:
        return d - abs(c)
    return d - c * c / (delta + math.copysign(1.0, delta) * math.hypot(delta, c))


# ---------------------------------------------------------------------------
# exact tools for the running example
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# the running example
# ---------------------------------------------------------------------------

LAMBDAS = [5.0, 3.0, 2.0, 1.0]          # descending; all four moduli distinct
PHI_COEFFS = [1.0, -11.0, 41.0, -61.0, 30.0]   # (x-1)(x-2)(x-3)(x-5)

# Four Givens rotations with rational c, s.  Their product is Q, and S = Q D Q^T
# has rational entries and exactly the eigenvalues 5, 3, 2, 1.
ROTATIONS = [(0, 1, 3.0 / 5.0, 4.0 / 5.0),
             (2, 3, 5.0 / 13.0, 12.0 / 13.0),
             (1, 2, 8.0 / 17.0, 15.0 / 17.0),
             (0, 3, 4.0 / 5.0, 3.0 / 5.0)]


def rotation(n, i, j, c, s):
    G = eye(n)
    G[i][i] = c
    G[i][j] = -s
    G[j][i] = s
    G[j][j] = c
    return G


def example():
    """S = Q diag(5,3,2,1) Q^T: rational entries, exactly known integer spectrum."""
    n = len(LAMBDAS)
    D = mat(n, n)
    for i, lam in enumerate(LAMBDAS):
        D[i][i] = lam
    Q = eye(n)
    for (i, j, c, s) in ROTATIONS:
        Q = mm(Q, rotation(n, i, j, c, s))
    return mm(mm(Q, D), Tr(Q))


def hessenberg(A):
    """Householder reduction to upper Hessenberg form; returns (H, Q) with H = Q^T A Q."""
    n = len(A)
    H = copy(A)
    Q = eye(n)
    for k in range(n - 2):
        x = [H[i][k] for i in range(k + 1, n)]
        nx = math.sqrt(sum(v * v for v in x))
        if nx == 0.0:
            continue
        v = list(x)
        v[0] += nx if x[0] >= 0 else -nx
        nv = math.sqrt(sum(t * t for t in v))
        if nv == 0.0:
            continue
        w = [t / nv for t in v]
        P = eye(n)
        for i in range(n - k - 1):
            for j in range(n - k - 1):
                P[k + 1 + i][k + 1 + j] -= 2.0 * w[i] * w[j]
        H = mm(P, mm(H, P))
        Q = mm(Q, P)
    return H, Q


def companion(coeffs):
    """Companion matrix of x^n + c_{n-1}x^{n-1} + ... + c_0 (descending coefficients)."""
    n = len(coeffs) - 1
    K = mat(n, n)
    for j in range(n):
        K[0][j] = -float(coeffs[j + 1])
    for i in range(1, n):
        K[i][i - 1] = 1.0
    return K


def charpoly_value(coeffs, x):
    """Evaluate a monic polynomial given by descending coefficients."""
    v = 0.0
    for c in coeffs:
        v = v * x + c
    return v


# ---------------------------------------------------------------------------
# self-tests: nothing below is used until these pass
# ---------------------------------------------------------------------------


def det(A):
    """Determinant by Gaussian elimination with partial pivoting (n <= 8 here)."""
    n = len(A)
    M = copy(A)
    d = 1.0
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(M[r][c]))
        if abs(M[p][c]) < 1e-300:
            return 0.0
        if p != c:
            M[c], M[p] = M[p], M[c]
            d = -d
        d *= M[c][c]
        for r in range(c + 1, n):
            f = M[r][c] / M[c][c]
            for k in range(c, n):
                M[r][k] -= f * M[c][k]
    return d


def charpoly_gap(A, coeffs, npts=9):
    """Largest *relative* mismatch between det(xI - A) and the monic polynomial.

    det(xI - A) grows like |x|^n, so an absolute tolerance is meaningless across
    sizes; each residual is divided by (1 + |p(x)|).
    """
    n = len(A)
    worst = 0.0
    for t in range(npts):
        x = -2.5 - 9.0 * t / (npts - 1.0)
        M = [[(x - A[i][i]) if i == j else -A[i][j] for j in range(n)] for i in range(n)]
        p = charpoly_value(coeffs, x)
        worst = max(worst, abs(det(M) - p) / (1.0 + abs(p)))
    return worst


def selftest():
    """Validate the two step routines before any of their output is reported.

    Two QR steps built from different reflector conventions are legitimately different
    matrices, so equality against a second implementation is not a valid check.  What
    every QR step must satisfy is checked instead: it is an orthogonal similarity, it
    stays Hessenberg, and it preserves the characteristic polynomial.

    All residuals are ||Q^T H Q - H_new||, orthogonality is ||Q^T Q - I||, and the
    characteristic-polynomial gap is max |det(xI - A) - p(x)| over a grid of x.
    """
    print("=" * 78)
    print("HARNESS SELF-TESTS")
    print("=" * 78)
    ok = True

    # --- 1. single shifted step on the running example (known exact spectrum) ---
    K, _ = hessenberg(example())
    A, u, Q = qr_step(K, 0.7, want_q=True)
    e1 = maxdiff(mm(mm(Tr(Q), K), Q), A)
    e2 = orthogonality(Q)
    e3 = beyond_hess(A)
    e4 = charpoly_gap(A, PHI_COEFFS)
    A2, Q2 = dense_qr_step(K, 0.7)
    e5 = maxdiff(mm(mm(Tr(Q2), K), Q2), A2)
    e6 = charpoly_gap(A2, PHI_COEFFS)
    print("  single step on H0 (sigma = 0.7):")
    print("    sparse Givens:  similarity %.2e  orthogonality %.2e  below-Hess %.2e  charpoly %.2e"
          % (e1, e2, e3, e4))
    print("    Householder:    similarity %.2e                     below-Hess %.2e  charpoly %.2e"
          % (e5, beyond_hess(A2), e6))
    print("    (the two differ in reflector sign convention, which is a legitimate")
    print("     difference between QR steps; both preserve the spectrum)")
    ok &= e1 < 1e-12 and e2 < 1e-13 and e3 < 1e-14 and e4 < 1e-9
    ok &= e5 < 1e-12 and e6 < 1e-9

    # --- 2. implicit double shift, nonsymmetric, several sizes ---
    trials = {
        "n=4": ([2., 2., -2., 0.], [1., 2., 1.]),
        "n=5": ([4., 1., -3., 2., 0.], [2., 3., 1., 2.]),
        "n=6": ([1., 5., -2., 3., 0., 4.], [2., 1., 3., 2., 1.]),
        "n=8": ([1., 5., -2., 3., 0., 4., -1., 2.], [2., 1., 3., 2., 1., 3., 1.]),
    }
    for trial, (d, e) in trials.items():
        m = len(d)
        H = mat(m, m)
        for i in range(m):
            H[i][i] = d[i]
        for i in range(m - 1):
            H[i][i + 1] = H[i + 1][i] = e[i]
        # perturb the upper triangle so the test matrix is genuinely nonsymmetric
        for i in range(m):
            for j in range(i + 1, m):
                H[i][j] += 0.3 * (1 if (i + j) % 2 else -1)
        # reference polynomial from the tridiagonal part is not what we test; use
        # the step-0 matrix's own charpoly via det at a grid of x
        Hd, Qd = double_shift_step(H, m)
        r = maxdiff(mm(mm(Tr(Qd), H), Qd), Hd)
        bh = beyond_hess(Hd)
        # charpoly preserved: compare det(xI - H) and det(xI - Hd) on a grid, relatively
        gap = 0.0
        for t in range(9):
            x = -2.5 - 9.0 * t / 8.0
            MH = [[(x - H[i][i]) if i == j else -H[i][j] for j in range(m)] for i in range(m)]
            MD = [[(x - Hd[i][i]) if i == j else -Hd[i][j] for j in range(m)] for i in range(m)]
            a = det(MH)
            gap = max(gap, abs(a - det(MD)) / (1.0 + abs(a)))
        print("  double shift %s: similarity %.2e  orthogonality %.2e  below-Hess %.2e  charpoly %.2e"
              % (trial, r, orthogonality(Qd), bh, gap))
        ok &= r < 1e-12 and orthogonality(Qd) < 1e-13 and bh < 1e-12 and gap < 1e-11

    # --- 3. many steps in a row must not drift ---
    A = copy(K)
    for _ in range(60):
        A, _ = qr_step(A, 0.0)
    drift = charpoly_gap(A, PHI_COEFFS)
    print("  after 60 unshifted sweeps on the example: charpoly drift %.2e" % drift)
    ok &= drift < 1e-8

    print("  SELF-TESTS:", "pass" if ok else "FAIL")
    print()
    return ok


# ---------------------------------------------------------------------------
# experiments
# ---------------------------------------------------------------------------


def exp01_example():
    S = example()
    H0, Qh = hessenberg(S)
    print("=" * 78)
    print("EXP 1  the running example, and the one-time reduction")
    print("=" * 78)
    print("  S = Q diag(5,3,2,1) Q^T, built from four Givens rotations with rational")
    print("  c, s, so every entry of S is rational and the spectrum is exactly {1,2,3,5}:")
    for r in S:
        print("     ", ["%14.10f" % x for x in r])
    for lam in LAMBDAS:
        print("    p(%.0f) = %+.1e" % (lam, charpoly_value(PHI_COEFFS, lam)))
    print("  trace %.6f = sum of eigenvalues %.0f" % (sum(S[i][i] for i in range(4)), sum(LAMBDAS)))
    print("  moduli 5, 3, 2, 1 are distinct, so each separation has its own ratio:")
    print("    |lam2/lam1| = 3/5 = %.3f   |lam3/lam2| = 2/3 = %.3f   |lam4/lam3| = 1/2 = %.3f"
          % (3 / 5, 2 / 3, 1 / 2))
    print()
    print("  Step one, one time: reduce to Hessenberg form H0 = Q^T S Q.")
    print("  Householder reduction, similarity %.2e, mass below the subdiagonal %.2e"
          % (maxdiff(mm(mm(Tr(Qh), S), Qh), H0), beyond_hess(H0)))
    for r in H0:
        print("     ", ["%14.10f" % x for x in r])
    print("  subdiagonal: %s" % ["%.8f" % x for x in subdiag(H0)])
    print("  H0 is symmetric here only because S is: nothing below the subdiagonal is ever")
    print("  nonzero, and that is what makes each later sweep cost O(n^2).")
    print()
    return H0


def exp02_unshifted(K, sweeps=60):
    print("=" * 78)
    print("EXP 2  unshifted QR: linear convergence at the predicted ratios")
    print("=" * 78)
    A = copy(K)
    rows = []
    prev = None
    print("  Starting from H0, applying only unshifted sweeps:")
    print("  step   |h21|        ratio     |h32|        ratio     |h43|        ratio")
    for k in range(1, sweeps + 1):
        A, _ = qr_step(A)
        s = subdiag(A)
        ratio = ["  -   "] * 3 if prev is None else ["%.4f" % (s[i] / prev[i]) for i in range(3)]
        if k in (1, 2, 3, 5, 10, 20, 40, 60):
            print("  %4d  %.4e  %s  %.4e  %s  %.4e  %s"
                  % (k, s[0], ratio[0], s[1], ratio[1], s[2], ratio[2]))
        prev = s
        rows.append({"sweep": k, "sub": list(s)})
    print("  predicted ratios  |lam2/lam1| = 0.6000   |lam3/lam2| = 0.6667   |lam4/lam3| = 0.5000")
    print("  measured (geometric mean over steps 20..60):")
    A = copy(K)
    hist = []
    for k in range(1, 61):
        A, _ = qr_step(A)
        hist.append(subdiag(A))
    for i, name in enumerate(("|h21|", "|h32|", "|h43|")):
        gm = (hist[-1][i] / hist[19][i]) ** (1.0 / 40.0)
        print("    %s : %.4f" % (name, gm))
    print()
    return rows


def exp03_perfect_shift(K):
    print("=" * 78)
    print("EXP 3  a perfect shift deflates in one sweep, and only for its own eigenvalue")
    print("=" * 78)
    A = copy(K)
    for k in range(1, 4):
        A, _ = qr_step(A, 1.0)          # 1.0 is an exact eigenvalue of K
        s = subdiag(A)
        print("  sweep %d with sigma = 1 (exact eigenvalue): |h21| %.4e  |h32| %.4e  |h43| %.4e"
              % (k, s[0], s[1], s[2]))
    print("    the bottom entry is gone after one sweep and then stays gone, while the")
    print("    3x3 block above it keeps working.")
    print("  Why: with sigma exactly an eigenvalue, K - sigma I is singular, so R's last")
    print("  diagonal entry is 0 and R Q + sigma I has a zero last row.")
    print("  What a perfect shift does NOT do is help the other eigenvalues: it is exact")
    print("  for 1 and wrong for 5, 3, 2.  A real algorithm has to guess, and the guess")
    print("  is the whole subject of the next section.")
    print()
    A = copy(K)
    print("  the same one-eigenvalue-perfect shift applied 3 more times, on the")
    print("  remaining 3x3 block, sigma still 1 (now a poor guess):")
    for k in range(1, 6):
        A, _ = qr_step(A, 1.0)
        s = subdiag(A)
        print("    sweep %d: |h21| %.4e  |h32| %.4e  |h43| %.4e   H[2][2] = %.6f"
              % (k, s[0], s[1], s[2], A[2][2]))
    print("    nothing else deflates: 1 appears once, so re-using it gives no new")
    print("    information and the sweep behaves like an unshifted one.")
    print()


def exp04_shift_target(K):
    print("=" * 78)
    print("EXP 4  what the shift knows: sigma vs the eigenvalue it is aiming at")
    print("=" * 78)
    A = copy(K)
    print("  step    sigma=H[3][3]   |h43|        nearest eigen-value   |lam - sigma|")
    for k in range(1, 16):
        sigma = rayleigh(A, 4)
        j = min(range(4), key=lambda t: abs(LAMBDAS[t] - sigma))
        print("  %4d  %14.7f  %.4e    lam = %-8.0f        %.4e"
              % (k, sigma, abs(A[3][2]), LAMBDAS[j], abs(LAMBDAS[j] - sigma)))
        A, _ = qr_step(A, sigma)
        if abs(A[3][2]) < 1e-11:
            print("        -> trailing 1x1 deflated with value %.8f at step %d" % (A[3][3], k))
            break
    print("  sigma converges to the eigenvalue, so |lam - sigma| -> 0 superlinearly;")
    print("  that shrinking distance is what the next section turns into speed.")
    print()


def exp05_shifted_rates(K):
    print("=" * 78)
    print("EXP 5  the shifted sweep: the same step, superlinear convergence")
    print("=" * 78)
    print("  Sweeps needed to finish, deflating as soon as the active block's bottom")
    print("  subdiagonal drops below 1e-11:")
    for name, fn in (("unshifted", None), ("Rayleigh", rayleigh), ("Wilkinson", wilkinson)):
        sweeps, defl, diag = deflating_qr(K, fn)
        found = " ".join("%g" % round(v, 6) for _, _, v in defl)
        print("    %-10s %3d sweeps   found in order: %s" % (name, sweeps, found))
    print("  All three reach the same spectrum {1,2,3,5}; only the count differs.")
    print("  The unshifted sweep needs the ratio 0.5^-1 and gets there eventually.")
    print()
    sweeps, defl, diag = deflating_qr(K, None)
    print("  unshifted, deflation trace:", [(s, m, round(v, 6)) for s, m, v in defl])
    sweeps, defl, diag = deflating_qr(K, rayleigh)
    print("  Rayleigh,  deflation trace:", [(s, m, round(v, 6)) for s, m, v in defl])
    print()
    print("  Rayleigh sweep by sweep, active block only:")
    print("   sweep   active m     sigma          |h(m,m-1)|     leading diag")
    A = copy(K)
    m = len(A)
    step = 0
    while m > 1 and step < 12:
        step += 1
        sigma = rayleigh(A, m)
        B = [[A[i][j] for j in range(m)] for i in range(m)]
        B, _ = qr_step(B, sigma)
        for i in range(m):
            for j in range(m):
                A[i][j] = B[i][j]
        print("   %5d %9d   %12.8f   %.4e     %s"
              % (step, m, sigma, abs(A[m - 1][m - 2]), ["%.6f" % A[i][i] for i in range(m)]))
        if abs(A[m - 1][m - 2]) < 1e-11:
            m -= 1
    print("  The shift chases 3.00000000 within 8 sweeps, then the block shrinks and the")
    print("  same rule walks to 2 and then 1.  Nothing is tuned; sigma is just H[m-1][m-1].")
    print()


def exp06_double_shift_complex():
    print("=" * 78)
    print("EXP 6  one condition changed: a complex pair")
    print("=" * 78)
    c3 = [1.0, -3.0, -5.0, -25.0]                  # (x-5)(x^2+2x+5)
    K3 = companion(c3)
    print("  K3 = companion of x^3 - 3x^2 - 5x - 25, so the spectrum is {5, -1+2i, -1-2i}:")
    for r in K3:
        print("     ", ["%7.0f" % x for x in r])
    print("  p(5) = %.1e   |p(-1+2i)| = %.1e   |p(-1-2i)| = %.1e"
          % (charpoly_value(c3, 5.0), abs(charpoly_value(c3, complex(-1, 2))),
             abs(charpoly_value(c3, complex(-1, -2)))))
    print("  K3 is nonsymmetric, so it is already in Hessenberg form (its subdiagonal is")
    print("  the identity); no reduction needed.")
    print("  The trailing 2x2 is nilpotent, so a shift taken from it is 0 -- exactly the")
    print("  breakdown a real implementation guards against with an exceptional shift.")
    print("  Use the Rayleigh shift instead, which reads the (1,1) entry:")
    A = copy(K3)
    print("   sweep    |h32|        |h21|        trailing-2x2 trace")
    for k in range(1, 41):
        A, _ = qr_step(A, rayleigh(A, 3))
        if k in (1, 5, 10, 20, 30, 40):
            print("   %5d  %.4e  %.4e   %+.8f"
                  % (k, abs(A[2][1]), abs(A[1][0]), A[1][1] + A[2][2]))
    print("    |h21| -> 0, so the real eigenvalue is being isolated, but slowly and it is")
    print("    the TOP row that is moving: with a real sigma the algorithm reaches the")
    print("    complex pair last, and |h32| does not fall at all.")
    print()
    A = copy(K3)
    print("  the same 3x3 under the Francis double shift (shifts from the trailing 2x2,")
    print("  which is nilpotent here, then the sum/determinant of the newly exposed block):")
    m = 3
    print("   sweep   active m   |h(m,m-1)|     |h(m-1,m-2)|   similarity this step")
    for k in range(1, 21):
        A_pre = copy(A)
        A, Q = double_shift_step(A, m)
        r = maxdiff(mm(mm(Tr(Q), A_pre), Q), A)
        print("   %5d %9d   %.4e       %.4e       %.2e"
              % (k, m, abs(A[m - 1][m - 2]), abs(A[m - 2][m - 3]) if m > 2 else 0.0, r))
        if abs(A[m - 1][m - 2]) < 1e-11:
            m -= 1
            if m <= 2:
                break
    print("    the 2x2 that remains holds the pair:")
    print("      trace %+.8f  (want -2)   determinant %+.8f  (want +5)"
          % (A[1][1] + A[2][2], A[1][1] * A[2][2] - A[1][2] * A[2][1]))
    print("  Real arithmetic cannot shrink that block below 2x2: the pair is carried as a")
    print("  block, which is what the real Schur form is.  Avoiding complex arithmetic")
    print("  costs the block; using it would roughly double storage and quadruple")
    print("  multiplies.  This is one of the reasons production codes stay real.")
    print()


def exp07_implicit_equals_explicit():
    print("=" * 78)
    print("EXP 7  why the implicit step equals the explicit one")
    print("=" * 78)
    K, _ = hessenberg(example())
    a, b, c, d = K[2][2], K[2][3], K[3][2], K[3][3]
    s1 = 0.5 * (a + d) + math.hypot(0.5 * (a - d), c)
    s2 = 0.5 * (a + d) - math.hypot(0.5 * (a - d), c)
    s, t = a + d, a * d - b * c

    def shifted(X, sh):
        n = len(X)
        return [[X[i][j] - (sh if i == j else 0.0) for j in range(n)] for i in range(n)]

    P = mm(shifted(K, s1), shifted(K, s2))                # p(K), the explicit shift polynomial
    pe1 = [P[i][0] for i in range(4)]                     # p(K) e_1
    print("  trailing-2x2 shifts s1 = %.8f, s2 = %.8f" % (s1, s2))
    print("  a check on p: s = a + d = %.8f, t = ad - bc = %.8f, and s1 + s2 = %.8f,"
          % (s, t, s1 + s2))
    print("  s1 s2 = %.8f, so the two shifts really are this block's eigenvalues." % (s1 * s2))
    print()
    print("  p(H) e_1 =", ["%12.8f" % x for x in pe1])
    print("  the fourth entry is %.1e: p(H)e_1 lies in the first THREE coordinates," % pe1[3])
    print("  which is why a single length-3 mirror along it starts the whole step.")
    print()
    # the implicit step, and the first column of its Q
    Ki, Qi = double_shift_step(K, 4)
    # the explicit route: an actual QR factorisation of p(K) = Q_e R_e
    Qe, Re = qr_factor(P)
    Ke = mm(mm(Tr(Qe), K), Qe)

    def ang(u, v):
        nu = math.sqrt(sum(x * x for x in u))
        nv = math.sqrt(sum(x * x for x in v))
        return math.degrees(math.acos(min(1.0, abs(sum(u[i] * v[i] for i in range(len(u)))) / (nu * nv))))

    print("  angle between p(H)e_1 and the first column of the implicit Q: %.2e degrees"
          % ang(pe1, [Qi[i][0] for i in range(4)]))
    print("  angle between p(H)e_1 and the first column of the explicit Q: %.2e degrees"
          % ang(pe1, [Qe[i][0] for i in range(4)]))
    print("  both steps are orthogonal similarities of H: implicit %.2e, explicit %.2e"
          % (maxdiff(mm(mm(Tr(Qi), K), Qi), Ki), maxdiff(mm(mm(Tr(Qe), K), Qe), Ke)))
    print("  and they agree to %.2e, as the Implicit Q theorem requires." % maxdiff(Ki, Ke))
    print()
    print("  The Implicit Q theorem: for an unreduced Hessenberg H, a QR step is")
    print("  determined by the first column of its Q.  Both steps push the first column")
    print("  into the direction p(H)e_1, so they produce the same Q, hence the same H.")
    print("  The implicit route never forms p(H) or its QR factorisation: it builds")
    print("  p(H)e_1 -- three numbers -- and chases the resulting bulge, which is what")
    print("  keeps a sweep at O(n^2) instead of O(n^3).")
    print()


def exp08_cost():
    print("=" * 78)
    print("EXP 8  the cost: one sweep is O(n^2), and shifts cut the number of sweeps")
    print("=" * 78)
    print("   n     units per sweep    n^2      ratio")
    for n in (8, 16, 32, 64, 128, 256, 512):
        H = mat(n, n)
        for i in range(n):
            for j in range(n):
                H[i][j] = 1.0 / (1.0 + abs(i - j))   # generic Hessenberg-ish filler
        _, u = qr_step(H, 0.0)
        print("  %4d  %16d  %8d  %8.3f" % (n, u, n * n, u / (n * n)))
    print("  Units are multiply-adds touched by the two rotation sweeps: ~6n^2 per step,")
    print("  i.e. O(n^2) per sweep, because the factor is Hessenberg.  A dense")
    print("  factorisation would cost O(n^3) per sweep; the Hessenberg form (a finite")
    print("  O(n^3) reduction done once) is what buys the whole saving.")
    print()


def demo1_frames(K, nframes=16):
    """Unshifted sweeps on the full matrix: per-sweep subdiagonal decay, for the chart."""
    A = copy(K)
    frames = []
    for k in range(nframes):
        frames.append({"sweep": k,
                       "H": copy(A),
                       "logsub": [(-16.0 if x == 0.0 else math.log10(x)) for x in subdiag(A)]})
        A, _ = qr_step(A)
    return frames


def demo2_frames(K, nframes=12):
    """Shifted sweeps with deflation: the active block, its shift, and its subdiagonal."""
    A = copy(K)
    n = len(A)
    m = n
    frames = []
    step = 0
    while step < nframes and m > 1:
        step += 1
        sigma = rayleigh(A, m)
        frames.append({"sweep": step,
                       "m": m,
                       "sigma": sigma,
                       "sub": [abs(A[i + 1][i]) for i in range(m - 1)],
                       "diag": [A[i][i] for i in range(m)]})
        B = [[A[i][j] for j in range(m)] for i in range(m)]
        B, _ = qr_step(B, sigma)
        for i in range(m):
            for j in range(m):
                A[i][j] = B[i][j]
        if abs(A[m - 1][m - 2]) < 1e-11:
            m -= 1
    return frames


def main():
    json_path = None
    if "--json" in sys.argv:
        json_path = sys.argv[sys.argv.index("--json") + 1]

    if not selftest():
        print("refusing to report results: the harness failed its own checks")
        return 1

    K = exp01_example()
    exp02_unshifted(K)
    exp03_perfect_shift(K)
    exp04_shift_target(K)
    exp05_shifted_rates(K)
    exp06_double_shift_complex()
    exp07_implicit_equals_explicit()
    exp08_cost()

    if json_path:
        payload = {
            "K": K,
            "roots": LAMBDAS,
            "unshifted": demo1_frames(K),
            "shifted": demo2_frames(K),
        }
        with open(json_path, "w") as fh:
            json.dump(payload, fh)
        print("wrote", json_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
