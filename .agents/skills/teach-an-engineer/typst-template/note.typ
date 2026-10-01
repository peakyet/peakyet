// note.typ -- the default question-map shell for a teach-an-engineer note.
//
// Copy this file to <Category>/<slug>/<slug>.typ and fill it in place; do not redesign
// it. The 'Ilm template, the shared partial, and the two lines that wire them together
// are fixed, so the import below needs no editing after the copy: the note sits exactly
// two folders deep, and the repository-absolute path is what makes that true.
//
//   cp .agents/skills/teach-an-engineer/typst-template/note.typ <Category>/<slug>/<slug>.typ
//   typst compile --root . <Category>/<slug>/<slug>.typ <Category>/<slug>/<slug>.pdf
//
// Rules for filling it:
//   - Replace every visible FILL: and act on every commented FILL: instruction.
//   - One `= Title <sN>` teaching section per deep question, labelled s1, s2, ... in
//     order. Keep headings plain text: the contents page and the section-to-PDF-page map
//     both read them.
//   - Each section opens with exactly one #question[...] and the prose under it supplies
//     only the running example, facts, assumptions, definitions, and notation needed to
//     attempt that question.
//   - Never write the expected insight, explanation, solution, proof, method list,
//     worked result, or conclusion in this file. Those go to summary.md.
//   - Inline math is `$x_k$` with no inner spaces; a displayed equation is
//     `$ ... $` with inner spaces and gets a number. Avoid `\[ ... \]`: it is verbatim
//     math, and grouping like `x_{k+1}` does not parse there.
//   - Note-local assets are relative to the note: `assets/<name>.svg`, `refs.bib`.
//     Never `../`.
//
// This shell compiles as shipped: everything that needs a note-local file is commented,
// so `typst compile --root . .agents/skills/teach-an-engineer/typst-template/note.typ
// /tmp/shell.pdf` is a usable smoke test of the partial and the template.

// `navy`, `teal`, and `gray` are the shared figure palette; drop them from the import if
// the note ends up with no drawing or table of its own.
#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

// One deep question per teaching section; the page tests understanding, it does not
// explain. `date` defaults to today and `paper-size` to A4 -- pass another 'Ilm option
// here only when the note needs it (see typst-template/ilm/main.typ for the list).
#show: note-ilm.with(
  title: [FILL: Note title],
  // The author is the agent that wrote the note, never the repository owner. Set this
  // to the name of the tool driving the session (Amp, Codex CLI, Claude Code, ...);
  // change it when another agent writes a note.
  authors: "Amp",
  abstract: [
    FILL: one line naming the problem and the chain of questions the note will ask.
    A preview of the questions, never an answer to any of them.
  ],
  // Uncomment once this note owns a refs.bib beside it, then cite with `@key`:
  // bibliography: bibliography("refs.bib"),
)

// ============================== 1. QUESTION ===============================

= FILL: the opening deep question <s1>

#question[FILL: ask for the mechanism, prediction, or reason that requires the key
  insight. Do not answer it here, and do not hint at the shape of the answer.]

FILL: establish the running example with the facts, assumptions, definitions, and
notation the reader needs to attempt the question. Do not state the expected answer.

// A displayed equation may state the setup or the question. Label it when a later
// section needs to point at it, then write #ref(<eq:setup>).
//
// $ x_(k+1) = "FILL"(x_k) $ <eq:setup>

// A figure exposes a phenomenon, object, or contrast to interpret. The caption says what to
// inspect, not what conclusion to draw. Prefer Typst's own vector drawing so labels stay
// typeset; references/figures.md has a verified pattern with axes and two series.
//
// #figure(
//   caption: [FILL: what to inspect or predict here.],
//   image("assets/<name>.svg", width: 100%),
// )

// If this section needs a simple sidecar demo, name its path in monospace; the PDF
// cannot link it reliably. Ceiling and checks: references/repo-notes.md.
//
// Open #raw("<slug>-demo.html") beside this note to move FILL and watch the same
// quantity as it changes.

// =============================== 2. NEED ==================================

= FILL: why does the familiar approach fail? <s2>

#question[FILL: ask the reader to identify the missing property, ambiguity, or failure
  mode. Do not reveal it.]

FILL: set up the familiar approach far enough that the reader can test it. Do not work it
through to the answer.

// =============================== 3. IDEA ==================================

= FILL: what must be supplied, and why? <s3>

#question[FILL: ask what object, relationship, or construction supplies the missing
  property. Do not name the answer.]

FILL: define only the notation and context needed to state the question. The expected
insight belongs in summary.md, not in this document.

// =============================== 4. WHY ===================================

= FILL: why should the idea work beyond one case? <s4>

#question[FILL: ask for the reason, invariant, or mechanism that would justify the idea.
  Do not provide the argument.]

FILL: give one revealing case or a set of assumptions the reader can reason about. Do not
supply the proof, claim, or conclusion.

// ============================== 5. METHOD =================================

= FILL: what does the method produce? <s5>

#question[FILL: ask what procedure follows and what the reader predicts it produces on
  the running example. Do not list the procedure or its result.]

FILL: specify the inputs, outputs, and stopping question only. Do not provide steps,
computed values, or a worked result.

// ============================== 6. LIMITS =================================

= FILL: what changes when one condition changes? <s6>

#question[FILL: change exactly one assumption or input and ask what the reader predicts,
  and why. Do not state the result.]

FILL: define the changed condition and the observations available to the reader. Do not
state where the guarantee ends or which alternative wins.

// ============================== 7. SOURCES ================================

= Sources and further reading

// Truthful for the current stage. Before any research, say so; after research, list only
// what was actually consulted, and never use a citation to disclose an expected answer.

FILL: no external sources have been consulted yet; this note makes no external claims.

// Suggested further reading stays separate and labelled as not consulted.
//
// Unconsulted suggestions: FILL: author, *title*, link.
