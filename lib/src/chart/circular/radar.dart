import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../param/chart_circular_param.dart';
import '../../param/chart_param.dart';
import '../../utils/chart_utils.dart';
import '../../base/chart_body_render.dart';
import '../../param/chart_layout_param.dart';
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

  late double _sweepAngle;
  late Paint _linePaint;
  late Paint _dataLinePaint;
  Paint? _fillDataLinePaint;

  @override
  void init(ChartParam param) {
    param as ChartCircularParam;
    super.init(param);
    int itemLength = data.length;
    double percent = 1 / itemLength;
    // 计算出每个数据所占的弧度值
    _sweepAngle = percent * math.pi * 2 * (direction == RotateDirection.forward ? 1 : -1);

    // 设置绘制属性
    _linePaint = Paint()
      ..strokeWidth = 1.0
      ..isAntiAlias = true
      ..color = lineColor
      ..style = PaintingStyle.stroke;

    _dataLinePaint = Paint()
      ..strokeWidth = 1.0
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    if (fillColors != null) {
      _fillDataLinePaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.fill;
    }

    //图例
    List<dynamic>? legendList = legendFormatter?.call();
    Offset center = param.center;
    double radius = param.radius;
    //开始点
    double startAngle = this.startAngle;
    for (int i = 0; i < itemLength; i++) {
      T itemData = data[i];
      //画边框
      final x = math.cos(startAngle) * radius + center.dx;
      final y = math.sin(startAngle) * radius + center.dy;
      _linePathList.add(Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(x, y));
      if (i == 0) {
        _borderLinePath.moveTo(x, y);
      } else {
        _borderLinePath.lineTo(x, y);
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
        _textPainterList.add(RadarTextPainter(textPainter: legendTextPainter, offset: textOffset));
      }

      //画value线
      List<num> pos = values.call(itemData);
      List<dynamic>? valueLegendList = valueFormatter?.call(itemData);
      assert(valueLegendList == null || pos.length == valueLegendList.length);
      for (int j = 0; j < pos.length; j++) {
        Path? dataLinePath = _dataLinePathList[j];
        if (dataLinePath == null) {
          dataLinePath = Path();
          _dataLinePathList[j] = dataLinePath;
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
          _textPainterList.add(RadarTextPainter(textPainter: legendTextPainter, offset: textOffset));
        }
      }

      //继续下一个
      startAngle = startAngle + _sweepAngle;
    }
    _borderLinePath.close();
  }

  ///由内向外的线
  final List<Path> _linePathList = [];

  ///外边框
  final Path _borderLinePath = Path();

  ///图例 和 value
  final List<RadarTextPainter> _textPainterList = [];

  ///数据相关的path
  final Map<int, Path> _dataLinePathList = {};

  @override
  void draw(Canvas canvas, ChartParam param) {
    //画边框
    for (var element in _linePathList) {
      canvas.drawPath(element, _linePaint);
    }
    canvas.drawPath(_borderLinePath, _linePaint);
    //画数据
    int index = 0;
    for (Path dataPath in _dataLinePathList.values) {
      dataPath.close();
      // 设置绘制属性
      _dataLinePaint.color = colors[index];
      canvas.drawPath(dataPath, _dataLinePaint);

      if (fillColors != null) {
        _fillDataLinePaint?.color = fillColors![index];
        canvas.drawPath(dataPath, _fillDataLinePaint!);
      }
      index++;
    }
    //最后再绘制，防止被挡住
    for (RadarTextPainter textPainter in _textPainterList) {
      textPainter.textPainter.paint(canvas, textPainter.offset);
    }
  }
}

class RadarTextPainter {
  final TextPainter textPainter;
  final Offset offset;
  RadarTextPainter({required this.textPainter, required this.offset});
}
