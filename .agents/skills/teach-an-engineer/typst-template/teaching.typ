// Teaching vocabulary shared by every teach-an-engineer note.
//
// A note imports this file by its repository-absolute path, so the import line is
// identical at any folder depth and survives being copied out of `typst-template/`:
//
//   #import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question
//
// Because `/` is the project root, builds name the root explicitly and run from the
// repository root:
//
//   typst compile --root . <Category>/<slug>/<slug>.typ <Category>/<slug>/<slug>.pdf
//
// This file exports the preset, the one callout, and the three palette colors below.
// Everything else a note needs is plain Typst:
// `$ ... $` for math (no inner spaces inline, inner spaces to display it), `#figure`,
// `#table`, and `#image("assets/<name>.svg")`. Note-local paths resolve against the
// note, never with `../`, which would escape the project root.
//
// Nothing here prints an answer. While a question is still open, its expected insight lives in
// the note's `summary.md`, not in the document; once the reader closes that section, the note
// carries the answer beneath the question and may use the callouts below.

#import "@preview/ilm:2.1.1": *

// The note palette, shared so figures and tables match across the series: navy for the
// primary series, teal for the contrast series, gray for axes and annotations.
#let navy = rgb("#1f4e79")
#let teal = rgb("#0f766e")
#let gray = rgb("#5b564b")

// The 'Ilm template with this repository's defaults for a one-file teaching note.
//
// A note calls it as `#show: note-ilm.with(title: [...], authors: "Name", ...)`, and
// every 'Ilm option stays reachable that way; `typst-template/ilm/main.typ` documents
// them (cover page, preface, appendix, footer style, indices, paper size). Defaults
// chosen here: A4, no bibliography until the note owns a `refs.bib`, no index of
// figures/tables/listings, and an installed monospace font so the build is
// warning-free.
#let note-ilm(..args, body) = {
  // Journal-style paper and ink, echoing the repository's note palette.
  set text(size: 12pt)

  // Displayed equations are numbered, so a later section can point at one with
  // `#ref(<eq:name>)` -- the Typst successor to the old `.eq` block.
  set math.equation(numbering: "(1)")

  // Navy section headings; 'Ilm still prints the section name in the footer.
  show heading.where(level: 1): set text(fill: rgb("#1f4e79"))

  show: ilm.with(
    paper-size: "a4",
    bibliography: none,
    figure-index: (enabled: false),
    table-index: (enabled: false),
    listing-index: (enabled: false),
    raw-text: (font: ("DejaVu Sans Mono",), size: 9pt),
    ..args,
  )

  body
}

// The callout a teaching section opens with: one per teaching section, asking for a
// mechanism, prediction, reason, transfer, or failure mode rather than a definition.
// While its section is open, nothing else in the section answers it. Once the reader
// closes the section, the write-up follows below -- plain Typst, or an intuition/takeaway
// callout if the note defines one.
#let question(body) = block(
  inset: (x: 10pt, y: 8pt),
  stroke: (left: 3pt + rgb("#1f4e79")),
  fill: rgb("#f8fafc"),
  width: 100%,
)[*Question:* #body]
