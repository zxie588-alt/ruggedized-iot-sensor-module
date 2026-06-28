# Toolchain Plan

## Confirmed / Intended Tools

| Tool | Role | Status |
| --- | --- | --- |
| SolidWorks 2018 | Enclosure, assembly, exploded view, drawings, STEP/STL exports | Confirmed installed |
| Abaqus / SIMULIA 2025 | Strap mount, corner load and screw-boss compression FEA | Confirmed installed |
| AutoCAD 2026 | 2D fixture/manufacturing layouts | Confirmed installed |
| Proteus 8 Professional | Electronics architecture and schematic-level model | Confirmed installed; schematic evidence package added |
| Keil MDK / uVision | Embedded firmware project and MCU code plan | Confirmed installed; ARMCM3 concept target build verified with 0 errors and 0 warnings |
| Python | Data processing, plots, optional dashboard | Confirmed installed |
| Node / GitHub Pages | Portfolio website | Confirmed installed |

## Tool Use Boundaries

- SolidWorks is the primary visual and mechanical design tool.
- Abaqus is used for three focused concept load cases, not full product certification.
- Proteus supports electronics packaging and signal/power architecture, not final PCB release.
- Keil supports firmware structure, embedded C evidence and a concept ARMCM3 target build, not a complete production firmware unless final hardware is later defined.

## Next Tool Actions

1. Build SolidWorks enclosure assembly and exploded view.
2. Convert schematic evidence package into native Proteus `.pdsprj` when final library parts are selected.
3. Bind Keil/uVision project to a final MCU device pack after MCU selection.
4. Add physical validation only after prototype hardware exists.
