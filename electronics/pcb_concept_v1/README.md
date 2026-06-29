# PCB Concept Package V1

Status: concept PCB evidence package for portfolio review.

This folder converts the existing Proteus-ready electronics architecture into a visible two-layer PCB concept package. It is intended to show board-level thinking: component placement, connector strategy, power routing, service/debug access, keepouts and manufacturability checks.

## Included Evidence

- `component_bom_v1.csv` - PCB-level component list.
- `pcb_netlist_v1.csv` - board nets traced to firmware ownership and mechanical interface.
- `placement_plan_v1.csv` - first-pass component locations and rotation intent.
- `layer_stackup_v1.csv` - two-layer FR-4 concept stackup.
- `drc_clearance_review_v1.md` - clearance/width review and remaining layout checks.
- `manufacturing_outputs/` - concept Gerber-style and NC drill evidence files.

## Board Concept

| Item | Concept |
| --- | --- |
| Board size | 72 mm x 44 mm rounded rectangle |
| Layers | 2-layer FR-4 |
| MCU | STM32L432KCUx candidate |
| Interfaces | I2C sensor, battery ADC, status/fault LEDs, SWD, UART radio boundary |
| Mechanical constraints | PCB standoffs, battery pocket, cable gland side and sealed service/debug port |
| Manufacturing intent | Low-cost two-layer prototype board with conservative clearances |

## Evidence Boundary

This package is not a production PCB release. It does not claim:

- Completed EDA-native PCB design.
- Vendor DRC sign-off.
- Controlled impedance.
- RF antenna certification.
- Fabricated board bring-up.

It is a concept board package that makes the electrical layout plan visible and reviewable before a final EDA tool release.
