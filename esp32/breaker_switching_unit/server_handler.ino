/************************************************************************************************
 *   UCF Senior Design Spring 2025- Group 26                                                    *
 * ---------------------------------------------                                                *
 * |            Nicholas Rubio                 |                                                *
 * |            Anika Zheng                    |                                                *
 * |            Huga Tarira                    |                                                *
 * |            Tristan Palumbo                |                                                *
 * ---------------------------------------------                                                *
 *                                                                                              *
 *  File:   server_handler.ino                                                                  *
 *                                                                                              *
 *  Description: The functions in this file are responsible for handling the various server     *
 *               request functions.                                                             *
 *                                                                                              *
 ************************************************************************************************/

#include "config.h"
#include <ArduinoJson.h>

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
          currentBreakerStatus.breaker1 = !currentBreakerStatus.breaker1;
          break;
        case 2:
          Serial.println("Attemping to flip breaker 2...");
          // Goes to switch 2
          moveStepperForward(s2);
          switchDCMotor();
          moveStepperBackward(s2);
          // Update new breaker status
          currentBreakerStatus.breaker2 = !currentBreakerStatus.breaker2;
          break;
        case 3:
          Serial.println("Attemping to flip breaker 3...");
          // Goes to switch 3
          moveStepperForward(s3);
          switchDCMotor();
          moveStepperBackward(s3);
          // Update new breaker status
          currentBreakerStatus.breaker3 = !currentBreakerStatus.breaker3;
          break;
        case 4:
          Serial.println("Attemping to flip breaker 4...");
          // Goes to switch 4
          moveStepperForward(s4);
          switchDCMotor();
          moveStepperBackward(s4);
          // Update new breaker status
          currentBreakerStatus.breaker4 = !currentBreakerStatus.breaker4;
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
  
void handleFreqResponseSettings() {
  if (server.hasArg("plain")) {
    String body = server.arg("plain");
    Serial.println("Received Breaker Settings: " + body);

    StaticJsonDocument<200> doc;
    DeserializationError error = deserializeJson(doc, body);

    if (error) {
      Serial.println("JSON Parsing Failed");
      server.send(400, "application/json", "{\"status\": \"error\", \"message\": \"Invalid JSON\"}");
      return;
    }

    // Update breaker settings from JSON
    freqResponseSettings.breaker1 = doc["breaker1"];
    freqResponseSettings.breaker2 = doc["breaker2"];
    freqResponseSettings.breaker3 = doc["breaker3"];
    freqResponseSettings.breaker4 = doc["breaker4"];

    Serial.println("Updated Frequency Response Settings Settings:");
    Serial.printf("Breaker 1: %d, Breaker 2: %d, Breaker 3: %d, Breaker 4: %d\n",
                  freqResponseSettings.breaker1, freqResponseSettings.breaker2,
                  freqResponseSettings.breaker3, freqResponseSettings.breaker4);

    server.send(200, "application/json", "{\"status\": \"success\"}");
  } else {
    server.send(400, "application/json", "{\"status\": \"error\", \"message\": \"No JSON received\"}");
  }
}