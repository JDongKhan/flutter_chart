part of flutter_chart_plus;

/// @author jd
class LabelAnnotation extends Annotation {

  LabelAnnotation({
    super.userInfo,
    super.onTap,
    super.fixed = false,
    super.yAxisPosition = 0,
    super.minZoomVisible,
    super.maxZoomVisible,
    required this.text,
    this.positions,
    this.anchor,
    this.offset = Offset.zero,
    this.textAlign = TextAlign.start,
    this.textStyle = const TextStyle(color: Colors.red),
  }) : assert(positions != null || anchor != null, 'positions or anchor must be not null');

  ///两个长度的数组，优先级最高，ImageAnnotation的位置，对应xy轴的value
  final List<num>? positions;

  ///文本风格
  final TextStyle textStyle;

  ///对齐方式
  final TextAlign textAlign;

  ///内容
  final String text;

  ///偏移，可以做细微调整
  final Offset offset;

  ///设置Annotation的偏移，忽略positions的设置
  final Offset Function(Size)? anchor;


  TextPainter? _textPainter;

  @override
  void init(ChartsState state) {
    super.init(state);
    _textPainter = TextPainter(text: TextSpan(text: text, style: textStyle), textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: state.layout.size.width);
  }

  @override
  void draw(Canvas canvas, ChartsState state) {
    if (!isNeedDraw(state)) {
      return;
    }
    ChartCoordinateState layout = state.layout;
    if (layout is ChartDimensionCoordinateState) {
      Offset ost;
      if (positions != null) {
        assert(positions!.length == 2, 'positions must be two length');
        num xValue = positions![0];
        num yValue = positions![1];
        double xPos = layout.xAxis.getWidth(xValue, fixed);
        double yPos = layout.yAxis[yAxisPosition].getHeight(yValue, fixed);
        Offset point = layout.transform.transformPoint(Offset(xPos, yPos), containPadding: true, xOffset: !fixed, yOffset: !fixed);
        ost = point.translate(offset.dx, offset.dy);
      } else {
        ost = anchor!(layout.size);
      }
      if (textAlign == TextAlign.end) {
        ost = ost.translate(-_textPainter!.width, 0);
      } else if (textAlign == TextAlign.center) {
        ost = ost.translate(-_textPainter!.width / 2, 0);
      }
      super.rect = ost & _textPainter!.size;
      _textPainter!.paint(canvas, ost);
    }
  }
}
