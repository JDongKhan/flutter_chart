import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

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
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                const Text('普通Bar'),
                SizedBox(
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                      yAxis: [
                        YAxis(min: 0, max: 300),
                      ],
                      xAxis: XAxis(
                        count: 7,
                        max: 10,
                        formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                      ),
                      charts: [
                        Bar(
                          data: dataList,
                          position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                          value: (item) => item['value1'],
                        ),
                      ],
                    ),
                  ),
                ),
                const Text('垂直StackBar'),
                SizedBox(
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                      yAxis: [
                        YAxis(min: 0, max: 1000),
                      ],
                      xAxis: XAxis(
                        count: 7,
                        max: 30,
                        formatter: (index) {
                          return startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd');
                        },
                      ),
                      charts: [
                        StackBar(
                          data: dataList,
                          direction: Axis.vertical,
                          itemWidth: 10,
                          highlightColor: Colors.yellow,
                          position: (item) {
                            return parserDateTimeToDayValue(item['time'] as DateTime, startTime);
                          },
                          values: (item) => [
                            double.parse(item['value1'].toString()),
                            double.parse(item['value2'].toString()),
                            double.parse(item['value3'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                      yAxis: [YAxis(min: 0, max: 100)],
                      xAxis: XAxis(
                        count: 7,
                        max: 30,
                        formatter: (index) {
                          return startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd');
                        },
                      ),
                      charts: [
                        StackBar(
                          data: dataList,
                          direction: Axis.vertical,
                          itemWidth: 10,
                          full: true,
                          highlightColor: Colors.yellow,
                          position: (item) {
                            return parserDateTimeToDayValue(item['time'] as DateTime, startTime);
                          },
                          values: (item) => [
                            double.parse(item['value1'].toString()),
                            double.parse(item['value2'].toString()),
                            double.parse(item['value3'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Text('水平StackBar'),
                SizedBox(
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      yAxis: [YAxis(min: 0, max: 500)],
                      margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                      xAxis: XAxis(
                        count: 7,
                        max: 30,
                        formatter: (index) {
                          return startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd');
                        },
                      ),
                      charts: [
                        StackBar(
                          data: dataList,
                          position: (item) {
                            return parserDateTimeToDayValue(item['time'] as DateTime, startTime);
                          },
                          direction: Axis.horizontal,
                          itemWidth: 10,
                          highlightColor: Colors.yellow,
                          values: (item) => [
                            double.parse(item['value1'].toString()),
                            double.parse(item['value2'].toString()),
                            double.parse(item['value3'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      yAxis: [YAxis(min: 0, max: 500)],
                      margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                      xAxis: XAxis(
                        count: 7,
                        max: 30,
                        formatter: (index) {
                          return startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd');
                        },
                      ),
                      charts: [
                        StackBar(
                          hotColor: Colors.yellow.withOpacity(0.1),
                          data: dataList,
                          position: (item) {
                            return parserDateTimeToDayValue(item['time'] as DateTime, startTime);
                          },
                          direction: Axis.horizontal,
                          itemWidth: 10,
                          highlightColor: Colors.yellow,
                          values: (item) => [
                            double.parse(item['value1'].toString()),
                            double.parse(item['value2'].toString()),
                            double.parse(item['value3'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
