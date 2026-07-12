# Design — `seam.math.lib` documentation + audit pass

**Date:** 2026-07-12
**Author:** Giuseppe Silvi (with Claude)
**Status:** Approved
**Repos touched:** `librerie/faust-libraries` (source + generated doc), `blog/s-e-a-m.github.io` (Jekyll site)

## Context

Second library documented with the SEAM faust2md single-source-of-truth pipeline,
after the `basic` pilot. `seam.math.lib` (prefix `sma`, active in `seam.lib`,
v0.1) already holds ~21 symbols but has **no faust2md doc blocks** — only informal
banner comments and inline `// process =` tests. This pass documents it (like
`basic`), applies an audit vs the official `maths.lib`, and publishes it at
`/faustlibraries/math/`.

The reusable TOC lesson from the `basic` round-2 fix is applied from the start:
headings must be monotonic and the top `References` block is an `## h2` section,
so the Minimal Mistakes right-hand TOC nests correctly.

All Faust changes below were **compile-verified** with `faust 2.85.5` against the
real `seam.lib` (temporary swap-and-restore), and the doc generation was previewed
with `doc/scripts/faustlib2md.awk`.

## Audit decisions (locked with user)

Vs the official `maths.lib`, most of `seam.math.lib` is genuinely additive
(no `deg2rad`/`rad2deg`, factorial, golden ratio, bilinear prewarp, spherical
conversions, or speed-of-sound upstream). Scrutiny outcomes:

- **Remove** `PIc` (`atan(1)*4`, identical to `ma.PI`) and `PIq` (81-decimal
  literal Faust truncates to double) — redundant with `ma.PI`. 0 external uses.
- **Rename** `w(fc)` → `prewarp(fc)` (self-documenting). Update the 2 call sites
  in `seam.filters.lib` (`g(fc) = sma.w(fc)` at lines 60 and 72).
- **Fix** `permutation(k,n) = k!/n!` → `permutation(n,k) = n!/(n-k)!` (standard
  nPr). 0 external uses.
- **Fix** `xyz2aed` elevation from the zenith angle `atan2(sqrt(x^2+y^2), z)` to
  `atan2(z, sqrt(x^2+y^2))`, making `aed2xyz`/`xyz2aed` exact inverses (elevation
  measured from the horizontal plane). 0 external uses. Latent bug found during
  authoring, analogous to the `scalel` `+c` fix in the `basic` pilot.

**Kept and documented (19 public symbols):** `twoPI, omega, prewarp, cosq, sinq,
d2r, r2d, aed2xyz, xyz2aed, phi, rphi, srphi, factorial, permutation, esos, isos,
emt2samp, imt2samp, imdelay`. `imdelay` is the only stateful function (wraps
`de.delay`) — documented as such. Version bumped 0.1 → 0.2.

## Doc structure (7 sections + References)

Header block (h1 title + description + bullet index + `## References`), then:

1. **Constants and Angular Frequency** — `twoPI`, `omega`, `prewarp`
2. **Trigonometry** — `cosq`, `sinq`
3. **Angle Conversion** — `d2r`, `r2d`
4. **Coordinates** — `aed2xyz`, `xyz2aed`
5. **Golden Ratio** — `phi`, `rphi`, `srphi`
6. **Combinatorics** — `factorial`, `permutation`
7. **Acoustics** — `esos`, `isos`, `emt2samp`, `imt2samp`, `imdelay`

Each function gets the standard faust2md block (`` `(sma.)name` `` header,
description, `#### Usage`, `Where` bullets, `#### Test`). Section banners use the
`//===== Name =====` form the awk renders as `## Name`.

## Part A — `librerie/faust-libraries`

- **A1.** Rewrite `src/seam.math.lib` with the full documented + audited content
  (the complete verified file is embedded in the implementation plan).
- **A2.** `src/seam.filters.lib`: rename both `sma.w(fc)` → `sma.prewarp(fc)`
  (lines 60, 72); verify `seam.filters.lib` still compiles.
- **A3.** Add `doc/audit-math.md` — the per-symbol audit decision record (mirrors
  `doc/audit-basic.md`).
- **A4.** Regenerate `doc/build/seam.math.md` via `make -C doc md` (untracked
  intermediate; do not commit under `doc/build/`).

## Part B — `blog/s-e-a-m.github.io`

- **B1.** Create `_libraries/math.md` = 5-line Jekyll front matter
  (`title: "Faust Libraries · math"`, `permalink: /faustlibraries/math/`,
  `toc: true`) + a blank line + the regenerated `doc/build/seam.math.md` body.
- **B2.** `_data/navigation.yml`: add a `math (sma)` child under "Library
  Reference" with `url: /faustlibraries/math/`.
- **B3.** No CSS or config changes — the `/faustlibraries/` permalink and the TOC
  CSS override are already global from the `basic` work.

## Out of scope (noted)

- `process` SVG block diagrams in the doc (deferred; `faust -svg`).
- Documenting `filters` itself (this pass only renames its 2 `sma.w` call sites).
- Any new math utilities (scope is document + audit existing only).

## Verification / success criteria

- `faust -I src` compiles a smoke DSP exercising all 19 kept symbols; `sma.PIc`
  and `sma.PIq` no longer resolve; `seam.filters.lib` compiles after the rename.
- `permutation(5,2)=20`; `aed2xyz`→`xyz2aed` round-trips (elevation preserved).
- `make -C doc md` regenerates `seam.math.md` with 7 `##` sections, `## References`
  first (no h1→h4 jump), 19 `### (sma.)` function blocks, no `PIc`/`PIq`/`w`.
- Local Jekyll build serves `/faustlibraries/math/`; sidebar shows `math (sma)`;
  right-hand TOC lists only sections + functions with clear hierarchy; the
  top-of-page bullet anchors all resolve.
