# Licensing

The DBDC Open-Source Refreshable Braille Display uses a different licence for each kind of material, as recommended for open source hardware. Full licence texts are in [`LICENSES/`](LICENSES/).

| What | Where | Licence | SPDX identifier |
|---|---|---|---|
| Hardware design: CAD sources, print files, bill of materials | [`hardware/`](hardware/) | CERN Open Hardware Licence v2, Strongly Reciprocal | `CERN-OHL-S-2.0` |
| Software and generated firmware tables | [`software/`](software/) | MIT License | `MIT` |
| Documentation, images and diagrams | [`docs/`](docs/), `README.md` and other Markdown files | Creative Commons Attribution-ShareAlike 4.0 International | `CC-BY-SA-4.0` |

Copyright 2026 Saad Chinoy and DBDC contributors.

## What this means in practice

- **You can build, modify, make and sell DBDC hardware.** If you distribute modified hardware or its design files, you must share your modified sources under the same CERN-OHL-S v2 licence and keep the source-location notice (the label debossed into the left end panel, and the header in each CAD file).
- **You can use the software in anything**, open or closed, as long as you keep the copyright notice.
- **You can copy and adapt the documentation**, crediting "DBDC Open-Source Refreshable Braille Display" with a link to the repository, and sharing your adaptations under CC BY-SA 4.0.

## Source location

`https://github.com/saadcaffeine/dbdc`

## Third-party components

The design uses off-the-shelf parts that are not covered by these licences: N20 gearmotors, hall effect sensors, magnets, motor drivers and a microcontroller board. Public datasheets for each are linked in [`hardware/bom.csv`](hardware/bom.csv). None needs a non-disclosure agreement.

## Name

"DBDC" stands for **de Bruijn Disc Cell**.
