#include <WiFi.h>
#include <WebServer.h>

// Wi-Fi credentials (ESP32 in AP mode)
const char* apSSID = "BEAM_Server";
const char* apPassword = "12345678";

WebServer server(80);

void setup() {
  Serial.begin(115200);
  WiFi.softAP(apSSID, apPassword);
  Serial.println("ESP32-A is running as an Access Point!");
  Serial.print("ESP32-A IP Address: ");
  Serial.println(WiFi.softAPIP());

  // Define endpoint for breaker updates
  server.on("/breaker", HTTP_POST, handleBreakerRequest);

  server.begin();
  Serial.println("HTTP server started, waiting for connections...");
}

void loop() {
  server.handleClient();
}

void handleBreakerRequest() {
  if (server.hasArg("breaker") && server.hasArg("status")) {
    int breakerIndex = server.arg("breaker").toInt();
    bool status = server.arg("status") == "1";

    Serial.printf("Received Breaker Update: Breaker %d is now %s\n",
                  breakerIndex + 1, status ? "ON" : "OFF");
    Serial.flush(); // fixes the random garbage characters

    server.send(200, "text/plain", "Success");
  } else {
    server.send(400, "text/plain", "Missing arguments");
  }
}
