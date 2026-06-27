# SolidWorks CAD Folder

CAD V1 and V2 generated on 2026-06-27 using SolidWorks 2018 COM automation.

Native files:

- `iot_lower_enclosure_v1.SLDPRT` - lower enclosure concept with bottom plate, side walls, corner screw bosses and PCB standoffs.
- `iot_lid_v1.SLDPRT` - upper lid concept with sensor/membrane boss, screw pads and internal alignment lip intent.
- `iot_gasket_v1.SLDPRT` - simplified gasket path placeholder.
- `iot_pcb_populated_placeholder_v1.SLDPRT` - PCB envelope with component keep-out placeholders.
- `iot_battery_placeholder_v1.SLDPRT` - battery pack envelope.
- `iot_sensor_module_exploded_v1.SLDASM` - exploded assembly showing package stack-up.

V2 native files:

- `iot_lower_enclosure_v2.SLDPRT` - detailed lower enclosure with screw boss rings, PCB standoff rings, gasket groove walls, internal ribs, battery restraint clips, rear strap-mount lugs, side service-port boss and front cable-gland ring.
- `iot_lid_v2.SLDPRT` - detailed lid with counterbored screw-pad intent, membrane clamp ring, gasket compression ribs, label recess, service-port seal pad and cable-gland clearance flat.
- `iot_gasket_v2.SLDPRT` - perimeter gasket with screw reliefs, service-port gasket run and cable-gland gasket run.
- `iot_pcb_populated_placeholder_v2.SLDPRT` - populated PCB envelope with MCU, sensor/power, connector, debug header, battery connector, antenna keep-out and mount markers.
- `iot_battery_placeholder_v2.SLDPRT` - battery envelope with two cell envelopes and retaining strap marker.
- `iot_sensor_module_exploded_v2.SLDASM` - detailed exploded assembly for portfolio display.

Neutral exports are stored in `exports/`, and rendered exploded views are stored in `images/`.

Rebuild command from the repository root:

```powershell
cscript //nologo scripts\build_solidworks_enclosure_v1.vbs
cscript //nologo scripts\build_solidworks_enclosure_v2.vbs
```

Notes:

- The script uses `C:\sw_iot_build` as an ASCII SolidWorks build cache because SolidWorks 2018 automation is unreliable when opening components from this user's Chinese-character project path.
- The cache is only a build helper; source CAD files are saved back into this folder.
- Current CAD is concept geometry for portfolio evidence and design development. V2 adds the main modelling features needed for review, but it still needs drawing sheets, tolerance notes, material assignment, FEA-ready cleanup and physical validation before any production claim.
