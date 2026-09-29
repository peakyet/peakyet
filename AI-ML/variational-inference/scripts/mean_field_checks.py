"""Numerical checks behind sections 4, 5, and 6 of variational-inference.typ.

Run from the repository root:

    python3 AI-ML/variational-inference/scripts/mean_field_checks.py

Standard library only. This replaces an earlier draft that four separate in-place patches
had made unreliable; it was deleted and rewritten rather than patched again. Bugs fixed in
the rewrite, each of which changed a number quoted in the note or in discussion:

  1. The Newton solve for section 5's MAP added the log binomial coefficient to the
     gradient instead of the head count, so the mode and every width derived from it were
     wrong (up and down coins came out identical, which was the tell).
  2. The mean-field loop compared a factor's normaliser against a global constant. For a
     product q, each per-factor quantity g_i = E_{q_i}[E_{q_{-i}}[log p(theta, D)]] is
     already the FULL expectation E_q[log p(theta, D)] -- integrating a product density over
     the other coordinates leaves a product density -- so
         ELBO = (1/d) sum_i g_i + sum_i H(q_i),
     and the spread of the g_i is a convergence diagnostic. An earlier version summed the
     g_i, overstating the free energy by a factor of twelve. The last sweep is also now
     recomputed from the final means, because a synchronous update otherwise evaluates each
     factor against stale partners.
  3. The KL fits searched a multiplicative grid centred on (3, 3), which cannot reach the
     sharply concentrated fits the two-bump model wants (the section 6 forward fit has
     alpha = 155). The rewrite searches from several starts and keeps the best.
  4. The constant part of each factor's expected log-joint carried only the prior's own
     terms and dropped the other coins' log-likelihoods, so the free energy came out about
     21 nats high while the per-factor spread stayed zero -- a reminder that an internal
     consistency check is not an external one. The Monte Carlo column is the external check.
  5. The corner comparison divided an unnormalised Gaussian kernel by a normalised one,
     which is why it printed ratios in the thousands. Both densities are now normalised.

Parts:
  A.  The one-coin models of sections 2-4 and 6: exact log evidence, the Beta(alpha, beta)
      fit that minimizes each KL direction, and the check log p(D) - ELBO(q) == KL(q||p).
  B.  The twelve-coin model of section 5 under a dense prior (one shared factor, every pair
      correlated) and a sparse one (nearest-neighbour stock, correlation rho^|i-j|): the
      mean-field fixed point, its free energy two independent ways, and the width, ellipse,
      and corner numbers section 5 asks about.
"""

import math
import random
import time

TLO, THI, TN = 1e-6, 1 - 1e-6, 1601          # grid on (0, 1), used by parts A
TH = (THI - TLO) / (TN - 1)
TGRID = [TLO + i * TH for i in range(TN)]

LLO, LHI, LN = -8.0, 8.0, 801                # logit grid, used by part B
LH = (LHI - LLO) / (LN - 1)
LGRID = [LLO + i * LH for i in range(LN)]


# ------------------------------------------------------------------- primitives


def sigmoid(x):
    if x >= 0:
        return 1.0 / (1.0 + math.exp(-x))
    e = math.exp(x)
    return e / (1.0 + e)


def log1pexp(x):
    return math.log1p(math.exp(-x)) + x if x > 0 else math.log1p(math.exp(x))


def logit(t):
    return math.log(t / (1 - t))


def binom_log(n, k):
    return math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)


def trapz(vals, h):
    return sum(vals) * h - 0.5 * (vals[0] + vals[-1]) * h


def normalize(vals, h):
    z = trapz(vals, h)
    return [v / z for v in vals], z


def mean_sd(dens, grid, h):
    m1 = trapz([d * x for d, x in zip(dens, grid)], h)
    m2 = trapz([d * x * x for d, x in zip(dens, grid)], h)
    return m1, math.sqrt(max(m2 - m1 * m1, 0.0))


def entropy(dens, h):
    return -trapz([d * math.log(d) for d in dens if d > 1e-300], h)


