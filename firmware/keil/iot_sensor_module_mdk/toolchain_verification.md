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
- Device-pack audit was performed and documented in `device_pack_audit_v1.md`.
- `Keil.STM32L4xx_DFP` 3.0.0 was installed locally and checked with CMSIS `PackChk.exe`: 0 errors, 256 warnings.
- `STM32L432KCUx` was selected as the next low-power candidate MCU path, but not yet claimed as a final board-specific firmware target.
- Candidate pin allocation and porting sequence are documented in `stm32l432_candidate_pinout_v1.csv` and `stm32l432_porting_plan_v1.md`.
- Files built successfully:
  - `src/main.c`
  - `src/app_state_machine.c`
  - `drivers/sensor_driver.c`
  - `drivers/power_monitor.c`
  - `platform/startup_armcm3.s`

Target notes:

- Current target: generic ARMCM3 concept target.
- Low-power candidate path: STM32L4 series, candidate device `STM32L432KCUx`.
- Startup and vector table are provided in `platform/startup_armcm3.s`.
- Linker memory layout is provided in `Ruggedized_IoT_Sensor_Module.sct`.
- The project file records ARM Compiler 6.14 / ARMCLANG settings and on-chip ROM/RAM ranges.
- Local workstation note: the installed Keil path and Keil `TOOLS.INI` path were aligned with a non-destructive directory junction. The repository itself does not require that absolute path.

Boundary:

This verifies source-level firmware structure, local ARM compiler availability, a clean uVision ARMCM3 concept target build and low-power STM32L4 device-pack readiness. It does not claim flashing, hardware-in-the-loop testing, low-power current measurement, radio-stack validation, final schematic pinout or completed board-specific MCU/RTE/startup binding.
