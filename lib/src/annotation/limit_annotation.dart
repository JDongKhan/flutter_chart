part of flutter_chart_plus;

typedef AnnotationPosition<T> = num Function(T);

/// @author jd
class LimitAnnotation extends Annotation {
  ///限制线对应y轴的value
  final num limit;

  ///线的颜色
  final Color color;

  ///线宽
  final double strokeWidth;

  LimitAnnotation({
    super.fixed = true,
    super.yAxisPosition = 0,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.limit,
    this.color = Colors.red,
    this.strokeWidth = 1,
  });
  Paint? _paint;
  Path? _path;

  @override
  void init(ChartParam param) {
    super.init(param);
    if (param is _ChartDimensionParam) {
      num yValue = limit;
      double yPos = param.yAxis[yAxisPosition].getItemHeight(yValue, fixed);
      yPos = param.layout.transform.transformY(yPos, containPadding: true);
      Offset start = Offset(param.layout.padding.left, yPos);
      Offset end = Offset(param.layout.size.width - param.layout.padding.right, yPos);
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
  void draw(Canvas canvas, ChartParam param) {
    if (!isNeedDraw(param)) {
      return;
    }
    if (_path != null && _paint != null) {
      canvas.drawPath(_path!, _paint!);
    }
  }
}
