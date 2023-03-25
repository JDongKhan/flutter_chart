import 'package:flutter/material.dart';

import '../base/chart_controller.dart';
import '../base/chart_coordinate_render.dart';
import 'line_bar_chart_coordinate_render.dart';

typedef LinePosition<T> = List<num> Function(T);

/// @author JD
class Line<T> extends ChartRender<T> {
  final LinePosition position;
  final List<Color> colors;
  final double dotRadius;
  final double strokeWidth;
  Line({
    required this.position,
    this.colors = colors10,
    this.dotRadius = 2,
    this.strokeWidth = 1,
  });

  @override
  void draw() {
    LineBarChartCoordinateRender<T> chart = coordinateChart as LineBarChartCoordinateRender<T>;
    List<T> data = chart.data;
    List<ChartShape> shapeList = [];
    //线
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    //点
    Paint dotPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.fill;

    int index = 0;
    //offset.dx 滚动偏移  (src.zoom - 1) * (src.size.width / 2) 缩放
    double left = chart.contentMargin.left;
    left = withXOffset(left);
    left = withXZoom(left);

    double right = chart.size.width - chart.contentMargin.right;
    double top = chart.contentMargin.top;
    double bottom = chart.size.height - chart.contentMargin.bottom;
    Map<int, Path> pathMap = {};
    ChartShape? lastShape;
    //遍历数据
    for (T value in data) {
      num xValue = chart.position.call(value);
      List<num> yValues = position.call(value);
      List<ChartShape> shapes = [];
      assert(colors.length >= yValues.length);
      double xPo = xValue * chart.xAxis.density + left;

      //先判断是否选中，此场景是第一次渲染之后点击才有，所以用老数据即可
      if (chart.controller.gesturePoint != null && (chart.controller.shapeList?[index].hitTest(chart.controller.gesturePoint!) == true)) {
        chart.controller.selectedIndex = index;
      }

      //一条数据下可能多条线
      for (int valueIndex = 0; valueIndex < yValues.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        Path? path = pathMap[valueIndex];
        if (path == null) {
          path = Path();
          pathMap[valueIndex] = path;
        }
        //计算点的位置
        num value = yValues[valueIndex];
        double yPo = bottom - (value * chart.yAxis.density);
        if (index == 0) {
          path.moveTo(xPo, yPo);
        } else {
          path.lineTo(xPo, yPo);
        }
        //先画点
        chart.canvas.drawCircle(Offset(xPo, yPo), dotRadius, dotPaint..color = colors[valueIndex]);
        //存放点的位置
        ChartShape shape = ChartShape.rect(rect: Rect.fromLTWH(xPo, yPo, dotRadius, dotRadius));
        shapes.add(shape);
      }
      //调整热区
      Rect currentTapRect;
      if (lastShape == null) {
        //说明当前是第一个
        currentTapRect = Rect.fromLTRB(left, top, left + dotRadius * 2, bottom);
      } else {
        double leftDiff = xPo - lastShape.hotRect!.right;
        //最后一个
        if (index == data.length - 1) {
          currentTapRect = Rect.fromLTRB(xPo - leftDiff / 2, top, right, bottom);
        } else {
          currentTapRect = Rect.fromLTRB(xPo - leftDiff / 2, top, xPo + dotRadius * 2, bottom);
        }
        //调整前面一个
        lastShape.translateHotRect(right: leftDiff / 2);
      }

      ChartShape shape = ChartShape.rect(rect: Rect.fromLTRB(xPo, top, xPo + dotRadius * 2, bottom), hotRect: currentTapRect);
      shape.children.addAll(shapes);
      shapeList.add(shape);

      lastShape = shape;
      //放到最后
      index++;
    }
    pathMap.forEach((index, path) {
      chart.canvas.drawPath(path, paint..color = colors[index]);
    });

    chart.controller.shapeList = shapeList;
  }
}
