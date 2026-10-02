#!/usr/bin/env python3
"""Reproduce every number printed in Algebra/qz-riccati/qz-riccati.typ.

Standard library only (fractions), so all arithmetic below is exact: the residuals
are the zero matrix, not a small matrix, and each multiplier check is a polynomial
evaluation that comes out exactly zero.

    python3 Algebra/qz-riccati/scripts/verify_qz_are.py

All cases are written in an orthonormal eigenbasis of A, where the plant and both
weightings are diagonal, so each one is three scalars per mode; section 0 proves that
this is the same pencil as the coordinate-free plant printed in the note.

Output sections:
  0. the two coordinate systems describe the same pencil
  1. continuous time: CARE residual, Hamiltonian multipliers, closed loop
  2. discrete time: DARE residual, pencil multipliers, gain, closed loop
  3. the six 2-of-4 selections in each domain
  4. the gap across the split for the running example
  5. the four changed cases of section s7, plus the limit of the fourth
  6. the fixed-point foil of section s6, iterated in exact rationals
"""

from fractions import Fraction as F
from itertools import combinations

# --------------------------------------------------------------------- matrices


def zeros(n, m=None):
    return [[F(0)] * (n if m is None else m) for _ in range(n)]


def eye(n):
    e = zeros(n)
    for i in range(n):
        e[i][i] = F(1)
    return e


def mm(A, B):
    n, k, m = len(A), len(B), len(B[0])
    out = zeros(n, m)
    for i in range(n):
        for j in range(m):
            out[i][j] = sum((A[i][t] * B[t][j] for t in range(k)), F(0))
    return out


def add(A, B, sign=F(1)):
    return [[A[i][j] + sign * B[i][j] for j in range(len(A[0]))] for i in range(len(A))]


def trans(A):
    return [list(r) for r in zip(*A)]


def scale(A, c):
    return [[c * x for x in r] for r in A]


def block4(TL, TR, BL, BR):
    n = len(TL)
    rows = [TL[i] + TR[i] for i in range(n)]
    rows += [BL[i] + BR[i] for i in range(n)]
    return rows


def det(A):
    a = [list(r) for r in A]
    n = len(a)
    d = F(1)
    for col in range(n):
        piv = next((r for r in range(col, n) if a[r][col] != 0), None)
        if piv is None:
            return F(0)
        if piv != col:
            a[col], a[piv] = a[piv], a[col]
            d = -d
        d *= a[col][col]
        for r in range(col + 1, n):
            f = a[r][col] / a[col][col]
            if f != 0:
                for c in range(col, n):
                    a[r][c] -= f * a[col][c]
    return d


def inv(A):
    n = len(A)
    aug = [list(A[i]) + list(eye(n)[i]) for i in range(n)]
    for col in range(n):
        piv = next((r for r in range(col, n) if aug[r][col] != 0), None)
        assert piv is not None, "inv(): singular matrix"
        aug[col], aug[piv] = aug[piv], aug[col]
        p = aug[col][col]
        aug[col] = [x / p for x in aug[col]]
        for r in range(n):
            if r != col and aug[r][col] != 0:
                f = aug[r][col]
                aug[r] = [a - f * b for a, b in zip(aug[r], aug[col])]
    return [row[n:] for row in aug]


def nullity(A):
    return len(A[0]) - rank(A)


def rank(A):
    a = [list(r) for r in A]
    rows, cols = len(a), len(a[0])
    r = 0
    for c in range(cols):
        piv = next((i for i in range(r, rows) if a[i][c] != 0), None)
        if piv is None:
            continue
        a[r], a[piv] = a[piv], a[r]
        p = a[r][c]
        a[r] = [x / p for x in a[r]]
        for i in range(rows):
            if i != r and a[i][c] != 0:
                f = a[i][c]
                a[i] = [x - f * y for x, y in zip(a[i], a[r])]
        r += 1
        if r == rows:
            break
    return r


