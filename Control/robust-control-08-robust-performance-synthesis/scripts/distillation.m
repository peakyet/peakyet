% Chapter 8: analysis, an explicit counterexample, and two constant-D/K updates.
% Run from the repository root with Octave and the control package.
1;
pkg load control;

function val = scaled_peak(x, responses)
  D = diag([exp(x(1)), exp(x(2)), 1, 1]);
  val = 0;
  for j = 1:size(responses, 3)
    val = max(val, norm(D \ responses(:,:,j) * D, 2));
  end
end

function value = point_bound(M)
  % Coarse grid followed by a local search, not an exact mu computation.
  best = Inf; start = [0;0];
  for u = -6:1:6
    for v = -6:1:6
      value = scaled_peak([u;v], M);
      if value < best, best = value; start = [u;v]; end
    end
  end
  [~, value] = fminsearch(@(x) scaled_peak(x,M), start, ...
    optimset('MaxIter',1000,'MaxFunEvals',2000,'Display','off'));
  value = min(best,value);
end

s = tf('s');
G0 = [87.8,-86.4;108.2,-109.6];
G = ss(1/(75*s+1))*G0;
W = ss((s+.1)/(.5*s+1))*eye(2);
I = ss(eye(2)); Z = ss(zeros(2));
Delta = ss(diag([-.99,0]));
Gp = G*(I+Delta*W);
printf('cond(G0) = %.6f; DC input gain change = -9.9%%\n',cond(G0));

% Part (b): retain both the upper bound and actual uncertainty witness.
for beta = [.1,.3,.5,.7]
  Kb = ss(beta*(75*s+1)/s)*inv(G0);
  Wp = ss((s+beta)/(s+1e-6))*eye(2);
  P = minreal([Z,Z,W; -Wp*G,Wp,-Wp*G; -G,I,-G]);
  M = lft(P,Kb);
  frequencies = logspace(-2,3,28);
  R = freqresp(M,frequencies); upper = 0;
  for j = 1:numel(frequencies), upper = max(upper,point_bound(R(:,:,j))); end
  rs = norm(ss((s+.1)/(.5*s+1)*beta/(s+beta)),Inf,1e-8);
  Sbad = feedback(I,Gp*Kb);
  assert(all(real(pole(Sbad)) < 0));
  witness_w = .1;
  witness = norm(freqresp(Wp*Sbad,witness_w),2);
  assert(witness > 1);
  printf(['beta=%.1f: RS norm %.6f; nominal performance 1; sampled RP upper %.4f; ' ...
          'actual bad-Delta gain at w=%.1f: %.4f; 2%% settling %.4f minutes\n'], ...
          beta,rs,upper,witness_w,witness,-log(.02)/beta);
end

% Part (c): the deliberate specification relaxation is alpha=0.1, beta=0.5.
alpha = .1; beta = .5;
Wp = ss(alpha*(s+beta)/(s+1e-6))*eye(2);
P = minreal([Z,Z,W; -Wp*G,Wp,-Wp*G; -G,I,-G]);
Kb = ss(beta*(75*s+1)/s)*inv(G0); K = Kb;
frequencies = [0,logspace(-7,5,600)]; x = [0;0];
for iteration = 1:2
  M = lft(P,K);
  % freqresp at Inf is undefined numerically; the state-space D matrix is its limit.
  R = cat(3,freqresp(M,frequencies),M.d);
  [xnew,sampled] = fminsearch(@(x) scaled_peak(x,R),x, ...
    optimset('MaxIter',250,'TolX',1e-6,'Display','off'));
  if sampled <= scaled_peak(x,R), x = xnew; end
  D = diag([exp(x(1)),exp(x(2)),1,1]);
  incumbent = norm(ss(inv(D))*M*ss(D),Inf,1e-8);
  Pd = blkdiag(inv(D),eye(2))*P*blkdiag(D,eye(2));
  [candidate,~,solver_gamma] = hinfsyn(Pd,2,2);
  candidate_M = lft(P,candidate);
  assert(all(real(pole(candidate_M)) < 0));
  candidate_bound = norm(ss(inv(D))*candidate_M*ss(D),Inf,1e-8);
  accepted = candidate_bound <= incumbent;
  if accepted, K = candidate; end
  certified = norm(ss(inv(D))*lft(P,K)*ss(D),Inf,1e-8);
  printf(['iteration %d: D=(%.8f,%.8f,1,1); old norm %.9f; ' ...
          'candidate norm %.9f; solver %.9f; accepted %d; retained %.9f\n'], ...
          iteration,D(1,1),D(2,2),incumbent,candidate_bound,solver_gamma,accepted,certified);
