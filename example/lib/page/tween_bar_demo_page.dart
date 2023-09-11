import 'dart:math';

import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class TweenBarChartDemoPage extends StatefulWidget {
  TweenBarChartDemoPage({Key? key}) : super(key: key);

  @override
  State<TweenBarChartDemoPage> createState() => _TweenBarChartDemoPageState();
}

class _TweenBarChartDemoPageState extends State<TweenBarChartDemoPage> {
  final DateTime startTime = DateTime(2023, 1, 1);
  final ChartController _controller = ChartController();

  late List<Map> dataList = [
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

  void _changeData() {
    double v = Random().nextInt(10) / 10;
    int diffDay = Random().nextInt(2);
    dataList = [
      {
        'time': startTime.add(Duration(days: 1 + diffDay)),
        'value1': 100 * v,
        'value2': 200 * v,
        'value3': 300 * v,
      },
      {
        'time': startTime.add(Duration(days: 3 + diffDay)),
        'value1': 200 * v,
        'value2': 400 * v,
        'value3': 300 * v,
      },
      {
        'time': startTime.add(Duration(days: 5 + diffDay)),
        'value1': 400 * v,
        'value2': 200 * v,
        'value3': 100 * v,
      },
      {
        'time': startTime.add(Duration(days: 8 + diffDay)),
        'value1': 100 * v,
        'value2': 300 * v,
        'value3': 200 * v,
      },
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
        actions: [
          TextButton(
            onPressed: () {
              _changeData();
            },
            child: const Text(
              '改变数据',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              children: [
                const Text('Line'),
                SizedBox(
                  height: 200,
                  child: ChartWidget(
                    coordinateRender: ChartDimensionsCoordinateRender(
                      crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                      margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                      padding: const EdgeInsets.only(left: 0, right: 0),
                      animationDuration: const Duration(milliseconds: 500),
                      yAxis: [YAxis(min: 0, max: 500)],
                      xAxis: XAxis(
                        count: 9,
                        zoom: true,
                        formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                      ),
                      charts: [
                        Line(
                          data: dataList,
                          position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                          values: (item) => [
                            item['value1'] as num,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // const Text('Bar'),
                // SizedBox(
                //   height: 200,
                //   child: ChartWidget(
                //     // controller: _controller,
                //     coordinateRender: ChartDimensionsCoordinateRender(
                //       animationDuration: const Duration(milliseconds: 500),
                //       margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                //       yAxis: [
                //         YAxis(min: 0, max: 300),
                //       ],
                //       xAxis: XAxis(
                //         count: 7,
                //         max: 10,
                //         formatter: (index) => startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd'),
                //       ),
                //       charts: [
                //         Bar(
                //           data: dataList,
                //           position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                //           value: (item) => item['value1'],
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 200,
                //   child: ChartWidget(
                //     coordinateRender: ChartDimensionsCoordinateRender(
                //       animationDuration: const Duration(milliseconds: 500),
                //       yAxis: [YAxis(min: 0, max: 500)],
                //       margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                //       xAxis: XAxis(
                //         count: 7,
                //         max: 30,
                //         formatter: (index) {
                //           return startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'dd');
                //         },
                //       ),
                //       charts: [
                //         StackBar(
                //           hotColor: Colors.yellow.withOpacity(0.1),
                //           data: dataList,
                //           position: (item) {
                //             return parserDateTimeToDayValue(item['time'] as DateTime, startTime);
                //           },
                //           direction: Axis.horizontal,
                //           itemWidth: 10,
                //           highlightColor: Colors.yellow,
                //           values: (item) => [
                //             double.parse(item['value1'].toString()),
                //             double.parse(item['value2'].toString()),
                //             double.parse(item['value3'].toString()),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
