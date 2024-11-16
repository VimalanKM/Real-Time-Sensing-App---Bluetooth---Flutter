import 'package:equity_ware_app_flutter/screens/partials.dart';
import 'package:equity_ware_app_flutter/services/ble_service.dart';
import 'package:equity_ware_app_flutter/services/location_service.dart';
import 'package:equity_ware_app_flutter/services/location_share_service.dart';
import 'package:equity_ware_app_flutter/services/map_marker_service.dart';
import 'package:equity_ware_app_flutter/services/notification_service.dart';
import 'package:equity_ware_app_flutter/services/ws_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:equity_ware_app_flutter/types.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Map<EventType, bool> mapLandmarkFilter =
      Map.fromEntries(EventType.values.map((elem) => MapEntry(elem, true)));

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();

    LocationService().init();
    BLEService().init();
    LocationShareService().init();
    MapMarkerService().init(() => setState(() {}));
    NotificationService().init();
    WSService().init((event) => alertOnUnsafe(context, event));

    LocationService().addLocationChangeListener("update-me", (event) {
      setState(() {
        MapMarkerService().updateCurrentPosition(event);
      });
    });
    LocationService().addLocationPoller("update-server", 5, (event) {
      LocationShareService().pushLocationShare(event, () {},
          onUpdate: (List<Event> people) {
        setState(() {
          MapMarkerService().updatePeople(people);
        });
      });
    });
    // BLEService().motionAndAudioSubscriber.addSubscriber((event) {
    //   alertOnUnsafe(context);
    // });
  }

  static String formatDateTime(DateTime dateTime) {
    // Function to get the day suffix
    String getDaySuffix(int day) {
      if (day >= 11 && day <= 13) {
        return 'th';
      }
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    // Formatting day with suffix
    String day = dateTime.day.toString();
    String daySuffix = getDaySuffix(dateTime.day);

    // Formatting month
    String month = DateFormat('MMMM').format(dateTime);

    // Formatting year
    String year = dateTime.year.toString();

    // Formatting time
    String time = DateFormat('h:mm a').format(dateTime).toLowerCase();

    return '$day$daySuffix $month, $year. $time';
  }

  void _markerOnFocusDefault(Event event) {
    showModalBottomSheet(
        context: context,
        constraints: const BoxConstraints.expand(),
        builder: (context) {
          return Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(event.description,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 30),
                  Center(child: Icon(event.type.getIcon(), size: 128)),
                  const SizedBox(height: 30),
                  Table(
                    children: [
                      const TableRow(children: [
                        Text("Latitude",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            )),
                        Text("Longitude",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ))
                      ]),
                      TableRow(children: [
                        Text(event.location.latitude.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            )),
                        Text(event.location.longitude.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ))
                      ])
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Text(event.location.toString()),
                  Row(
                    children: [
                      const Text("Time: ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          )),
                      Text(formatDateTime(event.timestamp),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          )),
                    ],
                  )
                ],
              ));
        });
    MapMarkerService().toMapFocus(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safe Wear"),
        actions: [
          IconButton(
              onPressed: () {
                debugPrint("Hello: ${LocationShareService().isActive}");
                if (!LocationShareService().isActive) {
                  LocationShareService().startLocationShare(
                    () {
                      debugPrint("sharing");
                      setState(() {});
                    },
                  );
                }
                showModalBottomSheet(
                    constraints: const BoxConstraints.expand(),
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Share",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            LocationShareService().currentPin != ""
                                ? Text(
                                    "Share PIN: ${LocationShareService().currentPin}")
                                : LocationShareService().isActive
                                    ? const Text(
                                        "Cannot share session - not owner.")
                                    : const Text(
                                        "Creating Location Share Session..."),
                            Text(
                                "Share ID: ${LocationShareService().currentShare}")
                          ],
                        ),
                      );
                    });
              },
              icon: const Icon(Icons.outbox_outlined))
        ],
      ),
      drawer: Drawer(
          child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: ListView(
                children: [
                  const ListTile(title: Text("Filter Events:")),
                  ...mapLandmarkFilter.keys.map((EventType key) {
                    return SwitchListTile(
                        title: Text(key.toString()),
                        value: mapLandmarkFilter[key]!,
                        onChanged: (bool value) {
                          setState(() {
                            mapLandmarkFilter[key] = value;
                          });
                        },
                        activeColor: const Color.fromRGBO(69, 103, 81, 1.0),
                        activeTrackColor:
                            const Color.fromRGBO(69, 103, 81, 0.5));
                  }).toList(),
                  // const Divider(),
                  // const ListTile(title: Text("Filter Time:")),
                ],
              ))),
      body: FlutterMap(
        mapController: MapMarkerService().getController(),
        options: MapOptions(
          keepAlive: true,
          maxZoom: 18,
          interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          center: MapMarkerService().center(),
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: MapMarkerService()
                .getMarkers(mapLandmarkFilter, _markerOnFocusDefault),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => MapMarkerService().toMapCenter(),
        shape: const CircleBorder(),
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
