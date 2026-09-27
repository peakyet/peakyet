---
name: teach-an-engineer
description: "Teach an engineering topic through a section-by-section deep-question map in a one-page HTML note. The page tests the reader's understanding without revealing the expected insight; deepen, research, or demonstrate only after the reader's answer requires it. Use for /teach-an-engineer, visual explanations, or requests to understand how something works in this knowledge base; not for ordinary prose-only answers."
---

# teach-an-engineer

**Questions drive the lesson, and the HTML is a question map, not an answer key: every teaching section poses one deep, insight-testing question with only the setup needed to attempt it. Ask one section at a time, wait for the reader's answer, and never place the expected answer, solution path, or conclusion in the page.**

Assume an engineer new to the topic but comfortable with basic algebra and calculus. Adapt without a prerequisite interview. `AGENTS.md` takes precedence over this skill and its references.

## Pass 1: publish the question map

- Read `AGENTS.md` and the [template router](templates/README.md) first; read [repo notes](references/repo-notes.md) when filing and verifying.
- Copy [note.html](templates/note.html) to `<Category>/<slug>/<slug>.html`. Read it once before filling so you know which classes and blocks exist; its typography, math renderer, navigation, responsive layout, and content vocabulary are fixed — change content and uncommented optional blocks, never the stylesheet or the scroll-spy script.
- Before teaching, write the shortest one-page note with one deep question per teaching section. Give the reader only the running example, facts, assumptions, definitions, and notation needed to attempt that question. Do not put the expected insight, explanation, solution, proof, method, result, conclusion, or leading hint in the HTML.
- Make each question test understanding rather than recall or recognition. Ask for a mechanism, prediction, reason, transfer to a changed case, or failure mode; a reader should need the key idea or deep insight to answer it. Avoid yes/no, definition-only, or questions already answered by the setup.
- Keep one running example. Let each question expose the next unresolved point in the chain, but do not display the answer that resolves the previous question. Setup may include approximate equations, objects, or a figure that presents the phenomenon to inspect; it must not state what the reader should conclude.
- Do not research, build demos, or verify before the reader attempts the question. No `Intuition:`, `Takeaway:`, `Claim:`, proof, method-summary, worked-result, or overall-conclusion blocks belong in the page. The Sources section may say that no external sources have been consulted yet; it must not reveal an expected answer.
- File the HTML and add the landing card immediately once the question map is usable. Fill [templates/summary.md](templates/summary.md) with the expected insight, likely misconception, assessment focus, unresolved claims, and route status for each question. These are teaching notes for the agent and must not be copied into the HTML.

## Ask and assess section by section

The page is visible immediately, but it tests understanding rather than explaining the answer. Teach one connected question at a time from its section anchor; keep chat to a deep link, the exact question, and the smallest clarification needed to attempt it.

- Send the section link and its question, then wait. Do not answer, hint, or expose the expected insight before the reader has attempted it.
- If the reader demonstrates the expected insight, mark the section `skipped` or `closed` and move on without research, source checking, demonstration, or verification.
- If the answer is partial, ask one narrower question about the missing distinction or give one hint. Deepen only if the reader still needs it.
- If the answer reveals a misconception or a wrong mechanism, use a counterexample, prediction, or targeted question to expose the conflict before explaining. Give the expected insight only after the reader has had a real attempt, unless they explicitly ask to skip the exercise.
- A request to explain, prove, source, illustrate, compute, or demonstrate deepens only the requested section and its immediate dependencies. Research and demos may be skipped entirely when the reader already has the idea.

## Research only what the response needs

- Keep the section question, expected insight, and the reader's attempt in view. Triage only the claim needed to assess the answer or prepare the smallest helpful follow-up; routine derivations, definitions, standard mathematical facts, and the reader's existing understanding need no external source.
- Use one authoritative source for an attributed, historical, quoted, or borrowed result, and read the passage that directly supports the claim. Add a second source only when credible sources conflict, priority is disputed, or the claim is unusually consequential or current.
- Use the `arxiv-mcp-server` and `paper-search-mcp` servers for scholarly discovery and metadata, not recalled citations. For software behavior, use official documentation. Follow [sources.md](references/sources.md) for retrieval, stopping, and attribution.
- Stop once the exact sentence or equation is supported. Do not read whole papers, chase citation chains, or require an original plus a survey unless lineage or priority is the teaching point. Record what the source grounds in `summary.md`; do not paste the expected answer into the HTML.
- Metadata and abstracts may establish bibliographic facts or attribution, but not a detailed technical result. If support remains inadequate, qualify or remove the claim instead of searching indefinitely.

## Verify only what changed

- Verify in service of the assessment: routine mathematics by direct reasoning; an external claim against its targeted passage; a computed number with one reproducible script run, using a second method only if results disagree or the claim is fragile; and an interactive addition with one smoke test.
- Every published revision passes the structural and rendering checks in [repo notes](references/repo-notes.md): no `FILL:` slots, headings and TOC anchors agree, asset paths resolve, and desktop and narrow views render without clipping or overlap.
- Check that the page remains answer-free: no `Intuition:`, `Takeaway:`, `Claim:`, solution, worked result, or concluding statement that would let the reader bypass the deep question.
- A deepened section also runs only the checks relevant to what it added: the source passage, numeric script, demo, changed anchor, or changed landing-card link. Do not repeat completed checks or re-verify a skipped section.
- Disclose checks that could not run. Do not build new verification infrastructure for routine page work.

## Handoff and delivery

- File the page and card using the repo notes, updating an existing page in place and keeping its renderer and class names.
- Keep `summary.md` short: stage, audience assumptions, question/expected-insight map and statuses, current discussion point, running example, unresolved or research-needed claims, sources actually consulted, and checks actually performed.
- Deliver the question-map link and the current question-section link. Keep research downloads and inspection artifacts out of the repository.

Topic: $ARGUMENTS
