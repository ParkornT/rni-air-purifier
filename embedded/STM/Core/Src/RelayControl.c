#include "RelayControl.h"

static uint8_t relayStatus = 0;

void initRelay(void) {
  // Pin is already configured in main.c MX_GPIO_Init()
  turnOffRelay();
}

void turnOnRelay(void) {
  HAL_GPIO_WritePin(Relay_Control_GPIO_Port, Relay_Control_Pin,
                    GPIO_PIN_RESET); // Active Low
  relayStatus = 1;
}

void turnOffRelay(void) {
  HAL_GPIO_WritePin(Relay_Control_GPIO_Port, Relay_Control_Pin,
                    GPIO_PIN_SET); // Active Low
  relayStatus = 0;
}

uint8_t toggleRelay(void) {
  if (relayStatus) {
    turnOffRelay();
  } else {
    turnOnRelay();
  }
  return relayStatus;
}

uint8_t getRelayState(void) { return relayStatus; }
