part of flutter_chart_plus;

/// @author jd
//区间标注
class RegionAnnotation extends Annotation {
  ///区间在x轴上的位置，两个长度
  final List<num> positions;

  ///区间颜色
  final Color color;

  RegionAnnotation({
    super.scroll = true,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.positions,
    this.color = const Color(0xFFF5F5F5),
  });

  Paint? _paint;
  @override
  void init(ChartParam param) {
    super.init(param);
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;
  }

  @override
  void draw(Canvas canvas, ChartParam param) {
    if (!needDraw(param)) {
      return;
    }
    if (param is _ChartDimensionParam) {
      assert(positions.length == 2, 'positions must be two length');
      num po1 = positions[0];
      num po2 = positions[1];
      double start = param.layout.transform.transformX(po1 * param.xAxis.density);
      start = param.layout.transform.withXOffset(start);
      double end = param.layout.transform.transformX(po2 * param.xAxis.density);
      end = param.layout.transform.withXOffset(end);

      double top = param.layout.top;
      double bottom = param.layout.bottom;
      if (_paint != null) {
        canvas.drawRect(Rect.fromLTRB(start, top, end, bottom), _paint!);
      }
    }
  }
}
