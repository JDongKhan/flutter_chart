import 'dart:ui';

import 'package:flutter/material.dart';
import '../../param/chart_dimension_param.dart';
import '../../param/chart_param.dart';
import '../../utils/chart_utils.dart';
import '../../base/chart_body_render.dart';
import '../../param/chart_layout_param.dart';

typedef LinePosition<T> = List<num> Function(T);

/// @author JD
class Line<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///每个点对应的值 不要使用过于耗时的方法
  final LinePosition values;

  ///线颜色
  final List<Color> colors;

  ///优先级高于colors  跟filled有关，false是折线的颜色，true是填充色
  final List<Shader>? shaders;

  ///点的颜色
  final List<Color>? dotColors;

  ///点半径
  final double dotRadius;

  ///是否有空心圆
  final bool isHollow;

  ///线宽
  final double strokeWidth;

  ///是否填充颜色  true：填充，false：不填充  默认false
  final bool? filled;

  ///是否是曲线  默认false
  final bool isCurve;

  ///路径之间的处理规则
  final PathOperation? operation;

  Line({
    required super.data,
    required this.position,
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
    this.operation,
  });

  ///线 画笔
  late final Paint paint = Paint()
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke;

  late final Paint _dotPaint = Paint()..strokeWidth = strokeWidth;

  Paint? _fullPaint;

  @override
  void init(ChartParam param) {
    super.init(param);
    layoutParam.children = List.generate(data.length, (index) => ChartLayoutParam()).toList();
    //这里可以提前计算好数据
    if (filled == true) {
      _fullPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill;
    }
  }

  @override
  void draw(Canvas canvas, ChartParam param) {
    param as ChartDimensionParam;
    List<ChartLayoutParam> shapeList = layoutParam.children;
    List<ChartLayoutParam>? lastDataList = getLastData(param.animal);
    int index = 0;
    //offset.dx 滚动偏移  (src.zoom - 1) * (src.size.width / 2) 缩放
    double left = param.contentMargin.left;
    double right = param.size.width - param.contentMargin.right;
    double top = param.contentMargin.top;
    double bottom = param.size.height - param.contentMargin.bottom;
    Map<int, LineInfo> pathMap = {};
    ChartLayoutParam? lastShape;
    num? lastXValue;
    //遍历数据 处理数据信息
    for (T value in data) {
      ChartLayoutParam currentPointLayout = shapeList[index];
      num? xValue = currentPointLayout.xValue;
      xValue ??= position.call(value);
      if (lastXValue != null) {
        assert(lastXValue < xValue, '虽然支持逆序，但是为了防止数据顺序混乱，还是强制要求必须是正序的数组');
      }
      List<num>? yValues = currentPointLayout.yValues;
      yValues ??= values.call(value);

      //保存数据
      currentPointLayout.xValue = xValue;
      currentPointLayout.yValues = yValues;

      /******* 动画 *********/
      assert(colors.length >= yValues.length, '颜色配置跟数据源不匹配');
      assert(shaders == null || shaders!.length >= yValues.length, '颜色配置跟数据源不匹配');
      //是否有动画
      if (param.animal && param.controlValue < 1) {
        List<num>? lastYValue;
        num? lastXValue;
        if (lastDataList != null && index < lastDataList.length) {
          ChartLayoutParam p = lastDataList[index];
          lastYValue = p.children.map((e) => e.yValue ?? 0).toList();
          lastXValue = p.xValue;
        }
        if (lastXValue != null) {
          //初始动画x轴不动
          xValue = lerpDouble(lastXValue, xValue, param.controlValue) ?? xValue;
        }
        yValues = lerpList(lastYValue, yValues, param.controlValue) ?? yValues;
      }

      //先判断是否选中，此场景是第一次渲染之后点击才有，所以用老数据即可
      if (param.localPosition != null && index < shapeList.length && (shapeList[index].hitTest(param.localPosition!) == true)) {
        layoutParam.selectedIndex = index;
      }

      //计算x轴和y轴的物理位置
      double xPos = xValue * param.xAxis.density + left;
      xPos = param.transform.withXOffset(xPos);

      //一组数据下可能多条线
      for (int valueIndex = 0; valueIndex < yValues.length; valueIndex++) {
        //每条线用map存放下，以便后面统一绘制
        LineInfo? lineInfo = pathMap[valueIndex];
        if (lineInfo == null) {
          lineInfo = LineInfo();
          pathMap[valueIndex] = lineInfo;
        }
        //计算点的位置
        num yValue = yValues[valueIndex];
        //y轴位置
        double yPos = bottom - param.yAxis[yAxisPosition].relativeHeight(yValue);
        yPos = param.transform.withYOffset(yPos);
        Offset currentPoint = Offset(xPos, yPos);
        //数据过滤
        if (!param.outDraw && xPos < 0) {
          lineInfo.startPoint = currentPoint;
          // debugPrint('1-第${index + 1}个数据超出去');
          continue;
        }
        lineInfo.startPoint ??= currentPoint;

        //点的信息
        ChartLayoutParam childLayoutParam;
        if (valueIndex < currentPointLayout.children.length) {
          childLayoutParam = currentPointLayout.children[valueIndex];
        } else {
          childLayoutParam = ChartLayoutParam();
          currentPointLayout.children.add(childLayoutParam);
        }

        childLayoutParam.setRect(Rect.fromCenter(center: currentPoint, width: dotRadius, height: dotRadius));
        childLayoutParam.index = index;
        childLayoutParam.xValue = xValue;
        childLayoutParam.yValue = yValue;
        //存放点的位置
        lineInfo.pointList.add(childLayoutParam);
      }

      Rect currentRect = Rect.fromLTRB(xPos - dotRadius, top, xPos + dotRadius, bottom);
      currentPointLayout.setRect(currentRect);
      currentPointLayout.left = left;
      currentPointLayout.right = right;
      //这里用链表解决查找附近节点的问题
      currentPointLayout.preShapeState = lastShape;
      lastShape?.nextShapeState = currentPointLayout;
      lastShape = currentPointLayout;
      //放到最后
      index++;
      lastXValue = xValue;

      //数据过滤
      if (!param.outDraw && xPos > param.size.width) {
        // debugPrint('2-第$index个数据超出去');
        break;
      }
    }

    //开启后可查看热区是否正确
    // int i = 0;
    // for (var element in shapeList) {
    //   Rect newRect = Rect.fromLTRB(element.getHotRect()!.left + 1, element.getHotRect()!.top + 1, element.getHotRect()!.right - 1, element.getHotRect()!.bottom);
    //   Paint newPaint = Paint()
    //     ..color = colors10[i % colors10.length]
    //     ..strokeWidth = strokeWidth
    //     ..style = PaintingStyle.stroke;
    //   canvas.drawRect(newRect, newPaint);
    //   i++;
    // }
    //开始绘制了
    _drawLine(param, canvas, pathMap);
  }

  void _drawLine(ChartParam param, Canvas canvas, Map<int, LineInfo> pathMap) {
    //画线
    if (strokeWidth > 0 || filled == true) {
      Path? lastPath;
      for (int index in pathMap.keys) {
        LineInfo? lineInfo = pathMap[index];
        if (lineInfo == null || lineInfo.pointList.isEmpty) {
          continue;
        }
        Path path = Path();
        path.moveTo(lineInfo.startPoint!.dx, lineInfo.startPoint!.dy);
        ChartLayoutParam? lastShape;
        for (int valueIndex = 0; valueIndex < lineInfo.pointList.length; valueIndex++) {
          ChartLayoutParam point = lineInfo.pointList[valueIndex];
          Offset currentPoint = point.rect!.center;
          if (isCurve) {
            double preX = lastShape!.rect!.center.dx;
            double preY = lastShape.rect!.center.dy;
            double xDiff = currentPoint.dx - preX;
            double centerX1 = preX + xDiff / 2;
            double centerY1 = preY;

            double centerX2 = currentPoint.dx - xDiff / 2;
            double centerY2 = currentPoint.dy;

            // chart.canvas.drawCircle(
            //     Offset(centerX1, centerY1), 2, Paint()..color = Colors.red);
            //
            // chart.canvas.drawCircle(
            //     Offset(centerX2, centerY2), 2, Paint()..color = Colors.blue);

            //绘制贝塞尔路径
            path.cubicTo(
              centerX1,
              centerY1, // control point 1
              centerX2,
              centerY2, //  control point 2
              currentPoint.dx,
              currentPoint.dy,
            );
          } else {
            path.lineTo(currentPoint.dx, currentPoint.dy);
          }
          lastShape = point;
        }

        //先画线
        if (strokeWidth > 0) {
          if (shaders != null && filled == false) {
            canvas.drawPath(path, paint..shader = shaders![index]);
          } else {
            canvas.drawPath(path, paint..color = colors[index]);
          }
        }

        //然后填充颜色
        if (filled == true) {
          Offset last = lineInfo.pointList.last.rect!.center;
          Offset first = lineInfo.pointList.first.rect!.center;
          path
            ..lineTo(last.dx, param.contentRect.bottom)
            ..lineTo(first.dx, param.contentRect.bottom);
          if (shaders != null) {
            _fullPaint?.shader = shaders![index];
          } else {
            _fullPaint?.color = colors[index];
          }
          Path newPath = path;
          if (operation != null) {
            if (lastPath != null) {
              newPath = Path.combine(operation!, newPath, lastPath);
            }
            lastPath = path;
          }
          canvas.drawPath(newPath, _fullPaint!);
        }
      }
    }
    //最后画点  防止被挡住
    // print(lineInfo.pointList);
    List<Color> dotColorList = dotColors ?? colors;
    for (int index in pathMap.keys) {
      LineInfo? lineInfo = pathMap[index];
      if (lineInfo == null) {
        continue;
      }
      if (dotRadius > 0) {
        for (ChartLayoutParam point in lineInfo.pointList) {
          if (!param.outDraw && point.rect!.center.dx < 0) {
            // debugPrint('1-第${lineInfo.pointList.indexOf(point) + 1} 个点 $point 超出去');
            continue;
          }
          if (!param.outDraw && point.rect!.center.dx > param.size.width) {
            // debugPrint('2-第${lineInfo.pointList.indexOf(point) + 1} 个点 $point超出去');
            break;
          }
          //再画空心
          if (isHollow) {
            //先用白色覆盖
            _dotPaint.style = PaintingStyle.fill;
            canvas.drawCircle(point.rect!.center, dotRadius, _dotPaint..color = Colors.white);
            _dotPaint.style = PaintingStyle.stroke;
          } else {
            _dotPaint.style = PaintingStyle.fill;
          }
          canvas.drawCircle(point.rect!.center, dotRadius, _dotPaint..color = dotColorList[index]);
        }
      }
    }
  }
}

class LineInfo {
  Offset? startPoint;
  List<ChartLayoutParam> pointList = [];
  LineInfo();
}
