# CAD Design Log

## 2026-06-27 - SolidWorks CAD V1

Objective: create the first physical product architecture for a ruggedized outdoor IoT sensor module.

Generated CAD files:

- Lower enclosure with bottom plate, side walls, M3-style screw boss locations and PCB standoff locations.
- Upper lid with raised sensor/membrane zone, screw pad locations and internal alignment lip intent.
- Gasket placeholder showing the intended compression path between lid and lower enclosure.
- Populated PCB placeholder showing board envelope, MCU/sensor/power/connector zones and antenna keep-out marker.
- Battery placeholder for early internal package checking.
- Exploded assembly to communicate assembly sequence and internal packaging.

Engineering intent:

- Establish package envelope before detailed feature design.
- Separate enclosure, gasket, electronics and battery as different design objects rather than one undifferentiated block.
- Show early DFM thinking through wall thickness, screw bosses, component clearances and assembly direction.
- Keep the CAD honest by labelling it as concept V1 rather than an IP-rated or production-ready enclosure.

Known limitations:

- Screw holes are represented by boss/pad locations only; detailed counterbores and fastener clearances are not yet modelled.
- Gasket is represented as a simplified path; the real groove, compression ratio and tolerance stack are still pending.
- External strap mount, sealed service/debug port and cable-gland geometry are pending.
- Fillets, draft, ribs and injection-moulding details need a second modelling pass.
- No FEA or physical validation has been completed on this CAD version.

Next CAD tasks:

- Add detailed screw holes, counterbores and lid-to-base fastening logic.
- Add gasket groove geometry and a simple compression/tolerance note.
- Add external strap/lug mount and prepare it for Abaqus load-case extraction.
- Add service/debug port seal concept.
- Create drawing sheets for main dimensions, exploded assembly and BOM callouts.

## 2026-06-27 - SolidWorks CAD V2

Objective: turn the V1 package study into a more complete product-design model suitable for portfolio review.

Added CAD features:

- M3-style screw boss rings in the lower enclosure and counterbored screw-pad intent in the lid.
- PCB standoff rings and PCB mounting markers.
- Gasket groove wall intent in the lower enclosure and matching lid compression ribs.
- Rear strap-mount lugs with through-hole intent for outdoor mounting.
- Side service/debug port boss with cover plate and matching lid seal pad.
- Front cable-gland ring and lid clearance flat.
- Internal rib and battery-restraint clip features.
- More detailed PCB package model with MCU, sensor/power, connector, debug header, battery connector and antenna keep-out features.
- Battery model with two cell envelopes and retaining strap marker.
- Detailed V2 exploded assembly, STEP/STL exports and rendered portfolio image.

Design intent:

- Make the sealing path, fastening path, mounting path and service path visible in the model.
- Keep the design honest as a concept CAD package, while still showing a realistic product-engineering workflow.
- Prepare geometry for the next engineering tasks: 2D drawings, strap-mount FEA extraction and electronics/firmware integration.

Remaining engineering limits:

- Screw and gasket geometry is modelled as design intent, not validated tolerance stack-up.
- Strap lugs are ready for a preliminary load case, but no FEA has been completed yet.
- No physical IP, drop, UV, thermal or vibration testing has been completed.
- Final draft angles, mould-flow considerations and production tooling features are still outside the current evidence boundary.
