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
                      const Text("Not connected to Device."),
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
