# SEAM `basic` Library Documentation Pilot — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Audit, document (GRAME `faust2md` convention), extract, and publish `seam.basic.lib` on the SEAM Jekyll site — the end-to-end pilot for the SEAM library documentation strategy.

**Architecture:** Library comments are the single source of truth. A reused GRAME AWK extractor turns `.lib` comments into markdown; a thin adapter wraps that markdown in Jekyll front matter for the SEAM `minimal-mistakes` site. Documenting each function is also the validation gate that decides whether it stays in `basic`.

**Tech Stack:** Faust (`.lib`), `gawk`/`make`, GRAME `faustlib2md.awk`, Jekyll + `minimal-mistakes` remote theme (kramdown).

**Prerequisite:** `gawk` (the extractor uses `gensub()`, a gawk extension; macOS BSD `awk` fails). Install with `brew install gawk` if `gawk --version` is not found — verify this in Task 1 Step 4.

## Global Constraints

- **Two Faust binaries.** Compile with stable Homebrew `faust -I src <file>.dsp` (no stdin `-` support). Use the dev build `/Users/giuseppe/Documents/github/faust/build/bin/faust` (alias `faust-od`) **only** for `ondemand`. `basic` needs none, so use stable `faust`. (memory `faust-two-binaries`)
- **No git by default.** No commit/push/rebase — a parallel session is active on branch `dslar`; the user handles versioning. Each task ends at a **Checkpoint** (staged-and-summarised for the user), not a commit.
- **New files only, one exception.** All pipeline (`doc/`) and Jekyll files are new. The only existing file edited in `faust-libraries` is `src/seam.basic.lib`, edited **only after** the audit decisions in Task 2. Site files `_config.yml` / `_data/navigation.yml` are existing files in the *separate* site repo (no parallel session there) — edited in Task 5 with a confirmation gate.
- **Preserve academic citations.** Keep every per-function `declare author/license/copyright`.
- **Semver.** Bump `declare version` in `seam.basic.lib` when its content changes.
- **Prefix.** `basic`'s official prefix is `sba` (3 letters — standard Faust prefixes are 2).

---

## File Structure

**Create (in `faust-libraries`, all new):**
- `doc/scripts/faustlib2md.awk` — GRAME extractor, copied verbatim.
- `doc/scripts/makeindex.awk` — GRAME index builder, copied with one path-prefix line adapted.
- `doc/Makefile` — driver: reads active libs from `src/seam.lib`, emits `doc/build/<lib>.md`.
- `doc/audit-basic.md` — records the per-function audit decision + rationale.
- `doc/build/` — generated markdown (git-ignored, never committed).

**Modify (in `faust-libraries`):**
- `src/seam.basic.lib` — apply audit, refactor to convention, fix `scalel`.
- `.gitignore` — add `doc/build/`.

**Create/Modify (in the SEAM site repo `blog/s-e-a-m.github.io`):**
- Create: `_libraries/basic.md` — generated body + Jekyll front matter.
- Modify: `_config.yml` — declare the `libraries` collection + defaults.
- Modify: `_data/navigation.yml` — add the Library Reference sidebar.

---

## Task 1: Stand up the extraction pipeline (`doc/`)

**Files:**
- Create: `doc/scripts/faustlib2md.awk`
- Create: `doc/scripts/makeindex.awk`
- Create: `doc/Makefile`
- Modify: `.gitignore` (append `doc/build/`)
- Test: generate a baseline `doc/build/seam.basic.md` from the *current* (pre-refactor) lib.

**Interfaces:**
- Produces: `make -C doc md` → one `doc/build/seam.<name>.md` per active `src/` lib; `make -C doc build/seam.basic.md` targets a single lib.

- [ ] **Step 1: Create `doc/scripts/faustlib2md.awk`** (verbatim from `grame-cncm/faustlibraries`)

