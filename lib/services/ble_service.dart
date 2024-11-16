import 'dart:async';
import 'dart:ffi';
import 'package:collection/collection.dart';
import 'package:equity_ware_app_flutter/services/location_service.dart';
import 'package:equity_ware_app_flutter/services/map_marker_service.dart';

import 'package:equity_ware_app_flutter/services/notification_service.dart';
import 'package:equity_ware_app_flutter/services/ws_service.dart';
import 'package:equity_ware_app_flutter/types.dart';
import 'package:flutter_blue/flutter_blue.dart';

final class BLE_MAIN_SERVICE {
  static const String MAIN_SERVICE_ID = "38673114-7bc1-4e32-9834-7e51be8fe6a8";
  static const String MOVEMENT_CHARACTERISTIC_ID =
      "639ba1c8-d356-4709-9df8-2c39156d8bf4";
  static const String DIRECTION_AND_AUDIO_CHARACTERISTIC_ID =
      "be76f066-adee-467b-8180-d0b43fa841e6";
  // static const String DIRECTION_CHARACTERISTIC_ID =
  //     "76e15a7b-ed1f-4d99-bde3-0f8e336132e2";
  // static const String PERSONALIZATION_CHARACTERISTIC_ID =
  //     "35acc144-59b7-4a22-b1ef-80e531347f45";
  static const String WIFI_SNIFFER_CHARACTERISTIC_ID =
      "07e273ad-2c77-4caa-b497-88b3d204bb1e";
}

abstract class BLESubscriber<T> {
  String name;
  final String uuid;
  BLESubscriber(this.uuid, {this.name = ""});
  List<Function(T)> listeners = [];
  void addSubscriber(Function(T) listener) {
    this.listeners.add(listener);
  }

  void process(List<int> value);

  void onEvent(T data) {
    for (Function(T) listener in listeners) {
      listener(data);
    }
  }

  void subscribe(BluetoothService service) {
    var charac = service.characteristics
        .firstWhereOrNull((charac) => charac.uuid == Guid(this.uuid));
    charac?.setNotifyValue(true);
    charac?.value.listen(this.process);
  }

  void reset() {
    this.listeners = [];
  }
}

class BLEByteSubscriber extends BLESubscriber<int> {
  BLEByteSubscriber(super.uuid, {super.name = ""});

  @override
  void process(List<int> value) {
    value.forEach(onEvent);
  }
}

class MotionAndAudioSubscriber extends BLESubscriber<Event> {
  MotionAndAudioSubscriber(super.uuid, {super.name = ""});
  @override
  void process(List<int> value) {
    print(value);
    int? data = value.firstOrNull;
    if (data == null) return;
    int motion = data ~/ 10;
    int audio = data % 10;
    String motionType = "";
    EventType audioType = EventType.other;
    switch (motion) {
      case 0:
        motionType = "Circular";
        break;
      case 1:
        motionType = "Snake";
        break;
      case 2:
        motionType = "Wave";
        break;
      case 3:
        motionType = "Other";
        break;
    }
    switch (audio) {
      case 0:
        audioType = EventType.engine;
        break;
      case 1:
        audioType = EventType.footsteps;
        break;
      case 2:
        audioType = EventType.keys;
        break;
      case 3:
        audioType = EventType.running;
        break;
      case 4:
        audioType = EventType.other;
        break;
    }
    onEvent(Event(
        type: audioType,
        title: "Detected $audioType",
        description: "$audioType was heard on the $motionType",
        timestamp: DateTime.now(),
        location: LocationService().getCurrentLocation()));
  }
}

class WifiSnifferPacket {
  String MAC;
  String SSID;
  WifiSnifferPacket(this.MAC, this.SSID);
  @override
  String toString() {
    return "MAC: $MAC, SSID: $SSID";
  }
}

class WifiSnifferGroup {
  int group;
  int length;
  List<WifiSnifferPacket> packets = [];
  WifiSnifferGroup(this.group, this.length);
}

class BLEWifiSnifferSubscriber extends BLESubscriber<List<WifiSnifferPacket>> {
  BLEWifiSnifferSubscriber(super.uuid, {super.name = ""});

  Map<int, WifiSnifferGroup> groupMap = {};

  @override
  void process(List<int> value) {
    List<String> parts = String.fromCharCodes(value).split("\t");
    if (parts.length != 4) return;
    try {
      int group = int.parse(parts[0]);
      int length = int.parse(parts[1]);
      WifiSnifferPacket packet = WifiSnifferPacket(parts[2], parts[3]);
      if (!groupMap.containsKey(group)) {
        groupMap[group] = WifiSnifferGroup(group, length);
      }
      groupMap[group]!.packets.add(packet);
      if (groupMap[group]!.packets.length == length) {
        onEvent(groupMap.remove(group)!.packets);
      }
    } catch (e) {
      // debugPrint(e.toString());
    }
  }
}

class BLEService {
  static final BLEService _singleton = BLEService._internal();
  factory BLEService() {
    return _singleton;
  }
  BLEService._internal();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool connected = false;
  bool owned = false;
  int notification_id = 0;

