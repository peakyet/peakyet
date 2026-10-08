// Copy to <Category>/<slug>/<slug>.typ; replace FILL: slots and remove unused blocks.
// Build from the repository root with typst compile --root . <source> <output>.

#import "/.agents/skills/teaching-complex-ideas/typst-template/teaching.typ": note-ilm, hook, check, navy, teal, gray

#show: note-ilm.with(
  title: [FILL: Note title],
  authors: "Amp", // Name the producing tool.
  abstract: [FILL: the central question, starting point, and scope.],
  // bibliography: bibliography("refs.bib"),
)

= FILL: Section title <s1>

FILL: the explanation. Add sections and figures as the idea needs.

// Optional callouts; exercises include visible answers below them.
// #hook[FILL: a concrete question.]
// #check[FILL: an exercise.]
// FILL: answer and reasoning.

= Sources and further reading

FILL: sources consulted and what they support, or state that none were consulted.
Label unconsulted suggestions separately.
