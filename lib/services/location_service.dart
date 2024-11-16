import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'package:equity_ware_app_flutter/types.dart';

class LocationService {
  static final LocationService _singleton = LocationService._internal();
  final Map<String, void Function(Event)> _locationChangeListeners = {};
  Event _currentLocation = Event.EMPTY_EVENT;
  final Map<String, Timer> _constantLocationPollerTimers = {};

  factory LocationService() {
    return LocationService._singleton;
  }
  LocationService._internal();

  void addLocationChangeListener(
      String name, void Function(Event) changeListener) {
    _locationChangeListeners[name] = changeListener;
  }

  void removeLocationChangeListener(String name) {
    if (_locationChangeListeners.containsKey(name)) {
      _locationChangeListeners.remove(name);
    }
  }

  void addLocationPoller(
      String name, int duration, void Function(Event) poller) {
    _constantLocationPollerTimers[name] =
        Timer.periodic(const Duration(seconds: 5), (Timer e) {
      poller(_currentLocation);
    });
  }

  void cancelLocationPoller(String name) {
    if (_constantLocationPollerTimers.containsKey(name)) {
      _constantLocationPollerTimers[name]!.cancel();
      _constantLocationPollerTimers.remove(name);
    }
  }

  LatLng getCurrentLocation() {
    return _currentLocation.location;
  }

  Future<void> init() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Geolocator.getPositionStream().listen(
      (Position position) {
        _currentLocation = Event(
            description: "Live Location of <Username>",
            title: "<Username>",
            type: EventType.person,
            timestamp: DateTime.now(),
            location: LatLng(position.latitude, position.longitude));
        _locationChangeListeners
            .forEach((_, listener) => listener(_currentLocation));
      },
    );
  }
}
