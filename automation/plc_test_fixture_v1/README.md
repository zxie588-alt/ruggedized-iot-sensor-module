# PLC Test Fixture Control Package V1

Status: concept PLC / industrial automation evidence package.

This package adds PLC evidence without forcing PLC into the product itself. The IoT sensor module does not need a PLC internally; the PLC belongs in a manufacturing or validation fixture that runs repeatable spray, thermal and service-state checks.

## Fixture Purpose

The fixture concept supports:

- Spray/pump cycle for ingress observation.
- Heat/lamp exposure enable for thermal screening.
- Door/interlock monitoring.
- Fixture clamping confirmation.
- Device-under-test power enable.
- Pass/fail stack-light output.
- Data-log trigger to the test PC or logger.

## Included Evidence

- `io_list_v1.csv` - PLC I/O allocation.
- `sequence_table_v1.csv` - step sequence for a repeatable validation cycle.
- `fault_matrix_v1.csv` - fault handling and reset logic.
- `ladder_logic_v1.md` - ladder-style control logic description.
- `hmi_screen_spec_v1.md` - HMI screen content and operator workflow.
- `iec61131/st_sensor_fixture_controller.st` - IEC 61131-3 structured-text implementation for the fixture sequence.

## Boundary

This is a concept automation package, not a downloaded PLC program. It does not claim connection to a physical Siemens/Allen-Bradley/Mitsubishi PLC, commissioned I/O or validated safety system. It demonstrates PLC-style sequence, interlock, alarm and HMI thinking for a test fixture.
