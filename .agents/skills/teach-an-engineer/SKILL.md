---
name: teach-an-engineer
description: "Teach an engineering topic through a concise, complete HTML slide deck and guided questions. Use for /teach-an-engineer, visual explanations, or requests to understand how something works in this knowledge base; not for ordinary prose-only answers."
---

# teach-an-engineer

**Build a minimal, complete explanation first; teach through connected questions that make each next step necessary; revise where understanding breaks.**

Assume an engineer new to the topic but comfortable with basic algebra and calculus. Adapt to their answers without a prerequisite interview. The repository's `AGENTS.md` takes precedence over this skill and its references.

## Build the whole draft first

- Read `AGENTS.md`, [template guidance](templates/README.md), and [repo notes](references/repo-notes.md). Start from [beamer-deck.html](templates/beamer-deck.html); preserve its renderer, navigation, and responsive layout.
- Before teaching, create the shortest self-contained HTML deck covering the entire reasoning chain. Complete means understandable end to end, not exhaustive: no placeholder sections or lessons deferred until the reader answers. No fixed frame or section counts.
- Start with a concrete problem or failure. Develop the core mechanism through one running example, introducing notation and necessary assumptions when used. Explain why each step follows; brevity must not erase a logical bridge.
- Present results, advantages, guarantees, limitations, and comparisons after the mechanism is understood. Motivation belongs early; properties needed to derive the method belong with the derivation. Defer optional variants and history.
- Give each frame one clear idea. Prefer a concrete object, inline SVG figure, or small demo to dense prose; use [figure guidance](references/figures.md) when needed. Close each section with a brief takeaway, not necessarily a separate frame. Keep the existing frame budget and `?fit` layout audit; do not squeeze content to meet an arbitrary slide count.

## Teach with questions, not gates

The complete deck is available from the start; the conversation proceeds one connected idea at a time. Teach from its frames, using a short deep link and a guiding question rather than a parallel lesson in chat.

- Questions primarily guide reasoning toward the core idea; diagnosing understanding is secondary. Ask why a step is necessary, what would fail without it, or what the mechanism predicts in a changed example—not for a formula or sentence copied from the slide.
- Supply the ingredients before asking for the inference. Each question should bridge from what has been established to the next idea, without relying on untaught knowledge. Depth is not obscurity.
- Put the question on the relevant frame and its answer with reasoning behind `data-fragment`, so the deck also works for independent reading. Close every question the deck opens. Use questions where they help, not to satisfy a quota.
- Use responses to clarify a missing link or repair a misconception. Add only the prerequisite explanation needed for that link, then return to the main thread. Do not require explain-back checklists, repeated quizzes, or explicit permission at every transition; respect requests to skip, pause, or go deeper. Silence is not evidence of understanding.
- Revise affected frames and downstream reasoning as the discussion develops. Keep lasting explanations in the deck; brief clarification in chat is fine.

## Research and computation

Use classic-first research: foundational papers, established books, and authoritative technical blogs. Read relevant passages, not everything. Avoid derivative or unsupported material; elementary does not mean low quality. Use newer primary sources when correctness, current behavior, or attribution requires them. Follow [sources.md](references/sources.md) for paper MCP tools and citation recording.

Use direct reasoning for routine derivations. Do not create a verifier for every claim. Use scripts mainly for demonstrations and illustrations, or when a difficult calculation genuinely needs checking. Run executable demos before reporting their output; label anything unrun. A numerical example is not a general proof. Verify specialized or attributed claims against sources, and disclose unresolved uncertainty rather than substituting confidence for evidence.

## Save and deliver

- File the deck and register its landing-page card using the repo notes. Artifact readiness is independent of teaching progress: add the card once the complete draft is usable and checked, without waiting for the reader to finish it. Update existing decks in place.
- Keep `summary.md` as a short handoff: audience assumptions, section/frame map, current discussion point, running example, unresolved gaps, sources and what they support, and checks performed. No transcript or prerequisite ledger.
- Use the existing `?fit` audit and inspect representative desktop frames plus a narrow view. Check math, controls, links, and the landing card; fix overflow and disclose unavailable checks. Do not build new verification infrastructure for routine page checks.
- Deliver the complete deck link, point to the first teaching frame, and ask its guiding question. Keep research downloads and generated inspection artifacts out of the repository.

Topic: $ARGUMENTS
