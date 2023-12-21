part of flutter_chart_plus;

enum ArcPosition {
  none,
  up,
  down,
}

@Deprecated('instead of  using [ChartCircularCoordinateRender]')
typedef CircularChartCoordinateRender = ChartCircularCoordinateRender;

/// @author JD
/// 圆形坐标系
class ChartCircularCoordinateRender extends ChartCoordinateRender {
  final double borderWidth;
  final Color borderColor;
  final StrokeCap? strokeCap;
  final ArcPosition arcPosition;
  ChartCircularCoordinateRender({
    super.margin = EdgeInsets.zero,
    super.padding = EdgeInsets.zero,
    required super.charts,
    super.safeArea,
    super.outDraw,
    super.animationDuration,
    super.backgroundAnnotations,
    super.foregroundAnnotations,
    this.arcPosition = ArcPosition.none,
    this.borderWidth = 1,
    this.strokeCap,
    this.borderColor = Colors.white,
  });

  // 定义圆形的绘制属性
  late final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = borderColor
    ..isAntiAlias = true
    ..strokeWidth = borderWidth;

  @override
  void paint(Canvas canvas, ChartsState state) {
    _ChartCircularCoordinateState layout = state.layout as _ChartCircularCoordinateState;
    _drawCircle(layout, canvas);
    _drawBackgroundAnnotations(state, canvas);
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
  }

  @override
  bool canZoom() {
    return false;
  }

  ///画背景圆
  void _drawCircle(_ChartCircularCoordinateState layout, Canvas canvas) {
    if (strokeCap != null) {
      _paint.strokeCap = strokeCap!;
    }
    //满圆
    if (arcPosition == ArcPosition.none) {
      // 使用 Canvas 的 drawCircle 绘制
      canvas.drawCircle(layout.center, layout.radius, _paint);
    } else {
      double startAngle = 0;
      double sweepAngle = math.pi;
      if (arcPosition == ArcPosition.up) {
        startAngle = math.pi;
      }
      Path path = Path()
        ..addArc(
          Rect.fromCenter(
            center: layout.center,
            width: layout.radius * 2,
            height: layout.radius * 2,
          ),
          startAngle,
          sweepAngle,
        );
      canvas.drawPath(path, _paint);
    }
  }

  ///背景
  void _drawBackgroundAnnotations(ChartsState state, Canvas canvas) {
    backgroundAnnotations?.forEach((element) {
      if (!element.isInit) {
        element.init(state);
      }
      element.draw(canvas, state);
    });
  }

  ///前景
  void _drawForegroundAnnotations(ChartsState state, Canvas canvas) {
    foregroundAnnotations?.forEach((element) {
      if (!element.isInit) {
        element.init(state);
      }
      element.draw(canvas, state);
    });
  }
}
