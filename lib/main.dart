import 'package:flutter/material.dart';
import 'package:temprature_monitor/widgets/mqttView.dart';
import 'package:temprature_monitor/widgets/monitorView.dart';
import 'package:temprature_monitor/mqtt/state/MQTTAppState.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MQTTAppState()),
        ],
        child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Uas David(43321118)'),
              ),
              body: MQTTView(),
              bottomNavigationBar: _buildBottomNavigationBar(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monitor),
          label: 'Monitor',
        ),
      ],
      currentIndex: 1,
      selectedItemColor: Colors.amber[800],
      onTap: (int index) {
        _onBottomNavigationBarTapped(context, index);
      },
    );
  }

  void _onBottomNavigationBarTapped(BuildContext context, int index) {
    print('BottomNavigationBar tapped: $index');
    if (index == 0) {
      // Do nothing or navigate to home screen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MQTTView(),
      ));
    } else if (index == 1) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MonitorView(),
      ));
    }
  }
}
