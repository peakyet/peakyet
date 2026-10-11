---
name: teaching-complex-ideas
description: "Explains complex engineering ideas to beginners through concrete examples, visual reasoning, and complete derivations. Use for new teaching notes."
---

Help the reader reconstruct the idea: what problem motivates it,
why its objects help, and how its essential relationships follow.

- Start from a concrete problem and the smallest example that preserves
  the difficult mechanism. Rebuild prerequisites where needed.
- Give each new object meaning and purpose before using its notation.
- Make the hardest conceptual step visible. Prefer annotated successive
  images showing what changes, or a simple interactive HTML demo when
  manipulating the objects reveals the mechanism. Connect the visuals
  to the algebra; choose another representation when a picture would mislead.
- Explain every essential transition. Keep the promised mechanism in the
  main explanation; citations and exercises cannot replace it.
- Distinguish examples from general arguments. Check assumptions,
  approximations, and cases that could expose a wrong interpretation.
- Use reader feedback to locate gaps and change the explanation.
  Correctness and approval alone do not establish comprehension.

Choose the structure, examples, tools, and pacing freely.
Follow AGENTS.md for sample feedback, publication, and verification.

Use the computer's tools when they clarify or check the idea:

- **Wolfram Language** (`wolframscript`, `math`, or `WolframKernel`) for exact
  symbolic algebra, calculus, difficult mathematical checks, and labeled plots.
- **GNU Octave** (`octave`) for MATLAB-like numerical linear algebra, simulation,
  parameter sweeps, and reproducible numerical figures.
- **Python through `uv`** for scripts, data, and plots when the needed environment
  is available; use Typst for the note, Node for JavaScript checks, and Chrome for
  interactive HTML inspection.


Topic: $ARGUMENTS
