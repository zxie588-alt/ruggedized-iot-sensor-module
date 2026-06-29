# Software Completion Boundary V1

Date: 2026-06-29

## Purpose

This note records where the project has been pushed as far as practical using local software tools, and what remains blocked by hardware, supplier review or interactive/proprietary tool behaviour.

## Closed Digital Evidence

| Area | Evidence now available |
| --- | --- |
| Mechanical concept | SolidWorks CAD V1/V2, STEP/STL exports, exploded renders |
| Mechanical analysis | Three Abaqus concept FEA load cases with reports and plots |
| Electronics architecture | Proteus-ready schematic package, netlist, signal ownership, power budget, SVG schematic |
| PCB concept | Two-layer PCB concept package with component BOM, board netlist, placement plan, stackup, DRC-style review and Gerber-style outputs |
| PLC fixture control | Test-fixture PLC concept with I/O list, sequence, fault matrix, ladder logic, HMI screen spec and IEC 61131-3 structured text |
| Native Proteus evidence | Verified `.pdsprj` container with `ROOT.DSN`, `ROOT.CDB`, `PROJECT.XML`, manifest and verification report |
| Firmware build | Keil/uVision ARMCM3 concept target, ARMCLANG source compile, 0-error/0-warning uVision build log |
| Low-power MCU path | STM32L4xx device pack installed/audited, `STM32L432KCUx` candidate path, pin allocation and porting plan |
| Thermal screening | Lumped thermal exposure simulation with CSV/JSON/SVG/report |
| Release control | BOM, DFM checklist, assembly instruction, drawing register, inspection-control sheet and CTQ table |
| Portfolio publishing | GitHub source and GitHub Pages project page |

## Remaining Items And Why They Are Not Claimed

| Remaining item | Current blocker | What would complete it |
| --- | --- | --- |
| Fully populated native Proteus schematic sheet and ERC export | Proteus schematic content is stored in proprietary native project data and the GUI was not reliably automatable from command line. A native project container is verified, but the sheet is not populated in a way that can be honestly claimed. | Manually populate the Proteus schematic in the GUI or use a supported Proteus automation/API flow, then export ERC and archive the native `.pdsprj`. |
| Final board-specific STM32L432 target build | Candidate MCU, pack, pinout and porting plan are done, but startup/system files, RTE configuration and final schematic pinout are not locked. | Add STM32L432 startup/system files, create `STM32L432KCUx_Candidate` Keil target, build, and archive target-specific log. |
| Native EDA PCB design | Current PCB package is a concept layout evidence package, not a native EDA production release. | Complete schematic capture, PCB placement/routing, vendor DRC and production manufacturing outputs in the chosen EDA tool. |
| Downloaded PLC fixture program | PLC package is a vendor-neutral control concept; no physical PLC or commissioned fixture is connected. | Import/adapt the logic in Siemens/Allen-Bradley/Mitsubishi/CODESYS, wire fixture I/O, test interlocks and archive commissioning results. |
| Flashed firmware and HIL test | Requires prototype hardware or development board wired to representative peripherals. | Flash the candidate target and run BOOT/SELF_TEST/SLEEP/SAMPLE/FAULT/SERVICE state checks against real or fixture-driven I/O. |
| Physical thermal logging | Requires assembled enclosure and temperature sensors. | Record internal/external temperature CSV under sunlight or lamp exposure and compare with simulation. |
| IP/spray evidence | Requires physical enclosure and test setup. | Run spray/dye/tissue observation test and record photos/results. |
| Supplier-reviewed production drawing set | Requires production intent, supplier process input and GD&T review. | Release supplier-reviewed 2D drawings and first-article/inspection records. |

## Honest Portfolio Position

The project is now strong as a software-backed product-engineering portfolio case study: it demonstrates requirements, CAD, simulation, electronics planning, embedded firmware structure, low-power MCU selection discipline, manufacturing thinking and evidence control.

It should still be presented as a concept engineering release package, not a production-ready IoT product.
