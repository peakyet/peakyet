# Repo notes

How a `teach-an-engineer` artifact lands in this repository. The repo's `AGENTS.md` is
authoritative; this file only restates it as steps. Read `AGENTS.md` too, because it changes.

## Tree

```text
index.html                                      landing page: every published note is a card in #grid
<Category>/<topic-slug>/<topic-slug>.typ        complete explanation, sections as the idea needs
<Category>/<topic-slug>/<topic-slug>.pdf        the compiled note; this is what the card links to
<Category>/<topic-slug>/summary.md              scope, explanation progression, sources, checks
<Category>/<topic-slug>/refs.bib                bibliography, only once a claim needs grounding
<Category>/<topic-slug>/assets/                 figures the note includes (never reached with ../)
<Category>/<topic-slug>/<topic-slug>-demo.html  optional simple interactive sidecar
<Category>/<topic-slug>/scripts/                runnable helpers (.mjs, .py, .json) that produced numbers on the page
```

Copy `typst-template/note.typ` to the plain page name above and fill it in place, then compile
the PDF beside it. A new topic owns that name. Publish exactly one card per topic, pointing at
that topic's published file -- the `.pdf` for a Typst note, the `.html` for a legacy note -- so
the grid counts topics rather than files.

Keep sample explanations and private review evidence in the environment's review-artifact
directory. In this workspace that is `.amp/in/artifacts/`, with `/.amp/in/` in the repository-local
exclude file. Drafts have no card and do not replace an existing published note. A sample may
contain a complete local derivation without being the complete promised topic.

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

Use [SKILL.md](../SKILL.md) for the writing workflow, and the
[template router](../templates/README.md) for Typst layout, filling, and math syntax.
Teaching links are `<slug>.pdf#page=N`, with `N` from the page map below. Name the demo path in
monospace in the PDF and send a clickable demo link in chat; relative links out of PDFs are unreliable.

## Simple interactive demos

A PDF cannot be poked at, so an interactive demonstration stays hand-written HTML. That is the one
sanctioned exception to "do not create HTML to teach". Use successive static pictures by default;
add a demo when manipulating an object materially helps explain the relationship. Ceiling,
all of it required:

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
  contract above and from the landing page's rules. The demo's labels and prose may state what
  the reader will see, since nothing is hidden.
- When the idea needs more than that ceiling -- synchronized views, a legend, exported plots, 3D, a
  solver loop -- do not build it. Use a static generated figure plus a script in `scripts/`, or run
  the investigation in chat.

## summary.md

Fill [../templates/summary.md](../templates/summary.md): scope, explanation progression, next
revision, sources, and checks. It is a production log, not an understanding state or learner
dossier. Keep the sample discussion and private review evidence in artifacts. Refresh the page
column after every compile.

## Verify

Before drafting a sample, check the mechanism, each quantity's meaning, assumptions, boundary
conditions, and essential derivation. Choose a case where a plausible wrong implementation or
interpretation would produce a different answer. Check extensions from scalar to matrix examples
and distinguish example evidence from general proof. Inspect exact source passages supporting
borrowed interpretations, not merely the final formulas.

Before delivery, follow the private evidence chain from assumed start through each essential
transition to its actual passage or figure. Confirm that the reader can follow the sequence
without adopting unexplained machinery. Execute exact displayed runnable snippets, including
initialization, stopping branches, and quoted outputs. A working helper script is insufficient
when the published listing differs. Every delivered revision also checks applicable structure,
rendered pages, numerical results, citations, and links. Do not repeat unaffected checks.

```sh
cd "<repository-root>"                          # typst needs the repository root as cwd
T=<Category>/<slug>/<slug>.typ; P=${T%.typ}.pdf
# The grep checks below pass when they print nothing, so their non-zero exit is expected.

# Structural contract: no leftover slots or upward asset paths. Callouts are optional.
grep -n 'FILL:' "$T"
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

Inspect every changed rasterized page using a media viewer with an objective naming the expected
result. Check sequential panels, mathematical coordinates, arrows and labels, readable equations,
clipping, and footer/page-map agreement. The map is the Nth value for `<sN>` when all teaching
sections use sequential labels and other numbered headings follow them; verify the actual heading
page before sending its link. Optional `#check` exercises always have visible answers.

For content review, verify the essential derivations and the correspondence between mathematical
objects and pictures. A one-line introduction does not explain a quantity; an adjacent display
does not justify its transition. Phrase searches and callout counts cannot certify coverage.
Use the general review patterns in [teaching-patterns.md](teaching-patterns.md) to check for gaps.
Technical checks establish artifact quality. Reader feedback establishes whether the explanation
works for them; neither approval nor correct numerical output proves comprehension.

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

Use an available browser to move each control and inspect the result. Serve with
`python3 -m http.server 8000` at the repository root if needed. A screenshot alone does not test
control behavior; inspect the capture as well. If no browser is available, record that the demo
was parse-checked but not rendered. For example, where Firefox is installed:

```sh
firefox --headless --screenshot=/tmp/<slug>-demo.png --window-size=1280,900 \
  "file://$PWD/<Category>/<slug>/<slug>-demo.html"; ls -l /tmp/<slug>-demo.png
```

When a card or cross-link changed, serve the repo and open `http://localhost:8000/index.html` to
confirm the affected card appears, that filters find it, and that its `href` resolves. Cache-bust
a re-render with `?v=$(date +%s)`. Use absolute paths and `ls` the output after a render batch,
because a missing file is the only signal that a command did nothing. Disclose any check that could
not run, and do not build new verification infrastructure for routine page work.

When only part of a note changed, run only its relevant checks: the changed rendered page, the
refreshed section-to-page map, one reproducible script for any quoted number, the exact passage
for any newly cited claim, the demo smoke test, and any changed deep or landing-card link. Do not
repeat a completed check, read a whole paper, or re-verify a claim already supported unless the
source, claim, or version changed.

## Legacy HTML notes

The site's older notes are self-contained HTML pages, and there is no template file for them any
more. When asked to update one, work from the file itself and keep its contract: serif on white
`#ffffff` with navy `#1f4e79`, a centered `h1` and italic `p.hero`, numbered `h2 id="sN"` sections
divided by `hr`, `nav.toc` with its scroll-spy script, `.eq` for displayed math with the page's own
renderer (`\( ... \)` inline, `\[ ... \]` displayed), `.figure` with `.figure-caption`, `.demo` for
an interactive widget, and the responsive rules below ~700px. Their existing `Question:` callouts,
`.callout` (with its `.takeaway` and `.intuition` variants), `.eq` blocks, and `.figure` blocks
are part of their own markup -- edit them in place from the file's own conventions.

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
