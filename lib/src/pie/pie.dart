import 'dart:math';

import 'package:flutter/material.dart';

import '../base/chart_body_render.dart';
import '../base/chart_coordinate_render.dart';
import '../base/chart_state.dart';
import 'pie_chart_coordinate_render.dart';

/// @author JD
typedef ValueFormatter<T> = String Function(T);

enum RotateDirection {
  forward,
  reverse,
}

class Pie<T> extends ChartBodyRender<T> {
  //颜色
  final List<Color> colors;
  //内圆半径
  final double holeRadius;
  //值的位置偏移
  final double valueTextOffset;
  //值文案格式化
  final ValueFormatter? valueFormatter;
  //图例文案格式化
  final ValueFormatter? legendFormatter;
  //值文字样式
  final TextStyle? textStyle;
  //图例样式
  final TextStyle legendTextStyle;
  //中间文案样式
  final TextStyle? centerTextStyle;
  //扇形的方向
  final RotateDirection direction;

  Pie({
    this.colors = colors10,
    this.holeRadius = 0,
    this.textStyle,
    this.legendTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    this.valueTextOffset = 0,
    this.valueFormatter,
    this.legendFormatter,
    this.centerTextStyle,
    this.direction = RotateDirection.forward,
    required super.data,
    required super.position,
  });
  @override
  void draw() {
    PieChartCoordinateRender chart = coordinateChart as PieChartCoordinateRender;
    Canvas canvas = chart.canvas;
    Offset center = chart.center;
    double radius = chart.radius;

    //先计算比例
    List<num> values = [];
    num total = 0;
    for (int i = 0; i < data.length; i++) {
      T item = data[i];
      //计算值
      num po = position.call(item);
      total += po;
      values.add(po);
    }

    // 设置绘制属性
    final paint = Paint()
      ..strokeWidth = 0.0
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    //开始画扇形
    double startAngle = 0;
    List<ChartShapeState> shapeList = [];
    assert(colors.length >= data.length);
    for (int i = 0; i < data.length; i++) {
      T item = data[i];
      //直接读取
      num percent = values[i] / total;
      // 计算出每个数据所占的弧度值
      final sweepAngle = percent * pi * 2 * (direction == RotateDirection.forward ? 1 : -1);

      ChartShapeState shape = ChartShapeState.arc(
        center: center,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        innerRadius: holeRadius,
        outRadius: radius,
      );
      shapeList.add(shape);

      ChartShapeState tapShape = shape;
      //判断是否选中
      bool selected = shape.hitTest(chart.state.gesturePoint);
      if (selected) {
        chart.state.bodyStateList[positionIndex]?.selectedIndex = i;
        tapShape = ChartShapeState.arc(
          center: center,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          innerRadius: holeRadius,
          outRadius: radius + 2,
        );
      }

      chart.canvas.drawPath(tapShape.path!, paint..color = colors[i]);
      //画圆弧
      // baseChart.canvas.drawArc(
      //     newRect, startAngle, sweepAngle, true, paint..color = colors[i]);

      //中心弧度
      final double radians = startAngle + sweepAngle / 2;

      //画图例
      if (legendFormatter != null) {
        String legend = legendFormatter!.call(item);
        TextPainter legendTextPainter = TextPainter(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: legend,
            style: legendTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout(
            minWidth: 0,
            maxWidth: chart.size.width,
          );
        // 根据三角函数计算中出标识文字的 x 和 y 位置，需要加上宽和高的一半适配 Canvas 的坐标
        double legendX = cos(radians) * (radius + chart.padding.horizontal) + chart.size.width / 2;
        double legendY = sin(radians) * (radius + chart.padding.vertical) + chart.size.height / 2;
        // 使用 TextPainter 绘制文字标识
        legendTextPainter.paint(canvas, Offset(legendX, legendY));
      }
      //画value
      String? valueText = valueFormatter?.call(item);
      if (textStyle != null && valueText != null) {
        // 使用 TextPainter 绘制文字标识
        valueText = valueFormatter!.call(item);
        TextPainter valueTextPainter = TextPainter(
          textAlign: TextAlign.start,
          text: TextSpan(
            text: valueText,
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout(
            minWidth: 0,
            maxWidth: chart.size.width,
          );
        // 使用三角函数计算文字位置 并根据文字大小适配
        double x = cos(radians) * (radius / 2 + valueTextOffset) + chart.size.width / 2 - valueTextPainter.width / 2;
        double y = sin(radians) * (radius / 2 + valueTextOffset) + chart.size.height / 2 - valueTextPainter.height / 2;
        valueTextPainter.paint(chart.canvas, Offset(x, y));
      }

      //中心点文案
      if (centerTextStyle != null && selected && valueText != null) {
        TextPainter valueTextPainter = TextPainter(
          textAlign: TextAlign.start,
          text: TextSpan(
            text: valueText,
            style: centerTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout(
            minWidth: 0,
            maxWidth: chart.size.width,
          );
        valueTextPainter.paint(canvas, center.translate(-valueTextPainter.width / 2, -valueTextPainter.height / 2));
      }

      //继续下一个
      startAngle = startAngle + sweepAngle;
    }
    chart.state.bodyStateList[positionIndex]?.shapeList = shapeList;
  }
}
