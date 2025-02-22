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

// Breakers struct containing on/off setting for each breaker
struct Breakers {
  bool breaker1;
  bool breaker2;
  bool breaker3;
  bool breaker4;
};

extern Breakers currentBreakerStatus;
extern Breakers freqResponseSettings;

#endif
