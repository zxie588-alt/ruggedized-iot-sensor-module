# Strap-Mount Lug FEA - Concept Load Case V1

## Purpose

This Abaqus load case checks the rear strap-mount lug concept added in SolidWorks CAD V2. The goal is to create early engineering evidence for the mounting path, not to claim product certification.

## Model Setup

- Software: Abaqus 2025.
- Unit system: mm, N, MPa.
- Geometry: simplified 3D surrogate of the rear enclosure edge and two strap-mount lugs.
- Material: PC-ABS concept, E = 2200 MPa, nu = 0.37, concept yield reference = 40 MPa.
- Mesh: C3D10 tet-dominated solid mesh with 4.0 mm seed.
- Boundary condition: Lower enclosure bottom edge fixed as an early screw-line surrogate.
- Load: 150 N total strap pull in +Y direction, split between two rear lug hole reference points.

## Results

- Maximum von Mises stress: 1.57 MPa.
- Maximum displacement magnitude: 0.010 mm.
- Concept yield ratio: 25.47.

## Interpretation

The model gives a first-pass check of whether the strap lug geometry is in a plausible range before detailed CAD cleanup and physical testing. Because the fixed support and material data are simplified, the result should be used for design direction only.

## Evidence Boundary

Concept FEA only. Geometry, supports and material data are simplified; no physical validation or certified safety factor is claimed.

## Generated Files

- `iot_strap_lug_static_v1.cae`
- `iot_strap_lug_static_v1.inp`
- `iot_strap_lug_static_v1.odb`
- `strap_lug_mises_contour_v1.png`
- `strap_lug_displacement_contour_v1.png`
- `strap_lug_fea_summary_v1.csv`
- `strap_lug_fea_summary_v1.json`
