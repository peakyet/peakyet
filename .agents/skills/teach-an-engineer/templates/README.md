# HTML template

One template ships with this set: **`beamer-deck.html`**. It is the default and only
starting point for a `teach-an-engineer` artifact. Do **not** hand-build a new template
unless the user explicitly asks for a custom look. The file is a complete skeleton
(layout + CSS + KaTeX from a CDN) — copy it and fill in the placeholder frames.

The skill teaches from these frames: a section is built on the page before it is
discussed, and the session hands over a `#/N` deep link instead of a terminal
explanation. Design the frames accordingly — one claim each, the question on the
frame, and the answer one key press away.

## `beamer-deck.html` — LaTeX Beamer look
- **Look & feel:** white 1280x720 pages on a grey backdrop, tinted head and foot
  bands, filled-triangle bullets, and Beamer's rounded `block` boxes. The default
  theme is classic Beamer blue (`data-theme="beamer"`, sans body);
  `data-theme="paper"` swaps in this repository's serif-on-paper palette with the
  same layout. **Light mode.**
- **Use it for:** every new artifact — a talk, a lesson the user walks through, or an
  explanation that gains from one claim per frame.
- **Font:** the Beamer theme uses a Helvetica/Arial sans stack, the paper theme a
  Source Serif Pro stack. Frame type is 26px on the 1280x720 canvas and everything
  else is in `em`, so a reflowed frame stays proportional.
- **Structure:** one `<section class="slide">` per frame, in this order —
  `.title` (the `\titlepage`), `.toc-frame` (`\tableofcontents`), then per section
  a `.section` divider followed by its `.frame` content frames. Every frame after
  the title carries a `.frame-head` (`\frametitle` plus an optional
  `.framesubtitle`), a `.frame-body`, and a `.frame-foot`. `data-section="N"`
  drives the foot-band miniframes and the outline highlight, `data-secname="..."`
  names the section in the foot. Do not hand-write the foot contents; the script
  fills them.
- **Overlays:** put `data-fragment` on any element to reveal it one step at a
  time. One `Right` press reveals the next fragment and the frame advances only
  after the last one. Use it for the argument beats of a frame and for the answer
  of a prediction prompt, never for the frame title.
- **Environments:** `.block` (`\begin{block}`) plus `.block.alert`,
  `.block.example`, and the teaching variants `.block.intuition` and
  `.block.takeaway`; theorem-like `.thm`, `.defn`, `.lem`, `.cor` with a
  `.thm-name` lead-in; `.proof` with a `.proof-name` and its closing tombstone;
  `.cols` (`.w46`, `.w64`, `.c3`) for side-by-side columns.
- **Shared vocabulary with the repository's notes:** `.eq`, `.figure` +
  `.figure-caption`, `.callout` (`.intuition` / `.takeaway`), `details.predict`,
  `.demo`, `.demo-controls`, `.mono`, `table`, and `pre` + `code` also exist on the
  long-form note pages, so content moves between the two shapes without restyling.
  Deck-only names: `.block`, `.thm` / `.proof`, `.cols`, `.frametitle`, `.item` /
  `.enum`, `.sectionpage`, `.titlepage`, `data-fragment`.
- **Fitting check:** a frame whose body no longer fits its page, or whose equation,
  table, or `pre` is clipped horizontally, gets a red `overfull \vbox` /
  `overfull \hbox` tag in the corner. Treat it like a compiler warning: shorten the
  frame, split it, or set the formula in `.eq.tight`.
- **Controls:** arrows, `Space`, `PageUp`/`PageDown` step fragments then frames;
  `Home`/`End` jump; `f` fullscreen; `r` reader mode; plus the corner button
  cluster. `#/N` deep-links to frame N, which is how a teaching session points at
  the frame it wants read. Below ~700px, and in reader mode, frames stack and reflow
  as a readable document with every overlay shown. Printing gives one frame per
  landscape page. Change `--frame-w` and `--frame-h` in the theme block for a
  different aspect ratio (1024x768 gives 4:3); the fit script measures them, and only
  the `@page{size:…}` line in the print block needs the same numbers.

## Math rendering

The template renders math with **KaTeX auto-render**, loaded from a CDN along with
`katex.min.css`; inline math uses `\(...\)`, display math uses `\[...\]`. The CDN
links are the default — inline the KaTeX CSS/JS (and web fonts) only if an offline
copy is specifically requested. Keep one display equation per `.eq`; if it will not
fit a column, shorten it or add `.eq.tight`.

## Reusing the template

1. Copy `beamer-deck.html` to `<Category>/<topic-slug>/<topic-slug>.html` — a new
   topic's deck owns the plain slug. When the topic already has a page at that name,
   leave it alone and write `<Category>/<slug>/<slug>-deck.html` beside it (see
   [../references/repo-notes.md](../references/repo-notes.md) for filing and for
   registering the card on the landing page).
2. Update `<title>` to `Deck Title — one-line hook`. The foot band prints the text
   before the em dash as the running title, so keep that part short.
3. Replace the placeholder frames. One claim per frame, four to six bullets at
   most, and a frame that only repeats the next one is a frame to delete.
4. Add or drop `.section` dividers with the outline, and keep `data-section` and
   `data-secname` identical across a divider and the frames it introduces.
5. Spend overlays where the argument branches: `data-fragment` on each beat of a
   list, and on the answer of a prediction prompt so the question lands first.
6. Close every section with a `.block.takeaway`, and the deck with a sources frame: one entry
   per authoritative reference, each carrying a real arXiv ID or DOI link and a line on what it
   adds. Fetch those identifiers with the paper MCP servers rather than from memory, and mirror
   the list into `summary.md` (see [../references/sources.md](../references/sources.md)).
7. Keep `data-theme="beamer"` unless the user wants the deck to read as part of the
   note series, then set `data-theme="paper"`. Recolor anything else only on request.
8. Fix every `overfull \vbox` / `overfull \hbox` tag before shipping, then keep the
   CDN KaTeX links and delete unused placeholder frames (the CSS may stay).

## Existing long-form notes

No template ships for the repository's older long-form pages, and none is needed:
their class vocabulary is documented in `AGENTS.md` and in the style contract of
[../references/repo-notes.md](../references/repo-notes.md). When editing an existing
note, keep that note's renderer and class names rather than importing this template
wholesale, and never convert a page to slides just for consistency.
