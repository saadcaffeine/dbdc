# DBDC software

SPDX-License-Identifier: MIT. See [`../LICENSE.md`](../LICENSE.md).

`dbdc_table.py` needs Python 3.9 or later and nothing else.

```sh
python3 dbdc_table.py                       # regenerate generated/*
python3 dbdc_table.py --check-scad ../hardware/cad/dbdc_3cell.scad
python3 dbdc_table.py --text "hello world"  # positions and moves for a-z text
```

## Generated files

| File | Use |
|---|---|
| `generated/dbdc_positions.h` | C header for firmware: `DBDC_POSITION_OF[mask]` gives the disc position for a dot mask (bit 0 = dot 1 ... bit 5 = dot 6, the same bit order as Unicode braille U+2800–U+283F) |
| `generated/dbdc_positions.json` | The same data for scripts and web tools |
| `generated/position_table.md` | Table of all 64 patterns, used in the docs |
| `generated/debruijn_strip.svg` | The two tracks unrolled, used in the docs |

## Conventions

- Positions `k` run 0–63. The disc angle is `k × 5.625°`.
- At position `k`, the top row (dots 1 and 4) reads rim position `k+1`, the middle row (dots 2 and 5) reads `k`, and the bottom row (dots 3 and 6) reads `k-1`.
- Rim symbol = `2 × left_track + right_track`.
- Moving from `a` to `b`: take the shortest way round, at most 32 positions (`shortest_move()`).
- The worm wheel has 64 teeth, so one worm turn = one position = one index pulse.
- Homing: position 0 is the middle index pulse of those seen while the home switch is active.

Firmware is not written yet. The interfaces it needs are documented in [`../docs/build-guide.md`](../docs/build-guide.md#electronics-and-wiring).
