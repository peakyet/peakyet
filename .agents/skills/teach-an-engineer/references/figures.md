# Figures

Actively build pictures that expose the operation or relationship the reader needs to understand.
Design the central visual construction before writing its prose. There is no figure quota;
coverage of the mechanism matters. Use equations, tables, or prose for steps where a picture
adds nothing, but do not use that exception to skip a visual construction of the central bridge.
A result plot demonstrates an outcome; it does not automatically explain the mechanism.

## Choose a visual operation

Ask what the reader should be able to watch or inspect, then draw that operation on the
smallest faithful example. Start with visible objects, show the change, and connect it to
the notation. Possible choices include:

- A linear map: a vector or basis before and after the map, on shared axes.
- A projection or constraint: a candidate, its projection, and the component removed.
- Elimination or composition: connected quantities before solving the shared relation,
  the substitution, and the remaining quantities afterwards.
- An iterative procedure: successive states with the changed region highlighted and the
  preserved relationship marked. Draw the action as well as recording its numeric values.

Choose another representation when these do not fit. Abstract ideas can use annotated
structural diagrams; geometry is not the only visual method. A table relabeled as a figure,
a list of stage names, or a final numerical result does not by itself show an operation.
If a faithful visual would mislead, identify the precise limitation in the private review
and use the clearest inspectable construction available.

## Turn movement into a readable sequence

For a central visual bridge, show the relevant states before, during, and after the operation.
These can be panels in one figure or successive figures. Keep axes, scale, labels, and object
colors consistent; mark the change rather than requiring the reader to discover it in two
unrelated drawings. Connect the changed part to the corresponding equation in nearby prose.
When a representation changes, show the correspondence explicitly.

State what arrows mean: transformed vectors, velocity, trajectory, or information flow.
For instance, negative eigenvalues describe decay of a continuous-time flow but do not imply
that multiplying by its generator contracts a vector. Show actual intermediate objects,
not simply boxes whose labels repeat the algorithm's name. A caption may explain a conclusion,
but the geometry and annotations must supply the relationship supporting it.

Use a small demo only when manipulating the object materially helps; the existing ceiling
in [repo-notes.md](repo-notes.md) still applies. Static sequences remain the default PDF medium.

## Build

Choose the representation that explains the relationship, then write the supporting prose:

- Geometric, structural, or stateful idea -> a Typst drawing.
- Comparison the reader should scan -> a `#table`.
- Measured or dense curves -> a script in `scripts/` that generates one exported asset.
- An idea clarified by manipulating the object -> the simple sidecar demo in
  [repo-notes.md](repo-notes.md), filed with the note itself.

Build and verify figures with these rules (the surrounding contract is in
[repo-notes.md](repo-notes.md)):

- Wrap every figure as `#figure(caption: [...], <content>)`. Typst numbers it and owns the caption:
  the caption may state the result the figure supports, since nothing is hidden. Leave figures in
  reading order using `placement:`
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
numbers; this compiles clean on the preset and is a starting point for curve comparisons.
Use a different construction when the mechanism is geometric, structural, or procedural.

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

First verify the mathematical geometry: points, slopes, scales, transformations, and labeled
relationships must match the example's equations. Then recompile, rasterize the pages the figure
sits on, and inspect with a media viewer using an objective naming the expected relationship.
Check intermediate and final panels, not just the final result. Confirm that nothing overlaps
or clips and each axis, tick, label, arrow, and legend has the correct meaning.

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
