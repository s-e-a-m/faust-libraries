# Inline-SVG Block-Diagram Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a replicable `make svg` step that compiles each `#### Diagram`-marked function's `#### Test` into a self-contained inline SVG in its doc page, and apply it to `basic`'s Sweep + Scaling functions.

**Architecture:** A new Python post-processor (`doc/scripts/svg-embed.py`) runs after the faust2md `make md` step: it finds `#### Diagram` markers in the generated markdown, compiles the function's Test to `faust -svg`, self-contains the top `process.svg`, and injects it inline. Opt-in per function via a `// #### Diagram` comment. A `.faust-diagram` CSS rule makes the diagrams responsive. The whole chain was spike-verified before this plan.

**Tech Stack:** Faust 2.85.5 (`faust -svg`), Python 3 (system), GNU `gawk`, GNU make, Jekyll + Minimal Mistakes, SCSS.

## Global Constraints

- Faust: stable Homebrew `faust`. Compile real files. Seam include path `-I src` (or `-I ../src` from `doc/`).
- Repo A: `/Users/giuseppe/Documents/github/seam/librerie/faust-libraries` (branch `master`, user-approved direct commits).
- Repo B: `/Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io` (branch `master`).
- `doc/build/` is untracked — never `git add` it; SVGs are inlined, not committed as files.
- Diagrams cover only these 7 `basic` functions this round: `sweep`, `lsweep`, `zsweep`, `zerox`, `scalel`, `scalee`, `scalec`.
- Every commit message ends with: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`

---

## Task 1: SVG pipeline + `#### Diagram` markers on basic (Repo A)

**Files:**
- Create: `doc/scripts/svg-embed.py`
- Modify: `doc/Makefile` (add `svg` + `doc` targets)
- Modify: `src/seam.basic.lib` (7 `// #### Diagram` markers)

**Interfaces:**
- Produces: `make -C doc svg` post-processes `build/*.md`, injecting `<div class="faust-diagram">…</div>` after each `#### Diagram` heading.

- [ ] **Step 1: Create `doc/scripts/svg-embed.py` with EXACTLY this content**

```python
#!/usr/bin/env python3
"""svg-embed.py — inject inline Faust block diagrams into generated library docs.

For every `#### Diagram` heading in a generated markdown file, take the nearest
preceding `#### Test` code block, turn its `NAME_test = EXPR;` line into
`process = EXPR;`, compile it with `faust -svg`, self-contain the top-level
`process.svg` (drop the XML prolog and the non-deterministic drill-down links),
and inline it right after the `#### Diagram` heading, wrapped in
`<div class="faust-diagram">`.

Idempotent: an already-injected diagram (an immediately-following
`<div class="faust-diagram">` block) is replaced, not duplicated.

