#ifndef DUST_SENSOR_H
#define DUST_SENSOR_H

#include "main.h"

void initDustSensor(void);
float readDustDensity(ADC_HandleTypeDef *hadc);

#endif // DUST_SENSOR_H
