import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<SalesData> _chartData = [];
  List<String> _logData = [];

  @override
  void initState() {
    super.initState();
    _loadLogData();
    _generateChartData();
  }

  // Load saved log data from SharedPreferences
  Future<void> _loadLogData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _logData = preferences.getStringList('log') ?? <String>[];
    });
  }

  // Generate chart data
  void _generateChartData() {
    setState(() {
      _chartData = [
        SalesData('Jan', 35),
        SalesData('Feb', 28),
        SalesData('Mar', 34),
        SalesData('Apr', 32),
        SalesData('May', 40),
        SalesData('Jun', 50),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Testing'),
      ),
      body: Center(
        child: Container(
          child: SfCartesianChart(
            // Initialize category axis
            primaryXAxis: CategoryAxis(),

            series: <LineSeries<SalesData, String>>[
              LineSeries<SalesData, String>(
                // Bind data source
                dataSource:  <SalesData>[
                  SalesData('Jan', 35),
                  SalesData('Feb', 28),
                  SalesData('Mar', 34),
                  SalesData('Apr', 32),
                  SalesData('May', 40)
                ],
                xValueMapper: (SalesData sales, _) => sales.year,
                yValueMapper: (SalesData sales, _) => sales.sales
              )
            ]
          )
        )
      )
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
