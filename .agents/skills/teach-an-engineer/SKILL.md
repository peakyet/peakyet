---
name: teach-an-engineer
description: "Explain a topic like I'm a well-educated engineer and land it in this knowledge base as a Beamer-style slide deck: a figure-driven, single-HTML artifact with small demos, filed under a category folder and linked from the landing page. Teach it one section at a time from the slides, with a deep link to the new frame rather than an explanation typed into the terminal. Use for /teach-an-engineer, picture-style explanations, or requests to understand how something works; do not use for ordinary prose-only answers."
---

# teach-an-engineer

Create a single HTML slide deck for an engineer who is new to the topic but comfortable with basic algebra and calculus, built from [templates/beamer-deck.html](templates/beamer-deck.html), the skill's only template. Build intuition first, then add rigor: explain the underlying why and how rather than presenting formulas and definitions to memorize. The deck is the teaching medium, not a transcript of the conversation: everything the user needs to understand a section belongs on a frame. Research the topic before writing, in proportion to how current, technical, or unfamiliar it is.

The output is a page in an existing series, not a throwaway file. The repository's `AGENTS.md` owns file layout and page style; [references/repo-notes.md](references/repo-notes.md) turns that into concrete steps for a new page.

Governing rule: prose is the scarce resource. Spend it on the **motivation** and the **core idea**; everywhere else, demonstrate with figures, examples, and demos in a few brief sentences, in plain language. Do not trade away a necessary explanation just to make the page shorter.

## 1. Set up the teaching session

Before teaching the first section, establish the route and create a recoverable draft. Do not require the user to complete a global prerequisite interview before seeing the artifact.

1. Read the repository instructions, [templates/README.md](templates/README.md), and [references/repo-notes.md](references/repo-notes.md).
2. Research the topic enough to identify the central problem, a durable running example, authoritative sources, likely misconceptions, and real cross-links. Use current web research for changing facts and use the `wolfram-mcp` skill for exact mathematical checks or reference plots when appropriate. Do not invent citations, outputs, or experiments.
3. Propose an initial section outline. The outline should normally move from motivation and failure mode to core mechanism, worked example, limits or tradeoffs, and broader connections. Make it adaptable: split, reorder, or revisit sections when the user's questions reveal that the route needs to change. Plan each section as three to five frames with one claim per frame, and say so in the outline the user sees.
4. Derive a filesystem-safe slug and choose the single category folder: `Algebra`, `Control`, `Mathematics`, `Optimization`, `Robotics`, `AI-ML`, or `Tools`.
5. Create the folder and copy [templates/beamer-deck.html](templates/beamer-deck.html) into `<Category>/<topic-slug>/<topic-slug>.html`, or into `<Category>/<slug>/<slug>-deck.html` when a page already owns that slug. Keep the valid HTML shell, CSS, KaTeX setup, metadata, outline frame, and foot bands. Mark the source as a draft with an unobtrusive HTML comment or equivalent source-level marker; do not add the page to `index.html` yet.
6. Create or update `summary.md` beside the page. Record the outline with each section's planned frame range, the current section, audience assumptions, prerequisite status known so far, running example, and any claims that still need verification. The frame ranges are what let the next session deep-link straight at the section being taught.

The draft deck is the artifact's persistent shell, and it grows one section at a time: a section's frames exist on the page before that section is discussed. Only sections that have passed the understanding gate are considered finalized content. Do not make an incomplete page discoverable from the landing page.

## 2. Teach one section at a time, from the slides

**Slide-first rule.** Teach a section from the artifact, not from the terminal. Build the section's frames first, hand over a deep link to its first frame, and let the frames carry the motivation, the figure, the mechanism, and the questions. Keep each terminal message to two or four lines: what to open, what to look at, and what you need back. Do not teach a section in chat and do not run the questioning in chat; a long explanation typed into the terminal is a defect that means the frame is missing content. Only the user's answers, and your one-or-two-sentence correction of them, belong in the terminal.

Use this lifecycle for every section. Stay in the current section until its gate is passed; never silently advance because the user gave a vague or incomplete answer.

### 2.1 Frame the section before saying anything

Write the outline entry into the deck first, then point at it. One section is one divider plus three to five frames:

- a `.section` divider stating the question this section resolves and the mental model to leave with, in a `block.intuition`;
- content frames that motivate before they name, then work the running example with one figure or demo and only the equations that make the mechanism predictable;
- the prediction prompt on the frame, with the tempting answer and why it fails behind `data-fragment`, so the question is part of the slide and the answer arrives on a key press;
- a `block.takeaway` closing the section.

