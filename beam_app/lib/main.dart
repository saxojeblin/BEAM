// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'websocket_service.dart';

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

class _ControlPageState extends State<ControlPage> with SingleTickerProviderStateMixin {
  late List<bool> breakerStatus;
  final String esp32Ip = "192.168.4.1";
  final String esp32Port = "80";

  final WebSocketService _webSocketService = WebSocketService();

  bool isLoading = false;
  String loadingMessage = "";

  bool isFrequencyCritical = false;
  bool resetPrompt = false;

  late AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();
    breakerStatus = _webSocketService.getBreakerStates();

    _iconAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _webSocketService.eventStream.listen((event) {
      if (event['event'] == 'frequency_drop') {
        setState(() {
          isFrequencyCritical = true;
          resetPrompt = false;
        });
      } else if (event['event'] == 'frequency_restore') {
        setState(() {
          isFrequencyCritical = true;
          resetPrompt = true;
        });
      }
    });

    if (_webSocketService.isFrequencyCritical()) {
      setState(() {
        isFrequencyCritical = true;
        resetPrompt = _webSocketService.isResetPending();
      });
    }
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  Future<void> sendBreakerStatus(int breakerIndex, bool status) async {
    if (isLoading || isFrequencyCritical) return;

    setState(() {
      isLoading = true;
      loadingMessage = "Flipping Breaker ${breakerIndex + 1}...";
    });

    final url = "http://$esp32Ip:$esp32Port/breaker";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'breaker': breakerIndex.toString(),
          'status': status ? '1' : '0',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception("Timeout"),
      );

      if (response.statusCode == 200) {
        setState(() {
          breakerStatus[breakerIndex] = status;
          _webSocketService.updateBreakerState(breakerIndex, status);
        });
      } else {
        setState(() {
          breakerStatus[breakerIndex] = !status;
        });
      }
    } catch (e) {
      setState(() {
        breakerStatus[breakerIndex] = !status;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to communicate with BEAM")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> sendRestoreCommand() async {
    final url = "http://$esp32Ip:$esp32Port/restore_breakers";

    setState(() {
      isLoading = true;
      loadingMessage = "Restoring breakers to previous state...";
    });

    try {
      final response = await http.post(Uri.parse(url)).timeout(Duration(seconds: 40));

      if (response.statusCode == 200) {
        _webSocketService.clearFrequencyStatus();
        setState(() {
          isFrequencyCritical = false;
          resetPrompt = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Breakers restored successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Restore failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Could not restore breakers")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal.shade800,
            title: const Text('Control', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
            currentIndex: 0,
            onTap: isLoading
                ? null
                : (index) {
                    if (index == 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SystemPage()),
                      );
                    } else if (index == 2) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    }
                  },
          ),
        ),

        if (isFrequencyCritical && !isLoading)
          _buildOverlay(),

        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
                    SizedBox(height: 15),
                    Text(
                      loadingMessage,
                      textAlign: TextAlign.center,
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

  Widget _buildOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + kToolbarHeight,
      left: 0,
      right: 0,
      bottom: kBottomNavigationBarHeight,
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.3).animate(
                  CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeInOut),
                ),
                child: Icon(
                  resetPrompt ? Icons.check_circle : Icons.warning,
                  color: resetPrompt ? Colors.greenAccent : Colors.redAccent,
                  size: 50,
                ),
              ),
              SizedBox(height: 15),
              Text(
                resetPrompt ? "Grid Stable" : "Grid Unstable - Frequency Drop",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 8),
              Text(
                resetPrompt
                    ? "Grid has stabilized.\nPlease restore breakers to resume control."
                    : "Grid instability detected.\nWaiting for grid to stabilize...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 20),
              if (resetPrompt)
                ElevatedButton(
                  onPressed: sendRestoreCommand,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal.shade800,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    "Restore Breakers",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
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
              AbsorbPointer(
                absorbing: isLoading || isFrequencyCritical,
                child: Switch(
                  value: breakerStatus[index],
                  onChanged: (value) => sendBreakerStatus(index, value),
                  activeColor: Colors.cyan.shade600,
                  inactiveThumbColor: Colors.amber.shade700,
                ),
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
  final WebSocketService webSocketService = WebSocketService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        title: const Text(
          'System Info',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<String>(
                      stream: webSocketService.frequencyStream,
                      initialData: webSocketService.getFrequency(),
                      builder: (context, snapshot) {
                        String gridFrequency = snapshot.data ?? "Loading...";
                        return Text(
                          'Grid Frequency: $gridFrequency',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<bool>(
                      stream: Stream.periodic(Duration(seconds: 1))
                          .map((_) => webSocketService.getConnectionStatus()),
                      initialData: webSocketService.getConnectionStatus(),
                      builder: (context, snapshot) {
                        bool isConnected = snapshot.data ?? false;
                        return Text(
                          'Wi-Fi Status: ${isConnected ? "Connected" : "Disconnected"}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isConnected ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<String>(
                      stream: webSocketService.batteryStatusStream,
                      initialData: webSocketService.getBatteryStatus(),
                      builder: (context, snapshot) {
                        String batteryStatus = snapshot.data ?? "Unknown";
                        return Text(
                          'Battery Status: $batteryStatus',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: batteryStatus == "Charged"
                                ? Colors.green
                                : batteryStatus == "Dead"
                                    ? Colors.red
                                    : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ControlPage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
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
  List<bool> breakersToFlip = [false, false, false, false];
  bool notificationsEnabled = false;

  final String esp32Ip = "192.168.4.1";
  final String esp32Port = "80";

  bool isLoading = false;
  String loadingMessage = "";

  @override
  void initState() {
    super.initState();
    fetchSavedSettings(); // Fetch current breaker settings from ESP32
  }

  Future<void> fetchSavedSettings() async {
    setState(() {
      isLoading = true;
      loadingMessage = "Loading saved settings...";
    });

    try {
      final response = await http.get(
        Uri.parse("http://$esp32Ip:$esp32Port/get_frequency_settings"),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          breakersToFlip = [
            data["breaker1"] ?? false,
            data["breaker2"] ?? false,
            data["breaker3"] ?? false,
            data["breaker4"] ?? false,
          ];
        });
      }
    } catch (e) {
      print("Error fetching settings: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> sendBreakerSettings() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      loadingMessage = "Saving Settings...";
    });

    final url = "http://$esp32Ip:$esp32Port/frequency_settings";
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
      ).timeout(Duration(seconds: 5));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200
                ? "Breaker settings updated successfully."
                : "Failed to update breaker settings.",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Could not connect to BEAM.")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal.shade800,
            title: const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Card(
                        color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                        title: Text("Breaker ${index + 1}"),
                                        value: breakersToFlip[index],
                                        onChanged: isLoading
                                            ? null
                                            : (value) {
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
                                    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Card(
                        color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                    ? null
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
            currentIndex: 2,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.control_camera), label: 'Control'),
              BottomNavigationBarItem(icon: Icon(Icons.system_update_alt), label: 'System'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
            onTap: isLoading
                ? null
                : (index) {
                    if (index == 0) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ControlPage()));
                    } else if (index == 1) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SystemPage()));
                    }
                  },
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
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
