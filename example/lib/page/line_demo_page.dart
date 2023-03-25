import 'dart:ui' as ui;

import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart/flutter_chart.dart';

/// @author JD
class LineChartDemoPage extends StatefulWidget {
  LineChartDemoPage({Key? key}) : super(key: key);

  @override
  State<LineChartDemoPage> createState() => _LineChartDemoPageState();
}

class _LineChartDemoPageState extends State<LineChartDemoPage> {
  final DateTime startTime = DateTime(2023, 1, 1);
  ui.Image? logoImage;

  @override
  void initState() {
    ImageAnnotation.getAssetImage('images/location.png', width: 10, height: 10).then((value) {
      setState(() {
        logoImage = value;
      });
    });
    super.initState();
  }

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 200,
            child: ChartWidget(
              builder: (controller) => LineBarChartCoordinateRender(
                zoom: true,
                crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                margin: const EdgeInsets.only(left: 40, top: 0, right: 0, bottom: 30),
                //提示的文案信息
                tooltipFormatter: (item) => TextSpan(
                  text: '${item['value1']}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                position: (item) => (item['time'] as DateTime).difference(startTime).inMilliseconds / (24 * 60 * 60 * 1000),
                yAxis: YAxis(min: 0, max: 500),
                xAxis: XAxis(
                  count: 7,
                  max: 7,
                  formatter: (index) => startTime.add(Duration(days: index)).toStringWithFormat(format: 'dd'),
                ),
                chartRender: Line(
                  position: (item) => [
                    item['value1'] as num,
                  ],
                ),
                data: dataList,
              ),
            ),
          ),
          const Text('Multiple Line'),
          SizedBox(
            // color: Colors.yellow,
            height: 200,
            width: 250,
            child: ChartWidget(
              builder: (controller) => LineBarChartCoordinateRender(
                foregroundAnnotations: [
                  LimitAnnotation(limit: 380),
                  LimitAnnotation(limit: 210),
                  if (logoImage != null) ImageAnnotation(image: logoImage!, positions: [1, 200], offset: Offset(-10, -10)),
                  LabelAnnotation(positions: [6, 380], text: '380'),
                ],
                backgroundAnnotations: [
                  RegionAnnotation(positions: [2.4, 3.3]),
                  RegionAnnotation(positions: [4.4, 5.3]),
                ],
                margin: const EdgeInsets.only(left: 40, top: 5, right: 0, bottom: 30),
                //提示的文案信息
                crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                tooltipFormatter: (item) => TextSpan(
                  text: '${item['value1']}',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                position: (item) => (item['time'] as DateTime).difference(startTime).inMilliseconds / (24 * 60 * 60 * 1000),
                yAxis: YAxis(min: 0, max: 500),
                xAxis: XAxis(
                  count: 7,
                  max: 20,
                  drawLine: false,
                  formatter: (index) => startTime.add(Duration(days: index)).toStringWithFormat(format: 'dd'),
                ),
                chartRender: Line(
                  position: (item) => [
                    item['value1'] as num,
                    item['value2'] as num,
                  ],
                ),
                data: dataList,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
