% Executable examples for Chapter 9. Run from the repository root.
1;
pkg load control;
s=tf('s'); g=1/(s+1); t=(0:.02:12)';
set(0,'defaultaxesfontname','DejaVu Sans','defaulttextfontname','DejaVu Sans', ...
      'defaultaxesfontsize',14,'defaulttextfontsize',14);
fh=figure('visible','off','position',[0,0,800,330]); hold on; grid on;
colors=[.12,.31,.47;.06,.46,.43;.65,.25,.15]; index=0;
for a=[.5,1,2]
  index=index+1; Q=a/(s+a); k=a*(s+1)/(s*(s+a+1));
  T=feedback(ss(g*k),1);
  % Compare physical feedback with a separately specified closed-loop transfer.
  for w=[.07,.8,3.2]
    assert(abs(freqresp(T,w)-a/((1i*w+1)*(1i*w+a))) < 1e-9);
    assert(abs(freqresp(feedback(k,g),w)-freqresp(Q,w)) < 1e-9);
  end
  assert(all(real(pole(T)) < 0));
  response=step(T,t);
  if a==1, assert(max(abs(response-(1-(1+t).*exp(-t)))) < 1e-8); end
  plot(t,response,'linewidth',2,'color',colors(index,:));
end
xlabel('Time'); ylabel('Unit-step output y'); title('Choose stable Q_a; recover stabilizing k_a');
legend('a = 0.5','a = 1','a = 2','location','southeast'); ylim([0,1.05]);
assets=fullfile(fileparts(fileparts(mfilename('fullpath'))),'assets');
if ~exist(assets,'dir'), mkdir(assets); end
print(fh,fullfile(assets,'youla-response.svg'),'-dsvg'); close(fh);

% An unstable controller can stabilize a stable plant. Do not cancel its states first.
k=ss(2*(s+1)/(s-1));
assert(any(real(pole(k)) > 0));
assert(all(real(pole(feedback(k,ss(g)))) < 0));

% Unstable plant and scalar coprime family (negative feedback).
gu=ss(1/(s-1)); n=1/(s+1); m=(s-1)/(s+1);
for q=[0,1]
  k=minreal((2+m*q)/(1-n*q));
  S=feedback(ss(1),gu*ss(k));
  assert(all(real(pole(S)) < 0));
  for w=[.13,.6,2.7]
    actual=freqresp(S,w);
    expected=(1i*w-1)/(1i*w+1)*(1-q/(1i*w+1));
    assert(abs(actual-expected) < 1e-8);
  end
end

% H2 projection example: expectations follow from independent scalar integrals.
gi=(s-1)/(s+1); target=1/(s+1);
assert(abs(norm(ss(target),2)^2-.5) < 1e-10);
for a=[.3,1.7]
  Q=a/(s+2);
  assert(abs(norm(ss(gi*Q-target),2)^2-(a^2/4+.5)) < 1e-9);
end
% Improper inverse: the filtered inverse converges without pretending exact attainment.
errors=[];
for eta=[.2,.05,.01]
  Q=(s+1)*target/(1+eta*s);
  errors(end+1)=norm(ss(g*Q-target),2);
end
assert(all(diff(errors) < 0));
printf('Almost-optimal matching errors: %.6f %.6f %.6f\n',errors);

% A noncommuting, asymmetric matrix example catches ordering and sign mistakes.
P=[1/(s+1),tf(0);2/(s+3),3/(s+2)];
Q=[.4/(s+2),tf(0);-.7/(s+4),.2/(s+5)];
for w=[.09,.7,2.3]
  p=freqresp(P,w); q=freqresp(Q,w);
  K=(eye(2)+q*p)\q;
  recovered=K/(eye(2)-p*K);
  assert(norm(recovered-q,2) < 1e-12 && abs(K(1,2)) < 1e-12);
  assert(norm(p*q-q*p,2) > 1e-4);
end

% Check the observer-based affine formula against the actual physical feedback loop.
A=[1,.4;0,-2]; B1=[.3;1]; B2=[1;1]; C1=[1,-.7]; C2=[1,0];
F=[-3,0]; L=[-4;0]; D11=.2; D12=.4; D21=.3;
P=ss(A,[B1,B2],[C1;C2],[D11,D12;D21,0]);
J=ss(A+B2*F+L*C2,[-L,B2],[F;-C2],[0,1;1,0]);
fixed=ss([A+B2*F,-B2*F;zeros(2),A+L*C2], ...
  [B1,B2;B1+L*D21,zeros(2,1)], ...
  [C1+D12*F,-D12*F;zeros(1,2),C2],[D11,D12;D21,0]);
for q={ss(0),ss(1/(s+3))}
  K=lft(J,q{1}); physical=lft(P,K);
  affine=fixed(1,1)+fixed(1,2)*q{1}*fixed(2,1);
  assert(all(real(pole(physical)) < 0));
  for w=[.17,.9,4]
    assert(abs(freqresp(physical,w)-freqresp(affine,w)) < 1e-9);
  end
end

% The printed exercise 2(d) omits LC even for D=0: Q=0 is then not a stabilizer.
A=1; B=1; C=1; F=-2; L=-2;
printed_K=ss(A+B*F,L,-F,0);
assert(max(real(pole(feedback(printed_K,gu,+1)))) > -1e-8);
corrected_K=ss(A+B*F+L*C,L,-F,0);
assert(all(real(pole(feedback(corrected_K,gu,+1))) < 0));
disp('All Chapter 9 numerical examples passed.');
