# TODO

## Source documentation (for web publishing)

Only `basic` and `math` have functions documented in the Grame banner format.
The others generate pages of bare titles and are held back by the coverage gate in `doc/scripts/publish.sh`.

Each entry below notes how much prose the generated page already has, as a rough measure of how far it is from being publishable.

- [ ] `seam.filters.lib` — 205 lines of text, no function banners
- [ ] `seam.analyzers.lib` — 192 lines, no function banners
- [ ] `seam.gerzon.lib` — 171 lines, no function banners
- [ ] `seam.pdclone.lib` — 145 lines, no function banners
- [ ] `seam.discipio.lib` — 85 lines, no function banners
- [ ] `seam.schroeder.lib` — 85 lines, no function banners
- [ ] `seam.cyclone.lib` — 63 lines, no function banners
- [ ] `seam.ambisonics.lib` — 51 lines, no function banners
- [ ] `seam.freeverb.lib` — 48 lines, no function banners
- [ ] `seam.linkwitz.lib` — 35 lines, no function banners
- [ ] `seam.moorer.lib` — 32 lines, no function banners
- [ ] `seam.reverbs.lib` — 18 lines, no function banners
- [ ] `seam.roads.lib` — 18 lines, no function banners
- [ ] `seam.noises.lib` — 10 lines, no function banners
- [ ] `seam.csound.lib` — 3 lines, no function banners
- [ ] `seam.ffunctions.lib` — 3 lines, no function banners
- [ ] `seam.dwt.lib` — nothing extractable yet
- [ ] `seam.stereophony.lib` — nothing extractable yet

## Site

- [ ] Sidebar: "Library Reference" is a heading, not a link — minimal-mistakes only renders `children` as links, so the suite index is reachable only from `/docs/`. Add a first child entry pointing at `/faust-libraries/`.
