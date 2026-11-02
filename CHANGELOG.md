# Changelog

All notable changes to the DBDC hardware, software and documentation.
Versions follow `MAJOR.MINOR` for the hardware; each released version can be certified separately with OSHWA.

## v0.2 (prototype, unreleased)

- **No encoder needed.** The worm wheel now has 64 teeth (module 0.94), one per position, so one turn of the worm moves the disc exactly one position.
- **Index sensing:** a 2 × 1.5 mm magnet in a collar on each worm sleeve passes a hall switch held in a tower on the motor rail, giving one pulse per position, centred on the cam's flat top. The front and back worms differ only in the angle of the magnet hole.
- **Home sensing:** a 3 × 1 mm magnet in each wheel and a hall switch on a raised pedestal beside it. Position 0 is the middle index pulse while the home switch is active.
- Plain N20 gearmotors (about 27 mm long instead of 41.5 mm). The unit is 14 mm shorter, and the base, bolts and panels are updated to match.
- Wheel 1.2 mm thick with 0.45 mm gaps; worm 8.9 mm across with a 7.6° lead angle (still self-locking); pins 11.25 / 11.13 mm.
- Recommended hall switch: TI DRV5023 (TO-92), two per cell.

## v0.1 (prototype, superseded)

- First printable 3-cell prototype: one 51 mm two-track de Bruijn cam disc per cell, 120-tooth side worm wheel, worm on an N20 encoder gearmotor, hall-sensor homing.
- Flat-printable frame: two end panels with locating pockets, pin guide plate, front and back motor rails, sensor rail and base, clamped with four M3 bolts.
- `software/dbdc_table.py` generates the pattern-to-position tables (C header, JSON, Markdown) and checks them against the CAD file.
- Design history kept in `hardware/cad/history/`: two-disc cam cell with steppers, worm-driven strips for 8 mm and 4 mm micro steppers.

- Fix: the disc and its worm wheel were joined only by a 10 mm hub, leaving a 0.55 mm gap that the cam had to bridge when printed wheel-face down. The gap is now filled with a solid web out to 0.1 mm inside the cam's lowest radius (`hub_r = R - web_margin`). The gap stays open above the cam surface, where the wheel needs 0.6 mm clearance to the right-hand column of pins.

- Worm support: a 2 mm metal journal pin in each worm's free end runs in a printed comb (front and back), so the worm can't deflect away from the wheel teeth. New parts `dbdc_comb_front` and `dbdc_comb_back`, with matching pockets in the end panels.
- Assembly fix: the base now has a channel for each row of encoder ends instead of closed pockets, so it can slide in after the motors are fitted. With closed pockets, the base and motors could not both be fitted.

- Assembly fix: the rail lip's inner edge moved outward to 0.3 mm beyond the worm's outer diameter. Before, the lip reached 0.45 mm into the worm's path, so a motor with its worm fitted could not be pushed up into place. A swept-path check now covers insertion.

Not yet done: pin return, electronics schematic, firmware, a built and tested unit.
