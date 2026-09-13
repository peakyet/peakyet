// ---------------------------------------------------------------------------
// demo_francis.mjs — the core math for the in-page bulge-chase demo.
// A direct JavaScript port of scripts/verify_francis.py (same algorithm, same
// LAPACK DLAHQR semantics). Works in Node (for testing) and in the browser
// (the page inlines this code).
// ---------------------------------------------------------------------------

export function mmul(A, B) {
  const n = A.length, p = B[0].length, k = B.length;
  const C = [];
  for (let i = 0; i < n; i++) {
    C.push([]);
    for (let j = 0; j < p; j++) {
      let s = 0;
      for (let t = 0; t < k; t++) s += A[i][t] * B[t][j];
      C[i].push(s);
    }
  }
  return C;
}

export function matT(A) {
  return A[0].map((_, j) => A.map(row => row[j]));
}

export function eye(n) {
  return Array.from({ length: n }, (_, i) =>
    Array.from({ length: n }, (_, j) => (i === j ? 1 : 0)));
}

export function vecnorm(v) {
  let s = 0;
  for (const x of v) s += x * x;
  return Math.sqrt(s);
}

// DLARFG semantics: H = I - tau*v*v' maps x -> beta*e1, beta = -sign(x0)|x|
export function dlarfg(x) {
  const alpha = x[0];
  let xnorm = 0;
  for (let i = 1; i < x.length; i++) xnorm += x[i] * x[i];
  xnorm = Math.sqrt(xnorm);
  if (xnorm === 0) {
    const v = [1.0].concat(new Array(x.length - 1).fill(0));
    return { beta: alpha, v, tau: 0 };
  }
  const sign_a = alpha >= 0 ? 1 : -1;
  const beta = -sign_a * Math.hypot(alpha, xnorm);
  const tau = (beta - alpha) / beta;
  const v = [1.0];
  for (let i = 1; i < x.length; i++) v.push(x[i] / (alpha - beta));
  return { beta, v, tau };
}

// apply H = I - tau*v*v' (v[0]==1) to rows/cols m..m+len(v)-1 of a full matrix
export function applyH(A, m, v, tau, left) {
  const n = A.length, k = v.length;
  if (left) {
    for (let j = 0; j < n; j++) {
      let s = 0;
      for (let t = 0; t < k; t++) s += v[t] * A[m + t][j];
      for (let t = 0; t < k; t++) A[m + t][j] -= tau * v[t] * s;
    }
  } else {
    for (let i = 0; i < n; i++) {
      let s = 0;
      for (let t = 0; t < k; t++) s += A[i][m + t] * v[t];
      for (let t = 0; t < k; t++) A[i][m + t] -= tau * v[t] * s;
    }
  }
}

export function clone(A) { return A.map(r => r.slice()); }

// DLAHQR's Wilkinson shift from the trailing 2x2 at rows k-1,k
export function wilkinsonShift(A, k) {
  const h11 = A[k - 1][k - 1], h12 = A[k - 1][k];
  const h21 = A[k][k - 1],   h22 = A[k][k];
  let s = Math.abs(h11) + Math.abs(h12) + Math.abs(h21) + Math.abs(h22);
  if (s === 0) return { rt1r: 0, rt1i: 0, rt2r: 0, rt2i: 0, complex: false };
  const a = h11 / s, b = h21 / s, c = h12 / s, d = h22 / s;
  const tr = (a + d) / 2;
  const det = (a - tr) * (d - tr) - c * b;
  const rtdisc = Math.sqrt(Math.abs(det));
  if (det >= 0) return { rt1r: tr * s, rt1i: rtdisc * s, rt2r: tr * s, rt2i: -rtdisc * s, complex: true };
  const r1 = (tr + rtdisc) * s, r2 = (tr - rtdisc) * s;
  if (Math.abs(r1 - d * s) <= Math.abs(r2 - d * s)) return { rt1r: r1, rt1i: 0, rt2r: r1, rt2i: 0, complex: false };
  return { rt1r: r2, rt1i: 0, rt2r: r2, rt2i: 0, complex: false };
}

// DLAHQR's first shift vector: first 3 entries of (A-mu1)(A-mu2) e1, scaled
export function firstVector(A, m, rt1r, rt1i, rt2r, rt2i) {
  let h21s = A[m + 1][m];
  let s = Math.abs(A[m][m] - rt2r) + Math.abs(rt2i) + Math.abs(h21s);
  h21s = h21s / s;
  const v1 = h21s * A[m][m + 1]
    + (A[m][m] - rt1r) * ((A[m][m] - rt2r) / s) - rt1i * (rt2i / s);
  const v2 = h21s * (A[m][m] + A[m + 1][m + 1] - rt1r - rt2r);
  const v3 = h21s * A[m + 2][m + 1];
  s = Math.abs(v1) + Math.abs(v2) + Math.abs(v3);
  return [v1 / s, v2 / s, v3 / s];
}

