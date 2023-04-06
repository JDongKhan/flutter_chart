import 'package:flutter/material.dart';

import '../../flutter_chart.dart';
import '../base/chart_body_render.dart';
import '../utils/transform_utils.dart';

class WaveProgress<T> extends ChartBodyRender<T> {
  WaveProgress({required super.data, required super.position});

  @override
  void draw(Offset offset) {
    CircularChartCoordinateRender chart =
        coordinateChart as CircularChartCoordinateRender;
    Offset center = chart.center;
    double radius = chart.radius;
    Canvas canvas = chart.canvas;
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    TransformUtils transformUtils;
    //处理圆形场景
    if (chart.arcPosition == ArcPosition.none) {
      Offset progressCenter = Offset(center.dx, center.dy + radius);
      transformUtils = TransformUtils(
        anchor: progressCenter,
        size: chart.size,
        offset: offset,
        zoomVertical: chart.zoomVertical,
        zoomHorizontal: chart.zoomHorizontal,
        zoom: chart.controller.zoom,
        padding: chart.padding,
        reverseX: false,
        reverseY: true,
      );
    } else {
      //半圆就不用特别处理了
      transformUtils = chart.transformUtils;
    }

    for (T item in data) {
      num po = position.call(item);
      double height = radius * 2;
      if (chart.arcPosition == ArcPosition.none) {
        height = radius * 2;
      } else {
        height = radius;
      }
      double waterHeight = height * po;
      Paint paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      Path path = _createBezierPath(transformUtils, radius, waterHeight);
      canvas.drawPath(path, paint);
    }
  }

  Path _createBezierPath(
    TransformUtils transformUtils,
    double radius,
    double waterHeight,
  ) {
    Path path = Path();
    Offset first = transformUtils.transformOffset(Offset(-radius, waterHeight));
    Offset last = transformUtils.transformOffset(Offset(radius, waterHeight));
    path.moveTo(first.dx, first.dy);

    Offset start = first;
    //分段
    int count = 4;
    double controlOffset = 10;
    double itemWidth = radius * 2 / count;
    for (int i = 0; i < count; i++) {
      Offset end = start.translate(itemWidth, 0);
      double diffX = end.dx - start.dx;
      double po1x = start.dx + diffX / 4;
      double po1Y = start.dy + controlOffset;

      double po2x = end.dx - diffX / 4;
      double po2y = end.dy - controlOffset;
      path.cubicTo(po1x, po1Y, po2x, po2y, end.dx, end.dy);
      start = end;
    }
    Offset end1 = transformUtils.transformOffset(Offset(radius, 0));
    Offset end2 = transformUtils.transformOffset(Offset(-radius, 0));
    path.lineTo(end1.dx, end1.dy);
    path.lineTo(end2.dx, end2.dy);
    // path.lineTo(end.dx, end.dy);
    path.close();
    return path;
  }
}
