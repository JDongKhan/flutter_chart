import 'dart:ui' as ui;
import 'dart:math';

import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

class RawTimeSales {
  final double time; // 采集时间点
  final double data;

  RawTimeSales(this.time, this.data);
}

/// @author JD
class LineChartDiyDemoPage extends StatefulWidget {
  const LineChartDiyDemoPage({Key? key}) : super(key: key);

  List<Map> createRandomData() {
    final random = Random();
    const int sectionSize = 4096;
    const int sectionZero = 100;
    const int sampleRate = 500; //16kHZ
    List<Map> data = [];
    const double sampleInterval = 1.0 / sampleRate;
    const maxTimeVlaue = sampleInterval * sectionSize;

    for (int i = 0; i < sectionSize - sectionZero; ++i) {
      data.add({
        "Time": i * sampleInterval,
        "Data": (random.nextBool() ? 1 : -1) * random.nextDouble() * 800,
      });
    }

    for (int i = sectionSize - sectionZero; i < sectionSize; ++i) {
      data.add({
        "Time": i * sampleInterval,
        "Data": 0,
      });
    }

    return data;
  }

  @override
  State<LineChartDiyDemoPage> createState() => _LineChartDiyDemoPageState();
}

class _LineChartDiyDemoPageState extends State<LineChartDiyDemoPage> {
  final DateTime startTime = DateTime(2023, 1, 1);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    //final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final statusBarHeight = mq.padding.top;
    final bottomBarHeight = mq.padding.bottom;

    final safeContentHeight = screenHeight - statusBarHeight - bottomBarHeight;
    final safeHeight = safeContentHeight - kToolbarHeight - kBottomNavigationBarHeight;

    final perWidgetHeight = safeHeight / 4;

    const int sectionSize = 4096;
    const int sampleRate = 500; //16kHZ
    const double sampleInterval = 1.0 / sampleRate;
    const maxTimeVlaue = sampleInterval * sectionSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LineDiyDemo'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: perWidgetHeight,
            child: ChartWidget(
              coordinateRender: ChartDimensionsCoordinateRender(
                margin: const EdgeInsets.only(left: 30, top: 10, right: 0, bottom: 25),
                padding: const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 0),
                yAxis: [YAxis(min: -800, max: 800)],
                xAxis: XAxis(
                  count: sectionSize,
                  max: maxTimeVlaue,
                  interval: sampleInterval,
                ),
                charts: [
                  Line(
                    data: widget.createRandomData(),
                    position: (item) => item["Time"] as num,
                    values: (item) => [
                      item['Data'] as num,
                    ],
                    dotRadius: 0,
                    strokeWidth: 0.5,
                  ),
                ],
              ),
            ),
          ),
          // SizedBox(
          //   height: perWidgetHeight,
          //   child: ChartWidget(
          //     coordinateRender: ChartDimensionsCoordinateRender(
          //       margin: const EdgeInsets.only(left: 30, top: 10, right: 0, bottom: 25),
          //       padding: const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 0),
          //       yAxis: [YAxis(min: -800, max: 800)],
          //       xAxis: XAxis(
          //         count: sectionSize,
          //         max: maxTimeVlaue,
          //         interval: sampleInterval,
          //       ),
          //       charts: [
          //         Line(
          //           data: widget.createRandomData(),
          //           position: (item) => item["Time"] as num,
          //           values: (item) => [
          //             item['Data'] as num,
          //           ],
          //           dotRadius: 0,
          //           strokeWidth: 0.5,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: perWidgetHeight,
          //   child: ChartWidget(
          //     coordinateRender: ChartDimensionsCoordinateRender(
          //       margin: const EdgeInsets.only(left: 30, top: 10, right: 0, bottom: 25),
          //       padding: const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 0),
          //       yAxis: [YAxis(min: -800, max: 800)],
          //       xAxis: XAxis(
          //         count: sectionSize,
          //         max: maxTimeVlaue,
          //         interval: sampleInterval,
          //       ),
          //       charts: [
          //         Line(
          //           data: widget.createRandomData(),
          //           position: (item) => item["Time"] as num,
          //           values: (item) => [
          //             item['Data'] as num,
          //           ],
          //           dotRadius: 0,
          //           strokeWidth: 0.5,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: perWidgetHeight,
          //   child: ChartWidget(
          //     coordinateRender: ChartDimensionsCoordinateRender(
          //       margin: const EdgeInsets.only(left: 30, top: 10, right: 0, bottom: 25),
          //       padding: const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 0),
          //       yAxis: [YAxis(min: -800, max: 800)],
          //       xAxis: XAxis(
          //         count: sectionSize,
          //         max: maxTimeVlaue,
          //         interval: sampleInterval,
          //       ),
          //       charts: [
          //         Line(
          //           data: widget.createRandomData(),
          //           position: (item) => item["Time"] as num,
          //           values: (item) => [
          //             item['Data'] as num,
          //           ],
          //           dotRadius: 0,
          //           strokeWidth: 0.5,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
