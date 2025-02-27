#include <WiFi.h>
#include <WebServer.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// stepper motor:
#define dirPin 13
#define stepPin 12
#define stepsPerRevolution 400
#define revolutions 15
#define s1 5
#define s2 10
#define s3 15
#define s4 20

// dc motor
#define in1 34
#define in2 32

// Wi-Fi credentials (ESP32 in AP mode)
const char* apSSID = "BEAM_Server";
const char* apPassword = "12345678";

// Server hosted on ESP32
WebServer server(80);

// Global breaker status variables
bool breaker_1_status;
bool breaker_2_status;
bool breaker_3_status;
bool breaker_4_status;

void setup() {
  //---Set up Wi-Fi server/access point---
  Serial.begin(115200);
  WiFi.softAP(apSSID, apPassword);
  Serial.println("Main Breaker Unit is running as an Access Point!");
  Serial.print("Main Breaker Unit IP Address: ");
  Serial.println(WiFi.softAPIP());

  // Define endpoint for breaker updates
  server.on("/breaker", HTTP_POST, handleBreakerRequest);

  // Define endpoint for Frequency updates
  server.on("/frequency", HTTP_POST, FrequencyRequest);

  server.begin();
  Serial.println("HTTP server started.");

  //---Set up pins---
  // Declare pins as output:
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);

  // Set up internal variables
  // Initialize global variables (OFF)
  breaker_1_status = false;
  breaker_2_status = false;
  breaker_3_status = false;
  breaker_4_status = false;
  printBreakerStates();

  Serial.println("Set up complete! - awaiting commands...");
}

void loop() {
  server.handleClient();
}

void handleBreakerRequest() {
  if (server.hasArg("breaker") && server.hasArg("status")) {
    // Get breaker command info
    int breakerIndex = server.arg("breaker").toInt() + 1; // breakers are 0 index on app
    bool status = server.arg("status") == "1";

    // Determine which breaker we are flipping
    switch (breakerIndex) {
      case 1:
        Serial.println("Attemping to flip breaker 1...");
        // Goes to switch 1
        moveStepperForward(s1);
        switchDCMotor();
        moveStepperBackward(s1);
        // Update new breaker status
        breaker_1_status = !breaker_1_status;
        break;
      case 2:
        Serial.println("Attemping to flip breaker 2...");
        // Goes to switch 2
        moveStepperForward(s2);
        switchDCMotor();
        moveStepperBackward(s2);
        // Update new breaker status
        breaker_2_status = !breaker_2_status;
        break;
      case 3:
        Serial.println("Attemping to flip breaker 3...");
        // Goes to switch 3
        moveStepperForward(s3);
        switchDCMotor();
        moveStepperBackward(s3);
        // Update new breaker status
        breaker_3_status = !breaker_3_status;
        break;
      case 4:
        Serial.println("Attemping to flip breaker 4...");
        // Goes to switch 4
        moveStepperForward(s4);
        switchDCMotor();
        moveStepperBackward(s4);
        // Update new breaker status
        breaker_4_status = !breaker_4_status;
        break;
      default:
        Serial.printf("ERROR: Invalid breaker index receieved: %d.\n", breakerIndex);
        break;
    }

    Serial.printf("Received Breaker Update: Breaker %d is now %s\n",
                  breakerIndex, status ? "ON" : "OFF");
    
    // print current breaker states (comment out if not needed)
    printBreakerStates();

    Serial.flush(); // fixes the random garbage characters
    server.send(200, "text/plain", "Success");
  } else {
    server.send(400, "text/plain", "Missing arguments");
    Serial.println("ERROR: Missing arguments in breaker request!");
  }
}

void FrequencyRequest(){
  if (server.hasArg("frequency")){
    double frequency = server.arg("frequency").toDouble();
    if (frequency <= 59.4){
      Serial.println("CRITICAL FREQUENCY DROP");
    } else{
    Serial.println("Frequency = " + String(frequency));
    server.send(200, "text/plain", "Success");
    }
  } else {
    server.send(400, "text/plain", "Missing arguments");
    Serial.println("ERROR: Missing arguments in frequency request!");
  }
}

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

void printBreakerStates()
{
  Serial.println("---Current breaker states----");
  Serial.printf("Breaker 1: %s\n", breaker_1_status ? "ON" : "OFF");
  Serial.printf("Breaker 2: %s\n", breaker_2_status ? "ON" : "OFF");
  Serial.printf("Breaker 3: %s\n", breaker_3_status ? "ON" : "OFF");
  Serial.printf("Breaker 4: %s\n", breaker_4_status ? "ON" : "OFF");
  Serial.println("-----------------------------");
}
