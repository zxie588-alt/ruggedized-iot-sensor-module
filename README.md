# Ruggedized Outdoor IoT Sensor Module

Portfolio engineering project in development: a rugged outdoor IoT sensor module for agricultural or industrial field monitoring. The project is structured to demonstrate mechanical product design, SolidWorks CAD, DFM, reliability thinking, test-rig design, FEA, electronics architecture, firmware planning and clear evidence boundaries.

## Project Intent

The goal is not to claim a certified commercial product. The goal is to show a realistic product-engineering workflow:

- Define use case, stakeholders and engineering requirements.
- Design a rugged enclosure with gasket, screw bosses, ribs, PCB/battery placeholders, sealed port and strap mount.
- Build test-rig concepts for strap pull, drop orientation, spray exposure and thermal logging.
- Run preliminary FEA for strap mount and enclosure corner loading.
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
- `firmware/keil/` - Keil MDK/uVision project placeholder and firmware plan.
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

## Evidence Boundary

Current project content includes planning documents and SolidWorks concept CAD V1/V2. Do not claim physical testing, IP rating, production readiness, final PCB design or certified compliance until those are actually completed. Next technical evidence targets are drawing sheets, strap-mount/load-case FEA, Proteus electronics architecture and Keil firmware structure.
