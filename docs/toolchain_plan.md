# Toolchain Plan

## Confirmed / Intended Tools

| Tool | Role | Status |
| --- | --- | --- |
| SolidWorks 2018 | Enclosure, assembly, exploded view, drawings, STEP/STL exports | Confirmed installed |
| Abaqus / SIMULIA 2025 | Strap mount, corner load and screw-boss compression FEA | Confirmed installed |
| AutoCAD 2026 | 2D fixture/manufacturing layouts | Confirmed installed |
| Proteus 8 Professional | Electronics architecture and schematic-level model | Confirmed installed; schematic evidence package and verified native project container added |
| Keil MDK / uVision | Embedded firmware project and MCU code plan | Confirmed installed; ARMCM3 concept target build verified with 0 errors and 0 warnings; STM32L4xx DFP 3.0.0 installed and audited |
| Python | Data processing, plots, optional dashboard | Confirmed installed |
| Node / GitHub Pages | Portfolio website | Confirmed installed |

## Tool Use Boundaries

- SolidWorks is the primary visual and mechanical design tool.
- Drawing-control evidence currently uses SVG/CSV concept sheets; AutoCAD or SolidWorks drawings can replace them when a production drawing format is needed.
- Abaqus is used for three focused concept load cases, not full product certification.
- Proteus supports electronics packaging, signal/power architecture and a native project container, not final PCB release.
- Keil supports firmware structure, embedded C evidence, a concept ARMCM3 target build and audited STM32L4 candidate device-pack readiness, not a complete production firmware unless final hardware is later defined.

## Next Tool Actions

1. Build SolidWorks enclosure assembly and exploded view.
2. Populate the native Proteus `.pdsprj` schematic sheet and export ERC when final library parts are selected.
3. Create a board-specific `STM32L432KCUx` Keil target after schematic/pinout selection, including startup/system files, RTE configuration and flash/HIL evidence.
4. Add physical validation only after prototype hardware exists.
