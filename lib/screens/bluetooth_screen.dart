import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:syncfusion_flutter_charts/charts.dart';  // Import Syncfusion chart library
import 'dart:typed_data';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _myCharacteristic;
  List<DataPoint> _dataPoints = [];  // List to store data for the chart
  List<DataPoint> _deltaDataPoints = [];  // List to store differences for the second chart
  List<DataPoint> _deltaDataPoints2 = [];
  List<DataPoint> _deltaDataPoints3 = [];
  String _incomingData = 'Waiting for data...';
  int _dataIndex = 0;  // Counter to keep track of the number of data points
  int _dataIndex2 = 0;
  int _dataIndex3 = -200;
  int switch_range = 0;

  // Dropdown selection
  String _selectedChart = 'Square Wave';  // Default chart to display

  // Replace these with your ESP32 Service and Characteristic UUIDs
  String serviceUUID = "12345678-1234-1234-1234-1234567890ab";  // ESP32 Service UUID
  String characteristicUUID = "abcdefab-1234-5678-1234-abcdefabcdef";  // ESP32 Characteristic UUID

  // Input controllers for the text fields
  TextEditingController _timeIntervalController = TextEditingController();
  TextEditingController _maxPointsController = TextEditingController();
  
  // Square Wave parameters
  TextEditingController _rampStartVoltController = TextEditingController(text: '-400.0');
  TextEditingController _rampPeakVoltController = TextEditingController(text: '600.0');
  TextEditingController _frequencyController = TextEditingController(text: '120');
  TextEditingController _amplitudeController = TextEditingController(text: '20');
  TextEditingController _rampIncrementController = TextEditingController(text: '10');
  
  // Cyclic parameters
  TextEditingController _cyclicRampStartVoltController = TextEditingController(text: '-200.0');
  TextEditingController _cyclicRampPeakVoltController = TextEditingController(text: '600.0');
  TextEditingController _stepNumberController = TextEditingController(text: '80');
  TextEditingController _rampDurationController = TextEditingController(text: '8000');

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
        // Assuming each value is a double (8 bytes)
        double receivedValue = _bytesToDouble(value);
        _incomingData = receivedValue.toString();
        
        // Add the new data point to the chart
        _dataPoints.add(DataPoint(_dataIndex.toDouble(), receivedValue));
        _deltaDataPoints3.add(DataPoint(_dataIndex3.toDouble(), receivedValue));

        // Logic for updating _dataIndex3 in a cycle from -200mV to 600mV and back
        if (_dataIndex3 == 600) {
          switch_range = 1;
        }
        else if (_dataIndex3 == -200) {
          switch_range = 0;
        }

        if (switch_range == 0) {
          _dataIndex3 += 20;
        }
        else {
          _dataIndex3 -= 20;
        }

        // Calculate the difference between the current and previous data point
        if (_dataIndex % 2 == 0 && _dataIndex > 1) {
          double difference = (_dataPoints[_dataIndex-1].value - _dataPoints[_dataIndex].value);
          _deltaDataPoints.add(DataPoint(_dataIndex.toDouble(), difference));

          _dataIndex2++;

          if (_dataIndex2 > 0 && _dataIndex2 % 2 == 0) {
            double difference2 = (_dataPoints[_dataIndex-1].value - difference);
            _deltaDataPoints2.add(DataPoint(_dataIndex2.toDouble(), difference2));
          }
        }

        // Increment the data index
        _dataIndex++;
      });
      //print('Received data: $_incomingData');
      print('Current _deltaDataPoints: ');
        _deltaDataPoints.forEach((dataPoint) {
          print('Time: ${dataPoint.time}, Value: ${dataPoint.value}');
        });
    });
  }

  // Convert byte array to double (assuming little-endian 8 bytes)
  double _bytesToDouble(List<int> bytes) {
    if (bytes.length == 8) {
      ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
      return byteData.getFloat64(0, Endian.little);  // Read 8 bytes as double
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
      appBar: AppBar(title: Text('Bluetooth Connection')),
      body: GestureDetector(  // Wrap the body with GestureDetector
        onTap: () {
          // Dismiss keyboard when tapping outside text fields
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(  // Make the body scrollable
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Text input boxes for controlling the data or chart
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time Interval (in seconds):',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextField(
                    controller: _timeIntervalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter time interval',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Maximum Points to Display:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextField(
                    controller: _maxPointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter maximum number of points',
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: startScan,
                    child: Text('Begin Test'),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Dropdown to select chart type
              DropdownButton<String>(
                value: _selectedChart,
                items: <String>['Square Wave', 'Cyclic']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedChart = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              
              // Conditional rendering based on dropdown selection
              if (_selectedChart == 'Square Wave') 
                Column(
                  children: [
                    TextField(
                      controller: _rampStartVoltController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ramp Start Voltage (V)',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _rampPeakVoltController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ramp Peak Voltage (V)',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _frequencyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Frequency (Hz)',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _amplitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Amplitude (mV)',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _rampIncrementController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ramp Increment (mV)',
                      ),
                    ),
                  ],
                ),
              
              if (_selectedChart == 'Cyclic')
                Column(
                  children: [
                    TextField(
                      controller: _cyclicRampStartVoltController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ramp Start Voltage (V)',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _cyclicRampPeakVoltController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ramp Peak Voltage (V)',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _stepNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Step Number',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _rampDurationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ramp Duration (ms)',
                      ),
                    ),
                  ],
                ),
              
              SizedBox(height: 20),

              // Conditional chart rendering based on dropdown selection
              if (_selectedChart == 'Square Wave') 
                Container(
                  height: 250,
                  width: double.infinity,
                  child: SfCartesianChart(
                    primaryXAxis: NumericAxis(title: AxisTitle(text: 'Time')),
                    primaryYAxis: NumericAxis(title: AxisTitle(text: 'Value')),
                    series: <CartesianSeries<DataPoint, double>>[
                      LineSeries<DataPoint, double>(
                        dataSource: _deltaDataPoints3,
                        xValueMapper: (DataPoint point, _) => point.time,
                        yValueMapper: (DataPoint point, _) => point.value,
                        name: 'Data Points',
                        color: Colors.blue,
                        markerSettings: MarkerSettings(isVisible: true),
                        enableTooltip: true,
                      ),
                    ],
                  ),
                ),
              
              if (_selectedChart == 'Cyclic')
                Container(
                  height: 250,
                  width: double.infinity,
                  child: SfCartesianChart(
                    primaryXAxis: NumericAxis(title: AxisTitle(text: 'Time')),
                    primaryYAxis: NumericAxis(title: AxisTitle(text: 'Difference')),
                    series: <CartesianSeries<DataPoint, double>>[
                      LineSeries<DataPoint, double>(
                        dataSource: _deltaDataPoints2,
                        xValueMapper: (DataPoint point, _) => point.time,
                        yValueMapper: (DataPoint point, _) => point.value,
                        name: 'Data Differences',
                        color: Colors.red,
                        markerSettings: MarkerSettings(isVisible: true),
                        enableTooltip: true,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// DataPoint class to represent each data point for the chart
class DataPoint {
  final double time;  // Time or index of the data
  final double value;  // The value (double)

  DataPoint(this.time, this.value);
}





/*
//Adding a dropdown menu to choose the chart
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:syncfusion_flutter_charts/charts.dart';  // Import Syncfusion chart library
import 'dart:typed_data';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _myCharacteristic;
  List<DataPoint> _dataPoints = [];  // List to store data for the chart
  List<DataPoint> _deltaDataPoints = [];  // List to store differences for the second chart
  String _incomingData = 'Waiting for data...';
  int _dataIndex = 0;  // Counter to keep track of the number of data points

  // Dropdown selection
  String _selectedChart = 'Original Data';  // Default chart to display

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
        // Assuming each value is a double (8 bytes)
        double receivedValue = _bytesToDouble(value);
        _incomingData = receivedValue.toString();
        
        // Add the new data point to the chart
        _dataPoints.add(DataPoint(_dataIndex.toDouble(), receivedValue));

        // Calculate the difference between the current and previous data point
        if (_dataIndex % 2 == 0 && _dataIndex > 0) {
          double difference =  (_dataPoints[_dataIndex-1].value - _dataPoints[_dataIndex].value);
          _deltaDataPoints.add(DataPoint(_dataIndex.toDouble(), difference));
        }

        /*
        // Limit the graph data points if necessary
        if (_dataPoints.length > 50) {
          _dataPoints.removeAt(0);
        }
        if (_deltaDataPoints.length > 50) {
          _deltaDataPoints.removeAt(0);
        }
        */
        // Increment the data index
        _dataIndex++;
      });
      print('Received data: $_incomingData');
    });
  }

  // Convert byte array to double (assuming little-endian 8 bytes)
  double _bytesToDouble(List<int> bytes) {
    if (bytes.length == 8) {
      ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
      return byteData.getFloat64(0, Endian.little);  // Read 8 bytes as double
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
      appBar: AppBar(title: Text('Bluetooth Connection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Received User Data from Device:',
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
            SizedBox(height: 20),
            
            // Dropdown to select chart type
            DropdownButton<String>(
              value: _selectedChart,
              items: <String>['Original Data', 'Data Differences']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedChart = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            
            // Conditional rendering based on dropdown selection
            if (_selectedChart == 'Original Data') 
              Container(
                height: 250,
                width: double.infinity,
                child: SfCartesianChart(
                  primaryXAxis: NumericAxis(title: AxisTitle(text: 'Time')),
                  primaryYAxis: NumericAxis(title: AxisTitle(text: 'Value')),
                  series: <CartesianSeries<DataPoint, double>>[
                    LineSeries<DataPoint, double>(
                      dataSource: _dataPoints,
                      xValueMapper: (DataPoint point, _) => point.time,
                      yValueMapper: (DataPoint point, _) => point.value,
                      name: 'Data Points',
                      color: Colors.blue,
                      markerSettings: MarkerSettings(isVisible: true),
                      enableTooltip: true,
                    ),
                  ],
                ),
              ),
            
            if (_selectedChart == 'Data Differences')
              Container(
                height: 250,
                width: double.infinity,
                child: SfCartesianChart(
                  primaryXAxis: NumericAxis(title: AxisTitle(text: 'Time')),
                  primaryYAxis: NumericAxis(title: AxisTitle(text: 'Difference')),
                  series: <CartesianSeries<DataPoint, double>>[
                    LineSeries<DataPoint, double>(
                      dataSource: _deltaDataPoints,
                      xValueMapper: (DataPoint point, _) => point.time,
                      yValueMapper: (DataPoint point, _) => point.value,
                      name: 'Data Differences',
                      color: Colors.red,
                      markerSettings: MarkerSettings(isVisible: true),
                      enableTooltip: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// DataPoint class to represent each data point for the chart
class DataPoint {
  final double time;  // Time or index of the data
  final double value;  // The value (double)

  DataPoint(this.time, this.value);
}
*/

/*
//Flutter code receiving double value - 10 decimal places - upto 16 decimal places - added additional chart
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:syncfusion_flutter_charts/charts.dart';  // Import Syncfusion chart library
import 'dart:typed_data';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _myCharacteristic;
  List<DataPoint> _dataPoints = [];  // List to store data for the chart
  List<DataPoint> _deltaDataPoints = [];  // List to store differences for the second chart
  String _incomingData = 'Waiting for data...';
  int _dataIndex = 0;  // Counter to keep track of the number of data points

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
        // Assuming each value is a double (8 bytes)
        double receivedValue = _bytesToDouble(value);
        _incomingData = receivedValue.toString();
        
        // Add the new data point to the chart
        _dataPoints.add(DataPoint(_dataIndex.toDouble(), receivedValue));

        // Calculate the difference between the current and previous data point
        if (_dataIndex % 2 == 0 && _dataIndex > 0) {
          double difference =  (_dataPoints[_dataPoints.length - 1].value - _dataPoints[_dataPoints.length - 2].value);
          _deltaDataPoints.add(DataPoint(_dataIndex.toDouble(), difference));
        }

        /*
        // Limit the graph data points if necessary
        if (_dataPoints.length > 50) {
          _dataPoints.removeAt(0);
        }
        if (_deltaDataPoints.length > 50) {
          _deltaDataPoints.removeAt(0);
        }
        */
        // Increment the data index
        _dataIndex++;
      });
      print('Received data: $_incomingData');
    });
  }

  // Convert byte array to double (assuming little-endian 8 bytes)
  double _bytesToDouble(List<int> bytes) {
    if (bytes.length == 8) {
      ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
      return byteData.getFloat64(0, Endian.little);  // Read 8 bytes as double
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
      appBar: AppBar(title: Text('Bluetooth Connection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Received User Data from Device:',
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
            SizedBox(height: 20),
            // Plot the first chart with original data points
            Container(
              height: 250,
              width: double.infinity,
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(title: AxisTitle(text: 'Time')),
                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Value')),
                series: <CartesianSeries<DataPoint, double>>[
                  LineSeries<DataPoint, double>(
                    dataSource: _dataPoints,
                    xValueMapper: (DataPoint point, _) => point.time,
                    yValueMapper: (DataPoint point, _) => point.value,
                    name: 'Data Points',
                    color: Colors.blue,
                    markerSettings: MarkerSettings(isVisible: true),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            // Plot the second chart with the differences
            Container(
              height: 250,
              width: double.infinity,
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(title: AxisTitle(text: 'Time')),
                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Difference')),
                series: <CartesianSeries<DataPoint, double>>[
                  LineSeries<DataPoint, double>(
                    dataSource: _deltaDataPoints,
                    xValueMapper: (DataPoint point, _) => point.time,
                    yValueMapper: (DataPoint point, _) => point.value,
                    name: 'Data Differences',
                    color: Colors.red,
                    markerSettings: MarkerSettings(isVisible: true),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DataPoint class to represent each data point for the chart
class DataPoint {
  final double time;  // Time or index of the data
  final double value;  // The value (double)

  DataPoint(this.time, this.value);
}
*/


/*
//Flutter code receiving double value - 10 decimal places - upto 16 decimal places
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:syncfusion_flutter_charts/charts.dart';  // Import Syncfusion chart library
import 'dart:typed_data';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _myCharacteristic;
  List<DataPoint> _dataPoints = [];  // List to store data for the chart
  String _incomingData = 'Waiting for data...';
  int _dataIndex = 0;  // Counter to keep track of the number of data points

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
        // Assuming each value is a double (8 bytes)
        double receivedValue = _bytesToDouble(value);
        _incomingData = receivedValue.toString();
        
        // Add the new data point to the chart
        _dataPoints.add(DataPoint(_dataIndex.toDouble(), receivedValue));

        /*// Limit the graph data points if necessary
        if (_dataPoints.length > 50) {
          _dataPoints.removeAt(0);
        }*/

        // Increment the data index
        _dataIndex++;
      });
      print('Received data: $_incomingData');
    });
  }

  // Convert byte array to double (assuming little-endian 8 bytes)
  double _bytesToDouble(List<int> bytes) {
    if (bytes.length == 8) {
      ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
      return byteData.getFloat64(0, Endian.little);  // Read 8 bytes as double
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
      appBar: AppBar(title: Text('Bluetooth Connection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Received User Data from Device:',
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
            SizedBox(height: 20),
            // Plot the chart with data points
            Container(
              height: 300,
              width: double.infinity,
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(title: AxisTitle(text: 'Time')),
                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Value')),
                series: <CartesianSeries<DataPoint, double>>[
                  LineSeries<DataPoint, double>(
                    dataSource: _dataPoints,
                    xValueMapper: (DataPoint point, _) => point.time,
                    yValueMapper: (DataPoint point, _) => point.value,
                    name: 'Data Points',
                    color: Colors.blue,
                    markerSettings: MarkerSettings(isVisible: true),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DataPoint class to represent each data point for the chart
class DataPoint {
  final double time;  // Time or index of the data
  final double value;  // The value (double)

  DataPoint(this.time, this.value);
}
*/


//Flutter code to receive float
/*
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:syncfusion_flutter_charts/charts.dart';  // Import Syncfusion chart library
import 'dart:typed_data';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _myCharacteristic;
  List<DataPoint> _dataPoints = [];  // List to store data for the chart
  String _incomingData = 'Waiting for data...';
  int _dataIndex = 0;  // Counter to keep track of the number of data points

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
        // Assuming each value is a float (4 bytes)
        double receivedValue = _bytesToFloat(value);
        _incomingData = receivedValue.toString();
        
        // Add the new data point to the chart
        _dataPoints.add(DataPoint(_dataIndex.toDouble(), receivedValue));

        // Limit the graph data points if necessary
        if (_dataPoints.length > 50) {
          _dataPoints.removeAt(0);
        }

        // Increment the data index
        _dataIndex++;
      });
      print('Received data: $_incomingData');
    });
  }

  // Convert byte array to float (assuming little-endian 4 bytes)
  double _bytesToFloat(List<int> bytes) {
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
      appBar: AppBar(title: Text('Bluetooth Connection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Received Float Data from ESP32:',
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
            SizedBox(height: 20),
            // Plot the chart with data points
            Container(
              height: 300,
              width: double.infinity,
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(title: AxisTitle(text: 'Time')),
                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Value')),
                series: <CartesianSeries<DataPoint, double>>[
                  LineSeries<DataPoint, double>(
                    dataSource: _dataPoints,
                    xValueMapper: (DataPoint point, _) => point.time,
                    yValueMapper: (DataPoint point, _) => point.value,
                    name: 'Data Points',
                    color: Colors.blue,
                    markerSettings: MarkerSettings(isVisible: true),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DataPoint class to represent each data point for the chart
class DataPoint {
  final double time;  // Time or index of the data
  final double value;  // The value (float)

  DataPoint(this.time, this.value);
}
*/

/*
//BLE Flutter code receiving fp data - working
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:typed_data';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _myCharacteristic;
  String _incomingData = 'Waiting for data...';
  int _dataIndex = 0; //Keeping track of the number of data points

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
        _incomingData = _bytesToFloat(value).toStringAsFixed(2);  // Convert byte data to float
      });
      print('Received data: $_incomingData');
    });
  }

  // Convert received byte array to float (assuming it's a 4-byte float)
  double _bytesToFloat(List<int> bytes) {
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
            SizedBox(height:20),
            //Plotting graph with 
          ],
        ),
      ),
    );
  }
}
*/


/*
// BLE flutter code that recieves string data - works
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
*/


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