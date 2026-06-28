# Native Proteus Capture Status V1

## Local Tool Check

- Proteus 8 Professional is installed locally.
- Detected launcher: `C:\Program Files (x86)\Labcenter Electronics\Proteus 8 Professional\BIN\PDS.EXE`.
- Proteus sample projects are present under the local installation `DATA\SAMPLES` folder.

## File-Format Boundary

Proteus `.pdsprj` files are ZIP-like containers with internal project metadata and binary schematic data. Because the schematic canvas data is a proprietary binary format, this repository does not hand-write a fake `.pdsprj` file.

## Current Evidence

The current `schematic_v1/` package is the native-capture input set:

- Candidate components.
- Connection-level netlist.
- Firmware-aligned pin map.
- Power-budget assumptions.
- Review checklist.
- Schematic-level SVG drawing.

## Next Native Proteus Step

Open Proteus 8 Professional, create a new schematic project, place library parts or labelled generic symbols for the selected candidates, wire nets according to `schematic_netlist_v1.csv`, run ERC, then export the native schematic image and `.pdsprj`.
