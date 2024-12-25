part of flutter_chart_plus;

///圆形坐标系信息
class ChartCircularCoordinateState extends ChartCoordinateState {

  ChartCircularCoordinateState({
    required super.size,
    required super.margin,
    required super.padding,
    required super.controlValue,
    required this.borderWidth,
    required this.arcPosition,
  });

  //边框宽度
  final double borderWidth;

  ///弧口方向
  final ArcDirection arcPosition;

  ///半径
  late double radius;

  ///中心点
  late Offset center;

  @override
  void init() {
    final sw = size.width - content.horizontal;
    final sh = size.height - content.vertical;
    //满圆
    if (arcPosition == ArcDirection.none) {
      // 确定圆的半径
      radius = math.min(sw, sh) / 2 - borderWidth / 2;
      // 定义中心点
      center = size.center(Offset.zero);
      transform = TransformUtils(
        anchor: center,
        size: size,
        padding: padding,
        offset: offset,
        reverseX: false,
        reverseY: false,
      );
    } else {
      //带有弧度
      double maxSize = math.max(sw, sh);
      double minSize = math.min(sw, sh);
      radius = math.min(maxSize / 2, minSize) - borderWidth / 2;
      center = size.center(Offset.zero);
      if (arcPosition == ArcDirection.up) {
        center = Offset(center.dx, bottom);
        transform = TransformUtils(
          anchor: center,
          size: size,
          padding: padding,
          offset: offset,
          reverseX: false,
          reverseY: true,
        );
      } else if (arcPosition == ArcDirection.down) {
        center = Offset(center.dx, top);
        transform = TransformUtils(
          anchor: center,
          size: size,
          padding: padding,
          offset: offset,
          reverseX: false,
          reverseY: false,
        );
      }
    }
  }
}

class _ChartCircularState extends ChartsState {
  _ChartCircularState.coordinate({
    super.outDraw,
    required Size size,
    required EdgeInsets margin,
    required EdgeInsets padding,
    required super.chartsState,
    required ChartCircularCoordinateRender coordinate,
    double controlValue = 1,
  }) {
    super._layout = ChartCircularCoordinateState(
      size: size,
      margin: margin,
      padding: padding,
      controlValue: controlValue,
      arcPosition: coordinate.arcDirection,
      borderWidth: coordinate.borderWidth,
    );
  }

  @override
  void init() {
    super.layout.init();
  }

  @override
  void scrollByDelta(Offset delta) {}

  @override
  void scroll(Offset offset) {}
}
