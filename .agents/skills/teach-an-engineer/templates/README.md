# Templates

`typst-template/note.typ` is a question-map shell, not an answer key. It gives each teaching
section one deep question and only the setup needed to attempt it. Figures and a simple demo may
expose a phenomenon for the reader to interpret, but the expected answer, conclusion, and worked
solution stay out of the document. The published artifact is the compiled PDF, which the site
serves beside the source.

## Layout

```text
typst-template/
  ilm/            vendored 'Ilm template: main.typ documents every option, refs.bib is a BibTeX example
  teaching.typ    the shared partial every note imports: note-ilm (the 'Ilm defaults), question (the callout), and the navy/teal/gray figure palette
  note.typ        the shell you copy; it compiles as shipped, so it doubles as the smoke test
templates/
  README.md       this router
  summary.md      the handoff that holds the expected insights, one per question
```

The site's older notes are hand-written HTML and have no template file here. Update one of those
in place from the file itself, keeping its KaTeX or MathJax renderer and its class names.

## Workflow

1. Read this router once.
2. Copy the shell, then read the copy before filling it. The repository-absolute import needs no
   editing after the copy, because a note always sits two folders deep:

   ```sh
   cp .agents/skills/teach-an-engineer/typst-template/note.typ <Category>/<slug>/<slug>.typ
   ```

   Slots are addressed by their text (`FILL: Note title`, `FILL: the opening deep question`) and
   each appears once. Keep the question-and-setup structure, and delete unused commented optional
   blocks cleanly.
3. Compile it from the repository root, so `--root .` makes the `/`-absolute import resolve:

   ```sh
   typst compile --root . <Category>/<slug>/<slug>.typ <Category>/<slug>/<slug>.pdf
   ```

   Fix every warning; a shipped note builds clean.
4. Fill the title, abstract, and every question-led section. Each section asks one deep question
   and supplies only the running example, assumptions, definitions, notation, or visual setup
   needed to attempt it. Do not fill an answer, explanation, solution, proof, method list, result,
   takeaway, or leading hint.
5. Keep every teaching section as one `= Title <sN>` level-1 heading with an ordered `<sN>` label.
   The label is the deep-link key that `summary.md` maps to a PDF page, and the contents page is
   built from these headings, so keep their text plain (no math) and renumber both together if a
   section is inserted or removed.
6. Make the Sources section truthful for the current stage: before any research, state that no
   external sources have been consulted yet. Once a claim needs grounding, add a `refs.bib` beside
   the note, uncomment the `bibliography:` line, and cite with `@key`. Never use a citation to
   disclose an expected answer.
7. File the `.typ`, the compiled `.pdf`, and the landing card immediately once the question map is
   usable. Load `summary.md` only at handoff.

The teaching route is question → reader attempts an answer from prior knowledge → assess the
attempt → targeted follow-up, hint, research, derivation, or demo only where needed → reader
revises → next question. The document carries the questions and the setup; it does not carry the
expected insight or the explanation.

## Fill rules

- Replace every visible `FILL:` and act on every commented `FILL:` instruction. A shipped note must
  pass `grep -n 'FILL:' <Category>/<slug>/<slug>.typ` with no output.
- Each section opens with a `#question[...]` callout that names the deep problem the section tests.
  The setup below it must make that question attemptable without answering it.
- Do not add an intuition, takeaway, claim, proof, method-summary, worked-result, or overall
  conclusion block to a question map. They would give away the expected insight.
- Inline math is `$x_k$` with no inner spaces; a displayed equation is `$ ... $` with inner
  spaces, is numbered, and can be labelled `<eq:name>` for `#ref(<eq:name>)`. An equation may
  state the setup or the question, never the expected answer.
- A figure should expose a phenomenon, object, or contrast for the reader to interpret or predict,
  as a `#figure(...)` whose caption says what to inspect, not what conclusion to draw. See
  [figures.md](../references/figures.md).
- Keep note-local paths relative to the note (`assets/<name>.svg`, `refs.bib`) and never use `../`,
  which escapes the project root that `--root .` establishes.
- A demo may be added later only when the reader's response calls for it, and only as the simple
  sidecar described in [repo-notes.md](../references/repo-notes.md). It must let the reader
  investigate rather than announce the answer, and it must be run before output is reported.

## Typst math, not LaTeX

In Typst, a backslash escapes the following character rather than naming a command, so LaTeX habits
break loudly (`$\alpha$` fails) or quietly wrong (`$\otimes$` silently renders `o times B`). Write
symbols by their Typst names, all of these verified on the shell's preset:

```typst
$ alpha, beta, lambda, partial_x f, nabla f, dif f $
$ sum_(i=0)^n i, product_i x_i, integral_a^b f, lim_(k -> oo) x_k $
$ frac(a, b), sqrt(2), binom(n, k), mat(A, B; C, D), vec(v), lr(( x )), lr{ 1, 2 } $
$ bb(R)^n, cal(L), frak(g), upright(H K), hat(x), bar(z), tilde(y), norm(v), abs(x) $
$ A -> B, x |-> y, a times b, f compose g, x in S, S subset.eq R, approx, equiv, therefore $
$ A^T A x = b quad "and" x_i^* quad "for" lambda > 0 $
```

Plain words inside math go in quotes, subscripts and superscripts chain as `x_i^*`, and a custom
operator is `op(*)_k`. When a symbol name is not obvious, look it up rather than guessing a LaTeX
command: <https://typst.app/docs/reference/symbols/sym/>.

Displayed math is the same `$ ... $` with a space after the opening and before the closing `$`,
which is what makes Typst set it on its own line with a number:

```typst
$ x_(k+1) = x_k - alpha nabla f(x_k) $ <eq:step>

Rewriting #ref(<eq:step>) exposes the whole tension.
```

Do not use `\[ ... \]` or `\( ... \)` for real content. Those are *verbatim* equations, and Typst
parses their innards differently: `$x_{k+1}$` and `\[ x_{k+1} \]` look equivalent, but the second
one fails with `error: unclosed delimiter`. Typst's own delimiters accept `x_(k+1)` and `x_{k+1}`
alike.

## Fixed document contract

- 'Ilm on A4 at 12pt: a cover page (title, authors, date, abstract), a contents page, one section
  per page, and a footer carrying the page number and the section name. The contents page replaces
  the old sticky table of contents, and `<slug>.pdf#page=N` replaces `#sN`.
  The cover `authors` slot names the agent that wrote the note -- the tool driving the session
  (Amp, Codex CLI, Claude Code, ...), never the repository owner or any person's name.
- Level-1 headings are navy `#1f4e79` and numbered; body text is the serif face 'Ilm selects. Change
  only the 'Ilm options the note genuinely needs (`paper-size: "us-letter"`, a `preface`, an
  `appendix`, a quieter `footer`), and record the reason in `summary.md`.
- `#question` is the only callout a question map uses. Its navy left rule on a pale fill is the
  shared partial's styling; restyle it in `teaching.typ` for the whole series, never inside one note.
  Figures take their colors from the same partial's `navy`, `teal`, and `gray` rather than
  re-declaring them.
- `teaching.typ`, `note.typ`, and the import line are fixed. Change content, and change the partial
  only when the whole series should change with it.
- Existing HTML notes and legacy decks keep their own renderer, markup, and class names. Never
  convert one artifact style into another merely for consistency.
