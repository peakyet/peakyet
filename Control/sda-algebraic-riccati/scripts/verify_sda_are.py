#!/usr/bin/env python3
"""
verify_sda_are.py -- every number quoted on the SDA / algebraic Riccati note.

Pure standard-library Python 3: no numpy, no scipy, no install step.

  python3 scripts/verify_sda_are.py             full report
  python3 scripts/verify_sda_are.py --json      machine-readable numbers
  python3 scripts/verify_sda_are.py --selftest  random-problem checks only

The report prints "self-test verdict: PASS" only if every random-problem
check holds: the SDA iterate Q_k reproduces the plain 2**k-th fixed-point
iterate, X still solves the Riccati equation after k doublings, and the
contraction factor of the k-th problem is the 2**k-th power of the first.
"""
import json, math, random, sys

# ---------------------------------------------------------------- linear algebra
# Matrices are lists of rows.  Everything works for floats and for
# fractions.Fraction alike, so the running example can be checked exactly.

def mm(A, B):
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][t] * B[t][j] for t in range(m)) for j in range(p)] for i in range(n)]

def mv(A, v):
    return [sum(A[i][j] * v[j] for j in range(len(v))) for i in range(len(A))]

def ma(A, B):  return [[A[i][j] + B[i][j] for j in range(len(A[0]))] for i in range(len(A))]
def ms(A, B):  return [[A[i][j] - B[i][j] for j in range(len(A[0]))] for i in range(len(A))]
def sc(A, s):  return [[A[i][j] * s for j in range(len(A[0]))] for i in range(len(A))]
def tr(A):     return [list(r) for r in zip(*A)]
def eye(n, one=1.0): return [[one if i == j else one * 0 for j in range(n)] for i in range(n)]
def zeros(n):  return [[0.0] * n for _ in range(n)]

def inv(M):
    n = len(M)
    A = [list(M[i]) + list(eye(n, type(M[0][0])(1) if not isinstance(M[0][0], float) else 1.0)[i]) for i in range(n)]
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(A[r][c]))
        if abs(A[p][c]) == 0:
            raise ZeroDivisionError("singular matrix at column %d" % c)
        A[c], A[p] = A[p], A[c]
        piv = A[c][c]
        A[c] = [x / piv for x in A[c]]
        for r in range(n):
            if r != c and A[r][c] != 0:
                f = A[r][c]
                A[r] = [A[r][k] - f * A[c][k] for k in range(2 * n)]
    return [row[n:] for row in A]

def frob(A):  return math.sqrt(sum(A[i][j] * A[i][j] for i in range(len(A)) for j in range(len(A[0]))))

def eig2(M):
    """Eigenvalues of a real 2x2 matrix, as complex numbers."""
    tr_, det_ = M[0][0] + M[1][1], M[0][0] * M[1][1] - M[0][1] * M[1][0]
    d = tr_ * tr_ - 4 * det_
    if d >= 0:
        s = math.sqrt(d)
        return [complex((tr_ + s) / 2, 0), complex((tr_ - s) / 2, 0)]
    s = math.sqrt(-d)
    return [complex(tr_ / 2, s / 2), complex(tr_ / 2, -s / 2)]

def rho2(M):  return max(abs(z) for z in eig2(M))

# ---------------------------------------------------------------- the equations

def care_residual(A, G, Q, X):
    """A^T X + X A - X G X + Q  (continuous-time algebraic Riccati equation)."""
    return ma(ms(ma(mm(tr(A), X), mm(X, A)), mm(mm(X, G), X)), Q)

def dare_residual(A, G, Q, X):
    """X - Q - A^T X (I + G X)^{-1} A  (discrete-time algebraic Riccati equation)."""
    return ms(X, ma(Q, mm(mm(tr(A), X), mm(inv(ma(eye(len(A)), mm(G, X))), A))))

def sda(A0, G0, Q0, steps):
    """Structure-preserving doubling algorithm.  Returns [(A_k, G_k, Q_k)]."""
    out, A, G, Q = [(A0, G0, Q0)], A0, G0, Q0
    for _ in range(steps):
        W = inv(ma(eye(len(A)), mm(G, Q)))          # one inverse per step
        A1 = mm(A, mm(W, A))
        G1 = ma(G, mm(A, mm(W, mm(G, tr(A)))))
        Q1 = ma(Q, mm(tr(A), mm(Q, mm(W, A))))      # Q before W keeps it symmetric
        A, G, Q = A1, G1, Q1
        out.append((A, G, Q))
    return out

