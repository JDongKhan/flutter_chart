import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class RadarChartDemoPage extends StatefulWidget {
  const RadarChartDemoPage({Key? key}) : super(key: key);

  @override
  State<RadarChartDemoPage> createState() => _RadarChartDemoPageState();
}

class _RadarChartDemoPageState extends State<RadarChartDemoPage> with SingleTickerProviderStateMixin {
  final DateTime startTime = DateTime(2023, 1, 1);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map> dataList = [
      {
        'time': startTime.add(const Duration(days: 8)),
        'value1': 600,
        'value2': 300,
        'value3': 200,
      },
      {
        'time': startTime.add(const Duration(days: 1)),
        'value1': 100,
        'value2': 200,
        'value3': 300,
      },
      {
        'time': startTime.add(const Duration(days: 3)),
        'value1': 200,
        'value2': 400,
        'value3': 300,
      },
      {
        'time': startTime.add(const Duration(days: 5)),
        'value1': 400,
        'value2': 200,
        'value3': 100,
      },
      {
        'time': startTime.add(const Duration(days: 8)),
        'value1': 100,
        'value2': 300,
        'value3': 200,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('radar'),
            Container(
              height: 200,
              margin: const EdgeInsets.only(top: 20),
              child: ChartWidget(
                coordinateRender: CircularChartCoordinateRender(
                  margin: const EdgeInsets.all(12),
                  charts: [
                    Radar(
                      max: 600,
                      data: dataList,
                      fillColors: colors10.map((e) => e.withOpacity(0.1)).toList(),
                      valueFormatter: (item) => [
                        item['value1'],
                      ],
                      position: (item) => [
                        (double.parse(item['value1'].toString())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Text('multiple radar'),
            Container(
              height: 200,
              margin: const EdgeInsets.only(top: 20),
              child: ChartWidget(
                coordinateRender: CircularChartCoordinateRender(
                  margin: const EdgeInsets.all(12),
                  charts: [
                    Radar(
                      max: 600,
                      data: dataList,
                      fillColors: colors10.map((e) => e.withOpacity(0.1)).toList(),
                      valueFormatter: (item) => [
                        item['value1'].toString(),
                        item['value2'].toString(),
                      ],
                      position: (item) => [
                        (double.parse(item['value1'].toString())),
                        (double.parse(item['value2'].toString())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
