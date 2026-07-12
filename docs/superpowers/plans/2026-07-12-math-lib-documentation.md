# `seam.math.lib` Documentation + Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Document `seam.math.lib` with the faust2md convention, apply the approved audit (remove `PIc`/`PIq`, rename `w`→`prewarp`, fix `permutation` and `xyz2aed`), and publish it at `/faustlibraries/math/`.

**Architecture:** Rewrite one source file (`src/seam.math.lib`) with full doc blocks + audit changes; rename its 2 call sites in `src/seam.filters.lib`; record the audit in `doc/audit-math.md`; regenerate the markdown with the existing `doc/` pipeline and publish it into the Jekyll site with a nav entry. The `/faustlibraries/` permalink and TOC CSS are already global from the `basic` work.

**Tech Stack:** Faust 2.85.5 (Homebrew `/usr/local/bin/faust`), GNU `gawk`, Jekyll + `github-pages`, Minimal Mistakes remote theme.

## Global Constraints

- Faust compiler: stable Homebrew `faust`. Compile REAL files (no stdin). Resolve seam imports with `-I src` from the repo root.
- Repo A: `/Users/giuseppe/Documents/github/seam/librerie/faust-libraries` (branch `master`, user-approved direct commits).
- Repo B: `/Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io` (branch `master`).
- Scratch dir `$S` for temp `.dsp`: `/private/tmp/claude-501/-Users-giuseppe-Documents-github-seam-librerie-faust-libraries/ecf3de67-9a57-42d9-85de-ed0da390f8a9/scratchpad` (NOT set as a shell var — use the literal path).
- `doc/build/` is untracked — never `git add` it.
- Headings must stay monotonic; the top `References` is an `## h2` (TOC-safety lesson from the `basic` round-2 fix).
- Every commit message ends with: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`

---

## Task 1: Rewrite `src/seam.math.lib` (documented + audited) + audit record

**Files:**
- Overwrite: `src/seam.math.lib`
- Create: `doc/audit-math.md`
- Test: temp `.dsp` compiled with `faust -I src`

**Interfaces:**
- Produces (public `sma.` symbols): `twoPI`, `omega(fc)`, `prewarp(fc)`, `cosq(x)`, `sinq(x)`, `d2r(d)`, `r2d(r)`, `aed2xyz(a,e,d)`, `xyz2aed(x,y,z)`, `phi(x)`, `rphi(x)`, `srphi(i,x)`, `factorial(n)`, `permutation(n,k)`, `esos`, `isos`, `emt2samp(mt)`, `imt2samp(mt)`, `imdelay(mt)`.
- Removes: `PIc`, `PIq`. Renames `w`→`prewarp` (call sites fixed in Task 2).

- [ ] **Step 1: Write the failing test**

Create `$S/math_test.dsp` (literal `$S` path from Global Constraints):
```faust
import("seam.lib");
process =
  sma.twoPI, sma.omega(1000), sma.prewarp(1000),
  sma.cosq(ma.PI), sma.sinq(1), sma.d2r(90), sma.r2d(ma.PI),
  sma.aed2xyz(0,0,1), (1,1,1 : sma.xyz2aed),
  sma.phi(1), sma.rphi(1), par(i,4,sma.srphi(i,ma.SR/2)),
  sma.factorial(5), sma.permutation(5,2),
  sma.esos, sma.isos, sma.emt2samp(3.4), sma.imt2samp(3.4),
  (no.noise : sma.imdelay(3.4));
