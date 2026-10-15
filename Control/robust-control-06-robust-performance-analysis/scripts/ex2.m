% Robust-control note, chapter 6: full Exercise 2 — parts (a)–(e).
% Produces every number and every figure quoted in the note. Run from the repo root:
%   octave --no-gui --quiet Control/robust-control-06-robust-performance-analysis/scripts/ex2.m
% Figures are written to .../robust-control-06-robust-performance-analysis/assets/.
pkg load control
format short g
s = tf('s');
here = 'Control/robust-control-06-robust-performance-analysis/assets/';
if exist(here, 'dir') != 7, mkdir(here); end
set(0, 'defaultfigurevisible', 'off');
set(0, 'defaultfigurepaperunits','inches','defaultfigurepaperposition',[0 0 7 2.8]);

% ---------------- plant ----------------
GH  = ss(200/((10*s+1)*(0.05*s+1)^2)); GH  = minreal(GH, 1e-9);
G05 = ss(100/(10*s+1));                G05 = minreal(G05, 1e-9);

% ---------------- (a) the uncertainty weight W ----------------
w1 = 30/sqrt(99);        % |W(30i)| = 1/1.0009 (proper regularization)
Wf = @(z) 0.01*(1+z/w1).^2./(1+z/1000).^2;
printf('W: zero at w1 = %.4f rad/s; |W| at w = 0.01, 0.1, 1, 10, 30, 100, 1000:\n', w1);
for ww = [0.01 0.1 1 10 30 100 1000]
  printf('   w=%8.4g  |W| = %.5f\n', ww, abs(Wf(1i*ww)));
end
printf('slope 30->300 rad/s: %.2f dB/decade\n', 20*log10(abs(Wf(300i))/abs(Wf(30i))));
wspec = [0.01 10 30 100];
printf('spec-point check |W(jw)| at w = 0.01, 10, 30, 100: %s\n', ...
       mat2str(arrayfun(@(x) abs(Wf(1i*x)), wspec), 4));

% ---------------- (b) static gains K in [1,3] ----------------
dG  = conv([0.05 1],[0.05 1]);
dGH = conv(dG,[10 1]);                    % 0.025 s^3 + 1.0025 s^2 + 10.1 s + 1
printf('\nloop denominator dGH = %s\n', mat2str(dGH, 6));
printf('K      max Re(eig of closed loop)\n');
for K = [1 1.5 2 2.02 2.05 2.5 3]
  chi = dGH; chi(end) = chi(end)+200*K;
  printf('%.3f   %+.4f\n', K, max(real(roots(chi))));
end
wp = logspace(-3,3.5,8000);
wK = logspace(-3,4,200001);               % fine grid for the part-(b) peaks
for K = [1 1.5 2]
  Lc = 200*K ./ polyval(dGH, 1i*wK);         % complex loop response
  Sm = abs(1./(1+Lc)); Tm = abs(Lc./(1+Lc)); % |S|, |T| (must use complex L)
  Wm = abs(Wf(1i*wK));
  [sw,iw] = max(Wm.*Tm);
  i707 = find(Sm >= 1/sqrt(2), 1);           % |S| first reaches 1/sqrt(2)
  bw = 0; if ~isempty(i707), bw = wK(i707); end
  printf('K=%.1f: |WT|inf=%.4g @w=%.4g, margin=%.4g, |S|inf=%.4g, bw=%.4g rad/s\n', ...
         K, sw, wK(iw), 1/sw, max(Sm), bw);
end

% ---------------- shared machinery ----------------
a_r = 3e5; b_r = 8; c_r = 0.001;          % r->e weight: DC 3e5, corner 8, roll 0.001
a_d = 8000; b_d = 3; c_d = 0.1;           % d->e weight: DC 8e3, corner 3, roll 0.1
rho = 1e-4;                               % control penalty
Wr = ss(a_r*(s/b_r+1)/(s/c_r+1)); Wr = minreal(Wr,1e-9);
Wd = ss(a_d*(s/b_d+1)/(s/c_d+1)); Wd = minreal(Wd,1e-9);
[agh,bgh,cgh,dgh] = ssdata(GH);
[a05,b05,c05,d05] = ssdata(G05);
[ar,brg,crg,drg]  = ssdata(Wr);
[ad_,bd,cd,dd]    = ssdata(Wd);
Wss = ss(0.01*(1+s/w1)^2/(1+s/1000)^2); Wss = minreal(Wss,1e-9);   % part-(a) weight

