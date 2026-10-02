---
name: teach-an-engineer
description: "Teaches engineering topics through guided questions and visual examples, recording explanations in a Typst/PDF note as sections close. Use for /teach-an-engineer or interactive teaching in this knowledge base; not for ordinary prose-only answers."
---

# teach-an-engineer

Prepare → ask → assess → help → check understanding when needed → write up → continue.

Assume an engineer new to the topic, comfortable with basic algebra and calculus. Adapt from their
responses without a prerequisite interview. `AGENTS.md` takes precedence.

## Note contract

Publish one note with compact question sections, then add explanations as it is taught. An **open**
section contains its question and only the example, assumptions, definitions, notation, and visual
setup needed to attempt it; its expected answer stays in `summary.md`. A **closed** section keeps
the question and gains the explanation beneath it. Close when the reader demonstrates the insight
or requests an explanation or skips the exercise. Hints and prerequisite help may be given in chat
while a section is open.

New notes use [note.typ](typst-template/note.typ) and compile to PDF; existing HTML notes keep their
format and renderer. Preserve the shared styling. A simple HTML demo sidecar is allowed under the
[repo notes](references/repo-notes.md) ceiling. Prefer a figure or table for geometric, structural,
or comparative ideas; use prose for assumptions and what the visual cannot convey.

## Prepare the question map

1. Read the [template router](templates/README.md) for a new note, or read the existing note in place.
   Keep one running example and a connected chain of questions. Ask for a mechanism, prediction
   with a reason, transfer, or failure mode rather than a definition or yes/no answer.
2. Make every question attemptable with the stated background. Supply unfamiliar prerequisite
   facts without giving away the target insight. Build the visual setup and any essential demo now;
   keep captions and readouts consistent with the note contract.
3. Check the setup and grading guide before teaching: reason through the answer, check any computed
   numbers, and consult a source if an external claim or uncertainty requires it. Avoid a broad
   literature pass. Use [sources.md](references/sources.md) for retrieval and attribution.
4. Compile and inspect the map using the repo checks, then file the source, PDF, and one landing
   card pointing at the real artifact. Fill [summary.md](templates/summary.md) with the question,
   expected insight, likely misconception, and section-to-page map. The cover and contents are
   additional pages; there is no one-page limit on the note.

## Teach one section at a time

Send its `<slug>.pdf#page=N` link (or the existing HTML anchor), quote the question, link any demo,
and wait. Keep each teaching turn focused on the current gap; use the note for longer derivations.

- **Correct reasoning:** accept equivalent explanations, identify what the reader got right, and
  close. Do not demand another demonstration when their answer already shows the mechanism.
- **Partial answer:** acknowledge the correct part, then ask one narrower question or give a hint
  about the missing distinction.
- **Misconception:** use a small counterexample or prediction to expose the faulty assumption,
  then help repair it. Do not prolong the puzzle after the conflict is clear.
- **“I don't know how to start”:** treat this as diagnostic evidence. Supply the missing concept
  or a small worked example, then ask the reader to complete or adapt it. Increase help if they
  remain stuck; unaided invention is not a requirement.
- **“Explain,” “show me how,” or “skip”:** explain directly and close the exercise. Record
  `explained` separately from `demonstrated`; receiving an answer is not evidence of understanding.

After help, when understanding remains uncertain, offer one short changed-case prediction or
completion problem. Do not make it a gate for a reader who chose to skip. Later in the lesson,
occasionally revisit an earlier idea without the answer visible; avoid testing every section again.
Record useful evidence or an unresolved gap, not a transcript. See
[teaching-patterns.md](references/teaching-patterns.md) for examples and pedagogical grounding.

## Write up and deliver

On closing, add the mechanism, smallest checkable derivation, worked result, and any correction
actually reached. Cite external claims where used. Recompile Typst notes and refresh the page map;
update legacy HTML in place. Update the handoff's learning evidence and write-up status separately.

Verify changed content before publishing: structural checks, warning-free compilation, rendered
pages, quoted numbers and sources, changed links, and changed demo behavior as applicable. Follow
the repo notes for commands; do not repeat unaffected checks or build new verification machinery.
Check that open sections still satisfy the note contract, and disclose checks that could not run.

Deliver the current section link and question, or its explanation link when closed. Keep the
compiled PDF with its source, and keep research downloads and inspection artifacts out of commits.

Topic: $ARGUMENTS
