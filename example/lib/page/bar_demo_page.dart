import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/flutter_chart.dart';

/// @author JD
class BarChartDemoPage extends StatelessWidget {
  BarChartDemoPage({Key? key}) : super(key: key);

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
      body: Column(
        children: [
          const Text('垂直StackBar'),
          SizedBox(
            width: 250,
            height: 200,
            child: ChartWidget(
              builder: (controller) => LineBarChartCoordinateRender(
                position: (item) {
                  return (item['time'] as DateTime).difference(startTime).inMilliseconds / (24 * 60 * 60 * 1000);
                },
                margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                yAxis: YAxis(min: 0, max: 1000),
                xAxis: XAxis(
                  count: 7,
                  max: 30,
                  formatter: (index) {
                    return startTime.add(Duration(days: index)).toStringWithFormat(format: 'dd');
                  },
                ),
                data: dataList,
                chartRender: StackBar(
                  direction: Axis.vertical,
                  itemWidth: 10,
                  highlightColor: Colors.yellow,
                  position: (item) => [
                    double.parse(item['value1'].toString()),
                    double.parse(item['value2'].toString()),
                    double.parse(item['value3'].toString()),
                  ],
                ),
              ),
            ),
          ),
          const Text('水平StackBar'),
          SizedBox(
            width: 250,
            height: 200,
            child: ChartWidget(
              builder: (controller) => LineBarChartCoordinateRender(
                position: (item) {
                  return (item['time'] as DateTime).difference(startTime).inMilliseconds / (24 * 60 * 60 * 1000);
                },
                yAxis: YAxis(min: 0, max: 500),
                margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                xAxis: XAxis(
                  count: 7,
                  max: 30,
                  formatter: (index) {
                    return startTime.add(Duration(days: index)).toStringWithFormat(format: 'dd');
                  },
                ),
                data: dataList,
                chartRender: StackBar(
                  direction: Axis.horizontal,
                  itemWidth: 10,
                  highlightColor: Colors.yellow,
                  position: (item) => [
                    double.parse(item['value1'].toString()),
                    double.parse(item['value2'].toString()),
                    double.parse(item['value3'].toString()),
                  ],
                ),
              ),
            ),
          ),
          const Text('普通Bar'),
          SizedBox(
            height: 200,
            width: 250,
            child: ChartWidget(
              builder: (controller) => LineBarChartCoordinateRender(
                lineColor: Colors.grey,
                margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                position: (item) => (item['time'] as DateTime).difference(startTime).inMilliseconds / (24 * 60 * 60 * 1000),
                yAxis: YAxis(min: 0, max: 300),
                xAxis: XAxis(
                  count: 7,
                  max: 10,
                  formatter: (index) => startTime.add(Duration(days: index)).toStringWithFormat(format: 'dd'),
                ),
                data: dataList,
                chartRender: Bar(position: (item) => item['value1']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