function o = stabword(tfm)
  if tfm, o = 'STABLE'; else, o = 'UNSTABLE'; end
end
function report(Kcl, tag, GHp, G05p)
  Lss = Kcl*GHp;
  Sc  = prescale(feedback(eye(1), Lss));
  Tss = prescale(feedback(Lss,eye(1)));
  wq  = [0 logspace(-3,3.5,4000)];
  ms  = squeeze(abs(freqresp(Sc, wq)));
  md  = squeeze(abs(freqresp(G05p, wq))) .* ms;
  i707 = find(ms >= 1/sqrt(2), 1);
  bw = 0; if ~isempty(i707), bw = wq(min(i707,numel(wq))); end
  [es,~] = step(Tss, linspace(0,200,100001));
  printf('%s: |S(0)|=%.3g  bw=%.4g rad/s  sup|S|=%.3g  max|G05*S| (w<=0.1)=%.3g  overshoot=%.2f%%\n', ...
    tag, ms(1), bw, max(ms), max(md(wq<=0.1)), (max(es)-1)*100);
  % Physical state equations, no cancellation of controller or plant states.
  [ap,bp,cp,dp]=ssdata(GHp); [ak,bk,ck,dk]=ssdata(Kcl);
  assert(norm(dp)==0);
  acl=[ap-bp*dk*cp bp*ck;-bk*cp ak];
  printf('  full nominal modes %d, max Re = %.9g; norm(WT) checked separately\n',rows(acl),max(real(eig(acl))));
  assert(max(real(eig(acl)))<0);
  [err,tt]=step(Sc,linspace(0,200,100001));
  printf('  error step min %.9g max %.9g at t=200 %.9g (e=1-y)\n',min(err),max(err),err(end));
  % Independent complex algebra: no state-space closed-loop inversion.
  kf=squeeze(freqresp(Kcl,wq)); pf=squeeze(freqresp(GHp,wq));
  sf=1./(1+pf.*kf);
  [residual,ir]=max(abs(sf-squeeze(freqresp(Sc,wq))));
  printf('  physical algebra / state-space sensitivity discrepancy %.3g at w=%.9g\n',residual,wq(ir));
  printf('  independent algebra S(0)=%.12g\n',sf(1));
  % The synthesized controller has poorly conditioned near-cancelling slow modes.
  % Check an absolute 1e-5 envelope (not machine-precision equivalence).
  assert(residual<1e-5);
end

% ---- (c) nominal design: inputs (rh, dh, u), outputs (z1 = e, z2 = rho*u, y = e) ----
nG=rows(agh); n5=rows(a05); nr=rows(ar); nd=rows(ad_); N=nG+n5+nr+nd;
A=zeros(N,N);
A(1:nG,1:nG)=agh; A(nG+1:nG+n5,nG+1:nG+n5)=a05;
A(nG+n5+1:nG+n5+nr,nG+n5+1:nG+n5+nr)=ar;
A(nG+n5+nr+1:N,nG+n5+nr+1:N)=ad_;
A(nG+1:nG+n5,nG+n5+nr+1:N)=b05*cd;        % disturbance enters via Wd output
B=zeros(N,3);
B(1:nG,3)=bgh; B(nG+1:nG+n5,2)=b05*dd;
B(nG+n5+1:nG+n5+nr,1)=brg; B(nG+n5+nr+1:N,2)=bd;
C=zeros(3,N); eC=zeros(1,N);
eC(1:nG)=-cgh; eC(nG+1:nG+n5)=-c05; eC(nG+n5+1:nG+n5+nr)=crg;
C(1,:)=eC; C(3,:)=eC;
D=[drg 0 0; 0 0 rho; drg 0 0];
P = ss(A,B,C,D);
[Kc,~,gamc] = hinfsyn(P,1,1);
Kc=prescale(Kc);                         % similarity only; retain every mode
printf('\n(c): gamma = %.4g, controller order %d\n', gamc, rows(Kc.a));
report(Kc, '(c)', GH, G05);

