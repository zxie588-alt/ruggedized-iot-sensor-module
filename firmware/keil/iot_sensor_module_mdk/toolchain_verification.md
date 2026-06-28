# Toolchain Verification

Date: 2026-06-28

Confirmed local tools:

- Keil/uVision launcher: `D:\...\keil\UV4\UV4.exe`
- ARM Compiler 6.14: `armclang.exe`
- Proteus launcher: `C:\Program Files (x86)\Labcenter Electronics\Proteus 8 Professional\BIN\PDS.EXE`

Verification performed:

- ARMCLANG source compile was run using `build_with_armclang.ps1`.
- uVision command-line target build was run using `UV4.exe -b Ruggedized_IoT_Sensor_Module.uvprojx`.
- The uVision build completed with process exit code 0.
- uVision build result: `0 Error(s), 0 Warning(s)`.
- Program size from the uVision build: Code 500 bytes, RO-data 80 bytes, RW-data 0 bytes, ZI-data 1024 bytes.
- Build log evidence: `keil_uv4_build_log.txt`.
- Files built successfully:
  - `src/main.c`
  - `src/app_state_machine.c`
  - `drivers/sensor_driver.c`
  - `drivers/power_monitor.c`
  - `platform/startup_armcm3.s`

Target notes:

- Current target: generic ARMCM3 concept target.
- Startup and vector table are provided in `platform/startup_armcm3.s`.
- Linker memory layout is provided in `Ruggedized_IoT_Sensor_Module.sct`.
- The project file records ARM Compiler 6.14 / ARMCLANG settings and on-chip ROM/RAM ranges.
- Local workstation note: the installed Keil path and Keil `TOOLS.INI` path were aligned with a non-destructive directory junction. The repository itself does not require that absolute path.

Boundary:

This verifies source-level firmware structure, local ARM compiler availability and a clean uVision ARMCM3 concept target build. It does not claim flashing, hardware-in-the-loop testing, low-power current measurement, radio-stack validation or final product MCU/device-pack configuration.
