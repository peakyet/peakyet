% verify_sda.m -- prints every number quoted in the SDA note.
% Run from the repository root with
%   octave --no-gui --quiet Control/sda-riccati/scripts/verify_sda.m
% Standard library only. Sections are labelled with the note's section numbers.
1;
format long g;

% ---------------------------------------------------------------- helpers
function [Ad, Gd, Qd] = cayley(Ac, Gc, Qc, tau)
  % Continuous -> discrete via the Cayley reduction, eq. (18) of the note.
  n = rows(Ac);
  T = inv([Ac - tau*eye(n), -Gc; Qc, Ac' - tau*eye(n)]) * [Ac + tau*eye(n), -Gc; Qc, Ac' + tau*eye(n)];
  Ad = T(1:n,1:n); Gd = T(1:n,n+1:2*n); Qd = -T(n+1:2*n,1:n);
end

function S = sympl(A, G, Q)
  % eq. (7): the symplectic matrix S.
  n = rows(A);
  S = inv([eye(n), G; zeros(n,n), A']) * [A, zeros(n,n); -Q, eye(n)];
end

function X = fixed_point(A, G, Q, iters)
  n = rows(A); X = zeros(n);
  for j = 1:iters
    X = Q + A'*X*inv(eye(n)+G*X)*A;
  end
end

function [steps, X] = count_fp(A, G, Q, tol)
  % Smallest j at which the value iteration stops changing by more than
  % tol relative to its own norm; same criterion as count_sda below.
  n = rows(A); X = zeros(n); steps = 0;
  for j = 1:2000000
    X1 = Q + A'*X*inv(eye(n)+G*X)*A;
    change = norm(X1 - X,'fro'); scale = max(1, norm(X1,'fro'));
    X = X1; steps = j;
    if change <= tol*scale, break; end
  end
end

function [steps, Qk] = sda(A, G, Q, tol)
  % eq. (15): the structure-preserving doubling algorithm, same stopping rule.
  n = rows(A); Ak = A; Gk = G; Qk = Q; steps = 0;
  for k = 1:300
    W1 = eye(n)+Gk*Qk; W2 = eye(n)+Qk*Gk;
    Ak1 = Ak*inv(W1)*Ak; Gk1 = Gk + Ak*Gk*inv(W2)*Ak'; Qk1 = Qk + Ak'*inv(W2)*Qk*Ak;
    change = norm(Qk1-Qk,'fro'); scale = max(1,norm(Qk1,'fro'));
    Ak = Ak1; Gk = Gk1; Qk = Qk1; steps = k;
    if change <= tol*scale, break; end
  end
end

% exact closed form of the plant's continuous Riccati solution
function P = care_closed(eps)
  p12 = sqrt(1+eps) - 1; p22 = sqrt(2*p12 + eps); p11 = p22*(1 + p12);
  P = [p11, p12; p12, p22];
end

% ======================== 1. the running plant ==========================
printf("=== S1/S7: continuous plant, closed form (Q=I, R=1) ===\n");
Ac = [0 1; -1 0]; Bc = [0;1]; Gc = Bc*Bc'; Qc = eye(2);
p12 = sqrt(2)-1; p22 = sqrt(2*p12+1); p11 = p22*(1+p12);
P = [p11, p12; p12, p22];
printf("closed form: p12 = %.9f  p22 = %.9f  p11 = %.9f\n", p12, p22, p11);
printf("P = [%.9f %.9f; %.9f %.9f]\n", P(1,1), P(1,2), P(2,1), P(2,2));
printf("CARE residual = %.3e\n", norm(Ac'*P + P*Ac - P*Gc*P + Qc, 'fro'));
printf("CARE closed loop eig = "); ec = sort(eig(Ac-Gc*P)); printf("%.6f%+.6fi ", [real(ec),imag(ec)].'); printf("\n");

printf("\n=== S1: running discrete data = Cayley image of the plant (tau=1) ===\n");
[Ad, Gd, Qd] = cayley(Ac, Gc, Qc, 1);
printf("A = [%.9f %.9f; %.9f %.9f]\n", Ad(1,1), Ad(1,2), Ad(2,1), Ad(2,2));
printf("G = [%.9f %.9f; %.9f %.9f]\n", Gd(1,1), Gd(1,2), Gd(2,1), Gd(2,2));
printf("Q = [%.9f %.9f; %.9f %.9f]\n", Qd(1,1), Qd(1,2), Qd(2,1), Qd(2,2));
printf("||G-G'|| = %.2e  ||Q-Q'|| = %.2e\n", norm(Gd-Gd','fro'), norm(Qd-Qd','fro'));
Xfp = fixed_point(Ad, Gd, Qd, 4000);
printf("DARE fixed-point limit vs continuous P: %.2e\n", norm(Xfp-P,'fro'));
printf("discrete residual at P: %.2e\n", norm(P-(Qd+Ad'*P*inv(eye(2)+Gd*P)*Ad),'fro'));
K = inv(eye(2)+Gd*P)*Ad;
printf("sigma = rho((I+GP)^{-1}A) = %.8f\n", max(abs(eig(K))));

% ================= 2. the graph map and its spectrum ====================
printf("\n=== S2: S is symplectic, spectrum in reciprocal pairs ===\n");
S = sympl(Ad, Gd, Qd); n = 2;
J = [zeros(n),eye(n); -eye(n),zeros(n)];
printf("symplectic defect ||S'JS - J|| = %.3e\n", norm(S'*J*S - J,'fro'));
es = eig(S); printf("eig(S) = "); printf("%.6f%+.6fi ", [real(es), imag(es)].'); printf("\n");
printf("moduli  = "); printf("%.8f ", sort(abs(es)).'); printf("\n");

printf("\n=== S2: scalar geometry example (Figure 1) ===\n");
a = 1.2; g = 1; q = 0.1;
xs = (-(1-q*g-a^2) + sqrt((1-q*g-a^2)^2 + 4*g*q))/(2*g);
printf("x_+ = %.8f   angle = %.3f deg\n", xs, atan(xs)*180/pi);
X = 0; printf("X_j = 0.00000");
for j = 1:8, X = q + a^2*X/(1+g*X); printf(" %.5f", X); end
printf("\n");

% ===================== 4. the powers that fail ==========================
printf("\n=== S4: explicit power vs factored form (Table 1) ===\n");
Ak = Ad; Gk = Gd; Qk = Qd;
for k = 0:6
  M = [Ak, zeros(n,n); -Qk, eye(n)]; N = [eye(n), Gk; zeros(n,n), Ak'];
  Sp = inv(S)^(2^k);
  printf("k=%d  explicit %.3e   factored %.3e\n", k, norm(Sp - inv(M)*N,'fro'), ...
     norm(Sp*[eye(n);zeros(n)] - [eye(n);Qk]*inv(Ak),'fro'));
  W1=eye(n)+Gk*Qk; W2=eye(n)+Qk*Gk;
  A1=Ak*inv(W1)*Ak; G1=Gk+Ak*Gk*inv(W2)*Ak'; Q1=Qk+Ak'*inv(W2)*Qk*Ak; Ak=A1; Gk=G1; Qk=Q1;
end

% ================== 5/6. the doubling algorithm =========================
printf("\n=== S6: SDA iterates, exactness and convergence (Table 2) ===\n");
Ak = Ad; Gk = Gd; Qk = Qd;
printf("k=0  Q=[%.6f %.6f; %.6f %.6f]  ||Q_k - X_+|| = %.3e\n", Qk(1,1),Qk(1,2),Qk(2,1),Qk(2,2), norm(Qk-P,'fro'));
for k = 1:5
  W1=eye(n)+Gk*Qk; W2=eye(n)+Qk*Gk;
  A1=Ak*inv(W1)*Ak; G1=Gk+Ak*Gk*inv(W2)*Ak'; Q1=Qk+Ak'*inv(W2)*Qk*Ak; Ak=A1; Gk=G1; Qk=Q1;
  X2k = fixed_point(Ad, Gd, Qd, 2^k);      % the value iteration's own 2^k-th iterate
  printf("k=%d  Q=[%.6f %.6f; %.6f %.6f]  ||Q_k - X_{2^k}|| = %.3e  ||Q_k - X_+|| = %.3e\n", ...
     k, Qk(1,1),Qk(1,2),Qk(2,1),Qk(2,2), norm(Qk - X2k,'fro'), norm(Qk - P,'fro'));
end
[its_d, Qfin] = sda(Ad, Gd, Qd, 1e-14);
[its_f, Xfin] = count_fp(Ad, Gd, Qd, 1e-14);
printf("running example: value iteration %d steps, doubling %d steps; SDA limit vs P %.3e\n", ...
   its_f, its_d, norm(Qfin-P,'fro'));

% ===================== 6. convergence vs work ===========================
printf("\n=== S6: error against work (Figure 3) ===\n");
X = zeros(n); printf("value iteration log10 err:");
for j = 0:32
  if j>0, X = Qd + Ad'*X*inv(eye(2)+Gd*X)*Ad; end
  printf(" %.4f", log10(max(norm(X-P,'fro'),1e-30)));
end
printf("\n");
Ak = Ad; Gk = Gd; Qk = Qd; printf("doubling log10 err: %.4f", log10(max(norm(Qk-P,'fro'),1e-30)));
for k = 1:5
  W1=eye(n)+Gk*Qk; W2=eye(n)+Qk*Gk;
  A1=Ak*inv(W1)*Ak; G1=Gk+Ak*Gk*inv(W2)*Ak'; Q1=Qk+Ak'*inv(W2)*Qk*Ak; Ak=A1; Gk=G1; Qk=Q1;
  printf(" %.4f", log10(max(norm(Qk-P,'fro'),1e-30)));
end
printf("\n");

% ===================== 6. epsilon study (Table 3) =======================
printf("\n=== S6: epsilon study (Table 3), tol = 1e-14 relative change ===\n");
printf("  eps      sigma    value steps   doubling steps   SDA err vs closed form\n");
for eps = [1e-1 1e-2 1e-4 1e-6 1e-8]
  [Ad2, Gd2, Qd2] = cayley(Ac, Gc, eps*eye(2), 1);
  Pe = care_closed(eps);
  sig = max(abs(eig(inv(eye(2)+Gd2*Pe)*Ad2)));
  [nf, ~] = count_fp(Ad2, Gd2, Qd2, 1e-14);
  [nd, Qs] = sda(Ad2, Gd2, Qd2, 1e-14);
  printf("  %5.0e  %.6f  %10d   %10d   %.2e\n", eps, sig, nf, nd, norm(Qs-Pe,'fro'));
end

% ===================== 7. shift sensitivity =============================
printf("\n=== S7: shift sensitivity (Q=I, R=1) ===\n");
for tau = [0.25 0.5 1 2 4 10]
  [Ad3, Gd3, Qd3] = cayley(Ac, Gc, eye(2), tau);
  [nd3, Qk3] = sda(Ad3, Gd3, Qd3, 1e-14);
  printf("  tau=%5g : %2d steps, ||Q_k - P|| = %.2e\n", tau, nd3, norm(Qk3-P,'fro'));
end

% ===================== discriminating cases =============================
printf("\n=== checks: push-through identity and random 3x3 DARE ===\n");
printf("||(I+GQ)^{-1}G - G(I+QG)^{-1}|| = %.3e\n", norm(inv(eye(n)+Gd*Qd)*Gd - Gd*inv(eye(n)+Qd*Gd),'fro'));
rand('seed', 7);
for t = 1:3
  m = 3; Ar = rand(m)-0.5*eye(m); Br = rand(m,1); Gr = Br*Br';
  Qr = 0.1*eye(m) + 0.1*(rand(m)-0.5); Qr = Qr*Qr';
  Xf = fixed_point(Ar, Gr, Qr, 40000);
  [itq, Qs] = sda(Ar, Gr, Qr, 1e-15);
  printf("random %d: ||SDA - value iteration|| = %.3e  residual = %.3e  (%d doublings)\n", ...
    t, norm(Qs-Xf,'fro'), norm(Qs-(Qr+Ar'*Qs*inv(eye(m)+Gr*Qs)*Ar),'fro'), itq);
end
