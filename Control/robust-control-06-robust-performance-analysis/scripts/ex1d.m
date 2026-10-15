% Deterministic Exercise 1(d) witness; no randomized mu search.
J=[0 1;1 0];
for h=[10 100]
  G=diag([h 1/h]); M1=inv(G); M2=eye(2);
  N=[-M1*G M1;-M2*G M2];
  lambda=h+1/h; D=blkdiag(-J,J)/lambda;
  printf('h=%g cond(G)=%g ||M1G||=%g ||M2||=%g mu >= %.9g\n', ...
    h,cond(G),norm(M1*G),norm(M2),lambda);
  printf('  witness norm %.12g, sigma_min(I-ND)=%.3g\n',norm(D),min(svd(eye(4)-N*D)));
  assert(min(svd(eye(4)-N*D))<1e-12);
end
