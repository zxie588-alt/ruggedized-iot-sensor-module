# Corner-Load FEA - Concept Load Case V1

## Purpose

This Abaqus load case checks a simplified enclosure corner under an equivalent static corner load. The purpose is to document early drop/handling risk thinking, not to claim dynamic drop certification.

## Model Setup

- Software: Abaqus 2025.
- Unit system: mm, N, MPa.
- Geometry: simplified 110 x 70 x 8 mm enclosure plate surrogate with four screw-line support regions.
- Material: PC-ABS concept, E = 2200 MPa, nu = 0.37, concept yield reference = 40 MPa.
- Mesh: C3D10 tet-dominated solid mesh with 5.0 mm seed.
- Boundary condition: Four screw-line support patches fixed as early fastening surrogate.
- Load: 120 N equivalent static load applied downward to one outer corner patch.

## Results

- Maximum von Mises stress: 5.55 MPa.
- Maximum displacement magnitude: 0.021 mm.
- Concept yield ratio: 7.21.

## Interpretation

The result helps identify whether the current corner and screw-line stiffness are plausible before a physical drop test. Because a real drop event is dynamic and contact-driven, this model should be treated as a conservative design-screening tool only.

## Evidence Boundary

Concept FEA only. The model is a simplified enclosure plate surrogate; it is not a dynamic drop test or certified impact result.

## Generated Files

- `iot_corner_load_static_v1.cae`
- `iot_corner_load_static_v1.inp`
- `iot_corner_load_static_v1.odb`
- `corner_load_mises_contour_v1.png`
- `corner_load_displacement_contour_v1.png`
- `corner_load_fea_summary_v1.csv`
- `corner_load_fea_summary_v1.json`
