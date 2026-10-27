# Landing page (`index.html`) specification

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
