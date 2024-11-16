import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class AlertDetailsPage extends StatelessWidget {
  final Map<String, dynamic> alert;
  final TextStyle _titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  

  AlertDetailsPage({required this.alert});

  // Helper function to format date and time
  String _formatDateTime(String date, String time) {
    final DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$date $time');
    final String formattedDate = DateFormat('MMMM d\'th\', yyyy').format(dateTime);
    final String formattedTime = DateFormat('h:mm a').format(dateTime);
    return '$formattedDate at $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    // Parse the latitude and longitude strings into doubles
    final double lat = double.parse(alert['latitude']);
    final double lon = double.parse(alert['longitude']);
    final LatLng alertPosition = LatLng(lat, lon);

    // Create a marker for the alert position
    final Marker alertMarker = Marker(
      width: 80.0,
      height: 80.0,
      point: alertPosition,
      builder: (ctx) => Container(
        child: Icon(Icons.location_pin, color: Colors.red,),
      ),
    );

    // Format date and time
    final String formattedDateTime = _formatDateTime(alert['date'], alert['time']);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(alert['title'], style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(69, 103, 81, 1.0),
      ),
      body: Column(
        children: [
          Container(
            height: 450,
            child: FlutterMap(
              mapController: MapController(),
              options: MapOptions(
                center: alertPosition,
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [alertMarker],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), 
            child: ListTile(
              title: Center(child: Text('Time and Date', style: _titleStyle)),
              subtitle: Center(child: Text(formattedDateTime, style: TextStyle(color: Colors.black))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), 
            child: ListTile(
              title: Center(child: Text('Location', style: _titleStyle)),
              subtitle: Center(child: Text('${alert['latitude']}, ${alert['longitude']}', style: TextStyle(color: Colors.black))),
            ),
          ),
        ],
      ),
    );
  }
}
