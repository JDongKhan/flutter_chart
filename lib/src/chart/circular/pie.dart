part of flutter_chart_plus;

/// @author JD
typedef PieValueFormatter<T> = String Function(T);

enum RotateDirection {
  forward,
  reverse,
}

class Pie<T> extends ChartBodyRender<T> {
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
    this.guideLineWidth,
    this.showValue = false,
    this.enableTap = true,
    this.startAngle = 0,
  });

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
  final PieValueFormatter<T>? valueFormatter;

  ///图例文案格式化 不要使用过于耗时的方法
  final PieValueFormatter<T>? legendFormatter;

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

  ///引导线宽度
  final double? guideLineWidth;

  ///是否在图中显示value
  final bool showValue;

  ///开始弧度，可以调整起始位置
  final double startAngle;

  List<num> _values = [];
  num _total = 0;
  late final Paint _paint = Paint()
    ..strokeWidth = 0.0
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  @override
  void init(ChartsState state) {
    super.init(state);
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
  }

  @override
  void draw(Canvas canvas, ChartsState state) {
    if (_total == 0) {
      return;
    }
    ChartCircularCoordinateState layout = state.layout as ChartCircularCoordinateState;
    Offset center = layout.center;
    double radius = layout.radius;

    List<ChartItemLayoutState>? lastLayoutState = getLastData(state.animal && layout.controlValue < 1);
    //开始画扇形
    double startAngle = this.startAngle;
    List<ChartItemLayoutState> childrenLayoutState = [];
    assert(colors.length >= data.length);
    assert(shaders == null || shaders!.length >= data.length);
    int index = 0;
    for (int i = 0; i < data.length; i++) {
      T item = data[i];
      //直接读取
      num percent = _values[i] / _total;
      num currentPercent = percent;
      //tween动画
      if (state.animal && layout.controlValue < 1) {
        num? lastPercent;
        if (lastLayoutState != null && index < lastLayoutState.length) {
          lastPercent = lastLayoutState[i].yValue;
        }
        //初始动画x轴不动
        currentPercent = ui.lerpDouble(lastPercent, percent, layout.controlValue) ?? 0;
      }

      // 计算出每个数据所占的弧度值
      final sweepAngle = currentPercent * math.pi * 2 * (direction == RotateDirection.forward ? 1 : -1);
      double rd = radius;
      //图形区域
      ChartItemLayoutState shape = measurePath(
          center: center, startAngle: startAngle, sweepAngle: sweepAngle, innerRadius: holeRadius, outRadius: rd);
      shape.yValue = percent;
      childrenLayoutState.add(shape);

      //放大区域
      ChartItemLayoutState tapShape = shape;
      //判断是否选中
      bool selected = enableTap && chartState.selectedIndex == i;
      if (selected) {
        rd = radius + 2;
        tapShape = measurePath(
            center: center, startAngle: startAngle, sweepAngle: sweepAngle, innerRadius: holeRadius, outRadius: rd);
      }
      if (shaders != null) {
        _paint.shader = shaders![i];
      } else {
        _paint.color = colors[i];
      }
      drawPie(canvas, tapShape.path!, _paint);
      //绘制间隙
      _drawSpaceLine(layout, canvas, rd, startAngle, sweepAngle);

      String? valueText = valueFormatter?.call(item);
      String? legend = legendFormatter?.call(item);

      //绘制引导线
      if (guideLine && layout.controlValue == 1) {
        _drawLineAndText(layout, canvas, valueText, legend, index, rd, startAngle, sweepAngle);
      }
      //选中就绘制
      if (selected) {
        _drawCenterValue(layout, canvas, valueText);
      }
      //画圆弧
      // baseChart.canvas.drawArc(
      //     newRect, startAngle, sweepAngle, true, paint..color = colors[i]);
      // _drawLegend(item, radius, startAngle, sweepAngle);
      if (showValue && layout.controlValue == 1) {
        _drawValue(state, canvas, valueText, radius, startAngle, sweepAngle);
      }
      //继续下一个
      startAngle = startAngle + sweepAngle;
      index++;
    }
    chartState.children = childrenLayoutState;
  }

  ///画空隙线
  void _drawSpaceLine(
      ChartCircularCoordinateState layout, Canvas canvas, double radius, double startAngle, double sweepAngle) {
    if (spaceWidth == null) {
      return;
    }
    Offset center = layout.center;
    //开始线
    var start1X = math.cos(startAngle) * holeRadius + center.dx;
    var start1Y = math.sin(startAngle) * holeRadius + center.dy;
    Offset start1Offset = Offset(start1X, start1Y);
    var end1X = math.cos(startAngle) * radius + center.dx;
    var end1Y = math.sin(startAngle) * radius + center.dy;
    Offset end1Offset = Offset(end1X, end1Y);
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white
      ..strokeWidth = spaceWidth!;
    canvas.drawLine(start1Offset, end1Offset, paint);
    //结束线
    var start2X = math.cos(startAngle + sweepAngle) * holeRadius + center.dx;
    var start2Y = math.sin(startAngle + sweepAngle) * holeRadius + center.dy;
    Offset start2Offset = Offset(start2X, start2Y);
    var end2X = math.cos(startAngle + sweepAngle) * radius + center.dx;
    var end2Y = math.sin(startAngle + sweepAngle) * radius + center.dy;
    Offset end2Offset = Offset(end2X, end2Y);
    canvas.drawLine(start2Offset, end2Offset, paint);
  }

  void _drawLineAndText(ChartCircularCoordinateState layout, Canvas canvas, String? valueText, String? legend,
      int index, double radius, double startAngle, double sweepAngle) {
    if (valueText == null && legend == null) {
      return;
    }
    TextPainter? legendTextPainter;
    if (legend != null) {
      legendTextPainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: legend,
          style: legendTextStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout(
          minWidth: 0,
          maxWidth: layout.size.width,
        );
    }

    TextPainter? valueTextPainter;
    if (valueText != null) {
      valueTextPainter = TextPainter(
        textAlign: TextAlign.start,
        text: TextSpan(
          text: valueText,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout(
          minWidth: 0,
          maxWidth: layout.size.width,
        );
    }
    Offset center = layout.center;
    //中心弧度
    final double radians = startAngle + sweepAngle / 2;
    double line1 = 15;
    double line2 = 40;
    if (guideLineWidth == null) {
      //未设置则根据值来设置
      line2 = math.max((legendTextPainter?.width ?? 0) + 10, (valueTextPainter?.width ?? 0) + 10);
    } else {
      line2 = guideLineWidth!;
    }
    Offset point1 = Offset(math.cos(radians) * (radius), math.sin(radians) * (radius)).translate(center.dx, center.dy);
    Offset point2 = Offset(math.cos(radians) * (radius + line1), math.sin(radians) * (radius + line1))
        .translate(center.dx, center.dy);
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

    if (legendTextPainter != null) {
      // 使用三角函数计算文字位置 并根据文字大小适配
      Offset textOffset =
          Offset(isLeft ? point3.dx : point3.dx - legendTextPainter.width, point3.dy - legendTextPainter.height);
      Paint dotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[index]
        ..strokeWidth = 1;
      canvas.drawCircle(Offset(textOffset.dx - 6, textOffset.dy + legendTextPainter.height / 2), 4, dotPaint);
      legendTextPainter.paint(canvas, textOffset);
    }

    if (valueTextPainter != null) {
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
  void _drawValue(
      ChartsState state, Canvas canvas, String? valueText, double radius, double startAngle, double sweepAngle) {
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
          maxWidth: state.layout.size.width,
        );
      // 使用三角函数计算文字位置 并根据文字大小适配
      double x =
          math.cos(radians) * (radius / 2 + valueTextOffset) + state.layout.size.width / 2 - valueTextPainter.width / 2;
      double y = math.sin(radians) * (radius / 2 + valueTextOffset) +
          state.layout.size.height / 2 -
          valueTextPainter.height / 2;
      valueTextPainter.paint(canvas, Offset(x, y));
    }
  }

  ///绘制中间文案
  void _drawCenterValue(ChartCircularCoordinateState layout, Canvas canvas, String? valueText) {
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
          maxWidth: layout.size.width,
        );
      valueTextPainter.paint(
          canvas, layout.center.translate(-valueTextPainter.width / 2, -valueTextPainter.height / 2));
    }
  }

  ///测量path
  ChartItemLayoutState measurePath({
    required Offset center, // 中心点
    required double innerRadius, // 小圆半径
    required double outRadius, // 大圆半径
    required double startAngle,
    required double sweepAngle,
  }) {
    return ChartItemLayoutState.arc(
        center: center, startAngle: startAngle, sweepAngle: sweepAngle, innerRadius: innerRadius, outRadius: outRadius);
  }

  ///可以重写，依靠path和paint修改成特殊的样式
  void drawPie(Canvas canvas, Path path, Paint paint) {
    canvas.drawPath(path, paint);
  }
}
