"""Numeric checks behind the Bayesian-inference note.

Run from the repository root:

    python3 Mathematics/bayesian-inference/scripts/pooling_checks.py

Standard library only. Every number quoted in the note is printed here, and each
part ends with the identities the note claims so that a failure is visible.

  A. The stamped box: the ten coins of the running example under Beta(3, 5), the
     pseudo-count rule, the attenuated spread, and the effect of the stamp's strength.
  B. Where a stamp could come from: the hyperposterior over (alpha, beta) for one
     coin and for ten, its marginals, and how the box that bounds it matters.
  C. What the stamp costs: the risk of the stamped answer against the raw frequency,
     as a function of the true bias, plus both average risks under the stamp.
  D. Prediction: the one-step prices of a seen coin (a martingale), the telescoped
     record probability, and the new-coin predictive under the stamp, the mixture of
     stamps, and a plug-in.
  E. Evidence: marginal likelihoods of five models of the same ten coins, and of a
     box that actually holds two kinds of coin.
  F. The two-factory box: the single-hump fit to two clumps, and what its predictive
     puts where no coin lives.
"""

import math

M = 10                                  # flips per coin
COUNTS = (0, 1, 2, 3, 3, 4, 5, 5, 6, 8)  # heads per coin, the running example
STAMP = (3.0, 5.0)                       # the label on the box: Beta(3, 5)
BOX = (0.1, 40.0)                        # the log-uniform range allowed for (alpha, beta)
NGRID = 361                              # cells per axis of the (log alpha, log beta) grid

TWO_FACTORY = (0, 1, 1, 2, 2, 8, 8, 9, 9, 10)   # five coins near 0.15, five near 0.85


# --------------------------------------------------------------- beta primitives

def log_beta(a, b):
    return math.lgamma(a) + math.lgamma(b) - math.lgamma(a + b)


def log_binom(n, k):
    return math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)


def log_beta_binom(h, m, a, b):
    """log P(h heads in m flips) when the bias is Beta(a, b)."""
    return log_binom(m, h) + log_beta(a + h, b + m - h) - log_beta(a, b)


def log_binom_pmf(h, m, p):
    if h < 0 or h > m:
        return -math.inf
    if p <= 0.0:
        return 0.0 if h == 0 else -math.inf
    if p >= 1.0:
        return 0.0 if h == m else -math.inf
    return log_binom(m, h) + h * math.log(p) + (m - h) * math.log1p(-p)


def grid(box=BOX, n=NGRID):
    """(alpha, beta) cells with the log-uniform measure the note states."""
    lo, hi = math.log(box[0]), math.log(box[1])
    step = (hi - lo) / (n - 1)
    cells = [(math.exp(lo + i * step), math.exp(lo + j * step)) for i in range(n) for j in range(n)]
    return cells, 1.0 / len(cells), step


def hyper(m, counts, cells):
    """Posterior weights over the cells; the measure is uniform in (log a, log b)."""
    logs = [sum(log_beta_binom(h, m, a, b) for h in counts) for a, b in cells]
    top = max(logs)
    ws = [math.exp(v - top) for v in logs]
    z = sum(ws)
    return [w / z for w in ws], logs


def posterior_mean(ws, cells, f):
    return sum(w * f(a, b) for w, (a, b) in zip(ws, cells))


def level_set(ws, logs, cells, mass):
    order = sorted(range(len(cells)), key=lambda i: -logs[i])
    cum = 0.0
    cut = -1
    for i in order:
        cum += ws[i]
        if cum >= mass:
            cut = i
            break
    level = logs[cut]
    inside = [cells[i] for i in order if logs[i] >= level]
    return level, inside


def marginal(ws, cells, f, bins, lo, hi):
    """Histogram of f under the posterior; returns [(x, density)] normalised to max 1."""
    step = (hi - lo) / bins
    acc = [0.0] * bins
    for w, (a, b) in zip(ws, cells):
        x = f(a, b)
        if lo <= x < hi:
            acc[int((x - lo) / step)] += w
    dens = [v / step for v in acc]
    top = max(dens) or 1.0
    return [(lo + (i + 0.5) * step, v / top) for i, v in enumerate(dens)]


def hpd_interval(ws, cells, f, mass=0.68):
    pts = sorted((f(a, b), i) for i, (a, b) in enumerate(cells))
    cum = 0.0
    lo = hi = None
    for v, i in pts:
        cum += ws[i]
        if lo is None and cum >= (1 - mass) / 2:
            lo = v
        if hi is None and cum >= (1 + mass) / 2:
            hi = v
    return lo, hi


