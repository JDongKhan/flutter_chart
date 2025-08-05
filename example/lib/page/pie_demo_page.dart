import 'dart:math';

import 'package:example/page/extension_datetime.dart';
import 'package:example/page/widget/wave_progress_demo.dart';
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

  List list = [0.5,0.2];
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
                coordinateRender: ChartCircularCoordinateRender(
                  margin: const EdgeInsets.all(30),
                  onClickChart: (BuildContext context, List<ChartLayoutState> list) {
                    debugPrint("点击事件:$list");
                  },
                  charts: [
                    Pie(
                      data: dataList,
                      showValue: true,
                      position: (item) => (double.parse(item['value1'].toString())),
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
                  margin: const EdgeInsets.all(30),
                  charts: [
                    Pie(
                      guideLine: true,
                      data: dataList,
                      position: (item) => (double.parse(item['value1'].toString())),
                      holeRadius: 40,
                      showValue: true,
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
            // const Text('Progress Pie 1'),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 40),
            //   height: 200,
            //   child: Stack(
            //     children: [
            //       const Positioned.fill(
            //         top: 100,
            //         child: Center(
            //           child: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Text('5%', style: TextStyle(fontSize: 24, color: Colors.black)),
            //               Text('完成度', style: TextStyle(fontSize: 30, color: Colors.black)),
            //             ],
            //           ),
            //         ),
            //       ),
            //       ChartWidget(
            //         coordinateRender: ChartCircularCoordinateRender(
            //           animationDuration: const Duration(seconds: 1),
            //           margin: const EdgeInsets.only(bottom: 10),
            //           strokeCap: StrokeCap.round,
            //           borderColor: Colors.grey,
            //           borderWidth: 13,
            //           arcDirection: ArcDirection.up,
            //           charts: [
            //             Progress(
            //               strokeWidth: 9,
            //               endPoint: true,
            //               strokeCap: StrokeCap.round,
            //               data: list,
            //               position: (item) => item,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // GestureDetector(onTap: () {
            //   setState(() {
            //     var d = Random().nextDouble();
            //     list = [d + 0.2,d];
            //   });
            // }, child: const Text('Progress Pie 2')),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 40),
            //   height: 200,
            //   child: Stack(
            //     children: [
            //       const Positioned.fill(
            //         bottom: 50,
            //         child: Center(
            //           child: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Text('5%', style: TextStyle(fontSize: 24, color: Colors.black)),
            //               Text('完成度', style: TextStyle(fontSize: 30, color: Colors.black)),
            //             ],
            //           ),
            //         ),
            //       ),
            //       ChartWidget(
            //         coordinateRender: ChartCircularCoordinateRender(
            //           margin: const EdgeInsets.only(bottom: 10),
            //           strokeCap: StrokeCap.round,
            //           borderColor: Colors.grey,
            //           borderWidth: 13,
            //           arcDirection: ArcDirection.down,
            //           charts: [
            //             Progress(
            //               strokeWidth: 9,
            //               endPoint: true,
            //               strokeCap: StrokeCap.round,
            //               data: list,
            //               position: (item) => item,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const Text('CircularProgress'),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 40),
            //   height: 200,
            //   child: Stack(
            //     children: [
            //       const Positioned.fill(
            //         bottom: 50,
            //         child: Center(
            //           child: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Text('50%', style: TextStyle(fontSize: 24, color: Colors.black)),
            //               Text('完成度', style: TextStyle(fontSize: 30, color: Colors.black)),
            //             ],
            //           ),
            //         ),
            //       ),
            //       ChartWidget(
            //         coordinateRender: ChartCircularCoordinateRender(
            //           animationDuration: const Duration(seconds: 1),
            //           margin: const EdgeInsets.only(bottom: 10),
            //           strokeCap: StrokeCap.round,
            //           borderColor: Colors.grey,
            //           borderWidth: 13,
            //           arcDirection: ArcDirection.none,
            //           charts: [
            //             CircularProgress(
            //               strokeWidth: 9,
            //               strokeCap: StrokeCap.round,
            //               data: list,
            //               position: (item) => item,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const WaveProgressDemo(),
          ],
        ),
      ),
    );
  }
}
