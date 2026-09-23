# Repo notes

How a `teach-an-engineer` artifact lands in this repository. The repo's `AGENTS.md` is authoritative; this file only restates it as steps. Read `AGENTS.md` too, because it changes.

## Tree

```text
index.html                                     landing page: every note is a card in #grid
<Category>/<topic-slug>/<topic-slug>.html      the page (file name repeats the folder name)
<Category>/<topic-slug>/summary.md             short teaching handoff, sources, current discussion point
<Category>/<topic-slug>/assets/                generated figures (png/svg) only when inline SVG will not do
<Category>/<topic-slug>/scripts/               runnable helpers (.mjs, .py, .json) that produced numbers on the page
```

The default page is a Beamer-style deck built from `templates/beamer-deck.html`, and
a new topic's deck owns the plain name above. An existing note keeps that name: add
`<Category>/<slug>/<slug>-deck.html` beside it instead of overwriting, and use
`<Category>/<slug>/<slug>-note.html` for a long-form note that follows a deck. Either
way it is one self-contained page, the same `assets/` and `scripts/` rules apply, and
the two pages link to each other.

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
- A deck gets its card the same way, with `slides` (or `talk`) in `data-tags`,
  `<span class="go">Open the slides</span>`, and a `data-field` matching its field, so
  the grid counts it exactly like a note.
- `#stat-notes`, `#stat-fields`, and the per-field `#cnt-*` numbers are all derived from `.card` elements. Do not hardcode them, and do not leave an `href` pointing at a file that does not exist.

## Style contract

Default to `templates/beamer-deck.html`. A deck keeps the same vocabulary inside a fixed
1280x720 frame: `.frame-head` with `.frametitle`, a `.frame-body`, and a script-filled
`.frame-foot`; `.block` in place of `.callout`, with the `.intuition` / `.takeaway`
variants; `data-fragment` in place of a collapsed `details.predict`, since a slide answer
should arrive on a key press rather than a click; one `.eq` per display equation;
`.figure` + `.figure-caption` for the frame's single visual claim. Frames stack and
reflow below ~700px, and a frame that no longer fits its page is tagged `overfull`.

Ship `data-theme="beamer"` — the classic blue theme, and the default for every deck. The
serif/gold `data-theme="paper"` is opt-in: the repository's *long-form notes* use that
palette, but a deck is a different artifact and does not inherit it, so do not switch a
deck to `paper` because a neighbouring page or an earlier deck looks that way. Only the
user's explicit request changes it, and `summary.md` records that they asked.

### Three rules that save the most time

1. **Budget the frame before writing it.** A `.frame-body` holds ~20 em (less ~1 em with a
   `.framesubtitle`). Count 1.45 em per text line, 3 em per `.eq`, 1.7 em per `.block`,
   0.9 em per table row. **`.cols` gives each column the same budget, not half the text** —
   the most common way a frame overflows is a two-column frame written at full-width length.
   Over 20 em → split the frame or cut content.
2. **One concrete object beats notation.** A frame stated over subspaces or operators reads as
   complexity even when the idea is simple; the same content around one vector or one number
   lands immediately. Introduce a symbol only if the frame uses it twice.
3. **Compute when it helps.** Use scripts for demos, illustrations, or difficult calculations,
   not as a prerequisite for every claim. Reason through routine derivations; ground specialized
   claims in authoritative sources. Report only real demo output, and do not treat examples as proofs.

The contract below is the repository's long-form note style, which every newer note under
`<Category>/<slug>/` already follows. No template ships for it: read these bullets when
editing an existing note, and keep that note's renderer and class names. For anything new,
start from the deck template rather than hand-rolling a page:

