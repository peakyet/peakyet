% Reproduce the note's visual and numerical checks; no synthesis or installation.
pkg load control;
here = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; endif
out = fullfile(here, 'assets');
if ~exist(out, 'dir'), mkdir(out); endif
s = tf('s');
S = (s+1)/(s+10); T = 9/(s+10); CS = 9*S;
WS = 2/(s+0.2); WT = (s+1)/(2*(s+10)); WU = 0.1;
w = logspace(-3, 4, 2000);
mag = @(H) reshape(abs(freqresp(H,w)),1,[]);
a = mag(WS*S); b = mag(WT*T); c = mag(WU*CS);
joint = sqrt(a.^2+b.^2+c.^2);
% Exact rational squared norm in x=omega^2:
% 4(x+1)/((x+.04)(x+100)) + 20.25(x+1)/(x+100)^2
% + .81(x+1)/(x+100).
% Combine over D=(x+.04)(x+100)^2, all descending coefficients.
D = conv([1,.04],conv([1,100],[1,100]));
N = 4*conv([1,1],[1,100]) + 20.25*conv([1,1],[1,.04]);
N = [0,N] + .81*conv(conv([1,1],[1,.04]),[1,100]);
% Prove H(x)<=H(0) on x>=0 by nonnegative coefficients of H(0)D-N.
gap = 1.010125*D-N;
assert(all(gap(1:3)>0) && abs(gap(4))<1e-10);
exact = sqrt(1+.045^2+.09^2);
assert(max(joint)<exact && exact>1);
assert(max(a)<=1 && max(b)<1 && max(c)<.9);
F = [0,1;1,0]; Wz = diag([2,1]); Ww = diag([1,.5]);
assert(norm(Wz*F*Ww)==1 && norm(Wz*Ww*F)==2);
v = [1;1i]/sqrt(2);
assert(abs(norm([1,-1i]*v)-sqrt(2))<1e-12);
assert(abs(norm([.6,.6])-sqrt(.72))<1e-12);
assert(abs(norm([.8;.8])-sqrt(1.28))<1e-12);
mm = 1/(s+1)-2/(s+2);
assert(abs(abs(freqresp(mm,sqrt(2)))-1/3)<1e-12);
assert(abs(20*.2*.1-.4)<1e-12);
fprintf('Mixed stack exact norm %.9f; grid %.9f; effort limit .9\n',exact,max(joint));
fprintf('Squared-gain gap polynomial coefficients: '); disp(gap);
fprintf('Budget gains %.9f and %.9f; matching peak %.9f at sqrt(2)\n',sqrt(.72),sqrt(1.28),1/3);
fprintf('All algebraic checks passed.\n');
set(0,'defaultfigurevisible','off');
fig = figure('position',[100,100,1100,420]);
subplot(1,2,1);
loglog(w,mag(S),'linewidth',2,w,1./mag(WS),'--','linewidth',2);
grid on; xlabel('Frequency (rad/s)'); ylabel('Physical gain');
title('Sensitivity and allowed envelope');
legend('|S|','1/|W_S|','location','northwest'); ylim([.05,1e4]);
subplot(1,2,2);
semilogx(w,a,w,b,w,c,w,joint,'linewidth',2); hold on;
semilogx(w,ones(size(w)),'k--','linewidth',1);
grid on; xlabel('Frequency (rad/s)'); ylabel('Normalized gain');
title('Separate channels versus joint output budget');
legend('|W_S S|','|W_T T|','|W_u CS|','stack','unit bound','location','east');
ylim([0,1.12]);
% The violation is only 0.5%; label the analytically checked DC limit explicitly.
plot(w(1),joint(1),'o','color',[.4 .1 .6],'handlevisibility','off');
text(.004,1.065,sprintf('DC stack %.5f > 1',exact), ...
     'color',[.4 .1 .6],'fontsize',10,'fontweight','bold','handlevisibility','off');
print(fig,fullfile(out,'budgets.png'),'-dpng','-r160');
close(fig);
