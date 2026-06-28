# Keil Firmware Folder

Confirmed local tool:

- Keil/uVision launcher: `D:\...\keil\UV4\UV4.exe`
- ARM Compiler 6.14: `armclang.exe`

Current outputs:

- `iot_sensor_module_mdk/` Keil/uVision-oriented project scaffold.
- Embedded C state machine.
- Mock sensor and power-monitor drivers.
- Board pin map.
- Firmware architecture note.
- Toolchain verification note.

Boundary:

The current firmware package verifies architecture and source-level build structure. It does not claim flashed firmware, final MCU/device-pack binding, hardware-in-the-loop testing or measured low-power performance.
