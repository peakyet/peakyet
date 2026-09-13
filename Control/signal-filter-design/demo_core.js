/* demo_core.js — pure math used by the interactive demos.
 * Mirrors filter_design.py (see report.txt for the verified numbers). */
"use strict";
var TAU = Math.PI * 2;

/* ---- the running loop: P = 20/(0.05s+1), PI zero at 4 Hz, crossover 20 Hz ---- */
var KP = 0.31188;          // V per rad/s  (report: 0.3119)
var KI = 7.8398;           // V per rad
var WZ = TAU * 4;          // PI zero, rad/s

function cmul(a, b, c, d) { return [a * c - b * d, a * d + b * c]; }
function cdiv(a, b, c, d) { var den = c * c + d * d; return [(a * c + b * d) / den, (b * c - a * d) / den]; }
function cabs(a, b) { return Math.hypot(a, b); }
function cdeg(a, b) { return Math.atan2(b, a) * 180 / Math.PI; }

/* Loop transmission L(jw) = C·P·H  (wn falsy => no filter) */
function Lloop(w, wn) {
  var cre = KP, cim = -KP * WZ / w;             // C = KP(1 + WZ/s), s = jw
  var pd = cdiv(1, 0, 1, 0.05 * w);             // P = 20/(1 + 0.05 jw)
  var L = cmul(cre, cim, 20 * pd[0], 20 * pd[1]);
  if (wn) {
    var h = cdiv(wn * wn, 0, wn * wn - w * w, Math.SQRT2 * wn * w);
    L = cmul(L[0], L[1], h[0], h[1]);
  }
  return L;
}

/* Crossover (|L|=1, bisection) and phase margin */
function margins(wn) {
  var lo = 0.01, hi = 1e6;
  for (var i = 0; i < 200; i++) {
    var mid = Math.sqrt(lo * hi);
    if (cabs.apply(null, Lloop(mid, wn)) > 1) lo = mid; else hi = mid;
  }
  var wc = Math.sqrt(lo * hi);
  var L = Lloop(wc, wn);
  var pm = 180 + cdeg(L[0], L[1]);
  if (pm > 180) pm -= 360;                     // unwrap (deep instability)
  return { wc: wc, pm: pm };
}

/* Butterworth H(jw): n poles on the circle of radius wn */
function butterH(w, wn, n) {
  var dr = 1, di = 0;                            // prod(jw - p_k)
  for (var k = 1; k <= n; k++) {
    var th = Math.PI * (2 * k + n - 1) / (2 * n);
    var pr = wn * Math.cos(th), pi = wn * Math.sin(th);
    var nr = dr * (-pr) - di * (w - pi);
    var ni = dr * (w - pi) + di * (-pr);
    dr = nr; di = ni;
  }
  var mag = Math.pow(wn, n) / Math.hypot(dr, di);
  var ph = -Math.atan2(di, dr);                  // numerator is real positive
  return { mag: mag, ph: ph };
}

/* Bilinear transform (with prewarp) of the 2nd-order Butterworth section */
function bilinearCoeffs(fs, fcorner) {
  var K = 2 * fs;
  var wd = 2 * fs * Math.tan(TAU * fcorner / (2 * fs));
  var D = K * K + Math.SQRT2 * wd * K + wd * wd;
  return {
    b0: wd * wd / D, b1: 2 * wd * wd / D, b2: wd * wd / D,
    a1: (-2 * K * K + 2 * wd * wd) / D,
    a2: (K * K - Math.SQRT2 * wd * K + wd * wd) / D,
    wdHz: wd / TAU
  };
}

/* -3 dB corner of a discrete filter, found by scan + bisect (last crossing) */
function discreteCorner(evalMag, fmax) {
  var n = 2000, fs0 = 0.5, fs1 = fmax * 0.999, i;
  var below = [];
  for (i = 0; i < n; i++) {
    var f = fs0 * Math.pow(fs1 / fs0, i / (n - 1));
    below.push(evalMag(f) <= 1 / Math.SQRT2 ? 1 : 0);
  }
  i = n - 1;
  while (i > 0 && !below[i]) i--;
  while (i > 0 && below[i]) i--;
  var lo = fs0 * Math.pow(fs1 / fs0, i / (n - 1));
  var hi = fs0 * Math.pow(fs1 / fs0, (i + 1) / (n - 1));
  for (var it = 0; it < 60; it++) {
    var mid = Math.sqrt(lo * hi);
    if (evalMag(mid) > 1 / Math.SQRT2) lo = mid; else hi = mid;
  }
  return Math.sqrt(lo * hi);
}

/* alpha-filter magnitude: H(e^{jwT}) = (1-a)/(e^{jwT}-a) */
function alphaMag(f, alpha, fs) {
  var th = TAU * f / fs;
  return (1 - alpha) / Math.hypot(Math.cos(th) - alpha, Math.sin(th));
}
function biquadMag(f, c, fs) {
  var th = TAU * f / fs, c1 = Math.cos(th), s1 = Math.sin(th), c2 = Math.cos(2 * th), s2 = Math.sin(2 * th);
  var nr = c.b0 + c.b1 * c1 + c.b2 * c2, ni = -(c.b1 * s1 + c.b2 * s2);
  var dr = 1 + c.a1 * c1 + c.a2 * c2, di = -(c.a1 * s1 + c.a2 * s2);
  return Math.hypot(nr, ni) / Math.hypot(dr, di);
}

/* Closed-loop Euler simulation of the motor speed loop.
 * mode=false: no filter; mode=true: 2nd-order Butterworth at fcorner on the measurement.
 * Returns decimated {t, ref, vp, u} plus summary stats. */
function simLoop(mode, fcorner, T, dt, decim) {
  var wn = mode ? TAU * fcorner : 0;
  var n = Math.round(T / dt);
  var vp = 0, xi = 0, f1 = 0, f2 = 0;
  var ts = [], ref = [], vps = [], us = [];
  var usum = 0, u2 = 0, ucnt = 0, peak = 0;
  for (var i = 0; i < n; i++) {
    var t = i * dt;
    var r = t >= 0.02 ? 10 : 0;
    var noise = 0.30 * Math.sin(TAU * 300 * t) + 0.20 * Math.sin(TAU * 1200 * t)
              + 0.15 * Math.sin(TAU * 19400 * t);
    var raw = vp + noise;
    var ym;
    if (mode) {
      f2 += (raw - Math.SQRT2 * wn * f2 - wn * wn * f1) * dt;
      f1 += f2 * dt;
      ym = wn * wn * f1;
    } else {
      ym = raw;
    }
    var u = KP * (r - ym) + KI * xi;
    xi += (r - ym) * dt;
    vp += (-vp + 20 * u) / 0.05 * dt;
    peak = Math.max(peak, vp);
    if (i % decim === 0) { ts.push(t); ref.push(r); vps.push(vp); us.push(u); }
    if (t > 0.3) { usum += u; u2 += u * u; ucnt++; }
  }
  var um = usum / ucnt;
  return {
    t: ts, ref: ref, vp: vps, u: us,
    overshoot: 100 * (peak - 10) / 10,
    uRipple: Math.sqrt(u2 / ucnt - um * um),
    pm: margins(mode ? TAU * fcorner : null).pm
  };
}

if (typeof module !== "undefined") {
  module.exports = { TAU: TAU, KP: KP, KI: KI, WZ: WZ, Lloop: Lloop, margins: margins,
    butterH: butterH, bilinearCoeffs: bilinearCoeffs, discreteCorner: discreteCorner,
    alphaMag: alphaMag, biquadMag: biquadMag, simLoop: simLoop };
}
