# Sources

## Choose and read

Research to resolve a concrete gap or ground a claim, not to accumulate references.
Prefer foundational papers, established textbooks or monographs, and authoritative
technical blogs with identifiable expertise and explicit reasoning. Avoid derivative,
unsupported, or content-farm material. An elementary treatment can be excellent.

Read the relevant chapter, argument, or equation. Start with a small number of strong
sources and stop when the mechanism and used claims are supported. Do not require both
an original paper and a survey for every topic. Use newer primary sources when needed
for a newer method, corrected result, disputed attribution, or current behavior; use
official documentation for software behavior.

## Retrieve

- Use `arxiv-mcp-server` and `paper-search-mcp` for scholarly discovery and metadata,
  not recalled citations. Search by known title or author when possible.
- On arXiv, use `search_papers` and, if needed, `get_abstract` to assess relevance;
  `download_paper` then outline, section, or text-search tools to read the argument.
  Citation graphs are optional for genuine lineage questions.
- For journal papers and books, use `paper-search-mcp` metadata tools such as
  `search_crossref` or `search_semantic`; retrieve relevant full text where available.
  Use publisher/author pages for books, and original author sites for technical blogs.
- Prefer publisher, author, and open repository copies. For `download_with_fallback`,
  pass `use_scihub=False` for the open-access route. Follow any explicit user direction
  about supplied or otherwise accessible copies without publishing private files.
- If retrieval fails, try an authoritative alternative and disclose unresolved checks.
  Search snippets and abstracts are discovery aids, not evidence for a detailed proof.

## Cite what was read

End with a concise Sources frame. Give each entry its author, title, public link, and
what it contributes. Use a DOI or versioned arXiv ID for papers when available; for
books, give the edition and relevant chapter with a publisher/author link or ISBN;
for blogs, give the author, article title, and canonical URL. Do not force books or
blogs into DOI/arXiv-only citations or invent bibliographic fields.

Mirror the source-to-claim mapping in `summary.md`, including relevant sections or
pages. Put attribution beside any borrowed numerical result. Retain enough provenance
to resume without repeating research; recheck when the source, claim, or version changes,
not merely because a new session began. Label suggested further reading separately
from sources actually consulted.

## Keep the repository clean

Pass an absolute `save_path` under `/tmp` for paper-search downloads; its default may
write inside the repository. Server-managed caches can stay outside the repo. Never
commit downloaded PDFs or extracted source text. Published decks link canonical public
pages, not local paths or private copies. Record uncertain versions or noncanonical
copies in the handoff and avoid unsupported priority claims.
