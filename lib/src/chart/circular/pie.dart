import 'dart:math';

import 'package:flutter/material.dart';

import '../../base/chart_body_render.dart';
import '../../param/chart_circular_param.dart';
import '../../param/chart_param.dart';
import '../../param/chart_layout_param.dart';
import '../../utils/chart_utils.dart';

/// @author JD
typedef ValueFormatter<T> = String Function(T);

enum RotateDirection {
  forward,
  reverse,
}

class Pie<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///颜色
  final List<Color> colors;

  ///优先级高于colors
  final List<Shader>? shaders;

  ///引导线颜色
  final Color lineColor;

  ///内圆半径
  final double holeRadius;

  ///值的位置偏移
  final double valueTextOffset;

  ///值文案格式化 不要使用过于耗时的方法
  final ValueFormatter? valueFormatter;

  ///图例文案格式化 不要使用过于耗时的方法
  final ValueFormatter? legendFormatter;

  ///值文字样式
  final TextStyle textStyle;

  ///图例样式
  final TextStyle legendTextStyle;

  ///中间文案样式 为空则不显示
  final TextStyle? centerTextStyle;

  ///扇形的方向
  final RotateDirection direction;

  ///百分比
  final double? spaceWidth;

  ///是否能点击
  final bool enableTap;

  ///是否显示引导线
  final bool guideLine;

  ///是否在图中显示value
  final bool showValue;

  ///开始弧度，可以调整起始位置
  final double startAngle;

  Pie({
    required super.data,
    required this.position,
    this.colors = colors10,
    this.shaders,
    this.holeRadius = 0,
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.grey),
    this.legendTextStyle = const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
    this.lineColor = Colors.grey,
    this.spaceWidth,
    this.valueTextOffset = 0,
    this.valueFormatter,
    this.legendFormatter,
    this.centerTextStyle,
    this.direction = RotateDirection.forward,
    this.guideLine = false,
    this.showValue = false,
    this.enableTap = true,
    this.startAngle = 0,
  });

  List<num> _values = [];
  num _total = 0;
  late Paint _paint;
  @override
  void init(ChartParam param) {
    super.init(param);
    //先计算比例
    _values = [];
    _total = 0;
    for (int i = 0; i < data.length; i++) {
      T item = data[i];
      //计算值
      num po = position.call(item);
      _total += po;
      _values.add(po);
    }
    // 设置绘制属性
    _paint = Paint()
      ..strokeWidth = 0.0
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
  }

  @override
  void draw(Canvas canvas, ChartParam param) {
    if (_total == 0) {
      return;
    }
    param as ChartCircularParam;
    Offset center = param.center;
    double radius = param.radius;

    //开始画扇形
    double startAngle = this.startAngle;
    List<ChartLayoutParam> childrenLayoutParams = [];
    assert(colors.length >= data.length);
    assert(shaders == null || shaders!.length >= data.length);
    int index = 0;
    for (int i = 0; i < data.length; i++) {
      T item = data[i];
      //直接读取
      num percent = _values[i] / _total;
      // 计算出每个数据所占的弧度值
      final sweepAngle = percent * pi * 2 * (direction == RotateDirection.forward ? 1 : -1);
      double rd = radius;
      //图形区域
      ChartLayoutParam shape = ChartLayoutParam.arc(
        center: center,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        innerRadius: holeRadius,
        outRadius: rd,
      );
      childrenLayoutParams.add(shape);

      //放大区域
      ChartLayoutParam tapShape = shape;
      //判断是否选中
      bool selected = enableTap && shape.hitTest(param.localPosition);
      if (selected) {
        rd = radius + 2;
        layoutParam.selectedIndex = i;
        tapShape = ChartLayoutParam.arc(
          center: center,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          innerRadius: holeRadius,
          outRadius: rd,
        );
      }
      if (shaders != null) {
        _paint.shader = shaders![i];
      } else {
        _paint.color = colors[i];
      }
      drawPie(canvas, tapShape.path!, _paint);
      //绘制间隙
      _drawSpaceLine(param, canvas, rd, startAngle, sweepAngle);

      String? valueText = valueFormatter?.call(item);
      String? legend = legendFormatter?.call(item);

      //绘制引导线
      if (guideLine) {
        _drawLineAndText(param, canvas, valueText, legend, index, rd, startAngle, sweepAngle);
      }
      //选中就绘制
      if (selected) {
        _drawCenterValue(param, canvas, valueText);
      }
      //画圆弧
      // baseChart.canvas.drawArc(
      //     newRect, startAngle, sweepAngle, true, paint..color = colors[i]);
      // _drawLegend(item, radius, startAngle, sweepAngle);
      if (showValue) {
        _drawValue(param, canvas, valueText, radius, startAngle, sweepAngle);
      }
      //继续下一个
      startAngle = startAngle + sweepAngle;
      index++;
    }
    layoutParam.children = childrenLayoutParams;
  }

  ///画空隙线
  void _drawSpaceLine(ChartCircularParam param, Canvas canvas, double radius, double startAngle, double sweepAngle) {
    if (spaceWidth == null) {
      return;
    }
    Offset center = param.center;
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

  void _drawLineAndText(ChartCircularParam param, Canvas canvas, String? valueText, String? legend, int index, double radius, double startAngle, double sweepAngle) {
    if (valueText == null && legend == null) {
      return;
    }
    Offset center = param.center;
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
          maxWidth: param.size.width,
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
          maxWidth: param.size.width,
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
  void _drawValue(ChartParam param, Canvas canvas, String? valueText, double radius, double startAngle, double sweepAngle) {
    //中心弧度
    final double radians = startAngle + sweepAngle / 2;
    //画value
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
          maxWidth: param.size.width,
        );
      // 使用三角函数计算文字位置 并根据文字大小适配
      double x = cos(radians) * (radius / 2 + valueTextOffset) + param.size.width / 2 - valueTextPainter.width / 2;
      double y = sin(radians) * (radius / 2 + valueTextOffset) + param.size.height / 2 - valueTextPainter.height / 2;
      valueTextPainter.paint(canvas, Offset(x, y));
    }
  }

  ///绘制中间文案
  void _drawCenterValue(ChartCircularParam param, Canvas canvas, String? valueText) {
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
          maxWidth: param.size.width,
        );
      valueTextPainter.paint(canvas, param.center.translate(-valueTextPainter.width / 2, -valueTextPainter.height / 2));
    }
  }

  ///可以重写，依靠path和paint修改成特殊的样式
  void drawPie(Canvas canvas, Path path, Paint paint) {
    canvas.drawPath(path, paint);
  }
}
