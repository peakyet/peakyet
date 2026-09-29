# Repo notes

How a `teach-an-engineer` artifact lands in this repository. The repo's `AGENTS.md` is
authoritative; this file only restates it as steps. Read `AGENTS.md` too, because it changes.

## Tree

```text
index.html                                      landing page: every note is a card in #grid
<Category>/<topic-slug>/<topic-slug>.typ        the note source: one question-led section per deep question
<Category>/<topic-slug>/<topic-slug>.pdf        the compiled note; this is what the card links to
<Category>/<topic-slug>/summary.md              short teaching handoff, sources, current discussion point
<Category>/<topic-slug>/refs.bib                bibliography, only once a claim needs grounding
<Category>/<topic-slug>/assets/                 figures the note includes (never reached with ../)
<Category>/<topic-slug>/<topic-slug>-demo.html  optional simple interactive sidecar
<Category>/<topic-slug>/scripts/                runnable helpers (.mjs, .py, .json) that produced numbers on the page
```

Copy `typst-template/note.typ` to the plain page name above and fill it in place, then compile
the PDF beside it. A new topic owns that name. Publish exactly one card per topic, pointing at
that topic's published file -- the `.pdf` for a Typst note, the `.html` for a legacy note -- so
the grid counts topics rather than files.

Treat any other layout as frozen. Notes already filed as `<slug>.html`, and deck-shaped files
(`-deck` suffixes, frame or slide markup, `#/N` deep links), are legacy pages that keep their own
vocabulary, renderer, and checks; never convert one into the other for consistency. Update an
existing HTML note in place from the file itself -- see [Legacy HTML notes](#legacy-html-notes).

Category folder -> the `data-category` chip token the card must carry:

| Folder | Chip | | Folder | Chip |
|---|---|---|---|---|
| `Algebra` | `algebra` | | `Robotics` | `robotics` |
| `Control` | `control` | | `AI-ML` | `ai` |
| `Optimization` | `optimization` | | `Tools` | `tools` |
| `Mathematics` | `math` | | | |

A card may list several chips (`data-category="algebra control"`) when the note genuinely spans
fields; it is then counted in each. Pick one category folder regardless -- the folder is the note's
home, the chips are its discoverability.

## Card recipe

Insert into `<div class="grid" id="grid">` in `index.html`, ordered with the neighbouring notes.
Copy the shape of an existing card; the parts and their roles:

```html
<a class="card" href="<Category>/<slug>/<slug>.pdf" data-category="<chips>" data-field="<Human Field Name>" data-tags="<searchable tokens>">
  <div class="toprow">
    <span class="tag amber"><Short subtopic label></span>
    <span class="read"></span>            <!-- filled by the page's reading-time script -->
  </div>
  <h3><Note title, no section number></h3>
  <p><One-paragraph hook: the problem and what the note resolves.></p>
  <div class="tags"><span class="tag-pill">token</span> ... </div>
  <span class="go">Read the note (PDF)</span>
  <span class="foot"><span class="field"><i></i><same text as data-field></span></span>
</a>
```

- The landing page is HTML and stays HTML; only the note itself is Typst. Its search box, category
  chips, reading-time estimate, and stat counts are all driven by the `.card` elements, so keep the
  structure (`class="card"`, `data-category`, `data-field`, the empty `.read` span) intact.
- `href` points at the compiled `.pdf` for a new note. Never leave a card pointing at a file that
  does not exist, and do not add a card for a demo or a `summary.md`.
- `data-tags` and the visible `tag-pill` spans should agree. Cover field, subtopic, method, and
  tools; search matches the title, description, and these tags, and every token of a multi-word
  query must match.
- `data-field` is a human label ("Numerical Linear Algebra", "Control Theory"), shown as the card
  footer and counted in the hero. It must equal the `.foot` text.
- Tag colour classes available on `.tag`: `amber`, `teal`, `purple`, `rose`. Match the neighbouring
  cards in the same category.
- Placeholder notes use `class="card soon"` and are excluded from the computed counts; a real note
  must not. `#stat-notes`, `#stat-fields`, and the per-field `#cnt-*` numbers are derived from
  `.card` elements, so never hardcode them.

## Document contract

New notes are Typst, built from `typst-template/note.typ` on the `ilm` template, and change only
their content:

- Build from the repository root, and ship a warning-free build:

  ```sh
  typst compile --root . <Category>/<slug>/<slug>.typ <Category>/<slug>/<slug>.pdf
  ```

  `--root .` is what makes the note's `#import "/.agents/skills/teach-an-engineer/typst-template/teaching.typ"`
  resolve, so the import line is identical in every note at any depth. Note-local paths
  (`assets/<name>.svg`, `refs.bib`) stay relative to the note; `../` escapes the project root.
- One `= Title <sN>` level-1 heading per deep question, labelled `s1`, `s2`, ... in order, and one
  `#question[...]` callout opening each teaching section. The setup under it carries only the
  running example, facts, assumptions, definitions, and notation needed to attempt the question.
- No intuition, takeaway, claim, proof, method-summary, worked-result, or conclusion block in a
  question map. Those live in `summary.md` or in chat.
- Displayed math is `$ ... $` with inner spaces and is numbered; inline math is `$x_k$` with no
  inner spaces. Avoid `\[ ... \]` -- verbatim math, where `x_{k+1}` does not parse. Label an
  equation `<eq:name>` when another section points at it with `#ref(<eq:name>)`.
- Figures and tables are `#figure(...)` / `#table(...)`; see [figures.md](figures.md).
- 'Ilm supplies the cover page, contents page, one section per page, and the page-numbered footer.
  Pass another 'Ilm option only when the note needs it, and say why in `summary.md`.
- Teaching deep links are `<slug>.pdf#page=N`, where `N` comes from the section-to-page map below.
  Typst emits no named destinations, so `#page=` is the fragment that works; a PDF cannot reliably
  carry a relative link out to a demo, so the note names the demo path in monospace instead.

Math renderer: Typst's own. Legacy HTML notes keep KaTeX or MathJax; never mix the two on one page,
and never "upgrade" an HTML note to Typst just to unify the series.

## Simple interactive demos

A PDF cannot be poked at, so an interactive demonstration stays hand-written HTML. That is the one
sanctioned exception to "do not create HTML to teach", and it is worth nothing unless a reader
really has to move something to attempt the question. Ceiling, all of it required:

- Filed as `<Category>/<slug>/<slug>-demo.html`, one per note, second one only if the reader asks
  mid-session. Add no landing card; the note names it and `summary.md` records it.
- Roughly 150 lines or fewer in one file: inline `<style>` plus one inline `<script>`. No
  `<script src=`, no `<link rel=`, no CDN, no external assets, no framework, no build step, no
  `../`. That rules out KaTeX too, so label with plain text or Unicode (`x' = Ax + Bu`).
- Vanilla JS driving either one 2D `<canvas>` or one inline SVG whose attributes are rewritten. At
  most three controls, each a native `<input type="range">`, `type="checkbox"`, or `<select>` with
  a real `<label>`, plus one monospace numeric readout. Redraw on input; no animation loop,
  worker, `fetch`, or storage.
- Journal styling only: serif stack, white background, navy `#1f4e79`. It is exempt from the Typst
  contract above and from the landing page's rules, but not from the answer-free rule: labels and
  any adjacent text say what to inspect, never what the sweep shows.
- When the idea needs more than that ceiling -- synchronized views, a legend, exported plots, 3D, a
  solver loop -- do not build it. Use a static generated figure plus a script in `scripts/`, or run
  the investigation in chat.

## summary.md

Fill [../templates/summary.md](../templates/summary.md) rather than designing one. Keep a short
handoff: stage, the `Artifact:` line naming the `.typ` and `.pdf`, audience assumptions, the
question / expected-insight map with its `PDF page` column, the demo path when one exists, the
current discussion point, the running example, unresolved or research-needed claims, sources
actually consulted, and checks actually performed or unavailable. Record useful learning evidence
without a transcript, mandatory explain-back, or prerequisite-status table. Follow
[sources.md](sources.md) when a section is deepened and research is actually needed.

The first artifact is a question map with the complete question chain and only the setup needed to
attempt each question. File it, compile it, and add the landing card immediately; the card points
at a real, readable PDF even though expected insights, proofs, citations, demos, and exact results
stay in the handoff or chat. Mark the handoff `question map`, record expected insights, likely
misconceptions, assessment focus, and precision-sensitive claims under the handoff headings, and
deepen the response during teaching without researching ahead or writing the answer into the note.

Refresh the section-to-page map after every compile: page numbers move when prose or figures are
added, and a stale map sends the reader to the wrong page.

## Verify

Checks are proportional to the pass. Every published revision checks the structural contract,
compiles clean, and inspects the rendered pages it changed. A deepened section checks only what it
added; a skipped or unchanged section is not rechecked. The question-map pass has no scripts,
computed numbers, or external sources to validate, so do not create checks merely to make the note
look complete.

```sh
cd "<repository-root>"                          # typst needs the repository root as cwd
T=<Category>/<slug>/<slug>.typ; P=${T%.typ}.pdf
# The grep checks below pass when they print nothing, so their non-zero exit is expected.

# Structural contract: no leftover slots, one question box per teaching section,
# no answer-revealing box, no upward paths.
grep -n 'FILL:' "$T"
sections=$(grep -c '^= ' "$T"); boxes=$(grep -c '^#question\[' "$T")
echo "sections=$sections boxes=$boxes"; test "$boxes" -eq $((sections - 1))   # -1 for Sources
grep -nE '^#(takeaway|intuition|claim)' "$T"
grep -nE '"\.\./' "$T"

# Build clean, then confirm the artifact exists.
typst compile --root . "$T" "$P"; ls -l "$P"

# Section -> PDF page map, one entry per numbered heading, in source order.
typst eval --root . 'query(heading.where(level: 1)).filter(h => h.numbering != none).map(h => str(h.location().page())).join(",")' --in "$T"
pdfinfo "$P" | grep Pages

# Confirm the pairing reads back, then look at the page rather than assume it.
pdftotext -f <page> -l <page> -layout "$P" - | head -3
pdftoppm -png -r 110 -f <page> -l <page> "$P" /tmp/<slug>-p && ls -l /tmp/<slug>-p*.png
```

Inspect every rasterized page that changed: heading and question box in place, math and figures
laid out, nothing clipped or wider than the text column, and the footer page number agreeing with
the map. The map is the Nth value for `<sN>`, so verify a section other than `s1` after any
heading or prose change.

For a demo, run its ceiling checks and then drive it:

```sh
D=<Category>/<slug>/<slug>-demo.html
wc -l "$D"                                                     # at most ~150
grep -nE '<script[[:space:]]+src=|<link[[:space:]]+rel|https?://|\.\./' "$D"   # must print nothing
python3 - "$D" <<'PY'                                          # the inline script must parse
import re, subprocess, sys, tempfile
src = open(sys.argv[1]).read()
scripts = re.findall(r"<script[^>]*>(.*?)</script>", src, re.S)
for i, js in enumerate(scripts):
    with tempfile.NamedTemporaryFile("w", suffix=f"_{i}.js", delete=False) as f:
        f.write(js); name = f.name
    subprocess.run(["node", "--check", name], check=True)
print(f"{len(src.splitlines())} lines, {len(scripts)} inline script(s) parse")
PY
```

No browser is on `PATH` in this environment, so a demo's behavior is confirmed by opening it --
`python3 -m http.server 8000` at the repository root and
`http://localhost:8000/<Category>/<slug>/<slug>-demo.html` -- and moving each control. If no
browser is available, record in `summary.md` that the demo was parse-checked but not rendered,
instead of implying it was. Where a headless browser does exist, a screenshot of the demo page is
the better check:

```sh
firefox --headless --screenshot=/tmp/<slug>-demo.png --window-size=1280,900 \
  "file://$PWD/<Category>/<slug>/<slug>-demo.html"; ls -l /tmp/<slug>-demo.png
```

When a card or cross-link changed, serve the repo and open `http://localhost:8000/index.html` to
confirm the affected card appears, that filters find it, and that its `href` resolves. Cache-bust
a re-render with `?v=$(date +%s)`. Use absolute paths and `ls` the output after a render batch,
because a missing file is the only signal that a command did nothing. Disclose any check that could
not run, and do not build new verification infrastructure for routine page work.

For a deepened section, run only its relevant checks: confirm the exact passage for a sourced
claim; one reproducible script for a computed number; the demo smoke test; a changed deep link or
landing-card link. Keep the result in the assessment or handoff, and do not add the expected answer
to the question map. Do not repeat a completed check, read a whole paper, or re-verify a claim
already supported unless the source, claim, or version changed.

## Legacy HTML notes

The site's older notes are self-contained HTML pages, and there is no template file for them any
more. When asked to update one, work from the file itself and keep its contract: serif on white
`#ffffff` with navy `#1f4e79`, a centered `h1` and italic `p.hero`, numbered `h2 id="sN"` sections
divided by `hr`, `nav.toc` with its scroll-spy script, `.eq` for displayed math with the page's own
renderer (`\( ... \)` inline, `\[ ... \]` displayed), `.figure` with `.figure-caption`, `.demo` for
an interactive widget, and the responsive rules below ~700px. Legacy pages may use `Intuition:` and
`Takeaway:` callouts; a question map may not.

Verify those pages the way they were built -- structural grep plus two renders:

```sh
P=<Category>/<slug>/<slug>.html                                  # absolute path
grep -n 'FILL:' "$P"
diff <(grep -o 'href="#[^"]*"' "$P" | cut -d'"' -f2 | sed 's/#//' | sort -u) \
     <(grep -o '<h[12][^>]*id="[^"]*"' "$P" | sed 's/.*id="//;s/"//' | sort -u)
grep -c '<h[23] id="s[0-9]' "$P"; grep -c '<strong>Question:</strong>' "$P"
grep -on 'src="\.\./\|href="\.\./' "$P"
firefox --headless --screenshot=/tmp/<slug>-desktop.png --window-size=1440,2600 "file://$P"
firefox --headless --screenshot=/tmp/<slug>-narrow.png --window-size=420,2600 "file://$P"
```

Inline SVG beats an embedded raster there, and a data-heavy page past a few hundred kilobytes means
the rasters belong in `assets/` rather than inlined.

## Provenance and housekeeping

- Name the producing script once near the numbers it generated ("all figures computed by
  `scripts/verify_<slug>.py`"), and keep computed numbers reproducible.
- Commit source: `.typ`, `summary.md`, `refs.bib`, figures, the demo HTML, and the small scripts that
  reproduce on-page numbers. Commit the compiled `.pdf` as well, because GitHub Pages runs no build
  step and the PDF is what readers open -- it is the served artifact, not a disposable build dump.
  Keep out caches, `/tmp` paper downloads, extracted source text, and any other generated site
  artifact.
- Do not add a Jekyll front-matter header or move notes into `_posts/`; this site is hand-written and
  served as-is by GitHub Pages.
- `@preview/ilm:2.1.1` is fetched on first use into the local Typst package cache (`~/.cache/typst`),
  which is not part of the repository. Note in the handoff if a build could not be reproduced
  offline.
