# Keil Device-Pack Audit V1

Date: 2026-06-29

## Purpose

This audit closes the easy-to-fake firmware evidence gap: whether the Keil project has a credible low-power MCU path, rather than only a generic ARMCM3 concept build.

## Local Keil Environment

- Keil/uVision launcher: `D:\...\keil\UV4\UV4.exe`
- Pack installer utilities found: `PackInstaller.exe`, `PackUnzip.exe`
- Pack root audited: `D:\...\keil\packs`
- Existing build evidence: `Concept_Firmware_Portable_C` target builds with 0 errors and 0 warnings using ARM Compiler 6.14 / ARMCLANG.

## Installed Packs Verified

The `.Web` folder contains many downloadable pack index files, but those were not counted as installed packs. Installed packs were counted only when a versioned folder and PDSC file existed under the vendor pack directory.

| Pack | Installed version | Evidence |
| --- | --- | --- |
| ARM.CMSIS | 5.7.0 | `ARM\CMSIS\5.7.0\ARM.CMSIS.pdsc` |
| ARM.CMSIS-Driver | 2.6.0 | `ARM\CMSIS-Driver\2.6.0\ARM.CMSIS-Driver.pdsc` |
| Keil.ARM_Compiler | 1.6.3 | `Keil\ARM_Compiler\1.6.3\Keil.ARM_Compiler.pdsc` |
| Keil.MDK-Middleware | 7.11.1 | `Keil\MDK-Middleware\7.11.1\Keil.MDK-Middleware.pdsc` |
| Keil.STM32F1xx_DFP | 1.0.5 | `Keil\STM32F1xx_DFP\1.0.5\Keil.STM32F1xx_DFP.pdsc` |
| Keil.STM32L4xx_DFP | 3.0.0 | `Keil\STM32L4xx_DFP\3.0.0\Keil.STM32L4xx_DFP.pdsc` |

## STM32L4 Pack Install Verification

- Official pack downloaded: `https://www.keil.com/pack/Keil.STM32L4xx_DFP.3.0.0.pack`
- Downloaded pack SHA256: `EC29ABFCA07C7B1B8D5F84D2517BD1B9E1523A7C79A5FAE8F40B2ACB3E2020D4`
- Installed PDSC SHA256: `5F1000A427974D3697950DE5DBFFFD9E5188F0376B7584D5B8549E72EC214878`
- CMSIS `PackChk.exe` result: 0 errors, 256 warnings.
- Warning interpretation: the pack exposes device definitions, SVD files and flash algorithms, but does not provide a ready startup/RTE component for every L4 device. That is acceptable for toolchain readiness, but not enough to claim a completed board-specific firmware port.

## Candidate MCU Binding

Candidate device selected for the next board-specific firmware target:

| Item | Candidate evidence |
| --- | --- |
| Candidate device | `STM32L432KCUx` |
| Device family | STM32L4 low-power series |
| Vendor | STMicroelectronics |
| Package evidence | QFN-32 in the PDSC device entry |
| Flash evidence | `0x00040000` bytes / 256 KB Flash in the PDSC device entry |
| Compile define | `STM32L432xx` |
| SVD file | `CMSIS/SVD/STM32L4x2.svd` |
| Flash algorithm | `CMSIS/Flash/STM32L4xx_256.FLM` |

Why this is a better candidate than the already-installed STM32F1 pack:

- The project is a sealed battery-powered outdoor sensor module, so a low-power MCU family is a better fit than selecting STM32F1 only because that pack was already installed.
- QFN-32 aligns with a compact PCB envelope and the current enclosure package intent.
- 256 KB Flash is a practical concept target for the current state machine, sensor driver, power monitor and future radio boundary.

## Evidence Boundary

This audit verifies low-power device-pack readiness and a plausible candidate MCU path. It does not claim:

- A final schematic pinout.
- A board-specific startup/system file.
- A completed Keil RTE configuration.
- A flashed target board.
- Hardware-in-the-loop testing.
- Measured low-power current.

## Next Exact Action

After final schematic/pinout selection, create a separate `STM32L432KCUx` Keil target with board-specific startup/system files, validate the RTE configuration, build it, then flash and run a hardware-in-the-loop state-machine test.
