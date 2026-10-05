% trace_qz_pencil.m -- the whole route for one instance of the running example, printed at the
% level of the generalized Schur form: the extended pencil, the unordered pairs, the deflated
% pencil, the ordered pairs, S, T, U11, U21, P, and the diagnostics.
%
% Companion to verify_qz_riccati.m: that script reproduces every number quoted in the note; this
% one prints the intermediate objects the note describes in words. It uses the real QZ, so S and T
% are quasi-upper-triangular in real arithmetic as a library would produce them.
%
%     octave --no-gui --quiet Control/qz-riccati/scripts/trace_qz_pencil.m

1;
format short

function [H, N] = extended_pencil(A, B, Q, R)
  [m, n] = size(B);
  H = [A, zeros(m), B; -Q, -A', zeros(m, n); zeros(n, m), B', R];
  N = [eye(m), zeros(m), zeros(m, n); zeros(m), eye(m), zeros(m, n); zeros(n, 2*m+n)];
end

function [Hd, Nd] = deflate_pencil(H, N, n2, p)
  % QR of the last p block columns, then keep the leading 2n rows (van Dooren, eq. (55))
  [q, ~] = qr(H(:, n2+1:n2+p));
  Hd = q(:, p+1:n2+p)' * H(:, 1:n2);
  Nd = q(1:n2, p+1:n2+p)' * N(1:n2, 1:n2);
end

function P = closed_rho(r)
  p12 = sqrt(r^2 + r) - r;
  p22 = sqrt(r*(2*p12 + 1));
  P = [p22 + p12*p22/r, p12; p12, p22];
end

function show_pairs(tag, AA, BB)
  printf('%s\n', tag);
  for k = 1:rows(AA)
    if abs(BB(k,k)) > 0
      printf('   alpha = %+10.6f   beta = %+10.6f   alpha/beta = %+12.6f\n', ...
        AA(k,k), BB(k,k), AA(k,k)/BB(k,k));
    else
      printf('   alpha = %+10.6f   beta = %+10.6f   alpha/beta = infinite\n', AA(k,k), BB(k,k));
    end
  end
end

function show_mat(tag, M, fmt)
  printf('%s\n', tag);
  for i = 1:rows(M)
    printf('  ');
    for j = 1:columns(M)
      v = M(i,j);
      if v == 0, v = 0; end   % print -0 as 0
      printf(fmt, v);
    end
    printf('\n');
  end
end

A = [0 1; -1 0]; B = [0; 1]; Q = eye(2); rho = 1e-6; R = rho;
printf('running example: A = [0 1; -1 0], B = [0; 1], Q = I, R = %g\n', R);

[H, N] = extended_pencil(A, B, Q, R);
printf('\n== the extended pencil, %dx%d, with B and R as blocks ==\n', rows(H), columns(H));
show_mat('H =', H, '%9.4g');
show_mat('N =', N, '%9.4g');

[AA, BB, ~, ~] = qz(H, N, 'real');
printf('\n== pairs from QZ on the full pencil (unordered) ==\n');
show_pairs('', AA, BB);

[Hd, Nd] = deflate_pencil(H, N, 4, 1);
printf('\n== after the QR deflation: %dx%d, smallest singular value of N_d = %.4e ==\n', ...
  rows(Hd), columns(Hd), min(svd(Nd)));

[AA, BB, Qz, Z] = qz(Hd, Nd, 'real');
printf('\n== QZ on the deflated pencil, before ordering ==\n');
show_pairs('', AA, BB);

[AA, BB, Qz, Z] = ordqz(AA, BB, Qz, Z, 'lhp');
printf('\n== ordered so that Re(alpha/beta) < 0 leads ==\n');
show_pairs('', AA, BB);
show_mat('S (quasi-upper-triangular) =', AA, '%10.4f');
show_mat('T (quasi-upper-triangular) =', BB, '%10.4f');

U = Z(:, 1:2); U11 = U(1:2, :); U21 = U(3:4, :);
show_mat('U11 =', U11, '%14.6f');
show_mat('U21 =', U21, '%14.6f');
printf('cond(U11) = %.4f\n', cond(U11));
P = U21 / U11;
show_mat('P = U21 / U11 =', P, '%14.6f');
show_mat('closed form P =', closed_rho(rho), '%14.6f');

printf('\n== diagnostics ==\n');
printf('relative error of P against the closed form   = %.3e\n', norm(P - closed_rho(rho))/norm(closed_rho(rho)));
printf('symmetry defect ||U11''U21 - U21''U11||        = %.3e\n', norm(U11'*U21 - U21'*U11));
printf('CARE residual   ||A''P + PA - PGP + Q||        = %.3e\n', ...
  norm(A'*P + P*A - P*(B*(1/R)*B')*P + Q));
printf('orthogonality   ||Qz''Qz - I|| = %.3e, ||Z''Z - I|| = %.3e\n', ...
  norm(Qz'*Qz - eye(rows(Qz))), norm(Z'*Z - eye(rows(Z))));
printf('closed-loop eigenvalues of the computed P     = ');
printf('%+.6f ', sort(real(eig(A - (B*(1/R)*B')*P))));
printf('\n');
