import 'package:flutter/material.dart';
import "alertDetail.dart"; 

class NotificationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> alerts = [
    {
        'title': 'Footsteps',
        'subtitle': 'Pilsen',
        'latitude': '41.8566',
        'longitude': '-87.6612',
        'time': '14:35',
        'date': '2024-02-11',
    },
    {
        'title': 'Person Approaching',
        'subtitle': 'Little Village',
        'latitude': '41.8456',
        'longitude': '-87.7050',
        'time': '22:10',
        'date': '2024-02-10',
    },
    {
        'title': 'Vehicle Approaching',
        'subtitle': 'Pilsen',
        'latitude': '41.8566',
        'longitude': '-87.6612',
        'time': '19:20',
        'date': '2024-02-09',
    },
    {
        'title': 'Key Jingle',
        'subtitle': 'Pilsen',
        'latitude': '41.8566',
        'longitude': '-87.6612',
        'time': '18:45',
        'date': '2024-02-08',
    },
    {
        'title': 'Rustling Leaves',
        'subtitle': 'Pilsen',
        'latitude': '41.8566',
        'longitude': '-87.6612',
        'time': '17:00',
        'date': '2024-02-07',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            color: Color.fromRGBO(69, 103, 81, 1.0),
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.white),
              title: Text(
                alerts[index]['title'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                alerts[index]['subtitle'],
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                // Navigate to the details page on tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlertDetailsPage(alert: alerts[index]),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}