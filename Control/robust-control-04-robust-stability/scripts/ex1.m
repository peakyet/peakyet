% ex1.m -- Exercise 1 of Scherer, Theory of Robust Control, Chapter 4 (pp. 133-134).
%
% The Figure-23 interconnection of Chapter 3, Exercise 3c, closed by the given
% 6-state 1x2 controller K = [K1 K2] (a = u1 + u2 = K*(y1;y2)).
%   main : G1 -> G1 + W1*Delta,  W1 = (s-2)/(s+2),  Delta real or in RH_inf
%   (a)  : pole of G2 = 1/(s-p) uncertain, p real (and complex)
%   (b)  : both uncertainties together -> trade-off curve r2(r1)
%
% Run from the repository root:
%   octave --no-gui Control/robust-control-04-robust-stability/scripts/ex1.m
%
% Every number quoted in the note is printed here.  GNU Octave 11.3 with the
% control package; no Robust Control Toolbox is used (sysic/mu are replaced by
% explicit state-space builds).
pkg load control
format long g
s = tf('s');
here = fileparts(mfilename('fullpath'));

% ---- Figure-23 components (Chapter 3, Exercise 3c) ------------------------
G2 = 1/(s-1); G3 = (s+1)/(s^2+1); G5 = 1/s; G7 = (s+2)/((s+3)*(s-2));
[A2,B2c,C2c,~] = ssdata(ss(G2));
[A3,B3c,C3c,~] = ssdata(ss(G3));
[A5,B5c,C5c,~] = ssdata(ss(G5));
[A7,B7c,C7c,~] = ssdata(ss(G7));
n7=rows(A7); n2=rows(A2); n3=rows(A3); n5=rows(A5); nw=1;
Z = @(r,c) zeros(r,c);
Aw=-2; Cw=-4; Dw=1;                       % W1 = (s-2)/(s+2) = Dw + Cw*(sI-Aw)^-1

% state (x7,x2,x3,x5,xw); extra input wD1 of G1, wD2 of the G2 pole.
A = [A7,Z(n7,n2),Z(n7,n3),Z(n7,n5),Z(n7,nw);
     -B2c*C7c,A2,Z(n2,n3),Z(n2,n5),B2c*Cw;
     -B3c*C7c,Z(n3,n2),A3,Z(n3,n5),B3c*Cw;
     Z(n5,n7),Z(n5,n2),Z(n5,n3),A5,Z(n5,nw);
     Z(nw,n7),Z(nw,n2),Z(nw,n3),Z(nw,n5),Aw];
% inputs: wD1, wD2, w, a
B = [ [Z(n7,1);B2c*Dw;B3c*Dw;Z(n5,1);1], ...   % wD1: q += W1 wD1 (Dw part + xw)
      [Z(n7,1);B2c;Z(n3,1);Z(n5,1);0], ...      % wD2: pole perturbation of G2
      [Z(n7,1);B2c;B3c;Z(n5,1);0], ...          % w:  q = w - z
      [B7c;Z(n2,1);Z(n3,1);B5c;0] ];            % a:  control input
Cz1=[-C7c,Z(1,n2),Z(1,n3),Z(1,n5),0];           % zD1 = e = w - z
Cz2=[Z(1,n7),C2c,Z(1,n3),Z(1,n5),0];            % zD2 = x2
Cy =[Z(1,n7),C2c,Z(1,n3),-C5c,0; Z(1,n7),Z(1,n2),C3c,-C5c,0];
n = rows(A);

% ---- given controller (Chapter 4, Exercise 1) ------------------------------
AK=[-4.69 -1.28 -1.02 7.29 -0.937 -0.736;
    -2.42 -3.29 -3.42 6.53 -1.17 -0.922;
    -1.48 0.418 -0.666 2.52 0 0;
    19 -0.491 1.34 -0.391 -6.16 -5.59;
    24.8 2.35 3.73 -8.48 -7.58 -3.61;
    4.38 4.02 3.2 -9.41 2.54 0];
BK=[5.69 1.6;2.42 4.12;1.48 1.05;0.943 -0.334;-3.45 -3.96;-4.38 -5.03];
CK=[20 -0.757 1.13 -1 -6.16 -5.59]; DK=zeros(1,2);
nk=rows(AK); Ba=B(:,4);