```

- [ ] **Step 2: Run test — verify it FAILS (baseline: `prewarp` not defined yet)**

Run from Repo A root:
```bash
faust -I src "$S/math_test.dsp" -o /dev/null 2>&1 | head; echo "EXIT=${PIPESTATUS[0]}"
```
Expected: non-zero EXIT — `sma.prewarp` (and the fixed `permutation` arg order) are not in the current source.

- [ ] **Step 3: Overwrite `src/seam.math.lib` with EXACTLY this content**

````faust
//################################ seam.math.lib ###############################
// SEAM Math library. Its official prefix is `sma`.
//
// General-purpose mathematical helpers used across SEAM instruments: angular
// and frequency quantities, squared trigonometry, angle and coordinate
// conversions, the golden ratio, combinatorics, and acoustic distance/delay
// utilities. Only elements not already provided by the standard Faust
// `maths.lib` are kept here.
//
// * [References](#references)
// * [Constants and Angular Frequency](#constants-and-angular-frequency)
// * [Trigonometry](#trigonometry)
// * [Angle Conversion](#angle-conversion)
// * [Coordinates](#coordinates)
// * [Golden Ratio](#golden-ratio)
// * [Combinatorics](#combinatorics)
// * [Acoustics](#acoustics)
//
// ## References
//
// * <https://github.com/s-e-a-m/faust-libraries/blob/master/src/seam.math.lib>
//##############################################################################
declare name "SEAM Math - Library";
declare version "0.2";
declare author "Giuseppe Silvi";
declare license "CC3";
import("seam.lib");
sma = library("seam.math.lib");

//======================= Constants and Angular Frequency ====================
// Angular constants and helpers that turn a frequency in Hz into the angular
// quantities used by oscillators and filter design.
//============================================================================

//-------------------------------`(sma.)twoPI`-------------------------------
// The constant `2*pi` (a full turn in radians). Convenience for angular-rate
// math, where a cycle spans `2*pi` radians.
//
// #### Usage
// ```
// sma.twoPI : _
// ```
//
// #### Test
// ```
// sma = library("seam.math.lib");
// twoPI_test = sma.twoPI;
// ```
//----------------------------------------------------------------------------
twoPI = 2*ma.PI;

//-------------------------------`(sma.)omega`-------------------------------
// Normalised angular frequency of `fc` in radians per sample:
// `omega = fc*2*pi/SR`. This is the per-sample phase increment of a sinusoid
// at `fc` Hz.
//
// #### Usage
// ```
// omega(fc) : _
// ```
// Where:
//
// * `fc`: frequency in Hz
//
// #### Test
// ```
// sma = library("seam.math.lib");
// omega_test = sma.omega(1000);
// ```
//----------------------------------------------------------------------------
omega(fc) = fc*twoPI/ma.SR;

//------------------------------`(sma.)prewarp`------------------------------
// Bilinear-transform frequency pre-warping: `tan(pi*fc/SR/2)`. Maps a target
// cutoff `fc` (Hz) to the warped value the bilinear transform expects, so an
// analog prototype lands on the intended digital frequency. Used by the
// `seam.filters` designs.
//
// #### Usage
// ```
// prewarp(fc) : _
// ```
// Where:
//
// * `fc`: cutoff frequency in Hz
//
// #### Test
// ```
// sma = library("seam.math.lib");
// prewarp_test = sma.prewarp(1000);
// ```
//----------------------------------------------------------------------------
prewarp(fc) = tan(ma.PI*fc/ma.SR/2);

//================================ Trigonometry ==============================
// Squared trigonometric helpers (e.g. for equal-power laws and identities).
//============================================================================

//--------------------------------`(sma.)cosq`-------------------------------
// Squared cosine: `cos(x)^2`.
//
// #### Usage
// ```
// cosq(x) : _
// ```
// Where:
//
// * `x`: angle in radians
//
// #### Test
// ```
// sma = library("seam.math.lib");
// cosq_test = sma.cosq(ma.PI);
// ```
//----------------------------------------------------------------------------
cosq(x) = cos(x)*cos(x);

//--------------------------------`(sma.)sinq`-------------------------------
// Squared sine: `sin(x)^2`.
//
// #### Usage
// ```
// sinq(x) : _
// ```
// Where:
//
// * `x`: angle in radians
//
// #### Test
// ```
// sma = library("seam.math.lib");
// sinq_test = sma.sinq(3/2*ma.PI);
// ```
//----------------------------------------------------------------------------
sinq(x) = sin(x)*sin(x);

//============================== Angle Conversion ============================
//============================================================================

//--------------------------------`(sma.)d2r`--------------------------------
// Degrees to radians: `d*pi/180`.
//
// #### Usage
// ```
// d2r(d) : _
// ```
// Where:
//
// * `d`: angle in degrees
//
// #### Test
// ```
// sma = library("seam.math.lib");
// d2r_test = sma.d2r(90);
// ```
//----------------------------------------------------------------------------
d2r(d) = d*(ma.PI/180);