def nullspace(A):
    """Exact null space of A; basis vectors returned as columns."""
    a = [list(r) for r in A]
    rows, cols = len(a), len(a[0])
    pivots, r = [], 0
    for c in range(cols):
        piv = next((i for i in range(r, rows) if a[i][c] != 0), None)
        if piv is None:
            continue
        a[r], a[piv] = a[piv], a[r]
        p = a[r][c]
        a[r] = [x / p for x in a[r]]
        for i in range(rows):
            if i != r and a[i][c] != 0:
                f = a[i][c]
                a[i] = [x - f * y for x, y in zip(a[i], a[r])]
        pivots.append(c)
        r += 1
        if r == rows:
            break
    basis = []
    for fc in [c for c in range(cols) if c not in pivots]:
        v = [F(0)] * cols
        v[fc] = F(1)
        for i, pc in enumerate(pivots):
            v[pc] = -a[i][fc]
        basis.append(v)
    return [list(col) for col in zip(*basis)] if basis else zeros(cols, 0)


# ------------------------------------------------------------------- polynomials


def polyval(c, z):
    return sum((ci * z ** i for i, ci in enumerate(c)), F(0))


def det_zN_minus_L(L, N):
    """Coefficients (low order first) of p(z) = det(z N - L), by exact interpolation.

    deg p <= len(L), so len(L) + 1 sample points determine it; the remaining points
    are used as a self-check that the recovered polynomial is right.
    """
    d = len(L)
    m = d + 1
    pts = list(range(9))

    def value(z):
        Mz = [[N[i][j] * F(z) for j in range(d)] for i in range(d)]
        return det(add(Mz, L, sign=-1))

    vals = [value(z) for z in pts[:m]]
    aug = [[F(z) ** k for k in range(m)] + [vals[k]] for k, z in enumerate(pts[:m])]
    for col in range(m):
        piv = next((r for r in range(col, m) if aug[r][col] != 0), None)
        assert piv is not None
        aug[col], aug[piv] = aug[piv], aug[col]
        p = aug[col][col]
        aug[col] = [x / p for x in aug[col]]
        for r in range(m):
            if r != col and aug[r][col] != 0:
                f = aug[r][col]
                aug[r] = [a - f * b for a, b in zip(aug[r], aug[col])]
    c = [aug[k][m] for k in range(m)]
    for z in pts[m:]:
        assert polyval(c, F(z)) == value(z), "interpolation self-check failed"
    while len(c) > 1 and c[-1] == 0:
        c.pop()
    return c


def charpoly(M):
    return det_zN_minus_L(M, eye(len(M)))


def monic(c):
    return [x / c[-1] for x in c]


def poly_str(c):
    """Print low-to-high coefficient list as a high-to-low polynomial."""
    parts = []
    for k in range(len(c) - 1, -1, -1):
        ck = c[k]
        if ck == 0:
            continue
        name = "" if k == 0 else ("z" if k == 1 else f"z^{k}")
        mag = abs(ck)
        if k == 0:
            body = f"{mag}"
        elif mag == 1:
            body = name
        else:
            body = f"({mag}){name}"
        parts.append((ck > 0, body))
    out = ""
    for i, (pos, body) in enumerate(parts):
        if i == 0:
            out += ("" if pos else "-") + body
        else:
            out += (" + " if pos else " - ") + body
    return out or "0"


def show(label, A):
    print(f"  {label}")
    for r in A:
        print("      [" + "  ".join(str(x) for x in r) + " ]")


def is_zero(A):
    return all(x == 0 for r in A for x in r)


def chordal_sq(set_a, set_b):
    """Smallest squared chordal distance |l-m|^2 / ((1+l^2)(1+m^2)) across a split."""
    best = None
    for l in set_a:
        for m in set_b:
            val = (l - m) ** 2 / ((1 + l * l) * (1 + m * m))
            if best is None or val < best[0]:
                best = (val, l, m)
    return best




