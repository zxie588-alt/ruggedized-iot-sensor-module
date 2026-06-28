from abaqus import mdb, session
from abaqusConstants import *
from caeModules import *
from driverUtils import executeOnCaeStartup

import csv
import json
import math
import os
import sys

import mesh
import regionToolset
from odbAccess import openOdb


JOB_NAME = "iot_strap_lug_static_v1"
MODEL_NAME = "strap_lug_static_v1"
PART_NAME = "strap_mount_surrogate"

# Units: mm, N, MPa.
WIDTH_MM = 110.0
BODY_MIN_Y = -35.0
BODY_MAX_Y = 35.0
LUG_MAX_Y = 44.0
THICKNESS_MM = 8.0
LUG_HALF_WIDTH_MM = 9.0
LUG_CENTER_LEFT_X = -28.0
LUG_CENTER_RIGHT_X = 28.0
LUG_CENTER_Y = 40.0
LUG_HOLE_RADIUS_MM = 2.1
TOTAL_PULL_N = 150.0
LOAD_PER_LUG_N = TOTAL_PULL_N / 2.0
MESH_SEED_MM = 4.0
SCRATCH_DIR = r"C:\abaqus_iot_fea\scratch"

# PC-ABS concept material values. These are reasonable early-design values only,
# not supplier-certified material data.
ELASTIC_MODULUS_MPA = 2200.0
POISSON_RATIO = 0.37
CONCEPT_YIELD_MPA = 40.0


def main():
    executeOnCaeStartup()
    reset_mdb()
    model = mdb.Model(name=MODEL_NAME)
    if "Model-1" in mdb.models:
        del mdb.models["Model-1"]

    part = build_part(model)
    assign_material(model, part)
    mesh_part(part)
    assembly = model.rootAssembly
    assembly.DatumCsysByDefault(CARTESIAN)
    instance = assembly.Instance(name=PART_NAME + "-1", part=part, dependent=ON)

    model.StaticStep(name="strap_pull_150N", previous="Initial", nlgeom=OFF)
    apply_boundary_conditions(model, assembly, instance)
    add_history_outputs(model)

    job = mdb.Job(
        name=JOB_NAME,
        model=MODEL_NAME,
        description="Concept FEA: 150 N strap pull on two rear mounting lugs of the ruggedized IoT sensor module.",
        memory=90,
        memoryUnits=PERCENTAGE,
        numCpus=4,
        numDomains=4,
        scratch=SCRATCH_DIR,
    )
    job.writeInput(consistencyChecking=OFF)
    mdb.saveAs(pathName=JOB_NAME + ".cae")
    job.submit(consistencyChecking=OFF)
    job.waitForCompletion()

    summary = postprocess_results()
    write_report(summary)
    write_summary_files(summary)


def reset_mdb():
    try:
        Mdb()
    except Exception:
        pass


def build_part(model):
    sketch = model.ConstrainedSketch(name="strap_lug_profile", sheetSize=220.0)
    points = [
        (-55.0, BODY_MIN_Y),
        (55.0, BODY_MIN_Y),
        (55.0, BODY_MAX_Y),
        (37.0, BODY_MAX_Y),
        (37.0, LUG_MAX_Y),
        (19.0, LUG_MAX_Y),
        (19.0, BODY_MAX_Y),
        (-19.0, BODY_MAX_Y),
        (-19.0, LUG_MAX_Y),
        (-37.0, LUG_MAX_Y),
        (-37.0, BODY_MAX_Y),
        (-55.0, BODY_MAX_Y),
    ]
    for idx, point in enumerate(points):
        next_point = points[(idx + 1) % len(points)]
        sketch.Line(point1=point, point2=next_point)

    sketch.CircleByCenterPerimeter(
        center=(LUG_CENTER_LEFT_X, LUG_CENTER_Y),
        point1=(LUG_CENTER_LEFT_X + LUG_HOLE_RADIUS_MM, LUG_CENTER_Y),
    )
    sketch.CircleByCenterPerimeter(
        center=(LUG_CENTER_RIGHT_X, LUG_CENTER_Y),
        point1=(LUG_CENTER_RIGHT_X + LUG_HOLE_RADIUS_MM, LUG_CENTER_Y),
    )

    part = model.Part(name=PART_NAME, dimensionality=THREE_D, type=DEFORMABLE_BODY)
    part.BaseSolidExtrude(sketch=sketch, depth=THICKNESS_MM)
    return part


def assign_material(model, part):
    material = model.Material(name="PC_ABS_concept")
    material.Elastic(table=((ELASTIC_MODULUS_MPA, POISSON_RATIO),))
    model.HomogeneousSolidSection(name="PC_ABS_section", material="PC_ABS_concept", thickness=None)
    cells = part.cells[:]
    part.SectionAssignment(region=regionToolset.Region(cells=cells), sectionName="PC_ABS_section")


