import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum EventType {
  footsteps,
  running,
  engine,
  keys,
  person,
  other;

  @override
  String toString() {
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  Color getColor() {
    switch (this) {
      case footsteps:
        return Colors.green;
      case running:
        return Colors.blue;
      case engine:
        return Colors.yellow;
      case keys:
        return Colors.black;
      case person:
        return Colors.purple;
      case other:
        return Colors.orange;
    }
  }

  IconData getIcon() {
    switch (this) {
      case footsteps:
        return Icons.directions_walk;
      case running:
        return Icons.run_circle;
      case engine:
        return Icons.car_repair;
      case keys:
        return Icons.key;
      case person:
        return Icons.person;
      case other:
        return Icons.info;
    }
  }
}

class Event {
  static final Event EMPTY_EVENT = Event(
      type: EventType.other,
      title: "",
      description: "",
      timestamp: DateTime(0),
      location: const LatLng(0, 0));
  EventType type;
  String title;
  String description;
  DateTime timestamp;
  LatLng location;
  Event(
      {required this.type,
      required this.title,
      required this.description,
      required this.timestamp,
      required this.location});
}
