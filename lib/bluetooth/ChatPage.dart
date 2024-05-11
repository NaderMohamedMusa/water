import 'dart:developer';
import 'dart:typed_data';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import '../histore_screen.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({super.key, required this.server});

  @override
  State<ChatPage> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  BluetoothConnection? connection;
  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';
  final TextEditingController textEditingController = TextEditingController();
  bool isConnecting = true;

  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;
  String dateNow = "${DateTime.now().year}:"
      "${DateTime.now().month}:"
      "${DateTime.now().day} "
      "${DateTime.now().hour}:"
      "${DateTime.now().minute}:"
      "${DateTime.now().second}";
  String oxygenR = "0.0";
  String phR = "0.0";
  String tdsR = "0.0";
  String turbidityR = "0.0";
  String temperatureR = "0.0";
  List<List<String>> oxygen = [];
  List<List<String>> ph = [];
  List<List<String>> tds = [];
  List<List<String>> turbidity = [];
  List<List<String>> temperature = [];
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    BluetoothConnection.toAddress(widget.server.address).then((connection) {
      log('Connected to the device');
      connection = connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          log('Disconnecting locally!');
        } else {
          log('Disconnected remotely!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      log('Cannot connect, exception occured');
      log(error.toString());
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (var element in messages) {
      List dataRead = element.text.split(',');

      /// tds
      tdsR = dataRead[0];
      tds = [];
      tds.add([dateNow, tdsR]);
      log("tdsR========>>>> $tdsR");
      log("tds========>>>> ${tds.length}");

      /// temperature
      temperatureR = dataRead[1];
      temperature = [];
      temperature.add([dateNow, temperatureR]);
      log("temperatureR========>>>> $temperatureR");
      log("temperature========>>>> ${temperature.length}");

      /// ph
      phR = dataRead[2];
      ph = [];
      ph.add([dateNow, phR]);
      log("phR========>>>> $phR");
      log("ph========>>>> ${ph.length}");

      /// turbidity
      turbidityR = dataRead[3];
      turbidity = [];
      turbidity.add([dateNow, turbidityR]);
      log("turbidityR========>>>> $turbidityR");
      log("turbidity========>>>> ${turbidity.length}");

      /// oxygen
      oxygenR = dataRead[4];
      oxygen = [];
      oxygen.add([dateNow, oxygenR]);
      log("oxygenR========>>>> $oxygenR");
      log("oxygen========>>>> ${oxygen.length}");
    }

    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting to $serverName...')
              : isConnected
                  ? Text('Live chat with $serverName')
                  : Text(serverName))),
      floatingActionButton: ConnectivityWidget(
          builder: (context, isOnline) => isOnline
              ? FloatingActionButton(
                  onPressed: () {
                    _uploadData().then((value) {
                      Fluttertoast.showToast(
                        msg: "Data added successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    });
                  },
                  child: const Icon(Icons.upload),
                )
              : const SizedBox()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '  Date : $dateNow',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildType(
              "Temperature",
              "$temperatureR°C",
              Icons.thermostat,
              Colors.red,
              temperature,
              100,
              5,
            ),
            const SizedBox(height: 20),
            _buildType("Water PH", phR, Icons.ac_unit, Colors.blue, ph, 14, 1),
            const SizedBox(height: 20),
            _buildType("Desolved oxygen", oxygenR, Icons.bubble_chart,
                Colors.purple, oxygen, 150, 5),
            const SizedBox(height: 20),
            _buildType("TDS", tdsR, Icons.blur_on, Colors.green, tds, 500, 5),
            const SizedBox(height: 20),
            _buildType(
              "Turbidity",
              turbidityR,
              Icons.cloud,
              Colors.orange,
              turbidity,
              1000,
              5,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildType(
      String propertyName,
      String propertyValue,
      IconData icon,
      Color iconColor,
      List<List<String>> value,
      double maximum,
      double interval) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        width: double.infinity,
        height: 70,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            WaveWidget(
              config: CustomConfig(
                colors: [
                  const Color(0xFF00BBF9).withOpacity(0.2),
                  const Color(0xFF00BBF9).withOpacity(0.3),
                ],
                durations: [
                  9000,
                  8000,
                ],
                heightPercentages: [
                  0.35,
                  0.36,
                ],
              ),
              backgroundColor: const Color(0xFFFFFFFF),
              size: const Size(double.infinity, double.infinity),
              waveAmplitude: 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              icon,
                              color: iconColor,
                            ),
                          ),
                          Text(
                            propertyName,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ]),
                    Text(
                      propertyValue,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => HistoryScreen(
                                value: value,
                                title: propertyName,
                                maximum: maximum,
                                interval: interval,
                              ))),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "History",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 15,
                          )
                        ],
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadData() async {
    try {
      for (var element in oxygen) {
        _database.child('Oxygen').child(element[0]).set(element[1]);
      }
      for (var element in ph) {
        _database.child('PH').child(element[0]).set(element[1]);
      }
      for (var element in tds) {
        _database.child('TDS').child(element[0]).set(element[1]);
      }
      for (var element in turbidity) {
        _database.child('Turbidity').child(element[0]).set(element[1]);
      }
      for (var element in temperature) {
        _database.child('Temperature').child(element[0]).set(element[1]);
      }
    } catch (error) {
      log('Error upload data: $error');
      Fluttertoast.showToast(
        msg: "Failed to add data: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _onDataReceived(Uint8List data) {
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
