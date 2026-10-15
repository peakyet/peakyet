% Reproducible SVG plots without a graphics backend. Run from repository root.
1;
function svgplot(path,x,ys,labels,xlabel,ylabel,xlim,ylim,logx)
  colors={'#176b87','#c45123','#6c4697','#158064'};
  f=fopen(path,'w');
  fprintf(f,'<svg xmlns="http://www.w3.org/2000/svg" width="840" height="420" viewBox="0 0 840 420"><rect width="840" height="420" fill="white"/><g font-family="sans-serif" font-size="15" fill="#263445">');
  if logx, xx=log10(x); xl=log10(xlim); else xx=x; xl=xlim; end
  X=@(v) 75+700*(v-xl(1))/diff(xl); Y=@(v) 325-275*(v-ylim(1))/diff(ylim);
  for a=linspace(xl(1),xl(2),5)
    fprintf(f,'<path d="M %.2f 50 V 325" stroke="#dce2e8"/><text x="%.2f" y="350" text-anchor="middle">',X(a),X(a));
    if logx, fprintf(f,'%.3g',10^a); else fprintf(f,'%.2g',a); end
    fprintf(f,'</text>');
  end
  for a=linspace(ylim(1),ylim(2),6)
    fprintf(f,'<path d="M 75 %.2f H 775" stroke="#dce2e8"/><text x="65" y="%.2f" text-anchor="end">%.2g</text>',Y(a),Y(a)+5,a);
  end
  fprintf(f,'<defs><clipPath id="p"><rect x="75" y="50" width="700" height="275"/></clipPath></defs><g clip-path="url(#p)">');
  for k=1:rows(ys)
    fprintf(f,'<polyline fill="none" stroke="%s" stroke-width="2.5" points="',colors{k});
    fprintf(f,'%.2f,%.2f ',[X(xx(:)) Y(ys(k,:)(:))]'); fprintf(f,'"/>');
  end
  fprintf(f,'</g>');
  if !isempty(strfind(path,'nyquist'))
    [~,j]=min(abs(x+1+1i*ys(1,:)));
    fprintf(f,'<path d="M %.2f %.2f L %.2f %.2f" stroke="#222" stroke-dasharray="5 4"/><circle cx="%.2f" cy="%.2f" r="4" fill="#222"/><text x="%.2f" y="%.2f">-1</text>',X(-1),Y(0),X(x(j)),Y(ys(1,j)),X(-1),Y(0),X(-1)-22,Y(0)-10);
  else
    fprintf(f,'<path d="M 75 %.2f H 775" stroke="#555" stroke-dasharray="6 4"/><text x="780" y="%.2f">1</text>',Y(1),Y(1)+5);
  end
  for k=1:numel(labels)
    fprintf(f,'<text x="%d" y="28" fill="%s">%s</text>',75+(k-1)*235,colors{k},labels{k});
  end
  fprintf(f,'<text x="425" y="392" text-anchor="middle">%s</text><text transform="translate(20 190) rotate(-90)" text-anchor="middle">%s</text></g></svg>',xlabel,ylabel);
  fclose(f);
end
base='Control/robust-control-02-siso/assets/';
% A thermally inertial plant with an uncertain actuator gain.
w=logspace(-2,2,1200); z=1i*w; L=3./(z+1); S=1./(1+L); T=L./(1+L);
svgplot([base 'thermal.svg'],w,[abs(S);abs(T);abs(S)+0.2*abs(T)],{'|S|','|T|','|S| + 0.2 |T|'},'Frequency (rad/s)','Dimensionless gain',[.01 100],[0 1.4],true);
% Geometry: an unstable open-loop example with joint gain and phase fragility.
n=-.46832*conv(conv(conv([1 3.3],[1 -2]),[1 .55]),[1 .8824 .5882]);
d=conv(conv(conv([1 .303],[1 -.5]),[1 1.818]),[1 1.5 1.7]);
w=logspace(-5,5,100000); v=polyval(n,1i*w)./polyval(d,1i*w);
[dist,j]=min(abs(1+v)); c=-1/v(j);
printf('Example 2.10 grid: distance %.9f at %.7f, critical c=%.7f%+.7fi, |c|=%.7f, phase=%.5f deg\n',dist,w(j),real(c),imag(c),abs(c),angle(c)*180/pi);
chi=d+n; printf('Example 2.10 nominal max Re pole %.9f\n',max(real(roots(chi))));
printf('Isolated critical gain, phase: max Re pole %.9f, %.9f\n',max(real(roots(d+abs(c)*n))),max(real(roots(d+exp(1i*angle(c))*n))));
assert(max(real(roots(d+abs(c)*n)))<0 && max(real(roots(d+exp(1i*angle(c))*n)))<0);
svgplot([base 'nyquist.svg'],real(v),[imag(v);-imag(v)],{'positive frequency','negative frequency'},'Real L','Imaginary L',[-1.7 .2],[-.7 .7],false);
% Satellite: separate robust stability and robust performance budgets.
nG=.036*[1 25.28]; dG=conv([1 0 0],[1 .00396 1]);
nK=7.9212*conv([1 .1818],[1 -.2244 .8981]); dK=conv([1 3.899 4.745],[1 1.039 3.395]);
w=logspace(-2,1.5,2000); z=1i*w;
L=polyval(conv(nG,nK),z)./polyval(conv(dG,dK),z); S=1./(1+L); T=L./(1+L);
Wp=abs(((z/sqrt(5)+.1)./(z+.1*sqrt(.001))).^2);
u=@(tau) abs(tau*z./(1+tau*z/sqrt(12))).*abs(T);
svgplot([base 'satellite.svg'],w,[u(.25);Wp.*abs(S)+u(.25);Wp.*abs(S)+u(.5)],{'RS, delay 0.25 s','RP, delay 0.25 s','RP, delay 0.50 s'},'Frequency (rad/s)','Worst-case budget',[.01 10^1.5],[0 1.4],true);
% The thermal example has an exact continuous maximum, verified here.
wm=sqrt(25^2-1);
assert(abs(abs((1i*wm+1)/(1i*wm+4))+.6/abs(1i*wm+4)-sqrt(1+.6^2/15))<1e-12);
printf('Thermal exact RP maximum %.9f at %.7f\n',sqrt(1+.6^2/15),wm);
