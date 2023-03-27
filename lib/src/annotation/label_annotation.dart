import 'package:flutter/material.dart';

import '../../flutter_chart.dart';

class LabelAnnotation extends Annotation {
  final List<num> positions;
  final TextStyle textStyle;
  final String text;
  //是否跟随滚动

  LabelAnnotation({
    required this.positions,
    required this.text,
    super.scroll = false,
    super.yAxisPosition = 0,
    this.textStyle = const TextStyle(color: Colors.red),
  });
  @override
  void draw() {
    if (coordinateChart is LineBarChartCoordinateRender) {
      LineBarChartCoordinateRender chart = coordinateChart as LineBarChartCoordinateRender;
      num xPo = positions[0];
      num yPo = positions[1];
      double itemWidth = xPo * chart.xAxis.density;
      double itemHeight = yPo * chart.yAxis[yAxisPosition].density;
      Offset offset = Offset(withXOffset(chart.contentMargin.left + itemWidth, scroll), withYOffset(chart.contentRect.bottom - itemHeight, scroll));
      TextPainter(
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