# ============================================================ A. the stamped box

def part_a():
    print("=" * 78)
    print("A. the stamped box: Beta(3, 5), ten coins, ten flips each")
    a_s, b_s = STAMP
    s = a_s + b_s
    w = M / (M + s)
    print(f"stamp mean alpha/(alpha+beta)      = {a_s/s:.6f}  (3/8)")
    print(f"stamp sd                           = {math.sqrt(a_s*b_s/(s*s*(s+1))):.6f}")
    print(f"stamp is worth alpha+beta          = {s:.0f} flips")
    print(f"posterior Beta(3+h, 5+t), mean     = (3+h)/18, weight on the count = {w:.6f} (5/9)")
    print(f"posterior sd for count h           = sqrt((3+h)(15-h)/(18^2*19)) = sqrt((3+h)(15-h))/78.46")
    print(f"column spread between counts h, h' = (h-h')/18   [pooled information cancels]")
    print()
    hdr = f"{'h':>3} {'mle':>6} {'stamped':>8} {'sd':>7} {'learned':>8} {'sd':>7}"
    print(hdr)
    cells, cw, _ = grid()
    ws, logs = hyper(M, COUNTS, cells)
    learned = {}
    for h in sorted(set(COUNTS)):
        mu = posterior_mean(ws, cells, lambda a, b, h=h: (a + h) / (a + b + M))
        e_var = posterior_mean(ws, cells, lambda a, b, h=h: (a + h) * (b + M - h)
                               / ((a + b + M) ** 2 * (a + b + M + 1)))
        var_mean = posterior_mean(ws, cells, lambda a, b, h=h: ((a + h) / (a + b + M)) ** 2) - mu ** 2
        learned[h] = (mu, math.sqrt(e_var + var_mean), math.sqrt(e_var))
    for h in COUNTS:
        mu_l, sd_l, sd_cond = learned[h]
        print(f"{h:>3} {h/M:>6.3f} {(a_s+h)/(s+M):>8.4f}"
              f" {math.sqrt((a_s+h)*(b_s+M-h)/((s+M)**2*(s+M+1))):>7.4f}"
              f" {mu_l:>8.4f} {sd_l:>7.4f}")
    print("  (last 'sd' is the total: the spread of the coin's own bias plus the spread of the")
    print("   population the ten coins imply; the conditional-only sds are "
          + ", ".join(f"{learned[h][2]:.4f}" for h in sorted(set(COUNTS))) + ")")
    gaps = [(abs(learned[h][0] - (a_s + h) / (s + M)), h) for h in COUNTS]
    print(f"largest gap between the stamped and learned columns = {max(gaps)[0]:.4f}"
          f" at h={max(gaps)[1]}")
    print()
    lo_h, hi_h = min(COUNTS), max(COUNTS)
    print(f"spread of the stamped column, 0 to 8 heads = {hi_h/M - lo_h/M:.4f} raw,"
          f" {(hi_h-lo_h)/(s+M):.4f} after the stamp  (ratio {(hi_h-lo_h)/(s+M)/((hi_h-lo_h)/M):.4f})")
    print("same mean, three strengths (stamp Beta(3n, 5n)):")
    for n in (0.25, 1, 4):
        ww = M / (M + n * s)
        print(f"  n={n:<5} alpha+beta={n*s:>5.1f} weight={ww:.4f} spread over 8 counts"
              f"={8/(n*s+M):.4f} mean of the 0-head coin={(3*n)/(n*s+M):.4f}")
    print(f"pooled frequency = {sum(COUNTS)/(len(COUNTS)*M):.4f}"
          f"  raw column spread = {hi_h/M - lo_h/M:.4f}")
    print(f"identities: 10/18 + 8/18 == 1 ? {abs(w + 8/18 - 1) < 1e-12}")
    print(f"            stamped mean of 3 heads == 1/3 ? {abs((a_s+3)/(s+M) - 1/3) < 1e-12}")
    return ws, logs, cells


# ======================================================= B. where a stamp comes from

