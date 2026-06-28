# Schematic Review Checklist V1

## Completed Concept Checks

- Power path has a named raw battery net, protected battery net, regulator input and regulated 3V3 rail.
- Battery ADC divider keeps 8.4 V maximum 2-cell input below the MCU ADC range.
- I2C sensor bus has explicit SCL/SDA ownership and pull-up resistors.
- Status and fault LED nets map to firmware states.
- SWD debug nets map to the sealed service/debug port in CAD V2.
- UART radio nets are intentionally marked as a reserved boundary, not a selected RF design.
- Power budget separates sleep, self-test, sample/filter, transmit-boundary, low-battery and service modes.
- Mechanical links are noted for battery pocket, sensor membrane opening, service port and antenna keep-out.

## Checks For Native Proteus Capture

- Replace class-level MCU candidate with a Proteus library part or explicit generic MCU symbol.
- Place regulator/protection circuit as either real Proteus parts or a labelled functional block.
- Run ERC after native capture and record warnings.
- Export schematic image from Proteus for side-by-side comparison with `iot_sensor_module_schematic_v1.svg`.
- Keep PCB layout and manufacturing output out of scope until mechanical PCB outline and final component packages are selected.

## Evidence Boundary

This is schematic-level concept evidence. It should be described as a Proteus-ready electronics package, not as a final Proteus `.pdsprj`, final PCB, RF design, battery safety design or physically validated circuit.
