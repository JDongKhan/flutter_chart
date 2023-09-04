import 'package:flutter/material.dart';

import '../../base/chart_param.dart';
import '../../coordinate/dimensions_chart_coordinate_render.dart';
import '../../base/chart_body_render.dart';

typedef ScatterValue<T> = num Function(T);

typedef ScatterColor<T> = Color Function(T);

typedef ScatterStyleFunction<T> = ScatterStyle Function(T);

ScatterStyleFunction _defaultScatterStyleFunction = (item) => const ScatterStyle(color: Colors.blue, radius: 2);

/// @author JD
class Scatter<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///每个点对应的值 不要使用过于耗时的方法
  final ScatterValue value;

  ///点的风格
  final ScatterStyleFunction style;

  Scatter({
    required super.data,
    required this.position,
    required this.value,
    ScatterStyleFunction? style,
  }) : style = style ?? _defaultScatterStyleFunction;

  @override
  void draw(ChartParam param, Canvas canvas, Size size) {
    DimensionsChartCoordinateRender chart = coordinateChart as DimensionsChartCoordinateRender;
    //offset.dx 滚动偏移  (src.zoom - 1) * (src.size.width / 2) 缩放
    double left = chart.contentMargin.left;
    left = chart.transformUtils.withXZoomOffset(left);

    double right = chart.size.width - chart.contentMargin.right;
    double top = chart.contentMargin.top;
    double bottom = chart.size.height - chart.contentMargin.bottom;

    Paint dotPaint = Paint()..strokeWidth = 1;

    //遍历数据 处理数据信息
    for (T itemData in data) {
      num xvs = position.call(itemData);
      num yvs = value.call(itemData);
      double xPo = xvs * chart.xAxis.density + left;
      double yPo = bottom - chart.yAxis[yAxisPosition].relativeHeight(yvs);
      yPo = chart.transformUtils.withYOffset(yPo);
      ScatterStyle sy = style.call(itemData);
      //最后画点
      if (sy.radius > 0) {
        dotPaint.style = PaintingStyle.fill;
        Color color = sy.color;
        canvas.drawCircle(Offset(xPo, yPo), sy.radius, dotPaint..color = color);
      }
    }
  }
}

class ScatterStyle {
  final Color color;
  final double radius;
  const ScatterStyle({
    required this.color,
    required this.radius,
  });
}
