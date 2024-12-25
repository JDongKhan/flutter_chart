part of flutter_chart_plus;

/// @author jd
//路径
class PathAnnotation extends Annotation {

  PathAnnotation({
    super.fixed = false,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.path,
    this.color = const Color(0xFFF5F5F5),
    this.anchor,
  });

  ///路径
  final Path path;

  ///颜色
  final Color color;

  ///所在位置
  final Offset Function(Size)? anchor;


  Paint? _paint;
  Path? _path;
  @override
  void init(ChartsState state) {
    super.init(state);
    _paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    _path = path;
    if (anchor != null) {
      Offset ost = anchor!(state.layout.size);
      final matrix = Matrix4.identity()..leftTranslate(ost.dx, ost.dy);
      _path = path.transform(matrix.storage);
    }
  }

  @override
  void draw(Canvas canvas, ChartsState state) {
    if (!isNeedDraw(state)) {
      return;
    }
    if (_paint != null && _path != null) {
      if (!fixed) {
        final scaleMatrix = Matrix4.identity();
        scaleMatrix.translate(-(state.layout.offset.dx - state.layout.left), 0);
        if (state.layout.zoom != 1) {
          scaleMatrix.scale(state.layout.zoom, 1);
        }
      }
      canvas.drawPath(_path!, _paint!);
    }
  }
}
