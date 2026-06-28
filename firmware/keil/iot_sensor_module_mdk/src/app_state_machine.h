#ifndef APP_STATE_MACHINE_H
#define APP_STATE_MACHINE_H

#include <stdint.h>

typedef enum {
    MODULE_STATE_BOOT = 0,
    MODULE_STATE_SELF_TEST,
    MODULE_STATE_SLEEP,
    MODULE_STATE_SAMPLE,
    MODULE_STATE_FILTER,
    MODULE_STATE_TRANSMIT,
    MODULE_STATE_LOW_BATTERY,
    MODULE_STATE_FAULT,
    MODULE_STATE_SERVICE
} ModuleState;

typedef struct {
    int16_t temperature_c_x10;
    uint16_t humidity_percent_x10;
    uint16_t battery_mv;
    uint8_t sensor_ok;
    uint8_t service_requested;
    uint8_t transmit_ok;
    uint8_t reserved;
} ModuleFrame;

ModuleState module_next_state(ModuleState current, const ModuleFrame *frame);
const char *module_state_name(ModuleState state);

#endif
