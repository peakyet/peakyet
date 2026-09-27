# Teaching patterns: discovery and model revision

These are adaptations from selected first-party examples, not a claim that every
3Blue1Brown or Veritasium video follows one recipe. Borrow the reasoning structure,
not catchphrases, visual branding, or an obligation to animate. Consult this note
when designing an opening, a visual explanation, or a guiding question.

## 3Blue1Brown: make the idea feel reconstructible

In *The Essence of Calculus*, a circle-area question becomes a sequence of rings,
rectangular approximations, and a graph before the general integration idea is
introduced. The concrete example contains the structure needed for generalization.

In *Linear transformations and matrices*, movement of vectors and the grid gives
meaning to a transformation. Tracking basis vectors then motivates the matrix entries
and multiplication rule, instead of asking the reader to memorize an unexplained recipe.

**Adaptation:** preserve a visible object across successive views; highlight the relationship
being used, then connect it to notation. A diagram should support a deduction, not
merely decorate a formula. Distinguish a helpful picture from a general proof.

## Veritasium: engage and revise the reader's existing model

In *Khan Academy and the Effectiveness of Science Videos*, Derek Muller argues for
addressing common misconceptions alongside scientific explanations rather than relying
on a polished correct explanation alone. This supports explicitly engaging the
reader's prior model; it is not a universal guarantee that surprise improves learning.
The linked video's public description grounds this summary, not a full-video analysis.

**Adaptation:** invite a prediction and its reason, show the specific observation or
counterexample it must explain, and identify exactly which assumption needs repair.
If the prediction was right, ask why it works or where its validity ends; do not force
an artificial failure. Resolve the puzzle instead of extending suspense for its own sake.

## Combined route, not a mandatory checklist

Question → reader attempts an answer from prior knowledge → assess exactly what the attempt
misses → targeted hint, counterexample, derivation, source, or demo → reader revises → next
question. The HTML carries only the question and the setup needed to attempt it. Intuition and
the key idea are the agent's expected answer and grading guide, not content printed on the page.
A failed attempt or misconception is optional, not a required performance; offer hints rather
than demand unaided invention. Include the complete question chain in the question-map pass, but
do not research, prove, or answer every link before teaching. Keep the response focused on the
question that exposed the gap.
After the reader has handled a question, the conversation can close it, vary one condition, or
move to the next question. A surprising observation may appear as a question, not as an
unexplained conclusion.

For example, instead of asking “What is matrix-vector multiplication?”, ask:
“If every vector is a combination of two basis vectors, what must a transformation
preserve for their two images to determine every other image?” The page can show the
basis images and the question; after the reader attempts an answer, the chat can supply
the vector-combination picture and use it to repair the missing idea.

## First-party sources consulted

- Grant Sanderson, [The Essence of Calculus](https://www.3blue1brown.com/lessons/essence-of-calculus/),
  official text adaptation: concrete example, visual reframing, generalization.
- Grant Sanderson, [Linear transformations and matrices](https://www.3blue1brown.com/lessons/linear-transformations/),
  official text adaptation: visual meaning before the computational recipe.
- Veritasium, [Khan Academy and the Effectiveness of Science Videos](https://www.youtube.com/watch?v=eVtCO84MDj8),
  creator's public video description: explicitly addressing misconceptions.

These sources ground this skill's pedagogy; they are not automatic citations for
future notes. Cite sources relevant to a note's subject only when a section makes a claim
that needs external grounding. An intuition pass may have no sources yet.
