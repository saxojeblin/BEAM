/************************************************************************************************
 *   UCF Senior Design Spring 2025- Group 26                                                    *
 * ---------------------------------------------                                                *
 * |            Nicholas Rubio                 |                                                *
 * |            Anika Zheng                    |                                                *
 * |            Huga Tarira                    |                                                *
 * |            Tristan Palumbo                |                                                *
 * ---------------------------------------------                                                *
 *                                                                                              *
 *  File:   motor_control.ino                                                                   *
 *                                                                                              *
 *  Description: The functions in this file are responsible for controlling the different       *
 *               motors in our system.                                                          *
 *                                                                                              *
 ************************************************************************************************/

#include "config.h"

void moveStepperForward(int stepsMultiplier) {
  // Set the spinning direction counterclockwise:
  digitalWrite(dirPin, LOW);
  delay(1000);

  for (int i = 0; i < stepsMultiplier * steps; i++) {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(500);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(500);
  }

}

void moveStepperBackward(int stepsMultiplier) {
  // Set the spinning direction counterclockwise:
  digitalWrite(dirPin, LOW);
  delay(1000);
  // Set the spinning direction clockwise:
  digitalWrite(dirPin, HIGH);
  delay(1000);

  for (int i = 0; i < stepsMultiplier * steps; i++) {
    digitalWrite(stepPin, HIGH);
    delayMicroseconds(500);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(500);
  }
}

void switchON() {         //EXTENDS (ON)

  X_AXIS_POWER_ON();

  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW); 
  delay(500);
  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH); 
  delay(500);

  X_AXIS_POWER_SHUTDOWN();

}

void switchOFF() {         //RETRACTS (OFF)

  X_AXIS_POWER_ON();

  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH); 
  delay(500);
  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW); 
  delay(500);
  
  X_AXIS_POWER_SHUTDOWN();

}

void ona(int stepper) {          //ON switch 1&2 function

  X_AXIS_POWER_ON();
  Y_AXIS_POWER_ON();

  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH);
  delay(2000);
  moveStepperForward(stepper);
  switchON();
  moveStepperBackward(stepper);

  X_AXIS_POWER_SHUTDOWN();
  Y_AXIS_POWER_SHUTDOWN();
}
void onb(int stepper) {          //ON switch 3&4 function
  
  X_AXIS_POWER_ON();
  Y_AXIS_POWER_ON();

  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH);
  delay(2000);
  moveStepperBackward(stepper);
  switchON();
  moveStepperForward(stepper);

  X_AXIS_POWER_SHUTDOWN();
  Y_AXIS_POWER_SHUTDOWN();
}

void offa(int stepper) {         //OFF switch 1&2 function
  
  X_AXIS_POWER_ON();
  Y_AXIS_POWER_ON();

  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);
  delay(2000);
  moveStepperForward(stepper);
  switchOFF();
  moveStepperBackward(stepper);

  X_AXIS_POWER_SHUTDOWN();
  Y_AXIS_POWER_SHUTDOWN();
  }

void offb(int stepper) {         //OFF switch 3&4 function
  
  X_AXIS_POWER_ON();
  Y_AXIS_POWER_ON();

  digitalWrite(in1, HIGH);
  digitalWrite(in2, LOW);
  delay(2000);
  moveStepperBackward(stepper);
  switchOFF();
  moveStepperForward(stepper);

  X_AXIS_POWER_SHUTDOWN();
  Y_AXIS_POWER_SHUTDOWN();
}

void X_AXIS_POWER_SHUTDOWN(){
  //turn off X-AXIS
  digitalWrite(STBY, LOW);
  digitalWrite(X_AXIS_REG, HIGH);
}

void X_AXIS_POWER_ON(){
  //turn on X-AXIS
  digitalWrite(STBY, HIGH);
  digitalWrite(X_AXIS_REG, LOW);
}

void Y_AXIS_POWER_SHUTDOWN(){
  //turn off Y-AXIS driver
  digitalWrite(EN, HIGH);
  digitalWrite(Y_AXIS_REG, HIGH);
}

void Y_AXIS_POWER_ON(){
  //turn on Y-AXIS driver
  digitalWrite(EN, LOW);
  digitalWrite(Y_AXIS_REG, LOW);
}
