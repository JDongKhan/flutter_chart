part of flutter_chart_plus;

///
/// @author JD

///十字准星样式
class CrossHairStyle {
  final Color color;
  final bool horizontalShow;
  final bool verticalShow;
  final double strokeWidth;
  //自动调整水平方向位置
  final bool adjustHorizontal;
  //自动调整垂直方向位置
  final bool adjustVertical;
  const CrossHairStyle({
    this.color = Colors.blue,
    this.horizontalShow = true,
    this.verticalShow = true,
    this.strokeWidth = 0.5,
    this.adjustHorizontal = false,
    this.adjustVertical = false,
  });
}

typedef ChartTooltipFormatter = InlineSpan? Function(List<ChartLayoutParam>);

///坐标渲染器， 每次刷新会重新构造，切忌不要存放状态数据，数据都在state里面
abstract class ChartCoordinateRender {
  ///图形外边距，用于控制坐标轴的外边距
  final EdgeInsets margin;

  ///图形内边距，用于控制坐标轴的内边距  不支持垂直方向的padding
  ///assert(padding.bottom == 0 && padding.top == 0, "暂不支持垂直方向的内间距")
  final EdgeInsets padding;

  ///最小缩放
  final double? minZoom;

  ///最大缩放
  final double? maxZoom;

  ///坐标系中间的绘图
  final List<ChartBodyRender> charts;

  ///安全区域
  final EdgeInsets? safeArea;

  ///用widget弹框来处理点击
  final TooltipWidgetBuilder? tooltipBuilder;

  ///背景标注
  final List<Annotation>? backgroundAnnotations;

  ///前景标注
  final List<Annotation>? foregroundAnnotations;

  ///不在屏幕内是否绘制 默认不绘制
  final bool outDraw;

  ///动画时间
  final Duration? animationDuration;

  ChartCoordinateRender({
    required this.margin,
    required this.padding,
    required this.charts,
    this.tooltipBuilder,
    this.minZoom,
    this.maxZoom,
    this.outDraw = false,
    this.animationDuration,
    this.backgroundAnnotations,
    this.foregroundAnnotations,
    this.safeArea,
  });

  late ChartController controller;

  bool canZoom();

  void paint(Canvas canvas, ChartParam param);
}
