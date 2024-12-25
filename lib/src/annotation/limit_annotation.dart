part of flutter_chart_plus;

typedef AnnotationPosition<T> = num Function(T);

/// @author jd
class LimitAnnotation extends Annotation {

  LimitAnnotation({
    super.fixed = true,
    super.yAxisPosition = 0,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.limit,
    this.color = Colors.red,
    this.strokeWidth = 1,
  });

  ///限制线对应y轴的value
  final num limit;

  ///线的颜色
  final Color color;

  ///线宽
  final double strokeWidth;

  Paint? _paint;
  Path? _path;

  @override
  void init(ChartsState state) {
    super.init(state);
    ChartCoordinateState layout = state.layout;
    if (layout is ChartDimensionCoordinateState) {
      num yValue = limit;
      double yPos = layout.yAxis[yAxisPosition].getHeight(yValue, fixed);
      yPos = layout.transform.transformY(yPos, containPadding: true);
      Offset start = Offset(layout.padding.left, yPos);
      Offset end = Offset(layout.size.width - layout.padding.right, yPos);
      _paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      Path path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(end.dx, end.dy);
      Path kDashPath = dashPath(path, dashArray: CircularIntervalList([3, 3]), dashOffset: null);
      _path = kDashPath;
    }
  }

  @override
  void draw(Canvas canvas, ChartsState state) {
    if (!isNeedDraw(state)) {
      return;
    }
    if (_path != null && _paint != null) {
      canvas.drawPath(_path!, _paint!);
    }
  }
}
