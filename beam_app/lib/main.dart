import 'package:flutter/material.dart';

void main() {
  runApp(BeamApp());
}

class BeamApp extends StatelessWidget {
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
      home: ControlPanelPage(),
    );
  }
}

class ControlPanelPage extends StatefulWidget {
  @override
  _ControlPanelPageState createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
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
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 3,
                  color: Colors.black26,
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification Clicked')),
              );
            },
          ),
        ],
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
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation tap
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
                    // Add code here to send the signal to ESP32 over Wi-Fi
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
