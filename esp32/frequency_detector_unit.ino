/************************************************************************************************
 *   UCF Senior Design Spring 2025- Group 28                                                    *
 * ---------------------------------------------                                                *
 * |            Nicholas Rubio                 |                                                *
 * |            Anika Zheng                    |                                                *
 * |            Huga Tarira                    |                                                *
 * |            Tristan Palumbo                |                                                *
 * ---------------------------------------------                                                *
 *                                                                                              *
 *  File:   frequency_detector_unit.ino                                                        *
 *                                                                                              *
 *  Description: This file contains the source code for the frequency detector unit in BEAM.    *
 *               This code is responsible for reading the frequency of the grid and sending     *
 *               signals to the breaker switching unit if there is a spike in grid frequency.   *
 *               The signals are converted using FFT and then read/monitored to determine       *
 *               whether responses need to be sent.                                             *
 ************************************************************************************************/

// anika code here