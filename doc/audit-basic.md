# Audit — seam.basic.lib vs official basics.lib (2026-07-10)

Rule: `basic` keeps only what is NOT already provided upstream (or documented,
justified variants). Decisions taken function-by-function with the user (the
"product that self-determines" gate).

Reference checkout (canonical upstream): `/Users/giuseppe/Documents/github/faustlibraries`

| symbol | upstream equivalent | evidence | DECISION | rationale |
|---|---|---|---|---|
| `sweep(p,t)`     | `ba.sweep`          | `ba.sweep = %(int(*:max(1)))~+(1)` counts from **1**, single arg + `run` gate. SEAM seeds `1'` → counts from **0**, period `p*t`. | **variant** | documented divergence: from-0 counting + parameterized base×multiplier period |
| `lsweep(sec,t)`  | (none exact)        | `os.phasor`/`os.lf_rawsaw` are normalized `0..1`; `lsweep` is a sample-domain ramp `0..ma.SR/2` repeating every `sec`. | **keep** | no upstream equivalent |
| `zsweep(p)`      | (none)              | zero-padded frame builder (`p` zeros + `sweep(p)`); composes `sweep`. | **keep** | no upstream equivalent |
| `zerox(x)`       | `ma.zc`             | `ma.zc = ba.tAndH(!=(0)) <: *(mem) < 0` fires on **any** crossing (up or down). `zerox = (x'<0)&(x>=0)` fires **only on rising** (neg→non-neg). | **variant** | directional (rising-only) variant of `ma.zc` |
| `revlist(n)`     | (none)              | downward parallel bus `n, n-1, … , 1`. `ba.count/take/subseq` differ (no reversed constant bus). | **keep** | no upstream reversed-constant-bus |
| `scalel(a,b,c,d,x)` | (none)           | no affine `scale` upstream (`it.interpolate_*` is a different API). Current def `((x-a)/(b-a))*(d-c)` **is missing `+c`** (bug hidden by examples using c=0). | **keep + fix** | unique; restore affine map `c + ((x-a)/(b-a))*(d-c)` |
| `vstin(y,n)`     | (none)              | `si.bus(y),si.block(n)` — trivial composition of standard primitives, but a recurring named idiom. | **keep** | recurring SEAM idiom (VST input management); worth a public documented name |
| `mille` `cento` `la` `rosa` | (none)   | `os.osc(1000/100/440)` + `no.pink_noise` — fixed-frequency test oscillators / personal shortcuts. | **remove** | personal test shortcuts, not public API |
| `nyq`            | (none; `ma.SR` only) | `ma.SR/2`. Official `maths.lib` has **no** Nyquist constant. | **remove** | Evidence: `nyq` is used **nowhere** as a value (only its own def + two commented tests), while `ma.SR/2` is written directly across the libs — almost always as a **delay-buffer size** (`de.delay(ma.SR/2,…)`, i.e. ~0.5 s of samples), *not* as a Nyquist frequency in Hz. The two meanings collide on the same expression, so a `nyq` alias would mislead. `ma.SR/2` is idiomatic, universal, and trivially derivable → fails the audit rule. Not worth relocating either. |

## Consequences for Task 3

- **Delete** from `seam.basic.lib`: `mille`, `cento`, `la`, `rosa`, `nyq`.
- **Fix** `scalel` (`+c` restored).
- **Keep & document** (header/section/Usage/Where/Test): `sweep`, `lsweep`,
  `zsweep`, `zerox`, `revlist`, `scalel`, `vstin`.
- **`seam.math.lib` untouched**: the only reference to `nyq` there is the
  commented `srphi` test on line 67; re-point it from `sba.nyq` to `ma.SR/2`
  directly. Scope of Task 3 stays confined to `seam.basic.lib` (plus that one
  commented test line), as in the original plan.
