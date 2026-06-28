#include "power_monitor.h"

void power_monitor_init(void)
{
    /* ADC setup will be bound after MCU selection. */
}

uint16_t power_monitor_battery_mv_mock(void)
{
    return 3720U;
}
