# `basic` Library Refinements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove `vstin`, add curved scaling (`scalee`/`scalec`) and list manipulators (`lrev`/`lrot`) to `seam.basic.lib`, and fix the published doc page (right-hand TOC clutter + `/faustlibraries/` URL and title).

**Architecture:** Two repos. In `librerie/faust-libraries` we edit one source file (`src/seam.basic.lib`) and regenerate its markdown with the existing `doc/` awk pipeline. In `blog/s-e-a-m.github.io` (a `remote_theme` Minimal Mistakes Jekyll site) we change the collection permalink, the page front matter, the sidebar nav, add a CSS override for the TOC, and paste the regenerated body.

**Tech Stack:** Faust 2.85.5 (Homebrew `/usr/local/bin/faust`), GNU `gawk`, Jekyll + `github-pages` gem, Minimal Mistakes remote theme, SCSS.

## Global Constraints

- Faust compiler: stable Homebrew `faust` (NOT the ondemand dev build). Compile real files, never stdin. Resolve seam imports with `-I src`.
- Repo A path: `/Users/giuseppe/Documents/github/seam/librerie/faust-libraries` (branch `master`).
- Repo B path: `/Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io`.
- Scratchpad for temp `.dsp`: `/private/tmp/claude-501/-Users-giuseppe-Documents-github-seam-librerie-faust-libraries/ecf3de67-9a57-42d9-85de-ed0da390f8a9/scratchpad`.
- Preserve every academic citation and existing doc-comment style; new functions get full faust2md doc blocks matching the file's format.
- `doc/build/` is untracked in Repo A — do not `git add` it; it is only an intermediate fed to Repo B.
- Commit messages end with the Co-Authored-By trailer used in this repo's history.
- Both repos are on their default branch; the user has approved committing this work.

---

## Task 1: Remove `vstin` and the Routing section (Repo A)

**Files:**
- Modify: `src/seam.basic.lib` (top section list; Routing section + `vstin` at EOF)
- Test: temp `.dsp` compiled with `faust -I src`

**Interfaces:**
- Consumes: nothing.
- Produces: `seam.basic.lib` with sections Sweep / List / Scaling only; `sba.vstin` no longer resolves.

