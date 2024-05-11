import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
import './BluetoothDeviceListEntry.dart';

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}
class SelectBondedDevicePage extends StatefulWidget {
  final bool checkAvailability;
  const SelectBondedDevicePage({super.key,
    this.checkAvailability = true});
  @override
  State<SelectBondedDevicePage>
  createState() => _SelectBondedDevicePage();
}
class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;
  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}
class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {
  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>.empty(growable: true);
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool _isDiscovering = false;
  _SelectBondedDevicePage();

  @override
  void initState() {
    super.initState();
    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var device = i.current;
          if (device.device == r.device) {
            device.availability = _DeviceAvailability.yes;
            device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    _discoveryStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map((device) => BluetoothDeviceListEntry(
              device: device.device,
              rssi: device.rssi,
              enabled: device.availability == _DeviceAvailability.yes,
              onTap: () {
                Navigator.of(context).pop(device.device);
              },
            ))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select device'),

        actions: <Widget>[
          _isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                      Icons.replay,
                    color: Colors.black,
                  ),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: ListView(children: list),
    );
  }
}