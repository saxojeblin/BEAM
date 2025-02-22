// #include <stdio.h>
// #include <stdlib.h>
// #include <string.h>

// // stepper motor:
// #define dirPin 13
// #define stepPin 12
// #define stepsPerRevolution 400
// #define revolutions 15
// #define s1 5
// #define s2 10
// #define s3 15
// #define s4 20

// // dc motor
// #define in1 34
// #define in2 32


// void setup() {
//   // Declare pins as output:
  
//   pinMode(stepPin, OUTPUT);
//   pinMode(dirPin, OUTPUT);
//   pinMode(in1, OUTPUT);
//   pinMode(in2, OUTPUT);
  

//   // Initialize serial communication:
//   Serial.begin(115200);
// }

// void loop() {
//   // Wait for user input:
//   //Serial.println("Test");
//   //delay(1000);
//   if (Serial.available() > 0) {
//     int userInput = Serial.parseInt();

//     switch (userInput) {
//       case 1:
//         // Goes to switch 1
//         moveStepperForward(s1);
//         switchDCMotor();
//         moveStepperBackward(s1);
//         break;
//       case 2:
//         // Goes to switch 2
//         moveStepperForward(s2);
//         switchDCMotor();
//         moveStepperBackward(s2);
//         break;
//       case 3:
//         // Goes to switch 3
//         moveStepperForward(s3);
//         switchDCMotor();
//         moveStepperBackward(s3);
//         break;
//       case 4:
//         // Goes to switch 4
//         moveStepperForward(s4);
//         switchDCMotor();
//         moveStepperBackward(s4);
//         break;
//       default:
//         Serial.println("Invalid input. Please enter 1, 2, 3, or 4.");
//         break;
//     }
//   }
// }


// void moveStepperForward(int stepsMultiplier) {
//   // Set the spinning direction counterclockwise:
//   digitalWrite(dirPin, LOW);
//   delay(1000);

//   for (int i = 0; i < stepsMultiplier * stepsPerRevolution; i++) {
//     digitalWrite(stepPin, HIGH);
//     delayMicroseconds(500);
//     digitalWrite(stepPin, LOW);
//     delayMicroseconds(500);
//   }

// }

//   void moveStepperBackward(int stepsMultiplier) {
//   // Set the spinning direction counterclockwise:
//   digitalWrite(dirPin, LOW);
//   delay(1000);
//   // Set the spinning direction clockwise:
//   digitalWrite(dirPin, HIGH);
//   delay(1000);

//   for (int i = 0; i < stepsMultiplier * stepsPerRevolution; i++) {
//     digitalWrite(stepPin, HIGH);
//     delayMicroseconds(500);
//     digitalWrite(stepPin, LOW);
//     delayMicroseconds(500);
//   }
// }

// void switchDCMotor() {
//   digitalWrite(in1, HIGH);
//   digitalWrite(in2, LOW); 
//   delay(2000);
//   digitalWrite(in1, LOW);
//   digitalWrite(in2, HIGH); 
//   delay(2000);
// }
