#include <avr/power.h>
#include <Adafruit_NeoPixel.h>
#include <TrinketFakeUsbSerial.h>
#include <TrinketFakeUsbSerialC.h>

#define PIXELS_COUNT 32
#define NEOPIXEL_PIN  0

#define BUFFER_SIZE  4
#define CONTROL_PIN  1

Adafruit_NeoPixel strip = Adafruit_NeoPixel(PIXELS_COUNT, NEOPIXEL_PIN, NEO_GRB + NEO_KHZ800);
uint8_t buffer[BUFFER_SIZE];
int pos = 0;

void transferReset(){
  resetBuffer();
}

void setup(){
  userFns.fn1 = transferReset;
  TFUSerial.begin();

  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
  
  pinMode(CONTROL_PIN, OUTPUT);     
}

void drawPixel(){
  uint32_t pixelColor = strip.Color(buffer[1], buffer[2], buffer[3]);
  uint16_t pixelIndex = ((uint16_t)buffer[0]);
      
  strip.setPixelColor(pixelIndex, pixelColor);
  strip.show();
}

void resetBuffer(){
  pos = 0;
}

void loop(){
  TFUSerial.task(); // this should be called at least once every 10 ms
  if (TFUSerial.available()) {
    uint8_t ch = ((uint8_t)TFUSerial.read());

    buffer[pos] = ch;
    if (pos < BUFFER_SIZE-1){
      pos++;
    }else{
      //TFUSerial.write(0x01);
      drawPixel();
      resetBuffer();
    }
  }
}
