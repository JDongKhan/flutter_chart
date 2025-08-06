part of flutter_chart_plus;

/// @author JD

@Deprecated('instead of  using [ChartDimensionsCoordinateRender]')
typedef DimensionsChartCoordinateRender = ChartDimensionsCoordinateRender;

/// 象限坐标系
class ChartDimensionsCoordinateRender extends ChartCoordinateRender {
  ChartDimensionsCoordinateRender({
    super.margin = const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 25),
    super.padding = const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 0),
    required super.charts,
    required this.yAxis,
    required this.xAxis,
    super.backgroundAnnotations,
    super.foregroundAnnotations,
    super.minZoom,
    super.maxZoom,
    super.safeArea,
    super.outDraw,
    super.animationDuration,
    super.tooltipBuilder,
    super.onClickChart,
    this.crossHair = const CrossHairStyle(),
  }) : assert(yAxis.isNotEmpty);

  ///y坐标轴
  final List<YAxis> yAxis;

  ///x坐标轴
  final XAxis xAxis;

  ///十字准星样式
  final CrossHairStyle crossHair;

  @override
  bool canZoom() {
    return xAxis.zoom;
  }

  void _clipContent(Canvas canvas, Size size) {
    //防止超过y轴
    canvas.clipRect(Rect.fromLTWH(margin.left, 0, size.width - margin.horizontal, size.height));
  }

  @override
  void paint(Canvas canvas, ChartsState state) {
    Size size = state.layout.size;
    // canvas.save();
    // 如果按坐标系切，就会面临坐标轴和里面的内容重复循环的问题，该组件的本意是尽可能减少无畏的循环，提高性能，如果
    // 给y轴切出来，超出这个范围就隐藏 这个会导致虚线绘制不出来 估注释掉
    // canvas.clipRect(Rect.fromLTWH(0, 0, margin.left, size.height));
    _drawYAxis(state, canvas);
    // canvas.restore();
    _clipContent(canvas, size);
    _drawXAxis(state, canvas);
    _drawBackgroundAnnotations(state, canvas);
    //绘图
    var index = 0;
    for (var element in charts) {
      element.index = index;
      element.controller = controller;
      if (!element.isInit) {
        element.init(state);
      }
      element.draw(canvas, state);
      index++;
    }
    _drawForegroundAnnotations(state, canvas);
    _drawCrosshair(state, canvas, size);
    _drawTooltip(state, canvas, size);
  }

  ///绘制y轴
  void _drawYAxis(ChartsState state, Canvas canvas) {
    Size size = state.layout.size;
    int yAxisIndex = 0;
    for (YAxis yA in yAxis) {
      Offset offset = yA.offset?.call(size) ?? Offset.zero;
      num max = yA.max;
      num min = yA.min;
      int count = yA.count;
      double itemValue = (max - min) / count;
      bool isInt = max is int;
      num xStartValue = 0;
      //先画文字和虚线
      for (int i = 0; i <= count; i++) {
        num vv = itemValue * i;
        if (isInt) {
          vv = vv.toInt();
        }
        num yValue = vv;
        Offset point = state.layout.transform.transformPoint(
            Offset(xStartValue * xAxis.density + offset.dx, yValue * yA.density),
            containPadding: false,
            adjustDirection: true);
        //绘制文本
        if (yA.drawLabel) {
          String text = yA.formatter?.call(i) ?? '${min + vv}';
          if (i == count) {
            _drawYTextPaint(yA, canvas, text, yAxisIndex > 0, point.dx + yA.padding, point.dy, false);
          } else {
            _drawYTextPaint(yA, canvas, text, yAxisIndex > 0, point.dx + yA.padding, point.dy, true);
          }
        }
        //绘制格子线  先放一起，以免再次遍历
        if (yA.drawGrid) {
          _drawYGridLine(state, yA, canvas, point, i);
        }
        //绘制分隔线
        if (yA.drawLine && yA.drawDivider) {
          _drawYDivider(state, yA, canvas, point, yValue);
        }
      }
      //画实线
      if (yA.drawLine) {
        _drawYLine(state, yA, canvas, offset);
      }
      yAxisIndex++;
    }
  }

  ///绘制虚线
  void _drawYGridLine(ChartsState state, YAxis yA, Canvas canvas, Offset point, int index) {
    final Matrix4 matrix = Matrix4.identity()..translate(point.dx, point.dy);
    canvas.drawPath(
        yA
            .getDashPath(index, Offset(state.layout.size.width - state.layout.margin.horizontal, 0))
            .transform(matrix.storage),
        yA.linePaint);
  }

  ///绘制Y轴文本
  void _drawYTextPaint(YAxis yAxis, Canvas canvas, String text, bool right, double left, double top, bool middle) {
    var textPainter = yAxis._textPainter[text];
    if (textPainter == null) {
      textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: yAxis.textStyle,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(); // 进行布局
      yAxis._textPainter[text] = textPainter;
    }
    textPainter.paint(
      canvas,
      Offset(
        right ? left : left - textPainter.width - 5,
        middle ? top - textPainter.height / 2 : top,
      ),
    ); // 进行绘制
  }

  ///绘制y轴指示器
  void _drawYDivider(ChartsState state, YAxis yA, Canvas canvas, Offset point, num yValue) {
    Offset endPoint = state.layout.transform
        .transformPoint(Offset(5, yValue * yA.density), containPadding: false, adjustDirection: true, yOffset: true);
    canvas.drawLine(point, endPoint, yA.linePaint);
  }

  ///绘制y轴line
  void _drawYLine(ChartsState state, YAxis yA, Canvas canvas, Offset offset) {
    Offset startPoint =
        Offset(state.layout.margin.left + offset.dx, state.layout.size.height - state.layout.margin.bottom);
    Offset endPoint = Offset(state.layout.margin.left + offset.dx, state.layout.margin.top);
    canvas.drawLine(startPoint, endPoint, yA.linePaint);
  }

  ///绘制x轴
  void _drawXAxis(ChartsState state, Canvas canvas) {
    Size size = state.layout.size;
    double density = xAxis.density;
    num interval = xAxis.interval;
    //实际要显示的数量
    int count = xAxis.max ~/ interval;
    //缩放时过滤逻辑
    double xFilterZoom = 1 / state.layout.zoom;
    //缩小时的策略
    int xReduceInterval = (xFilterZoom < 1 ? 1 : xFilterZoom).round();
    //放大后的策略
    int? xDivideCount = xAxis.divideCount?.call(state.layout.zoom);
    double? xAmplifyInterval;
    if (xDivideCount != null && xDivideCount > 0) {
      xAmplifyInterval = interval / xDivideCount;
      // double xAmplifyInterval = (xFilterZoom > 1 ? 1 : xFilterZoom);
      // int xCount = interval ~/ xAmplifyInterval;
    }

    for (int i = 0; i <= count; i++) {
      //处理缩小导致的x轴文字拥挤的问题
      if (i % xReduceInterval != 0) {
        continue;
      }
      num xValue = interval * i;

      Offset point = state.layout.transform.transformPoint(Offset(xValue * xAxis.density, 0),
          containPadding: true, adjustDirection: true, xOffset: true);
      Offset nextPoint = state.layout.transform.transformPoint(Offset(interval * (i + 1) * xAxis.density, 0),
          containPadding: true, adjustDirection: true, xOffset: true);
      // // 判断下一个点是否超出，因为这个和下个点之间可能有文案要显示
      // // 避免多余绘制，只绘制屏幕内容
      if (nextPoint.dx < 0) {
        continue;
      }
      Offset? oft = Offset(point.dx, 0);
      if (xAxis.drawLabel) {
        String? text = xAxis.formatter?.call(i);
        if (text != null) {
          bool adjustLast = (i == count);
          bool adjustFirst = (i == 0);
          oft = _drawXTextPaint(xAxis, canvas, text, state, point.dx, point.dy,
              adjustFirst: adjustFirst, adjustLast: adjustLast);
        }
      }
      //根据调整过的位置再比较
      if (oft.dx > size.width) {
        break;
      }
      //处理放大时里面的内容
      if (xDivideCount != null && xDivideCount > 0) {
        for (int j = 1; j < xDivideCount; j++) {
          num newValue = i + j * xAmplifyInterval!;
          String? newText = xAxis.formatter?.call(newValue);
          double left = state.layout.left + density * interval * newValue;
          left = state.layout.transform.withXScroll(left);
          if (newText != null) {
            _drawXTextPaint(xAxis, canvas, newText, state, left, point.dy);
          }
        }
      }
      // if (i == dreamXAxisCount - 1) {
      //   _drawXTextPaint(canvas, '${i + 1}', size,
      //       size.width - padding.right - contentPadding.right - 5);
      // }
      //先放一起，以免再次遍历
      if (xAxis.drawGrid) {
        // Path? kDashPath = xAxis._gridLine[i];
        // if (kDashPath == null) {
        //   Offset endPoint = state.transform.transformOffset(Offset(xValue * xAxis.density, yAxis.first.density * yAxis.first.max), containPadding: true, adjustDirection: true);
        //   kDashPath = _dashPath(point, endPoint);
        //   xAxis._gridLine[i] = kDashPath;
        // }
        // canvas.drawPath(kDashPath, xAxis.linePaint);
        _drawXGridLine(state, canvas, point, i);
      }
      //画底部线
      if (xAxis.drawLine && xAxis.drawDivider) {
        _drawXDivider(state, canvas, point, xValue);
      }
    }

    //划线
    if (xAxis.drawLine) {
      _drawXLine(state, canvas);
    }
  }

  ///绘制虚线
  void _drawXGridLine(ChartsState state, Canvas canvas, Offset point, int index) {
    final Matrix4 matrix = Matrix4.identity()..translate(point.dx, state.layout.margin.top);
    canvas.drawPath(
        xAxis
            .getDashPath(index, Offset(0, state.layout.size.height - state.layout.margin.vertical))
            .transform(matrix.storage),
        xAxis.linePaint);
  }

  ///绘制指示器
  void _drawXDivider(ChartsState state, Canvas canvas, Offset point, num xValue) {
    Offset endPoint = state.layout.transform
        .transformPoint(Offset(xValue * xAxis.density, 5), containPadding: true, adjustDirection: true, xOffset: true);
    canvas.drawLine(point, endPoint, xAxis.linePaint);
  }

  ///绘制x轴文本
  Offset _drawXTextPaint(
    XAxis axis,
    Canvas canvas,
    String text,
    ChartsState state,
    double left,
    double top, {
    bool adjustFirst = false,
    bool adjustLast = false,
  }) {
    var textPainter = xAxis._textPainter[text];
    if (textPainter == null) {
      //layout耗性能，只做一次即可
      textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: axis.textStyle,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(); // 进行布局
      xAxis._textPainter[text] = textPainter;
    }
    double textWidth = textPainter.width;
    double x = left - textWidth / 2;
    if (adjustFirst && x < state.layout.margin.left) {
      x = left;
    } else if (adjustLast && (left + textWidth / 2) > (state.layout.size.width - state.layout.margin.right)) {
      x = left - textWidth;
    }
    Offset offset = Offset(x, top);
    textPainter.paint(
      canvas,
      offset,
    ); // 进行绘制
    return offset;
  }

  ///绘制x轴line
  void _drawXLine(ChartsState state, Canvas canvas) {
    Offset startPoint = Offset(state.layout.margin.left, state.layout.size.height - state.layout.margin.bottom);
    Offset endPoint = Offset(
        state.layout.size.width - state.layout.margin.right, state.layout.size.height - state.layout.margin.bottom);
    canvas.drawLine(startPoint, endPoint, xAxis.linePaint);
  }

  ///绘制十字准星
  void _drawCrosshair(ChartsState state, Canvas canvas, Size size) {
    Offset? anchor = state.layout.localPosition;
    if (anchor == null) {
      return;
    }
    if (!crossHair.verticalShow && !crossHair.horizontalShow) {
      return;
    }
    double? top;
    double? left;

    double diffTop = 0;
    double diffLeft = 0;

    //查找更贴近点击的那条数据
    for (ChartLayoutState entry in state.chartsState) {
      int? index = entry.selectedIndex;
      if (index == null) {
        continue;
      }
      if (index >= entry.children.length) {
        continue;
      }
      ChartLayoutState shape = entry.children[index];
      //用于找哪个子图更适合
      for (ChartItemLayoutState childShape in shape.children) {
        Rect? realRect = childShape.getRealRect();
        if (realRect != null) {
          double cTop = realRect.center.dy;
          double topDiffAbs = (cTop - anchor.dy).abs();
          if (diffTop == 0 || topDiffAbs < diffTop) {
            top = cTop;
            diffTop = topDiffAbs;
          }

          double cLeft = realRect.center.dx;
          double leftDiffAbs = (cLeft - anchor.dx).abs();
          if (diffLeft == 0 || leftDiffAbs < diffLeft) {
            left = cLeft;
            diffLeft = leftDiffAbs;
          }
        }
      }
    }

    if (crossHair.adjustVertical) {
      anchor = Offset(anchor.dx, top ?? anchor.dy);
    }
    if (crossHair.adjustHorizontal) {
      anchor = Offset(left ?? anchor.dx, anchor.dy);
    }

    Paint paint = Paint()
      ..color = crossHair.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = crossHair.strokeWidth;
    //垂直
    if (crossHair.verticalShow) {
      Offset p1 = Offset(anchor.dx, margin.top);
      Offset p2 = Offset(anchor.dx, size.height - margin.bottom);
      Path path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy);
      Path kDashPath = dashPath(path, dashArray: CircularIntervalList([3, 3]), dashOffset: null);
      canvas.drawPath(kDashPath, paint);
    }
    //水平
    if (crossHair.horizontalShow) {
      Offset p11 = Offset(margin.left, anchor.dy);
      Offset p21 = Offset(size.width - margin.right, anchor.dy);
      Path path1 = Path()
        ..moveTo(p11.dx, p11.dy)
        ..lineTo(p21.dx, p21.dy);
      Path kDashPath = dashPath(path1, dashArray: CircularIntervalList([3, 3]), dashOffset: null);
      canvas.drawPath(kDashPath, paint);
    }
  }

  ///提示文案
  void _drawTooltip(ChartsState state, Canvas canvas, Size size) {
    Offset? anchor = state.layout.localPosition;
    if (anchor == null) {
      return;
    }
    //用widget实现
    if (tooltipBuilder != null) {
      Future.microtask(() {
        controller._notifyTooltip();
      });
      return;
    }
  }

  ///背景
  void _drawBackgroundAnnotations(ChartsState state, Canvas canvas) {
    if (backgroundAnnotations != null) {
      for (Annotation element in backgroundAnnotations!) {
        if (!element.isInit) {
          element.init(state);
        }
        element.draw(canvas, state);
      }
    }
  }

  ///前景
  void _drawForegroundAnnotations(ChartsState state, Canvas canvas) {
    if (foregroundAnnotations != null) {
      for (Annotation element in foregroundAnnotations!) {
        if (!element.isInit) {
          element.init(state);
        }
        element.draw(canvas, state);
      }
    }
  }
}

