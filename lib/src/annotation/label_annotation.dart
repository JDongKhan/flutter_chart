import 'package:flutter/material.dart';

import '../../flutter_chart.dart';

class LabelAnnotation extends Annotation {
  final List<num>? positions;
  final TextStyle textStyle;
  final String text;
  //是否跟随滚动
  final Offset offset;
  final Offset Function(Size)? anchor;
  LabelAnnotation({
    super.userInfo,
    super.onTap,
    super.scroll = true,
    super.yAxisPosition = 0,
    required this.text,
    this.positions,
    this.anchor,
    this.offset = Offset.zero,
    this.textStyle = const TextStyle(color: Colors.red),
  }) : assert(positions != null || anchor != null);
  @override
  void draw(final Offset offset) {
    if (coordinateChart is DimensionsChartCoordinateRender) {
      DimensionsChartCoordinateRender chart =
          coordinateChart as DimensionsChartCoordinateRender;
      Offset ost;
      if (positions != null) {
        num xPo = positions![0];
        num yPo = positions![1];
        double itemWidth = xPo * chart.xAxis.density;
        double itemHeight = yPo * chart.yAxis[yAxisPosition].density;
        double left = chart.transformUtils.transformX(
          itemWidth,
          containPadding: true,
        );
        double top = chart.transformUtils.transformY(
          itemHeight,
          containPadding: true,
        );
        if (scroll) {
          left = withXOffset(left);
          left = withXZoom(left);
          top = withYOffset(top);
        } else {
          //不跟随缩放
          if (chart.zoomHorizontal) {
            left = chart.transformUtils.transformX(
              itemWidth / chart.controller.zoom,
              containPadding: true,
            );
          }
          if (chart.zoomVertical) {
            top = chart.transformUtils.transformY(
              itemHeight / chart.controller.zoom,
              containPadding: true,
            );
          }
        }
        ost = Offset(left, top).translate(this.offset.dx, this.offset.dy);
      } else {
        ost = anchor!(chart.size);
      }

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
        ..paint(chart.canvas, ost);
    }
  }
}