# ------------------------------------------------------------------ conventions
#
# Every case is written in an orthonormal eigenbasis of A, so plant and weightings are
# diagonal and each claim reduces to three scalars per mode, (a_k, g_k, q_k). Section 0
# proves this is the same pencil as the coordinate-free plant the note quotes.
#
#   continuous mode block of H:  [[a, -g], [-q, -a]]  ->  lambda^2 = a^2 + g q
#   discrete mode pair: L_k = [[a, 0], [-q, 1]],  N_k = [[1, g], [0, a]]
#                       ->  a mu^2 - (a^2 + 1 + g q) mu + a = 0
#
# Only mode 1 is actuated (g = (9, 0)), which is why its multiplier pair moves with the
# weightings while mode 2's stays pinned at the plant's own multipliers.


def diag2(x, y):
    return [[x, F(0)], [F(0), y]]


def ct_mode_poly(av, gv, qv):
    return [-(av * av + gv * qv), F(0), F(1)]


def dt_mode_poly(av, gv, qv):
    return [av, -(av * av + 1 + gv * qv), av]


def polymul(p, q):
    out = [F(0)] * (len(p) + len(q) - 1)
    for i, x in enumerate(p):
        for j, y in enumerate(q):
            out[i + j] += x * y
    return out


def care_res(X, Am, Gm, Qm):
    return add(add(add(mm(trans(Am), X), mm(X, Am)), mm(mm(X, Gm), X), sign=-1), Qm)


def care_closed(X, Am, Gm):
    return add(Am, mm(Gm, X), sign=-1)


def dare_res(X, Am, Gm, Qm):
    t = add(eye(len(Am)), mm(Gm, X))
    return add(add(mm(trans(Am), mm(mm(X, inv(t)), Am)), Qm), X, sign=-1)


def dare_gain(X, Am, Bm):
    """R = 1 throughout, so the gain is a row: (1 + B'XB)^-1 B'XA."""
    s = F(1) + mm(mm(trans(Bm), X), Bm)[0][0]
    return [[x / s for x in mm(mm(trans(Bm), X), Am)[0]]]


def dare_closed(X, Am, Bm):
    return add(Am, mm(Bm, dare_gain(X, Am, Bm)), sign=-1)


def hamiltonian(Am, Gm, Qm):
    return block4(Am, scale(Gm, -1), scale(Qm, -1), scale(trans(Am), -1))


def pencil(Am, Qm, Gm):
    d = len(Am)
    Lm = block4(Am, zeros(d), scale(Qm, -1), eye(d))
    Nm = block4(eye(d), Gm, zeros(d), trans(Am))
    return Lm, Nm


def eig_dirs(mu, Mm, Nm=None):
    """Deflating directions of one multiplier: null(M - mu I), or null(L - mu N)."""
    if Nm is None:
        return nullspace(add(Mm, scale(eye(len(Mm)), mu), sign=-1))
    return nullspace(add(Mm, scale(Nm, mu), sign=-1))


def as_cols(vecs):
    return [list(c) for c in zip(*vecs)]


print("=" * 78)
print("0. THE TWO COORDINATE SYSTEMS DESCRIBE THE SAME PENCIL")
print("=" * 78)
Ao = [[F(11, 10), F(-12, 10)], [F(-12, 10), F(4, 10)]]
Bo = [[F(12, 5)], [F(-9, 5)]]
Qco = [[F(89, 25), F(-48, 25)], [F(-48, 25), F(61, 25)]]
Qdo = [[F(327, 500), F(36, 500)], [F(36, 500), F(348, 500)]]
U = [[F(4, 5), F(3, 5)], [F(-3, 5), F(4, 5)]]        # columns: the two unit eigenvectors
Av, Bv = diag2(F(2), F(-1, 2)), [[F(3)], [F(0)]]
Qcv, Qdv = diag2(F(5), F(1)), diag2(F(3, 5), F(3, 4))
for nm, Mo, Mv in (("A", Ao, Av), ("Qc", Qco, Qcv), ("Qd", Qdo, Qdv)):
    print(f"   U {nm}_diag U' == {nm} as printed in the note: "
          f"{mm(mm(U, Mv), trans(U)) == Mo}")