//--------------------------------`(sma.)r2d`--------------------------------
// Radians to degrees: `r*180/pi`.
//
// #### Usage
// ```
// r2d(r) : _
// ```
// Where:
//
// * `r`: angle in radians
//
// #### Test
// ```
// sma = library("seam.math.lib");
// r2d_test = sma.r2d(ma.PI);
// ```
//----------------------------------------------------------------------------
r2d(r) = r/ma.PI*180;

//================================ Coordinates ==============================
// Conversions between spherical (azimuth, elevation, distance) and Cartesian
// (x, y, z) coordinates. Angles are in radians; elevation is measured from
// the horizontal plane (`e=0` on the plane, `e=pi/2` straight up). `aed2xyz`
// and `xyz2aed` are exact inverses.
//============================================================================

//------------------------------`(sma.)aed2xyz`------------------------------
// Azimuth / elevation / distance to Cartesian `x, y, z`:
// `x = d*cos(a)*cos(e)`, `y = d*sin(a)*cos(e)`, `z = d*sin(e)`.
//
// #### Usage
// ```
// aed2xyz(a,e,d) : _,_,_
// ```
// Where:
//
// * `a`: azimuth in radians
// * `e`: elevation in radians (from the horizontal plane)
// * `d`: distance (radius)
//
// #### Test
// ```
// sma = library("seam.math.lib");
// aed2xyz_test = sma.aed2xyz(0,0,1);
// ```
//----------------------------------------------------------------------------
aed2xyz(a,e,d) = cx(a,e,d), cy(a,e,d), cz(a,e,d)
with{
  cx(a,e,d) = d*(cos(a)*cos(e));
  cy(a,e,d) = d*(sin(a)*cos(e));
  cz(a,e,d) = d*(sin(e));
};

//------------------------------`(sma.)xyz2aed`------------------------------
// Cartesian `x, y, z` to azimuth / elevation / distance:
// `a = atan2(y,x)`, `e = atan2(z, sqrt(x^2+y^2))`, `d = sqrt(x^2+y^2+z^2)`.
// The exact inverse of `aed2xyz` (elevation measured from the horizontal
// plane).
//
// #### Usage
// ```
// xyz2aed(x,y,z) : _,_,_
// ```
// Where:
//
// * `x`, `y`, `z`: Cartesian coordinates
//
// #### Test
// ```
// sma = library("seam.math.lib");
// xyz2aed_test = sma.xyz2aed(1,1,1) : sma.r2d, sma.r2d, _;
// ```
//----------------------------------------------------------------------------
xyz2aed(x,y,z) = a(x,y),e(x,y,z),d(x,y,z)
with{
  a(x,y)   = atan2(y,x);
  e(x,y,z) = atan2(z,sqrt(x^2+y^2));
  d(x,y,z) = sqrt(x^2+y^2+z^2);
};

//================================ Golden Ratio =============================
//============================================================================

//--------------------------------`(sma.)phi`--------------------------------
// Scales `x` by the golden ratio `phi = (1+sqrt(5))/2 ~= 1.618`.
//
// #### Usage
// ```
// phi(x) : _
// ```
// Where:
//
// * `x`: value to scale
//
// #### Test
// ```
// sma = library("seam.math.lib");
// phi_test = sma.phi(1);
// ```
//----------------------------------------------------------------------------
phi(x) = x*(1+(sqrt(5)))/2;

//--------------------------------`(sma.)rphi`-------------------------------
// Scales `x` by the reciprocal golden ratio `1/phi = (sqrt(5)-1)/2 ~= 0.618`.
//
// #### Usage
// ```
// rphi(x) : _
// ```
// Where:
//
// * `x`: value to scale
//
// #### Test
// ```
// sma = library("seam.math.lib");
// rphi_test = sma.rphi(1);
// ```
//----------------------------------------------------------------------------
rphi(x) = x*(sqrt(5)-1)/2;

//--------------------------------`(sma.)srphi`------------------------------
// Reciprocal-golden progression: applies `rphi` to `x` a total of `i` times,
// i.e. the `i`-th term of the geometric sequence with ratio `1/phi`.
//
// #### Usage
// ```
// srphi(i,x) : _
// ```
// Where:
//
// * `i`: number of iterations (compile-time integer)
// * `x`: starting value
//
// #### Test
// ```
// sma = library("seam.math.lib");
// srphi_test = par(i,16,sma.srphi(i,ma.SR/2));
// ```
//----------------------------------------------------------------------------
srphi(0,x) = x;
srphi(i,x) = rphi(x) : srphi(i-1);

