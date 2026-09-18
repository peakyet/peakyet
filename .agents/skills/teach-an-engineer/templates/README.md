# HTML templates

One template ships with this set: **`note-page.html`**. Do **not** hand-build a
new template unless the user explicitly asks for a custom look. The file is a
complete skeleton (layout + CSS + KaTeX from a CDN) — copy it and fill in the
placeholder sections.

## `note-page.html` — the repository's note style
- **Look & feel:** warm paper `#fdfcf8`, serif (Source Serif / Georgia), gold
  `#d4a72c` title underline, soft callout blocks. **Light mode**
  (light background, dark text).
- **Best when:** math-heavy, long-form explanations with a lecture-note rhythm.
- **Font:** Source Serif Pro / Georgia / Times, serif; base 17px.
- **Palette:** bg `#fdfcf8`, ink `#1a1a1a`, heading underline gold `#d4a72c`,
  link `#9a5b00`; equation block bg `#f7f4ec`; intuition blue `#4a7bb5` on
  `#eef4fb`; takeaway green `#3a7d44` on `#edf5ec`.
- **Structure:** sticky bottom jumplist `.toc` nav (section anchors, with the
  scroll-spy script), `<h1>` title + one-paragraph hero, numbered `<h2>`
  sections, centred `.eq` blocks, `.callout` (`intuition` / `takeaway`),
  `.figure` with `.figure-caption` (inline SVG example included),
  `details.predict`, `.demo` with `.demo-controls` / `.mono`, `table`, `pre` +
  `code`, and `<hr>` dividers.
- **Already matches the notes in this repo.** Every newer note under
  `<Category>/<slug>/<slug>.html` uses these class names; the older MathJax
  pages predate the template. When editing an existing note, keep that note's
  renderer and class vocabulary instead of importing this file wholesale.

## Math rendering

The template renders math with **KaTeX auto-render**, loaded from a CDN along
with `katex.min.css`; inline math uses `\(...\)`, display math uses `\[...\]`.
The CDN links are the default — inline the KaTeX CSS/JS (and web fonts) only
if an offline copy is specifically requested.

## Reusing the template

1. Copy `note-page.html` to `<Category>/<topic-slug>/<topic-slug>.html`
   (see [../references/repo-notes.md](../references/repo-notes.md) for where the
   note goes and how it is registered on the landing page).
2. Update `<title>`, `<h1>`, and hero text.
3. Recolor the gold accents (`#d4a72c`, `#9a5b00`) or the body font family only
   if the user asks for a different look.
4. Replace the placeholder sections with the topic content, keeping the
   intuition / takeaway callouts from `SKILL.md`.
5. Keep the CDN KaTeX links; inline them only if an offline copy is requested.
6. Delete the `.predict`, `.demo`, or `pre` examples that the final note does
   not need — the CSS may stay, unused blocks are cheap.
