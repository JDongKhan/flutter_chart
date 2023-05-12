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
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.limit,
    this.dashPainter,
    this.color = Colors.red,
    this.strokeWidth = 1,
  });
  @override
  void draw(Canvas canvas, Size size) {
    if (minZoomVisible != null) {
      if (coordinateChart.controller.zoom < minZoomVisible!) {
        return;
      }
    }
    if (maxZoomVisible != null) {
      if (coordinateChart.controller.zoom > maxZoomVisible!) {
        return;
      }
    }
    if (coordinateChart is DimensionsChartCoordinateRender) {
      DimensionsChartCoordinateRender chart =
          coordinateChart as DimensionsChartCoordinateRender;
      num po = limit;
      double itemHeight = po * chart.yAxis[0].density;
      Offset start = Offset(
        chart.padding.left,
        chart.transformUtils.transformY(
          itemHeight,
          containPadding: true,
        ),
      );
      Offset end = Offset(
        chart.size.width - chart.padding.right,
        chart.transformUtils.transformY(
          itemHeight,
          containPadding: true,
        ),
      );

      Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      Path path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
      DashPainter painter =
          dashPainter ?? const DashPainter(span: 3, step: 5, pointCount: 0);
      painter.paint(canvas, path, paint);
    }
  }
}
