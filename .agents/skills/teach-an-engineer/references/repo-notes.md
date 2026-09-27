# Repo notes

How a `teach-an-engineer` artifact lands in this repository. The repo's `AGENTS.md` is authoritative; this file only restates it as steps. Read `AGENTS.md` too, because it changes.

## Tree

```text
index.html                                     landing page: every note is a card in #grid
<Category>/<topic-slug>/<topic-slug>.html      the one-page note
<Category>/<topic-slug>/summary.md             short teaching handoff, sources, current discussion point
<Category>/<topic-slug>/assets/                figure exports referenced by the note (never ../)
<Category>/<topic-slug>/scripts/               runnable helpers (.mjs, .py, .json) that produced numbers on the page
```

Copy `templates/note.html` to the plain page name above and fill it in place. A new topic owns
that name. Update an existing note there too, keeping its current math renderer and class names.
Treat any other layout as frozen — deck-shaped files (`-deck` suffixes, frame or slide markup,
`#/N` deep links) are legacy pages that keep their own vocabulary; never convert one into the
other for consistency. Publish exactly one card per topic, pointing at that topic's plain note,
so the grid counts topics rather than files.

Category folder -> the `data-category` chip token the card must carry:

| Folder | Chip | | Folder | Chip |
|---|---|---|---|---|
| `Algebra` | `algebra` | | `Robotics` | `robotics` |
| `Control` | `control` | | `AI-ML` | `ai` |
| `Optimization` | `optimization` | | `Tools` | `tools` |
| `Mathematics` | `math` | | | |

A card may list several chips (`data-category="algebra control"`) when the note genuinely spans fields; it is then counted in each. Pick one category folder regardless — the folder is the note's home, the chips are its discoverability.

## Card recipe

Insert into `<div class="grid" id="grid">` in `index.html`, ordered with the neighbouring notes. Copy the shape of an existing card; the parts and their roles:

```html
<a class="card" href="<Category>/<slug>/<slug>.html" data-category="<chips>" data-field="<Human Field Name>" data-tags="<searchable tokens>">
  <div class="toprow">
    <span class="tag amber"><Short subtopic label></span>
    <span class="read"></span>            <!-- filled by the page's reading-time script -->
  </div>
  <h3><Note title, no section number></h3>
  <p><One-paragraph hook: the problem and what the note resolves.></p>
  <div class="tags"><span class="tag-pill">token</span> ... </div>
  <span class="go">Read the note</span>
  <span class="foot"><span class="field"><i></i><same text as data-field></span></span>
</a>
```

- `data-tags` and the visible `tag-pill` spans should agree. Cover field, subtopic, method, and tools; the search box matches the title, description, and these tags, and every token of a multi-word query must match.
- `data-field` is a human label ("Numerical Linear Algebra", "Control Theory"), shown as the card footer and counted in the hero. It must equal the `.foot` text.
- Tag colour classes available on `.tag`: `amber`, `teal`, `purple`, `rose`. Match the neighbouring cards in the same category.
- Placeholder notes use `class="card soon"` and are excluded from the computed counts; a real note must not.
- `#stat-notes`, `#stat-fields`, and the per-field `#cnt-*` numbers are all derived from `.card` elements. Do not hardcode them, and do not leave an `href` pointing at a file that does not exist.

## Style contract

New pages use `templates/note.html` unchanged apart from content and intentional, documented
exceptions. The page is one responsive document:

- Journal-style serif on white: `"Source Serif Pro", Georgia, ...`, background `#ffffff`, navy
  accent `#1f4e79`, links `#173b5c`. Base font size 17px, content column `max-width:880px`.
- Centered `h1`, an italic `p.hero` summary, numbered `h2` sections with `id="sN"`, and `<hr>`
  between sections.
- Each section starts with a visible `.callout` containing `<strong>Question:</strong>` and only
  the setup needed to attempt it. The expected answer, explanation, solution, proof, method,
  result, conclusion, and takeaway stay out of the HTML and are tracked in `summary.md`.
- Do not use `Intuition:`, `Takeaway:`, or `Claim:` blocks in the default question-map page.
  Their styles remain available for other notes but would reveal the expected insight here.
- Display math in `<div class="eq">\[ ... \]</div>`; inline math in `\(...\)`. Equations may
  state setup or the question, never the answer.
- `.figure` with `.figure-caption` (`<b>Figure N.</b>` first); inline SVG, local assets, or
  external assets are allowed, including computed plots.
- `.demo` for an interactive widget: `.demo-controls` with labeled controls, an output area,
  and `.mono` for numbers. Controls must be keyboard usable.
- `nav.toc` is a restrained sticky contents bar with one anchor per section, horizontal overflow
  on narrow screens, and the template's scroll-spy script for active-section highlighting.
- Keep the page responsive below ~700px; the template's media query covers the common cases.

Math renderer: a new page uses the template's KaTeX auto-render from the jsDelivr CDN. Some
older notes load MathJax instead. When editing an existing page, keep that page's renderer;
never mix the two on one page.

