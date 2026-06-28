# Native Proteus Capture V1

This folder contains a native Proteus 8.13 project container created locally for the ruggedized outdoor IoT sensor module.

## Included Files

- `ruggedized_iot_sensor_module_v1.pdsprj` - native Proteus project container.
- `proteus_native_project_manifest_v1.json` - generated container verification manifest.
- `proteus_native_project_verification_v1.md` - human-readable verification note.

## Evidence Meaning

The `.pdsprj` file is a real Proteus project archive with `PROJECT.XML`, `ROOT.DSN`, `ROOT.CDB` and script data entries. This is useful evidence that the electronics package has been moved from pure documentation toward native Proteus tooling.

## Boundary

This file should not be described as a completed native schematic capture. The detailed schematic intent remains in `../schematic_v1/`: component selection, netlist, power budget, interface pin map, review checklist and SVG schematic. A fully populated native Proteus schematic sheet and ERC export remain future work.