% closed loop N = P * K (inputs wD1,wD2,w; outputs zD1,zD2,z)
Acl=[A+Ba*DK*Cy, Ba*CK; BK*Cy, AK];
Bcl=[B(:,1:2); zeros(nk,2)];
Ccl=[Cz1, zeros(1,nk); Cz2, zeros(1,nk)];
Dcl=zeros(2); % both outputs are states; no direct pole-error -> e path
printf('nominal closed loop: max real part of eigenvalues = %.6f\n', ...
       max(real(eig(Acl))));

Meval = @(sk) Ccl/(sk*eye(rows(Acl))-Acl)*Bcl + Dcl;   % 2x2, (wD1,wD2)->(zD1,zD2)

% close a dynamic/static uncertainty Delta on channels (wD2->zD2 resp. wD1->zD1)
% N is zD=[c1;c2]x + D wD + ... ; wD_i = Delta_i zD_i.
function ev = close_delta(Acl,Bcl,Ccl,Dcl, i, Ad,Bd,Cd,Dd)
  b = Bcl(:,i); C = Ccl(i,:);
  if isempty(Ad)          % static Delta = Dd
    ev = eig(Acl + b*(Dd*C));
  else
    ev = eig([Acl + b*Dd*C, b*Cd; Bd*C, Ad]);
  end
end

% ==========================================================================
% MAIN PART: G1 -> G1 + W1*Delta
% ==========================================================================
M = @(sk) Meval(sk)(1,1);
w = logspace(-4,5,400000);
Mv = arrayfun(@(wi) M(1i*wi), w);
[pk,ip]=max(abs(Mv));
g = @(lw) -abs(M(1i*10^lw));
[lwopt,fv]=fminbnd(g, log10(w(max(ip-200,1))), log10(w(min(ip+200,numel(w)))), ...
                   optimset('TolX',1e-13));
infM = -fv; w0 = 10^lwopt;
r_dyn = 1/infM;
printf('\nMAIN (additive uncertainty at G1):\n');
printf('  ||M||inf = %.8f at omega = %.8f rad/s\n', infM, w0);
printf('  dynamic margin  r = 1/||M||inf = %.8f\n', r_dyn);
% real Delta: destabilising reals are 1/M(iw) with M(iw) real
imM=imag(Mv); idx=find(imM(1:end-1).*imM(2:end)<=0); cand=[];
for k=idx(:)'
  w1=w(k); w2=w(k+1); f1=imM(k); f2=imM(k+1);
  wt=w1; if f2~=f1, wt=w1+(w2-w1)*(-f1)/(f2-f1); end
  Mt=M(1i*wt); cand=[cand; wt, real(Mt), abs(1/Mt)];
end
[mn,ik]=min(cand(:,3)); r_real=mn; wr=cand(ik,1); Mr=cand(ik,2);
printf('  real margin     r = %.8f (Delta* = %.8f at omega = %.8f)\n', ...
       r_real, 1/Mr, wr);
% destabilising perturbations of smallest size, and their verification
D0 = 1/M(1i*w0);                          % dynamic critical value
rho=abs(D0); th=angle(D0);
beta = w0*tan(th/2); sgn=1;              % Delta(s)= sgn*rho*(s-beta)/(s+beta)
if beta<=0, th2=th-pi; beta=w0*tan(th2/2); sgn=-1; end
Ad=-beta; Bd=1; Cd=-2*beta*sgn*rho; Dd=sgn*rho;   % sgn*rho*(s-beta)/(s+beta)
ev = close_delta(Acl,Bcl,Ccl,Dcl,1,Ad,Bd,Cd,Dd);
[~,ie]=min(abs(real(ev)));
printf('  dynamic destabiliser: Delta(s)=%+.4f*(s-%.4f)/(s+%.4f)\n', sgn*rho,beta,beta);
printf('    ||Delta||inf = %.8f ; closed-loop eigenvalue nearest axis = %.6f%+.6fi\n', ...
       rho, real(ev(ie)), imag(ev(ie)));
