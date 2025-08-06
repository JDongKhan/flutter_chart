import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

import 'widget/wave_progress_demo.dart';

/// @author jd

class ProgressDemoPage extends StatefulWidget {
  const ProgressDemoPage({super.key});

  @override
  State<ProgressDemoPage> createState() => _ProgressDemoPageState();
}

class _ProgressDemoPageState extends State<ProgressDemoPage> {
  List list = [0.5, 0.2];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                var d = Random().nextDouble();
                list = [d + 0.2, d];
              });
            },
            child: const Text("刷新"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Progress Pie 1'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              height: 200,
              child: Stack(
                children: [
                  const Positioned.fill(
                    top: 100,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('5%', style: TextStyle(fontSize: 24, color: Colors.black)),
                          Text('完成度', style: TextStyle(fontSize: 30, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  ChartWidget(
                    coordinateRender: ChartCircularCoordinateRender(
                      animationDuration: const Duration(seconds: 1),
                      margin: const EdgeInsets.only(bottom: 10),
                      strokeCap: StrokeCap.round,
                      borderColor: Colors.grey,
                      borderWidth: 13,
                      arcDirection: ArcDirection.up,
                      charts: [
                        Progress(
                          strokeWidth: 9,
                          endPoint: true,
                          strokeCap: StrokeCap.round,
                          data: list,
                          position: (item, index) => item,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Text('Progress Pie 2'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              height: 200,
              child: Stack(
                children: [
                  const Positioned.fill(
                    bottom: 50,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('5%', style: TextStyle(fontSize: 24, color: Colors.black)),
                          Text('完成度', style: TextStyle(fontSize: 30, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  ChartWidget(
                    coordinateRender: ChartCircularCoordinateRender(
                      margin: const EdgeInsets.only(bottom: 10),
                      strokeCap: StrokeCap.round,
                      borderColor: Colors.grey,
                      borderWidth: 13,
                      arcDirection: ArcDirection.down,
                      charts: [
                        Progress(
                          strokeWidth: 9,
                          endPoint: true,
                          strokeCap: StrokeCap.round,
                          data: list,
                          position: (item, index) => item,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Text('CircularProgress'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              height: 200,
              child: Stack(
                children: [
                  const Positioned.fill(
                    bottom: 50,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('50%', style: TextStyle(fontSize: 24, color: Colors.black)),
                          Text('完成度', style: TextStyle(fontSize: 30, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  ChartWidget(
                    coordinateRender: ChartCircularCoordinateRender(
                      animationDuration: const Duration(seconds: 1),
                      margin: const EdgeInsets.only(bottom: 10),
                      strokeCap: StrokeCap.round,
                      borderColor: Colors.grey,
                      borderWidth: 13,
                      arcDirection: ArcDirection.none,
                      charts: [
                        CircularProgress(
                          strokeWidth: 9,
                          strokeCap: StrokeCap.round,
                          data: list,
                          position: (item, index) => item,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const WaveProgressDemo(),
          ],
        ),
      ),
    );
  }
}