//================================ Combinatorics ============================
//============================================================================

//-----------------------------`(sma.)factorial`----------------------------
// Factorial `n! = n*(n-1)*...*1` (with `0! = 1`), by compile-time recursion.
//
// #### Usage
// ```
// factorial(n)
// ```
// Where:
//
// * `n`: non-negative integer (compile-time constant)
//
// #### Test
// ```
// sma = library("seam.math.lib");
// factorial_test = sma.factorial(5);
// ```
//----------------------------------------------------------------------------
factorial(0) = 1;
factorial(i) = i * factorial(i-1);

//----------------------------`(sma.)permutation`---------------------------
// Number of ordered arrangements of `k` items taken from `n`:
// `P(n,k) = n!/(n-k)!`. Requires `n >= k >= 0`.
//
// #### Usage
// ```
// permutation(n,k)
// ```
// Where:
//
// * `n`: size of the set (compile-time integer)
// * `k`: number of items chosen (compile-time integer, `<= n`)
//
// #### Test
// ```
// sma = library("seam.math.lib");
// permutation_test = sma.permutation(5,2);
// ```
//----------------------------------------------------------------------------
permutation(n,k) = factorial(n)/factorial(n-k);

//================================= Acoustics ===============================
// Speed of sound and distance-to-delay helpers for physical spatialisation.
// SEAM distinguishes an `exterior` (open-air) and an `interior` (room) speed
// of sound.
//============================================================================

//--------------------------------`(sma.)esos`-------------------------------
// Exterior speed of sound: `344` m/s (open air, ~20 degrees C).
//
// #### Usage
// ```
// sma.esos : _
// ```
//
// #### Test
// ```
// sma = library("seam.math.lib");
// esos_test = sma.esos;
// ```
//----------------------------------------------------------------------------
esos = 344; // exterior

//--------------------------------`(sma.)isos`-------------------------------
// Interior speed of sound: `331.4` m/s (~0 degrees C reference).
//
// #### Usage
// ```
// sma.isos : _
// ```
//
// #### Test
// ```
// sma = library("seam.math.lib");
// isos_test = sma.isos;
// ```
//----------------------------------------------------------------------------
isos = 331.4; // interior

//------------------------------`(sma.)emt2samp`-----------------------------
// Metres to whole samples using the exterior speed of sound:
// `int(mt*SR/esos)`.
//
// #### Usage
// ```
// emt2samp(mt)
// ```
// Where:
//
// * `mt`: distance in metres
//
// #### Test
// ```
// sma = library("seam.math.lib");
// emt2samp_test = sma.emt2samp(3.4);
// ```
//----------------------------------------------------------------------------
emt2samp(mt) = int(mt*ma.SR/esos);

//------------------------------`(sma.)imt2samp`-----------------------------
// Metres to whole samples using the interior speed of sound:
// `int(mt*SR/isos)`.
//
// #### Usage
// ```
// imt2samp(mt)
// ```
// Where:
//
// * `mt`: distance in metres
//
// #### Test
// ```
// sma = library("seam.math.lib");
// imt2samp_test = sma.imt2samp(3.4);
// ```
//----------------------------------------------------------------------------
imt2samp(mt) = int(mt*ma.SR/isos);

//------------------------------`(sma.)imdelay`------------------------------
// Pure integer-sample delay for a distance `mt` in metres, using the interior
// speed of sound. The one stateful function in this library. Delay line is
// `1<<15` samples (~0.68 s at 48 kHz, ~226 m). Used by the SEAM-LTM DDELAY
// plugin (per channel).
//
// #### Usage
// ```
// _ : imdelay(mt) : _
// ```
// Where:
//
// * `mt`: distance in metres
//
// #### Test
// ```
// no = library("noises.lib");
// sma = library("seam.math.lib");
// imdelay_test = no.noise : sma.imdelay(3.4);
// ```
//----------------------------------------------------------------------------
imdelay(mt) = de.delay(1 << 15, imt2samp(mt));
````

- [ ] **Step 4: Run test — verify it PASSES**

```bash
faust -I src "$S/math_test.dsp" -o /dev/null 2>&1 | head; echo "EXIT=${PIPESTATUS[0]}"
```
Expected: `EXIT=0`.

