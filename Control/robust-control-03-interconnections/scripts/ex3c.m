% ex3c.m -- Exercise 3c of Scherer, Theory of Robust Control, Chapter 3.
% Builds the open-loop interconnection P of Figure 23 for the given G_j,
% tests the generalized-plant conditions (Theorem 3.10), designs an
% observer-based controller (the construction in the proof of Theorem 3.10,
% with LQR/Kalman-type gains), checks internal stability via (3.8)-(3.9),
% and writes a Bode magnitude plot of P*K.
%
% Run from the repository root:
%   octave --no-gui Control/robust-control-03-interconnections/scripts/ex3c.m
pkg load control
format short g
here = fileparts(mfilename('fullpath'));
s = tf('s');
% Evaluate a transfer matrix at a complex point through any realization.
function G = evalat(sys, sk)
  [a,b,c,d] = ssdata(ss(sys));
  G = c/(sk*eye(rows(a)) - a)*b + d;
end

% Asymmetric static ports: solve the original simultaneous signal equations.
p22 = [1;2]; kk = [0.1,0.2]; p21 = [3;5];
uy = [1,-kk; -p22,eye(2)] \ [0;p21];
assert(abs(uy(1)-2.6) < 1e-12 && abs(1+2*uy(1)-6.2) < 1e-12);
% Exercise 3b: minimal diagonal controller, zero external transfer but two
% unstable physical states. Separate measurement injections expose each pole.
cancelK = ss(eye(2), eye(2), diag([1,-1]), zeros(2));
assert(all(real(pole(cancelK)) == 1));
for sk = [0.5i, 2i, 1+1i]
  assert(abs([1,1]*evalat(cancelK,sk)*[1;1]) < 1e-12);
end

% Components (G1 = 1, G4 = 0, G6 = 1 are static and inlined below).
G2 = 1/(s-1);  G3 = (s+1)/(s^2+1);  G5 = 1/s;  G7 = (s+2)/((s+3)*(s-2));
[A2,B2c,C2c,D2c] = ssdata(ss(G2));
[A3,B3c,C3c,D3c] = ssdata(ss(G3));
[A5,B5c,C5c,D5c] = ssdata(ss(G5));
[A7,B7c,C7c,D7c] = ssdata(ss(G7));
assert(all([D2c D3c D5c D7c] == 0));   % every dynamic block is strictly proper

% Signals: a = u1 + u2,  z = G7 a,  q = G1 (w - (G4+G6) z) = w - z,
%          y1 = G2 q - G5 a,  y2 = G3 q - G5 a.
% State x = [x7; x2; x3; x5].
n7 = rows(A7); n2 = rows(A2); n3 = rows(A3); n5 = rows(A5);
Z = @(r,c) zeros(r,c);
A = [A7,            Z(n7,n2), Z(n7,n3), Z(n7,n5);
     -B2c*C7c,      A2,       Z(n2,n3), Z(n2,n5);
     -B3c*C7c,      Z(n3,n2), A3,       Z(n3,n5);
     Z(n5,n7),      Z(n5,n2), Z(n5,n3), A5];
Bw = [Z(n7,1); B2c; B3c; Z(n5,1)];
Ba = [B7c; Z(n2,1); Z(n3,1); B5c];
B1 = Bw;  B2 = [Ba, Ba];                         % u = [u1; u2]
C1 = [C7c, Z(1,n2), Z(1,n3), Z(1,n5)];
C2 = [Z(1,n7), C2c, Z(1,n3), -C5c;
      Z(1,n7), Z(1,n2), C3c, -C5c];
D11 = 0; D12 = [0 0]; D21 = [0; 0]; D22 = zeros(2,2);
n = rows(A);
P = ss(A, [B1 B2], [C1; C2], [D11 D12; D21 D22]);

% Cross-check against the transfer-matrix formula of Exercise 3a.
H2 = G2*G7 + G5;  H3 = G3*G7 + G5;
Ptf = [0, G7, G7; G2, -H2, -H2; G3, -H3, -H3];
err = 0;
for sk = [0.3+1.7i, 2.5-0.4i, -0.7+3i]
  err = max(err, norm(evalat(P, sk) - evalat(Ptf, sk)));
end
printf('max |P_ss - P_formula| at test points: %.2e\n', err);
assert(err < 1e-10);

