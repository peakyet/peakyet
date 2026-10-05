% qz_sweeps.m -- two parts of the QZ algorithm, run on real data so the note's figures and its
% demo can be drawn from measured states rather than a cartoon:
%
%   (1) the Hessenberg-triangular reduction, recorded rotation by rotation, including the entry of B
%       that each left rotation fills in below the diagonal and the right rotation that removes it;
%   (2) the elementary QZ step of a 2x2 pencil, exactly: the right rotation that puts the pencil's
%       eigenvector in the first coordinate, and the left rotation that then makes both matrices
%       triangular.
%
% The implicit double-shift sweep that a library runs between those two ends (bulge chasing, O(n^2)
% per sweep) is NOT implemented here: writing it by hand is the one piece the note tells the reader
% not to write. See Moler & Stewart (1973) and LAPACK's dhgeqz.
%
%     octave --no-gui --quiet Control/qz-riccati/scripts/qz_sweeps.m

1;

function [v, beta] = house(x)
  % (I - beta v v') x = alpha e1, with v(1) = 1
  x = x(:); n = numel(x);
  nx = norm(x);
  if nx == 0, v = zeros(n, 1); beta = 0; return; end
  if x(1) >= 0, alpha = -nx; else, alpha = nx; end     % never sign(0) = 0
  if alpha == 0, v = zeros(n, 1); beta = 0; return; end
  v = x; v(1) = v(1) - alpha;
  beta = 2 / (v' * v);
end

function X = hleft(X, v, beta, rows)
  X(rows, :) = X(rows, :) - beta * v * (v' * X(rows, :));
end

function X = hright(X, v, beta, cols)
  X(:, cols) = X(:, cols) - beta * (X(:, cols) * v) * v';
end

function [c, s] = givens(a, b)
  % rotation G = [c s; -s c] with G*[a; b] = [r; 0]; also used on the right, where
  % (B*G)(m, p) = c B(m,p) - s B(m,q) for columns (p, q)
  if b == 0, c = 1; s = 0; return; end
  r = hypot(a, b); c = a / r; s = b / r;
end

function [A, B, Q, Z, steps] = hess_tri(A, B, Q, Z)
  % Hessenberg-triangular reduction: A upper Hessenberg, B upper triangular, Q' M Z = A,
  % Q' N Z = B. Phase 1 triangularizes B from the left. Phase 2 zeroes A below its sub-diagonal
  % with a bottom-up sweep, one entry per rotation pair, and records every state for the figures.
  [n, ~] = size(A);
  steps = {};
  for k = 1:n-1
    [v, beta] = house(B(k:n, k));
    if beta ~= 0
      B = hleft(B, v, beta, k:n); A = hleft(A, v, beta, k:n); Q = hright(Q, v, beta, k:n);
      steps{end+1} = struct('kind', 'B triangularized, left Householder on rows', ...
        'p', k, 'q', n, 'A', A, 'B', B);
    end
  end
  for k = 1:n-2
    for i = n:-1:k+2
      [c, s] = givens(A(i-1, k), A(i, k));
      G = [c, s; -s, c];
      A([i-1, i], :) = G * A([i-1, i], :);
      B([i-1, i], :) = G * B([i-1, i], :);
      Q(:, [i-1, i]) = Q(:, [i-1, i]) * G';
      fill = B(i, i-1);
      steps{end+1} = struct('kind', sprintf('left rotation on rows (%d,%d): A(%d,%d) -> 0, B(%d,%d) filled to %.4f', i-1, i, i, k, i, i-1, fill), ...
        'p', i-1, 'q', i, 'A', A, 'B', B);
      [c, s] = givens(B(i, i), B(i, i-1));
      G = [c, s; -s, c];
      A(:, [i-1, i]) = A(:, [i-1, i]) * G;
      B(:, [i-1, i]) = B(:, [i-1, i]) * G;
      Z(:, [i-1, i]) = Z(:, [i-1, i]) * G;
      steps{end+1} = struct('kind', sprintf('right rotation on columns (%d,%d): B(%d,%d) -> 0', i-1, i, i, i-1), ...
        'p', i-1, 'q', i, 'A', A, 'B', B);
    end
  end
end

function [A2, B2, Q2, Z2, info] = qz2(A2in, B2in)
  % The QZ step for a 2x2 pencil, exactly. Z2 puts an eigenvector of the pencil in the first
  % coordinate; the first columns of A2*Z2 and B2*Z2 are then parallel, so one left rotation makes
  % both matrices triangular. info carries the numbers the figures need.
  A2 = A2in; B2 = B2in;
  % eigenvector of the pivot: use the eigenvalue of the pencil nearest the (2,2) diagonal ratio
  c2 = det(B2); c1 = -(A2(1,1)*B2(2,2) + A2(2,2)*B2(1,1) - A2(1,2)*B2(2,1) - A2(2,1)*B2(1,2));
  c0 = det(A2);
  sc = max(abs([c2, c1, c0]));
  if sc == 0, sc = 1; end
  c2 = c2/sc; c1 = c1/sc; c0 = c0/sc;
  disc = c1^2 - 4*c2*c0;
  if disc >= 0, sq = sqrt(disc); else, sq = sqrt(-disc) * 1i; end
  t = -c1 - sign(real(c1) + (real(c1) == 0)) * sq;
  cand = [t, 2*c2; 2*c0, t];                              % the two eigenvalues as (alpha, beta)
  al = 0; be = 0; best = inf;
  for r = 1:2
    aa = cand(r,1); bb = cand(r,2);
    if abs(bb) > 0, d = abs(aa/bb - A2(2,2)/B2(2,2)); else, d = inf; end
    if d < best, best = d; al = aa; be = bb; end
  end
  nrm = sqrt(abs(al)^2 + abs(be)^2); if nrm > 0, al = al/nrm; be = be/nrm; end
  % eigenvector of (beta*A - alpha*B) for that pair
  M = be*A2 - al*B2;
  vv = [M(2,2); -M(2,1)];
  if norm(vv) == 0, vv = [1; 0]; end
  vv = vv / norm(vv);
  % right rotation Z2 with first column vv
  Z2 = [vv, [-vv(2); vv(1)]];
  A2 = A2 * Z2; B2 = B2 * Z2;
  % left rotation that zeroes the second entry of the (parallel) first columns
  [c, s] = givens(B2(1,1), B2(2,1));
  Q2 = [c, s; -s, c];
  A2 = Q2 * A2; B2 = Q2 * B2;
  info = struct('alpha', al, 'beta', be, 'v', vv, 'angle', atan2(vv(2), vv(1)));
end

% ---- the instance: oscillator with damping, Q = I, R = 1. Its closed-loop spectrum is real, so
% ---- the panels show a genuinely triangular Schur form; the well-conditioned R keeps B's
% ---- diagonal away from zero.
A0 = [0 1; -1 -2]; B0 = [0; 1]; Q0 = eye(2); rho = 1;
m = 2; p = 1; n2 = 4;
H = [A0, zeros(m), B0; -Q0, -A0', zeros(m, p); zeros(p, m), B0', rho];
N = [eye(m), zeros(m), zeros(m, p); zeros(m), eye(m), zeros(m, p); zeros(p, 2*m+p)];
[q, ~] = qr(H(:, n2+1:n2+p));
Hd = q(:, p+1:n2+p)' * H(:, 1:n2);
Nd = q(1:n2, p+1:n2+p)' * N(1:n2, 1:n2);

printf('=== the deflated pencil for the damped oscillator (4x4) ===\n');
disp(Hd); disp(Nd);
printf('eigenvalues: '); printf('%.6f%+.6fi ', [real(eig(Hd,Nd))'; imag(eig(Hd,Nd))']); printf('\n');

printf('\n=== part 1: the Hessenberg-triangular reduction, step by step ===\n');
[A, B, Q, Z, steps] = hess_tri(Hd, Nd, eye(4), eye(4));
for s = 1:numel(steps)
  printf('%-78s A(4,1)=%+.3f A(3,1)=%+.3f A(4,2)=%+.3f B(4,2)=%+.3f B(3,2)=%+.3f B(4,3)=%+.3f\n', ...
    steps{s}.kind, steps{s}.A(4,1), steps{s}.A(3,1), steps{s}.A(4,2), steps{s}.B(4,2), steps{s}.B(3,2), steps{s}.B(4,3));
end
ph1 = (numel(steps) >= 3);   % after the last Householder of phase 1
for s_ = 1:numel(steps), if ~isempty(strfind(steps{s_}.kind, 'Householder')), ph1 = steps{s_}; end, end
printf('state after phase 1 (B triangular, A full):\n'); disp(ph1.A); disp(ph1.B);
printf('final A (upper Hessenberg):\n'); disp(A);
printf('final B (upper triangular):\n'); disp(B);
printf('  below the band: A = %.1e, B = %.1e\n', ...
  max(abs([A(3,1), A(4,1), A(4,2)])), max(abs([B(2,1), B(3,1), B(4,1), B(3,2), B(4,2), B(4,3)])));
printf('  ||Q''Q-I|| = %.2e, ||Z''Z-I|| = %.2e, ||Q''HdZ-A|| = %.2e, ||Q''NdZ-B|| = %.2e\n', ...
  norm(Q'*Q-eye(4)), norm(Z'*Z-eye(4)), norm(Q'*Hd*Z-A), norm(Q'*Nd*Z-B));
printf('  eigenvalues kept: '); printf('%.6f%+.6fi ', [real(eig(A,B))'; imag(eig(A,B))']); printf('\n');

printf('\n=== part 2: the elementary QZ step on the trailing 2x2 pencil ===\n');
A2 = A(3:4, 3:4); B2 = B(3:4, 3:4);
printf('the 2x2 pencil:\n'); disp(A2); disp(B2);
printf('its eigenvalues: '); printf('%.6f%+.6fi ', [real(eig(A2,B2))'; imag(eig(A2,B2))']); printf('\n');
[A2s, B2s, Q2, Z2, info] = qz2(A2, B2);
printf('shift used: (alpha, beta) = (%.6f, %.6f), alpha/beta = %.6f\n', info.alpha, info.beta, info.alpha/info.beta);
printf('eigenvector direction of that shift: (%.6f, %.6f), angle %.4f rad\n', info.v(1), info.v(2), info.angle);
printf('Z2 =\n'); disp(Z2); printf('Q2 =\n'); disp(Q2);
printf('after the step: A =\n'); disp(A2s); printf('B =\n'); disp(B2s);
printf('  below the diagonals: A = %.1e, B = %.1e\n', abs(A2s(2,1)), abs(B2s(2,1)));
printf('  ||Q2''Q2-I|| = %.2e, ||Z2''Z2-I|| = %.2e\n', norm(Q2'*Q2-eye(2)), norm(Z2'*Z2-eye(2)));
printf('  reconstruction ||Q2''*A_s*Z2'' - A_in|| = %.2e, ||Q2''*B_s*Z2'' - B_in|| = %.2e\n', norm(Q2'*A2s*Z2' - A2), norm(Q2'*B2s*Z2' - B2));
printf('  eigenvalues of the step: '); printf('%.6f%+.6fi ', [real(eig(A2s,B2s))'; imag(eig(A2s,B2s))']); printf('\n');
printf('  pairs on the diagonal: (%.6f, %.6f) and (%.6f, %.6f)\n', A2s(1,1), B2s(1,1), A2s(2,2), B2s(2,2));
printf('  ratios: %.6f and %.6f\n', A2s(1,1)/B2s(1,1), A2s(2,2)/B2s(2,2));