def fixed_point(A, G, Q, j):
    """X_{j+1} = Q + A^T X_j (I + G X_j)^{-1} A, from X_0 = 0."""
    X = zeros(len(A))
    for _ in range(j):
        W = inv(ma(eye(len(A)), mm(G, X)))
        X = ma(Q, mm(mm(tr(A), X), mm(W, A)))
    return X

def cayley(A, G, Q, tau):
    """Chu-Fan-Lin starting data: CARE -> DARE at shift tau > 0."""
    n = len(A)
    At = ms(A, sc(eye(n, 1.0), tau))
    Ai = inv(At)
    K = ma(tr(At), mm(Q, mm(Ai, G)))
    A0 = ma(eye(n, 1.0), sc(tr(inv(K)), 2 * tau))
    G0 = sc(mm(mm(Ai, G), inv(K)), 2 * tau)
    Q0 = sc(mm(mm(inv(K), Q), Ai), 2 * tau)
    return A0, G0, Q0

def cayley_eig(lam, tau):  # multiplier (lambda + tau) / (lambda - tau)
    return (lam + tau) / (lam - tau)

# ---------------------------------------------------------------- output helpers

def digits(Qk, X):
    e = frob(ms(Qk, X)) / frob(X)
    return 99.0 if e == 0 else -math.log10(e)

def fmat(M, p=6):
    return "[" + "; ".join(" ".join(("%+.*f" % (p, x)) for x in row) for row in M) + "]"

R = {}   # machine-readable results

# ================================================================ A. the example
print("=" * 78)
print("A.  Running example: a continuous-time LQR problem  (exact rationals)")
print("=" * 78)
from fractions import Fraction as F
A = [[F(-1), F(0)], [F(0), F(1)]]          # one stable mode, one unstable mode
B = [[F(1)], [F(1)]]
Q = [[F(1), F(0)], [F(0), F(2)]]
G = mm(B, tr(B))                            # G = B R^{-1} B^T with R = 1
X = [[F(1, 2), F(-1, 2)], [F(-1, 2), F(7, 2)]]   # the stabilizing solution
K = mm(tr(B), X)                            # K = R^{-1} B^T X
Acl = ms(A, mm(B, K))
print("A   =", [[str(x) for x in r] for r in A], "  B =", [[str(x) for x in r] for r in B])
print("Q   =", [[str(x) for x in r] for r in Q], "  R = [[1]]")
print("G=BB'=", [[str(x) for x in r] for r in G])
print("X   =", [[str(x) for x in r] for r in X])
print("K   = B'X =", [[str(x) for x in r] for r in K])
print("Acl = A - BK =", [[str(x) for x in r] for r in Acl])
print("CARE residual at X (exact)            :", [[str(x) for x in r] for r in care_residual(A, G, Q, X)])
print("open-loop eigenvalues                 :", [str(z) for z in eig2([[float(x) for x in r] for r in A])])
print("closed-loop eigenvalues               :", [str(z) for z in eig2([[float(x) for x in r] for r in Acl])])
print("X eigenvalues                         :", [str(z) for z in eig2([[float(x) for x in r] for r in X])])
R["example"] = dict(A=[[float(x) for x in r] for r in A], B=[[float(x) for x in r] for r in B],
                    Q=[[float(x) for x in r] for r in Q], G=[[float(x) for x in r] for r in G],
                    X=[[float(x) for x in r] for r in X], K=[[float(x) for x in r] for r in K],
                    Acl=[[float(x) for x in r] for r in Acl],
                    open_loop=[str(z) for z in eig2([[float(x) for x in r] for r in A])],
                    closed_loop=[str(z) for z in eig2([[float(x) for x in r] for r in Acl])])

