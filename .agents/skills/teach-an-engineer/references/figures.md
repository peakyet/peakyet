# Figures

Figures are the default teaching medium, not an accessory. Show the idea before writing about it:
give every central idea a primary figure when a visual representation can carry it, and keep prose
for what the figure cannot say. Do not add several decorative variants just to satisfy a quota.
Text around a figure motivates it and says what to inspect while its section is open; once the reader
closes the section, the write-up's prose and captions may state the conclusion the figure supports.

Choose the visual form first, then write the minimum prose around it:

- Geometric, structural, or stateful idea -> a Typst drawing.
- Comparison the reader should scan -> a `#table`.
- Measured or dense curves -> a script in `scripts/` that generates one exported asset.
- An idea the reader must operate to attempt the question -> the simple sidecar demo in
  [repo-notes.md](repo-notes.md), filed with the question map.

Build and verify figures with these rules (the surrounding contract is in
[repo-notes.md](repo-notes.md)):

- Wrap every figure as `#figure(caption: [...], <content>)`. Typst numbers it and owns the caption,
  so an open section's caption says what to inspect without revealing its answer; a closed
  section's caption may explain the result. Leave figures in reading order using `placement:`
  only when needed, so the section-to-page map stays honest.
- Choose the representation that exposes the idea:
  - Typst's own drawing -- `line`, `curve`, `path`, `polygon`, `rect`, `circle`, `ellipse`, `arc`,
    `place`, `move` -- for geometry, state diagrams, axes, and annotated comparisons. Labels are
    Typst content, so they are typeset and stay sharp at any size.
  - `#table(...)` for a comparison the reader should scan, and `#figure` around it for a caption.
  - `#image("assets/<name>.svg")` for a diagram exported from another tool. SVG is embedded as
    vector, so it scales; a raster `assets/<name>.png` is right for measured or dense curves.
  - A script in `scripts/` that generates the data, then one exported asset. Name the producing
    script once near the numbers it generated.
- Keep math in the document layer, not baked into a raster. Inside a figure, math is still Typst
  math: `$ mat(A, B; C, D) $`, `$x_k$`.
- Typst drawing takes coordinates as lengths measured down and to the right from the current
  position, and `curve` in Typst 0.15 is built from segment functions -- `curve.move(p)`,
  `curve.line(p)`, `curve.quad(control, p)`, `curve.cubic(c1, c2, p)`, `curve.close()` -- not
  LaTeX commands. Give a canvas an explicit height, and give *every* drawing element its own
  `#place(top + left)` so they share one origin: consecutive bare `line`/`curve` calls stack
  vertically and shift apart, and a `scale` over a group multiplies the offsets instead of the data.
  Map data coordinates to the page with small functions, and keep the marks inside the canvas.
- A figure should give the reader one clear thing to inspect, predict, or compare. Keep the geometry
  of the running example stable across successive figures so the reader can compare them, and put
  the reading instruction in the caption.
- Nothing may be wider than the text column; on 'Ilm's A4 page with its default margins the column is
  roughly 16cm, and Typst will happily let a figure overflow into the margin silently.
- Use color sparingly and consistently: `navy` for the primary series, `teal` for a contrast series,
  `gray` for axes and annotations. All three come from `teaching.typ`, so import them instead of
  re-declaring hex values per note.

## A verified starting pattern

Two annotated series over a shared axis, using the shell's import line. Copy the shape, not the
numbers; this compiles clean on the preset and is the layout most teaching figures need.

```typst
#figure(
  caption: [Two response curves sharing an axis. Inspect where they separate.],
  box(width: 100%, height: 6cm)[
    #let x0 = 0.8cm      // left edge of the plot
    #let y0 = 4.8cm      // baseline
    #let px(t) = x0 + t * 1.2cm
    #let py(v) = y0 - v * 0.7cm    // values grow upward
    #place(top + left)[
      #line(start: (px(0), py(0)), end: (px(0), py(6)), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #line(start: (px(0), py(0)), end: (px(9.4), py(0)), stroke: 0.8pt + gray)
    ]
    #place(top + left)[
      #curve(
        stroke: 1.2pt + navy,
        curve.move((px(0), py(5))),
        curve.cubic((px(2.5), py(5)), (px(6), py(0.6)), (px(9.2), py(0.9))),
      )
    ]
    #place(top + left)[
      #curve(
        stroke: 1.2pt + teal,
        curve.move((px(0), py(1.6))),
        curve.line((px(9.2), py(3.6))),
      )
    ]
    #place(top + left, dx: px(3.6), dy: py(6) - 1.4em)[response $x_k$]
    #place(top + left, dx: px(8.4), dy: py(0) + 2pt)[time $t$]
  ],
)
```

## Verify

Look at the rendered page rather than assuming it: recompile, rasterize the pages the figure sits
on, and check that elements sit where they belong, nothing overlaps or clips, and every visible
equation, axis, tick, label, and legend is correct. Fix problems instead of leaving them.

```sh
typst compile --root . <Category>/<slug>/<slug>.typ <Category>/<slug>/<slug>.pdf
pdftotext -f <page> -l <page> -layout <Category>/<slug>/<slug>.pdf - | head -5   # caption and labels present
pdftoppm -png -r 110 -f <page> -l <page> <Category>/<slug>/<slug>.pdf /tmp/<slug>-fig
ls -l /tmp/<slug>-fig*.png
```

Then inspect the PNG. An inline SVG export or a generated plot is also worth a direct look with an
image viewer before it is referenced, since a broken asset still compiles.

For a legacy HTML note, keep its own convention instead: inline `<svg>` inside `.figure` with a
`.figure-caption`, math left in the HTML layer for its KaTeX or MathJax renderer to typeset, and
`assets/<name>.png` for data-heavy plots.
