int sampleRate = 100; //samples per second
int sampleInterval = 500000/sampleRate; //Inverse of SampleRate
long timer = micros(); //timer

//int ledOn = 0; //to control the LED.
int tagsAmountSec2 = 0;

#include <FastLED.h>

#define LED_PIN     8
#define NUM_LEDS    15

CRGB leds[NUM_LEDS];

void setup() {

  Serial.begin(9600); //serial

  FastLED.addLeds<WS2812, LED_PIN, GRB>(leds, NUM_LEDS);

  leds[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15] = CRGB(255, 255, 255); //initialise the colours 
  FastLED.show();
}

void loop() {
    
  if (micros() - timer >= sampleInterval) { //Timer: send sensor data in every 10ms
    timer = micros();
    getDataFromProcessing(); //Receive before sending out the signals
  }

}

void getDataFromProcessing() {
  while (Serial.available()) {

    char inChar = (char)Serial.read();
    tagsAmountSec2 = Serial.parseInt();

    if (inChar == 'T') { //temperature - temperature increases, warm
      leds[1, 2, 3] = CRGB (206, 38, 25);
      FastLED.show();
    }

    if (inChar == 'H') { //humidity increases
      leds[4, 5, 6] = CRGB (190, 113, 50);
      FastLED.show();
    }

    if (inChar == 'N') { //noise increases
      leds[7, 8, 9] = CRGB (172, 45, 114);
      FastLED.show();
    }

    if (inChar == 'A') { //air quality getting bad
      leds[10, 11, 12] = CRGB (241, 195, 195);
      FastLED.show();               
    }
    
    if ((tagsAmountSec2 > 15) & (tagsAmountSec2 <=20)) OR ((tagsAmountSec2 <= 5) & (tagsAmountSec2 >=0) { //light intensity is bad - too dark or bright
      leds[13, 14, 15] = CRGB (165, 79, 43);
      FastLED.show();
    }

    if (inChar == 't') { //temperature decreases
      leds[1, 2, 3] = CRGB (126, 197, 240);
      FastLED.show();
    }

    if (inChar == 'h') { //if humidity decrease
      leds[4, 5, 6] = CRGB (138, 218, 224);
      FastLED.show();
    }

    if (inChar == 'n') { // if noise decreases
      leds[7, 8, 9] = CRGB (184, 171, 233);
      FastLED.show();
    }  

    if (inChar == 'a') { // air quality gets better
      leds[10, 11, 12] = CRGB (119, 219, 182);
      FastLED.show();
    }

    if ((tagsAmountSec2 > 5) OR (tagsAmountSec2 <= 15) ) { //light quality good
      leds[13, 14, 15] = CRGB (142, 172, 225);
      FastLED.show();
    }
  }
}
