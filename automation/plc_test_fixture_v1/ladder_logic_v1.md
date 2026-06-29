# Ladder Logic Concept V1

This file describes the PLC ladder logic in a vendor-neutral way. The matching structured-text implementation is in `iec61131/st_sensor_fixture_controller.st`.

## Network 1 - Master Safety Permissive

`MASTER_OK = E_STOP_OK AND DOOR_CLOSED AND NOT LEAK_SENSOR AND NOT TEMP_HIGH`

Purpose: all hazardous outputs require the master permissive.

## Network 2 - Start Latch

Start request is accepted only when:

- `MASTER_OK`
- `DUT_PRESENT`
- `CLAMP_CLOSED`
- `LOGGER_READY`
- no active fault

The accepted start transitions the sequence from `IDLE` to `PRECHECK`.

## Network 3 - Precheck

Outputs:

- `DUT_POWER = TRUE`
- `LOGGER_TRIGGER` pulses once at step entry

Exit when the short precheck timer is complete.

## Network 4 - Spray Exposure

Outputs:

- `PUMP_ENABLE = MASTER_OK`
- `DUT_POWER = TRUE`

Exit when spray timer reaches `SPRAY_TIME_SP`.

Faults:

- leak sensor
- E-stop chain loss
- door opened
- clamp lost

## Network 5 - Thermal Exposure

Outputs:

- `LAMP_ENABLE = MASTER_OK`
- `DUT_POWER = TRUE`
- `LOGGER_TRIGGER` pulses once at step entry

Exit when thermal timer reaches `THERMAL_TIME_SP`.

Faults:

- over-temperature
- E-stop chain loss
- door opened
- clamp lost

## Network 6 - Cooldown

Outputs:

- `VENT_FAN = TRUE`
- `DUT_POWER = TRUE`

Exit when cooldown timer reaches `COOLDOWN_TIME_SP`.

## Network 7 - Complete

Outputs:

- `PASS_LIGHT = TRUE`
- one logger trigger pulse to mark test end

Operator reset returns the fixture to idle.

## Network 8 - Fault

Any active fault forces:

- `PUMP_ENABLE = FALSE`
- `LAMP_ENABLE = FALSE`
- `DUT_POWER = FALSE`
- `FAIL_LIGHT = TRUE`
- `BUZZER = pulsed`

Fault reset is accepted only when safety inputs are restored.
