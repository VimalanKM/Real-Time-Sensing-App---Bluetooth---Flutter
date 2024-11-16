import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

@pragma('vm:entry-point')
void _notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

// Please please please please change this in the future
class NotificationService {
  // creates an instance of the Singleton class
  static final NotificationService _singleton = NotificationService._internal();
  // final StreamController<String?> _selectNotificationStream =
  //     StreamController<String?>.broadcast();

  final StreamController<NotificationObject>
      _didReceiveLocalNotificationStream =
      StreamController<NotificationObject>.broadcast();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> notify(NotificationObject notification) async {
    const NotificationDetails notificationDetails = NotificationDetails();
    await _flutterLocalNotificationsPlugin.show(notification.id,
        notification.title, notification.body, notificationDetails,
        payload: notification.payload);
  }

  factory NotificationService() {
    return _singleton;
  }
  NotificationService._internal();
  Future<void> init() async {
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      requestCriticalPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        _didReceiveLocalNotificationStream.add(
          NotificationObject(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      // android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      // linux: initializationSettingsLinux,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // switch (notificationResponse.notificationResponseType) {
        //   case NotificationResponseType.selectedNotification:
        //     selectNotificationStream.add(notificationResponse.payload);
        //     break;
        //   case NotificationResponseType.selectedNotificationAction:
        //     if (notificationResponse.actionId == navigationActionId) {
        //       selectNotificationStream.add(notificationResponse.payload);
        //     }
        //     break;
        // }
        print(notificationResponse.toString());
      },
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );
  }
}

class NotificationObject {
  NotificationObject({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
