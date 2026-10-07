% verify_qz.m -- every number quoted in Algebra/qz-algorithm/qz-algorithm.typ.
% Octave, standard library only. Run from the repository root:
%   octave --no-gui --quiet Algebra/qz-algorithm/scripts/verify_qz.m

1;
more off;
format short e

% ---------------------------------------------------------------------------
% The running example: a pencil whose generalized Schur form we choose, then
% hide behind an orthogonal change of coordinates.  S0 - lambda*T0 is the
% decoupled form; U is a rotation in the (1,3) plane.
% ---------------------------------------------------------------------------
c0 = 1/sqrt(2);
U  = [c0 0 -c0; 0 1 0; c0 0 c0];
S0 = [0 -1 0; 1 0 0; 0 0 1];
T0 = @(d) diag([1 1 d]);
A  = U*S0*U';

fprintf('==================== 1. the pencil and its spectrum ====================\n');
d = 0.5;
B = U*T0(d)*U';
fprintf('delta = %.4f\n', d);
fprintf('A =\n');   disp(A);
fprintf('B =\n');   disp(B);
fprintf('U orthogonal error = %.2e\n', norm(U'*U-eye(3)));
% closed form: det(S0 - lambda*T0) = (lambda^2+1)(1 - delta*lambda)
lam = [0.3, -1.7, 2.4];
det_num  = arrayfun(@(l) det(A - l*B), lam);
det_clsd = arrayfun(@(l) (l^2+1)*(1 - d*l), lam);
fprintf('det(A-lam B)  numeric   = '); fprintf('%+.6e ', det_num);  fprintf('\n');
fprintf('det(A-lam B)  closed    = '); fprintf('%+.6e ', det_clsd); fprintf('\n');
fprintf('max |numeric-closed|    = %.2e\n', max(abs(det_num-det_clsd)));
% eigenpairs: exact {i,-i,1/delta}
exact = [1i; -1i; 1/d];
[V, Dg] = eig(A, B);
ev = diag(Dg);
fprintf('exact eigenvalues       = '); fprintf('%+.6f%+.6fi ', [real(exact) imag(exact)].'); fprintf('\n');
fprintf('eig(A,B) eigenvalues    = '); fprintf('%+.6f%+.6fi ', [real(ev) imag(ev)].'); fprintf('\n');
% residual of each computed pair: ||A v - lambda B v|| / (||A||+|lambda|||B||)
res = 0;
for k = 1:3
  lam_k = ev(k); v = V(:,k);
  res = max(res, norm(A*v - lam_k*B*v) / ((norm(A)+abs(lam_k)*norm(B))*norm(v)));
end
fprintf('max relative eigpair residual = %.2e\n', res);
% eigenvectors: check Z of the real Schur form reproduces them (section 5)

fprintf('\n==================== 2. why not B \\ A ====================\n');
fprintf('  delta    cond(B)   err(eig(B\\A)) on {i,-i}   err(eig(A,B)) on {i,-i}\n');
for d = [1, 0.5, 1e-2, 1e-4, 1e-8, 1e-12, 1e-16]
  B = U*T0(d)*U';
  e_m = eig(B\A); e_q = eig(A, B);
  pair = @(e) max( min(abs(e-1i))/1, min(abs(e+1i))/1 );  % relative, |lambda|=1
  fprintf('%9.0e  %9.2e  %20.3e   %20.3e\n', d, cond(B), pair(e_m), pair(e_q));
end
fprintf('\n  the large eigenvalue 1/delta, same two routes (relative error)\n');
fprintf('  delta    err(eig(B\\A)) on 1/delta   err(eig(A,B)) on 1/delta\n');
for d = [1, 0.5, 1e-4, 1e-8, 1e-12]
  B = U*T0(d)*U';
  e_m = eig(B\A); e_q = eig(A, B);
  fm = min(abs(e_m - 1/d))/(1/d); fq = min(abs(e_q - 1/d))/(1/d);
  fprintf('%9.0e  %22.3e   %22.3e\n', d, fm, fq);
end

d = 0; B0 = U*T0(d)*U';
fprintf('\ndelta = 0:  rank(B) = %d, det(B) = %g, cond(B) = Inf\n', rank(B0), det(B0));
fprintf('  B \\ A exists? ');
try
  M0 = B0\A; fprintf('no -- Octave warns and returns ||B\\A|| = %.2e\n', norm(M0));
catch err
  fprintf('no -- %s\n', err.message);
end
e0 = eig(A, B0);
fprintf('  eig(A,B) at delta=0    = '); fprintf('%+.4f%+.4fi ', [real(e0) imag(e0)].'); fprintf('\n');

fprintf('\n==================== 3. the generalized Schur form ====================\n');
% (a) complex form: S and T are truly upper triangular, so the pairs are the diagonals.
for d = [0.5, 0]
  B = U*T0(d)*U';
  [S, T, Q, Z] = qz(A, B);
  fprintf('--- complex QZ, delta = %g ---\n', d);
  fprintf('diagonal pairs (S_ii, T_ii) and ratio:\n');
  for k = 1:3
    fprintf('   (%+.4f%+.4fi, %+.4f%+.4fi)   ratio %+.4f%+.4fi\n', ...
            real(S(k,k)), imag(S(k,k)), real(T(k,k)), imag(T(k,k)), ...
            real(S(k,k)/T(k,k)), imag(S(k,k)/T(k,k)));
  end
  fprintf('orthogonality  ||Q''Q-I||=%.2e  ||Z''Z-I||=%.2e\n', norm(Q'*Q-eye(3)), norm(Z'*Z-eye(3)));
  fprintf('equivalence    ||QAZ-S||=%.2e  ||QBZ-T||=%.2e\n', norm(Q*A*Z-S), norm(Q*B*Z-T));
  fprintf('S =\n'); disp(S); fprintf('T =\n'); disp(T);
end
% (b) real form: S is quasi-upper-triangular; a complex pair is a 2x2 block.
d = 0.5; B = U*T0(d)*U';
[S, T, Q, Z] = qz(A, B, 'real');
fprintf('--- real QZ, delta = 0.5 ---\n');
fprintf('S =\n'); disp(S); fprintf('T =\n'); disp(T);
fprintf('equivalence    ||QAZ-S||=%.2e  ||QBZ-T||=%.2e\n', norm(Q*A*Z-S), norm(Q*B*Z-T));
fprintf('1x1 pair  (S_11,T_11) = (%+.6f,%+.6f) -> %+.6f\n', S(1,1), T(1,1), S(1,1)/T(1,1));
S2 = S(2:3,2:3); T2 = T(2:3,2:3);
fprintf('2x2 block S = [%+.3f %+.3f; %+.3f %+.3f], T = [%+.3f %+.3f; %+.3f %+.3f]\n', ...
        S2(1,1),S2(1,2),S2(2,1),S2(2,2), T2(1,1),T2(1,2),T2(2,1),T2(2,2));
fprintf('2x2 block generalized eigenvalues = '); 
eb = eig(S2, T2); fprintf('%+.6f%+.6fi ', [real(eb) imag(eb)].'); fprintf('\n');

fprintf('\n==================== 4. the pair, not the ratio ====================\n');
% In the decoupled coordinates the third pair is exactly (1, delta): finite data whose
% ratio is not representable.  (The dense B = U T0 U' rounds delta away long before this.)
for d = [1e-300, 1e-309]
  fprintf('delta = %.0e: pair (alpha,beta) = (1, %.3e) both finite; ratio 1/delta = %g\n', d, d, 1/d);
end

fprintf('\n==================== 5. using a library ====================\n');
d = 0.5; B = U*T0(d)*U';
[V, Dg] = eig(A, B);
fprintf('eig(A,B): eigenvalue order and residual\n');
for k = 1:3
  lam = Dg(k,k); v = V(:,k);
  fprintf('  lambda_%d = %+.6f%+.6fi   ||Av-lambda Bv||/||v|| = %.2e\n', ...
          k, real(lam), imag(lam), norm(A*v - lam*B*v)/norm(v));
end
fprintf('eig(A,B) at delta=0 (singular B) still returns a finite pair and -Inf:\n');
[dum, Dg0] = eig(A, B0);
fprintf('  '); fprintf('%+.4f%+.4fi ', [real(diag(Dg0)) imag(diag(Dg0))].'); fprintf('\n');

% ---------------------------------------------------------------------------
% The Sylvester equation of subsection 6.1 is the invariance (eigenvector)
% condition written as a graph.  Check both readings directly.
% ---------------------------------------------------------------------------
fprintf('\n==================== 6. the swap equation is the invariance condition ====================\n');
% scalar:  a*x - x*b = c  <=>  M*v = b*v with v = (-x; 1)
a = 1; c = 1; b = 4; M = [a c; 0 b];
x = c/(a-b); v = [-x; 1];
fprintf('scalar: x = c/(a-b) = %.4f ;  ||M*v - b*v|| = %.2e\n', x, norm(M*v - b*v));
% block:  A*X - X*B = C  <=>  M*[-X;I] = [-X;I]*B
A2 = [1 2; 0 3]; B2 = [4 1; 0 5]; C2 = ones(2); n2 = 2;
X2 = reshape((kron(eye(n2),A2)-kron(B2.',eye(n2)))\C2(:), n2, n2);
Mb = [A2 C2; zeros(n2) B2]; Gg = [-X2; eye(n2)];
fprintf('block:  ||A*X - X*B - C|| = %.2e ;  ||M*[-X;I] - [-X;I]*B|| = %.2e\n', ...
        norm(A2*X2 - X2*B2 - C2), norm(Mb*Gg - Gg*B2));

% ---------------------------------------------------------------------------
% From the solution to the rotation: the swap is the invariant direction made
% into a basis.  Single matrix: one similarity.  (The pencil case is cited, not
% re-implemented; its outcome is checked with ordqz in the note's text.)
% ---------------------------------------------------------------------------
fprintf('\n==================== 7. from the solution to the rotation ====================\n');
% 2x2: the rotation whose first column is the invariant direction v = (-x; 1)
a = 1; c = 1; b = 4; M = [a c; 0 b]; x = c/(a-b);
G = [-x -1; 1 -x] / sqrt(1+x^2); Gt = G.'*M*G;
fprintf('2x2: x = %.4f ; ||G''G - I|| = %.2e ; G''MG = [%+.4f %+.4f; %+.2e %+.4f]\n', ...
        x, norm(G.'*G-eye(2)), Gt(1,1), Gt(1,2), Gt(2,1), Gt(2,2));
% block single matrix: orthonormalise the graph (-X; I) as the leading columns
W1 = orth([-X2; eye(n2)]); W2 = null(W1.'); Gb = [W1 W2]; Gtb = Gb.'*Mb*Gb;
fprintf('block: ||G''G - I|| = %.2e ; lower-left block = %.2e\n', ...
        norm(Gb.'*Gb-eye(4)), norm(Gtb(3:4,1:2)));
fprintf('     leading eigenvalues = %.3f %.3f (ev of B) ; trailing = %.3f %.3f (ev of A)\n', ...
        sort(real(eig(Gtb(1:2,1:2)))), sort(real(eig(Gtb(3:4,3:4)))));
