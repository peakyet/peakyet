# Run: python3 prioritized-recovery.py — proves scarce recovery capacity must follow service priority.
services = {
    "payments": {"time": 50, "essential": True},
    "invoices": {"time": 30, "essential": False},
    "dashboards": {"time": 40, "essential": False},
}
budget = 90


def recover(order):
    used, restored = 0, []
    for name in order:
        if used + services[name]["time"] <= budget:
            restored.append(name)
            used += services[name]["time"]
    return restored, used

for label, order in [
    ("naive build order", ["dashboards", "invoices", "payments"]),
    ("priority order", ["payments", "invoices", "dashboards"]),
]:
    restored, used = recover(order)
    status = "UP" if "payments" in restored else "DOWN"
    print(f"{label:18} -> {', '.join(restored):20} ({used:2} min), payments: {status}")
