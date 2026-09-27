# Templates

`note.html` is a question-map shell, not an answer key. It gives each teaching section one deep
question and only the setup needed to attempt it. Figures and demos may expose a phenomenon for
the reader to interpret, but the expected answer, conclusion, and worked solution stay out of the
page. Its renderer, typography, math setup, navigation, and responsive behavior are fixed.

## Workflow

1. Read this router once.
2. Copy the shell, then read the copy before filling it:

   ```sh
   cp .agents/skills/teach-an-engineer/templates/note.html <Category>/<slug>/<slug>.html
   ```

   Slots are addressed by their text (`FILL: Note title`, `FILL: the opening question`) and each
   appears once; keep the question/setup structure and remove unused optional blocks cleanly.
3. Fill the title, hero, and every visible question-led section. Each section asks one deep
   question and supplies only the running example, assumptions, definitions, notation, or visual
   setup needed to attempt it. Do not fill an answer, explanation, solution, proof, method list,
   result, takeaway, or leading hint.
4. Make the Sources section truthful for the current stage: before any research, state that no
   external sources have been consulted yet. Never use a citation to disclose an expected answer.
5. Keep every `#sN` heading anchor in `nav.toc`, in the same order, and renumber both together
   if a section is inserted or removed.
6. File the page and landing card immediately after the question map is usable. Load
   `summary.md` only at handoff.

The teaching route is question → reader attempts an answer from prior knowledge → assess the
attempt → targeted follow-up, hint, research, derivation, or demo only where needed → reader
revises → next question. The HTML carries the questions and setup; it does not carry the expected
insight or the explanation.

## Fill rules

- Replace every visible `FILL:` and act on every commented `FILL:` instruction. A shipped page
  must pass `grep -rn 'FILL:' <Category>/<slug>/` with no output.
- Each section opens with a visible `.callout` whose `<strong>Question:</strong>` names the deep
  problem the section tests. The setup visible below it must make that question attemptable
  without answering it.
- Do not use `Intuition:`, `Takeaway:`, `Claim:`, proof, method-summary, worked-result, or overall
  conclusion blocks in the default question-map page. Their styles remain available for other
  notes, but they would give away the expected insight here.
- One `.eq` per display equation. Inline math uses `\(...\)` and display math uses `\[...\]`.
  An equation may state the setup or the question; it must not state the expected answer.
- A figure should expose a phenomenon, object, or contrast for the reader to interpret or predict.
  Its caption says what to inspect, not what conclusion to draw.
- A demo may be added later only when the reader's response calls for it, and it must let the
  reader investigate rather than announce the answer. Run it before reporting output.

## Fixed page contract

- Academic serif on paper: `"Source Serif Pro", Georgia, "Times New Roman", serif`, background
  `#ffffff`, navy accent `#1f4e79`, content width up to `880px`.
- Centered `h1` with a one-line italic `p.hero`, then numbered `h2 id="sN"` sections separated
  by `hr`.
- `nav.toc` is a restrained sticky top contents bar, horizontally scrollable on narrow screens,
  and highlights the active section. `#sN` is the teaching deep link.
- KaTeX auto-render is the default for new pages: `\(...\)` inline, `\[...\]` inside `.eq`.
  When editing an existing page, keep its existing renderer and never mix renderers.
- Existing notes and legacy decks keep their own renderer and class names. Never convert one
  artifact style into another merely for consistency.