Then announce it in one short message: the question in a clause, the deep link `file:///.../<slug>.html#/<N>` at the section's first frame, and what the user should be able to explain, predict, or debug afterward. Do not deliver the explanation in that message. Do not open with a dictionary definition when a concrete failure, question, or paradox can motivate the section.

### 2.2 Probe from the slide

Build a small, section-specific prerequisite map lazily, and do the probing through the frames rather than an interview in chat. Do not expose the internal tree or bookkeeping.

- Let the frame's prediction prompt be the probe: ask the user to answer it after reading, instead of questioning them before the slide exists.
- Check each prerequisite before relying on it; do not infer knowledge from silence, job title, wording, or the assumed audience.
- Ask about a coherent cluster only when one answer can genuinely establish the status of every item in that cluster.
- When an answer shows a gap, teach the gap on a new frame, with its motivation, central idea, and underlying theorem or governing principle, and link it into the section. Do not fill the gap with a paragraph in the terminal.
- Reuse confirmed prerequisite knowledge when it is shared by later sections, but re-probe when the new use is materially different.

### 2.3 Guide the reading

Once the user has the frame open, keep the loop short and in the frame's terms:

- point at the part of the frame that carries the mechanism ("the dashed line in Figure 1, then the second overlay") instead of restating it;
- when a question needs narrowing, write the narrower question onto the frame as another overlay and ask the user to advance to it; keep explaining and narrowing until the user connects the mechanism to the section's problem;
- reveal a failed tempting answer by advancing the overlay, then add one sentence on why it fails;
- keep symbols defined on first use and notation consistent; and
- do not write unverified demo output as fact.

A question is a teaching instrument, not a quiz gate by itself.

### 2.4 Apply the understanding gate

A section is understood only after all of the following, with the frames on screen:

1. The user explains the core mechanism in their own words, referring to the frame.
2. The user answers at least one targeted prediction or application check when the concept admits one.
3. The agent corrects any remaining misconception: by editing the frame when the frame caused it, and in one or two terminal sentences when the reading did.
4. The user explicitly confirms that the explanation is clear enough to continue.

If any part is missing or incorrect, stay in the section: revise the frame, add a narrower prompt as an overlay, and ask again. Do not fall back to typing the lesson into the terminal. Do not write the section as finalized, claim that the user understands it, or move to the next section until the gate is satisfied. The gate should be lightweight for a familiar section and more guided for a genuine prerequisite gap.

### 2.5 Finalize and transition

Once the gate is passed:

1. Bring the section's frames to finished form, since they were written before the discussion: replace every placeholder you drafted against, cut what the conversation made redundant, keep the `block.intuition` / `block.takeaway` callouts, figures, equations, demos, cross-links, and source notes, and clear any `overfull` tag. Do not leave a lesson that only exists in the transcript: if the gate was passed through chat, move that content onto a frame.
2. Update `summary.md` with the section's completion status, its final frame range, the user's concise explain-back or prediction evidence, the running-example values, and claims verified by code or authoritative sources.
3. Tell the user in one or two lines what changed on the page, and identify the next section in the outline.
4. Ask whether to begin the next section. If the user pauses, leave the draft and `summary.md` in a state that can resume at the first incomplete section.

If a later section exposes a flaw in an earlier explanation, revisit the earlier frames, update affected downstream content or links, and refresh `summary.md` before continuing.

## 3. Write the explanation well

- Spend depth where it counts: before introducing an idea, state the problem it solves and why solving it matters, then work through it patiently in plain words, concrete examples, and small steps. This is the only content allowed to run long, and it runs long across frames, not in the terminal.
- Write for the frame, not the chat: when an explanation would take more than a few sentences to type, it needs its own frame with a claim, a figure or example, and a takeaway. Two or four terminal lines per section is the target.
- Teach every confirmed knowledge gap at full explanatory depth before relying on it: give the motivation, central idea, and underlying theorem or governing principle, then connect it back to the main topic. Do not hide an unfamiliar leaf in a parenthetical or one-line definition.
- Prefer one running example that survives the whole explanation. Add another example, figure, or small interactive demo only when it reveals a genuinely different aspect.
- Use two to four prediction prompts or productive failures where they clarify likely misconceptions. Put each one on the frame that raises it, with the answer behind `data-fragment` so it arrives on the next key press; close every question or loop that the page opens.
- End every completed section with a one-sentence takeaway, using the template's `intuition` and `takeaway` callouts. Keep the sequence of takeaways coherent when read by itself.
- Keep demos minimal: one idea, one short source file, and output that fits on one screen. Run every executable demo yourself and include the actual output. If a demo cannot be run, label it as unverified and do not present its output as fact.
- Define symbols on first use and keep notation consistent. Render equations with the template's math engine at LaTeX quality: proper variables, spacing, fractions, exponents, and operators.
- Progress from the core idea to variations, limits, and tradeoffs, then connect it to related theory. End the deck with a closing frame listing reputable resources, each with a one-line note about what it adds.

