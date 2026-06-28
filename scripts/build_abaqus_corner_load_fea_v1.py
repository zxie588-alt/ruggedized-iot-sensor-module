from abaqus import mdb, session
from abaqusConstants import *
from caeModules import *
from driverUtils import executeOnCaeStartup

import csv
import json

import mesh
import regionToolset
from odbAccess import openOdb


JOB_NAME = "iot_corner_load_static_v1"
MODEL_NAME = "corner_load_static_v1"
PART_NAME = "corner_load_surrogate"

# Units: mm, N, MPa.
WIDTH_MM = 110.0
HEIGHT_MM = 70.0
THICKNESS_MM = 8.0
SCREW_X_MM = 42.0
SCREW_Y_MM = 22.0
SCREW_PATCH_HALF_MM = 5.0
CORNER_PATCH_MM = 12.0
TOTAL_CORNER_LOAD_N = 120.0
MESH_SEED_MM = 5.0
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

    part = build_part(model)
    assign_material(model, part)
    mesh_part(part)

    assembly = model.rootAssembly
    assembly.DatumCsysByDefault(CARTESIAN)
    instance = assembly.Instance(name=PART_NAME + "-1", part=part, dependent=ON)

    model.StaticStep(name="corner_load_120N", previous="Initial", nlgeom=OFF)
    node_counts = apply_boundary_conditions_and_load(model, assembly, instance)
    model.fieldOutputRequests["F-Output-1"].setValues(variables=("S", "U", "RF"))

    job = mdb.Job(
        name=JOB_NAME,
        model=MODEL_NAME,
        description="Concept FEA: 120 N equivalent static corner load on enclosure plate surrogate.",
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

    summary = postprocess_results(node_counts)
    write_report(summary)
    write_summary_files(summary)


def reset_mdb():
    try:
        Mdb()
    except Exception:
        pass


def build_part(model):
    sketch = model.ConstrainedSketch(name="corner_plate_profile", sheetSize=180.0)
    half_w = WIDTH_MM / 2.0
    half_h = HEIGHT_MM / 2.0
    sketch.rectangle(point1=(-half_w, -half_h), point2=(half_w, half_h))

    # Boss/fastener hole markers in the surrogate. These are not detailed CAD
    # holes; they help communicate where screw-line support exists.
    for x in (-SCREW_X_MM, SCREW_X_MM):
        for y in (-SCREW_Y_MM, SCREW_Y_MM):
            sketch.CircleByCenterPerimeter(center=(x, y), point1=(x + 1.8, y))

    part = model.Part(name=PART_NAME, dimensionality=THREE_D, type=DEFORMABLE_BODY)
    part.BaseSolidExtrude(sketch=sketch, depth=THICKNESS_MM)
    return part


def assign_material(model, part):
    material = model.Material(name="PC_ABS_concept")
    material.Elastic(table=((ELASTIC_MODULUS_MPA, POISSON_RATIO),))
    model.HomogeneousSolidSection(name="PC_ABS_section", material="PC_ABS_concept", thickness=None)
    part.SectionAssignment(region=regionToolset.Region(cells=part.cells[:]), sectionName="PC_ABS_section")


def mesh_part(part):
    part.seedPart(size=MESH_SEED_MM, deviationFactor=0.08, minSizeFactor=0.08)
    part.setMeshControls(regions=part.cells[:], elemShape=TET, technique=FREE)
    elem_type = mesh.ElemType(elemCode=C3D10, elemLibrary=STANDARD)
    part.setElementType(regions=(part.cells[:],), elemTypes=(elem_type,))
    part.generateMesh()


def apply_boundary_conditions_and_load(model, assembly, instance):
    fixed_nodes_by_label = {}
    for x in (-SCREW_X_MM, SCREW_X_MM):
        for y in (-SCREW_Y_MM, SCREW_Y_MM):
            nodes = instance.nodes.getByBoundingBox(
                xMin=x - SCREW_PATCH_HALF_MM,
                xMax=x + SCREW_PATCH_HALF_MM,
                yMin=y - SCREW_PATCH_HALF_MM,
                yMax=y + SCREW_PATCH_HALF_MM,
                zMin=-0.1,
                zMax=THICKNESS_MM + 0.1,
            )
            for node in nodes:
                fixed_nodes_by_label[node.label] = node

    fixed_labels = tuple(sorted(fixed_nodes_by_label))
    if not fixed_labels:
        raise RuntimeError("No screw support nodes were selected.")

    fixed_nodes_all = instance.nodes.sequenceFromLabels(fixed_labels)
    assembly.Set(nodes=fixed_nodes_all, name="SCREW_LINE_SUPPORT_NODES")
    model.EncastreBC(
        name="screw_line_support_surrogate",
        createStepName="Initial",
        region=assembly.sets["SCREW_LINE_SUPPORT_NODES"],
    )

    corner_nodes = instance.nodes.getByBoundingBox(
        xMin=-WIDTH_MM / 2.0 - 0.1,
        xMax=-WIDTH_MM / 2.0 + CORNER_PATCH_MM,
        yMin=-HEIGHT_MM / 2.0 - 0.1,
        yMax=-HEIGHT_MM / 2.0 + CORNER_PATCH_MM,
        zMin=THICKNESS_MM - 0.2,
        zMax=THICKNESS_MM + 0.2,
    )
    if not corner_nodes:
        raise RuntimeError("No corner load nodes were selected.")

    corner_labels = tuple(node.label for node in corner_nodes)
    corner_nodes = instance.nodes.sequenceFromLabels(corner_labels)
    assembly.Set(nodes=corner_nodes, name="CORNER_IMPACT_PATCH_NODES")
    load_per_node = -TOTAL_CORNER_LOAD_N / float(len(corner_nodes))
    model.ConcentratedForce(
        name="corner_equivalent_static_load",
        createStepName="corner_load_120N",
        region=assembly.sets["CORNER_IMPACT_PATCH_NODES"],
        cf3=load_per_node,
    )

    return {
        "fixed_node_count": len(fixed_nodes_all),
        "corner_load_node_count": len(corner_nodes),
        "load_per_corner_node_N": load_per_node,
    }


def postprocess_results(node_counts):
    odb_path = JOB_NAME + ".odb"
    odb = openOdb(path=odb_path)
    step = odb.steps["corner_load_120N"]
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
        "total_corner_load_N": TOTAL_CORNER_LOAD_N,
        "material": "PC-ABS concept",
        "elastic_modulus_MPa": ELASTIC_MODULUS_MPA,
        "poisson_ratio": POISSON_RATIO,
        "concept_yield_MPa": CONCEPT_YIELD_MPA,
        "mesh_seed_mm": MESH_SEED_MM,
        "element_family": "C3D10 tet-dominated solid mesh",
        "max_mises_MPa": float(max_mises),
        "max_displacement_mm": float(max_disp),
        "factor_to_concept_yield": float(factor_to_concept_yield) if factor_to_concept_yield else None,
        "boundary_condition": "Four screw-line support patches fixed as early fastening surrogate.",
        "load_case": "120 N equivalent static load applied downward to one outer corner patch.",
        "evidence_boundary": "Concept FEA only. The model is a simplified enclosure plate surrogate; it is not a dynamic drop test or certified impact result.",
    }
    summary.update(node_counts)
    return summary


