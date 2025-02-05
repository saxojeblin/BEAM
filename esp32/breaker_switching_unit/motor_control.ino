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
// #define in1 5 
// #define in2 6

// void setup() {
//   // Declare pins as output:
//   pinMode(stepPin, OUTPUT);
//   pinMode(dirPin, OUTPUT);
//   pinMode(in1, OUTPUT);
//   pinMode(in2, OUTPUT);

//   // Initialize serial communication:
//   Serial.begin(9600);
// }

// void loop() {
//   // Wait for user input:
//   if (Serial.available() > 0) {
//     int userInput = Serial.parseInt();

//     switch (userInput) {
//       case 1:
//         // Goes to switch 1
//         moveStepper(s1);
//         switchDCMotor();
//         moveStepper(s1);
//         break;
//       case 2:
//         // Goes to switch 2
//         moveStepper(s2);
//         switchDCMotor();
//         moveStepper(s2);
//         break;
//       case 3:
//         // Goes to switch 3
//         moveStepper(s3);
//         switchDCMotor();
//         moveStepper(s3);
//         break;
//       case 4:
//         // Goes to switch 4
//         moveStepper(s4);
//         switchDCMotor();
//         moveStepper(s4);
//         break;
//       default:
//         Serial.println("Invalid input. Please enter 1, 2, 3, or 4.");
//         break;
//     }
//   }
// }

// void moveStepper(int stepsMultiplier) {
//   // Set the spinning direction counterclockwise:
//   digitalWrite(dirPin, LOW);
//   delay(1000);

//   for (int i = 0; i < stepsMultiplier * stepsPerRevolution; i++) {
//     digitalWrite(stepPin, HIGH);
//     delayMicroseconds(500);
//     digitalWrite(stepPin, LOW);
//     delayMicroseconds(500);
//   }

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