/*************************************************************************************/
/// 象限坐标系  x轴在左边 y轴在下面 ，后续可能会有 原点在右下角或者左上角等可能,所有通过子类化 减少逻辑复杂度。
class ChartInvertDimensionsCoordinateRender extends ChartDimensionsCoordinateRender {
  ChartInvertDimensionsCoordinateRender({
    super.margin = const EdgeInsets.only(left: 25, top: 0, right: 0, bottom: 30),
    super.padding = const EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 10),
    required super.charts,
    required super.yAxis,
    required super.xAxis,
    super.backgroundAnnotations,
    super.foregroundAnnotations,
    super.minZoom,
    super.maxZoom,
    super.safeArea,
    super.outDraw,
    super.animationDuration,
    super.tooltipBuilder,
    super.crossHair = const CrossHairStyle(),
  }) : assert(yAxis.isNotEmpty);

  @override
  void _clipContent(Canvas canvas, Size size) {
    //防止超过y轴
    canvas.clipRect(Rect.fromLTWH(0, margin.top, size.width - margin.right, size.height - margin.bottom));
  }

  ///绘制虚线
  @override
  void _drawYGridLine(ChartsState state, YAxis yA, Canvas canvas, Offset point, int index) {
    final Matrix4 matrix = Matrix4.identity()..translate(point.dx, state.layout.margin.top);
    canvas.drawPath(
        yA
            .getDashPath(index, Offset(0, state.layout.size.height - state.layout.margin.vertical))
            .transform(matrix.storage),
        yA.linePaint);
  }

  ///绘制Y轴文本，现在y周在底部了
  @override
  void _drawYTextPaint(YAxis yAxis, Canvas canvas, String text, bool isTop, double left, double top, bool middle) {
    var textPainter = yAxis._textPainter[text];
    if (textPainter == null) {
      textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: yAxis.textStyle,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(); // 进行布局
      yAxis._textPainter[text] = textPainter;
    }
    textPainter.paint(
      canvas,
      Offset(
          middle ? left - textPainter.width / 2 : left - textPainter.width, isTop ? top - textPainter.height : top + 5),
    ); // 进行绘制
  }

  ///绘制y轴line
  @override
  void _drawYLine(ChartsState state, YAxis yA, Canvas canvas, Offset offset) {
    Offset startPoint =
        Offset(state.layout.margin.left, state.layout.size.height - state.layout.margin.bottom - offset.dy);
    Offset endPoint = Offset(state.layout.size.width - state.layout.margin.right,
        state.layout.size.height - state.layout.margin.bottom - -offset.dy);
    canvas.drawLine(startPoint, endPoint, yA.linePaint);
  }

  ///绘制X轴虚线
  @override
  void _drawXGridLine(ChartsState state, Canvas canvas, Offset point, int index) {
    final Matrix4 matrix = Matrix4.identity()..translate(point.dx, point.dy);
    canvas.drawPath(
        xAxis.getDashPath(index, Offset(state.layout.size.width, 0)).transform(matrix.storage), xAxis.linePaint);
  }

  ///绘制x轴文本 ，现在x在左侧了
  @override
  Offset _drawXTextPaint(XAxis axis, Canvas canvas, String text, ChartsState state, double left, double top,
      {bool adjustFirst = false, bool adjustLast = false}) {
    var textPainter = xAxis._textPainter[text];
    if (textPainter == null) {
      //layout耗性能，只做一次即可
      textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: axis.textStyle,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(); // 进行布局
      xAxis._textPainter[text] = textPainter;
    }
    double y = top - textPainter.height / 2;
    double textBottom = top + textPainter.height / 2;
    double contentBottom = (state.layout.size.height - state.layout.margin.bottom);
    if (adjustFirst && textBottom > contentBottom) {
      y = top - textPainter.height;
    } else if (adjustLast) {
      y = top;
    }
    Offset offset = Offset(margin.left - textPainter.width - 5, y);
    textPainter.paint(canvas, offset); // 进行绘制
    return offset;
  }

  ///绘制x轴line
  @override
  void _drawXLine(ChartsState state, Canvas canvas) {
    Offset startPoint = Offset(state.layout.margin.left, state.layout.size.height - state.layout.margin.bottom);
    Offset endPoint = Offset(state.layout.margin.left, state.layout.margin.top);
    canvas.drawLine(startPoint, endPoint, xAxis.linePaint);
  }
}
