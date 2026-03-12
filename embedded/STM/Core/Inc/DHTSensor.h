#ifndef DHT_SENSOR_H
#define DHT_SENSOR_H

#include "main.h"

void initDHTSensor(void);
uint8_t readDHT22(float *temp, float *hum);

#endif // DHT_SENSOR_H
