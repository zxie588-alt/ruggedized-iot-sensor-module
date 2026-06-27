# SolidWorks CAD Folder

CAD V1 generated on 2026-06-27 using SolidWorks 2018 COM automation.

Native files:

- `iot_lower_enclosure_v1.SLDPRT` - lower enclosure concept with bottom plate, side walls, corner screw bosses and PCB standoffs.
- `iot_lid_v1.SLDPRT` - upper lid concept with sensor/membrane boss, screw pads and internal alignment lip intent.
- `iot_gasket_v1.SLDPRT` - simplified gasket path placeholder.
- `iot_pcb_populated_placeholder_v1.SLDPRT` - PCB envelope with component keep-out placeholders.
- `iot_battery_placeholder_v1.SLDPRT` - battery pack envelope.
- `iot_sensor_module_exploded_v1.SLDASM` - exploded assembly showing package stack-up.

Neutral exports are stored in `exports/`, and the rendered exploded view is stored in `images/iot_sensor_module_exploded_v1.png`.

Rebuild command from the repository root:

```powershell
cscript //nologo scripts\build_solidworks_enclosure_v1.vbs
```

Notes:

- The script uses `C:\sw_iot_build` as an ASCII SolidWorks build cache because SolidWorks 2018 automation is unreliable when opening components from this user's Chinese-character project path.
- The cache is only a build helper; source CAD files are saved back into this folder.
- Current CAD is concept geometry for portfolio evidence and design development. It still needs refined fillets, actual screw holes, gasket groove detailing, material assignment, drawing sheets and FEA-ready cleanup.
