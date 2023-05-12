import 'package:flutter/material.dart';

import '../../flutter_chart.dart';
import '../base/chart_shape_state.dart';
import '../utils/transform_utils.dart';
import '../widget/dash_painter.dart';

/// @author JD

/// 象限坐标系
class DimensionsChartCoordinateRender extends ChartCoordinateRender {
  //坐标系颜色
  final List<YAxis> yAxis;
  final XAxis xAxis;
  DimensionsChartCoordinateRender({
    super.margin =
        const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 25),
    super.padding =
        const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 0),
    required super.charts,
    super.backgroundAnnotations,
    super.foregroundAnnotations,
    super.tooltipRenderer,
    super.tooltipFormatter,
    super.tooltipWidgetRenderer,
    super.zoomHorizontal,
    super.zoomVertical = false,
    super.minZoom,
    super.maxZoom,
    super.crossHair = const CrossHairStyle(),
    super.safeArea,
    required this.yAxis,
    XAxis? xAxis,
  })  : assert(yAxis.isNotEmpty),
        assert(zoomVertical == false, '暂不支持垂直方向缩放'),
        xAxis = xAxis ?? XAxis(max: 7);

  @override
  void init(Size size) {
    super.init(size);

    double width = size.width;
    double height = size.height;
    int count = xAxis.count;
    //每格的宽度，用于控制一屏最多显示个数
    double density =
        (width - contentMargin.horizontal) / count / xAxis.interval;
    //x轴密度 即1 value 等于多少尺寸
    if (zoomHorizontal) {
      xAxis.density = density * controller.zoom;
    } else {
      xAxis.density = density;
    }
    for (YAxis yA in yAxis) {
      num max = yA.max;
      num min = yA.min;
      int yCount = yA.count;
      //y轴密度  即1 value 等于多少尺寸
      double itemHeight = (height - margin.vertical) / yCount;
      double itemValue = (max - min) / yCount;
      if (zoomVertical) {
        yA.density = itemHeight / itemValue * controller.zoom;
      } else {
        yA.density = itemHeight / itemValue;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(rect);

    //转换工具
    transformUtils = TransformUtils(
      anchor: Offset(margin.left, size.height - margin.bottom),
      zoom: controller.zoom,
      offset: controller.offset,
      size: size,
      zoomVertical: zoomVertical,
      zoomHorizontal: zoomHorizontal,
      padding: padding,
      reverseX: false,
      reverseY: true,
    );
    // canvas.save();
    // 如果按坐标系切，就会面临坐标轴和里面的内容重复循环的问题，该组件的本意是尽可能减少无畏的循环，提高性能，如果
    //给y轴切出来，超出这个范围就隐藏
    // canvas.clipRect(Rect.fromLTWH(0, 0, margin.left, size.height));
    _drawYAxis(canvas, size);
    // canvas.restore();

    //防止超过y轴
    canvas.clipRect(Rect.fromLTWH(
        margin.left, 0, size.width - margin.horizontal, size.height));
    _drawXAxis(canvas, size);
    _drawBackgroundAnnotations(canvas, size);
    //绘图
    for (var element in charts) {
      element.draw(canvas, size);
    }
    _drawForegroundAnnotations(canvas, size);
    _drawCrosshair(canvas, size);
    _drawTooltip(canvas, size);
  }

  void _drawYAxis(Canvas canvas, Size size) {
    int yAxisIndex = 0;
    for (YAxis yA in yAxis) {
      Offset offset = yA.offset?.call(size) ?? Offset.zero;
      num max = yA.max;
      num min = yA.min;
      int count = yA.count;
      double itemValue = (max - min) / count;
      Paint paint = Paint()
        ..color = yA.lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      bool isInt = max is int;

      double left = margin.left + offset.dx;
      //先画文字和虚线
      for (int i = 0; i <= count; i++) {
        num vv = itemValue * i;
        if (isInt) {
          vv = vv.toInt();
        }
        String text = yA.formatter?.call(i) ?? '${min + vv}';
        double top = size.height - contentMargin.bottom - vv * yA.density;
        top = transformUtils.withYOffset(top);
        if (i == count) {
          _drawYTextPaint(
              canvas, text, yA.textStyle, yAxisIndex > 0, left, top, false);
        } else {
          _drawYTextPaint(
              canvas, text, yA.textStyle, yAxisIndex > 0, left, top, true);
        }
        //绘制格子线  先放一起，以免再次遍历
        if (yA.drawGrid) {
          _drawGridLine(canvas, Offset(left, top),
              Offset(size.width - margin.right, top), paint, yA.dashPainter);
        }
        if (yA.drawLine && yA.drawDivider) {
          canvas.drawLine(Offset(left, top), Offset(left + 3, top), paint);
        }
      }
      //再画实线
      if (yA.drawLine) {
        canvas.drawLine(Offset(left, margin.top),
            Offset(left, size.height - margin.bottom), paint);
      }

      yAxisIndex++;
    }
  }

  void _drawGridLine(Canvas canvas, Offset p1, Offset p2, Paint paint,
      DashPainter? dashPainter) {
    Path path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy);
    DashPainter painter = dashPainter ?? const DashPainter(span: 6, step: 3);
    painter.paint(canvas, path, paint);
  }

  void _drawYTextPaint(Canvas canvas, String text, TextStyle textStyle,
      bool right, double left, double top, bool middle) {
    var textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(); // 进行布局
    textPainter.paint(
      canvas,
      Offset(
        right ? left : left - textPainter.width - 5,
        middle ? top - textPainter.height / 2 : top,
      ),
    ); // 进行绘制
  }

  void _drawXAxis(Canvas canvas, Size size) {
    double density = xAxis.density;
    num interval = xAxis.interval;
    Paint paint = Paint()
      ..color = xAxis.lineColor
      ..strokeWidth = 1;

    //实际要显示的数量
    int count = (xAxis.max ?? xAxis.count) ~/ interval;
    //缩放时过滤逻辑
    double xFilterZoom = 1 / controller.zoom;
    //缩小时的策略
    int xReduceInterval = (xFilterZoom < 1 ? 1 : xFilterZoom).round();
    //放大后的策略
    int? xDivideCount = xAxis.divideCount?.call(controller.zoom);
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

      String? text = xAxis.formatter?.call(i);
      double left = contentMargin.left + density * interval * i;
      left = transformUtils.withXZoomOffset(left);

      if (text != null) {
        _drawXTextPaint(canvas, text, xAxis.textStyle, size, left);
      }

      //处理放大时里面的内容
      if (xDivideCount != null && xDivideCount > 0) {
        for (int j = 1; j < xDivideCount; j++) {
          num newValue = i + j * xAmplifyInterval!;
          String? newText = xAxis.formatter?.call(newValue);
          double left = contentMargin.left + density * interval * newValue;
          left = transformUtils.withXZoomOffset(left);
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
        _drawGridLine(
            canvas,
            Offset(left, margin.top),
            Offset(left, size.height - margin.bottom),
            paint,
            xAxis.dashPainter);
      }

      if (xAxis.drawLine && xAxis.drawDivider) {
        canvas.drawLine(Offset(left, size.height - margin.bottom),
            Offset(left, size.height - margin.bottom - 3), paint);
      }
    }

    //划线
    if (xAxis.drawLine) {
      canvas.drawLine(
          Offset(margin.left, size.height - margin.bottom),
          Offset(size.width - margin.right, size.height - margin.bottom),
          paint);
    }
  }

  void _drawXTextPaint(
      Canvas canvas, String text, TextStyle textStyle, Size size, double left) {
    var textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(); // 进行布局
    textPainter.paint(
      canvas,
      Offset(
        left - textPainter.width / 2,
        size.height - margin.bottom + 8,
      ),
    ); // 进行绘制
  }

  void _drawCrosshair(Canvas canvas, Size size) {
    //十字准星
    Offset? anchor = controller.localPosition;
    if (anchor == null) {
      return;
    }
    double? top;
    double? left;

    double diffTop = 0;
    double diffLeft = 0;

    //查找更贴近点击的那条数据
    for (CharBodyState entry in controller.childrenState) {
      int? index = entry.selectedIndex;
      if (index == null) {
        continue;
      }
      ChartShapeState? shape = entry.shapeList?[index];
      if (shape == null) {
        continue;
      }
      //用于找哪个子图更适合
      for (ChartShapeState childShape in shape.children) {
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
      const DashPainter(span: 5, step: 5).paint(canvas, path, paint);
    }
    //水平
    if (crossHair.horizontalShow) {
      Offset p11 = Offset(margin.left, anchor.dy);
      Offset p21 = Offset(size.width - margin.right, anchor.dy);
      Path path1 = Path()
        ..moveTo(p11.dx, p11.dy)
        ..lineTo(p21.dx, p21.dy);
      const DashPainter(span: 5, step: 5).paint(canvas, path1, paint);
    }
  }

  //提示文案
  void _drawTooltip(
    Canvas canvas,
    Size size,
  ) {
    Offset? anchor = controller.localPosition;
    if (anchor == null) {
      return;
    }

    //用widget实现
    if (tooltipWidgetRenderer != null) {
      controller.notifyTooltip();
      return;
    }

    if (tooltipRenderer != null) {
      tooltipRenderer?.call(canvas, size, anchor, controller.childrenState);
      return;
    }

    InlineSpan? textSpan = tooltipFormatter?.call(controller.childrenState);
    if (textSpan == null) {
      return;
    }

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    const EdgeInsets padding = EdgeInsets.all(10);
    final width = padding.left + textPainter.width + padding.right;
    final height = padding.top + textPainter.height + padding.bottom;

    var windowRect = Rect.fromLTWH(
      anchor.dx,
      anchor.dy,
      width,
      height,
    );

    var textPaintPoint = anchor + padding.topLeft;
    const bool constrained = true;
    Rect kSafeArea;
    if (safeArea != null) {
      kSafeArea = Rect.fromLTRB(safeArea!.left, safeArea!.top,
          size.width - safeArea!.right, size.height - safeArea!.bottom);
    } else {
      kSafeArea = Rect.fromLTRB(margin.left, margin.top,
          size.width - margin.right, size.height - margin.bottom);
    }
    if (constrained) {
      final horizontalAdjust = windowRect.left < kSafeArea.left
          ? (kSafeArea.left - windowRect.left)
          : (windowRect.right > kSafeArea.right
              ? (kSafeArea.right - windowRect.right)
              : 0.0);
      final verticalAdjust = windowRect.top < kSafeArea.top
          ? (kSafeArea.top - windowRect.top)
          : (windowRect.bottom > kSafeArea.bottom
              ? (kSafeArea.bottom - windowRect.bottom)
              : 0.0);
      if (horizontalAdjust != 0 || verticalAdjust != 0) {
        windowRect = windowRect.translate(horizontalAdjust, verticalAdjust);
        textPaintPoint =
            textPaintPoint.translate(horizontalAdjust, verticalAdjust);
      }
    }

    const Radius radius = Radius.circular(3.0);
    Path windowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(windowRect, radius));

    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.2;
    const elevation = 3.0;
    const Color backgroundColor = Colors.white;
    canvas.drawShadow(windowPath, backgroundColor, elevation, false);
    // drawShadows(canvas, windowPath, [
    //   BoxShadow(
    //     color: Colors.black.withOpacity(0.05),
    //     offset: const Offset(0, 0),
    //     blurRadius: 2,
    //     spreadRadius: -3,
    //   ),
    //   BoxShadow(
    //     color: Colors.black.withOpacity(0.05),
    //     offset: const Offset(0, 0),
    //     blurRadius: 2,
    //     spreadRadius: 2,
    //   )
    // ]);

    canvas.drawPath(windowPath, paint);

    textPainter.paint(
      canvas,
      textPaintPoint,
    );
    // canvas.drawRect(Rect.fromLTWH(point.dx, point.dy, 100, 40), paint);
  }

  @override
  void scroll(Offset delta) {
    Offset newOffset = controller.offset.translate(-delta.dx, -delta.dy);
    //校准偏移，不然缩小后可能起点都在中间了，或者无限滚动
    double x = newOffset.dx;
    double y = newOffset.dy;
    if (x < 0) {
      x = 0;
    }
    double zoom = controller.zoom;
    if (zoom >= 1) {
      //放大的场景  offset会受到zoom的影响，所以这里的宽度要先剔除zoom的影响再比较
      double chartContentWidth = xAxis.density * (xAxis.max ?? xAxis.count);
      double chartViewPortWidth = size.width - contentMargin.horizontal;
      //处理成跟缩放无关的偏移
      double maxOffset = (chartContentWidth - chartViewPortWidth) / zoom;
      if (maxOffset < 0) {
        //内容小于0
        x = 0;
      } else if (x > maxOffset) {
        x = maxOffset;
      }
    }
    // // zoom = zoom < 1 ? 1 : zoom;
    // double minXOffsetValue = (1 - zoom) * size.width / 2;
    // // print('$x -- $minXOffsetValue');
    // if (x < minXOffsetValue) {
    //   x = minXOffsetValue;
    // }
    // double chartContentWidth = xAxis.density * (xAxis.max ?? xAxis.count);
    // double chartViewPortWidth = size.width - padding.horizontal;
    // double maxOffset = chartContentWidth - chartViewPortWidth;
    // if (x > maxOffset) {
    //   x = maxOffset;
    // }
    // //因为offset可能为负的，换算成正值便于后面计算
    // double realXOffset = x - minXOffsetValue;
    // //说明内容超出了组件
    // if (chartContentWidth > chartViewPortWidth) {
    //   //偏移+
    //   if ((realXOffset + chartViewPortWidth) >= chartContentWidth) {
    //     x = chartContentWidth - chartViewPortWidth + minXOffsetValue;
    //   }
    // } else {
    //   x = minXOffsetValue;
    // }
    //
    // if (zoomVertical) {
    //   //y轴
    //   double minYOffsetValue = (1 - controller.zoom) * size.height / 2;
    //
    //   double chartContentHeight =
    //       padding.vertical + yAxis[0].density * yAxis[0].max;
    //   double chartViewPortHeight = size.height - margin.vertical;
    //   //因为offset可能为负的，换算成正值便于后面计算
    //   // double realYOffset = y - minYOffsetValue;
    //   //说明内容超出了组件
    //   if (chartContentHeight > chartViewPortHeight) {
    //     if (y < minYOffsetValue) {
    //       y = minYOffsetValue;
    //     } else if (y > (chartContentHeight - chartViewPortHeight)) {
    //       y = (chartContentHeight - chartViewPortHeight);
    //     }
    //   } else {
    //     y = minYOffsetValue;
    //   }
    // } else {
    //   y = 0;
    // }

    controller.offset = Offset(x, 0);
    // print(controller.offset);
  }

  //背景
  void _drawBackgroundAnnotations(Canvas canvas, Size size) {
    if (backgroundAnnotations != null) {
      for (Annotation annotation in backgroundAnnotations!) {
        annotation.init(this);
        annotation.draw(canvas, size);
      }
    }
  }

  //前景
  void _drawForegroundAnnotations(Canvas canvas, Size size) {
    if (foregroundAnnotations != null) {
      for (Annotation annotation in foregroundAnnotations!) {
        annotation.init(this);
        annotation.draw(canvas, size);
      }
    }
  }

  //绘制阴影
  // static void drawShadows(Canvas canvas, Path path, List<BoxShadow> shadows) {
  //   for (final BoxShadow shadow in shadows) {
  //     final Paint shadowPainter = shadow.toPaint();
  //     if (shadow.spreadRadius == 0) {
  //       canvas.drawPath(path.shift(shadow.offset), shadowPainter);
  //     } else {
  //       Rect zone = path.getBounds();
  //       double xScale = (zone.width + shadow.spreadRadius) / zone.width;
  //       double yScale = (zone.height + shadow.spreadRadius) / zone.height;
  //       Matrix4 m4 = Matrix4.identity();
  //       m4.translate(zone.width / 2, zone.height / 2);
  //       m4.scale(xScale, yScale);
  //       m4.translate(-zone.width / 2, -zone.height / 2);
  //       canvas.drawPath(
  //           path.shift(shadow.offset).transform(m4.storage), shadowPainter);
  //     }
  //   }
  //   Paint whitePaint = Paint()..color = Colors.black;
  //   canvas.drawPath(path, whitePaint);
  // }
}