## 4. Land the completed deck in the repo

- Read the repository's `AGENTS.md` first. Where it and this skill overlap, it wins on style and file layout and this skill wins on pedagogy.
- Read `templates/README.md` and start from `beamer-deck.html`, the skill's only template: fixed 1280x720 frames, tinted head and foot bands, Beamer `block` boxes, overlays, and the classic blue theme (or `data-theme="paper"` for the repository's serif-on-paper palette). Light background, dark text. Build a custom template only if the user asks for one.
- Save the deck as `<Category>/<topic-slug>/<topic-slug>.html` — the file name repeats the folder name, and a page has no `index.html`. When the topic already has a long-form note at that name, keep the note where it is and write `<Category>/<topic-slug>/<topic-slug>-deck.html` beside it. If a deck already exists for this topic, update it in place instead of writing a second one, and never overwrite an unrelated page.
- Keep the reader-facing artifact as one HTML file. Prefer inline HTML, CSS, SVG, and JavaScript; put generated figures in `assets/` and runnable helpers in `scripts/` beside the page, referenced relatively, and keep any external dependency obvious and local to the folder. The template's KaTeX CDN is acceptable unless offline output was requested.
- Save `summary.md` beside the page throughout the session, not only at the end. It is the handoff file for resuming section-by-section teaching, so record each section's frame range and the calibration answers rather than re-deriving them later.
- Add a card for the deck to `#grid` in `index.html` only after every planned section is finalized, all required resources are present, and the deck passes final verification. Use the recipe in [references/repo-notes.md](references/repo-notes.md). Search, category chips, reading times, and field counts are all computed from that grid, so keep every attribute filled.
- Link to sibling pages where the relation is real, so the deck sits inside the series rather than beside it. Use `../<sibling-slug>/<sibling-slug>.html` within a category and `../../<Category>/<sibling-slug>/<sibling-slug>.html` across categories; every `href` must resolve to a file that exists.
- Use semantic HTML (`figure`/`figcaption`, headings, lists, tables, and labeled controls), meaningful alt text or a nearby text equivalent for every non-decorative figure, keyboard-accessible demos, and responsive dimensions. Avoid visual styling that makes labels, equations, or controls overlap or clip.

## 5. Verify and follow up

- Before adding the landing-page card, render the deck frame by frame at a desktop viewport, and once at a narrow viewport, using the verification commands in [references/repo-notes.md](references/repo-notes.md). Check that math renders, figures and controls are usable, links and local assets resolve, and no content overlaps or clips. Inspect the title frame, the densest content frame, and the closing frame with every overlay revealed, and leave no `overfull` tag on any frame. If browser inspection is unavailable, perform static checks and say what was not inspected.
- Check the wiring, not only the page: the card is in `#grid`, its `href` and filter classes are real, cross-links resolve, and no unrelated landing-page entry was disturbed.
- Check that no draft marker or placeholder frame remains in the completed deck, that every section has a takeaway frame, that each section's frames cover what the conversation taught, and that `summary.md` records the final calibration, frame ranges, and verification state.
- Add the landing-page card only after these checks. Then verify that filters find it, reading time and counts update, and its link resolves.
- Deliver the deck and `summary.md` together, name the category and slug it landed in, and invite questions. Answer a follow-up in two or three lines plus a deep link to the frame that carries the answer; where no frame carries it, add one.
- If the user engages in a teaching follow-up, correct the misconception on the relevant frames, revise them in place, and refresh `summary.md` with the final understanding. Offer an optional short comprehension check on a frame; do not force a new quiz once the deck is complete.

## Tools

For math, verification, or reference plots, use the `wolfram-mcp` skill when it is the right tool; C++, Python, JavaScript, Octave, or another suitable tool is fine for behavioral demos. Follow the relevant tool or skill instructions before using it.

Topic: $ARGUMENTS
