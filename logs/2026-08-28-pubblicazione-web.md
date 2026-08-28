# Session log — 2026-08-28 — Publishing the reference on the SEAM site

## Goal
Bring the reference generated under `doc/` onto the `s-e-a-m.github.io` site, at an address consistent with the repository name, through a repeatable command.

## What was found
This repository had GitHub Pages enabled and was serving its own README with the default theme at `/faust-libraries/`.
The site was serving the curated reference at `/faustlibraries/`, without the hyphen: that was the only free path, because when a project page and the user site claim the same path, the project page wins.

The two published library pages were already online but orphaned: no entry in the site's main menu named them, so they were reachable only by typing the URL.

Regenerating `doc/build/` from scratch showed that only `seam.basic` (10 functions) and `seam.math` (19) have functions documented at the source.
The other eighteen have no function banners in the Grame format and produce pages of bare titles; `dwt` and `stereophony` produce empty files.

## Decisions
The public URL is the repository name: `/faust-libraries/`.
GitHub Pages for the repository is off, so the path belongs to the site.
`publish.sh` applies a coverage gate: only documented libraries are published, and the ratio is printed.

## Actions
- Disabled GitHub Pages on the repository (`gh api -X DELETE repos/s-e-a-m/faust-libraries/pages`).
- Added `doc/scripts/publish.sh`, `doc/scripts/navblock.py`, `doc/scripts/test-publish.sh`, and the `publish` and `test` targets in `doc/Makefile`.
- Published two references plus the suite index; the sidebar is generated into a marked block of the site's `_data/navigation.yml`.
- Added `CLAUDE.md`, `TODO.md` and this `logs/` directory, which the repository did not have.

## Notes
The test counts how many checks it ran.
A check broken by a quoting mistake prints neither `ok` nor `FAIL`: it disappears, and would leave a green test that verified nothing.

## Open
- Eighteen libraries to document at the source — one entry each in `TODO.md`.
- After the site deploy, confirm that `/faust-libraries/` is served by the site and not by the cached project page.

## Who
**Who:** Claude (agent), on Giuseppe's instructions.
