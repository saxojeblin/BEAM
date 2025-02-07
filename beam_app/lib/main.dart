// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  // Function to send breaker status update to ESP32
  Future<void> sendBreakerStatus(int breakerIndex, bool status) async {
    String url = "http://$esp32Ip:$esp32Port/breaker";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'breaker': breakerIndex.toString(), // index on esp32 isn't 0 based
          'status': status ? '1' : '0',
        },
      );

      if (response.statusCode == 200) {
        print("Breaker ${breakerIndex + 1} updated successfully.");
      } else {
        print("Failed to update breaker ${breakerIndex + 1}. Response: ${response.body}");
      }
    } catch (e) {
      print("Error sending breaker update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        onTap: (index) {
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
                onChanged: (value) {
                  setState(() {
                    breakerStatus[index] = value;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Breaker ${index + 1} turned ${value ? 'ON' : 'OFF'}'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  });

                  // Send request to ESP32 when toggled
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
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  bool notificationsEnabled = false;
  String connectionStatus = "Disconnected";

  Future<void> testConnection() async {
    String ip = ipController.text;
    String port = portController.text;
    if (ip.isEmpty || port.isEmpty) {
      setState(() {
        connectionStatus = "Please enter IP and Port.";
      });
      return;
    }

    String url = "http://$ip:$port/test";

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: 3),
        onTimeout: () {
          throw Exception("Timeout");
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          connectionStatus = "Connected to BEAM device!";
        });
      } else {
        setState(() {
          connectionStatus = "Failed (Code: ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        connectionStatus = "Could not connect to BEAM device";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: ipController,
                              decoration: InputDecoration(
                                labelText: "IP Address",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: portController,
                              decoration: InputDecoration(
                                labelText: "Port",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: testConnection,
                              child: Text("Connect"),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Status: $connectionStatus",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Enable Notifications", style: TextStyle(fontSize: 18)),
                            Switch(
                              value: notificationsEnabled,
                              onChanged: (value) {
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
        currentIndex: 2, // Set to 2 for the Settings page
        onTap: (index) {
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
    );
  }
}