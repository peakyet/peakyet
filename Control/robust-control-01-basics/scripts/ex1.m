% ex1.m -- Exercise 1 of Scherer, Theory of Robust Control, Chapter 1.
%
% Verifies the hand-derived 9-state realization of
%   G(s) = [ 1/s                       1/(s+1)^2   s/(s+1)          ]
%          [ (s^2-3s+5)/(2s^3+4s+1)    1/s         1/(s+1)          ]
% and shows that its McMillan degree (minimal order) is 8, not 9.
%
% Plain Octave (no toolbox needed).  Run from the repository root:
%   octave --no-gui Control/robust-control-01-basics/scripts/ex1.m

1;

A = [ 0  0  0  0   0   0  0  0   0;
      0  0  1  0   0   0  0  0   0;
      0 -1 -2  0   0   0  0  0   0;
      0  0  0 -1   0   0  0  0   0;
      0  0  0  0   0   1  0  0   0;
      0  0  0  0   0   0  1  0   0;
      0  0  0  0 -1/2 -2  0  0   0;
      0  0  0  0   0   0  0  0   0;
      0  0  0  0   0   0  0  0  -1];
B = [ 1 0 0; 0 0 0; 0 1 0; 0 0 1; 0 0 0; 0 0 0; 1 0 0; 0 1 0; 0 0 1];
C = [ 1 1 0 -1 0 0 0 0 0; 0 0 0 0 5/2 -3/2 1/2 1 1];
D = [ 0 0 1; 0 0 0];

G = @(s) [ 1/s, 1/(s+1)^2, s/(s+1);
           (s^2-3*s+5)/(2*s^3+4*s+1), 1/s, 1/(s+1) ];

printf('realization check  max |C(sI-A)^-1 B + D - G(s)| over s in {0.5,1,2,3}:\n');
for s = [0.5 1 2 3]
  H = C*((s*eye(9)-A)\B) + D;
  printf('  s = %.1f :  %.3e\n', s, max(abs(H(:) - G(s)(:))));
end

% McMillan degree = rank of the block Hankel matrix of Markov parameters
% h_k = C A^{k-1} B of the strictly proper part.
N = 20; h = zeros(2,3,N); Ak = eye(9);
for k = 1:N
  h(:,:,k) = C*Ak*B;
  Ak = Ak*A;
end
Hb = []; for i = 1:10
  row = []; for j = 1:10, row = [row h(:,:,i+j-1)]; end
  Hb = [Hb; row];
end
printf('minimum order via Hankel rank = %d  (stacked states = 9)\n', rank(Hb));

% Cross-check with minreal when the control package is available.
try
  pkg load control;
  printf('control package minreal order = %d\n', size(minreal(ss(A,B,C,D)).a,1));
catch
  printf('(control package not loaded; Hankel rank above is the minimal order)\n');
end

% Remaining chapter examples. Fail loudly rather than merely printing claims.
pkg load control;
assert(rank(Hb)==8);
assert(size(minreal(ss(A,B,C,D)).a,1)==8);
for s=[0.5,1,2,3,1+2i,-0.3+0.7i]
  assert(norm(C*((s*eye(9)-A)\B)+D-G(s),inf)<1e-12);
end
plant=ss([-1 0;3 -2],[1;0],[0 1],0);
t=(0:0.01:6)'; ys=step(plant,t);
y=1.5-3*exp(-t)+1.5*exp(-2*t);
step_error=max(abs(ys-y)); assert(step_error<1e-12);
printf('two-state step max error = %.3e; y(6) = %.12f\n',step_error,y(end));
H=tf([1 -1],[1 3 2]);
h=@(t) -2*exp(-t)+3*exp(-2*t);
r=log(1.5);
peak=quadgk(@(t) abs(h(t)),0,Inf,'WayPoints',r);
hn=norm(H,inf,1e-10);
assert(abs(peak-5/6)<1e-10 && abs(hn-0.5)<1e-8);
printf('signed kernel: zero %.12f; absolute integral %.12f; Hinf %.12f\n',r,peak,hn);
% Exact piecewise-constant propagation for sign-aligned peak input at T=8.
Ah=diag([-1 -2]); Bh=[1;1]; Ch=[-2 3]; T=8;
x=Ah\((expm(Ah*(T-r))-eye(2))*Bh*(-1));
x=expm(Ah*r)*x+Ah\((expm(Ah*r)-eye(2))*Bh);
peak8=Ch*x; assert(abs(peak8-quadgk(@(t) abs(h(t)),0,T,'WayPoints',r))<1e-12);
printf('sign-aligned output at T=8 = %.12f (limit 5/6)\n',peak8);
% Constant-pulse output energy INCLUDING the infinite post-pulse tail.
% Lyapunov integrates the tail exactly; quadrature checks the on-pulse segment.
P=lyap(Ah',Ch'*Ch);
for T=[10 100 1000]
  xt=Ah\((expm(Ah*T)-eye(2))*Bh);
  E=quadgk(@(t) (-0.5+2*exp(-t)-1.5*exp(-2*t)).^2,0,T)+xt'*P*xt;
  printf('constant pulse T=%d: energy gain %.12f\n',T,sqrt(E/T));
  assert(sqrt(E/T)<hn);
