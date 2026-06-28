# Firmware Architecture

## Purpose

The firmware package shows how the ruggedized sensor module would move from low-power sleep to sampling, validation, transmission and fault handling.

## State Machine

- `BOOT`: minimal startup and watchdog setup.
- `SELF_TEST`: sensor and battery checks.
- `SLEEP`: low-power wait until sample period or service wake.
- `SAMPLE`: read environmental sensor and battery monitor.
- `FILTER`: reject impossible readings and prepare payload.
- `TRANSMIT`: send or log payload through a future radio boundary.
- `LOW_BATTERY`: reduce activity and signal degraded state.
- `FAULT`: hold fault indication until reset/service.
- `SERVICE`: debug/service mode through the sealed service port.

## Design Boundaries

- Sensor and battery drivers are mock implementations until MCU and exact parts are selected.
- Radio transmit is represented as a firmware boundary, not as a certified RF stack.
- The uVision project now builds as a generic ARMCM3 concept target; final product MCU/device-pack binding remains future work.
