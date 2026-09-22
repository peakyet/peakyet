# Literature research

How a `teach-an-engineer` deck finds the sources behind its claims and records them. Read this
whenever the topic rests on papers, standards, or attributed results: a numerical algorithm and
its rate, an ML method, a control theorem, or anything where the deck states who proved what,
when, or with which bound.

Two MCP servers are configured for this. Prefer them over ad hoc web search for scholarly
material.

| Server | What it is good at |
|---|---|
| `arxiv-mcp-server` | arXiv-native work: preprint search, abstracts, full text of a paper you fetched, citation graph in both directions, BibTeX export |
| `paper-search-mcp` | everything outside arXiv: DOI and journal metadata, multi-source fan-out, Semantic Scholar, CrossRef, OpenAlex, DBLP, IACR, PubMed |

## Size the research to the topic

- Classic, stable material (a textbook decomposition, a well-known step) → the originating paper
  plus one modern treatment or survey. Read enough to state the mechanism correctly, not to
  summarise the paper.
- Recent or contested (a 2023-onward method, "does X beat Y", a convergence rate, a priority
  dispute) → search, read several abstracts, then read the body of the one or two papers the deck
  actually relies on. Fetch a survey when the field is unfamiliar.
- Library or tool behaviour (`acados`, LAPACK, a browser API) → the docs and the source are
  primary. Use papers only for the algorithm inside them.

## Find

arXiv first for math, CS, control, and robotics: dense coverage and free full text.

```text
mcp__arxiv_mcp_server__search_papers
  query='"damped L-BFGS" AND ti:"stochastic"'
  categories=['math.OC','cs.LG']            # strongly improves relevance
  max_results=10, abstract_mode='snippet'
```

Query syntax is quoted phrases plus `ti:` / `au:` / `abs:` / `cat:` joined by `AND`, `OR`,
`ANDNOT`. Bare words match title and abstract only and never authors, so use `au:"Kelley"` for a
name. Use `sort_by='date'` when the question is what is recent, and `date_from` when the deck
claims a method is new.

For journal-only papers, older classics, and fields arXiv does not carry, go multi-source:

```text
mcp__paper_search_mcp__search_papers          # one fan-out over many platforms
  query='eigenvalue iteration algorithm', sources='crossref,semantic,openalex,arxiv',
  max_results_per_source=5
mcp__paper_search_mcp__search_crossref        # DOI, journal, volume, pages
mcp__paper_search_mcp__search_semantic        # year filters, citation counts, related work
```

`search_google_scholar` and the keyless Semantic Scholar path get rate limited. Treat a hard
failure as a reason to switch source, not as evidence that the paper does not exist.

## Read

Climb this ladder and stop as soon as the claim on the frame is grounded.

1. `mcp__arxiv_mcp_server__get_abstract` to judge relevance without downloading.
2. `mcp__arxiv_mcp_server__download_paper`, which prefers the HTML rendering and caches under
   `~/.arxiv-mcp-server/papers`. Then `read_paper`, `get_paper_outline`, and `search_paper_text`
   to pull the one section or equation you need instead of the whole body.
3. `mcp__paper_search_mcp__read_semantic_paper` for full text that is not on arXiv (it accepts a
   DOI, PMID, MAG, or ACL identifier), and `read_arxiv_paper` to read an arXiv PDF when the HTML
   route gave nothing useful. Pass `save_path` explicitly; see Hygiene.
4. `mcp__paper_search_mcp__download_with_fallback` when a journal PDF is the only way to read
   something. The chain is source-native, then OA repositories, then Unpaywall, then Sci-Hub, and
   `use_scihub` defaults to `True`, so pass `use_scihub=False` to hold the chain at open access. Note
   which leg produced the file; see Paywalled papers.
5. `mcp__arxiv_mcp_server__citation_graph` for papers citing this one and papers it cites. Use it
   to place an algorithm in its lineage, to find the successor method the deck should name, and to
   check that the paper you are calling "the original" really is.
6. `mcp__arxiv_mcp_server__semantic_search` only over papers already downloaded, and only when the
   server was installed with its `[pro]` extra. Handy once several candidates are already local.

## Record

Every deck closes with a Sources frame. Each entry needs a resolvable identifier plus one line on
what it adds:

```html
<li>J. Banks, J. Garza-Vargas &amp; N. Srivastava,
    <a href="https://arxiv.org/abs/2111.07976">arXiv:2111.07976</a> &mdash;
    &ldquo;Global Convergence of Hessenberg Shifted QR I: Exact Arithmetic&rdquo;; the
    exceptional-shift argument behind section 4.</li>
```

- arXiv preprint → `https://arxiv.org/abs/<id>`, keeping the version suffix (`v2`) when a specific
  version is what was read.
- Journal paper → DOI as `https://doi.org/<doi>`, with journal, volume, pages, year. Read those
  fields back from `search_crossref` rather than from memory, and let
  `mcp__arxiv_mcp_server__export_citations` render BibTeX from authoritative arXiv metadata when
  an entry is fiddly.
- Mirror the same list into `summary.md` under **Sources**, and note what each entry grounds:
  "section 3's rate is from X §4", "Figure 2 numbers come from Y's Table 1". A resumed session
  should be able to re-check a claim without redoing the search.

Cite what was actually read. An author-title-year string assembled from recollection is a defect
even when it looks plausible: verify the identifier or drop the attribution. Where a frame states
a number from a paper, say so in the caption or frame foot so it is traceable.

## Hygiene

- Papers are research scratch, not site content. arXiv-server downloads land in
  `~/.arxiv-mcp-server/papers`; anything fetched through `paper-search-mcp` goes wherever you
  point `save_path`, and its default is `./downloads`, which is inside the repository. Pass an
  absolute `save_path` under `/tmp` every time. Never commit a PDF, and never link a deck at a
  local path: link the public URL.
- **Paywalled papers.** Working around a paywall is the user's decision, not a call to relitigate one
  paper at a time: when they ask for a paywalled item, or hand over a PDF they already hold, get on
  with it rather than lecturing or refusing. Try the open legs first anyway, because they are the
  better engineering: a publisher or repository copy arrives with a resolvable DOI, a stated version,
  and a URL you can point a reader at, and Unpaywall or an OA repository often has the accepted
  manuscript. Reach for the last leg when the open ones cannot answer the question.
- **Provenance travels with the copy.** When the route was anything other than the publisher or arXiv,
  record it in `summary.md` next to the source ("read from a mirror copy; version unconfirmed"), and
  still cite the canonical DOI or arXiv ID. Date and priority claims need a version you can name; if
  the copy does not say which version it is, soften the claim to what the mathematics supports instead
  of dating it precisely.
- **Published pages stay clean.** A private copy is not site content. `index.html` and every deck link
  public identifiers only: DOI, arXiv, publisher, or archive. No mirror hostname, no local path. The
  site handing out a link is a different act from reading one.
- Both servers are network clients. DNS failures, timeouts, and 429s usually mean the domain is
  outside the sandbox's network allowlist rather than that the paper is missing. Fall back to the
  Exa web-search tools, and state plainly in the answer which literature check did not run rather
  than implying the topic was verified against sources.
- Search results are metadata, not understanding. Do not put an abstract's phrasing on a frame as
  though the paper argued it; read the section or drop the sentence.
