import 'package:flutter/material.dart';
import 'package:flutter_chart_plus/flutter_chart.dart';

/// @author jd

class WaveProgressDemo extends StatefulWidget {
  const WaveProgressDemo({super.key});

  @override
  State<WaveProgressDemo> createState() => _WaveProgressDemoState();
}

class _WaveProgressDemoState extends State<WaveProgressDemo> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _animationController.addStatusListener((status) {
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        //动画在开始时就停止的状态
        _animationController.forward(); //向前
      }
    });
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Wave Progress'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: 200,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (c, child) => ChartWidget(
              coordinateRender: ChartCircularCoordinateRender(
                borderColor: Colors.grey,
                charts: [
                  WaveProgress(
                    data: [0.5, 0.48, 0.47, 0.46],
                    controlPoint: _animationController.value * 20 + 5,
                    controlOffset: _animationController.value,
                    position: (item,_) => item,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