% Generalized-plant test (Theorem 3.10) by the Hautus/PBH test at every
% eigenvalue with Re >= 0.
ev = eig(A);
printf('open-loop eigenvalues: %s\n', mat2str(ev.', 4));
printf('rank ctrb(A,[B1 B2]) = %d, rank obsv(A,[C1;C2]) = %d (n = %d)\n', ...
       rank(ctrb(A,[B1 B2])), rank(obsv(A,[C1;C2])), n);
for k = 1:n
  lam = ev(k);
  if real(lam) >= -1e-9
    rc = rank([A - lam*eye(n), B2]);  ro = rank([A - lam*eye(n); C2]);
    printf('  lambda = %+.3f%+.3fi: rank[A-lI B2] = %d, rank[A-lI; C2] = %d\n', ...
           real(lam), imag(lam), rc, ro);
    assert(rc == n && ro == n);
  end
end

% Controller design.  Figure 23 forces the structure K = diag(K1, K2):
% u1 = K1 y1, u2 = K2 y2.  Choose K2 = k2 static (no controller states, so
% no pole can be shared by K1 and K2), close that loop, and design K1 for the
% remaining SISO plant u1 -> y1 with the observer-based construction from the
% proof of Theorem 3.10:  xK' = (A' + b F + L c) xK - L y1,  u1 = F xK.
k2 = 1;
Ap = A + B2(:,2)*k2*C2(2,:);           % plant with loop 2 closed (D22 = 0)
b = B2(:,1);  c = C2(1,:);
printf('loop 1 after closing u2 = %g*y2: rank ctrb = %d, rank obsv = %d\n', ...
       k2, rank(ctrb(Ap, b)), rank(obsv(Ap, c)));
F = -lqr(Ap, b, eye(n), 1);             % Ap + b F stable
L = -lqr(Ap', c', eye(n), 1)';          % Ap + L c stable
A1 = Ap + b*F + L*c;
AK = A1;  BK = [-L, zeros(n,1)];  CK = [F; zeros(1,n)];  DK = [0 0; 0 k2];
K = ss(AK, BK, CK, DK);
printf('F = %s\nL = %s\n', mat2str(F, 4), mat2str(L', 4));

% Internal stability check: (3.8) and the eigenvalues of (3.9).
W = [eye(2), -DK; -D22, eye(2)];
printf('det of (3.8) matrix = %.3f\n', det(W));
nk = rows(AK);
Ab  = [A, zeros(n,nk); zeros(nk,n), AK];
B1b = [B1; zeros(nk,1)];
B2b = [B2, zeros(n,2); zeros(nk,2), BK];
C1b = [C1, zeros(1,nk)];  D12b = [D12, zeros(1,2)];
C2b = [zeros(2,n), CK; C2, zeros(2,nk)];
D21b = [zeros(2,1); D21];  D22b = [zeros(2), DK; D22, zeros(2)];
M = inv(eye(4) - D22b);
Acl = Ab + B2b*M*C2b;                    % this is (3.9)
evcl = eig(Acl);
printf('closed-loop eigenvalues (3.9):\n'); disp(evcl);
printf('max real part = %.4f\n', max(real(evcl)));
assert(max(real(evcl)) < -0.19);
% Independent physical wiring: a = F*xi + y2, xi' = A1*xi - L*y1.
Aphysical = [A + Ba*C2(2,:), Ba*F; -L*C2(1,:), A1];
physical_error = norm(Aphysical - Acl, inf);
printf('physical state equations vs general closure: %.2e\n', physical_error);
assert(physical_error < 1e-12);
% In coordinates (x,e=x-xi), verify the separation principle including its sign.
E = [eye(n), zeros(n); eye(n), -eye(n)];
separation_error = norm(E*Aphysical/E - [Ap+b*F, -b*F; zeros(n), Ap+L*c], inf);
printf('error-coordinate triangularization residual: %.2e\n', separation_error);
assert(separation_error < 1e-10);

% Closed loop P*K, realization (3.7).
Bcl = B1b + B2b*M*D21b;  Ccl = C1b + D12b*M*C2b;  Dcl = D11 + D12b*M*D21b;
Tzw = ss(Acl, Bcl, Ccl, Dcl);
% Cross-check against the formula P11 + P12 K (I - P22 K)^{-1} P21.
err = 0;
for sk = [0.5i, 2i, 1+1i]
  Pk = evalat(Ptf, sk); Kk = evalat(K, sk);
  f = Pk(1,1) + Pk(1,2:3)*Kk/(eye(2) - Pk(2:3,2:3)*Kk)*Pk(2:3,1);
  err = max(err, abs(f - evalat(Tzw, sk)));
end
printf('max |(3.7) - LFT formula| at test points: %.2e\n', err);
assert(err < 1e-9);

% The nine maps (3.14) via the realization (3.16): inputs (w, v1, v2),
% outputs (z, u, v).  Its poles after removing hidden modes must be stable.
Mi = inv(eye(4) - D22b);
B16 = [B1b + B2b*Mi*D21b, B2b*Mi];
C16 = [C1b + D12b*Mi*C2b; Mi*C2b];
D16 = [D11 + D12b*Mi*D21b, D12b*Mi; Mi*D21b, Mi];
T9 = ss(Acl, B16, C16, D16);
% Check all nine blocks by solving the original port equations pointwise.
err9 = 0;
for sk = [0.5i, 2i, 1+1i]
  pp = evalat(P, sk); kk = evalat(K, sk);
  port = [eye(2), -kk; -pp(2:3,2:3), eye(2)] \ ...
         [zeros(2,1), eye(2), zeros(2); pp(2:3,1), zeros(2), eye(2)];
  direct = [[pp(1,1), zeros(1,4)] + pp(1,2:3)*port(1:2,:); port];
  err9 = max(err9, norm(direct - evalat(T9, sk), inf));
end
printf('nine maps vs original disturbed port equations: %.2e\n', err9);
assert(err9 < 1e-8);
p9 = pole(minreal(T9, 1e-9));
printf('nine maps (3.14): %d poles after minreal, max real part %.4f\n', ...
       numel(p9), max(real(p9)));
K1 = ss(A1, -L, F, 0);
printf('poles of K1:\n'); disp(eig(A1));
[nK1, dK1] = tfdata(tf(minreal(K1, 1e-9)), 'v');
printf('K1 numerator   %s\nK1 denominator %s\n', mat2str(nK1, 6), mat2str(dK1, 6));

% Closed-loop numbers.
w = logspace(-3, 3, 2000);
mag = zeros(size(w));
for k = 1:numel(w), mag(k) = abs(evalat(Tzw, 1i*w(k))); end
[pk, ipk] = max(mag);
printf('|P*K|(j0) = %.4f, peak = %.4f at w = %.4f rad/s\n', ...
       abs(dcgain(Tzw)), pk, w(ipk));
printf('zeros of P*K:\n'); disp(zero(minreal(Tzw, 1e-8)));
g = @(lw) -abs(evalat(Tzw, 1i*10^lw));
[lw, fpk] = fminbnd(g, log10(w(max(ipk-5,1))), log10(w(min(ipk+5,end))));
printf('refined peak |P*K| = %.4f (%.2f dB) at w = %.4f rad/s\n', -fpk, 20*log10(-fpk), 10^lw);

% Bode magnitude plot.
graphics_toolkit('qt');
fig = figure('visible', 'off', 'position', [0 0 720 360]);
semilogx(w, 20*log10(mag), 'color', [0.122 0.306 0.475], 'linewidth', 2);
grid on;
xlabel('frequency (rad/s)'); ylabel('magnitude (dB)');
title('closed loop P*K: w to z');
set(gca, 'fontsize', 11);
outdir = fullfile(here, '..', 'assets');
if ~exist(outdir, 'dir'), mkdir(outdir); end
print(fig, fullfile(outdir, 'ex3c-bode.svg'), '-dsvg');
printf('wrote %s\n', fullfile(outdir, 'ex3c-bode.svg'));

% Cancellation is not decay: independent physical states, unequal input gains.
t = linspace(0, 4, 201);
hidden = ss(eye(2), [1;2], [2,-1], 0);
zh = initial(hidden, [1;0], t);
assert(max(abs(zh(:) - 2*exp(t(:)))) < 1e-9);
fig2 = figure('visible', 'off', 'position', [0 0 760 310]);
subplot(1,2,1);
plot(t, zh, 'linewidth', 2, t, zeros(size(t)), '--', 'linewidth', 1.5);
xlabel('time (s)'); ylabel('z'); grid on;
title('Same zero transfer, growing initial response');
legend('x(0) = [1;0]', 'zero-state response', 'location', 'northwest');
subplot(1,2,2);
plot(real(ev), imag(ev), 'x', 'markersize', 8, 'linewidth', 2); hold on;
plot(real(evcl), imag(evcl), 'o', 'markersize', 6, 'linewidth', 1.5);
plot([0 0], [-1.6 1.6], 'k:'); grid on;
xlabel('real part'); ylabel('imaginary part');
title('Exercise 3c: physical closed-loop modes');
legend('open plant', 'closed loop', 'location', 'northwest');
print(fig2, fullfile(outdir, 'internal-modes.svg'), '-dsvg');
printf('all assertions passed; wrote internal-modes.svg\n');
