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
  //引导线颜色
  final Color lineColor;
  //内圆半径
  final double holeRadius;
  //值的位置偏移
  final double valueTextOffset;
  //值文案格式化
  final ValueFormatter? valueFormatter;
  //图例文案格式化
  final ValueFormatter? legendFormatter;
  //值文字样式
  final TextStyle textStyle;
  //图例样式
  final TextStyle legendTextStyle;
  //中间文案样式 为空则不显示
  final TextStyle? centerTextStyle;
  //扇形的方向
  final RotateDirection direction;
  //百分比
  final double? spaceWidth;

  Pie({
    this.colors = colors10,
    this.holeRadius = 0,
    this.textStyle = const TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ),
    this.legendTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    this.lineColor = Colors.grey,
    this.spaceWidth,
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
    if (total == 0) {
      return;
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
    int index = 0;
    for (int i = 0; i < data.length; i++) {
      T item = data[i];
      //直接读取
      num percent = values[i] / total;
      // 计算出每个数据所占的弧度值
      final sweepAngle = percent * pi * 2 * (direction == RotateDirection.forward ? 1 : -1);
      double rd = radius;
      //图形区域
      ChartShapeState shape = ChartShapeState.arc(
        center: center,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        innerRadius: holeRadius,
        outRadius: rd,
      );
      shapeList.add(shape);

      //放大区域
      ChartShapeState tapShape = shape;
      //判断是否选中
      bool selected = shape.hitTest(chart.state.gesturePoint);
      if (selected) {
        rd = radius + 2;
        chart.state.bodyStateList[positionIndex]?.selectedIndex = i;
        tapShape = ChartShapeState.arc(
          center: center,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          innerRadius: holeRadius,
          outRadius: rd,
        );
      }
      drawPie(canvas, tapShape.path!, paint..color = colors[i]);
      //绘制间隙
      _drawSpaceLine(rd, startAngle, sweepAngle);

      String? valueText = valueFormatter?.call(item);
      String? legend = legendFormatter?.call(item);

      //绘制引导线
      _drawLineAndText(valueText, legend, index, rd, startAngle, sweepAngle);

      //选中就绘制
      if (selected) {
        _drawCenterValue(valueText);
      }
      //画圆弧
      // baseChart.canvas.drawArc(
      //     newRect, startAngle, sweepAngle, true, paint..color = colors[i]);
      // _drawLegend(item, radius, startAngle, sweepAngle);
      // _drawValue(item, radius, startAngle, sweepAngle, selected);
      //继续下一个
      startAngle = startAngle + sweepAngle;
      index++;
    }
    chart.state.bodyStateList[positionIndex]?.shapeList = shapeList;
  }

  //画空隙线
  void _drawSpaceLine(double radius, double startAngle, double sweepAngle) {
    if (spaceWidth == null) {
      return;
    }
    PieChartCoordinateRender chart = coordinateChart as PieChartCoordinateRender;
    Offset center = chart.center;
    Canvas canvas = chart.canvas;
    //开始线
    var start1X = cos(startAngle) * holeRadius + center.dx;
    var start1Y = sin(startAngle) * holeRadius + center.dy;
    Offset start1Offset = Offset(start1X, start1Y);
    var end1X = cos(startAngle) * radius + center.dx;
    var end1Y = sin(startAngle) * radius + center.dy;
    Offset end1Offset = Offset(end1X, end1Y);
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..strokeWidth = spaceWidth!;
    canvas.drawLine(start1Offset, end1Offset, paint);
    //结束线
    var start2X = cos(startAngle + sweepAngle) * holeRadius + center.dx;
    var start2Y = sin(startAngle + sweepAngle) * holeRadius + center.dy;
    Offset start2Offset = Offset(start2X, start2Y);
    var end2X = cos(startAngle + sweepAngle) * radius + center.dx;
    var end2Y = sin(startAngle + sweepAngle) * radius + center.dy;
    Offset end2Offset = Offset(end2X, end2Y);
    canvas.drawLine(start2Offset, end2Offset, paint);
  }

  void _drawLineAndText(String? valueText, String? legend, int index, double radius, double startAngle, double sweepAngle) {
    if (valueText == null && legend == null) {
      return;
    }
    PieChartCoordinateRender chart = coordinateChart as PieChartCoordinateRender;
    Offset center = chart.center;
    Canvas canvas = chart.canvas;
    //中心弧度
    final double radians = startAngle + sweepAngle / 2;
    double line1 = 10;
    double line2 = 40;
    Offset point1 = Offset(cos(radians) * (radius), sin(radians) * (radius)).translate(center.dx, center.dy);
    Offset point2 = Offset(cos(radians) * (radius + line1), sin(radians) * (radius + line1)).translate(center.dx, center.dy);
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = lineColor
      ..strokeWidth = 1;
    canvas.drawLine(point1, point2, paint);
    Offset point3;
    //绘制延长线
    bool isLeft;
    if ((point2.dx - point1.dx) > 0) {
      isLeft = false;
      //说明在左边
      point3 = Offset(point2.dx + line2, point2.dy);
      canvas.drawLine(point2, point3, paint);
    } else {
      isLeft = true;
      point3 = Offset(point2.dx - line2, point2.dy);
      canvas.drawLine(point2, point3, paint);
    }

    if (legend != null) {
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
      // 使用三角函数计算文字位置 并根据文字大小适配
      Offset textOffset = Offset(isLeft ? point3.dx : point3.dx - legendTextPainter.width, point3.dy - legendTextPainter.height);
      Paint dotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[index]
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(textOffset.dx - 6, textOffset.dy + legendTextPainter.height / 2), 4, dotPaint);
      legendTextPainter.paint(canvas, textOffset);
    }

    if (valueText != null) {
      // 使用 TextPainter 绘制文字标识
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
      Offset textOffset = Offset(isLeft ? point3.dx : point3.dx - valueTextPainter.width, point3.dy);
      valueTextPainter.paint(canvas, textOffset);
    }
  }

  //画图例
  // void _drawLegend(T item, double radius, double startAngle, double sweepAngle) {
  //   PieChartCoordinateRender chart = coordinateChart as PieChartCoordinateRender;
  //   //中心弧度
  //   final double radians = startAngle + sweepAngle;
  //   //画图例
  //   if (legendFormatter != null) {
  //     String legend = legendFormatter!.call(item);
  //     TextPainter legendTextPainter = TextPainter(
  //       textAlign: TextAlign.center,
  //       text: TextSpan(
  //         text: legend,
  //         style: legendTextStyle,
  //       ),
  //       textDirection: TextDirection.ltr,
  //     )..layout(
  //         minWidth: 0,
  //         maxWidth: chart.size.width,
  //       );
  //     // 根据三角函数计算中出标识文字的 x 和 y 位置，需要加上宽和高的一半适配 Canvas 的坐标
  //     double legendX = cos(radians) * (radius + chart.padding.horizontal) + chart.size.width / 2;
  //     double legendY = sin(radians) * (radius + chart.padding.vertical) + chart.size.height / 2;
  //     // 使用 TextPainter 绘制文字标识
  //     legendTextPainter.paint(chart.canvas, Offset(legendX, legendY));
  //   }
  // }
  //
  // void _drawValue(T item, double radius, double startAngle, double sweepAngle, bool selected) {
  //   PieChartCoordinateRender chart = coordinateChart as PieChartCoordinateRender;
  //   //中心弧度
  //   final double radians = startAngle + sweepAngle / 2;
  //   //画value
  //   String? valueText = valueFormatter?.call(item);
  //   if (textStyle != null && valueText != null) {
  //     // 使用 TextPainter 绘制文字标识
  //     TextPainter valueTextPainter = TextPainter(
  //       textAlign: TextAlign.start,
  //       text: TextSpan(
  //         text: valueText,
  //         style: textStyle,
  //       ),
  //       textDirection: TextDirection.ltr,
  //     )..layout(
  //         minWidth: 0,
  //         maxWidth: chart.size.width,
  //       );
  //     // 使用三角函数计算文字位置 并根据文字大小适配
  //     double x = cos(radians) * (radius / 2 + valueTextOffset) + chart.size.width / 2 - valueTextPainter.width / 2;
  //     double y = sin(radians) * (radius / 2 + valueTextOffset) + chart.size.height / 2 - valueTextPainter.height / 2;
  //     valueTextPainter.paint(chart.canvas, Offset(x, y));
  //   }
  //
  //   //中心点文案
  //   if (centerTextStyle != null && selected && valueText != null) {
  //     TextPainter valueTextPainter = TextPainter(
  //       textAlign: TextAlign.start,
  //       text: TextSpan(
  //         text: valueText,
  //         style: centerTextStyle,
  //       ),
  //       textDirection: TextDirection.ltr,
  //     )..layout(
  //         minWidth: 0,
  //         maxWidth: chart.size.width,
  //       );
  //     valueTextPainter.paint(chart.canvas, chart.center.translate(-valueTextPainter.width / 2, -valueTextPainter.height / 2));
  //   }
  // }

  //绘制中间文案
  void _drawCenterValue(String? valueText) {
    PieChartCoordinateRender chart = coordinateChart as PieChartCoordinateRender;
    //中心点文案
    if (centerTextStyle != null && valueText != null) {
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
      valueTextPainter.paint(chart.canvas, chart.center.translate(-valueTextPainter.width / 2, -valueTextPainter.height / 2));
    }
  }

  //可以重写，依靠path和paint修改成特殊的样式
  void drawPie(Canvas canvas, Path path, Paint paint) {
    canvas.drawPath(path, paint);
  }
}
