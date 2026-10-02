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
If a correct prediction lacks reasoning, ask why it works or where its validity ends;
otherwise accept it. Resolve the puzzle instead of extending suspense for its own sake.

## Guided discovery and later practice

Use the teaching loop in [SKILL.md](../SKILL.md). A failed attempt is optional; missing background
calls for help, not repeated demands to invent the method. Accept an explanation request directly.

For example, show two basis vectors and their images and ask: “What must a transformation
preserve for those two images to determine every other image?” If the reader cannot start, work
through how a sum is transformed, then ask them to complete the scalar-multiple case. If they ask
for the explanation, provide it. When understanding is uncertain, change the transformation to
an affine map and ask what extra information is needed. Later, ask them to reconstruct the basis
argument without looking at the answer. These are possible follow-ups, not a mandatory sequence.

The learning-science sources below motivate guidance and later retrieval. Their abstracts were
consulted; they do not establish an ideal number of hints, a mastery threshold, or a fixed schedule:

- Alfieri et al. (2011), [Does discovery-based instruction enhance learning?](https://doi.org/10.1037/a0021017):
  two meta-analyses distinguish unassisted from assisted discovery. The reported results favor
  explicit instruction over unassisted discovery, and assisted discovery over comparison
  instruction. This supports scaffolding, feedback, and worked examples; effects vary by context.
- Karpicke and Roediger (2008), [The critical importance of retrieval for learning](https://pubmed.ncbi.nlm.nih.gov/18276894/):
  repeated retrieval after an initially correct answer improved delayed recall of vocabulary.
  This motivates occasional later retrieval; it does not demonstrate engineering transfer or make
  one correct response a general mastery criterion.

## First-party sources consulted

- Grant Sanderson, [The Essence of Calculus](https://www.3blue1brown.com/lessons/essence-of-calculus/),
  official text adaptation: concrete example, visual reframing, generalization.
- Grant Sanderson, [Linear transformations and matrices](https://www.3blue1brown.com/lessons/linear-transformations/),
  official text adaptation: visual meaning before the computational recipe.
- Veritasium, [Khan Academy and the Effectiveness of Science Videos](https://www.youtube.com/watch?v=eVtCO84MDj8),
  creator's public video description: explicitly addressing misconceptions.

These sources ground this skill's pedagogy; they are not automatic citations for
future notes. Cite sources relevant to a note's subject only when a section makes a claim
that needs external grounding. A question map may need no external sources.
