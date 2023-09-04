import 'dart:ui' as ui;

import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class LineChartScaleDemoPage extends StatefulWidget {
  const LineChartScaleDemoPage({Key? key}) : super(key: key);

  @override
  State<LineChartScaleDemoPage> createState() => _LineChartScaleDemoPageState();
}

class _LineChartScaleDemoPageState extends State<LineChartScaleDemoPage> {
  final DateTime startTime = DateTime(2023, 1, 1);

  @override
  void initState() {
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
        'value1': 150,
        'value2': 250,
        'value3': 300,
      },
      {
        'time': startTime.add(const Duration(days: 5)),
        'value1': 200,
        'value2': 280,
        'value3': 300,
      },
      {
        'time': startTime.add(const Duration(days: 8)),
        'value1': 300,
        'value2': 450,
        'value3': 300,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: ChartWidget(
              coordinateRender: DimensionsChartCoordinateRender(
                zoomHorizontal: true,
                // zoomVertical: true,
                crossHair: const CrossHairStyle(adjustHorizontal: true, adjustVertical: true),
                //提示的文案信息
                tooltipBuilder: (BuildContext context, List<ChartShapeLayoutParam> body) {
                  return PreferredSize(
                    preferredSize: const Size(60, 60),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(body.map((e) => e.selectedIndex).toString()),
                    ),
                  );
                },
                yAxis: [
                  YAxis(
                    min: 0,
                    max: 500,
                    drawGrid: true,
                  ),
                ],
                xAxis: XAxis(
                  count: 7,
                  max: 9,
                  drawDivider: true,
                  divideCount: (zoom) => zoom.toInt(),
                  formatter: (index) {
                    double hours = (index % 1.0) * 24;
                    double minutes = (hours % 1.0) * 60;
                    if (hours == 0) {
                      //是否是0点
                      return startTime.add(Duration(days: index.toInt())).toStringWithFormat(format: 'MM-dd');
                    } else {
                      return startTime.add(Duration(days: index.toInt(), hours: hours.toInt(), minutes: minutes.toInt())).toStringWithFormat(format: 'HH:mm');
                    }
                  },
                ),
                backgroundAnnotations: [
                  RegionAnnotation(positions: [2.4, 3.3]),
                  RegionAnnotation(positions: [4.4, 5.3]),
                  LabelAnnotation(
                    positions: [3.3, 0],
                    text: '夜晚',
                    textAlign: TextAlign.end,
                    minZoomVisible: 1,
                    maxZoomVisible: 4,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                    offset: const Offset(-10, -20),
                  ),
                  LabelAnnotation(
                    positions: [3.3, 0],
                    text: '白天',
                    minZoomVisible: 1,
                    maxZoomVisible: 4,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                    ),
                    offset: const Offset(10, -20),
                  ),
                ],
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
        ],
      ),
    );
  }
}
