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
