import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../flutter_chart.dart';

typedef AnnotationPosition<T> = num Function(T);

/// @author jd
class LimitAnnotation extends Annotation {
  ///限制线对应y轴的value
  final num limit;

  ///线的颜色
  final Color color;

  ///线宽
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
  Paint? _paint;
  Path? _path;

  @override
  void init(ChartCoordinateRender coordinateChart) {
    super.init(coordinateChart);
    if (coordinateChart is DimensionsChartCoordinateRender) {
      DimensionsChartCoordinateRender chart = coordinateChart;
      num po = limit;
      double itemHeight = chart.yAxis[yAxisPosition].relativeHeight(po);
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

      _paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      Path path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);

      Path kDashPath = dashPath(path, dashArray: CircularIntervalList([3, 3]), dashOffset: null);
      _path = kDashPath;
    }
  }

  @override
  void draw(Canvas canvas, Size size) {
    if (minZoomVisible != null && coordinateChart.controller.zoom < minZoomVisible!) {
      return;
    }
    if (maxZoomVisible != null && coordinateChart.controller.zoom > maxZoomVisible!) {
      return;
    }
    if (_path != null && _paint != null) {
      canvas.drawPath(_path!, _paint!);
    }
  }
}
