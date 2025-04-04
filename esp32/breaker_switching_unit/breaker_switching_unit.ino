/************************************************************************************************
 *   UCF Senior Design Spring 2025- Group 26                                                    *
 * ---------------------------------------------                                                *
 * |            Nicholas Rubio                 |                                                *
 * |            Anika Zheng                    |                                                *
 * |            Huga Tarira                    |                                                *
 * |            Tristan Palumbo                |                                                *
 * ---------------------------------------------                                                *
 *                                                                                              *
 *  File:   breaker_switching_unit.ino                                                          *
 *                                                                                              *
 *  Description: This file contains the source code for the main breakers switching ESP32.      *
 *               This MCU acts as the host for the HTTPS web server for Wi-Fi communication     *
 *               between the mobile app and frequency detector MCU. Its responsibilty is to     *
 *               manage the breaker states and flip breakers in response to either commands     *
 *               from the mobile app or the frequency detector unit, and report those states    *
 *               back to the other systems.                                                     *
 ************************************************************************************************/

#include <WiFi.h>
#include <WebServer.h>
#include <WebSocketsServer.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "config.h"

// Wi-Fi credentials (ESP32 in AP mode)
const char* apSSID = "BEAM_Server";
const char* apPassword = "12345678";

// Server hosted on ESP32
WebServer server(80);
WebSocketsServer webSocket(81);

// Global breakers structures
Breakers currentBreakerStatus = {false, false, false, false};
Breakers freqResponseSettings = {false, false, false, false};

unsigned long lastUpdateTime = 0;

void setup() {
  //---Set up Wi-Fi server/access point---
  Serial.begin(115200);
  WiFi.softAP(apSSID, apPassword);
  Serial.println("Main Breaker Unit is running as an Access Point!");
  Serial.print("Main Breaker Unit IP Address: ");
  Serial.println(WiFi.softAPIP());

  //---Set up HTTP server---
  // Define endpoint for breaker updates
  server.on("/breaker", HTTP_POST, handleBreakerRequest);
  // Define endpoint for Frequency updates
  server.on("/frequency", HTTP_POST, FrequencyRequest);
  // Define endpoint for frequency response settings
  server.on("/frequency_settings", HTTP_POST, handleFreqResponseSettings);
  // Define endpoint for restoring breaker states after frequency drop
  server.on("/restore_breakers", HTTP_POST, restoreBreakerStates);

  server.begin();
  Serial.println("HTTP server started.");

  //---Set up websocket server---
  webSocket.begin();
  webSocket.onEvent(handleWebSocketMessage);
  Serial.println("WebSocket server started on port 81.");

  //---Set up pins---
  // Declare pins as output:
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(EN, OUTPUT);
  pinMode(STBY, OUTPUT);
  pinMode(X_AXIS_REG, OUTPUT);
  pinMode(Y_AXIS_REG, OUTPUT);
  X_AXIS_POWER_SHUTDOWN();
  Y_AXIS_POWER_SHUTDOWN();

  printBreakerStates();

  Serial.println("Set up complete! - awaiting commands...");
}

void loop() {
  server.handleClient();
  webSocket.loop();

  // simulate freq update every 3s
  // if (millis() - lastUpdateTime > 3000)
  // {
  //   float frequency = 59.5 + (random(0,10) / 10.0);
  //   lastUpdateTime = millis();
  //   sendFrequencyUpdate(frequency);
  // }

  // simulate frequency request manual values
  // if (Serial.available() > 0)
  // {
  //   float userInput = Serial.parseFloat();
  //   FrequencyRequestTest(userInput);
  // }
}

void printBreakerStates()
{
  Serial.println("---Current breaker states----");
  Serial.printf("Breaker 1: %s\n", currentBreakerStatus.breaker1 ? "ON" : "OFF");
  Serial.printf("Breaker 2: %s\n", currentBreakerStatus.breaker2 ? "ON" : "OFF");
  Serial.printf("Breaker 3: %s\n", currentBreakerStatus.breaker3 ? "ON" : "OFF");
  Serial.printf("Breaker 4: %s\n", currentBreakerStatus.breaker4 ? "ON" : "OFF");
  Serial.println("-----------------------------");
}