% ---- (d) stability margin of the (c) design ----
Lc  = Kc*GH;
Tcc = prescale(feedback(Lc,eye(1)));
[wmag,w0] = norm(ss(Wss*Tcc),inf,1e-7);
gstar = 1/wmag;
printf('(d): |WT|inf = %.4g at w = %.4g  ==>  gamma* = %.4g\n', wmag, w0, gstar);
% destabiliser Delta(s) = c*(alpha-s)/(alpha+s): |Delta(iw)| = c, arg = -2 atan(w/alpha)
theta = angle(freqresp(Wss*Tcc, w0));
dneed = mod(-pi - theta, 2*pi);           % wanted arg of Delta(iw0)
if dneed > pi, dneed = dneed - 2*pi; end  % now in (-pi, pi]
dsign=1;
if dneed > 0, dneed = dneed - pi; dsign=-1; end
alp = w0 / tan(-dneed/2);
for c1 = [1 1.2 1.5 2.0]*gstar
  Dd = minreal(dsign*c1*(alp-s)/(alp+s), 1e-9);
  Lp  = Lc*(eye(1)+Wss*Dd);               % K*G*(1+W*Delta)*H
  Lpt = minreal(Lp, 1e-9);
  [nL,dL] = tfdata(Lpt, 'v');
  p = roots(dL + nL);                     % 1 + L = 0
  status='BOUNDARY CANDIDATE (floating-point roots)';
  if c1>gstar, status=stabword(max(real(p))<0); end
  printf('  c=%.4g: alpha=%.4g, |Delta|=%.4g, max Re pole of 1+K*G*(1+W*D) = %+.4g -> %s\n', ...
    c1, alp, c1, max(real(p)), status);
  % Retain the actual shared plant: u+Delta*W*u drives one GH realization.
  Pphys=ss(GH)*(ss(1)+ss(Dd)*Wss);
  [ap,bp,cp,dp]=ssdata(Pphys); [ak,bk,ck,dk]=ssdata(Kc);
  assert(norm(dp)==0);
  acl=[ap-bp*dk*cp bp*ck;-bk*cp ak];
  printf('    full physical loop: %d modes, max Re %.9g\n',rows(acl),max(real(eig(acl))));
  if c1 == gstar
    residual=abs(1+freqresp(Wss*Tcc*Dd,w0));
    printf('    boundary return-difference residual %.3g\n',residual);
    assert(residual<1e-10);
    assert(min(abs(eig(acl)-1i*w0))<1e-4);
  else
    assert(max(real(eig(acl)))>0);
  end
end

% ---- (e) robust design: adds the uncertainty channel ----
nw=rows(Wss.a); Ne=nG+n5+nr+nd+nw;
Ae=zeros(Ne,Ne);
Ae(1:nG,1:nG)=agh; Ae(nG+1:nG+n5,nG+1:nG+n5)=a05;
Ae(nG+n5+1:nG+n5+nr,nG+n5+1:nG+n5+nr)=ar;
Ae(nG+n5+nr+1:nG+n5+nr+nd,nG+n5+nr+1:nG+n5+nr+nd)=ad_;
Ae(Ne-nw+1:Ne,Ne-nw+1:Ne)=Wss.a;
Ae(nG+1:nG+n5,nG+n5+nr+1:nG+n5+nr+nd)=b05*cd;
Be=zeros(Ne,4);
Be(1:nG,3)=bgh; Be(1:nG,4)=bgh;           % wD and u both enter the plant input
Be(nG+1:nG+n5,2)=b05*dd;
Be(nG+n5+1:nG+n5+nr,1)=brg; Be(nG+n5+nr+1:nG+n5+nr+nd,2)=bd;
Be(Ne-nw+1:Ne,4)=Wss.b;                   % u drives the W block (zD = W u)
Ce=zeros(4,Ne); eC=zeros(1,Ne);
eC(1:nG)=-cgh; eC(nG+1:nG+n5)=-c05; eC(nG+n5+1:nG+n5+nr)=crg;
Ce(1,:)=eC; Ce(4,:)=eC;
Ce(2,Ne-nw+1:Ne)=Wss.c;
De=zeros(4,4);
De(2,4)=Wss.d;                            % zD = W u direct term
De(3,4)=rho;                              % same control penalty as part (c)
De(1,1)=drg; De(4,1)=drg;
Pe = ss(Ae,Be,Ce,De);
[Ke,~,game] = hinfsyn(Pe,1,1);
Ke=prescale(Ke);
printf('(e): gamma = %.4g, controller order %d\n', game, rows(Ke.a));
report(Ke, '(e)', GH, G05);
Le  = Ke*GH;
Tee = prescale(feedback(Le,eye(1)));
WmTe = squeeze(abs(freqresp(Wss*Tee, wp)));
[wmage,imde] = max(WmTe);
printf('(e): |WT|inf = %.4g at w = %.4g  ==>  gamma* = %.4g\n', wmage, wp(imde), 1/wmage);
% Continuous-frequency H-infinity algorithm, not the plotting grid.
[nc,wc]=norm(ss(Wss*Tcc),inf,1e-7);
[ne,we]=norm(ss(Wss*Tee),inf,1e-7);
printf('continuous norm: (c) %.10g @ %.10g, margin %.10g; (e) %.10g @ %.10g, margin %.10g\n',nc,wc,1/nc,ne,we,1/ne);
printf('Routh exact Kcrit = %.12g\n',(dGH(2)*dGH(3)/dGH(1)-1)/200);

