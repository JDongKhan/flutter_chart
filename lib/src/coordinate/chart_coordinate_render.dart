part of flutter_chart_plus;

///
/// @author JD

///十字准星样式
class CrossHairStyle {

  const CrossHairStyle({
    this.color = Colors.blue,
    this.horizontalShow = true,
    this.verticalShow = true,
    this.strokeWidth = 0.5,
    this.adjustHorizontal = false,
    this.adjustVertical = false,
  });
  final Color color;
  final bool horizontalShow;
  final bool verticalShow;
  final double strokeWidth;
  //自动调整水平方向位置
  final bool adjustHorizontal;
  //自动调整垂直方向位置
  final bool adjustVertical;
}

typedef ChartTooltipFormatter = InlineSpan? Function(List<ChartLayoutState>);

///坐标渲染器， 每次刷新会重新构造，切忌不要存放状态数据，数据都在state里面
abstract class ChartCoordinateRender {

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
    this.onClickChart,
  }): assert(padding.bottom == 0 && padding.top == 0,"暂不支持垂直方向的内间距");


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

  ///用widget弹框来处理点击,返回PreferredSizeWidget便于边界碰撞计算，如果不在乎边界问题，可以随便设置，值越靠近真实宽高边界检测越准
  final TooltipWidgetBuilder? tooltipBuilder;

  ///点击事件
  final OnClickChart? onClickChart;

  ///背景标注
  final List<Annotation>? backgroundAnnotations;

  ///前景标注
  final List<Annotation>? foregroundAnnotations;

  ///不在屏幕内是否绘制 默认不绘制
  final bool outDraw;

  ///动画时间
  final Duration? animationDuration;

  late ChartController controller;

  ///判断图表数量和类型是否发生改变  未改变就做tween动画  改变了就重置 防止数据错乱
  bool hasChange(ChartCoordinateRender other) {
    bool change = other.runtimeType != runtimeType || other.charts.length != charts.length;
    if (!change) {
      for (int i = 0; i < charts.length; i++) {
        ChartBodyRender chart = charts[i];
        ChartBodyRender otherChart = other.charts[i];
        if (chart.runtimeType != otherChart.runtimeType) {
          change = true;
        }
      }
    }
    return change;
  }

  bool canZoom();

  void paint(Canvas canvas, ChartsState state);
}
