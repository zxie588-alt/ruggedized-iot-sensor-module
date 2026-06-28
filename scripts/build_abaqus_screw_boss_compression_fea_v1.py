from abaqus import mdb, session
from abaqusConstants import *
from caeModules import *
from driverUtils import executeOnCaeStartup

import csv
import json

import mesh
import regionToolset
from odbAccess import openOdb


JOB_NAME = "iot_screw_boss_compression_v1"
MODEL_NAME = "screw_boss_compression_v1"
PART_NAME = "screw_boss_axisymmetric_surrogate"

# Axisymmetric r-z model. Units: mm, N, MPa.
PLATE_RADIUS_MM = 18.0
PLATE_THICKNESS_MM = 3.0
BOSS_OUTER_RADIUS_MM = 5.5
BOSS_INNER_RADIUS_MM = 1.8
BOSS_HEIGHT_MM = 8.0
TOTAL_CLAMP_LOAD_N = 90.0
MESH_SEED_MM = 0.8
SCRATCH_DIR = r"C:\abaqus_iot_fea\scratch"

# PC-ABS concept material values. These are early-design placeholders only.
ELASTIC_MODULUS_MPA = 2200.0
POISSON_RATIO = 0.37
CONCEPT_YIELD_MPA = 40.0


def main():
    executeOnCaeStartup()
    reset_mdb()
    model = mdb.Model(name=MODEL_NAME)
    if "Model-1" in mdb.models:
        del mdb.models["Model-1"]

    part = build_axisymmetric_part(model)
    assign_material(model, part)
    mesh_part(part)

    assembly = model.rootAssembly
    assembly.DatumCsysByDefault(CARTESIAN)
    instance = assembly.Instance(name=PART_NAME + "-1", part=part, dependent=ON)

    model.StaticStep(name="boss_clamp_90N", previous="Initial", nlgeom=OFF)
    load_data = apply_boundary_conditions_and_load(model, assembly, instance)
    model.fieldOutputRequests["F-Output-1"].setValues(variables=("S", "U", "RF"))

    job = mdb.Job(
        name=JOB_NAME,
        model=MODEL_NAME,
        description="Concept FEA: 90 N screw clamp compression on axisymmetric PC-ABS screw boss surrogate.",
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

    summary = postprocess_results(load_data)
    write_report(summary)
    write_summary_files(summary)


def reset_mdb():
    try:
        Mdb()
    except Exception:
        pass


def build_axisymmetric_part(model):
    sketch = model.ConstrainedSketch(name="screw_boss_rz_profile", sheetSize=80.0)
    sketch.ConstructionLine(point1=(0.0, -5.0), point2=(0.0, 20.0))
    top_z = PLATE_THICKNESS_MM + BOSS_HEIGHT_MM
    points = [
        (0.0, 0.0),
        (PLATE_RADIUS_MM, 0.0),
        (PLATE_RADIUS_MM, PLATE_THICKNESS_MM),
        (BOSS_OUTER_RADIUS_MM, PLATE_THICKNESS_MM),
        (BOSS_OUTER_RADIUS_MM, top_z),
        (BOSS_INNER_RADIUS_MM, top_z),
        (BOSS_INNER_RADIUS_MM, PLATE_THICKNESS_MM),
        (0.0, PLATE_THICKNESS_MM),
    ]
    for index, point in enumerate(points):
        next_point = points[(index + 1) % len(points)]
        sketch.Line(point1=point, point2=next_point)

    part = model.Part(name=PART_NAME, dimensionality=AXISYMMETRIC, type=DEFORMABLE_BODY)
    part.BaseShell(sketch=sketch)
    return part


def assign_material(model, part):
    material = model.Material(name="PC_ABS_concept")
    material.Elastic(table=((ELASTIC_MODULUS_MPA, POISSON_RATIO),))
    model.HomogeneousSolidSection(name="PC_ABS_section", material="PC_ABS_concept", thickness=None)
    part.SectionAssignment(region=regionToolset.Region(faces=part.faces[:]), sectionName="PC_ABS_section")


def mesh_part(part):
    part.seedPart(size=MESH_SEED_MM, deviationFactor=0.08, minSizeFactor=0.08)
    part.setMeshControls(regions=part.faces[:], elemShape=QUAD_DOMINATED, technique=FREE)
    elem_type = mesh.ElemType(elemCode=CAX4R, elemLibrary=STANDARD)
    part.setElementType(regions=(part.faces[:],), elemTypes=(elem_type,))
    part.generateMesh()


def apply_boundary_conditions_and_load(model, assembly, instance):
    bottom_edge = instance.edges.findAt(((PLATE_RADIUS_MM * 0.5, 0.0, 0.0),))
    assembly.Set(edges=bottom_edge, name="FIXED_LOCAL_PLATE_BOTTOM")
    model.EncastreBC(
        name="fixed_local_plate_bottom",
        createStepName="Initial",
        region=assembly.sets["FIXED_LOCAL_PLATE_BOTTOM"],
    )

    axis_edge = instance.edges.findAt(((0.0, PLATE_THICKNESS_MM * 0.5, 0.0),))
    assembly.Set(edges=axis_edge, name="AXIS_RADIAL_CONSTRAINT")
    model.DisplacementBC(
        name="axis_radial_constraint",
        createStepName="Initial",
        region=assembly.sets["AXIS_RADIAL_CONSTRAINT"],
        u1=SET,
        u2=UNSET,
        ur3=UNSET,
        amplitude=UNSET,
        distributionType=UNIFORM,
        fieldName="",
        localCsys=None,
    )

    top_z = PLATE_THICKNESS_MM + BOSS_HEIGHT_MM
    top_contact_edge = instance.edges.findAt(
        (((BOSS_OUTER_RADIUS_MM + BOSS_INNER_RADIUS_MM) * 0.5, top_z, 0.0),)
    )
    assembly.Surface(side1Edges=top_contact_edge, name="SCREW_HEAD_CONTACT_EDGE")

    contact_area_mm2 = 3.141592653589793 * (
        BOSS_OUTER_RADIUS_MM ** 2 - BOSS_INNER_RADIUS_MM ** 2
    )
    pressure_mpa = TOTAL_CLAMP_LOAD_N / contact_area_mm2
    model.Pressure(
        name="screw_clamp_pressure_90N",
        createStepName="boss_clamp_90N",
        region=assembly.surfaces["SCREW_HEAD_CONTACT_EDGE"],
        magnitude=pressure_mpa,
    )

    return {
        "contact_area_mm2": contact_area_mm2,
        "equivalent_pressure_MPa": pressure_mpa,
    }


def postprocess_results(load_data):
    odb_path = JOB_NAME + ".odb"
    odb = openOdb(path=odb_path)
    step = odb.steps["boss_clamp_90N"]
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

    summary = {
        "job_name": JOB_NAME,
        "model_name": MODEL_NAME,
        "total_clamp_load_N": TOTAL_CLAMP_LOAD_N,
        "material": "PC-ABS concept",
        "elastic_modulus_MPa": ELASTIC_MODULUS_MPA,
        "poisson_ratio": POISSON_RATIO,
        "concept_yield_MPa": CONCEPT_YIELD_MPA,
        "mesh_seed_mm": MESH_SEED_MM,
        "element_family": "CAX4R axisymmetric quadrilateral mesh",
        "max_mises_MPa": float(max_mises),
        "max_displacement_mm": float(max_disp),
        "factor_to_concept_yield": float(factor_to_concept_yield) if factor_to_concept_yield else None,
        "geometry": "Axisymmetric local plate and screw boss: 18 mm plate radius, 3 mm plate thickness, 5.5 mm boss OD, 1.8 mm pilot-hole radius, 8 mm boss height.",
        "boundary_condition": "Local plate bottom fixed, with the r=0 axis constrained radially.",
        "load_case": "90 N equivalent screw clamp load applied as pressure to the top annular boss edge.",
        "evidence_boundary": "Concept FEA only. The model screens screw boss compression risk; it does not model detailed threads, torque scatter, creep, inserts or physical pull-out testing.",
    }
    summary.update(load_data)
    return summary


def save_contour_images(odb_path):
    odb_for_session = session.openOdb(name=odb_path)
    viewport = session.Viewport(name="screw_boss_results", origin=(0, 0), width=180, height=120)
    viewport.setValues(displayedObject=odb_for_session)
    viewport.view.setValues(session.views["Front"])
    viewport.viewportAnnotationOptions.setValues(title=OFF, state=OFF)
    viewport.odbDisplay.display.setValues(plotState=(CONTOURS_ON_DEF,))
    viewport.odbDisplay.commonOptions.setValues(visibleEdges=FEATURE)
    viewport.odbDisplay.setPrimaryVariable(
        variableLabel="S",
        outputPosition=INTEGRATION_POINT,
        refinement=(INVARIANT, "Mises"),
    )
    session.printToFile(fileName="screw_boss_mises_contour_v1", format=PNG, canvasObjects=(viewport,))
    viewport.odbDisplay.setPrimaryVariable(
        variableLabel="U",
        outputPosition=NODAL,
        refinement=(INVARIANT, "Magnitude"),
    )
    session.printToFile(fileName="screw_boss_displacement_contour_v1", format=PNG, canvasObjects=(viewport,))
    odb_for_session.close()


def write_summary_files(summary):
    with open("screw_boss_fea_summary_v1.json", "w") as handle:
        json.dump(summary, handle, indent=2, sort_keys=True)
    with open("screw_boss_fea_summary_v1.csv", "w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["metric", "value", "unit"])
        writer.writerow(["total_clamp_load", summary["total_clamp_load_N"], "N"])
        writer.writerow(["equivalent_pressure", summary["equivalent_pressure_MPa"], "MPa"])
        writer.writerow(["max_mises", summary["max_mises_MPa"], "MPa"])
        writer.writerow(["max_displacement", summary["max_displacement_mm"], "mm"])
        writer.writerow(["factor_to_concept_yield", summary["factor_to_concept_yield"], "-"])


def write_report(summary):
    lines = [
        "# Screw-Boss Compression FEA - Concept Load Case V1",
        "",
        "## Purpose",
        "",
        "This Abaqus load case checks a local screw boss under an equivalent screw clamp load. The purpose is to document assembly and boss-cracking risk thinking before a physical torque or pull-out test exists.",
        "",
        "## Model Setup",
        "",
        "- Software: Abaqus 2025.",
        "- Unit system: mm, N, MPa.",
        "- Geometry: {0}".format(summary["geometry"]),
        "- Material: PC-ABS concept, E = {0:.0f} MPa, nu = {1:.2f}, concept yield reference = {2:.0f} MPa.".format(
            ELASTIC_MODULUS_MPA,
            POISSON_RATIO,
            CONCEPT_YIELD_MPA,
        ),
        "- Mesh: {0} with {1:.1f} mm seed.".format(summary["element_family"], MESH_SEED_MM),
        "- Boundary condition: {0}".format(summary["boundary_condition"]),
        "- Load: {0}".format(summary["load_case"]),
        "- Equivalent contact pressure: {0:.3f} MPa.".format(summary["equivalent_pressure_MPa"]),
        "",
        "## Results",
        "",
        "- Maximum von Mises stress: {0:.2f} MPa.".format(summary["max_mises_MPa"]),
        "- Maximum displacement magnitude: {0:.3f} mm.".format(summary["max_displacement_mm"]),
        "- Concept yield ratio: {0:.2f}.".format(summary["factor_to_concept_yield"]),
        "",
        "## Interpretation",
        "",
        "The result screens whether the current boss wall and support stiffness are in a plausible range for an early assembly clamp-load assumption. Because real screw performance depends on thread forming, torque scatter, creep, inserts and repeated service cycles, this should be treated as a design-screening result only.",
        "",
        "## Evidence Boundary",
        "",
        summary["evidence_boundary"],
        "",
        "## Generated Files",
        "",
        "- `iot_screw_boss_compression_v1.cae`",
        "- `iot_screw_boss_compression_v1.inp`",
        "- `iot_screw_boss_compression_v1.odb`",
        "- `screw_boss_mises_contour_v1.png`",
        "- `screw_boss_displacement_contour_v1.png`",
        "- `screw_boss_fea_summary_v1.csv`",
        "- `screw_boss_fea_summary_v1.json`",
    ]
    with open("screw_boss_fea_report_v1.md", "w") as handle:
        handle.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
