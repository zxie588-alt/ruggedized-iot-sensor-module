# Keil/uVision Target Build Summary V1

Date: 2026-06-28

## Build Command

`UV4.exe -b Ruggedized_IoT_Sensor_Module.uvprojx -o keil_uv4_build_log.txt`

## Result

- Toolchain: ARM Compiler 6.14 / ARMCLANG.
- Target: `Concept_Firmware_Portable_C`.
- Device profile: generic ARMCM3 concept target.
- Build process exit code: 0.
- Build result: 0 errors, 0 warnings.
- Program size: Code 500 bytes, RO-data 80 bytes, RW-data 0 bytes, ZI-data 1024 bytes.

## Evidence Files

- `Ruggedized_IoT_Sensor_Module.uvprojx`
- `Ruggedized_IoT_Sensor_Module.sct`
- `platform/startup_armcm3.s`
- `keil_uv4_build_log.txt`
- `build_with_armclang.ps1`

## Engineering Meaning

This closes the firmware evidence gap from "source files only" to a reproducible Keil/uVision concept target build. The firmware still uses mock sensor and power-monitor drivers, but the project now has a real target definition, startup vector table, linker memory map and clean compiler/linker output.

## Boundary

This is not a final production firmware release. The project still needs final MCU selection, vendor device pack binding, real peripheral drivers, flashing, hardware-in-the-loop testing, current measurement and radio validation.
