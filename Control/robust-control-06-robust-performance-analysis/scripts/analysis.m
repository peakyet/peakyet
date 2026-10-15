% Exact pedagogical examples and independent physical-loop checks.
pkg load control
set(0,'defaultfigurevisible','off');
set(0,'defaultfigurepaperunits','inches','defaultfigurepaperposition',[0 0 7 2.8]);
out='Control/robust-control-06-robust-performance-analysis/assets/';
w=logspace(-2,2,800); s=tf('s');
G=1/(s+1); K=1; V=1.2/(s+1); W=1.2;
S=feedback(1,G*K); T=1-S; delta=-0.9;
physical=V*feedback(1,G*K*(1+W*delta));
cut=V*S/(1+W*T*delta);
assert(max(abs(squeeze(freqresp(physical-cut,w))))<1e-12);
[gain,peak]=norm(physical,inf);
printf('scalar NP %.12g RS %.12g RP %.12g; witness gain %.12g pole %.12g\n', ...
  norm(V*S,inf),norm(W*T,inf),norm(V*S,inf)+norm(W*T,inf),gain,pole(physical)(end));
printf('physical/cut discrepancy %.3g; expected witness pole -0.92\n',max(abs(squeeze(freqresp(physical-cut,w)))));
f=figure(1); clf;
semilogx(w,abs(squeeze(freqresp(V*S,w))),'b','linewidth',2); hold on;
semilogx(w,abs(squeeze(freqresp(W*T,w))),'r--','linewidth',2);
semilogx(w,abs(squeeze(freqresp(V*S,w)))+abs(squeeze(freqresp(W*T,w))),'k','linewidth',2);
semilogx(w,abs(squeeze(freqresp(physical,w))),'color',[0 .55 .35],'linewidth',2);
line([w(1) w(end)],[1 1],'color',[.5 .5 .5],'linestyle',':');
grid on; xlabel('frequency [rad/s]'); ylabel('gain');
legend('nominal |VS|','stability |WT|','exact extended mu','actual Delta=-0.9','target 1','location','northeast');
title('Stability and nominal performance pass; robust performance fails');
print(f,[out 'three-tests.png'],'-dpng','-r160');
N=[.2 4;.08 .3]; mu=max(eig(N)); ratio=sqrt(4/.08);
D=diag([ratio 1]); ub=norm(D\N*D);
printf('asymmetric N: norm %.12g, optimal ratio %.12g, mu=scaled norm %.12g; witness residual %.3g\n',norm(N),ratio,ub,min(svd(eye(2)-N/mu)));
assert(abs(mu-ub)<1e-12);
q=logspace(-1,2,500); vals=arrayfun(@(r) norm(diag([1/r 1])*N*diag([r 1])),q);
f=figure(2); clf;
loglog(q,vals,'b','linewidth',2); hold on;
line([q(1) q(end)],[mu mu],'color',[0 .5 .3],'linestyle','--');
line([q(1) q(end)],[1 1],'color',[.5 .5 .5],'linestyle',':');
plot(ratio,ub,'ro','markersize',7,'linewidth',2);
grid on; xlabel('ratio d_1 / d_2'); ylabel('upper bound ||D^{-1} N D||_2');
legend('scaled upper bound','exact mu','target 1','optimum','location','northwest');
title('An upper bound above one is not a failure witness');
print(f,[out 'asymmetric-scaling.png'],'-dpng','-r160');