typedef AxisFormatter = String? Function(num);
typedef AxisOffset = Offset? Function(Size size);
//放大时的数据
typedef AxisDivideCountAtAmplify = int? Function(double);

//x轴配置
class XAxis {
  //方便计算，count代表一屏显示的格子数
  final int count;
  final num interval;
  final num? max;
  final AxisFormatter? formatter;
  //每1个逻辑value代表多宽
  late double density;
  //是否画格子线
  final bool drawGrid;
  //是否有分隔线
  final bool drawDivider;
  //是否绘制最下面一行的线
  bool drawLine;
  //虚线
  final DashPainter? dashPainter;
  //文字颜色
  final TextStyle textStyle;
  //最边上的线的颜色
  final Color lineColor;
  //放大时单item下分隔数量
  final AxisDivideCountAtAmplify? divideCount;
  XAxis({
    this.formatter,
    this.interval = 1,
    this.count = 7,
    this.drawLine = true,
    this.drawGrid = false,
    this.lineColor = const Color(0x99cccccc),
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.grey),
    this.dashPainter,
    this.drawDivider = true,
    this.divideCount,
    this.max,
  });

  num widthOf(num value) {
    return density * value;
  }
}

//y轴配置
class YAxis {
  //是否开启 暂时未启用
  final bool enable;
  final num min;
  final num max;
  //一屏显示的数量
  final int count;
  //文案格式化
  final AxisFormatter? formatter;
  //是否画轴线
  final bool drawLine;
  //是否画格子线
  final bool drawGrid;
  //是否有分隔线
  final bool drawDivider;
  //密度
  late double density;
  //虚线
  final DashPainter? dashPainter;
  //轴的偏移
  final AxisOffset? offset;
  //文字风格
  final TextStyle textStyle;
  //最边上线的颜色
  final Color lineColor;

  YAxis({
    this.enable = true,
    required this.min,
    required this.max,
    this.formatter,
    this.count = 5,
    this.drawLine = true,
    this.drawGrid = false,
    this.lineColor = const Color(0x99cccccc),
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.grey),
    this.dashPainter,
    this.drawDivider = true,
    this.offset,
  });

  num heightOf(num value) {
    return density * value;
  }
}
