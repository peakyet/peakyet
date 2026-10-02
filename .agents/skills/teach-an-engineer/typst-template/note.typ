// note.typ -- the default shell for a teach-an-engineer note.
//
// Copy to <Category>/<slug>/<slug>.typ. Teaching behavior: ../SKILL.md.
// Filling and math syntax: ../templates/README.md. Checks: ../references/repo-notes.md.
//
//   cp .agents/skills/teach-an-engineer/typst-template/note.typ <Category>/<slug>/<slug>.typ
//   typst compile --root . <Category>/<slug>/<slug>.typ <Category>/<slug>/<slug>.pdf
//
// Replace every FILL: and delete unused optional blocks. Keep only the questions needed,
// with ordered <sN> labels and one #question per section. Add the answer on closing beneath
// the question, then compile and refresh the handoff's page map. Preserve the import/preset.
// This shell compiles as shipped; note-local assets remain commented until supplied.

// `navy`, `teal`, and `gray` are the shared figure palette; drop them from the import if
// the note ends up with no drawing or table of its own.
#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ": note-ilm, question, navy, teal, gray

// `date` defaults to today and `paper-size` to A4. See ilm/main.typ for options.
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

// On closing, add the explanation, derivation, and worked result beneath the question,
// preserving the visual setup and definitions in a readable order.

// Lead with the visual. A figure exposes a phenomenon, object, or contrast to interpret; the
// caption says what to inspect, not what conclusion to draw. Prefer Typst's own vector drawing so
// labels stay typeset; references/figures.md has a verified pattern with axes and two series.
//
// #figure(
//   caption: [FILL: what to inspect or predict here.],
//   image("assets/<name>.svg", width: 100%),
// )

// If the question only becomes attemptable by moving a parameter, name the sidecar demo's path in
// monospace -- the PDF cannot link it reliably. File the demo with this question map, not later.
// Ceiling and checks: references/repo-notes.md.
//
// Open #raw("<slug>-demo.html") beside this note to move FILL and watch the same
// quantity as it changes.

FILL: keep prose to what the visual cannot say -- the running example, facts, assumptions,
definitions, and notation the reader needs to attempt the question. Do not state the expected
answer.

// A displayed equation may state the setup or the question. Label it when a later
// section needs to point at it, then write #ref(<eq:setup>).
//
// $ x_(k+1) = "FILL"(x_k) $ <eq:setup>

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

#question[FILL: ask what procedure follows from the ideas already taught, or what the
  reader predicts it produces on the running example.]

FILL: specify inputs, outputs, and prerequisite facts needed to attempt the question.
Keep this section's target insight out until it closes.

// ============================== 6. LIMITS =================================

= FILL: what changes when one condition changes? <s6>

#question[FILL: change exactly one assumption or input and ask what the reader predicts,
  and why. Do not state the result.]

FILL: define the changed condition and the observations available to the reader. Do not
state where the guarantee ends or which alternative wins.

// ============================== 7. SOURCES ================================

= Sources and further reading

// Truthful for the current stage. Before any research, say so; once a section is written up and
// cites a source, list only what was actually consulted. A citation in a still-open section must
// not disclose that section's expected answer.

FILL: list sources used for claims in the note, or state truthfully that none were consulted.
Sources used only to check the grading guide are recorded in summary.md until their claims appear here.

// Suggested further reading stays separate and labelled as not consulted.
//
// Unconsulted suggestions: FILL: author, *title*, link.
