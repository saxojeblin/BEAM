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
  
    for (int i = 0; i < stepsMultiplier * stepsPerRevolution; i++) {
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

    for (int i = 0; i < stepsMultiplier * stepsPerRevolution; i++) {
        digitalWrite(stepPin, HIGH);
        delayMicroseconds(500);
        digitalWrite(stepPin, LOW);
        delayMicroseconds(500);
    }
}
  
void switchDCMotor() {
    digitalWrite(in1, HIGH);
    digitalWrite(in2, LOW); 
    delay(2000);
    digitalWrite(in1, LOW);
    digitalWrite(in2, HIGH); 
    delay(2000);
}