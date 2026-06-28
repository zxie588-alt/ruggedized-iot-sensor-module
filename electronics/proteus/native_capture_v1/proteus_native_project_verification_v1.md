# Proteus Native Project Verification V1

Date: 2026-06-29

## File

- Project file: `ruggedized_iot_sensor_module_v1.pdsprj`
- File size: 10562 bytes
- SHA256: `b4800b9bde406fd9ee91b5728a862fd7a9458fe8bdd18b850485ca744f1ca2e5`

## Container Check

- Required entries present: True
- Missing entries: none
- `ROOT.DSN` uncompressed size: 65076 bytes

## Entries

- `SCRIPTS/PWRRAILS.DAT`: 17 bytes uncompressed
- `ROOT.CDB`: 118 bytes uncompressed
- `ROOT.DSN`: 65076 bytes uncompressed
- `PROJECT.XML`: 249 bytes uncompressed

## Engineering Meaning

This confirms that the repository contains a native Proteus `.pdsprj` project
created by Proteus 8.13, with a real `ROOT.DSN` schematic data entry and project
metadata. The detailed schematic design intent remains controlled in the
schematic evidence package: component selection, netlist, power budget, pin map
and SVG schematic.

## Boundary

This closes the gap for a native Proteus project container. It does not claim a
fully populated native schematic sheet, ERC export, PCB layout, circuit
simulation, manufactured PCB or physical electrical validation.
