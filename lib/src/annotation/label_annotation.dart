import 'package:flutter/material.dart';

import '../../flutter_chart.dart';

class LabelAnnotation extends Annotation {
  final List<num>? positions;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final String text;
  //是否跟随滚动
  final Offset offset;
  final Offset Function(Size)? anchor;
  LabelAnnotation({
    super.userInfo,
    super.onTap,
    super.scroll = true,
    super.yAxisPosition = 0,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.text,
    this.positions,
    this.anchor,
    this.offset = Offset.zero,
    this.textAlign = TextAlign.start,
    this.textStyle = const TextStyle(color: Colors.red),
  }) : assert(positions != null || anchor != null);

  TextPainter? _textPainter;

  @override
  void init(ChartCoordinateRender coordinateChart) {
    super.init(coordinateChart);
    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: coordinateChart.size.width,
      );
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
          left = chart.transformUtils.withXZoomOffset(left);
          top = chart.transformUtils.withYOffset(top);
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
        ost = Offset(left, top).translate(offset.dx, offset.dy);
      } else {
        ost = anchor!(chart.size);
      }

      if (textAlign == TextAlign.end) {
        ost = ost.translate(-_textPainter!.width, 0);
      } else if (textAlign == TextAlign.center) {
        ost = ost.translate(-_textPainter!.width / 2, 0);
      }
      _textPainter!.paint(canvas, ost);
    }
  }
}
