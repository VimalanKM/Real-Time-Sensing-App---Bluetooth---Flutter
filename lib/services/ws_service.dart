import 'package:equity_ware_app_flutter/services/location_service.dart';
import 'package:equity_ware_app_flutter/services/notification_service.dart';
import 'package:equity_ware_app_flutter/services/map_marker_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:equity_ware_app_flutter/types.dart';
import 'package:web_socket_channel/status.dart' as status;

class WSService {
  static final WSService _singleton = WSService._internal();
  factory WSService() {
    return _singleton;
  }
  WSService._internal();

  static final Uri _wsURL = Uri.parse("ws://18.117.99.73:80/");

  final channel = WebSocketChannel.connect(_wsURL);

  Future<void> init(void Function(Event) triggerAlert) async {
    await channel.ready;

    channel.sink.add('join');
    // channel.sink.close(status.goingAway);

    print("Init Websocket");

    channel.stream.listen((data) {
      final components = data.split(":");
      if (components.length != 3) return;
      NotificationService().notify(
        NotificationObject(
          id: 999,
          title: components[1],
          body: components[2],
          payload: components[2],
        ),
      );
      final event = Event(
          type: EventType.values.byName(components[0].toString().toLowerCase()),
          title: components[1],
          description: components[2],
          timestamp: DateTime.now(),
          location: LocationService().getCurrentLocation());
      MapMarkerService().addEvent(event);
      triggerAlert(event);
      channel.sink.add("[Manual] $data");
    });
  }

  void pushLog(tag, data) {
    channel.sink.add("[$tag] $data");
  }
}
