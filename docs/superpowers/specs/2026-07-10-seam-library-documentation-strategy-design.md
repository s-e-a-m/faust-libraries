# SEAM Library Documentation Strategy — Design

**Date:** 2026-07-10
**Author:** Giuseppe Silvi (with Claude)
**Status:** Approved (design), pending implementation plan
**Pilot library:** `seam.basic.lib` (prefix `sba`)

---

## 1. Overview

SEAM maintains a set of Faust libraries (`src/seam.*.lib`) that extend the standard
Faust libraries. They are richly commented but have **no published reference
documentation** and their comment style is only *partially* aligned with the Faust
distribution's conventions.

This design establishes a documentation strategy in which **the library comments are
the single source of truth**, authored in the GRAME `faust2md` convention, and rendered
to multiple targets automatically — with the SEAM website as the primary published
output. Documenting a library is also used as a **validation pass** over that library
("the product that self-determines"): writing each function's `Usage`/`Where` block
forces a decision about whether the function is correct, well-named, and legitimately
SEAM-specific.

### Guiding principle — one substrate, four outputs

The same `//###` / `//===` / `//---` comment markers inside a `.lib` feed, with no
duplicated hand-written docs:

1. **Live IDE docs** — `faustide-od`'s in-browser `Faust2MD.ts` parser (hover tooltips,
   Ctrl-D) on any loaded lib.
2. **SEAM website** — generated markdown rendered by the SEAM Jekyll site (primary).
3. **GitHub `.md`** — browsable reference in the repo.
4. **LLM sources** — an `llms.txt`-style pointer to the authoritative markdown.

## 2. Goals / Non-goals

**Goals**
- Adopt the GRAME `faust2md` authoring convention across active `src/` libraries.
- Reuse GRAME's extractor (`faustlib2md.awk`) unchanged for `.lib → .md`.
- Publish the reference on the **SEAM Jekyll site** (`s-e-a-m.github.io`), with a
  documentation section/skin, one library at a time starting with `basic`.
- Use the documentation pass to **audit** each library against the official Faust
  libraries, keeping only what is not already provided upstream.

**Non-goals (for now)**
- Full cross-repo build automation (submodule / GitHub Action). Pilot uses manual copy.
- Documenting `temp/` (WIP) libraries — excluded, mirroring GRAME's exclusion of
  deprecated libs.
- Extending `faustide-od`'s `docSections` prefix map (3-letter SEAM prefixes vs 2-letter
  standard) — noted as a follow-up for full IDE Ctrl-D integration.

## 3. Authoring convention (per library)

