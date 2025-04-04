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

double previousFrequency = 60.0;

void handleBreakerRequest() {
    if (server.hasArg("breaker") && server.hasArg("status")) {
      // Get breaker command info
      int breakerIndex = server.arg("breaker").toInt() + 1; // breakers are 0 index on app
      bool status = server.arg("status") == "1";
  
      // Determine which breaker we are flipping
      switch (breakerIndex) {
        case 1:
          // Flip breaker 1
          Serial.println("Attemping to flip breaker 1...");
          if(status) ona(step1);
          else offa(step1);
          // Update new breaker status
          currentBreakerStatus.breaker1 = !currentBreakerStatus.breaker1;
          break;
        case 2:
          // Flip breaker 2
          Serial.println("Attemping to flip breaker 2...");
          if(status) ona(step2);
          else offa(step2);
          // Update new breaker status
          currentBreakerStatus.breaker2 = !currentBreakerStatus.breaker2;
          break;
        case 3:
          // Flip breaker 3
          Serial.println("Attemping to flip breaker 3...");
          if(status) onb(step1);
          else offb(step1);
          // Update new breaker status
          currentBreakerStatus.breaker3 = !currentBreakerStatus.breaker3;
          break;
        case 4:
          // Flip breaker 4
          Serial.println("Attemping to flip breaker 4...");
          if(status) onb(step2);
          else offb(step2);
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

void FrequencyRequest(){
  if (server.hasArg("frequency")){
    // Get the grid frequency and send to the app
    double frequency = server.arg("frequency").toDouble();
    sendFrequencyUpdate(frequency);

    // If the grid is unstable, alert the app to disable control and carry out response
    if (frequency <= 59.4){
      previousFrequency = frequency;
      // Send message to the app
      String message = R"({"type": "event", "event": "frequency_drop", "message": "Critical Frequency Drop: Grid is unstable"})";
      webSocket.broadcastTXT(message);

      // Carry out automatic frequency drop response
      automaticFrequencyResponse();
      Serial.println("CRITICAL FREQUENCY DROP");
    } else {
      // Return to previous state before frequency drop event
      if (previousFrequency <= 59.4)
      {
        previousFrequency = frequency;
        Serial.println("Frequency back to normal, alerting app.");
        String message = R"({"type": "event", "event": "frequency_restore", "message": "Grid frequency has returned to normal"})";
        webSocket.broadcastTXT(message);
      }
    Serial.println("Frequency = " + String(frequency));
    server.send(200, "text/plain", "Success");
    }
  } else {
    server.send(400, "text/plain", "Missing arguments");
    Serial.println("ERROR: Missing arguments in frequency request!");
  }
}

void FrequencyRequestTest(float frequency){
  // send serial frequency
  // sending 0 bug fix
  if (frequency == 0)
  {
    return;
  }
  sendFrequencyUpdate(frequency);
  Serial.println("previous frequency = " + String(previousFrequency));

  // If the grid is unstable, alert the app to disable control and carry out response
  if (frequency <= 59.4){
    previousFrequency = frequency;
    // Send message to the app
    Serial.println("Sending crit freq drop to app!!!");
    String message = R"({"type": "event", "event": "frequency_drop", "message": "Critical Frequency Drop: Grid is unstable"})";
    webSocket.broadcastTXT(message);

    // Carry out automatic frequency drop response
    automaticFrequencyResponse();
    Serial.println("CRITICAL FREQUENCY DROP");
  } else {
    // Return to previous state before frequency drop event
    if (previousFrequency <= 59.4)
    {
      previousFrequency = frequency;
      printf("Frequency back to normal! Alerting app.");
      String message = R"({"type": "event", "event": "frequency_restore", "message": "Grid frequency has returned to normal"})";
      webSocket.broadcastTXT(message);
    }
  Serial.println("Frequency = " + String(frequency));
  server.send(200, "text/plain", "Success");
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

void restoreBreakerStates()
{
  // write code here to restore breaker states 
  // based on the stored freq response settings
  Serial.println("Reverting breakers to original states.");
  delay(1000);
  delay(1000);
  delay(1000);
  server.send(200, "text/plain", "Breakers restored");
}

void automaticFrequencyResponse()
{
  //write automatic frequency response here
  //save the states of the breakers to use in restoreBreakerStates()
}