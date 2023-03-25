import 'package:flutter/material.dart';

import '../../flutter_chart.dart';

class LabelAnnotation<T> extends Annotation<T> {
  final List<num> positions;
  final TextStyle textStyle;
  final String text;
  LabelAnnotation({
    required this.positions,
    required this.text,
    this.textStyle = const TextStyle(color: Colors.red),
  });
  @override
  void draw() {
    if (coordinateChart is LineBarChartCoordinateRender) {
      LineBarChartCoordinateRender chart = coordinateChart as LineBarChartCoordinateRender;
      num xPo = positions[0];
      num yPo = positions[1];
      double itemWidth = xPo * chart.xAxis.density!;
      double itemHeight = yPo * chart.yAxis.density!;
      Offset offset = Offset(chart.padding.left + itemWidth, chart.contentRect.bottom - itemHeight);

      TextPainter textPainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: text,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(
          minWidth: 0,
          maxWidth: chart.size.width,
        )
        ..paint(chart.canvas, offset);
    }
  }
}
