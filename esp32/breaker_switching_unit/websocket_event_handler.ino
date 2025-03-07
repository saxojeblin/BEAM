/************************************************************************************************
 *   UCF Senior Design Spring 2025- Group 26                                                    *
 * ---------------------------------------------                                                *
 * |            Nicholas Rubio                 |                                                *
 * |            Anika Zheng                    |                                                *
 * |            Huga Tarira                    |                                                *
 * |            Tristan Palumbo                |                                                *
 * ---------------------------------------------                                                *
 *                                                                                              *
 *  File:   websocket_event_handler.ino                                                         *
 *                                                                                              *
 *  Description: This file contains the source code for all event involving the websocket       *
 *               server. Primarily, information being sent from the breaker unit to the mobile  *
 *               app.                                                                           *
 ************************************************************************************************/

#include <WebSocketsServer.h>
#include <ArduinoJson.h>

// optional, in case the client sends a message
void handleWebSocketMessage(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
    switch (type) {
        case WStype_CONNECTED:
            Serial.printf("Client [%u] connected.\n", num);
            break;
        case WStype_TEXT:
            Serial.printf("Received message: %s\n", payload);
            break;
        case WStype_DISCONNECTED:
            Serial.printf("Client [%u] disconnected.\n", num);
            break;
    }
}

void sendFrequencyUpdate(float frequency) {
    // Format the frequency message
    StaticJsonDocument<200> doc;
    doc["frequency"] = frequency;
    String response;
    serializeJson(doc, response);

    // Send the frequency to clients (mobile app)
    webSocket.broadcastTXT(response);
    Serial.println("Sent frequency update: " + response);
}