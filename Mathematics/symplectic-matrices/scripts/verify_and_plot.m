% Reproduce the note's figures and check its mathematical examples.
% From the repository root:
% QT_QPA_PLATFORM=offscreen octave --no-gui --quiet Mathematics/symplectic-matrices/scripts/verify_and_plot.m
clear; close all;
pkg load control;
root = fileparts(fileparts(mfilename('fullpath')));
out = fullfile(root, 'assets');
if ~exist(out, 'dir'), mkdir(out); end
set(0, 'defaultfigurevisible', 'off');
set(0, 'defaultaxesfontsize', 12);
set(0, 'defaulttextfontname', 'DejaVu Sans');
set(0, 'defaultaxesfontname', 'DejaVu Sans');
navy = [0.09, 0.20, 0.31]; teal = [0.08, 0.49, 0.46];
rose = [0.76, 0.25, 0.30]; gray = [0.48, 0.51, 0.56];
J = [0,1;-1,0];

% Geometry: equal canonical area does not imply equal shape or energy.
theta = linspace(0, 2*pi, 401);
circle = [cos(theta); sin(theta)];
maps = {eye(2), [2,0;0,0.5], [1,1;0,1]};
names = {'Identity', 'Squeeze: diag(2, 1/2)', 'Shear: [1, 1; 0, 1]'};
f = figure('position', [0,0,1200,380], 'color', 'white');
for k = 1:3
  S = maps{k};
  assert(norm(S'*J*S-J, 'fro') < 1e-13);
  y = S*circle;
  subplot(1,3,k);
  fill(y(1,:), y(2,:), [0.88,0.95,0.94], 'edgecolor', teal, 'linewidth', 2);
  hold on; plot(circle(1,:), circle(2,:), '--', 'color', gray);
  plot([-2.5,2.5], [0,0], '-', 'color', gray);
  plot([0,0], [-2.5,2.5], '-', 'color', gray);
  axis equal; axis([-2.5,2.5,-2.1,2.1]); grid on;
  xlabel('q'); ylabel('p'); title(names{k}, 'color', navy);
  text(-2.2,-1.7,'Area = pi', 'color', navy);
end
print(f, fullfile(out,'canonical-area.png'), '-dpng', '-r160'); close(f);

% A volume-preserving four-dimensional map that is NOT symplectic.
J4 = [zeros(2),eye(2);-eye(2),zeros(2)];
D = diag([2,1,1,0.5]);
assert(abs(det(D)-1) < 1e-13);
assert(norm(D'*J4*D-J4, 'fro') > 1);

% Oscillator: exact, explicit Euler, and kick-drift symplectic Euler.
h = 0.2; N = 300; t = (0:N)*h;
E = [1,h;-h,1]; S = [1-h*h,h;-h,1];
W = [1,-h/2;-h/2,1];
assert(norm(S'*J*S-J, 'fro') < 1e-13);
assert(norm(S'*W*S-W, 'fro') < 1e-13);
assert(norm(E'*J*E-J, 'fro') > 0.05);
xe = zeros(2,N+1); xs = xe; xe(:,1) = xs(:,1) = [1;0];
for k = 1:N
  xe(:,k+1) = E*xe(:,k); xs(:,k+1) = S*xs(:,k);
end
energy_e = sum(xe.^2,1); energy_s = sum(xs.^2,1); % H/H(0)
assert(max(abs(energy_e-(1+h*h).^(0:N))) < 1e-8);
assert(max(abs(sum(xs.*(W*xs),1)-1)) < 1e-12);
assert(min(energy_s) >= 1/(1+h/2)-1e-12);
assert(max(energy_s) <= 1/(1-h/2)+1e-12);
assert(abs(energy_s(2)-1) > 0.01); % Symplectic does not mean energy exact.
% Stability boundary: a symplectic method can still be unstable.
for hh = [1.9,2.1]
  radius = max(abs(eig([1-hh*hh,hh;-hh,1])));
  if hh < 2, assert(radius < 1+1e-12); else, assert(radius > 1.5); end
end
f = figure('position', [0,0,1200,440], 'color', 'white');
subplot(1,2,1);
plot(xe(1,1:101), xe(2,1:101), '-', 'color', rose, 'linewidth', 1.4);
hold on; plot(cos(theta), -sin(theta), '--', 'color', navy, 'linewidth', 1.5);
plot(xs(1,:),xs(2,:),'-','color',teal,'linewidth',1.3);
limit = 1.08*max(max(abs(xe(:,1:101))));
axis equal; axis([-limit,limit,-limit,limit]); grid on; xlabel('q'); ylabel('p');
title('Phase portrait: first 100 Euler steps', 'color', navy);
legend('Explicit Euler','Exact circle','Symplectic Euler',...
  'location','southoutside','orientation','horizontal','fontsize',10);
subplot(1,2,2);
semilogy(t,energy_e,'-','color',rose,'linewidth',1.8); hold on;
semilogy(t,energy_s,'-','color',teal,'linewidth',1.5);
semilogy(t,ones(size(t)),'--','color',navy,'linewidth',1.2);
grid on; xlabel('Time (h = 0.2)'); ylabel('H_k / H_0 (log scale)');
title('300 steps: bounded is not constant', 'color', navy);
legend('Explicit Euler','Symplectic Euler','Exact','location','northwest');
print(f,fullfile(out,'oscillator.png'),'-dpng','-r160'); close(f);
fprintf('Oscillator: Euler H_300/H_0 = %.6f; symplectic range [%.6f, %.6f]\n',...
  energy_e(end), min(energy_s), max(energy_s));

% Continuous LQR: independently known double-integrator answer.
A = [0,1;0,0]; B = [0;1]; Q = eye(2); R = 1;
G = B*(R\B'); H = [A,-G;-Q,-A'];
Pexact = [sqrt(3),1;1,sqrt(3)];
[P,~,K] = care(A,B,Q,R);
assert(norm(P-Pexact,'fro') < 1e-11);
assert(norm(K-[1,sqrt(3)]) < 1e-11);
assert(norm(H'*J4+J4*H,'fro') < 1e-13);
assert(norm(expm(0.37*H)'*J4*expm(0.37*H)-J4,'fro') < 1e-12);
assert(norm(H*[eye(2);P]-[eye(2);P]*(A-G*P),'fro') < 1e-11);
assert(norm([eye(2);P]'*J4*[eye(2);P],'fro') < 1e-12);
assert(max(real(eig(A-B*K))) < -0.8);
fprintf('Double integrator: CARE error %.3g; invariant-graph residual %.3g\n',...
  norm(P-Pexact,'fro'), norm(H*[eye(2);P]-[eye(2);P]*(A-G*P),'fro'));

% Scalar LQR: stable/unstable directions and the terminal-cost graph.
Hs = [1,-1;-1,-1]; ps = 1+sqrt(2); pu = 1-sqrt(2);
assert(norm(Hs*[1;ps]+sqrt(2)*[1;ps]) < 1e-13);
assert(norm(Hs*[1;pu]-sqrt(2)*[1;pu]) < 1e-13);
f = figure('position',[0,0,1200,420],'color','white');
subplot(1,2,1); xx = linspace(-1.15,1.15,100);
plot(xx,ps*xx,'-','color',teal,'linewidth',2); hold on;
plot(xx,pu*xx,'--','color',rose,'linewidth',2);
for x0 = [-1,1]
  tt = linspace(0,2,100);
  plot(x0*exp(-sqrt(2)*tt),ps*x0*exp(-sqrt(2)*tt),'.','color',teal);
end
plot(0,0,'o','color',navy,'markerfacecolor',navy);
grid on; xlabel('State x'); ylabel('Costate lambda');
title('LQR selects a line in state-costate space','color',navy);
legend('Stable: lambda = (1 + sqrt(2)) x','Unstable: lambda = (1 - sqrt(2)) x',...
  'location','northwest');
subplot(1,2,2); tau = linspace(0,4,150); pv = zeros(size(tau));
for k = 1:numel(tau)
  F = expm(-tau(k)*[0,-1;-1,0]);
  pv(k) = F(2,1)/F(1,1);
end
assert(max(abs(pv-tanh(tau))) < 1e-13);
plot(tau,pv,'-','color',teal,'linewidth',2); hold on;
plot(tau,ones(size(tau)),'--','color',gray);
grid on; xlabel('Remaining horizon T - t'); ylabel('P(t)'); ylim([0,1.12]);
title('Integrator LQR: P(t) = tanh(T - t)','color',navy);
print(f,fullfile(out,'riccati-geometry.png'),'-dpng','-r160'); close(f);

% Discrete transfer and pencil on asymmetric data (order matters).
Ad = [1.1,0.3;-0.1,0.8]; Bd = [0.2;1]; Qd = diag([2,0.7]); Rd = 1.3;
Gd = Bd*(Rd\Bd');
M = [Ad,zeros(2);-Qd,eye(2)]; L = [eye(2),Gd;zeros(2),Ad'];
Sd = L\M;
assert(norm(M*J4*M'-L*J4*L','fro') < 1e-13);
assert(norm(Sd'*J4*Sd-J4,'fro') < 1e-12);
[Pd,~,Kd] = dare(Ad,Bd,Qd,Rd);
assert(norm(Sd*[eye(2);Pd]-[eye(2);Pd]*(Ad-Bd*Kd),'fro') < 1e-11);
assert(max(abs(eig(Ad-Bd*Kd))) < 1);
% A singular A still gives a valid symplectic pair.
As = [1,0.4;0,0];
Ms = [As,zeros(2);-Qd,eye(2)]; Ls = [eye(2),Gd;zeros(2),As'];
assert(rank(Ls) < 4);
assert(norm(Ms*J4*Ms'-Ls*J4*Ls','fro') < 1e-13);
% Thin-lens optics and a nontrivial block symplectic map.
optics = [1,0.7;0,1]*[1,0;-1/1.4,1];
assert(norm(optics'*J*optics-J,'fro') < 1e-13);
C = [1,0.3;-0.2,1.7];
T = blkdiag(C,inv(C'));
assert(norm(T'*J4*T-J4,'fro') < 1e-12);
fprintf('Discrete: symplectic defect %.3g; graph residual %.3g\n',...
  norm(Sd'*J4*Sd-J4,'fro'), norm(Sd*[eye(2);Pd]-[eye(2);Pd]*(Ad-Bd*Kd),'fro'));
fprintf('All checks passed. Figures written to %s\n',out);
