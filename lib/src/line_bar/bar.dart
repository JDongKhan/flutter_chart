import 'package:flutter/material.dart';

import '../base/chart_body_render.dart';
import '../base/chart_controller.dart';
import '../base/chart_coordinate_render.dart';
import 'line_bar_chart_coordinate_render.dart';

typedef BarPosition<T> = num Function(T);

/// @author JD
///普通bar
class Bar<T> extends ChartBodyRender<T> {
  //bar的宽度
  final double itemWidth;
  //值格式化
  final BarPosition value;
  //颜色
  final Color color;
  //高亮颜色
  final Color highlightColor;
  Bar({
    required super.data,
    required this.value,
    required super.position,
    this.itemWidth = 20,
    this.color = Colors.blue,
    this.highlightColor = Colors.yellow,
  });
  @override
  void draw() {
    LineBarChartCoordinateRender<T> chart = coordinateChart as LineBarChartCoordinateRender<T>;
    List<ChartShape> shapeList = [];
    for (int index = 0; index < data.length; index++) {
      T value = data[index];
      shapeList.add(_draw(chart, index, value));
    }
    chart.controller.shapeList = shapeList;
  }

  ChartShape _draw(LineBarChartCoordinateRender<T> chart, int index, T data) {
    num po = position.call(data);
    num v = value.call(data);
    if (v == 0) {
      return ChartShape();
    }
    double bottom = chart.size.height - chart.contentMargin.bottom;
    double contentHeight = chart.size.height - chart.contentMargin.vertical;

    double left = chart.contentMargin.left + chart.xAxis.density * po - itemWidth / 2;
    left = withXOffset(left);
    left = withXZoom(left);

    double present = v / chart.yAxis.max;
    double itemHeight = contentHeight * present;
    double top = bottom - itemHeight;
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
    ChartShape shape = ChartShape.rect(
      rect: rect,
    );
    if (shape.hitTest(chart.controller.gesturePoint)) {
      chart.controller.selectedIndex = index;
      paint.color = highlightColor;
    }
    chart.canvas.drawRect(rect, paint);
    return shape;
  }
}

typedef StackBarPosition<T> = List<num> Function(T);

//stackBar  支持水平/垂直排列
class StackBar<T> extends ChartBodyRender<T> {
  //值格式化
  final StackBarPosition<T> values;
  //bar的宽度
  final double itemWidth;
  //多个颜色
  final List<Color> colors;
  //高亮颜色
  final Color highlightColor;
  //方向
  final Axis direction;
  //撑满 如果为true则会根据实际数值的总和求比例，如果为false则会根据Y轴最大值求比例
  final bool full;

  final double padding;

  StackBar({
    required super.data,
    required super.position,
    required this.values,
    this.highlightColor = Colors.yellow,
    this.colors = colors10,
    this.itemWidth = 20,
    this.direction = Axis.horizontal,
    this.full = false,
    this.padding = 5,
  });
  @override
  void draw() {
    LineBarChartCoordinateRender<T> chart = coordinateChart as LineBarChartCoordinateRender<T>;
    List<ChartShape> shapeList = [];
    for (int index = 0; index < data.length; index++) {
      T value = data[index];
      if (direction == Axis.horizontal) {
        shapeList.add(_drawHorizontal(chart, index, value));
      } else {
        shapeList.add(_drawVertical(chart, index, value));
      }
    }
    chart.controller.shapeList = shapeList;
  }

  //水平排列图形
  ChartShape _drawHorizontal(LineBarChartCoordinateRender<T> chart, int index, T data) {
    num po = position.call(data);
    List<num> vas = values.call(data);
    assert(colors.length >= vas.length);
    num total = chart.yAxis.max;
    if (total == 0) {
      return ChartShape();
    }
    double bottom = chart.size.height - chart.contentMargin.bottom;
    double contentHeight = chart.size.height - chart.contentMargin.vertical;
    int stackIndex = 0;

    double center = vas.length * itemWidth / 2;

    double left = chart.contentMargin.left + chart.xAxis.density * po - itemWidth / 2 - center;
    left = withXOffset(left);
    left = withXZoom(left);

    ChartShape shape = ChartShape.rect(
      rect: Rect.fromLTWH(
        left,
        chart.contentMargin.top,
        itemWidth * vas.length + padding * (vas.length - 1),
        chart.size.height - chart.contentMargin.vertical,
      ),
    );

    for (num v in vas) {
      double present = v / total;
      double itemHeight = contentHeight * present;
      double top = bottom - itemHeight;
      Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
      ChartShape stackShape = ChartShape.rect(rect: rect);
      Paint paint = Paint()
        ..color = colors[stackIndex]
        ..strokeWidth = 1
        ..style = PaintingStyle.fill;
      if (stackShape.hitTest(chart.controller.gesturePoint)) {
        chart.controller.selectedIndex = index;
        paint.color = highlightColor;
      }
      chart.canvas.drawRect(rect, paint);
      left = left + itemWidth + padding;
      shape.children.add(stackShape);
      stackIndex++;
    }
    return shape;
  }

  ChartShape _drawVertical(LineBarChartCoordinateRender<T> chart, int index, T data) {
    num po = position.call(data);
    List<num> vas = values.call(data);
    assert(colors.length >= vas.length);
    num total = chart.yAxis.max;
    if (full) {
      total = vas.fold(0, (previousValue, element) => previousValue + element);
    }
    if (total == 0) {
      return ChartShape();
    }
    double bottom = chart.size.height - chart.contentMargin.bottom;
    double contentHeight = chart.size.height - chart.contentMargin.vertical;
    int stackIndex = 0;
    double left = chart.contentMargin.left + chart.xAxis.density * po - itemWidth / 2;
    left = withXOffset(left);
    left = withXZoom(left);
    ChartShape shape = ChartShape.rect(
      rect: Rect.fromLTWH(
        left,
        chart.contentMargin.top,
        itemWidth,
        chart.size.height - chart.contentMargin.vertical,
      ),
    );

    for (num v in vas) {
      double present = v / total;
      double itemHeight = contentHeight * present;
      double top = bottom - itemHeight;
      Paint paint = Paint()
        ..color = colors[stackIndex]
        ..strokeWidth = 1
        ..style = PaintingStyle.fill;
      Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
      ChartShape stackShape = ChartShape.rect(rect: rect);
      if (stackShape.hitTest(chart.controller.gesturePoint)) {
        chart.controller.selectedIndex = index;
        paint.color = highlightColor;
        shape.children.add(stackShape);
      }
      chart.canvas.drawRect(rect, paint);
      stackIndex++;
      bottom = top;
    }
    return shape;
  }
}
