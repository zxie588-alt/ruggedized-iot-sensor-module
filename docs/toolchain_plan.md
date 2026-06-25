# Toolchain Plan

## Confirmed / Intended Tools

| Tool | Role | Status |
| --- | --- | --- |
| SolidWorks 2018 | Enclosure, assembly, exploded view, drawings, STEP/STL exports | Confirmed installed |
| Abaqus / SIMULIA 2025 | Strap mount and corner load FEA | Confirmed installed |
| AutoCAD 2026 | 2D fixture/manufacturing layouts | Confirmed installed |
| Proteus 8 Professional | Electronics architecture, schematic-level model | Confirmed installed |
| Keil MDK / uVision | Embedded firmware project or MCU code plan | Driver confirmed; executable path to verify during firmware step |
| Python | Data processing, plots, optional dashboard | Confirmed installed |
| Node / GitHub Pages | Portfolio website | Confirmed installed |

## Tool Use Boundaries

- SolidWorks is the primary visual and mechanical design tool.
- Abaqus is used for two focused load cases, not full product certification.
- Proteus supports electronics packaging and signal/power architecture, not final PCB release.
- Keil supports firmware structure and embedded C evidence, not a complete production firmware unless hardware is later defined.

## Next Tool Actions

1. Build SolidWorks enclosure assembly and exploded view.
2. Add Proteus schematic placeholder matching enclosure PCB/battery layout.
3. Add Keil/embedded C project skeleton once MCU choice is fixed.
4. Add FEA only after strap mount and boss geometry exist.
