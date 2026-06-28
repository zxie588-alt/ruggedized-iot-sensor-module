#include "sensor_driver.h"

void sensor_driver_init(void)
{
    /* Hardware I2C setup will be bound after MCU selection. */
}

SensorReading sensor_driver_read_mock(void)
{
    SensorReading reading;
    reading.temperature_c_x10 = 213;
    reading.humidity_percent_x10 = 645;
    reading.sensor_ok = 1U;
    return reading;
}
