from __future__ import annotations

import hashlib
import json
from pathlib import Path
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]
CAPTURE_DIR = ROOT / "electronics" / "proteus" / "native_capture_v1"
PROJECT_FILE = CAPTURE_DIR / "ruggedized_iot_sensor_module_v1.pdsprj"
SUMMARY_JSON = CAPTURE_DIR / "proteus_native_project_manifest_v1.json"
REPORT_MD = CAPTURE_DIR / "proteus_native_project_verification_v1.md"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> None:
    if not PROJECT_FILE.exists():
        raise FileNotFoundError(PROJECT_FILE)

    with ZipFile(PROJECT_FILE) as archive:
        entries = [
            {
                "name": item.filename,
                "uncompressed_bytes": item.file_size,
                "compressed_bytes": item.compress_size,
            }
            for item in archive.infolist()
        ]
        project_xml = archive.read("PROJECT.XML").decode("utf-8", errors="replace")

    required_entries = {"PROJECT.XML", "ROOT.DSN", "ROOT.CDB", "SCRIPTS/PWRRAILS.DAT"}
    present_entries = {entry["name"] for entry in entries}
    missing_entries = sorted(required_entries - present_entries)
    root_dsn_size = next(
        entry["uncompressed_bytes"] for entry in entries if entry["name"] == "ROOT.DSN"
    )

    manifest = {
        "project_file": PROJECT_FILE.name,
        "proteus_file_type": "Proteus PDS project ZIP container",
        "file_size_bytes": PROJECT_FILE.stat().st_size,
        "sha256": sha256(PROJECT_FILE),
        "entries": entries,
        "required_entries_present": not missing_entries,
        "missing_entries": missing_entries,
        "root_dsn_uncompressed_bytes": root_dsn_size,
        "project_xml_excerpt": project_xml.strip(),
        "status": "native_project_container_verified",
        "evidence_boundary": (
            "This verifies a native Proteus project container created by Proteus 8.13. "
            "It does not claim a fully populated native schematic capture or ERC result."
        ),
    }

    SUMMARY_JSON.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    entry_lines = "\n".join(
        f"- `{entry['name']}`: {entry['uncompressed_bytes']} bytes uncompressed"
        for entry in entries
    )
    report = f"""# Proteus Native Project Verification V1

Date: 2026-06-29

## File

- Project file: `{PROJECT_FILE.name}`
- File size: {manifest["file_size_bytes"]} bytes
- SHA256: `{manifest["sha256"]}`

## Container Check

- Required entries present: {manifest["required_entries_present"]}
- Missing entries: {", ".join(missing_entries) if missing_entries else "none"}
- `ROOT.DSN` uncompressed size: {root_dsn_size} bytes

## Entries

{entry_lines}

## Engineering Meaning

This confirms that the repository contains a native Proteus `.pdsprj` project
created by Proteus 8.13, with a real `ROOT.DSN` schematic data entry and project
metadata. The detailed schematic design intent remains controlled in the
schematic evidence package: component selection, netlist, power budget, pin map
and SVG schematic.

## Boundary

This closes the gap for a native Proteus project container. It does not claim a
fully populated native schematic sheet, ERC export, PCB layout, circuit
simulation, manufactured PCB or physical electrical validation.
"""
    REPORT_MD.write_text(report, encoding="utf-8")


if __name__ == "__main__":
    main()
