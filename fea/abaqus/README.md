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

### Enclosure Corner Equivalent Static Load - V1

Folder: `corner_load_static_v1/`

This load case checks the enclosure corner and screw-line support concept under an equivalent static corner load.

Setup:

- Software: Abaqus 2025.
- Unit system: mm, N, MPa.
- Geometry: simplified 110 x 70 x 8 mm enclosure plate surrogate with four screw-line support regions.
- Material: PC-ABS concept, E = 2200 MPa, nu = 0.37, concept yield reference = 40 MPa.
- Mesh: C3D10 tet-dominated solid mesh with 5.0 mm seed.
- Load: 120 N equivalent static load applied downward to one outer corner patch.
- Boundary condition: four screw-line support patches fixed as an early fastening surrogate.

Results:

- Maximum von Mises stress: 5.55 MPa.
- Maximum displacement magnitude: 0.021 mm.
- Concept yield ratio: 7.21.
- Abaqus status file reports: analysis completed successfully.

Evidence boundary:

This is concept FEA only. The model is a simplified enclosure plate surrogate; it is not a dynamic drop test, certified impact result or physical validation result.

## Planned Next Load Cases

1. Optional screw boss compression / torque risk check.
2. Optional gasket compression contact check.
