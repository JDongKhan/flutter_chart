import 'package:flutter/material.dart';

import '../coordinate/dimensions_chart_coordinate_render.dart';
import 'annotation.dart';

//路径
class PathAnnotation extends Annotation {
  final Path path;
  final Color color;
  final Offset Function(Size)? anchor;

  PathAnnotation({
    super.scroll = true,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.path,
    this.color = const Color(0xFFF5F5F5),
    this.anchor,
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
      Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 1;

      Path newPath = path;
      if (anchor != null) {
        Offset ost = anchor!(chart.size);
        final matrix = Matrix4.identity()..leftTranslate(ost.dx, ost.dy);
        newPath = path.transform(matrix.storage);
      }
      canvas.drawPath(newPath, paint);
    }
  }
}
