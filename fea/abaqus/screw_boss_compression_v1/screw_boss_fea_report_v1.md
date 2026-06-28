# Screw-Boss Compression FEA - Concept Load Case V1

## Purpose

This Abaqus load case checks a local screw boss under an equivalent screw clamp load. The purpose is to document assembly and boss-cracking risk thinking before a physical torque or pull-out test exists.

## Model Setup

- Software: Abaqus 2025.
- Unit system: mm, N, MPa.
- Geometry: Axisymmetric local plate and screw boss: 18 mm plate radius, 3 mm plate thickness, 5.5 mm boss OD, 1.8 mm pilot-hole radius, 8 mm boss height.
- Material: PC-ABS concept, E = 2200 MPa, nu = 0.37, concept yield reference = 40 MPa.
- Mesh: CAX4R axisymmetric quadrilateral mesh with 0.8 mm seed.
- Boundary condition: Local plate bottom fixed, with the r=0 axis constrained radially.
- Load: 90 N equivalent screw clamp load applied as pressure to the top annular boss edge.
- Equivalent contact pressure: 1.061 MPa.

## Results

- Maximum von Mises stress: 1.20 MPa.
- Maximum displacement magnitude: 0.005 mm.
- Concept yield ratio: 33.36.

## Interpretation

The result screens whether the current boss wall and support stiffness are in a plausible range for an early assembly clamp-load assumption. Because real screw performance depends on thread forming, torque scatter, creep, inserts and repeated service cycles, this should be treated as a design-screening result only.

## Evidence Boundary

Concept FEA only. The model screens screw boss compression risk; it does not model detailed threads, torque scatter, creep, inserts or physical pull-out testing.

## Generated Files

- `iot_screw_boss_compression_v1.cae`
- `iot_screw_boss_compression_v1.inp`
- `iot_screw_boss_compression_v1.odb`
- `screw_boss_mises_contour_v1.png`
- `screw_boss_displacement_contour_v1.png`
- `screw_boss_fea_summary_v1.csv`
- `screw_boss_fea_summary_v1.json`
