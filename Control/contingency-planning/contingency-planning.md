# Contingency planning — final understanding

Contingency planning is the pre-decision system for keeping essential organizational functions operating during abnormal conditions. It is not primarily a list of backups or a promise to restore every component identically.

The central move is to plan from **functions and promises**:

1. Identify what must continue for the mission or customer.
2. Set an RTO (maximum intended unavailability), RPO (acceptable recent data loss), and MTD (outer limit of tolerable downtime).
3. Map the people, systems, data, facilities, suppliers, credentials, and authority that make each function possible.
4. Design a safe degraded mode: queue, cache, read-only operation, manual fallback, alternate supplier, or deliberate postponement.
5. Sequence recovery under scarce time and staff according to impact, not build order.
6. Make actions executable with triggers, owners, prerequisites, verification checks, communications, and exit criteria.
7. Exercise the assumptions, measure outcomes, and feed findings back into architecture, operations, and the plan.

The most important insight is that resilience is not the number of replicas or the length of a runbook. It is the ability to preserve the most important promise, honestly and safely, while the system is constrained—and to return to normal only after correctness is verified.


## Contingency MPC

Contingency model predictive control (CMPC) applies the same principle to a dynamical system. At every control update, it optimizes a nominal trajectory for normal performance while simultaneously preserving a feasible alternate trajectory for a selected emergency. The two predictions share the first command because the future event has not yet occurred; after the event is revealed, the controller can follow the alternate inputs.

For nominal and contingency models, respectively,

\[ x^n_{i+1}=f_n(x^n_i,u^n_i),\qquad x^c_{i+1}=f_c(x^c_i,u^c_i) \]

with coupling

\[x^n_0=x^c_0=x_k,\qquad u^n_0=u^c_0.\]

The optimization balances nominal performance against the contingency objective, but the contingency constraints are the important part: they ensure the predicted emergency branch remains safe and feasible. CMPC is therefore selectively robust rather than universally worst-case. Compared with scenario-tree MPC, which branches over many possible uncertainty evolutions and enforces nonanticipative decisions, CMPC maintains one explicit escape trajectory for one identified high-consequence event.

In the canonical two-horizon formulation, only the current control is coupled:

\[x^n_0=x^c_0=x_k,\qquad u^n_0=u^c_0=u_k.\]

The initial states are equal because they are the same measured plant state. The next predicted states need not be equal if the nominal and contingency models differ, even under the same first command. Future controls may diverge because the controller re-solves after applying the current command.

The branch point should be chosen from information timing. If the contingency can be detected after \(\tau_b\) samples, enforce a common prefix:

\[u^n_i=u^c_i\quad\text{for }i=0,\ldots,\tau_b-1;\qquad u^n_i\text{ and }u^c_i\text{ may differ for }i\ge\tau_b.\]

For the original receding-horizon setup, \(\tau_b=1\) is appropriate when the event can be classified before the next command is issued. With sensing or communication delay, use a longer common prefix. If the event is already confirmed, activate the contingency policy; if its timing is uncertain, use multiple branch points or a scenario tree.


## Dynamic branch timing

The branch time does not have to be fixed. A practical approach is event-triggered CMPC: a monitor updates the evidence about the contingency and activates the branch when a residual, fault classifier, belief threshold, or predicted safety margin crosses a trigger. A reachability- or viability-based trigger can branch before waiting makes the contingency infeasible.

A conceptual rule is to choose the earliest time at which either the evidence is strong enough or the remaining safe escape margin is about to disappear. The trigger must be causal: it may use only information available to the real controller. If the branch time is optimized directly, impose a common control prefix for every delay that is still observationally indistinguishable and certify safety for the latest allowed branch.

A useful implementation maintains an information clock and a safety clock. The information clock is the first time a detector or belief update justifies different actions. The safety clock is the latest time at which a common prefix remains viable for every relevant scenario. A conservative branch rule is \(\tau_{\mathrm{branch}}=\min(\tau_{\mathrm{info}},\tau_{\mathrm{safe}})\). If safety becomes tight before the event is identifiable, the controller should not use scenario-specific controls; it should switch to an emergency-ready common policy.

This is different from adaptive scenario-tree MPC, where new measurements update the scenarios or uncertainty set themselves. Belief-space/POMDP-style MPC is useful when the event is partially observed and sensing actions affect future information.