evr = close_delta(Acl,Bcl,Ccl,Dcl,1,[],[],[],1/Mr);
[~,ie2]=min(abs(real(evr)));
printf('  real destabiliser: Delta = %.6f ; nearest-axis closed-loop eigenvalue = %.6f%+.6fi\n', ...
       1/Mr, real(evr(ie2)), imag(evr(ie2)));

% ==========================================================================
% PART (a): pole of G2 = 1/(s-p) uncertain
% ==========================================================================
Ma = @(sk) Meval(sk)(2,2);
Mav = arrayfun(@(wi) Ma(1i*wi), w);
[pka,ipa]=max(abs(Mav));
ga=@(lw) -abs(Ma(1i*10^lw));
[lwa,fva]=fminbnd(ga, log10(w(max(ipa-200,1))), log10(w(min(ipa+200,numel(w)))), ...
                  optimset('TolX',1e-13));
infMa=-fva; wa=10^lwa;
r_complex = 1/infMa;
imMa=imag(Mav); idxa=find(imMa(1:end-1).*imMa(2:end)<=0); canda=[];
for k=idxa(:)'
  w1=w(k); w2=w(k+1); f1=imMa(k); f2=imMa(k+1);
  wt=w1; if f2~=f1, wt=w1+(w2-w1)*(-f1)/(f2-f1); end
  Mt=Ma(1i*wt); canda=[canda; wt, real(Mt), abs(1/Mt)];
end
[mna,ika]=min(canda(:,3)); r_real_a=mna; wra=canda(ika,1);
printf('\nPART (a) (pole of G2 uncertain):\n');
printf('  ||M22||inf = %.8f ; complex-pole margin r = %.8f\n', infMa, r_complex);
printf('  real-pole margin r = %.8f (p = 1 + Delta = %.8f at omega = %.8f)\n', ...
       r_real_a, 1+1/canda(ika,2), wra);
% verification: closed loop with p = 1 + Delta, Delta = 1/M22(iw) real
p_a = 1 + 1/canda(ika,2);
printf('  real pole p = %.8f -> ', p_a);
G2p = 1/(s-p_a); [A2p,B2p,C2p,~]=ssdata(ss(G2p));
Ap=[A7,Z(n7,n2),Z(n7,n3),Z(n7,n5);-B2p*C7c,A2p,Z(n2,n3),Z(n2,n5);
    -B3c*C7c,Z(n3,n2),A3,Z(n3,n5);Z(n5,n7),Z(n5,n2),Z(n5,n3),A5];
Bap=[B7c;Z(n2,1);Z(n3,1);B5c];
Cyp=[Z(1,n7),C2p,Z(1,n3),-C5c; Z(1,n7),Z(1,n2),C3c,-C5c];
evp=eig([Ap,Bap*CK;BK*Cyp,AK]); [mxl,il]=max(real(evp));
printf('max real part = %.8f (imag %.6f)\n', mxl, imag(evp(il)));

% ==========================================================================
% PART (b): both uncertainties; trade-off r2(r1)  (r1 for G1, r2 for G2 pole)
% ==========================================================================
printf('\nPART (b) (both uncertainties):\n');
w2g = [0 logspace(-3,3,20000) wra wr w0];
% No joint stable family extends beyond the pure real-pole margin. Include
% its crossing frequency explicitly so the plotted endpoint cannot miss it.
e2 = linspace(-r_real_a,r_real_a,30001); ae=abs(e2); [asrt,ixs]=sort(ae);
Gcurve = 1e9*ones(size(ae));
for k=1:numel(w2g)
  Mk = Meval(1i*w2g(k));
  num = 1 - Mk(2,2)*e2;
  den = Mk(1,1)*(1-Mk(2,2)*e2) + Mk(1,2)*Mk(2,1)*e2;
  gg = abs(num./den);
  cm = cummin(gg(ixs));
  Gcurve = min(Gcurve, cm);
end
% Gcurve(j) = largest r1 for r2 = asrt(j)
r2g = asrt(:); r1g = Gcurve(:);
% diagonal crossing r1=r2
dd = r1g - r2g; jc=find(dd(1:end-1).*dd(2:end)<=0,1);
if ~isempty(jc)
  printf('  largest equal margins r1 = r2 = %.6f\n', (r2g(jc)+r1g(jc))/2);
