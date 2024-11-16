import 'dart:convert';

import 'package:equity_ware_app_flutter/types.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationShareService {
  static final LocationShareService _singleton =
      LocationShareService._internal();
  factory LocationShareService() {
    return _singleton;
  }
  LocationShareService._internal();

  static const String API_LOCATION = "http://3.15.229.93";
  static const String API_BASE = "api";

  bool isActive = false;
  String currentSession = "";
  String currentPin = "";
  String currentShare = "";

  String nickname = "Ananay";

  void init() {}

  void startLocationShare(void Function() onFinished) async {
    debugPrint("Starting Location Share");
    await updateLocationShare((events) {});
    if (isActive) return;

    var request = http.MultipartRequest(
        'POST', Uri.parse("$API_LOCATION/$API_BASE/create.php"));

    request.fields['pwd'] = 'test';
    request.fields['dur'] = "3600";
    request.fields['int'] = "30";
    request.fields['mod'] = "1";
    request.fields['nic'] = nickname;

    final response = await request.send();
    if (response.statusCode != 200) return;
    final lines = (await response.stream.bytesToString())
        .split("\n")
        .map((line) => line.trim())
        .toList();
    if (lines[0] != "OK") return;
    isActive = true;
    currentSession = lines[1];
    currentPin = lines[3];
    currentShare = lines[4];
    debugPrint(
        "location: $isActive, $currentSession, $currentPin, $currentShare");
    onFinished();
  }

  void joinLocationShare(String pin, void Function() onFinished) async {
    await updateLocationShare((events) {});
    if (isActive) return;

    var request = http.MultipartRequest(
        'POST', Uri.parse("$API_LOCATION/$API_BASE/create.php"));

    request.fields['pwd'] = 'test';
    request.fields['dur'] = "3600";
    request.fields['int'] = "30";
    request.fields['pin'] = pin;
    request.fields['mod'] = "1";
    request.fields['nic'] = nickname;

    final response = await request.send();
    if (response.statusCode != 200) return;
    final lines = (await response.stream.bytesToString())
        .split("\n")
        .map((line) => line.trim())
        .toList();
    if (lines[0] != "OK") return;
    isActive = true;
    currentSession = lines[1];
    currentShare = lines[3];
    print("location: $isActive, $currentSession, $currentPin, $currentShare");
    onFinished();
  }

  Future<void> updateLocationShare(
      void Function(List<Event>) onFinished) async {
    if (!isActive) return;
    final res = await http
        .get(Uri.parse("$API_LOCATION/$API_BASE/fetch.php?id=$currentShare"));
    if (res.statusCode != 200) {
      _deactivate();
      return;
    }
    final output = jsonDecode(res.body);
    final List<Event> events = [];
    debugPrint("${res.body}, $output");
    for (var name in output['points'].keys) {
      if (output['points'][name].isEmpty) {
        continue;
      }
      events.add(Event(
        type: EventType.person,
        title: name,
        description: "$name is sharing their location with you",
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(output['points'][name][0][2]),
        location: LatLng(
          output['points'][name][0][0],
          output['points'][name][0][1],
        ),
      ));
    }
    onFinished(events);
  }

  void pushLocationShare(Event locationEvent, void Function() onFinished,
      {void Function(List<Event>)? onUpdate}) async {
    await updateLocationShare(onUpdate ?? (events) {});
    if (!isActive) return;

    var request = http.MultipartRequest(
        'POST', Uri.parse("$API_LOCATION/$API_BASE/post.php"));

    request.fields['pwd'] = 'test';
    request.fields['lat'] = locationEvent.location.latitude.toString();
    request.fields['lon'] = locationEvent.location.longitude.toString();
    request.fields['time'] =
        locationEvent.timestamp.millisecondsSinceEpoch.toString();
    request.fields['sid'] = currentSession;

    final response = await request.send();
    debugPrint(
        "${response.statusCode}, ${await response.stream.bytesToString()}");
    onFinished();
  }

  void deactivate(void Function() onFinished) async {
    await updateLocationShare((events) {});
    if (!isActive) return;

    var request = http.MultipartRequest(
        'POST', Uri.parse("$API_LOCATION/$API_BASE/stop.php"));

    request.fields['pwd'] = 'test';
    request.fields['sid'] = currentSession;
    request.fields['lid'] = currentShare;

    _deactivate();
    await request.send();
    onFinished();
  }

  void _deactivate() {
    isActive = false;
    currentPin = "";
    currentSession = "";
    currentShare = "";
  }
}
