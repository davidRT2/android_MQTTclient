import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:temprature_monitor/model/sensor_data.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';
  double _temperature = 0.0;
  double _humidity = 0.0;
  bool _firstConnection = true;

  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = _historyText + '\n' + _receivedText;

    // Parse JSON payload
    try {
      final Map<String, dynamic> jsonData = json.decode(text);
      final SensorData sensorData = SensorData.fromJson(jsonData);
      _temperature = sensorData.temperature;
      _humidity = sensorData.humidity;
    } catch (e) {
      print('Error parsing JSON: $e');
    }

    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  void setFirstConnection(bool value) {
    _firstConnection = value;
    notifyListeners();
  }

  void setTemperature(double a){
    _temperature = a;
    notifyListeners();
  }

  void setHumidity(double a){
    _humidity = a;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

  double get getTemperature => _temperature;
  double get getHumidity => _humidity;
  bool get isFirstConnection => _firstConnection;
}
