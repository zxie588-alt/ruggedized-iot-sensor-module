# Proteus Electronics Architecture

## Confirmed Local Tool

- Proteus launcher: `C:\Program Files (x86)\Labcenter Electronics\Proteus 8 Professional\BIN\PDS.EXE`

## Concept Blocks

- MCU: low-power ARM Cortex-M class placeholder.
- Sensor: I2C environmental sensor placeholder.
- Power: 2-cell Li-ion pack, regulator, battery divider and reverse/ESD protection placeholder.
- Debug/service: SWD header and sealed service wake input.
- User indication: status LED and fault LED.
- Communication: UART radio boundary for future module selection.

## Schematic Evidence Package V1

Folder: `schematic_v1/`

- Candidate component table for MCU, I2C sensor, battery input, regulator, protection, LEDs, SWD/service port and radio boundary.
- Connection-level netlist for `VBAT_RAW`, `VBAT_PROTECTED`, `REG_IN`, `3V3`, `GND`, `BATTERY_ADC`, I2C, LEDs, service wake, UART and SWD.
- Early power budget for sleep, self-test, sample/filter, transmit-boundary, low-battery and service modes.
- Firmware-aligned interface pin map matching the Keil/uVision ARMCM3 concept target.
- SVG schematic concept for portfolio review.

## Proteus Boundary

This folder currently documents schematic architecture, signal ownership and Proteus-ready schematic evidence. A final native `.pdsprj`, PCB layout, manufactured board and validated circuit simulation are not claimed yet.