% ---------------- figures ----------------
% Fig 1: the weight with evaluated sample points (not independent specifications).
f = figure(1); clf;
semilogx(wp(2:end), 20*log10(abs(Wf(1i*wp(2:end)))), 'b', 'linewidth', 1.4); hold on;
semilogx(wspec, 20*log10(arrayfun(@(x) abs(Wf(1i*x)), wspec)), 'ro', 'markersize', 7);
grid on; xlabel('\omega [rad/s]'); ylabel('|W(j\omega)| [dB]');
legend('|W|', 'sample points', 'location', 'northwest');
title('Uncertainty weight W(s), Exercise 2(a)');
print(f, [here 'ex2-W.png'], '-dpng', '-r120');

% Fig 2: nominal design (c): |S|, |T|, disturbance channel
Sc2 = prescale(feedback(eye(1), Lc));
msc = squeeze(abs(freqresp(Sc2, wp)));
mtc = squeeze(abs(freqresp(Tcc, wp)));
mdc = squeeze(abs(freqresp(G05, wp))) .* msc;
f = figure(2); clf;
loglog(wp(2:end), msc(2:end), 'b', wp(2:end), mtc(2:end), 'r', ...
       wp(2:end), mdc(2:end), 'g', 'linewidth', 1.3); hold on;
line([1e-3 0.1], [0.01 0.01], 'color', 'k', 'linestyle', '--');
line([0.1 0.1], [1e-4 1], 'color', 'k', 'linestyle', ':');
grid on; xlabel('\omega [rad/s]'); ylabel('magnitude');
legend('|S|', '|T|', '|D_0 S|', 'target 0.01', 'location', 'southeast');
title(sprintf('Nominal H_inf design (c), gamma = %.4g', gamc));
print(f, [here 'ex2-c.png'], '-dpng', '-r120');

% Fig 3: robust design (e), same curves
Sc3 = prescale(feedback(eye(1), Le));
mse = squeeze(abs(freqresp(Sc3, wp)));
mte = squeeze(abs(freqresp(Tee, wp)));
mde = squeeze(abs(freqresp(G05, wp))) .* mse;
f = figure(3); clf;
loglog(wp(2:end), mse(2:end), 'b', wp(2:end), mte(2:end), 'r', ...
       wp(2:end), mde(2:end), 'g', 'linewidth', 1.3); hold on;
loglog(wp, WmTe, 'm', 'linewidth', 1.3);
line([1e-3 0.1], [0.01 0.01], 'color', 'k', 'linestyle', '--');
grid on; xlabel('\omega [rad/s]'); ylabel('magnitude');
legend('|S|', '|T|', '|D_0 S|', '|WT|', 'target 0.01', 'location', 'southeast');
title(sprintf('Augmented H_inf design (e), gamma = %.4g', game));
print(f, [here 'ex2-e.png'], '-dpng', '-r120');
printf('\nfigures written to %s\n', here);

% ================= functions =================
