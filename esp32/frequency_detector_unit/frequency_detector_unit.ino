/************************************************************************************************
 *   UCF Senior Design Spring 2025- Group 26                                                    *
 * ---------------------------------------------                                                *
 * |            Nicholas Rubio                 |                                                *
 * |            Anika Zheng                    |                                                *
 * |            Huga Tarira                    |                                                *
 * |            Tristan Palumbo                |                                                *
 * ---------------------------------------------                                                *
 *                                                                                              *
 *  File:   frequency_detector_unit.ino                                                         *
 *                                                                                              *
 *  Description: This file contains the source code for the frequency detector unit in BEAM.    *
 *               This code is responsible for reading the frequency of the grid and sending     *
 *               signals to the breaker switching unit if there is a spike in grid frequency.   *
 *               The signals are converted using FFT and then read/monitored to determine       *
 *               whether responses need to be sent.                                             *
 ************************************************************************************************/

// anika code here
#include "WiFi.h"
#include <HTTPClient.h>

#include <arduinoFFT.h>

#define LED_PIN 18
#define ADC_PIN 39
#define NUM_SAMPLES 1024   // Must be power of 2 because it makes FFT easier to calculate // 240/1024 gives us the resolution and 1024/240 gives us the total sampling time
#define SAMPLING_FREQ 240  //Our sampling rate because according to nyquist thereom we need twice the frequency of what we want to detect the actual frequency
#define History_size 3 //Store last 3 frequency values

const char* ssid = "BEAM_Server";
const char* password = "12345678";
const char* serverName = "http://192.168.4.1:80/frequency";

double real_samples[NUM_SAMPLES];
double imag_samples[NUM_SAMPLES];
double sampling_period_us;
double frequency_history[History_size] = {0,0,0};
double last_frequency = 0;

ArduinoFFT<double> FFT = ArduinoFFT<double>(real_samples, imag_samples, NUM_SAMPLES, SAMPLING_FREQ);

void setup() {
  // initialize serial communication at 115200 bits per second:
  Serial.begin(115200);

  // Remove the password parameter, if you want the AP (Access Point) to be open
  WiFi.begin(ssid, password);
  Serial.println("Connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to WiFi network with IP Address: ");
  Serial.println(WiFi.localIP());

  //set the resolution to 12 bits (0-4095)
  analogReadResolution(12);

  sampling_period_us = 1000000.0 / SAMPLING_FREQ;

  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  int start_time = micros();  //micros() is the current time in microseconds
  for (int i = 0; i < NUM_SAMPLES; i++) {
    while ((micros() - start_time) < sampling_period_us * i) {}
    real_samples[i] = analogRead(ADC_PIN);  //reads # proportional to the voltage and stores in real_samples
    imag_samples[i] = 0;
  }
  // Compute FFT
  FFT.dcRemoval();                                           //removes DC bias so average value of all the samples is 0
  FFT.windowing(FFTWindow::Hamming, FFTDirection::Forward);  //controls windowing and gives us a reduced spread of frequency on the spectrum
  FFT.compute(FFTDirection::Forward);                        //just compute the FFT
  FFT.complexToMagnitude();

  int peak_index = 0;
  double peak_value = 0;

  for (int i = 0; i < NUM_SAMPLES / 2; i++) {  //only looping through half the samples because the second half is the same data
    if (real_samples[i] > peak_value) {
      peak_value = real_samples[i];  //the highest point of the FFT
      peak_index = i;                //the index of the highest point
    }
  }

  double frequency = ((1.0 * peak_index) / NUM_SAMPLES) * SAMPLING_FREQ;  //multiplying the index by the resolution

  for (int i = 0; i < History_size-1; i++) {
    frequency_history[i] = frequency_history[i+1];
  }

  frequency_history[History_size-1] = frequency;

  bool sendupdate = false;

  if(frequency >= 59.4) {
    if (frequency != last_frequency){
      sendupdate = true;
    }
  } else if (frequency_history[0] < 59.4 && frequency_history[1] < 59.4) {
    sendupdate = true;
  }

  if (sendupdate && WiFi.status() == WL_CONNECTED) {
    WiFiClient client;
    HTTPClient http;

    // Your Domain name with URL path or IP address with path
    http.begin(client, serverName);
    // // Specify content-type header
    // http.addHeader("Content-Type", "application/json");
    // // Data to send with HTTP POST
    // // Send HTTP POST request
    // int httpResponseCode = http.POST("{\"frequency\":" + String(frequency) + "}"); // { "frequency": 60.00 }

    // Specify content-type header
    http.addHeader("Content-Type", "application/x-www-form-urlencoded");
    // Data to send with HTTP POST
    String httpRequestData = "frequency=" + String(frequency);
    // Send HTTP POST request
    int httpResponseCode = http.POST(httpRequestData);

    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);

    // Free resources
    http.end();
    last_frequency = frequency;
  } else {
    Serial.println("WiFi Disconnected");
  }

  Serial.printf("Frequency = %.1f\n", frequency);

  digitalWrite(LED_PIN, HIGH);  // turn the LED on (HIGH is the voltage level)
  delay(100);                   // wait for a second
  digitalWrite(LED_PIN, LOW);   // turn the LED off by making the voltage LOW
}
