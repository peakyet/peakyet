---
name: teach-an-engineer
description: "Teach an engineering topic through a section-by-section deep-question map in a one-page Typst note compiled to PDF. The note tests the reader's understanding without revealing the expected insight; deepen, research, or demonstrate only after the reader's answer requires it. Use for /teach-an-engineer, visual explanations, or requests to understand how something works in this knowledge base; not for ordinary prose-only answers."
---

# teach-an-engineer

**Questions drive the lesson, and the note is a question map, not an answer key: every teaching section poses one deep, insight-testing question with only the setup needed to attempt it. Ask one section at a time, wait for the reader's answer, and never place the expected answer, solution path, or conclusion in the document.**

Assume an engineer new to the topic but comfortable with basic algebra and calculus. Adapt without a prerequisite interview. `AGENTS.md` takes precedence over this skill and its references.

A note is Typst on the `ilm` template, compiled to the PDF the site serves. Do not write a new teaching page in HTML; the only hand-written HTML a note may gain is the simple demo sidecar described in [repo notes](references/repo-notes.md), and the landing page stays HTML.

## Pass 1: publish the question map

- Read `AGENTS.md` and the [template router](templates/README.md) first; read [repo notes](references/repo-notes.md) when filing and verifying.
- Copy [note.typ](typst-template/note.typ) to `<Category>/<slug>/<slug>.typ`. Read the copy once before filling it so you know which blocks exist; the shared partial, the `ilm` styling, the numbered-section contract, and the `#question` callout are fixed -- change content and uncommented optional blocks, never `teaching.typ` for one note's convenience.
- Compile with `typst compile --root . <Category>/<slug>/<slug>.typ <Category>/<slug>/<slug>.pdf` from the repository root and keep the build warning-free.
- Before teaching, write the shortest one-page note with one deep question per teaching section. Give the reader only the running example, facts, assumptions, definitions, and notation needed to attempt that question. Do not put the expected insight, explanation, solution, proof, method, result, conclusion, or leading hint in the document.
- Make each question test understanding rather than recall or recognition. Ask for a mechanism, prediction, reason, transfer to a changed case, or failure mode; a reader should need the key idea or deep insight to answer it. Avoid yes/no, definition-only, or questions already answered by the setup.
- Keep one running example. Let each question expose the next unresolved point in the chain, but do not display the answer that resolves the previous question. Setup may include approximate equations, objects, or a figure that presents the phenomenon to inspect; it must not state what the reader should conclude.
- Do not research, build demos, or verify before the reader attempts the question. No intuition, takeaway, claim, proof, method-summary, worked-result, or overall-conclusion block belongs in the page. The Sources section may say that no external sources have been consulted yet; it must not reveal an expected answer.
- File the `.typ`, the compiled `.pdf`, and the landing card immediately once the question map is usable. Fill [templates/summary.md](templates/summary.md) with the expected insight, likely misconception, assessment focus, unresolved claims, and route status for each question, plus the section-to-PDF-page map. These are teaching notes for the agent and must not be copied into the document.

## Ask and assess section by section

The PDF is visible immediately, but it tests understanding rather than explaining the answer. Teach one connected question at a time from its section; keep chat to a deep link, the exact question, and the smallest clarification needed to attempt it.

- Send the section's `<slug>.pdf#page=N` link from the handoff map, quote the question, then wait. Do not answer, hint, or expose the expected insight before the reader has attempted it.
- If the reader demonstrates the expected insight, mark the section `skipped` or `closed` and move on without research, source checking, demonstration, or verification.
- If the answer is partial, ask one narrower question about the missing distinction or give one hint. Deepen only if the reader still needs it.
- If the answer reveals a misconception or a wrong mechanism, use a counterexample, prediction, or targeted question to expose the conflict before explaining. Give the expected insight only after the reader has had a real attempt, unless they explicitly ask to skip the exercise.
- A request to explain, prove, source, illustrate, compute, or demonstrate deepens only the requested section and its immediate dependencies. Research and demos may be skipped entirely when the reader already has the idea.

## Research only what the response needs

- Keep the section question, expected insight, and the reader's attempt in view. Triage only the claim needed to assess the answer or prepare the smallest helpful follow-up; routine derivations, definitions, standard mathematical facts, and the reader's existing understanding need no external source.
- Use one authoritative source for an attributed, historical, quoted, or borrowed result, and read the passage that directly supports the claim. Add a second source only when credible sources conflict, priority is disputed, or the claim is unusually consequential or current.
- Use the `arxiv-mcp-server` and `paper-search-mcp` servers for scholarly discovery and metadata, not recalled citations. For software behavior, use official documentation. Follow [sources.md](references/sources.md) for retrieval, stopping, and attribution.
- Stop once the exact sentence or equation is supported. Do not read whole papers, chase citation chains, or require an original plus a survey unless lineage or priority is the teaching point. Record what the source grounds in `summary.md`, and add the note's `refs.bib` entry only for a claim the document itself makes; the expected answer stays out of the document either way.
- Metadata and abstracts may establish bibliographic facts or attribution, but not a detailed technical result. If support remains inadequate, qualify or remove the claim instead of searching indefinitely.

## Verify only what changed

- Verify in service of the assessment: routine mathematics by direct reasoning; an external claim against its targeted passage; a computed number with one reproducible script run, using a second method only if results disagree or the claim is fragile; and a demo with one smoke test.
- Every published revision passes the structural and rendering checks in [repo notes](references/repo-notes.md): a warning-free `typst compile`, no `FILL:` slots, one `#question` per teaching section, note-relative asset paths, and a refreshed section-to-PDF-page map whose pages are inspected as rendered images.
- Check that the document remains answer-free: no intuition, takeaway, claim, solution, worked result, or concluding statement that would let the reader bypass the deep question.
- A deepened section also runs only the checks relevant to what it added: the source passage, numeric script, demo, changed section page, or changed landing-card link. Do not repeat completed checks or re-verify a skipped section.
- Disclose checks that could not run -- in particular a demo that no browser here could render. Do not build new verification infrastructure for routine page work.

## Handoff and delivery

- File the note, its compiled PDF, and the card using the repo notes, updating an existing page in place and keeping its format: a Typst note stays Typst, a legacy HTML note keeps its renderer and class names.
- Keep `summary.md` short: stage, audience assumptions, question/expected-insight map with statuses and PDF page numbers, the demo path if any, current discussion point, running example, unresolved or research-needed claims, sources actually consulted, and checks actually performed.
- Deliver the question-map PDF link and the current question's page link plus its question text. Keep research downloads and inspection artifacts out of the repository.

Topic: $ARGUMENTS
