/************************************************************************************************
 *   UCF Senior Design Spring 2025- Group 26                                                    *
 * ---------------------------------------------                                                *
 * |            Nicholas Rubio                 |                                                *
 * |            Anika Zheng                    |                                                *
 * |            Huga Tarira                    |                                                *
 * |            Tristan Palumbo                |                                                *
 * ---------------------------------------------                                                *
 *                                                                                              *
 *  File:   config.h                                                                            *
 *                                                                                              *
 *  Description: This file contains the various defined macros, such as pin definitions, motor  *
 *               control parameters, etc., and defined data structures in our project.          *
 *                                                                                              *
 ************************************************************************************************/

#ifndef CONFIG_H
#define CONFIG_H


// stepper motor:
#define dirPin 22
#define stepPin 21

//step distance is 20.5 mm per 2000 revolutions, and distance between each breaker is 26mm
#define steps 2536

#define step1 1
#define step2 2

#define EN 16
#define STBY 32
#define X_AXIS_REG 14
#define Y_AXIS_REG 23

#define UVLO 35
#define X_AXIS_CURRENT 33

// dc motor
#define in1 27  
#define in2 26

// Breakers struct containing on/off setting for each breaker
struct Breakers {
  bool breaker1;
  bool breaker2;
  bool breaker3;
  bool breaker4;
};

extern Breakers currentBreakerStatus;
extern Breakers freqResponseSettings;
extern Breakers prevBreakerStates;

#endif