print(f"   U B_diag == B as printed in the note: {mm(U, Bv) == Bo}")
print(f"   U'U == I: {mm(trans(U), U) == eye(2)}  (an orthogonal change of coordinates,")
print("   which the generalized Schur decomposition respects)")

n = 2
A, B, Qc, Qd = Av, Bv, Qcv, Qdv
G = mm(B, trans(B))
I2 = eye(2)
a = [A[0][0], A[1][1]]
g = [G[0][0], G[1][1]]
print(f"   eigenbasis data: A = diag({a[0]}, {a[1]}),  B' = ({B[0][0]}, {B[1][0]}),  "
      f"G = diag({g[0]}, {g[1]}),  R = 1")
print(f"   Qc = diag({Qc[0][0]}, {Qc[1][1]}),  Qd = diag({Qd[0][0]}, {Qd[1][1]})")
print(f"   det A = {det(A)};  the actuated mode is the unstable one (a_1 = 2)")

print()
print("=" * 78)
print("1. CONTINUOUS TIME: CARE A'P + PA - P G P + Qc = 0,  K = B'P,  loop A - G P")
print("=" * 78)
H = hamiltonian(A, G, Qc)
show("H =", H)
hc = monic(charpoly(H))
m1c, m2c = ct_mode_poly(a[0], g[0], Qc[0][0]), ct_mode_poly(a[1], g[1], Qc[1][1])
print(f"   char poly of H: {poly_str(hc)}")
print(f"   mode 1 factor, a^2 + g q = {a[0] ** 2 + g[0] * Qc[0][0]}: {poly_str(m1c)}")
print(f"   mode 2 factor, a^2 + g q = {a[1] ** 2 + g[1] * Qc[1][1]}: {poly_str(m2c)}")
print(f"   product of the mode factors == char poly: {polymul(m1c, m2c) == hc}")
mul_c = [F(7), F(-7), F(1, 2), F(-1, 2)]
print(f"   values at 7, -7, 1/2, -1/2: {[str(polyval(hc, m)) for m in mul_c]}")
print(f"   det H = {det(H)},  tr H^2 = {sum(mm(H, H)[i][i] for i in range(4))} = 2(49 + 1/4)")
print(f"   CARE residual at P = I: {[str(x) for r in care_res(I2, A, G, Qc) for x in r]}")
print(f"   mode 1 scalar equation 4p - 9p^2 + 5 = 0 at p = 1: {4 - 9 + 5}; at p = -5/9: "
      f"{polyval([F(5), F(4), F(-9)], F(-5, 9))}")
print("   mode 2 scalar equation -p + 1 = 0 -> p = 1 is its only root (mode 2 unactuated)")
print(f"   K = B'P = {[str(x) for x in mm(trans(B), I2)[0]]}")
clc = care_closed(I2, A, G)
print(f"   A - G P = {[[str(x) for x in r] for r in clc]}, closed-loop poly "
      f"{poly_str(monic(charpoly(clc)))}")

print()
print("=" * 78)
print("2. DISCRETE TIME: DARE P = A'P(I + G P)^-1 A + Qd,  K = (R + B'PB)^-1 B'PA")
print("=" * 78)
L, N = pencil(A, Qd, G)
show("L =", L)
show("N =", N)
dc = det_zN_minus_L(L, N)
dm = monic(dc)
m1d, m2d = dt_mode_poly(a[0], g[0], Qd[0][0]), dt_mode_poly(a[1], g[1], Qd[1][1])
print(f"   det(z N - L) = {poly_str(dc)}  (det N = {det(N)} = det A,  det L = {det(L)})")
print(f"   monic pencil polynomial: {poly_str(dm)}")
print(f"   mode 1 factor (a, g, q) = ({a[0]}, {g[0]}, {Qd[0][0]}): {poly_str(m1d)}")
print(f"   mode 2 factor (a, g, q) = ({a[1]}, {g[1]}, {Qd[1][1]}): {poly_str(m2d)}")
print(f"   product of the mode factors == det(z N - L): {polymul(m1d, m2d) == dc}")
mul_d = [F(1, 5), F(5), F(-1, 2), F(-2)]
print(f"   values at 1/5, 5, -1/2, -2: {[str(polyval(dm, m)) for m in mul_d]}")
print(f"   coefficients low..high {[str(x) for x in dm]}: self-reciprocal, c_k == c_(4-k): "
      f"{all(dm[k] == dm[4 - k] for k in range(5))}")