```awk
function removeComment (arg) {
	gsub(/^\/\//, "", arg);
	gsub(/^ /, "", arg);
	return arg;
}

function makeurl(arg) {
	if (index(arg, "<http")) {
		gsub(/ *[*-][^a-zA-Z0-9]/, "", arg);
		url = gensub(/[^>]*<(http[^>]+)>.*/, "\\1", 1, arg);
		if (url == arg) return arg;
		gsub(":", "://", url);
		gsub(/\/\/\/\//, "//", url);
		gsub(/<http..*>/, "["url"]("url")", arg);
		return "* "arg;
	}
	return arg;
}

function makefunction (arg) { gsub(/\/\//, "", arg); gsub(/-*/, "", arg); return "\n----\n\n### " arg "\n"; }
function makegroup (arg)    { gsub(/\/\//, "", arg); gsub(/=*/, "", arg); return "\n## " arg "\n"; }
function makeheader (libname) { return "# "libname "\n"; }

BEGIN { STARTF = 0; PRINTDOC = 0; INGROUP = 0; NAME = ""; VERSION = ""; }
END { }

/^\/\/====*$/ { }
/^\/\/####*$/ { PRINTDOC = 0; }
/^\/\/====*$/ { PRINTDOC = 0; }
/^\/\/----*$/ { PRINTDOC = 0; }
/^\/\/ end/   { }

/^\/\/====*[^=]+/ { print makegroup($0); PRINTDOC = 1; }
/^\/\/####*[^#]+/ { gsub(/\/\//, "", $0); gsub(/#*/, "", $0); print makeheader($0); PRINTDOC = 1; }
/^\/\/----*[^-]+/ { print makefunction($0); PRINTDOC = 1; }

/^\/\/ / { if (PRINTDOC) { line = removeComment($0); line = makeurl(line); print line; } }
/^\/\/$/ { if (PRINTDOC) print ""; }

/declare name[ 	]*]/    { gsub(/^[^"]*"/, "", $0); gsub(/".*/, "", $0); NAME = $0; }
/declare version[ 	]*]/ { gsub(/^[^"]*"/, "", $0); gsub(/".*/, "", $0); VERSION = $0; }
```

- [ ] **Step 2: Create `doc/scripts/makeindex.awk`** (from GRAME; the one adapted line is marked)

