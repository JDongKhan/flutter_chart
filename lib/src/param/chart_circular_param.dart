part of flutter_chart_plus;

class _ChartCircularParam extends ChartParam {
  ///半径
  late double radius;

  ///中心点
  late Offset center;

  //边框宽度
  final double borderWidth;

  final ArcPosition arcPosition;

  _ChartCircularParam.coordinate({
    super.outDraw,
    super.controlValue,
    required super.childrenState,
    required ChartCircularCoordinateRender coordinate,
  })  : arcPosition = coordinate.arcPosition,
        borderWidth = coordinate.borderWidth;

  @override
  void init({required Size size, required EdgeInsets margin, required EdgeInsets padding}) {
    super.init(size: size, margin: margin, padding: padding);
    final sw = size.width - contentMargin.horizontal;
    final sh = size.height - contentMargin.vertical;
    //满圆
    if (arcPosition == ArcPosition.none) {
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
      if (arcPosition == ArcPosition.up) {
        center = Offset(center.dx, size.height - contentMargin.bottom);
        transform = TransformUtils(
          anchor: center,
          size: size,
          padding: padding,
          offset: offset,
          reverseX: false,
          reverseY: true,
        );
      } else if (arcPosition == ArcPosition.down) {
        center = Offset(center.dx, contentMargin.top);
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

  @override
  void scroll(Offset offset) {}
}
