# Publishing and checks

Follow repository `AGENTS.md`. File each note under `<Category>/<slug>/`:
`<slug>.typ`, compiled `<slug>.pdf`, and `summary.md`; add `refs.bib`, `assets/`,
and producing `scripts/` when needed. The summary records scope, explanation
progression with PDF pages, source support, checks, and next revision.

Keep samples and private review material in `.amp/in/artifacts/`, with `/.amp/in/`
locally excluded. Publish one landing card for a complete note, linking its PDF.
Copy a neighboring card and set matching categories, field, tags, and footer.
Category tokens: Algebra → `algebra`, Control → `control`, Optimization →
`optimization`, Robotics → `robotics`, Mathematics → `math`, AI-ML → `ai`, Tools → `tools`.

## Build

Copy `typst-template/note.typ`, fill its placeholders, and adjust sections freely.
Keep the shared preset; label teaching sections `<s1>`, `<s2>`, … for page links.
Typst uses `$x_k$` inline and `$ x_(k+1) = A x_k $` for numbered display math,
not LaTeX commands. Assets and bibliography paths are relative to the note.

Run from the repository root:

```sh
typst compile --root . <Category>/<slug>/<slug>.typ <Category>/<slug>/<slug>.pdf
typst eval --root . 'query(heading.where(level: 1)).filter(h => h.numbering != none).map(h => str(h.location().page())).join(",")' --in <Category>/<slug>/<slug>.typ
pdftoppm -png -r 110 -f <page> -l <page> <Category>/<slug>/<slug>.pdf .amp/in/artifacts/<slug>
```

Require a warning-free build and inspect rendered affected pages, including figures
and page numbers. Check relevant derivations, numerical outputs, exact displayed
runnable snippets, citations, and links. Exercise any demo controls in a browser;
verify landing cards appear, filter correctly, and resolve. Report unavailable checks.
Deliver verified `<slug>.pdf#page=N` links. Commit source and compiled PDF;
keep research downloads and caches out of the repository.

## Simple demo ceiling

Use a demo when manipulating an object helps explain the mechanism:

- `<slug>-demo.html`, one per note; a second only on reader request. No landing card;
  name it in the note and summary and provide a clickable link in chat.
- Roughly 150 lines or fewer, one file with inline CSS and one inline script.
  No external assets, CDN, framework, build step, or `../` paths.
- Vanilla JS with one 2D canvas or inline SVG; at most three labeled native range,
  checkbox, or select controls plus one monospace numeric readout. Redraw on input;
  no animation loop, worker, fetch, or storage.
- Serif text, white background, navy `#1f4e79`; plain-text or Unicode math labels.
- For synchronized views, legends, exported plots, 3D, solver loops, or other needs
  beyond this ceiling, use static figures with producing scripts or investigate in chat.
