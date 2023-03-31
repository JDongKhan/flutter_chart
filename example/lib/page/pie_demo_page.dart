import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/flutter_chart.dart';

/// @author JD
class PieChartDemoPage extends StatelessWidget {
  PieChartDemoPage({Key? key}) : super(key: key);

  final DateTime startTime = DateTime(2023, 1, 1);

  @override
  Widget build(BuildContext context) {
    final List<Map> dataList = [
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
            const Text('Pie'),
            SizedBox(
              height: 200,
              child: ChartWidget(
                builder: () => CircularChartCoordinateRender(
                  margin: const EdgeInsets.all(30),
                  charts: [
                    Pie(
                      data: dataList,
                      showValue: true,
                      position: (item) =>
                          (double.parse(item['value1'].toString())),
                      valueFormatter: (item) => item['value1'].toString(),
                    ),
                  ],
                ),
              ),
            ),
            const Text('Hole Pie'),
            SizedBox(
              height: 200,
              child: ChartWidget(
                builder: () => CircularChartCoordinateRender(
                  margin: const EdgeInsets.all(30),
                  charts: [
                    Pie(
                      guideLine: true,
                      data: dataList,
                      position: (item) =>
                          (double.parse(item['value1'].toString())),
                      holeRadius: 40,
                      valueTextOffset: 20,
                      legendFormatter: (item) {
                        return (item['time'] as DateTime)
                            .toStringWithFormat(format: 'MM-dd');
                      },
                      centerTextStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      valueFormatter: (item) => item['value1'].toString(),
                    ),
                  ],
                ),
              ),
            ),
            const Text('Progress Pie'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              height: 200,
              child: Stack(
                children: [
                  Positioned.fill(
                    top: 100,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '5%',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '完成度',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ChartWidget(
                    builder: () => CircularChartCoordinateRender(
                      margin: const EdgeInsets.only(bottom: 10),
                      strokeCap: StrokeCap.round,
                      borderColor: Colors.grey,
                      borderWidth: 13,
                      arcPosition: ArcPosition.up,
                      charts: [
                        Progress(
                          strokeWidth: 9,
                          endPoint: true,
                          strokeCap: StrokeCap.round,
                          data: [0.5, 0.2],
                          position: (item) => item,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Text('Wave Progress'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              height: 200,
              child: ChartWidget(
                builder: () => CircularChartCoordinateRender(
                  borderColor: Colors.grey,
                  charts: [
                    WaveProgress(
                      data: [0.5],
                      position: (item) => item,
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
