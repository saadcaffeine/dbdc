# DBDC hardware

SPDX-License-Identifier: CERN-OHL-S-2.0. See [`../LICENSE.md`](../LICENSE.md).

## Files

| File | What it is |
|---|---|
| `cad/dbdc_3cell.scad` | Main parametric OpenSCAD source for the 3-cell prototype: discs, worms, frame, and a placeholder model of every bought part |
| `cad/history/01_cam_cell_stepper.scad` | First idea: two 19 mm discs per cell (one per column), stepper on a face gear |
| `cad/history/02_worm_strip_8mm.scad` | Two discs per cell, worm drive, 8 mm micro steppers in three staggered positions |
| `cad/history/03_worm_strip_4mm.scad` | Same, with 4 mm micro steppers in two rows |
| `cad/history/04_single_disc_n20_encoder.scad` | v0.1: one disc per cell, 120-tooth wheel, N20 gearmotors with encoders |
| `stl/dbdc_*.stl` | Print-ready parts, each laid flat on the bed |
| `bom.csv` | Bill of materials with quantities, datasheet links and estimated prices |

## Export

Each part has a `print_` view that lays it flat:

```sh
for p in disc worm_front worm_back panel_left panel_right guide_plate rail_front rail_back sensor_rail base comb_front comb_back; do
  openscad -D "part=\"print_$p\"" -o stl/dbdc_$p.stl cad/dbdc_3cell.scad
done
```

Other views: `assembly`, `exploded`, `mechanism` (no frame), `end_view`.

## Print settings (suggested)

| Part | Layer | Notes |
|---|---|---|
| Disc | 0.2 mm, or 0.12 mm for a smoother cam | Wheel face on the bed; 4 perimeters, so the cam rim and teeth are solid |
| Worms (front ×2, back ×1) | 0.1–0.15 mm | Upright, pinned end on the bed; the collar has a 45° chamfer underneath. Front and back differ only in the index-magnet hole angle |
| Worm combs | 0.2 mm | Flat; check that the 2.2 mm holes turn freely on a 2 mm pin |
| Panels, rails, base, plates | 0.2 mm | Pockets face up; no supports |

PLA or PETG both work. Check the 1.8 mm pin holes and the 10.3 × 12.3 mm motor pockets against your parts, and use `fit` and `mfit` in the CAD if you need to adjust the clearances.

## Key parameters

Everything is driven from the parameters at the top of `dbdc_3cell.scad`. The ones you're most likely to change:

| Parameter | Default | Meaning |
|---|---|---|
| `cells` | `[[1,4],[1],[2,3,4,5]]` | Dots shown in the assembly view ("cat") |
| `dot_height` | 0.6 | Cam lift = dot height (mm) |
| `pin_d`, `pin_clear` | 1.5, 0.15 | Pin diameter and guide clearance |
| `gear_teeth` | 64 | One tooth per position, so one worm turn = one position; module follows (0.94) |
| `mot_w`, `mot_h`, `can_len`, `tail_len` | 10, 12, 15, 3 | N20 body size (no encoder); measure yours |
| `collar_r`, `idx_mag_d`, `idx_mag_t` | 4, 2, 1.5 | Index collar and magnet on the worm |
| `motor_start` | 18 | Worm centre to gearbox face |
| `fit`, `mfit` | 0.2, 0.15 | Pocket clearances |
