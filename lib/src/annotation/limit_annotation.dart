import 'package:flutter/material.dart';

import '../../flutter_chart.dart';
import '../widget/dash_painter.dart';

typedef AnnotationPosition<T> = num Function(T);

class LimitAnnotation extends Annotation {
  final num limit;
  final DashPainter? dashPainter;
  final Color color;
  final double strokeWidth;
  LimitAnnotation({
    super.scroll = false,
    super.yAxisPosition = 0,
    required this.limit,
    this.dashPainter,
    this.color = Colors.red,
    this.strokeWidth = 1,
  });
  @override
  void draw() {
    if (coordinateChart is LineBarChartCoordinateRender) {
      LineBarChartCoordinateRender chart = coordinateChart as LineBarChartCoordinateRender;
      num po = limit;
      double itemHeight = po * chart.yAxis[0].density;
      Offset start = Offset(chart.padding.left, chart.contentRect.bottom - itemHeight);
      Offset end = Offset(chart.size.width - chart.padding.right, chart.contentRect.bottom - itemHeight);

      Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      Path path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
      DashPainter painter = dashPainter ?? const DashPainter(span: 5, step: 5, pointCount: 0);
      painter.paint(chart.canvas, path, paint);
    }
  }
}
