# AGENTS

This is a GitHub Pages site serving a personal **math knowledge base**. It is hand-written,
static content with one exception: a new teaching note is written in Typst and compiled once with
the `typst` CLI, because GitHub Pages runs no build step of its own. There is no framework and no
shared stylesheet. Network access is assumed, so pages may load external CDN assets or external
figures.

## Layout

- `index.html` — the landing page / front door. Lists and links to every note.
- `<Category>/<topic-slug>/` — one folder per note, so it can bundle figures alongside the prose.
  The top-level `Category` is the field the note belongs to: `Algebra`, `Control`, `Optimization`,
  `Robotics`, `Mathematics`, `AI-ML`, or `Tools`.
- `<Category>/<topic-slug>/<topic-slug>.typ` and `<topic-slug>.pdf` — a new note: Typst source plus
  the compiled PDF the site serves. `refs.bib` and `assets/` join them once the note cites a source
  or includes an exported figure, and a `<topic-slug>-demo.html` sidecar is allowed only under the
  simplicity ceiling in the skill.
- `<Category>/<topic-slug>/<topic-slug>.html` — the repository's existing notes, hand-written HTML.
  They stay as they are; new notes are not written this way.
- `LICENSE` — the repository license.

When adding a note, create it under the matching category folder (its own topic subfolder), then
add a card for it on the landing page so it stays discoverable.

## Landing page (`index.html`)

The landing page is a modern, UI-style page and **does not need to follow any rule used by the
note pages** — this exemption is intentional and must be kept.

Note cards are filtered client-side by a search box and category chips. When you add a note,
add a matching `<a class="card" href="<Category>/...">` to `#grid` and set:

- `data-category` — one or more space-separated classes chosen from `algebra`, `control`,
  `optimization`, `robotics`, `math`, `ai`, `tools`. The filter matches *any* of them, so a note
  can appear under several field chips (e.g. an ARE solver can be `control algebra`). The card is
  counted in every class it lists in the Fields section.
- `data-field` — a human-readable field label shown as the card footer and counted in the hero.
- `data-tags` — a space-separated list of searchable tags, also rendered as pills on the card.
  Cover field, subtopic, method, and relevant tools (e.g. `control riccati lqr schur
  numerical-methods`). The search box matches the title, description, and these tags, and a
  multi-word query must match every token.

Keep every `href` pointing at a real note file — a compiled `.pdf` for a new note, a `.html` for an
existing one — so the grid never dangles. Publish one card per topic, and no card for a `summary.md`
or a demo. The search, filter, reading-time estimate, and stat counts are all driven by that grid, so
keep the structure (`.card`, `data-category`, `data-field`) intact.

The hero stats (`#stat-notes`, `#stat-fields`) and the per-field counts in the section
(`#cnt-algebra`, `#cnt-control`, `#cnt-optimization`, `#cnt-robotics`, `#cnt-math`, `#cnt-ai`,
`#cnt-tools`) are all computed from `.card` elements. Placeholder "coming soon" cards should use
class `soon` and be excluded from those counts.

## Note pages

New teaching notes are Typst, built from the skill's `typst-template/note.typ` on the `ilm` package
template. A new note helps the reader reconstruct an idea: what problem prompted it, why its
objects are useful, and how its essential formulas follow. Use a connected progression around a
central question, with successive annotated pictures where they explain the mechanism. Sections
have no prescribed count, beat sequence, or mandatory callout. A `#hook` is optional; a `#check`
exercise is optional and always has its answer visibly below it. Numbered display equations, an
'Ilm cover page, a contents page, and a page-numbered footer are shared with the rest of the site.
Teaching deep links are `<topic-slug>.pdf#page=N`.

Before producing the full note, explain its hardest conceptual bridge in a short visual sample
and revise from the reader's feedback. This is feedback on the explanation, not a learner test or
a separate outline-approval stage. If feedback is unavailable, retain the sample as a review draft
and say that comprehension is unassessed; do not infer approval from silence. A request to write
the full note directly overrides this discussion stage. Published notes contain complete
explanations and visible answers; publication never depends on passing a quiz. Explain directly
when help is requested, and revise published notes whenever the reader asks.