  BLESubscriber<int> movementSubscriber = BLEByteSubscriber(
      BLE_MAIN_SERVICE.MOVEMENT_CHARACTERISTIC_ID,
      name: "Movement");
  BLESubscriber<Event> motionAndAudioSubscriber = MotionAndAudioSubscriber(
      BLE_MAIN_SERVICE.DIRECTION_AND_AUDIO_CHARACTERISTIC_ID,
      name: "Motion and Audio");
  BLESubscriber<List<WifiSnifferPacket>> wifiSnifferSubscriber =
      BLEWifiSnifferSubscriber(BLE_MAIN_SERVICE.WIFI_SNIFFER_CHARACTERISTIC_ID,
          name: "Wifi");

  void init() {
    FlutterBlue.instance.connectedDevices
        .then((devices) => devices.forEach((device) => device.disconnect()));
    // debugPrinter(name) => (value) => print("Name: ${name} Value: ${value}");

    movementSubscriber.reset();
    motionAndAudioSubscriber.reset();
    wifiSnifferSubscriber.reset();

    // notificationPusher(name) => (value) {
    //       NotificationService().notify(NotificationObject(
    //           id: ++notification_id,
    //           title: "$name detected $name",
    //           body: "$value",
    //           payload: "$value"));
    //       // stateSetter(name, value);
    //     };

    // movementSubscriber.addSubscriber(notificationPusher("Movement"));
    // motionAndAudioSubscriber.addSubscriber((value) {
    //   NotificationService().notify(NotificationObject(
    //       id: notification_id,
    //       title: value.title,
    //       body: value.description,
    //       payload: value.description));
    // });
    // motionAndAudioSubscriber.addSubscriber(notificationPusher("Audio"));
    // motionAndAudioSubscriber
    //     .addSubscriber((value) => {MapMarkerService().addEvent(value)});
    // movementSubscriber
    //     .addSubscriber((value) => {MapMarkerService().addEvent()});

    // wifiSnifferSubscriber.addSubscriber(notificationPusher("Wifi Network"));

    movementSubscriber
        .addSubscriber((value) => WSService().pushLog("Direction", value));
    motionAndAudioSubscriber.addSubscriber((Event value) =>
        WSService().pushLog("Motion & Audio", value.description));
    wifiSnifferSubscriber
        .addSubscriber((value) => WSService().pushLog("Wifi", value));
  }

  void resetScanner() {
    FlutterBlue.instance.stopScan();
  }

  void deactivate() {
    FlutterBlue.instance.stopScan();
    FlutterBlue.instance.connectedDevices
        .then((devices) => devices.forEach((device) => device.disconnect()));
  }

  BluetoothDevice? currentDevice;
  void scanAndConnect(
      {onConnect, onDiscover, onFail, onDisconnect, onOwn}) async {
    connected = false;
    owned = false;
    currentDevice = null;
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.on) {
        _scanAndConnectOnState(
            onConnect: onConnect,
            onDiscover: onDiscover,
            onFail: onFail,
            onDisconnect: onDisconnect,
            onOwn: onOwn);
      } else {
        // debugPrint("Bluetooth not available");
      }
    });
  }

  void _scanAndConnectOnState(
      {onConnect, onDiscover, onFail, onDisconnect, onOwn}) async {
    // debugPrint("Internal: Scanning");
    try {
      var result = (await flutterBlue.scan(
        withServices: [Guid(BLE_MAIN_SERVICE.MAIN_SERVICE_ID)],
        timeout: const Duration(seconds: 10),
      ).toList())
          .firstWhereOrNull((element) => true);
      if (result == null) {
        // debugPrint("No device found");
        onFail();
        return;
      }
      try {
        await result.device.connect(timeout: const Duration(seconds: 10));
      } catch (e) {
        // debugPrint(e.toString());
        onFail();
        return;
      }
      // debugPrint("connected");
      connected = true;
      currentDevice = result.device;
      currentDevice!.state.listen((state) {
        if (state == BluetoothDeviceState.disconnected) {
          onDisconnect();
          connected = false;
          currentDevice = null;
        }
      });
      // debugPrint("connected");

      (onConnect ?? () {})();
      // debugPrint("connected");

      await currentDevice!.discoverServices();
      // debugPrint("discovered");
      (onDiscover ?? () {})();
      // debugPrint("device: ${result.device.id}");
      await currentDevice?.services.forEach((serviceList) async {
        // debugPrint("servicelist length: ${serviceList.length}");
        for (var service in serviceList) {
          // debugPrint("service: ${service.uuid}");
          if (service.uuid == Guid(BLE_MAIN_SERVICE.MAIN_SERVICE_ID)) {
            // debugPrint("owning");
            own(service, () {
              movementSubscriber.subscribe(service);
              motionAndAudioSubscriber.subscribe(service);
              wifiSnifferSubscriber.subscribe(service);
              (onOwn ?? () {})();
            }, onFail);
          }
        }
      });
    } catch (e) {
      // debugPrint(e.toString());
      if (onFail != null) onFail();
    }
  }

  void own(BluetoothService service, onOwned, onFail) {
    owned = true;
    onOwned();
  }
}
