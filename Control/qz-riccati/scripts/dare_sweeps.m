% dare_sweeps.m -- the discrete-time algebraic Riccati equation (DARE) solved with the same
% deflating-subspace recipe the note uses for CARE, on real data so that the note's numbers and the
% figure drawn from them are measured rather than asserted:
%
%   (1) a scalar instance whose answer has a closed form, solved twice: by hand from the pencil's
%       stable eigenvector, and by the ordered QZ route;
%   (2) a discrete double integrator (2x2), checked against the Riccati recursion and against the
%       symplectic-matrix form;
%   (3) a plant with singular A, where the symplectic matrix does not exist but the pencil does;
%   (4) the deflation of the control block (m infinite eigenvalues -> 0) and the symplectic
%       structure of the deflated pair.
%
% The extended (symplectic) pencil for  A'PA - P - A'PB (R + B'PB)^-1 B'PA + Q = 0  is
%
%     M - lambda N = [ A   0   B ]      [ I   0   0 ]
%                    [-Q   I   0 ]  - l [ 0  A'   0 ]
%                    [ 0   0   R ]      [ 0 -B'   0 ]
%
% It uses A and A' as blocks and never forms R^-1 or G = B R^-1 B'; it is regular for every R >= 0.
% The stable deflating subspace (|alpha/beta| < 1) is the graph of P.
%
%     octave --no-gui --quiet Control/qz-riccati/scripts/dare_sweeps.m

1;

function [Md, Nd, Qc] = deflate(M, N, n, m)
  % Van Dooren's deflation, as in the note's continuous section: the last m columns of M are the
  % stacked blocks B, 0, R.  QR those, drop the m directions they span from both sides.
  Mc = M(:, 2*n+1:2*n+m);
  [Qc, ~] = qr(Mc);
  Q2 = Qc(:, m+1:end);
  Tr = [eye(2*n); zeros(m, 2*n)];
  Md = Q2' * M * Tr;
  Nd = Q2' * N * Tr;
end

function [M, N] = dare_pencil(A, B, Q, R)
  n = size(A, 1); m = size(B, 2);
  M = [A, zeros(n), B; -Q, eye(n), zeros(n, m); zeros(m, n), zeros(m, n), R];
  N = [eye(n), zeros(n), zeros(n, m); zeros(n), A', zeros(n, m); zeros(m, n), -B', zeros(m)];
end

function P = solve_dare_pencil(A, B, Q, R)
  n = size(A, 1); m = size(B, 2);
  [M, N] = dare_pencil(A, B, Q, R);
  [Md, Nd] = deflate(M, N, n, m);
  [S, T, Q1, Z] = qz(Md, Nd, 'real');
  [S, T, Q1, Z] = ordqz(S, T, Q1, Z, 'udi');   % |alpha/beta| < 1 leads
  P = Z(n+1:2*n, 1:n) / Z(1:n, 1:n);
end

function r = dare_res(A, B, Q, R, P)
  r = A'*P*A - P - (A'*P*B) / (R + B'*P*B) * (B'*P*A) + Q;
end

function d = sympl_defect(S)
  n = size(S, 1)/2; J = [zeros(n), eye(n); -eye(n), zeros(n)];
  d = norm(S'*J*S - J);
end

function [k, Pk] = riccati_recursion(A, B, Q, R)
  % independent check: iterate the DARE itself to its fixed point
  Pk = Q;
  for k = 1:2000
    Pn = A'*Pk*A - (A'*Pk*B) / (R + B'*Pk*B) * (B'*Pk*A) + Q;
    if norm(Pn - Pk, 'fro') < 1e-15 * max(1, norm(Pn, 'fro')), break; end
    Pk = Pn;
  end
end

printf('=== 1. scalar instance, a = 2, b = 1, q = 1, r = 1 ===\n');
A = 2; B = 1; Q = 1; R = 1;
[M, N] = dare_pencil(A, B, Q, R);
ev = eig(M, N); evf = ev(isfinite(ev));
printf('extended pencil is %dx%d; its eigenvalues:\n', size(M, 1), size(M, 1));
printf('  %.10f   %.10f   and %d infinite (beta = 0)\n', evf(1), evf(2), sum(~isfinite(ev(:))));
[Md, Nd] = deflate(M, N, 1, 1);
evd = sort(real(eig(Md, Nd)));
printf('after deflation (%dx%d): %.10f and %.10f  -- product = %.12f\n', ...
       size(Md, 1), size(Md, 1), evd(1), evd(2), prod(evd));
[V, L] = eig(Md, Nd); [~, i] = min(abs(diag(L)));
v = V(:, i) / V(1, i);
printf('the stable eigenvector, first coordinate scaled to 1: [1; %.12f]\n', v(2));
printf('  so the slope of the stable direction is P = %.12f\n', v(2));
P1 = solve_dare_pencil(A, B, Q, R);
printf('closed form 2 + sqrt(5)              = %.12f\n', 2 + sqrt(5));
printf('ordered QZ route on the same pencil  = %.12f\n', P1);
printf('DARE residual on the pencil answer   = %.3e\n', dare_res(A, B, Q, R, P1));
printf('closed loop A - B(R+B''PB)^-1 B''PA  = %.12f  (inside the unit circle)\n', ...
       A - B/(R + B'*P1*B)*B'*P1*A);

printf('\n=== 2. discrete double integrator, A = [1 1; 0 1], B = [0; 1], Q = I, R = 1 ===\n');
A = [1 1; 0 1]; B = [0; 1]; Q = eye(2); R = 1;
P2 = solve_dare_pencil(A, B, Q, R);
printf('P =\n'); disp(P2);
printf('DARE residual = %.3e, ||P - P''|| = %.3e\n', norm(dare_res(A, B, Q, R, P2)), norm(P2 - P2'));
[k, Pk] = riccati_recursion(A, B, Q, R);
printf('Riccati recursion converged in %d steps; ||P_pencil - P_recursion|| = %.3e\n', k, norm(P2 - Pk));
F = (R + B'*P2*B) \ (B'*P2*A);
printf('closed-loop radius = %.12f  (stable: %d)\n', max(abs(eig(A - B*F))), max(abs(eig(A - B*F))) < 1);
[M, N] = dare_pencil(A, B, Q, R);
[Md, Nd] = deflate(M, N, 2, 1);
S = [A + B/R*B'*inv(A')*Q, -B/R*B'*inv(A'); -inv(A')*Q, inv(A')];   % symplectic matrix, needs inv(A)
printf('the symplectic-matrix form needs inv(A); A is invertible here, det A = %g\n', det(A));
printf('  ||S'' J S - J|| = %.3e (S is symplectic)\n', sympl_defect(S));
printf('  eig(S) = '); disp(eig(S)');
printf('  max|eig(S)-eig(deflated pencil)| = %.3e\n', ...
       max(abs(sort(eig(S)) - sort(eig(Md, Nd)))));
mo = sort(abs(eig(S)), 'descend');
printf('  |eig(S)| = %.6f %.6f %.6f %.6f, outer product %.6f x %.6f = %.12f\n', ...
       mo(1), mo(2), mo(3), mo(4), mo(1), mo(4), mo(1)*mo(4));

printf('\n=== 3. singular A: A = [1 1; 0 0], B = [0; 1], Q = I, R = 1 ===\n');
A = [1 1; 0 0]; B = [0; 1]; Q = eye(2); R = 1;
printf('det A = %g, so inv(A) -- and with it the symplectic matrix -- does not exist\n', det(A));
[M, N] = dare_pencil(A, B, Q, R);
ok = 0; for t = 1:20
  a = randn; bb = randn;
  if abs(det(a*M - bb*N)) > 1e-10, ok = ok + 1; end
end
printf('the pencil is still regular: %d of 20 random (alpha, beta) give det(alpha M - beta N) != 0\n', ok);
[Md, Nd] = deflate(M, N, 2, 1);
printf('deflated eigenvalues: '); disp(eig(Md, Nd)');
P3 = solve_dare_pencil(A, B, Q, R);
printf('P =\n'); disp(P3);
printf('DARE residual = %.3e, ||P - P''|| = %.3e\n', norm(dare_res(A, B, Q, R, P3)), norm(P3 - P3'));
F = (R + B'*P3*B) \ (B'*P3*A);
printf('closed-loop radius = %.12f  (stable: %d)\n', max(abs(eig(A - B*F))), max(abs(eig(A - B*F))) < 1);

printf('\n=== 4. what the pencil eigenvalues are ===\n');
cases = {[1 1; 0 1], 'A invertible'; [1 1; 0 0], 'A singular'};
for c = 1:2
  A = cases{c,1}; B = [0; 1]; Q = eye(2); R = 1;
  [M, N] = dare_pencil(A, B, Q, R);
  ev = eig(M, N); ninf = sum(~isfinite(ev(:)));
  evf = sort(real(ev(isfinite(ev))));
  [Md, Nd] = deflate(M, N, 2, 1);
  ed = eig(Md, Nd); ninfd = sum(~isfinite(ed(:)));
  P = solve_dare_pencil(A, B, Q, R);
  F = (R + B'*P*B) \ (B'*P*A);
  cl = eig(A - B*F); [~, i1] = sort(real(cl)); cl = cl(i1);
  inside = ed(abs(ed) < 1); [~, i2] = sort(real(inside)); inside = inside(i2);
  printf('%s, A = [%g %g; %g %g]: rank([A;B]) = %d\n', cases{c,2}, A(1,1), A(1,2), A(2,1), A(2,2), rank([A; B.']));
  printf('  extended %dx%d: %d finite, %d infinite (%d control direction)\n', ...
         size(M,1), size(M,1), numel(evf), ninf, 1);
  printf('  deflated %dx%d: %d finite, %d infinite; product of all finite = %.10f\n', ...
         size(Md,1), size(Md,1), numel(ed)-ninfd, ninfd, prod(ed(isfinite(ed))));
  printf('  eigenvalues inside the unit circle: '); printf('%.4f%+.4fi  ', [real(inside(:)), imag(inside(:))]'); printf('\n');
  printf('  closed-loop poles eig(A - BF):      '); printf('%.4f%+.4fi  ', [real(cl(:)), imag(cl(:))]'); printf('\n');
  printf('  max |inside - closed loop| = %.3e, closed-loop radius = %.12f\n', ...
         max(abs(inside - cl)), max(abs(cl)));
  printf('  DARE residual = %.3e, ||P - P''|| = %.3e\n\n', ...
         norm(dare_res(A, B, Q, R, P)), norm(P - P'));
end

printf('=== 5. the graph identity and the reciprocal half ===\n');
for c = 1:2
  A = cases{c,1}; B = [0; 1]; Q = eye(2); R = 1; n = 2;
  [M, N] = dare_pencil(A, B, Q, R);
  [Md, Nd] = deflate(M, N, n, 1);
  P = solve_dare_pencil(A, B, Q, R); F = (R + B'*P*B) \ (B'*P*A); Acl = A - B*F;
  G = [eye(n); P];
  ed = eig(Md, Nd); [~, i1] = sort(real(ed)); ed = ed(i1);
  both = [eig(Acl); 1./eig(Acl)]; [~, i2] = sort(real(both)); both = both(i2);
  printf('%s:  ||Md*G - Nd*G*Acl|| = %.3e  (G = [I; P] is the deflating subspace)\n', ...
         cases{c,2}, norm(Md*G - Nd*G*Acl));
  printf('  the 4 pencil eigenvalues are the closed-loop poles and their reciprocals:\n');
  printf('    max |eig(deflated) - [eig(Acl); 1./eig(Acl)]| = %.3e\n', max(abs(ed - both)));
  printf('    product of all four = %g (1 when no closed-loop pole sits at 0)\n\n', prod(ed));
end
