---
title: Why cost matters
nav_order: 7
---

# Why cost matters
{: .no_toc }

1. TOC
{:toc}

## Braille on a screen costs thousands

For a blind person, a refreshable braille display is the screen. It is how they read and write code, check a spreadsheet, proofread a document or read a book in braille. But displays cost far more than the computers they connect to.

| Display | Cells | Price | Price per cell |
|---|---|---|---|
| Orbit Reader 20 | 20 | $449 (2017) | ~$22 |
| Braille Me | 20 | $515.50 | ~$26 |
| VarioUltra 20 | 20 | $2,395 (2017) | ~$120 |
| Braille Edge 40 | 40 | $2,795 (2017) | ~$70 |
| Canute 360 (multi-line) | 360 | £2,495 | ~£7 |
| Monarch (multi-line graphics) | 320 cells (3,840 pins) | $15,500 | ~$48 |

Sources are in [Related projects and products](related-projects.md#commercial-displays).

The core reason is the actuators. Commercial piezo cells are commonly quoted at **$100–150 each**, which puts a 40-cell display at **$4,000–6,000** and an 80-cell one at **$8,000–12,000** ([Hackaday.io, 2023](https://hackaday.io/project/191181-electromechanical-refreshable-braille-module)). In 2000, NIST reported 80-cell displays at **$10,000–15,000**, plus about **$500 a year** in maintenance ([NIST](https://www.nist.gov/node/710926)). Twenty-five years on, low-cost designs have brought 20-cell displays down to around $450–520. A full-width line, or several lines, is still a major purchase.

## What that price means around the world

- About **1.1 billion people** live with sight loss. 90% of it is preventable or treatable, and the number is projected to pass 1.7 billion by 2050 ([IAPB Vision Atlas](https://visionatlas.iapb.org/global-data/)).
- Sight loss costs an estimated **$410.7 billion** a year in lost productivity worldwide, $43.6 billion of it from blindness ([IAPB, citing Burton et al., *Lancet Global Health*, 2021](https://visionatlas.iapb.org/global-data/)).
- The World Bank classes economies with a gross national income of **$1,175 per person a year or less** as low income, and $1,176–4,635 as lower-middle income ([World Bank, FY2027](https://datahelpdesk.worldbank.org/knowledgebase/articles/906519)).

At that threshold, even the cheapest 20-cell display costs about **38% of a year's income per person**. A 40-cell piezo display costs about **2.4 years'** income, and a multi-line graphics display more than **13 years'**. Gross national income per person is a national average, not a household budget. But the gap is clear: for most blind people in low- and middle-income countries, refreshable braille is out of reach, and so are the schools, libraries and employers who might buy it for them.

## Braille literacy and work

Braille is literacy, not just access. Several US studies have found that braille readers are more likely to be employed. A summary by the National Research and Training Center on Blindness and Low Vision at Mississippi State University ([NRTC](https://www.blind.msstate.edu/our-products/braille-use-related-employment)) includes:

- **Bell, Ewell and Mino (2013)**, 1,056 adults: **58%** of braille readers were employed, against **44%** of non-readers, with average earnings of $45,947 against $34,826.
- **Ryles (1996)**, 74 congenitally blind adults: **56%** of those who learned braille were employed, against **23%** of those who learned print.
- **McDonnall et al. (2025)**: proficient braille was associated with employment, more strongly among people who are totally blind.

These are associations, not proof of cause, and the NRTC notes that more rigorous research is needed. They are consistent, though.

Braille literacy has also fallen. A 2009 National Federation of the Blind report found that **fewer than 10%** of the 1.3 million legally blind people in the US read braille. In the 1950s, more than half of blind children learned it ([NBC News](https://www.nbcnews.com/id/wbna29882719)). Many factors are involved. One of them is cost: when every braille reader needs an expensive device, schools ration them.

## Why open hardware helps

Cheaper parts are only half of it. Open hardware also changes who can make, fix and improve the device:

- **Local manufacture.** Makerspaces and small workshops can print and assemble displays without importing finished devices or paying distributor margins.
- **Repair.** A worn disc, worm or pin is a reprint or a piece of rod, not a return to the manufacturer. Repair is the long-term cost that NIST identified.
- **Adaptation.** Different braille codes, cell counts, form factors and languages can be designed by the people who need them.
- **No lock-in.** Open firmware and drivers (for example via [BRLTTY](https://brltty.app/)) keep the display usable when a vendor moves on.
- **Shared progress.** Every builder's test results improve the next version for everyone.

## Where DBDC aims

DBDC targets **a few dollars of parts per cell**. Based on current retail and marketplace prices, the estimate is about $3–7 per cell for a plain N20 motor, a share of a driver chip, two hall switches, two magnets, the pins and the printed parts, plus about $10–20 shared across a unit for the controller, supply and frame. A 20-cell line would then cost roughly $70–160 in parts. Dropping the motor encoder in v0.2 saved about a third of the per-cell cost. These are estimates from the [bill of materials](https://github.com/saadcaffeine/dbdc/blob/main/hardware/bom.csv), not quotes. They exclude labour, and they need a built, tested unit to confirm.

The trade-offs are real: DBDC is slower to refresh, larger and noisier than piezo displays (see [How it works → Trade-offs](how-it-works.md#trade-offs)). For a reader who has no display at all, a slower, open display they can afford and repair may be worth much more than a fast one they can't.
