#include "Arduino.h"
#include <Wire.h>
#include <stdlib.h>
#include <OneWire.h>
#include <DallasTemperature.h>
void primtTemp_large(float temp);
void bigDigit(int col, int digit);
void enableBigDigits();
void moveCursorTo(int col, int row);
void clearLCD();
void convertAddress(DeviceAddress deviceAddress, char* addrAsString);
void checkKnownSensors();
void getSensorName(int deviceNumber, char* name);
