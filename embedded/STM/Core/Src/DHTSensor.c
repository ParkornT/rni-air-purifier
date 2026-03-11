#include "DHTSensor.h"

extern uint32_t SystemCoreClock;

// Delay function
static void dht_delay_us(uint32_t us) {
  uint32_t count = us * (SystemCoreClock / 1000000) / 4;
  while (count--) {
    __NOP();
  }
}

static void set_dht_pin_output(void) {
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  GPIO_InitStruct.Pin = DHT22_DATA_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
  HAL_GPIO_Init(DHT22_DATA_GPIO_Port, &GPIO_InitStruct);
}

static void set_dht_pin_input(void) {
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  GPIO_InitStruct.Pin = DHT22_DATA_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_PULLUP;
  HAL_GPIO_Init(DHT22_DATA_GPIO_Port, &GPIO_InitStruct);
}

void initDHTSensor(void) {
  set_dht_pin_output();
  HAL_GPIO_WritePin(DHT22_DATA_GPIO_Port, DHT22_DATA_Pin, GPIO_PIN_SET);
}

uint8_t readDHT22(float *temp, float *hum) {
  uint8_t data[5] = {0, 0, 0, 0, 0};

  // MCU Start Signal
  set_dht_pin_output();
  HAL_GPIO_WritePin(DHT22_DATA_GPIO_Port, DHT22_DATA_Pin, GPIO_PIN_RESET);
  dht_delay_us(2000); // 2ms
  HAL_GPIO_WritePin(DHT22_DATA_GPIO_Port, DHT22_DATA_Pin, GPIO_PIN_SET);
  dht_delay_us(30);
  set_dht_pin_input();

  // Wait for response
  uint32_t timeout = 10000;
  while (HAL_GPIO_ReadPin(DHT22_DATA_GPIO_Port, DHT22_DATA_Pin) ==
         GPIO_PIN_SET) {
    if (--timeout == 0)
      return 0;
  }

  timeout = 10000;
  while (HAL_GPIO_ReadPin(DHT22_DATA_GPIO_Port, DHT22_DATA_Pin) ==
         GPIO_PIN_RESET) {
    if (--timeout == 0)
      return 0;
  }

  timeout = 10000;
  while (HAL_GPIO_ReadPin(DHT22_DATA_GPIO_Port, DHT22_DATA_Pin) ==
         GPIO_PIN_SET) {
    if (--timeout == 0)
      return 0;
  }

  // Read 40 bits
  for (int i = 0; i < 40; i++) {
    timeout = 10000;
    while (HAL_GPIO_ReadPin(DHT22_DATA_GPIO_Port, DHT22_DATA_Pin) ==
           GPIO_PIN_RESET) {
      if (--timeout == 0)
        return 0;
    }

    uint32_t t = 0;
    while (HAL_GPIO_ReadPin(DHT22_DATA_GPIO_Port, DHT22_DATA_Pin) ==
           GPIO_PIN_SET) {
      t++;
      if (t > 10000)
        return 0;
    }

    if (t > 40) { // If high time is > ~40us, it's a '1' (cycle count depends on
                  // clock)
      data[i / 8] |= (1 << (7 - (i % 8)));
    }
  }

  // Check parity
  uint8_t sum = data[0] + data[1] + data[2] + data[3];
  if (data[4] == sum) {
    uint16_t hRaw = (data[0] << 8) | data[1];
    uint16_t tRaw = (data[2] << 8) | data[3];

    *hum = hRaw / 10.0;
    *temp = (tRaw & 0x7FFF) / 10.0;
    if (tRaw & 0x8000)
      *temp = -(*temp);

    return 1; // Success
  }

  return 0; // Checksum error
}
