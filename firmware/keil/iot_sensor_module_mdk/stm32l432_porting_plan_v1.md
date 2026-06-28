# STM32L432 Candidate Porting Plan V1

Date: 2026-06-29

## Purpose

This note converts the generic Keil/ARMCM3 firmware evidence into a credible next board-specific path for the ruggedized outdoor sensor module.

The current repository still keeps the buildable target as a generic ARMCM3 concept target. That is deliberate: it avoids pretending that a final schematic, startup file, clock tree and hardware board already exist. This plan defines the exact migration path to a candidate low-power STM32L4 target.

## Candidate Target

| Item | Candidate |
| --- | --- |
| MCU | `STM32L432KCUx` |
| Family | STM32L4 low-power series |
| Package | QFN-32 |
| Flash | 256 KB |
| Keil pack | `Keil.STM32L4xx_DFP` 3.0.0 |
| Compile define | `STM32L432xx` |
| SVD | `CMSIS/SVD/STM32L4x2.svd` |
| Flash algorithm | `CMSIS/Flash/STM32L4xx_256.FLM` |

## Candidate Pin Allocation

The first-pass pin allocation is controlled in `stm32l432_candidate_pinout_v1.csv`.

Key design choices:

- I2C environmental sensor on PB6/PB7 to match a common STM32 I2C1 route.
- Battery measurement on PA0 as a simple ADC input.
- Status/fault LEDs on PA5/PA6 with explicit current-budget review before prototype.
- Radio boundary on USART1 PA9/PA10, still treated as a future module interface rather than a certified RF design.
- SWD on PA13/PA14 routed only through the sealed service/debug interface.
- PB3 service wake is useful but must be checked against SWO/JTAG debug needs before final layout.

## Porting Steps

1. Lock final schematic pinout against the enclosure, service connector and PCB edge constraints.
2. Add STM32L432 startup and system files from an approved ST/CMSIS device source.
3. Add a new Keil target named `STM32L432KCUx_Candidate`.
4. Set memory map to 0x08000000 Flash / 0x20000000 SRAM for the selected STM32L432 variant.
5. Add `STM32L432xx` compile define and STM32L4 SVD/debug metadata.
6. Replace mock board I/O with a thin board-support layer for GPIO, I2C, ADC, USART and low-power entry.
7. Rebuild in uVision and keep a separate build log for the STM32L432 candidate target.
8. Flash a prototype board and run a hardware-in-the-loop state-machine test.
9. Measure sleep, sample and transmit-boundary current and update the power budget.

## Risks To Check Before Claiming Final Binding

| Risk | Why it matters | Control action |
| --- | --- | --- |
| PB3 debug conflict | PB3 can be debug-adjacent on STM32 devices | Decide whether SWO is needed; move service wake if required |
| ADC divider leakage | Battery monitor can drain the pack in sleep | Add high-value divider and/or switched divider control |
| I2C pull-up current | Always-on pull-ups can hurt low-power mode | Confirm pull-up values and sensor power switching |
| Radio UART boot state | Some radio modules drive pins during boot | Confirm voltage, default state and sleep pins |
| Service connector sealing | Debug access can compromise enclosure integrity | Keep service routing tied to sealed-port mechanical review |

## Evidence Boundary

This is a candidate porting plan and pin allocation, not a completed MCU port. The project still does not claim:

- Final PCB routing.
- Final schematic sign-off.
- Board-specific startup/system integration.
- Completed Keil RTE target.
- Flashed hardware.
- Measured current consumption.