end
K2 = K; % Full state-space realization remains available when run interactively.
assert(certified < .8);
assert(all(real(pole(lft(P,K2))) < 0));
printf('Retained controller order %d; nominal closed-loop rightmost pole %.9g\n', ...
       rows(K2.a),max(real(pole(lft(P,K2)))));
disp('Controller realization [A B; C D], with A of size 6 by 6:');
disp([K2.a,K2.b;K2.c,K2.d]);

t = (0:.02:60)';
nominal = exp(-beta*t)*[1,1];
bad = lsim(feedback(I,Gp*Kb),ones(numel(t),2),t);
improved_loop = feedback(I,Gp*K2);
assert(all(real(pole(improved_loop)) < 0));
improved = lsim(improved_loop,ones(numel(t),2),t);
assert(max(bad(:,2)) > 3.8 && max(improved(:,2)) < 1.05);
for pair = {bad,improved}
  ee = pair{1};
  printf('step maxima=(%.6f,%.6f), minima=(%.6f,%.6f), at t=2=(%.6f,%.6f)\n', ...
    max(ee),min(ee),ee(101,:));
end

% Cross-check the analytic uncertainty formula independently of lft synthesis.
analytic = G0*blkdiag(s/(s+beta*(1-.99*(s+.1)/(.5*s+1))), ...
                            s/(s+beta))*inv(G0);
for w = [.03,.2,2,20]
  assert(norm(freqresp(analytic,w)-freqresp(feedback(I,Gp*Kb),w),2) < 1e-7);
end

% Compute both controller singular values, not just entries or a scalar gain.
w = logspace(-3,2,240);
R = freqresp(K2,w); Rb = freqresp(Kb,w);
sigma = zeros(2,numel(w)); sigma_b = sigma;
for j=1:numel(w), sigma(:,j)=svd(R(:,:,j)); sigma_b(:,j)=svd(Rb(:,:,j)); end
set(0,'defaultaxesfontname','DejaVu Sans','defaulttextfontname','DejaVu Sans', ...
      'defaultaxesfontsize',14,'defaulttextfontsize',14);
fh=figure('visible','off','position',[0,0,1000,460]);
subplot(1,2,1); hold on; grid on;
plot(t,bad(:,2),'color',[.65,.25,.15],'linewidth',2);
plot(t,improved(:,2),'color',[.06,.46,.43],'linewidth',2);
plot(t,nominal(:,2),'--','color',[.35,.35,.35],'linewidth',1.5);
xlim([0,30]); ylim([-1,4]); xlabel('Time (minutes)'); ylabel('Output 2 tracking error');
title('Same bad uncertainty');
legend('Decoupling','Redesign','Nominal decoupling','location','northeast','fontsize',12);
subplot(1,2,2); hold on; grid on;
loglog(w,sigma(1,:),'color',[.06,.46,.43],'linewidth',2);
loglog(w,sigma(2,:),'--','color',[.06,.46,.43],'linewidth',2);
loglog(w,sigma_b(1,:),':','color',[.65,.25,.15],'linewidth',1.8);
xlabel('Frequency (rad/min)'); ylabel('Controller singular value');
title('Directional controller gain');
legend('Redesign: largest','Redesign: smallest','Decoupling: largest', ...
       'location','southwest','fontsize',12);
assets=fullfile(fileparts(fileparts(mfilename('fullpath'))),'assets');
if ~exist(assets,'dir'), mkdir(assets); end
print(fh,fullfile(assets,'redesign.svg'),'-dsvg');
close(fh);