// entries below the first subdiagonal that exceed tol
export function belowSubdiag(A, tol = 1e-9) {
  const out = [];
  for (let i = 0; i < A.length; i++)
    for (let j = 0; j < i - 1; j++)
      if (Math.abs(A[i][j]) > tol) out.push([i, j]);
  return out;
}

// one implicit Francis double-shift step (DLAHQR loop bounds); returns
// { A, Q, trace, shifts, Vfirst } -- trace[k] is the matrix after reflector k
export function implicitStep(Ain, m = 0) {
  const A = clone(Ain);
  const n = A.length;
  const Q = eye(n);
  const trace = [];
  const sh = wilkinsonShift(A, n - 1);
  const Vfirst = firstVector(A, m, sh.rt1r, sh.rt1i, sh.rt2r, sh.rt2i);
  for (let K = m; K < n - 1; K++) {
    const NR = Math.min(3, n - K);
    let V;
    if (K > m) {
      V = [A[K][K - 1], A[K + 1][K - 1]];
      if (NR === 3) V.push(A[K + 2][K - 1]);
    } else {
      V = Vfirst.slice();
    }
    const { beta, v, tau } = dlarfg(V);
    if (Math.abs(tau) < 1e-300) continue;
    if (K > m) {
      A[K][K - 1] = beta;
      A[K + 1][K - 1] = 0;
      if (NR === 3) A[K + 2][K - 1] = 0;
    }
    // left: rows K..K+NR-1 x columns K..n-1
    for (let j = K; j < n; j++) {
      let s = 0;
      for (let t = 0; t < NR; t++) s += v[t] * A[K + t][j];
      for (let t = 0; t < NR; t++) A[K + t][j] -= tau * v[t] * s;
    }
    // right: columns K..K+NR-1 x rows 0..min(K+3,n-1)
    const hi = Math.min(K + 3, n - 1);
    for (let i = 0; i <= hi; i++) {
      let s = 0;
      for (let t = 0; t < NR; t++) s += A[i][K + t] * v[t];
      for (let t = 0; t < NR; t++) A[i][K + t] -= tau * v[t] * s;
    }
    applyH(Q, K, v, tau, false);          // Q = Q * H
    trace.push(clone(A));
  }
  return { A, Q, trace, shifts: sh, Vfirst };
}

// explicit double shift: N = (A-mu1)(A-mu2) is REAL for mu1=conj(mu2);
// real QR of N, then A' = Q^T A Q
export function explicitStep(Ain, mu1r, mu1i, mu2r, mu2i) {
  const A = clone(Ain);
  const n = A.length;
  // N = (A - mu1 I)(A - mu2 I) in complex, drop the (zero) imaginary part
  const N = [];
  for (let i = 0; i < n; i++) {
    N.push([]);
    for (let j = 0; j < n; j++) {
      let r = 0, im = 0;
      for (let t = 0; t < n; t++) {
        const a1r = A[i][t] - ((i === t) ? mu1r : 0);
        const a1i = (i === t) ? -mu1i : 0;
        const a2r = A[t][j] - ((t === j) ? mu2r : 0);
        const a2i = (t === j) ? -mu2i : 0;
        r += a1r * a2r - a1i * a2i;
        im += a1r * a2i + a1i * a2r;
      }
      N[i].push(r);
    }
  }
  const Q = eye(n);
  const R = clone(N);
  for (let k = 0; k < n - 1; k++) {
    const x = [R[k][k]];
    for (let i = k + 1; i < n; i++) x.push(R[i][k]);
    const { beta, v, tau } = dlarfg(x);
    if (Math.abs(tau) < 1e-300) continue;
    applyH(R, k, v, tau, true);
    applyH(Q, k, v, tau, false);
  }
  const Ap = mmul(matT(Q), mmul(A, Q));
  return { A: Ap, Q, N };
}

// min over sign vectors s of ||B - diag(s) C diag(s)||_F  (implicit-Q-theorem
// ambiguity).  n must be small (<= 8).
export function bestSignDiff(B, C) {
  const n = B.length;
  let best = Infinity;
  for (let mask = 0; mask < (1 << n); mask++) {
    let d = 0;
    for (let i = 0; i < n; i++)
      for (let j = 0; j < n; j++) {
        const si = ((mask >> i) & 1) ? -1 : 1;
        const sj = ((mask >> j) & 1) ? -1 : 1;
        const t = B[i][j] - si * sj * C[i][j];
        d += t * t;
      }
    if (d < best) best = d;
  }
  return Math.sqrt(best);
}

// the 6x6 demo matrix: real Hessenberg, trailing 2x2 block [[0,-1],[2,0]]
// whose eigenvalues are the complex-conjugate pair +/- i sqrt(2).
export function demoMatrix() {
  return [
    [1, 2, 3, 4, 5, 6],
    [1, 1, 1, 1, 1, 1],
    [0, 1, 2, 1, 1, 1],
    [0, 0, 1, 0, -1, 1],
    [0, 0, 0, 1, 0, -1],
    [0, 0, 0, 0, 2, 0],
  ].map(r => r.map(x => x * 1.0));
}