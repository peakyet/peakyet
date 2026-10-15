% Reproduces the numbers of Exercises 4-5 (Scherer, Theory of Robust Control, Ch. 2).
% Run from the repository root:  octave -q Control/robust-control-02-siso/scripts/satellite_delay.m
% Plain Octave (no toolbox needed): transfer functions are evaluated as polynomial ratios.
1;
function v = ev(num, den, s)
  v = polyval(num, s) ./ polyval(den, s);
end
function r = crossings(f, w)       % refined sign changes of f on grid w
  v = f(w); i = find(sign(v(1:end-1)) ~= sign(v(2:end))); r = [];
  for k = i, r(end+1) = fzero(f, [w(k) w(k+1)]); end
end
function [pk, wpk] = peak(f)          % sup over w>0 of f(w), dense grid + local refinement
  w = logspace(-4, 3, 200001); v = f(w); [pk, i] = max(v);
  lo = w(max(i-1,1)); hi = w(min(i+1,numel(w)));
  [wpk, m] = fminbnd(@(x) -f(x), lo, hi); pk = -m;
end

b0 = 0.00396;                                  % Exercise 4 as printed (Example 2.6 uses 0.0396)
nG = 0.036*[1 25.28];  dG = conv([1 0 0], [1 b0 1]);
nK = 7.9212*conv([1 0.1818], [1 -0.2244 0.8981]);
dK = conv([1 3.899 4.745], [1 1.039 3.395]);
nL = conv(nG, nK); dL = conv(dG, dK);
chi = dL + [zeros(1, numel(dL)-numel(nL)) nL];  % characteristic polynomial N_G N_K + D_G D_K
printf("closed-loop poles (max real part) = %.4f\n", max(real(roots(chi))));
L = @(w) ev(nL, dL, 1i*w);  S = @(w) 1./(1+L(w));  T = @(w) L(w)./(1+L(w));

% classical margins (Examples 2.7, 2.8)
wg = logspace(-3, 3, 400001);
for wc = crossings(@(w) abs(L(w))-1, wg)
  pm = mod(angle(L(wc))*180/pi, 360) - 180;   % angle of L(iwc) measured from -1
  printf("|L|=1 at w=%.4f rad/s: signed angular clearance %.2f deg, positive-delay candidate %.4f s\n", wc, pm, mod(pm,360)*pi/180/wc);
end
for w180 = crossings(@(w) imag(L(w)), wg)
  printf("Im L = 0 at w=%.4f rad/s: L = %.4f\n", w180, real(L(w180)));
end
[pT, wT] = peak(@(w) abs(T(w)));  [pS, wS] = peak(@(w) abs(S(w)));
printf("||T||_inf = %.4f at %.4f,  ||S||_inf = %.4f at %.4f\n", pT, wT, pS, wS);

% delay weight W_T(s) = T s / (1 + T s / sqrt(12))
g = sqrt(12);
WT = @(w, Td) abs(Td*1i*w ./ (1 + Td*1i*w/g));
for Td = [0.25]
  [m, wm] = peak(@(w) WT(w,Td).*abs(T(w)));
  printf("T=%.2f: ||W_T T||_inf = %.4f at w=%.4f, robust stability margin %.4f\n", Td, m, wm, 1/m);
end
Tmax_rs = fzero(@(Td) peak(@(w) WT(w,Td).*abs(T(w))) - 1, [0.2 2]);
printf("max delay with ||W_T T||<=1: %.4f s\n", Tmax_rs);

% performance weight of Example 2.20
Wpf = @(w, wB) abs(((1i*w/sqrt(5) + wB) ./ (1i*w + wB*sqrt(1e-3))).^2);
[np, wn] = peak(@(w) Wpf(w,0.1).*abs(S(w)));
printf("nominal performance ||Wp S||_inf = %.4f at w=%.4f\n", np, wn);
rp = @(Td, wB) peak(@(w) Wpf(w,wB).*abs(S(w)) + WT(w,Td).*abs(T(w)));
[r, wr] = rp(0.25, 0.1);
printf("RP index at T=0.25: max_w |WpS|+|WT T| = %.4f at w=%.4f\n", r, wr);
Tmax_rp = fzero(@(Td) rp(Td, 0.1) - 1, [0.25 1]);
printf("Tmax for robust performance: %.4f s\n", Tmax_rp);
wBmax = fzero(@(wB) rp(0.25, wB) - 1, [0.1 1]);
printf("max bandwidth wB at T=0.25: %.5f rad/s\n", wBmax);

% Exercise 5d: performance-violating model for T = 0.5 > Tmax
Td = 0.5; [r, w0] = rp(Td, 0.1); printf("Exercise 5d with T=%.2f: RP index %.4f\n", Td, r);
s0 = 1i*w0; L0 = ev(nL, dL, s0); W0 = Td*s0/(1 + Td*s0/g);
u = 1 + L0; v = W0*L0;
delta = exp(1i*(angle(u) - angle(v) + pi));     % Lemma 2.22, |u+delta v| = |u|-|v|
d0 = 0.999*delta;
printf("w0 = %.4f, |Wp(iw0)| = %.4f, |u| = %.4f, |v| = %.4f, |u+d0 v| = %.4f\n", w0, Wpf(w0,0.1), abs(u), abs(v), abs(u+d0*v));
% Lemma 2.14: Delta(s) = alpha (s-beta)/(s+beta), Delta(i w0) = d0, beta >= 0
for alpha = [abs(d0) -abs(d0)]
  beta = real(1i*w0*(alpha-d0)/(alpha+d0));
  if beta >= 0, break; end
