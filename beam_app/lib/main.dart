import 'package:flutter/material.dart';

void main() {
  runApp(BeamApp());
}

class BeamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        title: const Text('BEAM', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
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
        color: Colors.lightBlueAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) => _buildBreakerTile(index)),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          title: Text(
            'Breaker ${index + 1} Status: ${breakerStatus[index] ? 'ON' : 'OFF'}',
            style: const TextStyle(fontSize: 18),
          ),
          trailing: Switch(
            value: breakerStatus[index],
            onChanged: (value) {
              setState(() {
                breakerStatus[index] = value;
                // Add code here to send the signal to ESP32 over Wi-Fi
              });
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
        ),
      ),
    );
  }
}
