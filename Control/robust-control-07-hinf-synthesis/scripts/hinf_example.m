% Chapter 7: executable derivations, physical-loop checks, and the figure.
% Run from the repository root with Octave's control package.
1;
pkg load control;
s = tf('s');

% Storage inequality for M(s)=2/(s+3), not just a frequency-grid test.
assert(abs(norm(ss(2/(s+3)),Inf,1e-10)-2/3) < 1e-9);
assert(-6+4+1/.8^2 < 0); % p=1 is a strict storage certificate.
assert(36-16/.6^2 < 0); % no real Riccati roots at gamma=.6.
pminus = .8^2*(3-sqrt(9-4/.8^2));
pplus = .8^2*(3+sqrt(9-4/.8^2));
assert(-3+pminus/.8^2 < 0 && -3+pplus/.8^2 > 0);
printf('Storage example: roots %.6f, %.6f; exact norm %.6f\n',pminus,pplus,2/3);

% Normalized output-feedback plant: w=[measurement noise; process disturbance].
A=-1; B1=[0,1]; B2=1; C1=[1;0]; D12=[0;1]; C2=1; D21=[1,0];
P=ss(A,[B1,B2],[C1;C2],[zeros(2),D12;D21,0]);
assert(D12'*C1 == 0 && D12'*D12 == 1);
assert(B1*D21' == 0 && D21*D21' == 1);
gstar=sqrt(3)-1;

function [K,a,coupling] = central(gamma)
  % Rationalized root stays well defined at gamma=1 and gamma=Inf.
  assert(gamma > sqrt(3)-1);
  a=1/(1+sqrt(2-gamma^(-2)));
  coupling=a^2/gamma^2;
  Z=1/(1-coupling);
  AK=-1-Z*a+(gamma^(-2)-1)*a;
  K=ss(AK,Z*a,-a,0);
end

% Three distinct feasibility outcomes, including the coupling-failure region.
assert(2-.70^(-2) < 0);
a72=1/(1+sqrt(2-.72^(-2)));
assert(-1+(.72^(-2)-1)*a72 < 0 && a72^2/.72^2 > 1);
lo=.70; hi=1;
for j=1:50
  gamma=(lo+hi)/2;
  if gamma <= 1/sqrt(2), feasible=false;
  else
    a=1/(1+sqrt(2-gamma^(-2)));
    feasible=(a^2 < gamma^2);
  end
  if feasible, hi=gamma; else lo=gamma; end
end
assert(abs(hi-gstar) < 1e-12);
printf('Bisection gamma*: %.12f; analytic: %.12f\n',hi,gstar);

for gamma=[.7321,.75,1,1.2,2,Inf]
  [K,a,r]=central(gamma);
  N=lft(P,K);
  % Do not minreal before checking full plant+controller internal dynamics.
  assert(rows(N.a)==2 && max(real(eig(N.a))) < 0);
  achieved=norm(N,Inf,1e-10);
  assert(achieved < gamma && achieved > gstar);
  if isfinite(gamma)
    assert(abs(-2*a+(gamma^(-2)-1)*a^2+1) < 1e-12);
    assert(-1+(gamma^(-2)-1)*a < 0 && r < 1);
  end
  % Independent elimination of the physical equations, including feedback sign.
  h=-K.c*K.b; p=-K.a;
  for w=[0,.13,1.7,20]
    q=1i*w; den=(q+1)*(q+p)+h;
    expected=[-h,q+p;-h*(q+1),-h]/den;
    assert(norm(freqresp(N,w)-expected,2) < 1e-9);
  end
  printf(['gamma=%7.4f: X=Y=%.6f; coupling=%.6f; ' ...
          'AK=%.6f; BK=%.6f; CK=%.6f; norm=%.6f\n'], ...
          gamma,a,r,K.a,K.b,K.c,achieved);
  if isinf(gamma)
    assert(abs(a-(sqrt(2)-1)) < 1e-12);
    printf('LQG-limit H2 norm: %.9f\n',norm(N,2));
  end
end

% A general solver is an independent check, not the source of the closed form.
[Ksolver,~,reported]=hinfsyn(P,1,1,'tolgam',1e-8);
Nsolver=lft(P,Ksolver);
assert(max(real(eig(Nsolver.a))) < 0);
solved=norm(Nsolver,Inf,1e-9);
assert(abs(solved-gstar) < 2e-5);
printf('hinfsyn cross-check: reported %.9f, physical-loop norm %.9f\n',reported,solved);

