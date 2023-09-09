import 'package:example/page/bar_demo_page.dart';
import 'package:example/page/line_demo_page.dart';
import 'package:example/page/pie_demo_page.dart';
import 'package:flutter/material.dart';

import 'page/line_right_demo_page.dart';
import 'page/line_scale_demo_page.dart';
import 'page/radar_demo_page.dart';
import 'page/scatter_demo_page.dart';
import 'page/tween_bar_demo_page.dart';

/// @author JD
class ChartDemoPage extends StatelessWidget {
  ChartDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChartDemo'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LineChartDemoPage(),
                ),
              );
            },
            child: const Text('Line'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScatterDemoPage(),
                ),
              );
            },
            child: const Text('Scatter'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BarChartDemoPage(),
                ),
              );
            },
            child: const Text('Bar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PieChartDemoPage(),
                ),
              );
            },
            child: const Text('Pie'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RadarChartDemoPage(),
                ),
              );
            },
            child: const Text('Radar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LineChartScaleDemoPage(),
                ),
              );
            },
            child: const Text('scale line'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LineChartRightDemoPage(),
                ),
              );
            },
            child: const Text('ecg or oxy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TweenBarChartDemoPage(),
                ),
              );
            },
            child: const Text('tween animal'),
          ),
        ],
      ),
    );
  }
}
