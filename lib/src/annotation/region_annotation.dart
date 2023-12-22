part of flutter_chart_plus;

/// @author jd
//区间标注
class RegionAnnotation extends Annotation {
  ///区间在x轴上的位置，两个长度
  final List<num> positions;

  ///区间颜色
  final Color color;

  RegionAnnotation({
    super.fixed = false,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.positions,
    this.color = const Color(0xFFF5F5F5),
  });

  Paint? _paint;
  @override
  void init(ChartsState state) {
    super.init(state);
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;
  }

  @override
  void draw(Canvas canvas, ChartsState state) {
    if (!isNeedDraw(state)) {
      return;
    }
    ChartCoordinateState layout = state.layout;
    if (layout is ChartDimensionCoordinateState) {
      assert(positions.length == 2, 'positions must be two length');
      num startValue = positions[0];
      num endValue = positions[1];
      //区间start
      double startPos = layout.xAxis.getWidth(startValue, fixed);
      startPos = layout.transform.transformX(startPos);
      startPos = layout.transform.withXScroll(startPos);
      //区间end
      double endPos = layout.xAxis.getWidth(endValue, fixed);
      endPos = layout.transform.transformX(endPos);
      endPos = layout.transform.withXScroll(endPos);
      double top = layout.top;
      double bottom = layout.bottom;
      if (_paint != null) {
        canvas.drawRect(Rect.fromLTRB(startPos, top, endPos, bottom), _paint!);
      }
    }
  }
}
