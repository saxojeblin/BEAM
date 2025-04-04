import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:async';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  List<bool> breakerStates = [true, true, true, true];

  IOWebSocketChannel? channel;
  final String esp32Ip = "192.168.4.1";
  bool isConnected = false;
  String lastFrequency = "60 Hz";

  String _batteryStatus = "Unknown";
  final StreamController<String> _batteryStatusController = StreamController<String>.broadcast();

  final StreamController<String> _frequencyController = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _eventController = StreamController<Map<String, dynamic>>.broadcast();

  // 🔒 Frequency status flags
  bool frequencyLockActive = false;
  bool frequencyResetPending = false;

  Stream<String> get frequencyStream => _frequencyController.stream;
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  Stream<String> get batteryStatusStream => _batteryStatusController.stream;
  String getBatteryStatus() => _batteryStatus;

  WebSocketService._internal() {
    _connect();
  }

  void _connect() {
    String url = "ws://$esp32Ip:81";
    try {
      channel = IOWebSocketChannel.connect(url);
      isConnected = true;
      print("✅ Connected to WebSocket Server!");

      channel!.stream.listen(
        (message) {
          final jsonResponse = jsonDecode(message);

          // Update frequency
          if (jsonResponse.containsKey("frequency")) {
            lastFrequency = "${jsonResponse['frequency']} Hz";
            _frequencyController.sink.add(lastFrequency);
          }

          // Update battery status
          if (jsonResponse.containsKey("battery")) {
            _batteryStatus = jsonResponse['battery'] == "charged" ? "Charged" : "Dead";
            _batteryStatusController.sink.add(_batteryStatus);
          }

          // Handle events
          if (jsonResponse['type'] == 'event') {
            if (jsonResponse['event'] == 'frequency_drop') {
              frequencyLockActive = true;
              frequencyResetPending = false;
            } else if (jsonResponse['event'] == 'frequency_restore') {
              frequencyLockActive = true;
              frequencyResetPending = true;
            }
            _eventController.sink.add(jsonResponse);
          }
        },
        onError: (error) {
          print("❌ WebSocket Error: $error");
          isConnected = false;
          _reconnect();
        },
        onDone: () {
          print("🔌 WebSocket Disconnected");
          isConnected = false;
          _reconnect();
        },
      );
    } catch (e) {
      print("⚠️ WebSocket Connection Failed: $e");
      isConnected = false;
      _reconnect();
    }
  }

  void updateBreakerState(int index, bool value) {
    if (index >= 0 && index < breakerStates.length) {
      breakerStates[index] = value;
    }
  }

  List<bool> getBreakerStates() => List.from(breakerStates);

  void _reconnect() {
    Future.delayed(Duration(seconds: 3), () {
      if (!isConnected) {
        print("🔁 Attempting to reconnect...");
        _connect();
      }
    });
  }

  String getFrequency() => lastFrequency;
  bool getConnectionStatus() => isConnected;

  // 👇 Access last known frequency status
  bool isFrequencyCritical() => frequencyLockActive;
  bool isResetPending() => frequencyResetPending;

  void dispose() {
    _frequencyController.close();
    _eventController.close();
    channel?.sink.close();
    _batteryStatusController.close();
  }

  void clearFrequencyStatus() {
    frequencyLockActive = false;
    frequencyResetPending = false;
  }

}
