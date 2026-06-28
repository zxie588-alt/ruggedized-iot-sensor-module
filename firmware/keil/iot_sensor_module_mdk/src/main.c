#include "app_state_machine.h"
#include "module_config.h"
#include "power_monitor.h"
#include "sensor_driver.h"

static ModuleFrame build_frame(void)
{
    SensorReading sensor = sensor_driver_read_mock();
    ModuleFrame frame;

    frame.temperature_c_x10 = sensor.temperature_c_x10;
    frame.humidity_percent_x10 = sensor.humidity_percent_x10;
    frame.battery_mv = power_monitor_battery_mv_mock();
    frame.sensor_ok = sensor.sensor_ok;
    frame.service_requested = 0U;
    frame.transmit_ok = 1U;
    frame.reserved = 0U;

    return frame;
}

int main(void)
{
    ModuleState state = MODULE_STATE_BOOT;
    ModuleFrame frame;

    sensor_driver_init();
    power_monitor_init();

    for (;;) {
        frame = build_frame();
        state = module_next_state(state, &frame);

        if (state == MODULE_STATE_FAULT) {
            break;
        }
    }

    return 0;
}
