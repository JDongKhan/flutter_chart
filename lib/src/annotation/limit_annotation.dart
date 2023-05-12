import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../flutter_chart.dart';

typedef AnnotationPosition<T> = num Function(T);

class LimitAnnotation extends Annotation {
  final num limit;
  final Color color;
  final double strokeWidth;
  LimitAnnotation({
    super.scroll = false,
    super.yAxisPosition = 0,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.limit,
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

      Path kDashPath = dashPath(path,
          dashArray: CircularIntervalList([3, 3]), dashOffset: null);
      canvas.drawPath(kDashPath, paint);
    }
  }
}
