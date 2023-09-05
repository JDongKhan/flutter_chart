import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../measure/chart_param.dart';
import '../coordinate/chart_coordinate_render.dart';
import '../coordinate/chart_dimensions_coordinate_render.dart';
import 'annotation.dart';

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
  void init(ChartParam param, ChartCoordinateRender coordinateChart) {
    super.init(param, coordinateChart);
    if (coordinateChart is ChartDimensionsCoordinateRender) {
      ChartDimensionsCoordinateRender chart = coordinateChart;
      num po = limit;
      double itemHeight = chart.yAxis[yAxisPosition].relativeHeight(po);
      Offset start = Offset(
        chart.padding.left,
        param.transformUtils.transformY(
          itemHeight,
          containPadding: true,
        ),
      );
      Offset end = Offset(
        param.size.width - chart.padding.right,
        param.transformUtils.transformY(
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
  void draw(ChartParam param, Canvas canvas, Size size) {
    if (!needDraw(param)) {
      return;
    }
    if (_path != null && _paint != null) {
      canvas.drawPath(_path!, _paint!);
    }
  }
}
