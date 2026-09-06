# AGENTS

This is a GitHub Pages site serving a personal **math knowledge base**. It is hand-written,
static HTML (no framework, no build step). Each page is self-contained and carries its own
CSS in `<head>`; there is no shared stylesheet or build pipeline.

## Layout

- `index.html` — the landing page / front door. Lists and links to every note.
- `<Category>/<topic-slug>/<topic-slug>.html` — one folder (and one file) per note. A note is its
  own folder so it can bundle figures alongside the prose. The top-level `Category` is the field
  the note belongs to: `Algebra`, `Control`, `Optimization`, `Robotics`, `Mathematics`,
  `AI-ML`, or `Tools`.
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
  Cover field, subtopic, method, and relevant tools (e.g. `control riccati lqr schur qz
  numerical-methods`). The search box matches the title, description, and these tags, and a
  multi-word query must match every token.

Keep every `href` pointing at a real note file so the grid never dangles. The search, filter,
reading-time estimate, and stat counts are all driven by that grid, so keep the structure
(`.card`, `data-category`, `data-field`) intact.

The hero stats (`#stat-notes`, `#stat-fields`) and the per-field counts in the section
(`#cnt-algebra`, `#cnt-control`, `#cnt-optimization`, `#cnt-robotics`, `#cnt-math`, `#cnt-ai`,
`#cnt-tools`) are all computed from `.card` elements. Placeholder "coming soon" cards should use
class `soon` and be excluded from those counts.

## Note pages

Notes follow a consistent academic style. Match the existing notes unless there's a reason not
to change it for the whole series:

- Font: a serif stack such as `"Source Serif Pro", Georgia, "Times New Roman", serif`.
- Palette: paper background `#fdfcf8`, amber/gold accent `#d4a72c`. Keep the serif/paper look
  distinct from the landing page.
- Math: use the **same** renderer already used in the note being edited — KaTeX inlined or the
  MathJax CDN. Do not mix or drop it. If using MathJax, keep the `window.MathJax` config.
- Displayed equations live in `.eq`; inline math uses the active renderer's syntax.
- Short side notes use `.callout`, with `.takeaway` (green) and `.intuition` (blue) variants.
- Figures are inline SVG inside a `.figure` block (with a `.figure-caption`). Keep diagrams
  self-contained SVG, not external images.
- A sticky table of contents uses `.toc`, with active-section highlighting.
- Use `hr` as section dividers; keep the page responsive below ~700px.

## Content principles

- Motivation first, then the reasoning, then the details.
- Intuition before formalism: build the mental model before the equations.
- Each note stands alone but links to related notes when useful.

## Housekeeping

- Keep the repo statically servable by GitHub Pages. Commit only source HTML; generated/site
  artifacts (`.gitignore` already covers `_site/`, `/vendor`, `Gemfile.lock`) should not be added.
- The landing page is exempt from the note-page rules; everything else should stay coherent with
  the existing patterns above.