def part_b(ws, logs, cells):
    print("=" * 78)
    print("B. the hyperposterior over (alpha, beta): one coin against ten")
    a_s, b_s = STAMP
    mode = max(zip(logs, cells))[1]
    print(f"ten coins  mode (alpha,beta) = ({mode[0]:.3f}, {mode[1]:.3f})"
          f"  -> population Beta({mode[0]:.2f}, {mode[1]:.2f})")
    lev, inside = level_set(ws, logs, cells, 0.68)
    print(f"           68% set: alpha in [{min(p[0] for p in inside):.2f},"
          f" {max(p[0] for p in inside):.2f}], beta in [{min(p[1] for p in inside):.2f},"
          f" {max(p[1] for p in inside):.2f}], alpha+beta in"
          f" [{min(p[0]+p[1] for p in inside):.2f}, {max(p[0]+p[1] for p in inside):.2f}]")
    print(f"           is the label {STAMP} inside the 68% set? "
          f"{log_beta_sum(ws, logs, cells, a_s, b_s, lev)}")
    print(f"           E[alpha+beta] = {posterior_mean(ws, cells, lambda a, b: a+b):.2f}"
          f"  E[alpha/(alpha+beta)] = "
          f"{posterior_mean(ws, cells, lambda a, b: a/(a+b)):.4f}")
    for label, f in [("alpha/(alpha+beta)", lambda a, b: a/(a+b)),
                     ("log(alpha+beta)", lambda a, b: math.log(a+b))]:
        lo, hi = hpd_interval(ws, cells, f)
        print(f"           {label}: 68% interval [{lo:.4f}, {hi:.4f}] width {hi-lo:.4f}")
    # fraction of mass that asks for a tighter population than the label
    tight = sum(w for w, (a, b) in zip(ws, cells) if a + b > 20)
    print(f"           mass with alpha+beta > 20 = {tight:.4f}")

    print()
    print("one coin only (the coin with three heads):")
    ws1, logs1 = hyper(M, (3,), cells)
    mode1 = max(zip(logs1, cells))[1]
    lev1, inside1 = level_set(ws1, logs1, cells, 0.68)
    print(f"           mode (alpha,beta) = ({mode1[0]:.3f}, {mode1[1]:.3f}) at the box corner"
          f"  mean = {mode1[0]/sum(mode1):.4f}")
    print(f"           68% set: alpha in [{min(p[0] for p in inside1):.2f},"
          f" {max(p[0] for p in inside1):.2f}], beta in [{min(p[1] for p in inside1):.2f},"
          f" {max(p[1] for p in inside1):.2f}]  (the box is {BOX})")
    for label, f in [("alpha/(alpha+beta)", lambda a, b: a/(a+b)),
                     ("log(alpha+beta)", lambda a, b: math.log(a+b))]:
        lo, hi = hpd_interval(ws1, cells, f)
        print(f"           {label}: 68% interval [{lo:.4f}, {hi:.4f}] width {hi-lo:.4f}")
    print(f"           mass with alpha+beta > 20 ="
          f" {sum(w for w, (a, b) in zip(ws1, cells) if a+b > 20):.4f}")
    print(f"           P(3 heads in 10) at the corner population:"
          f" {math.exp(log_beta_binom(3, M, *mode1)):.4f}"
          f"  at Beta(3,5): {math.exp(log_beta_binom(3, M, *STAMP)):.4f}"
          f"  at Beta(1,1): {1/(M+1):.4f}")

    print()
    print("box sensitivity of the ten-coin answer (alpha, beta range):")
    for box in [(0.05, 80.0), (0.1, 40.0), (0.2, 20.0)]:
        cs, _, _ = grid(box)
        w2, l2 = hyper(M, COUNTS, cs)
        md = max(zip(l2, cs))[1]
        lv, ins = level_set(w2, l2, cs, 0.68)
        print(f"  box {box}: mode ({md[0]:.3f},{md[1]:.3f})"
              f"  E[alpha+beta]={posterior_mean(w2, cs, lambda a,b: a+b):.2f}"
              f"  E[alpha/(alpha+beta)]="
              f"{posterior_mean(w2, cs, lambda a,b: a/(a+b)):.4f}"
              f"  68% alpha+beta in [{min(p[0]+p[1] for p in ins):.2f},"
              f" {max(p[0]+p[1] for p in ins):.2f}]")
    print(f"  log evidence over the box: "
          + ", ".join(f"{b}: {math.log(sum(math.exp(v) for v in hyper(M, COUNTS, grid(b)[0])[1]) / len(grid(b)[0])):.4f}"
                      for b in [(0.05, 80.0), (0.1, 40.0), (0.2, 20.0)]))

    print()
    print("marginal of log(alpha+beta), normalised, for the figure (x from -0.9 to 4.3):")
    for label, w3 in [("one coin", ws1), ("ten coins", ws)]:
        pts = marginal(w3, cells, lambda a, b: math.log(a+b), 26, -0.9, 4.3)
        print(f"  {label}: " + ", ".join(f"({x:.3f}, {y:.4f})" for x, y in pts))
    print()
    print("what the ten coins buy, against the box's own prior:")
    w_prior = [1.0 / len(cells)] * len(cells)
    for label, w3 in [("prior", w_prior), ("one coin", ws1), ("ten coins", ws)]:
        for fname, f in [("alpha/(alpha+beta)", lambda a, b: a/(a+b)),
                         ("log(alpha+beta)", lambda a, b: math.log(a+b))]:
            lo, hi = hpd_interval(w3, cells, f)
            print(f"  {label:>9} {fname:<18} 68% [{lo:.4f}, {hi:.4f}] width {hi-lo:.4f}")
    return ws1


