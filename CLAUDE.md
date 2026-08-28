# CLAUDE.md

Guidance for Claude Code working in this repository.
Workspace-level context (namespace prefixes, build commands, conventions) lives in the `CLAUDE.md` of the `seam` workspace one level up.

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