This skill does not handle any existing question-led notes; they are older documents, edited only
if a user asks for a change (their `#question` callout still renders because the shared
`teaching.typ` keeps the function for backward compatibility).

Build from the repository root with `typst compile --root .` and ship a warning-free build. Do not
write a new teaching page in HTML; a simple interactive demo is the only sanctioned exception.

The existing HTML notes follow a consistent academic style. Match them when editing them, unless
there's a reason to change it for the whole series:

- Font: a serif stack such as `"Source Serif Pro", Georgia, "Times New Roman", serif`.
- Palette: journal-style white background `#ffffff`, navy accent `#1f4e79`. Keep the serif/paper look
  distinct from the landing page.
- Math: use the **same** renderer already used in the note being edited — KaTeX inlined or the
  MathJax CDN. Do not mix or drop it. If using MathJax, keep the `window.MathJax` config.
- Displayed equations live in `.eq`; inline math uses the active renderer's syntax.
- Short side notes use `.callout`, with `.takeaway` (teal) and `.intuition` (blue) variants.
- Figures live inside a `.figure` block (with a `.figure-caption`). Use inline SVG for diagrams
  or an external asset when that is clearer.
- A sticky table of contents uses `.toc`, with active-section highlighting.
- Use `hr` as section dividers; keep the page responsive below ~700px.

Update one of those pages in place from the file itself; there is no HTML template file to copy any
more. Long-form notes and old decks keep their current renderer and class names, and are never
converted to Typst just to unify the series.

## Content principles

- Motivation first, then the reasoning, then the details.
- Intuition before formalism: build the mental model before the equations.
- Each note stands alone but links to related notes when useful.

## Housekeeping

- Keep the repo statically servable by GitHub Pages. Commit source: HTML, Typst `.typ`,
  `summary.md`, `refs.bib`, figures, demos, and the small scripts that reproduce on-page numbers.
- Commit a note's compiled `.pdf` too. It is the artifact readers open, since Pages cannot run
  Typst; it is not a disposable build dump. Keep out caches, downloaded papers, and generated
  site artifacts (`.gitignore` already covers `_site/`, `/vendor`, `Gemfile.lock`).
- The landing page is exempt from the note rules above; everything else should stay coherent with
  the existing patterns.

## Agent skills

- `.agents/skills/` holds repo-local skills, checked in so they are available to any agent working
  in this repository. `teach-an-engineer` writes one note at a time: it establishes the learning
  goal, verifies the mechanism, tests a visual explanation of the hardest bridge with the reader,
  then writes and verifies the complete note. Its checks distinguish mathematical and visual
  correctness from whether the explanation works for this reader.
  It encodes the layout and style rules above. It handles only new notes; the already-published
  question-led notes under `Control/` are not its concern (their `#question` callout is kept in
  the shared `teaching.typ` purely so they still recompile).
  Its `references/repo-notes.md` is the concrete checklist for where files go, how the card is
  registered, the simplicity ceiling for an interactive demo, and the commands that verify a build.
  Its `typst-template/note.typ` is the default page shell and `typst-template/teaching.typ` the
  shared partial (exporting `note-ilm`, the `hook`/`check`/`question` callouts, and the palette),
  described by `templates/README.md`; `typst-template/ilm/` is the vendored template whose own
  document lists the available options.
  Its research step cites papers through the `arxiv-mcp-server` and `paper-search-mcp` MCP servers
  rather than from memory -- see its `references/sources.md` -- records what each source grounds in
  the note's `summary.md`, and keeps downloaded PDFs out of the repo.
- If the rules in this file and in that skill disagree, this file wins; update the skill rather than
  working around it.

## Coding Environment

- The python virtual environment is available by using 'uv'. You don't need to write any code by yourself if there exists some package. The needed package can be install in virtual environment after asking user and obtaining the approvement.