def log_beta_sum(ws, logs, cells, a, b, level):
    for i, (x, y) in enumerate(cells):
        if abs(x - a) < 1e-9 and abs(y - b) < 1e-9:
            return f"yes (log posterior {logs[i]:.3f} vs level {level:.3f})" if logs[i] >= level \
                else f"no (log posterior {logs[i]:.3f} < level {level:.3f})"
    # nearest cell
    best = min(range(len(cells)), key=lambda i: (cells[i][0]-a)**2 + (cells[i][1]-b)**2)
    return (f"nearest grid cell ({cells[best][0]:.3f},{cells[best][1]:.3f}): "
            f"log posterior {logs[best]:.3f} vs level {level:.3f} -> "
            f"{'inside' if logs[best] >= level else 'outside'}")


# ============================================================= C. what it costs

def part_c():
    print("=" * 78)
    print("C. risk of the stamped answer against the raw frequency, as a function of theta")
    a_s, b_s = STAMP
    w = M / (M + a_s + b_s)
    mu0 = a_s / (a_s + b_s)

    def raw(t):
        return t * (1 - t) / M

    def stamped(t):
        return w * w * t * (1 - t) / M + (w * t + (1 - w) * mu0 - t) ** 2

    def diff(t):
        return stamped(t) - raw(t)

    grid_t = [i / 2000 for i in range(1, 2000)]
    cross = []
    prev = diff(grid_t[0])
    for t in grid_t[1:]:
        cur = diff(t)
        if prev * cur < 0:
            c = t - (grid_t[1]-grid_t[0])
            for _ in range(60):                      # bisection on the difference
                mid = (c + t) / 2
                if diff(c) * diff(mid) <= 0:
                    t = mid
                else:
                    c = mid
            cross.append((c + t) / 2)
        prev = cur
    print(f"weight on the count w = {w:.6f}, stamp mean = {mu0:.6f}")
    print("closed forms: raw risk = theta(1-theta)/10;"
          " stamped risk = (25/81)theta(1-theta)/10 + (16/81)(theta-3/8)^2")
    print("the two agree exactly at the roots of 432 theta^2 - 352 theta + 45 = 0:")
    disc = 352 ** 2 - 4 * 432 * 45
    print(f"  discriminant {disc}, roots at {(352-math.sqrt(disc))/864:.6f} and"
          f" {(352+math.sqrt(disc))/864:.6f}")
    for t in (0.0, 0.15, 0.375, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0):
        print(f"  theta={t:<6} raw risk={raw(t):.6f}  stamped risk={stamped(t):.6f}"
              f"  ratio={stamped(t)/raw(t) if raw(t) else float('inf'):.3f}")
    print(f"crossover(s) where the two are equal: "
          + ", ".join(f"{c:.6f}" for c in cross))
    ts = [i / 100000 for i in range(100001)]
    print(f"max raw risk over theta     = {max(raw(t) for t in ts):.6f} at theta=0.5")
    print(f"max stamped risk over theta = {max(stamped(t) for t in ts):.6f}"
          f" at theta={max(ts, key=stamped):.4f}")
    # average risk with theta drawn from the stamp
    pmf = [math.exp(log_beta_binom(h, M, a_s, b_s)) for h in range(M + 1)]
    print(f"sum of the stamp's own marginal over h = {sum(pmf):.10f}")
    b_risk = sum(pmf[h] * (a_s + h) * (b_s + M - h) / ((a_s + b_s + M) ** 2 * (a_s + b_s + M + 1))
                 for h in range(M + 1))
    raw_bayes = (mu0 * (1 - mu0) - a_s * b_s / ((a_s + b_s) ** 2 * (a_s + b_s + 1))) / M
    print(f"average risk under the stamp: stamped = {b_risk:.6f}, raw = {raw_bayes:.6f},"
          f" ratio = {raw_bayes/b_risk:.4f}")
    print(f"  as fractions: raw {raw_bayes:.6f} = 1/48 ? {abs(raw_bayes - 1/48) < 1e-12},"
          f" stamped {b_risk:.6f} = 5/432 ? {abs(b_risk - 5/432) < 1e-12}")
    print(f"  worst case: raw {max(raw(t) for t in ts):.6f} = 1/40 ?"
          f" {abs(max(raw(t) for t in ts) - 1/40) < 1e-12},"
          f" stamped {max(stamped(t) for t in ts):.6f} = 25/324 ?"
          f" {abs(max(stamped(t) for t in ts) - 25/324) < 1e-9}")
    print("risk curves for the figure, x from 0.02 to 0.98 at 25 points:")
    for label, f in [("raw", raw), ("stamped", stamped)]:
        pts = [(i / 24 * 0.96 + 0.02, f(i / 24 * 0.96 + 0.02)) for i in range(25)]
        print(f"  {label}: " + ", ".join(f"({x:.4f}, {y:.6f})" for x, y in pts))
    return raw, stamped, cross


