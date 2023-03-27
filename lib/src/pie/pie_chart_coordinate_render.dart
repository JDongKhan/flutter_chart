import 'dart:math';

import 'package:flutter/material.dart';

import '../base/chart_coordinate_render.dart';

/// @author JD
class PieChartCoordinateRender extends ChartCoordinateRender {
  final double borderWidth;
  final Color borderColor;
  PieChartCoordinateRender({
    super.margin = EdgeInsets.zero,
    super.padding = EdgeInsets.zero,
    required super.charts,
    super.zoomHorizontal,
    super.zoomVertical,
    this.borderWidth = 1,
    this.borderColor = Colors.white,
  });

  late double radius;
  late Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(rect);
    _drawCircle(canvas, size);
    _drawBackgroundAnnotations(canvas, size);
    for (var element in charts) {
      element.draw();
    }
    _drawForegroundAnnotations(canvas, size);
  }

  //画背景圆
  void _drawCircle(Canvas canvas, Size size) {
    final sw = size.width - contentMargin.horizontal;
    final sh = size.height - contentMargin.vertical;
    // 确定圆的半径
    radius = min(sw, sh) / 2 - borderWidth * 2;
    // 定义中心点
    center = size.center(Offset.zero);
    // 定义圆形的绘制属性
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = borderColor
      ..strokeWidth = borderWidth;

    // 使用 Canvas 的 drawCircle 绘制
    canvas.drawCircle(center, radius, paint);
  }

  //背景
  void _drawBackgroundAnnotations(Canvas canvas, Size size) {
    backgroundAnnotations?.forEach((element) {
      element.init(this);
      element.draw();
    });
  }

  //前景
  void _drawForegroundAnnotations(Canvas canvas, Size size) {
    foregroundAnnotations?.forEach((element) {
      element.init(this);
      element.draw();
    });
  }

  @override
  void scroll(Offset offset) {}
}
