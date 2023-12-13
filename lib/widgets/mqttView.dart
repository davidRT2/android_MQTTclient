import 'dart:io' show Platform;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temprature_monitor/mqtt/state/MQTTAppState.dart';
import 'package:temprature_monitor/mqtt/MQTTManager.dart';

class MQTTView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final String _topiSubscribe = "UAS-IOT/43321118/data";
  bool _led1Status = false;
  bool _led2Status = false;
  bool _led3Status = false;

  late MQTTAppState currentAppState;
  late MQTTManager manager;

  @override
  void initState() {
    super.initState();

    /*
    _hostTextController.addListener(_printLatestValue);
    _messageTextController.addListener(_printLatestValue);
    _topicTextController.addListener(_printLatestValue);

     */
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  /*
  _printLatestValue() {
    print("Second text field: ${_hostTextController.text}");
    print("Second text field: ${_messageTextController.text}");
    print("Second text field: ${_topicTextController.text}");
  }

   */

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    final Scaffold scaffold = Scaffold(body: _buildColumn());
    return scaffold;
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Aku David dan aku bahagia 😥'),
      backgroundColor: const Color.fromARGB(255, 10, 184, 100),
    );
  }

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        // _buildAppBar(context),  // Add this line to include the app bar
        // _buildConnectionStateText(
        //     _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
        _buildEditableColumn(),
        // _buildScrollableTextWith(currentAppState.getHistoryText),
        // Show Snackbar based on connection state
        _buildSensorDataCard(),
        // _buildLEDControlCard(),
        _showStatusSnackbar(),
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
  // ... (rest of your existing _MQTTViewState class)

  Widget _showStatusSnackbar() {
    return Builder(
      builder: (BuildContext context) {
        String snackbarMessage = '';
        IconData snackbarIcon = Icons.info; // Default icon
        Color snackbarColor = Colors.black; // Default color

        if (currentAppState.getAppConnectionState ==
                MQTTAppConnectionState.connected &&
            currentAppState.isFirstConnection) {
          // Hanya tampilkan pesan snackbar saat status terhubung (connected)
          currentAppState.setFirstConnection(false);
          snackbarMessage =
              'Connected! Already subscribed to \n' + _topiSubscribe;
          snackbarIcon = Icons.check;
          snackbarColor = Colors.green;
        } else if (currentAppState.getAppConnectionState ==
            MQTTAppConnectionState.disconnected) {
          currentAppState.setFirstConnection(true);
          snackbarMessage = 'Disconnected!';
          snackbarIcon = Icons.clear;
          snackbarColor = Colors.red;
        } else if (currentAppState.getAppConnectionState ==
            MQTTAppConnectionState.connecting) {
          snackbarMessage = 'Proses...';
          snackbarColor = Colors.blue;
        }

        if (snackbarMessage.isNotEmpty) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    if (currentAppState.getAppConnectionState ==
                        MQTTAppConnectionState.connecting)
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    else
                      Icon(snackbarIcon, color: Colors.white),
                    SizedBox(width: 10),
                    Text(snackbarMessage),
                  ],
                ),
                duration: Duration(seconds: 3),
                backgroundColor: snackbarColor,
              ),
            );
          });
        }

        return Container();
      },
    );
  }

  Widget _buildEditableColumn() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          _buildTextFieldWith(_usernameTextController, 'Enter your username',
              currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          _buildTextFieldWith(_passwordTextController, 'Enter your password',
              currentAppState.getAppConnectionState),
          _buildTextFieldWith(_hostTextController, 'Enter broker address',
              currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          // _buildTextFieldWith(
          //     _topicTextController,
          //     'Enter a topic to subscribe or listen',
          //     currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          _buildPublishMessageRow(),
          const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState)
        ],
      ),
    );
  }

  // Widget _buildPublishMessageRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: <Widget>[
  //       Expanded(
  //         child: _buildTextFieldWith(_messageTextController, 'Enter a message',
  //             currentAppState.getAppConnectionState),
  //       ),
  //       _buildSendButtonFrom(currentAppState.getAppConnectionState)
  //     ],
  //   );
  // }
  Widget _buildPublishMessageRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Expanded(
        child: _buildTextFieldWith(_messageTextController, 'Kendali DHT MUEHEHEHEE',
            currentAppState.getAppConnectionState),
      ),
      _buildSendButton(1), // Tombol untuk mengirim status go (payload: 1)
      _buildSendButton(0), // Tombol untuk mengirim status stop (payload: 0)
    ],
  );
}