# ================================================================ D. prediction

def part_d(ws, cells):
    print("=" * 78)
    print("D. prediction")
    a_s, b_s = STAMP
    print("one-step prices for a seen coin, stamped: (3+h)/(18+n)")
    for h in (0, 3, 8):
        print(f"  h={h}: price = {(a_s+h)/(a_s+b_s+M):.6f}")
    print("telescoping: ten tails for the 0-head coin")
    prod = 1.0
    for n in range(M):
        prod *= (b_s + n) / (a_s + b_s + n)
    direct = math.exp(log_beta_binom(0, M, a_s, b_s))
    print(f"  product of the ten one-step prices = {prod:.10f}")
    print(f"  Beta-binomial P(0 heads in 10)     = {direct:.10f}")
    print(f"  as a fraction: 7/136 ? {abs(prod - 7/136) < 1e-12}")
    print("order irrelevance: P(3 heads then 7 tails) / P(any order with 3 heads)")
    seq = 1.0
    for n in range(M):
        h_so_far = min(n, 3)
        t_so_far = n - h_so_far
        if h_so_far < 3:
            seq *= (a_s + h_so_far) / (a_s + b_s + n)
        else:
            seq *= (b_s + t_so_far) / (a_s + b_s + n)
    print(f"  one specific order = {seq:.10f}   pmf(3)/C(10,3) ="
          f" {math.exp(log_beta_binom(3, M, a_s, b_s))/math.comb(M,3):.10f}")
    print(f"  next flip after eight heads = {(a_s+8)/18:.6f}"
          f"  (the stamped mean of that coin)")
    print()
    print("a new coin from the box")
    print(f"  stamped: P(heads) = alpha/(alpha+beta) = {a_s/(a_s+b_s):.6f} (3/8, exactly)")
    pmean = posterior_mean(ws, cells, lambda a, b: a / (a + b))
    print(f"  ten coins, integrating the stamp: {pmean:.6f}")
    seen = [posterior_mean(ws, cells, lambda a, b, h=h: (a + h) / (a + b + M)) for h in COUNTS]
    print(f"  the ten seen coins' posterior means average {sum(seen)/len(seen):.6f}"
          f"  (range {min(seen):.4f} to {max(seen):.4f})")
    print()
    print("predictive count of a NEW coin: stamp, mixture of stamps, plug-in at the mode")
    mode = max(zip(*hyper(M, COUNTS, cells)[::-1]))[1] if False else None
    ws_l, logs_l = hyper(M, COUNTS, cells)
    mode = max(zip(logs_l, cells))[1]
    plug = [math.exp(log_beta_binom(h, M, *mode)) for h in range(M + 1)]
    mix = []
    for h in range(M + 1):
        mix.append(sum(w * math.exp(log_beta_binom(h, M, a, b))
                       for w, (a, b) in zip(ws_l, cells)))
    stamp = [math.exp(log_beta_binom(h, M, a_s, b_s)) for h in range(M + 1)]
    for label, v in [("stamp", stamp), ("mixture", mix), ("plug-in", plug)]:
        mean = sum(h * p for h, p in enumerate(v))
        var = sum((h - mean) ** 2 * p for h, p in enumerate(v))
        print(f"  {label:>8}: sum={sum(v):.8f} mean={mean:.4f} sd={math.sqrt(var):.4f}"
              f" P(h>=7)={sum(v[7:]):.4f} P(h<=1)={sum(v[:2]):.4f}"
              f" P(h=5)={v[5]:.4f}")
    # variance decomposition on the theta scale, new coin
    e_var = posterior_mean(ws_l, cells, lambda a, b: a * b / ((a + b) ** 2 * (a + b + 1)))
    var_mean = posterior_mean(ws_l, cells, lambda a, b: (a / (a + b)) ** 2) - pmean ** 2
    print(f"  new coin theta: E[Var]={e_var:.6f} Var[E]={var_mean:.6f}"
          f" total={e_var+var_mean:.6f} sd={math.sqrt(e_var+var_mean):.4f}")
    seen_var = posterior_mean(ws_l, cells,
                              lambda a, b: ((a + 3) * (b + 7) / ((a + b + M) ** 2 * (a + b + M + 1))))
    seen_mean = posterior_mean(ws_l, cells, lambda a, b: (a + 3) / (a + b + M))
    seen_var_tot = posterior_mean(ws_l, cells, lambda a, b: (a + 3) * (b + 7)
                                  / ((a + b + M) ** 2 * (a + b + M + 1))) \
        + posterior_mean(ws_l, cells, lambda a, b: ((a + 3) / (a + b + M)) ** 2) - seen_mean ** 2
    print(f"  seen coin (3 heads): theta mean={seen_mean:.4f} sd={math.sqrt(seen_var_tot):.4f}")
    print()
    print("the same three columns for ONE coin (three heads in ten):")
    ws1, logs1 = hyper(M, (3,), cells)
    mode1 = max(zip(logs1, cells))[1]
    plug1 = [math.exp(log_beta_binom(h, M, *mode1)) for h in range(M + 1)]
    mix1 = [sum(w * math.exp(log_beta_binom(h, M, a, b)) for w, (a, b) in zip(ws1, cells))
            for h in range(M + 1)]
    for label, v in [("mixture", mix1), ("plug-in", plug1)]:
        mean = sum(h * p for h, p in enumerate(v))
        var = sum((h - mean) ** 2 * p for h, p in enumerate(v))
        print(f"  {label:>8}: mean={mean:.4f} sd={math.sqrt(var):.4f}"
              f" P(h<=1)={v[0]+v[1]:.4f} P(h>=7)={sum(v[7:]):.4f} P(h=5)={v[5]:.4f}"
              f"  (plug-in population Beta({mode1[0]:.2f},{mode1[1]:.2f}))")
    print("ten-coin rows, for the same table:")
    for label, v in [("label", stamp), ("mixture", mix), ("plug-in", plug)]:
        mean = sum(h * p for h, p in enumerate(v))
        var = sum((h - mean) ** 2 * p for h, p in enumerate(v))
        print(f"  {label:>8}: mean={mean:.4f} sd={math.sqrt(var):.4f}"
              f" P(h<=1)={v[0]+v[1]:.4f} P(h>=7)={sum(v[7:]):.4f} P(h=5)={v[5]:.4f}")


