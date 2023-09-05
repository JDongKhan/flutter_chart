import 'dart:math';

import 'package:flutter/material.dart';

import '../measure/chart_circular_param.dart';
import '../measure/chart_param.dart';
import 'chart_coordinate_render.dart';

enum ArcPosition {
  none,
  up,
  down,
}

@Deprecated('instead of  using [ChartCircularCoordinateRender]')
typedef CircularChartCoordinateRender = ChartCircularCoordinateRender;

/// @author JD
/// 圆形坐标系
class ChartCircularCoordinateRender extends ChartCoordinateRender {
  final double borderWidth;
  final Color borderColor;
  final StrokeCap? strokeCap;
  final ArcPosition arcPosition;
  ChartCircularCoordinateRender({
    super.margin = EdgeInsets.zero,
    super.padding = EdgeInsets.zero,
    required super.charts,
    super.safeArea,
    super.backgroundAnnotations,
    super.foregroundAnnotations,
    this.arcPosition = ArcPosition.none,
    this.borderWidth = 1,
    this.strokeCap,
    this.borderColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, ChartParam param) {
    param as ChartCircularParam;
    _drawCircle(param, canvas);
    _drawBackgroundAnnotations(param, canvas);
    var index = 0;
    for (var element in charts) {
      element.index = index;
      if (!element.isInit) {
        element.init(param);
      }
      element.draw(canvas, param);
      index++;
    }
    _drawForegroundAnnotations(param, canvas);
  }

  ///画背景圆
  void _drawCircle(ChartCircularParam param, Canvas canvas) {
    // 定义圆形的绘制属性
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..isAntiAlias = true
      ..strokeWidth = borderWidth;

    if (strokeCap != null) {
      paint.strokeCap = strokeCap!;
    }

    //满圆
    if (arcPosition == ArcPosition.none) {
      // 使用 Canvas 的 drawCircle 绘制
      canvas.drawCircle(param.center, param.radius, paint);
    } else {
      double startAngle = 0;
      double sweepAngle = pi;
      if (arcPosition == ArcPosition.up) {
        startAngle = pi;
      } else if (arcPosition == ArcPosition.down) {}
      Path path = Path()
        ..addArc(
          Rect.fromCenter(
            center: param.center,
            width: param.radius * 2,
            height: param.radius * 2,
          ),
          startAngle,
          sweepAngle,
        );
      canvas.drawPath(path, paint);
    }
  }

  ///背景
  void _drawBackgroundAnnotations(ChartParam param, Canvas canvas) {
    backgroundAnnotations?.forEach((element) {
      if (!element.isInit) {
        element.init(param);
      }
      element.draw(canvas, param);
    });
  }

  ///前景
  void _drawForegroundAnnotations(ChartParam param, Canvas canvas) {
    foregroundAnnotations?.forEach((element) {
      if (!element.isInit) {
        element.init(param);
      }
      element.draw(canvas, param);
    });
  }
}
