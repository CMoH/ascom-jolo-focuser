// ASCOM focuser arduino sketch
// ascom-jolo-focuser Google code project
// 
// Author: jolo drjolo@gmail.com
// ver. 1.3 08-11-2013
// ver. 1.4 11-11-2013
// ver. 1.5 - production
// removed encoder
// add signal led
// 
// 
#include <OneWire.h>
#include <DallasTemperature.h>
#include <EEPROM.h>
#include <AccelStepper.h>
#include <Bounce.h>

#define DEVICE_RESPONSE "Jolo primary focuser"

// pin map
#define TEMP_SENSOR_PIN    2
#define ENCODER_IN_PIN     7
#define ENCODER_OUT_PIN    4
#define BUZZER_PIN         5
#define STEPPER_PWM_PIN    6
#define BUZ_LED_PIN       11
#define STEPPER_POWER_PIN  3

#define STEPPER_PIN1      12
#define STEPPER_PIN2      13


// EEPROM addresses
#define FOCUSER_POS_START 900
#define STEPPER_SPEED_ADD 3      
#define DUTY_CYCLE_ADDR 2  

// Encoder config
Bounce outButton = Bounce( ENCODER_OUT_PIN, 30 ); 
Bounce inButton = Bounce( ENCODER_IN_PIN, 30 ); 

// Buzzer config
#define BUZZ_LONG 300
#define BUZZ_SHORT 50
#define BUZZ_PAUSE 50
#define BUZZER_ON true

// Temperature sensor config (one wire protocol)
#define TEMP_CYCLE 3000
OneWire oneWire(TEMP_SENSOR_PIN);
DallasTemperature sensors(&oneWire);
DeviceAddress insideThermometer;

// Stepper config
#define STEPPER_ACC 2500
#define MANUAL_STEPPER_ACC 600
AccelStepper stepper = AccelStepper(AccelStepper::DRIVER, STEPPER_PIN1, STEPPER_PIN2);

// Global vars
boolean positionSaved;               // Flag indicates if stepper position was saved as new focuser position
unsigned long tempRequestMilis;      // Next temperature request time
unsigned long tempReadMilis;         // Next temperature read time (188ms after temperature read request) 
boolean sensorConnected;             // Flag indicates if temperature sensor is connected
float currentTemp;                   // Current cached temperature  
String inputString;                  // Serial input command string (terminated with \n)

boolean newCommand = false;          // set to true before issuing a new command
boolean stepperEnabled = false;      // see lastCommandMillis
unsigned long lastCommandMillis = 0; // millis since last stepper command
#define DISABLE_TIMEOUT 10000         // millis of inactivity before powerdown 10 sec

byte buzzes = 0;                     // Number of buzzes to do 
int buzz_time = 0;                   // Next buzz period 
unsigned long buzz_next_action = 0;  // Time to next buzz action change

int manualStep = 16;                 // Manual focuser position change in steps 
long maxFocuserPos = 1000000;        // Maximum focuser position


void loop() 
{
  //enable if needed
#ifdef DISABLE_TIMEOUT
  if (newCommand) {
    lastCommandMillis = millis();
    if (!stepperEnabled) stepper.enableOutputs();
    stepperEnabled = true;
    newCommand = false;
  }
#endif

  // Stepper loop
  stepper.run();

  if(stepper.distanceToGo() == 0 && !positionSaved) {
    saveFocuserPos(stepper.currentPosition());
    positionSaved = true;
    buzz(BUZZ_SHORT, 1);
    analogWrite(STEPPER_PWM_PIN, (255 * EEPROM.read(DUTY_CYCLE_ADDR)/100));
    tempRequestMilis = millis() + 500;
  }

  // Temperature read loop
  if(sensorConnected && tempRequestMilis != 0 && tempRequestMilis < millis()) requestTemp();  
  if(sensorConnected && tempReadMilis != 0 && tempReadMilis < millis()) readTemp();  

  // Buzzer call
  doBuzz();

  // Manual control
  doButtonsCheck();

  // Power down after inactivity
#ifdef DISABLE_TIMEOUT
  if (stepperEnabled && millis() > lastCommandMillis + DISABLE_TIMEOUT) {
    stepper.disableOutputs();
    stepperEnabled = false;
  }
#endif
}






