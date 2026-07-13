# Design — replicable inline-SVG block-diagram pipeline

**Date:** 2026-07-13
**Author:** Giuseppe Silvi (with Claude)
**Status:** Approved
**Repos touched:** `librerie/faust-libraries` (pipeline + source), `blog/s-e-a-m.github.io` (CSS + published page)

## Context

The SEAM library doc pages (`basic`, `math`, live at `/faustlibraries/<name>/`)
would be more complete with Faust block diagrams. This designs a **replicable**
way to generate them and embed them in the pages, reusing the existing faust2md
`doc/` pipeline. Applied to `basic` this round; every future library then only
needs opt-in markers + a rerun.

Every technical risk was cleared with real spikes before this design:

- `faust -svg <file>` emits a **directory**: a top-level `process.svg` plus one
  SVG per named block, with **non-deterministic hex filenames** (`osc-0x…svg`)
  and `<a xlink:href>` drill-down links between them — so the multi-file diagram
  is inherently non-reproducible.
- The **top-level `process.svg`**, with its `<a xlink:href>` wrappers and the
  `<?xml…?>` prolog stripped, is a **valid, self-contained ~4 KB SVG** (viewBox
  and Arial text intact). Two compiles of the same source produce a
  **byte-identical** body — fully reproducible.
- Inline `<svg>` survives kramdown / Minimal Mistakes into `_site` **un-escaped**
  and renders (verified with a throwaway page, incl. the `<div class="faust-diagram">`
  wrapper).
- The end-to-end script (below) was run against a `#### Diagram`-marked `scalel`:
  1 diagram injected, idempotent on re-run, other (unmarked) functions untouched.

## Decisions (locked with user)

- **Embed** as **inline self-contained SVG** in the generated page body (no asset
  directory; the page stays a pure product of the pipeline; ~4 KB per diagram).
- **Cover only meaningful signal-flow functions** (opt-in), not constants/values
  whose diagram is a trivial number box.
- **Source** of each diagram = the function's own `#### Test` snippet, transformed
  `NAME_test = EXPR;` → `process = EXPR;`.
- **Depth** = top-level `process.svg` only (self-contained), never the multi-file
  drill-down (non-reproducible hex filenames).
- **This round:** build the pipeline and apply it to `basic`'s **Sweep + Scaling**
  functions: `sweep`, `lsweep`, `zsweep`, `zerox`, `scalel`, `scalee`, `scalec`.

## Mechanism

1. **Opt-in marker.** The library author adds a `// #### Diagram` line to a
   function's doc block (right after its `#### Test` block). `make md` renders it
   as a `#### Diagram` heading (h4 — hidden from the sidebar TOC by the existing
   CSS, shown as a small label in the body).
2. **New pipeline step `make svg`** (runs after `make md`): the script
   `doc/scripts/svg-embed.py` scans each generated `doc/build/seam.<name>.md`;
   for every `#### Diagram` heading it takes the nearest preceding `#### Test`
   code, rewrites `NAME_test = EXPR;` → `process = EXPR;`, compiles it with
   `faust -svg -I ../src`, self-contains the top `process.svg` (drop `<?xml?>`,
   `<a xlink:href>`, `</a>`), and injects it after the heading wrapped in
   `<div class="faust-diagram">`. Idempotent: an already-injected figure is
   replaced, not stacked.
3. **Presentation.** A `.faust-diagram` rule in the blog `assets/css/main.scss`
   makes the fixed-size Faust SVG responsive (`max-width:100%`, `height:auto`)
   and lets wide diagrams scroll inside their own box (`overflow-x:auto`) so the
   page body never scrolls horizontally.
4. **Publish.** Re-copy the SVG-enriched `doc/build/seam.basic.md` body into the
   blog `_libraries/basic.md` (same front-matter assembly as before).

Determinism means regeneration yields byte-identical SVGs, so re-running the
pipeline produces clean (empty) diffs unless the source math actually changed.

## Part A — `librerie/faust-libraries`

- **A1.** Add `doc/scripts/svg-embed.py` (the verified script; full text in the plan).
- **A2.** `doc/Makefile`: add a phony `svg` target (depends on `md`) that runs
  `svg-embed.py` on each `build/*.md` with `-I $(SEAMLIB)`, and a `doc: md svg`
  convenience target. Requires `python3` (system, on macOS) and `faust`.
- **A3.** `src/seam.basic.lib`: add `// #### Diagram` after the `#### Test` block
  of `sweep`, `lsweep`, `zsweep`, `zerox`, `scalel`, `scalee`, `scalec`.

## Part B — `blog/s-e-a-m.github.io`

- **B1.** `assets/css/main.scss`: add the `.faust-diagram` rules (responsive SVG,
  horizontal scroll on overflow, centered, a little vertical margin).
- **B2.** Republish `_libraries/basic.md` = existing 5-line front matter + blank
  line + the SVG-enriched regenerated body.

## Out of scope (noted)

- Applying diagrams to `math` and other libraries (fast follow: add `#### Diagram`
  markers + rerun `make doc`, republish).
- Custom per-diagram `process` expressions that differ from the `#### Test`
  (v1 reuses the Test; a Test is assumed to be a single `NAME_test = EXPR;` line).
- Committing generated SVGs as files (we inline; `doc/build/` stays untracked).

## Verification / success criteria

- `make -C doc md && make -C doc svg` injects exactly 7 `<div class="faust-diagram">`
  figures into `doc/build/seam.basic.md`, one per marked function; re-running is a
  no-op (idempotent); no `xlink:href` or `<?xml` remains in the injected SVGs.
- Every marked function's `#### Test` compiles as a `process` under `faust -I src`.
- Local Jekyll build serves `/faustlibraries/basic/` with 7 rendered diagrams
  (un-escaped `<svg>`, styled by `.faust-diagram`), the page body does not scroll
  horizontally, and the sidebar TOC is unchanged.
