% qz_sweeps.m -- the reduction and one iteration of the QZ algorithm, printed step by step.
% Octave, standard library only. Run from the repository root:
%   octave --no-gui --quiet Algebra/qz-algorithm/scripts/qz_sweeps.m
%
% The reduction (phase 1 + phase 2) is implemented here for the note's running example.
% The iteration is implemented as a *complex single-shift* QZ sweep -- the form a complex
% driver (LAPACK zggev) uses.  A real driver (dggev) takes the two shifts of the trailing
% 2x2 pencil at once so it can stay in real arithmetic; the rotation pattern and the
% convergence check are the same.  The note says which part is which.

1;
more off;
format short

function [c, s] = gz(a, b)
  % [c s; -s c] * [a; b] = [r; 0]
  if b == 0, c = 1; s = 0; return; end
  r = hypot(a, b); c = a/r; s = b/r;
end

function [Ah, Bh, Q, Z, log] = ht_reduce(A, B)
  n = size(A,1); Ah = A; Bh = B; Q = eye(n); Z = eye(n); log = {};
  % phase 1 -- Householder QR of B from the left, applied to both
  for k = 1:n-1
    x = Bh(k:n,k); nx = norm(x);
    if nx > 0
      alpha = -sign(x(1))*nx; if x(1) == 0, alpha = -nx; end
      v = x; v(1) = v(1) - alpha; nv = norm(v);
      if nv > 0
        v = v/nv;
        Bh(k:n,k:n) = Bh(k:n,k:n) - 2*v*(v'*Bh(k:n,k:n));
        Ah(k:n,:)   = Ah(k:n,:)   - 2*v*(v'*Ah(k:n,:));
        H = eye(n); H(k:n,k:n) = H(k:n,k:n) - 2*(v*v');
        Q = H*Q;
      end
    end
  end
  log{end+1} = 'phase 1: QR of B from the left, applied to A and B; B is triangular now';
  % phase 2 -- reduce A to Hessenberg, repairing B with a paired right rotation
  for k = 1:n-2
    for i = n:-1:k+2
      a1 = Ah(i-1,k); a2 = Ah(i,k);
      if abs(a2) > 0
        [c,s] = gz(a1,a2);
        G = eye(n); G(i-1,i-1)=c; G(i-1,i)=s; G(i,i-1)=-s; G(i,i)=c;
        Ah = G*Ah; Bh = G*Bh; Q = G*Q;
        log{end+1} = sprintf('left  rot rows (%d,%d): zeros A(%d,%d); fills B(%d,%d) = %+.4f', ...
                             i-1, i, i, k, i, i-1, Bh(i,i-1));
        p = Bh(i,i-1); q = Bh(i,i); r = hypot(p,q); c2 = q/r; s2 = p/r;
        Zc = eye(n); Zc(i-1,i-1)=c2; Zc(i-1,i)=s2; Zc(i,i-1)=-s2; Zc(i,i)=c2;
        Ah = Ah*Zc; Bh = Bh*Zc; Z = Z*Zc;
        log{end+1} = sprintf('right rot cols (%d,%d): clears B(%d,%d) -> %+.4f', ...
                             i-1, i, i, i-1, Bh(i,i-1));
      end
    end
  end
end

function [H, T, pairs, sweeps] = qz_iterate(H, T)
  n = size(H,1); pairs = zeros(n,2); m = n; guard = 0; sweeps = 0; tol = 1e-13;
  while m > 1 && guard < 500
    guard = guard + 1;
    if abs(H(m,m-1)) <= tol*(abs(H(m-1,m-1)) + abs(H(m,m)) + 1e-300)
      H(m,m-1) = 0; pairs(m,:) = [H(m,m) T(m,m)]; m = m - 1; continue;
    end
    Hs = H(m-1:m,m-1:m); Ts = T(m-1:m,m-1:m); e = eig(Hs,Ts);
    target = H(m,m)/T(m,m); [~, idx] = min(abs(e - target)); mu = e(idx);
    x1 = H(1,1) - mu*T(1,1); x2 = H(2,1); [c,s] = gz(x1,x2);
    Gm = eye(m); Gm(1,1)=c; Gm(1,2)=s; Gm(2,1)=-s; Gm(2,2)=c;
    H(1:m,1:m) = Gm*H(1:m,1:m); T(1:m,1:m) = Gm*T(1:m,1:m);
    p = T(2,1); q = T(2,2); r = hypot(p,q); c2 = q/r; s2 = p/r;
    Zm = eye(m); Zm(1,1)=c2; Zm(1,2)=s2; Zm(2,1)=-s2; Zm(2,2)=c2;
    H(1:m,1:m) = H(1:m,1:m)*Zm; T(1:m,1:m) = T(1:m,1:m)*Zm;
    for k = 2:m-1
      a1 = H(k,k-1); a2 = H(k+1,k-1); [c3,s3] = gz(a1,a2);
      Gk = eye(m); Gk(k,k)=c3; Gk(k,k+1)=s3; Gk(k+1,k)=-s3; Gk(k+1,k+1)=c3;
      H(1:m,1:m) = Gk*H(1:m,1:m); T(1:m,1:m) = Gk*T(1:m,1:m);
      p = T(k+1,k); q = T(k+1,k+1); r = hypot(p,q); c4 = q/r; s4 = p/r;
      Zk = eye(m); Zk(k,k)=c4; Zk(k,k+1)=s4; Zk(k+1,k)=-s4; Zk(k+1,k+1)=c4;
      H(1:m,1:m) = H(1:m,1:m)*Zk; T(1:m,1:m) = T(1:m,1:m)*Zk;
    end
    sweeps = sweeps + 1;
  end
  pairs(1,:) = [H(1,1) T(1,1)];
end

function pr(name, M)
  fprintf('%s =\n', name);
  for i = 1:rows(M)
    fprintf('  '); fprintf('%+9.4f ', real(M(i,:))); fprintf('\n');
  end
end

% ---------------------------------------------------------------- the example
c0 = 1/sqrt(2); U = [c0 0 -c0; 0 1 0; c0 0 c0];
S0 = [0 -1 0; 1 0 0; 0 0 1];
d = 0.5; A = U*S0*U'; B = U*diag([1 1 d])*U';

fprintf('================ the reduction, delta = %.1f ================\n', d);
pr('A', A); pr('B', B);
[Ah,Bh,Q,Z,log] = ht_reduce(A,B);
fprintf('\nrecorded operations:\n');
for k = 1:numel(log), fprintf('  %s\n', log{k}); end
fprintf('\n');
pr('A after phase 1', []);
% redo phase 1 alone to print the intermediate (ht_reduce does not keep it)
A1 = A; B1 = B;
for k = 1:2
  x = B1(k:3,k); nx = norm(x); alpha = -sign(x(1))*nx; if x(1)==0, alpha = -nx; end
  v = x; v(1) = v(1)-alpha; v = v/norm(v);
  B1(k:3,k:3) = B1(k:3,k:3) - 2*v*(v'*B1(k:3,k:3));
  A1(k:3,:)   = A1(k:3,:)   - 2*v*(v'*A1(k:3,:));
end
pr('A after phase 1', A1); pr('B after phase 1', B1);
% phase-2 step, printed before and after
a1 = A1(2,1); a2 = A1(3,1); [c,s] = gz(a1,a2);
G = eye(3); G(2,2)=c; G(2,3)=s; G(3,2)=-s; G(3,3)=c;
A2 = G*A1; B2 = G*B1;
fprintf('\nleft rotation rows (2,3): c = %+.4f, s = %+.4f\n', c, s);
pr('A after left rotation', A2); pr('B after left rotation (fill at (3,2))', B2);
p = B2(3,2); q = B2(3,3); r = hypot(p,q); c2 = q/r; s2 = p/r;
Zc = eye(3); Zc(2,2)=c2; Zc(2,3)=s2; Zc(3,2)=-s2; Zc(3,3)=c2;
A3 = A2*Zc; B3 = B2*Zc;
fprintf('\nright rotation cols (2,3): c = %+.4f, s = %+.4f\n', c2, s2);
pr('A after right rotation (Hessenberg)', A3); pr('B after right rotation (triangular)', B3);
fprintf('\nA below its band  = %.2e\n', max(abs(tril(Ah,-2))(:)));
fprintf('B below diagonal  = %.2e\n', max(abs(tril(Bh,-1))(:)));
fprintf('Q, Z orthogonality = %.2e, %.2e\n', norm(Q'*Q-eye(3)), norm(Z'*Z-eye(3)));
fprintf('equivalence       = %.2e, %.2e\n', norm(Q'*Ah*Z'-A), norm(Q'*Bh*Z'-B));

fprintf('\n================ one QZ sweep on the reduced pair ================\n');
% A complex single shift (as a complex driver uses).  The entries become complex, so we
% report magnitudes of the moving bulge rather than dumping complex matrices.
H = complex(Ah); T = complex(Bh);
Hs = H(2:3,2:3); Ts = T(2:3,2:3); e = eig(Hs,Ts);
fprintf('trailing 2x2 pencil eigenvalues = %+.4f%+.4fi, %+.4f%+.4fi\n', ...
        real(e(1)),imag(e(1)),real(e(2)),imag(e(2)));
target = H(3,3)/T(3,3); [~,idx] = min(abs(e-target)); mu = e(idx);
fprintf('shift mu (nearest H_33/T_33)      = %+.4f%+.4fi\n', real(mu), imag(mu));
x1 = H(1,1)-mu*T(1,1); x2 = H(2,1); [c,s] = gz(x1,x2);
Gm = eye(3); Gm(1,1)=c; Gm(1,2)=s; Gm(2,1)=-s; Gm(2,2)=c;
H = Gm*H; T = Gm*T;
fprintf('after left  rows (1,2): |T(2,1)| = %.4f\n', abs(T(2,1)));
p = T(2,1); q = T(2,2); r = hypot(p,q); c2 = q/r; s2 = p/r;
Zm = eye(3); Zm(1,1)=c2; Zm(1,2)=s2; Zm(2,1)=-s2; Zm(2,2)=c2;
H = H*Zm; T = T*Zm;
fprintf('after right cols (1,2): |H(3,1)| = %.4f  (T triangular again)\n', abs(H(3,1)));
a1 = H(2,1); a2 = H(3,1); [c3,s3] = gz(a1,a2);
Gk = eye(3); Gk(2,2)=c3; Gk(2,3)=s3; Gk(3,2)=-s3; Gk(3,3)=c3;
H = Gk*H; T = Gk*T;
fprintf('after left  rows (2,3): |T(3,2)| = %.4f  (H back in Hessenberg form)\n', abs(T(3,2)));
p = T(3,2); q = T(3,3); r = hypot(p,q); c4 = q/r; s4 = p/r;
Zk = eye(3); Zk(2,2)=c4; Zk(2,3)=s4; Zk(3,2)=-s4; Zk(3,3)=c4;
H = H*Zk; T = T*Zk;
fprintf('after right cols (2,3): T triangular; one sweep complete\n');

fprintf('\n================ iterate to convergence ================\n');
[Hc, Tc, pairs, sweeps] = qz_iterate(complex(Ah), complex(Bh));
fprintf('sweeps = %d\n', sweeps);
ex = [1i; -1i; 1/d];
fprintf('exact      = '); fprintf('%+12.8f%+12.8fi ', [real(ex) imag(ex)].'); fprintf('\n');
fprintf('computed   = ');
got = pairs(:,1)./pairs(:,2);
fprintf('%+12.8f%+12.8fi ', [real(got) imag(got)].'); fprintf('\n');
fprintf('A below band = %.2e, B below diagonal = %.2e\n', ...
        max(abs(tril(Hc,-2))(:)), max(abs(tril(Tc,-1))(:)));
