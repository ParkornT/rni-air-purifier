#include "OLEDDisplay.h"
#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <stdlib.h>

#define DEVICE_NAME "ESP32_BT"
#define SERVICE_UUID "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
#define CHARACTERISTIC_UUID_RX "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
#define CHARACTERISTIC_UUID_DUST "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
#define CHARACTERISTIC_UUID_TEMP "6e400004-b5a3-f393-e0a9-e50e24dcca9e"
#define CHARACTERISTIC_UUID_HUM "6e400005-b5a3-f393-e0a9-e50e24dcca9e"
#define CHARACTERISTIC_UUID_RESPONSE "6e400006-b5a3-f393-e0a9-e50e24dcca9e"

BLEServer *pServer = NULL;
BLECharacteristic *pDustCharacteristic;
BLECharacteristic *pTempCharacteristic;
BLECharacteristic *pHumCharacteristic;
BLECharacteristic *pResponseCharacteristic;

bool deviceConnected = false;
bool wasConnected = false; // ← Track previous state

#define DUST_INTERVAL 500
#define DHT_INTERVAL 2000

float currentDust = 0;
float currentTemp = 0;
float currentHum = 0;

// Mutex to prevent simultaneous BLE writes from different tasks
portMUX_TYPE bleMux = portMUX_INITIALIZER_UNLOCKED;

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
    Serial.println("Client connected!");
  }
  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
    Serial.println("Client disconnected. Restarting advertising...");
  }
};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String rxValue = pCharacteristic->getValue();
    if (rxValue.length() > 0) {
      Serial.print("Received: ");
      Serial.println(rxValue.c_str());

      // ตรวจสอบคำสั่งเพื่อควบคุม Relay ไปยัง STM32
      if (rxValue.indexOf("Fan Manual On") != -1) {
        Serial2.print("CMD:ON\n");
      } else if (rxValue.indexOf("Fan Manual Off") != -1) {
        Serial2.print("CMD:OFF\n");
      } else if (rxValue.indexOf("Fan Auto") != -1) {
        Serial2.print("CMD:AUTO\n");
      } else if (rxValue.indexOf("Fan Manual") != -1) {
        Serial2.print("CMD:OFF\n"); // Default behavior for just "Fan Manual"
      } else if (rxValue.indexOf("ON") != -1) {
        Serial2.print("CMD:ON\n");
      } else if (rxValue.indexOf("OFF") != -1) {
        Serial2.print("CMD:OFF\n");
      } else if (rxValue.indexOf("toggle") != -1 ||
                 rxValue.indexOf("TOGGLE") != -1) {
        Serial2.print("CMD:TOGGLE\n");
      } else if (rxValue.indexOf("Auto") != -1 ||
                 rxValue.indexOf("AUTO") != -1) {
        Serial2.print("CMD:AUTO\n");
      }
    }
  }
};

void setup() {
  Serial.begin(115200);

  // Init BLE with your device name
  BLEDevice::init(DEVICE_NAME);

  // Create BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create BLE UART Service
  BLEService *pService = pServer->createService(
      BLEUUID(SERVICE_UUID),
      100); // Increased handler count to 100 for multiple characteristics

  // TX Characteristic (ESP32 → Flutter)
  // --- Dust Characteristic ---
  pDustCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_DUST, BLECharacteristic::PROPERTY_NOTIFY);
  pDustCharacteristic->addDescriptor(new BLE2902());

  // --- Temperature Characteristic ---
  pTempCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_TEMP, BLECharacteristic::PROPERTY_NOTIFY);
  pTempCharacteristic->addDescriptor(new BLE2902());

  // --- Humidity Characteristic ---
  pHumCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_HUM, BLECharacteristic::PROPERTY_NOTIFY);
  pHumCharacteristic->addDescriptor(new BLE2902());

  // Response Characteristic (ESP32 → Flutter)
  pResponseCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_RESPONSE, BLECharacteristic::PROPERTY_NOTIFY);
  pResponseCharacteristic->addDescriptor(new BLE2902());

  // RX Characteristic (Flutter → ESP32)
  BLECharacteristic *pRxCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID_RX, BLECharacteristic::PROPERTY_WRITE);
  pRxCharacteristic->setCallbacks(new MyCallbacks());

  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pServer->getAdvertising()->start();
  Serial.println("BLE UART ready! Waiting for connections...");

  // Initialize STM32 UART (RX2 = 16, TX2 = 17)
  Serial2.begin(115200, SERIAL_8N1, 16, 17);

  // Initialize OLED Display
  initOLEDDisplay();
}

void loop() {
  unsigned long now = millis();

  // Device just disconnected — restart advertising
  if (!deviceConnected && wasConnected) {
    delay(500); // Give BLE stack time to settle
    pServer->startAdvertising();
    Serial.println("Restarting advertising...");
    wasConnected = false;
  }

  // Device just connected
  if (deviceConnected && !wasConnected) {
    wasConnected = true;
  }

  // Read data from STM32 continuously
  if (Serial2.available()) {
    String rx = Serial2.readStringUntil('\n');
    rx.trim();
    if (rx.length() > 0) {
      Serial.println("STM32: " + rx);

      // PM:35.0,T:28.5,H:60.0,R:1,M:1
      int pmIdx = rx.indexOf("PM:");
      int tIdx = rx.indexOf(",T:");
      int hIdx = rx.indexOf(",H:");
      int rIdx = rx.indexOf(",R:");
      int mIdx = rx.indexOf(",M:");

      if (pmIdx != -1 && tIdx != -1 && hIdx != -1 && rIdx != -1) {
        currentDust = rx.substring(pmIdx + 3, tIdx).toFloat();
        currentTemp = rx.substring(tIdx + 3, hIdx).toFloat();
        currentHum = rx.substring(hIdx + 3, rIdx).toFloat();

        int currentRelay;
        int currentMode = 1; // Default to Auto

        if (mIdx != -1) {
          currentRelay = rx.substring(rIdx + 3, mIdx).toInt();
          currentMode = rx.substring(mIdx + 3).toInt();
        } else {
          currentRelay = rx.substring(rIdx + 3).toInt();
        }

        // Update OLED
        updateDisplay(currentDust, currentTemp, currentHum, deviceConnected);

        // Update BLE
        if (deviceConnected) {
          pDustCharacteristic->setValue(String(currentDust).c_str());
          pDustCharacteristic->notify();

          pTempCharacteristic->setValue(String(currentTemp).c_str());
          pTempCharacteristic->notify();

          pHumCharacteristic->setValue(String(currentHum).c_str());
          pHumCharacteristic->notify();

          String rState = (currentRelay == 1) ? "Fan:ON" : "Fan:OFF";
          rState += (currentMode == 1) ? " [AUTO]" : " [MANUAL]";

          pResponseCharacteristic->setValue(rState.c_str());
          pResponseCharacteristic->notify();
        }
      }
    }
  }
}