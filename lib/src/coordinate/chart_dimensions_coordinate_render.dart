import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../annotation/annotation.dart';
import '../param/chart_param.dart';
import '../param/chart_layout_param.dart';
import 'chart_coordinate_render.dart';
import '../base/chart_controller.dart';

/// @author JD

@Deprecated('instead of  using [ChartDimensionsCoordinateRender]')
typedef DimensionsChartCoordinateRender = ChartDimensionsCoordinateRender;

/// 象限坐标系
class ChartDimensionsCoordinateRender extends ChartCoordinateRender {
  ///y坐标轴
  final List<YAxis> yAxis;

  ///x坐标轴
  final XAxis xAxis;

  ///十字准星样式
  final CrossHairStyle crossHair;

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
    this.crossHair = const CrossHairStyle(),
  }) : assert(yAxis.isNotEmpty);

  @override
  bool canZoom() {
    return xAxis.zoom;
  }

  @override
  void paint(Canvas canvas, ChartParam param) {
    Size size = param.size;
    // canvas.save();
    // 如果按坐标系切，就会面临坐标轴和里面的内容重复循环的问题，该组件的本意是尽可能减少无畏的循环，提高性能，如果
    // 给y轴切出来，超出这个范围就隐藏
    // canvas.clipRect(Rect.fromLTWH(0, 0, margin.left, size.height));
    _drawYAxis(param, canvas);
    // canvas.restore();

    //防止超过y轴
    canvas.clipRect(Rect.fromLTWH(margin.left, 0, size.width - margin.horizontal, size.height));
    _drawXAxis(param, canvas);
    _drawBackgroundAnnotations(param, canvas);
    //绘图
    var index = 0;
    for (var element in charts) {
      element.indexAtChart = index;
      element.controller = controller;
      if (!element.isInit) {
        element.init(param);
      }
      element.draw(canvas, param);
      index++;
    }
    _drawForegroundAnnotations(param, canvas);
    _drawCrosshair(param, canvas, size);
    _drawTooltip(param, canvas, size);
  }

  ///绘制y轴
  void _drawYAxis(ChartParam param, Canvas canvas) {
    Size size = param.size;
    int yAxisIndex = 0;
    for (YAxis yA in yAxis) {
      Offset offset = yA.offset?.call(size) ?? Offset.zero;
      num max = yA.max;
      num min = yA.min;
      int count = yA.count;
      double itemValue = (max - min) / count;
      bool isInt = max is int;
      double left = margin.left + offset.dx;
      //先画文字和虚线
      for (int i = 0; i <= count; i++) {
        num vv = itemValue * i;
        if (isInt) {
          vv = vv.toInt();
        }
        String text = yA.formatter?.call(i) ?? '${min + vv}';
        double top = size.height - param.contentMargin.bottom - vv * yA.density;
        top = param.transform.withYOffset(top);
        //绘制文本
        if (i == count) {
          _drawYTextPaint(yA, canvas, text, yA.textStyle, yAxisIndex > 0, left + yA.left, top, false);
        } else {
          _drawYTextPaint(yA, canvas, text, yA.textStyle, yAxisIndex > 0, left + yA.left, top, true);
        }
        //绘制格子线  先放一起，以免再次遍历
        if (yA.drawGrid) {
          Path? kDashPath = yA._gridLine[i];
          if (kDashPath == null) {
            kDashPath = _dashPath(Offset(left, top), Offset(size.width - margin.right, top));
            yA._gridLine[i] = kDashPath;
          }
          canvas.drawPath(kDashPath, yA.paint);
        }
        if (yA.drawLine && yA.drawDivider) {
          canvas.drawLine(Offset(left, top), Offset(left + 3, top), yA.paint);
        }
      }
      //画实线
      if (yA.drawLine) {
        canvas.drawLine(Offset(left, margin.top), Offset(left, size.height - margin.bottom), yA.paint);
      }
      yAxisIndex++;
    }
  }

  ///绘制Y轴文本
  void _drawYTextPaint(YAxis yAxis, Canvas canvas, String text, TextStyle textStyle, bool right, double left, double top, bool middle) {
    var textPainter = yAxis._textPainter[text];
    if (textPainter == null) {
      textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: textStyle,
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

  ///绘制x轴
  void _drawXAxis(ChartParam param, Canvas canvas) {
    Size size = param.size;
    double density = xAxis.density;
    num interval = xAxis.interval;
    //实际要显示的数量
    int count = xAxis.max ~/ interval;
    //缩放时过滤逻辑
    double xFilterZoom = 1 / param.zoom;
    //缩小时的策略
    int xReduceInterval = (xFilterZoom < 1 ? 1 : xFilterZoom).round();
    //放大后的策略
    int? xDivideCount = xAxis.divideCount?.call(param.zoom);
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

      double left = param.contentMargin.left + density * interval * i;
      left = param.transform.withXOffset(left);
      //避免多余绘制，只绘制屏幕内容
      if (left < 0) {
        continue;
      }
      String? text = xAxis.formatter?.call(i);
      Offset? oft = Offset(left, 0);
      if (text != null) {
        oft = _drawXTextPaint(canvas, text, xAxis.textStyle, size, left, first: (i == 0) && padding.left == 0, end: (i == count) && padding.right == 0);
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
          double left = param.contentMargin.left + density * interval * newValue;
          left = param.transform.withXOffset(left);
          if (newText != null) {
            _drawXTextPaint(canvas, newText, xAxis.textStyle, size, left);
          }
        }
      }
      // if (i == dreamXAxisCount - 1) {
      //   _drawXTextPaint(canvas, '${i + 1}', size,
      //       size.width - padding.right - contentPadding.right - 5);
      // }
      //先放一起，以免再次遍历
      if (xAxis.drawGrid) {
        final Matrix4 matrix = Matrix4.identity()..translate(left, 0);
        canvas.drawPath(xAxis.getDashPath(i, param.contentSize.height).transform(matrix.storage), xAxis.linePath);
      }
      //画底部线
      if (xAxis.drawLine && xAxis.drawDivider) {
        canvas.drawLine(Offset(left, size.height - margin.bottom), Offset(left, size.height - margin.bottom - 3), xAxis.linePath);
      }
    }

    //划线
    if (xAxis.drawLine) {
      canvas.drawLine(Offset(margin.left, size.height - margin.bottom), Offset(size.width - margin.right, size.height - margin.bottom), xAxis.linePath);
    }
  }

  ///绘制x轴文本
  Offset _drawXTextPaint(Canvas canvas, String text, TextStyle textStyle, Size size, double left, {bool first = false, bool end = false}) {
    var textPainter = xAxis._textPainter[text];
    if (textPainter == null) {
      //layout耗性能，只做一次即可
      textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: textStyle,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(); // 进行布局
      xAxis._textPainter[text] = textPainter;
    }
    Offset offset = Offset(
      end ? left - textPainter.width : (first ? left : left - textPainter.width / 2),
      size.height - margin.bottom + 8,
    );
    textPainter.paint(
      canvas,
      offset,
    ); // 进行绘制
    return offset;
  }

  ///绘制十字准星
  void _drawCrosshair(ChartParam param, Canvas canvas, Size size) {
    Offset? anchor = param.localPosition;
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
    for (ChartLayoutParam entry in param.childrenState) {
      int? index = entry.selectedIndex;
      if (index == null) {
        continue;
      }
      if (index >= entry.children.length) {
        continue;
      }
      ChartLayoutParam shape = entry.children[index];
      //用于找哪个子图更适合
      for (ChartLayoutParam childShape in shape.children) {
        if (childShape.rect != null) {
          double cTop = childShape.rect!.center.dy;
          double topDiffAbs = (cTop - anchor.dy).abs();
          if (diffTop == 0 || topDiffAbs < diffTop) {
            top = cTop;
            diffTop = topDiffAbs;
          }

          double cLeft = childShape.rect!.center.dx;
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

  //提示文案
  void _drawTooltip(ChartParam param, Canvas canvas, Size size) {
    Offset? anchor = param.localPosition;
    if (anchor == null) {
      return;
    }
    //用widget实现
    if (tooltipBuilder != null) {
      Future.microtask(() {
        controller.notifyTooltip();
      });
      return;
    }
  }

  //背景
  void _drawBackgroundAnnotations(ChartParam param, Canvas canvas) {
    if (backgroundAnnotations != null) {
      for (Annotation element in backgroundAnnotations!) {
        if (!element.isInit) {
          element.init(param);
        }
        element.draw(canvas, param);
      }
    }
  }

  //前景
  void _drawForegroundAnnotations(ChartParam param, Canvas canvas) {
    if (foregroundAnnotations != null) {
      for (Annotation element in foregroundAnnotations!) {
        if (!element.isInit) {
          element.init(param);
        }
        element.draw(canvas, param);
      }
    }
  }
}

typedef AxisFormatter = String? Function(num);
typedef AxisOffset = Offset? Function(Size size);

///放大时的数据
typedef AxisDivideCountAtAmplify = int? Function(double);

///x轴配置
class XAxis {
  ///方便计算，count代表一屏显示的格子数
  final int count;

  ///每个格子代表的值
  final num interval;

  ///x轴最大值， 最大格子数 = max / interval, 如果最大格子数 == count,则不会滚动, 默认值为count的值
  final num max;

  ///x轴文案格式化  不要使用过于耗时的方法
  final AxisFormatter? formatter;

  ///每1个逻辑value代表多宽， 在绘制过程中如果使用Matrix4转换不便更为细腻的控制，所以设计出了密度的概念
  late double density;

  ///固定的密度，不随缩放变动
  late double fixedDensity;

  ///是否画格子线
  final bool drawGrid;

  ///是否有分隔线
  final bool drawDivider;

  ///是否绘制最下面一行的线
  bool drawLine;

  ///文字颜色
  final TextStyle textStyle;

  ///最边上的线的颜色
  final Color lineColor;

  ///放大时单item下分隔数量
  final AxisDivideCountAtAmplify? divideCount;

  //是否支持缩放
  final bool zoom;

  XAxis({
    required this.count,
    this.formatter,
    this.interval = 1,
    this.drawLine = true,
    this.drawGrid = false,
    this.zoom = false,
    this.lineColor = const Color(0x99cccccc),
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.grey),
    this.drawDivider = false,
    this.divideCount,
    num? max,
  }) : max = max ?? count;

  late final Paint linePath = Paint()
    ..color = lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  num widthOf(num value) {
    return density * value;
  }

  Path getDashPath(int index, double height) {
    Path? kDashPath = _gridLine[index];
    if (kDashPath == null) {
      kDashPath = _dashPath(const Offset(0, 0), Offset(0, height));
      _gridLine[index] = kDashPath;
    }
    return kDashPath;
  }

  ///缓存对应的信息
  final Map<int, Path> _gridLine = {};
  final Map<String, TextPainter> _textPainter = {};
}

///y轴配置
class YAxis {
  ///是否开启 暂时未启用
  final bool enable;

  ///最小值
  final num min;

  ///最大值
  final num max;

  ///一屏显示的数量
  final int count;

  ///文案格式化 不要使用过于耗时的方法
  final AxisFormatter? formatter;

  ///是否画轴线
  final bool drawLine;

  ///是否画格子线
  final bool drawGrid;

  ///是否有分隔线
  final bool drawDivider;

  ///密度
  late double density;

  ///固定的密度，不随缩放变动
  late double fixedDensity;

  ///轴的偏移
  final AxisOffset? offset;

  ///文字风格
  final TextStyle textStyle;

  ///最边上线的颜色
  final Color lineColor;

  ///文字距左边的间隙
  final double left;

  //是否支持缩放
  final bool zoom;

  YAxis({
    required this.max,
    this.min = 0,
    this.enable = true,
    this.formatter,
    this.count = 5,
    this.zoom = false,
    this.drawLine = true,
    this.drawGrid = false,
    this.lineColor = const Color(0x99cccccc),
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.grey),
    this.drawDivider = true,
    this.offset,
    this.left = 0,
  }) : assert(zoom == false, '暂不支持垂直方向缩放');

  ///缓存对应的信息
  final Map<int, Path> _gridLine = {};
  final Map<String, TextPainter> _textPainter = {};

  Paint? _paint;
  Paint get paint {
    _paint ??= Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    return _paint!;
  }

  num relativeValue(num value) {
    return value - min;
  }

  double relativeHeight(num value) {
    return (value - min) * density;
  }
}

///该方法太耗性能，建议少用
Path _dashPath(Offset p1, Offset p2) {
  Path path = Path()
    ..moveTo(p1.dx, p1.dy)
    ..lineTo(p2.dx, p2.dy);
  return dashPath(path, dashArray: CircularIntervalList([3, 3]), dashOffset: null);
}
