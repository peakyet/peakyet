# Sources

Derive routine mathematics directly. Research external claims, attribution,
borrowed results, or unresolved uncertainty using authoritative sources.
Use `arxiv-mcp-server` and `paper-search-mcp` for scholarly discovery;
official documentation for software behavior. Search known titles or identifiers first.

Read the passage supporting the claim, including relevant definitions, assumptions,
and boundary conditions. Metadata and abstracts cannot support a detailed derivation.
Stop when adequately grounded; qualify or remove unsupported claims.

Put consulted sources in note-local `refs.bib`, enable
`bibliography: bibliography("refs.bib")` in `note-ilm.with(...)`, and cite with
`@key` beside the supported claim. Record what each source supports in `summary.md`.
Use canonical public links and real bibliographic fields. Label unconsulted further
reading separately; if no sources were consulted, say so.

Keep downloaded papers and extracted text outside the repository; pass an absolute
`save_path` under `/tmp` to download tools. The note's own compiled PDF is committed.
