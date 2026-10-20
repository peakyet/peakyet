% Cross-check the note's LP bounds against independent integer enumeration.
% Run from any directory: octave --no-gui --quiet path/to/scripts/verify.m
clear;
c = [3; 2];
A = [2, 1; 1, 2];
b = [5; 5];
param.msglev = 0;
tol = 1e-8;

% An independent list of every original-feasible integer decision.
points = [];
for x = 0:2
  for y = 0:5
    if 2*x + y >= 5 && x + 2*y >= 5
      points(end+1, :) = [x, y];
    endif
  endfor
endfor
costs = points * c;
assert(min(costs) == 9);
assert(sum(costs == 9) == 1);
assert(isequal(points(costs == 9, :), [1, 3]));
assert(all(sum(points, 2) >= 4)); % Validity of the rounded aggregation cut.
assert(3*2 + 2*2 == 10 && all(A*[2; 2] >= b));
assert(any(A*[1; 1] < b)); % Rounding down is infeasible.

names = {'R', 'B', 'C', 'D', 'A'};
lower = [0, 0; 2, 0; 2, 0; 2, 2; 0, 0];
upper = [2, 5; 2, 5; 2, 1; 2, 5; 1, 5];
expected = [25/3, 9, Inf, 10, 9];
expected_points = [5/3, 5/3; 2, 3/2; NaN, NaN; 2, 2; 1, 3];
node_bounds = zeros(1, 5);
for k = 1:numel(names)
  lb = lower(k, :)'; ub = upper(k, :)';
  [v, value, err, extra] = glpk(c, A, b, lb, ub, 'LL', 'CC', 1, param);
  in_node = all(points >= lb' & points <= ub', 2);
  if isinf(expected(k))
    assert(err == 10 || (err == 0 && extra.status == 4));
    assert(!any(in_node));
    node_bounds(k) = Inf;
    fprintf('%s: infeasible\n', names{k});
  else
    assert(err == 0 && extra.status == 5);
    assert(abs(value - expected(k)) < tol);
    assert(norm(v - expected_points(k, :)', Inf) < tol);
    assert(all(A*v >= b-tol));
    assert(all(v >= lb-tol) && all(v <= ub+tol));
    assert(value <= min(costs(in_node)) + tol);
    node_bounds(k) = value;
    fprintf('%s: (%.9g, %.9g), LP bound %.9g\n', names{k}, v(1), v(2), value);
  endif
endfor

% Closing rules for R, B, C, D, A in the order printed in the note.
assert(node_bounds(1) < 10 && node_bounds(2) < 10);
assert(isinf(node_bounds(3)) && node_bounds(4) >= 10);
assert(node_bounds(5) == 9);
% If A is solved first, B can close on equality without creating C and D.
assert(node_bounds(2) >= node_bounds(5));

[v, value, err, extra] = glpk(c, [A; 1, 1], [b; 4], [0; 0], [2; 5],
                              'LLL', 'CC', 1, param);
assert(err == 0 && extra.status == 5);
assert(abs(value-9) < tol && norm(v-[1; 3], Inf) < tol);
fprintf('Cut-strengthened root: (1, 3), LP bound 9\n');
fprintf('Enumeration: %d feasible points out of 18; unique optimum (1, 3), cost 9\n', rows(points));
fprintf('All checks passed.\n');
