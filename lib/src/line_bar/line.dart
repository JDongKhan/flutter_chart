import 'package:flutter/material.dart';

import '../base/chart_body_render.dart';
import '../base/chart_coordinate_render.dart';
import '../base/chart_state.dart';
import 'line_bar_chart_coordinate_render.dart';

typedef LinePosition<T> = List<num> Function(T);

/// @author JD
class Line<T> extends ChartBodyRender<T> {
  final LinePosition values;
  final List<Color> colors;
  final List<Color>? dotColors;
  final double dotRadius;
  final bool isHollow;
  final double strokeWidth;
  Line({
    required super.data,
    required super.position,
    required this.values,
    super.yAxisPosition = 0,
    this.colors = colors10,
    this.dotColors,
    this.dotRadius = 2,
    this.strokeWidth = 1,
    this.isHollow = true,
  });

  @override
  void draw() {
    LineBarChartCoordinateRender chart = coordinateChart as LineBarChartCoordinateRender;
    List<ChartShapeState> shapeList = [];

    int index = 0;
    //offset.dx 滚动偏移  (src.zoom - 1) * (src.size.width / 2) 缩放
    double left = chart.contentMargin.left;
    left = withXOffset(left);
    left = withXZoom(left);

    double right = chart.size.width - chart.contentMargin.right;
    double top = chart.contentMargin.top;
    double bottom = chart.size.height - chart.contentMargin.bottom;
    Map<int, LineInfo> pathMap = {};
    ChartShapeState? lastShape;
    num? lastXvs;
    //遍历数据 处理数据信息
    for (T value in data) {
      num xvs = position.call(value);
      if (lastXvs != null) {
        assert(lastXvs < xvs, '虽然支持逆序，但是为了防止数据顺序混乱，还是强制要求必须是正序的数组');
      }
      List<num> yvs = values.call(value);
      List<ChartShapeState> shapes = [];
      assert(colors.length >= yvs.length, '颜色配置跟数据源不匹配');
      double xPo = xvs * chart.xAxis.density + left;

      //先判断是否选中，此场景是第一次渲染之后点击才有，所以用老数据即可
      List<ChartShapeState>? currentShapeList = chart.state.bodyStateList[positionIndex]?.shapeList;
      if (chart.state.gesturePoint != null && (currentShapeList?[index].hitTest(chart.state.gesturePoint!) == true)) {
        chart.state.bodyStateList[positionIndex]?.selectedIndex = index;
      }
      //一条数据下可能多条线
      for (int valueIndex = 0; valueIndex < yvs.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        LineInfo? lineInfo = pathMap[valueIndex];
        if (lineInfo == null) {
          lineInfo = LineInfo();
          pathMap[valueIndex] = lineInfo;
        }
        //计算点的位置
        num value = yvs[valueIndex];
        double yPo = bottom - (value * chart.yAxis[yAxisPosition].density);
        if (index == 0) {
          lineInfo.path.moveTo(xPo, yPo);
        } else {
          lineInfo.path.lineTo(xPo, yPo);
        }
        lineInfo.pointList.add(Offset(xPo, yPo));
        //存放点的位置
        ChartShapeState shape = ChartShapeState.rect(rect: Rect.fromCenter(center: Offset(xPo, yPo), width: dotRadius, height: dotRadius));
        shapes.add(shape);
      }
      //调整热区
      Rect currentRect = Rect.fromLTRB(xPo, top, xPo + dotRadius * 2, bottom);
      Rect currentTapRect;
      if (lastShape == null) {
        //说明当前是第一个
        currentTapRect = Rect.fromLTRB(left, top, right, bottom);
      } else {
        //正序
        if (lastXvs! < xvs) {
          double leftDiff = currentRect.left - lastShape.rect!.right;
          //最后一个
          if (index == data.length - 1) {
            currentTapRect = Rect.fromLTRB(currentRect.left - leftDiff / 2, top, right, bottom);
          } else {
            currentTapRect = Rect.fromLTRB(currentRect.left - leftDiff / 2, top, xPo + dotRadius * 2, bottom);
          }
          //调整前面一个
          lastShape.adjustHotRect(right: leftDiff / 2);
        } else {
          //逆序
          double rightDiff = currentRect.right - lastShape.rect!.left;
          //因为是逆序，这是就是最左边的那个
          if (index == data.length - 1) {
            currentTapRect = Rect.fromLTRB(left, top, currentRect.right - rightDiff / 2, bottom);
          } else {
            currentTapRect = Rect.fromLTRB(xPo, top, currentRect.right - rightDiff / 2, bottom);
          }
          //调整前面一个
          lastShape.adjustHotRect(left: rightDiff / 2);
        }
      }

      ChartShapeState shape = ChartShapeState.rect(rect: currentRect, hotRect: currentTapRect);
      shape.children.addAll(shapes);
      shapeList.add(shape);

      lastShape = shape;
      //放到最后
      index++;
      lastXvs = xvs;
    }

    //开启后可查看热区是否正确
    // int i = 0;
    // for (var element in shapeList) {
    //   Rect newRect = Rect.fromLTRB(element.hotRect!.left + 1, element.hotRect!.top + 1, element.hotRect!.right - 1, element.hotRect!.bottom);
    //   Paint newPaint = Paint()
    //     ..color = colors10[i]
    //     ..strokeWidth = strokeWidth
    //     ..style = PaintingStyle.stroke;
    //   chart.canvas.drawRect(newRect, newPaint);
    //   i++;
    // }
    //开始绘制了
    drawLine(pathMap);
    chart.state.bodyStateList[positionIndex]?.shapeList = shapeList;
  }

  void drawLine(Map<int, LineInfo> pathMap) {
    LineBarChartCoordinateRender chart = coordinateChart as LineBarChartCoordinateRender;
    //线
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    //点
    Paint dotPaint = Paint()..strokeWidth = strokeWidth;

    List<Color> dotColorList = dotColors ?? colors;
    pathMap.forEach((index, lineInfo) {
      //先画线
      chart.canvas.drawPath(lineInfo.path, paint..color = colors[index]);
      //先画点
      if (dotRadius > 0) {
        for (Offset point in lineInfo.pointList) {
          //先用白色覆盖
          dotPaint.style = PaintingStyle.fill;
          chart.canvas.drawCircle(Offset(point.dx, point.dy), dotRadius, dotPaint..color = Colors.white);
          //再画空心
          if (isHollow) {
            dotPaint.style = PaintingStyle.stroke;
          } else {
            dotPaint.style = PaintingStyle.fill;
          }
          chart.canvas.drawCircle(Offset(point.dx, point.dy), dotRadius, dotPaint..color = dotColorList[index]);
        }
      }
    });
  }
}

class LineInfo {
  final Path path = Path();
  final List<Offset> pointList = [];
  LineInfo();
}
