% Robust-control note, chapter 10 / Appendix A: the bisection algorithm, run on the scalar
% example of chapter 7, whose optimal level is gamma* = sqrt(3) - 1.
% Run from the repository root:
%   octave --no-gui --quiet Control/robust-control-10-outlook/scripts/bisection.m
1;

function [X, ok] = are_stab(A, R, Q)
  n = size(A, 1);
  H = [A, R; -Q, -A'];
  [V, D] = eig(H); d = diag(D); idx = find(real(d) < -1e-9);
  if numel(idx) ~= n, X = []; ok = false; return; end
  W = V(:, idx); U = W(1:n, :); Vs = W(n+1:2*n, :);
  if rcond(U) < 1e-12, X = []; ok = false; return; end
  X = real((Vs/U + (Vs/U)')/2); ok = true;
end
function ok = feasible(A, B1, B2, C1, C2, r)
  [X, o1] = are_stab(A', (C1'*C1)/r^2 - C2'*C2, B1*B1');
  [Y, o2] = are_stab(A, (B1*B1')/r^2 - B2*B2', C1'*C1);
  ok = false;
  if ~(o1 && o2), return; end
  ok = min(eig(X)) > -1e-8 && min(eig(Y)) > -1e-8 && max(abs(eig(X*Y))) < r^2 - 1e-12;
end

A = -1; B1 = [0, 1]; B2 = 1; C1 = [1; 0]; C2 = 1;
a = 0.6; b = 5.0;
printf("Bisection for gamma* (test: the two indefinite AREs are solvable with rho(XY) < gamma^2)\n");
printf("  j     a_j        b_j        b_j - a_j\n");
for j = 1:22
  printf("%3d  %.9f  %.9f  %.3e\n", j, a, b, b-a);
  m = (a+b)/2;
  if feasible(A, B1, B2, C1, C2, m), b = m; else a = m; end
end
printf("\nfinal interval [%.9f, %.9f], midpoint %.9f\n", a, b, (a+b)/2);
printf("exact gamma* = sqrt(3) - 1 = %.9f, error %.2e\n", sqrt(3)-1, abs((a+b)/2-(sqrt(3)-1)));