```awk
function makeSection(file) {
	section = file;
	gsub(/^build\//, "", section);   # ADAPTED: SEAM build dir (GRAME used docs/libs/)
	sub(/\.md$/, "", section);
	return section;
}
function printSection() { print "### " SECTION; print OUT "\n"; OUT = ""; }
BEGIN { OUT = ""; SECTION = ""; PREVSECTION = ""; print "# SEAM Libraries Index\n\n--------\n"; }
END { }
/^### `\(/ {
	SECTION = makeSection(FILENAME);
	if (SECTION != PREVSECTION) { print "\n## " SECTION "\n"; PREVSECTION = SECTION; }
	gsub(/### `/, "", $0);
	fun = $0; gsub(/`/, "", fun);
	link = fun; gsub(/[\[\]\|\(\)\.]/, "", link); gsub(" ", "-", link);
	print "[" fun "](" SECTION ".md#" tolower(link) ")";
}
```

- [ ] **Step 3: Create `doc/Makefile`**

```makefile
# SEAM library documentation generator (mirrors grame-cncm/faustlibraries/doc)
SEAMLIB ?= ../src
BUILD   ?= build
AWK     ?= gawk   # gensub() in faustlib2md.awk is a gawk extension (BSD awk fails)

# Active libraries = uncommented `xx = library("seam.NAME.lib")` lines in seam.lib
SRC := $(shell grep -oE '^[a-z][a-z]* = library\("seam\.[a-z]+\.lib"\)' $(SEAMLIB)/seam.lib \
         | sed -E 's/.*"(seam\.[a-z]+\.lib)".*/\1/')
MD  := $(SRC:%.lib=$(BUILD)/%.md)

.PHONY: md index list clean
md: $(MD)

$(BUILD)/%.md: $(SEAMLIB)/%.lib
	@mkdir -p $(BUILD)
	@echo "  building $<"
	@cat $< | $(AWK) -f scripts/faustlib2md.awk > $@

index: $(BUILD)/index.md
$(BUILD)/index.md: $(MD)
	@$(AWK) -f scripts/makeindex.awk $(BUILD)/*.md > $@

list:
	@echo $(SRC)

clean:
	rm -rf $(BUILD)
```

- [ ] **Step 4: Verify the driver sees the active libs**

Run: `make -C doc list`
Expected: a space-separated list including `seam.basic.lib` and the other active `src/` libs (NOT the commented-out `temp/` ones like `seam.nono.lib`).

- [ ] **Step 5: Generate a baseline md from the CURRENT lib (proves the pipeline works and exposes the "phantom `###`" problem the refactor fixes)**

Run: `make -C doc build/seam.basic.md && grep -c '^###' doc/build/seam.basic.md`
Expected: file is produced; several `###` headings appear, INCLUDING empty phantom ones like `### SWEEP FUNCTIONS` (this is the pre-refactor state — confirms Task 3 is needed).

- [ ] **Step 6: Ignore generated output**

Append to `.gitignore`:
```
# generated library documentation
doc/build/
```

- [ ] **Step 7: Checkpoint**

Summarise for the user: new `doc/` pipeline created (3 new files + `.gitignore` line), baseline `seam.basic.md` generated. Show the phantom-`###` lines as motivation for Task 3. Do NOT commit (user handles git).

---

## Task 2: Audit `seam.basic.lib` vs official `basics.lib` (decision gate)

**Files:**
- Create: `doc/audit-basic.md` (decision record)
- Read-only: `src/seam.basic.lib`, `/Users/giuseppe/Documents/github/faustlibraries/basics.lib`, `.../oscillators.lib`, `.../analyzers.lib`

**Interfaces:**
- Produces: a verdict `keep` | `variant` | `remove` for each `basic` symbol, consumed by Task 3.

- [ ] **Step 1: Gather evidence for the two functions that need cross-lib checks**

Run:
```bash
R=/Users/giuseppe/Documents/github/faustlibraries
grep -nE 'zc|zero' $R/analyzers.lib | head          # is there an analyzers zero-cross?
grep -nE '`\(os\.\)(lf_saw|sweep|lf_rawsaw)`' $R/oscillators.lib   # linear-sweep neighbours
```
Expected: capture whether `zerox` and `lsweep` have upstream equivalents. Record findings.

- [ ] **Step 2: Create `doc/audit-basic.md` with the decision table**

```markdown
# Audit — seam.basic.lib vs official basics.lib (2026-07-10)

Rule: `basic` keeps only what is NOT already provided upstream (or documented, justified variants).

| symbol | upstream equivalent | evidence | DECISION | rationale |
|---|---|---|---|---|
| sweep(p,t)     | ba.sweep            | variant: counts from 0 (uses 1'), modulus p*t | ? | |
| lsweep(sec,t)  | (none exact)        | near os.lf_rawsaw / line               | ? | |
| zsweep(p)      | (none)              |                                        | ? | |
| zerox(x)       | (check an.*)        |                                        | ? | |
| revlist(n)     | (none)              | ba has take/subseq/count               | ? | |
| scalel(a..d,x) | (none; ba.bpf diff) | HAS +c bug                             | ? | |
| vstin(y,n)     | (none)              | composes si.bus/si.block               | ? | |
| mille/cento/la/rosa/nyq | (none)     | convenience constants                  | ? | |
```

- [ ] **Step 3: Present each row to the user and fill the DECISION column**

For each symbol, show the user: the official behavior (if any) and the SEAM behavior, then ask keep/variant/remove. Fill `doc/audit-basic.md`. This is the "product that self-determines" gate — **do not proceed to Task 3 until every DECISION is set.**

- [ ] **Step 4: Checkpoint**

Summarise the decisions. Confirm with the user that Task 3 may edit `src/seam.basic.lib` accordingly.

---

## Task 3: Refactor `seam.basic.lib` to the convention + apply audit + fix `scalel`

**Files:**
- Modify: `src/seam.basic.lib`
- Test: compile each `#### Test` snippet with `faust -I src`; re-run the extractor.

**Interfaces:**
- Consumes: audit decisions from `doc/audit-basic.md`.
- Produces: a convention-compliant `seam.basic.lib` whose extracted md has no phantom `###`.

**Note on scope:** apply the audit — delete every symbol marked `remove`. The steps below give the *full doc block for each symbol as if kept*; drop the blocks for removed symbols. The header/section skeleton and the `scalel` fix are unconditional.

- [ ] **Step 1: Write the library header block** (replace the current bare `declare`/`import` top)

```faust
//############################### seam.basic.lib ###############################
// SEAM Basics library. Its official prefix is `sba`.
//
// Reusable low-level building blocks that EXTEND the standard Faust `basics.lib`:
// only elements not already provided upstream are kept here.
//
// * [Sweep Functions](#sweep-functions)
// * [List Functions](#list-functions)
// * [Scaling](#scaling)
// * [Routing](#routing)
//
// #### References
//
// * <https://github.com/s-e-a-m/faust-libraries/blob/master/src/seam.basic.lib>
//##############################################################################
declare name "SEAM Basic - Library";
declare version "0.3";
declare author "Giuseppe Silvi";
declare license "CC3";
import("seam.lib");
sba = library("seam.basic.lib");
```

- [ ] **Step 2: Write the Sweep Functions section** (include only symbols kept by the audit)

```faust
//================================ Sweep Functions ============================
// Ramp/counter generators used across SEAM instruments.
//============================================================================

//-------------------------------`(sba.)sweep`--------------------------------
// Repeating sample counter. Differs from `ba.sweep`: it counts from **0** to
// `(p*t)-1` (via the `1'` seed) rather than starting at 1, and uses `p*t` as
// the period.
//
// #### Usage
// ```
// sweep(p,t) : _
// ```
// Where:
//
// * `p`: base period in samples
// * `t`: period multiplier (final period is `p*t`)
//
// #### Test
// ```
// sba = library("seam.basic.lib");
// sweep_test = sba.sweep(1,10);
// ```
//----------------------------------------------------------------------------
sweep(p,t) = p : %(int(*(t):max(1)))~+(1');

//-------------------------------`(sba.)lsweep`-------------------------------
// Linear sweep from 0 up to Nyquist (`ma.SR/2`), repeating every `sec` seconds.
//
// #### Usage
// ```
// lsweep(sec,t) : _
// ```
// Where:
//
// * `sec`: sweep duration in seconds
// * `t`: period multiplier
//
// #### Test
// ```
// sba = library("seam.basic.lib");
// lsweep_test = sba.lsweep(0.01,1);
// ```
//----------------------------------------------------------------------------
lsweep(sec,t) = (ma.SR/2) : %(int(*(t):max(1)))~+((1/sec)');

//-------------------------------`(sba.)zsweep`-------------------------------
// Zero-padded sweep: a `sweep` of length `p` preceded by `p` samples of zero,
// yielding a `2p+1` frame useful for zero-padded spectral analysis.
//
// #### Usage
// ```
// zsweep(p) : _
// ```
// Where:
//
// * `p`: sweep length in samples
//
// #### Test
// ```
// sba = library("seam.basic.lib");
// zsweep_test = sba.zsweep(10);
// ```
//----------------------------------------------------------------------------
zsweep(p) = (sweep((p*2+1),1)<(p)) : sweep(p);

//-------------------------------`(sba.)zerox`-------------------------------
// One-sample pulse on a **rising** zero crossing (negative -> non-negative).
//
// #### Usage
// ```
// _ : zerox : _
// ```
// Where the input is any signal; output is 1 for one sample at each upward
// zero crossing, 0 otherwise.
//
// #### Test
// ```
// os = library("oscillators.lib");
// sba = library("seam.basic.lib");
// zerox_test = os.osc(1000) : sba.zerox;
// ```
//----------------------------------------------------------------------------
zerox(x) = (x'<0) & (x>=0);
```

- [ ] **Step 3: Write the List Functions section**

```faust
//================================ List Functions ============================
//============================================================================

//-------------------------------`(sba.)revlist`-----------------------------
// Parallel bus of `n` constants counting DOWN: `n, n-1, ... , 1`.
//
// #### Usage
// ```
// revlist(n)
// ```
// Where:
//
// * `n`: number of parallel outputs (compile-time constant)
//
// #### Test
// ```
// sba = library("seam.basic.lib");
// revlist_test = sba.revlist(23);
// ```
//----------------------------------------------------------------------------
revlist(n) = par(i,n,(n)-i);
```

- [ ] **Step 4: Write the Scaling section WITH the `scalel` bug fix (`+c` restored)**

```faust
//================================ Scaling ===================================
//============================================================================

//-------------------------------`(sba.)scalel`------------------------------
// Linear (affine) rescale of `x` from input range `[a,b]` to output range
// `[c,d]`.
//
// #### Usage
// ```
// _ : scalel(a,b,c,d) : _
// ```
// Where:
//
// * `a`, `b`: input range (min, max)
// * `c`, `d`: output range (min, max)
//
// #### Test
// ```
// os = library("oscillators.lib");
// sba = library("seam.basic.lib");
// scalel_test = os.osc(1000) : sba.scalel(-1,1,0,1);
// ```
//----------------------------------------------------------------------------
scalel(a,b,c,d,x) = c + ((x-a)/(b-a))*(d-c);
```

- [ ] **Step 5: Write the Routing section**

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

- [ ] **Step 6: Handle the lazy constants per the audit decision**

If the audit kept `mille/cento/la/rosa/nyq`, add a `//=== Constants ===` section documenting each as a named signal (e.g. `` `(sba.)la` `` = 440 Hz sine). If the audit removed them, delete these definitions. Apply exactly what `doc/audit-basic.md` records — no other option.

- [ ] **Step 7: Compile-verify every kept `#### Test` snippet**

Run (one temp file per snippet, e.g. for `scalel`):
```bash
SP=/private/tmp/claude-501/-Users-giuseppe-Documents-github-seam-librerie-faust-libraries/238ec2cb-cf38-408e-a470-4e216ad32a7c/scratchpad
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
printf 'import("seam.lib"); process = os.osc(1000) : sba.scalel(-1,1,0,1);\n' > $SP/t.dsp
faust -I src $SP/t.dsp >/dev/null && echo OK
```
Expected: `OK` for each kept function's Test snippet.

- [ ] **Step 8: Re-generate md and assert no phantom `###`**

Run:
```bash
make -C doc build/seam.basic.md
# Every ### heading must be a backtick function signature now:
grep '^###' doc/build/seam.basic.md | grep -v '`(sba\.)' || echo "CLEAN: all ### are function signatures"
```
Expected: `CLEAN: all ### are function signatures` (no bare/phantom headings).

- [ ] **Step 9: Assert the header, sections, and Usage blocks are present**

Run:
```bash
grep -c '^# seam.basic.lib' doc/build/seam.basic.md   # 1  (H1 header)
grep -c '^## ' doc/build/seam.basic.md                # >=4 (sections)
grep -c '#### Usage' doc/build/seam.basic.md          # one per kept function
```
Expected: header = 1, sections >= 4, one `#### Usage` per surviving function.

- [ ] **Step 10: Checkpoint**

Summarise: `seam.basic.lib` refactored, `scalel` fixed, version bumped to 0.3, all Test snippets compile, clean md. Confirm the diff with the user before any commit (user handles git).

---

## Task 4: Verify IDE hover compatibility

**Files:** none created — verification only.

**Interfaces:** Consumes the refactored `src/seam.basic.lib`.

- [ ] **Step 1: Confirm the markers match the IDE's stricter `Faust2MD.ts` regex**

Run:
```bash
grep -nE '^//-{3,}`\(sba\.\)[a-zA-Z0-9_]+`-{3,}$' src/seam.basic.lib | wc -l
```
Expected: equals the number of documented functions — proves each function marker is closed on both sides (the IDE regex `REGEX_BEG_COMMENT` requires trailing dashes, unlike the AWK).

- [ ] **Step 2: Manual IDE check (record result, do not block on it)**

In `faustide-od` (once built/served), drag `seam.basic.lib` (+ the `seam.*.lib` files it imports, or a self-contained copy) into Project Files, type `sba.scalel`, and confirm the hover tooltip shows the Usage/Where text. Note the result in the Task 5 checkpoint. (Browser step — cannot be automated here.)

- [ ] **Step 3: Checkpoint** — report whether the marker regex count matches and the manual hover result if performed.

---

## Task 5: Publish `basic` on the SEAM Jekyll site

**Files (in `blog/s-e-a-m.github.io`):**
- Create: `_libraries/basic.md`
- Modify: `_config.yml`
- Modify: `_data/navigation.yml`

**Interfaces:** Consumes `doc/build/seam.basic.md`.

> **Gate:** this task edits existing files in the *site* repo. Confirm with the user before editing `_config.yml` / `_data/navigation.yml`.

- [ ] **Step 1: Declare the `libraries` collection in `_config.yml`**

Add:
```yaml
collections:
  libraries:
    output: true
    permalink: /libraries/:path/

defaults:
  # ... existing defaults stay ...
  - scope:
      path: ""
      type: libraries
    values:
      layout: single
      author_profile: false
      sidebar:
        nav: "libraries"
```

- [ ] **Step 2: Add the Library Reference sidebar to `_data/navigation.yml`**

Append:
```yaml
libraries:
  - title: "Library Reference"
    children:
      - title: "basic (sba)"
        url: /libraries/basic/
```

- [ ] **Step 3: Create `_libraries/basic.md` from the generated body + front matter**

Run (adapter = prepend Jekyll front matter to the generated md):
```bash
SITE=/Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
mkdir -p $SITE/_libraries
{ printf -- '---\ntitle: "basic"\npermalink: /libraries/basic/\ntoc: true\n---\n\n';
  cat doc/build/seam.basic.md; } > $SITE/_libraries/basic.md
```
Expected: `_libraries/basic.md` begins with the front matter then the generated `# seam.basic.lib` body.

- [ ] **Step 4: Build the site and verify the page renders**

Run:
```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
bundle exec jekyll build 2>&1 | tail -5
test -f _site/libraries/basic/index.html && echo "RENDERED"
```
Expected: build succeeds; `RENDERED` printed. (If `bundle` is unavailable, note it and fall back to `jekyll build`; if neither, record as a manual step for the user.)

- [ ] **Step 5: Verify the sidebar link and content landed**

Run: `grep -c 'scalel' _site/libraries/basic/index.html`
Expected: >= 1 (the documented function reached the rendered HTML).

- [ ] **Step 6: Checkpoint**

Summarise: collection + sidebar + `basic.md` published locally; screenshot/serve instructions for the user (`bundle exec jekyll serve`). Report the IDE hover result from Task 4. Do NOT commit either repo — user handles git and the cross-repo transfer decision.

---

## Definition of done (pilot)

- `seam.basic.lib` holds only audit-approved symbols; `scalel` fixed; version bumped; citations preserved.
- Every public function has header/section/`Usage`/`Where`/`Test`; extractor produces clean `basic.md` (no phantom `###`).
- `basic.md` renders on the SEAM Jekyll site under Library Reference.
- Function markers pass the IDE `Faust2MD.ts` regex (Step 4.1); manual hover confirmed or noted.
- Every kept Test snippet compiles under stable `faust`.
- `doc/audit-basic.md` records a decision + rationale per symbol.
