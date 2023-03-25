import 'package:flutter/material.dart';
import 'package:flutter_chart/flutter_chart.dart';

//区间标注
class RegionAnnotation<T> extends Annotation<T> {
  final List<num> positions;
  final Color color;
  RegionAnnotation({
    super.scroll = true,
    required this.positions,
    this.color = const Color(0xFFF5F5F5),
  });
  @override
  void draw() {
    if (coordinateChart is LineBarChartCoordinateRender) {
      LineBarChartCoordinateRender chart = coordinateChart as LineBarChartCoordinateRender;
      num po1 = positions[0];
      num po2 = positions[1];
      double start = withXOffset(chart.contentMargin.left + po1 * chart.xAxis.density);
      double end = withXOffset(chart.contentMargin.left + po2 * chart.xAxis.density);
      double top = chart.contentMargin.top;
      double bottom = chart.size.height - chart.contentMargin.bottom;

      Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeWidth = 1;
      chart.canvas.drawRect(Rect.fromLTRB(start, top, end, bottom), paint);
    }
  }
}
