import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class ScatterDemoPage extends StatefulWidget {
  const ScatterDemoPage({Key? key}) : super(key: key);

  @override
  State<ScatterDemoPage> createState() => _ScatterDemoPageState();
}

class _ScatterDemoPageState extends State<ScatterDemoPage> {
  final DateTime startTime = DateTime(2023, 1, 1);
  final int maxCount = 5000;
  late List<Map> dataList = [
    {
      'time': startTime.add(const Duration(days: 1)),
      'value1': 100,
    },
    {
      'time': startTime.add(const Duration(days: 2)),
      'value1': 150,
    },
    {
      'time': startTime.add(const Duration(days: 3)),
      'value1': 200,
    },
    {
      'time': startTime.add(const Duration(days: 4)),
      'value1': 300,
    },
  ];

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      _insertNewData();
    });
  }

  void _insertNewData() {
    //去掉第一个数据
    if (dataList.length >= maxCount) {
      dataList.removeAt(0);
    }
    dataList.add({
      'time': startTime.add(Duration(days: Random().nextInt(7), hours: Random().nextInt(23))),
      'value1': Random().nextInt(500),
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: ChartWidget(
              coordinateRender: ChartDimensionsCoordinateRender(
                padding: const EdgeInsets.only(left: 5, top: 0, right: 5, bottom: 0),
                yAxis: [
                  YAxis(min: 0, max: 500, drawGrid: true),
                ],
                xAxis: XAxis(count: 7, max: 7),
                charts: [
                  Scatter(
                    style: (item) => item['value1'] > 400 ? const ScatterStyle(color: Colors.red, radius: 2) : const ScatterStyle(color: Colors.blue, radius: 2),
                    data: dataList,
                    position: (item) => parserDateTimeToDayValue(item['time'] as DateTime, startTime),
                    value: (item) => item['value1'] as num,
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