print(f"   DARE residual at P = I: {[str(x) for r in dare_res(I2, A, G, Qd) for x in r]}")
print(f"   mode 1 scalar equation p = 4p/(1+9p) + 3/5 at p = 1: "
      f"{F(1) - F(4) / F(10) - F(3, 5)};  at p = -1/15: "
      f"{F(-1, 15) - F(4) * F(-1, 15) / (1 + 9 * F(-1, 15)) - F(3, 5)}")
print("   mode 2 scalar equation p = p/4 + 3/4 -> p = 1")
Kd = dare_gain(I2, A, B)
print(f"   K = (R + B'PB)^-1 B'PA = {[str(x) for x in Kd[0]]}")
cld = dare_closed(I2, A, B)
print(f"   A - BK = {[[str(x) for x in r] for r in cld]}, closed-loop poly "
      f"{poly_str(monic(charpoly(cld)))}")
print(f"   (I + G P)^-1 A == A - BK at P = I: {mm(inv(add(I2, mm(G, I2))), A) == cld}")

print()
print("=" * 78)
print("3. SELECTIONS: every 2-of-4 choice of multipliers, both domains")
print("=" * 78)
INF = "infinity"


def report(tag, muls, Mm, Nm, res_fun, closed_fun, gain_fun=None):
    print(f"  --- {tag}")
    dirs = {}
    for mu in muls:
        V = nullspace(Nm) if mu is INF else eig_dirs(mu, Mm, Nm)
        dirs[mu] = V
        print(f"      mu = {mu}: {len(V[0])} deflating direction(s); its state block = "
              f"{[str(V[k][0]) for k in range(n)]}")
    for S in combinations(muls, 2):
        vecs = []
        for mu in S:
            V = dirs[mu]
            vecs += [[row[j] for row in V] for j in range(len(V[0]))]
        if len(vecs) != n:
            print(f"      S = {S}: only {len(vecs)} independent deflating directions -> "
                  f"the pencil is defective at this split, no 2-dim invariant subspace "
                  f"spanned by these choices")
            continue
        V = as_cols(vecs)
        V1, V2 = V[:n], V[n:]
        if det(V1) == 0:
            print(f"      S = {S}: det V1 = 0 -> NOT a graph over the state block")
            continue
        X = mm(V2, inv(V1))
        cp = monic(charpoly(closed_fun(X)))
        vals = [str(polyval(cp, m)) for m in S if m is not INF]
        kstr = ""
        if gain_fun is not None:
            kstr = f"; K = {[str(x) for r in gain_fun(X) for x in r]}"
        print(f"      S = {S}: graph (det V1 = {det(V1)}); P = "
              f"{[str(x) for r in X for x in r]}; residual zero = {is_zero(res_fun(X))}; "
              f"symmetric = {X == trans(X)}; det P = {det(X)}{kstr}; closed-loop poly "
              f"{poly_str(cp)}; values at the selected multipliers = {vals}")


report("CONTINUOUS running example", mul_c, H, None,
       lambda X: care_res(X, A, G, Qc), lambda X: care_closed(X, A, G),
       lambda X: [mm(trans(B), X)[0]])
print()
report("DISCRETE running example", mul_d, L, N,
       lambda X: dare_res(X, A, G, Qd), lambda X: dare_closed(X, A, B),
       lambda X: dare_gain(X, A, B))

