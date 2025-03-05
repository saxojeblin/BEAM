// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(BeamApp());
}

class BeamApp extends StatelessWidget {
  const BeamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          labelLarge: TextStyle(fontSize: 16, color: Colors.black),
          labelMedium: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ),
      home: ControlPage(),
    );
  }
}

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // Breaker statuses
  List<bool> breakerStatus = [false, false, false, false];

  // ESP32 IP Address (Set dynamically from Settings)
  final String esp32Ip = "192.168.4.1"; // Default AP mode IP
  final String esp32Port = "80"; // Default Port

  bool isLoading = false; // Track if a request is in progress
  String loadingMessage = ""; // Dynamic loading message

  // Function to send breaker status update to ESP32
  Future<void> sendBreakerStatus(int breakerIndex, bool status) async {
    if (isLoading) return; // Prevent multiple requests

    setState(() {
      isLoading = true;
      loadingMessage = "Flipping Breaker ${breakerIndex + 1}..."; // Dynamic message
    });

    String url = "http://$esp32Ip:$esp32Port/breaker";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'breaker': breakerIndex.toString(),
          'status': status ? '1' : '0',
        },
      ).timeout(
        Duration(seconds: 30), // ✅ Timeout after 5 seconds
        onTimeout: () {
          throw Exception("Timeout");
        },
      );

      if (response.statusCode == 200) {
        print("Breaker ${breakerIndex + 1} updated successfully.");
        setState(() {
          breakerStatus[breakerIndex] = status; // Update UI only on success
        });
      } else {
        print("Failed to update breaker ${breakerIndex + 1}. Response: ${response.body}");
        setState(() {
          breakerStatus[breakerIndex] = !status; // Revert toggle if failure
        });
      }
    } catch (e) {
      print("Error sending breaker update: $e");
      setState(() {
        breakerStatus[breakerIndex] = !status; // Revert toggle on error
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to communicate with BEAM. Check connection."),
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      isLoading = false; // ✅ Re-enable UI after timeout or response
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal.shade800,
            title: const Text(
              'Control',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade300, Colors.cyan.shade600],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => _buildBreakerTile(index)),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.grey.shade900,
            selectedItemColor: Colors.cyan,
            unselectedItemColor: Colors.grey.shade500,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.control_camera), label: 'Control'),
              BottomNavigationBarItem(icon: Icon(Icons.system_update_alt), label: 'System'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
            currentIndex: 0, // Set to 0 for the Control page
            onTap: isLoading
                ? null // Prevent navigation while loading
                : (index) {
                    if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SystemPage()),
                      );
                    } else if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    }
                  },
          ),
        ),

        // Full-Screen Loading Overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6), // Darken screen
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
                    SizedBox(height: 15),
                    // Replace with Text.rich to remove underline
                    Text.rich(
                      TextSpan(
                        text: loadingMessage,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none, // Remove underline
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBreakerTile(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        color: Colors.grey.shade100,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Breaker ${index + 1} Status: ',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                TextSpan(
                  text: breakerStatus[index] ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: breakerStatus[index] ? Colors.cyan.shade600 : Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                breakerStatus[index] ? Icons.check_circle : Icons.cancel,
                color: breakerStatus[index] ? Colors.cyan.shade600 : Colors.amber.shade700,
              ),
              Switch(
                value: breakerStatus[index],
                onChanged: isLoading
                    ? null // Disable switch while waiting for ESP32 response
                    : (value) {
                        sendBreakerStatus(index, value);
                      },
                activeColor: Colors.cyan.shade600,
                inactiveThumbColor: Colors.amber.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SystemPage extends StatefulWidget {
  const SystemPage({super.key});

  @override
  _SystemPageState createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> {
  // Placeholder for system information
  String gridFrequency = "60 Hz";
  String wifiStatus = "Connected";

  // Log of status changes
  List<String> statusLog = [
    "3:22 pm - 'Breaker 1' turned OFF",
    "3:34 pm - 'Breaker 3' turned ON",
    "3:56 pm - 'Breaker 4' turned OFF",
    "4:48 pm - 'Breaker 1' turned ON",
    "6:38 pm - 'Breaker 2' turned OFF",
    "9:38 pm - 'Breaker 3' turned OFF",
    "9:59 pm - 'Breaker 4' turned OFF",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        title: const Text(
          'System Info',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade300, Colors.cyan.shade600],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grid Frequency: $gridFrequency',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Wi-Fi Status: $wifiStatus',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Log',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                              Divider(color: Colors.grey),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: statusLog.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Text(
                                        statusLog[index],
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey.shade500,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.control_camera), label: 'Control'),
          BottomNavigationBarItem(icon: Icon(Icons.system_update_alt), label: 'System'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 1, // Set to 1 for the System page
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ControlPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          }
        },
      ),
    );
  }
}


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Breakers configuration for frequency spikes
  List<bool> breakersToFlip = [false, false, false, false];

  // Notifications toggle
  bool notificationsEnabled = false;

  // ESP32 IP Address (Modify if needed)
  final String esp32Ip = "192.168.4.1";
  final String esp32Port = "80";

  // Loading State
  bool isLoading = false;
  String loadingMessage = ""; // Dynamic loading text

  Future<void> sendBreakerSettings() async {
    if (isLoading) return; // Prevent multiple clicks

    setState(() {
      isLoading = true;
      loadingMessage = "Saving Settings..."; // Show dynamic message
    });

    String url = "http://$esp32Ip:$esp32Port/frequency_settings";
    Map<String, dynamic> data = {
      "breaker1": breakersToFlip[0],
      "breaker2": breakersToFlip[1],
      "breaker3": breakersToFlip[2],
      "breaker4": breakersToFlip[3],
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(
        Duration(seconds: 5), // Timeout after 5 seconds
        onTimeout: () {
          throw Exception("Timeout");
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Breaker settings updated successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update breaker settings.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Could not connect to ESP32.")),
      );
    }

    setState(() {
      isLoading = false; // Re-enable UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal.shade800,
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade300, Colors.cyan.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // **Frequency Spike Settings**
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Card(
                        color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Breakers to Flip on Frequency Spike:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Column(
                                children: List.generate(4, (index) {
                                  return Column(
                                    children: [
                                      CheckboxListTile(
                                        title: Text("Breaker ${index + 1}",
                                            style: TextStyle(fontSize: 14)),
                                        value: breakersToFlip[index],
                                        onChanged: isLoading
                                            ? null // Disable changes while loading
                                            : (bool? value) {
                                                setState(() {
                                                  breakersToFlip[index] = value ?? false;
                                                });
                                              },
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                        dense: true,
                                        activeColor: Colors.teal.shade800,
                                      ),
                                      if (index < 3)
                                        Divider(color: Colors.grey.shade400, height: 10),
                                    ],
                                  );
                                }),
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : sendBreakerSettings,
                                  child: Text("Save Settings"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isLoading
                                        ? Colors.grey.shade500
                                        : Colors.teal.shade800,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    textStyle:
                                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // **Notifications Toggle**
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Card(
                        color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Enable Notifications", style: TextStyle(fontSize: 16)),
                              Switch(
                                value: notificationsEnabled,
                                onChanged: isLoading
                                    ? null // Disable switch while saving
                                    : (value) {
                                        setState(() {
                                          notificationsEnabled = value;
                                        });
                                      },
                                activeColor: Colors.cyan.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.grey.shade900,
            selectedItemColor: Colors.cyan,
            unselectedItemColor: Colors.grey.shade500,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.control_camera), label: 'Control'),
              BottomNavigationBarItem(icon: Icon(Icons.system_update_alt), label: 'System'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
            currentIndex: 2,
            onTap: isLoading
                ? null // Prevent navigation while loading
                : (index) {
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ControlPage()),
                      );
                    } else if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SystemPage()),
                      );
                    }
                  },
          ),
        ),

        // **Full-Screen Loading Overlay**
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6), // Darken screen
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
                    SizedBox(height: 15),
                    Text(
                      loadingMessage,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