# ================================================================= E. evidence

def log_evidence_models(counts, m=M):
    """Log marginal likelihood of five models of the same counts."""
    cells, cw, _ = grid()
    out = {}

    # 1. one shared bias, uniform prior
    tot_h, tot_n = sum(counts), m * len(counts)
    out["one shared bias"] = (sum(log_binom(m, h) for h in counts)
                              + log_beta(tot_h + 1, tot_n - tot_h + 1))
    # 2. the stamped population
    out["stamped Beta(3,5)"] = sum(log_beta_binom(h, m, *STAMP) for h in counts)
    # 3. population with the log-uniform hyperprior
    _, logs = hyper(m, counts, cells)
    out["population, learned"] = math.log(sum(math.exp(v) for v in logs) * cw)
    # 4. each coin free, uniform prior
    out["each coin free, uniform"] = sum(log_beta_binom(h, m, 1.0, 1.0) for h in counts)
    # 5. each coin free, Beta(3,5) prior
    out["each coin free, Beta(3,5)"] = sum(log_beta_binom(h, m, *STAMP) for h in counts)

    # 6. two groups: each coin's bias is l or h with probability a half each
    half = 0.5
    ng = 241
    acc = 0.0
    cell = 1.0 / (ng * ng)
    for i in range(ng):
        p = (i + 0.5) / ng
        for j in range(ng):
            q = (j + 0.5) / ng
            tot = 0.0
            for h in counts:
                lp = log_binom_pmf(h, m, p)
                lq = log_binom_pmf(h, m, q)
                mx = max(lp, lq)
                tot += mx + math.log(half * math.exp(lp - mx) + half * math.exp(lq - mx))
            acc += math.exp(tot) * cell
    out["two groups, learned"] = math.log(acc)
    return out


