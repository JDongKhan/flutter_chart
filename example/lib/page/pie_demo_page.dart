import 'dart:math';

import 'package:example/page/extension_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class PieChartDemoPage extends StatefulWidget {
  const PieChartDemoPage({Key? key}) : super(key: key);

  @override
  State<PieChartDemoPage> createState() => _PieChartDemoPageState();
}

class _PieChartDemoPageState extends State<PieChartDemoPage> with SingleTickerProviderStateMixin {
  final DateTime startTime = DateTime(2023, 1, 1);
  @override
  Widget build(BuildContext context) {
    final List<Map> dataList = [
      {
        'time': startTime.add(const Duration(days: 1)),
        'value1': Random().nextInt(500),
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 3)),
        'value1': Random().nextInt(500),
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 5)),
        'value1': Random().nextInt(500),
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 8)),
        'value1': Random().nextInt(500),
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 12)),
        'value1': Random().nextInt(500),
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
      {
        'time': startTime.add(const Duration(days: 12)),
        'value1': Random().nextInt(500),
        'value2': Random().nextInt(500),
        'value3': Random().nextInt(500),
      },
    ];



    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text("刷新"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Pie'),
            SizedBox(
              height: 200,
              child: ChartWidget(
                coordinateRender: ChartCircularCoordinateRender(
                  margin: const EdgeInsets.all(30),
                  animationDuration: const Duration(seconds: 1),
                  onClickChart: (BuildContext context, List<ChartLayoutState> list) {
                    debugPrint("点击事件:$list");
                  },
                  charts: [
                    Pie(
                      data: dataList,
                      position: (item,_) => (double.parse(item['value1'].toString())),
                      valueFormatter: (item) => item['value1'].toString(),
                    ),
                  ],
                ),
              ),
            ),
            // const Text('Hole Pie'),
            SizedBox(
              height: 200,
              child: ChartWidget(
                coordinateRender: ChartCircularCoordinateRender(
                  animationDuration: const Duration(seconds: 1),
                  margin: const EdgeInsets.all(30),
                  charts: [
                    Pie(
                      guideLine: true,
                      drawValueTextAfterAnimation: false,
                      data: dataList,
                      position: (item,_) => (double.parse(item['value1'].toString())),
                      holeRadius: 40,
                      valueTextOffset: 20,
                      legendFormatter: (item) {
                        return (item['time'] as DateTime).toStringWithFormat(format: 'MM-dd');
                      },
                      centerTextStyle: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                      valueFormatter: (item) => item['value1'].toString(),
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
