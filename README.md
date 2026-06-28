# Ruggedized Outdoor IoT Sensor Module

Portfolio engineering project in development: a rugged outdoor IoT sensor module for agricultural or industrial field monitoring. The project is structured to demonstrate mechanical product design, SolidWorks CAD, DFM, reliability thinking, test-rig design, FEA, electronics architecture, firmware planning and clear evidence boundaries.

## Project Intent

The goal is not to claim a certified commercial product. The goal is to show a realistic product-engineering workflow:

- Define use case, stakeholders and engineering requirements.
- Design a rugged enclosure with gasket, screw bosses, ribs, PCB/battery placeholders, sealed port and strap mount.
- Build test-rig concepts for strap pull, drop orientation, spray exposure and thermal logging.
- Run preliminary FEA for strap mount, enclosure corner loading and screw-boss clamp compression.
- Create electronics architecture in Proteus and firmware plan in Keil / embedded C.
- Package evidence into drawings, BOM, DFMEA, test plan and portfolio page.

## Target Employers / Role Fit

- Hardware product companies: enclosure design, DFM, jigs, fixtures, test equipment and validation.
- Manufacturing engineering roles: BOM, assembly sequence, process risks and inspection points.
- Aerospace / high-rigor mechanical roles: requirements, FEA, DFMEA, test matrix and evidence register.
- Building-services roles: secondary fit through systems thinking and validation discipline.

## Repository Structure

- `cad/solidworks/` - native SolidWorks models and drawing files.
- `exports/` - STEP/STL neutral CAD exports.
- `drawings/` - 2D drawing sheets and manufacturing/fixture layouts.
- `electronics/proteus/` - Proteus schematic/model files and electronics architecture notes.
- `firmware/keil/` - Keil MDK/uVision concept target and firmware plan.
- `firmware/embedded_c/` - portable embedded C skeletons if Keil project export is not available.
- `fea/abaqus/` - Abaqus model files, load case notes and result exports.
- `docs/` - requirements, DFMEA, test plan, DFM note and evidence register.
- `bom/` - preliminary bill of materials and cost estimates.
- `images/` - portfolio diagrams and render outputs.
- `data/` - future measured or simulated validation data.

## Current Status

Step 2 completed with working SolidWorks CAD V1 and detailed CAD V2:

- 5 native SolidWorks part files: lower enclosure, upper lid, gasket, populated PCB placeholder and battery placeholder.
- 1 native SolidWorks exploded assembly showing enclosure stack-up and internal packaging intent.
- V2 SolidWorks model set with screw boss rings, gasket groove intent, lid compression rib, strap-mount lugs, service/debug port, cable-gland ring, battery restraint and more detailed PCB/battery envelopes.
- STEP/STL exports for the individual parts, plus assembly STEP exports.
- Rendered V1/V2 exploded-view images for the portfolio page.
- Reproducible SolidWorks automation scripts in `scripts/`.

The current CAD establishes package size, component stack-up, screw boss locations, gasket/lip intent, service access, strap mounting and assembly direction. It is still a portfolio concept model, not a production enclosure.

Step 3 completed three Abaqus concept load cases:

- Strap-mount lug static pull model in Abaqus 2025.
- 150 N total pull load split across two rear lug holes.
- PC-ABS concept material, C3D10 solid mesh and simplified support boundary.
- Result summary: 1.57 MPa max von Mises stress, 0.010 mm max displacement, concept yield ratio 25.47.
- Outputs include `.cae`, `.inp`, `.odb`, contour plots, CSV/JSON summary and a short FEA report.
- Enclosure corner-load equivalent static model in Abaqus 2025.
- 120 N downward load applied to one outer corner patch with four screw-line support regions.
- Result summary: 5.55 MPa max von Mises stress, 0.021 mm max displacement, concept yield ratio 7.21.
- Outputs include `.cae`, `.inp`, `.odb`, contour plots, CSV/JSON summary and a short FEA report.
- Screw-boss compression model in Abaqus 2025.
- 90 N equivalent screw clamp load applied to an axisymmetric local boss and plate surrogate.
- Result summary: 1.20 MPa max von Mises stress, 0.005 mm max displacement, concept yield ratio 33.36.
- Outputs include `.cae`, `.inp`, `.odb`, contour plots, CSV/JSON summary and a short FEA report.

Step 4 started with electronics and firmware architecture:

- Proteus electronics architecture note and concept signal table.
- Proteus-ready schematic evidence package with component candidates, connection-level netlist, power budget, firmware-aligned pin map, review checklist and SVG schematic.
- Native Proteus 8.13 `.pdsprj` project container added and verified with `ROOT.DSN`, `ROOT.CDB`, `PROJECT.XML`, manifest and verification report.
- Keil/uVision ARMCM3 concept target using the local `UV4.exe` uVision launcher.
- Startup assembly, linker scatter file and ARM Compiler 6 project settings added for a reproducible target build.
- ARMCLANG source compile and uVision command-line target build verified.
- uVision build result: 0 errors, 0 warnings; program size Code 500 bytes, RO-data 80 bytes, RW-data 0 bytes, ZI-data 1024 bytes.
- State machine, mock sensor/power drivers, board pin map and firmware architecture notes.
- Portfolio diagrams connecting electronics blocks, firmware states and mechanical package constraints.

Step 5 completed a concept engineering release package:

- Drawing register and two concept drawing sheets.
- Drawing control plan with DWG-003 inspection-control sheet and CTQ inspection characteristics table.
- V2 concept BOM.
- DFM checklist.
- Assembly work instruction.
- Verification and validation matrix.
- Engineering release package note with explicit evidence boundary.

Step 6 completed a thermal exposure concept model:

- Lumped thermal RC model for a sealed outdoor enclosure under warm ambient and solar/lamp heat input.
- 240 minute simulated exposure with electronics baseline and transmit-boundary power pulses.
- Result summary: 66.6 C peak internal temperature under the selected conservative heat-input assumption, exceeding the 55 C warning reference.
- Outputs include CSV data, JSON summary, SVG plot, a short report and a reproducible Python script.
- The result is treated as a design risk flag, not as measured thermal performance.

## Evidence Boundary

Current project content includes planning documents, SolidWorks concept CAD V1/V2, three Abaqus concept FEA load cases, Proteus-ready electronics/firmware architecture evidence, a verified native Proteus `.pdsprj` project container, a clean Keil/uVision ARMCM3 concept target build, thermal exposure simulation, concept drawing-control evidence and a concept engineering release package. Do not claim physical testing, IP rating, production readiness, final PCB design, flashed firmware, fully populated native Proteus schematic capture, supplier-approved production drawings or certified compliance until those are actually completed. Remaining high-value targets are populated native Proteus schematic capture with ERC export, final product MCU/device-pack binding, supplier-reviewed production drawings and physical prototype testing.
