import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../measure/chart_circular_param.dart';
import '../../measure/chart_param.dart';
import '../../utils/chart_utils.dart';
import '../../base/chart_body_render.dart';
import '../../measure/chart_layout_param.dart';
import '../../coordinate/chart_circular_coordinate_render.dart';
import 'pie.dart';

typedef RadarChartValue<T> = List<num> Function(T);
typedef RadarValueFormatter<T> = List<dynamic> Function(T);
typedef RadarLegendFormatter = List<dynamic> Function();

///雷达图
/// @author JD
class Radar<T> extends ChartBodyRender<T> {
  ///开始的方向
  final RotateDirection direction;

  ///最大值
  final num max;

  ///点的位置
  final RadarChartValue<T> values;

  ///值文案格式化 不要使用过于耗时的方法
  final RadarValueFormatter? valueFormatter;

  ///图例文案格式化 不要使用过于耗时的方法
  final RadarLegendFormatter? legendFormatter;

  ///基线的颜色
  final Color lineColor;

  ///值的线颜色
  final List<Color> colors;

  ///值的填充颜色
  final List<Color>? fillColors;

  ///图例样式
  final TextStyle legendTextStyle;

  ///开始弧度，可以调整起始位置
  final double startAngle;

  Radar({
    required super.data,
    required this.values,
    required this.max,
    this.lineColor = Colors.black12,
    this.direction = RotateDirection.forward,
    this.valueFormatter,
    this.legendFormatter,
    this.colors = colors10,
    this.startAngle = -math.pi / 2,
    this.fillColors,
    this.legendTextStyle = const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
  });

  @override
  void draw(ChartParam param, Canvas canvas, Size size) {
    param as ChartCircularParam;
    Offset center = param.center;
    double radius = param.radius;

    //开始点
    double startAngle = this.startAngle;
    int itemLength = data.length;
    double percent = 1 / itemLength;
    List<ChartLayoutParam> childrenLayoutParams = [];
    // 计算出每个数据所占的弧度值
    final sweepAngle = percent * math.pi * 2 * (direction == RotateDirection.forward ? 1 : -1);

    //图例
    List<dynamic>? legendList = legendFormatter?.call();

    // 设置绘制属性
    final linePaint = Paint()
      ..strokeWidth = 1.0
      ..isAntiAlias = true
      ..color = lineColor
      ..style = PaintingStyle.stroke;

    Path linePath = Path();
    Map<int, Path> dataLinePathList = {};
    List<RadarTextPainter> textPainterList = [];
    for (int i = 0; i < itemLength; i++) {
      T itemData = data[i];
      //画边框
      final x = math.cos(startAngle) * radius + center.dx;
      final y = math.sin(startAngle) * radius + center.dy;
      canvas.drawLine(center, Offset(x, y), linePaint);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }

      if (legendList != null) {
        String legend = legendList[i].toString();
        TextPainter legendTextPainter = TextPainter(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: legend,
            style: legendTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout(
            minWidth: 0,
            maxWidth: param.size.width,
          );
        bool isLeft = x < center.dx;
        bool isBottom = y >= center.dy;
        Offset textOffset = Offset(isLeft ? (x - legendTextPainter.width) : x, isBottom ? y : y - legendTextPainter.height);
        //最后再绘制，防止被挡住
        textPainterList.add(RadarTextPainter(textPainter: legendTextPainter, offset: textOffset));
      }

      //画value线
      List<num> pos = values.call(itemData);
      List<dynamic>? valueLegendList = valueFormatter?.call(itemData);
      assert(valueLegendList == null || pos.length == valueLegendList.length);
      for (int j = 0; j < pos.length; j++) {
        Path? dataLinePath = dataLinePathList[j];
        if (dataLinePath == null) {
          dataLinePath = Path();
          dataLinePathList[j] = dataLinePath;
        }
        num subPos = pos[j];
        double vp = subPos / max;
        double newRadius = radius * vp;
        final dataX = math.cos(startAngle) * newRadius + center.dx;
        final dataY = math.sin(startAngle) * newRadius + center.dy;
        if (i == 0) {
          dataLinePath.moveTo(dataX, dataY);
        } else {
          dataLinePath.lineTo(dataX, dataY);
        }

        //画文案
        if (valueLegendList != null) {
          String legend = valueLegendList[j].toString();
          TextPainter legendTextPainter = TextPainter(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: legend,
              style: legendTextStyle,
            ),
            textDirection: TextDirection.ltr,
          )..layout(
              minWidth: 0,
              maxWidth: param.size.width,
            );
          bool isLeft = dataX < center.dx;
          bool isTop = dataY <= (center.dy - radius) && legendList != null;
          Offset textOffset = Offset(isLeft ? (dataX - legendTextPainter.width) : dataX, isTop ? dataY : dataY - legendTextPainter.height);
          //最后再绘制，防止被挡住
          textPainterList.add(RadarTextPainter(textPainter: legendTextPainter, offset: textOffset));
        }
      }

      //继续下一个
      startAngle = startAngle + sweepAngle;
    }
    linePath.close();
    canvas.drawPath(linePath, linePaint);
    //画数据
    int index = 0;
    for (Path dataPath in dataLinePathList.values) {
      dataPath.close();

      // 设置绘制属性
      final dataLinePaint = Paint()
        ..strokeWidth = 1.0
        ..color = colors[index]
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke;
      canvas.drawPath(dataPath, dataLinePaint);

      if (fillColors != null) {
        final fillDataLinePaint = Paint()
          ..color = fillColors![index]
          ..isAntiAlias = true
          ..style = PaintingStyle.fill;
        canvas.drawPath(dataPath, fillDataLinePaint);
      }
      index++;
    }
    //最后再绘制，防止被挡住
    for (RadarTextPainter textPainter in textPainterList) {
      textPainter.textPainter.paint(canvas, textPainter.offset);
    }

    layoutParam.children = childrenLayoutParams;
  }
}

class RadarTextPainter {
  final TextPainter textPainter;
  final Offset offset;
  RadarTextPainter({required this.textPainter, required this.offset});
}
