import 'package:flutter/material.dart';
import 'package:temprature_monitor/mqtt/state/MQTTAppState.dart';
import 'package:temprature_monitor/mqtt/MQTTManager.dart';
import 'package:provider/provider.dart';

class MonitorView extends StatefulWidget {
  @override
  _MonitorViewState createState() => _MonitorViewState();
}

class _MonitorViewState extends State<MonitorView> {
  late MQTTAppState currentAppState;
  late MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;

    return _buildColumn();
  }

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        _buildSensorDataCard(),
        _buildLEDSwitchCard(),
      ],
    );
  }

  Widget _buildSensorDataCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(20.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.thermostat, color: Colors.red, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Temperature',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  '${currentAppState.getTemperature} °C',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 15),
            Divider(color: Colors.grey),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.opacity, color: Colors.blue, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Humidity',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  '${currentAppState.getHumidity} %',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLEDSwitchCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(20.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'LED Control',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            _buildLEDSwitch('LED 1'),
            _buildLEDSwitch('LED 2'),
            _buildLEDSwitch('LED 3'),
          ],
        ),
      ),
    );
  }

  Widget _buildLEDSwitch(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18),
        ),
        Switch(
          value: false, // Sesuaikan dengan status LED
          onChanged: (value) {
            // Logika untuk mengubah status LED sesuai dengan value
          },
        ),
      ],
    );
  }
}
