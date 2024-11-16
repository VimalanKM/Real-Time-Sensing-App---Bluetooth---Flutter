import 'dart:async';

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings.dart';
import 'screens/bluetooth_screen.dart';
import 'services/notification_service.dart';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  await NotificationService().notify(NotificationObject(
      id: 1, title: "from background", body: "${DateTime.now()}", payload: ""));
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  // if (service is AndroidServiceInstance) {
  //   service.on('setAsForeground').listen((event) {
  //     service.setAsForegroundService();
  //   });

  //   service.on('setAsBackground').listen((event) {
  //     service.setAsBackgroundService();
  //   });
  // }

  // service.on('stopService').listen((event) {
  //   service.stopSelf();
  // });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.

        // if you don't using custom notification, uncomment this
        service.setForegroundNotificationInfo(
          title: "My App Service",
          content: "Updated at ${DateTime.now()}",
        );
      }
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    print(await preferences.getStringList('log') ?? <String>[]);

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    // final deviceInfo = DeviceInfoPlugin();
    // String? device;
    // if (Platform.isAndroid) {
    //   final androidInfo = await deviceInfo.androidInfo;
    //   device = androidInfo.model;
    // } else if (Platform.isIOS) {
    //   final iosInfo = await deviceInfo.iosInfo;
    //   device = iosInfo.model;
    // }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": "test",
      },
    );
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  // await initializeService();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    // NotificationsPage(),
    HomeScreen(),
    BluetoothScreen(),
    SettingsPage(),
    // this is where you add the other screens
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeWear',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.circle_notifications),
            //   label: 'Alerts',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth),
              label: 'Bluetooth',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),

            // Add other navigation bar items here
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromRGBO(69, 103, 81, 1.0),
          unselectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
