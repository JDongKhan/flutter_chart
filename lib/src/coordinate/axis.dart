part of flutter_chart_plus;

typedef AxisFormatter = String? Function(num);
typedef AxisOffset = Offset? Function(Size size);

///放大时的数据
typedef AxisDivideCountAtAmplify = int? Function(double);

///x轴配置
class XAxis {
  ///方便计算，count代表一屏显示的格子数
  final int count;

  ///每个格子代表的值
  final num interval;

  ///x轴最大值， 最大格子数 = max / interval, 如果最大格子数 == count,则不会滚动, 默认值为count的值
  final num max;

  ///x轴文案格式化  不要使用过于耗时的方法
  final AxisFormatter? formatter;

  ///每1个逻辑value代表多宽， 在绘制过程中如果使用Matrix4转换不便更为细腻的控制，所以设计出了密度的概念
  late double density;

  ///固定的密度，不随缩放变动
  late double fixedDensity;

  ///是否画格子线
  final bool drawGrid;

  ///是否有分隔线
  final bool drawDivider;

  ///是否绘制label
  final bool drawLabel;

  ///是否绘制最下面一行的线
  bool drawLine;

  ///文字颜色
  final TextStyle textStyle;

  ///最边上的线的颜色
  final Color lineColor;

  ///放大时单item下分隔数量
  final AxisDivideCountAtAmplify? divideCount;

  //是否支持缩放
  final bool zoom;

  XAxis({
    required this.count,
    this.formatter,
    this.interval = 1,
    this.drawLine = true,
    this.drawGrid = false,
    this.drawLabel = true,
    this.zoom = false,
    this.lineColor = const Color(0x99cccccc),
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.grey),
    this.drawDivider = false,
    this.divideCount,
    num? max,
  })  : max = max ?? count * interval,
        assert(count > 0, "count must be greater than 0 "),
        assert(interval > 0, "interval must be greater than 0  ");

  ///根据元数据计算出对应的宽带
  double getWidth(num value, [bool fixed = false]) {
    if (fixed) {
      return value * fixedDensity;
    }
    return value * density;
  }

  ///轴线
  late final Paint linePaint = Paint()
    ..color = lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  ///x轴的虚线
  Path getDashPath(int index, Offset endPoint) {
    Path? kDashPath = _gridLine[index];
    if (kDashPath == null) {
      kDashPath = _dashPath(const Offset(0, 0), endPoint);
      _gridLine[index] = kDashPath;
    }
    return kDashPath;
  }

  ///缓存对应的信息
  final Map<int, Path> _gridLine = {};
  final Map<String, TextPainter> _textPainter = {};
}

///y轴配置
class YAxis {
  ///最小值
  final num min;

  ///最大值
  final num max;

  ///一屏显示的数量
  final int count;

  ///文案格式化 不要使用过于耗时的方法
  final AxisFormatter? formatter;

  ///是否画轴线
  final bool drawLine;

  ///是否画格子线
  final bool drawGrid;

  ///是否有分隔线
  final bool drawDivider;

  ///是否绘制label
  final bool drawLabel;

  ///轴的偏移
  final AxisOffset? offset;

  ///文字风格
  final TextStyle textStyle;

  ///最边上线的颜色
  final Color lineColor;

  ///文字距边的间隙
  final double padding;

  //是否支持缩放
  final bool zoom;

  YAxis({
    required this.max,
    this.min = 0,
    this.formatter,
    this.drawLabel = true,
    this.count = 5,
    this.zoom = false,
    this.drawLine = true,
    this.drawGrid = false,
    this.lineColor = const Color(0x99cccccc),
    this.textStyle = const TextStyle(fontSize: 12, color: Colors.grey),
    this.drawDivider = true,
    this.offset,
    this.padding = 0,
  })  : assert(zoom == false, '暂不支持垂直方向缩放'),
        assert(max > 0, "max must be greater than 0 ");

  ///密度
  late double density;

  ///固定的密度，也就是原始密度，不随缩放变动
  late double fixedDensity;

  ///缓存对应的信息
  final Map<int, Path> _gridLine = {};
  final Map<String, TextPainter> _textPainter = {};

  ///y轴线
  Paint? _paint;
  Paint get linePaint {
    _paint ??= Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    return _paint!;
  }

  ///y轴对应的虚线
  Path getDashPath(int index, Offset endPoint) {
    Path? kDashPath = _gridLine[index];
    if (kDashPath == null) {
      kDashPath = _dashPath(const Offset(0, 0), endPoint);
      _gridLine[index] = kDashPath;
    }
    return kDashPath;
  }

  ///根据元数据计算出对应的高度
  double getHeight(num value, [bool fixed = false]) {
    if (fixed) {
      return (value - min) * fixedDensity;
    }
    return (value - min) * density;
  }
}

///该方法太耗性能，建议少用
Path _dashPath(Offset p1, Offset p2) {
  Path path = Path()
    ..moveTo(p1.dx, p1.dy)
    ..lineTo(p2.dx, p2.dy);
  return dashPath(path, dashArray: CircularIntervalList([3, 3]), dashOffset: null);
}
