import 'package:flutter/material.dart';

import '../base/chart_body_render.dart';
import '../base/chart_coordinate_render.dart';
import '../base/chart_shape_state.dart';
import '../coordinate/dimensions_chart_coordinate_render.dart';

typedef LinePosition<T> = List<num> Function(T);

/// @author JD
class Line<T> extends ChartBodyRender<T> {
  //每个点对应的值
  final LinePosition values;
  //线颜色
  final List<Color> colors;
  //优先级高于colors
  final List<Shader>? shaders;
  //点的颜色
  final List<Color>? dotColors;
  //点半径
  final double dotRadius;
  //是否有空心圆
  final bool isHollow;
  //线宽
  final double strokeWidth;
  //填充颜色
  final bool? filled;
  //曲线
  final bool isCurve;
  Line({
    required super.data,
    required super.position,
    required this.values,
    super.yAxisPosition = 0,
    this.colors = colors10,
    this.shaders,
    this.dotColors,
    this.dotRadius = 2,
    this.strokeWidth = 1,
    this.isHollow = false,
    this.filled = false,
    this.isCurve = false,
  });

  @override
  void draw(final Offset offset) {
    DimensionsChartCoordinateRender chart =
        coordinateChart as DimensionsChartCoordinateRender;
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
      assert(shaders == null || shaders!.length >= yvs.length, '颜色配置跟数据源不匹配');
      double xPo = xvs * chart.xAxis.density + left;

      //先判断是否选中，此场景是第一次渲染之后点击才有，所以用老数据即可
      List<ChartShapeState>? currentShapeList =
          chart.controller.childrenController[positionIndex]?.shapeList;
      if (chart.controller.gesturePoint != null &&
          (currentShapeList?[index].hitTest(chart.controller.gesturePoint!) ==
              true)) {
        chart.controller.childrenController[positionIndex]?.selectedIndex =
            index;
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
        yPo = withYOffset(yPo);
        if (index == 0) {
          lineInfo.path.moveTo(xPo, yPo);
        } else {
          if (isCurve) {
            ChartShapeState lastChild = lastShape!.children[valueIndex];
            double preX = lastChild.rect!.center.dx;
            double preY = lastChild.rect!.center.dy;
            double xDiff = xPo - preX;
            double centerX1 = preX + xDiff / 2;
            double centerY1 = preY;

            double centerX2 = xPo - xDiff / 2;
            double centerY2 = yPo;

            // chart.canvas.drawCircle(
            //     Offset(centerX1, centerY1), 2, Paint()..color = Colors.red);
            //
            // chart.canvas.drawCircle(
            //     Offset(centerX2, centerY2), 2, Paint()..color = Colors.blue);

            //绘制贝塞尔路径
            lineInfo.path.cubicTo(
              centerX1,
              centerY1, // control point 1
              centerX2,
              centerY2, //  control point 2
              xPo,
              yPo,
            );
          } else {
            lineInfo.path.lineTo(xPo, yPo);
          }
        }
        lineInfo.pointList.add(Offset(xPo, yPo));
        //存放点的位置
        ChartShapeState shape = ChartShapeState.rect(
            rect: Rect.fromCenter(
                center: Offset(xPo, yPo), width: dotRadius, height: dotRadius));
        shapes.add(shape);
      }

      Rect currentRect = Rect.fromLTRB(xPo, top, xPo + dotRadius * 2, bottom);
      ChartShapeState shape = ChartShapeState.rect(rect: currentRect);
      shape.left = left;
      shape.right = right;
      shape.children.addAll(shapes);
      //这里用链表解决查找附近节点的问题
      shape.preShapeState = lastShape;
      lastShape?.nextShapeState = shape;
      shapeList.add(shape);

      lastShape = shape;
      //放到最后
      index++;
      lastXvs = xvs;
    }

    //开启后可查看热区是否正确
    // int i = 0;
    // for (var element in shapeList) {
    //   Rect newRect = Rect.fromLTRB(
    //       element.getHotRect()!.left + 1,
    //       element.getHotRect()!.top + 1,
    //       element.getHotRect()!.right - 1,
    //       element.getHotRect()!.bottom);
    //   Paint newPaint = Paint()
    //     ..color = colors10[i % colors10.length]
    //     ..strokeWidth = strokeWidth
    //     ..style = PaintingStyle.stroke;
    //   chart.canvas.drawRect(newRect, newPaint);
    //   i++;
    // }
    //开始绘制了
    drawLine(pathMap);
    chart.controller.childrenController[positionIndex]?.shapeList = shapeList;
  }

  void drawLine(Map<int, LineInfo> pathMap) {
    DimensionsChartCoordinateRender chart =
        coordinateChart as DimensionsChartCoordinateRender;
    //线
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    //点
    Paint dotPaint = Paint()..strokeWidth = strokeWidth;

    Paint? fullPaint;
    if (filled == true) {
      fullPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill;
    }

    List<Color> dotColorList = dotColors ?? colors;
    pathMap.forEach((index, lineInfo) {
      //先画线
      chart.canvas.drawPath(lineInfo.path, paint..color = colors[index]);
      //然后填充颜色
      if (filled == true) {
        Offset last = lineInfo.pointList.last;
        Offset first = lineInfo.pointList.first;
        lineInfo.path
          ..lineTo(last.dx, chart.contentRect.bottom)
          ..lineTo(first.dx, chart.contentRect.bottom);

        if (shaders != null) {
          fullPaint!.shader = shaders![index];
        } else {
          fullPaint!.color = colors[index];
        }
        chart.canvas.drawPath(lineInfo.path, fullPaint);
      }
      //先画点
      if (dotRadius > 0) {
        for (Offset point in lineInfo.pointList) {
          //先用白色覆盖
          dotPaint.style = PaintingStyle.fill;
          chart.canvas.drawCircle(Offset(point.dx, point.dy), dotRadius,
              dotPaint..color = Colors.white);
          //再画空心
          if (isHollow) {
            dotPaint.style = PaintingStyle.stroke;
          } else {
            dotPaint.style = PaintingStyle.fill;
          }
          chart.canvas.drawCircle(Offset(point.dx, point.dy), dotRadius,
              dotPaint..color = dotColorList[index]);
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
