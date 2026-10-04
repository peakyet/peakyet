// Minimal layout shell, not a prescribed explanation sequence.
// Copy to <Category>/<slug>/<slug>.typ after the hardest-bridge sample discussion.
// Workflow: ../SKILL.md. Syntax: ../templates/README.md.
// Verify from the repository root with typst compile --root . <source> <output>.
// Replace all FILL: slots, including comments, and remove unused optional blocks.

#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, hook, check, navy, teal, gray

#show: note-ilm.with(
  title: [FILL: Note title],
  // Name the producing tool, never the repository owner.
  authors: "Amp",
  abstract: [
    FILL: the central question, starting point, and what this explanation will make
    reconstructible. State scope plainly; avoid a collection of unexplained technical names.
  ],
  // Uncomment only when the note owns refs.bib and cite supported claims with @key:
  // bibliography: bibliography("refs.bib"),
)

= FILL: the problem we want to understand <s1>

FILL: establish the problem and starting assumptions using the smallest faithful example.
Show the objects and operations the reader needs to understand before attaching new notation.

// Add successive annotated pictures when they carry the reasoning. Keep axes and labels
// consistent; mark what changes and connect it to the calculation. See references/figures.md.
// #figure(
//   caption: [FILL: the operation and relationship visible in these panels],
//   image("assets/<name>.svg", width: 100%),
// )

= FILL: the connection that makes the mechanism work <s2>

FILL: explain the representation or construction, its meaning on the example, and the
essential derivation. Connect each substantive algebraic step to the relationship being used.
Make the transition from an example to a general argument explicit and state its conditions.

// Add, remove, or expand sections as the explanation needs. Use <s1>, <s2>, ... in order.
// There is no fixed section count, beat sequence, per-section callout, or forced suspense.
// Secondary proofs and implementation details may follow as optional extensions.
// Optional callouts; delete if unused. A published exercise always includes its answer.
// #hook[FILL: a concrete question, when a callout helps the reader.]
// #check[FILL: an optional changed case.]
// FILL: the exercise's visible explanation and answer.

= Sources and further reading

FILL: sources actually consulted and what they support, or state that none were consulted.
Do not cite from memory. Label unconsulted suggestions separately.