- Serif on paper: `"Source Serif Pro", Georgia, ...`, background `#fdfcf8`, gold accent `#d4a72c`, links `#9a5b00`. Base font size 17px, content column `max-width:900px`.
- `h1` with a gold underline, a `p.hero` summary, numbered `h2` sections with `id="sN"`, `<hr>` between sections.
- Display math in `<div class="eq">\[ ... \]</div>`; inline math in `\(...\)`.
- `.callout` for a side note, `.callout.intuition` (blue) for the mental model, `.callout.takeaway` (green) for the one-sentence close of a section.
- `.figure` with `.figure-caption` (`<b>Figure N.</b>` first); inline SVG preferred, `assets/` images when the plot is the evidence.
- `details.predict` for a prediction prompt, with the answer revealed inside the same block.
- `.demo` for an interactive widget: `.demo-controls` with labeled `input[type=range]`/`select`, an output area, and `.mono` for numbers. Controls must be keyboard usable.
- `nav.toc` sticky at the bottom with one anchor per section, plus the scroll-spy script that marks the active section.
- Keep the page responsive below ~700px; the media query in the template covers the common cases.

Math renderer: a new deck uses the template's KaTeX (auto-render from the jsDelivr CDN). Some older notes load MathJax instead. When editing an existing page, keep that page's renderer; never mix the two on one page, and never convert a note to slides just for consistency.

## summary.md

Keep a short handoff: audience assumptions, section-to-frame links, current discussion
point, the running example, unresolved gaps, sources with the claims they support, and
checks actually performed or unavailable. Record useful learning evidence without a
transcript, mandatory explain-back, or prerequisite-status table. Follow [sources.md](sources.md)
for papers, books, and blogs.

The first HTML draft covers the complete reasoning chain; teaching progress is separate
from artifact readiness. Add the landing card after the complete draft is usable and
checked, not after the reader passes each section. Revise the deck and handoff during teaching.

## Verify

**Use Chrome, not Firefox.** Chrome renders a frame in ~3 s; headless Firefox takes 30–120 s,
has hung and left a stale process that blocks every later run, and caches `file://` pages so
a re-render can silently serve the previous frame.

### Layout audit — the whole deck in one screenshot

The template's `?fit` mode renders a panel listing every frame's fill and status. This is the
loop to use while *writing* frames:

```sh
P=/home/chun/work/peakyet/<Category>/<slug>/<slug>.html          # ABSOLUTE path
google-chrome-stable --headless --disable-gpu --no-sandbox \
  --user-data-dir=/tmp/chrome-deck \
  --screenshot=/tmp/<slug>-fit.png --window-size=1440,900 "file://$P?fit#/1"
```

Read `frame fill status`. **`fill` is the number that matters, not the badge** — a frame at
94% passes today and overflows after one more sentence, so trim anything above ~90% and never
leave a frame above 95%. Chrome and Firefox break lines differently, so the Chrome audit is
the authority; a Firefox shot alone does not clear a frame.

### Visual check — a few frames, once the audit is clean

```sh
google-chrome-stable --headless --disable-gpu --no-sandbox --user-data-dir=/tmp/chrome-deck \
  --screenshot=/tmp/<slug>-f1.png --window-size=1440,900 "file://$P#/1"     # then #/4, #/<N>
google-chrome-stable --headless --disable-gpu --no-sandbox --user-data-dir=/tmp/chrome-deck \
  --screenshot=/tmp/<slug>-narrow.png --window-size=420,3200 "file://$P"
```

`#/N` deep-links to frame N and reveals every overlay inside it, which is what the printed
deck shows. For a long-form note, shoot the document instead at `1440,2600` and `420,2600`.

Then look: math rendered, figures placed and labelled, nothing clipped or overlapping, no SVG
label collisions, TOC anchors present. For cross-links, serve the repo
(`python3 -m http.server 8000`), open `http://localhost:8000/index.html`, and confirm the card
appears, filters find it, and its link resolves. Note any check you could not run.

**Hygiene, each of which has bitten:** absolute paths only (a bare `$PWD/...` breaks silently
when the working directory moves — the browser writes no file and the batch looks like it
ran); a dedicated `--user-data-dir` (otherwise the profile lock refuses a second run);
cache-bust re-renders with `?v=$(date +%s)` before the `#`; and `ls` the output file after a
batch, because a missing file is the only signal that the command did nothing.

## Housekeeping

- Commit only source: HTML, `summary.md`, figures, and the small scripts that reproduce on-page numbers. No caches, no build output.
- Do not add a Jekyll front-matter header or move notes into `_posts/`; this site is hand-written static HTML served as-is by GitHub Pages.
