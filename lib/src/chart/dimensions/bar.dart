import 'package:flutter/material.dart';

import '../../base/chart_param.dart';
import '../../coordinate/dimensions_chart_coordinate_render.dart';
import '../../utils/chart_utils.dart';
import '../../base/chart_body_render.dart';
import '../../measure/chart_layout_param.dart';

typedef BarPosition<T> = num Function(T);

/// @author JD
///普通bar
class Bar<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///bar的宽度
  final double itemWidth;

  ///值格式化 不要使用过于耗时的方法
  final BarPosition value;

  ///颜色
  final Color color;

  ///优先级高于color
  final Shader? shader;

  ///高亮颜色
  final Color highlightColor;

  Bar({
    required super.data,
    required this.value,
    required this.position,
    super.yAxisPosition,
    this.itemWidth = 20,
    this.color = Colors.blue,
    this.shader,
    this.highlightColor = Colors.yellow,
  });

  @override
  void draw(ChartParam param, Canvas canvas, Size size) {
    DimensionsChartCoordinateRender chart = coordinateChart as DimensionsChartCoordinateRender;
    List<ChartLayoutParam> childrenLayoutParams = [];
    Paint paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    for (int index = 0; index < data.length; index++) {
      T value = data[index];
      childrenLayoutParams.add(drawBar(param, canvas, chart, paint, index, value));
    }
    layoutParam.children = childrenLayoutParams;
  }

  //可以重写 自定义特殊的图形
  ChartLayoutParam drawBar(ChartParam param, Canvas canvas, DimensionsChartCoordinateRender chart, Paint paint, int index, T data) {
    num po = position.call(data);
    num v = value.call(data);
    if (v == 0) {
      return ChartLayoutParam();
    }
    double bottom = chart.size.height - chart.contentMargin.bottom;
    double contentHeight = chart.size.height - chart.contentMargin.vertical;

    double left = chart.contentMargin.left + chart.xAxis.density * po - itemWidth / 2;
    left = chart.transformUtils.withXZoomOffset(left);

    double present = v / chart.yAxis[yAxisPosition].max;
    double itemHeight = contentHeight * present;
    double top = bottom - itemHeight;

    Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
    ChartLayoutParam shape = ChartLayoutParam.rect(
      rect: rect,
    );
    if (shape.hitTest(param.localPosition)) {
      layoutParam.selectedIndex = index;
      paint.color = highlightColor;
    } else {
      if (shader != null) {
        paint.shader = shader;
      } else {
        paint.color = color;
      }
    }
    //开始绘制，bar不同于line，在循环中就可以绘制
    canvas.drawRect(rect, paint);
    return shape;
  }
}

typedef StackBarPosition<T> = List<num> Function(T);

