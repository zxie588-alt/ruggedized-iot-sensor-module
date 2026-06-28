# Abaqus FEA Folder

## Completed Concept Load Case

### Strap-Mount Lug Static Pull - V1

Folder: `strap_lug_static_v1/`

This load case checks the rear strap-mount lug concept added in SolidWorks CAD V2.

Setup:

- Software: Abaqus 2025.
- Unit system: mm, N, MPa.
- Geometry: simplified 3D surrogate of the rear enclosure edge and two strap-mount lugs.
- Material: PC-ABS concept, E = 2200 MPa, nu = 0.37, concept yield reference = 40 MPa.
- Mesh: C3D10 tet-dominated solid mesh with 4.0 mm seed.
- Load: 150 N total strap pull in +Y direction, split between two lug-hole reference points.
- Boundary condition: lower enclosure bottom edge fixed as an early screw-line surrogate.

Results:

- Maximum von Mises stress: 1.57 MPa.
- Maximum displacement magnitude: 0.010 mm.
- Concept yield ratio: 25.47.
- Abaqus status file reports: analysis completed successfully.

Evidence boundary:

This is concept FEA only. Geometry, supports and material data are simplified; no physical validation, IP rating, certified safety factor or production readiness is claimed.

## Planned Next Load Cases

1. Enclosure corner drop equivalent static load.
2. Optional screw boss compression / torque risk check.
