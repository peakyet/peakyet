% Reproduce the asymmetric teaching example and an explicit Exercise-4 witness.
% Run: QT_QPA_PLATFORM=offscreen octave --no-gui <this file>
format long g
here=fileparts(mfilename('fullpath')); out=fullfile(here,'..','assets');
T=[0 4; .25 0];
printf('asymmetric: full gain %.12f, diagonal mu %.12f\n',norm(T),sqrt(4*.25));
for d={[.2;4],[.3;4],[1;1]}
 ev=eig(-eye(2)+diag(d{1})*T);
 printf('d1=%.3f d2=%.3f FULL poles: ',d{1}); disp(ev.');
end
Df=[0 0;.25 0];
printf('full-block witness norm %.12f, det residual %.3e; FULL poles ',norm(Df),abs(det(eye(2)-T*Df)));
disp(eig(-eye(2)+Df*T).');
Mc=[12 -3 2;-1 7 8;5 3 -1];
f=@(t) [Mc(1:2,1:2),t*Mc(1:2,3);Mc(3,1:2)/t,Mc(3,3)];
[t,g]=fminbnd(@(t) norm(f(t)),.5,2,optimset('TolX',1e-13));
[U,S,V]=svd(f(t)); u=U(:,1); v=V(:,1);
Dw=blkdiag(v(1:2)*u(1:2)'/(u(1:2)'*u(1:2)*g),v(3)/u(3)/g);
printf('ex4 independent SVD: t %.12f, upper %.12f, witness norm %.12f, lower %.12f, residual %.3e\n',t,g,norm(Dw),1/norm(Dw),min(svd(eye(3)-Mc*Dw)));
disp(Dw);
graphics_toolkit('qt');
fig=figure('visible','off','position',[0 0 900 370]);
subplot(1,2,1); w=logspace(-2,2,500);
semilogx(w,4./sqrt(1+w.^2),'linewidth',2,w,1./sqrt(1+w.^2),'linewidth',2); grid on;
xlabel('frequency (rad/s)'); ylabel('gain'); title('Same M, different uncertainty sets');
legend('full-block gain','diagonal complex mu','location','northeast');
subplot(1,2,2); r=linspace(.1,1.2,500);
plot(r,1./r,'linewidth',2); hold on;
plot(.2,4,'o','markersize',8,'linewidth',2); plot(.3,4,'x','markersize',8,'linewidth',2);
xlabel('radius r_1'); ylabel('radius r_2'); title('Diagonal uncertainty: r_1 r_2 = 1');
ylim([0 6]); grid on; legend('boundary','stable corner','unstable corner');
print(fig,fullfile(out,'asymmetric.svg'),'-dsvg'); close(fig);
fig=figure('visible','off','position',[0 0 650 330]);
ts=linspace(.5,2,500); vs=arrayfun(@(t)norm(f(t)),ts); fs=arrayfun(@(t)norm(f(t),'fro'),ts);
plot(ts,vs,'linewidth',2,ts,fs,'linewidth',2); hold on; plot(t,g,'o','linewidth',2);
grid on; xlabel('scaling ratio t'); ylabel('upper bound'); title('Exercise 4: two different norm optimizations');
legend('spectral norm (tight here)','Frobenius norm','spectral optimum');
print(fig,fullfile(out,'scaling.svg'),'-dsvg'); close(fig);