Three GRAME markers, **closed on both sides** (compatible with both `faustlib2md.awk`
and the IDE's stricter `Faust2MD.ts` regex):

### 3.1 Library header — `//###### seam.basic.lib ######`
Body must include:
- A prose description of the library.
- The official prefix, using the exact GRAME phrasing: `` Its official prefix is `sba`. ``
- A usage block:
  ````
  // ```
  // sba = library("seam.basic.lib");
  // process = sba.functionCall;
  // ```
  // Another option is to import `seam.lib`:
  // ```
  // import("seam.lib");
  // process = sba.functionCall;
  // ```
  ````
- A section table-of-contents with anchor links.
- A `#### References` block.

### 3.2 Section — `//====== Section Name ======`
One per thematic group (e.g. Sweep Functions, List Functions, Scale, Logic). Replaces
the current misuse of `//---` markers for grouping.

### 3.3 Function — `` //------`(sba.)sweep`------ ``
Signature in backticks at the marker (so the function is indexed and the IDE hover binds
the name). Body:
- Short description. If the function is a variant of a standard one, an explicit note:
  *"Differs from `ba.sweep`: counts from 0 (not 1) …"*.
- `#### Usage` — a fenced code block with the call signature.
- `Where:` — a bullet list of parameters.
- `#### Test` — a compilable snippet. **Reuse the existing `//process = …` inline tests**
  as the seed for these.
- Preserve per-function `declare author "…"` / `declare license "…"` where present —
  **required** for the academic citations (Di Scipio, Gerzon, Linkwitz).

### 3.4 Versioning
Each library keeps a semver `declare version`. (A global version file, à la GRAME's
`version.lib`, is out of scope for the pilot.)

## 4. Extraction pipeline (GRAME-compatible) — new files

A new `doc/` folder inside `faust-libraries`, mirroring the `faustlibraries/doc/` layout:
- **Reuse `faustlib2md.awk` unchanged** for `.lib → .md`. No new extractor code.
- Driven by the `src/seam.lib` import-list (SEAM's equivalent of GRAME's `doc.lib`):
  active `src/` libs are documented; `temp/` is excluded.
- A `makeindex`-style step builds a cross-library index of `` `(sX.)fn` `` signatures.
- Generated `.md` is **not committed** (regenerated on build), following GRAME's rule.

> **Rejected alternative:** porting the IDE's `Faust2MD.ts`. It is valuable *in-browser*
> but for offline site generation the proven AWK is more direct and keeps us
> bit-compatible with GRAME.

## 5. Publishing on the SEAM site (Jekyll / minimal-mistakes) — new files

The SEAM site is Jekyll + the `minimal-mistakes` remote theme (kramdown, dark skin,
search). Plan:
- A **`_libraries` collection** holding one page per documented library.
- A **doc layout** + a **sidebar** defined in `_data/navigation.yml` — the native
  minimal-mistakes "docs" pattern.
- A thin **adapter** step that prepends Jekyll front matter (layout, collection, nav
  key, title) to each generated `.md`.
- Optional dedicated **documentation skin** via minimal-mistakes SCSS overrides.
- **Cross-repo transfer:** for the pilot, copy `basic.md` into the site manually.
  `faust-libraries` is not currently a submodule of the site; automation (submodule or a
  GitHub Action that regenerates and pushes) is deferred.

**Compatibility note:** Jekyll uses kramdown, mkdocs uses python-markdown. Because
`faust2md` output is intentionally simple (headings, lists, fenced code), it renders
identically on both — this is exactly why "GRAME-compatible authoring" and "SEAM-native
rendering" do not conflict.

## 6. Audit gate — documentation as validation

`seam.basic.lib` predates recent Faust releases and has never been re-checked against the
official `basics.lib` (87 public `ba.*` functions today). Rule: **`basic` should contain
only objects not already provided by the official library.**

Before documenting each function, a **per-function decision gate**: present *what `ba.*`
does* vs *what the SEAM function does*, and the user decides **function by function** —
keep / keep-as-justified-variant / remove. Bugs found are fixed.

First-pass audit of `seam.basic.lib`:

| Function | In official `ba.*`? | Preliminary verdict |
|---|---|---|
| `sweep(p,t)` | **yes** (`ba.sweep`, variant) | redundant-but-variant → justify or remove |
| `lsweep(sec,t)` | no (near `line`/`ramp`/`os.lf_rawsaw`) | likely SEAM-only — verify vs oscillators |
| `zsweep(p)` | no | SEAM-only |
| `zerox(x)` | no in `ba` | likely SEAM-only — verify vs `an.*` analyzers |
| `revlist(n)` | no | SEAM-only |
| `scalel(a,b,c,d,x)` | no `scale` in `ba` (there is `bpf`) | SEAM-only, **but has the `+c` bug** |
| `vstin(y,n)` | no (composes `si.bus`/`si.block`) | SEAM-only utility |
| `mille/cento/la/rosa/nyq` | no | convenience aliases — decide: public API or noise? |

**Known bug:** `scalel(a,b,c,d,x) = ((x-a)/(b-a))*(d-c)` is missing the `+c` offset; the
correct affine map `[a,b]→[c,d]` is `c + ((x-a)/(b-a))*(d-c)`. The current example
`scalel(-1,1,0,1)` masks it because `c=0`.

## 7. Pilot scope & cadence

End-to-end pilot on **`seam.basic.lib`**:
1. Audit each function (gate with user).
2. Refactor comments to the convention (§3); fix bugs (`scalel`).
3. Stand up the `doc/` extraction pipeline (§4); generate `basic.md`.
4. Publish on the SEAM site (§5); verify rendering; verify IDE hover via drag&drop.
5. Verify every `#### Test` snippet compiles (stable `faust`; `faust-od` if `ondemand`).

Then repeat **one library at a time**.

## 8. Coordination & constraints

- A **parallel session is active on branch `dslar`.** This work writes **new files**
  (the `doc/` pipeline, the Jekyll collection). The only **existing** file edited is
  `seam.basic.lib`, which is unrelated to the dslar work and edited **only after** the
  user's per-function decisions — never autonomously.
- **No git operations by default** (no commit/push/rebase) — versioning is handled by the
  user to avoid colliding with the parallel session.
- **Two Faust binaries:** stable Homebrew `faust` (no `ondemand`, no stdin `-`) for
  normal compiles; `faust-od` dev build only for `ondemand`. Compile with
  `faust -I src <file>.dsp`. (See memory `faust-two-binaries`.)

## 9. Success criteria

- `seam.basic.lib` contains only functions not already in official `ba.*` (or documented,
  justified variants), with `scalel` fixed.
- Every public function has a header/section/`Usage`/`Where`/`Test` doc block in GRAME
  convention; `faustlib2md.awk` produces clean `basic.md` with no empty phantom `###`.
- `basic.md` renders on the SEAM Jekyll site under a Library Reference section.
- IDE hover-doc shows SEAM function docs when `seam.basic.lib` is loaded in `faustide-od`.
- Every `#### Test` snippet compiles.

## 10. Open questions (to resolve during implementation)

- `mille/cento/la/rosa/nyq`: keep as a didactic SEAM vocabulary or drop from the public API?
- `sweep`: keep the from-0 variant (documented) or defer to `ba.sweep`?
- Section names for `basic` (final taxonomy of the `//===` groups).
- Doc skin: reuse minimal-mistakes default doc styling for the pilot, or invest in a
  custom SEAM documentation skin now?