- [ ] **Step 1: Write the failing test** (confirms `vstin` currently exists, then that it's gone)

Create `$SCRATCH/vstin_test.dsp`:
```faust
import("seam.lib");
process = sba.vstin(1,3);
```

- [ ] **Step 2: Run test — verify it PASSES now (baseline)**

Run (from Repo A root):
```bash
faust -I src "$SCRATCH/vstin_test.dsp" -o /dev/null 2>&1; echo "EXIT=$?"
```
Expected: `EXIT=0` (vstin still defined — baseline before removal).

- [ ] **Step 3: Remove the Routing entry from the top section list**

In `src/seam.basic.lib`, delete this line from the header block:
```faust
// * [Routing](#routing)
```
(Leave the `Sweep Functions`, `List Functions`, `Scaling` lines.)

- [ ] **Step 4: Remove the Routing section and `vstin` definition**

Delete this entire trailing block (section header through the definition):
```faust
//================================ Routing ===================================
//============================================================================

//-------------------------------`(sba.)vstin`-------------------------------
// Input manager: pass the first `y` channels through, block the next `n`.
//
// #### Usage
// ```
// si.bus(y+n) : vstin(y,n) : si.bus(y)
// ```
// Where:
//
// * `y`: number of channels to pass
// * `n`: number of channels to block
//
// #### Test
// ```
// sba = library("seam.basic.lib");
// vstin_test = sba.vstin(1,3);
// ```
//----------------------------------------------------------------------------
vstin(y,n) = si.bus(y),si.block(n);
```

- [ ] **Step 5: Run test — verify it now FAILS**

Run:
```bash
faust -I src "$SCRATCH/vstin_test.dsp" -o /dev/null 2>&1; echo "EXIT=$?"
```
Expected: non-zero EXIT with an "undefined symbol vstin" style error — confirms removal.

- [ ] **Step 6: Regression — the rest of the library still compiles**

Create `$SCRATCH/basic_smoke.dsp`:
```faust
import("seam.lib");
process = sba.sweep(1,10), (os.osc(1000):sba.scalel(-1,1,0,1)), sba.revlist(4);
```
Run:
```bash
faust -I src "$SCRATCH/basic_smoke.dsp" -o /dev/null 2>&1; echo "EXIT=$?"
```
Expected: `EXIT=0`.

- [ ] **Step 7: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
git add src/seam.basic.lib
git commit -m "refactor(basic): drop sba.vstin and empty Routing section

vstin is unused workspace-wide; signal-bus routing belongs to seam.routes.lib.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Add `scalee` and `scalec` to the Scaling section (Repo A)

**Files:**
- Modify: `src/seam.basic.lib` (Scaling section, after `scalel`)
- Test: temp `.dsp` compiled with `faust -I src`

**Interfaces:**
- Consumes: `seam.basic.lib` from Task 1.
- Produces:
  - `scalee(a,b,c,d,x)` → geometric rescale, output `= c * pow(d/c, (x-a)/(b-a))`.
  - `scalec(a,b,c,d,curve,x)` → power-curve rescale, output `= c + pow((x-a)/(b-a), curve) * (d-c)`.

- [ ] **Step 1: Write the failing test**

Create `$SCRATCH/scale_test.dsp`:
```faust
import("seam.lib");
process = (os.osc(1) : sba.scalee(-1,1,20,20000)),
          (os.osc(1) : sba.scalec(-1,1,0,1,2));
```

- [ ] **Step 2: Run test — verify it FAILS**

```bash
faust -I src "$SCRATCH/scale_test.dsp" -o /dev/null 2>&1; echo "EXIT=$?"
```
Expected: non-zero EXIT — `scalee`/`scalec` undefined.

- [ ] **Step 3: Add the two definitions with doc blocks**

In `src/seam.basic.lib`, immediately AFTER the `scalel(a,b,c,d,x) = ...;` line (still inside the Scaling section), insert:
```faust

//-------------------------------`(sba.)scalee`------------------------------
// Exponential (geometric) rescale of `x` from input range `[a,b]` to output
// range `[c,d]`. Perceptually uniform — a linear control sounds even — so it
// is ideal for frequency and gain. The curve is fixed by the ratio `d/c`.
//
// Requires `c` and `d` non-zero and of the same sign; for ranges that include
// zero use `scalec`.
//
// #### Usage
// ```
// _ : scalee(a,b,c,d) : _
// ```
// Where:
//
// * `a`, `b`: input range (min, max)
// * `c`, `d`: output range (min, max), same sign, non-zero
//
// #### Test
// ```
// os = library("oscillators.lib");
// sba = library("seam.basic.lib");
// scalee_test = os.osc(1) : sba.scalee(-1,1,20,20000);
// ```
//----------------------------------------------------------------------------
scalee(a,b,c,d,x) = c * pow(d/c, (x-a)/(b-a));

//-------------------------------`(sba.)scalec`------------------------------
// Curved (power) rescale of `x` from `[a,b]` to `[c,d]`, shaped by `curve`:
// `curve=1` is linear, `curve>1` eases in (slow start), `curve<1` eases out
// (fast start). Works for any output range, including `c=0`. Keep `x` within
// `[a,b]` (a negative normalized base with a fractional `curve` is undefined).
//
// #### Usage
// ```
// _ : scalec(a,b,c,d,curve) : _
// ```
// Where:
//
// * `a`, `b`: input range (min, max)
// * `c`, `d`: output range (min, max)
// * `curve`: curvature exponent (>0); 1 = linear
//
// #### Test
// ```
// os = library("oscillators.lib");
// sba = library("seam.basic.lib");
// scalec_test = os.osc(1) : sba.scalec(-1,1,0,1,2);
// ```
//----------------------------------------------------------------------------
scalec(a,b,c,d,curve,x) = c + pow((x-a)/(b-a), curve) * (d-c);
```

- [ ] **Step 4: Run test — verify it PASSES**

```bash
faust -I src "$SCRATCH/scale_test.dsp" -o /dev/null 2>&1; echo "EXIT=$?"
```
Expected: `EXIT=0`.

- [ ] **Step 5: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
git add src/seam.basic.lib
git commit -m "feat(basic): add scalee (geometric) and scalec (power-curve) scaling

Fills a gap absent from the official basics.lib: a generic curved rescale.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Add `lrev` and `lrot` to List Functions + bump version (Repo A)

**Files:**
- Modify: `src/seam.basic.lib` (List Functions section, after `revlist`; `declare version`)
- Test: temp `.dsp` compiled with `faust -I src`

**Interfaces:**
- Consumes: `seam.basic.lib` from Task 2.
- Produces:
  - `lrev(l)` → reverses a list-literal.
  - `lrot(l,k)` → cyclic rotation of a list-literal (`k>0` left, `k<0` right, `k` mod length).

- [ ] **Step 1: Write the failing test**

Create `$SCRATCH/list_test.dsp`:
```faust
import("seam.lib");
process = sba.lrev((10,20,30)),
          sba.lrot((1,2,3,4),1),
          sba.lrot((1,2,3,4),-1),
          sba.lrot((1,2,3,4),5);
```

- [ ] **Step 2: Run test — verify it FAILS**

```bash
faust -I src "$SCRATCH/list_test.dsp" -o /dev/null 2>&1; echo "EXIT=$?"
```
Expected: non-zero EXIT — `lrev`/`lrot` undefined.

- [ ] **Step 3: Add the two definitions with doc blocks**

In `src/seam.basic.lib`, immediately AFTER the `revlist(n) = par(i,n,(n)-i);` line (inside the List Functions section), insert:
```faust

//-------------------------------`(sba.)lrev`--------------------------------
// Reverse a list-literal: the parallel bus `(x0,x1,...,xn)` becomes
// `(xn,...,x1,x0)`. Generalizes `revlist` (which only generates a descending
// counter) to any list of values.
//
// #### Usage
// ```
// lrev((x0,x1,...,xn))
// ```
// Where:
//
// * the argument is a list-literal (compile-time parallel expression)
//
// #### Test
// ```
// sba = library("seam.basic.lib");
// lrev_test = sba.lrev((10,20,30));
// ```
//----------------------------------------------------------------------------
lrev(l) = par(i, ba.count(l), ba.take(ba.count(l)-i, l));

//-------------------------------`(sba.)lrot`--------------------------------
// Cyclically rotate a list-literal by `k`: `((1,2,3,4),1)` becomes
// `(2,3,4,1)`. `k` is taken modulo the list length, so any integer is valid;
// positive `k` rotates left, negative rotates right.
//
// #### Usage
// ```
// lrot((x0,x1,...,xn), k)
// ```
// Where:
//
// * the first argument is a list-literal
// * `k`: rotation amount (compile-time integer)
//
// #### Test
// ```
// sba = library("seam.basic.lib");
// lrot_test = sba.lrot((1,2,3,4),1);
// ```
//----------------------------------------------------------------------------
lrot(l,k) = par(i, ba.count(l), ba.take(((i+k)%ba.count(l)+ba.count(l))%ba.count(l)+1, l));
```

- [ ] **Step 4: Bump the library version**

In `src/seam.basic.lib`, change:
```faust
declare version "0.3";
```
to:
```faust
declare version "0.4";
```

- [ ] **Step 5: Run test — verify it PASSES**

```bash
faust -I src "$SCRATCH/list_test.dsp" -o /dev/null 2>&1; echo "EXIT=$?"
```
Expected: `EXIT=0`.

- [ ] **Step 6: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
git add src/seam.basic.lib
git commit -m "feat(basic): add lrev/lrot list manipulators; bump to v0.4

List-literal reverse and cyclic rotate (value-level, not signal-bus routing).

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Collection permalink, page title, and sidebar nav → `/faustlibraries/` (Repo B)

**Files:**
- Modify: `_config.yml:91`
- Modify: `_libraries/basic.md` (front matter lines 2–3)
- Modify: `_data/navigation.yml:16`

**Interfaces:**
- Consumes: nothing.
- Produces: the `basic` page served at `/faustlibraries/basic/` with a Faust-referencing title.

- [ ] **Step 1: Change the collection permalink**

In `_config.yml`, under `collections: libraries:`, change:
```yaml
    permalink: /libraries/:path/
```
to:
```yaml
    permalink: /faustlibraries/:path/
```

- [ ] **Step 2: Update the page front matter**

In `_libraries/basic.md`, change the first lines:
```yaml
title: "basic"
permalink: /libraries/basic/
```
to:
```yaml
title: "Faust Libraries · basic"
permalink: /faustlibraries/basic/
```
(Leave `toc: true` and the `---` fences intact.)

- [ ] **Step 3: Update the sidebar nav link**

In `_data/navigation.yml`, change:
```yaml
        url: /libraries/basic/
```
to:
```yaml
        url: /faustlibraries/basic/
```

- [ ] **Step 4: Verify there are no other `/libraries/` references left**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
grep -rn "/libraries/" _pages _data _config.yml _libraries 2>/dev/null
```
Expected: no output (all references now `/faustlibraries/`).

- [ ] **Step 5: Build and verify the new path**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
bundle exec jekyll build 2>&1 | tail -5
ls _site/faustlibraries/basic/index.html && echo "PATH OK"
grep -o "<title>[^<]*</title>" _site/faustlibraries/basic/index.html | head -1
```
Expected: `PATH OK`, and the `<title>` contains "Faust Libraries · basic".
(If `bundle` is unavailable, install first with `bundle install`; the remote theme needs network on first build.)

- [ ] **Step 6: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
git add _config.yml _libraries/basic.md _data/navigation.yml
git commit -m "site(libraries): serve library pages under /faustlibraries/ with Faust-referencing title

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: TOC depth clamp + visual hierarchy via CSS override (Repo B)

**Files:**
- Create: `assets/css/main.scss`

**Interfaces:**
- Consumes: nothing (independent of Task 4).
- Produces: right-hand TOC showing only section (`h2`) + function (`h3`) entries, with sections visually heavier than functions.

- [ ] **Step 1: Create the Minimal Mistakes CSS override file**

Create `assets/css/main.scss` with EXACTLY this content (the leading `---` front matter is required so Jekyll processes the SCSS; the two `@import`s reproduce the theme's own `main.scss`, then our rules are appended):
```scss
---
# Custom styles layered on top of the Minimal Mistakes theme.
# The empty front matter is required for Jekyll to compile this SCSS.
---

@charset "utf-8";

@import "minimal-mistakes/skins/{{ site.minimal_mistakes_skin | default: 'default' }}";
@import "minimal-mistakes";

/* ===== Library reference: tidy the right-hand table of contents ===== */

/* Drop Usage/Test (h4) and deeper from the sidebar TOC.
   MM nests one <ul> per heading level, so ".toc__menu ul ul" is the h4 list.
   Headings stay in the body — only the sidebar is trimmed. */
.toc__menu ul ul {
  display: none;
}

/* Section titles (h2): heavier, uppercase, clearly the top level. */
.toc__menu > li > a {
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

/* Function entries (h3): lighter and subordinate. */
.toc__menu > li > ul > li > a {
  font-weight: 400;
  text-transform: none;
  letter-spacing: 0;
  opacity: 0.85;
}
```

- [ ] **Step 2: Build the site**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
bundle exec jekyll build 2>&1 | tail -5
```
Expected: build completes with no SCSS error.

- [ ] **Step 3: Verify the TOC in the built page**

Open `_site/faustlibraries/basic/index.html` in a browser (or inspect the `.toc__menu` markup). Confirm:
- The right-hand TOC lists only section titles and function names — no "Usage"/"Test"/"Where" entries.
- Section titles are visibly bolder/uppercase; function names are lighter and indented under them.

If h4 entries are still visible, the theme's TOC nesting differs from the assumption — inspect the generated `.toc__menu` markup and adjust the `.toc__menu ul ul` selector to match the actual h4 wrapper before continuing. If the size contrast is too weak/strong, tune `font-weight`/`opacity` on the two selectors.

- [ ] **Step 4: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
git add assets/css/main.scss
git commit -m "site(css): clamp library TOC to sections+functions and clarify hierarchy

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Regenerate and publish the `basic` doc body (Repo A → Repo B)

**Files:**
- Regenerate (Repo A, untracked): `doc/build/seam.basic.lib.md`
- Modify (Repo B): `_libraries/basic.md` (body below the front matter)

**Interfaces:**
- Consumes: `seam.basic.lib` from Task 3; front matter from Task 4.
- Produces: published body reflecting the new functions and no `vstin`/Routing.

- [ ] **Step 1: Regenerate the markdown from the edited source**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
make -C doc md
```
Expected: prints `building ../src/seam.basic.lib`; writes `doc/build/seam.basic.lib.md`.

- [ ] **Step 2: Sanity-check the regenerated markdown**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
grep -cE "scalee|scalec|lrev|lrot" doc/build/seam.basic.lib.md   # expect >= 4
grep -cE "vstin|# +Routing" doc/build/seam.basic.lib.md          # expect 0
```
Expected: first count ≥ 4, second count 0.

- [ ] **Step 3: Replace the body of the published page (keep front matter)**

In Repo B `_libraries/basic.md`, keep the 5 front-matter lines (the `---` … `---` block from Task 4) and replace EVERYTHING below them with the full contents of Repo A `doc/build/seam.basic.lib.md`. (The generated file has no front matter, so paste it directly after the closing `---`.)

- [ ] **Step 4: Build and verify the published body**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
bundle exec jekyll build 2>&1 | tail -5
grep -cE "scalee|scalec|lrev|lrot" _site/faustlibraries/basic/index.html   # expect >= 4
grep -c "vstin" _site/faustlibraries/basic/index.html                       # expect 0
```
Expected: functions present, `vstin` absent.

- [ ] **Step 5: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
git add _libraries/basic.md
git commit -m "docs(basic): republish body — curved scaling + list manipulators, no vstin

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Final verification (all tasks)

- [ ] Repo A: `git log --oneline -3` shows the three basic.lib commits; `git status` clean.
- [ ] Repo B: `git log --oneline -3` shows the three site commits; `git status` clean.
- [ ] Repo A: `faust -I src "$SCRATCH/list_test.dsp" -o /dev/null; echo $?` and the scale test both exit 0; the vstin test exits non-zero.
- [ ] Repo B: `_site/faustlibraries/basic/index.html` exists; browser tab title references Faust Libraries; TOC shows only sections + functions with clear hierarchy; body shows `scalee`/`scalec`/`lrev`/`lrot` and no `vstin`/Routing.
- [ ] Push both repos (user-approved): `git push` in each. GitHub Pages redeploys Repo B.
