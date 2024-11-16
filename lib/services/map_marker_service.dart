import 'package:equity_ware_app_flutter/services/location_share_service.dart';
import 'package:equity_ware_app_flutter/types.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class MapMarkerService {
  static final MapMarkerService _singleton = MapMarkerService._internal();
  factory MapMarkerService() {
    return _singleton;
  }
  MapMarkerService._internal();

  final MapController _mapController = MapController();
  List<Event> _pastEvents = [];
  Event _currentPosition = Event.EMPTY_EVENT;
  List<Event> _people = [];

  void Function() _updater = () {};

  void init(void Function() updater) {
    _updater = updater;
    _currentPosition = Event.EMPTY_EVENT;
    // toMapCenter();
    _pastEvents = [];
    _people = [];
  }

  void updateCurrentPosition(Event currentEvent) {
    if (_currentPosition == Event.EMPTY_EVENT) {
      _mapController.move(
          LatLng(
              currentEvent.location.latitude, currentEvent.location.longitude),
          15);
    }
    _currentPosition = currentEvent;
  }

  void updatePeople(List<Event> people) {
    _people = people;
  }

  void addEvent(Event event) {
    _pastEvents += [event];
  }

  void toMapFocus(Event event) {
    if ((_pastEvents.contains(event) ||
            _people.contains(event) ||
            _currentPosition == event) &&
        event != Event.EMPTY_EVENT) {
      _mapController.move(
          LatLng(event.location.latitude, event.location.longitude), 15,
          offset: const Offset(0, -200));
    }
  }

  void toMapCenter() {
    _mapController.move(
        LatLng(_currentPosition.location.latitude,
            _currentPosition.location.longitude),
        15);
  }

  Marker _getMarker(Event event, void Function(Event) onFocus, {Color? color}) {
    return Marker(
      point: event.location,
      rotate: true,
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onFocus(event),
        child: Icon(
          Icons.location_pin,
          color: color ?? event.type.getColor(),
          size: 64,
          shadows: const [
            Shadow(
              color: Colors.black,
              blurRadius: 7.0,
              offset: Offset(0, 1.0),
            )
          ],
        ),
      ),
    );
  }

  MapController getController() {
    return _mapController;
  }

  LatLng center() {
    return _currentPosition.location;
  }

  List<Marker> getMarkers(
      Map<EventType, bool> filters, void Function(Event) onFocus) {
    return [
      ...(!LocationShareService().isActive ||
              _people.isEmpty ||
              filters[EventType.person] == false)
          ? [_getMarker(_currentPosition, onFocus, color: Colors.red)]
          : [],
      ..._pastEvents
          .where((element) => filters[element.type]!)
          .map((element) => _getMarker(element, onFocus)),
      ...(filters[EventType.person] == true
          ? _people.map((element) => _getMarker(element, onFocus,
              color: LocationShareService().nickname == element.title
                  ? Colors.red
                  : null))
          : [])
    ];
  }
}
