# bezier_hull.py — proves: for a Bezier curve, control points inside a box
# guarantee the WHOLE curve inside (convex hull property). An interpolating
# spline through the same points gives no such guarantee — it escapes the box.
# Run: python3 bezier_hull.py

import random
random.seed(7)

def bezier(cp, t):
    """de Casteljau evaluation of a Bezier curve, any order."""
    pts = list(cp)
    while len(pts) > 1:
        pts = [((1 - t) * p[0] + t * q[0], (1 - t) * p[1] + t * q[1])
               for p, q in zip(pts, pts[1:])]
    return pts[0]

def catmull_rom(p0, p1, p2, p3, t):
    """Interpolating spline: passes THROUGH p1, p2 (same 4 points)."""
    t2, t3 = t * t, t * t * t
    return tuple(0.5 * (2 * p1[i] + (-p0[i] + p2[i]) * t
                        + (2 * p0[i] - 5 * p1[i] + 4 * p2[i] - p3[i]) * t2
                        + (-p0[i] + 3 * p1[i] - 3 * p2[i] + p3[i]) * t3)
                 for i in (0, 1))

box = (0.0, 0.0, 1.0, 1.0)                      # "corridor": a convex free box
inside = lambda p: box[0] <= p[0] <= box[2] and box[1] <= p[1] <= box[3]

n_cfg, n_s = 5000, 300                          # configs, samples per curve
bez_bad = cr_bad = 0
bez_worst = cr_worst = 0.0
for _ in range(n_cfg):
    cp = [(random.random(), random.random()) for _ in range(4)]
    for k in range(n_s):
        t = k / (n_s - 1)
        b = bezier(cp, t)
        c = catmull_rom(*cp, t)
        if not inside(b):
            bez_bad += 1
            bez_worst = max(bez_worst, box[1] - b[1], b[1] - box[3])
        if not inside(c):
            cr_bad += 1
            cr_worst = max(cr_worst, box[1] - c[1], c[1] - box[3])

total = n_cfg * n_s
print(f"{total:,} sampled points on each curve family")
print(f"Bezier:        {bez_bad:>6} points outside the box "
      f"(worst overshoot {bez_worst:.3f} m)")
print(f"Catmull-Rom:   {cr_bad:>6} points outside the box "
      f"(worst overshoot {cr_worst:.3f} m)")
