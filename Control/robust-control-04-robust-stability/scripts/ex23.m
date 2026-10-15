% ex23.m -- supporting numeric checks for Exercises 2 and 3 (Chapter 4).
%
% Exercise 2 rests on the determinant identity
%     det(sI - A_Delta) det(I - D Delta) = det(sI - A) det(I - Sigma(s) Delta),
%     Sigma(s) = C (sI-A)^{-1} B + D,  A_Delta = A + B Delta (I - D Delta)^{-1} C.
% Exercise 3 claims  mu_{Delta_c}(a b^T) = sum_j |a_j b_j|  for real diagonal
%     Delta_c = {diag(d1,...,dm) : ||Delta|| < 1}.
%
% Run from the repository root:
%   octave --no-gui Control/robust-control-04-robust-stability/scripts/ex23.m
format long g
rand('seed', 7);
randn('seed', 7);

% --- identity check for Exercise 2 ------------------------------------------
n = 4; m = 3;
A = randn(n,n); B = randn(n,m); C = randn(m,n); D = randn(m,m);
Dl = diag(0.3*randn(m,1));                 % structured real Delta
AD = A + B*Dl*inv(eye(m)-D*Dl)*C;
s = 0.7 + 0.3i;
lhs = det(s*eye(n)-AD)*det(eye(m)-D*Dl);
Sigma = C*inv(s*eye(n)-A)*B + D;
rhs = det(s*eye(n)-A)*det(eye(m)-Sigma*Dl);
printf('identity (4.ex2): |lhs-rhs| = %.2e\n', abs(lhs-rhs));
l0 = det(-AD)*det(eye(m)-D*Dl);
S0 = C*inv(-A)*B + D;
r0 = det(-A)*det(eye(m)-S0*Dl);
printf('  at s=0 (part a):  |lhs-rhs| = %.2e\n', abs(l0-r0));

% --- Exercise 3: mu_{Delta_c}(a b^T) ---------------------------------------
a = [1.3; -2.1; 0.4]; b = [-0.7; 1.1; 2.0]; c = a.*b;
formula = sum(abs(c));
% brute force: min_(d1,d2) max_j |d_j| subject to sum_j c_j d_j = 1
% (d3 is eliminated by the constraint); local search from a coarse grid guess
obj = @(x) max(abs([x(1) x(2) (1 - c(1)*x(1) - c(2)*x(2))/c(3)]));
bestp = [0 0]; best = inf;
for d1 = linspace(-3,3,121)
  for d2 = linspace(-3,3,121)
    v = obj([d1 d2]);
    if v < best, best = v; bestp = [d1 d2]; end
  end
end
% multi-start local refinement (the objective is convex, so no local minima,
% but the max-kink can stall a single simplex)
fopt = inf;
for x0 = {bestp, [0 0], [0.1 0.1], [-0.2 -0.2], [0.3 -0.3]}
  [~, f] = fminsearch(obj, x0{1}, optimset('TolX', 1e-14, 'TolFun', 1e-14));
  fopt = min(fopt, f);
end
printf('Exercise 3: sum|a_j b_j| = %.8f ; brute-force mu = %.8f\n', formula, 1/fopt);

% Explicit witnesses and the well-posedness condition that part (a) needs.
Ds=diag(sign(c)/formula);
printf('rank-one explicit witness: norm %.12f, determinant residual %.3e\n', ...
 norm(Ds),abs(det(eye(3)-a*b'*Ds)));
A0=1; B0=2; C0=1; D0=2; d0=.5;
printf('ex2a counterexample: Sigma(0)=%.1f but I-D*delta=%.1f at delta=%.1f\n', ...
 D0-C0/A0*B0,1-D0*d0,d0);
assert(abs(det(eye(3)-a*b'*Ds))<1e-12);
