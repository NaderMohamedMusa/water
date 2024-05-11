import 'dart:developer';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:water/histore_screen.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'bluetooth/ChatPage.dart';
import 'bluetooth/SelectBondedDevicePage.dart';

class MyHomePage extends StatefulWidget {
  final User user;

  const MyHomePage(this.user, {super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  String firstName = '';
  String lastName = '';
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
  bool connectivityStatus = false;

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    });
    _fetchData();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      _database.child('users/${widget.user.uid}').onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          var userData = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            firstName = userData['firstName'].toString();
            lastName = userData['lastName'].toString();
          });
        }
      });
    } catch (error) {
      log('Error fetching user data: $error');
    }
  }

  Future<void> _fetchData() async {
    try {
      _database.child("Oxygenr").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          oxygenR = snapshot.value as String;
          setState(() {});
        }
      });

      _database.child("PHr").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          phR = snapshot.value as String;
          setState(() {});
        }
      });

      _database.child("TDSr").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          tdsR = snapshot.value as String;
          setState(() {});
        }
      });

      _database.child("Turbidityr").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          turbidityR = snapshot.value as String;
          setState(() {});
        }
      });

      _database.child("Temperaturer").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          temperatureR = snapshot.value as String;
          setState(() {});
        }
      });

      _database.child("Oxygen").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          var oxygenData = snapshot.value as Map<dynamic, dynamic>;
          oxygenData.forEach((k, v) {
            log('k oxygen data: $k');
            log('v oxygen data: $v');
            oxygen.add([k, v]);
          });
          setState(() {});
        }
      });

      _database.child("PH").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          var pPHData = snapshot.value as Map<dynamic, dynamic>;
          pPHData.forEach((k, v) {
            ph.add([k, v]);
          });
          setState(() {});
        }
      });

      _database.child("TDS").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          var tTDSData = snapshot.value as Map<dynamic, dynamic>;
          tTDSData.forEach((k, v) {
            tds.add([k, v]);
          });
          setState(() {});
        }
      });

      _database.child("Turbidity").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          var tTurbidityData = snapshot.value as Map<dynamic, dynamic>;
          tTurbidityData.forEach((k, v) {
            turbidity.add([k, v]);
          });
          setState(() {});
        }
      });

      _database.child("Temperature").onValue.listen((event) {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          var tTemperatureData = snapshot.value as Map<dynamic, dynamic>;
          tTemperatureData.forEach((k, v) {
            temperature.add([k, v]);
          });
          setState(() {});
        }
      });

      log('oxygen data: ${oxygen.length}');
      log('PH data: ${ph.length}');
      log('tds data: ${tds.length}');
      log('temperature data: ${temperature.length}');
      log('turbidity data: ${turbidity.length}');
    } catch (error) {
      log('Error fetching user data: $error');
    }
  }

  Future<void> _uploadData() async {
    try {
      _database.child('Oxygen').child(dateNow).set(oxygenR);
      _database.child('PH').child(dateNow).set(phR);
      _database.child('TDS').child(dateNow).set(tdsR);
      _database.child('Turbidity').child(dateNow).set(turbidityR);
      _database.child('Temperature').child(dateNow).set(temperatureR);
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

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      showOfflineBanner: false,
        builder: (context, isOnline) => Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
          actions: [
            IconButton(
                onPressed: () async {
                  final BluetoothDevice? selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const SelectBondedDevicePage(
                            checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    log('Connect -> selected ${selectedDevice.address}');
                    startChat(selectedDevice);
                  } else {
                    log('Connect -> no device selected');
                  }
                },
                icon: const Icon(Icons.bluetooth)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.wifi))
          ],
        ),
        floatingActionButton: isOnline
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
            : const SizedBox(),
        body: isOnline
            ? SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $firstName $lastName',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
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
                10,
              ),

              // TURBIDITY : 0:1000
              const SizedBox(height: 20),
              _buildType("Water PH", phR, Icons.ac_unit, Colors.blue,
                  ph, 14, 1),
              const SizedBox(height: 20),
              _buildType("Desolved oxygen", oxygenR, Icons.bubble_chart,
                  Colors.purple, oxygen, 150, 5),
              const SizedBox(height: 20),
              _buildType("TDS", tdsR, Icons.blur_on, Colors.green, tds,
                  500, 10),
              const SizedBox(height: 20),
              _buildType(
                "Turbidity",
                turbidityR,
                Icons.cloud,
                Colors.orange,
                turbidity,
                1000,
                10,
              ),
              const SizedBox(height: 100),
            ],
          ),
        )
            : const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "No Internet ?",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 30),
              Text("Connect with bluetooth"),
              SizedBox(height: 10),
            ],
          ),
        ),
    ));
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

  void startChat(BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}
