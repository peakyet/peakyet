# Developing a reconstructible explanation

Use this when choosing the example, sequencing the explanation, or reviewing its hardest
bridge. These techniques guide judgment; they are not a mandatory sequence of section beats.

## Learn from the procedure in the lessons

In 3Blue1Brown's [The Essence of Calculus](https://www.3blue1brown.com/lessons/essence-of-calculus),
the problem is the area of a circle. Rings become approximate rectangles, rectangles become
an area under a graph, and shrinking their thickness connects the approximation to the exact
answer. The lesson acknowledges alternative subdivisions and approximation error. The circle
example contains the structure needed to discuss integrals more generally.

In [Linear transformations and matrices](https://www.3blue1brown.com/lessons/linear-transformations),
vectors move, a grid makes the movement readable, and tracking two basis vectors makes it
possible to reconstruct any transformed vector. The columns of a matrix then store something
the reader already understands. Formal properties connect that picture to the general argument.

These observations come from the official text adaptations, not a claim about the creator's
private production workflow. Reuse the reasoning, not branding or an obligation to animate.
They are sources for this teaching approach, not automatic citations in future technical notes.

## Choose a special case that retains the difficult step

Begin with an object the reader can inspect or compute. Prefer an example that exposes the
actual construction rather than merely producing attractive numbers. Ask privately: which
part survives generalization, and which part is special to this example? A scalar calculation
cannot validate matrix multiplication order. A diagonal system may conceal coupling. A convenient
boundary condition may hide information required in the general case.

Give the example enough detail to reconstruct the mechanism without surrounding it with
every possible case. Add a discriminating case during verification, not necessarily to the
main explanation. Change examples when helpful, but explain the correspondence.

## Make the need for an object intelligible

A useful progression starts from a problem, explores what a familiar approach can do, and
introduces a representation that makes the next step accessible. A failed attempt is optional.
Do not manufacture a contradiction or describe a useful choice as logically inevitable.

Before using a new object, answer: what does it represent, what can we now do with it, and why
does that help here? A quantity's name, dimensions, and one-line definition may all be correct
while its purpose remains opaque. Show its action on the example, then connect the notation.
State legitimate starting assumptions, such as taking an equation as the target, rather than
quietly assuming the very mechanism the note promises to explain.

## Join pictures, calculations, and general arguments

Keep identifiable objects across successive pictures. Explain what changes, what remains,
and which operation the equation records. Pictures establish a mental model; equations make
it precise. Neither is a substitute for the other. A static final configuration may verify a
result while failing to explain how it arose.

Work essential derivations in the main explanation, including each substantive manipulation
and its reason. Keep routine algebra concise when this reader can follow it; expand a step
when meaning or a prerequisite is missing. Do not replace a central derivation with a paper
reference, "extra bookkeeping", or an exercise. A chain of displays with no explained
relationships can be just as unhelpful as a missing chain.

Label the point where the argument becomes general. State conditions, approximations, and
limits of an analogy. Counterexamples can separate concepts that a successful example merges:
finding one solution versus proving uniqueness, or agreement on one input versus equivalence
of two operations.

## Sample feedback and voice

Explain the hardest bridge in a rendered sample before producing the full note. The sample
must include enough setup to make the bridge understandable; it cannot open with unexplained
machinery borrowed from an unwritten earlier section. Ask where the reader loses the thread,
not whether they can pass an unaided derivation. Explain directly on request. Change the
representation or add the missing connection rather than merely increasing verbosity.

Write as a precise whiteboard explanation. Avoid collections of notation before meaning,
artificial suspense, and a hook in every section. Section lengths and count follow the idea.
Feedback can establish that an approach works for the reader; approval does not prove mastery.

## Review for common explanation gaps

Apply the relevant checks to the current explanation. These are general review patterns;
they do not depend on a particular note or require a fixed set of examples.

| Explanation gap | What the review must catch | Evidence needed to repair the explanation |
|---|---|---|
| A formula uses a representation before explaining it | Correct formulas can depend on an unbuilt mental model; a later derivation does not fix the order | Show the representation's meaning and action on the example before using its notation |
| A central operation is dismissed as routine algebra or delegated to a citation | The promised mechanism is asserted rather than explained | Work the substantive intermediate steps and explain why each follows |
| A metaphor is promoted into a mathematical interpretation without checking assumptions | A vivid description and correct final output do not establish that interpretation | Verify definitions, boundary conditions, and the correspondence between the example and the general argument |
| The displayed code is checked only through a separate verification script | A working script can miss errors in the actual lesson listing | Execute the exact displayed runnable listing, including relevant branches |
| A result table or final diagram has a caption claiming the mechanism | Labels and measured outputs can illustrate without explaining | Show the transformation or intermediate relationship, with coordinates and arrows matching the algebra |

Record a small private chain of evidence: assumed start → essential transition → actual
passage/figure → mathematical check. Follow that chain through the rendered draft. Missing
evidence prompts a revision; counting callouts or searching for forbidden phrases cannot
certify an explanation. Keep the record in review artifacts, not a public learner dossier.
