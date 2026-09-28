# FILL: Topic — teaching handoff

Keep this short. It is a handoff, not a transcript and not a prerequisite ledger.

**Stage:** FILL: question map / deepening / complete

**Artifact:** FILL: `<Category>/<slug>/<slug>.typ`, compiled to `<Category>/<slug>/<slug>.pdf`.
FILL: add `+ <slug>-demo.html` when the note has a sidecar demo, otherwise delete that clause.

## Audience

FILL: who this assumes — an engineer new to the topic, comfortable with basic algebra and
calculus — and anything calibrated differently during discussion.

## Route and assessment

| Section | PDF page | Deep question | Expected insight / assessment focus | Status |
|---|---|---|---|---|
| FILL: `<s1>` | FILL: 3 | FILL: the opening question | FILL: the answer the reader must demonstrate | FILL: question-ready / deepened / skipped / closed |
| FILL: `<s3>` | FILL: 5 | FILL: the next question | FILL: the answer the reader must demonstrate | FILL: question-ready / deepened / skipped / closed |

FILL: the running example in one sentence — the concrete objects every section returns to.

Keep expected insights here as teaching notes. Do not copy them into the question map.

The `PDF page` column is what the chat deep link is built from, so refresh it after every
compile with the `typst eval` command in [repo-notes.md](../references/repo-notes.md): it lists
one page per numbered heading in source order, so row N is `<sN>`. Page numbers move whenever
prose, an equation, or a figure is added, and a stale column sends the reader to the wrong page.

## Current discussion point

FILL: where the conversation stopped, and which section's page link and question to send next.

## Unresolved or research-needed claims

- FILL: `<sN>` — FILL: the exact claim, number, rate, attribution, or version that must be
  qualified or checked before it can be used to assess or deepen a response. Write "None" when
  there are none.

## Sources consulted

FILL: If none, write "None yet; the question map makes no external claims." Otherwise use one
row per source and group the claim families it grounds. Each consulted source also earns a
`refs.bib` entry, cited from the sentence in the note that uses it.

| Source and passage read | Grounds |
|---|---|
| FILL: Author, *Title*, section or pages read — plus DOI / versioned arXiv ID when available | FILL: the claim family or sections supported |

Do not log searches, rejected candidates, or routine metadata checks. Keep suggested further
reading separate and labelled as not consulted.

## Checks

- FILL: build — `typst compile --root .` exited 0 with no warnings; FILL: page count.
- FILL: structural — no `FILL:` slots, one `#question` per teaching section, note-relative asset
  paths only, section-to-page map refreshed and spot-checked against a page other than the first.
- FILL: answer-free — no intuition, takeaway, claim, worked solution, or conclusion in the note.
- FILL: rendered — rasterized pages inspected: equations, figures, and captions placed; nothing
  clipped or wider than the text column.
- FILL: demo — ceiling checks and a control-by-control smoke test, or "no demo".
- FILL: stage-specific — source passage, numeric script, changed page link, or changed
  landing-card link; write "not applicable" when the pass added none.
- FILL: checks that could not run, and why (for example, no browser available to render a demo).

## Notes

- FILL: any intentional deviation from `typst-template/note.typ`, the 'Ilm defaults, or the demo
  ceiling, and why the question map required it.
