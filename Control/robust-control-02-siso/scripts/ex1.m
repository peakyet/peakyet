% Robust-control note, chapter 2: exercise 1 (a)-(d), evaluated on the given realization.
% Run from the repository root:
%   octave --no-gui --quiet Control/robust-control-02-siso/scripts/ex1.m
1;

function [n, d] = trimf(n, d)
  n = n / d(1); d = d / d(1);
end

AG = [0 1; -2 -3]; BG = [0; 1]; AK = 1; BK = 1; CK = 1;

% closed-loop system matrix  [x; xK]:  xdot = AG x + BG CK xK ;  xKdot = -BK CG x + AK xK
for alpha = [1.0, 1.001, 0.999]
  CG = [alpha, -1];
  Acl = [AG, BG*CK; -BK*CG, AK];
  printf("alpha = %.4f : eigenvalues of the closed-loop system matrix = %s\n", ...
         alpha, mat2str(sort(real(eig(Acl)), 'descend'), 6));
end

% transfer functions for alpha = 1
alpha = 1;
% G = (alpha - s)/(s^2 + 3s + 2),  K = 1/(s-1)
nG = [-1, alpha];  dG = [1, 3, 2];
nK = [1];          dK = [1, -1];
nGK = conv(nG, nK); dGK = conv(dG, dK);
nu = dGK + [zeros(1, numel(dGK)-numel(nGK)), nGK];   % 1 + GK
printf("\n1 + G K numerator   = %s\n", mat2str(nu, 8));
printf("roots of (1+GK) numerator   = %s\n", mat2str(sort(real(roots(nu)), 'descend'), 8));
printf("roots of G K denominator     = %s\n", mat2str(sort(real(roots(dGK)), 'descend'), 8));

% S = 1/(1+GK) = dGK / nu  (unguarded)
nS = dGK; dS = nu;
printf("\nS (unguarded) poles = %s\n", mat2str(sort(real(roots(dS)), 'descend'), 8));
% cancel common roots
[nu2, dS2] = trimf(nS, dS);
% polyreduce-like cancellation of common roots
r = roots(dS2); keep = [];
for k = 1:numel(r)
  if abs(polyval(nu2, r(k))) > 1e-9, keep(end+1) = r(k); end
end
dSred = poly(keep);
printf("S after cancelling the common root at s=1: denominator %s, poles %s\n", ...
       mat2str(dSred, 6), mat2str(sort(real(roots(dSred)), 'descend'), 6));

% reduced forms (derived by hand, verified here): G S = -1/(s^2+3s+1) ; K S = (s^2+3s+2)/((s-1)(s^2+3s+1))
printf("G S reduced poles = %s\n", mat2str(sort(real(roots([1 3 1])), 'descend'), 8));
printf("K S reduced poles = %s\n", mat2str(sort(real(roots(conv([1 -1], [1 3 1]))), 'descend'), 8));
printf("\\nK S has a pole at s = +1: an unstable transfer function hidden by the cancellation in S.\n");
