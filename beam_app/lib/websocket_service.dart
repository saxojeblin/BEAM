import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:async';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  IOWebSocketChannel? channel;
  final String esp32Ip = "192.168.4.1"; // ESP32 WebSocket Server IP
  bool isConnected = false;
  String lastFrequency = "60 Hz"; // Store last received frequency

  final StreamController<String> _frequencyController =
      StreamController<String>.broadcast(); // ✅ Keeps streaming live updates

  WebSocketService._internal() {
    _connect();
  }

  void _connect() {
    String url = "ws://$esp32Ip:81";
    try {
      channel = IOWebSocketChannel.connect(url);
      isConnected = true;
      print("Connected to WebSocket Server!");

      channel!.stream.listen(
        (message) {
          var jsonResponse = jsonDecode(message);
          if (jsonResponse.containsKey("frequency")) {
            lastFrequency = "${jsonResponse['frequency']} Hz";
            _frequencyController.sink.add(lastFrequency); // ✅ Push real-time updates
            print("Updated Frequency: $lastFrequency"); // Debugging output
          }
        },
        onError: (error) {
          print("WebSocket Error: $error");
          isConnected = false;
          _reconnect();
        },
        onDone: () {
          print("WebSocket Disconnected!");
          isConnected = false;
          _reconnect();
        },
      );
    } catch (e) {
      print("WebSocket Connection Failed: $e");
      isConnected = false;
      _reconnect();
    }
  }

  void _reconnect() {
    Future.delayed(Duration(seconds: 3), () {
      if (!isConnected) {
        print("Reconnecting to WebSocket...");
        _connect();
      }
    });
  }

  Stream<String> get frequencyStream => _frequencyController.stream; // ✅ Ensure real-time updates

  String getFrequency() => lastFrequency;

  bool getConnectionStatus() => isConnected;
}