def part_e():
    print("=" * 78)
    print("E. evidence: the marginal likelihood of six models of the same coins")
    for name, counts in [("ten coins, heads " + str(COUNTS), COUNTS),
                         ("two factories, heads " + str(TWO_FACTORY), TWO_FACTORY)]:
        print(f"-- {name}")
        ev = log_evidence_models(counts)
        best = max(ev.values())
        for k in sorted(ev, key=lambda k: -ev[k]):
            print(f"     {ev[k]:>10.4f} nats   {ev[k]-best:>9.4f} nats vs best   {k}")
    print()
    print("the free-coin model's sensitivity to its own prior (ten coins):")
    for lab, prior in [("uniform", (1.0, 1.0)), ("Beta(3,5)", STAMP), ("Beta(6,10)", (6.0, 10.0))]:
        print(f"     {lab:>9}: {sum(log_beta_binom(h, M, *prior) for h in COUNTS):.4f} nats")
    print()
    print("the population model's evidence against the width of its own box (ten coins):")
    for box in [(0.9, 1.1), (0.5, 2.0), (0.2, 20.0), (0.1, 40.0), (0.05, 80.0)]:
        cs, cw2, _ = grid(box)
        _, logs = hyper(M, COUNTS, cs)
        print(f"     box {box}: {math.log(sum(math.exp(v) for v in logs) * cw2):.4f} nats"
              f"   (the uniform shape alone: {sum(log_beta_binom(h, M, 1.0, 1.0) for h in COUNTS):.4f})")


# =========================================================== F. two-factory box

def part_f():
    print("=" * 78)
    print("F. a box that holds two kinds of coin")
    cells, cw, _ = grid()
    ws, logs = hyper(M, TWO_FACTORY, cells)
    mode = max(zip(logs, cells))[1]
    print(f"counts {TWO_FACTORY}")
    print(f"fitted population: mode (alpha,beta) = ({mode[0]:.3f}, {mode[1]:.3f})"
          f" -> mean {mode[0]/sum(mode):.4f}, sd"
          f" {math.sqrt(mode[0]*mode[1]/(sum(mode)**2*(sum(mode)+1))):.4f}")
    lev, inside = level_set(ws, logs, cells, 0.68)
    print(f"  68% set: alpha in [{min(p[0] for p in inside):.2f},"
          f" {max(p[0] for p in inside):.2f}], beta in [{min(p[1] for p in inside):.2f},"
          f" {max(p[1] for p in inside):.2f}]")
    print(f"  E[alpha/(alpha+beta)] = {posterior_mean(ws, cells, lambda a,b: a/(a+b)):.4f}")
    mix = [sum(w * math.exp(log_beta_binom(h, M, a, b)) for w, (a, b) in zip(ws, cells))
           for h in range(M + 1)]
    stamp = [math.exp(log_beta_binom(h, M, *STAMP)) for h in range(M + 1)]
    plug = [math.exp(log_beta_binom(h, M, *mode)) for h in range(M + 1)]
    truth = [0.5 * math.exp(log_binom_pmf(h, M, 0.15)) + 0.5 * math.exp(log_binom_pmf(h, M, 0.85))
             for h in range(M + 1)]
    print(f"{'h':>3} {'mixture':>9} {'plug-in':>9} {'stamp':>9} {'truth':>9}")
    for h in range(M + 1):
        print(f"{h:>3} {mix[h]:>9.4f} {plug[h]:>9.4f} {stamp[h]:>9.4f} {truth[h]:>9.4f}")
    print(f"sums: {sum(mix):.8f} {sum(plug):.8f} {sum(stamp):.8f} {sum(truth):.8f}")
    print(f"P(a new coin lands on 5 heads): mixture {mix[5]:.4f}, plug-in {plug[5]:.4f},"
          f" stamp {stamp[5]:.4f}, truth {truth[5]:.4f}")
    print(f"P(1 or fewer): mixture {mix[0]+mix[1]:.4f}, truth {truth[0]+truth[1]:.4f}")
    print(f"P(9 or more): mixture {mix[9]+mix[10]:.4f}, truth {truth[9]+truth[10]:.4f}")
    print("predictive pmf for the figure:")
    for label, v in [("mixture", mix), ("truth", truth)]:
        print(f"  {label}: " + ", ".join(f"({h}, {p:.4f})" for h, p in enumerate(v)))
    print()
    print("what the fit says about the two coins at the ends")
    for h in (0, 10):
        mu = posterior_mean(ws, cells, lambda a, b, h=h: (a + h) / (a + b + M))
        stamped = (STAMP[0] + h) / (STAMP[0] + STAMP[1] + M)
        print(f"  h={h:>2}: fitted posterior mean {mu:.4f}, stamped {stamped:.4f},"
              f" raw {h/M:.2f}")