end
printf('  trade-off (r1, r2):\n');
for rr=[0.02 0.05 0.08 0.10 0.13]
  [~,j]=min(abs(r1g-rr)); printf('    r1=%.3f  r2max=%.5f\n', rr, r2g(j));
end
% figure: Bode magnitude of |M| (main) and the trade-off curve
outdir = fullfile(here,'..','assets'); if ~exist(outdir,'dir'), mkdir(outdir); end
graphics_toolkit('qt');
sel=find(w>=.01 & w<=100); sel=sel(1:100:end);
wp = w(sel); Mp = Mv(sel); % concentrate the plot on the relevant dynamics
jp = round(linspace(1,numel(r1g),1500));
fig=figure('visible','off','position',[0 0 760 340]);
subplot(1,2,1);
semilogx(wp,20*log10(abs(Mp)),'color',[0.122 0.306 0.475],'linewidth',2); grid on;
xlabel('frequency (rad/s)'); ylabel('|M| (dB)'); title('transfer seen by \Delta');
set(gca,'fontsize',10);
subplot(1,2,2);
plot(r1g(jp), r2g(jp),'color',[0.122 0.306 0.475],'linewidth',2); grid on;
xlabel('r_1  (G_1 weight)'); ylabel('r_2 max  (pole weight)');
title('trade-off curve'); xlim([0 0.14]); ylim([0 0.45]); set(gca,'fontsize',10);
print(fig, fullfile(outdir,'ex1.svg'), '-dsvg'); close(fig);
printf('  wrote %s\n', fullfile(outdir,'ex1.svg'));

% Independent signal elimination, not a second copy of the state assembly.
err=0;
for wi=[0.13 0.7 1.4 3.1 12]
  sk=1i*wi; kv=CK/(sk*eye(nk)-AK)*BK;
  g2=1/(sk-1); g3=(sk+1)/(sk^2+1); g5=1/sk;
  g7=(sk+2)/((sk+3)*(sk-2)); ww=(sk-2)/(sk+2);
  h=(kv(1)*g2+kv(2)*g3)/(1+sum(kv)*g5);
  j=kv(1)*g2/(1+sum(kv)*g5);
  mi=[-g7*h*ww/(1+g7*h),-g7*j/(1+g7*h);
      g2*ww/(1+g7*h),g2*(1-g7*j/(1+g7*h))];
  err=max(err,norm(Meval(sk)-mi));
end
printf('independent signal-elimination frequency residual = %.3e\n',err);

% Refine the mixed equal-radius boundary, then close BOTH actual blocks.
function d1=critical_d1(Mk,d2)
  d1=(1-Mk(2,2)*d2)/(Mk(1,1)*(1-Mk(2,2)*d2)+Mk(1,2)*Mk(2,1)*d2);
end
obj=@(x) max(abs([critical_d1(Meval(1i*exp(x(1))),x(2)),x(2)]));
best=inf;
for seedw=[0.25 0.7 1.2 1.6 2 4]
 for seedd=[-0.11 0.11]
  [xx,v]=fminsearch(obj,[log(seedw),seedd],optimset('TolX',1e-12,'TolFun',1e-12,'MaxFunEvals',3000));
  if v<best, best=v; xb=xx; end
 end
end
wb=exp(xb(1)); d2=xb(2); d1=critical_d1(Meval(1i*wb),d2);
th=angle(d1); beta=wb*tan(th/2); sg=1;
if beta<=0, beta=wb*tan((th-pi)/2); sg=-1; end
rho=abs(d1); Ad=-beta; Cd=-2*beta*sg*rho; Dd=sg*rho;
Ab=Acl+Bcl(:,2)*d2*Ccl(2,:);
evb=eig([Ab+Bcl(:,1)*Dd*Ccl(1,:),Bcl(:,1)*Cd;Ccl(1,:),Ad]);
printf('refined mixed radius = %.10f, omega = %.10f, d2 = %.10f\n',best,wb,d2);
printf('mixed all-pass = %+.10f*(s-%.10f)/(s+%.10f)\n',sg*rho,beta,beta);
printf('mixed FULL poles (no minreal):\n'); disp(evb.');
printf('mixed witness determinant residual %.3e; max real pole %.3e\n', ...
 abs(det(eye(2)-Meval(1i*wb)*diag([d1,d2]))),max(real(evb)));
