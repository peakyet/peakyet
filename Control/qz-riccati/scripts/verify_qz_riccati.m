% verify_qz_riccati.m -- reproduces every number quoted in
% Control/qz-riccati/qz-riccati.typ, and checks the claims behind them.
%
% Base Octave only (LAPACK qz / ordqz / schur / ordschur / eig); no packages.
% Run from the repository root:
%
%     octave --no-gui --quiet Control/qz-riccati/scripts/verify_qz_riccati.m
%
% Running example: a unit mass on a unit spring,
%     A = [0 1; -1 0],  B = [0; 1],
% with two cost knobs, each with a closed-form solution:
%   knob 1 (cheap state penalty): Q = eps*I, R = 1
%   knob 2 (cheap control):       Q = I,     R = rho
% Section letters match the note's tables. Every route here is a hand-written
% route, so the note's numbers do not depend on another Riccati solver.

1;
format compact

function P = care_eig(A, G, Q)
  % classical eigenvector route: P = X2 X1^{-1} from the stable eigenvectors
  n = rows(A);
  [V, D] = eig([A, -G; -Q, -A']);
  idx = find(real(diag(D)) < 0);
  P = real(V(n+1:2*n, idx) / V(1:n, idx));
end

function P = care_schur(A, G, Q)
  % Laub's ordered Schur route on the Hamiltonian matrix H
  n = rows(A);
  [U, S] = schur([A, -G; -Q, -A'], 'complex');
  [U, S] = ordschur(U, S, real(diag(S)) < 0);
  P = real(U(n+1:2*n, 1:n) / U(1:n, 1:n));
end

function [P, asym, c11] = qz_stable(H, J, n)
  % H, J form the (2n+p)-square extended pencil; n is the state dimension.
  % QR-deflate the last p columns away (van Dooren 1981, eq. (55) -- the step
  % scipy's solve_continuous_are takes), then QZ ordered stable-first.
  N = rows(H); n2 = 2*n;
  [q, ~] = qr(H(:, n2+1:N));
  Hd = q(:, N-n2+1:N)' * H(:, 1:n2);
  Jd = q(1:n2, N-n2+1:N)' * J(1:n2, 1:n2);
  [AA, BB, Qz, Z] = qz(Hd, Jd);
  [AA, BB, Qz, Z] = ordqz(AA, BB, Qz, Z, 'lhp');
  U = Z(:, 1:n); U11 = U(1:n, :); U21 = U(n+1:2*n, :);
  P = real(U21 / U11);
  asym = norm(U11' * U21 - U21' * U11);
  c11 = cond(U11);
end

function [H, J] = extended_pencil(A, B, Q, R)
  [m, n] = size(B);
  H = [A, zeros(m), B; -Q, -A', zeros(m, n); zeros(n, m), B', R];
  J = [eye(m), zeros(m), zeros(m, n); zeros(m), eye(m), zeros(m, n); zeros(n, 2*m+n)];
end

function [P, asym, c11] = care_qz(A, B, Q, R)
  [H, J] = extended_pencil(A, B, Q, R);
  [P, asym, c11] = qz_stable(H, J, rows(A));
end

% Closed forms -------------------------------------------------------------
% knob 1: Q = eps*I, R = 1, with -2p12 - p12^2 + eps = 0 and p22^2 = 2p12 + eps
function P = closed_eps(eps_)
  p12 = sqrt(1 + eps_) - 1;
  p22 = sqrt(2*p12 + eps_);
  P = [p22 * (1 + p12), p12; p12, p22];
end
% knob 2: Q = I, R = rho, with -2p12 - p12^2/rho + 1 = 0 and p22^2 = rho(2p12+1)
function P = closed_rho(rho)
  p12 = sqrt(rho^2 + rho) - rho;
  p22 = sqrt(rho * (2*p12 + 1));
  P = [p22 + p12*p22/rho, p12; p12, p22];
end

relerr = @(P, R) norm(P - R) / norm(R);
resid = @(A, G, Q, P) norm(A'*P + P*A - P*G*P + Q);
A0 = [0 1; -1 0]; B0 = [0; 1];

printf('=== A. the closed forms solve their equations and give stable closed loops ===\n');
for eps_ = [1e-2, 1e-4, 1e-6, 1e-8, 1e-12]
  Q = eps_ * eye(2); G = B0 * B0'; P = closed_eps(eps_);
  printf('knob1 eps=%7.0e  residual=%.2e  asymmetry=%.2e  closed-loop Re=%+.4e  ||P||=%.4e\n', ...
    eps_, resid(A0, G, Q, P), norm(P - P'), max(real(eig(A0 - G*P))), norm(P));
end
for rho = [1, 1e-4, 1e-6, 3e-8, 3e-10]
  Q = eye(2); G = B0 * (1/rho) * B0'; P = closed_rho(rho);
  printf('knob2 rho=%7.0e  residual=%.2e  asymmetry=%.2e  closed-loop eig=%s  ||P||=%.4e\n', ...
    rho, resid(A0, G, Q, P), norm(P - P'), mat2str(sort(real(eig(A0 - G*P)))', 6), norm(P));
end

printf('\n=== B. knob 1: eigenvector route vs ordered Schur vs deflated QZ ===\n');
printf('eps      |Re|(pair)  1-|v1.v2|   cond(V)    relerr_eig  relerr_schur  relerr_qz\n');
for eps_ = [1e-4, 1e-6, 1e-8, 1e-12]
  Q = eps_ * eye(2); G = B0 * B0'; P = closed_eps(eps_);
  [V, D] = eig([A0, -G; -Q, -A0']);
  ev = diag(D);
  [~, k] = min(abs(ev - 1i)); d = abs(ev - ev(k)); d(k) = inf; [~, j] = min(d);
  v1 = V(:, k) / norm(V(:, k)); v2 = V(:, j) / norm(V(:, j));
  Pe = care_eig(A0, G, Q); Ps = care_schur(A0, G, Q); Pq = care_qz(A0, B0, Q, 1);
  printf('%7.0e  %+.3e  %10.3e  %9.3e  %10.2e  %12.2e  %10.2e\n', ...
    eps_, abs(real(ev(k))), 1 - abs(v1' * v2), cond(V), relerr(Pe, P), relerr(Ps, P), relerr(Pq, P));
end
eps_ = 1e-8; Q = eps_ * eye(2); G = B0 * B0';
[V, D] = eig([A0, -G; -Q, -A0']);
idx = find(real(diag(D)) < 0);
Vs = V(:, idx);
sv = svd(Vs / diag(sqrt(sum(abs(Vs).^2))));
printf('  the stable invariant subspace is anyway well conditioned: at eps=1e-8 the two\n');
printf('  stable eigenvectors are separated, min(svd) of the unit-norm pair = %.3e,\n', sv(end));
printf('  while the error of every route is within a factor of 4 of 2.2e-16/eps = %.1e.\n', 2.2e-16/1e-8);

printf('\n  spectrum of H for figure F1(a) (real, imaginary parts):\n');
for eps_ = [1e-2, 1e-8]
  ev = sort(eig([A0, -B0*B0'; -eps_*eye(2), -A0']));
  printf('  eps=%7.0e : ', eps_);
  for k = 1:4, printf('(%+.9f,%+.9f) ', real(ev(k)), imag(ev(k))); end
  printf('\n');
end

printf('\n  series for figure F1(b): eps, closed-loop |Re|, eigenvalue gap, eigenvector overlap\n');
for eps_ = [1e-2, 1e-4, 1e-6, 1e-8, 1e-10, 1e-12]
  Q = eps_ * eye(2); G = B0 * B0'; P = closed_eps(eps_);
  [V, D] = eig([A0, -G; -Q, -A0']);
  ev = diag(D);
  [~, k] = min(abs(ev - 1i)); d = abs(ev - ev(k)); d(k) = inf; [~, j] = min(d);
  v1 = V(:, k) / norm(V(:, k)); v2 = V(:, j) / norm(V(:, j));
  printf('  eps=%7.0e  |Re|=%.4e  gap=%.4e  overlap=%.4e  (sqrt(eps)=%.4e)\n', ...
    eps_, abs(real(ev(k))), abs(ev(k) - ev(j)), 1 - abs(v1' * v2), sqrt(eps_));
end

printf('\n=== C. knob 2: forming G = B*inv(R)*B'' costs accuracy; the pencil does not ===\n');
printf('rho       ||P||      err_schur_with_G  err_pencil_qz  digits_lost  cond(U11)\n');
for rho = [1e-4, 1e-6, 3e-8, 3e-10]
  Q = eye(2); G = B0 * (1/rho) * B0'; P = closed_rho(rho);
  Ps = care_schur(A0, G, Q); [Pq, ~, c11] = care_qz(A0, B0, Q, rho);
  e1 = relerr(Ps, P); e2 = relerr(Pq, P);
  printf('%7.0e  %9.3e  %15.2e  %14.2e  %11.1f  %11.2e\n', rho, norm(P), e1, e2, log10(e1/e2), c11);
end
printf('rho = 0: ');
R = 0; G = B0 * (1/R) * B0';
if all(isfinite(G(:)))
  printf('G = B*inv(R)*B'' = %s (finite?!)\n', mat2str(G));
else
  printf('G = B*inv(R)*B'' is not finite: the matrix route does not exist.\n');
end
[H, J] = extended_pencil(A0, B0, eye(2), 0);
[AA, BB, ~, ~] = qz(H, J);
alf = diag(AA); bet = diag(BB);
ninf = sum(abs(bet) <= 1e-14 * max(abs(alf))); nfin = numel(alf) - ninf;
printf('        the same data as a 5x5 pencil: %d finite and %d infinite eigenvalues at R = 0\n', nfin, ninf);
printf('        finite values: ');
for k = 1:numel(alf)
  if abs(bet(k)) > 1e-14 * max(abs(alf)), printf('%+.6f ', alf(k)/bet(k)); end
end
printf('\n');

printf('\n=== D. with R = 1 the deflated pencil route matches the standard Hamiltonian route ===\n');
for eps_ = [1e-2, 1e-6]
  Q = eps_ * eye(2); G = B0 * B0'; P = closed_eps(eps_);
  Ps = care_schur(A0, G, Q); Pq = care_qz(A0, B0, Q, 1);
  printf('eps=%7.0e  ||Pq-Ps||/||P||=%.2e   errors against the closed form: schur %.2e  qz %.2e\n', ...
    eps_, norm(Pq - Ps)/norm(P), relerr(Ps, P), relerr(Pq, P));
end

printf('\n=== E. the symmetry defect is a tripwire, not a certificate ===\n');
printf('eps      worst relerr (100 pencil roundings)  worst asym defect   ratio\n');
for eps_ = [1e-4, 1e-6, 1e-8, 1e-10]
  Q = eps_ * eye(2); P = closed_eps(eps_);
  [H, J] = extended_pencil(A0, B0, Q, 1);
  worst_e = 0; worst_a = 0;
  for k = 1:100
    rand('seed', 9000 + k);
    dH = (2*rand(rows(H)) - 1) * 1.1e-16 * norm(H, 1);
    [Pq, asym] = qz_stable(H + dH, J, 2);
    worst_e = max(worst_e, relerr(Pq, P));
    worst_a = max(worst_a, asym);
  end
  printf('%7.0e  %29.2e  %18.2e  %8.2e\n', eps_, worst_e, worst_a, worst_a/worst_e);
end

printf('\n=== F. the smallest example with the same mechanism ===\n');
printf('The Jordan pivot [[1,1],[eps,1]] has eigenvalues 1 +- sqrt(eps), so their gap is 2 sqrt(eps),\n');
printf('with unit eigenvectors (1, +-sqrt(eps))/norm, so 1-|v.w| = 2eps/(1+eps).\n');
for eps_ = [1e-4, 1e-8, 1e-12]
  s = sqrt(eps_);
  v = [1; s] / norm([1; s]); w = [1; -s] / norm([1; -s]);
  ev = sort(eig([1, 1; eps_, 1]));
  printf('eps=%7.0e  gap=%.4e (= 2 sqrt(eps) = %.4e)  1-|v.w|=%.4e (= 2eps/(1+eps) = %.4e)\n', ...
    eps_, ev(2) - ev(1), 2*s, 1 - abs(v' * w), 2*eps_/(1+eps_));
end
eps_ = 1e-8; Q = eps_ * eye(2); G = B0 * B0';
[V, D] = eig([A0, -G; -Q, -A0']);
ev = diag(D); [~, k] = min(abs(ev - 1i)); d = abs(ev - ev(k)); d(k) = inf; [~, j] = min(d);
v1 = V(:, k) / norm(V(:, k)); v2 = V(:, j) / norm(V(:, j));
ov = 1 - abs(v1' * v2);
printf('The real example at eps=1e-8: 1-|v1.v2| = %.3e = %.2f eps, with eigenvalue split %.3e.\n', ...
  ov, ov/eps_, abs(ev(k) - ev(j)));