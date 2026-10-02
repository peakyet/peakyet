#!/usr/bin/env python3
"""Reproduce every number quoted in Control/symplectic-matrix/symplectic-matrix.typ.

Pure standard library (no numpy on this machine). Run from the repository root:

    python3 Control/symplectic-matrix/scripts/verify_symplectic.py

It checks, in order:
  1. the 2x2 reduction  M^T J M = (det M) J  and the symplectic defect of sample maps;
  2. that the running example's Hamiltonian flow map is symplectic and det = 1;
  3. that the damped flow contracts phase-space area at rate exp(-c t);
  4. the LQR Hamiltonian matrix of the running example: symmetry of the spectrum,
     the Riccati solution P(eps), and the closed-loop pair;
  5. the eigenvalue quartet of two symplectic matrices (the s3 figure);
  6. the eps -> 0 migration of the Hamiltonian spectrum (the s6 table).
"""
from fractions import Fraction as F
from cmath import exp, sqrt, pi, cos, sin
import cmath

# ---------------------------------------------------------------- tiny linalg
def mm(A, B):
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][k] * B[k][j] for k in range(m)) for j in range(p)] for i in range(n)]

def T(A):
    return [list(r) for r in zip(*A)]

def det(M):
    if len(M) == 1:
        return M[0][0]
    s = 0
    for j in range(len(M)):
        minor = [row[:j] + row[j + 1:] for row in M[1:]]
        s += ((-1) ** j) * M[0][j] * det(minor)
    return s

def eig2(M):
    """Eigenvalues of a 2x2 matrix."""
    a, b, c, d = M[0][0], M[0][1], M[1][0], M[1][1]
    tr, dt = a + d, a * d - b * c
    disc = tr * tr - 4 * dt
    r = cmath.sqrt(disc)
    return [(tr + r) / 2, (tr - r) / 2]

def fmt(z, nd=4):
    return f"{z.real:+.{nd}f}{z.imag:+.{nd}f}i"

def fmtP(M, nd=4):
    return "[" + "; ".join(", ".join(f"{x:+.{nd}f}" for x in row) for row in M) + "]"

J2 = [[F(0), F(1)], [F(-1), F(0)]]

# ------------------------------------------------------- 1. the 2x2 reduction
print("== 1. sample maps: det M and symplectic defect  ||M^T J M - J|| ==")
samples = {
    "shear  [[1, 0.8], [0, 1]]": [[1.0, 0.8], [0.0, 1.0]],
    "rotation 30 deg": [[cos(pi / 6), -sin(pi / 6)], [sin(pi / 6), cos(pi / 6)]],
    "squeeze  diag(1.6, 0.6)": [[1.6, 0.0], [0.0, 0.6]],
}
for name, M in samples.items():
    JTJM = mm(mm(T(M), [[0.0, 1.0], [-1.0, 0.0]]), M)
    defect = max(abs(JTJM[i][j] - (1.0 if (i, j) in [(0, 1)] else -1.0 if (i, j) == (1, 0) else 0.0))
                 for i in range(2) for j in range(2))
    print(f"  {name:32s} det={det(M):+.4f}  ||M^T J M - J||={defect:.3e}")

# ------------------------------------- 2/3. flow maps of the running example
def expm2(A, t, terms=40):
    """expm(A t) by a truncated series (2x2, small ||A t||)."""
    n = 2
    R = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
    term = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
    for k in range(1, terms):
        term = mm(term, A)
        term = [[term[i][j] * t / k for j in range(n)] for i in range(n)]
        R = [[R[i][j] + term[i][j] for j in range(n)] for i in range(n)]
    return R

A = [[0.0, 1.0], [-1.0, 0.0]]            # undamped oscillator, m = k = 1
print("\n== 2. undamped Hamiltonian flow, t = 1 ==")
Phi = expm2(A, 1.0)
J = [[0.0, 1.0], [-1.0, 0.0]]
d = max(abs(mm(mm(T(Phi), J), Phi)[i][j] - J[i][j]) for i in range(2) for j in range(2))
print(f"  Phi_1 = {fmtP(Phi)}")
print(f"  ||Phi^T J Phi - J|| = {d:.3e}   det Phi_1 = {det(Phi):.6f}")
print(f"  eigenvalues of Phi_1: {fmt(eig2(Phi)[0])}, {fmt(eig2(Phi)[1])}")

print("\n== 3. damped flow A_c = [[0,1],[-1,-c]], area ratio det expm(A_c t) = exp(-c t) ==")
for c in (0.0, 0.5, 1.0):
    Ac = [[0.0, 1.0], [-1.0, -c]]
    dt_num = det(expm2(Ac, 1.0))
    print(f"  c={c:3.1f}  det Phi_1 = {dt_num:.6f}   exp(-c*1) = {exp(-c):.6f}")

# ---------------------------------------------- 4. the LQR Hamiltonian matrix
print("\n== 4. LQR: A = [[0,1],[-1,0]], B = [0;1], Q = eps I, R = 1 ==")
def care(eps):
    """Closed-form stabilizing P(eps) for the running example."""
    s = sqrt(1.0 + eps)                    # principal root, s >= 1
    q = s - 1
    r = sqrt((s + 3) * (s - 1))            # r >= 0
    p = r * s
    return [[p, q], [q, r]], s, r

for eps in (1.0, 0.1, 0.01, 0.0):
    P, s, r = care(eps)
    Acl = [[0.0, 1.0], [-1.0 - P[1][0], -P[1][1]]]
    lam = eig2(Acl)
    print(f"  eps={eps:4.2f}  P={fmtP(P, 5)}  A_cl eig = {fmt(lam[0])}, {fmt(lam[1])}"
          f"   |Im/Re| = {abs(lam[0].imag/lam[0].real) if abs(lam[0].real) > 1e-12 else float('inf'):.3f}")

