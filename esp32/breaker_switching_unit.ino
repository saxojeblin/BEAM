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

// Wi-Fi credentials
const char* ssid = "test";
const char* password = "test";

// Web server running on port 80
WebServer server(80);

// GPIO pins for relays
const int relayPins[] = {5, 18, 19, 21}; // Replace with your relay GPIO pins
const int relayCount = sizeof(relayPins) / sizeof(relayPins[0]);

void setup() {
  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to Wi-Fi");
  Serial.println(WiFi.localIP());

  // Initialize relay pins
  for (int i = 0; i < relayCount; i++) {
    pinMode(relayPins[i], OUTPUT);
    digitalWrite(relayPins[i], HIGH); // Default OFF state for active-low relays
  }

  // Define HTTP endpoints
  server.on("/toggle", handleToggle);
  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
}

// Handle requests to toggle relays
void handleToggle() {
  if (server.hasArg("breaker") && server.hasArg("state")) {
    int breaker = server.arg("breaker").toInt() - 1; // Breaker index (1-based)
    String state = server.arg("state");

    if (breaker >= 0 && breaker < relayCount) {
      if (state == "on") {
        digitalWrite(relayPins[breaker], LOW); // Turn relay ON
        server.send(200, "text/plain", "Breaker turned ON");
      } else if (state == "off") {
        digitalWrite(relayPins[breaker], HIGH); // Turn relay OFF
        server.send(200, "text/plain", "Breaker turned OFF");
      } else {
        server.send(400, "text/plain", "Invalid state");
      }
    } else {
      server.send(400, "text/plain", "Invalid breaker index");
    }
  } else {
    server.send(400, "text/plain", "Missing parameters");
  }
}
