import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PatientData> _chartData1 = [];
  List<PatientData> _chartData2 = [];
  List<String> _logData = [];

  @override
  void initState() {
    super.initState();
    _loadLogData();
    _chartData1 = getChartData1();
    _chartData2 = getChartData2(_chartData1);
  }

  // Load saved log data from SharedPreferences
  Future<void> _loadLogData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _logData = preferences.getStringList('log') ?? <String>[];
    });
  }

  //function to return chart data
  List<PatientData> getChartData1(){
    return <PatientData> [
                  PatientData('1', 0.0000555273),
                  PatientData('2', 0.0002756368),
                  PatientData('3', 0.0000666020),
                  PatientData('4', 0.0002730220),
                  PatientData('5', 0.0000662944),
                  PatientData('6', 0.0002714838),
                  PatientData('7', 0.0000630642),
                  PatientData('8', 0.0002631779),
                  PatientData('9', 0.0000610646),
                  PatientData('10', 0.0002579481),
                  PatientData('11', 0.0000524510),
                  PatientData('12', 0.0002508726),
                  PatientData('13', 0.0000524510),
                  PatientData('14', 0.0002514879),
                  PatientData('15', 0.0000402996),
                  PatientData('16', 0.0002419513),
                  PatientData('17', 0.0000407610),
                  PatientData('18', 0.0002334915),
                  PatientData('19', 0.0000386076),
                  PatientData('20', 0.0002301076),
                  PatientData('21', 0.0000281482),
                  PatientData('22', 0.0002294923),
                  PatientData('23', 0.0000238414),
                  PatientData('24', 0.0002205710),
                  PatientData('25', 0.0000198422),
                  PatientData('26', 0.0002190329),
                  PatientData('27', 0.0000121514),
                  PatientData('28', 0.0002090349),
                  PatientData('29', 0.0000104594),
                  PatientData('30', 0.0002067277),
                  PatientData('31', 0.0000064602),
                  PatientData('32', 0.0002016517),
                  PatientData('33', -0.0000024610),
                  PatientData('34', 0.0001984216),
                  PatientData('35', -0.0000113823),
                  PatientData('36', 0.0001881160),
                  PatientData('37', -0.0000167659),
                  PatientData('38', 0.0001851935),
                  PatientData('39', -0.0000204574),
                  PatientData('40', 0.0001842706),
                  PatientData('41', -0.0000344546),
                  PatientData('42', 0.0001755032),
                  PatientData('43', -0.0000361466),
                  PatientData('44', 0.0001727345),
                  PatientData('45', -0.0000484518),
                  PatientData('46', 0.0001721192),
                  PatientData('47', -0.0000555273),
                  PatientData('48', 0.0001653514),
                  PatientData('49', -0.0000712164),
                  PatientData('50', 0.0001647361),
                  PatientData('51', -0.0000850598),
                  PatientData('52', 0.0001681201),
                  PatientData('53', -0.0001005952),
                  PatientData('54', 0.0001571991),
                  PatientData('55', -0.0001133618),
                  PatientData('56', 0.0001561224),
                  PatientData('57', -0.0001324349),
                  PatientData('58', 0.0001518156),
                  PatientData('59', -0.0001539690),
                  PatientData('60', 0.0001492008),
                  PatientData('61', -0.0001779642),
                  PatientData('62', 0.0001507389),
                  PatientData('63', -0.0002051895),
                  PatientData('64', 0.0001487393),
                  PatientData('65', -0.0002365678),
                  PatientData('66', 0.0001545843),
                  PatientData('67', -0.0002676385),
                  PatientData('68', 0.0001516618),
                  PatientData('69', -0.0003013240),
                  PatientData('70', 0.0001516618),
                  PatientData('71', -0.0003373168),
                  PatientData('72', 0.0001542767),
                  PatientData('73', -0.0003717714),
                  PatientData('74', 0.0001542767),
                  PatientData('75', -0.0004254529),
                  PatientData('76', 0.0001682739),
                  PatientData('77', -0.0004635991),
                  PatientData('78', 0.0001710425),
                  PatientData('79', -0.0005106665),
                  PatientData('80', 0.0001828863),
                  PatientData('81', -0.0005581954),
                  PatientData('82', 0.0001830401),
                  PatientData('83', -0.0006178757),
                  PatientData('84', 0.0001990369),
                  PatientData('85', -0.0006612517),
                  PatientData('86', 0.0002079582),
                  PatientData('87', -0.0007263155),
                  PatientData('88', 0.0002202634),
                  PatientData('89', -0.0007661536),
                  PatientData('90', 0.0002264160),
                  PatientData('91', -0.0008127597),
                  PatientData('92', 0.0002416437),
                  PatientData('93', -0.0008702865),
                  PatientData('94', 0.0002602553),
                  PatientData('95', -0.0009176616),
                  PatientData('96', 0.0002647160),
                  PatientData('97', -0.0009664210),
                  PatientData('98', 0.0002785594),
                  PatientData('99', -0.0010022600),
                  PatientData('100', 0.0002862501),
                  PatientData('101', -0.0010513270),
                  PatientData('102', 0.0002965558),
                  PatientData('103', -0.0010763990),
                  PatientData('104', 0.0002980939),
                  PatientData('105', -0.0011168523),
                  PatientData('106', 0.0003083995),
                  PatientData('107', -0.0011317724),
                  PatientData('108', 0.0003071690),
                  PatientData('109', -0.0011457696),
                  PatientData('110', 0.0003107067),
                  PatientData('111', -0.0011791474),
                  PatientData('112', 0.0003183975),
                  PatientData('113', -0.0011836082),
                  PatientData('114', 0.0003107067),
                  PatientData('115', -0.0011972976),
                  PatientData('116', 0.0003128602),
                  PatientData('117', -0.0011916064),
                  PatientData('118', 0.0002997859),
                  PatientData('119', -0.0011999124),
                  PatientData('120', 0.0003065537),
                  PatientData('121', -0.0011768400),
                  PatientData('122', 0.0002876344),
                  PatientData('123', -0.0011662269),
                  PatientData('124', 0.0002864040),
                  PatientData('125', -0.0011354641),
                  PatientData('126', 0.0002713301),
                  PatientData('127', -0.0010917805),
                  PatientData('128', 0.0002616397),
                  PatientData('129', -0.0010617865),
                  PatientData('130', 0.0002576405),
                  PatientData('131', -0.0010167186),
                  PatientData('132', 0.0002261084),
                  PatientData('133', -0.0009690358),
                  PatientData('134', 0.0002153413),
                  PatientData('135', -0.0009099708),
                  PatientData('136', 0.0001796562),
                  PatientData('137', -0.0008602886),
                  PatientData('138', 0.0001584297),
                  PatientData('139', -0.0007978395),
                  PatientData('140', 0.0001219755),
                  PatientData('141', -0.0007384670),
                  PatientData('142', 0.0001005952),
                  PatientData('143', -0.0006892460),
                  PatientData('144', 0.0000678325),
                  PatientData('145', -0.0006361797),
                  PatientData('146', 0.0000433759),
                  PatientData('147', -0.0005974182),
                  PatientData('148', 0.0000258410),
                  PatientData('149', -0.0005592721),
                  PatientData('150', -0.0000095365),
                  PatientData('151', -0.0005254328),
                  PatientData('152', -0.0000193807),
                  PatientData('153', -0.0004906706),
                  PatientData('154', -0.0000459907),
                  PatientData('155', -0.0004682135),
                  PatientData('156', -0.0000552197),
                  PatientData('157', -0.0004428340),
                  PatientData('158', -0.0000707550),
                  PatientData('159', -0.0004239148),
                  PatientData('160', -0.0000776767),
                  PatientData('161', -0.0004046878),
                  PatientData('162', -0.0000862903),
                  PatientData('163', -0.0003853072),
                  PatientData('164', -0.0000887514),
                  PatientData('165', -0.0003713100),
                  PatientData('166', -0.0000939811),
                  PatientData('167', -0.0003610043),
                  PatientData('168', -0.0000982879),
                  PatientData('169', -0.0003493144),
                  PatientData('170', -0.0000992108),
                  PatientData('171', -0.0003423927),
                  PatientData('172', -0.0001055172),
                  PatientData('173', -0.0003311642),
                  PatientData('174', -0.0001041329),
                  PatientData('175', -0.0003283955),
                  PatientData('176', -0.0001138233),
                  PatientData('177', -0.0003276264),
                  PatientData('178', -0.0001072092),
                  PatientData('179', -0.0003242425),
                  PatientData('180', -0.0001122851),
                  PatientData('181', -0.0003170132),
                  PatientData('182', -0.0001159767),
                  PatientData('183', -0.0003213200),
                  PatientData('184', -0.0001150538),
                  PatientData('185', -0.0003150135),
                  PatientData('186', -0.0001165919),
                  PatientData('187', -0.0003231658),
                  PatientData('188', -0.0001193606),
                  PatientData('189', -0.0003205510),
                  PatientData('190', -0.0001241289),
                  PatientData('191', -0.0003250116),
                  PatientData('192', -0.0001273590),
                  PatientData('193', -0.0003273188),
                  PatientData('194', -0.0001305891),
                  PatientData('195', -0.0003239348),
                  PatientData('196', -0.0001281281),
                  PatientData('197', -0.0003320871),
                  PatientData('198', -0.0001401257),
                  PatientData('199', -0.0003260883),
                  PatientData('200', -0.0001396642),
                  PatientData('201', -0.0003288570),
                  PatientData('202', -0.0001405871),
                  PatientData('203', -0.0003319332),
                  PatientData('204', -0.0001479702),
                  PatientData('205', -0.0003348558),
                  PatientData('206', -0.0001413562),
                  PatientData('207', -0.0003367015),
                  PatientData('208', -0.0001484317),
                  PatientData('209', -0.0003411621),
                  PatientData('210', -0.0001519694),
                  PatientData('211', -0.0003354710),
                  PatientData('212', -0.0001568915),
                  PatientData('213', -0.0003446999),
                  PatientData('214', -0.0001484317),
                  PatientData('215', -0.0003497758),
                  PatientData('216', -0.0001588911),
                  PatientData('217', -0.0003565437),
                  PatientData('218', -0.0001628903),
                  PatientData('219', -0.0003505449),
                  PatientData('220', -0.0001650437),
                  PatientData('221', -0.0003602352),
                  PatientData('222', -0.0001613521),
                  PatientData('223', -0.0003613119),
                  PatientData('224', -0.0001604293),
                  PatientData('225', -0.0003640806),
                  PatientData('226', -0.0001650437),
                  PatientData('227', -0.0003680798),
                  PatientData('228', -0.0001705811),
                  PatientData('229', -0.0003685413),
                  PatientData('230', -0.0001658128),
                  PatientData('231', -0.0003674646),
                  PatientData('232', -0.0001645823),
                  PatientData('233', -0.0003725405),
                  PatientData('234', -0.0001688891),
                  PatientData('235', -0.0003728481),
                  PatientData('236', -0.0001690429),
                  PatientData('237', -0.0003742324),
                  PatientData('238', -0.0001727345),
                  PatientData('239', -0.0003849995),
                  PatientData('240', -0.0001779642),
                  PatientData('241', -0.0003873067),
                  PatientData('242', -0.0001733497),
                  PatientData('243', -0.0003839227),
                  PatientData('244', -0.0001730421),
                  PatientData('245', -0.0003853072),
                  PatientData('246', -0.0001801176),
                  PatientData('247', -0.0003900754),
                  PatientData('248', -0.0001771951),
                  PatientData('249', -0.0003903831), 
    ];
  }

  //Function to return second chart data by subtracting current value by previous value
  List<PatientData> getChartData2(List<PatientData> data){
    List<PatientData> diffData = [];
    for(int i = 1; i < data.length; i = i+2){
      double difference = data[i-1].level - data[i].level ;
      diffData.add(PatientData(data[i].day, difference));
    }
    return diffData;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Testing'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //Chart 1
              Container(
                padding: EdgeInsets.all(5),
                height: 350,
                child: SfCartesianChart(
                  title: const ChartTitle(
                    text: 'Patient Data - Raw',
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  primaryXAxis: const CategoryAxis(
                    title: AxisTitle(
                      text: 'Time (s)',
                    ),
                  ),
                  primaryYAxis: const NumericAxis(
                    title: AxisTitle(
                      text: 'Level (microAmp)',
                    ),
                  ),
                  series: <LineSeries <PatientData, String>> [
                    LineSeries<PatientData, String>(
                      dataSource: _chartData1,
                      xValueMapper: (PatientData data, _) => data.day,
                      yValueMapper: (PatientData data, _) => data.level, 
                    )
                  ]
                ),
              ),
              //Chart 2
              Container(
                padding: EdgeInsets.all(5),
                height: 350,
                child: SfCartesianChart(
                  title: const ChartTitle(
                    text: 'Patient Data - Cleaned',
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  primaryXAxis: const CategoryAxis(
                    title: AxisTitle(
                      text: 'Time (s)',
                    ),
                  ),
                  primaryYAxis: const NumericAxis(
                    title: AxisTitle(
                      text: 'Level (microAmp)',
                    ),
                  ),
                  series: <LineSeries<PatientData, String>>[
                    LineSeries<PatientData, String>(
                      dataSource: _chartData2,
                      xValueMapper: (PatientData data, _) => data.day,
                      yValueMapper: (PatientData data, _) => data.level,
                    ),
                  ],
                )
              )
            ],
          ),
        ),
      )
    );
  }
}

class PatientData {
  PatientData(this.day, this.level);
  final String day;
  final double level;
}

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Testing'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: SfCartesianChart(
            // Initialize category axis
            primaryXAxis: CategoryAxis(),

            series: <LineSeries<PatientData, String>>[
              LineSeries<PatientData, String>(
                // Bind data source
                dataSource:  _chartData1,
                xValueMapper: (PatientData data, _) => data.day,
                yValueMapper: (PatientData data, _) => data.level
              )
            ]
          )
        )
      )
    );
  }
}
*/


