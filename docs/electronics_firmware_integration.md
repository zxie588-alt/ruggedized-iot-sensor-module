# Electronics and Firmware Integration

## Purpose

This step connects the mechanical package to a plausible embedded electronics and firmware architecture. The goal is to show system-level hardware product thinking rather than only enclosure modelling.

## Electronics Architecture

- Battery pack and 3V3 regulator feed MCU, sensor, debug interface and future radio boundary.
- I2C environmental sensor maps to firmware sensor driver.
- Battery divider maps to power-monitor ADC logic and low-battery state.
- Status/fault LEDs map to visible service feedback.
- SWD and service wake signals map to the sealed service/debug port in CAD V2.
- UART radio boundary is reserved for future transmit/log module selection.
- Schematic evidence V1 adds candidate components, connection-level netlist, power budget and firmware-aligned pin map.

## Firmware Architecture

- `BOOT`
- `SELF_TEST`
- `SLEEP`
- `SAMPLE`
- `FILTER`
- `TRANSMIT`
- `LOW_BATTERY`
- `FAULT`
- `SERVICE`

## Evidence Added

- Keil/uVision project scaffold.
- ARMCLANG-verifiable embedded C source structure.
- Pin map linking electronics signals to firmware ownership.
- Proteus electronics architecture note and signal table.
- Proteus-ready schematic package V1.
- Architecture diagrams for portfolio display.

## Evidence Boundary

This step does not claim a final PCB, native Proteus `.pdsprj`, physical circuit test, RF certification, measured current consumption or flashed firmware. It shows integration planning and firmware architecture readiness.
