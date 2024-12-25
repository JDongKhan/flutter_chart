part of flutter_chart_plus;

///坐标系布局信息
abstract class ChartCoordinateState {


  ChartCoordinateState({
    required this.size,
    required this.margin,
    required this.padding,
    required this.controlValue,
  }) {
    content = margin + padding;
  }

  ///尺寸
  final Size size;

  ///外间隙
  final EdgeInsets margin;

  ///内间隙
  final EdgeInsets padding;

  ///控制点
  final double controlValue;

  ///点击的位置
  Offset? localPosition;

  ///缩放级别
  double zoom = 1;

  ///滚动偏移
  Offset offset = Offset.zero;

  ///坐标转换工具
  late TransformUtils transform;

  ///图形内容的外边距信息
  late EdgeInsets _content;
  set content(EdgeInsets v) {
    _content = v;
    left = v.left;
    right = size.width - v.right;
    top = v.top;
    bottom = size.height - v.bottom;
    contentWidth = size.width - v.horizontal;
    contentHeight = size.height - v.vertical;
  }

  EdgeInsets get content => _content;

  late double left;
  late double right;
  late double top;
  late double bottom;
  late double contentWidth;
  late double contentHeight;

  double getPosForX(double position, [bool withOffset = false]) {
    double xPos = position + left;
    if (withOffset) {
      xPos = transform.withXScroll(xPos);
    }
    return xPos;
  }

  double getPosForY(double position) {
    double yPos = bottom - position;
    return yPos;
  }

  void init();
}
