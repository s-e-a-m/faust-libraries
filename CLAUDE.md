# CLAUDE.md

Guidance for Claude Code working in this repository.
Workspace-level context (org, gotchas) lives in the `CLAUDE.md` of the `seam` workspace two levels up.

## Entry Point

`src/seam.lib` imports `stdfaust.lib` and all active sub-libraries with short namespace prefixes.
DSP files only need `import("seam.lib")` to access everything.

## Namespace Prefixes

Defined in `src/seam.lib` — read it rather than trusting a copied list.

## Building / Testing

```bash
faust -svg file.dsp          # SVG block diagram
faust2jack file.dsp           # JACK standalone
echo 'import("src/seam.lib"); process = sms.dfl(1,1/sqrt(2));' | faust -  # inline test
```

Commented-out `//process = ...` lines in `.lib` files are inline tests — uncomment and compile to verify.

## Conventions

- Every `.lib` starts with `declare` metadata + `import("seam.lib")`
- Each `.lib` re-declares its own prefix for self-referencing
- Academic citations in reverb/spatialization code must be preserved
- `src/` = active libs, `temp/` = WIP (commented out in seam.lib)

## Web publishing

The documentation lives on the `s-e-a-m.github.io` site, in the `_libraries` collection, at `/faust-libraries/` — the same name as this repository.

Regenerate and transport it with `make -C doc publish`.
The script writes only into its own collection, its own marked block of `_data/navigation.yml`, and never commits.

**GitHub Pages for this repository must stay off.**
When a project page and the user site claim the same path, the project page wins.
Turning it back on would leave the site's pages built, uploaded and never served, with no visible error anywhere.

## The coverage gate

`doc/scripts/publish.sh` publishes only libraries with at least one function documented at the source, and prints the coverage.
A page of bare section titles is worse than no page.

To make a library publishable, document its functions in the Grame banner format that `doc/scripts/faustlib2md.awk` reads — see `seam.basic.lib` and `seam.math.lib` for the two that already do.

Run `make -C doc test` after touching anything under `doc/scripts/`.
