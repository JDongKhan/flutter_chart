import 'package:flutter/material.dart';

import '../coordinate/chart_coordinate_render.dart';
import 'annotation.dart';

/// @author jd
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

  Paint? _paint;
  Path? _path;
  @override
  void init(ChartCoordinateRender coordinateChart) {
    super.init(coordinateChart);
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    _path = path;
    if (anchor != null) {
      Offset ost = anchor!(coordinateChart.size);
      final matrix = Matrix4.identity()..leftTranslate(ost.dx, ost.dy);
      _path = path.transform(matrix.storage);
    }
  }

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
    if (_paint != null && _path != null) {
      canvas.drawPath(_path!, _paint!);
    }
  }
}
