/*
  Ruggedized Outdoor IoT Sensor Module - firmware state-machine skeleton.

  This file is intentionally hardware-neutral for Step 1. It will later be
  adapted into a Keil/uVision project after the MCU target is selected.
*/

typedef enum {
    STATE_SLEEP = 0,
    STATE_WAKE,
    STATE_READ_SENSOR,
    STATE_VALIDATE_DATA,
    STATE_TRANSMIT_OR_LOG,
    STATE_FAULT,
    STATE_SERVICE_MODE
} ModuleState;

typedef struct {
    int battery_mv;
    int temperature_c_x10;
    int humidity_percent_x10;
    int enclosure_open;
    int sensor_ok;
} SensorFrame;

static ModuleState next_state(ModuleState current, SensorFrame frame)
{
    if (!frame.sensor_ok || frame.battery_mv < 3300) {
        return STATE_FAULT;
    }

    if (frame.enclosure_open) {
        return STATE_SERVICE_MODE;
    }

    switch (current) {
    case STATE_SLEEP:
        return STATE_WAKE;
    case STATE_WAKE:
        return STATE_READ_SENSOR;
    case STATE_READ_SENSOR:
        return STATE_VALIDATE_DATA;
    case STATE_VALIDATE_DATA:
        return STATE_TRANSMIT_OR_LOG;
    case STATE_TRANSMIT_OR_LOG:
        return STATE_SLEEP;
    case STATE_FAULT:
        return STATE_SLEEP;
    case STATE_SERVICE_MODE:
        return STATE_SLEEP;
    default:
        return STATE_FAULT;
    }
}
