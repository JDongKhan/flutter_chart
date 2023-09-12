part of flutter_chart_plus;

/// @author jd
//路径
class PathAnnotation extends Annotation {
  ///路径
  final Path path;

  ///颜色
  final Color color;

  ///所在位置
  final Offset Function(Size)? anchor;

  PathAnnotation({
    super.scroll = true,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.path,
    this.color = const Color(0xFFF5F5F5),
    this.anchor,
  });

  Paint? _paint;
  Path? _path;
  @override
  void init(ChartParam param) {
    super.init(param);
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    _path = path;
    if (anchor != null) {
      Offset ost = anchor!(param.size);
      final matrix = Matrix4.identity()..leftTranslate(ost.dx, ost.dy);
      _path = path.transform(matrix.storage);
    }
  }

  @override
  void draw(Canvas canvas, ChartParam param) {
    if (!needDraw(param)) {
      return;
    }
    if (_paint != null && _path != null) {
      canvas.drawPath(_path!, _paint!);
    }
  }
}
