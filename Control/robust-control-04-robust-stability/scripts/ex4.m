% ex4.m -- Exercise 4 of Scherer, Theory of Robust Control, Chapter 4 (p. 135).
%
%  a) mu of Mc = [12 -3 2; -1 7 8; 5 3 -1] with the structure
%     Delta = diag(Delta1 (2x2 full), Delta33 (1x1 full)), ||Delta||<1.
%     Computed with an m-file that uses ONLY max, eig and a for-loop (no mu).
%  b) Frobenius-norm D-scaling bound d* = argmin ||[M1 d M12; M21/d M2]||_F.
%
% Run from the repository root:
%   octave --no-gui Control/robust-control-04-robust-stability/scripts/ex4.m
format long g
Mc = [12 -3 2; -1 7 8; 5 3 -1];
M1 = Mc(1:2,1:2); M12 = Mc(1:2,3); M21 = Mc(3,1:2); M2 = Mc(3,3);

% --- (a) mu via the D-scaling min_t sigma_max([[M1, t M12],[M21/t, M2]]) ----
% With nr=nc=0, nf=2, Theorem 4.20 says this scaling value IS mu.
f    = @(t) [M1, t*M12; (1/t)*M21, M2];
smax = @(A) sqrt(max(eig(A'*A)));      % largest singular value via eig
best = inf; bestt = NaN;
for lt = linspace(-3, 3, 20001)        % coarse for-loop grid over log10 t
  t = 10^lt; v = smax(f(t));
  if v < best, best = v; bestt = t; end
end
lo = bestt/1.5; hi = bestt*1.5;       % golden-section refinement
for it = 1:80
  a = lo + (hi-lo)/3; b = hi - (hi-lo)/3;
  if smax(f(a)) < smax(f(b)), hi = b; else lo = a; end
end
topt = (lo+hi)/2; mu = smax(f(topt));
printf('EXERCISE 4a (m-file with max/eig/for only)\n');
printf('  exact via D-scaling:  mu = %.8f  at  d2/d1 = %.8f\n', mu, topt);
printf('  (sigma_max without scaling, t=1: %.8f)\n', smax(f(1)));

% --- (c) randomised lower bound, cross-checking the exact value -----------
% rho(Mc*Delta) <= mu for every admissible Delta with ||Delta|| <= 1, so the
% maximum of rho(Mc*Delta) over samples is a valid lower bound on mu.
rand('seed', 20240001);
randn('seed', 20240001);      % legacy rand('seed',..) does NOT seed randn
best = 0; bestD = zeros(3);
for k = 1:200000
  D1 = randn(2,2); D1 = D1/norm(D1);          % spectral norm 1
  D  = blkdiag(D1, 2*rand-1);                 % ||Delta|| <= 1
  r  = max(abs(eig(Mc*D)));
  if r > best, best = r; bestD = D; end
end
samp = best;                                  % plain random search
step = 0.05;                                  % local refinement
for it = 1:4000
  Dp = bestD + step*[randn(2,2) zeros(2,1); zeros(1,2) randn];
  D1 = Dp(1:2,1:2); if norm(D1) > 1, D1 = D1/norm(D1); end
  D  = blkdiag(D1, max(-1, min(1, Dp(3,3))));
  r  = max(abs(eig(Mc*D)));
  if r > best, best = r; bestD = D; else step = step*0.999; end
end
printf('EXERCISE 4c (randomised lower bound, seeded)\n');
printf('  max rho(Mc Delta): %.6f sampled, %.6f after local refinement\n', samp, best);
printf('  (exact mu = %.8f, so the bound is tight to %.1e)\n', mu, mu - best);

% --- (b) Frobenius D-scaling: d* = argmin ||[M1 d M12; M21/d M2]||_F ---------
dstar = (norm(M21,'fro')/norm(M12,'fro'))^0.5;
fro   = norm(f(dstar),'fro');
printf('EXERCISE 4b (Frobenius scaling)\n');
printf('  ||M1||f=%.6f ||M12||f=%.6f ||M21||f=%.6f ||M2||f=%.6f\n', ...
       norm(M1,'fro'), norm(M12,'fro'), norm(M21,'fro'), norm(M2,'fro'));
printf('  d* = %.8f  ( = (||M21||f/||M12||f)^{1/2} )\n', dstar);
printf('  upper bound  min_d ||.||f = %.8f\n', fro);
printf('  sigma_max at d* = %.8f\n', smax(f(dstar)));
printf('  compare: mu = %.8f  <=  bound = %.8f  (ratio %.4f)\n', mu, fro, fro/mu);
