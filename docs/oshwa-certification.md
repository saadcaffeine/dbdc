---
title: OSHWA certification
nav_order: 8
---

# OSHWA certification plan
{: .no_toc }

The [Open Source Hardware Association](https://certification.oshwa.org/) (OSHWA) runs a free self-certification programme. Certified projects get a unique identifier and may use the OSHWA certification mark. **DBDC is not certified yet.** This page tracks what the requirements ask for and where the project stands.

{: .important }
> Don't put the OSHWA mark on DBDC hardware, documentation or this site until certification is granted, and then follow OSHWA's mark usage guidelines.

1. TOC
{:toc}

## What OSHWA asks for

From the [certification requirements](https://certification.oshwa.org/requirements.html) and [FAQ](https://certification.oshwa.org/basics/faq.html), certified projects must:

- comply with the community [Open Source Hardware Definition](https://oshwa.org/definition/);
- share all of the creator's own contributions as open source, and make every part within their control open;
- use third-party components whose **datasheets are fully accessible and shareable**, with no NDA;
- certify each project through the online form, register each product version that will carry the mark, and **renew every year**;
- keep the linked documentation up to date.

Each certified version receives a unique identifier: a **two-letter country code plus six digits** (the first US project was US000001). Projects can be certified before launch, against documentation links that will be public at launch. Certification is then provisional until the public documentation matches.

The Open Source Hardware Definition requires, among other things, documentation that includes **design files in the preferred format for making changes**, a clear statement of what the licence covers, and openly licensed or fully documented software where the hardware needs software to work.

## Checklist

| Requirement | Status | Where |
|---|---|---|
| Open hardware licence applied | Done: CERN-OHL-S-2.0 | [`LICENSE.md`](https://github.com/saadcaffeine/dbdc/blob/main/LICENSE.md), SPDX header in the CAD, label on the left panel |
| Open software licence (OSI-approved) | Done: MIT | `software/` |
| Open documentation licence | Done: CC BY-SA 4.0 | `docs/`, `README.md` |
| Scope of each licence stated | Done | `LICENSE.md` table |
| Design files in the preferred format | Done: parametric OpenSCAD source; STLs are outputs | `hardware/cad/` |
| Fabrication outputs | Done: print-ready STLs, laid flat | `hardware/stl/` |
| Bill of materials | Done | `hardware/bom.csv` |
| Assembly instructions | Done (draft) | [Build guide](build-guide.md) |
| Third-party datasheets public | Done: N20-class gearmotor (Pololu micro metal gearmotor datasheet and drawings), DRV5023 hall switch (TI), DRV8833 (TI), ESP32 (Espressif) | `hardware/bom.csv` |
| Necessary software open, or interfaces documented | Partly done: interfaces documented and tables generated; firmware still to write | [Build guide → Firmware interface](build-guide.md#firmware-interface) |
| Electronics design files | To do: only a wiring table so far; a KiCad schematic is recommended | — |
| Built and tested version | To do | — |
| Tagged release matching the certified version | To do: tag `v0.2` once built | — |

## Recommended steps

1. **Build and test v0.1.** Fix any fit problems in the CAD and re-export.
2. **Add the pin return** and a reading-surface cover.
3. **Publish an electronics schematic** in KiCad (CERN-OHL-S), even if the prototype uses modules.
4. **Publish basic firmware** under MIT: homing, index-pulse positioning and a serial protocol. Alternatively, keep the documented interface as the open reference.
5. **Tag a release** (`v0.2`) whose files match the documentation exactly.
6. **Apply** at [certification.oshwa.org](https://certification.oshwa.org/). You'll need the project name, version, a description, the licences for hardware, software and documentation, and links to the repository and this site.
7. **After approval**, add the UID to the README, the docs and the panel label (for example "OSHW SG000xxx", using the country code OSHWA assigns), following OSHWA's mark guidelines.
8. **Renew yearly**, and register each new hardware version that will carry the mark.

## Why CERN-OHL-S

The strongly reciprocal CERN Open Hardware Licence v2 means anyone who distributes a modified DBDC must share their modified design files too. For an assistive device where cost and repairability matter, that keeps improvements open for everyone. If a future collaborator needs to combine DBDC with closed parts, the weakly reciprocal CERN-OHL-W-2.0 is an alternative. Changing licence requires agreement from all copyright holders, so decide before accepting outside contributions.
