# Designing a Filter for a Signal in a Control Loop — summary

The companion HTML (`signal-filter-design.html`) is the full lesson with figures and four
interactive demos. This file is the distilled reference.

## The problem

A controller is a noise amplifier: whatever jitter sits in the error is multiplied by the
loop gain and commanded onto the plant. For the running example (DC-motor speed loop, PI,
20 Hz crossover, encoder-derived speed), hash at 300 Hz–20 kHz and ±0.3 rad/s amplitude
became ~86 mV RMS of actuator chatter. Signal and noise overlap in *amplitude* but not in
*frequency* — that gap is what a filter exploits.

## Core idea

A linear filter is a frequency-dependent gain: each sinusoid is scaled by $|H(j\omega)|$ and
shifted by $\angle H(j\omega)$. Designing a filter = shaping $|H|$: passband ≈ 1 where the
signal lives, stopband ≈ 0 where the noise lives. Two free knobs (corner, steepness); phase
is the bill.

## The one-pole filter

$H(s) = \omega_c/(s+\omega_c)$: −20 dB/decade above the corner, phase 0→−90°, −45° at the
corner, group delay at DC $= 1/\omega_c$. Attenuation at 2×/5×/10× corner: −7/−14/−20 dB.

## The loop interaction (the heart)

The filter sits inside the loop transmission, $L = C\,P\,H$. Its gain at crossover is ≈ 1
(crossover barely moves: 20.00 → 19.98 Hz), but its **phase at crossover is subtracted from
the phase margin**: the 100 Hz two-pole design spent 16.4° of margin (PM 87.7° → 71.3°).

Rules of thumb:
- corner ≈ 5–10× crossover; one-pole lag ≈ 57.3°/ratio, two-pole Butterworth ≈ 81°/ratio
  (degrees at crossover).
- Spend only what you have: 10–15° is tolerable with a 60° margin; ~30° rings; corner at
  crossover removes ~90° → oscillation. Simulated overshoot ladder: 1.6% (no filter) →
  2.2% (100 Hz) → 15.6% (50 Hz) → 47% (30 Hz) → 62% (25 Hz) → unstable < ~17 Hz.

## Sharper knees: order and families

- $n$ poles → $-n\cdot20$ dB/decade. Butterworth attenuation at multiples $m$ of the corner:
  $|H| = 1/\sqrt{1+m^{2n}}$ (−28 dB at 5×, n = 2).
- Order from spec: $n \ge \log_{10}(10^{A/10}-1)\,/\,2\log_{10}(\omega_s/\omega_c)$.
- Butterworth poles: $s_k = \omega_c e^{j(2k+n-1)\pi/(2n)}$. Key factored forms
  ($\omega_c$ corner): n=2: $\omega_c^2/(s^2+\sqrt2\,\omega_c s+\omega_c^2)$;
  n=3: $\omega_c^3/((s+\omega_c)(s^2+\omega_c s+\omega_c^2))$;
  n=4: sections with 0.765 and 1.848.
- Families (same −3 dB corner, n = 3, verified): Butterworth — flattest passband, default;
  Bessel — flattest delay, 0.8% overshoot, laziest skirt (−38 dB at 6×); Chebyshev —
  passband ripple buys the steepest skirt (−55 dB at 6×). Step overshoot: 8.2% / 0.8% / 6.4%.

## Realization

- **Analog** (Sallen–Key, equal R/C): $\omega_c = 1/RC$, op-amp gain $K = 3-1/Q$;
  Butterworth $Q = 0.707$ → $K = 1.586$. R = 15.92 kΩ, C = 100 nF → 100.1 Hz.
- **Anti-alias first**: sampling folds everything above $f_s/2$ back; 20 kHz PWM sampled at
  1 kHz lands at **DC** where the integrator chases it. A 200 µs RC before the ADC
  (796 Hz) gives −28 dB at 20 kHz, −0.6 dB at 300 Hz. Analog = bodyguard, digital = surgeon.
- **First order in code**: $y[k] = \alpha y[k-1] + (1-\alpha)x[k]$, $\alpha = e^{-T/\tau}$
  (τ = 1.59 ms, T = 1 ms → α = 0.5335; realized −3 dB at 103.5 Hz).
- **General**: bilinear transform $s \leftarrow \tfrac{2}{T}\tfrac{z-1}{z+1}$; warping makes
  a 100 Hz design land at 96.9 Hz (fs = 1 kHz); prewarp (design at 103.43 Hz) hits 100.00 Hz
  exactly. Verified discrete section:
  $H(z) = \frac{0.067455 + 0.134911 z^{-1} + 0.067455 z^{-2}}{1 - 1.142981 z^{-1} + 0.412802 z^{-2}}$

## The seven-step recipe

1. Know the noise (where in frequency, how big).
2. Know the loop (crossover, margin).
3. Corner at 5–10× crossover; check the lag spend.
4. Order from the attenuation spec.
5. Family: Butterworth by default.
6. Realize (Sallen–Key or bilinear biquad) + analog anti-alias RC.
7. Re-verify the *loop* (overshoot tax, actuator ripple), not the magnitude plot.

Worked result: actuator ripple 86 → 7.3 mV RMS; speed pollution 14.2 → 1.6 mrad/s; cost:
overshoot 1.6% → 2.2%, group delay 2.25 ms.

## Beyond

Notch filters for single known tones; Kalman filters when signal and noise models exist
(same lag/margin trade-offs); feedforward bypasses the filter tax; synchronous ADC sampling
keeps PWM ripple from beating against $f_s$.

## Files

- `signal-filter-design.html` — the lesson (8 figures, 4 interactive demos).
- `filter_design.py` — every number/curve verified, pure stdlib; `report.txt` is its output.
- `demo_core.js` — demo math (same formulas), node-testable; `build_lesson.py` rebuilds the
  HTML from verified data.
