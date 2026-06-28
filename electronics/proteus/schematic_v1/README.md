# Schematic Evidence Package V1

This folder turns the earlier Proteus block architecture into a schematic-level evidence package for the ruggedized outdoor IoT sensor module.

## Included Files

- `component_selection_v1.csv` - candidate parts and why they were chosen for the concept.
- `schematic_netlist_v1.csv` - connection-level net ownership for power, I2C, ADC, LEDs, SWD, service wake and radio boundary.
- `power_budget_v1.csv` - early current-budget estimate for sleep, sample and transmit states.
- `interface_pin_map_v1.csv` - MCU pin mapping aligned with the Keil/uVision firmware scaffold.
- `schematic_review_checklist_v1.md` - ERC-style review checklist and evidence boundary.
- `iot_sensor_module_schematic_v1.svg` - schematic-level visual for portfolio review.

## Design Intent

The schematic package is designed around a low-power STM32-class MCU, an I2C environmental sensor, a 2-cell Li-ion battery input, a 3.3 V regulator, battery-voltage sensing, status/fault LEDs, SWD programming, a sealed service wake input and a UART radio-module boundary.

## Proteus Boundary

Proteus 8 Professional is confirmed installed locally. This package is Proteus-ready schematic evidence, but it does not yet claim a native Proteus `.pdsprj` capture, PCB layout, simulated circuit result or manufactured PCB.