# ============================================================ G. independent checks

def part_g():
    """Every identity the note leans on, recomputed by a second route."""
    print("=" * 78)
    print("G. checks: each identity by a route that shares no code with the one above")
    a_s, b_s = STAMP

    # 1. conjugacy: the product of likelihood and prior, normalised on a theta grid
    n, lo, hi = 400001, 1e-7, 1 - 1e-7
    step = (hi - lo) / (n - 1)
    for h in (0, 3, 8):
        pts = [(lo + i * step) for i in range(n)]
        dens = [math.exp(h * math.log(t) + (M - h) * math.log1p(-t)
                         + (a_s - 1) * math.log(t) + (b_s - 1) * math.log1p(-t)) for t in pts]
        z = sum(dens) * step
        mean = sum(d * t for d, t in zip(dens, pts)) * step / z
        var = sum(d * (t - mean) ** 2 for d, t in zip(dens, pts)) * step / z
        print(f"  h={h}: numeric mean {mean:.10f} vs (3+h)/18 = {(a_s+h)/18:.10f}"
              f"  numeric sd {math.sqrt(var):.10f} vs"
              f" {math.sqrt((a_s+h)*(b_s+M-h)/((a_s+b_s+M)**2*(a_s+b_s+M+1))):.10f}")

    # 2. the one-step price by the augmentation route, and the telescoped record
    for h in (0, 3, 8):
        num = math.exp(log_beta_binom(h + 1, M + 1, a_s, b_s)) * (h + 1) / (M + 1)
        den = math.exp(log_beta_binom(h, M, a_s, b_s))
        print(f"  price of heads after {h} of 10, by augmentation = {num/den:.10f}"
              f" vs posterior mean {(a_s+h)/18:.10f}")

    # 3. every ordering of a record has the same probability
    import itertools
    tot = {}
    for seq in itertools.permutations("HHHTTTTTTT"):
        p, hh, tt = 1.0, 0, 0
        for c in seq:
            p *= (a_s + hh) / (a_s + b_s + hh + tt) if c == "H" else (b_s + tt) / (a_s + b_s + hh + tt)
            hh, tt = hh + (c == "H"), tt + (c == "T")
        tot[seq] = p
    print(f"  all {len(tot)} orderings of 3 heads in 10: min {min(tot.values()):.10f},"
          f" max {max(tot.values()):.10f}"
          f"  (pmf(3)/C(10,3) ="
          f" {math.exp(log_beta_binom(3, M, a_s, b_s))/math.comb(M,3):.10f})")

    # 4. the risk closed form against the direct sum over the binomial counts
    w = M / (M + a_s + b_s)
    worst = 0.0
    for i in range(0, 1001):
        t = i / 1000
        direct = sum(math.exp(log_binom_pmf(h, M, t)) * ((a_s + h) / 18 - t) ** 2
                     for h in range(M + 1))
        closed = w * w * t * (1 - t) / M + (1 - w) ** 2 * (t - a_s / (a_s + b_s)) ** 2
        worst = max(worst, abs(direct - closed))
    print(f"  risk: worst disagreement between the closed form and the sum over h = {worst:.3e}")
    print(f"  risk at theta=0 (a coin that never shows heads):"
          f" {(1-w)**2*(a_s/(a_s+b_s))**2:.10f} = 1/36 ?"
          f" {abs((1-w)**2*(a_s/(a_s+b_s))**2 - 1/36) < 1e-12}")


if __name__ == "__main__":
    ws, logs, cells = part_a()
    part_b(ws, logs, cells)
    part_c()
    part_d(ws, cells)
    part_e()
    part_f()
    part_g()
