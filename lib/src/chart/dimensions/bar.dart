part of flutter_chart_plus;

typedef BarPosition<T> = num Function(T);
typedef BarValueFormatter<T> = String Function(T);
typedef BarValuesFormatter<T> = List<String> Function(T);

/// @author JD
///普通bar
class Bar<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///bar的宽度
  final double itemWidth;

  ///值格式化 不要使用过于耗时的方法
  final BarPosition value;

  ///颜色 如果设置了colors 则color不会生效
  final Color color;

  /// bar 颜色
  final List<Color>? colors;

  ///优先级高于color
  final Shader? shader;

  ///高亮颜色
  final Color? highlightColor;

  ///值文案格式化 不要使用过于耗时的方法
  final BarValueFormatter? valueFormatter;

  ///值文字样式
  final TextStyle textStyle;

  ///文案偏移
  final Offset valueOffset;

  Bar({
    required super.data,
    required this.value,
    required this.position,
    this.valueFormatter,
    this.valueOffset = Offset.zero,
    this.textStyle = const TextStyle(fontSize: 10, color: Colors.black),
    super.yAxisPosition,
    this.itemWidth = 20,
    this.color = Colors.blue,
    this.colors,
    this.shader,
    this.highlightColor = Colors.yellow,
  });

  final Paint _paint = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  //bar的颜色
  Color _paintBarColor({required int index, required bool selected}) {
    if (selected) {
      if (highlightColor != null) {
        return highlightColor!;
      } else if (colors != null) {
        return colors![index];
      } else {
        return color;
      }
    } else {
      if (colors != null) {
        return colors![index];
      } else {
        return color;
      }
    }
  }

  @override
  void draw(Canvas canvas, ChartParam param) {
    param as _ChartDimensionParam;
    List<ChartItemLayoutParam> childrenLayoutParams = [];

    List<ChartItemLayoutParam>? lastDataList = getLastData(param.animal && param.layout.controlValue < 1);

    for (int index = 0; index < data.length; index++) {
      T item = data[index];
      num xValue = position.call(item);
      num yValue = value.call(item);
      //是否有补间动画
      if (param.animal && param.layout.controlValue < 1) {
        num? lastYValue;
        num? lastXValue;
        if (lastDataList != null && index < lastDataList.length) {
          ChartItemLayoutParam p = lastDataList[index];
          lastYValue = p.yValue;
          lastXValue = p.xValue;
        }
        if (lastXValue != null) {
          xValue = ui.lerpDouble(lastXValue, xValue, param.layout.controlValue) ?? xValue;
        }
        yValue = ui.lerpDouble(lastYValue, yValue, param.layout.controlValue) ?? yValue;
      }
      ChartItemLayoutParam p = _measureBarLayoutParam(param, xValue, yValue)..index = index;
      if (p.originRect != null) {
        if (layoutParam.selectedIndex == index) {
          _paint.shader = null;
          _paint.color = _paintBarColor(index: index, selected: true);
        } else {
          if (shader != null) {
            _paint.shader = shader;
          } else {
            _paint.color = _paintBarColor(index: index, selected: false);
          }
        }
        //开始绘制，bar不同于line，在循环中就可以绘制
        canvas.drawRect(p.originRect!, _paint);
        //绘制文本
        if (param.layout.controlValue == 1) {
          _drawText(canvas, param, item, p);
        }
      }
      childrenLayoutParams.add(p);
    }
    layoutParam.children = childrenLayoutParams;
  }

  void _drawText(Canvas canvas, _ChartDimensionParam param, T item, ChartItemLayoutParam p) {
    String? valueString = valueFormatter?.call(item);
    if (valueString != null && valueString.isNotEmpty) {
      TextPainter legendTextPainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(text: valueString, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: param.layout.size.width);
      Offset offset = Offset.zero;
      if (param.invert) {
        offset = p.originRect!.centerRight;
        offset = offset.translate(valueOffset.dx, -legendTextPainter.height / 2 + valueOffset.dy);
      } else {
        offset = p.originRect!.topCenter;
        offset = offset.translate(-legendTextPainter.width / 2 + valueOffset.dx, -legendTextPainter.height + valueOffset.dy);
      }
      legendTextPainter.paint(canvas, offset);
    }
  }

  //可以重写 自定义特殊的图形
  ChartItemLayoutParam _measureBarLayoutParam(_ChartDimensionParam param, num xValue, num yValue) {
    Rect rect = Rect.zero;
    if (param.invert) {
      double contentWidth = param.layout.contentWidth;
      double top = param.layout.bottom - param.xAxis.density * xValue - itemWidth / 2;
      top = param.layout.transform.withYOffset(top);
      double present = yValue / param.yAxis[yAxisPosition].max;
      double itemHeight = contentWidth * present;
      double left = param.layout.left;
      if (top < 0) {
        return ChartItemLayoutParam()
          ..xValue = xValue
          ..yValue = yValue;
      }
      rect = Rect.fromLTWH(left, top, itemHeight, itemWidth);
    } else {
      double bottom = param.layout.bottom;
      double contentHeight = param.layout.contentHeight;
      double left = param.layout.left + param.xAxis.density * xValue - itemWidth / 2;
      left = param.layout.transform.withXOffset(left);
      double present = yValue / param.yAxis[yAxisPosition].max;
      double itemHeight = contentHeight * present;
      double top = bottom - itemHeight;
      if (left > param.layout.size.width || (left + itemWidth) < 0) {
        return ChartItemLayoutParam()
          ..xValue = xValue
          ..yValue = yValue;
      }
      rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
    }

    ChartItemLayoutParam shape = ChartItemLayoutParam.rect(originRect: rect)
      ..xValue = xValue
      ..yValue = yValue;
    return shape;
  }
}