def mesh_part(part):
    part.seedPart(size=MESH_SEED_MM, deviationFactor=0.08, minSizeFactor=0.08)
    part.setMeshControls(regions=part.cells[:], elemShape=TET, technique=FREE)
    elem_type_1 = mesh.ElemType(elemCode=C3D10, elemLibrary=STANDARD)
    part.setElementType(regions=(part.cells[:],), elemTypes=(elem_type_1,))
    part.generateMesh()


def apply_boundary_conditions(model, assembly, instance):
    fixed_face = instance.faces.findAt(((0.0, BODY_MIN_Y, THICKNESS_MM / 2.0),))
    assembly.Set(faces=fixed_face, name="FIXED_LOWER_EDGE_SURROGATE")
    model.EncastreBC(
        name="fixed_lower_edge_surrogate",
        createStepName="Initial",
        region=assembly.sets["FIXED_LOWER_EDGE_SURROGATE"],
    )

    left_hole_face = instance.faces.findAt(((LUG_CENTER_LEFT_X, LUG_CENTER_Y + LUG_HOLE_RADIUS_MM, THICKNESS_MM / 2.0),))
    right_hole_face = instance.faces.findAt(((LUG_CENTER_RIGHT_X, LUG_CENTER_Y + LUG_HOLE_RADIUS_MM, THICKNESS_MM / 2.0),))
    assembly.Surface(side1Faces=left_hole_face, name="LEFT_STRAP_HOLE_SURFACE")
    assembly.Surface(side1Faces=right_hole_face, name="RIGHT_STRAP_HOLE_SURFACE")

    left_rp_region = create_reference_point_region(
        assembly,
        point=(LUG_CENTER_LEFT_X, LUG_CENTER_Y, THICKNESS_MM / 2.0),
        name="LEFT_LOAD_RP",
    )
    right_rp_region = create_reference_point_region(
        assembly,
        point=(LUG_CENTER_RIGHT_X, LUG_CENTER_Y, THICKNESS_MM / 2.0),
        name="RIGHT_LOAD_RP",
    )

    model.Coupling(
        name="left_hole_kinematic_coupling",
        controlPoint=left_rp_region,
        surface=assembly.surfaces["LEFT_STRAP_HOLE_SURFACE"],
        influenceRadius=WHOLE_SURFACE,
        couplingType=KINEMATIC,
        localCsys=None,
        u1=ON,
        u2=ON,
        u3=ON,
        ur1=ON,
        ur2=ON,
        ur3=ON,
    )
    model.Coupling(
        name="right_hole_kinematic_coupling",
        controlPoint=right_rp_region,
        surface=assembly.surfaces["RIGHT_STRAP_HOLE_SURFACE"],
        influenceRadius=WHOLE_SURFACE,
        couplingType=KINEMATIC,
        localCsys=None,
        u1=ON,
        u2=ON,
        u3=ON,
        ur1=ON,
        ur2=ON,
        ur3=ON,
    )

    model.ConcentratedForce(
        name="left_lug_pull_75N",
        createStepName="strap_pull_150N",
        region=left_rp_region,
        cf2=LOAD_PER_LUG_N,
    )
    model.ConcentratedForce(
        name="right_lug_pull_75N",
        createStepName="strap_pull_150N",
        region=right_rp_region,
        cf2=LOAD_PER_LUG_N,
    )


def create_reference_point_region(assembly, point, name):
    rp = assembly.ReferencePoint(point=point)
    rp_obj = assembly.referencePoints[rp.id]
    assembly.Set(referencePoints=(rp_obj,), name=name)
    return regionToolset.Region(referencePoints=(rp_obj,))


def add_history_outputs(model):
    model.fieldOutputRequests["F-Output-1"].setValues(variables=("S", "U", "RF"))


def postprocess_results():
    odb_path = JOB_NAME + ".odb"
    odb = openOdb(path=odb_path)
    step = odb.steps["strap_pull_150N"]
    frame = step.frames[-1]
    stress = frame.fieldOutputs["S"].getScalarField(invariant=MISES)
    displacement = frame.fieldOutputs["U"].getScalarField(invariant=MAGNITUDE)

    max_mises = max(value.data for value in stress.values)
    max_disp = max(value.data for value in displacement.values)
    factor_to_concept_yield = CONCEPT_YIELD_MPA / max_mises if max_mises > 0 else None

    save_contour_images(odb_path)
    try:
        odb.close()
    except Exception:
        pass

    return {
        "job_name": JOB_NAME,
        "model_name": MODEL_NAME,
        "total_pull_N": TOTAL_PULL_N,
        "load_per_lug_N": LOAD_PER_LUG_N,
        "material": "PC-ABS concept",
        "elastic_modulus_MPa": ELASTIC_MODULUS_MPA,
        "poisson_ratio": POISSON_RATIO,
        "concept_yield_MPa": CONCEPT_YIELD_MPA,
        "mesh_seed_mm": MESH_SEED_MM,
        "element_family": "C3D10 tet-dominated solid mesh",
        "max_mises_MPa": float(max_mises),
        "max_displacement_mm": float(max_disp),
        "factor_to_concept_yield": float(factor_to_concept_yield) if factor_to_concept_yield else None,
        "boundary_condition": "Lower enclosure bottom edge fixed as an early screw-line surrogate.",
        "load_case": "150 N total strap pull in +Y direction, split between two rear lug hole reference points.",
        "evidence_boundary": "Concept FEA only. Geometry, supports and material data are simplified; no physical validation or certified safety factor is claimed.",
    }


