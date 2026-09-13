// Node cross-check: the JavaScript port must reproduce the Python-verified
// numbers (see the trace dumped from verify_francis.py with the same matrix).
import {
  bestSignDiff, belowSubdiag, demoMatrix, explicitStep, firstVector,
  implicitStep, mmul, vecnorm,
} from "./demo_francis.mjs";

let failures = 0;
function check(name, got, want, tol) {
  const ok = Math.abs(got - want) <= tol;
  if (!ok) failures++;
  console.log(`${ok ? "ok  " : "FAIL"} ${name}: got ${got.toExponential(4)}, want ${want.toExponential(4)} (tol ${tol})`);
}
function checkArr(name, got, want, tol) {
  const ok = got.length === want.length &&
    got.every((g, i) => Math.abs(g - want[i]) <= tol);
  if (!ok) failures++;
  console.log(`${ok ? "ok  " : "FAIL"} ${name}: [${got.map(x => x.toFixed(6))}]`);
}

const A0 = demoMatrix();

// 1. Wilkinson shifts of the trailing 2x2 [[0,-1],[2,0]]  ->  +/- i sqrt(2)
const sh = implicitStep(A0).shifts;
check("shift real part", sh.rt1r, 0, 1e-9);
check("shift imag part (sqrt(2))", sh.rt1i, Math.SQRT2, 1e-9);
check("conj shift imag part", sh.rt2i, -Math.SQRT2, 1e-9);

// 2. first shift vector V = (0.625, 0.25, 0.125)  -- (N e1)/8 for this matrix
const Vf = firstVector(A0, 0, sh.rt1r, sh.rt1i, sh.rt2r, sh.rt2i);
checkArr("Vfirst", Vf, [0.625, 0.25, 0.125], 1e-12);

// 3. bulge staircase
const step = implicitStep(A0, 0);
const wantBulge = [
  [[2, 0], [3, 0], [3, 1]],
  [[3, 1], [4, 1], [4, 2]],
  [[4, 2], [5, 2], [5, 3]],
  [[5, 3]],
  [],
];
step.trace.forEach((T, idx) => {
  const got = belowSubdiag(T).map(p => p.join(",")).join(";");
  const want = wantBulge[idx].map(p => p.join(",")).join(";");
  if (got !== want) failures++;
  console.log(`${got === want ? "ok  " : "FAIL"} bulge after reflector ${idx + 1}: ${got === "" ? "[]" : got}`);
});

// 4. final matrix matches the Python-verified trace
const finalWant = [
  [2.66667, 3.93765, 3.91061, 6.09315, 3.03998, 3.88454],
  [0.62361, 0.30476, 0.03352, -0.97069, -0.48204, -1.09093],
  [0.0, 1.25438, 1.21067, 0.45173, 0.22763, -0.11729],
  [0.0, 0.0, 0.55470, 0.42664, 0.96725, 0.86373],
  [0.0, 0.0, 0.0, -0.99917, -0.36264, 1.91537],
  [0.0, 0.0, 0.0, 0.0, -1.20271, -0.24610],
];
const dFinal = Math.sqrt(
  step.A.flatMap((row, i) => row.map((x, j) => (x - finalWant[i][j]) ** 2)).reduce((a, b) => a + b, 0));
check("final matrix vs Python trace (Frobenius)", dFinal, 0, 5e-5);
check("final matrix is Hessenberg again", belowSubdiag(step.A).length, 0, 0);

// 5. implicit == explicit up to sign ambiguity
const exp = explicitStep(A0, sh.rt1r, sh.rt1i, sh.rt2r, sh.rt2i);
const dBest = bestSignDiff(step.A, exp.A);
check("||A_imp - D A_exp D||_F (best signs)", dBest, 0, 1e-12);

// 6. first column of Q is -N e1 / ||N e1|| (direction identity)
const q1 = step.Q.map(r => r[0]);
const q1n = vecnorm(q1);
const dir = q1[0] >= 0 ? 1 : -1;   // Q e1 = +/- N e1 / ||N e1||; here it is negative
const dQ = Math.sqrt(
  q1.slice(0, 3).reduce((s, v, i) => s + (dir * v / q1n - [5, 2, 1][i] / Math.sqrt(30)) ** 2, 0));
check("|sgn*Q e1 - N e1/||N e1||| (rows 0..2)", dQ, 0, 1e-12);

console.log(failures === 0 ? "\nALL JS CHECKS PASSED" : `\n${failures} FAILURES`);
process.exit(failures === 0 ? 0 : 1);