def log_softmax_two(a, b):
    m = max(a, b)
    return m + math.log(math.exp(a - m) + math.exp(b - m))


def invert(mat):
    n = len(mat)
    a = [row[:] + [1.0 if i == j else 0.0 for j in range(n)] for i, row in enumerate(mat)]
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(a[r][col]))
        a[col], a[piv] = a[piv], a[col]
        pv = a[col][col]
        a[col] = [v / pv for v in a[col]]
        for r in range(n):
            if r != col and a[r][col]:
                f = a[r][col]
                a[r] = [v - f * w for v, w in zip(a[r], a[col])]
    return [row[n:] for row in a]


def solve(mat, rhs):
    n = len(mat)
    a = [row[:] + [rhs[i]] for i, row in enumerate(mat)]
    for c in range(n):
        piv = max(range(c, n), key=lambda r: abs(a[r][c]))
        a[c], a[piv] = a[piv], a[c]
        pv = a[c][c]
        a[c] = [v / pv for v in a[c]]
        for r in range(n):
            if r != c and a[r][c]:
                f = a[r][c]
                a[r] = [v - f * w for v, w in zip(a[r], a[c])]
    return [a[i][n] for i in range(n)]


def cholesky(a):
    n = len(a)
    lo = [[0.0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1):
            t = a[i][j] - sum(lo[i][k] * lo[j][k] for k in range(j))
            lo[i][j] = math.sqrt(t) if i == j else t / lo[j][j]
    return lo


def logdet(a):
    return 2.0 * sum(math.log(cholesky(a)[i][i]) for i in range(len(a)))


def equicorr_cov(d, rho):
    return [[rho if i != j else 1.0 for j in range(d)] for i in range(d)]


def chain_cov(d, rho):
    return [[rho ** abs(i - j) for j in range(d)] for i in range(d)]


def grid_cdf(dens, h):
    acc, out = 0.0, []
    for v in dens:
        acc += v * h
        out.append(acc)
    return out


def sample_from(cdf, grid, u):
    target, lo, hi = u * cdf[-1], 0, len(cdf) - 1
    while lo < hi:
        mid = (lo + hi) // 2
        if cdf[mid] < target:
            lo = mid + 1
        else:
            hi = mid
    return grid[lo]


# ------------------------------------------------------------- part A machinery


def beta_log_pdf(alpha, beta):
    lc = math.lgamma(alpha) + math.lgamma(beta) - math.lgamma(alpha + beta)
    return [(alpha - 1) * math.log(t) + (beta - 1) * math.log(1 - t) - lc for t in TGRID]


def one_coin_model(n=10, heads=7, prior_sd=1.0, bump=None):
    """Logistic-normal prior (one bump, or an equal-weight two-bump mixture), binomial data.

    Everything is carried on the theta grid, with the Jacobian -log(t(1-t)) folded into the
    prior so that p(theta) is a density on (0, 1).
    """
    llik, lpri = [], []
    for t in TGRID:
        llik.append(binom_log(n, heads) + heads * math.log(t) + (n - heads) * math.log(1 - t))
        x, jac = logit(t), math.log(t) + math.log(1 - t)
        if bump is None:
            lpri.append(-0.5 * (x / prior_sd) ** 2
                        - math.log(prior_sd * math.sqrt(2 * math.pi)) - jac)
        else:
            m1, m2, s = bump
            lk = math.log(0.5 / (s * math.sqrt(2 * math.pi)))
            lpri.append(log_softmax_two(lk - 0.5 * ((x - m1) / s) ** 2,
                                        lk - 0.5 * ((x - m2) / s) ** 2) - jac)
    joint = [a + b for a, b in zip(llik, lpri)]
    mx = max(joint)
    raw = [math.exp(v - mx) for v in joint]
    post, area = normalize(raw, TH)
    log_evid = mx + math.log(area)
    lpost = [v - log_evid for v in joint]
    return dict(log_evid=log_evid, post=post, lpost=lpost, llik=llik, lpri=lpri,
                truth=mean_sd(post, TGRID, TH))


def kl_divergence(q, log_q, log_p):
    return trapz([qi * (lqi - lpi) for qi, lqi, lpi in zip(q, log_q, log_p)
                  if qi > 1e-300], TH)


def fit_beta(model, forward, starts=None, rounds=7, steps=11):
    """Minimize KL(q||p) (forward) or KL(p||q) (reverse) over Beta(alpha, beta), alpha,beta>1.

    Multi-start: a single search centre cannot find the concentrated fits the two-bump
    model wants.
    """
    starts = starts or [(1.05, 1.05), (1.5, 1.5), (3.0, 3.0), (8.0, 8.0), (30.0, 30.0),
                        (2.0, 20.0), (20.0, 2.0), (60.0, 8.0), (8.0, 60.0), (150.0, 40.0),
                        (40.0, 150.0), (1.2, 40.0), (40.0, 1.2)]
    post, lpost = model["post"], model["lpost"]

    def value(a, b):
        if a <= 1.0 or b <= 1.0:
            return float("inf")
        lq = beta_log_pdf(a, b)
        q = [math.exp(v) for v in lq]
        z = trapz(q, TH)
        if not (0.98 < z < 1.02):
            return float("inf")           # reject grids too coarse for these parameters
        lqn = [v + math.log(z) for v in lq]
        qn = [v / z for v in q]
        if forward:
            return kl_divergence(qn, lqn, lpost)
        # reverse: int p log(p/q)
        return trapz([p * (lp - lq) for p, lp, lq in zip(post, lpost, lqn)
                      if p > 1e-300], TH)

    best = (None, None, float("inf"))
    for s in starts:
        cur = (s[0], s[1], value(*s))
        span = 0.7
        for _ in range(rounds):
            for i in range(steps):
                for j in range(steps):
                    a = cur[0] * math.exp(-span + 2 * span * i / (steps - 1))
                    b = cur[1] * math.exp(-span + 2 * span * j / (steps - 1))
                    v = value(a, b)
                    if v < cur[2]:
                        cur = (a, b, v)
            span *= 0.55
        if cur[2] < best[2]:
            best = cur
    a, b, div = best
    lq = beta_log_pdf(a, b)
    q = [math.exp(v) for v in lq]
    z = trapz(q, TH)
    lqn = [v + math.log(z) for v in lq]
    qn = [v / z for v in q]
    m1, s1 = mean_sd(qn, TGRID, TH)
    acc = trapz([x * (l + p) for x, l, p in zip(qn, model["llik"], model["lpri"])], TH)
    ent = entropy(qn, TH)
    return dict(alpha=a, beta=b, div=div, mean=m1, sd=s1, acc=acc, ent=ent, elbo=acc + ent,
                gap=model["log_evid"] - (acc + ent),
                kl_fwd=kl_divergence(qn, lqn, model["lpost"]),
                kl_rev=trapz([p * (lp - lq) for p, lp, lq in zip(model["post"], model["lpost"], lqn)
                              if p > 1e-300], TH))


# ------------------------------------------------------------- part B machinery


def mean_field(d=12, rho=0.9, n=10, structure="equi", sweeps=400, tol=1e-12, damp=0.0):
    heads = [round(0.7 * n)] * (d // 2) + [round(0.3 * n)] * (d - d // 2)
    cov = equicorr_cov(d, rho) if structure == "equi" else chain_cov(d, rho)
    lam = invert(cov)
    log_prior_norm = -0.5 * (d * math.log(2 * math.pi) + logdet(cov))
    lcs = [binom_log(n, h) for h in heads]

    def factor(i, mu):
        lin = sum(lam[i][j] * mu[j] for j in range(d) if j != i)
        hv = [lcs[i] + heads[i] * x - n * log1pexp(x) - 0.5 * lam[i][i] * x * x
              - lin * x for x in LGRID]
        mx = max(hv)
        ex = [math.exp(v - mx) for v in hv]
        qd, _ = normalize(ex, LH)
        m1, s1 = mean_sd(qd, LGRID, LH)
        return qd, mx + math.log(trapz(ex, LH)), m1, s1 * s1

    mu, var = [0.0] * d, [1.0] * d
    for _ in range(sweeps):
        upd = [factor(i, mu) for i in range(d)]
        new_mu = [(1 - damp) * upd[i][2] + damp * mu[i] for i in range(d)]
        shift = max(abs(new_mu[i] - mu[i]) for i in range(d))
        mu, var = new_mu, [upd[i][3] for i in range(d)]
        if shift < tol:
            break

    # final consistent pass: every factor evaluated against the same converged means
    upd = [factor(i, mu) for i in range(d)]
    dens = [u[0] for u in upd]
    logz = [u[1] for u in upd]
    ent = [entropy(d, LH) for d in dens]
    var = [u[3] for u in upd]
    mu = [u[2] for u in upd]
    # E_{q_j} of the single-coin log-likelihood, needed by every factor's constant part
    ell = []
    for j in range(d):
        ell.append(lcs[j] + heads[j] * mu[j]
                   - n * trapz([x * log1pexp(v) for x, v in zip(dens[j], LGRID)], LH))
    g, c = [], []
    for i in range(d):
        quad = sum(lam[j][j] * var[j] for j in range(d) if j != i)
        cross = sum(lam[j][k] * mu[j] * mu[k] for j in range(d) if j != i
                    for k in range(d) if k != i)
        c.append(sum(ell[j] for j in range(d) if j != i)
                 - 0.5 * (quad + cross) + log_prior_norm)
        g.append(logz[i] + c[i] - ent[i])                 # = E_q[log p(theta, D)]
    elbo = sum(g) / d + sum(ent)

    def log_joint(th):
        s = sum(lcs[j] + heads[j] * th[j] - n * log1pexp(th[j]) for j in range(d))
        q = sum(lam[i][j] * th[i] * th[j] for i in range(d) for j in range(d))
        return s - 0.5 * q + log_prior_norm

    return dict(d=d, lam=lam, mu=mu, var=var, dens=dens, ent=ent, g=g, elbo=elbo,
                log_joint=log_joint, heads=heads, n=n, sweeps=_)


def laplace(mf):
    d, lam, heads, n = mf["d"], mf["lam"], mf["heads"], mf["n"]
    phi = [0.0] * d
    for _ in range(400):
        hess = [[-lam[i][j] for j in range(d)] for i in range(d)]
        gr = []
        for j in range(d):
            p = sigmoid(phi[j])
            hess[j][j] -= n * p * (1 - p)
            gr.append(heads[j] - n * p - sum(lam[j][k] * phi[k] for k in range(d)))
        step = solve(hess, [-v for v in gr])
        phi = [phi[j] + step[j] for j in range(d)]
        if max(abs(s) for s in step) < 1e-14:
            break
    prec = [[lam[i][j] for j in range(d)] for i in range(d)]
    for j in range(d):
        p = sigmoid(phi[j])
        prec[j][j] += n * p * (1 - p)
    cov = invert(prec)
    sd = [math.sqrt(cov[j][j]) for j in range(d)]
    return dict(phi=phi, prec=prec, cov=cov, sd=sd,
                corr=lambda i, j: cov[i][j] / (sd[i] * sd[j]),
                diag_sd=[1.0 / math.sqrt(prec[j][j]) for j in range(d)])


def mc_log_joint(mf, nsam=20000, seed=7):
    random.seed(seed)
    cdfs = [grid_cdf(mf["dens"][i], LH) for i in range(mf["d"])]
    tot = 0.0
    for _ in range(nsam):
        th = [sample_from(cdfs[i], LGRID, random.random()) for i in range(mf["d"])]
        tot += mf["log_joint"](th)
    return tot / nsam


def marginal_density(lap, mf, ti, tj, a, b):
    """(truth, product) densities at the theta pair (a, b), both normalized."""
    ta, tb = logit(a), logit(b)
    blk = [[lap["cov"][ti][ti], lap["cov"][ti][tj]], [lap["cov"][tj][ti], lap["cov"][tj][tj]]]
    ib = invert(blk)
    ua, ub = ta - lap["phi"][ti], tb - lap["phi"][tj]
    q = (ib[0][0] * ua * ua + 2 * ib[0][1] * ua * ub + ib[1][1] * ub * ub)
    truth = math.exp(-0.5 * q) / (2 * math.pi * math.sqrt(blk[0][0] * blk[1][1] - blk[0][1] ** 2))
    prod = 1.0
    for idx, tt in ((ti, ta), (tj, tb)):
        s2 = mf["var"][idx]
        prod *= math.exp(-0.5 * (tt - mf["mu"][idx]) ** 2 / s2) / math.sqrt(2 * math.pi * s2)
    return truth, prod


def main():
    t0 = time.time()
    print("== A: one-coin models, Beta family fitted in both KL directions ==")
    for label, model in (("one bump  (sections 2-4)", one_coin_model()),
                         ("two bumps (section 6)  ", one_coin_model(bump=(0.0, 1.8, 0.3)))):
        print(f"  {label}: exact log p(D) = {model['log_evid']:.5f}; true posterior mean "
              f"{model['truth'][0]:.4f}, sd {model['truth'][1]:.4f}")
        for tag, forward in (("forward KL(q||p)", True), ("reverse KL(p||q)", False)):
            r = fit_beta(model, forward)
            print(f"    {tag}: Beta({r['alpha']:.4f}, {r['beta']:.4f})  mean {r['mean']:.4f}  "
                  f"sd {r['sd']:.4f}")
            print(f"      fitted {r['div']:.5f} | other direction "
                  f"{r['kl_rev'] if forward else r['kl_fwd']:.5f} | ELBO {r['elbo']:.5f} | "
                  f"gap {r['gap']:.5f} | gap == KL(q||p): {abs(r['gap'] - r['kl_fwd']) < 2e-3}")
    print(f"  [{time.time() - t0:.0f}s]")

    print("\n== B: twelve coins, dense vs sparse coupling ==")
    for structure in ("equi", "chain"):
        for n in (3, 10, 30, 100):
            m = mean_field(structure=structure, n=n)
            lap = laplace(m)
            gm = sum(m["g"]) / m["d"]
            spread = max(abs(x - gm) for x in m["g"])
            mc = mc_log_joint(m)
            ratio = sum(m["var"]) / sum(lap["sd"][i] ** 2 for i in range(m["d"]))
            print(f"  {structure:>5} n={n:>3}: MF sd {math.sqrt(m['var'][0]):.4f} | marginal sd "
                  f"{lap['sd'][0]:.4f} | var ratio {ratio:.4f} | corr {lap['corr'](0, 6):+.3f} "
                  f"| g spread {spread:.1e} | ELBO {m['elbo']:.5f} vs MC "
                  f"{mc + sum(m['ent']):.5f} (diff {m['elbo'] - mc - sum(m['ent']):+.5f})")

    print("\n== B2: which prior structure actually hurts a product fit? (n = 10) ==")
    for label, struct, rho in (("one shared factor, every pair +0.90 ", "equi", 0.90),
                               ("one shared factor, every pair +0.99 ", "equi", 0.99),
                               ("same stock, neighbours +0.90 only     ", "chain", 0.90),
                               ("same stock, neighbours +0.99 only     ", "chain", 0.99)):
        m = mean_field(structure=struct, rho=rho, n=10)
        lap = laplace(m)
        vr = sum(m["var"]) / sum(lap["sd"][i] ** 2 for i in range(m["d"]))
        adj, far = lap["corr"](0, 1), lap["corr"](0, 6)
        print(f"  {label}: MF sd {math.sqrt(m['var'][0]):.4f} | marginal sd {lap['sd'][0]:.4f}"
              f" | var ratio {vr:.4f} | corr(adjacent) {adj:+.3f} | corr(6 apart) {far:+.3f}"
              f" | 1-sigma axis ratio of an adjacent pair "
              f"{math.sqrt((1 + adj) / (1 - adj)):.2f}")

    print("\n== C: section 5's model -- dense prior, +0.99, n = 10 ==")
    m = mean_field(structure="equi", rho=0.99, n=10)
    lap = laplace(m)
    r = lap["corr"](0, 6)
    print(f"  MAP logit up {lap['phi'][0]:+.4f} (theta {sigmoid(lap['phi'][0]):.4f}), "
          f"down {lap['phi'][6]:+.4f} (theta {sigmoid(lap['phi'][6]):.4f})")
    print(f"  posterior marginal sd             = {lap['sd'][0]:.4f}")
    print(f"  posterior corr (any pair)         = {r:+.4f}")
    print(f"  plotted pair's axis ratio         = {math.sqrt((1 + r) / (1 - r)):.3f}")
    print(f"  mean-field factor sd              = {math.sqrt(m['var'][0]):.4f}")
    print(f"  sd given one partner              = {lap['sd'][0] * math.sqrt(1 - r * r):.4f}")
    print(f"  sd given all eleven = 1/sqrt(P_jj) = {lap['diag_sd'][0]:.4f}")
    print(f"  factor sd / marginal sd           = {math.sqrt(m['var'][0]) / lap['sd'][0]:.4f}")
    for (ti, tj, a, b, label) in ((0, 1, 0.9, 0.9, "both coins high      (0.90, 0.90)"),
                                  (0, 6, 0.9, 0.1, "as the data suggest  (0.90, 0.10)"),
                                  (0, 1, 0.55, 0.55, "at the posterior mode (0.55, 0.55)")):
        tr, pr = marginal_density(lap, m, ti, tj, a, b)
        print(f"  {label}: product/truth density = {pr / tr:.4f}")
    blk = [[lap["cov"][0][0], lap["cov"][0][6]], [lap["cov"][6][0], lap["cov"][6][6]]]
    tr_, det_ = blk[0][0] + blk[1][1], blk[0][0] * blk[1][1] - blk[0][1] ** 2
    e1 = tr_ / 2 + math.sqrt(max(tr_ * tr_ / 4 - det_, 0.0))
    e2 = tr_ / 2 - math.sqrt(max(tr_ * tr_ / 4 - det_, 0.0))
    ang = math.atan2(e1 - blk[0][0], blk[0][1])
    pts = []
    for k in range(24):
        u = 2 * math.pi * k / 24
        uu, vv = math.sqrt(e1) * math.cos(u), math.sqrt(e2) * math.sin(u)
        pts.append((lap["phi"][0] + uu * math.cos(ang) - vv * math.sin(ang),
                    lap["phi"][6] + uu * math.sin(ang) + vv * math.cos(ang)))
    # Closed-form check on the equicorrelated case: the posterior precision is
    # alpha * I + beta * ones' , so its inverse has the same two-parameter form and
    # every entry is available without a 12x12 solve.
    A = lap["prec"][0][0] - lap["prec"][0][6]      # coefficient of I
    B = lap["prec"][0][6]                          # coefficient of ones'
    diag_cf = (A + 11 * B) / (A * (A + 12 * B))
    off_cf = -B / (A * (A + 12 * B))
    print(f"  closed form: precision = {A:.4f} I + ({B:.4f}) ones' ; "
          f"cov diag {diag_cf:.5f} off {off_cf:+.5f}; eigenvalues of the covariance "
          f"{1 / A:.5f} (x11) and {1 / (A + 12 * B):.5f} (x1), both positive")
    print(f"  numeric    : cov diag {lap['cov'][0][0]:.5f} off {lap['cov'][0][6]:+.5f}")
    print("  figure 2, one-sigma contour of the true posterior for coins 1 and 7 (logits):")
    print("  " + ", ".join(f"({x:+.4f}, {y:+.4f})" for x, y in pts))
    print(f"  centre ({lap['phi'][0]:+.4f}, {lap['phi'][6]:+.4f}); marginal half-width "
          f"{lap['sd'][0]:.4f}; axes {math.sqrt(e1):.4f} x {math.sqrt(e2):.4f}; tilt "
          f"{math.degrees(ang):+.1f} deg")
    print(f"\ntotal {time.time() - t0:.0f}s")


if __name__ == "__main__":
    main()