end
M=[1 2;0 1]; v=[1;1+sqrt(2)]; v=v/norm(v);
assert(abs(norm(M*v)-(1+sqrt(2)))<1e-12);
printf('MIMO singular gain %.12f; direction [%.12f %.12f]\n',norm(M),v);
for b=[-1 3]
  inverse=ss(-2-(b-2),1,-(b-2),1);
  for s=[0.2+0.7i 2+3i]
    [ai,bi,ci,di]=ssdata(inverse);
    assert(abs((ci*((s*eye(size(ai))-ai)\bi)+di)*(s+b)/(s+2)-1)<1e-12);
  end
  printf('b=%d: inverse pole %.0f\n',b,pole(inverse));
end
m=6; hh=[0.25 2*(-0.5).^(0:m-1)];
Mm=toeplitz(hh,[hh(1) zeros(1,m)]); u=sign(Mm(end,:))';
assert(norm(Mm,inf)==4.1875 && (Mm*u)(end)==4.1875);
printf('discrete horizon 6 norm %.12f; attained output %.12f; limit 4.25\n',norm(Mm,inf),(Mm*u)(end));

% Deterministic SVG generation: no plotting backend, fonts or package installs.
function svgtext(f,x,y,s,color='#253746',size=15)
  fprintf(f,'<text x="%g" y="%g" fill="%s" font-family="sans-serif" font-size="%g">%s</text>\n',x,y,color,size,s);
end
function curve(f,x,y,box,xlim,ylim,color)
  X=box(1)+(x-xlim(1))/diff(xlim)*box(3);
  Y=box(2)+box(4)-(y-ylim(1))/diff(ylim)*box(4);
  fprintf(f,'<polyline fill="none" stroke="%s" stroke-width="2.5" points="',color);
  fprintf(f,'%.3f,%.3f ',[X(:)';Y(:)']); fprintf(f,'"/>\n');
end
function axes_svg(f,box,xlim,ylim,xlabel,ylabel)
  for a=linspace(ylim(1),ylim(2),4)
    yy=box(2)+box(4)-(a-ylim(1))/diff(ylim)*box(4);
    fprintf(f,'<path d="M%g %g H%g" stroke="#dce3e8"/>',box(1),yy,box(1)+box(3));
    svgtext(f,box(1)-38,yy+5,sprintf('%.2g',a),'#596775',13);
  end
  for a=linspace(xlim(1),xlim(2),4)
    xx=box(1)+(a-xlim(1))/diff(xlim)*box(3);
    svgtext(f,xx-5,box(2)+box(4)+22,sprintf('%.2g',a),'#596775',13);
  end
  svgtext(f,box(1),box(2)-15,ylabel);
  svgtext(f,box(1)+box(3)-45,box(2)+box(4)+43,xlabel);
end
out=fullfile(fileparts(fileparts(mfilename('fullpath'))),'assets');
if ~exist(out,'dir'), mkdir(out); end
f=fopen(fullfile(out,'basics.svg'),'w');
fprintf(f,'<svg xmlns="http://www.w3.org/2000/svg" width="880" height="320" viewBox="0 0 880 320"><rect width="880" height="320" fill="white"/>');
box=[55 55 340 200]; axes_svg(f,box,[0 6],[0 1.5],'t (s)','Unit-step response');
curve(f,t,ones(size(t)),box,[0 6],[0 1.5],'#89939d');
curve(f,t,1-exp(-t),box,[0 6],[0 1.5],'#0f766e');
curve(f,t,y,box,[0 6],[0 1.5],'#1f4e79');
svgtext(f,280,85,'y = x2','#1f4e79'); svgtext(f,315,148,'x1','#0f766e');
box=[490 55 340 200]; axes_svg(f,box,[0 3],[0 20],'t (s)','Hidden mode versus visible output');
tt=linspace(0,3,300);
curve(f,tt,exp(tt)-1,box,[0 3],[0 20],'#b45309');
curve(f,tt,1.5-3*exp(-tt)+1.5*exp(-2*tt),box,[0 3],[0 20],'#1f4e79');
svgtext(f,565,110,'q = exp(t) - 1','#b45309');
svgtext(f,565,225,'same bounded y','#1f4e79'); fprintf(f,'</svg>'); fclose(f);
f=fopen(fullfile(out,'gains.svg'),'w');
fprintf(f,'<svg xmlns="http://www.w3.org/2000/svg" width="880" height="320" viewBox="0 0 880 320"><rect width="880" height="320" fill="white"/>');
box=[55 55 340 200]; axes_svg(f,box,[0 6],[-0.5 1],'t (s)','Impulse kernel h(t)');
curve(f,t,zeros(size(t)),box,[0 6],[-0.5 1],'#89939d');
curve(f,t,h(t),box,[0 6],[-0.5 1],'#0f766e');
svgtext(f,155,115,'positive area = 1/6','#0f766e',14);
svgtext(f,155,235,'negative area = -2/3','#0f766e',14);
box=[490 55 340 200]; axes_svg(f,box,[0 6],[0 0.6],'w (rad/s)','Frequency magnitude |H(iw)|');
curve(f,t,1./sqrt(t.^2+4),box,[0 6],[0 0.6],'#1f4e79');
svgtext(f,600,105,'maximum = 1/2','#1f4e79'); fprintf(f,'</svg>'); fclose(f);
printf('All assertions passed; regenerated assets/basics.svg and assets/gains.svg\n');
