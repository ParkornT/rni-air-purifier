#include "DustSensor.h"
#include <stdint.h>

extern uint32_t SystemCoreClock;

// Simple delay function using empty loops, approximate
static void delay_us(uint32_t us) {
  // A simple loop takes around 3-4 cycles
  uint32_t count = us * (SystemCoreClock / 1000000) / 4;
  while (count--) {
    __NOP();
  }
}

void initDustSensor(void) {
  // ADC and GPIO pins are initialized in main.c
}

float readDustDensity(ADC_HandleTypeDef *hadc) {
  uint32_t adcSum = 0;

  HAL_GPIO_WritePin(DUST_LED_PIN_GPIO_Port, DUST_LED_PIN_Pin,
                    GPIO_PIN_RESET); // เปิด LED
  delay_us(280);

  // วนอ่านย้ำๆ 10 รอบ
  for (int i = 0; i < 10; i++) {
    HAL_ADC_Start(hadc);                  // สั่ง ADC ทำงาน
    HAL_ADC_PollForConversion(hadc, 100); // ⭐️ เพิ่ม Timeout ตรงนี้จาก 10 เป็น 100

    // ตรวจสอบสถานะว่ามันมีข้อมูลจริงๆ ค่อยเก็บ
    if (HAL_IS_BIT_SET(HAL_ADC_GetState(hadc), HAL_ADC_STATE_REG_EOC)) {
      adcSum += HAL_ADC_GetValue(hadc);
    }
    HAL_ADC_Stop(hadc); // หยุดแล้วเดี๋ยว Start ใหม่รอบถัดไป
  }

  uint32_t adcValue = adcSum / 10; // หาค่าเฉลี่ย

  delay_us(40);
  HAL_GPIO_WritePin(DUST_LED_PIN_GPIO_Port, DUST_LED_PIN_Pin,
                    GPIO_PIN_SET); // ปิด LED
  delay_us(9680);

  // คำนวณ
  float calcVoltage = adcValue * (3.3 / 4095.0);
  float dustDensity = 170.0 * calcVoltage - 0.1;
  if (dustDensity < 0)
    dustDensity = 0.0;

  return dustDensity;
}
