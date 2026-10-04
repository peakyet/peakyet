---
name: teach-an-engineer
description: "Teaches engineering ideas through reconstructible visual explanations, sample feedback, and complete Typst/PDF notes. Use for /teach-an-engineer or new teaching notes in this knowledge base; not for ordinary prose-only answers."
---

# teach-an-engineer

Help the reader reconstruct an idea: what problem prompted it, why its objects are useful,
and how its essential formulas follow. Develop the explanation in the spirit of 3Blue1Brown's
lessons, using pictures and examples to make the reasoning accessible. A polished document,
a memorable metaphor, or correct numerical output does not establish understanding.

The reader is the repository owner. `AGENTS.md` takes precedence. Existing notes are revised
only when requested; preserve their format and the shared callouts' compatibility.

## Establish the goal and verify the mechanism

1. Use the request and available context to establish what the reader wants to reconstruct.
   Ask at most a couple of relevant questions when necessary. Familiar terminology is not
   evidence of a familiar mechanism. Rebuild a missing prerequisite where it is needed;
   do not conduct a prerequisite interview or require unaided discovery.
2. Privately work the essential derivation through before designing its story. Give each
   quantity a precise meaning, with assumptions and boundary or initial conditions. Check
   a small example and a case that could expose a wrong interpretation. For numerical
   work, retain the reproducing script. Source technical claims as needed using
   [sources.md](references/sources.md); do not replace an explanation with a citation.
3. Choose the smallest example that preserves the mechanism. A scalar example may establish
   meaning, but verify its extension to matrices or general objects: scalar commutativity,
   a special symmetry, or a convenient boundary must not hide the difficult step. Mark
   approximations and scope limits honestly.
4. Sketch a connected progression around one central question. Identify the hardest bridge:
   the step where the reader must adopt a new representation, understand a construction,
   or connect the picture to the essential algebra. Plan how to explain that step before
   committing to a full note. Craft guidance: [teaching-patterns.md](references/teaching-patterns.md).

## Explain the hardest bridge first

Produce a short, complete visual sample of that bridge, including the local prerequisites
that make it understandable. Give answers and reasoning directly. Use successive annotated
pictures when they carry the argument; a static result diagram with a persuasive caption
is insufficient. See [figures.md](references/figures.md).

Present the rendered sample and invite feedback on where the thread is lost. Revise the
explanation there: a simpler representation, a missing intermediate step, or a better example
may help more than additional prose. Do not merely repeat the same explanation more slowly.
When the reader accepts the approach, proceed to the complete note; there is no separate
outline-approval ceremony or quiz gate. A request to write the full note directly overrides
this sample discussion. If feedback is unavailable, deliver a review draft and report
comprehension as unassessed; silence is not approval.

The sample is a draft, not a partially published lesson: keep it in review artifacts rather
than replacing an existing note or adding a landing-page card. Follow the environment's
artifact location; in this workspace use `.amp/in/artifacts/` with `/.amp/in/` locally excluded.

## Write the complete explanation

Use [note.typ](typst-template/note.typ) and the [template router](templates/README.md).
Sections address obstacles to understanding. There is no required section count, beat sequence,
opening callout, failed attempt, escalation, or closing tease.

- Start from an understandable problem. A plausible attempt can expose why a new construction
  helps, but do not manufacture a failure or claim the construction is the only possible choice.
- Give objects meaning before relying on them. Explain what a symbol represents, what operation
  it allows, and why it is useful here. Naming a matrix in one sentence is not explaining it.
- Keep essential derivations in the main explanation. Explain each substantive transition in
  the picture and algebra, at a pace suited to this reader. Do not substitute a citation,
  "extra bookkeeping", or an exercise for a central step. Adjacent equations alone do not
  explain their relationship. Rebuild prerequisites when that relationship needs them.
- Preserve the example across views where useful. If the example or representation changes,
  explicitly connect the old and new objects. Distinguish evidence on an example from a
  general argument; verify the promoted argument independently.
- Put secondary proofs and implementation details in optional extensions. Declare a prerequisite
  result taken as given, but never move the promised mechanism outside the explanation.
- Write conversationally and precisely. Spread new notation across the reasoning rather than
  collecting definitions up front. A `#hook` is optional. A `#check` exercise is optional and
  always has its answer visibly below it. Nothing in a published note is hidden or gated.

## Review evidence and deliver

Keep a small private review record: assumed starting knowledge, essential transitions, and the
actual passage or figure explaining each transition. Read the draft through that chain. Check
the mathematics, boundary cases, diagram coordinates, and exact displayed runnable snippets;
a separate correct script cannot validate a broken code listing. Use the general review patterns
in [teaching-patterns.md](references/teaching-patterns.md) to check that the review catches gaps.

Compile warning-free, inspect rendered pages, and perform the applicable numerical, citation,
link, and demo checks in [repo-notes.md](references/repo-notes.md). Checks establish artifact
quality, not learner comprehension. Report the reader's feedback without claiming mastery
from approval; if none has arrived, comprehension remains unassessed.

Fill [templates/summary.md](templates/summary.md) with scope, explanation progression, source
support, checks, and the next revision. It is a production log, not a learner dossier; keep
private review and conversational details out of public notes and summaries. Add a landing-page
card only for a complete published note, and deliver PDF page links. Apply later feedback in place.

Topic: $ARGUMENTS
