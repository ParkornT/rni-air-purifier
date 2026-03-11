#ifndef RELAY_CONTROL_H
#define RELAY_CONTROL_H

#include "main.h"

void initRelay(void);
void turnOnRelay(void);
void turnOffRelay(void);
uint8_t toggleRelay(void);
uint8_t getRelayState(void);

#endif // RELAY_CONTROL_H
