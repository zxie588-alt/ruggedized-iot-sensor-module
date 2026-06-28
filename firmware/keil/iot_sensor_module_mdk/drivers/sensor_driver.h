#ifndef SENSOR_DRIVER_H
#define SENSOR_DRIVER_H

#include <stdint.h>

typedef struct {
    int16_t temperature_c_x10;
    uint16_t humidity_percent_x10;
    uint8_t sensor_ok;
    uint8_t reserved;
} SensorReading;

void sensor_driver_init(void);
SensorReading sensor_driver_read_mock(void);

#endif
