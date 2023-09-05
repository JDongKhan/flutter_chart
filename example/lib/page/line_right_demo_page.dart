import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author JD
class LineChartRightDemoPage extends StatefulWidget {
  const LineChartRightDemoPage({Key? key}) : super(key: key);

  @override
  State<LineChartRightDemoPage> createState() => _LineChartRightDemoPageState();
}

class _LineChartRightDemoPageState extends State<LineChartRightDemoPage> {
  final DateTime startTime = DateTime(2023, 1, 1);
  final int maxCount = 500;
  late List<Map> dataList = [
    {
      'value1': 100,
    },
    {
      'value1': 150,
    },
    {
      'value1': 200,
    },
    {
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
              coordinateRender: DimensionsChartCoordinateRender(
                zoomHorizontal: false,
                padding: const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                // zoomVertical: true,
                crossHair: const CrossHairStyle(verticalShow: false, horizontalShow: false),
                //提示的文案信息
                tooltipBuilder: (BuildContext context, List<CharBodyState> body) {
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
                  count: maxCount,
                  max: maxCount,
                ),
                charts: [
                  Line(
                    dotRadius: 0,
                    data: dataList,
                    position: (item) => maxCount - (dataList.length - dataList.indexOf(item)),
                    // position: (item) => dataList.indexOf(item),
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
