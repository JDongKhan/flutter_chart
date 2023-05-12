import 'package:flutter/material.dart';

import '../coordinate/dimensions_chart_coordinate_render.dart';
import 'annotation.dart';

//区间标注
class RegionAnnotation extends Annotation {
  final List<num> positions;
  final Color color;
  RegionAnnotation({
    super.scroll = true,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.positions,
    this.color = const Color(0xFFF5F5F5),
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
      num po1 = positions[0];
      num po2 = positions[1];
      double start = chart.transformUtils.transformX(po1 * chart.xAxis.density);
      start = chart.transformUtils.withXZoomOffset(start);
      double end = chart.transformUtils.transformX(po2 * chart.xAxis.density);
      end = chart.transformUtils.withXZoomOffset(end);

      double top = chart.contentMargin.top;
      double bottom = chart.size.height - chart.contentMargin.bottom;

      Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 1;
      canvas.drawRect(Rect.fromLTRB(start, top, end, bottom), paint);
    }
  }
}
