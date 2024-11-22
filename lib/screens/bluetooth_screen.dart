/*
//BLE Flutter Code to receive float - not receiving
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:typed_data';
import 'dart:convert';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _myCharacteristic;
  String _incomingData = 'Waiting for data...';

  // Replace these with your ESP32 Service and Characteristic UUIDs
  String serviceUUID = "12345678-1234-1234-1234-1234567890ab";  // ESP32 Service UUID
  String characteristicUUID = "abcdefab-1234-5678-1234-abcdefabcdef";  // ESP32 Characteristic UUID

  @override
  void initState() {
    super.initState();
    startScan();
  }

  // Start scanning for Bluetooth devices
  void startScan() {
    flutterBlue.scan(timeout: Duration(seconds: 4)).listen((scanResult) {
      print('Found device: ${scanResult.device.name}');
      if (scanResult.device.name == 'ESP32_BLE') {  // Match with the ESP32 name
        flutterBlue.stopScan();
        print('Connecting to ESP32...');
        connectToDevice(scanResult.device);
      }
    });
  }

  // Connect to the ESP32 device
  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    print('Connected to ESP32');
    discoverServices(device);
  }

  // Discover services and characteristics
  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == serviceUUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == characteristicUUID) {
            _myCharacteristic = characteristic;
            print('Found characteristic: ${characteristic.uuid}');
            setUpNotifications(characteristic);
          }
        });
      }
    });
  }

  // Set up notifications to receive data
  void setUpNotifications(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      setState(() {
        _incomingData = _bytesToDouble(value).toString();  // Convert byte data to double
      });
      print('Received data: $_incomingData');
    });
  }

  // Convert received byte array to double (assuming it's a 4-byte float)
  double _bytesToDouble(List<int> bytes) {
    if (bytes.length == 4) {
      ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
      return byteData.getFloat32(0, Endian.little);  // Assuming little-endian format
    } else {
      return 0.0;  // Return 0.0 if the data is not of expected length
    }
  }

  @override
  void dispose() {
    super.dispose();
    _device?.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ESP32 BLE Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Received Float Data from ESP32:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              _incomingData,  // Display the received float as a string
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: startScan,
              child: Text('Scan for ESP32'),
            ),
          ],
        ),
      ),
    );
  }
}
*/



// BLE flutter code that recieves string data
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _myCharacteristic;
  String _incomingData = 'Waiting for data...';

  // Replace these with your ESP32 Service and Characteristic UUIDs
  String serviceUUID = "12345678-1234-1234-1234-1234567890ab";  // ESP32 Service UUID
  String characteristicUUID = "abcdefab-1234-5678-1234-abcdefabcdef";  // ESP32 Characteristic UUID

  @override
  void initState() {
    super.initState();
    startScan();
  }

  // Start scanning for Bluetooth devices
  void startScan() {
    flutterBlue.scan(timeout: Duration(seconds: 4)).listen((scanResult) {
      print('Found device: ${scanResult.device.name}');
      if (scanResult.device.name == 'ESP32_BLE') {  // Match with the ESP32 name
        flutterBlue.stopScan();
        print('Connecting to ESP32...');
        connectToDevice(scanResult.device);
      }
    });
  }

  // Connect to the ESP32 device
  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    print('Connected to ESP32');
    discoverServices(device);
  }

  // Discover services and characteristics
  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == serviceUUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == characteristicUUID) {
            _myCharacteristic = characteristic;
            print('Found characteristic: ${characteristic.uuid}');
            setUpNotifications(characteristic);
          }
        });
      }
    });
  }

  // Set up notifications to receive data
  void setUpNotifications(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      setState(() {
        _incomingData = String.fromCharCodes(value);
      });
      print('Received data: $_incomingData');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ESP32 BLE Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Received Data from ESP32:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              _incomingData,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: startScan,
              child: Text('Scan for ESP32'),
            ),
          ],
        ),
      ),
    );
  }
}



/*
import 'package:equity_ware_app_flutter/services/ble_service.dart';
import 'package:flutter/material.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  BLEService service = BLEService();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    BLEService().resetScanner();
  }

  @override
  void dispose() {
    BLEService().deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Connection'),
      ),
      body: Center(
        child: service.owned
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  Text("Owned Device.")
                ],
              )
            : service.connected
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.yellow,
                        size: 64,
                      ),
                      Text("Connected... Attempting to own device.")
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 64,
                      ),
                      const Text("Not connected to Electrochemical Sensing Device."),
                      ElevatedButton(
                          onPressed: loading
                              ? null
                              : () {
                                  setState(() {
                                    loading = true;
                                  });
                                  service.scanAndConnect(onDiscover: () {
                                    setState(() {
                                      loading = false;
                                    });
                                  }, onFail: () {
                                    setState(() {
                                      loading = false;
                                    });
                                  }, onDisconnect: () {
                                    setState(() {});
                                  }, onOwn: () {
                                    setState(() {});
                                  });
                                },
                          child: Text(loading ? "Connecting..." : "Connect"))
                    ],
                  ),
      ),
    );
  }
}
*/