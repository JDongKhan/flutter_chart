import 'dart:math';

import 'package:flutter/material.dart';

import '../base/chart_body_render.dart';
import '../base/chart_coordinate_render.dart';
import '../coordinate/circular_chart_coordinate_render.dart';

class Progress<T> extends ChartBodyRender<T> {
  //线宽
  final double strokeWidth;
  //开始弧度，可以调整起始位置
  final double startAngle;
  //结尾样式
  final StrokeCap? strokeCap;
  //颜色
  final List<Color> colors;
  //结尾画小原点
  final bool endPoint;
  Progress({
    required super.data,
    required super.position,
    this.endPoint = false,
    this.colors = colors10,
    this.startAngle = pi,
    this.strokeWidth = 1,
    this.strokeCap,
  });

  @override
  void draw(Offset offset) {
    CircularChartCoordinateRender chart =
        coordinateChart as CircularChartCoordinateRender;
    Offset center = chart.center;
    double radius = chart.radius;
    Canvas canvas = chart.canvas;

    // 定义圆形的绘制属性
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth;

    if (strokeCap != null) {
      paint.strokeCap = strokeCap!;
    }

    Paint? pointPaint;

    if (endPoint) {
      pointPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white
        ..isAntiAlias = true
        ..strokeWidth = 1;
    }
    int index = 0;
    num? lastXvs;

    double startAngle = this.startAngle;
    double fullSweepAngle = pi;
    //
    if (chart.arcPosition == ArcPosition.none) {
      fullSweepAngle = pi * 2;
    } else if (chart.arcPosition == ArcPosition.up) {
      fullSweepAngle = pi;
    } else if (chart.arcPosition == ArcPosition.down) {
      startAngle = 0;
    }

    for (T item in data) {
      num po = position.call(item);

      if (lastXvs != null) {
        assert(lastXvs > po, '数据必须降序，否则会被挡住');
      }
      double sweepAngle = fullSweepAngle * po;
      Path path = Path()
        ..addArc(
          Rect.fromCenter(
            center: center,
            width: radius * 2,
            height: radius * 2,
          ),
          startAngle,
          sweepAngle,
        );
      canvas.drawPath(path, paint..color = colors[index]);
      if (pointPaint != null && sweepAngle > 0) {
        double endAngle = startAngle + sweepAngle;
        var startX = cos(endAngle) * radius + center.dx;
        var startY = sin(endAngle) * radius + center.dy;
        canvas.drawCircle(
          Offset(startX, startY),
          strokeWidth / 2 - 2,
          pointPaint,
        );
      }
      index++;
      lastXvs = po;
    }
  }
}
