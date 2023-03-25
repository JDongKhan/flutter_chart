import 'dart:math';

import 'package:flutter/material.dart';

import '../base/chart_coordinate_render.dart';

/// @author JD
class PieChartCoordinateRender<T> extends ChartCoordinateRender<T> {
  final double borderWidth;
  final Color borderColor;
  PieChartCoordinateRender({
    super.margin = EdgeInsets.zero,
    super.padding = EdgeInsets.zero,
    required super.position,
    required super.chartRender,
    required super.data,
    super.zoom,
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
    chartRender.draw(data);
  }

  //画背景圆
  void _drawCircle(Canvas canvas, Size size) {
    final sw = size.width - content.horizontal;
    final sh = size.height - content.vertical;
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

  @override
  void scroll(Offset offset) {}
}