print()
print("=" * 78)
print("4. GAP ACROSS THE SPLIT (running example)")
print("=" * 78)
gc = chordal_sq([F(-7), F(-1, 2)], [F(7), F(1, 2)])
print(f"   continuous: chordal chi^2 = {gc[0]} (chi = 7/25 = {float(gc[0]) ** 0.5:.4f}) "
      f"between {gc[1]} and {gc[2]}")
_cp = min((abs(x - y), x, y) for x in (F(-7), F(-1, 2)) for y in (F(7), F(1, 2)))
print(f"   continuous: plain |lambda - mu| across the split, smallest = {_cp[0]} "
      f"between {_cp[1]} and {_cp[2]}")
gd = chordal_sq([F(1, 5), F(-1, 2)], [F(5), F(-2)])
print(f"   discrete: chordal chi^2 = {gd[0]} (chi ~ {float(gd[0]) ** 0.5:.4f}) between "
      f"{gd[1]} and {gd[2]}")
_dr = min((abs(y) / abs(x), x, y) for x in (F(1, 5), F(-1, 2)) for y in (F(5), F(-2)))
print(f"   discrete: smallest |mu|/|lambda| across the split = {_dr[0]} "
      f"between the inside {_dr[1]} and the outside {_dr[2]}")

print()
print("=" * 78)
print("5. THE FOUR CHANGED CASES OF SECTION s7 (one input changed each)")
print("=" * 78)

print("  (a) continuous, control authority removed: g = (0, 0), plant and Qc unchanged")
Ga = diag2(F(0), F(0))
Ha = hamiltonian(A, Ga, Qc)
ca = monic(charpoly(Ha))
print(f"      char poly {poly_str(ca)}; values at 2, -2, 1/2, -1/2: "
      f"{[str(polyval(ca, m)) for m in (F(2), F(-2), F(1, 2), F(-1, 2))]}")
report("(a) selections", [F(2), F(-2), F(1, 2), F(-1, 2)], Ha, None,
       lambda X: care_res(X, A, Ga, Qc), lambda X: care_closed(X, A, Ga))

print()
print("  (b) continuous, the weighting stops seeing the unstable mode: q = (0, 1)")
Qb = diag2(F(0), F(1))
Hb = hamiltonian(A, G, Qb)
cb = monic(charpoly(Hb))
print(f"      char poly {poly_str(cb)}; values at 2, -2, 1/2, -1/2: "
      f"{[str(polyval(cb, m)) for m in (F(2), F(-2), F(1, 2), F(-1, 2))]};  rank(H - mu) "
      f"checks: {(4 - rank(add(Hb, scale(eye(4), F(-2)), sign=-1)))} direction(s) at -2")
report("(b) selections", [F(2), F(-2), F(1, 2), F(-1, 2)], Hb, None,
       lambda X: care_res(X, A, G, Qb), lambda X: care_closed(X, A, G))
for Pn, lbl in ((diag2(F(4, 9), F(1)), "stabilizing candidate P = diag(4/9, 1)"),
                (diag2(F(0), F(1)), "other graph solution P = diag(0, 1)")):
    clx = care_closed(Pn, A, G)
    kx = mm(trans(B), Pn)[0]
    print(f"      {lbl}: K = B'P = {[str(x) for x in kx]}, closed loop "
          f"{[[str(x) for x in r] for r in clx]}, residual zero = "
          f"{is_zero(care_res(Pn, A, G, Qb))}, cost x'Px = ({Pn[0][0]}) x1^2 + ({Pn[1][1]}) x2^2")

print()
print("  (c) discrete, one plant mode goes dead: a = (2, 0), B, G, Qd unchanged")
Ac = diag2(F(2), F(0))
Lc, Nc = pencil(Ac, Qd, G)
print(f"      mode 1 factor {poly_str(dt_mode_poly(F(2), F(9), Qd[0][0]))}; mode 2 factor "
      f"{poly_str(dt_mode_poly(F(0), F(0), Qd[1][1]))} (linear: the degree drops)")