% State-feedback optimum attained at the non-strict boundary: F=-1.
fullstate=ss(-2,[0,1],[1;-1],zeros(2));
assert(abs(norm(fullstate,Inf,1e-10)-1/sqrt(2)) < 1e-9);

% Exercise 10(b): Hurwitz does NOT mean A+A' is negative definite.
An=[-1,10;0,-2]; Q=[2,.3;.3,-1]; alpha=4;
assert(max(eig(An+An')) > 0);
H=lyap(An',eye(2));
X0=lyap(An',Q);
t=max(0,(alpha-min(eig(X0)))/min(eig(H)))+1;
X=X0+t*H;
assert(min(eig(X-alpha*eye(2))) > 0);
assert(max(eig(An'*X+X*An+Q)) < 0);
assert(norm(An'*X+X*An+Q+t*eye(2),2) < 1e-11);

% Exercise 11: a matching lower bound met by an explicit stable f.
g=(s-1)/(s+1); h=2/(s+2); f=-2*(s+1)/(3*(s+2));
E=minreal(h-g*f);
assert(all(real(pole(f)) < 0));
assert(abs(norm(ss(E),Inf,1e-10)-2/3) < 1e-9);
assert((.7^2-4/9)/2 > 0 && (.6^2-4/9)/2 < 0);

% Asymmetric data check the order in Exercise 9's residual channel.
Y0=[2,.4;.4,1.5]; C=diag([1,1.4]); R=C'*C;
Ab=.5*(eye(2)-Y0*R*Y0)/Y0; B=[.7,0;.2,.3];
assert(norm(Ab*Y0+Y0*Ab'+Y0*R*Y0-eye(2),2) < 1e-12);
M=Ab+Y0*R;
assert(min(real(eig(M))) > 0);
assert(norm(M-(Ab+R*Y0),2) > .1);
gmin=norm(ss(-M,B,C,zeros(2)),Inf,1e-10);
gamma=1.3*gmin;
Ham=[Ab',R;eye(2)-B*B'/gamma^2,-Ab];
[V,D]=eig(Ham); W=V(:,real(diag(D))>0);
Yg=real(W(3:4,:)/W(1:2,:));
E=Y0-Yg;
assert(norm(-M*E-E*M'+E*R*E+B*B'/gamma^2,2) < 1e-10);
assert(max(real(eig(-M+E*R))) < 0);
printf('Exercise checks passed, including nonnormal Lyapunov and noncommuting order.\n');

% Figure: the achieved norm approaches gamma* from ABOVE, not from below.
gam=[gstar+1e-4,linspace(.735,1,50),linspace(1.02,2,50)];
ratio=zeros(size(gam)); achieved=ratio;
for j=1:numel(gam)
  [K,~,ratio(j)]=central(gam(j));
  achieved(j)=norm(lft(P,K),Inf,1e-9);
end
set(0,'defaultaxesfontname','DejaVu Sans','defaulttextfontname','DejaVu Sans', ...
      'defaultaxesfontsize',18,'defaulttextfontsize',18);
fh=figure('visible','off','position',[0,0,1050,500]);
subplot(1,2,1); hold on; grid on;
plot(gam,ratio,'linewidth',2,'color',[.12,.31,.47]);
plot([.7,2],[1,1],'--','color',[.5,.5,.5]);
plot(gstar,1,'o','markersize',7,'markerfacecolor',[.06,.46,.43]);
xlabel('Requested bound gamma'); ylabel('rho(XY) / gamma^2');
title('Coupling sets the limit'); xlim([.7,2]); ylim([0,1.08]);
legend('Coupling ratio','Boundary = 1','gamma*','location','northeast');
subplot(1,2,2); hold on; grid on;
plot(gam,achieved,'linewidth',2,'color',[.06,.46,.43]);
plot(gam,gam,'--','color',[.5,.5,.5]);
plot([.7,2],[gstar,gstar],':','linewidth',1.5,'color',[.65,.25,.15]);
xlabel('Requested bound gamma'); ylabel('Achieved H-infinity norm');
title('Requested vs achieved'); xlim([.7,2]); ylim([.7,1.25]);
legend('Central controller','Requested bound','Optimal infimum','location','northwest');
assets=fullfile(fileparts(fileparts(mfilename('fullpath'))),'assets');
print(fh,fullfile(assets,'hinf-example.svg'),'-dsvg'); close(fh);
disp('All Chapter 7 numerical examples passed.');