end
printf("Delta(s) = %.4f (s - %.4f)/(s + %.4f), check Delta(iw0)-d0 = %.2e\n", alpha, beta, beta, abs(alpha*(s0-beta)/(s0+beta)-d0));
% H = G (1 + W_T Delta); evaluate ||Wp (1+HK)^-1|| and stability of (1+HK)^-1
nW = [Td 0]; dW = [Td/g 1];
nD = alpha*[1 -beta]; dD = [1 beta];
nH = conv(nG, conv(dW, dD) + conv(nW, nD));  dH = conv(dG, conv(dW, dD));
nHK = conv(nH, nK); dHK = conv(dH, dK);
chiH = dHK + [zeros(1, numel(dHK)-numel(nHK)) nHK];
printf("max real part of zeros of D_H D_K + N_H N_K = %.4f\n", max(real(roots(chiH))));
HK = @(w) ev(nHK, dHK, 1i*w);
[pp, wpp] = peak(@(w) Wpf(w,0.1)./abs(1+HK(w)));
printf("||Wp (1+HK)^-1||_inf = %.4f at w=%.4f\n", pp, wpp);
% check |H/G - 1| < |W_T| on the axis: equals |Delta| |W_T| = |d0||W_T|
printf("|Delta(iw)| = %.4f for all w\n", abs(d0));

% reference: the worked Example 2.6 uses the ten-times-more-damped b0 = 0.0396
b0b = 0.0396; dGb = conv([1 0 0], [1 b0b 1]); dLb = conv(dGb, dK);
chib = dLb + [zeros(1, numel(dLb)-numel(nL)) nL];
printf("Example 2.6 (b0=0.0396): max real part of closed-loop poles %.4f\n", max(real(roots(chib))));
Lb = @(w) ev(nL, dLb, 1i*w); Tb = @(w) Lb(w)./(1+Lb(w));
printf("Example 2.6 (b0=0.0396): ||W_T T|| at T=0.25 = %.4f\n", peak(@(w) WT(w,0.25).*abs(Tb(w))));

% Continuous rational norm checks, not just frequency-grid lower bounds.
pkg load control;
Ls = tf(nL,dL); Ss = feedback(tf(1),Ls); Ts = feedback(Ls,tf(1));
Ws = tf([0.25 0],[0.25/g 1]);
[cert,wcert] = norm(Ws*Ts,inf,1e-9);
printf("SLICOT continuous ||WT T|| = %.9f at %.7f\n",cert,wcert);
assert(abs(cert-peak(@(w) WT(w,0.25).*abs(T(w))))<1e-5);
assert(max(real(roots(chi)))<0);
Wps=((tf([1/sqrt(5) .1],[1 .1*sqrt(.001)]))^2);
[stack,wstack]=norm([Wps*Ss;Ws*Ts],inf,1e-9);
printf("SLICOT stacked norm %.9f at %.7f; continuous RP upper bound sqrt(2)*norm = %.9f\n",stack,wstack,sqrt(2)*stack);
assert(sqrt(2)*stack<1);
% Delay crossing residual and direction: ds/dtau = s/(L'/L-tau).
wcs = crossings(@(w) abs(L(w))-1,wg); delays=[];
% Enumerate all positive solutions of |N(iw)|^2-|D(iw)|^2=0
% as a polynomial in w^2; cross-check the sign-change search.
an=conv(nL,nL.*(-1).^((numel(nL)-1):-1:0));
ad=conv(dL,dL.*(-1).^((numel(dL)-1):-1:0));
ap=[zeros(1,numel(ad)-numel(an)) an]-ad;
ap=ap(1:2:end).*(-1).^((numel(ap)-1)/2:-1:0);
rr=roots(ap); positive=real(rr(abs(imag(rr))<1e-6 & real(rr)>0));
algebraic=sort(sqrt(positive))';
printf("all algebraic unit-gain crossings %s\n",mat2str(algebraic,9));
assert(numel(algebraic)==numel(wcs) && max(abs(algebraic-wcs))<1e-6);
for wc=wcs
  tau=mod(angle(L(wc))+pi,2*pi)/wc; delays(end+1)=tau;
  z=1i*wc;
  ld=polyval(polyder(nL),z)/polyval(nL,z)-polyval(polyder(dL),z)/polyval(dL,z);
  printf("delay crossing tau=%.7f, residual %.2e, Re ds/dtau=%.7f\n",tau,abs(1+L(wc)*exp(-z*tau)),real(z/(ld-tau)));
end
printf("first exact-delay crossing %.7f s (not the covering-class bound)\n",min(delays));