dcp = det_zN_minus_L(Lc, Nc)
print(f"      det(z N - L) = {poly_str(dcp)} -> degree {len(dcp) - 1} of 4, so "
      f"{4 - (len(dcp) - 1)} multiplier at infinity, i.e. (alpha, beta) = (1, 0)")
print(f"      det N = {det(Nc)}, rank N = {rank(Nc)}: N is singular, so N^-1 L cannot be "
      f"formed;  det L = {det(Lc)}")
report("(c) selections", [F(1, 5), F(5), F(0), INF], Lc, Nc,
       lambda X: dare_res(X, Ac, G, Qd), lambda X: dare_closed(X, Ac, B))

print()
print("  (d) continuous, the penalty on the actuated mode turns negative: q = (-11/25, 1)")
Qd2 = diag2(F(-11, 25), F(1))
Hd = hamiltonian(A, G, Qd2)
cd = monic(charpoly(Hd))
print(f"      char poly {poly_str(cd)}; values at 1/5, -1/5, 1/2, -1/2: "
      f"{[str(polyval(cd, m)) for m in (F(1, 5), F(-1, 5), F(1, 2), F(-1, 2))]}")
report("(d) selections", [F(1, 5), F(-1, 5), F(1, 2), F(-1, 2)], Hd, None,
       lambda X: care_res(X, A, G, Qd2), lambda X: care_closed(X, A, G))
gd2 = chordal_sq([F(-1, 5), F(-1, 2)], [F(1, 5), F(1, 2)])
print(f"      gap across the split: plain {min(abs(x - y) for x in (F(-1, 5), F(-1, 2)) for y in (F(1, 5), F(1, 2)))}, "
      f"chordal chi^2 = {gd2[0]} (chi ~ {float(gd2[0]) ** 0.5:.4f})")

print()
print("  (d-limit) q = (-4/9, 1): that multiplier pair sits exactly on the imaginary axis")
Qd3 = diag2(F(-4, 9), F(1))
Hd3 = hamiltonian(A, G, Qd3)
cd3 = monic(charpoly(Hd3))
print(f"      char poly {poly_str(cd3)}; values at 0, 1/2, -1/2: "
      f"{[str(polyval(cd3, m)) for m in (F(0), F(1, 2), F(-1, 2))]}")
print(f"      algebraic multiplicity of 0 is 2 (poly'(0) = {polyval([cd3[1], 2 * cd3[2], 3 * cd3[3]], F(0))}, "
      f"poly''(0)/2 = {cd3[2]}), nullity of H = {len(nullspace(Hd3)[0])} -> defective")
report("(d-limit) selections", [F(0), F(1, 2), F(-1, 2)], Hd3, None,
       lambda X: care_res(X, A, G, Qd3), lambda X: care_closed(X, A, G))


print()
print("=" * 78)
print("6. THE FIXED-POINT FOIL OF SECTION s6 (iterated in exact rationals)")
print("=" * 78)
print("   The recursion P_{k+1} = Qd + A' P_k (I + G P_k)^-1 A from P_0 = Qd, on the")
print("   running discrete data. It reaches the stabilizing solution diag(1, 1) without")
print("   ever forming the 4-by-4 pair, and the rate is set by the pencil, not by P.")

Pk = Qd
for k in range(7):
    print(f"   P_{k} = diag({Pk[0][0]}, {Pk[1][1]})"
          + ("" if k else "   <- P_0 = Q_d"))
    Pk = add(Qd, mm(mm(mm(trans(A), Pk), inv(add(eye(2), mm(G, Pk)))), A))
print("   the entries climb toward diag(1, 1) from below, and no 4-by-4 object is formed;")
print("   the residual A'P(I+GP)^-1 A + Qd - P of the printed iterates is not zero, so each")
print("   P_k is a legitimate iterate and not yet a solution of eq:dare.")
