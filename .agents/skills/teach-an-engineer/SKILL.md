---
name: teach-an-engineer
description: "Explain a topic like I'm a well-educated engineer and land it as a note in this knowledge base: a figure-driven, single-HTML explainer with small demos, filed under a category folder and linked from the landing page. Use for /teach-an-engineer, picture-style explanations, or requests to understand how something works; do not use for ordinary prose-only answers."
---

# teach-an-engineer

Create a single HTML note, in this repository's note style, for an engineer who is new to the topic but comfortable with basic algebra and calculus. Build intuition first, then add rigor: explain the underlying why and how rather than presenting formulas and definitions to memorize. Research the topic before writing, in proportion to how current, technical, or unfamiliar it is.

The output is a note in an existing series, not a throwaway file. The repository's `AGENTS.md` owns file layout and note-page style; [references/repo-notes.md](references/repo-notes.md) turns that into concrete steps for a new note.

Governing rule: prose is the scarce resource. Spend it on the **motivation** and the **core idea**; everywhere else, demonstrate with figures, examples, and demos in a few brief sentences, in plain language. Do not trade away a necessary explanation just to make the page shorter.

## 1. Gauge the audience

Use an exhaustive, adaptive depth-first walk over the prerequisite tree. Do not assume that the reader knows any baseline except basic algebra and calculus; every prerequisite that the explanation relies on must be explicitly calibrated.

1. **Build lazily.** Make the topic the root. Add a child only when the current explanation genuinely depends on it. Expand a child into its own prerequisites when the reader is not comfortable with it, and do not add unrelated branches speculatively.
2. **Walk depth-first.** Start with the prerequisite that the first section needs. Ask whether the reader is comfortable with that node, or with a genuinely coherent cluster when the answer can apply to every item in it. A clear “yes” marks that node or cluster known and lets DFS continue; a “no”, “partly”, or unclear answer marks it as needing support and descends into its first unresolved prerequisite. Reuse an answer for shared prerequisites rather than asking twice, but do not infer knowledge from silence, job title, wording, or the assumed audience.
3. **Stop only when calibration is complete.** Continue asking until every prerequisite needed by the planned explanation has an explicit status: confirmed comfortable, or confirmed as a gap whose own relevant prerequisites have also been checked. The first unresolved gap determines where teaching begins. If an unfamiliar leaf is found, treat it as a first-class context in the explanation, not as a minimal primer: explain its motivation, core idea, and underlying mathematical theorem (or governing principle when it is not mathematical) with the same care as the main topic before building on it. That gap is an explicit result, not an assumption. Do not write or deliver the artifact while required calibration questions remain unanswered.

Do not expose the tree or its bookkeeping to the reader. The purpose of DFS is to establish the explanation's entry point without silently skipping prerequisites. The traversal may take as many short rounds as the dependency tree requires, but each question should cover the smallest coherent subtree that can be resolved without losing calibration precision.

## 2. Research and outline

- Verify technical claims against reputable primary or authoritative sources. Use current web research for changing facts and use the `wolfram-mcp` skill for exact mathematical checks or reference plots when appropriate. Do not invent citations, outputs, or experiments.
- Choose one concrete running example that can survive the whole explanation. Make the opening a question, paradox, or concrete failure that the example will resolve; do not start with a dictionary definition.
- Outline the mechanism before writing prose: problem, naive approach and its failure, core idea, worked example, edge cases or tradeoffs, and connection to the broader framework. Drop any section that does not help the reader predict, use, or debug the idea.
- Note which existing notes the topic touches while outlining; a cross-link at the end of a section is usually the cheapest way to place a new note inside the series.

## 3. Write the explanation

