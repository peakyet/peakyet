# dcp_tree_count.py — proves: allowing at most ONE action change per planning
# cycle turns an exponential policy count into a linear one (EPSILON's DCP-Tree).
# Run: python3 dcp_tree_count.py

def all_sequences(n_actions, depth):
    """Candidate policies if any sequence of semantic actions were allowed."""
    return n_actions ** depth

def dcp_tree(n_actions, depth):
    """Policies with at most one change: stay with the ongoing action the whole
    way, or switch once at any of the (depth-1) later steps to any other action."""
    return 1 + (depth - 1) * (n_actions - 1)

n = 9          # ego menu: 3 longitudinal (aggr./mod./cons.) x 3 lateral (keep/L/R)
h = 5          # tree depth: 5 semantic actions x 1 s = 5 s horizon
print(f"action menu |A| = {n}, tree depth h = {h}")
print(f"all action sequences : {all_sequences(n, h):>7,} policies")
print(f"DCP-Tree (1 change)  : {dcp_tree(n, h):>7,} policies")
print(f"reduction            : {all_sequences(n, h) / dcp_tree(n, h):>7,.0f}x")
print()
print(f"{'depth h':>8} {'all sequences':>15} {'DCP-Tree':>10}")
for h in range(2, 9):
    print(f"{h:>8} {all_sequences(n, h):>15,} {dcp_tree(n, h):>10,}")
