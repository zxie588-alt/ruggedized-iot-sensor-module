# PCB Concept DRC / Clearance Review V1

Date: 2026-06-29

## Concept Rules

| Rule | Concept value | Rationale |
| --- | --- | --- |
| Minimum track width | 0.20 mm signal, 0.60 mm power | Conservative for low-cost prototype fabrication |
| Minimum clearance | 0.20 mm | Conservative two-layer prototype spacing |
| Via drill | 0.30 mm drill / 0.60 mm pad | Common prototype capability |
| Mounting hole copper keepout | 2.0 mm radial | Avoid screw/standoff shorting |
| Board edge copper keepout | 1.0 mm | Avoid exposed copper at enclosure edge |
| Sensor keepout | 8 mm x 8 mm above U2 | Keep sensor membrane area clear |
| Radio keepout | 16 mm x 14 mm around J2 | Reserve future radio module and antenna review |

## Review Result

| Check | Status | Comment |
| --- | --- | --- |
| Board outline within enclosure PCB envelope | Concept pass | 72 mm x 44 mm fits current V2 package envelope |
| Battery connector near battery pocket | Concept pass | BT1 placed on left edge for short cable route |
| Service/debug connector near sealed port | Concept pass | J1 placed on right edge near service port |
| MCU central placement | Concept pass | U1 centralises I2C, ADC, UART and SWD routes |
| Sensor thermal separation | Concept review | U2 kept away from regulator, but final heat map needs physical validation |
| Power route width | Concept review | VBAT/3V3 intended wider than signal routes, exact EDA DRC still future work |
| Mounting-hole keepouts | Concept pass | Four corner keepout zones included in layout image |
| Final EDA DRC | Not claimed | Requires native PCB tool layout and DRC export |

## Boundary

This is a DRC-style concept review, not a native EDA DRC sign-off. It is suitable for portfolio evidence of PCB layout planning and manufacturing awareness. Final clearance, drill and fabrication checks must be rerun in the chosen PCB tool before ordering hardware.
