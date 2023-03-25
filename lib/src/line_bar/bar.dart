import 'package:flutter/material.dart';

import '../base/chart_controller.dart';
import '../base/chart_coordinate_render.dart';
import 'line_bar_chart_coordinate_render.dart';

typedef BarPosition<T> = num Function(T);

/// @author JD
///普通bar
class Bar<T> extends ChartRender<T> {
  //bar的宽度
  final double itemWidth;
  //值格式化
  final BarPosition position;
  //颜色
  final Color color;
  //高亮颜色
  final Color highlightColor;
  Bar({
    required this.position,
    this.itemWidth = 20,
    this.color = Colors.blue,
    this.highlightColor = Colors.yellow,
  });
  @override
  void draw(List<T> data) {
    LineBarChartCoordinateRender<T> chart = coordinateChart as LineBarChartCoordinateRender<T>;
    Offset offset = chart.controller!.offset;
    List<ChartShape> shapeList = [];
    for (int index = 0; index < data.length; index++) {
      T value = data[index];
      shapeList.add(_draw(chart, offset, index, value));
    }
    chart.controller?.shapeList = shapeList;
  }

  ChartShape _draw(LineBarChartCoordinateRender<T> chart, Offset offset, int index, T data) {
    num po = chart.position.call(data);
    num value = position.call(data);
    if (value == 0) {
      return ChartShape();
    }
    double bottom = chart.content.bottom;
    double contentHeight = chart.size.height - chart.content.vertical;

    double left = chart.content.left + chart.xAxis.density! * po - offset.dx - itemWidth / 2 - (chart.controller!.zoom - 1) * (chart.size.width / 2);

    double present = value / chart.yAxis.max;
    double itemHeight = contentHeight * present;
    double top = chart.size.height - bottom - itemHeight;
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
    ChartShape shape = ChartShape.rect(
      rect: rect,
    );
    if (shape.hitTest(chart.controller?.gesturePoint)) {
      chart.controller?.selectedIndex = index;
      paint.color = highlightColor;
    }
    chart.canvas.drawRect(rect, paint);
    return shape;
  }
}

typedef StackBarPosition<T> = List<num> Function(T);

//stackBar  支持水平/垂直排列
class StackBar<T> extends ChartRender<T> {
  //值格式化
  final StackBarPosition<T> position;
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

  StackBar({
    required this.position,
    this.highlightColor = Colors.yellow,
    this.colors = colors10,
    this.itemWidth = 20,
    this.direction = Axis.horizontal,
    this.full = false,
  });
  @override
  void draw(List<T> data) {
    LineBarChartCoordinateRender<T> chart = coordinateChart as LineBarChartCoordinateRender<T>;
    Offset offset = chart.controller!.offset;
    List<ChartShape> shapeList = [];
    for (int index = 0; index < data.length; index++) {
      T value = data[index];
      if (direction == Axis.horizontal) {
        shapeList.add(_drawHorizontal(chart, offset, index, value));
      } else {
        shapeList.add(_drawVertical(chart, offset, index, value));
      }
    }
    chart.controller?.shapeList = shapeList;
  }

  //水平排列图形
  ChartShape _drawHorizontal(LineBarChartCoordinateRender<T> chart, Offset offset, int index, T data) {
    num po = chart.position.call(data);
    List<num> values = position.call(data);
    assert(colors.length >= values.length);
    num total = chart.yAxis.max;
    if (total == 0) {
      return ChartShape();
    }
    double bottom = chart.content.bottom;
    double contentHeight = chart.size.height - chart.content.vertical;
    int stackIndex = 0;

    double center = values.length * itemWidth / 2;

    double left = chart.content.left + chart.xAxis.density! * po - offset.dx - itemWidth / 2 - (chart.controller!.zoom - 1) * (chart.size.width / 2) - center;
    double padding = 10;

    ChartShape shape = ChartShape.rect(
      rect: Rect.fromLTWH(
        left,
        chart.content.top,
        itemWidth * values.length + padding * (values.length - 1),
        chart.size.height - chart.content.vertical,
      ),
    );

    for (num v in values) {
      double present = v / total;
      double itemHeight = contentHeight * present;
      double top = chart.size.height - bottom - itemHeight;
      Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
      ChartShape stackShape = ChartShape.rect(rect: rect);
      Paint paint = Paint()
        ..color = colors[stackIndex]
        ..strokeWidth = 1
        ..style = PaintingStyle.fill;
      if (stackShape.hitTest(chart.controller?.gesturePoint)) {
        chart.controller?.selectedIndex = index;
        paint.color = highlightColor;
      }
      chart.canvas.drawRect(rect, paint);
      left = left + itemWidth + padding;
      shape.children.add(stackShape);
      stackIndex++;
    }
    return shape;
  }

  ChartShape _drawVertical(LineBarChartCoordinateRender<T> chart, Offset offset, int index, T data) {
    num po = chart.position.call(data);
    List<num> values = position.call(data);
    assert(colors.length >= values.length);
    num total = chart.yAxis.max;
    if (full) {
      total = values.fold(0, (previousValue, element) => previousValue + element);
    }
    if (total == 0) {
      return ChartShape();
    }
    double bottom = chart.content.bottom;
    double contentHeight = chart.size.height - chart.content.vertical;
    int stackIndex = 0;
    double left = chart.content.left + chart.xAxis.density! * po - offset.dx - itemWidth / 2 - (chart.controller!.zoom - 1) * (chart.size.width / 2);

    ChartShape shape = ChartShape.rect(
      rect: Rect.fromLTWH(
        left,
        chart.content.top,
        itemWidth,
        chart.size.height - chart.content.vertical,
      ),
    );

    for (num v in values) {
      double present = v / total;
      double itemHeight = contentHeight * present;
      double top = chart.size.height - bottom - itemHeight;
      Paint paint = Paint()
        ..color = colors[stackIndex]
        ..strokeWidth = 1
        ..style = PaintingStyle.fill;
      Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
      ChartShape stackShape = ChartShape.rect(rect: rect);
      if (stackShape.hitTest(chart.controller?.gesturePoint)) {
        chart.controller?.selectedIndex = index;
        paint.color = highlightColor;
        shape.children.add(stackShape);
      }
      chart.canvas.drawRect(rect, paint);
      stackIndex++;
      bottom += itemHeight;
    }
    return shape;
  }
}