Widget _buildSendButton(int status) {
  return ElevatedButton(
    onPressed: () {
      // Gantilah `yourJsonKey` dengan kunci yang sesuai di dalam JSON Anda.
      // Sesuaikan payload sesuai dengan nilai status yang dipilih.
      var jsonPayload = {'status': status};
      var jsonString = jsonEncode(jsonPayload);
      // Kirim JSON ke tempat yang sesuai, seperti melalui socket atau HTTP request.
      // Gantilah 'sendJsonPayload' dengan metode yang sesuai untuk pengiriman.
      manager.publish(status.toString());

      // Jika status adalah 0, set temperature dan humidity di appState ke 0.0.
      if (status == 0) {
        currentAppState.setTemperature(0.0);
        currentAppState.setHumidity(0.0);
      }
    },
    child: Text(status == 1 ? 'Go' : 'Stop'), // Ubah teks tombol sesuai dengan status.
  );
}


  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.deepOrange,
              child: Text(status, textAlign: TextAlign.center)),
        ),
      ],
    );
  }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if (controller == _messageTextController &&
        state == MQTTAppConnectionState.connected) {
      shouldEnable = true;
    } else if ((controller == _hostTextController ||
            controller == _usernameTextController ||
            controller == _passwordTextController) &&
        state == MQTTAppConnectionState.disconnected) {
      shouldEnable = true;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 400,
        height: 200,
        child: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            child: const Text('Connect'),
            style: ElevatedButton.styleFrom(
              primary: Colors.lightBlueAccent,
            ),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null, //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // ignore: deprecated_member_use
          child: ElevatedButton(
            child: const Text('Disconnect'),
            style: ElevatedButton.styleFrom(primary: Colors.red),
            onPressed: state == MQTTAppConnectionState.connected
                ? _disconnect
                : null, //
          ),
        ),
      ],
    );
  }

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    // ignore: deprecated_member_use
    return ElevatedButton(
      child: const Text('Send'),
      style: ElevatedButton.styleFrom(
        primary: Colors.green,
      ),
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              _publishMessage(_messageTextController.text);
            }
          : null, //
    );
  }

  // Utility functions
  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  void _configureAndConnect() {
    // ignore: flutter_style_todos
    // TODO: Use UUID
    String osPrefix = 'David_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'David_andro';
    }

    manager = MQTTManager(
        username: _usernameTextController.text,
        password: _passwordTextController.text,
        host: _hostTextController.text,
        topic: _topiSubscribe,
        identifier: osPrefix,
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }

  void _publishMessage(String text) {
    String osPrefix = 'David_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'David_Android';
    }
    final String message = osPrefix + ' says: ' + text;
    manager.publish(message);
    _messageTextController.clear();
  }
   Widget _buildLEDControlCard() {
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
            _buildLEDSwitch('LED 1', _led1Status, (value) {
              setState(() {
                _led1Status = value;
              });
              _publishLEDStatus();
            }),
            _buildLEDSwitch('LED 2', _led2Status, (value) {
              setState(() {
                _led2Status = value;
              });
              _publishLEDStatus();
            }),
            _buildLEDSwitch('LED 3', _led3Status, (value) {
              setState(() {
                _led3Status = value;
              });
              _publishLEDStatus();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLEDSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Function to publish LED statuses as JSON to MQTT
  void _publishLEDStatus() {
    final Map<String, dynamic> ledStatusJson = {
      'led1': _led1Status,
      'led2': _led2Status,
      'led3': _led3Status,
    };

    final String ledStatusMessage = json.encode(ledStatusJson);
    manager.publish(ledStatusMessage);
  }
}

Widget _buildBottomNavigationBar() {
  return BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ],
    currentIndex: 0, // Indeks halaman saat ini
    selectedItemColor: Colors.amber[800],
    onTap: _onBottomNavigationBarTapped,
  );
}

void _onBottomNavigationBarTapped(int index) {
  // Handle navigasi antar halaman sesuai dengan indeks yang dipilih
  // Misalnya, menggunakan Navigator.push atau mengubah state widget.
  print('BottomNavigationBar tapped: $index');
}