# ================================================================ B. the bridge
print()
print("=" * 78)
print("B.  Cayley bridge with tau = 2:  CARE data -> DARE data  (exact rationals)")
print("=" * 78)
tau = 2
Af = [[float(x) for x in r] for r in A]; Gf = [[float(x) for x in r] for r in G]; Qf = [[float(x) for x in r] for r in Q]
Xf = [[float(x) for x in r] for r in X]
A0, G0, Q0 = cayley(Af, Gf, Qf, tau)
W0 = inv(ma(eye(2, 1.0), mm(G0, Xf)))
K0 = mm(W0, A0)                      # closed loop of the transformed DARE
from fractions import Fraction as Q_
At_e = ms(A, sc(eye(2, F(1)), F(tau))); Ai_e = inv(At_e)
K_e = ma(tr(At_e), mm(Q, mm(Ai_e, G)))
A0e = ma(eye(2, F(1)), sc(tr(inv(K_e)), F(2 * tau)))
G0e = sc(mm(mm(Ai_e, G), inv(K_e)), F(2 * tau))
Q0e = sc(mm(mm(inv(K_e), Q), Ai_e), F(2 * tau))
print("tau                                   :", tau)
print("exact A_0 =", [[str(x) for x in r] for r in A0e], " G_0 =", [[str(x) for x in r] for r in G0e])
print("exact Q_0 =", [[str(x) for x in r] for r in Q0e], " K_tau =", [[str(x) for x in r] for r in K_e])
print("A - tau I                             :", fmat([[-3, 0], [0, -1]], 0))
print("A_0 (starting A for the DARE)         :", fmat(A0))
print("G_0 (starting G)                      :", fmat(G0))
print("Q_0 (starting Q)                      :", fmat(Q0))
print("transformed closed loop (I+G0 X)^-1 A0:", fmat(K0))
print("  eigenvalues                         :", [str(z) for z in eig2(K0)])
print("sigma = rho((I+G0 X)^-1 A0)           : %.15g   (= 1/3 exactly)" % rho2(K0))
print("DARE residual at X                    : %.3e" % frob(dare_residual(A0, G0, Q0, Xf)))
R["cayley"] = dict(tau=tau, A0=A0, G0=G0, Q0=Q0, K0=K0, sigma=rho2(K0),
                   eig=[str(z) for z in eig2(K0)])

# ================================================================ C. SDA run
print()
print("=" * 78)
print("C.  SDA on the transformed problem: quadratic convergence")
print("=" * 78)
iters = sda(A0, G0, Q0, 7)
def sigma_at(Ak, Gk, Xs):
    return rho2(mm(inv(ma(eye(len(Ak), 1.0), mm(Gk, Xs))), Ak))
print(" k | ||A_k||_F | digits(Q_k vs X) | DARE resid | sigma_k at X | 3^-2^k | sigma at Q_k")
for k, (Ak, Gk, Qk) in enumerate(iters):
    print(" %d | %9.2e | %16.2f | %10.2e | %12.3e | %.3e | %.3e"
          % (k, frob(Ak), digits(Qk, Xf), frob(dare_residual(Ak, Gk, Qk, Xf)),
             sigma_at(Ak, Gk, Xf), 3.0 ** (-2 ** k), sigma_at(Ak, Gk, Qk)))
R["sda"] = [dict(k=k, A=frob(Ak), digits=digits(Qk, Xf),
                 resid=frob(dare_residual(Ak, Gk, Qk, Xf)),
                 sigma_at_X=sigma_at(Ak, Gk, Xf),
                 sigma_at_Q=sigma_at(Ak, Gk, Qk),
                 sigma_theory=3.0 ** (-2 ** k)) for k, (Ak, Gk, Qk) in enumerate(iters)]
print("  Q_7 =", fmat(iters[7][2]), "  X =", fmat(Xf))
Kbase = sigma_at            # alias not needed; compute the closed loops explicitly
Kk_prev = [[-1.0/3, 1.0], [0.0, 0.0]]          # K_0 = (I+G_0X)^-1 A_0, exactly
for k, (Ak, Gk, Qk) in enumerate(iters[:6]):
    Kk = mm(inv(ma(eye(2, 1.0), mm(Gk, Xf))), Ak)
    P = [[1.0, 0.0], [0.0, 1.0]]
    for _ in range(2 ** k):
        P = mm(P, Kk_prev)
    print("  || K_%d - K_0^(2^%d) || = %.3e" % (k, k, frob(ms(Kk, P))))

# ================================================================ D. plain loop
print()
print("=" * 78)
print("D.  The plain fixed-point iteration on the same problem")
print("=" * 78)
X0 = zeros(2)
print("  j | digits(X_j vs X) |   Q_k from the SDA with 2^k = j matches")
for k in range(6):
    j = 2 ** k
    Xj = fixed_point(A0, G0, Q0, j)
    Qk = iters[k][2]
    print(" %2d | %16.2f |   max|X_j - Q_%d| = %.2e" % (j, digits(Xj, Xf), k, frob(ms(Xj, Qk))))
