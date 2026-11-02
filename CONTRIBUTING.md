# Contributing to DBDC

Thank you for helping make refreshable braille affordable.

## Ways to help

- **Build and test a unit.** Report print settings, fit problems, refresh time, noise and how the dots feel. Photos and short videos help.
- **Read and review as a braille user.** Dot height, firmness, spacing and refresh behaviour matter most, and only readers can judge them.
- **Design.** Pin return, the reading-surface cover, the electronics board, a 20-cell frame, and alternative motors.
- **Firmware and software.** Homing, encoder positioning, a host protocol, a BRLTTY driver.
- **Documentation.** Clearer instructions, translations, and accessibility fixes to these pages.

## How to contribute

1. Open an issue describing what you want to change, or what you found.
2. Fork the repository and make your change on a branch.
3. For CAD changes, edit `hardware/cad/dbdc_3cell.scad` (the source, not the STLs), then re-export the affected STLs and run:
   ```sh
   python3 software/dbdc_table.py --check-scad hardware/cad/dbdc_3cell.scad
   ```
4. Open a pull request explaining what changed and how you checked it.

## Licensing of contributions

By contributing you agree that your contribution is licensed under the licence of the part you changed: CERN-OHL-S-2.0 for `hardware/`, MIT for `software/`, CC BY-SA 4.0 for documentation. Add an `SPDX-FileCopyrightText` line to new files.

## Accessibility of the project itself

Many people interested in this project read with a screen reader or braille. Please:
- give every image meaningful alt text,
- keep tables simple (one header row, no merged cells),
- don't convey information by colour alone,
- prefer text over screenshots of text.
