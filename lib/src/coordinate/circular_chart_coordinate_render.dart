import 'dart:math';

import 'package:flutter/material.dart';

import '../base/chart_coordinate_render.dart';
import '../utils/transform_utils.dart';

enum ArcPosition {
  none,
  up,
  down,
}

/// @author JD
class CircularChartCoordinateRender extends ChartCoordinateRender {
  final double borderWidth;
  final Color borderColor;
  final StrokeCap? strokeCap;
  final ArcPosition arcPosition;
  CircularChartCoordinateRender({
    super.margin = EdgeInsets.zero,
    super.padding = EdgeInsets.zero,
    super.safeArea,
    required super.charts,
    this.arcPosition = ArcPosition.none,
    this.borderWidth = 1,
    this.strokeCap,
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
      element.draw(controller.offset);
    }
    _drawForegroundAnnotations(canvas, size);
  }

  //画背景圆
  void _drawCircle(Canvas canvas, Size size) {
    final sw = size.width - contentMargin.horizontal;
    final sh = size.height - contentMargin.vertical;
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
      // 确定圆的半径
      radius = min(sw, sh) / 2 - borderWidth / 2;
      // 定义中心点
      center = size.center(Offset.zero);
      // 使用 Canvas 的 drawCircle 绘制
      canvas.drawCircle(center, radius, paint);
      transformUtils = TransformUtils(
        anchor: center,
        size: size,
        padding: padding,
        offset: controller.offset,
        reverseX: false,
        reverseY: false,
      );
    } else {
      //带有弧度
      double maxSize = max(sw, sh);
      double minSize = min(sw, sh);
      radius = min(maxSize / 2, minSize) - borderWidth / 2;
      center = size.center(Offset.zero);
      double startAngle = 0;
      double sweepAngle = pi;
      if (arcPosition == ArcPosition.up) {
        startAngle = pi;
        center = Offset(center.dx, size.height - contentMargin.bottom);
        transformUtils = TransformUtils(
          anchor: center,
          size: size,
          padding: padding,
          offset: controller.offset,
          reverseX: false,
          reverseY: true,
        );
      } else if (arcPosition == ArcPosition.down) {
        center = Offset(center.dx, contentMargin.top);
        transformUtils = TransformUtils(
          anchor: center,
          size: size,
          padding: padding,
          offset: controller.offset,
          reverseX: false,
          reverseY: false,
        );
      }
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
      canvas.drawPath(path, paint);
    }
  }

  //背景
  void _drawBackgroundAnnotations(Canvas canvas, Size size) {
    backgroundAnnotations?.forEach((element) {
      element.init(this);
      element.draw(controller.offset);
    });
  }

  //前景
  void _drawForegroundAnnotations(Canvas canvas, Size size) {
    foregroundAnnotations?.forEach((element) {
      element.init(this);
      element.draw(controller.offset);
    });
  }

  @override
  void scroll(Offset delta) {}
}