- Spend depth where it counts: before introducing an idea, state the problem it solves and why solving it matters, then work through it patiently in plain words, concrete examples, and small steps. This is the only prose allowed to run long.
- Teach every confirmed knowledge gap at full explanatory depth before relying on it: give the motivation, the central idea, and the underlying theorem or governing principle, then connect it back to the main topic. Do not hide an unfamiliar leaf in a parenthetical definition or compress it into an unexplained prerequisite.
- Minimize terminology. Introduce a term only when the reader needs its name, anchor it to an example or figure, and never define it only with other unfamiliar terms.
- Demonstrate, do not merely describe. Each central idea needs at least one primary carrier: a figure, a worked example, or a small interactive demo. Add the others only when they reveal a different aspect. Follow [references/figures.md](references/figures.md) for figures.
- Use two to four prediction prompts or productive failures when they clarify a likely misconception. Reveal the answer and why the tempting answer fails immediately; close every question or loop that the page opens.
- End every section with a one-sentence takeaway, using the template's `intuition` and `takeaway` callouts. Keep the sequence of takeaways coherent when read by itself.
- Keep demos minimal: one idea, one short source file, and output that fits on one screen. Run every executable demo yourself and include the actual output. If a demo cannot be run, label it as unverified and do not present its output as fact.
- Define symbols on first use and keep notation consistent. Render equations with the template's math engine at LaTeX quality: proper variables, spacing, fractions, exponents, and operators.
- Progress from the core idea to variations, limits, and tradeoffs, then connect it to related theory. End with a concise list of reputable resources, each with a one-line note about what it adds.

## 4. Land the note in the repo

- Read the repository's `AGENTS.md` first. Where it and this skill overlap, it wins on style and file layout and this skill wins on pedagogy.
- Read `templates/README.md` and start the page from the `note-page.html` template; it is the note style this repo already uses (serif on paper, gold accents, KaTeX, `.callout`, `.figure`, sticky `.toc`). Light background, dark text. Build a custom template only if the user asks for one.
- Derive a filesystem-safe slug from the topic and choose the single category folder the note belongs to: `Algebra`, `Control`, `Mathematics`, `Optimization`, `Robotics`, `AI-ML`, or `Tools`. Never use raw user text as a path.
- Save the page as `<Category>/<topic-slug>/<topic-slug>.html` — the file name repeats the folder name; a note has no `index.html`. If a note already exists for this topic, update it in place instead of writing a second page, and never overwrite an unrelated note.
- Keep the reader-facing artifact as one HTML file. Prefer inline HTML, CSS, SVG, and JavaScript; put generated figures in `assets/` and runnable helpers in `scripts/` beside the page, referenced relatively, and keep any external dependency obvious and local to the note folder. The template's KaTeX CDN is acceptable unless offline output is requested.
- Save `summary.md` beside the page: audience calibration, the prerequisite map, the running example with its verified numbers, and which claims were confirmed by running code. Regenerate it whenever the page changes.
- Add a card for the note to `#grid` in `index.html` using the recipe in [references/repo-notes.md](references/repo-notes.md). Search, category chips, reading times, and the field counts are all computed from that grid, so keep every attribute filled.
- Link to sibling notes where the relation is real, so the page sits inside the series rather than beside it. Use `../<sibling-slug>/<sibling-slug>.html` within a category and `../../<Category>/<sibling-slug>/<sibling-slug>.html` across categories; every `href` must resolve to a file that exists.
- Use semantic HTML (`figure`/`figcaption`, headings, lists, tables, and labeled controls), meaningful alt text or a nearby text equivalent for every non-decorative figure, keyboard-accessible demos, and responsive dimensions. Avoid visual styling that makes labels, equations, or controls overlap or clip.

## 5. Verify and follow up

- Before delivery, render the page and inspect it at both a desktop and a narrow viewport, using the verification commands in [references/repo-notes.md](references/repo-notes.md). Check that math renders, figures and controls are usable, links and local assets resolve, and no content overlaps or clips. If browser inspection is unavailable, perform static checks and say what was not inspected.
- Check the wiring, not only the page: the card is in `#grid`, its `href` and filter classes are real, cross-links resolve, and no unrelated note or landing-page entry was disturbed.
- Deliver the note and `summary.md` together, name the category and slug the note landed in, then invite questions. Answer follow-ups briefly and plainly, using a figure, example, or demo where useful. Do not require a quiz before delivering the artifact.
- If the user engages in a teaching follow-up, correct misconceptions, revise the relevant section in place, and refresh `summary.md` with the final understanding. Offer an optional short comprehension check; do not force one or claim that every section is understood without evidence.

## Tools

For math, verification, or reference plots, use the `wolfram-mcp` skill when it is the right tool; C++, Python, JavaScript, Octave, or another suitable tool is fine for behavioral demos. Follow the relevant tool or skill instructions before using it.

Topic: $ARGUMENTS