typedef StackBarPosition<T> = List<num> Function(T);

///stackBar  支持水平/垂直排列
class StackBar<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///值格式化
  final StackBarPosition<T> values;

  ///bar的宽度
  final double itemWidth;

  ///多个颜色
  final List<Color> colors;

  ///优先级高于colors
  final List<Shader>? shaders;

  ///高亮颜色
  final Color? highlightColor;

  ///方向
  final Axis direction;

  ///撑满 如果为true则会根据实际数值的总和求比例，如果为false则会根据Y轴最大值求比例
  final bool full;

  ///绘制热区 颜色
  final Color? hotColor;

  ///两个bar之间的间距
  final double padding;

  ///值文案格式化 不要使用过于耗时的方法
  final BarValuesFormatter? valuesFormatter;

  ///值文字样式
  final TextStyle textStyle;

  ///文案偏移
  final Offset valueOffset;

  StackBar({
    required super.data,
    required this.position,
    required this.values,
    super.yAxisPosition = 0,
    this.highlightColor = Colors.yellow,
    this.colors = colors10,
    this.shaders,
    this.itemWidth = 20,
    this.direction = Axis.horizontal,
    this.full = false,
    this.padding = 5,
    this.hotColor,
    this.valuesFormatter,
    this.textStyle = const TextStyle(fontSize: 10, color: Colors.black),
    this.valueOffset = Offset.zero,
  });

  final Paint _paint = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.fill;

  late final Paint _hotPaint = Paint()..style = PaintingStyle.fill;

  @override
  void draw(Canvas canvas, ChartParam param) {
    param as _ChartDimensionParam;
    List<ChartItemLayoutParam> childrenLayoutParams = [];
    List<ChartItemLayoutParam>? lastDataList = getLastData(param.animal && param.layout.controlValue < 1);

    for (int index = 0; index < data.length; index++) {
      T item = data[index];
      num xValue = position.call(item);
      List<num> yValues = values.call(item);
      assert(colors.length >= yValues.length);
      assert(shaders == null || shaders!.length >= yValues.length);
      ChartItemLayoutParam p;

      //是否有补间动画
      if (param.animal && param.layout.controlValue < 1) {
        List<num>? lastYPov;
        num? lastXValue;
        if (lastDataList != null && index < lastDataList.length) {
          ChartItemLayoutParam p = lastDataList[index];
          lastYPov = p.children.map((e) => e.yValue ?? 0).toList();
          lastXValue = p.xValue;
        }
        if (lastXValue != null) {
          //初始动画x轴不动
          xValue = ui.lerpDouble(lastXValue, xValue, param.layout.controlValue) ?? xValue;
        }
        yValues = lerpList(lastYPov, yValues, param.layout.controlValue) ?? yValues;
      }

      if (direction == Axis.horizontal) {
        p = _measureHorizontalBarLayoutParam(param, xValue, yValues);
      } else {
        p = _measureVerticalBarLayoutParam(param, xValue, yValues);
      }
      childrenLayoutParams.add(p..index = index);

      List<String>? valueString = valuesFormatter?.call(item);

      int stackIndex = 0;
      for (ChartItemLayoutParam cp in p.children) {
        if (cp.originRect != null) {
          if (shaders != null) {
            _paint.shader = shaders![stackIndex];
          } else {
            _paint.color = colors[stackIndex];
          }
          if (cp.hitTest(param.layout.localPosition)) {
            cp.selectedIndex = stackIndex;
            _paint.shader = null;
            if (highlightColor != null) {
              _paint.color = highlightColor!;
            }
          }
          //画图
          canvas.drawRect(cp.originRect!, _paint);
          //画文案
          if (param.layout.controlValue == 1 && valueString != null && valueString.isNotEmpty) {
            if (direction == Axis.horizontal) {
              _drawTopText(canvas, param, valueString[stackIndex], cp);
            } else {
              _drawCenterText(canvas, param, valueString[stackIndex], cp);
            }
          }
        }
        stackIndex++;
      }

      //绘制热区
      if (hotColor != null && p.originRect != null && param.layout.controlValue == 1) {
        canvas.drawRect(p.originRect!, _hotPaint..color = hotColor!);
      }
    }
    layoutParam.children = childrenLayoutParams;
  }

  ///水平排列图形
  ChartItemLayoutParam _measureHorizontalBarLayoutParam(_ChartDimensionParam param, num xValue, List<num> yValues) {
    num total = param.yAxis[yAxisPosition].max;
    if (total == 0) {
      return ChartItemLayoutParam()..xValue = xValue;
    }
    ChartItemLayoutParam shape;
    if (param.invert) {
      double contentWidth = param.layout.contentWidth;
      double center = yValues.length * itemWidth / 2;
      double top = param.layout.bottom - param.xAxis.density * xValue - center;
      top = param.layout.transform.withYOffset(top);

      double left = param.layout.left;
      shape = ChartItemLayoutParam.rect(
        originRect: Rect.fromLTWH(left, top, contentWidth, itemWidth * yValues.length + padding * (yValues.length - 1)),
      );
      List<ChartItemLayoutParam> childrenLayoutParams = [];
      for (num yV in yValues) {
        double present = yV / total;
        double itemHeight = contentWidth * present;
        Rect rect = Rect.fromLTWH(left, top, itemHeight, itemWidth);
        ChartItemLayoutParam stackShape = ChartItemLayoutParam.rect(originRect: rect);
        top = top + itemWidth + padding;
        stackShape.xValue = xValue;
        stackShape.yValue = yV;
        childrenLayoutParams.add(stackShape);
      }
      shape.xValue = xValue;
      shape.children = childrenLayoutParams;
    } else {
      double bottom = param.layout.bottom;
      double contentHeight = param.layout.contentHeight;

      double center = yValues.length * itemWidth / 2;

      double left = param.layout.left + param.xAxis.density * xValue - itemWidth / 2 - center;
      left = param.layout.transform.withXOffset(left);

      shape = ChartItemLayoutParam.rect(
        originRect: Rect.fromLTWH(left, param.layout.top, itemWidth * yValues.length + padding * (yValues.length - 1), contentHeight),
      );
      List<ChartItemLayoutParam> childrenLayoutParams = [];
      for (num yV in yValues) {
        double present = yV / total;
        double itemHeight = contentHeight * present;
        double top = bottom - itemHeight;
        Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
        ChartItemLayoutParam stackShape = ChartItemLayoutParam.rect(originRect: rect);
        left = left + itemWidth + padding;
        stackShape.xValue = xValue;
        stackShape.yValue = yV;
        childrenLayoutParams.add(stackShape);
      }
      shape.xValue = xValue;
      shape.children = childrenLayoutParams;
    }
    return shape;
  }

  ///垂直排列图形
  ChartItemLayoutParam _measureVerticalBarLayoutParam(_ChartDimensionParam param, num xValue, List<num> yValues) {
    num total = param.yAxis[yAxisPosition].max;
    if (full) {
      total = yValues.fold(0, (previousValue, element) => previousValue + element);
    }
    if (total == 0) {
      return ChartItemLayoutParam()..xValue = xValue;
    }
    ChartItemLayoutParam shape;
    if (param.invert) {
      double top = param.layout.bottom - param.xAxis.density * xValue - itemWidth / 2;
      top = param.layout.transform.withYOffset(top);
      double left = param.layout.left;
      double contentWidth = param.layout.contentWidth;
      shape = ChartItemLayoutParam.rect(
        originRect: Rect.fromLTWH(left, top, contentWidth, itemWidth),
      );
      List<ChartItemLayoutParam> childrenLayoutParams = [];
      for (num yV in yValues) {
        double present = yV / total;
        double itemHeight = contentWidth * present;
        Rect rect = Rect.fromLTWH(left, top, itemHeight, itemWidth);
        ChartItemLayoutParam stackShape = ChartItemLayoutParam.rect(originRect: rect);
        stackShape.xValue = xValue;
        stackShape.yValue = yV;
        childrenLayoutParams.add(stackShape);
        left = left + itemHeight;
      }
      shape.children = childrenLayoutParams;
      shape.xValue = xValue;
    } else {
      double bottom = param.layout.bottom;
      double contentHeight = param.layout.contentHeight;
      double left = param.layout.left + param.xAxis.density * xValue - itemWidth / 2;
      left = param.layout.transform.withXOffset(left);
      shape = ChartItemLayoutParam.rect(
        originRect: Rect.fromLTWH(left, param.layout.top, itemWidth, contentHeight),
      );
      List<ChartItemLayoutParam> childrenLayoutParams = [];
      for (num yV in yValues) {
        double present = yV / total;
        double itemHeight = contentHeight * present;
        double top = bottom - itemHeight;
        Rect rect = Rect.fromLTWH(left, top, itemWidth, itemHeight);
        ChartItemLayoutParam stackShape = ChartItemLayoutParam.rect(originRect: rect);
        stackShape.xValue = xValue;
        stackShape.yValue = yV;
        childrenLayoutParams.add(stackShape);
        bottom = top;
      }
      shape.children = childrenLayoutParams;
      shape.xValue = xValue;
    }
    return shape;
  }

  void _drawCenterText(Canvas canvas, _ChartDimensionParam param, String? text, ChartItemLayoutParam p) {
    if (text != null && text.isNotEmpty) {
      TextPainter legendTextPainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: param.layout.size.width);
      Offset offset = Offset.zero;
      if (param.invert) {
        offset = p.originRect!.center;
        offset = offset.translate(-legendTextPainter.width / 2 + valueOffset.dx, -legendTextPainter.height / 2 + valueOffset.dy);
      } else {
        offset = p.originRect!.center;
        offset = offset.translate(itemWidth / 2 + 2 + valueOffset.dx, -legendTextPainter.height / 2 + valueOffset.dy);
      }
      legendTextPainter.paint(canvas, offset);
    }
  }

  void _drawTopText(Canvas canvas, _ChartDimensionParam param, String? text, ChartItemLayoutParam p) {
    if (text != null) {
      TextPainter legendTextPainter = TextPainter(
        textAlign: TextAlign.center,
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: param.layout.size.width);
      Offset offset = Offset.zero;
      if (param.invert) {
        offset = p.originRect!.centerRight;
        offset = offset.translate(valueOffset.dx, -legendTextPainter.height / 2 + valueOffset.dy);
      } else {
        offset = p.originRect!.topCenter;
        offset = offset.translate(-legendTextPainter.width / 2 + valueOffset.dx, -legendTextPainter.height + valueOffset.dy);
      }
      legendTextPainter.paint(canvas, offset);
    }
  }
}