Usage: svg-embed.py <file.md> [-I <faust-include-dir>]
"""
import os, re, sys, subprocess, tempfile

def selfcontain(svg):
    svg = re.sub(r'<\?xml[^>]*\?>\s*', '', svg)          # drop XML prolog for inline HTML
    svg = re.sub(r'<a xlink:href="[^"]*">', '', svg)     # drop non-deterministic drill-down links
    return svg.replace('</a>', '')

def test_to_process(code_lines):
    out = []
    for ln in code_lines:
        m = re.match(r'\s*[A-Za-z_][A-Za-z0-9_]*_test\s*=\s*(.*)$', ln)
        out.append('process = ' + m.group(1) if m else ln)
    return '\n'.join(out) + '\n'

def compile_svg(code_lines, incdir):
    with tempfile.TemporaryDirectory() as d:
        with open(os.path.join(d, 'diagram.dsp'), 'w') as f:
            f.write(test_to_process(code_lines))
        r = subprocess.run(['faust', '-svg', '-I', incdir, 'diagram.dsp', '-o', '/dev/null'],
                           cwd=d, capture_output=True, text=True)
        if r.returncode != 0:
            raise RuntimeError(r.stderr.strip())
        with open(os.path.join(d, 'diagram-svg', 'process.svg')) as f:
            return selfcontain(f.read()).strip()

def embed(path, incdir):
    lines = open(path).read().split('\n')
    out, i, last_test, injected = [], 0, None, 0
    while i < len(lines):
        line = lines[i]
        if line.strip() == '#### Test':
            out.append(line); i += 1
            while i < len(lines) and lines[i].strip() != '```':
                out.append(lines[i]); i += 1
            if i < len(lines):
                out.append(lines[i]); i += 1
            code = []
            while i < len(lines) and lines[i].strip() != '```':
                code.append(lines[i]); out.append(lines[i]); i += 1
            last_test = code
            continue
        if line.strip() == '#### Diagram':
            out.append(line); i += 1
            if i < len(lines) and lines[i].strip() == '' and i + 1 < len(lines) \
               and lines[i + 1].startswith('<div class="faust-diagram">'):
                i += 1
                while i < len(lines) and not lines[i].startswith('</div>'):
                    i += 1
                i += 1
            if last_test is None:
                raise RuntimeError(f'{path}: "#### Diagram" with no preceding "#### Test"')
            svg = compile_svg(last_test, incdir)
            out += ['', f'<div class="faust-diagram">\n{svg}\n</div>']
            injected += 1
            continue
        out.append(line); i += 1
    open(path, 'w').write('\n'.join(out))
    return injected

if __name__ == '__main__':
    args = sys.argv[1:]
    incdir = '../src'
    if '-I' in args:
        k = args.index('-I'); incdir = args[k + 1]; del args[k:k + 2]
    incdir = os.path.abspath(incdir)   # resolve before faust runs with cwd=tempdir
    n = embed(args[0], incdir)
    print(f'  embedded {n} diagram(s) into {args[0]}')
```

- [ ] **Step 2: Add the `svg` and `doc` targets to `doc/Makefile`**

Change the `.PHONY` line from:
```make
.PHONY: md index list clean
```
to:
```make
.PHONY: md svg doc index list clean
```
And add these targets (e.g. right after the `md: $(MD)` target):
```make
svg: md
	@for f in $(BUILD)/*.md; do python3 scripts/svg-embed.py $$f -I $(SEAMLIB); done

doc: md svg
```
(`$(SEAMLIB)` is already defined as `../src`; `$(BUILD)` as `build`.)

- [ ] **Step 3: Add `// #### Diagram` markers to the 7 basic functions**

In `src/seam.basic.lib`, for EACH of these functions — `sweep`, `lsweep`, `zsweep`, `zerox`, `scalel`, `scalee`, `scalec` — find its `#### Test` block and insert, immediately AFTER that block's closing `// ` + triple-backtick fence line and BEFORE the `//----…----` separator line that precedes the definition, these two lines:
```faust
//
// #### Diagram
```
Concretely, each function's doc tail changes from:
```faust
// #### Test
// ```
// …test code…
// ```
//----------------------------------------------------------------------------
```
to:
```faust
// #### Test
// ```
// …test code…
// ```
//
// #### Diagram
//----------------------------------------------------------------------------
```
Do this for exactly those 7 functions (the Sweep section's `sweep`, `lsweep`, `zsweep`, `zerox`; the Scaling section's `scalel`, `scalee`, `scalec`). Do NOT add markers to `revlist`, `lrev`, `lrot`.

- [ ] **Step 4: Run the pipeline and verify 7 diagrams are injected**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
make -C doc md && make -C doc svg
grep -c '<div class="faust-diagram">' doc/build/seam.basic.md   # expect 7
grep -cE 'xlink:href|<\?xml' doc/build/seam.basic.md            # expect 0
grep -c '#### Diagram' doc/build/seam.basic.md                  # expect 7
```
Expected: 7 figures, 0 leftover drill-down/prolog, 7 markers.

- [ ] **Step 5: Verify idempotency (re-run svg is a no-op)**

```bash
cp doc/build/seam.basic.md /tmp/basic.once.md
make -C doc svg
diff -q /tmp/basic.once.md doc/build/seam.basic.md && echo "IDEMPOTENT"
```
Expected: `IDEMPOTENT` (byte-identical).

- [ ] **Step 6: Verify each marked function's Test compiles as a process**

```bash
printf 'sba = library("seam.basic.lib");\nprocess = sba.sweep(1,10);\n' > /tmp/d.dsp
faust -I src /tmp/d.dsp -o /dev/null 2>&1; echo "EXIT=$?"
```
Expected: `EXIT=0` (representative check; `make svg` in Step 4 already compiled all 7 — a non-zero would have aborted it).

- [ ] **Step 7: Commit (do NOT add `doc/build/`)**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
git add doc/scripts/svg-embed.py doc/Makefile src/seam.basic.lib
git commit -m "feat(doc): make svg — inline Faust block diagrams from #### Diagram markers

Adds doc/scripts/svg-embed.py + make svg/doc targets; marks basic Sweep+Scaling.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: `.faust-diagram` responsive CSS (Repo B)

**Files:**
- Modify: `assets/css/main.scss` (append rules)

**Interfaces:**
- Consumes: nothing (independent).

- [ ] **Step 1: Append the diagram styling to `assets/css/main.scss`**

At the END of `assets/css/main.scss` (after the existing TOC rules), add:
```scss
/* ===== Faust block diagrams embedded in library docs ===== */
.faust-diagram {
  margin: 1.5em 0;
  overflow-x: auto;   /* wide diagrams scroll in their own box; page body never does */
  text-align: center;
}

.faust-diagram svg {
  max-width: 100%;
  height: auto;
}
```

- [ ] **Step 2: Build to confirm the SCSS still compiles**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
bundle exec jekyll build 2>&1 | tail -3
grep -c 'faust-diagram' _site/assets/css/main.css   # expect >= 1
```
Expected: build clean; `faust-diagram` rule present in the compiled CSS.

- [ ] **Step 3: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
git add assets/css/main.scss
git commit -m "site(css): responsive styling for embedded Faust diagrams

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Republish `basic` with diagrams (Repo A → Repo B)

**Files:**
- Regenerate (Repo A, untracked): `doc/build/seam.basic.md`
- Modify (Repo B): `_libraries/basic.md`

**Interfaces:**
- Consumes: the pipeline from Task 1 and the CSS from Task 2.

- [ ] **Step 1: Regenerate the SVG-enriched body**

```bash
cd /Users/giuseppe/Documents/github/seam/librerie/faust-libraries
make -C doc md && make -C doc svg
grep -c '<div class="faust-diagram">' doc/build/seam.basic.md   # expect 7
```
Expected: 7 figures.

- [ ] **Step 2: Rebuild `_libraries/basic.md` (front matter + enriched body)**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
head -5 _libraries/basic.md > /tmp/fm.txt
# confirm /tmp/fm.txt is exactly the 5 front-matter lines (---, title, permalink, toc, ---)
{ cat /tmp/fm.txt; echo ""; cat /Users/giuseppe/Documents/github/seam/librerie/faust-libraries/doc/build/seam.basic.md; } > /tmp/basic.new.md
mv /tmp/basic.new.md _libraries/basic.md
```
First VERIFY `head -5 _libraries/basic.md` is the 5 front-matter lines; if not, stop and report.

- [ ] **Step 3: Build and verify the diagrams render**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
bundle exec jekyll build 2>&1 | tail -3
grep -c '<div class="faust-diagram">' _site/faustlibraries/basic/index.html   # expect 7
grep -c '&lt;svg' _site/faustlibraries/basic/index.html                        # expect 0 (not escaped)
grep -c '<svg' _site/faustlibraries/basic/index.html                           # expect >= 7
```
Then open `_site/faustlibraries/basic/index.html` and confirm: 7 diagrams render (under the Sweep and Scaling functions), each sized within the content column (no horizontal page scroll), and the right-hand TOC is unchanged (no `Diagram` clutter — the h4 is hidden by the existing CSS).

- [ ] **Step 4: Commit**

```bash
cd /Users/giuseppe/Documents/github/seam/blog/s-e-a-m.github.io
git add _libraries/basic.md
git commit -m "docs(basic): embed Faust block diagrams for Sweep + Scaling functions

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Final verification (all tasks)

- [ ] Repo A: `git log --oneline -2` shows the pipeline commit; `make -C doc svg` injects 7 diagrams idempotently; `git status` clean (no `doc/build/`).
- [ ] Repo B: `git log --oneline -3` shows CSS + republish commits; `git status` clean.
- [ ] `_site/faustlibraries/basic/index.html` has 7 rendered `.faust-diagram` SVGs, none escaped, page body does not scroll horizontally, TOC unchanged.
- [ ] Push both repos (user-approved). Fast follow (not this plan): add `#### Diagram` markers to `math` and rerun `make -C doc doc` + republish.