def save_contour_images(odb_path):
    odb_for_session = session.openOdb(name=odb_path)
    viewport = session.Viewport(name="corner_load_results", origin=(0, 0), width=180, height=120)
    viewport.setValues(displayedObject=odb_for_session)
    viewport.view.setValues(session.views["Iso"])
    viewport.viewportAnnotationOptions.setValues(title=OFF, state=OFF)
    viewport.odbDisplay.display.setValues(plotState=(CONTOURS_ON_DEF,))
    viewport.odbDisplay.commonOptions.setValues(visibleEdges=FEATURE)
    viewport.odbDisplay.setPrimaryVariable(
        variableLabel="S",
        outputPosition=INTEGRATION_POINT,
        refinement=(INVARIANT, "Mises"),
    )
    session.printToFile(fileName="corner_load_mises_contour_v1", format=PNG, canvasObjects=(viewport,))
    viewport.odbDisplay.setPrimaryVariable(
        variableLabel="U",
        outputPosition=NODAL,
        refinement=(INVARIANT, "Magnitude"),
    )
    session.printToFile(fileName="corner_load_displacement_contour_v1", format=PNG, canvasObjects=(viewport,))
    odb_for_session.close()


def write_summary_files(summary):
    with open("corner_load_fea_summary_v1.json", "w") as handle:
        json.dump(summary, handle, indent=2, sort_keys=True)
    with open("corner_load_fea_summary_v1.csv", "w", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["metric", "value", "unit"])
        writer.writerow(["total_corner_load", summary["total_corner_load_N"], "N"])
        writer.writerow(["max_mises", summary["max_mises_MPa"], "MPa"])
        writer.writerow(["max_displacement", summary["max_displacement_mm"], "mm"])
        writer.writerow(["factor_to_concept_yield", summary["factor_to_concept_yield"], "-"])
        writer.writerow(["corner_load_node_count", summary["corner_load_node_count"], "nodes"])


def write_report(summary):
    lines = [
        "# Corner-Load FEA - Concept Load Case V1",
        "",
        "## Purpose",
        "",
        "This Abaqus load case checks a simplified enclosure corner under an equivalent static corner load. The purpose is to document early drop/handling risk thinking, not to claim dynamic drop certification.",
        "",
        "## Model Setup",
        "",
        "- Software: Abaqus 2025.",
        "- Unit system: mm, N, MPa.",
        "- Geometry: simplified 110 x 70 x 8 mm enclosure plate surrogate with four screw-line support regions.",
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
        "The result helps identify whether the current corner and screw-line stiffness are plausible before a physical drop test. Because a real drop event is dynamic and contact-driven, this model should be treated as a conservative design-screening tool only.",
        "",
        "## Evidence Boundary",
        "",
        summary["evidence_boundary"],
        "",
        "## Generated Files",
        "",
        "- `iot_corner_load_static_v1.cae`",
        "- `iot_corner_load_static_v1.inp`",
        "- `iot_corner_load_static_v1.odb`",
        "- `corner_load_mises_contour_v1.png`",
        "- `corner_load_displacement_contour_v1.png`",
        "- `corner_load_fea_summary_v1.csv`",
        "- `corner_load_fea_summary_v1.json`",
    ]
    with open("corner_load_fea_report_v1.md", "w") as handle:
        handle.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
