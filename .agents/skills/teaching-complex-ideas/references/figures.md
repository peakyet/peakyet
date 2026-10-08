# Typst figures

Use native drawings for geometry and structural relationships, exported SVG for
external diagrams, and generated assets for dense plots. Keep producing scripts
beside the note. Wrap content in `#figure(caption: [...], ...)` and keep it within
the text column (roughly 16cm with the preset).

Import `navy`, `teal`, and `gray` from `teaching.typ`. Keep math as Typst content,
and axes, scales, colors, and labels consistent across successive states.

Typst coordinates grow rightward and downward. Give the canvas an explicit size
and each drawing element its own `#place(top + left)` to share an origin;
bare drawing calls otherwise stack vertically. For example:

```typst
#figure(
  caption: [The blue vector becomes the green vector under $A$.],
  box(width: 100%, height: 4cm)[
    #place(top + left)[
      #line(start: (1cm, 3cm), end: (3cm, 2cm), stroke: navy)
    ]
    #place(top + left)[
      #line(start: (1cm, 3cm), end: (4cm, 1cm), stroke: teal)
    ]
    #place(top + left, dx: 3cm, dy: 2cm)[$x$]
    #place(top + left, dx: 4cm, dy: 1cm)[$A x$]
  ],
)
```

Check depicted coordinates and relationships against the mathematics, then inspect
rendered pages for readable labels, clipping, and overlap. This drawing is a syntax
example; choose the construction that explains the actual mechanism.
