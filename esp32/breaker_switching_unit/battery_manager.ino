/************************************************************************************************
 *   UCF Senior Design Spring 2025- Group 26                                                    *
 * ---------------------------------------------                                                *
 * |            Nicholas Rubio                 |                                                *
 * |            Anika Zheng                    |                                                *
 * |            Huga Tarira                    |                                                *
 * |            Tristan Palumbo                |                                                *
 * ---------------------------------------------                                                *
 *                                                                                              *
 *  File:   battery_manager.ino                                                          *
 *                                                                                              *
 *  Description: This file contains the source code for monitoring the battery level of the     *
 *               system and notifying the app if the battery is dead.                           *
 ************************************************************************************************/

#include "config.h"

// power input
int UVLO_STATE = 0;

// Current Sensor
int XCurrentValue = 0;

// Checks the state of the battery.
void CHECK_UVLO(){
    UVLO_STATE = digitalRead(UVLO);
    if(UVLO_STATE == LOW){
    //if UVLO happens turn everything off
    //and notify the user that he battery needs
    //to be charged
    COMPLETE_SHUTDOWN();
    while(UVLO_STATE == LOW){
        sendBatteryStatus(false);
        Serial.printf("\nLOW BATTERY...SYSTEM SHUTTING DOWN");
        UVLO_STATE = digitalRead(UVLO);
        delay(100);
        }
    }
    sendBatteryStatus(true);
}

void COMPLETE_SHUTDOWN(){
    //turn off both motor drivers
    X_AXIS_POWER_SHUTDOWN();
    Y_AXIS_POWER_SHUTDOWN();
}

void COMPLETE_TURNON(){
    //turn on both motor drivers
    Y_AXIS_POWER_ON();
    X_AXIS_POWER_ON();
}