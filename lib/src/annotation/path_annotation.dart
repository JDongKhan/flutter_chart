import 'package:flutter/material.dart';

import '../line_bar/line_bar_chart_coordinate_render.dart';
import 'annotation.dart';

//路径
class PathAnnotation extends Annotation {
  final Path path;
  final Color color;
  final Offset Function(Size)? anchor;

  PathAnnotation({
    super.scroll = true,
    required this.path,
    this.color = const Color(0xFFF5F5F5),
    this.anchor,
  });
  @override
  void draw(final Offset offset) {
    if (coordinateChart is LineBarChartCoordinateRender) {
      LineBarChartCoordinateRender chart = coordinateChart as LineBarChartCoordinateRender;
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
      chart.canvas.drawPath(newPath, paint);
    }
  }
}