- [ ] **Step 5: Verify the removed symbols no longer resolve**

```bash
printf 'import("seam.lib");\nprocess = sma.PIc, sma.PIq, sma.w(1000);\n' > "$S/removed.dsp"
faust -I src "$S/removed.dsp" -o /dev/null 2>&1 | head -2; echo "EXIT=${PIPESTATUS[0]}"
```
Expected: non-zero EXIT with "undefined symbol : PIc" (or PIq / w).

- [ ] **Step 6: Create `doc/audit-math.md`**

Write this file:
```markdown
# seam.math.lib audit (2026-07-12)

Audited vs the official `maths.lib`. 21 -> 19 public symbols; version 0.1 -> 0.2.
Most of the library is genuinely additive (no deg2rad/rad2deg, factorial, golden
ratio, bilinear prewarp, spherical conversions, or speed-of-sound upstream).

| symbol | verdict | reason |
|--------|---------|--------|
| `PIc` | REMOVED | `atan(1)*4` == `ma.PI` (redundant); 0 uses |
| `PIq` | REMOVED | 81-decimal literal truncated to double; redundant with `ma.PI`; 0 uses |
| `w` -> `prewarp` | RENAMED | cryptic name; 2 call sites in `seam.filters.lib` updated |
| `permutation` | FIXED | `k!/n!` -> `n!/(n-k)!` (standard nPr); arg order now `(n,k)`; 0 uses |
| `xyz2aed` | FIXED | elevation `atan2(sqrt(x^2+y^2),z)` (zenith) -> `atan2(z,sqrt(x^2+y^2))`; now exact inverse of `aed2xyz`; 0 uses |
| `twoPI`, `omega`, `prewarp` | KEPT | angular/frequency helpers, not upstream |
| `cosq`, `sinq` | KEPT | squared trig, not upstream |
| `d2r`, `r2d` | KEPT | degrees<->radians, not upstream |
| `aed2xyz`, `xyz2aed` | KEPT | spherical<->Cartesian, not upstream (not duplicated in ambisonics) |
| `phi`, `rphi`, `srphi` | KEPT | golden ratio, not upstream (`srphi` used by example 97) |
| `factorial` | KEPT | not upstream |
| `esos`, `isos`, `emt2samp`, `imt2samp` | KEPT | speed of sound / distance->samples (SEAM domain) |
| `imdelay` | KEPT | distance delay (only stateful fn; used by seam-ltm ddelay) |
```

- [ ] **Step 7: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
git add src/seam.math.lib doc/audit-math.md
git commit -m "docs(math): document seam.math.lib + audit (v0.2)

Remove PIc/PIq, rename w->prewarp, fix permutation to nPr and xyz2aed inverse.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Rename `sma.w` → `sma.prewarp` in `seam.filters.lib`

**Files:**
- Modify: `src/seam.filters.lib` (2 occurrences of `sma.w(fc)`, at lines 60 and 72)
- Test: temp `.dsp` compiled with `faust -I src`

**Interfaces:**
- Consumes: `sma.prewarp` from Task 1.

- [ ] **Step 1: Write the failing test**

Create `$S/filters_test.dsp`:
```faust
import("seam.lib");
process = sfi.ap2coeff(24000,1);
```
(`ap2coeff` is one of the two `with{}` blocks that call `sma.w` — it must still compile after Task 1 removed `w`, which it will only once the rename is done.)

- [ ] **Step 2: Run test — verify it FAILS**

```bash
faust -I src "$S/filters_test.dsp" -o /dev/null 2>&1 | head -2; echo "EXIT=${PIPESTATUS[0]}"
```
Expected: non-zero EXIT — `sma.w` is undefined after Task 1 (`ERROR : undefined symbol : w`).

- [ ] **Step 3: Rename both call sites**

In `src/seam.filters.lib`, replace both occurrences of:
```faust
sma.w(fc)
```
with:
```faust
sma.prewarp(fc)
```
They appear inside `ap2coeff` (line 60: `  g(fc) = sma.w(fc);`) and `ap1coeff` (line 72: ` g(fc) = sma.w(fc);`). Change only `sma.w(fc)`→`sma.prewarp(fc)`; leave surrounding indentation and code untouched.

