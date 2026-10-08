#!/usr/bin/env python3
"""Reproduce every tiger-problem number quoted in Robotics/pomdp/pomdp.typ.

The model is the two-state tiger problem of Kaelbling, Littman & Cassandra (1998),
section 5.1: states {tiger left, tiger right}; actions {open left, open right, listen};
opening the safe door pays +10 and the other -100; listening costs -1 and returns a
growl that is correct with probability 0.85.

Standard library only. Run: python3 Robotics/pomdp/scripts/tiger_check.py
"""

Z_CORRECT = 0.85
OPEN_SAFE = 10.0
OPEN_TIGER = -100.0
LISTEN_COST = -1.0


def act_value_left(b):
    """Expected value of opening the left door; it is safe only if the tiger is right."""
    return OPEN_SAFE * (1 - b) + OPEN_TIGER * b


def act_value_right(b):
    """Expected value of opening the right door; it is safe only if the tiger is left."""
    return OPEN_SAFE * b + OPEN_TIGER * (1 - b)


def best_act(b):
    """A(b) = max over the two doors of the immediate action value."""
    return max(act_value_left(b), act_value_right(b))


def listen_then_act(b):
    """L(b): pay 1 to listen, then open the better door with the updated belief.

    The closed form L(b) = -46 + 110(|0.5b - 0.075| + |0.5b - 0.425|) of the note."""
    p_growl_left = Z_CORRECT * b + (1 - Z_CORRECT) * (1 - b)
    b_left = Z_CORRECT * b / p_growl_left
    p_growl_right = 1 - p_growl_left
    b_right = (1 - Z_CORRECT) * b / p_growl_right
    return LISTEN_COST + p_growl_left * best_act(b_left) + p_growl_right * best_act(b_right)


def report(b=0.6):
    p_left = Z_CORRECT * b + (1 - Z_CORRECT) * (1 - b)
    b_left = Z_CORRECT * b / p_left
    b_right = (1 - Z_CORRECT) * b / (1 - p_left)
    a = best_act(b)
    l = listen_then_act(b)
    info = (l - LISTEN_COST) - a  # value of the observation E[A(b')] - A(b)
    print(f"prior b = {b}")
    print(f"  P(growl left)  = {p_left:.4f}   b' = {b_left:.6f}")
    print(f"  P(growl right) = {1 - p_left:.4f}   b'' = {b_right:.6f}")
    print(f"  A(b)  = {a:.4f}    (open right)")
    print(f"  L(b)  = {l:.6f}")
    print(f"  value of the growl = {info:.4f}   net of its price = {l - a:.4f}")

    print("closed form L(b) = -46 + 110(|0.5b - 0.075| + |0.5b - 0.425|):")
    for x in (0.1, 0.15, 0.2, 0.5, 0.8, 0.85, 0.9):
        closed = -46 + 110 * (abs(0.5 * x - 0.075) + abs(0.5 * x - 0.425))
        assert abs(closed - listen_then_act(x)) < 1e-9, x
        print(f"  b = {x:>4}: L = {closed:8.4f}   (direct {listen_then_act(x):8.4f})")

    print("L(b) is flat at -7.5 on [0.15, 0.85]; it meets A(b) at")
    for b_star in (0.5 - 37.5 / 110, 0.5 + 37.5 / 110):
        assert abs(listen_then_act(b_star) - best_act(b_star)) < 1e-9
        print(f"  b = {b_star:.6f}  (A = L = {best_act(b_star):.4f})")


if __name__ == "__main__":
    report()
