---
name: teach-an-engineer
description: "Explain a topic like I'm a well-educated engineer and land it as a note in this knowledge base: a figure-driven, single-HTML explainer with small demos, filed under a category folder and linked from the landing page. Use for /teach-an-engineer, picture-style explanations, or requests to understand how something works; do not use for ordinary prose-only answers."
---

# teach-an-engineer

Create a single HTML note, in this repository's note style, for an engineer who is new to the topic but comfortable with basic algebra and calculus. Build intuition first, then add rigor: explain the underlying why and how rather than presenting formulas and definitions to memorize. Research the topic before writing, in proportion to how current, technical, or unfamiliar it is.

The output is a note in an existing series, not a throwaway file. The repository's `AGENTS.md` owns file layout and note-page style; [references/repo-notes.md](references/repo-notes.md) turns that into concrete steps for a new note.

Governing rule: prose is the scarce resource. Spend it on the **motivation** and the **core idea**; everywhere else, demonstrate with figures, examples, and demos in a few brief sentences, in plain language. Do not trade away a necessary explanation just to make the page shorter.

## 1. Set up the teaching session

Before teaching the first section, establish the route and create a recoverable draft. Do not require the user to complete a global prerequisite interview before seeing the artifact.

1. Read the repository instructions, [templates/README.md](templates/README.md), and [references/repo-notes.md](references/repo-notes.md).
2. Research the topic enough to identify the central problem, a durable running example, authoritative sources, likely misconceptions, and real cross-links. Use current web research for changing facts and use the `wolfram-mcp` skill for exact mathematical checks or reference plots when appropriate. Do not invent citations, outputs, or experiments.
3. Propose an initial section outline. The outline should normally move from motivation and failure mode to core mechanism, worked example, limits or tradeoffs, and broader connections. Make it adaptable: split, reorder, or revisit sections when the user's questions reveal that the route needs to change.
4. Derive a filesystem-safe slug and choose the single category folder: `Algebra`, `Control`, `Mathematics`, `Optimization`, `Robotics`, `AI-ML`, or `Tools`.
5. Create the note folder and copy [templates/note-page.html](templates/note-page.html) into `<Category>/<topic-slug>/<topic-slug>.html`. Keep the valid HTML shell, CSS, active math renderer, metadata, and TOC. Mark the source as a draft with an unobtrusive HTML comment or equivalent source-level marker; do not add the note to `index.html` yet.
6. Create or update `summary.md` beside the page. Record the outline, current section, audience assumptions, prerequisite status known so far, running example, and any claims that still need verification.

The draft page is the artifact's persistent shell. Only sections that have passed the understanding gate are considered finalized content. Do not make an incomplete note discoverable from the landing page.

## 2. Teach one section at a time

Use this lifecycle for every section. Stay in the current section until its gate is passed; never silently advance because the user gave a vague or incomplete answer.

### 2.1 Announce the section

State, in plain language:

- the question or problem this section resolves;
- why the section matters to the running example;
- the mental model the user should leave with; and
- what the user should be able to explain, predict, or debug afterward.

Do not begin with a dictionary definition when a concrete failure, question, or paradox can motivate the section.

### 2.2 Probe locally

Build a small, section-specific prerequisite map lazily. Ask only the probing questions needed for this section and do not expose the internal tree or bookkeeping.

- Check each prerequisite before relying on it; do not infer knowledge from silence, job title, wording, or the assumed audience.
- Ask about a coherent cluster only when one answer can genuinely establish the status of every item in that cluster.
- If the user is comfortable, mark the prerequisite as confirmed and continue.
- If the user is unsure, partly comfortable, or unclear, teach that gap before building on it.
- Reuse confirmed prerequisite knowledge when it is shared by later sections, but re-probe when the new use is materially different.

### 2.3 Explain and guide

Teach the section through short interactive loops rather than delivering the whole note at once:

- motivate the idea before introducing notation;
- use the running example, one useful figure or demo, and equations only where they make the mechanism predictable;
- ask probing questions, prediction prompts, or productive-failure questions at the point where they diagnose understanding;
- reveal the answer and explain why a tempting alternative fails;
- teach an unfamiliar prerequisite with its motivation, central idea, and underlying theorem or governing principle before relying on it;
- keep symbols defined on first use and notation consistent; and
- do not write unverified demo output as fact.

A question is a teaching instrument, not a quiz gate by itself. Keep explaining and narrowing the question until the user can connect the mechanism to the section's problem.

### 2.4 Apply the understanding gate

A section is understood only after all of the following:

1. The user explains the core mechanism in their own words.
2. The user answers at least one targeted prediction or application check when the concept admits one.
3. The agent corrects any remaining misconception in the conversation.
4. The user explicitly confirms that the explanation is clear enough to continue.

If any part is missing or incorrect, stay in the section, ask a narrower question, and teach again. Do not write the section as finalized, claim that the user understands it, or move to the next section until the gate is satisfied. The gate should be lightweight for a familiar section and more guided for a genuine prerequisite gap.

### 2.5 Finalize and transition

Once the gate is passed:

