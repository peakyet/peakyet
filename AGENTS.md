# AGENTS

This is a GitHub Pages site serving a personal **math knowledge base**. It is hand-written,
static content with one exception: a new teaching note is written in Typst and compiled once with
the `typst` CLI, because GitHub Pages runs no build step of its own. There is no framework and no
shared stylesheet. Network access is assumed, so pages may load external CDN assets or external
figures.

## Layout

- `index.html` — the landing page / front door. Lists and links to every note.
- `<Category>/<topic-slug>/` — one folder per note, so it can bundle figures alongside the prose.
  The top-level `Category` is the field the note belongs to: `Algebra`, `Control`, `Optimization`,
  `Robotics`, `Mathematics`, `AI-ML`, or `Tools`.
- `<Category>/<topic-slug>/<topic-slug>.typ` and `<topic-slug>.pdf` — a new note: Typst source plus
  the compiled PDF the site serves. `refs.bib` and `assets/` join them once the note cites a source
  or includes an exported figure, and a `<topic-slug>-demo.html` sidecar is allowed only under the
  simplicity ceiling in the skill.
- `<Category>/<topic-slug>/<topic-slug>.html` — the repository's existing notes, hand-written HTML.
  They stay as they are; new notes are not written this way.
- `LICENSE` — the repository license.

When adding a note, create it under the matching category folder (its own topic subfolder), then
add a card for it on the landing page so it stays discoverable.

## Landing page (`index.html`)

Before editing `index.html`, read [the landing-page specification](specifications/landing-page.md).
Load it only when the task requires editing the landing page, including adding a note card.

## Coding Environment

- The python virtual environment is available by using 'uv'. You don't need to write any code by yourself if there exists some package. The needed package can be install in virtual environment after asking user and obtaining the approvement.

## Web access: Exa or Tavily first

Every web search and page read in this workspace goes through the connected `exa` tools
(`web_search_exa`, `web_fetch_exa`) or `tavily` tools (`tavily_search`, `tavily_extract`) first.
This includes lookups about Amp itself — its docs, CLI flags, plugins, and orbs.

The built-in `web_search` and `read_web_page` are a fallback only: use them when Exa and Tavily
are unavailable, error, or return nothing usable, and say so in the reply.

## Render Option

- 'google-chrome-stable' is available for rendering HTML.
