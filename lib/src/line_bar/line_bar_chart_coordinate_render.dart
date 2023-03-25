import 'package:flutter/material.dart';

import '../base/chart_controller.dart';
import '../base/chart_coordinate_render.dart';
import '../widget/dash_painter.dart';

/// @author JD
typedef AxisFormatter = String? Function(int);

class XAxis {
  final int count;
  final num interval;
  final num max;
  final AxisFormatter? formatter;
  late double density;
  final bool drawGrid;
  //是否绘制最下面一行的线
  bool drawLine;
  final DashPainter? dashPainter;
  XAxis({
    this.formatter,
    this.interval = 1,
    this.count = 7,
    this.drawLine = true,
    this.drawGrid = true,
    this.dashPainter,
    required this.max,
  });
}

class YAxis {
  final num min;
  final num max;
  //一屏显示的数量
  final int count;
  final AxisFormatter? formatter;
  final bool drawLine;
  final bool drawGrid;
  //密度
  late double density;
  final DashPainter? dashPainter;
  YAxis({
    required this.min,
    required this.max,
    this.formatter,
    this.count = 5,
    this.drawLine = true,
    this.drawGrid = true,
    this.dashPainter,
  });
}

class LineBarChartCoordinateRender<T> extends ChartCoordinateRender<T> {
  //坐标系颜色
  final Color lineColor;
  final YAxis yAxis;
  final XAxis xAxis;
  LineBarChartCoordinateRender({
    required super.data,
    super.margin = const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 30),
    super.padding = const EdgeInsets.only(left: 30, top: 0, right: 0, bottom: 0),
    required super.position,
    required super.chartRender,
    super.backgroundAnnotations,
    super.foregroundAnnotations,
    super.tooltipRenderer,
    super.tooltipFormatter,
    super.zoom,
    super.crossHair = const CrossHairStyle(),
    YAxis? yAxis,
    XAxis? xAxis,
    this.lineColor = Colors.grey,
  })  : yAxis = yAxis ?? YAxis(min: 0, max: 10),
        xAxis = xAxis ?? XAxis(max: 7);

  @override
  void init(Canvas canvas, Size size) {
    super.init(canvas, size);

    double width = size.width;
    double height = size.height;
    //每格的宽度，用于控制一屏最多显示个数
    int count = xAxis.count;
    double density = (width - contentMargin.horizontal) / count;
    //x轴密度 即1 value 等于多少尺寸
    xAxis.density = density * controller.zoom;

    num max = yAxis.max;
    num min = yAxis.min;
    int yCount = yAxis.count;
    //y轴密度  即1 value 等于多少尺寸
    double itemHeight = (height - margin.vertical) / yCount;
    double itemValue = (max - min) / yCount;
    yAxis.density = itemHeight / itemValue;
    //缩放比例
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(rect);
    _drawYAxis(canvas, size);
    //防止超过y轴
    canvas.clipRect(Rect.fromLTWH(margin.left, margin.top, size.width - margin.left - margin.right, size.height));
    _drawXAxis(canvas, size);
    _drawBackgroundAnnotations(canvas, size);
    chartRender.draw();
    _drawTooltip(canvas, size);
    _drawCrosshair(canvas, size);
    _drawForegroundAnnotations(canvas, size);
  }

  void _drawYAxis(Canvas canvas, Size size) {
    num max = yAxis.max;
    num min = yAxis.min;
    int count = yAxis.count;
    double itemValue = (max - min) / count;
    double itemHeight = itemValue * yAxis.density;
    Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.2;
    //划线
    if (yAxis.drawLine) {
      canvas.drawLine(Offset(margin.left, margin.top), Offset(margin.left, size.height - margin.bottom), paint);
    }
    for (int i = 0; i <= count; i++) {
      String text = yAxis.formatter?.call(i) ?? '${min + itemValue * i}';

      if (i == count) {
        _drawYTextPaint(canvas, text, margin.top, false);
      } else {
        _drawYTextPaint(canvas, text, size.height - margin.bottom - itemHeight * i, true);
      }
      //绘制格子线
      if (yAxis.drawGrid) {
        _drawGridLine(canvas, Offset(margin.left, margin.top + itemHeight * i), Offset(size.width - margin.right, margin.top + itemHeight * i), yAxis.dashPainter);
      }
    }
  }

  void _drawGridLine(Canvas canvas, Offset p1, Offset p2, DashPainter? dashPainter) {
    Paint paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.2;
    Path path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy);
    DashPainter painter = dashPainter ?? const DashPainter(span: 5, step: 5);
    painter.paint(canvas, path, paint);
  }

  void _drawYTextPaint(Canvas canvas, String text, double top, bool middle) {
    var textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12,
          color: lineColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(); // 进行布局
    textPainter.paint(
      canvas,
      Offset(
        margin.left - textPainter.width - 5,
        middle ? top - textPainter.height / 2 : top,
      ),
    ); // 进行绘制
  }

  void _drawXAxis(Canvas canvas, Size size) {
    double density = xAxis.density;
    Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.2;
    //划线
    if (xAxis.drawLine) {
      canvas.drawLine(Offset(margin.left, size.height - margin.bottom), Offset(size.width - margin.right, size.height - margin.bottom), paint);
    }

    int count = xAxis.max ~/ xAxis.interval;
    for (int i = 0; i < count; i++) {
      String text = xAxis.formatter?.call(i) ?? '$i';

      double left = contentMargin.left + density * i;
      left = withXOffset(left);
      left = withXZoom(left);
      _drawXTextPaint(canvas, text, size, left);
      // if (i == dreamXAxisCount - 1) {
      //   _drawXTextPaint(canvas, '${i + 1}', size,
      //       size.width - padding.right - contentPadding.right - 5);
      // }
      if (xAxis.drawGrid) {
        _drawGridLine(canvas, Offset(left, margin.top), Offset(left, size.height - margin.bottom), xAxis.dashPainter);
      }
    }
  }

  void _drawXTextPaint(Canvas canvas, String text, Size size, double left) {
    var textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 12,
          color: lineColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(); // 进行布局
    textPainter.paint(
      canvas,
      Offset(
        left - textPainter.width / 2,
        size.height - margin.bottom + 5,
      ),
    ); // 进行绘制
  }

  void _drawCrosshair(Canvas canvas, Size size) {
    //十字准星
    Offset? anchor = controller.gesturePoint;
    int? index = controller.selectedIndex;
    if (anchor == null || index == null) {
      return;
    }

    ChartShape? shape = controller.shapeList?[index];
    if (shape == null) {
      return;
    }
    double? top = shape.rect?.top;
    double? left = shape.rect?.left;
    double diffTop = 0;
    double diffLeft = 0;
    //用于找哪个子图更适合
    for (ChartShape childShape in shape.children) {
      if (childShape.rect != null) {
        double cTop = childShape.rect!.top;
        double topDiffAbs = (cTop - anchor.dy).abs();
        if (topDiffAbs < diffTop) {
          top = childShape.rect!.top;
        } else if (diffTop == 0) {
          diffTop = topDiffAbs;
          top = childShape.rect!.top;
        }

        double cLeft = childShape.rect!.left;
        double leftDiffAbs = (cLeft - anchor.dx).abs();
        if (leftDiffAbs < diffLeft) {
          left = childShape.rect!.left;
        } else if (diffLeft == 0) {
          diffLeft = leftDiffAbs;
          left = childShape.rect!.left;
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
      Offset p2 = Offset(anchor.dx, size.height - margin.vertical);
      Path path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy);
      const DashPainter(span: 5, step: 5).paint(canvas, path, paint);
    }
    //水平
    if (crossHair.horizontalShow) {
      Offset p11 = Offset(margin.left, anchor.dy);
      Offset p21 = Offset(size.width - margin.horizontal, anchor.dy);
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
    Offset? anchor = controller.gesturePoint;
    int? index = controller.selectedIndex;
    if (anchor == null || index == null) {
      return;
    }
    if (tooltipRenderer != null) {
      tooltipRenderer?.call(canvas, size, anchor, index);
      return;
    }
    T item = data[index];
    InlineSpan? textSpan = tooltipFormatter?.call(item);
    if (textSpan == null) {
      return;
    }

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    const EdgeInsets padding = EdgeInsets.all(5);
    final width = padding.left + textPainter.width + padding.right;
    final height = padding.top + textPainter.height + padding.bottom;

    var windowRect = Rect.fromLTWH(
      anchor.dx,
      anchor.dy,
      width,
      height,
    );

    var textPaintPoint = anchor + padding.topLeft;
    //是否约束在组件范围内
    const bool constrained = true;
    Size contentSize = Size(size.width - padding.horizontal, size.height - padding.vertical);
    if (constrained) {
      final horizontalAdjust = windowRect.left < 0 ? -windowRect.left : (windowRect.right > contentSize.width ? contentSize.width - windowRect.right : 0.0);
      final verticalAdjust = windowRect.top < 0 ? -windowRect.top : (windowRect.bottom > contentSize.height ? contentSize.height - windowRect.bottom : 0.0);
      if (horizontalAdjust != 0 || verticalAdjust != 0) {
        windowRect = windowRect.translate(horizontalAdjust, verticalAdjust);
        textPaintPoint = textPaintPoint.translate(horizontalAdjust, verticalAdjust);
      }
    }

    const Radius radius = Radius.circular(3.0);
    Path windowPath = Path()..addRRect(RRect.fromRectAndRadius(windowRect, radius));

    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.2;
    const elevation = 3.0;
    const Color backgroundColor = Colors.white;
    canvas.drawShadow(windowPath, backgroundColor, elevation, true);

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
    //因为缩放最小值可能为负的了
    double minValue = (1 - controller.zoom) * size.width / 2;
    if (x < minValue) {
      x = minValue;
    }
    if (y < 0) {
      y = 0;
    }
    double chartContentWidth = padding.horizontal + xAxis.density * xAxis.max;
    double chartViewPortWidth = size.width - margin.horizontal;
    //因为offset可能为负的，换算成正值便于后面计算
    double realOffset = x - minValue;
    //说明内容超出了组件
    if (chartContentWidth > chartViewPortWidth) {
      //偏移+
      if ((realOffset + chartViewPortWidth) >= chartContentWidth) {
        x = chartContentWidth - chartViewPortWidth + minValue;
      }
    } else {
      x = minValue;
    }
    controller.offset = Offset(x, y);
  }

  //背景
  void _drawBackgroundAnnotations(Canvas canvas, Size size) {
    backgroundAnnotations?.forEach((element) {
      element.init(this);
      element.draw();
    });
  }

  //前景
  void _drawForegroundAnnotations(Canvas canvas, Size size) {
    foregroundAnnotations?.forEach((element) {
      element.init(this);
      element.draw();
    });
  }
}
