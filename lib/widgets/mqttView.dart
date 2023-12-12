import 'dart:io' show Platform;
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
      backgroundColor: Colors.greenAccent,
    );
  }

  Widget _buildColumn() {
  return Column(
    children: <Widget>[
      _buildAppBar(context),  // Add this line to include the app bar
      // _buildConnectionStateText(
      //     _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
      _buildEditableColumn(),
      // _buildScrollableTextWith(currentAppState.getHistoryText),
      // Show Snackbar based on connection state
      _buildStatusCard(),
      _showStatusSnackbar(),
    ],
  );
}
  Widget _buildStatusCard() {
  return Card(
    elevation: 5,
    margin: const EdgeInsets.all(20.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Temperature: ${currentAppState.getTemperature} °C',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Humidity: ${currentAppState.getHumidity} %',
            style: TextStyle(fontSize: 16),
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

      switch (currentAppState.getAppConnectionState) {
        case MQTTAppConnectionState.connected:
          snackbarMessage = 'Connected! Already subscribed to \n' + _topiSubscribe;
          snackbarIcon = Icons.check;
          snackbarColor = Colors.green;
          break;
        case MQTTAppConnectionState.disconnected:
          snackbarMessage = 'Disconnected!';
          snackbarIcon = Icons.clear;
          snackbarColor = Colors.red;
          break;
        case MQTTAppConnectionState.connecting:
          snackbarMessage = 'Proses...';
          snackbarColor = Colors.blue;
          break;
        // Add other cases as needed
        default:
          snackbarMessage = 'Unknown state';
      }

      if (snackbarMessage.isNotEmpty) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  if (currentAppState.getAppConnectionState == MQTTAppConnectionState.connecting)
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

  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildTextFieldWith(_messageTextController, 'Enter a message',
              currentAppState.getAppConnectionState),
        ),
        _buildSendButtonFrom(currentAppState.getAppConnectionState)
      ],
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.deepOrangeAccent,
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
}