## summary.md

Fill [../templates/summary.md](../templates/summary.md) rather than designing one. Keep a short
handoff: stage, audience assumptions, question/expected-insight map and statuses, current discussion
point, the running example, unresolved or research-needed claims, sources actually consulted,
and checks actually performed or unavailable. Record useful learning evidence without a
transcript, mandatory explain-back, or prerequisite-status table. Follow
[sources.md](sources.md) when a section is deepened and research is actually needed.

The first HTML artifact is a question map with the complete question chain and only the setup
needed to attempt each question. File it and add the landing card immediately; the card points at
a real, readable page even though expected insights, proofs, citations, demos, and exact results
stay in the handoff or chat. Mark the handoff `question map`, record expected insights, likely
misconceptions, assessment focus, and precision-sensitive claims under the handoff headings, and
deepen the response during teaching without researching ahead or writing the answer into HTML.

## Verify

Checks are proportional to the pass. Every published revision checks the structural contract and
renders desktop and narrow views. A deepened section checks only what it added; a skipped or
unchanged section is not rechecked. The question-map pass has no scripts, demos, computed numbers,
or external sources to validate, so do not create checks merely to make the page look complete.

Prefer Firefox or Chrome headless for consistency with existing layout checks; use an available
browser if necessary and record it. Inspect actual rendering rather than assuming one browser's
layout results apply to all browsers.

```sh
P=/home/chun/work/peakyet/<Category>/<slug>/<slug>.html          # ABSOLUTE path
# Structural contract: no leftover slots, and nav.toc anchors match heading ids exactly.
grep -n 'FILL:' "$P"
diff <(grep -o 'href="#[^"]*"' "$P" | cut -d'"' -f2 | sed 's/#//' | sort -u) \
     <(grep -o '<h[12][^>]*id="[^"]*"' "$P" | sed 's/.*id="//;s/"//' | sort -u)
# Teaching sections carry one visible question each (the sources heading legitimately does not).
grep -c '<h[23] id="s[0-9]' "$P"; grep -c '<strong>Question:</strong>' "$P"
# Question-map pages must not contain answer-revealing blocks.
grep -n '<strong>\(Intuition\|Takeaway\|Claim\):</strong>' "$P"
grep -on 'src="\.\./\|href="\.\./\|src="https\?://[^"]*\.\(png\|jpe\?g\|svg\|gif\)"' "$P"
ls -l "$P"
firefox --headless --screenshot=/tmp/<slug>-desktop.png --window-size=1440,2600 "file://$P"
firefox --headless --screenshot=/tmp/<slug>-narrow.png --window-size=420,2600 "file://$P"
# Only when a section anchor or the TOC changed:
# firefox --headless --screenshot=/tmp/<slug>-section.png --window-size=1440,1200 "file://$P#s2"
```

The anchor diff must print nothing (the `#s7` sources heading carries an id and belongs in both
lists). Compare the two counts after excluding any sources or further-reading heading from the
section count, so ask for one question per *teaching* section only — an `intuition` or
`What changes:` callout legitimately follows a section's opening `.callout`. Keep the counts equal
when inserting or removing a section.

For a deepened section, run only its relevant checks: confirm the exact passage for a sourced
claim; run one reproducible script for a computed number; smoke-test a new demo; spot-check a
changed deep link or landing-card link. Keep the result in the assessment or handoff; do not add
the expected answer to the question map. Do not repeat a completed check, read a whole paper, or
re-verify a claim already supported unless the source, claim, or version changed.

Inline SVG beats an embedded raster for anything carrying text, because it stays sharp and its
labels stay correct at any width. A generated plot may be inline or a local asset referenced as
`assets/<name>.png` beside the note (`../` paths break under GitHub Pages, whose root is the
repository), and a data-heavy page past a few hundred kilobytes usually means raster figures
belonging in `assets/`, not inlined bytes. Provenance convention from the existing notes: name
the producing script once near the numbers it generated ("all frames computed by
`scripts/verify_<slug>.py`").

Look for rendered math, figures placed and labelled, no clipping or overlap, no SVG label
collisions, usable sticky TOC navigation, and correct section-anchor positioning below it. Test
one deep link other than `#s1` when the TOC or anchors changed. When card or cross-links changed,
serve the repo (`python3 -m http.server 8000`), open `http://localhost:8000/index.html`, and
confirm the affected card appears, filters find it, and its link resolves. Note any check you
could not run.

Use absolute paths resolved from the repository root and `ls` the output file after a screenshot
batch, because a missing file is the only signal that the command did nothing. Cache-bust
re-renders with `?v=$(date +%s)` before the section anchor when the browser serves a stale copy.

## Housekeeping

- Commit only source: HTML, `summary.md`, figures, and the small scripts that reproduce on-page numbers. No caches, no build output.
- Do not add a Jekyll front-matter header or move notes into `_posts/`; this site is hand-written static HTML served as-is by GitHub Pages.
