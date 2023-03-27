import 'package:flutter/material.dart';

import '../../flutter_chart.dart';

class LabelAnnotation extends Annotation {
  final List<num> positions;
  final TextStyle textStyle;
  final String text;
  //是否跟随滚动
  final Offset offset;
  LabelAnnotation({
    required this.positions,
    required this.text,
    this.offset = Offset.zero,
    super.scroll = true,
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
      double left = chart.contentMargin.left + itemWidth;
      double top = chart.contentRect.bottom - itemHeight;
      if (scroll) {
        left = withXOffset(left);
        left = withXZoom(left);
        top = withYOffset(top);
      } else {
        //不跟随缩放
        if (chart.zoomHorizontal) {
          left = chart.contentMargin.left + itemWidth / chart.state.zoom;
        }
        if (chart.zoomVertical) {
          top = chart.contentRect.bottom - itemHeight / chart.state.zoom;
        }
      }
      Offset offset = Offset(left, top);
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
        ..paint(chart.canvas, offset.translate(this.offset.dx, this.offset.dy));
    }
  }
}
