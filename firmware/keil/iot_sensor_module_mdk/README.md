# Keil/uVision Firmware Architecture Package

This folder is a Keil/uVision-oriented firmware evidence package for the ruggedized outdoor IoT sensor module.

Confirmed local tool:

- Keil/uVision executable: `D:\游戏专用\keil\UV4\UV4.exe`
- Note: Keil MDK 5 commonly uses `UV4.exe` as the executable name.

Current status:

- Firmware architecture and source structure created.
- uVision ARMCM3 concept target added with startup assembly, scatter file and ARM Compiler 6 configuration.
- uVision command-line build verified with `UV4.exe`: 0 errors, 0 warnings.
- Program size from the verified target build: Code 500 bytes, RO-data 80 bytes, RW-data 0 bytes, ZI-data 1024 bytes.
- Code is written as hardware-facing embedded C with explicit board abstraction and mock driver boundaries.
- No production firmware, certified radio stack or final MCU pinout is claimed.

Firmware states:

- `BOOT`
- `SELF_TEST`
- `SLEEP`
- `SAMPLE`
- `FILTER`
- `TRANSMIT`
- `LOW_BATTERY`
- `FAULT`
- `SERVICE`

Evidence boundary:

The current project demonstrates firmware architecture, state-machine design, battery/sensor fault handling, local ARMCLANG source compilation and a clean uVision ARMCM3 concept target build. It is not yet flashed to a physical board and does not claim validated low-power performance or final product MCU binding.