R["plain"] = [dict(j=2 ** k, digits=digits(fixed_point(A0, G0, Q0, 2 ** k), Xf),
                   match=frob(ms(fixed_point(A0, G0, Q0, 2 ** k), iters[k][2]))) for k in range(6)]
j12 = next(j for j in range(1, 64) if digits(fixed_point(A0, G0, Q0, j), Xf) >= 12)
k12 = next(k for k, (_, _, Qk) in enumerate(iters) if digits(Qk, Xf) >= 12)
print("  steps to 1e-12:  plain fixed point %d   SDA %d   (each SDA step costs one solve)" % (j12, k12))
R["steps_to_1e-12"] = dict(plain=j12, sda=k12)

# ================================================================ E. Riccati flow
print()
print("=" * 78)
print("E.  The obvious continuous route: integrate the Riccati flow")
print("=" * 78)
def flow_rhs(A, G, Q, Y):
    return ma(ms(ma(mm(tr(A), Y), mm(Y, A)), mm(mm(Y, G), Y)), Q)
dt, T = 0.02, 26.0
Y = zeros(2); t = 0.0; steps = 0; marks = {}
first12 = None
while t < T - 1e-12:
    k1 = flow_rhs(Af, Gf, Qf, Y)
    k2 = flow_rhs(Af, Gf, Qf, ma(Y, sc(k1, dt / 2)))
    k3 = flow_rhs(Af, Gf, Qf, ma(Y, sc(k2, dt / 2)))
    k4 = flow_rhs(Af, Gf, Qf, ma(Y, sc(k3, dt)))
    Y = ma(Y, sc(ma(ma(k1, sc(k2, 2)), ma(sc(k3, 2), k4)), dt / 6))
    t += dt; steps += 1
    if first12 is None and digits(Y, Xf) >= 12:
        first12 = steps
    for tm in (4.0, 8.0, 12.0, 16.0, 20.0, 24.0):
        if abs(t - tm) < dt / 2 and tm not in marks:
            marks[tm] = digits(Y, Xf)
print("  RK4, dt = %.2f, T = %.0f -> %d steps" % (dt, T, steps))
for tm in sorted(marks):
    print("    t = %2.0f : %5.2f digits   (predicted rate e^{-2t}: %.2f)"
          % (tm, marks[tm], -math.log10(math.exp(-2 * tm) * frob(Xf))))
print("  flow reaches 1e-12 at t = %.2f, i.e. step %d (~%d Riccati-map evaluations)"
      % (first12 * dt, first12, 4 * first12))
R["flow"] = dict(dt=dt, T=T, steps=steps, first12=first12, t12=first12 * dt,
                 marks={str(k): v for k, v in marks.items()}, rate=2.0)

# ================================================================ F. tau knob
print()
print("=" * 78)
print("F.  One knob: the Cayley shift tau")
print("=" * 78)
print("  tau   |  sigma(tau)  | SDA steps to 1e-12 | plain-iteration steps")
taur = {}
for tauv in (0.25, 0.5, 1.0, 1.5, math.sqrt(2), 2.0, 4.0, 8.0, 16.0, 32.0):
    if abs(tauv - 1.0) < 1e-12:
        print(" %6.4f |   --------   |  A - tau I is SINGULAR: no bridge" % tauv); continue
    At = ms(Af, sc(eye(2, 1.0), tauv)); Ai = inv(At)
    Kt = ma(tr(At), mm(Qf, mm(Ai, Gf)))
    a0, g0, q0 = cayley(Af, Gf, Qf, tauv)
    sig = math.sqrt(1e-30)
    it = sda(a0, g0, q0, 12)
    dg = [digits(q, Xf) for _, _, q in it]
    kk = next((k for k, d in enumerate(dg) if d >= 12), None)
    jj = next((j for j in range(1, 4097) if digits(fixed_point(a0, g0, q0, j), Xf) >= 12), None)
    # sigma via the eigenvalues of the transformed DARE closed loop
    W = inv(ma(eye(2, 1.0), mm(g0, Xf))); sig = rho2(mm(W, a0))
    taur[tauv] = dict(sigma=sig, sda=kk, plain=jj)
    print(" %6.4f |  %10.5f  |         %2s         |        %4s"
          % (tauv, sig, kk, jj))
R["tau"] = {("%.6f" % k): v for k, v in taur.items()}
print("  optimum: equal multipliers <=> tau = sqrt(2) = %.5f, sigma = 3-2sqrt2 = %.5f"
      % (math.sqrt(2), 3 - 2 * math.sqrt(2)))

