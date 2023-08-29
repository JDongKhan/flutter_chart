import 'package:flutter/material.dart';

import '../../flutter_chart.dart';
import '../base/chart_body_render.dart';
import '../utils/transform_utils.dart';

/// @author jd
class WaveProgress<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///波纹峰值
  final double controlPoint;

  ///从0 到 1
  final double controlOffset;

  ///颜色
  final List<Color> colors;

  WaveProgress({
    required super.data,
    required this.position,
    this.controlOffset = 0.5,
    this.controlPoint = 10,
    this.colors = colors10,
  });

  @override
  void draw(Canvas canvas, Size size) {
    CircularChartCoordinateRender chart = coordinateChart as CircularChartCoordinateRender;
    Offset center = chart.center;
    double radius = chart.radius;
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    TransformUtils transformUtils;
    //处理圆形场景
    if (chart.arcPosition == ArcPosition.none) {
      Offset progressCenter = Offset(center.dx, center.dy + radius);
      transformUtils = TransformUtils(
        anchor: progressCenter,
        size: chart.size,
        offset: chart.controller.offset,
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
    var index = 0;
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
        ..color = colors[index]
        ..style = PaintingStyle.fill;
      Path path = _createBezierPath(transformUtils, radius, waterHeight);
      canvas.drawPath(path, paint);
      index++;
    }
  }

  Path _createBezierPath(
    TransformUtils transformUtils,
    double radius,
    double waterHeight,
  ) {
    double ofst = radius * controlOffset;

    Path path = Path();
    Offset first = transformUtils.transformOffset(Offset(-radius * 2 + ofst, waterHeight));
    Offset last = transformUtils.transformOffset(Offset(radius + ofst, waterHeight));
    path.moveTo(first.dx, first.dy);

    Offset start = first;
    //分段
    int count = 4;
    double itemWidth = (last.dx - first.dx) / count;
    for (int i = 0; i < count; i++) {
      Offset end = start.translate(itemWidth, 0);
      double diffX = end.dx - start.dx;
      double po1x = start.dx + diffX / 4;
      double po1Y = start.dy + controlPoint;

      double po2x = end.dx - diffX / 4;
      double po2y = end.dy - controlPoint;
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
