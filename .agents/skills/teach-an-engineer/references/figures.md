# Figures

Figures are a primary teaching medium. Give each central idea one primary figure when a visual representation genuinely helps the reader inspect the mechanism or make a prediction; do not add several decorative variants just to satisfy a quota. Text around a figure should motivate it and say what to inspect, while the expected answer stays out of the page.

Build and verify figures with these rules (the `.figure` / `.figure-caption` markup are in [repo-notes.md](repo-notes.md)):

- Choose the representation that exposes the idea: HTML/CSS for layouts, states, and comparisons; inline SVG for geometry and annotated diagrams; a generated plot for measured data, dense curves, or computed results. Prefer inline SVG whenever the figure carries text, so KaTeX-quality labels survive scaling. Reference a local asset as `assets/<name>` beside the note — never `../`, whose path breaks when GitHub Pages serves the repository as the site root — and an external asset only from a stable public URL.
- Keep explanatory math in the HTML layer so KaTeX can typeset it. Use SVG text only for short labels that are part of the geometry; keep computed SVG plot labels and legends legible when embedded inline.
- Give every figure one clear thing to inspect, predict, or compare; include a semantic `<figure>`/`<figcaption>` and useful alt text or an adjacent text equivalent. The caption may state what the figure shows or asks, but must not state the expected answer.
- Make responsive figures from a stable coordinate system. Use an explicit `viewBox` and `aspect-ratio` for SVG/overlay layouts, keep labels inside the bounds, and avoid absolute-positioned text whose position drifts away from the geometry.
- Before finishing, inspect every figure at desktop and narrow widths when possible: verify that elements sit where they belong, nothing overlaps or clips, and every visible equation, axis, label, and legend is correct. Fix problems rather than leaving them.
