import 'package:flutter/material.dart';

void main() {
  runApp(SmartBreakerApp());
}

class SmartBreakerApp extends StatelessWidget {
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
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // Breaker statuses
  List<bool> breakerStatus = [true, false, true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.cyan, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'BEAM',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(3, 3),
                  blurRadius: 5,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) => _buildBreakerTile(index)),
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
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.cyan, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'System Info',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(3, 3),
                  blurRadius: 5,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
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
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  bool notificationsEnabled = false;
  String connectionStatus = "Disconnected";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.cyan, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Network Settings',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(3, 3),
                  blurRadius: 5,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
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
                        onPressed: () {
                          setState(() {
                            connectionStatus = "Connected to ${ipController.text}:${portController.text}";
                          });
                        },
                        child: Text("Connect"),
                      ),
                      SizedBox(height: 16),
                      Text("Status: $connectionStatus",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                      Text("Enable Notifications",
                          style: TextStyle(fontSize: 18)),
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
