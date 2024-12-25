part of flutter_chart_plus;

enum ArcDirection {
  none,
  up,
  down,
}

@Deprecated('instead of  using [ChartCircularCoordinateRender]')
typedef CircularChartCoordinateRender = ChartCircularCoordinateRender;

/// @author JD
/// 圆形坐标系
class ChartCircularCoordinateRender extends ChartCoordinateRender {

  ChartCircularCoordinateRender({
    super.margin = EdgeInsets.zero,
    super.padding = EdgeInsets.zero,
    required super.charts,
    super.safeArea,
    super.outDraw,
    super.animationDuration,
    super.backgroundAnnotations,
    super.foregroundAnnotations,
    super.onClickChart,
    this.arcDirection = ArcDirection.none,
    this.borderWidth = 1,
    this.strokeCap,
    this.borderColor = Colors.white,
  });
  ///边框宽度
  final double borderWidth;
  ///边框颜色
  final Color borderColor;
  ///画笔样式
  final StrokeCap? strokeCap;
  /// 弧度方向
  final ArcDirection arcDirection;

  // 定义圆形的绘制属性
  late final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = borderColor
    ..isAntiAlias = true
    ..strokeWidth = borderWidth;

  @override
  void paint(Canvas canvas, ChartsState state) {
    ChartCircularCoordinateState layout = state.layout as ChartCircularCoordinateState;
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
  void _drawCircle(ChartCircularCoordinateState layout, Canvas canvas) {
    if (strokeCap != null) {
      _paint.strokeCap = strokeCap!;
    }
    //满圆
    if (arcDirection == ArcDirection.none) {
      // 使用 Canvas 的 drawCircle 绘制
      canvas.drawCircle(layout.center, layout.radius, _paint);
    } else {
      double startAngle = 0;
      double sweepAngle = math.pi;
      if (arcDirection == ArcDirection.up) {
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
