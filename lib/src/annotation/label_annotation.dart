import 'package:flutter/material.dart';

import '../measure/chart_param.dart';
import '../coordinate/chart_coordinate_render.dart';
import '../coordinate/chart_dimensions_coordinate_render.dart';
import 'annotation.dart';

/// @author jd
class LabelAnnotation extends Annotation {
  ///两个长度的数组，优先级最高，ImageAnnotation的位置，对应xy轴的value
  final List<num>? positions;

  ///文本风格
  final TextStyle textStyle;

  ///对齐方式
  final TextAlign textAlign;

  ///内容
  final String text;

  ///偏移，可以做细微调整
  final Offset offset;

  ///设置Annotation的偏移，忽略positions的设置
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
  }) : assert(positions != null || anchor != null, 'positions or anchor must be not null');

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
  void draw(ChartParam param, Canvas canvas, Size size) {
    if (!needDraw(param)) {
      return;
    }

    if (coordinateChart is ChartDimensionsCoordinateRender) {
      ChartDimensionsCoordinateRender chart = coordinateChart as ChartDimensionsCoordinateRender;
      Offset ost;
      if (positions != null) {
        assert(positions!.length == 2, 'positions must be two length');
        num xPo = positions![0];
        num yPo = positions![1];
        double itemWidth = xPo * chart.xAxis.density;
        double itemHeight = chart.yAxis[yAxisPosition].relativeHeight(yPo);
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
              itemWidth / param.zoom,
              containPadding: true,
            );
          }
          if (chart.zoomVertical) {
            top = chart.transformUtils.transformY(
              itemHeight / param.zoom,
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
      super.location = ost;
      super.size = _textPainter!.size;
      _textPainter!.paint(canvas, ost);
    }
  }
}