def save_contour_images(odb_path):
    odb_for_session = session.openOdb(name=odb_path)
    viewport = session.Viewport(name="strap_lug_results", origin=(0, 0), width=180, height=120)
    viewport.setValues(displayedObject=odb_for_session)
    viewport.view.setValues(session.views["Iso"])
    viewport.odbDisplay.display.setValues(plotState=(CONTOURS_ON_DEF,))
    viewport.odbDisplay.commonOptions.setValues(visibleEdges=FEATURE)
    viewport.odbDisplay.setPrimaryVariable(
        variableLabel="S",
        outputPosition=INTEGRATION_POINT,
        refinement=(INVARIANT, "Mises"),
    )
    session.printToFile(fileName="strap_lug_mises_contour_v1", format=PNG, canvasObjects=(viewport,))
    viewport.odbDisplay.setPrimaryVariable(
        variableLabel="U",
        outputPosition=NODAL,
        refinement=(INVARIANT, "Magnitude"),
    )
    session.printToFile(fileName="strap_lug_displacement_contour_v1", format=PNG, canvasObjects=(viewport,))
    odb_for_session.close()


def write_summary_files(summary):
    with open("strap_lug_fea_summary_v1.json", "w") as handle:
        json.dump(summary, handle, indent=2, sort_keys=True)
    with open("strap_lug_fea_summary_v1.csv", "w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["metric", "value", "unit"])
        writer.writerow(["total_pull", summary["total_pull_N"], "N"])
        writer.writerow(["load_per_lug", summary["load_per_lug_N"], "N"])
        writer.writerow(["max_mises", summary["max_mises_MPa"], "MPa"])
        writer.writerow(["max_displacement", summary["max_displacement_mm"], "mm"])
        writer.writerow(["factor_to_concept_yield", summary["factor_to_concept_yield"], "-"])


def write_report(summary):
    lines = [
        "# Strap-Mount Lug FEA - Concept Load Case V1",
        "",
        "## Purpose",
        "",
        "This Abaqus load case checks the rear strap-mount lug concept added in SolidWorks CAD V2. The goal is to create early engineering evidence for the mounting path, not to claim product certification.",
        "",
        "## Model Setup",
        "",
        "- Software: Abaqus 2025.",
        "- Unit system: mm, N, MPa.",
        "- Geometry: simplified 3D surrogate of the rear enclosure edge and two strap-mount lugs.",
        "- Material: PC-ABS concept, E = {0:.0f} MPa, nu = {1:.2f}, concept yield reference = {2:.0f} MPa.".format(
            ELASTIC_MODULUS_MPA,
            POISSON_RATIO,
            CONCEPT_YIELD_MPA,
        ),
        "- Mesh: {0} with {1:.1f} mm seed.".format(summary["element_family"], MESH_SEED_MM),
        "- Boundary condition: {0}".format(summary["boundary_condition"]),
        "- Load: {0}".format(summary["load_case"]),
        "",
        "## Results",
        "",
        "- Maximum von Mises stress: {0:.2f} MPa.".format(summary["max_mises_MPa"]),
        "- Maximum displacement magnitude: {0:.3f} mm.".format(summary["max_displacement_mm"]),
        "- Concept yield ratio: {0:.2f}.".format(summary["factor_to_concept_yield"]),
        "",
        "## Interpretation",
        "",
        "The model gives a first-pass check of whether the strap lug geometry is in a plausible range before detailed CAD cleanup and physical testing. Because the fixed support and material data are simplified, the result should be used for design direction only.",
        "",
        "## Evidence Boundary",
        "",
        summary["evidence_boundary"],
        "",
        "## Generated Files",
        "",
        "- `iot_strap_lug_static_v1.cae`",
        "- `iot_strap_lug_static_v1.inp`",
        "- `iot_strap_lug_static_v1.odb`",
        "- `strap_lug_mises_contour_v1.png`",
        "- `strap_lug_displacement_contour_v1.png`",
        "- `strap_lug_fea_summary_v1.csv`",
        "- `strap_lug_fea_summary_v1.json`",
    ]
    with open("strap_lug_fea_report_v1.md", "w") as handle:
        handle.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
