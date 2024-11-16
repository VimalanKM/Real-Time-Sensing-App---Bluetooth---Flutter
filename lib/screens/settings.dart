import 'package:equity_ware_app_flutter/types.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<EventType, bool> trackingOptions =
      Map.fromEntries(EventType.values.map((elem) => MapEntry(elem, true)));

  String locationFrequency = 'Every Minute';

  final List<String> frequencyOptions = [
    'Every Second',
    'Every Minute',
    'Every 5 Minutes',
    'Every 10 Minutes',
    'Every 30 Minutes',
    'Every Hour',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ...trackingOptions.keys.map((EventType key) {
            return SwitchListTile(
                title: Text(key.toString()),
                value: trackingOptions[key]!,
                onChanged: (bool value) {
                  setState(() {
                    trackingOptions[key] = value;
                  });
                  ;
                },
                activeColor: Color.fromRGBO(69, 103, 81, 1.0),
                activeTrackColor: Color.fromRGBO(69, 103, 81, 0.5));
          }).toList(),
          // Divider(),
          // ListTile(
          //   title: Text('Location Update Frequency'),
          //   trailing: DropdownButton<String>(
          //     value: locationFrequency,
          //     onChanged: (String? newValue) {
          //       setState(() {
          //         locationFrequency = newValue!;
          //       });
          //     },
          //     items: frequencyOptions
          //         .map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //   ),
          // ),
        ],
      ),
    );
  }
}
