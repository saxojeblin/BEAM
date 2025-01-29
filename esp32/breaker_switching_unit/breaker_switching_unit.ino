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

// Define Wi-Fi credentials (ESP32 will create its own network)
const char* apSSID = "BEAM_Server";
const char* apPassword = "12345678"; // Minimum 8 characters required

// Create a web server on port 80
WebServer server(80);

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("ESP32 is starting...");

  // Start ESP32 as a Wi-Fi Access Point
  WiFi.softAP(apSSID, apPassword);

  Serial.println("ESP32-A is running as an Access Point!");
  Serial.print("ESP32-A IP Address: ");
  Serial.println(WiFi.softAPIP());

  // Define a test endpoint
  server.on("/test", HTTP_GET, []() {
    server.send(200, "text/plain", "ESP32-A Connection Successful!");
  });

  // Start the web server
  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
}