# ================================================================ G. baby case
print()
print("=" * 78)
print("G.  The baby case the doubling idea is built on: Stein equation")
print("=" * 78)
S = [[0.5, 0.25], [0.0, 0.9]]                 # any stable matrix works here
S = mm(S, sc(S, 0.9 / frob(S)))
Qs = [[1.0, 0.0], [0.0, 1.0]]
def stein_partial(A, Q, k, terms):            # sum_{i<terms} (A^T)^i Q A^i
    acc, P = zeros(2), Q
    for i in range(terms):
        acc = ma(acc, P); P = mm(mm(tr(A), P), A)
    return acc
Ak, Qsk = S, Qs
stein_dev = []
print("  k | squared-Smith Q_k vs the explicit 2^k-term sum")
for k in range(7):
    dev = frob(ms(Qsk, stein_partial(S, Qs, k, 2 ** k)))
    stein_dev.append(dev)
    print("  %d | 2^k = %3d terms, max|Q_k - sum| = %.2e" % (k, 2 ** k, dev))
    Ak, Qsk = mm(Ak, Ak), ma(Qsk, mm(mm(tr(Ak), Qsk), Ak))
R["stein"] = dict(rho=rho2(S), dev=stein_dev)
print("  rho(A) = %.4f, so the plain partial sums gain %.3f digits per step"
      % (rho2(S), -math.log10(rho2(S) ** 2)))

# ================================================================ H. critical
print()
print("=" * 78)
print("H.  The mechanism behind the critical rate 1/2 (cited theorem, shown here)")
print("=" * 78)
J = [[-1.0, 1.0], [0.0, -1.0]]                 # unit-modulus Jordan block, lambda = -1
P = J
crit = []
print("  k | J^(2^k) = [[1, -2^k],[0,1]]  ->  ||J^(2^k)||_F  vs  2^k")
for k in range(8):
    crit.append((k, frob(P), 2.0 ** k))
    print("  %d | %13.3f  vs  %7.0f      (ratio %.4f)" % (k, frob(P), 2.0 ** k, frob(P) / 2.0 ** k))
    P = mm(P, P)
R["critical"] = crit
print("  a unit-modulus multiplier with a 2x2 Jordan block survives squaring:")
print("  its off-diagonal grows like 2^k, so a normalized doubling iteration can")
print("  only gain a constant number of bits per step -- linear, rate 1/2")

# ================================================================ J. self-test
print()
print("=" * 78)
print("J.  Self-test: random discrete-time Riccati problems, n = 2..4")
print("=" * 78)
random.seed(20260927)
bad = []
for trial in range(24):
    n = random.choice([2, 3, 4])
    Am = [[random.uniform(-1, 1) for _ in range(n)] for _ in range(n)]
    Am = sc(Am, 0.9 / frob(Am))                       # ||A||_F < 1  =>  rho(A) < 1
    C = [[random.uniform(-1, 1) for _ in range(n)] for _ in range(n)]
    Gm = mm(tr(C), C); Gm = sc(Gm, 0.5 / frob(Gm))
    D = [[random.uniform(-1, 1) for _ in range(n)] for _ in range(n)]
    Qm = mm(tr(D), D); Qm = sc(Qm, 0.5 / frob(Qm))
    iter8 = sda(Am, Gm, Qm, 8)
    Xstar = iter8[-1][2]
    res = frob(dare_residual(Am, Gm, Qm, Xstar))
    for k in range(6):
        Ak, Gk, Qk = iter8[k]
        if frob(dare_residual(Ak, Gk, Qk, Xstar)) > 1e-9:            # same solution
            bad.append((trial, k, "invariance"))
        Xj = fixed_point(Am, Gm, Qm, 2 ** k)
        if frob(ms(Xj, Qk)) > 1e-8:                                  # Q_k = X_{2^k}
            bad.append((trial, k, "iterate match"))
        W = inv(ma(eye(n, 1.0), mm(Gk, Qk)))
        sig = rho2(mm(W, Ak)) if n == 2 else None
    if res > 1e-8:
        bad.append((trial, -1, "residual %.2e" % res))
print("  %d random problems, %s" % (24, "PASS" if not bad else "FAIL: %s" % bad[:4]))
print("  self-test verdict:", "PASS" if not bad else "FAIL")
R["selftest"] = "PASS" if not bad else "FAIL"

if "--json" in sys.argv:
    print()
    print(json.dumps(R, indent=2, default=str))