1. Write the finished section into the draft HTML using the repository's note style. Include the relevant intuition and takeaway callouts, figures, equations, demos, cross-links, and source notes.
2. Update `summary.md` with the section's completion status, the user's concise explain-back or prediction evidence, the running-example values, and claims verified by code or authoritative sources.
3. Show the user a concise summary of what was saved and identify the next section in the outline.
4. Ask whether to begin the next section. If the user pauses, leave the draft and `summary.md` in a state that can resume at the first incomplete section.

If a later section exposes a flaw in an earlier explanation, revisit the earlier section, update affected downstream prose or links, and refresh `summary.md` before continuing.

## 3. Write the explanation well

- Spend depth where it counts: before introducing an idea, state the problem it solves and why solving it matters, then work through it patiently in plain words, concrete examples, and small steps. This is the only prose allowed to run long.
- Teach every confirmed knowledge gap at full explanatory depth before relying on it: give the motivation, central idea, and underlying theorem or governing principle, then connect it back to the main topic. Do not hide an unfamiliar leaf in a parenthetical or one-line definition.
- Prefer one running example that survives the whole explanation. Add another example, figure, or small interactive demo only when it reveals a genuinely different aspect.
- Use two to four prediction prompts or productive failures where they clarify likely misconceptions. Reveal the answer and why the tempting answer fails immediately; close every question or loop that the page opens.
- End every completed section with a one-sentence takeaway, using the template's `intuition` and `takeaway` callouts. Keep the sequence of takeaways coherent when read by itself.
- Keep demos minimal: one idea, one short source file, and output that fits on one screen. Run every executable demo yourself and include the actual output. If a demo cannot be run, label it as unverified and do not present its output as fact.
- Define symbols on first use and keep notation consistent. Render equations with the template's math engine at LaTeX quality: proper variables, spacing, fractions, exponents, and operators.
- Progress from the core idea to variations, limits, and tradeoffs, then connect it to related theory. End the completed note with a concise list of reputable resources, each with a one-line note about what it adds.

## 4. Land the completed note in the repo

- Read the repository's `AGENTS.md` first. Where it and this skill overlap, it wins on style and file layout and this skill wins on pedagogy.
- Read `templates/README.md` and start the page from `note-page.html`; it is the note style this repo already uses (serif on paper, gold accents, KaTeX, `.callout`, `.figure`, sticky `.toc`). Light background, dark text. Build a custom template only if the user asks for one.
- Save the page as `<Category>/<topic-slug>/<topic-slug>.html` — the file name repeats the folder name; a note has no `index.html`. If a note already exists for this topic, update it in place instead of writing a second page, and never overwrite an unrelated note.
- Keep the reader-facing artifact as one HTML file. Prefer inline HTML, CSS, SVG, and JavaScript; put generated figures in `assets/` and runnable helpers in `scripts/` beside the page, referenced relatively, and keep any external dependency obvious and local to the note folder. The template's KaTeX CDN is acceptable unless offline output was requested.
- Save `summary.md` beside the page throughout the session, not only at the end. It is the handoff file for resuming section-by-section teaching.
- Add a card for the note to `#grid` in `index.html` only after every planned section is finalized, all required resources are present, and the note passes final verification. Use the recipe in [references/repo-notes.md](references/repo-notes.md). Search, category chips, reading times, and field counts are all computed from that grid, so keep every attribute filled.
- Link to sibling notes where the relation is real, so the page sits inside the series rather than beside it. Use `../<sibling-slug>/<sibling-slug>.html` within a category and `../../<Category>/<sibling-slug>/<sibling-slug>.html` across categories; every `href` must resolve to a file that exists.
- Use semantic HTML (`figure`/`figcaption`, headings, lists, tables, and labeled controls), meaningful alt text or a nearby text equivalent for every non-decorative figure, keyboard-accessible demos, and responsive dimensions. Avoid visual styling that makes labels, equations, or controls overlap or clip.

## 5. Verify and follow up

- Before adding the landing-page card, render the completed page and inspect it at both a desktop and a narrow viewport, using the verification commands in [references/repo-notes.md](references/repo-notes.md). Check that math renders, figures and controls are usable, links and local assets resolve, and no content overlaps or clips. If browser inspection is unavailable, perform static checks and say what was not inspected.
- Check the wiring, not only the page: the card is in `#grid`, its `href` and filter classes are real, cross-links resolve, and no unrelated landing-page entry was disturbed.
- Check that no draft marker or placeholder section remains in the completed artifact, that every section has a takeaway, and that `summary.md` records the final calibration and verification state.
- Add the landing-page card only after these checks. Then verify that filters find it, reading time and counts update, and its link resolves.
- Deliver the note and `summary.md` together, name the category and slug the note landed in, and invite questions. Answer follow-ups briefly and plainly, using a figure, example, or demo where useful.
- If the user engages in a teaching follow-up, correct misconceptions, revise the relevant section in place, and refresh `summary.md` with the final understanding. Offer an optional short comprehension check; do not force a new quiz after the note is complete.

## Tools

For math, verification, or reference plots, use the `wolfram-mcp` skill when it is the right tool; C++, Python, JavaScript, Octave, or another suitable tool is fine for behavioral demos. Follow the relevant tool or skill instructions before using it.

Topic: $ARGUMENTS