- [ ] **Step 4: Run test — verify it PASSES**

```bash
faust -I src "$S/filters_test.dsp" -o /dev/null 2>&1 | head; echo "EXIT=${PIPESTATUS[0]}"
```
Expected: `EXIT=0`.

- [ ] **Step 5: Confirm no stray `sma.w(` remains**

```bash
grep -n "sma\.w(" src/seam.filters.lib; echo "grep-exit=$?"
```
Expected: no output (grep-exit=1).

- [ ] **Step 6: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
git add src/seam.filters.lib
git commit -m "refactor(filters): use sma.prewarp (renamed from sma.w)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Regenerate and publish the `math` doc page (Repo A → Repo B)

**Files:**
- Regenerate (Repo A, untracked): `doc/build/seam.math.md`
- Create (Repo B): `_libraries/math.md`
- Modify (Repo B): `_data/navigation.yml`

**Interfaces:**
- Consumes: `src/seam.math.lib` from Task 1.

- [ ] **Step 1: Regenerate the markdown**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
make -C doc md
```
Then sanity-check `doc/build/seam.math.md`:
```bash
grep -cE "^## " doc/build/seam.math.md                 # expect 8 (7 sections + References)
grep -cE "^### \`\(sma\.\)" doc/build/seam.math.md      # expect 19 function blocks
grep -cE "PIc|PIq|\(sma\.\)w\b" doc/build/seam.math.md  # expect 0
head -1 doc/build/seam.math.md                          # expect "#  seam.math.lib"
```
Expected: 8 `##` headings, 19 `###` function blocks, 0 removed symbols. Do NOT `git add doc/build/`.

- [ ] **Step 2: Create `_libraries/math.md` (front matter + regenerated body)**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
{ printf -- '---\ntitle: "Faust Libraries · math"\npermalink: /faustlibraries/math/\ntoc: true\n---\n\n'; \
  cat /Users/giuseppe/Documents/github/seam/librerie/faust-libraries/doc/build/seam.math.md; } > _libraries/math.md
head -5 _libraries/math.md
```
Expected: the 5 front-matter lines shown, then the body follows.

- [ ] **Step 3: Add the sidebar nav entry**

In `_data/navigation.yml`, under `libraries:` → `- title: "Library Reference"` → `children:`, add a second child after the `basic (sba)` entry so the block reads:
```yaml
libraries:
  - title: "Library Reference"
    children:
      - title: "basic (sba)"
        url: /faustlibraries/basic/
      - title: "math (sma)"
        url: /faustlibraries/math/
```

- [ ] **Step 4: Build and verify**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
bundle exec jekyll build 2>&1 | tail -3
ls _site/faustlibraries/math/index.html && echo "PATH OK"
grep -cE "sma\.\)prewarp|sma\.\)permutation" _site/faustlibraries/math/index.html   # expect >= 2
grep -c "PIc" _site/faustlibraries/math/index.html                                   # expect 0
```
Then inspect `_site/faustlibraries/math/index.html`: confirm the right-hand `.toc__menu` is well-formed (h1 title → 8 h2 sections incl. References → h3 functions; no Usage/Test in the sidebar), and that the top-of-page bullet-list anchors (`#constants-and-angular-frequency`, `#trigonometry`, `#angle-conversion`, `#coordinates`, `#golden-ratio`, `#combinatorics`, `#acoustics`, `#references`) each resolve to a heading `id` on the page. (jekyll deprecation warnings about faraday-retry/ostruct are harmless.)

- [ ] **Step 5: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
git add _libraries/math.md _data/navigation.yml
git commit -m "docs(math): publish seam.math.lib reference at /faustlibraries/math/

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Final verification (all tasks)

- [ ] Repo A: `git log --oneline -3` shows the math + filters commits; `git status` clean.
- [ ] Repo B: `git log --oneline -2` shows the publish commit; `git status` clean.
- [ ] `faust -I src` compiles the Task 1 smoke DSP (exit 0); `sma.PIc`/`sma.PIq`/`sma.w` fail; `sfi.ap2coeff` compiles.
- [ ] `_site/faustlibraries/math/index.html` exists; sidebar shows `math (sma)`; TOC well-formed with clear hierarchy; body shows 19 functions and no `PIc`/`PIq`/`w`.
- [ ] Push both repos (user-approved).