///stackBar  支持水平/垂直排列
class StackBar<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///值格式化
  final StackBarPosition<T> values;

  ///bar的宽度
  final double itemWidth;

  ///多个颜色
  final List<Color> colors;

  ///优先级高于colors
  final List<Shader>? shaders;

  ///高亮颜色
  final Color highlightColor;

  ///方向
  final Axis direction;

  ///撑满 如果为true则会根据实际数值的总和求比例，如果为false则会根据Y轴最大值求比例
  final bool full;

  ///两个bar之间的间距
  final double padding;

  StackBar({
    required super.data,
    required this.position,
    required this.values,
    super.yAxisPosition = 0,
    this.highlightColor = Colors.yellow,
    this.colors = colors10,
    this.shaders,
    this.itemWidth = 20,
    this.direction = Axis.horizontal,
    this.full = false,
    this.padding = 5,
  });

  @override
  void draw(ChartParam param, Canvas canvas, Size size) {
    DimensionsChartCoordinateRender chart = coordinateChart as DimensionsChartCoordinateRender;
    List<ChartLayoutParam> childrenLayoutParams = [];
    for (int index = 0; index < data.length; index++) {
      T value = data[index];
      if (direction == Axis.horizontal) {
        childrenLayoutParams.add(drawHorizontalBar(param, canvas, chart, index, value));
      } else {
        childrenLayoutParams.add(drawVerticalBar(param, canvas, chart, index, value));
      }
    }
    layoutParam.children = childrenLayoutParams;
  }

  ///水平排列图形
  ChartLayoutParam drawHorizontalBar(ChartParam param, Canvas canvas, DimensionsChartCoordinateRender chart, int index, T data) {
    num po = position.call(data);
    List<num> vas = values.call(data);
    assert(colors.length >= vas.length);
    assert(shaders == null || shaders!.length >= vas.length);
    num total = chart.yAxis[yAxisPosition].max;
    if (total == 0) {
      return ChartLayoutParam();
    }
    double bottom = chart.size.height - chart.contentMargin.bottom;
    double contentHeight = chart.size.height - chart.contentMargin.vertical;
    int stackIndex = 0;

    double center = vas.length * itemWidth / 2;

    double left = chart.contentMargin.left + chart.xAxis.density * po - itemWidth / 2 - center;
    left = chart.transformUtils.withXZoomOffset(left);

    ChartLayoutParam shape = ChartLayoutParam.rect(
      rect: Rect.fromLTWH(
        left,
        chart.contentMargin.top,
        itemWidth * vas.length + padding * (vas.length - 1),
        chart.size.height - chart.contentMargin.vertical,
      ),
    );
    List<ChartLayoutParam> childrenLayoutParams = [];
    for (num v in vas) {
      double present = v / total;
      double itemHeight = contentHeight * present;
      double top = bottom - itemHeight;
      Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
      ChartLayoutParam stackShape = ChartLayoutParam.rect(rect: rect);
      Paint paint = Paint()
        ..strokeWidth = 1
        ..style = PaintingStyle.fill;
      if (shaders != null) {
        paint.shader = shaders![stackIndex];
      } else {
        paint.color = colors[stackIndex];
      }
      if (stackShape.hitTest(param.localPosition)) {
        layoutParam.selectedIndex = index;
        paint.color = highlightColor;
      }
      //画图
      canvas.drawRect(rect, paint);
      left = left + itemWidth + padding;
      childrenLayoutParams.add(stackShape);
      stackIndex++;
    }
    shape.children = childrenLayoutParams;
    return shape;
  }

  ///垂直排列图形
  ChartLayoutParam drawVerticalBar(ChartParam param, Canvas canvas, DimensionsChartCoordinateRender chart, int index, T data) {
    num po = position.call(data);
    List<num> vas = values.call(data);
    assert(colors.length >= vas.length);
    assert(shaders == null || shaders!.length >= vas.length);
    num total = chart.yAxis[yAxisPosition].max;
    if (full) {
      total = vas.fold(0, (previousValue, element) => previousValue + element);
    }
    if (total == 0) {
      return ChartLayoutParam();
    }
    double bottom = chart.size.height - chart.contentMargin.bottom;
    double contentHeight = chart.size.height - chart.contentMargin.vertical;
    int stackIndex = 0;
    double left = chart.contentMargin.left + chart.xAxis.density * po - itemWidth / 2;
    left = chart.transformUtils.withXZoomOffset(left);
    ChartLayoutParam shape = ChartLayoutParam.rect(
      rect: Rect.fromLTWH(
        left,
        chart.contentMargin.top,
        itemWidth,
        chart.size.height - chart.contentMargin.vertical,
      ),
    );
    List<ChartLayoutParam> childrenLayoutParams = [];
    for (num v in vas) {
      double present = v / total;
      double itemHeight = contentHeight * present;
      double top = bottom - itemHeight;
      Paint paint = Paint()
        ..strokeWidth = 1
        ..style = PaintingStyle.fill;
      if (shaders != null) {
        paint.shader = shaders![stackIndex];
      } else {
        paint.color = colors[stackIndex];
      }
      Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
      ChartLayoutParam stackShape = ChartLayoutParam.rect(rect: rect);
      if (stackShape.hitTest(param.localPosition)) {
        layoutParam.selectedIndex = index;
        paint.color = highlightColor;
        childrenLayoutParams.add(stackShape);
      }
      canvas.drawRect(rect, paint);
      stackIndex++;
      bottom = top;
    }
    shape.children = childrenLayoutParams;
    return shape;
  }
}
