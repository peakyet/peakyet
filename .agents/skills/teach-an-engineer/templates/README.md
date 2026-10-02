# Templates

Use this router when creating a Typst note. Teaching behavior and the open/closed section rule
live in [SKILL.md](../SKILL.md); filing, demos, and verification commands live in
[repo-notes.md](../references/repo-notes.md).

## Files

- `typst-template/note.typ` — copyable shell; also compiles as a smoke test.
- `typst-template/teaching.typ` — shared 'Ilm preset, question callout, and navy/teal/gray palette.
- `typst-template/ilm/main.typ` — documents the vendored template's options.
- `templates/summary.md` — short handoff with grading guide, learning evidence, and page map.

Existing HTML notes are edited in place with their current renderer and classes.

## Create and fill

Create the topic folder, then copy and read the shell:

```sh
cp .agents/skills/teach-an-engineer/typst-template/note.typ <Category>/<slug>/<slug>.typ
typst compile --root . <Category>/<slug>/<slug>.typ <Category>/<slug>/<slug>.pdf
```

Run from the repository root. The `/`-absolute import resolves against `--root .`; note-local assets
use `assets/<name>.svg` and `refs.bib`. Keep those paths relative to the note without `../`.

- Replace all `FILL:` slots, including commented instructions; delete unused optional blocks.
- Use one plain-text `= Title <sN>` heading and one opening `#question[...]` per teaching section.
  Labels run `s1`, `s2`, … in order; renumber if sections change. The six shell sections are a
  starting route: keep only the questions the topic needs.
- Put the visual setup after the question; see [figures.md](../references/figures.md).
- Keep the import, preset, and shared styling. Change `teaching.typ` only for a series-wide change.
- The cover's `authors` names the producing tool (Amp, Codex CLI, Claude Code, …).
- Once needed, add `refs.bib`, enable `bibliography: bibliography("refs.bib")`, and cite with `@key`
  where the claim is used; see [sources.md](../references/sources.md). If none were consulted, say
  so. If sources were consulted only for the grading guide, record them in the handoff and state
  that distinction truthfully in the note until their supported claims appear there.

## Typst math

Use Typst symbol names rather than LaTeX commands:

```typst
$ alpha, beta, lambda, partial_x f, nabla f, dif f $
$ sum_(i=0)^n i, product_i x_i, integral_a^b f, lim_(k -> oo) x_k $
$ frac(a, b), sqrt(2), binom(n, k), mat(A, B; C, D), vec(v), lr(( x )), lr{ 1, 2 } $
$ bb(R)^n, cal(L), frak(g), upright(H K), hat(x), bar(z), tilde(y), norm(v), abs(x) $
$ A -> B, x |-> y, a times b, f compose g, x in S, S subset.eq R, approx, equiv, therefore $
```

Inline math has no inner spaces (`$x_k$`); display math has inner spaces and the preset numbers it:

```typst
$ x_(k+1) = x_k - alpha nabla f(x_k) $ <eq:step>

See #ref(<eq:step>).
```

Quote ordinary words inside math. Subscripts and superscripts chain as `x_i^*`; custom operators
use `op(*)_k`. Do not use `\[ ... \]`, `\( ... \)`, or commands such as `\alpha`. Look up unknown
symbols in the [Typst reference](https://typst.app/docs/reference/symbols/sym/).

## Layout and revision

'Ilm supplies A4 at 12pt, a cover, contents, sections starting on new pages, and a footer with the
page number and section name. Keep sections compact but allow a write-up to span pages. Headings
are numbered and navy; body text is serif. Record any necessary preset option change in the handoff.

On closing a section, keep its question and add the explanation beneath it. Compile without
warnings, inspect changed pages, and refresh `summary.md`'s section-to-PDF-page map using the repo
commands before sending another deep link.
