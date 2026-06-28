#include "app_state_machine.h"
#include "module_config.h"

ModuleState module_next_state(ModuleState current, const ModuleFrame *frame)
{
    if (frame == 0) {
        return MODULE_STATE_FAULT;
    }

    if (frame->service_requested) {
        return MODULE_STATE_SERVICE;
    }

    if (frame->battery_mv <= MODULE_CRITICAL_BATTERY_MV) {
        return MODULE_STATE_FAULT;
    }

    if (frame->battery_mv <= MODULE_LOW_BATTERY_MV) {
        return MODULE_STATE_LOW_BATTERY;
    }

    if (!frame->sensor_ok) {
        return MODULE_STATE_FAULT;
    }

    switch (current) {
    case MODULE_STATE_BOOT:
        return MODULE_STATE_SELF_TEST;
    case MODULE_STATE_SELF_TEST:
        return MODULE_STATE_SLEEP;
    case MODULE_STATE_SLEEP:
        return MODULE_STATE_SAMPLE;
    case MODULE_STATE_SAMPLE:
        return MODULE_STATE_FILTER;
    case MODULE_STATE_FILTER:
        return MODULE_STATE_TRANSMIT;
    case MODULE_STATE_TRANSMIT:
        return frame->transmit_ok ? MODULE_STATE_SLEEP : MODULE_STATE_FAULT;
    case MODULE_STATE_LOW_BATTERY:
        return MODULE_STATE_SLEEP;
    case MODULE_STATE_SERVICE:
        return MODULE_STATE_SLEEP;
    case MODULE_STATE_FAULT:
    default:
        return MODULE_STATE_FAULT;
    }
}

const char *module_state_name(ModuleState state)
{
    switch (state) {
    case MODULE_STATE_BOOT:
        return "BOOT";
    case MODULE_STATE_SELF_TEST:
        return "SELF_TEST";
    case MODULE_STATE_SLEEP:
        return "SLEEP";
    case MODULE_STATE_SAMPLE:
        return "SAMPLE";
    case MODULE_STATE_FILTER:
        return "FILTER";
    case MODULE_STATE_TRANSMIT:
        return "TRANSMIT";
    case MODULE_STATE_LOW_BATTERY:
        return "LOW_BATTERY";
    case MODULE_STATE_SERVICE:
        return "SERVICE";
    case MODULE_STATE_FAULT:
    default:
        return "FAULT";
    }
}
