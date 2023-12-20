part of flutter_chart_plus;

/// @author jd
class Progress<T> extends ChartBodyRender<T> {
  ///不要使用过于耗时的方法
  ///数据在坐标系的位置，每个坐标系下取值逻辑不一样，在line和bar下是相对于每格的值，比如xAxis的interval为1，你的数据放在1列和2列中间，那么position就是0.5，在pie下是比例
  final ChartPosition<T> position;

  ///线宽
  final double strokeWidth;

  ///开始弧度，可以调整起始位置
  final double startAngle;

  ///结尾样式
  final StrokeCap? strokeCap;

  ///颜色
  final List<Color> colors;

  ///结尾画小原点
  final bool endPoint;

  Progress({
    required super.data,
    required this.position,
    this.endPoint = false,
    this.colors = colors10,
    this.startAngle = math.pi,
    this.strokeWidth = 1,
    this.strokeCap,
  });

  late final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = strokeWidth;
  Paint? _endPaint;

  @override
  void init(ChartParam param) {
    super.init(param);

    if (strokeCap != null) {
      _paint.strokeCap = strokeCap!;
    }
    if (endPoint) {
      _endPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white
        ..isAntiAlias = true
        ..strokeWidth = 1;
    }
  }

  @override
  void draw(Canvas canvas, ChartParam param) {
    param as _ChartCircularParam;
    Offset center = param.center;
    double radius = param.radius;

    int index = 0;
    num? lastXvs;

    double startAngle = this.startAngle;
    double fullSweepAngle = math.pi;
    //
    if (param.arcPosition == ArcPosition.none) {
      fullSweepAngle = math.pi * 2;
    } else if (param.arcPosition == ArcPosition.up) {
      fullSweepAngle = math.pi;
    } else if (param.arcPosition == ArcPosition.down) {
      startAngle = 0;
    }

    for (T item in data) {
      num po = position.call(item);
      if (lastXvs != null) {
        assert(lastXvs > po, '数据必须降序，否则会被挡住');
      }
      double sweepAngle = fullSweepAngle * po * param.layout.controlValue;
      Path path = Path()
        ..addArc(
          Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
          startAngle,
          sweepAngle,
        );
      canvas.drawPath(path, _paint..color = colors[index]);
      if (_endPaint != null && sweepAngle > 0) {
        double endAngle = startAngle + sweepAngle;
        var startX = math.cos(endAngle) * radius + center.dx;
        var startY = math.sin(endAngle) * radius + center.dy;
        canvas.drawCircle(Offset(startX, startY), strokeWidth / 2 - 2, _endPaint!);
      }
      index++;
      lastXvs = po;
    }
  }
}