# characteristic polynomial of H via LeVerrier, exact rationals, then roots.
def charpoly(H):
    """Coefficients c_0..c_n of det(x I - H) = x^n + c_1 x^(n-1) + ... + c_n."""
    n = len(H)
    Hf = [[F(H[i][j]).limit_denominator(10**9) for j in range(n)] for i in range(n)]
    M = [[F(0)] * n for _ in range(n)]
    c = [F(1)]
    for k in range(1, n + 1):
        HM = mm(Hf, M)
        if k == 1:
            HM = Hf
        tr = sum(HM[i][i] for i in range(n))
        ck = -tr / k
        c.append(ck)
        M = [[HM[i][j] + (ck if i == j else F(0)) for j in range(n)] for i in range(n)]
    return c

def durand_kerner(coeffs, iters=400):
    """Roots of x^n + c1 x^(n-1) + ... + cn."""
    n = len(coeffs) - 1
    roots = [0.4 + 0.9j] * n
    for i in range(n):
        roots[i] = (0.4 + 0.9j) ** (i + 1)
    def poly(x):
        v = 1 + 0j
        for c in coeffs[1:]:
            v = v * x + complex(c)
        return v
    for _ in range(iters):
        for i in range(n):
            num = poly(roots[i])
            den = 1 + 0j
            for j in range(n):
                if j != i:
                    den *= (roots[i] - roots[j])
            roots[i] -= num / den
    return roots

eps = 1.0
P, s, r = care(eps)
G = [[0.0, 0.0], [0.0, 1.0]]                     # B R^-1 B^T
H = [[A[i][j] for j in range(2)] + [-G[i][j] for j in range(2)] for i in range(2)] + \
    [[-eps if i == j else 0.0 for j in range(2)] + [-A[j][i] for j in range(2)] for i in range(2)]
c = charpoly(H)
print(f"\n  H(eps=1) char poly (x^4 + c1 x^3 + c2 x^2 + c3 x + c4): {[str(x) for x in c]}")
print(f"  roots from Durand-Kerner: {', '.join(fmt(z) for z in durand_kerner(c))}")
Acl = [[0.0, 1.0], [-1.0 - P[1][0], -P[1][1]]]
lam = eig2(Acl)[0]
pred = [lam, lam.conjugate(), -lam, -lam.conjugate()]
print(f"  predicted sigma(H) = sigma(A_cl) union -sigma(A_cl): {', '.join(fmt(z) for z in pred)}")

# ------------------------------- 5. eigenvalue quartets of two symplectic maps
print("\n== 5. eigenvalues of two symplectic matrices (s3 figure) ==")
M1 = expm2(A, 1.0)                                # flow map of the running example
q1 = eig2(M1)
print(f"  M1 = Phi_1 (Hamiltonian flow): {', '.join(fmt(z) for z in q1)}")
# a second symplectic matrix: exp of another Hamiltonian H2 = [[A2, -G2],[-Q2, -A2^T]]
A2 = [[0.0, 1.0], [-2.0, -0.2]]
Q2 = [[0.5, 0.0], [0.0, 0.25]]
G2 = [[0.0, 0.0], [0.0, 1.0]]
H2 = [[A2[i][j] for j in range(2)] + [-G2[i][j] for j in range(2)] for i in range(2)] + \
     [[-Q2[i][j] for j in range(2)] + [-A2[j][i] for j in range(2)] for i in range(2)]
# expm of a 4x4 by scaling-and-squaring with a 20-term series
def mm4(A, B):
    return [[sum(A[i][k] * B[k][j] for k in range(4)) for j in range(4)] for i in range(4)]
def expm4(A, t, terms=24):
    n = 4
    R = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
    term = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
    for k in range(1, terms):
        term = mm4(term, A)
        term = [[term[i][j] * t / k for j in range(n)] for i in range(n)]
        R = [[R[i][j] + term[i][j] for j in range(n)] for i in range(n)]
    return R
M2 = expm4(H2, 1.0)
J4 = [[0.0 if i < 2 and j < 2 or i >= 2 and j >= 2 else (1.0 if i < 2 and j >= 2 and i + 2 == j else -1.0 if i >= 2 and j < 2 and i - 2 == j else 0.0) for j in range(4)] for i in range(4)]
d2 = max(abs(mm4(mm4(T(M2), J4), M2)[i][j] - J4[i][j]) for i in range(4) for j in range(4))
print(f"  M2 = expm(H2), ||M2^T J M2 - J|| = {d2:.3e}, det = {det(M2):.6f}")
for z in durand_kerner(charpoly(M2)):
    print(f"    eig M2: {fmt(z)}   |.|={abs(z):.4f}   1/eig = {fmt(1/z)}")

# ----------------------------------- 6. eps -> 0 migration (s6 table numbers)
print("\n== 6. Hamiltonian spectrum as the state weight eps -> 0 ==")
print("  eps    closed-loop pair (A - B B^T P)          |lam|      note")
for eps in (1.0, 0.1, 0.01, 0.0):
    P, s, r = care(eps)
    Acl = [[0.0, 1.0], [-1.0 - P[1][0], -P[1][1]]]
    l1, l2 = eig2(Acl)
    print(f"  {eps:4.2f}   {fmt(l1, 4)} / {fmt(l2, 4)}   {abs(l1):.4f}    sigma(H) = {{lam, conj(lam), -lam, -conj(lam)}}")
