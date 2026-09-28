# Sources

## When to research

Do not perform a literature pass before teaching. Start with the question map and no
external sources. Research only when a reader's answer, a request, or the expected insight
needed to assess that answer requires external grounding. Research supports the assessment
or follow-up; it does not go into the note as a revealed answer.

Research when the claim depends on a named paper, book, technical blog, historical
attribution, exact rate or number, disputed result, or current software behavior. Do not
research routine algebra, calculus, definitions, a local derivation, or an idea the reader
already understands.

## Triage the claim

- **Derived or standard:** settle it by direct reasoning and record the derivation. Do not
  look up a paper merely to reassure the reader.
- **Grounded:** attribution, history, a quoted result, or a borrowed number needs one
  authoritative source and the passage that supports the claim.
- **High-risk or current:** disputed priority, a recent result, or version-dependent
  behavior may need one additional source. Software behavior uses official documentation.

Stop once the claim family has adequate support. A second source is for disagreement,
priority, or genuine risk, not for accumulating confidence.

## Retrieve

- Use `arxiv-mcp-server` and `paper-search-mcp` for scholarly discovery and metadata,
  not recalled citations. Search by known title, author, or DOI first.
- On arXiv, use `search_papers` only if the item is not already known; use `get_abstract`
  to assess relevance or attribution. Download and use outline, section, or text-search
  tools only when the claim needs the body. Citation graphs are optional for genuine
  lineage questions, not routine verification.
- For journal papers and books, use `paper-search-mcp` metadata tools such as
  `search_crossref` or `search_semantic`; retrieve relevant full text where available.
  Use publisher or author pages for books, and original author sites for technical blogs.
- Prefer publisher, author, and open repository copies. For `download_with_fallback`,
  pass `use_scihub=False` for the open-access route. Follow explicit user direction about
  supplied or otherwise accessible copies without publishing private files.
- Read only the deciding passage. If retrieval fails, try one authoritative alternative
  and then qualify or remove the claim; do not broaden the search indefinitely. Search
  snippets and abstracts are discovery aids, not evidence for a detailed proof.

## Stop and cite

End with a concise Sources section only when sources were actually consulted. In a Typst
note that section is the document's own bibliography: add a `refs.bib` beside the note,
uncomment the `bibliography: bibliography("refs.bib")` line in the `note-ilm.with(...)`
call, and cite with `@key` in the sentence that uses the claim. Give each entry its author,
title, public link, and the claim family it supports. Use a DOI or versioned arXiv ID for
papers when available; for books, give the edition and relevant chapter with a publisher or
author link, adding an ISBN only when no public link exists; for blogs, give the author,
article title, and canonical URL. Do not force books or blogs into DOI/arXiv-only citations
or invent bibliographic fields.

An unconsulted note says so in that section's own words rather than citing from memory, and
`@preview/ilm` renders the list at the end of the document, before any index. Keep suggested
further reading as ordinary prose in the same section, labelled as not consulted, so the
bibliography stays a record of what was actually used.

Record in `summary.md` what each consulted source grounds, grouped by source rather
than one row per sentence. An abstract or metadata record may ground attribution or a bibliographic
fact, but not a detailed technical result. Put attribution beside any borrowed numerical
result. Retain enough provenance to resume without repeating research; recheck when the
source, claim, or version changes, not merely because a new session began. Label suggested
further reading separately from sources actually consulted.

If no source is adequate, qualify or remove the claim. If no external source has been
consulted, say so explicitly rather than filling the section from memory. Record what a
source grounds in `summary.md`; do not paste its conclusion into the question map.

## Keep the repository clean

Pass an absolute `save_path` under `/tmp` for paper-search downloads; its default may
write inside the repository. Server-managed caches can stay outside the repo. Never
commit downloaded PDFs or extracted source text. Published notes link canonical public
pages, not local paths or private copies. Record uncertain versions or noncanonical
copies in the handoff and avoid unsupported priority claims.

Distinguish those downloads from the note's own compiled `<slug>.pdf`, which is committed
because the site serves it. A research PDF belongs in `/tmp` and never in the note folder,
even though both are PDFs.
